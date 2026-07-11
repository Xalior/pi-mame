#!/bin/sh
# Canonical MAME cross-build invocation for the rapi-circle target.
# Usage: scripts/build-mame.sh [extra make args]
# Log: build/mame-build.log. Requires aarch64-none-elf-* on PATH.

set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

command -v aarch64-none-elf-ar >/dev/null || {
    echo "build-mame.sh: Arm GNU aarch64-none-elf toolchain not on PATH" >&2
    exit 1
}

mkdir -p "$ROOT/build"
cd "$ROOT/mame"
make -j"$(getconf _NPROCESSORS_ONLN)" \
    TARGETOS=rapi-circle \
    PLATFORM=arm64 \
    OSD=sdl \
    SUBTARGET=spectrum \
    SOURCES=src/mame/sinclair/spectrum.cpp,src/mame/sinclair/spec128.cpp,src/mame/sinclair/next/specnext.cpp,src/mame/sinclair/specpls3.cpp,src/mame/sinclair/zx.cpp,src/mame/sinclair/timex.cpp,src/mame/sinclair/pentagon.cpp,src/mame/sinclair/scorpion.cpp,src/mame/sinclair/atm.cpp,src/mame/sinclair/evo/pentevo.cpp,src/mame/sinclair/evo/tsconf.cpp \
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
    "$@" 2>&1 | tee "$ROOT/build/mame-build.log" | tail -30

# genie's final host-style link always fails (it links for the build host);
# the archives are what matter, and host/Makefile links the kernel itself.
