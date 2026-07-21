#!/bin/sh
# mkcard.sh — assemble a platform card tree in build/card-<platform>-<tier>-<board>/.
#
# Usage: scripts/mkcard.sh <platform> <free|public> [assets-dir]
#        board comes from $RAPI_BOARD (rpi3|rpi4|rpi5; default rpi4).
#
# A platform card is one card per vendor-class (sinclair, amstrad, …) AND per
# board: pi-mame ships PER-BOARD cards, so each card carries exactly ONE board's
# firmware, picker and core. The boot picker is the front door; one platform
# binary serves every machine the card can run. The FREE/PUBLIC split is a CARD
# split, not a build split — the free and public cards carry the IDENTICAL
# platform binary and differ only in two generated things: the bootmenu.cfg
# (free lists only all-free machines; public the full roster) and the asset
# bundle.
#
# The tree is a complete FAT-root layout:
#   pi-mame-boot-<board>.img  the boot picker (what the Pi firmware boots)
#   kernel-<board>.img        the platform binary — the MAME core. The picker
#                             chain-boots it by this GENERIC name (the bootloader
#                             is board-generic and carries no pi-mame refs;
#                             menu-loader/kernel.h bakes SD:/kernel-<board>.img).
#   bootmenu.cfg       generated for this platform + tier (gen-bootmenu.sh)
#   config.txt         our host/config-card.txt (firmware boots the picker)
#   cmdline.txt        the card's regional canvas (see the note below)
#   firmware           this board's Foundation firmware set + DTBs (Circle's boot/)
#   roms/ next/ carts/ the tier's assets, if an assets dir is given
#
# Regional canvas: cmdline.txt is per-CARD, not per-machine, and a platform can
# span PAL and NTSC machines. The card defaults to the PAL canvas (the majority
# tube); the per-region-per-card design is an open PoC2 question (see
# docs/pi-mame-poc2.html "Platform cards"), not decided here.

set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PLATFORM="${1:?usage: mkcard.sh <platform> <free|public> [assets-dir]}"
TIER="${2:?usage: mkcard.sh <platform> <free|public> [assets-dir]}"
ASSETS="$3"

case "$TIER" in
    free|public) ;;
    *) echo "mkcard.sh: tier must be 'free' or 'public', got '$TIER'" >&2; exit 2 ;;
esac

# One card per board. RAPI_BOARD selects the picker image, the core, the circle
# world (for firmware) and the on-card board token in every filename.
BOARD="${RAPI_BOARD:-rpi4}"
case "$BOARD" in
    rpi3|rpi4|rpi5) ;;
    *) echo "mkcard.sh: unknown RAPI_BOARD '$BOARD' (rpi3|rpi4|rpi5)" >&2; exit 2 ;;
esac

# The picker image Circle names per board (RASPPI baked into its world):
#   rpi3 -> kernel8.img   rpi4 -> kernel8-rpi4.img   rpi5 -> kernel_2712.img
case "$BOARD" in
    rpi3) PICKER_IMG=kernel8.img ;;
    rpi4) PICKER_IMG=kernel8-rpi4.img ;;
    rpi5) PICKER_IMG=kernel_2712.img ;;
esac

PICKER="$ROOT/rapi-bootloader/menu-loader/build/$BOARD/$PICKER_IMG"
BINARY="$ROOT/host/build/$BOARD/kernel8-$PLATFORM.img"
SD="$ROOT/build/card-$PLATFORM-$TIER-$BOARD"

[ -f "$PICKER" ] || { echo "mkcard.sh: $PICKER not built (make -C rapi-bootloader menu-loader-$BOARD)" >&2; exit 1; }
[ -f "$BINARY" ] || { echo "mkcard.sh: $BINARY not built (make -C host RAPI_BOARD=$BOARD PLATFORM=$PLATFORM)" >&2; exit 1; }

# Firmware + ARM stub via Circle's own boot makefile (pinned revision). Firmware
# is board-agnostic Foundation firmware; the board's own circle world carries it.
BOOTDIR="$ROOT/circle-libsdl2/circle-stdlib-$BOARD/libs/circle/boot"
make -C "$BOOTDIR" firmware
[ "$BOARD" = rpi4 ] && make -C "$BOOTDIR" armstub64 || true

# Per-board Foundation firmware set. Pi 4 loads a secondary-core armstub; Pi 3
# loads its stage-1 bootcode.bin + start.elf; Pi 5 boots from EEPROM firmware
# (no start*.elf) and needs the d0-stepping overlay.
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
    else echo "mkcard.sh: warning: firmware file $f not in $BOOTDIR" >&2; fi
done
if [ "$BOARD" = rpi5 ]; then
    mkdir -p "$SD/overlays"
    [ -f "$BOOTDIR/bcm2712d0.dtbo" ] && cp "$BOOTDIR/bcm2712d0.dtbo" "$SD/overlays/" \
        || echo "mkcard.sh: warning: bcm2712d0.dtbo not in $BOOTDIR" >&2
fi

# Firmware boots pi-mame-boot-<board>.img (the PICKER); the picker chain-boots
# kernel-<board>.img (the platform binary — the MAME core).
cp "$ROOT/host/config-card.txt" "$SD/config.txt"
cp "$ROOT/host/cmdline-pal.txt" "$SD/cmdline.txt"
cp "$PICKER" "$SD/pi-mame-boot-$BOARD.img"
cp "$BINARY" "$SD/kernel-$BOARD.img"

# The tier's menu, generated fresh from the manifest.
"$ROOT/scripts/gen-bootmenu.sh" "$PLATFORM" "$TIER" > "$SD/bootmenu.cfg"

if [ -n "$ASSETS" ]; then
    for d in roms next carts; do
        [ -d "$ASSETS/$d" ] && cp -R "$ASSETS/$d" "$SD/$d" || true
    done
else
    echo "mkcard.sh: no assets dir given — add roms/ (and next/, carts/) to the card yourself" >&2
fi

echo "platform card ready ($BOARD): $SD"
find "$SD" -maxdepth 2 | sort
