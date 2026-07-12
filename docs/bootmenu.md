# The boot picker and bootmenu.cfg

A **platform card** (see the [top-level README](../README.md)) boots into a
picker instead of a single machine: a menu of that platform's machines,
read from a text file on the card. This page is for anyone building or
hand-editing that card — what's on it, who reads what, and the exact
`bootmenu.cfg` format.

## What the picker is

`pi-mame-boot-rpi4.img` is a tiny, single-core boot kernel — the Pi 4's
firmware boots it directly (the card's `config.txt` names it in the `[pi4]`
section). It has one job: show a menu, read a keyboard pick, patch that
pick's defaults string into the MAME core image staged on the card, and
chain-boot it. It never runs MAME itself; the core binary it chain-boots is
the one that does.

## What's on a platform card

`scripts/mkcard.sh` lays out a complete FAT-root tree in
`build/card-<platform>-<tier>/`:

| File | What it is |
|---|---|
| `pi-mame-boot-rpi4.img` | the boot picker — what the Pi 4's firmware boots first |
| `pi-mame-core-rpi4.img` | the MAME core (built as `kernel8-<platform>.img`, renamed onto the card) — what the picker patches and chain-boots |
| `bootmenu.cfg` | the menu the picker reads, generated per platform and tier by `scripts/gen-bootmenu.sh` |
| `config.txt` | our card boot config (`[pi4] kernel=pi-mame-boot-rpi4.img`) |
| `cmdline.txt` | the card's regional canvas (PAL by default) |
| firmware files (`start4.elf`, `fixup4.dat`, device trees, `armstub8-rpi4.bin`, licences) | Circle's pinned Raspberry Pi firmware |
| `roms/`, `next/`, `carts/` | the tier's assets, copied in from the assets directory you supply |

The card ships our own `config.txt`: its `[pi4]` section names
`pi-mame-boot-rpi4.img` as the kernel the firmware boots. Two vocabularies
name the board here, and they are not the same word — the `[pi4]` section is
the Raspberry Pi firmware's board filter (fixed by the firmware), while the
`rpi4` in the filename is Circle's image-suffix token (also read as "RPi").

The picker reads `bootmenu.cfg` from `SD:/bootmenu.cfg` and, on a pick,
loads and patches `SD:/pi-mame-core-rpi4.img` (the MAME core's on-card
name — `rpi4` names the board, ahead of a future multi-board card).

## bootmenu.cfg format

One entry per line:

```
label|defaults-string
```

The parser (`boot-picker/bootmenu.cpp`) works like this:

- Each line is trimmed of leading and trailing whitespace, including a
  trailing `\r` from CRLF files.
- A blank line, or a line whose first character is `#`, is ignored — the
  generated header comments in a `gen-bootmenu.sh` output are `#` lines
  for exactly this reason.
- The line is split on the **first** `|`. Everything before it is the
  label; everything after is the defaults string.
- The label has its trailing whitespace trimmed. The defaults string has
  its leading whitespace trimmed (trailing whitespace was already trimmed
  off the whole line).
- A line with no `|` at all is malformed: it is skipped, and the picker
  logs a warning to serial. It does not stop the rest of the file loading.
- Entries are kept in **file order** — the top line is where the menu
  cursor starts.

Ceilings, enforced so a bad file fails safely rather than corrupting
memory or silently truncating a machine's arguments:

- **64 entries.** Anything past the 64th line with a valid `|` is ignored,
  with a warning logged.
- **96 bytes per label**, truncated to fit if longer.
- **1024 bytes per defaults string**, truncated to fit if longer — but
  see below: an over-long string is *preserved up to this ceiling* rather
  than silently cut short at a smaller size, so the patch step can still
  refuse it against the platform image's real capacity instead of quietly
  changing what you asked for.
- The config file itself is read up to **64 KB**; anything beyond that is
  not read.

`bootmenu.cfg` is read from the FAT root of the SD card (`SD:/bootmenu.cfg`).

## What the picker does with it

- **No entries.** If the file is missing, empty, or every line is blank,
  a comment, or malformed, the picker shows "no usable entries in
  SD:/bootmenu.cfg" on the glass and halts. It never guesses a machine to
  boot.
- **One entry.** Nothing to choose, so the picker boots it immediately —
  no menu is drawn, no key is needed. This makes a single-line
  `bootmenu.cfg` boot straight through unattended.
- **Two or more entries.** The picker draws a numbered menu (reverse-video
  on the highlighted line) and waits for a keyboard pick: **Up**/**Down**
  move the cursor, digits **1–9** jump straight to that entry, and
  **Enter** (main or numpad) selects the highlighted one.
- **On selection**, the picker loads the MAME core image
  (`SD:/pi-mame-core-rpi4.img`) into memory, patches the selected entry's
  defaults string into it at offset `0x800` (see
  [defaults-abi.md](defaults-abi.md) for the block format), and
  chain-boots the patched image. Every step is logged to serial.
- **On any failure** — the image is missing or unreadable, its size is
  out of range, or the defaults patch is refused (wrong or absent magic,
  or a string too long for the image's block capacity) — the picker shows
  the failure reason on the glass and halts. It never falls back to
  booting something else or guessing: every entry on a card boots the
  same platform image, so a malformed one fails identically every time.

## The defaults-string grammar

The defaults string after the `|` is exactly what gets tokenised into
MAME's argv by the platform kernel at boot (`host/defaults.cpp`). A menu
author writes it like a shell command line, with a few fixed rules:

- Tokens are split on whitespace.
- Double quotes group whitespace into a single token, and the quotes
  themselves are stripped: `-view "Screen 1"` becomes the two argv
  entries `-view` and `Screen 1`.
- An empty pair of quotes, `""`, produces an **empty argv entry** — this
  is the only way to bake an option's value empty. For example
  `-iec8 ""` tells MAME to leave IEC device 8 unpopulated.
- Tokens starting with `--rapi-` are consumed by the kernel itself and
  never reach MAME's argv. A recognised one sets a kernel flag (for
  example `--rapi-fps` turns on MAME's built-in FPS/speed readout); an
  unrecognised one is logged and dropped.
- An empty defaults string boots MAME's own system-selection list instead
  of a specific machine.
- The first token is normally the machine's short name, matching what
  `make kernel MACHINE=<name>` builds.

### Real examples

These are genuine `MACHINE_STRING_*` values from `host/machines.mk`, the
same strings `scripts/gen-bootmenu.sh` writes into a generated
`bootmenu.cfg`:

```
c64|c64 -iec8 ""
tbblue|tbblue -hard1 /next/next.img
cpc464p|cpc464p -cart /carts/sysukpd.bin
```

The first bakes the Commodore 64 with its external IEC disk drive slot
left empty. The second bakes the ZX Spectrum Next with its Next SD-card
image attached. The third bakes the CPC464+ with its game-free system
cartridge.

A generated card's `bootmenu.cfg` carries two leading `#` comment lines
naming the platform and tier it was generated for — `gen-bootmenu.sh`
marks the file "do not edit" — but the parser treats those exactly like
any other comment line, so hand-written entries above, below, or between
them work identically.
