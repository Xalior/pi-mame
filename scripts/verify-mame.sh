#!/bin/sh
# verify-mame.sh — truth-gate for a board's shared mamedrivers engine build.
#
# build-mame.sh tees through `tail`, and genie's final host-style link ALWAYS
# fails by design (it links for the build host; our kernel links the archives
# itself), so the make pipe can exit non-fatally even on a real failure. This
# checks the REAL success criteria for the board's mamedrivers tree: the two
# SOURCES-invariant objects host/Makefile links (mame.o, version.o), the OSD
# archive, and the driver archives. Absent => a genuine compile failure hid
# behind genie's by-design host-link failure; fail here.
#
# Usage: scripts/verify-mame.sh [board]   (rpi3|rpi4|rpi5; default $RAPI_BOARD, else rpi4)
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BOARD="${1:-${RAPI_BOARD:-rpi4}}"

st=$(make -s -f "$ROOT/host/machines.mk" print-MAMEDRIVERS_SUBTARGET)
MB="$ROOT/mame-$BOARD/build/mamedrivers/rapi-circle"
ok=1
[ -f "$MB/obj/Release/src/mame/mame.o" ]     || { echo "MISSING: $MB/obj/Release/src/mame/mame.o"; ok=0; }
[ -f "$MB/obj/Release/generated/version.o" ] || { echo "MISSING: $MB/obj/Release/generated/version.o"; ok=0; }
[ -f "$MB/bin/libosd_sdl.a" ]                || { echo "MISSING: $MB/bin/libosd_sdl.a"; ok=0; }
if ls "$MB"/bin/mame_"$st"/*.a >/dev/null 2>&1; then :; else
    echo "MISSING: $MB/bin/mame_$st/*.a"; ok=0
fi

echo "mamedrivers archive tree size:"; du -sh "$MB" 2>/dev/null || true
if [ "$ok" != 1 ]; then
    echo "mamedrivers archives absent — a real compile failure hid behind genie's"
    echo "by-design host-link failure. See build/mame-build-$BOARD.log."
    exit 1
fi
echo "genie's host link failed on purpose; the real archives are present — OK."
