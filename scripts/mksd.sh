#!/bin/sh
# mksd.sh — assemble a copy-to-card SD tree in build/sd-<machine>-<board>/.
#
# Usage: scripts/mksd.sh <machine> [assets-dir]
#        board comes from $RAPI_BOARD (rpi3|rpi4|rpi5; default rpi4).
#
# One machine's single-purpose card, for ONE board (pi-mame ships per-board
# cards). For a platform card (the boot picker plus a menu of a platform's
# machines) use scripts/mkcard.sh instead.
#
# The tree is a complete FAT-root layout: this board's Raspberry Pi firmware
# (fetched at the revision pinned by circle/boot/Makefile, using Circle's own
# download mechanism), our host/config-machine.txt as config.txt (firmware boots
# the MAME core directly, no picker), the machine's regional canvas as
# cmdline.txt, the chosen kernel image as kernel-<board>.img, and — if an assets
# directory is given — roms/, next/, and carts/ copied from it. ROMs, disk
# images, and cartridges are yours to provide; not part of this repository.

set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MACHINE="${1:?usage: mksd.sh <machine> [assets-dir]}"
ASSETS="$2"

# One card per board. RAPI_BOARD selects the core, the circle world (firmware)
# and the on-card board token in every filename.
BOARD="${RAPI_BOARD:-rpi4}"
case "$BOARD" in
    rpi3|rpi4|rpi5) ;;
    *) echo "mksd.sh: unknown RAPI_BOARD '$BOARD' (rpi3|rpi4|rpi5)" >&2; exit 2 ;;
esac

SD="$ROOT/build/sd-$MACHINE-$BOARD"
IMG="$ROOT/host/build/$BOARD/kernel8-$MACHINE.img"

[ -f "$IMG" ] || { echo "mksd.sh: $IMG not built (make -C host RAPI_BOARD=$BOARD MACHINE=$MACHINE)" >&2; exit 1; }

# Firmware + ARM stub via Circle's own boot makefile (pinned revision). Firmware
# is board-agnostic Foundation firmware; the board's own circle world carries it.
BOOTDIR="$ROOT/circle-libsdl2/circle-stdlib-$BOARD/libs/circle/boot"
make -C "$BOOTDIR" firmware
[ "$BOARD" = rpi4 ] && make -C "$BOOTDIR" armstub64 || true

# Per-board Foundation firmware set (see mkcard.sh for the per-board rationale).
case "$BOARD" in
    rpi3) FW="bootcode.bin start.elf fixup.dat bcm2710-rpi-zero-2-w.dtb bcm2710-rpi-cm0.dtb" ;;
    rpi4) FW="start4.elf fixup4.dat armstub8-rpi4.bin bcm2711-rpi-4-b.dtb bcm2711-rpi-400.dtb bcm2711-rpi-cm4.dtb" ;;
    rpi5) FW="bcm2712-rpi-5-b.dtb bcm2712-rpi-500.dtb bcm2712d0-rpi-5-b.dtb" ;;
esac
FW="$FW LICENCE.broadcom COPYING.linux"

rm -rf "$SD"
mkdir -p "$SD"

for f in $FW; do
    if [ -f "$BOOTDIR/$f" ]; then cp "$BOOTDIR/$f" "$SD/"; \
    else echo "mksd.sh: warning: firmware file $f not in $BOOTDIR" >&2; fi
done
if [ "$BOARD" = rpi5 ]; then
    mkdir -p "$SD/overlays"
    [ -f "$BOOTDIR/bcm2712d0.dtbo" ] && cp "$BOOTDIR/bcm2712d0.dtbo" "$SD/overlays/" \
        || echo "mksd.sh: warning: bcm2712d0.dtbo not in $BOOTDIR" >&2
fi

# Firmware boots kernel-<board>.img (the MAME core) directly on this board.
cp "$ROOT/host/config-machine.txt" "$SD/config.txt"
cp "$IMG" "$SD/kernel-$BOARD.img"

# The regional canvas: a machine's region picks its television. The American
# 60Hz machines fill the NTSC tube (720x480); everything else fills PAL
# (720x576).
case "$MACHINE" in
    ts2068|ts1000|ts1500|c64|c64_jp|c64c|sx64|dx64|pet64|edu64|vic20|vic1001|c264|plus4|c16|v364|bbcb_us|a400|a800|a600xl|a800xl|a65xe|a800xe|xegs|m5|crvisioj|vsmile|vsmilem) CANVAS=cmdline-ntsc.txt ;;
    *)                    CANVAS=cmdline-pal.txt ;;
esac
cp "$ROOT/host/$CANVAS" "$SD/cmdline.txt"

if [ -n "$ASSETS" ]; then
    [ -d "$ASSETS/roms" ] && cp -R "$ASSETS/roms" "$SD/roms" \
        || echo "mksd.sh: warning: no roms/ in $ASSETS" >&2
    [ -d "$ASSETS/next" ] && cp -R "$ASSETS/next" "$SD/next" \
        || true
    [ -d "$ASSETS/carts" ] && cp -R "$ASSETS/carts" "$SD/carts" \
        || true
else
    echo "mksd.sh: no assets dir given — add roms/ (and next/ for tbblue) to the card yourself" >&2
fi

echo "SD tree ready ($BOARD): $SD"
find "$SD" -maxdepth 2 | sort
