# pi-mame

Bare-metal MAME for the Raspberry Pi 4. No Linux, no OS, no desktop — the
Pi boots in seconds straight into an emulated machine, like an appliance,
because that's what it is.

pi-mame embeds MAME's emulation core on the [Circle](https://github.com/rsta2/circle)
bare-metal framework through a purpose-built
[SDL2 shim](https://github.com/Xalior/circle-libsdl2). MAME's desktop
surface — command line, config files, snapshots, debugger — never ships:
every image is built with its configuration baked in. One machine per
image; switching machines means booting a different kernel.

The current family is the Sinclair range (SUBTARGET=spectrum): the 48K
ZX Spectrum, the ZX Spectrum Next (`tbblue`, with its SD card image
attached), and three dozen relatives.

## The three images

| `make` | Image | Boots into |
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
- On macOS: Homebrew `bash` (5.x) and `gnu-getopt` on `PATH` ahead of the
  system versions — circle-stdlib's `configure` needs them
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
