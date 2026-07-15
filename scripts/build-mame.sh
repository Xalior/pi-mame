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
# UNION subtarget (SUBTARGET=union, SOURCES = every shipped platform's drivers
# together). The union's device/driver archives hold the SUPERSET device closure
# of all platforms; host/Makefile then links each platform kernel against that
# one shared engine with a per-platform drivlist it generates itself, so the
# linker keeps only that platform's machines and the kernel stays its usual size.
# One engine + N drivers, not N x full-engine.
#
# BOARD IS THE ISOLATION UNIT. Circle's newlib+libc++ sysroot is baked per
# architecture, so MAME must be compiled once per board (Pi 3/4/5 = cortex-a53/
# -a72/-a76, RASPPI 3/4/5). Each board builds in its OWN MAME source tree
# (mame-rpi3 / mame-rpi4 / mame-rpi5) — genie generates into the tree and cannot
# share one across concurrent builds — so the three boards are fully independent
# and dispatchable to concurrent CI jobs, one board per runner. Per-board
# differentiation is entirely in mk/cross's wrapper flags (-mcpu, -DRASPPI) plus
# the hoisted circle world (circle-libsdl2/circle-stdlib-<board>): nothing
# board-specific is baked into the MAME source.

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

SUBTARGET="$(q UNION_SUBTARGET)"
SOURCES="$(q PLATFORM_SOURCES_UNION | tr -s ' ' ',')"
[ -n "$SUBTARGET" ] && [ -n "$SOURCES" ] || {
    echo "build-mame.sh: UNION_SUBTARGET / PLATFORM_SOURCES_UNION empty in machines.mk" >&2
    exit 2
}

mkdir -p "$ROOT/build"
cd "$MAMETREE"

echo "=== building $BOARD union engine (subtarget=$SUBTARGET, tree=mame-$BOARD, build-dir=build/union) ==="
# BUILDDIR=build/union: the board tree's single build. genie appends the TARGETOS
# subdir, so archives land in mame-$BOARD/build/union/rapi-circle/.
make -j"$(getconf _NPROCESSORS_ONLN)" \
    BUILDDIR="build/union" \
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
