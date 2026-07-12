# Changelog

## PoC2 — in progress (unreleased)

Work landed so far this cycle. Nothing here has shipped: it's unreleased,
and the core split below is still awaiting review.

- **The core split.** MAME's emulation core now runs alone on its own CPU
  core, with all platform access (video, input, audio, file I/O) marshaled
  through the shim to a dedicated services core, presentation moved off the
  emulation core entirely, a hardware-threads layer for secondary-core
  work, and a cross-core heartbeat/watchdog that detects a stalled core
  instead of hanging silently. De-risked by a series of on-hardware
  experiments beforehand, then proven on real hardware with the ZX Spectrum
  Next (tbblue), which booted NextZXOS to its main menu and sustained a
  live, animating screensaver — continuous cross-core frame delivery, not
  just a static boot screen. This work is unpushed and pending review; it
  has not been promoted onto the full machine table yet.
- **The patchable-defaults factory.** A platform now builds as a single
  kernel binary: the specific machine, and its media defaults, are patched
  into a small fixed block in the image at boot, rather than needing a
  separate rebuild per machine. An unpatched image still boots its baked
  defaults unchanged, so a plain build behaves exactly as before.
- **The boot picker.** A chainboot menu, separate from PoC1's MAME
  system-list picker: it reads a boot-menu configuration file from the
  card, takes a keyboard selection, and chain-boots the chosen machine
  before MAME itself ever starts. Build-verified — compiles, links, and
  fits comfortably under the kernel size ceiling — and this cycle, the
  receiving side was proven on hardware too: given a selection, it
  chain-boots the chosen machine end to end.
- **Per-platform builds.** Each platform (a MAME `src/mame/<vendor>/`
  directory) builds in its own MAME tree — own `SUBTARGET`, `SOURCES`,
  and `BUILDDIR` — and links one platform binary. Per-machine images
  are byte-patches of that binary's defaults block.
- **Commodore platform added.** 29 machines from the c64, vic20 and
  plus4 driver families, each with an HDMI capture from a real Pi 4 in
  [docs/commodore/](docs/commodore/README.md).
- **Quoted defaults arguments and view selection.** The defaults string
  accepts double-quoted arguments containing spaces; `-view` selects
  which screen a multi-screen machine renders full-canvas.
- **Platform card zips.** Releases build one zip per platform and tier:
  the boot picker, the platform binary, a generated `bootmenu.cfg`
  listing the tier's machines, and the tier's assets. `cpc464`,
  `cpc664` and `cpc6128` moved to the free tier under Amstrad's
  recorded distribution permission; an amstrad-free card now builds.
  Commodore has no free tier.

## PoC1 — vStranger · 2026-07-11

The first release. If you're new here, this is the orientation.

### What changes over stock MAME

pi-mame is a bare-metal build target for MAME: `TARGETOS=rapi-circle`,
`OSD=sdl`, linking MAME's emulation core directly against the
[Circle](https://github.com/rsta2/circle) bare-metal framework through an
SDL2-compatible shim — no Linux, no OS of any kind underneath. The image
ships the emulation core only; MAME's desktop application surface never
ships — no environment, no user-editable command line, no debugger, no
snapshot tooling, no developer tools. Every image bakes exactly one machine
(or the system-list picker, below) at a fixed resolution with software
rendering, and runs single-process with cooperative threading
(`-numprocessors 1`). Which machine an image runs is a build-time choice,
never runtime configuration. The MAME fork itself carries a minimal,
well-isolated branch: the flag and toolchain surgery needed to build this
way lives in out-of-tree compiler wrappers, not as changes scattered through
the MAME tree.

### Linked projects

- [Circle](https://github.com/rsta2/circle) — the bare-metal framework
  MAME's core runs on.
- [circle-stdlib](https://codeberg.org/larchcone/circle-stdlib) and
  [circle-newlib](https://codeberg.org/larchcone/circle-newlib) — the C/C++
  standard library layer over Circle.
- [circle-libsdl2](https://github.com/Xalior/circle-libsdl2) — a
  from-scratch SDL2-compatible shim mapping the SDL2 API surface MAME calls
  onto Circle's bare-metal drivers.
- [mame](https://github.com/Xalior/mame), branch `rapi-circle` — the MAME
  fork carrying the bare-metal target.
- The [Arm GNU toolchain](https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads),
  release 15.2.Rel1, target `aarch64-none-elf` — the cross compiler.

### Systems and subsystems supported

Two platforms, one machine per image, plus a picker image that boots into
MAME's own system list (machines with ROMs on the card run from there):

- **Sinclair** — 48K ZX Spectrum, ZX Spectrum 128, +2, +2a, +3, ZX Spectrum
  Next (original board plus the KS1, KS2, and KS3 Kickstarter boards),
  Sinclair ZX-80 and ZX-81, Timex TC-2048, TS-2068, TS-1000, and TS-1500,
  and the Eastern Bloc clone family: Pentagon 128K, Scorpion ZS-256,
  MicroART ATM-Turbo 2, ZX Evolution BASECONF, ZX Evolution
  TS-Configuration, Elwro 800-3 Junior, PEVM Byte, and the Peters Plus
  Sprinter.
- **Amstrad** — CPC464, CPC664, CPC6128, the cartridge-booting CPC464+,
  CPC6128+, and GX4000, the KC Compact clone, the NC100 and NC200 notepad
  organisers, and the PC1512 SD (Amstrad's 8086 IBM PC compatible).

Platform subsystems proven under this release: video (framebuffer output
with software rendering — the Pi 4 has no bare-metal GPU driver, so
software rendering is the design, not a stopgap), USB HID keyboard input,
the USB host stack those keyboards attach to, FatFs SD card storage, and
CPU throttle / thermal management. The shim also implements an HDMI audio
output path, though no shipped machine image has MAME's audio wired up to
it yet.
