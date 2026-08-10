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
# directory is given — roms/ and this one machine's own loose media (from
# media/<type>/<driver>/ in the assets dir, MACHINE_ASSETS_<machine> in
# host/machines.mk naming which). ROMs, disk images, and cartridges are yours
# to provide; not part of this repository.

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

[ -f "$IMG" ] || { echo "mksd.sh: $IMG not built (make kernel RAPI_BOARD=$BOARD MACHINE=$MACHINE)" >&2; exit 1; }

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

# There are NO region cards: every board boots the panel's native mode
# (cmdline.txt asks for none) and the shim scales onto it. Region is a
# virtual resolution — the kernel declares MAME's display (--virtual-resolution
# per machine, the 720x576 PAL canvas otherwise).
cp "$ROOT/host/cmdline-native.txt" "$SD/cmdline.txt"

if [ -n "$ASSETS" ]; then
    [ -d "$ASSETS/roms" ] && cp -R "$ASSETS/roms" "$SD/roms" \
        || echo "mksd.sh: warning: no roms/ in $ASSETS" >&2
    # This machine's own loose media (MACHINE_ASSETS_<machine> in
    # host/machines.mk), each asset's manifest stanza naming the card path
    # (dest) under the ruled media/<type>/<driver>/ layout — the
    # media/hard/tbblue/next.img precedent (mkcard.sh copies the same way
    # for a whole platform's roster).
    for a in $(make --no-print-directory -s -f "$ROOT/host/machines.mk" \
                    "print-MACHINE_ASSETS_$MACHINE"); do
        dest="$(awk -F'|' -v n="$a" '$1=="asset" && $2==n {print $5; exit}' \
            "$ROOT/scripts/assets.manifest")"
        [ -n "$dest" ] || continue
        case "$dest" in roms/*) continue ;; esac  # already copied above
        if [ -f "$ASSETS/$dest" ]; then
            mkdir -p "$SD/$(dirname "$dest")"
            cp "$ASSETS/$dest" "$SD/$dest"
        else
            echo "mksd.sh: warning: $dest not in $ASSETS — add it to boot $MACHINE" >&2
        fi
    done
else
    echo "mksd.sh: no assets dir given — add roms/ (and its media/ for $MACHINE) to the card yourself" >&2
fi

echo "SD tree ready ($BOARD): $SD"
find "$SD" -maxdepth 2 | sort
