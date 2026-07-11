# pi-mame 👾

Bare-metal MAME for the Raspberry Pi 4. No Linux, no OS, no desktop — the
Pi boots in seconds straight into an emulated machine, like an appliance,
because that's what it is. 📺⚡

pi-mame embeds MAME's emulation core on the [Circle](https://github.com/rsta2/circle)
bare-metal framework through a purpose-built
[SDL2 shim](https://github.com/Xalior/circle-libsdl2). Every image is the
same emulator; what differs is what happens at power-on, and that is
decided when the image is **built** — never by config files or a command
line, because there are none. A machine image powers on as its one
machine, instantly, every time. The picker image powers on into MAME's
system list instead: pick a machine with the keyboard and — if its ROMs
are on the card — it starts. Nothing you pick is remembered — power off,
and the next power-on asks again. 🔁

## 🔬 How small is the P in this PoC?

Delightfully small. Let's be precise about what this actually is:

- **Nineteen machines run.** 🕹️ The 48K ZX Spectrum, the ZX Spectrum 128, the
  ZX Spectrum +2 (`specpls2`, Amstrad's grey 128), the ZX Spectrum +2a
  (`specpl2a`, Amstrad's +3 firmware in the +2's cassette case), the ZX
  Spectrum +3 (`specpls3`, the same firmware with the built-in 3" floppy
  drive), the ZX Spectrum Next (`tbblue`, with its SD card image
  attached), the ZX Spectrum Next KS1 (`specnext_ks1`, the 2020
  Kickstarter board revision, sharing the Next's ROMs and SD image), the
  ZX Spectrum Next KS2 (`specnext_ks2`, the 2023 Kickstarter board
  revision, likewise sharing the Next's ROMs and SD image), the
  ZX Spectrum Next KS3 (`specnext_ks3`, the 2025 Kickstarter board
  revision, whose trimmed BIOS list draws the same Next ROMs from
  `tbblue.zip` and boots the same SD image), the
  Sinclair ZX-80 (`zx80`, the 1980 original), the
  Sinclair ZX-81 (`zx81`, 1981), the Timex TC-2048 (`tc2048`, Timex
  of Portugal's 1984 Spectrum clone), the Timex Sinclair TS-2068
  (`ts2068`, Timex's 1983 American Spectrum on a 60Hz television), and the
  Timex Sinclair TS-1000 (`ts1000`, Timex's 1982 American ZX-81), and the
  Timex Sinclair TS-1500 (`ts1500`, Timex's 1983 ZX-81 in a TS-1000 case
  with 16K on board), the Pentagon 128K (`pentagon`, Vladimir
  Drozdov's 1991 Russian Spectrum clone, whose startup menu carries a
  TR-DOS entry for its built-in Beta Disk interface), and the
  Scorpion ZS-256 (`scorpio`, the 1992 Russian "Yellow PCB" clone, whose
  V.2.94 firmware boots to a menu of 128 TR-DOS, 128 BASIC, Calculator,
  48 BASIC, and 48 TR-DOS on its own Beta Disk interface), and the
  MicroART ATM-Turbo 2 (`atmtb2`, MicroART's 1992 Russian turbo Spectrum
  clone, whose firmware boots to a MicroART menu of CP/M, TR-DOS 48,
  Spectrum 128, Spectrum 48, and Turbo On over a red MicroART logo on the
  PAL canvas), and the NedoPC ZX Evolution: BASECONF (`pentevo`, NedoPC's
  2009 open-hardware Spectrum clone, whose EVO Reset Service v0.60.02
  firmware boots to a BASECONF main menu — TR-DOS boot, File browse, Tape
  load, SD-card boot, 48K and 128K BASIC, and more — beside a settings panel,
  on the PAL canvas). That's it. That's the list.
- **One driver family is compiled.** The build's `SOURCES` names exactly
  ten MAME driver files: `spectrum.cpp`, `spec128.cpp` (the 128 and the
  +2 both), `specnext.cpp`, `specpls3.cpp` (the +2a and the +3),
  `zx.cpp` (the ZX-80, the ZX-81, the TS-1000, and the TS-1500),
  `timex.cpp` (the TC-2048 and the TS-2068), `pentagon.cpp` (the
  Pentagon 128K), `scorpion.cpp` (the Scorpion ZS-256), `atm.cpp`
  (the MicroART ATM-Turbo 2), and `evo/pentevo.cpp` (the ZX Evolution
  BASECONF). The picker's
  list shows everything those files define, but a listed machine only runs
  if you've supplied its ROMs — with the default assets, that's the
  nineteen above.
- **One board.** 🥧 Proven on a Raspberry Pi 4 Model B (4GB). Nothing else
  has ever booted it. (The firmware files for the Pi 400 and CM4 ride
  along because Circle ships them — consider those a rumor, not a
  feature.)
- **Single-threaded, and silent.** One of the Pi's four cores does all the
  work, and audio isn't wired up yet. 🔇

Building more of MAME in is a `SOURCES` change in `scripts/build-mame.sh`;
running more is a matter of what you put in `roms/`. Everything on this
page describes **this repository's build system and its defaults** — all
of it is yours to change: add a `MACHINE_DEFS_<name>` line in
`host/Makefile` to bake a different machine, write your own canvas, go
wild. A custom image is the same build with your choices in it. 🧪

## 📦 The default images

Out of the box, twenty images:

| `make` | Image | Powers on into |
|---|---|---|
| `MACHINE=spectrum` | `kernel8-spectrum.img` | 48K ZX Spectrum BASIC |
| `MACHINE=spec128` | `kernel8-spec128.img` | ZX Spectrum 128 startup menu (128 BASIC, Tape Loader, …) |
| `MACHINE=specpls2` | `kernel8-specpls2.img` | ZX Spectrum +2 startup menu (Amstrad's grey 128) |
| `MACHINE=specpl2a` | `kernel8-specpl2a.img` | ZX Spectrum +2a startup menu (Loader, +3 BASIC, Calculator, 48 BASIC) |
| `MACHINE=specpls3` | `kernel8-specpls3.img` | ZX Spectrum +3 startup menu (Loader, +3 BASIC, Calculator, 48 BASIC; drives A: and M:) |
| `MACHINE=tbblue` | `kernel8-tbblue.img` | ZX Spectrum Next / NextZXOS (needs `next/next.img` on the card) |
| `MACHINE=specnext_ks1` | `kernel8-specnext_ks1.img` | ZX Spectrum Next, KS1 board (2020 Kickstarter) / NextZXOS (needs `next/next.img`, shares `tbblue.zip`) |
| `MACHINE=specnext_ks2` | `kernel8-specnext_ks2.img` | ZX Spectrum Next, KS2 board (2023 Kickstarter) / NextZXOS (needs `next/next.img`, shares `tbblue.zip`) |
| `MACHINE=specnext_ks3` | `kernel8-specnext_ks3.img` | ZX Spectrum Next, KS3 board (2025 Kickstarter) / NextZXOS (needs `next/next.img`, shares `tbblue.zip`) |
| `MACHINE=zx80` | `kernel8-zx80.img` | Sinclair ZX-80 (1980) BASIC — the inverse-video `K` cursor |
| `MACHINE=zx81` | `kernel8-zx81.img` | Sinclair ZX-81 (1981) BASIC — the same `K` cursor, one year on |
| `MACHINE=tc2048` | `kernel8-tc2048.img` | Timex TC-2048 (1984) — a 48K-compatible Spectrum, boots to `© 1982 Sinclair Research Ltd` |
| `MACHINE=ts2068` | `kernel8-ts2068.img` | Timex Sinclair TS-2068 (1983) — the American 60Hz machine, boots to `© 1982 Sinclair Research Ltd` / `© 1983 Timex Computer Corp` on the NTSC canvas |
| `MACHINE=ts1000` | `kernel8-ts1000.img` | Timex Sinclair TS-1000 (1982) — the American ZX-81, the inverse-video `K` cursor on the NTSC canvas |
| `MACHINE=ts1500` | `kernel8-ts1500.img` | Timex Sinclair TS-1500 (1983) — the ZX-81 with 16K on board in a TS-1000 case, the inverse-video `K` cursor on the NTSC canvas |
| `MACHINE=pentagon` | `kernel8-pentagon.img` | Pentagon 128K (1991) — Vladimir Drozdov's Russian Spectrum clone, boots to a 128-style startup menu (Tape Loader, 128 BASIC, Calculator, 48 BASIC, TR-DOS) on the PAL canvas |
| `MACHINE=scorpio` | `kernel8-scorpio.img` | Scorpion ZS-256 (1992) — the Russian "Yellow PCB" clone, V.2.94 firmware boots to a menu (128 TR-DOS, 128 BASIC, Calculator, 48 BASIC, 48 TR-DOS) on the PAL canvas |
| `MACHINE=atmtb2` | `kernel8-atmtb2.img` | MicroART ATM-Turbo 2 (1992) — MicroART's Russian turbo Spectrum clone, boots to a MicroART firmware menu (CP/M, TR-DOS 48, Spectrum 128, Spectrum 48, Turbo On) over a red MicroART logo on the PAL canvas |
| `MACHINE=pentevo` | `kernel8-pentevo.img` | ZX Evolution: BASECONF (2009) — NedoPC's open-hardware Spectrum clone, boots to the EVO Reset Service v0.60.02 firmware, a BASECONF menu (TR-DOS boot, File browse, Tape load, SD-card boot, 48K/128K BASIC, …) beside a settings panel, on the PAL canvas |
| `MACHINE=picker` | `kernel8-picker.img` | MAME's system list — a menu; machines with ROMs on the card run |

The SD card is identical in every case — only the kernel differs. "Which
machine" is not configuration; it's which binary you boot. 💾

## 📺 Display: the regional canvas

The framebuffer geometry is Raspberry Pi boot configuration
(`width=`/`height=` in `cmdline.txt`, a documented Circle option), set per
**region**, not per machine — exactly the contract an 80s home computer had
with the family television. 📼 Two canvases ship: `cmdline-pal.txt` is the
720×576 PAL canvas that every PAL machine stretches to fill, and
`cmdline-ntsc.txt` is the 720×480 NTSC canvas for the American 60Hz
machines (the TS-2068 and the TS-1000). `make sd` copies the right one for the machine you
name. The GPU outputs that geometry as the video signal; your display's own
controller stretches it to the glass. `socmaxtemp=70` in the same file is
load-bearing thermal configuration: don't remove it. 🌡️

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

## 🏗️ Building

```sh
git clone --recursive https://github.com/Xalior/pi-mame.git
cd pi-mame

make deps      # circle-stdlib (multicore) + the SDL2 shim
make mame      # the MAME archives — the long one; log: build/mame-build.log
               # (genie's final host-style link fails by design; the
               #  archives are the product and the kernel links itself)
make kernels   # kernel8-spectrum.img, kernel8-spec128.img, kernel8-specpls2.img,
               #   kernel8-specpl2a.img, kernel8-specpls3.img, kernel8-tbblue.img,
               #   kernel8-specnext_ks1.img, kernel8-specnext_ks2.img,
               #   kernel8-specnext_ks3.img,
               #   kernel8-zx80.img, kernel8-zx81.img,
               #   kernel8-tc2048.img, kernel8-ts2068.img, kernel8-ts1000.img,
               #   kernel8-ts1500.img, kernel8-pentagon.img,
               #   kernel8-scorpio.img, kernel8-atmtb2.img,
               #   kernel8-pentevo.img, kernel8-picker.img

make sd MACHINE=spectrum ASSETS=~/my-assets   # see "Assets you must supply"
```

`make sd` assembles a complete copy-to-card tree in `build/sd/`:
Raspberry Pi firmware (fetched at the revision Circle pins), Circle's
`config64.txt` boot configuration, the PAL canvas `cmdline.txt`, and the
chosen kernel. `ASSETS` points at a directory you provide (layout below);
leave it off and `make sd` still builds the tree — you'll just add
`roms/` (and `next/`) to the card yourself.

Then, concretely: 💾

1. Format an SD card with a single **FAT32** partition (any size card; the
   Pi 4 boots from FAT).
2. Copy everything *inside* `build/sd/` onto it — files at the card's top
   level, not in a subfolder.
3. Put the card in the Pi, plug the display into **HDMI0 — the micro-HDMI
   port next to the USB-C power connector** — and power on. 🔌

## 🕹️ Assets you must supply

This repository contains no ROMs and no disk images. The `ASSETS`
directory you hand to `make sd` looks like this:

```
my-assets/
├── roms/
│   ├── spectrum.zip   # MAME-format ROM zip for the 48K
│   ├── spec128.zip    # …and for the 128
│   ├── specpls2.zip   # …and for the +2
│   ├── specpl2a.zip   # …and for the +2a
│   ├── specpls3.zip   # …and for the +3
│   ├── tbblue.zip     # …and for the Next (also feeds the KS1 and KS2 clones)
│   ├── zx80.zip       # …and for the ZX-80
│   ├── zx81.zip       # …and for the ZX-81
│   ├── tc2048.zip     # …and for the Timex TC-2048
│   ├── ts2068.zip     # …and for the Timex Sinclair TS-2068
│   ├── ts1000.zip     # …and for the Timex Sinclair TS-1000
│   ├── ts1500.zip     # …and for the Timex Sinclair TS-1500
│   ├── pentagon.zip   # …and for the Pentagon 128K (a spec128 clone; parent ROMs come from spec128.zip)
│   ├── scorpio.zip    # …and for the Scorpion ZS-256 (a spec128 clone; parent ROMs come from spec128.zip)
│   ├── atmtb2.zip     # …and for the MicroART ATM-Turbo 2 (a spec128 clone; parent ROMs come from spec128.zip)
│   ├── pentevo.zip    # …and for the ZX Evolution BASECONF (a spec128 clone; parent ROMs come from spec128.zip)
│   └── betadisk.zip   # Beta Disk / TR-DOS interface ROMs (the disk device shared by the pentagon, the scorpio, the atmtb2, and the pentevo)
└── next/
    └── next.img       # ZX Spectrum Next SD-card image (tbblue, specnext_ks1, specnext_ks2, specnext_ks3)
```

- ROM zips are standard MAME romsets, named for their machine.
- `pentagon`, `scorpio`, `atmtb2`, and `pentevo` are MAME clones of
  `spec128`: each zip (`pentagon.zip`, `scorpio.zip`, `atmtb2.zip`,
  `pentevo.zip`) carries only the clone's own ROMs, and MAME resolves the
  shared 128 ROMs from `spec128.zip` — so both the clone zip and
  `spec128.zip` must be present. Each machine's Beta Disk interface pulls
  the TR-DOS ROMs from `betadisk.zip` (MAME's `betadisk` device set).
- `next.img` is distributed by the
  [Spectrum Next project](https://www.specnext.com/latestdistro/); the
  `tbblue`, `specnext_ks1`, `specnext_ks2`, and `specnext_ks3` machines
  boot NextZXOS from it. `specnext_ks1`, `specnext_ks2`, and `specnext_ks3`
  are ROM-compatible clones of `tbblue` (KS3's trimmed BIOS list names only
  files `tbblue.zip` already carries), so they read `tbblue.zip` — no
  separate romset.
- Only supplying some assets is fine: machines without their ROMs simply
  won't run.

## ⌨️ At the keyboard

A USB keyboard is the machine's keyboard. Computers with full keyboards
receive **every** key by default; press **Scroll Lock** to toggle MAME's UI
controls (then **Tab** opens the menu — media loading lives there). On the
Spectrum, Left Shift is CAPS SHIFT and Right Shift is SYMBOL SHIFT. 🌈

## 🚧 Status

Video, input, and media loading are proven on hardware; audio is not wired
up yet. The emulation is currently single-threaded (`-numprocessors 1`) on
one of the Pi 4's four cores; a multicore architecture is designed and
measured, not yet integrated. This is a proof of concept wearing its P
proudly. 🚀

## ⚖️ License

The build glue and kernel host in this repository are GPLv3, matching the
projects they bind together. MAME, Circle, circle-stdlib, circle-newlib,
and circle-libsdl2 remain under their own licenses in their own trees.
