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

- **Two machines run.** 🕹️ The 48K ZX Spectrum and the ZX Spectrum Next
  (`tbblue`, with its SD card image attached). That's it. That's the list.
- **One driver family is compiled.** The build's `SOURCES` names exactly
  two MAME driver files: `spectrum.cpp` and `specnext.cpp`. The picker's
  list shows everything those files define, but a listed machine only runs
  if you've supplied its ROMs — with the default assets, that's the two
  above.
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

Out of the box, three images:

| `make` | Image | Powers on into |
|---|---|---|
| `MACHINE=spectrum` | `kernel8-spectrum.img` | 48K ZX Spectrum BASIC |
| `MACHINE=tbblue` | `kernel8-tbblue.img` | ZX Spectrum Next / NextZXOS (needs `next/next.img` on the card) |
| `MACHINE=picker` | `kernel8-picker.img` | MAME's system list — a menu; machines with ROMs on the card run |

The SD card is identical in every case — only the kernel differs. "Which
machine" is not configuration; it's which binary you boot. 💾

## 📺 Display: the regional canvas

The framebuffer geometry is Raspberry Pi boot configuration
(`width=`/`height=` in `cmdline.txt`, a documented Circle option), set per
**region**, not per machine: the shipped `cmdline-pal.txt` is a 720×576 PAL
canvas that every PAL machine stretches to fill — exactly the contract an
80s home computer had with the family television. 📼 The GPU outputs that
geometry as the video signal; your display's own controller stretches it
to the glass. `socmaxtemp=70` in the same file is load-bearing thermal
configuration: don't remove it. 🌡️

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
make kernels   # kernel8-spectrum.img, kernel8-tbblue.img, kernel8-picker.img

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
│   └── tbblue.zip     # …and for the Next
└── next/
    └── next.img       # ZX Spectrum Next SD-card image (tbblue only)
```

- ROM zips are standard MAME romsets, named for their machine.
- `next.img` is distributed by the
  [Spectrum Next project](https://www.specnext.com/latestdistro/); the
  `tbblue` machine boots NextZXOS from it.
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
