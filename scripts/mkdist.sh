#!/bin/sh
# mkdist.sh — assemble the whole release: one platform-card zip per
# (board, platform, tier) into dist/. This IS the release machinery, run
# identically by a local user (`make dist`) and by CI, so the release path is
# always under test both ways — nothing release-shaped lives only in CI.
#
# Usage: scripts/mkdist.sh <tag> [assets-base-dir]
#   <tag>            names the zips: pi-mame-<tag>-<platform>-<tier>-<board>.zip
#   assets-base-dir  where the two fetched asset bundles land (default: repo root)
#   $BOARDS          which boards to build (default "rpi3 rpi4 rpi5")
#
# pi-mame ships PER-BOARD cards, so the matrix is board × platform × tier: each
# zip is one board's single-board card. The FREE/PUBLIC split carries its OWN
# assets — the whole point of the split. Free cards get the free-blessed set;
# public cards get the full set (free + the grey public ROMs). The public ROMs
# are NOT in this repo (keeping it legal): fetch-assets.sh pulls them from their
# mirrors HERE, at build time, into the release zip only. Both bundles are
# fetched once; each card copies from the one for its tier. A tier whose menu is
# empty (e.g. commodore-free — every commodore romset is public) ships no card:
# an empty menu is nothing to boot.
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TAG="${1:?usage: mkdist.sh <tag> [assets-base-dir]}"
ABASE="${2:-$ROOT}"
BOARDS="${BOARDS:-rpi3 rpi4 rpi5}"
FREE="$ABASE/free-assets"
ALL="$ABASE/all-assets"
cd "$ROOT"

# Fetch both bundles once — the same make targets a user runs by hand. Assets
# are board-agnostic (ROMs are not architecture-specific), so this is done once,
# outside the board loop.
make assets-free ASSETS="$FREE"
make assets      ASSETS="$ALL"

mkdir -p dist
for b in $BOARDS; do
    # --no-print-directory: the roster is captured into a shell variable, so a
    # narrating make would add "Entering directory" as a platform to card up
    # (see gen-bootmenu.sh).
    for p in $(make --no-print-directory -s -f host/machines.mk print-PLATFORMS); do
        for tier in free public; do
            # Skip only a truly empty menu (all lines '#' or blank). Counted with
            # awk, not `grep -qv '^#'` — the latter silently drops cards under a
            # non-GNU grep (e.g. ugrep), losing public cards from a release. The
            # menu is board-independent, but the check is cheap to repeat.
            entries=$(scripts/gen-bootmenu.sh "$p" "$tier" | awk '!/^#/ && NF' | wc -l)
            if [ "$entries" -eq 0 ]; then
                echo "skip: $p-$tier menu is empty"; continue
            fi
            case "$tier" in
                free)   ca="$FREE" ;;
                public) ca="$ALL"  ;;
            esac
            make card RAPI_BOARD="$b" PLATFORM="$p" TIER="$tier" ASSETS="$ca"
            ( cd "build/card-$p-$tier-$b" && zip -qr "../../dist/pi-mame-$TAG-$p-$tier-$b.zip" . )
        done

        # The platform binary ships as a release asset in its own right, and it
        # is NAMED HERE, by the release machinery, for the same reason the zips
        # are: every board builds a file called kernel8-<platform>.img, and a
        # GitHub release's assets are a flat namespace keyed on filename. Three
        # boards' identically-named images collide there and two are silently
        # discarded — so the board token goes into the name at the point the
        # release is assembled, not left to whatever collects the files.
        # Built already if either tier produced a card; built here if a platform
        # shipped no card at all (both menus empty) so the binary still ships.
        [ -f "host/build/$b/kernel8-$p.img" ] || \
            make -C host RAPI_BOARD="$b" PLATFORM="$p"
        cp "host/build/$b/kernel8-$p.img" "dist/pi-mame-$TAG-$p-$b.img"
    done
done
ls -lh dist/
