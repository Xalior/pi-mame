#!/bin/sh
# verify-kernels.sh — assert every expected kernel image for a board exists and
# is under that board's kernel ceiling: every per-machine image (roster from
# machines.mk), every platform binary (kernel8-<platform>.img, the no-options
# kernels), and the board's boot picker at its real per-board path.
#
# The ceiling is read from the world the images were built against, never
# written down here — see where CEIL is set.
#
# All artifacts are board-scoped under host/build/<board>/ (and the picker under
# rapi-bootloader/menu-loader/build/<board>/), so verifying one board never
# depends on another being built.
#
# `make platform machines` is the real gate; this is belt-and-braces, and it
# runs locally as well as in CI. Size read with `wc -c` (portable across GNU
# and BSD/macOS — no `stat -c` vs `-f` split).
#
# Usage: scripts/verify-kernels.sh [board] [scope]
#   board  rpi3|rpi4|rpi5 (default $RAPI_BOARD, else rpi4)
#   scope  all      every per-machine image + platform binaries + picker
#          platform platform binaries + picker only — what a release ships.
#                   Per-machine images are a local byte-patch of the platform
#                   binary (make kernel MACHINE=<m>); at roster scale the full
#                   set neither fits a CI runner's disk nor belongs in release
#                   assets, so CI gates on this scope (the patch path is still
#                   proven by CI's `make sd` smoke test).
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BOARD="${1:-${RAPI_BOARD:-rpi4}}"
SCOPE="${2:-all}"
case "$BOARD" in
    rpi3|rpi4|rpi5) ;;
    *) echo "verify-kernels.sh: unknown board '$BOARD' (rpi3|rpi4|rpi5)" >&2; exit 2 ;;
esac
case "$SCOPE" in
    all|platform) ;;
    *) echo "verify-kernels.sh: unknown scope '$SCOPE' (all|platform)" >&2; exit 2 ;;
esac
MK="$ROOT/host/machines.mk"
HOSTDIR="$ROOT/host/build/$BOARD"

# The ceiling is the world's, read from the world.
#
# It is decided when circle-libsdl2 configures a board's circle-stdlib
# (--kernel-max-size) and baked into that world's Config.mk as
# -DKERNEL_MAX_SIZE=0x... Everything downstream derives it from there, and a
# second copy written down here would be a copy that goes stale: it did, and
# the gate then passed images the world's own linker would have refused.
#
# Read, never guessed. A world that cannot be found, or a Config.mk with no
# such define, stops this script — a size gate that quietly invented its own
# limit would be worse than no gate, because it would report OK.
WORLD="${CIRCLE_WORLDS:-$ROOT/circle-libsdl2}/circle-stdlib-$BOARD"
[ -f "$WORLD/Config.mk" ] || {
    echo "verify-kernels.sh: no $WORLD/Config.mk — build the world first" >&2
    echo "  (or point CIRCLE_WORLDS at the set of worlds this build used)" >&2
    exit 2; }
CEIL_HEX=$(sed -n 's/.*-DKERNEL_MAX_SIZE=\(0[xX][0-9a-fA-F]*\).*/\1/p' "$WORLD/Config.mk" | head -1)
[ -n "$CEIL_HEX" ] || {
    echo "verify-kernels.sh: no KERNEL_MAX_SIZE in $WORLD/Config.mk" >&2; exit 2; }
CEIL=$(printf '%d' "$CEIL_HEX")
echo "ceiling: $CEIL bytes ($((CEIL / 1024 / 1024)) MiB, $CEIL_HEX) from $WORLD/Config.mk"
fail=0

check() {   # <path>
    if [ ! -f "$1" ]; then echo "MISSING: $1"; fail=1; return; fi
    sz=$(wc -c < "$1" | tr -d '[:space:]')
    if [ "$sz" -ge "$CEIL" ]; then echo "OVERSIZE: $1 is $sz bytes (>= $CEIL)"; fail=1; return; fi
    echo "OK: $1 ($sz bytes)"
}

# --no-print-directory: these rosters are captured into shell variables, and a
# narrating make would turn its own "Entering directory" banner into a machine
# name to check (see gen-bootmenu.sh).
if [ "$SCOPE" = all ]; then
    for m in $(make --no-print-directory -s -f "$MK" print-MACHINES); do
        check "$HOSTDIR/kernel8-$m.img"
    done
fi
for p in $(make --no-print-directory -s -f "$MK" print-PLATFORMS); do
    check "$HOSTDIR/kernel8-$p.img"
done

# The board's boot picker, at the per-board build path (Circle names the image
# per RASPPI: rpi3 -> kernel8.img, rpi4 -> kernel8-rpi4.img, rpi5 -> kernel_2712.img).
case "$BOARD" in
    rpi3) PICKER_IMG=kernel8.img ;;
    rpi4) PICKER_IMG=kernel8-rpi4.img ;;
    rpi5) PICKER_IMG=kernel_2712.img ;;
esac
check "$ROOT/rapi-bootloader/menu-loader/build/$BOARD/$PICKER_IMG"

[ "$fail" = 0 ] || { echo "kernel image verification failed"; exit 1; }
echo "all $BOARD kernel images present and under the ceiling — OK."
