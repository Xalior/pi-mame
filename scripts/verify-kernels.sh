#!/bin/sh
# verify-kernels.sh — assert every expected kernel image for a board exists and
# is under the 256MB ceiling: every per-machine image (roster from machines.mk),
# every platform binary (kernel8-<platform>.img, the no-options kernels), and
# the board's boot picker at its real per-board path.
#
# All artifacts are board-scoped under host/build/<board>/ (and the picker under
# rapi-bootloader/menu-loader/build/<board>/), so verifying one board never
# depends on another being built.
#
# `make platform machines` is the real gate; this is belt-and-braces, and it
# runs locally as well as in CI. Size read with `wc -c` (portable across GNU
# and BSD/macOS — no `stat -c` vs `-f` split).
#
# Usage: scripts/verify-kernels.sh [board]   (default $RAPI_BOARD, else rpi4)
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BOARD="${1:-${RAPI_BOARD:-rpi4}}"
case "$BOARD" in
    rpi3|rpi4|rpi5) ;;
    *) echo "verify-kernels.sh: unknown board '$BOARD' (rpi3|rpi4|rpi5)" >&2; exit 2 ;;
esac
MK="$ROOT/host/machines.mk"
HOSTDIR="$ROOT/host/build/$BOARD"
CEIL=268435456   # 256 MiB
fail=0

check() {   # <path>
    if [ ! -f "$1" ]; then echo "MISSING: $1"; fail=1; return; fi
    sz=$(wc -c < "$1" | tr -d '[:space:]')
    if [ "$sz" -ge "$CEIL" ]; then echo "OVERSIZE: $1 is $sz bytes (>= $CEIL)"; fail=1; return; fi
    echo "OK: $1 ($sz bytes)"
}

for m in $(make -s -f "$MK" print-MACHINES); do
    check "$HOSTDIR/kernel8-$m.img"
done
for p in $(make -s -f "$MK" print-PLATFORMS); do
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
echo "all $BOARD kernel images present and under the 256MB ceiling — OK."
