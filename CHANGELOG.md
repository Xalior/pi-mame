# Changelog

## PoC2 — Me and my Shadow core · 2026-07-14

- **Settings and NVRAM persist.** The appliance never exits, so MAME's
  exit-time persistence never fires, and no timer can tell a deliberate setting
  from a ticking clock register. Machine settings and battery-backed RAM are
  now checkpointed on the falling edge of MAME's own menu — the one trustworthy
  signal that the user just changed something and closed the OSD — writing each
  device's store into a baked NVRAM directory. Machines with an emulated
  real-time clock (the Amstrad NC100/NC200) read an *unset* wall-clock as
  power-loss and wipe their battery RAM on boot, so the kernel seeds a
  factory-style wall-clock before MAME constructs the machine; the NC100 now
  warm-boots to its own menu with the clock intact. Zero MAME modifications:
  the OSD subclass drives MAME's own public save paths.
- **The loaders became their own project.** The boot picker and the development
  network-loader now live in a standalone repository,
  [rapi-bootloader](https://github.com/Xalior/rapi-bootloader), which **owns the
  0x800 defaults-block ABI** — its README is the authoritative spec, and
  `docs/defaults-abi.md` here is now just a reference to it. pi-mame submodules
  it: a card's picker is its *menu-loader*, and its *network-loader* serves
  TFTP/HTTP/WebDAV for reflash-free development. Neither is pi-mame-specific —
  the design dates to NextPi (2018) and stands on its own.
- **One Circle world per threading model.** Each consumer now owns its
  `circle-stdlib` as a nested submodule instead of the tree carrying shared
  top-level ones: **circle-libsdl2** owns the MULTICORE world (the shim's
  core-split runs a presentation worker on a second physical core) and
  **rapi-bootloader** owns the SINGLE-CORE world (Circle's `EnableChainBoot()`
  refuses a multicore build). The top-level `circle`, `circle-newlib` and
  `circle-stdlib` submodules are gone, and `make deps` is two self-contained
  calls. A fresh `git clone --recursive` plus `make deps` builds everything,
  with nothing else to configure.
- **Card image naming scheme.** The Raspberry Pi firmware boots
  `pi-mame-boot-<board>.img` (the boot picker), selected by the board section
  in our own `config.txt`; the picker chain-boots `pi-mame-core-<board>.img`
  (the MAME core carrying the defaults ABI). A single-machine card has no
  picker — the firmware boots the core directly. The board token is Circle's
  `rpi4` image suffix; the `config.txt` section is the firmware's `[pi4]`
  board filter. Card zips are `pi-mame-<tag>-<platform>-<tier>.zip` — the
  board token lives inside, on the images.
- **Boot picker and defaults-ABI docs.** `docs/bootmenu.md` documents the
  boot picker and the `bootmenu.cfg` format for card builders;
  `docs/defaults-abi.md` documents the patchable-defaults block's layout
  and writer/receiver contracts for anyone building their own tooling
  against a pi-mame image.
- **A defaults-block ABI in every kernel image.** Kernel images carry a
  patchable block at fixed offset `0x800`: `PM8D` magic, capacity and
  length fields, and a 512-byte text buffer holding the machine name
  and its media arguments. Any holder of the image before boot — the
  build system, the dev chainloader, the boot picker, or third-party
  tooling — may rewrite the text after verifying the magic; the kernel
  tokenises it into MAME's argv at boot. Writers and receiver compile
  the same header (`rapi-bootloader/defaultsblock/defaultsblock.h`); a
  four-byte trampoline at the image entry displaces Circle's startup past
  the block.
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
