#!/bin/sh
# Canonical MAME cross-build invocation for the rapi-circle target, per board.
# Usage: scripts/build-mame.sh [board] [--all] [-- extra make args]
#   board is rpi3 | rpi4 | rpi5 (default: $RAPI_BOARD, else rpi4).
#   --all builds the engine with every driver MAME has, rather than only the
#   drivers the roster names. See "TWO ENGINES" below.
# Logs: build/mame-build-<board>.log, or -<board>-all.log with --all.
# Requires aarch64-none-elf-* on PATH.
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

# Split args into an optional board and an optional --all (both before --),
# and pass-through make args after it.
BOARD=""
EXTRA=""
ALL=0
seen_sep=0
for a in "$@"; do
    if [ "$seen_sep" = 1 ]; then EXTRA="$EXTRA $a"; continue; fi
    if [ "$a" = "--" ]; then seen_sep=1; continue; fi
    if [ "$a" = "--all" ]; then ALL=1; continue; fi
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

# TWO ENGINES, AND THEY ARE NOT INTERCHANGEABLE.
#
# The default engine holds only the drivers named by SOURCES, and a kernel may
# link no driver the engine does not carry. --all drops the filter, which is
# simply what MAME builds by default, and produces the engine the whole-tree
# kernels need. Its own build directory, so one never overwrites the other and
# both can exist at once.
#
# NOWERROR=1 is MAME's own switch for dropping -Werror. This compiler is newer
# than anything upstream builds with and proves a pair of sprintf calls in
# disc_sys.hxx can overflow their buffer. That is upstream's code and upstream's
# call, so a build flag says so rather than an edit to their source.
#
# -k so one run reports every wall instead of stopping at the first. This
# compiles the entire tree, and finding the failures one build at a time costs
# hours each.
if [ "$ALL" = 1 ]; then
    SUBTARGET=mame
    SOURCES=""
    BUILDSUB="$BOARD-all"
    WHAT="whole-tree"
    EXTRA="-k REGENIE=1 NOWERROR=1 $EXTRA"
else
    SUBTARGET="$(q MAMEDRIVERS_SUBTARGET)"
    SOURCES="$(q PLATFORM_SOURCES_MAMEDRIVERS | tr -s ' ' ',')"
    [ -n "$SUBTARGET" ] && [ -n "$SOURCES" ] || {
        echo "build-mame.sh: MAMEDRIVERS_SUBTARGET / PLATFORM_SOURCES_MAMEDRIVERS empty in machines.mk" >&2
        exit 2
    }
    BUILDSUB="$BOARD"
    WHAT="mamedrivers"
fi

# SOURCES is passed only when there is one. An empty SOURCES= on the command
# line is not the same as omitting it: genie takes it as a filter matching
# nothing and builds an engine with no drivers in it at all.
[ -n "$SOURCES" ] && SOURCES_ARG="SOURCES=$SOURCES" || SOURCES_ARG=""

mkdir -p "$ROOT/build"
cd "$MAMETREE"

echo "=== building $BOARD $WHAT engine (subtarget=$SUBTARGET, tree=mame, build-dir=build/$BUILDSUB) ==="
# BUILDDIR=build/$BUILDSUB: this engine's whole artifact tree inside the shared
# source tree. genie appends the TARGETOS subdir, so archives land in
# mame/build/$BUILDSUB/rapi-circle/. The two engines differ only in that name,
# which is what lets both exist at once.
make -j"$(getconf _NPROCESSORS_ONLN)" \
    BUILDDIR="build/$BUILDSUB" \
    TARGETOS=rapi-circle \
    PLATFORM=arm64 \
    OSD=sdl \
    SUBTARGET="$SUBTARGET" \
    $SOURCES_ARG \
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
    $EXTRA 2>&1 | tee "$ROOT/build/mame-build-$BUILDSUB.log" | tail -30

# genie's final host-style link always fails (it links for the build host); the
# archives are what matter, and host/Makefile links the kernel itself.
