# Changelog

## PoC3 — I can't believe it's not Silicon Spread · 2026-07-27

pi-mame runs MAME's emulation core directly on Raspberry Pi hardware, with
no operating system underneath it. There is no Linux, no shell, no desktop
and no configuration to edit: the machine an image emulates is fixed when
that image is built. Power on, and the emulated computer is on screen in a
few seconds.

This release extends pi-mame from one Raspberry Pi model to three, from
four computer families to fifteen, and changes the form the release takes.

### Which file to download

pi-mame now supports the **Raspberry Pi 3, 4 and 5**. Earlier releases
supported the Pi 4 only.

Each board has its own build, and **the board is the last field in every
filename**:

    pi-mame-<version>-<family>-<free|public>-<rpi3|rpi4|rpi5>.zip

An image built for one board will not boot on another. If you own more
than one Pi, this is the field to check.

### What a download contains

Each zip is a complete SD card: the Raspberry Pi firmware for that board,
the boot configuration, a boot menu, the emulator built for that family,
and the ROMs that family's menu refers to.

1. Format an SD card with a single **FAT32** partition.
2. Unzip the archive onto it, with the files at the top level of the card
   rather than inside a directory.
3. Insert the card, connect the display to **HDMI0** — on the Pi 4 and Pi 5
   the micro-HDMI socket nearest the USB-C power connector, and on the Pi 3
   the single full-size HDMI socket.
4. Power on.

The boot menu lists that family's machines. Selecting one writes the
machine's name into the emulator image and starts it. The selection is not
persistent: the next power-on presents the menu again.

### The free and public editions

Each family is published in up to two editions, which differ only in the
provenance of the ROMs they carry.

- **free** — ROMs whose redistribution the rights holder has explicitly
  permitted, obtained from an upstream that distributes them under that
  permission. Amstrad's standing permission covers the Sinclair and
  Amstrad machines, which is why those families have a free edition.
- **public** — ROM sets mirrored on public archives. They are in wide
  circulation but carry no explicit grant, and using them is a decision
  the reader makes rather than one this project makes for them.

Nine assets in the manifest are free-tier against 177 public, so most
families are published as a public edition only — no comparable permission
exists for them. A family whose free menu would contain no bootable
machine is not published in that edition at all.

Every ROM is verified by CRC32 and SHA1 against `scripts/assets.manifest`
before it is packaged, using the checksums MAME itself declares.

### Fifteen families, 195 machines

- **Sinclair** — ZX Spectrum family, ZX80/ZX81, ZX Spectrum Next (23)
- **Amstrad** — CPC range, NC100/NC200 notepads, PC1512 (10)
- **Commodore** — C64 range, VIC-20, TED machines (29)
- **Amiga** — Arcadia Multi Select coin-op systems (19)
- **Atari** — 8-bit line, 400 through XEGS (10)
- **Acorn** — BBC Micro family, Electron, Atom (26)
- **EACA** — Colour Genie (2)
- **MGT** — SAM Coupé (1)
- **Camputers** — Lynx (3)
- **Tatung** — Einstein (2)
- **Memotech** — MTX line (3)
- **Enterprise** — Enterprise 64 and 128 (3)
- **Sord** — m5 (3)
- **VTech** — Laser/VZ family and relatives (24)
- **TRS** — TRS-80, CoCo, Dragon, MC-10 (37)

Every machine on the roster carries a verdict obtained on real hardware,
recorded on its family's page under `docs/`. Machines that run are
documented with an HDMI capture of the actual display. Machines that do
not are recorded as parked, with the cause.

The dominant cause is not emulation failure. MAME raises a modal warning
box for machines flagged with imperfect or missing subsystems, and an
appliance with no user-facing input path at that moment cannot dismiss it,
so the machine is held behind a dialog rather than failing to emulate.
Three machines require media that cannot be supplied, one is blocked by a
cartridge that cannot be proven, one hits a cooperative-scheduling hang,
and two fail to build in this toolchain.

### Raspberry Pi 5 support

The Pi 5 payload now boots. Chain-loading works, and the serial console
runs on the GPIO14/15 header pins on all three boards.

The Pi 5 differs from its predecessors in an important respect: its
firmware will not output a requested video mode. Mode requests over the
mailbox interface are acknowledged and then ignored, and every kernel
inherits a single surface at the display's native EDID mode. pi-mame
therefore queries the surface it was given, sizes its window to that, and
presents through a shadow buffer. The Pi 5 build alone enables MAME's
aspect-preserving scaler, which is affordable on that CPU and not on the
others; the Pi 3 and Pi 4 blit 1:1 into a framebuffer whose geometry is
set by `cmdline.txt`, and rely on the display to stretch it.

The practical consequence is visible on machines whose panels are not
approximately 4:3. The Amstrad NC100 (480x64) and NC200 (480x128) render
in their true proportions on a Pi 5, and are stretched to fill the canvas
on a Pi 3 or Pi 4.

### Removed: the per-machine download

Previous releases published one `kernel8-<machine>.img` per machine. This
release does not.

At fifteen families the full set is 195 machines across three boards, at
roughly 84 MB each — approximately 49 GB per release, which exceeds both
the CI runner's disk and any reasonable release page. The redundancy is
almost total: a per-machine image is its family's binary with a 28-byte
string patched in at offset `0x800`.

Releases now carry the card archives and the per-family binaries. A
single-machine image remains one command from the published sources:

    make kernel MACHINE=<name>

The defaults block that command patches is unchanged and remains
documented in `docs/defaults-abi.md` — a magic value, capacity and length
fields, and a 512-byte text buffer that any holder of an image may rewrite
before boot. Third-party tooling built against it is unaffected.

### Sound

No image produces sound. The audio path itself is implemented and working:
the SDL layer drives HDMI audio through Circle's sound device with a
hardware queue of roughly 100 ms, exposes the standard
`SDL_OpenAudioDevice` callback interface, and carries samples across the
core split on a lock-free ring. What is absent is the connection between
MAME's own sound output and that path. It is the next milestone's work.

### Build changes

- **Per-board toolchains.** The newlib and libc++ sysroot pi-mame links
  against is compiled per architecture, so MAME is built once per board,
  each in its own source tree against its own Circle world, differentiated
  by the cross-compiler wrapper's `-mcpu` and `-DRASPPI` flags.
- **One engine per board, one driver set per family.** PoC2 compiled a
  complete MAME for every family. A board now compiles a single shared
  engine once: the framework that does not vary with the driver list, all
  third-party dependencies, and the combined device closure of every
  shipped family's drivers. Each family's kernel then links that engine
  against a driver list generated from its own sources, using MAME's own
  `sourcesfilter` and `driverlist` tools, so the linker retains only that
  family's machines. Output images are the size they always were; the
  compile is performed once rather than once per family.
- **CI covers all three boards.** One job per board, running concurrently,
  with fail-fast disabled so a failure on one board still reports the
  others. CI invokes the same `make` targets documented in the README —
  `make dist` is the release — so the published build instructions are the
  ones under test.
- **Cards carry only their own media.** Card assembly previously copied
  every family's ROMs, disk and cartridge images onto every card,
  producing a 2.2 GB Amstrad card that could not fit 1 GB media. A card
  now derives its contents from its own generated menu: approximately
  86 MB for that same card.

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
- **The core split: MAME gets a CPU core to itself.** The emulation core now
  runs alone on core 1. Core 0 keeps the platform — devices, scheduler, the
  shim's servo task and a cross-core watchdog that catches a stalled core
  instead of hanging silently — and core 2 does nothing but present frames:
  blit and page flip, off the emulation core entirely. MAME reaches the
  hardware through lock-free rings (events in, audio out), a one-deep frame
  mailbox, and a marshalled call path for the rare ones; its file I/O is
  `osd_file` reimplemented over that path, because a core that does not own
  the SD card must not touch it. MAME's threads become hardware threads,
  pinned to cores, by link substitution — the standard library's threading is
  swapped out, with no change to circle-stdlib. Proven on real hardware: the
  ZX Spectrum Next boots NextZXOS from its 2 GB hard-disk image and sustains a
  live, animating screensaver — continuous cross-core frame delivery, not a
  static boot screen.
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
