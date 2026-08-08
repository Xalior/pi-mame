# pi-mame 👾

[![build](https://github.com/Xalior/pi-mame/actions/workflows/build.yml/badge.svg)](https://github.com/Xalior/pi-mame/actions/workflows/build.yml)

Bare-metal MAME for the Raspberry Pi 3, 4 and 5. No Linux, no OS, no
desktop — the Pi boots in seconds straight into an emulated machine, like an
appliance, because that's what it is. 📺⚡

pi-mame embeds MAME's emulation core on the [Circle](https://github.com/rsta2/circle)
bare-metal framework through a purpose-built
[SDL2 shim](https://github.com/Xalior/circle-libsdl2). Every image is the
same emulator; what differs is what happens at power-on, and that is
decided when the image is **built** — never by config files or a command
line, because there are none. A machine image powers on as its one
machine, instantly, every time. A platform card powers on into a picker
instead: a menu of that platform's machines — pick one with the keyboard
and, if its ROMs are on the card, it starts. Nothing you pick is
remembered — power off, and the next power-on asks again. 🔁

## 📥 Download a ready-made image

Every tagged release carries several asset forms — grab yours from
[**the latest release**](https://github.com/Xalior/pi-mame/releases/latest)
and skip the toolchain:

**Pick the zip for your board.** Every card is built for one specific
Raspberry Pi — `rpi3`, `rpi4` or `rpi5` — because the emulator inside it is
compiled for that board's CPU. A card is not portable between boards; the
board is the last word in the filename so a folder full of downloads still
tells you which is which.

- **`pi-mame-<tag>-<platform>-<free|public>-<board>.zip`** — a platform card,
  the ready-to-boot download: that board's Pi firmware, `config.txt`, the
  regional `cmdline.txt`, the boot picker (as `pi-mame-boot-<board>.img`,
  which the firmware boots), that platform's binary as the MAME core (as
  `kernel-<board>.img`, which the picker chain-boots), a menu of the
  platform's machines, and their ROMs. The **free** card lists only machines
  whose ROMs are all free-tier and bundles just those free-blessed ROMs. The
  **public** card lists the full roster and bundles the full ROM set — the
  grey "public-tier" ROMs are not in this repo; CI fetches them from their
  mirrors at build time into this zip alone (see
  [Assets you must supply](#-assets-you-must-supply) for the tiers). Extract
  it onto a blank **FAT32** SD card — files at the card's top level, not in a
  subfolder — put the card in the Pi, plug the display into **HDMI0** (on the
  Pi 4 and Pi 5, the micro-HDMI port nearest the USB-C power connector), and
  power on.
- **`pi-mame-<tag>-<platform>-<board>.img`** — one platform's binary on its
  own, for one board. This is the same core already inside that board's card
  zips; it is here for anyone assembling a card by hand or replacing the core
  on one they built. Copy it onto the card as `kernel-<board>.img`, the name
  the picker chain-boots. The board is in this filename for the same reason it
  is in the zips': every board builds a file called
  `kernel8-<platform>.img`, so the release names them apart.

A release does **not** carry a separate download per machine: that would mean
near-identical files per board, each about 84 MB, differing only by a few
bytes of baked-in defaults. If you want a card that
powers straight on into one machine with no picker, build it from the
published sources with `make kernel MACHINE=<name>` — see
[Building from source](#-building-from-source-the-long-way).

Which machine? Every platform's folder under [docs/](docs/) lists its
machines with a details page each — start at
[docs/sinclair/](docs/sinclair/README.md),
[docs/amstrad/](docs/amstrad/README.md),
[docs/commodore/](docs/commodore/README.md) or
[docs/amiga/](docs/amiga/README.md), or see
[the platform table](#-the-default-images) below.

CI **compiles** every release on a clean Ubuntu runner, every board —
that's what's proven for every asset there. It does not boot-test them:
hardware proof lives in the platform tables, where every screenshot is an
HDMI capture from a real Pi (more in
[Continuous integration](#-continuous-integration) below).

Prefer building it yourself? See
[Building from source](#-building-from-source-the-long-way) below.

## 🔬 How small is the P in this PoC?

Delightfully small. Let's be precise about what this actually is:

- **Every platform, every machine.** Each platform is a family of machines
  built on related hardware, sharing a MAME driver lineage and, often, ROMs.
  Every machine on the roster carries a verdict from real hardware: it is
  either proven on the glass with an HDMI capture on its details page, or
  parked with the reason recorded. Parked is a real category and an honest
  one — most parked machines are held by a MAME warnings box the appliance
  has no way to dismiss, not by a broken emulator.
- **Every board.** 🥧 Raspberry Pi 3, 4 and 5. MAME is compiled separately
  for each — they are Cortex-A53, -A72 and -A76 — so a card is built for one
  board and boots that board only.
- **Split cores, and silent.** 🔇 The emulation gets a CPU core to itself while
  another core does nothing but push finished frames to the display, so they
  never wait on each other. MAME itself still runs single-threaded
  (`-numprocessors 1`) on its core. There is no sound yet: the shim has a
  working HDMI audio path, but no shipped image connects MAME's output to it,
  and wiring that up is deliberately the next milestone's job.

Building more of MAME in is a `SOURCES` change in `host/machines.mk`
(each platform's driver list); running more is a matter of what you put in
`roms/`. Everything on this page describes **this repository's build system
and its defaults** — all of it is yours to change: add a machine's row to
`host/machines.mk` (its defaults string and assets), write your own canvas,
go wild. A custom image is the same build with your choices in it. 🧪

## 📦 The default images

Each board compiles **one shared MAME engine**, and each platform links that
engine against only its own drivers (no crossover) to make **one binary per
platform**. No machine is compiled in: the machine name and its media ride a
fixed-size **defaults string** at offset `0x800` in the image, written before
boot. "Which machine" is not configuration you edit at runtime — there is no
CLI and no config files of ours — it's what got stamped into that block. 💾

What comes out of that one binary per platform:

| Image | Powers on into |
|---|---|
| `kernel8-<platform>.img` | the platform's **no-options** kernel — unpatched, so MAME boots its own system list; machines with ROMs on the card run |
| `kernel8-<machine>.img` | one machine — the same platform binary with that machine's defaults stamped in (`make kernel MACHINE=<name>`, built locally; not a release download) |
| the **boot picker** (`make picker`) | a menu of the platform's machines read from `bootmenu.cfg`; a pick patches the platform binary and chain-boots it |

Those `kernel8-*.img` names are the build products. **On a card, fixed
names matter instead**, both carrying the board token so a card is
self-describing:

| On the card | What it is |
|---|---|
| `pi-mame-boot-<board>.img` | the boot picker — this is what the Pi firmware boots |
| `kernel-<board>.img` | the MAME core the picker chain-boots: a platform binary, or a single machine's image on a `make sd` card |

`make sd` and `make card` put them there for you; do the rename by hand only
if you're dropping a bare kernel onto a card you already built.

Every machine belongs to one of these platforms:

| Platform | Details |
|---|---|
| Sinclair — the ZX Spectrum family and its clones | [docs/sinclair/](docs/sinclair/README.md) |
| Amstrad — the CPC family, the KC Compact, and the PC1512 | [docs/amstrad/](docs/amstrad/README.md) |
| Commodore — the C64 line, the VIC-20s, and the TED machines | [docs/commodore/](docs/commodore/README.md) |
| Amiga — the Arcadia Multi Select arcade system | [docs/amiga/](docs/amiga/README.md) |
| Atari — the 8-bit computer line, 400 through XEGS | [docs/atari/](docs/atari/README.md) |
| Acorn — the BBC Micro family, the Electron, and the Atom | [docs/acorn/](docs/acorn/README.md) |
| EACA — the Colour Genie | [docs/eaca/](docs/eaca/README.md) |
| SAM Coupé — MGT's Spectrum successor | [docs/samcoupe/](docs/samcoupe/README.md) |
| Camputers — the Lynx | [docs/camputers/](docs/camputers/README.md) |
| Tatung — the Einstein | [docs/tatung/](docs/tatung/README.md) |
| Memotech — the MTX line | [docs/memotech/](docs/memotech/README.md) |
| Enterprise — the 64 and 128 | [docs/enterprise/](docs/enterprise/README.md) |
| Sord — the m5 | [docs/sord/](docs/sord/README.md) |
| VTech — the Laser / VZ family and friends | [docs/vtech/](docs/vtech/README.md) |
| TRS — the TRS-80, CoCo, Dragon and MC-10 | [docs/trs/](docs/trs/README.md) |
| Sega — the Hang-On and Out Run arcade boards | [docs/sega/](docs/sega/README.md) |

Each platform page carries its own machine table (`make kernel MACHINE=` target,
system, year, romset, TV region) and a details page per machine covering
exactly what appears on the glass at power-on and exactly which assets it
needs. Every screenshot in those pages is an HDMI capture from a real
Raspberry Pi running that machine's image — not an emulator window, not a
mockup. 📸 The original platforms were captured on a Pi 4; the ones that
followed were captured on a Pi 5.

A platform card's menu and the mechanism behind it are documented
separately: [docs/bootmenu.md](docs/bootmenu.md) covers the boot picker
and the `bootmenu.cfg` format for anyone building or editing a card, and
[docs/defaults-abi.md](docs/defaults-abi.md) covers the patchable-defaults
block itself for anyone writing their own tooling against a pi-mame
image.

## 📺 Display: the regional canvas

The framebuffer geometry is Raspberry Pi boot configuration
(`width=`/`height=` in `cmdline.txt`, a documented Circle option), set per
**region**, not per machine — exactly the contract an 80s home computer had
with the family television. 📼 `cmdline-pal.txt` is the 720×576 PAL canvas
that every PAL machine stretches to fill, and `cmdline-ntsc.txt` is the
720×480 NTSC canvas for the American 60Hz machines. Every card this release builds uses the PAL canvas, including
the ones carrying American machines; serving those their own canvas is
work still to come. The GPU outputs that geometry as the video signal; your display's own
controller stretches it to the glass. `socmaxtemp=70` in the same file is
load-bearing thermal configuration: don't remove it. 🌡️

The same `cmdline.txt` also configures the keyboard layout. Circle defaults to US, but supports UK, German, Spanish, French, Italian and Dvorak. If your keyboard is not US, add `keymap=` to the file:

    keymap=uk

Valid values are: `us` (default), `uk`, `de`, `es`, `fr`, `it`, `dv` (Dvorak). Without the correct layout, keyboard input reads as the wrong characters — arrow keys and number keys become unusable, making the menu hard to navigate.

## 💾 It remembers

Change a machine's settings, or write to its battery-backed memory, and
that state is written to the card when you close MAME's menu. Power the Pi
off and it is still there next time.

Emulated real-time clocks are the exception, and it is why the Amstrad
NC100 and NC200 do not ship in this release: their saved state returns
correctly, but the clock itself comes back reset. Both machines are parked
until that is fixed.

## 🧰 Prerequisites

- [Arm GNU toolchain](https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads)
  release 15.2.Rel1, target **aarch64-none-elf** — pick the archive whose
  *host* matches the machine you're building on (x86_64 Linux, macOS,
  AArch64 Linux, …), untar it anywhere, and put its `bin/` on your `PATH`
- `git`, GNU make, `wget` (firmware download)
- On macOS: `brew install bash gnu-getopt`, and put both ahead of the
  system versions when building —

  ```sh
  export PATH="/opt/homebrew/opt/gnu-getopt/bin:/opt/homebrew/bin:$PATH"
  ```

  The stock bash 3.2 and BSD getopt silently break circle-stdlib's
  `configure` (the symptom is `Error: Invalid toolchain prefix`) 🍎🪤
- ~15 GB of disk and real patience: the MAME step is hours, not
  minutes ☕☕☕

## 🏗️ Building from source (the long way)

Most people want a [ready-made image](#-download-a-ready-made-image)
instead. This is for building the kernels yourself: a toolchain download,
a MAME compile measured in hours on most machines, and full control
over which machines get baked in.

```sh
git clone --recursive https://github.com/Xalior/pi-mame.git
cd pi-mame

make deps      # circle-stdlib worlds + SDL2 shim (multicore, per board) and the picker's single-core world
make mame      # the board's ONE shared mamedrivers engine — the long one; logs:
               #   build/mame-build-<board>.log. Default RAPI_BOARD=rpi4; add
               #   RAPI_BOARD=rpi3|rpi5 to build another board (each in its own
               #   mame-<board> tree). (genie's final host-style link fails by
               #   design; the archives are the product and the kernel links itself)
make kernels   # every platform binary + every machine's kernel8-<machine>.img
               #   + the boot picker — each platform kernel links the shared
               #   mamedrivers engine with its own drivlist. Each platform's
               #   folder under docs/ lists its machines, or use
               #   `make kernel MACHINE=<name>` for just one

make sd MACHINE=spectrum ASSETS=~/my-assets   # a single-machine card, or:
make card PLATFORM=sinclair TIER=free ASSETS=~/my-assets   # a platform card
```

`make sd` assembles a complete single-machine copy-to-card tree in
`build/sd/`: that board's Raspberry Pi firmware (fetched at the revision
Circle pins), our `config.txt` boot configuration, the machine's regional
canvas `cmdline.txt`, and the MAME core as `kernel-<board>.img` — which the
firmware boots directly, no picker. `make card PLATFORM=<p> TIER=<free|public>`
instead lays out a platform card in `build/card-<p>-<tier>-<board>/`: the boot
picker as `pi-mame-boot-<board>.img` (the front door the firmware boots), the
MAME core as `kernel-<board>.img`, and a generated `bootmenu.cfg` (the
**free** menu lists only machines whose ROMs are all free-tier; **public**
lists the full roster). A card carries the media its own menu asks for and
nothing else. `ASSETS` points at a directory you provide (layout on the
platform pages); leave it off and the tree still builds — you'll just add
`roms/` (and any platform extras) to the card yourself.

Both targets take `RAPI_BOARD=rpi3|rpi4|rpi5` and build for that board;
`make dist` fans the whole matrix — every platform, both tiers, every
board — into one zip per combination in `dist/`.

Then, concretely: 💾

1. Format an SD card with a single **FAT32** partition (any size card; the
   Pi boots from FAT).
2. Copy everything *inside* `build/sd/` onto it — files at the card's top
   level, not in a subfolder.
3. Put the card in the Pi — the same board you built for — plug the display
   into **HDMI0** (on the Pi 4 and Pi 5, the micro-HDMI port nearest the
   USB-C power connector; the Pi 3 has a single full-size HDMI socket), and
   power on. 🔌

## 🤖 Continuous integration

Every version tag (`v*`) on `main` is built from scratch on a clean Ubuntu
runner — a stranger test at every release cut: if these published sources
can't build pi-mame with nothing but the toolchain, the tag goes red. 🚦
One job per board, all at once, and a break on one board still reports the
others. CI runs the same `make` targets you would run locally, so the release
path is the tested path. Each tag's build cuts a GitHub Release whose assets
are the card zips and the per-platform binaries, so you can grab one and skip
the toolchain entirely. ⬇️

CI proves the build **compiles**; what has actually run on real hardware
lives in the platform tables — every screenshot there is an HDMI capture from
a real Pi, not a CI artifact. 📸

## 🕹️ Assets you must supply

This repository contains no ROMs and no disk images. `make sd`'s `ASSETS`
directory always has a `roms/` folder; some platforms add their own
subfolder alongside it (the Sinclair platform's Next SD-card image lives
in `next/`, for instance). Each platform's page under [docs/](docs/) has the
exact tree it expects — for example
[docs/sinclair/README.md](docs/sinclair/README.md#assets),
[docs/amstrad/README.md](docs/amstrad/README.md#assets) and
[docs/commodore/README.md](docs/commodore/README.md#assets). Only supplying
some assets is fine: machines without their ROMs simply won't run.

### 🥤 Fetching them

`scripts/fetch-assets.sh` will pour, if you're thirsty. It ships no bytes —
it *shows you where the free soda is* and, on request, fetches it into an
assets directory you own, verifying every ROM member (CRC32 + SHA1 against
[`scripts/assets.manifest`](scripts/assets.manifest), whose checksums come
from MAME's own `ROM_START` definitions) before it installs anything. Tiers
exist because provenance differs:

- **free** — content whose redistribution is properly blessed, fetched from
  a proper upstream: the Sinclair/Amstrad 8-bit ROMs under Amstrad's
  standing permission (shipped by the Fuse emulator and the proteanthread
  ZX-81 project), and a hosted ready-to-boot ZX Spectrum Next SD image.
- **public** — publicly-available-but-grey MAME romset mirrors on
  archive.org. Widely used, not formally blessed; your call whether to
  drink.

Be aware how lopsided that split is: most assets are public-tier, with only
a handful free. Amstrad's standing permission is the reason the Sinclair and
Amstrad machines have a free card at all — no comparable blessing exists for
most other platforms, so their machines are public-tier only. A platform
whose free menu would be empty simply ships no free card.

```sh
make assets-free   ASSETS=~/my-assets   # just the blessed sources
make assets-public ASSETS=~/my-assets   # just the archive.org mirrors
make assets        ASSETS=~/my-assets   # both
# (or run scripts/fetch-assets.sh <free|public|all> ~/my-assets directly)
```

It's idempotent (an asset already present and valid is left alone), it
prints a per-asset ledger (`FETCHED` / `ALREADY-PRESENT` / `FAILED` /
`SKIPPED`), and partial success is normal — a source that's down or a set
that's moved fails only its own asset. Point `make sd`'s `ASSETS` at the
same directory.

**`next.img` is checksum-exempt.** The ZX Spectrum Next's 2 GB SD image is
a live filesystem whose contents advance, so it isn't byte-pinned like the
ROMs: the fetcher downloads a hosted ready-to-boot image, extracts it,
sanity-checks the size, and installs it as `media/hard/tbblue/next.img` —
see [docs/sinclair/tbblue.md](docs/sinclair/tbblue.md).

### 🎮 Extra games

Some platform cards add a few free games to their menu, on top of the
machine's own system list. These games are not part of any MAME romset, so
`make assets` does not fetch them. A separate command does:

```sh
make media ASSETS=~/my-assets
```

This installs each game into the same `ASSETS` directory, so `make sd` and
`make card` pick it up with no extra step. It checksums every file it
downloads and is idempotent, the same way `make assets` is.

Not every game listed in `scripts/trial-games.manifest` has a working
`make media` entry yet. For some, the exact download link was never
recorded when the game was first added to the project, and the script will
not guess one on your behalf. The ledger it prints marks those games
`UNAVAILABLE` rather than `FAILED`, and the corresponding menu entry will
not start until a real link is found.

## ⌨️ At the keyboard

A USB keyboard is the machine's keyboard. Computers with full keyboards
receive **every** key by default; press **Scroll Lock** to toggle MAME's UI
controls (then **Tab** opens the menu — media loading lives there). On the
Spectrum, Left Shift is CAPS SHIFT and Right Shift is SYMBOL SHIFT. 🌈

## 🚧 Status

Video, input, and media loading are proven on hardware, on every board.
The core split is integrated and shipping: MAME emulates on a core of its
own while another core presents frames. MAME itself remains single-threaded
(`-numprocessors 1`) on that core. Sound is the notable gap — the audio path
exists in the shim and is not yet connected to MAME in any shipped image,
which is the next milestone's work. This is a proof of concept wearing its P
proudly. 🚀

## ⚖️ License

The build glue and kernel host in this repository are GPLv3, matching the
projects they bind together. MAME, Circle, circle-stdlib, circle-newlib,
and circle-libsdl2 remain under their own licenses in their own trees.
