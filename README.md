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

- **Two platforms are proven** — Sinclair and Amstrad. Each is a family of
  machines built on related hardware, sharing a MAME driver lineage and,
  often, ROMs: see [docs/sinclair/](docs/sinclair/README.md) and
  [docs/amstrad/](docs/amstrad/README.md) for exactly which machines and
  what each needs.
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

Every image bakes one machine (or the picker) into `host/kernel.cpp` as
compiled-in constants — no CLI, no config files of ours. "Which machine"
is not configuration; it's which binary you boot, and the SD card is
identical in every case: only the kernel differs. 💾

| `make` | Image | Powers on into |
|---|---|---|
| `MACHINE=picker` | `kernel8-picker.img` | MAME's system list — a menu; machines with ROMs on the card run |

Every other machine belongs to one of two platforms:

| Platform | Details | Machines |
|---|---|---|
| Sinclair — the ZX Spectrum family and its clones | [docs/sinclair/README.md](docs/sinclair/README.md) | [`docs/sinclair/`](docs/sinclair/) |
| Amstrad — the CPC family, the NC notepads, and the PC1512 | [docs/amstrad/README.md](docs/amstrad/README.md) | [`docs/amstrad/`](docs/amstrad/) |

Each platform page carries its own machine table (`make MACHINE=` target,
system, year, romset, TV region) and a details page per machine covering
exactly what appears on the glass at power-on and exactly which assets it
needs.

## 📺 Display: the regional canvas

The framebuffer geometry is Raspberry Pi boot configuration
(`width=`/`height=` in `cmdline.txt`, a documented Circle option), set per
**region**, not per machine — exactly the contract an 80s home computer had
with the family television. 📼 Two canvases ship: `cmdline-pal.txt` is the
720×576 PAL canvas that every PAL machine stretches to fill, and
`cmdline-ntsc.txt` is the 720×480 NTSC canvas for the American 60Hz
machines. `make sd` copies the right one for the machine you
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
make kernels   # every machine's kernel8-<machine>.img, plus kernel8-picker.img
               #   — see docs/sinclair/ and docs/amstrad/ for the full list,
               #   or `make kernel MACHINE=<name>` for just one

make sd MACHINE=spectrum ASSETS=~/my-assets   # see "Assets you must supply"
```

`make sd` assembles a complete copy-to-card tree in `build/sd/`:
Raspberry Pi firmware (fetched at the revision Circle pins), Circle's
`config64.txt` boot configuration, the machine's regional canvas
`cmdline.txt`, and the chosen kernel. `ASSETS` points at a directory you
provide (layout on the platform pages); leave it off and `make sd` still
builds the tree — you'll just add `roms/` (and any platform extras)
to the card yourself.

Then, concretely: 💾

1. Format an SD card with a single **FAT32** partition (any size card; the
   Pi 4 boots from FAT).
2. Copy everything *inside* `build/sd/` onto it — files at the card's top
   level, not in a subfolder.
3. Put the card in the Pi, plug the display into **HDMI0 — the micro-HDMI
   port next to the USB-C power connector** — and power on. 🔌

## 🕹️ Assets you must supply

This repository contains no ROMs and no disk images. `make sd`'s `ASSETS`
directory always has a `roms/` folder; some platforms add their own
subfolder alongside it (the Sinclair platform's Next SD-card image lives
in `next/`, for instance). Each platform page has the exact tree:
[docs/sinclair/README.md](docs/sinclair/README.md#assets) and
[docs/amstrad/README.md](docs/amstrad/README.md#assets). Only supplying
some assets is fine: machines without their ROMs simply won't run.

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
