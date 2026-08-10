#!/bin/sh
# Canonical MAME cross-build invocation for the rapi-circle target, per board.
# Usage: scripts/build-mame.sh [board] [-- extra make args]
#   board is rpi3 | rpi4 | rpi5 (default: $RAPI_BOARD, else rpi4).
# Logs: build/mame-build-<board>.log. Requires aarch64-none-elf-* on PATH.
#
# BUILD THE ENGINE ONCE, LINK THE DRIVERS PER PLATFORM. MAME's SOURCES-invariant
# half — the engine framework (libemu, libutil, the OSD core) and all of
# 3rdparty (bgfx, zlib, expat, flac, …) — is byte-identical across every
# platform we ship, so it is compiled exactly ONCE per board here, as a single
# mamedrivers subtarget (SUBTARGET=mamedrivers, SOURCES = every shipped platform's drivers
# together). The mamedrivers device/driver archives hold the SUPERSET device closure
# of all platforms; host/Makefile then links each platform kernel against that
# one shared engine with a per-platform drivlist it generates itself, so the
# linker keeps only that platform's machines and the kernel stays its usual size.
# One engine + N drivers, not N x full-engine.
#
# BOARD IS THE ISOLATION UNIT, BUILDDIR IS HOW IT IS ISOLATED. Circle's
# newlib+libc++ sysroot is baked per architecture, so MAME must be compiled once
# per board (Pi 3/4/5 = cortex-a53/-a72/-a76, RASPPI 3/4/5). All three boards
# share ONE MAME source tree (mame) and keep their artifacts apart under
# BUILDDIR=build/<board>: genie puts its generated project files, its generated
# sources and the whole object tree under BUILDDIR, so a board's build reads and
# writes nothing another board's build owns. Per-board differentiation is
# entirely in mk/cross's wrapper flags (-mcpu, -DRASPPI) plus the circle world
# (circle-libsdl2/circle-stdlib-<board>): nothing board-specific is baked into
# the MAME source.
#
# Two boards building AT THE SAME TIME in this tree is untested. Build them one
# after another.

set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MACHINES_MK="$ROOT/host/machines.mk"

# Split args into an optional board (before --) and pass-through make args.
BOARD=""
EXTRA=""
seen_sep=0
for a in "$@"; do
    if [ "$seen_sep" = 1 ]; then EXTRA="$EXTRA $a"; continue; fi
    if [ "$a" = "--" ]; then seen_sep=1; continue; fi
    BOARD="$a"
done
[ -n "$BOARD" ] || BOARD="${RAPI_BOARD:-rpi4}"
case "$BOARD" in
    rpi3|rpi4|rpi5) : ;;
    *) echo "build-mame.sh: unknown board '$BOARD' (rpi3|rpi4|rpi5)" >&2; exit 2 ;;
esac

# mk/cross's wrappers read RAPI_BOARD to pick RASPPI, -mcpu and the circle world.
export RAPI_BOARD="$BOARD"

MAMETREE="$ROOT/mame"
[ -d "$MAMETREE/src" ] || {
    echo "build-mame.sh: MAME tree '$MAMETREE' not checked out (git submodule update --init mame)" >&2
    exit 2
}

command -v aarch64-none-elf-ar >/dev/null || {
    echo "build-mame.sh: Arm GNU aarch64-none-elf toolchain not on PATH" >&2
    exit 1
}

# Read a machines.mk fact without pulling in the Circle build. The answer is
# captured into a shell variable, so make must not narrate its directory
# changes into stdout (see gen-bootmenu.sh).
q() { make --no-print-directory -s -f "$MACHINES_MK" "print-$1"; }

SUBTARGET="$(q MAMEDRIVERS_SUBTARGET)"
SOURCES="$(q PLATFORM_SOURCES_MAMEDRIVERS | tr -s ' ' ',')"
[ -n "$SUBTARGET" ] && [ -n "$SOURCES" ] || {
    echo "build-mame.sh: MAMEDRIVERS_SUBTARGET / PLATFORM_SOURCES_MAMEDRIVERS empty in machines.mk" >&2
    exit 2
}

mkdir -p "$ROOT/build"
cd "$MAMETREE"

echo "=== building $BOARD mamedrivers engine (subtarget=$SUBTARGET, tree=mame, build-dir=build/$BOARD) ==="
# BUILDDIR=build/$BOARD: this board's whole artifact tree inside the shared
# source tree. genie appends the TARGETOS subdir, so archives land in
# mame/build/$BOARD/rapi-circle/.
make -j"$(getconf _NPROCESSORS_ONLN)" \
    BUILDDIR="build/$BOARD" \
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
    $EXTRA 2>&1 | tee "$ROOT/build/mame-build-$BOARD.log" | tail -30

# genie's final host-style link always fails (it links for the build host); the
# archives are what matter, and host/Makefile links the kernel itself.
