#!/bin/sh
# verify-kernels.sh — assert every expected kernel image exists and is under
# the 256MB ceiling: every per-machine image (roster from machines.mk), every
# platform binary (kernel8-<platform>.img, the no-options kernels), and — on
# rpi4 — the boot picker at its real path (rapi-bootloader/menu-loader/).
#
# `make platform machines` is the real gate; this is belt-and-braces, and it
# runs locally as well as in CI. Size read with `wc -c` (portable across GNU
# and BSD/macOS — no `stat -c` vs `-f` split).
#
# Usage: scripts/verify-kernels.sh [board]   (default $RAPI_BOARD, else rpi4)
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BOARD="${1:-${RAPI_BOARD:-rpi4}}"
MK="$ROOT/host/machines.mk"
CEIL=268435456   # 256 MiB
fail=0

check() {   # <path>
    if [ ! -f "$1" ]; then echo "MISSING: $1"; fail=1; return; fi
    sz=$(wc -c < "$1" | tr -d '[:space:]')
    if [ "$sz" -ge "$CEIL" ]; then echo "OVERSIZE: $1 is $sz bytes (>= $CEIL)"; fail=1; return; fi
    echo "OK: $1 ($sz bytes)"
}

for m in $(make -s -f "$MK" print-MACHINES); do
    check "$ROOT/host/kernel8-$m.img"
done
for p in $(make -s -f "$MK" print-PLATFORMS); do
    check "$ROOT/host/kernel8-$p.img"
done
[ "$BOARD" = rpi4 ] && check "$ROOT/rapi-bootloader/menu-loader/kernel8-rpi4.img"

[ "$fail" = 0 ] || { echo "kernel image verification failed"; exit 1; }
echo "all kernel images present and under the 256MB ceiling — OK."
