#!/usr/bin/env python3
"""
gen-machine-docs.py — generate a platform's docs/<platform>/README.md and
docs/<platform>/<machine>.md pages straight from source, so they can never
drift: every fact is read fresh, nothing is hand-typed.

Usage: scripts/gen-machine-docs.py <platform>
       scripts/gen-machine-docs.py all      # every platform in machines.mk

Ground truth (read fresh every run, nothing cached or hand-maintained):
  host/machines.mk        the roster (PLATFORM_MACHINES_<platform>), each
                           machine's asset needs (MACHINE_ASSETS_<machine>)
                           and the platform's own MAME driver SOURCES
                           (PLATFORM_SOURCES_<platform>) — read via
                           `make -f host/machines.mk print-<VAR>`, the same
                           mechanism scripts/gen-bootmenu.sh uses, so this
                           generator sees exactly what the build sees.
  host/machines/<m>.conf  each machine's `--virtual-resolution` directive, if
                           any — the TV standard a card must present it on
                           (see derive_tv_standard below).
  scripts/assets.manifest each asset's tier (free/public) and destination
                           zip path.
  mame-rpi4/<SOURCES>      the platform's MAME driver files: GAME()/COMP()/
                           CONS()/SYST() macro invocations give YEAR,
                           MANUFACTURER and TITLE; ROM_START(<machine>)
                           blocks give the ROM filenames + CRC32 for that
                           machine's own zip, verbatim, and each entry's
                           enclosing ROM_REGION name gives its role label
                           when that name already says what it is (see
                           ROM_ROLE_LABELS below) — anything else, PLA_TAG
                           included, carries no label rather than a guess.
                           A ROM_START that is
                           just a bare reference to a #define'd macro (the
                           BIOS-root pattern) is expanded one level to
                           produce that shared asset's own table.
  scripts/platform-docs/<platform>.md
                           the platform's ONE data file for whatever this
                           generator cannot derive from the sources above:
                           hand-authored prose — the platform's intro,
                           its "Quirks" section, and any per-machine caption
                           or note that says something a mechanical scan of
                           ROM/driver facts cannot. See "Platform data file
                           format" below. One file per platform, the same
                           shape as one host/machines/<m>.conf per machine —
                           never a monolithic cross-platform file, never
                           scattered fragments, and never code (this script
                           carries no hand-authored prose of its own).
  ../docs/media/<platform> the meta repo's hardware-proof screenshots
                           (<machine>.jpg, plus any <machine>-<slug>.jpg
                           extra captures a machine_sections body may
                           reference), copied into docs/<platform>/images/
                           if present.

Nothing here is platform-specific by name or in code: a new platform needs
no code change, only its own machines.mk facts, driver source, and a
platform-docs/<platform>.md (a minimal one carries just `## display` and
`## intro` — see platform-docs/sega.md). Re-running regenerates
byte-identical output from unchanged source — the generator is idempotent.

Platform data file format (scripts/platform-docs/<platform>.md):
  Plain text. A line that is exactly "## <name>" starts a section; its body
  is everything up to the next such line or EOF (blank-trimmed at the ends,
  otherwise verbatim). Recognised sections, all but the first two optional:

  ## display            required, one line: the platform's short display
                         name (e.g. "SAM Coupé").
  ## intro               required: one or more hand-authored paragraphs
                         introducing the platform. Wrap lines for
                         readability if you like — they're rejoined into
                         one line per paragraph on render, the same
                         convention every generated paragraph already uses.
                         Separate paragraphs with a blank line.
  ## tier_note           overrides the generic "Public-tier only: every
                         asset this platform needs is a public-tier
                         (grey-mirror) source" sentence the generator would
                         otherwise auto-append when every asset in the
                         roster is public-tier. Use it only when the
                         platform's real reason carries information the
                         generic sentence doesn't (e.g. commodore's
                         contrast with Sinclair's free-tier permission).
  ## quirks              the platform's "## Quirks" section body, verbatim
                         markdown (bullets, links, bold, code spans).
  ## driver_note         overrides the generic "MAME driver: `<file>`."
                         sentence in every roster machine's Notes section
                         with this platform-wide sentence instead (used
                         where the platform's own hardware story is the
                         more useful fact than which driver file it's in).
  ## boot_caption_shared and ## boot_caption_own
                         a matched pair, only meaningful on a platform
                         where machines either boot through a shared
                         firmware/BIOS blob or carry their own — same
                         mechanism uses_shared_bios() already detects.
                         Each is one sentence with a `{fullname}`
                         placeholder, used instead of the generic
                         has-image/no-image caption when both are present.
  ## machine_captions    one `<machine>: <caption>` line per machine whose
                         "At power-on" text is more than the generic
                         boilerplate — what a human actually sees on the
                         glass. Highest-priority caption source (wins over
                         boot_caption_shared/own and the generic ones, but
                         not over a bench PARKED verdict).
  ## machine_notes       one `<machine>: <note>` line per EXTRA Notes
                         bullet beyond the generic driver/clone sentences.
                         A machine may repeat across several lines; each
                         becomes its own bullet, in file order.
  ## machine_sections    extra, fully free-form machine sections this
                         generator has no other slot for — a second capture
                         showing third-party software running, a deep-dive
                         explaining one machine's own hardware quirk, code
                         blocks, whatever the source page carried. Marked by
                         a `### <machine>: <heading>` sub-header inside this
                         section's body, followed by the verbatim markdown
                         to render under "## <heading>" — image markdown
                         included; any <machine>-*.jpg file present in
                         docs/media/<platform>/ is copied alongside the
                         primary capture, so a body may reference
                         `images/<machine>-<slug>.jpg` directly. A machine
                         may repeat across several `### ` markers for more
                         than one extra section, rendered in file order,
                         after Notes.
  ## withdrawn           one `<machine>: <banner>` line per machine that is
                         NOT in this platform's PLATFORM_MACHINES roster
                         (its driver stays in PLATFORM_SOURCES, its page is
                         kept "for the record") — machines pulled from the
                         roster by a policy ruling, not a MAME warning box
                         (that's the bench PARKED.txt mechanism, unrelated).
                         The banner renders as a blockquote at the top of
                         the page; a machine listed here also needs a
                         machine_captions entry, since these machines did
                         reach a real screen worth describing.
"""

import re
import shutil
import subprocess
import sys
from pathlib import Path

SCRIPT_ROOT = Path(__file__).resolve().parent.parent  # public/
MACHINES_MK = SCRIPT_ROOT / "host" / "machines.mk"
MACHINE_CONF_DIR = SCRIPT_ROOT / "host" / "machines"
MANIFEST = SCRIPT_ROOT / "scripts" / "assets.manifest"
MAME_ROOT = SCRIPT_ROOT / "mame-rpi4"  # RAPI_BOARD default (host/Makefile); one MAME source tree per board, identical drivers
MEDIA_ROOT = SCRIPT_ROOT.parent / "docs" / "media"  # meta repo's hardware-proof screenshots
PLATFORM_DOCS_DIR = SCRIPT_ROOT / "scripts" / "platform-docs"  # one hand-authored data file per platform

SYSTEM_MACROS = r"GAME|GAMEL|COMP|COMPX|COMPB|CONS|CONSX|SYST"


# --- host/machines.mk facts, via `make print-<VAR>` (never re-parsed by hand) ---

def make_var(var):
    # --no-print-directory: the answer IS the captured stdout, and run under
    # another make the banners would land in it (see gen-bootmenu.sh).
    result = subprocess.run(
        ["make", "--no-print-directory", "-s", "-f", str(MACHINES_MK),
         f"print-{var}"],
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


def load_manifest_members():
    """scripts/assets.manifest also carries one 'mem|<asset>|<filename>|
    <crc32>|<sha1>|<source-name>' line per file inside that asset — the same
    ground truth scripts/fetch-assets.sh itself fetches by. A romset scanned
    from PLATFORM_SOURCES only sees systems this platform's own driver files
    declare; a shared asset backed by a device ROM_START in some other file
    (sx1541's is in src/devices/bus/cbmiec/c1541.cpp, well outside any
    platform's own SOURCES) or that is not a MAME romset at all (a disk
    image, a single cartridge file) has no such entry, so this is the
    fallback member list for those -> {asset: [(filename, crc32), ...]},
    skipping members with no CRC (an unverifiable disk image, "-")."""
    members = {}
    for line in MANIFEST.read_text().splitlines():
        if not line.startswith("mem|"):
            continue
        parts = line.split("|")
        if len(parts) < 4:
            continue
        _, name, fname, crc = parts[0], parts[1], parts[2], parts[3]
        if crc and crc != "-":
            members.setdefault(name, []).append((fname, crc))
    return members


# --- scripts/platform-docs/<platform>.md: the platform's one hand-authored data file ---

def load_platform_data(platform):
    """Parse the "## <name>" - delimited sections described in this file's
    own docstring. Returns None if the platform has no data file at all —
    the caller's cue that this platform's docs are not yet wired up."""
    path = PLATFORM_DOCS_DIR / f"{platform}.md"
    if not path.is_file():
        return None
    sections, name, body = {}, None, []
    for line in path.read_text().splitlines():
        m = re.match(r"^## (\w+)$", line)
        if m:
            if name:
                sections[name] = "\n".join(body).strip("\n")
            name, body = m.group(1), []
        else:
            body.append(line)
    if name:
        sections[name] = "\n".join(body).strip("\n")
    return sections


def unwrap_paragraphs(text):
    """Blank-line-separated paragraphs, each hand-wrapped source line joined
    into one continuous line — the convention every generated paragraph
    already uses, so a data file may keep human-readable line wraps."""
    if not text:
        return []
    paras = re.split(r"\n\s*\n", text.strip())
    return [" ".join(line.strip() for line in p.splitlines() if line.strip())
            for p in paras if p.strip()]


def collapse(text):
    """Join a hand-wrapped single-paragraph field into one line."""
    return " ".join((text or "").split())


def parse_kv_lines(text):
    """'<machine>: <text>' lines, PARKED.txt's own convention: split on the
    FIRST ':' only, so the text itself may contain colons -> {machine: text}.
    A repeated machine keeps its last line."""
    out = {}
    for line in (text or "").splitlines():
        line = line.strip()
        if not line or ":" not in line:
            continue
        m, v = line.split(":", 1)
        out[m.strip()] = v.strip()
    return out


def parse_kv_lines_multi(text):
    """As parse_kv_lines, but a machine may repeat across several lines —
    each becomes its own list entry, in file order (a machine can carry
    more than one extra hand-authored Notes bullet)."""
    out = {}
    for line in (text or "").splitlines():
        line = line.strip()
        if not line or ":" not in line:
            continue
        m, v = line.split(":", 1)
        out.setdefault(m.strip(), []).append(v.strip())
    return out


def parse_machine_sections(text):
    """'### <machine>: <heading>' sub-markers inside the machine_sections
    section body, each followed by a verbatim markdown block, up to the
    next such marker or EOF -> {machine: [(heading, body), ...]}, in file
    order (a machine may carry more than one extra section)."""
    out = {}
    machine = heading = None
    body = []

    def flush():
        if machine is not None:
            out.setdefault(machine, []).append((heading, "\n".join(body).strip("\n")))

    for line in (text or "").splitlines():
        m = re.match(r"^### (\S+): (.*)$", line)
        if m:
            flush()
            machine, heading = m.group(1), m.group(2)
            body = []
        else:
            body.append(line)
    flush()
    return out


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

# ROM_REGION and its width variants (ROM_REGION16_BE, ...) — scanned
# alongside ROM_LOAD_MACROS in source order so each load entry can be
# attributed to its enclosing region.
ROM_REGION_MACROS = r"ROM_REGION\w*"

# A ROM_REGION's second argument names the region. When that name already
# IS the ROM's role — "basic", "kernal", a Commodore/Acorn BASIC ROM; the
# character generator, spelled "charom" in some drivers and "chargen" in
# others — the label is read straight off the source, no guessing involved.
# Any other region name (a CPU/graphics tag like "maincpu"/"gfx1", a
# device tag, or a macro token such as commodore's PLA_TAG, which expands
# to a board designator like "u17" — human board knowledge this generator
# has no source for) carries no label at all. Mechanical only: extending
# this map to a new name is a decision about what MAME's own source
# already spells out, never a hand-authored guess.
ROM_ROLE_LABELS = {
    "basic": "basic",
    "kernal": "kernal",
    "charom": "chargen",
    "chargen": "chargen",
}


def rom_entries_in_block(block):
    """Literal ROM_LOAD*(...) calls directly in this block, each tagged with
    its enclosing ROM_REGION's role label (see ROM_ROLE_LABELS) when that
    region's name is one this generator recognises as self-describing —
    [(filename, crc32, label_or_None)], in source order. Entries with no CRC
    (NO_DUMP) are skipped — nothing to fetch, nothing to verify."""
    out = []
    seen = set()
    label = None
    for name, call in iter_calls(block, f"{ROM_REGION_MACROS}|{ROM_LOAD_MACROS}"):
        if name.startswith("ROM_REGION"):
            args = split_top_level(call)
            region = args[1].strip() if len(args) > 1 else ""
            label = (ROM_ROLE_LABELS.get(region[1:-1])
                      if region.startswith('"') and region.endswith('"') else None)
            continue
        fname = re.search(r'"([^"]+)"', call)
        crc = re.search(r"CRC\(([0-9a-fA-F]+)\)", call)
        if fname and crc:
            key = (fname.group(1), crc.group(1))
            # A romset may load the same physical file more than once (a
            # BIOS-alternate set reusing one BASIC image at two addresses):
            # one zip member, one table row.
            if key in seen:
                continue
            seen.add(key)
            out.append((fname.group(1), crc.group(1), label))
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


# --- TV standard: derived from each machine's own boot conf, not the driver ---

def tv_standard_for_machine(machine):
    """host/machines/<machine>.conf carries at most one --virtual-resolution=WxH
    directive. Absent means the machine fills the default 720x576 PAL
    canvas. 720x480 is the NTSC canvas the region sweep introduced. Any
    other value is a machine's own native raster (an arcade board's video
    timing, an LCD panel's own resolution) — not a broadcast TV standard at
    all, so neither PAL nor NTSC is claimed for it; the caller renders
    "—" for that case, same as it already does for "no extra assets"."""
    conf = MACHINE_CONF_DIR / f"{machine}.conf"
    if not conf.is_file():
        return "PAL"
    m = re.search(r"--virtual-resolution=(\S+)", conf.read_text())
    if not m:
        return "PAL"
    return "NTSC" if m.group(1) == "720x480" else None


# --- rendering helpers ---

def rom_table_md(entries):
    """entries is [(filename, crc32)] or [(filename, crc32, label_or_None)] —
    manifest_members (assets.manifest's fallback member list, for a romset
    this generator cannot scan a ROM_START for) carries no label, only
    rom_table()'s own driver-source scan does."""
    lines = ["  | ROM | CRC32 |", "  |---|---|"]
    for entry in entries:
        fname, crc = entry[0], entry[1]
        label = entry[2] if len(entry) > 2 else None
        cell = f"`{fname}` ({label})" if label else f"`{fname}`"
        lines.append(f"  | {cell} | `{crc}` |")
    return "\n".join(lines)


def machine_page(platform, machine, facts, rom_starts, defines, manifest,
                  manifest_members, images_dir_exists, parked, pdata, withdrawn):
    display = pdata["display"]
    sysinfo = facts["systems"].get(machine, {})
    fullname = sysinfo.get("fullname") or machine
    year = sysinfo.get("year")
    company = sysinfo.get("company")
    parent = sysinfo.get("parent")
    tv = tv_standard_for_machine(machine)

    own_assets = [a for a in facts["machine_assets"][machine] if a != machine]
    own_entries = rom_table(machine, rom_starts, defines)
    shared_bios = uses_shared_bios(machine, rom_starts, defines)

    lines = [f"# {fullname}", ""]

    if machine in withdrawn:
        lines.append(f"> {withdrawn[machine]}")
        lines.append("")

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
    caption = pdata["machine_captions"].get(machine)
    if machine in parked:
        # The bench observed MAME's blocking known-problems box (or another
        # documented stop): the capture shows the stop, and the page says
        # PARKED — a capture is a boot RESULT, never by itself a pass.
        caption = (f"**PARKED** — {parked[machine]} The capture above shows "
                   f"the observed stop; the machine is not offered until the "
                   f"park is lifted by a policy ruling.")
    elif caption:
        pass  # a hand-authored caption always wins over the generic ones
    elif pdata["boot_caption_shared"] and pdata["boot_caption_own"]:
        template = pdata["boot_caption_shared"] if shared_bios else pdata["boot_caption_own"]
        caption = template.format(fullname=fullname)
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
    if not own_entries and machine not in manifest:
        # Genuinely no romset — not a scanning gap (the CPC+ range's
        # firmware lives entirely on the cartridge asset listed below).
        lines.append(f"No romset zip: the `{machine}` romset is empty.")
        lines.append("")
    else:
        own_path = manifest.get(machine, {}).get("path", f"roms/{machine}.zip")
        lines.append(f"- `{own_path}`")
        lines.append("")
        lines.append(rom_table_md(own_entries or manifest_members.get(machine, [])))
    for a in own_assets:
        a_sysinfo = facts["systems"].get(a, {})
        a_fullname = a_sysinfo.get("fullname")
        a_path = manifest.get(a, {}).get("path", f"roms/{a}.zip")
        desc = f" — the shared {a_fullname}" if a_fullname else ""
        lines.append(f"- `{a_path}`{desc}")
    lines.append("")

    if pdata["driver_note"]:
        notes = [pdata["driver_note"]]
    else:
        own_src = facts.get("machine_source", {}).get(machine)
        driver_files = (f"`{Path(own_src).name}`" if own_src else
                        ", ".join(f"`{Path(s).name}`" for s in facts.get("sources", [])))
        notes = [f"MAME driver: {driver_files}." if driver_files else
                 "See the platform's MAME driver source."]
    parent_info = facts["systems"].get(parent, {}) if parent else {}
    if parent and parent != "0" and not parent_info.get("is_bios_root"):
        parent_fullname = parent_info.get("fullname", parent)
        notes.append(
            f"MAME clone of `{parent}` ({parent_fullname}) — the system "
            f"macro's parent field in the driver source. The ROM table "
            f"above lists every member this machine's own zip needs."
        )
    notes.extend(pdata["machine_notes"].get(machine, []))
    lines.append("## Notes")
    lines.append("")
    for n in notes:
        lines.append(f"- {n}")
    lines.append("")

    for heading, body in pdata["machine_sections"].get(machine, []):
        lines.append(f"## {heading}")
        lines.append("")
        lines.append(body)
        lines.append("")

    lines.append(f"[← back to {display}](README.md)")
    lines.append("")
    return "\n".join(lines)


def readme_page(platform, roster, facts, manifest, manifest_members, pdata):
    display = pdata["display"]
    all_assets = set()
    for m in roster:
        all_assets.update(facts["machine_assets"][m])
    tiers = {manifest.get(a, {}).get("tier") for a in all_assets}
    public_only = tiers == {"public"}

    lines = [f"# {display}", ""]
    lines.extend(unwrap_paragraphs(pdata["intro"]))
    if pdata["tier_note"]:
        lines.append("")
        lines.append(collapse(pdata["tier_note"]))
    elif public_only:
        lines.append("")
        lines.append(
            "Public-tier only: every asset this platform needs is a "
            "public-tier (grey-mirror) source — see [the top-level "
            "README](../../README.md#-fetching-them) for what that means."
        )
    lines.append("")
    lines.append(
        "Prefer a download? Every [tagged release]"
        "(https://github.com/Xalior/pi-mame/releases/latest) carries a "
        "ready-to-boot card and a binary per platform — see [Download a "
        "ready-made image](../../README.md#-download-a-ready-made-image) "
        "in the top-level README. CI proves every release compiles; the "
        "table below is the hardware proof, one HDMI capture per machine."
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
        m_has_rom = bool(rom_table(m, facts["rom_starts"], facts["defines"]))
        if m in manifest:
            romset = f"`{Path(manifest[m]['path']).name}`"
        elif m_has_rom:
            romset = f"`{m}.zip`"
        else:
            romset = "— (empty)"
        extra = [a for a in facts["machine_assets"][m] if a != m]
        extra_cell = ", ".join(f"`{Path(manifest.get(a, {}).get('path', a + '.zip')).name}`" for a in extra) or "—"
        tv = tv_standard_for_machine(m) or "—"
        lines.append(f"| `MACHINE={m}` | {fullname} | {year} | {romset} | {extra_cell} | {tv} | [details]({m}.md) |")
    lines.append("")
    lines.append(
        "Click through to a machine's details page for its exact romset "
        "(CRC32 per ROM)."
    )
    lines.append("")

    lines.append("## Assets")
    lines.append("")

    def asset_path(name):
        return manifest.get(name, {}).get("path", f"roms/{name}.zip")

    # Shared assets are the ones no roster machine already lists as its own
    # romset zip: a parent romset doubling as a clone's extra asset (sord's
    # m5.zip under m5p) is already in the tree as its machine's own line and
    # already has its own details page, so it is not repeated here.
    shared = sorted({a for m in roster for a in facts["machine_assets"][m]
                     if a != m} - set(roster))
    # A roster machine only gets a tree entry if it actually has a
    # downloadable romset — some don't (the CPC+ range's firmware lives
    # entirely on a baked cartridge, listed below as that shared asset
    # instead). Every entry's real destination comes from the manifest, not
    # an assumed roms/<name>.zip — a cartridge file or an SD-card image
    # lives under media/<mediatype>/<driver>/, so the tree is grouped by
    # each asset's actual directory rather than assumed to be one flat
    # roms/.
    tree_paths = [asset_path(m) for m in roster
                  if m in manifest or rom_table(m, facts["rom_starts"], facts["defines"])]
    tree_paths += [asset_path(a) for a in shared]
    by_dir = {}
    for path in tree_paths:
        by_dir.setdefault(str(Path(path).parent), []).append(Path(path).name)

    lines.append("```")
    lines.append("my-assets/")
    dirs = list(by_dir.items())
    for i, (d, files) in enumerate(dirs):
        last_dir = i == len(dirs) - 1
        lines.append(f"{'└──' if last_dir else '├──'} {d}/")
        branch = "    " if last_dir else "│   "
        for j, f in enumerate(files):
            last_file = j == len(files) - 1
            lines.append(f"{branch}{'└──' if last_file else '├──'} {f}")
    lines.append("```")
    lines.append("")
    for a in shared:
        if manifest.get(a, {}).get("kind") == "image":
            # A disk/SD-card image, not a MAME romset — no member CRCs
            # apply (next.img is exactly this: one 2GB card image).
            continue
        a_sysinfo = facts["systems"].get(a, {})
        a_fullname = a_sysinfo.get("fullname")
        # A shared asset's own ROM_START may live outside this platform's
        # PLATFORM_SOURCES entirely (sx1541's is a device file under
        # src/devices/, scanned nowhere) — assets.manifest's own member
        # list is the same ground truth scripts/fetch-assets.sh fetches by,
        # so it is the fallback source of truth here.
        entries = rom_table(a, facts["rom_starts"], facts["defines"]) or manifest_members.get(a, [])
        label = f"`{Path(asset_path(a)).name}`"
        desc = f" — {a_fullname}," if a_fullname else ""
        lines.append(f"{label}{desc} shared by every machine above:")
        lines.append("")
        if entries:
            lines.append(rom_table_md(entries))
        lines.append("")
    lines.append(
        "`scripts/fetch-assets.sh` (see the [README](../../README.md#-fetching-them)) "
        "can fetch these for you — `make assets ASSETS=~/my-assets`."
    )
    lines.append("")

    if pdata["quirks"]:
        lines.append("## Quirks")
        lines.append("")
        lines.append(pdata["quirks"])
        lines.append("")

    lines.append(f"[← back to the top-level README](../../README.md)")
    lines.append("")
    return "\n".join(lines)


def main():
    if len(sys.argv) != 2:
        print("usage: gen-machine-docs.py <platform>|all", file=sys.stderr)
        sys.exit(2)
    platform_arg = sys.argv[1]

    manifest = load_manifest()
    manifest_members = load_manifest_members()
    platforms = make_list("PLATFORMS") if platform_arg == "all" else [platform_arg]

    exit_code = 0
    for platform in platforms:
        exit_code |= generate(platform, manifest, manifest_members)
    sys.exit(exit_code)


def generate(platform, manifest, manifest_members):
    raw = load_platform_data(platform)
    if raw is None:
        print(f"gen-machine-docs.py: no scripts/platform-docs/{platform}.md — "
              f"write one first (see platform-docs/sega.md for the minimal shape)",
              file=sys.stderr)
        return 2
    if "display" not in raw or "intro" not in raw:
        print(f"gen-machine-docs.py: platform-docs/{platform}.md is missing "
              f"'## display' or '## intro'", file=sys.stderr)
        return 2

    pdata = {
        "display": raw["display"].strip(),
        "intro": raw.get("intro", ""),
        "tier_note": raw.get("tier_note"),
        "quirks": raw.get("quirks"),
        "driver_note": collapse(raw["driver_note"]) if raw.get("driver_note") else None,
        "boot_caption_shared": collapse(raw["boot_caption_shared"]) if raw.get("boot_caption_shared") else None,
        "boot_caption_own": collapse(raw["boot_caption_own"]) if raw.get("boot_caption_own") else None,
        "machine_captions": parse_kv_lines(raw.get("machine_captions")),
        "machine_notes": parse_kv_lines_multi(raw.get("machine_notes")),
        "machine_sections": parse_machine_sections(raw.get("machine_sections")),
        "withdrawn": parse_kv_lines(raw.get("withdrawn")),
    }

    roster = make_list(f"PLATFORM_MACHINES_{platform}")
    if not roster:
        print(f"gen-machine-docs.py: empty roster for platform '{platform}' "
              f"(check PLATFORM_MACHINES_{platform} in host/machines.mk)", file=sys.stderr)
        return 2
    withdrawn_machines = list(pdata["withdrawn"].keys())
    all_machines = roster + [m for m in withdrawn_machines if m not in roster]

    sources = make_list(f"PLATFORM_SOURCES_{platform}")
    file_texts = {src: strip_disabled_blocks((MAME_ROOT / src).read_text())
                  for src in sources}
    driver_text = "\n".join(file_texts.values())

    defines = parse_defines(driver_text)
    rom_starts = parse_rom_starts(driver_text)
    systems = parse_system_macros(driver_text)

    machine_assets = {m: make_list(f"MACHINE_ASSETS_{m}") for m in all_machines}

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
        "sources": sources,
        "machine_source": machine_source,
    }

    out_dir = SCRIPT_ROOT / "docs" / platform
    images_dir = out_dir / "images"
    images_dir_exists = {}
    media_dir = MEDIA_ROOT / platform
    if media_dir.is_dir():
        images_dir.mkdir(parents=True, exist_ok=True)
        for m in all_machines:
            src = media_dir / f"{m}.jpg"
            if src.is_file():
                shutil.copy2(src, images_dir / f"{m}.jpg")
                images_dir_exists[m] = True
            # Any second, non-primary capture for this machine (a
            # "Booting media" screenshot, a hardware deep-dive's own
            # picture) that a machine_sections body actually references —
            # only copied when this machine has such a section, so an
            # unrelated <machine>-*.jpg sitting in the media store (forensic
            # capture, abandoned draft) never lands as an unreferenced
            # orphan in the published output.
            if m in pdata["machine_sections"]:
                for extra in media_dir.glob(f"{m}-*.jpg"):
                    shutil.copy2(extra, images_dir / extra.name)
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
    for m in all_machines:
        if m not in systems:
            missing_facts.append(f"{m}: no GAME()/COMP()/... entry found")
        if not rom_table(m, rom_starts, defines):
            missing_facts.append(f"{m}: no ROM entries found in its ROM_START")
    for m in withdrawn_machines:
        if m not in pdata["machine_captions"]:
            missing_facts.append(f"{m}: withdrawn but no machine_captions entry "
                                  f"— it needs a real 'At power-on' description")

    for m in all_machines:
        page = machine_page(platform, m, facts, rom_starts, defines, manifest,
                             manifest_members, images_dir_exists, parked, pdata,
                             pdata["withdrawn"])
        (out_dir / f"{m}.md").write_text(page)

    (out_dir / "README.md").write_text(
        readme_page(platform, roster, facts, manifest, manifest_members, pdata))

    print(f"generated {len(all_machines) + 1} files under {out_dir}")
    for w in missing_facts:
        print(f"gen-machine-docs.py: WARNING: {w}", file=sys.stderr)
    return 0


if __name__ == "__main__":
    main()
