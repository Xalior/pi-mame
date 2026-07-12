#!/bin/sh
# Commodore-platform MAME cross-build invocation for the rapi-circle target.
# Usage: scripts/build-mame-commodore.sh [extra make args]
# Log: build/mame-build-commodore.log. Requires aarch64-none-elf-* on PATH.
#
# Separate SUBTARGET/SOURCES from build-mame.sh's sinclair+amstrad build —
# platforms never share a binary. mame/build/rapi-circle is a single shared
# tree regardless of SUBTARGET (SOURCES-trimmed core libraries like libemu.a
# are NOT subtarget-isolated within it), so building this after build-mame.sh
# leaves the tree scoped to commodore only; rerun build-mame.sh to restore a
# sinclair/amstrad-scoped tree when needed.

set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

command -v aarch64-none-elf-ar >/dev/null || {
    echo "build-mame-commodore.sh: Arm GNU aarch64-none-elf toolchain not on PATH" >&2
    exit 1
}

mkdir -p "$ROOT/build"
cd "$ROOT/mame"
make -j"$(getconf _NPROCESSORS_ONLN)" \
    TARGETOS=rapi-circle \
    PLATFORM=arm64 \
    OSD=sdl \
    SUBTARGET=commodore \
    SOURCES=src/mame/commodore/c64.cpp \
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
    "$@" 2>&1 | tee "$ROOT/build/mame-build-commodore.log" | tail -30

# genie's final host-style link always fails (it links for the build host);
# the archives are what matter, and host/Makefile links the kernel itself.
