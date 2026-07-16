#!/bin/sh
# Canonical MAME cross-build for the rapi-circle target — per board, per platform.
# Usage: scripts/build-mame.sh [board] [platform ...] [-- extra make args]
#   board is rpi3 | rpi4 | rpi5 (default: $RAPI_BOARD, else rpi4).
#   platforms default to every PLATFORM in host/machines.mk; name some to limit.
# Logs: build/mame-build-<board>-<platform>.log. Requires aarch64-none-elf-* on PATH.
#
# ONE ARCH PER CARD, NOTHING SHARED. Each platform builds its OWN complete MAME
# (the engine framework + all of 3rdparty + only that vendor's drivers) into
# mame-<board>/build/<platform> — genie generates into the tree and scopes obj/bin
# by BUILDDIR, so every platform is fully isolated. host/Makefile links each
# platform kernel against its own tree, using that tree's own drivlist. A shared
# "union" engine was tried and dropped: it was pure bloat (it dragged the whole
# superset device closure into every kernel), and never a need — one card is one
# arch is one platform's binary.
#
# BOARD IS THE ISOLATION UNIT (above platform). Circle's newlib+libc++ sysroot is
# baked per architecture, so MAME is compiled once per board (Pi 3/4/5 =
# cortex-a53/-a72/-a76, RASPPI 3/4/5), each in its own tree (mame-rpi3/4/5) and
# against its own hoisted circle world (circle-libsdl2/circle-stdlib-<board>).
# Per-board differentiation is entirely in mk/cross's wrapper flags (-mcpu,
# -DRASPPI) — nothing board-specific is baked into the MAME source. Mirrors the
# bootloader: each board is built on its own, never shared.

set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MACHINES_MK="$ROOT/host/machines.mk"

# Split args into an optional board, platform names, and pass-through make args.
BOARD=""
PLATFORMS_ARG=""
EXTRA=""
seen_sep=0
for a in "$@"; do
    if [ "$seen_sep" = 1 ]; then EXTRA="$EXTRA $a"; continue; fi
    if [ "$a" = "--" ]; then seen_sep=1; continue; fi
    case "$a" in
        rpi3|rpi4|rpi5) BOARD="$a" ;;
        *) PLATFORMS_ARG="$PLATFORMS_ARG $a" ;;
    esac
done
[ -n "$BOARD" ] || BOARD="${RAPI_BOARD:-rpi4}"

# mk/cross's wrappers read RAPI_BOARD to pick RASPPI, -mcpu and the circle world.
export RAPI_BOARD="$BOARD"

MAMETREE="$ROOT/mame-$BOARD"
[ -d "$MAMETREE" ] || {
    echo "build-mame.sh: MAME tree '$MAMETREE' not checked out (git submodule update --init $MAMETREE)" >&2
    exit 2
}
command -v aarch64-none-elf-ar >/dev/null || {
    echo "build-mame.sh: Arm GNU aarch64-none-elf toolchain not on PATH" >&2
    exit 1
}

# Read a machines.mk fact without pulling in the Circle build.
q() { make -s -f "$MACHINES_MK" "print-$1"; }

PLATFORMS="$PLATFORMS_ARG"
[ -n "$PLATFORMS" ] || PLATFORMS="$(q PLATFORMS)"

mkdir -p "$ROOT/build"
cd "$MAMETREE"

for P in $PLATFORMS; do
    SUBTARGET="$(q PLATFORM_SUBTARGET_$P)"
    SOURCES="$(q PLATFORM_SOURCES_$P | tr -s ' ' ',')"
    [ -n "$SUBTARGET" ] && [ -n "$SOURCES" ] || {
        echo "build-mame.sh: PLATFORM_SUBTARGET_$P / PLATFORM_SOURCES_$P empty in machines.mk" >&2
        exit 2
    }
    echo "=== building $BOARD/$P (subtarget=$SUBTARGET, tree=mame-$BOARD, build-dir=build/$P) ==="
    # BUILDDIR=build/<platform>: this platform's own isolated build. genie appends
    # the TARGETOS subdir, so archives land in mame-$BOARD/build/$P/rapi-circle/.
    # REGENIE=1: regenerate this subtarget's project so a SOURCES change is honoured.
    make -j"$(getconf _NPROCESSORS_ONLN)" \
        REGENIE=1 \
        BUILDDIR="build/$P" \
        TARGETOS=rapi-circle \
        PLATFORM=arm64 \
        OSD=sdl \
        SUBTARGET="$SUBTARGET" \
        SOURCES="$SOURCES" \
        OVERRIDE_CC="$ROOT/mk/cross/aarch64-circle-gcc" \
        OVERRIDE_CXX="$ROOT/mk/cross/aarch64-circle-g++" \
        OVERRIDE_AR="$(command -v aarch64-none-elf-ar)" \
        SDL_INSTALL_ROOT="$ROOT/mk/sdlroot" \
        NOASM=1 \
        FORCE_DRC_C_BACKEND=1 \
        NO_X11=1 \
        NO_USE_XINPUT=1 \
        USE_QTDEBUG=0 \
        NO_USE_MIDI=1 \
        NO_USE_PORTAUDIO=1 \
        USE_WAYLAND=0 \
        TOOLS=0 \
        $EXTRA 2>&1 | tee "$ROOT/build/mame-build-$BOARD-$P.log" | tail -20 || true
    # genie's final host-style link always fails (it links for the build host); the
    # archives are what matter, and host/Makefile links the kernel itself.
done
