#!/bin/sh
# mksd.sh — assemble a copy-to-card SD tree in build/sd/.
#
# Usage: scripts/mksd.sh <machine> [assets-dir]
#
# One machine's single-purpose card. For a platform card (the boot picker plus
# a menu of a platform's machines) use scripts/mkcard.sh instead.
#
# The tree is a complete FAT-root layout: Raspberry Pi firmware (fetched at
# the revision pinned by circle/boot/Makefile, using Circle's own download
# mechanism), our host/config-machine.txt as config.txt (firmware boots the MAME
# core directly, no picker), the machine's regional canvas as cmdline.txt, the
# chosen kernel image as pi-mame-core-rpi4.img, and — if an assets directory is
# given — roms/, next/, and carts/ copied from it. ROMs, disk images, and
# cartridges are yours to provide; they are not part of this repository.

set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MACHINE="${1:?usage: mksd.sh <machine> [assets-dir]}"
ASSETS="$2"
SD="$ROOT/build/sd"
IMG="$ROOT/host/kernel8-$MACHINE.img"

# On-card board token: the core's board suffix (Circle's image-suffix vocab,
# matching the picker's SYSTEMBIT). PoC3 parameterizes this per board.
BOARD=rpi4

[ -f "$IMG" ] || { echo "mksd.sh: $IMG not built (make -C host MACHINE=$MACHINE)" >&2; exit 1; }

# Firmware + ARM stub via Circle's own boot makefile (pinned revision).
make -C "$ROOT/circle-libsdl2/circle-stdlib/libs/circle/boot" firmware armstub64

rm -rf "$SD"
mkdir -p "$SD"

for f in start4.elf fixup4.dat bcm2711-rpi-4-b.dtb bcm2711-rpi-400.dtb \
         bcm2711-rpi-cm4.dtb LICENCE.broadcom COPYING.linux \
         armstub8-rpi4.bin; do
    cp "$ROOT/circle-libsdl2/circle-stdlib/libs/circle/boot/$f" "$SD/"
done

# Our config.txt boots pi-mame-core-rpi4.img (the MAME core) directly on a Pi 4.
cp "$ROOT/host/config-machine.txt" "$SD/config.txt"
cp "$IMG" "$SD/pi-mame-core-$BOARD.img"

# The regional canvas: a machine's region picks its television. The American
# 60Hz machines fill the NTSC tube (720x480); everything else fills PAL
# (720x576).
case "$MACHINE" in
    ts2068|ts1000|ts1500|c64|c64_jp|c64c|sx64|dx64|pet64|edu64|vic20|vic1001|c264|plus4|c16|v364) CANVAS=cmdline-ntsc.txt ;;
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

echo "SD tree ready: $SD"
find "$SD" -maxdepth 2 | sort
