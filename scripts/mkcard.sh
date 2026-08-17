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
#   cmdline.txt        host/cmdline-native.txt (no mode request — see below)
#   firmware           this board's Foundation firmware set + DTBs (Circle's boot/)
#   roms/               romsets the card's OWN menu needs (rompath; untouched
#                       by the media layout below)
#   media/<type>/<driver>/  loose media (hard disk images, cartridges,
#                       cassettes, …) the card's OWN menu needs — one
#                       directory per MAME device instance type per driver
#                       short name, e.g. media/hard/tbblue/next.img
#                       These, and roms/, are populated only if an assets
#                       dir is given — each menu entry's manifest assets
#                       (MACHINE_ASSETS_* for a machine, trial-games.manifest
#                       for a trial title), never the whole bundle
#
# There are NO region cards. Every board boots the panel's native mode
# (cmdline.txt asks for none — asking is also what makes a Pi 5 firmware
# claim a mode it is not scanning out) and the shim's presentation core
# scales the picture onto it, aspect preserved. Region is a VIRTUAL
# resolution now: the kernel declares what MAME renders — the machine's own
# raster where its defaults string carries --rapi-vfb=WxH, the region
# canvas (720x576 PAL) otherwise.

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
cp "$ROOT/host/cmdline-native.txt" "$SD/cmdline.txt"
cp "$PICKER" "$SD/pi-mame-boot-$BOARD.img"
cp "$BINARY" "$SD/kernel-$BOARD.img"

# The tier's menu, generated fresh from the manifest.
"$ROOT/scripts/gen-bootmenu.sh" "$PLATFORM" "$TIER" > "$SD/bootmenu.cfg"

# The card carries the media its own menu asks for, and nothing else.
#
# A bootmenu.cfg line's label is either a real machine short name (a roster
# entry — MACHINE_ASSETS_* in host/machines.mk names its manifest assets:
# romset zips AND mounted media like /media/hard/tbblue/next.img) or a
# trial-game label (scripts/trial-games.manifest — free text, not a
# machine; its OWN line there names the one asset it mounts). Trial labels
# are excluded from the MACHINE_ASSETS_ lookup below (a label containing
# ':' or spaces is not a valid make target) and resolved separately.
# Every asset's manifest stanza names the card path (dest); copy exactly
# those files. A file absent from the bundle is the public tier's "boots
# but wants its ROMs added" case — warn, never fail the card.
if [ -n "$ASSETS" ]; then
    TRIAL_LABELS="$ROOT/scripts/trial-games.manifest"
    {
        for m in $(awk -F'|' '!/^#/ && NF {print $1}' "$SD/bootmenu.cfg"); do
            if [ -f "$TRIAL_LABELS" ] && \
               awk -F'|' -v p="$PLATFORM" -v l="$m" \
                   '$1=="trial" && $2==p && $3==l {found=1} END{exit !found}' \
                   "$TRIAL_LABELS"
            then
                continue
            fi
            make --no-print-directory -s -f "$ROOT/host/machines.mk" \
                "print-MACHINE_ASSETS_$m"
        done
        [ -f "$TRIAL_LABELS" ] && awk -F'|' -v p="$PLATFORM" \
            '$1=="trial" && $2==p {print $5}' "$TRIAL_LABELS"
    } | tr ' ' '\n' | sort -u | while IFS= read -r a; do
        [ -n "$a" ] || continue
        dest="$(awk -F'|' -v n="$a" '$1=="asset" && $2==n {print $5; exit}' \
            "$ROOT/scripts/assets.manifest")"
        if [ -z "$dest" ]; then
            echo "mkcard.sh: warning: no manifest stanza for asset '$a'" >&2
        elif [ -f "$ASSETS/$dest" ]; then
            mkdir -p "$SD/$(dirname "$dest")"
            cp "$ASSETS/$dest" "$SD/$dest"
        else
            echo "mkcard.sh: warning: $dest not in $ASSETS — add it to boot its machines" >&2
        fi
    done
else
    echo "mkcard.sh: no assets dir given — add roms/ (and media/ for its machines) to the card yourself" >&2
fi

echo "platform card ready ($BOARD): $SD"
find "$SD" -maxdepth 2 | sort
