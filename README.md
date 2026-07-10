# pi-mame

Bare-metal MAME for the Raspberry Pi 4. No Linux, no OS, no desktop — the
Pi boots in seconds straight into an emulated machine, like an appliance,
because that's what it is.

pi-mame embeds MAME's emulation core on the [Circle](https://github.com/rsta2/circle)
bare-metal framework through a purpose-built
[SDL2 shim](https://github.com/Xalior/circle-libsdl2). Every image contains
the same compiled-in family of machines. What differs is what happens at
power-on, and that is decided when the image is **built** — never by config
files or a command line, because there are none. A machine image powers on
as its one machine, instantly, every time. The picker image powers on into
MAME's system list instead: pick any machine in the family with the
keyboard and it starts. Nothing you pick is remembered — power off, and the
next power-on asks again.

The family compiled into every image is exactly what the build's `SOURCES`
names: `spectrum.cpp` and `specnext.cpp` — the 48K ZX Spectrum with its
direct clones, and the ZX Spectrum Next (`tbblue`, with its SD card image
attached). The wider Sinclair range (128K, +2/+3, Timex, Pentagon, …) lives
in other driver files and is not built by default; adding it is a
`SOURCES` change in `scripts/build-mame.sh`.

## The default images

Everything on this page describes **this repository's build system and its
defaults** — the family it compiles, the machines it bakes, the canvas it
ships. All of it is yours to change: add a `MACHINE_DEFS_<name>` line in
`host/Makefile` to bake a different machine, change `SOURCES` in
`scripts/build-mame.sh` to compile a different family, write your own
canvas. A custom image is the same build with your choices in it.

Out of the box, three images:

| `make` | Image | Powers on into |
|---|---|---|
| `MACHINE=spectrum` | `kernel8-spectrum.img` | 48K ZX Spectrum BASIC |
| `MACHINE=tbblue` | `kernel8-tbblue.img` | ZX Spectrum Next / NextZXOS (needs `next/next.img` on the card) |
| `MACHINE=picker` | `kernel8-picker.img` | MAME's system list — the whole compiled family as a menu |

The SD card is identical in every case — only the kernel differs. "Which
machine" is not configuration; it's which binary you boot.

## Display: the regional canvas

The framebuffer geometry is Raspberry Pi boot configuration
(`width=`/`height=` in `cmdline.txt`, a documented Circle option), set per
**region**, not per machine: the shipped `cmdline-pal.txt` is a 720×576 PAL
canvas that every PAL machine stretches to fill — exactly the contract an
80s home computer had with the family television. The GPU outputs that
geometry as the video signal; your display's own controller stretches it
to the glass. `socmaxtemp=70` in the same file is load-bearing thermal
configuration: don't remove it.

## Prerequisites

- [Arm GNU toolchain](https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads)
  **aarch64-none-elf**, release 15.2.Rel1, on your `PATH`
- GNU make, `wget` (firmware download)
- On macOS: `brew install bash gnu-getopt`, and put both ahead of the
  system versions when building —

  ```sh
  export PATH="/opt/homebrew/opt/gnu-getopt/bin:/opt/homebrew/bin:$PATH"
  ```

  The stock bash 3.2 and BSD getopt silently break circle-stdlib's
  `configure` (the symptom is `Error: Invalid toolchain prefix`)
- ~15 GB of disk and some patience: MAME is a large build

## Building

```sh
git clone --recursive https://github.com/Xalior/pi-mame.git
cd pi-mame

make deps      # circle-stdlib (multicore) + the SDL2 shim
make mame      # the MAME archives — the long one; log: build/mame-build.log
               # (genie's final host-style link fails by design; the
               #  archives are the product and the kernel links itself)
make kernels   # kernel8-spectrum.img, kernel8-tbblue.img, kernel8-picker.img

make sd MACHINE=spectrum ASSETS=~/my-assets
```

`make sd` assembles a complete copy-to-FAT-card tree in `build/sd/`:
Raspberry Pi firmware (fetched at the revision Circle pins), Circle's
`config64.txt` boot configuration, the PAL canvas `cmdline.txt`, and the
chosen kernel. Copy its contents to an SD card's FAT partition and power
the Pi on.

## Assets you must supply

This repository contains no ROMs and no disk images. Your assets directory
provides:

- `roms/` — MAME-format ROM zips for the machines you build
  (e.g. `spectrum.zip`; `tbblue.zip` for the Next)
- `next/next.img` — a ZX Spectrum Next SD-card image, required by the
  `tbblue` machine (distributed by the
  [Spectrum Next project](https://www.specnext.com/latestdistro/))

## At the keyboard

A USB keyboard is the machine's keyboard. Computers with full keyboards
receive **every** key by default; press **Scroll Lock** to toggle MAME's UI
controls (then **Tab** opens the menu — media loading lives there). On the
Spectrum, Left Shift is CAPS SHIFT and Right Shift is SYMBOL SHIFT.

## Status

Video, input, and media loading are proven on hardware; audio is not wired
up yet. The emulation is currently single-threaded (`-numprocessors 1`) on
one of the Pi 4's four cores; a multicore architecture is designed and
measured, not yet integrated.

## License

The build glue and kernel host in this repository are GPLv3, matching the
projects they bind together. MAME, Circle, circle-stdlib, circle-newlib,
and circle-libsdl2 remain under their own licenses in their own trees.
