# Changelog

pi-mame doesn't version by semver yet — each cycle is a named proof-of-concept
(PoC). This log starts with PoC1, the first released cycle, then rolls
straight into PoC2, the cycle in progress.

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

## PoC2 — in progress (unreleased)

Work landed so far this cycle. Nothing here has shipped: it's unreleased,
and the larger of the two pieces below is still awaiting review.

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
- **The boot picker.** A chainboot menu, separate from PoC1's MAME
  system-list picker: it reads a boot-menu configuration file from the
  card, takes a keyboard selection, and chain-boots the chosen machine
  before MAME itself ever starts. Build-verified — compiles, links, and
  fits comfortably under the kernel size ceiling — but not yet proven on
  hardware: the menu display, keyboard input, SD reads, and the chain-boot
  hand-off to a machine kernel are all still owed a hardware pass.
