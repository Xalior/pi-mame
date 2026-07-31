## display
Amstrad

## intro
The Amstrad CPC family — the classic range, the cartridge-booting Plus
range and its GX4000 console, and the East German clone — plus another
Amstrad-badged machine built on different hardware: the PC1512,
Amstrad's 8086 IBM PC-compatible. Each
`make kernel MACHINE=<name>` below bakes one machine into its own
`kernel8-<name>.img` — see the [top-level README](../../README.md) for the
build and the regional canvas.

## quirks
- **The CPC+ range boots from the baked cart.** `cpc464p`, `cpc6128p`, and
  `gx4000` have empty romsets — no zip, because the Plus firmware lives on
  the cartridge itself. These images bake `-cart /carts/sysukpd.bin`, the
  game-free Locomotive BASIC + ParaDOS homebrew cart (MAME softlist entry
  `sysukpd`: `engpados.bin`, renamed `sysukpd.bin`), which you supply like
  every other asset. Other carts load through MAME's UI at runtime
  (Scroll Lock → Tab → file manager).
- **The GX4000 halts at the sign-on.** The keyboard-less console does not
  drop into BASIC; with the default cart it renders the sign-on and awaits
  a game cart. That is its correct power-on state.
- **The NC100 and NC200 are parked and are not built.** Both notepads are
  withdrawn from this platform: their emulated real-time clock does not
  survive a power cycle. The machine comes back to its main menu with its
  saved memory intact, but the clock reads 1 January 1990, 00:00. For a
  diary and clock organiser that is not shippable. Their pages remain as
  [nc100.md](nc100.md) and [nc200.md](nc200.md) for the record.

## machine_captions
cpc464: Amstrad's all-in-one home computer, boots to Locomotive BASIC 1.0: the yellow-on-blue `Amstrad 64K Microcomputer (v1)` / `©1984 Amstrad Consumer Electronics plc and Locomotive Software Ltd.` sign-on over `BASIC 1.0` / `Ready`, on the PAL canvas.
cpc464p: The Plus-range CPC, whose hardware boots from a cartridge: the image bakes `-cart /carts/sysukpd.bin` (the game-free Locomotive BASIC + ParaDOS cart), which signs on yellow-on-blue as `Amstrad Microcomputer (v4)` / `©1985 Amstrad plc and Locomotive Software Ltd.` / `PARADOS V1.1. ©1997 QUANTUM Solutions.` over `BASIC 1.1` / `Ready`, on the PAL canvas.
cpc6128: The 128K disk-based CPC, a cpc464 clone with 128K of RAM and a built-in 3" floppy drive, boots to Locomotive BASIC 1.1: the yellow-on-blue `Amstrad 128K Microcomputer (v3)` / `©1985 Amstrad Consumer Electronics plc and Locomotive Software Ltd.` sign-on over `BASIC 1.1` / `Ready`, on the PAL canvas.
cpc6128p: The 128K Plus-range CPC, whose hardware boots from a cartridge: the image bakes `-cart /carts/sysukpd.bin` (the game-free Locomotive BASIC + ParaDOS cart), which signs on yellow-on-blue as `Amstrad Microcomputer (v4)` / `©1985 Amstrad plc and Locomotive Software Ltd.` / `PARADOS V1.1. ©1997 QUANTUM Solutions.` over `BASIC 1.1` / `Ready`, on the PAL canvas — byte-identical to the `cpc464p` sign-on, because it comes from the cart, not the board.
cpc664: The short-lived disk-based CPC, a cpc464 clone with a built-in 3" floppy drive, boots to Locomotive BASIC 1.1: the yellow-on-blue `Amstrad 64K Microcomputer (v2)` / `©1984 Amstrad Consumer Electronics plc and Locomotive Software Ltd.` sign-on over `BASIC 1.1` / `Ready`, on the PAL canvas.
gx4000: The keyboard-less games console of the Plus range, whose hardware boots from a cartridge: the image bakes `-cart /carts/sysukpd.bin` (the game-free Locomotive BASIC + ParaDOS cart), which renders `Amstrad Microcomputer (v4)` / `©1985 Amstrad plc and Locomotive Software Ltd.` and halts at that sign-on — with no keyboard, the console does not drop into BASIC; it awaits a game cart. That is its correct power-on state, on the PAL canvas.
kccomp: The East German CPC clone — a cpc464 clone whose reworked firmware carries its own maker's sign-on, the yellow-on-blue `KC compact` / `Version 1.3` above `BASIC 1.1` and `Ready`, on the PAL canvas.
nc100: A Z80-based A4 notepad computer, powers on to its `Set time and date` screen: a `London` / `Mon 1 Jan 1990` status bar above a time box (`00:00`) and a date box (`1 Jan 1990`), with the prompt `Set the time...` / `Press ↑↓ to adjust the hour` / `Press ↵ when finished` / `Press Stop to exit`, in the LCD's blue-on-tan, stretched to fill the PAL canvas.
nc200: The NC100's successor — a taller 480×128 LCD and a built-in 3½″ floppy drive — powers on to the same `Set time and date` first-run screen: the `Set time and date` title bar, a time box (`00:00`) and a date box (`1 Jan 1990`), the prompt `Set the time...` / `Press ↑↓ to adjust the hour` / `Press ↵ when finished` / `Press Stop to exit`, and a live `MONDAY 1 JAN` / `London` calendar-clock widget ticking away, in the LCD's blue-on-tan, stretched to fill the PAL canvas.
pc1512: Amstrad's 8086 IBM PC-compatible, the first x86 machine in the set, powers on through its ROM BIOS self-test to the `AMSTRAD PC 512k (V1)` / `(c)1986 AMSTRAD Consumer Electronics plc` sign-on and, with no floppy or hard media shipped, `Please set time and date` / `Please set user options (if required)` above `Insert a SYSTEM disk into drive A` / `Then press any key`, on the PAL canvas.

## machine_notes
cpc464p: Other carts load through MAME's UI at runtime (Scroll Lock → Tab → file manager).
cpc6128p: Other carts load through MAME's UI at runtime (Scroll Lock → Tab → file manager).
gx4000: Other carts load through MAME's UI at runtime (Scroll Lock → Tab → file manager).
kccomp: `farben.rom` is the colour PROM.
nc100: Own 480×64 monochrome LCD and built-in organiser firmware — not a CPC, the same maker's later portable.
nc100: Battery-backed memory: shut it down with its own **On/Off** key before removing power and it keeps its clock and memory, warm-booting straight to the main menu next time. Cut the power mid-session and it forgets — coming back to this Set-time screen with the clock reset, exactly as the real NC100 did. Faithful modelling, not a bug.
nc200: Battery-backed memory: shut it down with its own **On/Off** key before removing power and it keeps its clock and memory, warm-booting straight to the main menu next time. Cut the power mid-session and it forgets — coming back to this Set-time screen with the clock reset, exactly as the real NC200 did. Faithful modelling, not a bug.

## withdrawn
nc100: **Parked — not built and not shipped.** This machine's emulated real-time clock does not survive a power cycle. Set the clock, save, power off and on, and it returns to its main menu with its saved memory intact but the clock reset to 1 January 1990, 00:00. For a machine whose purpose is a diary and clock, that is not shippable, so it is withdrawn from the Amstrad roster until the clock is fixed. Proven on a Raspberry Pi 5, 27 July 2026. This page is kept for the record.
nc200: **Parked — not built and not shipped.** This machine's emulated real-time clock does not survive a power cycle. Set the clock, save, power off and on, and it returns to its main menu with its saved memory intact but the clock reset to 1 January 1990, 00:00. For a machine whose purpose is a diary and clock, that is not shippable, so it is withdrawn from the Amstrad roster until the clock is fixed. Proven on a Raspberry Pi 5, 27 July 2026. This page is kept for the record.

## machine_sections
### cpc6128: Booting media
![Amstrad CPC6128 running Lala Prologue "The Magical"](images/cpc6128-lala.jpg)

Lala Prologue "The Magical" (Mojon Twins, 2010, CC BY-NC-SA 3.0) loaded from a `.dsk` floppy with `RUN"LALA`, showing its title screen.

### cpc6128p: Booting media
![Amstrad CPC6128+ running Goldorak](images/cpc6128p-goldorak.jpg)

Goldorak (Titan, freeware fan game) auto-booted from a CPC+ cartridge (`.cpr`), showing its title screen.

### gx4000: Booting media
![Amstrad GX4000 running Hyperdrive from cartridge](images/gx4000-hyperdrive.jpg)

Fit a game cartridge and the GX4000 boots straight into it — no keyboard, no load command. Shown: **Hyperdrive** (Juan J. Martínez, CC BY-NC-SA 4.0), a native GX4000 / CPC Plus vertical shoot-'em-up, auto-booting from its `.cpr` cartridge into gameplay.

### pc1512: Booting media
![Amstrad PC1512 booted to the FreeDOS prompt](images/pc1512-freedos.jpg)

FreeDOS (GPL) auto-booting from a 360K floppy in drive A: to the `A:\>` prompt — the PC1512's IBM-PC-XT-class BIOS treats it like any DOS floppy.
