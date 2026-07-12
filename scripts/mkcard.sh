#!/bin/sh
# mkcard.sh — assemble a platform card tree in build/card-<platform>-<tier>/.
#
# Usage: scripts/mkcard.sh <platform> <free|public> [assets-dir]
#
# A platform card is one card per vendor-class (sinclair, amstrad, …): the boot
# picker is the front door, and one platform binary serves every machine the
# card can run. The FREE/PUBLIC split is a CARD split, not a build split — the
# free and public cards carry the IDENTICAL platform binary and differ only in
# two generated things: the bootmenu.cfg (free lists only all-free machines;
# public the full roster) and the asset bundle.
#
# The tree is a complete FAT-root layout:
#   kernel8-rpi4.img   the boot picker (what the Pi firmware boots)
#   pi-mame-rpi4.img   the platform binary (what the picker chain-boots and
#                      patches per pick — SYSTEMBIT rpi4, see boot-picker/kernel.h)
#   bootmenu.cfg       generated for this platform + tier (gen-bootmenu.sh)
#   config.txt         Circle's config64.txt
#   cmdline.txt        the card's regional canvas (see the note below)
#   firmware           start4.elf, fixups, dtbs, armstub — Circle's pinned revision
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

PICKER="$ROOT/boot-picker/kernel8-rpi4.img"
BINARY="$ROOT/host/kernel8-$PLATFORM.img"
SD="$ROOT/build/card-$PLATFORM-$TIER"

[ -f "$PICKER" ] || { echo "mkcard.sh: $PICKER not built (make picker)" >&2; exit 1; }
[ -f "$BINARY" ] || { echo "mkcard.sh: $BINARY not built (make -C host PLATFORM=$PLATFORM)" >&2; exit 1; }

# Firmware + ARM stub via Circle's own boot makefile (pinned revision).
make -C "$ROOT/circle/boot" firmware armstub64

rm -rf "$SD"
mkdir -p "$SD"

for f in start4.elf fixup4.dat bcm2711-rpi-4-b.dtb bcm2711-rpi-400.dtb \
         bcm2711-rpi-cm4.dtb LICENCE.broadcom COPYING.linux \
         armstub8-rpi4.bin; do
    cp "$ROOT/circle/boot/$f" "$SD/"
done

# Circle's documented boot config selects kernel8-rpi4.img on a Pi 4 — that is
# the PICKER; the picker then chain-boots pi-mame-rpi4.img (the platform binary).
cp "$ROOT/circle/boot/config64.txt" "$SD/config.txt"
cp "$ROOT/host/cmdline-pal.txt" "$SD/cmdline.txt"
cp "$PICKER" "$SD/kernel8-rpi4.img"
cp "$BINARY" "$SD/pi-mame-rpi4.img"

# The tier's menu, generated fresh from the manifest.
"$ROOT/scripts/gen-bootmenu.sh" "$PLATFORM" "$TIER" > "$SD/bootmenu.cfg"

if [ -n "$ASSETS" ]; then
    for d in roms next carts; do
        [ -d "$ASSETS/$d" ] && cp -R "$ASSETS/$d" "$SD/$d" || true
    done
else
    echo "mkcard.sh: no assets dir given — add roms/ (and next/, carts/) to the card yourself" >&2
fi

echo "platform card ready: $SD"
find "$SD" -maxdepth 2 | sort
