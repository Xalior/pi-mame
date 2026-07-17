#!/bin/sh
# mkdist.sh — assemble the whole release: one platform-card zip per
# (platform, tier) into dist/. This IS the release machinery, run identically
# by a local user (`make dist`) and by CI, so the release path is always under
# test both ways — nothing release-shaped lives only in the CI workflow.
#
# Usage: scripts/mkdist.sh <tag> [assets-base-dir]
#   <tag>            names the zips: pi-mame-<tag>-<platform>-<tier>.zip
#   assets-base-dir  where the two fetched asset bundles land (default: repo root)
#
# Each tier carries its OWN assets — the whole point of the split. Free cards
# get the free-blessed set; public cards get the full set (free + the grey
# public ROMs). The public ROMs are NOT in this repo (keeping it legal):
# fetch-assets.sh pulls them from their mirrors HERE, at build time, into the
# release zip only. Both bundles are fetched once; each card copies from the one
# for its tier. A tier whose menu is empty (e.g. commodore-free — every
# commodore romset is public) ships no card: an empty menu is nothing to boot.
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TAG="${1:?usage: mkdist.sh <tag> [assets-base-dir]}"
ABASE="${2:-$ROOT}"
FREE="$ABASE/free-assets"
ALL="$ABASE/all-assets"
cd "$ROOT"

# Fetch both bundles once — the same make targets a user runs by hand.
make assets-free ASSETS="$FREE"
make assets      ASSETS="$ALL"

mkdir -p dist
for p in $(make -s -f host/machines.mk print-PLATFORMS); do
    for tier in free public; do
        # Skip only a truly empty menu (all lines '#' or blank). Counted with
        # awk, not `grep -qv '^#'` — the latter silently drops cards under a
        # non-GNU grep (e.g. ugrep), losing public cards from a release.
        entries=$(scripts/gen-bootmenu.sh "$p" "$tier" | awk '!/^#/ && NF' | wc -l)
        if [ "$entries" -eq 0 ]; then
            echo "skip: $p-$tier menu is empty"; continue
        fi
        case "$tier" in
            free)   ca="$FREE" ;;
            public) ca="$ALL"  ;;
        esac
        make card PLATFORM="$p" TIER="$tier" ASSETS="$ca"
        ( cd "build/card-$p-$tier" && zip -qr "../../dist/pi-mame-$TAG-$p-$tier.zip" . )
    done
done
ls -lh dist/
