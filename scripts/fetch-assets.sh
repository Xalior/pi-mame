#!/bin/sh
# fetch-assets.sh — fetch the ROMs, cartridge, and Next image pi-mame's
# machines need, from public upstreams, into an assets directory you own.
#
#   scripts/fetch-assets.sh <free|public|all> [ASSETS_DIR]
#
# Tiers (see scripts/assets.manifest for the doctrine and every source):
#   free    content whose redistribution is properly blessed, from a proper
#           upstream (Fuse / proteanthread under Amstrad's permission; the
#           SpecNext official distro).
#   public  publicly-available-but-grey MAME-set mirrors (archive.org).
#   all     both.
#
# This repository ships NO ROMs. The script fetches them; it offers, you choose.
# Every member is verified CRC32 + SHA1 against the manifest before install; a
# bad artifact is deleted and that asset reported FAILED (the run continues).
# next.img is the sole checksum-exempt asset (a live image whose version
# advances). Idempotent: an asset already present and valid is left untouched.

set -u

MODE="${1:-}"
ASSETS_DIR="${2:-./my-assets}"

case "$MODE" in
    free|public|all) ;;
    *) echo "usage: $0 <free|public|all> [ASSETS_DIR]" >&2; exit 2 ;;
esac

SELF_DIR=$(cd "$(dirname "$0")" && pwd)
MANIFEST="$SELF_DIR/assets.manifest"
[ -f "$MANIFEST" ] || { echo "fetch-assets: manifest not found: $MANIFEST" >&2; exit 2; }

# --- tool detection -----------------------------------------------------------
if command -v sha1sum >/dev/null 2>&1;  then SHA1="sha1sum"
elif command -v shasum >/dev/null 2>&1; then SHA1="shasum"
else echo "fetch-assets: need sha1sum or shasum" >&2; exit 2; fi
command -v unzip >/dev/null 2>&1 || { echo "fetch-assets: need unzip" >&2; exit 2; }
command -v zip   >/dev/null 2>&1 || { echo "fetch-assets: need zip" >&2; exit 2; }

HAVE_CURL=0; command -v curl >/dev/null 2>&1 && HAVE_CURL=1
HAVE_WGET=0; command -v wget >/dev/null 2>&1 && HAVE_WGET=1
[ "$HAVE_CURL" = 1 ] || [ "$HAVE_WGET" = 1 ] || { echo "fetch-assets: need curl or wget" >&2; exit 2; }

WORK=$(mktemp -d "${TMPDIR:-/tmp}/fetch-assets.XXXXXX") || exit 2
trap 'rm -rf "$WORK"' EXIT INT TERM
LEDGER="$WORK/ledger"
: > "$LEDGER"

# download <url> <outfile>  -> 0 on success (non-empty file)
download() {
    _u="$1"; _o="$2"
    if [ "$HAVE_CURL" = 1 ]; then
        curl -fsSL --retry 2 -o "$_o" "$_u" 2>/dev/null && [ -s "$_o" ] && return 0
    fi
    if [ "$HAVE_WGET" = 1 ]; then
        wget -q -O "$_o" "$_u" 2>/dev/null && [ -s "$_o" ] && return 0
    fi
    return 1
}

sha1_of() { "$SHA1" "$1" | cut -d' ' -f1; }

# CRC32 table of a zip: prints "<crc>|<member name>" per entry
zip_crc_table() {
    unzip -v "$1" 2>/dev/null | awk '
        $7 ~ /^[0-9a-f]{8}$/ { c=$7; $1=$2=$3=$4=$5=$6=$7=""; sub(/^ +/,""); print c"|"$0 }'
}

log()  { printf '%s\n' "$1" >> "$LEDGER"; }
note() { printf '  %s\n' "$1" >&2; }

# --- manifest helpers ---------------------------------------------------------
asset_srcs() { grep "^src|$1|" "$MANIFEST"; }
asset_mems() { grep "^mem|$1|" "$MANIFEST"; }

# Obtain one member into $1/<target>.  Tries each source in order.
# args: workdir name target crc sha raw
obtain_member() {
    _wd="$1"; _name="$2"; _tgt="$3"; _crc="$4"; _sha="$5"; _raw="$6"
    asset_srcs "$_name" | while IFS='|' read -r _ _ stype surl; do
        rm -f "$_wd/$_tgt"
        case "$stype" in
        raw)
            [ "$_raw" = "-" ] && continue
            case "$_raw" in
            *+*)   # concatenate parts
                _ok=1; : > "$_wd/$_tgt"
                _rest="$_raw"
                while [ -n "$_rest" ]; do
                    _part="${_rest%%+*}"
                    [ "$_part" = "$_rest" ] && _rest="" || _rest="${_rest#*+}"
                    if download "$surl/$_part" "$_wd/.part"; then
                        cat "$_wd/.part" >> "$_wd/$_tgt"; rm -f "$_wd/.part"
                    else _ok=0; break; fi
                done
                [ "$_ok" = 1 ] || continue
                ;;
            *)
                download "$surl/$_raw" "$_wd/$_tgt" || continue
                ;;
            esac
            ;;
        zip)
            _cache="$WORK/cache_${_name}_$(printf '%s' "$surl" | cksum | cut -d' ' -f1)"
            if [ ! -d "$_cache" ]; then
                mkdir -p "$_cache"
                if ! download "$surl" "$_cache/src.zip"; then rm -rf "$_cache"; continue; fi
                if ! unzip -qo "$_cache/src.zip" -d "$_cache/x" 2>/dev/null; then rm -rf "$_cache"; continue; fi
                zip_crc_table "$_cache/src.zip" > "$_cache/crc"
            fi
            _srcname=$(grep "^$_crc|" "$_cache/crc" | head -1 | cut -d'|' -f2-)
            [ -n "$_srcname" ] || continue
            [ -f "$_cache/x/$_srcname" ] || continue
            cp "$_cache/x/$_srcname" "$_wd/$_tgt" || continue
            ;;
        *) continue ;;
        esac
        # verify this member
        if [ "$(sha1_of "$_wd/$_tgt")" = "$_sha" ]; then
            printf 'ok\n' > "$_wd/.got_$_tgt"
            return 0
        fi
        rm -f "$_wd/$_tgt"
    done
    [ -f "$_wd/.got_$_tgt" ]
}

# Verify a built zip against the manifest members of asset $2. 0 = valid.
verify_zip() {
    _zip="$1"; _name="$2"
    [ -f "$_zip" ] || return 1
    zip_crc_table "$_zip" > "$WORK/vcrc" 2>/dev/null
    _vx="$WORK/vx"; rm -rf "$_vx"; mkdir -p "$_vx"
    unzip -qo "$_zip" -d "$_vx" 2>/dev/null || return 1
    _bad=0
    asset_mems "$_name" | while IFS='|' read -r _ _ tgt crc sha raw; do
        _found=$(grep "^$crc|" "$WORK/vcrc" | head -1 | cut -d'|' -f2-)
        [ "$_found" = "$tgt" ] || { echo bad > "$WORK/vbad"; break; }
        [ -f "$_vx/$tgt" ] || { echo bad > "$WORK/vbad"; break; }
        [ "$(sha1_of "$_vx/$tgt")" = "$sha" ] || { echo bad > "$WORK/vbad"; break; }
    done
    [ -f "$WORK/vbad" ] && { rm -f "$WORK/vbad"; return 1; }
    return 0
}

# --- per-kind handlers --------------------------------------------------------
do_zip() {
    _name="$1"; _dest="$2"
    _out="$ASSETS_DIR/$_dest"
    if [ -f "$_out" ] && verify_zip "$_out" "$_name"; then
        log "ALREADY-PRESENT  $_dest"; return
    fi
    _wd="$WORK/build_$_name"; rm -rf "$_wd"; mkdir -p "$_wd"
    _list="$_wd/.list"; : > "$_list"
    _fail=""
    asset_mems "$_name" | while IFS='|' read -r _ _ tgt crc sha raw; do
        if obtain_member "$_wd" "$_name" "$tgt" "$crc" "$sha" "$raw"; then
            printf '%s\n' "$tgt" >> "$_list"
        else
            echo "$tgt" > "$_wd/.missing"; break
        fi
    done
    if [ -f "$_wd/.missing" ]; then
        log "FAILED           $_dest  (could not fetch member: $(cat "$_wd/.missing"))"
        return
    fi
    rm -f "$_wd/out.zip"
    ( cd "$_wd" && zip -q -X "out.zip" -@ < ".list" ) || {
        log "FAILED           $_dest  (repack failed)"; return; }
    if verify_zip "$_wd/out.zip" "$_name"; then
        mkdir -p "$(dirname "$_out")"
        mv "$_wd/out.zip" "$_out"
        log "FETCHED          $_dest"
    else
        rm -f "$_wd/out.zip"
        log "FAILED           $_dest  (verification mismatch)"
    fi
}

do_file() {
    _name="$1"; _dest="$2"
    _out="$ASSETS_DIR/$_dest"
    # single member; target == the dest file basename
    set -- $(asset_mems "$_name" | head -1 | awk -F'|' '{print $3, $4, $5, $6}')
    _tgt="$1"; _crc="$2"; _sha="$3"; _raw="$4"
    if [ -f "$_out" ] && [ "$(sha1_of "$_out")" = "$_sha" ]; then
        log "ALREADY-PRESENT  $_dest"; return
    fi
    _wd="$WORK/file_$_name"; rm -rf "$_wd"; mkdir -p "$_wd"
    if obtain_member "$_wd" "$_name" "$_tgt" "$_crc" "$_sha" "$_raw"; then
        mkdir -p "$(dirname "$_out")"
        mv "$_wd/$_tgt" "$_out"
        log "FETCHED          $_dest"
    else
        log "FAILED           $_dest  (could not fetch/verify)"
    fi
}

# next.img: checksum-exempt. Scrape the distro page for the current download,
# fetch it, and install a plausible .img if the distro carries one.
do_image() {
    _name="$1"; _dest="$2"
    _out="$ASSETS_DIR/$_dest"
    if [ -f "$_out" ] && [ "$(wc -c < "$_out")" -gt 268435456 ]; then
        log "ALREADY-PRESENT  $_dest"; return
    fi
    _page=$(asset_srcs "$_name" | grep '|page|' | head -1 | cut -d'|' -f4)
    [ -n "$_page" ] || { log "FAILED           $_dest  (no page source)"; return; }
    if ! download "$_page" "$WORK/distro.html"; then
        log "FAILED           $_dest  (distro page unreachable: $_page)"; return
    fi
    # newest-looking distro archive link on the page
    _link=$(grep -oiE 'href="[^"]*\.(zip|7z|img)"' "$WORK/distro.html" \
            | sed 's/^href="//I;s/"$//' | grep -iE 'complete|distro|sd|next|sn-' \
            | head -1)
    case "$_link" in
        /*)  _link="https://www.specnext.com$_link" ;;
        http*) ;;
        "" ) log "FAILED           $_dest  (no download link on $_page — page shape changed?)"; return ;;
        *)   _link="https://www.specnext.com/$_link" ;;
    esac
    note "next.img: official distro at $_link"
    if ! download "$_link" "$WORK/distro.dl"; then
        log "FAILED           $_dest  (distro download failed: $_link)"; return
    fi
    _img=""
    if unzip -qo "$WORK/distro.dl" -d "$WORK/distro" 2>/dev/null; then
        _img=$(find "$WORK/distro" -type f -iname '*.img' -size +262144k 2>/dev/null | head -1)
    fi
    if [ -n "$_img" ]; then
        mkdir -p "$(dirname "$_out")"
        mv "$_img" "$_out"
        log "FETCHED          $_dest  (checksum-exempt; $(wc -c < "$_out") bytes)"
    else
        log "FAILED           $_dest  (official distro ships a file tree, no raw SD .img — build next.img yourself; see README)"
    fi
}

# --- main loop ----------------------------------------------------------------
echo "fetch-assets: mode=$MODE  ->  $ASSETS_DIR" >&2
mkdir -p "$ASSETS_DIR"

grep '^asset|' "$MANIFEST" | while IFS='|' read -r _ name tier kind dest; do
    case "$MODE" in
        free)   [ "$tier" = "free" ]   || { log "SKIPPED(public)  $dest"; continue; } ;;
        public) [ "$tier" = "public" ] || { log "SKIPPED(free)    $dest"; continue; } ;;
    esac
    note "-> $name ($tier, $dest)"
    case "$kind" in
        zip)   do_zip   "$name" "$dest" ;;
        file)  do_file  "$name" "$dest" ;;
        image) do_image "$name" "$dest" ;;
    esac
done

# --- ledger -------------------------------------------------------------------
echo
echo "================ asset ledger ($MODE) ================"
sort "$LEDGER"
echo "====================================================="
_fetched=$(grep -c '^FETCHED'         "$LEDGER"); _fetched=${_fetched:-0}
_present=$(grep -c '^ALREADY-PRESENT' "$LEDGER"); _present=${_present:-0}
_failed=$(grep  -c '^FAILED'          "$LEDGER"); _failed=${_failed:-0}
_skipped=$(grep -c '^SKIPPED'         "$LEDGER"); _skipped=${_skipped:-0}
echo "FETCHED=$_fetched  ALREADY-PRESENT=$_present  FAILED=$_failed  SKIPPED=$_skipped"

# Non-zero only if EVERYTHING attempted failed (partial success is normal).
_attempted=$((_fetched + _present + _failed))
if [ "$_attempted" -gt 0 ] && [ "$_fetched" -eq 0 ] && [ "$_present" -eq 0 ]; then
    exit 1
fi
exit 0
