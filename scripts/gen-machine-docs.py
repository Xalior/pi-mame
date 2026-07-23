#!/usr/bin/env python3
"""
gen-machine-docs.py — generate a platform's docs/<platform>/README.md and
docs/<platform>/<machine>.md pages straight from source, so they can never
drift: every fact is read fresh, nothing is hand-typed.

Usage: scripts/gen-machine-docs.py <platform>

Ground truth (read fresh every run, nothing cached or hand-maintained):
  host/machines.mk        the roster (PLATFORM_MACHINES_<platform>), each
                           machine's asset needs (MACHINE_ASSETS_<machine>)
                           and the platform's own MAME driver SOURCES
                           (PLATFORM_SOURCES_<platform>) — read via
                           `make -f host/machines.mk print-<VAR>`, the same
                           mechanism scripts/gen-bootmenu.sh uses, so this
                           generator sees exactly what the build sees.
  scripts/assets.manifest each asset's tier (free/public) and destination
                           zip path.
  mame-rpi4/<SOURCES>      the platform's MAME driver files: GAME()/COMP()/
                           CONS()/SYST() macro invocations give YEAR,
                           MANUFACTURER and TITLE; ROM_START(<machine>)
                           blocks give the ROM filenames + CRC32 for that
                           machine's own zip, verbatim. A ROM_START that is
                           just a bare reference to a #define'd macro (the
                           BIOS-root pattern) is expanded one level to
                           produce that shared asset's own table.
  ../docs/media/<platform> the meta repo's hardware-proof screenshots
                           (<machine>.jpg), copied into
                           docs/<platform>/images/ if present.

Nothing here is platform-specific by name: PLATFORM_SOURCES_<platform> tells
the generator which driver files to scan, so a later platform (PoC4: sinclair
/ amstrad / commodore) needs no code change, only its own machines.mk facts
and driver source to already exist. Re-running regenerates byte-identical
output from unchanged source — the generator is idempotent.
"""

import re
import shutil
import subprocess
import sys
from pathlib import Path

SCRIPT_ROOT = Path(__file__).resolve().parent.parent  # public/
MACHINES_MK = SCRIPT_ROOT / "host" / "machines.mk"
MANIFEST = SCRIPT_ROOT / "scripts" / "assets.manifest"
MAME_ROOT = SCRIPT_ROOT / "mame-rpi4"  # RAPI_BOARD default (host/Makefile); one MAME source tree per board, identical drivers
MEDIA_ROOT = SCRIPT_ROOT.parent / "docs" / "media"  # meta repo's hardware-proof screenshots

PLATFORM_DISPLAY = {
    "sinclair": "Sinclair",
    "amstrad": "Amstrad",
    "commodore": "Commodore",
    "amiga": "Amiga",
    "atari": "Atari",
    "acorn": "Acorn",
    "eaca": "EACA",
    "samcoupe": "SAM Coupé",
    "camputers": "Camputers",
    "tatung": "Tatung",
    "memotech": "Memotech",
    "enterprise": "Enterprise",
    "sord": "Sord",
}

# Per-platform README intro paragraph. The machines table, assets tree and
# shared-asset tables below it are fully generic; this paragraph is the one
# hand-authored fact block per platform.
PLATFORM_INTRO = {
    "amiga": (
        "The Arcadia Multi Select arcade platform: Arcadia Systems' "
        "ten-interchangeable-game coin-op cabinet built on Amiga A500 "
        "hardware (an A500 motherboard driving an external ROM cage through "
        "the expansion port). Each `make kernel MACHINE=<name>` below bakes "
        "one machine into its own `kernel8-<name>.img` — see the "
        "[top-level README](../../README.md) for the build and the regional "
        "canvas."
    ),
    "atari": (
        "The 8-bit Atari computer line: the 400/800 originals and the "
        "XL/XE range that followed them (MOS 6502C SALLY + ANTIC/GTIA/POKEY, "
        "`atari400.cpp` in MAME). Each `make kernel MACHINE=<name>` below "
        "bakes one machine into its own `kernel8-<name>.img` — see the "
        "[top-level README](../../README.md) for the build and the regional "
        "canvas."
    ),
    "acorn": (
        "The Acorn 8-bit line: the BBC Micro family — Model A/B, B+, Master, "
        "Master Compact and their rehousings (`bbcb`/`bbcbp`/`bbcm`/"
        "`bbcmc.cpp` in MAME) — plus the Electron (`electron.cpp`) and the "
        "Atom (`atom.cpp`), all built on the 6502. Each `make kernel "
        "MACHINE=<name>` below bakes one machine into its own "
        "`kernel8-<name>.img` — see the [top-level README](../../README.md) "
        "for the build and the regional canvas."
    ),
    "eaca": (
        "The EACA Colour Genie EG2000 line (`cgenie.cpp` in MAME): EACA's "
        "1982 Z80 home computer (HD6845 video, AY-3-8910 sound), in its "
        "European original and New Zealand variants. Each `make kernel "
        "MACHINE=<name>` below bakes one machine into its own "
        "`kernel8-<name>.img` — see the [top-level README](../../README.md) "
        "for the build and the regional canvas."
    ),
    "samcoupe": (
        "The MGT SAM Coupé (`samcoupe.cpp` in MAME): Miles Gordon "
        "Technology's 1989 Z80 home computer (6 MHz Z80, custom ASIC "
        "video, SAA1099 sound, two front drive bays). Each `make kernel "
        "MACHINE=<name>` below bakes one machine into its own "
        "`kernel8-<name>.img` — see the [top-level README](../../README.md) "
        "for the build and the regional canvas."
    ),
    "camputers": (
        "The Camputers Lynx line (`camplynx.cpp` in MAME): the British "
        "1983 Z80A home computer (Motorola 6845 video, one-voice beeper) "
        "in its 48k original and the 96k/128k models that followed it. "
        "Each `make kernel MACHINE=<name>` below bakes one machine into "
        "its own `kernel8-<name>.img` — see the "
        "[top-level README](../../README.md) for the build and the regional "
        "canvas."
    ),
    "tatung": (
        "The Tatung Einstein line (`einstein.cpp` in MAME): Tatung's 1984 "
        "Z80A floppy-CP/M machine, the Einstein TC-01 (TMS9129 video, "
        "AY-3-8910 sound, built-in 3\" drive), and the 1986 Einstein 256 "
        "(V9938 video). Each `make kernel MACHINE=<name>` below bakes one "
        "machine into its own `kernel8-<name>.img` — see the "
        "[top-level README](../../README.md) for the build and the regional "
        "canvas."
    ),
    "memotech": (
        "The Memotech MTX line (`mtx.cpp` in MAME): Memotech's 1983 Z80A "
        "home computers (TMS9929A video, SN76489A sound, aluminium case) — "
        "the MTX 512, the 32K MTX 500 and the 1984 RS 128 with its "
        "serial-board Z80DART. Each `make kernel MACHINE=<name>` below "
        "bakes one machine into its own `kernel8-<name>.img` — see the "
        "[top-level README](../../README.md) for the build and the regional "
        "canvas."
    ),
    "enterprise": (
        "The Enterprise line (`ep64.cpp` in MAME): Enterprise Computers' "
        "1985 Z80A home computer with its NICK video and DAVE sound custom "
        "chips \u2014 the Enterprise Sixty Four, its German Mephisto PHC 64 OEM "
        "sibling, and the 1986 Enterprise One Two Eight. Each `make kernel "
        "MACHINE=<name>` below bakes one machine into its own "
        "`kernel8-<name>.img` \u2014 see the [top-level README](../../README.md) "
        "for the build and the regional canvas."
    ),
    "sord": (
        "The Sord m.5 line (`m5.cpp` in MAME): Sord's 1983 Z80A home "
        "computer (TMS9928A/9929A video, SN76489A sound, twin cartridge "
        "slots) — the Japanese m.5, the European m.5p and the Czech BRNO "
        "mod with its WD2797 floppy and RAM disk. Each "
        "`make kernel MACHINE=<name>` below bakes one machine into its own "
        "`kernel8-<name>.img` — see the "
        "[top-level README](../../README.md) for the build and the regional "
        "canvas."
    ),
}

SYSTEM_MACROS = r"GAME|GAMEL|COMP|COMPX|COMPB|CONS|CONSX|SYST"


# --- host/machines.mk facts, via `make print-<VAR>` (never re-parsed by hand) ---

def make_var(var):
    result = subprocess.run(
        ["make", "-s", "-f", str(MACHINES_MK), f"print-{var}"],
        cwd=SCRIPT_ROOT, capture_output=True, text=True, check=True,
    )
    return result.stdout.strip()


def make_list(var):
    v = make_var(var)
    return v.split() if v else []


# --- scripts/assets.manifest: tier + zip path per asset ---

def load_manifest():
    assets = {}  # name -> {"tier": ..., "path": ...}
    for line in MANIFEST.read_text().splitlines():
        if not line.startswith("asset|"):
            continue
        _, name, tier, kind, dest = line.split("|", 4)
        assets[name] = {"tier": tier, "kind": kind, "path": dest}
    return assets


# --- MAME driver source: balanced-paren macro-call scanner ---

def iter_calls(text, name_pattern):
    """Yield (macro_name, call_body) for each `<name_pattern>( ... )`
    invocation in text, matching parens so args can themselves contain
    parens (e.g. CRC(xxxxxxxx))."""
    for m in re.finditer(rf"\b({name_pattern})\s*\(", text):
        name = m.group(1)
        i = m.end()
        depth = 1
        while depth > 0 and i < len(text):
            c = text[i]
            if c == "(":
                depth += 1
            elif c == ")":
                depth -= 1
            i += 1
        yield name, text[m.end():i - 1]


def split_top_level(s):
    """Split macro-call args on top-level commas, respecting quoted strings
    and nested parens (so a quoted fullname containing a comma is safe)."""
    args, cur, depth, in_str = [], "", 0, False
    i = 0
    while i < len(s):
        c = s[i]
        if in_str:
            cur += c
            if c == '"' and s[i - 1] != "\\":
                in_str = False
        elif c == '"':
            in_str = True
            cur += c
        elif c == "(":
            depth += 1
            cur += c
        elif c == ")":
            depth -= 1
            cur += c
        elif c == "," and depth == 0:
            args.append(cur.strip())
            cur = ""
        else:
            cur += c
        i += 1
    if cur.strip():
        args.append(cur.strip())
    return args


def parse_defines(text):
    """#define NAME ... (line-continued with trailing backslashes) -> body
    text, for expanding a bare macro reference inside a ROM_START block."""
    defines = {}
    lines = text.split("\n")
    i = 0
    while i < len(lines):
        m = re.match(r"^\s*#define\s+(\w+)\b(.*)$", lines[i])
        if m:
            name, body = m.group(1), [m.group(2)]
            while body[-1].rstrip().endswith("\\"):
                i += 1
                body.append(lines[i])
            defines[name] = "\n".join(body)
        i += 1
    return defines


def strip_disabled_blocks(text):
    """Drop disabled source before any scan: preprocessor `#if 0` ... `#endif`
    regions (tracking nested conditionals; einstein.cpp fences its diagnostic
    ROM this way) and `//` line comments (m5.cpp keeps alternate BRNO ROMs as
    commented-out ROM_LOAD lines). A disabled ROM_LOAD is not part of the
    romset MAME compiles, so it must never reach a docs ROM table."""
    out, depth = [], 0
    for line in text.split("\n"):
        stripped = line.lstrip()
        if depth == 0:
            if re.match(r"#\s*if\s+0\b", stripped):
                depth = 1
                continue
            out.append(re.sub(r"//.*", "", line))
        else:
            if re.match(r"#\s*(if|ifdef|ifndef)\b", stripped):
                depth += 1
            elif re.match(r"#\s*endif\b", stripped):
                depth -= 1
            continue
    return "\n".join(out)


def parse_rom_starts(text):
    """ROM_START(name) ... ROM_END -> {name: block body text}."""
    blocks = {}
    for m in re.finditer(r"ROM_START\(\s*(\w+)\s*\)", text):
        start = m.end()
        end = text.index("ROM_END", start)
        blocks[m.group(1)] = text[start:end]
    return blocks


def parse_system_macros(text):
    """GAME()/COMP()/CONS()/SYST() -> {name: {year, parent, company, fullname,
    is_bios_root}}. YEAR, NAME, PARENT are always the first three positional
    args across every one of these macro shapes; COMPANY and FULLNAME are
    simply the two quoted-string args (their positions vary by macro, the
    quoting doesn't); the flags arg (always last) may carry
    MACHINE_IS_BIOS_ROOT — the shared-BIOS link every other system's PARENT
    field points at, which is not a real clone relationship."""
    systems = {}
    for _, body in iter_calls(text, SYSTEM_MACROS):
        args = split_top_level(body)
        if len(args) < 3:
            continue
        # A string arg may be a u8"..." literal (samcoupe.cpp's fullname
        # carries the accented Coupé that way): strip the encoding prefix so
        # the quoted-string scan below still recognises it.
        norm = [a[2:] if a.startswith('u8"') else a for a in args]
        quoted = [a[1:-1] for a in norm if a.startswith('"') and a.endswith('"')]
        systems[args[1].strip()] = {
            "year": args[0].strip(),
            "parent": args[2].strip(),
            "company": quoted[0] if len(quoted) > 0 else None,
            "fullname": quoted[1] if len(quoted) > 1 else None,
            "is_bios_root": "MACHINE_IS_BIOS_ROOT" in args[-1],
        }
    return systems


# ROM_LOAD and its width variants (ROM_LOAD16_BYTE, ...), plus ROMX_LOAD —
# the BIOS-alternate loader. Multi-BIOS romsets (the BBC line's MOS
# revisions, Kickstart alternates) carry members ONLY via ROMX_LOAD, so
# omitting it drops those members from the table; MAME's own -listroms
# lists every BIOS alternate's members, and so does this.
ROM_LOAD_MACROS = r"ROM_LOAD\w*|ROMX_LOAD"


def rom_entries_in_block(block):
    """Literal ROM_LOAD*(...) calls directly in this block: [(filename, crc32)],
    in source order. Entries with no CRC (NO_DUMP) are skipped — nothing to
    fetch, nothing to verify."""
    out = []
    for _, call in iter_calls(block, ROM_LOAD_MACROS):
        fname = re.search(r'"([^"]+)"', call)
        crc = re.search(r"CRC\(([0-9a-fA-F]+)\)", call)
        if fname and crc:
            entry = (fname.group(1), crc.group(1))
            # A romset may load the same physical file more than once (a
            # BIOS-alternate set reusing one BASIC image at two addresses):
            # one zip member, one table row.
            if entry not in out:
                out.append(entry)
    return out


def bare_macro_refs(block, defines):
    """Bare macro-name tokens referenced (not called) on their own line
    inside a ROM_START block, e.g. a shared BIOS macro."""
    refs = []
    for line in block.split("\n"):
        tok = line.strip()
        if tok and re.fullmatch(r"[A-Z][A-Z0-9_]*", tok) and tok in defines:
            refs.append(tok)
    return refs


def rom_table(name, rom_starts, defines, _seen=None):
    """A system's own ROM table: its ROM_START's literal entries, or — if it
    has none of its own (the BIOS-root pattern: ROM_START is just a bare
    macro reference) — the one-level expansion of that referenced macro.
    A clone with no ROM_START at all may instead alias its parent's block
    (`#define rom_<clone> rom_<parent>`, e.g. atari400.cpp's a800xlp): the
    alias is followed, because MAME resolves the clone's romset to exactly
    the parent's members."""
    seen = _seen or set()
    block = rom_starts.get(name)
    if block is None:
        alias = defines.get(f"rom_{name}", "").strip()
        m = re.fullmatch(r"rom_(\w+)", alias)
        if m and m.group(1) != name and name not in (_seen or set()):
            return rom_table(m.group(1), rom_starts, defines,
                             (_seen or set()) | {name})
        return []
    entries = rom_entries_in_block(block)
    if not entries:
        for ref in bare_macro_refs(block, defines):
            if ref in seen:
                continue
            seen.add(ref)
            entries.extend(rom_entries_in_block(defines[ref]))
    return entries


def uses_shared_bios(name, rom_starts, defines):
    block = rom_starts.get(name, "")
    return bool(bare_macro_refs(block, defines))


# --- TV standard: derived from the driver, not guessed ---

def derive_tv_standard(text):
    m = re.search(r"m_agnus_id\s*=\s*AGNUS_\w*_(NTSC|PAL)", text)
    return m.group(1) if m else None


# --- rendering helpers ---

def rom_table_md(entries):
    lines = ["  | ROM | CRC32 |", "  |---|---|"]
    for fname, crc in entries:
        lines.append(f"  | `{fname}` | `{crc}` |")
    return "\n".join(lines)


def machine_page(platform, machine, facts, rom_starts, defines, driver_text, manifest, images_dir_exists, parked):
    display = PLATFORM_DISPLAY[platform]
    sysinfo = facts["systems"].get(machine, {})
    fullname = sysinfo.get("fullname") or machine
    year = sysinfo.get("year")
    company = sysinfo.get("company")
    parent = sysinfo.get("parent")
    tv = facts["tv_standard"]

    own_assets = [a for a in facts["machine_assets"][machine] if a != machine]
    own_entries = rom_table(machine, rom_starts, defines)
    shared_bios = uses_shared_bios(machine, rom_starts, defines)

    lines = [f"# {fullname}", ""]

    img = MEDIA_ROOT / platform / f"{machine}.jpg"
    if images_dir_exists.get(machine):
        lines.append(f"![{fullname} at power-on](images/{machine}.jpg)")
        lines.append("")

    lines.append(f"- **`make kernel MACHINE={machine}`** — {display}")
    if year:
        lines.append(f"- **Year**: {year}")
    if company:
        lines.append(f"- **Manufacturer**: {company}")
    if tv:
        lines.append(f"- **Television**: {tv}")
    lines.append("")

    lines.append("## At power-on")
    lines.append("")
    if platform == "amiga":
        # Arcadia-specific boot description — every amiga roster machine is
        # hardware-proven, so the caption may describe the capture.
        if shared_bios:
            caption = (f"`{fullname}` boots via the shared Arcadia System BIOS "
                       f"into its attract/title sequence — see the capture above.")
        else:
            caption = (f"`{fullname}` boots directly from its own Kickstart into "
                       f"its attract/title sequence (no shared OnePlay/TenPlay BIOS "
                       f"menu) — see the capture above.")
    elif machine in parked:
        # The bench observed MAME's blocking known-problems box (or another
        # documented stop): the capture shows the stop, and the page says
        # PARKED — a capture is a boot RESULT, never by itself a pass.
        caption = (f"**PARKED** — {parked[machine]} The capture above shows "
                   f"the observed stop; the machine is not offered until the "
                   f"park is lifted by a policy ruling.")
    elif images_dir_exists.get(machine):
        # A hardware-proof capture exists (copied from the meta bench media):
        # the screenshot is the claim, the caption just points at it.
        caption = (f"`{fullname}` at power-on on the real board — see the "
                   f"capture above.")
    else:
        # No capture yet: compile-stage truth only. The platform kernel
        # builds and links; nothing is claimed about boot behaviour until
        # the bench capture lands and this page regenerates.
        caption = ("Built into the platform kernel, awaiting hardware "
                   "verification — no boot capture yet, so no boot behaviour "
                   "is claimed here.")
    lines.append(caption)
    lines.append("")

    lines.append("## Required assets")
    lines.append("")
    own_path = manifest.get(machine, {}).get("path", f"roms/{machine}.zip")
    lines.append(f"- `{own_path}`")
    lines.append("")
    lines.append(rom_table_md(own_entries))
    for a in own_assets:
        a_sysinfo = facts["systems"].get(a, {})
        a_fullname = a_sysinfo.get("fullname")
        a_path = manifest.get(a, {}).get("path", f"roms/{a}.zip")
        desc = f" — the shared {a_fullname}" if a_fullname else ""
        lines.append(f"- `{a_path}`{desc}")
    lines.append("")

    if platform == "amiga":
        notes = [
            "Arcade coin-op on the Arcadia Multi Select hardware — an Amiga A500 "
            "motherboard driving an external ROM cage through the expansion port "
            "(see the driver header in `arsystems.cpp`) — hardware-proven on the "
            "Pi 4 bench.",
        ]
    else:
        own_src = facts.get("machine_source", {}).get(machine)
        driver_files = (f"`{Path(own_src).name}`" if own_src else
                        ", ".join(f"`{Path(s).name}`" for s in facts.get("sources", [])))
        notes = [f"MAME driver: {driver_files}." if driver_files else
                 "See the platform's MAME driver source."]
    parent_info = facts["systems"].get(parent, {}) if parent else {}
    if parent and parent != "0" and not parent_info.get("is_bios_root"):
        parent_fullname = parent_info.get("fullname", parent)
        if platform == "amiga":
            notes.append(
                f"MAME clone of `{parent}` ({parent_fullname}) — see the `GAME()` "
                f"parent field in `arsystems.cpp`. Its own `ROM_START` fully lists "
                f"every ROM this zip needs; none are borrowed from the parent zip."
            )
        else:
            notes.append(
                f"MAME clone of `{parent}` ({parent_fullname}) — the system "
                f"macro's parent field in the driver source. The ROM table "
                f"above lists every member this machine's own zip needs."
            )
    if platform == "amiga" and not shared_bios:
        notes.append(
            "Plugs directly into the A500 motherboard with its own Kickstart "
            "copy — no shared OnePlay/TenPlay BIOS selection, unlike the rest "
            "of the roster (see the driver's comment on `ROM_START( ar_argh )`)."
        )
    lines.append("## Notes")
    lines.append("")
    for n in notes:
        lines.append(f"- {n}")
    lines.append("")

    lines.append(f"[← back to {display}](README.md)")
    lines.append("")
    return "\n".join(lines)


def readme_page(platform, roster, facts, manifest):
    display = PLATFORM_DISPLAY[platform]
    all_assets = set()
    for m in roster:
        all_assets.update(facts["machine_assets"][m])
    tiers = {manifest.get(a, {}).get("tier") for a in all_assets}
    public_only = tiers == {"public"}

    lines = [f"# {display}", ""]
    lines.append(PLATFORM_INTRO[platform])
    if public_only:
        lines.append("")
        lines.append(
            "Public-tier only: every asset this platform needs is a "
            "public-tier (grey-mirror) source — see [the top-level "
            "README](../../README.md#-fetching-them) for what that means."
        )
    lines.append("")

    lines.append("## Machines")
    lines.append("")
    lines.append("| `make kernel` | System | Year | Romset | Extra assets | TV | |")
    lines.append("|---|---|---|---|---|---|---|")
    for m in roster:
        sysinfo = facts["systems"].get(m, {})
        fullname = sysinfo.get("fullname", m)
        year = sysinfo.get("year", "—")
        own_path = manifest.get(m, {}).get("path", f"roms/{m}.zip")
        romset = f"`{Path(own_path).name}`"
        extra = [a for a in facts["machine_assets"][m] if a != m]
        extra_cell = ", ".join(f"`{Path(manifest.get(a, {}).get('path', a + '.zip')).name}`" for a in extra) or "—"
        tv = facts["tv_standard"] or "—"
        lines.append(f"| `MACHINE={m}` | {fullname} | {year} | {romset} | {extra_cell} | {tv} | [details]({m}.md) |")
    lines.append("")
    lines.append(
        "Click through to a machine's details page for its exact romset "
        "(CRC32 per ROM)."
    )
    lines.append("")

    lines.append("## Assets")
    lines.append("")
    lines.append("```")
    lines.append("my-assets/")
    lines.append("└── roms/")
    # Shared assets are the ones no roster machine already lists as its own
    # romset zip: a parent romset doubling as a clone's extra asset (sord's
    # m5.zip under m5p) is already in the tree as its machine's own line and
    # already has its own details page, so it is not repeated here.
    shared = sorted({a for m in roster for a in facts["machine_assets"][m]
                     if a != m} - set(roster))
    for i, m in enumerate(roster):
        last = not shared and i == len(roster) - 1
        lines.append(f"    {'└──' if last else '├──'} {m}.zip")
    for i, a in enumerate(shared):
        prefix = "    └──" if i == len(shared) - 1 else "    ├──"
        lines.append(f"{prefix} {a}.zip")
    lines.append("```")
    lines.append("")
    for a in shared:
        a_sysinfo = facts["systems"].get(a, {})
        a_fullname = a_sysinfo.get("fullname", a)
        entries = rom_table(a, facts["rom_starts"], facts["defines"])
        lines.append(f"`{a}.zip` — {a_fullname}, shared by every machine above:")
        lines.append("")
        lines.append(rom_table_md(entries))
        lines.append("")
    lines.append(
        "`scripts/fetch-assets.sh` (see the [README](../../README.md#-fetching-them)) "
        "can fetch these for you — `make assets ASSETS=~/my-assets`."
    )
    lines.append("")

    lines.append(f"[← back to the top-level README](../../README.md)")
    lines.append("")
    return "\n".join(lines)


def main():
    if len(sys.argv) != 2:
        print("usage: gen-machine-docs.py <platform>", file=sys.stderr)
        sys.exit(2)
    platform = sys.argv[1]
    if platform not in PLATFORM_DISPLAY:
        print(f"gen-machine-docs.py: unknown platform '{platform}'", file=sys.stderr)
        sys.exit(2)
    if platform not in PLATFORM_INTRO:
        # A platform without generator coverage has hand-maintained pages
        # (sinclair/amstrad/commodore) — refusing here keeps a stray run from
        # clobbering them with half-generic output.
        print(f"gen-machine-docs.py: platform '{platform}' has no PLATFORM_INTRO "
              f"— its docs are hand-maintained; add an intro to generate them",
              file=sys.stderr)
        sys.exit(2)

    roster = make_list(f"PLATFORM_MACHINES_{platform}")
    if not roster:
        print(f"gen-machine-docs.py: empty roster for platform '{platform}' "
              f"(check PLATFORM_MACHINES_{platform} in host/machines.mk)", file=sys.stderr)
        sys.exit(2)

    sources = make_list(f"PLATFORM_SOURCES_{platform}")
    file_texts = {src: strip_disabled_blocks((MAME_ROOT / src).read_text())
                  for src in sources}
    driver_text = "\n".join(file_texts.values())

    manifest = load_manifest()
    defines = parse_defines(driver_text)
    rom_starts = parse_rom_starts(driver_text)
    systems = parse_system_macros(driver_text)

    # The TV standard must come only from the file(s) that actually define
    # this roster's own machines — PLATFORM_SOURCES can include sibling
    # driver files for OTHER, non-roster systems on the same platform (e.g.
    # amiga.cpp's general-purpose Amiga models alongside arsystems.cpp's
    # arcade boards), and those can hardcode a different region.
    roster_text = "\n".join(
        text for text in file_texts.values()
        if any(re.search(rf"ROM_START\(\s*{re.escape(m)}\s*\)", text) for m in roster)
    )
    tv_standard = derive_tv_standard(roster_text)

    machine_assets = {m: make_list(f"MACHINE_ASSETS_{m}") for m in roster}

    # Which single source file carries each machine's system macro, so a
    # multi-driver-file platform (the BBC line spans four) can attribute a
    # machine to ITS driver rather than listing the whole SOURCES set.
    machine_source = {}
    for src, text in file_texts.items():
        for name in parse_system_macros(text):
            machine_source.setdefault(name, src)

    facts = {
        "systems": systems,
        "rom_starts": rom_starts,
        "defines": defines,
        "machine_assets": machine_assets,
        "tv_standard": tv_standard,
        "sources": sources,
        "machine_source": machine_source,
    }

    out_dir = SCRIPT_ROOT / "docs" / platform
    images_dir = out_dir / "images"
    images_dir_exists = {}
    media_dir = MEDIA_ROOT / platform
    if media_dir.is_dir():
        images_dir.mkdir(parents=True, exist_ok=True)
        for m in roster:
            src = media_dir / f"{m}.jpg"
            if src.is_file():
                shutil.copy2(src, images_dir / f"{m}.jpg")
                images_dir_exists[m] = True
    # Bench verdicts ride beside the captures: PARKED.txt lists
    # "<machine>: <reason>" lines for machines whose capture shows an
    # observed stop (MAME's blocking known-problems box) rather than the
    # machine's own face. A capture is a boot RESULT — the verdict file
    # is what distinguishes park from proud on the generated page.
    parked = {}
    parked_file = media_dir / "PARKED.txt"
    if parked_file.is_file():
        for line in parked_file.read_text().splitlines():
            line = line.strip()
            if line and not line.startswith("#") and ":" in line:
                m, reason = line.split(":", 1)
                parked[m.strip()] = reason.strip()
    out_dir.mkdir(parents=True, exist_ok=True)

    missing_facts = []
    for m in roster:
        if m not in systems:
            missing_facts.append(f"{m}: no GAME()/COMP()/... entry found")
        if not rom_table(m, rom_starts, defines):
            missing_facts.append(f"{m}: no ROM entries found in its ROM_START")

    for m in roster:
        page = machine_page(platform, m, facts, rom_starts, defines, driver_text, manifest, images_dir_exists, parked)
        (out_dir / f"{m}.md").write_text(page)

    (out_dir / "README.md").write_text(readme_page(platform, roster, facts, manifest))

    print(f"generated {len(roster) + 1} files under {out_dir}")
    if not tv_standard:
        print("gen-machine-docs.py: could not derive a TV standard from the driver "
              "(m_agnus_id assignment not found) — TV field omitted", file=sys.stderr)
    for w in missing_facts:
        print(f"gen-machine-docs.py: WARNING: {w}", file=sys.stderr)


if __name__ == "__main__":
    main()
