#!/bin/sh
# Canonical MAME cross-build invocation for the rapi-circle target.
# Usage: scripts/build-mame.sh [platform ...] [-- extra make args]
#   (no platform args => every platform in machines.mk PLATFORMS)
# Logs: build/mame-build-<platform>.log. Requires aarch64-none-elf-* on PATH.
#
# PLATFORM IS THE LOGICAL UNIT — one MAME src/mame/<vendor>/ directory per
# platform, and there is NEVER crossover. Each platform is built in complete
# isolation: its own SUBTARGET, its own SOURCES (only that vendor's drivers),
# and — load-bearing — its own BUILDDIR (mame/build/<platform>). MAME's genie
# build output is scoped by TARGETOS, not by SUBTARGET: the engine libraries
# (libemu.a, libbgfx.a, obj/Release/…) live in bin/ and obj/ shared across every
# subtarget of one build tree. Two platforms sharing a tree would share those
# libraries, and one platform's rebuild — different SOURCES, different compile
# fingerprint — could silently invalidate or corrupt the other's already-built
# engine, surfacing only later as an unrelated broken kernel. A per-platform
# BUILDDIR keeps each platform's obj/, bin/ and generated/ entirely its own.

set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MACHINES_MK="$ROOT/host/machines.mk"

command -v aarch64-none-elf-ar >/dev/null || {
    echo "build-mame.sh: Arm GNU aarch64-none-elf toolchain not on PATH" >&2
    exit 1
}

# Read a machines.mk fact without pulling in the Circle build.
q() { make -s -f "$MACHINES_MK" "print-$1"; }

# Split args into platform names (before --) and pass-through make args (after).
PLATFORMS=""
EXTRA=""
seen_sep=0
for a in "$@"; do
    if [ "$seen_sep" = 1 ]; then EXTRA="$EXTRA $a"; continue; fi
    if [ "$a" = "--" ]; then seen_sep=1; continue; fi
    PLATFORMS="$PLATFORMS $a"
done
[ -n "$PLATFORMS" ] || PLATFORMS="$(q PLATFORMS)"

mkdir -p "$ROOT/build"
cd "$ROOT/mame"

for p in $PLATFORMS; do
    SUBTARGET="$(q "PLATFORM_SUBTARGET_$p")"
    SOURCES="$(q "PLATFORM_SOURCES_$p" | tr -s ' ' ',')"
    if [ -z "$SUBTARGET" ] || [ -z "$SOURCES" ]; then
        echo "build-mame.sh: unknown platform '$p' (see PLATFORMS in host/machines.mk)" >&2
        exit 2
    fi

    echo "=== building platform '$p' (subtarget=$SUBTARGET, build-dir=build/$p) ==="
    # BUILDDIR=build/<p>: the isolated tree. genie appends the TARGETOS subdir,
    # so archives land in mame/build/<p>/rapi-circle/.
    make -j"$(getconf _NPROCESSORS_ONLN)" \
        BUILDDIR="build/$p" \
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
        $EXTRA 2>&1 | tee "$ROOT/build/mame-build-$p.log" | tail -30

    # genie's final host-style link always fails (it links for the build host);
    # the archives are what matter, and host/Makefile links the kernel itself.
done
