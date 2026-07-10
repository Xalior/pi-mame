#!/bin/sh
# mksd.sh — assemble a copy-to-card SD tree in build/sd/.
#
# Usage: scripts/mksd.sh <spectrum|tbblue|picker> [assets-dir]
#
# The tree is a complete FAT-root layout: Raspberry Pi firmware (fetched at
# the revision pinned by circle/boot/Makefile, using Circle's own download
# mechanism), Circle's config64.txt as config.txt, the PAL canvas as
# cmdline.txt, the chosen kernel image, and — if an assets directory is
# given — roms/ and next/ copied from it. ROMs and disk images are yours
# to provide; they are not part of this repository.

set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MACHINE="${1:?usage: mksd.sh <spectrum|tbblue|picker> [assets-dir]}"
ASSETS="$2"
SD="$ROOT/build/sd"
IMG="$ROOT/host/kernel8-$MACHINE.img"

[ -f "$IMG" ] || { echo "mksd.sh: $IMG not built (make -C host MACHINE=$MACHINE)" >&2; exit 1; }

# Firmware + ARM stub via Circle's own boot makefile (pinned revision).
make -C "$ROOT/circle/boot" firmware armstub64

rm -rf "$SD"
mkdir -p "$SD"

for f in start4.elf fixup4.dat bcm2711-rpi-4-b.dtb bcm2711-rpi-400.dtb \
         bcm2711-rpi-cm4.dtb LICENCE.broadcom COPYING.linux \
         armstub8-rpi4.bin; do
    cp "$ROOT/circle/boot/$f" "$SD/"
done

# Circle's documented boot config selects kernel8-rpi4.img on a Pi 4.
cp "$ROOT/circle/boot/config64.txt" "$SD/config.txt"
cp "$IMG" "$SD/kernel8-rpi4.img"

# The regional canvas: every PAL machine fills the same PAL tube.
cp "$ROOT/host/cmdline-pal.txt" "$SD/cmdline.txt"

if [ -n "$ASSETS" ]; then
    [ -d "$ASSETS/roms" ] && cp -R "$ASSETS/roms" "$SD/roms" \
        || echo "mksd.sh: warning: no roms/ in $ASSETS" >&2
    [ -d "$ASSETS/next" ] && cp -R "$ASSETS/next" "$SD/next" \
        || true
else
    echo "mksd.sh: no assets dir given — add roms/ (and next/ for tbblue) to the card yourself" >&2
fi

echo "SD tree ready: $SD"
find "$SD" -maxdepth 2 | sort
