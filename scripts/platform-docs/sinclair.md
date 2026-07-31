## display
Sinclair

## intro
The ZX Spectrum family: Sinclair's own machines, the Amstrad-era +2/+2a/+3,
the Kickstarter-era ZX Spectrum Next boards, the Timex NTSC variants, and
the Eastern Bloc clones (Russian, Polish) that grew their own firmware
around the same hardware. Each `make kernel MACHINE=<name>` below bakes one
machine into its own `kernel8-<name>.img` — see the [top-level
README](../../README.md) for the build and the regional canvas.

## quirks
- **The Next needs `next.img`.** `tbblue`, `specnext_ks1`, `specnext_ks2`,
  and `specnext_ks3` all boot NextZXOS from `media/hard/tbblue/next.img`
  (distributed by the [Spectrum Next
  project](https://www.specnext.com/latestdistro/)), attached as the
  machine's hard disk. `specnext_ks1`, `specnext_ks2`, and `specnext_ks3`
  are each a MAME clone of `tbblue` with their own board-specific romset,
  and each also needs `tbblue.zip` on the card alongside its own.
- **The Russian clones share `betadisk.zip`.** `pentagon`, `scorpio`,
  `atmtb2`, and `pentevo` are each a MAME clone of `spec128`, but each
  carries its own complete, self-contained romset — nothing is borrowed
  from `spec128.zip`. What they do share is their built-in Beta Disk /
  TR-DOS interface, which reads `betadisk.zip`.
- **The Timex machines are NTSC, but their card is not.** `ts2068`,
  `ts1000`, and `ts1500` are the 60Hz American Sinclair/Timex machines.
  Every card built today uses the 720×576 PAL canvas, these included;
  giving them `cmdline-ntsc.txt`'s 720×480 canvas is work still to come.

## machine_captions
atmtb2: A Russian turbo Spectrum clone, boots to a MicroART firmware menu (CP/M, TR-DOS 48, Spectrum 128, Spectrum 48, Turbo On) over a red MicroART logo on the PAL canvas.
byte: A Soviet Spectrum clone from the Brest Electromechanical Plant, its Prusak firmware boots to a Cyrillic maker's credit (`Брестское ПО` / `средств вычислительной техники`) at the foot of the grey PAL canvas.
elwro800: A Polish Spectrum clone built for schools, boots to an `ELWRO 800-3 Junior` banner (`64kB RAM 24kB ROM   wersja dyskowa`, the yellow `elwro` logo, the Spectrum K cursor) on the PAL canvas.
pentagon: A Russian Spectrum clone, boots to a 128-style startup menu (Tape Loader, 128 BASIC, Calculator, 48 BASIC, TR-DOS) on the PAL canvas.
pentevo: An open-hardware Spectrum clone, boots the EVO Reset Service v0.60.02 firmware to a BASECONF menu (TR-DOS boot, File browse, Tape load, SD-card boot, 48K/128K BASIC, …) beside a settings panel, on the PAL canvas.
scorpio: The Russian "Yellow PCB" clone, V.2.94 firmware boots to a menu (128 TR-DOS, 128 BASIC, Calculator, 48 BASIC, 48 TR-DOS) on the PAL canvas.
spec128: ZX Spectrum 128 startup menu (128 BASIC, Tape Loader, …).
specnext_ks1: ZX Spectrum Next / NextZXOS on the KS1 board, booting from its attached SD card image.
specnext_ks2: ZX Spectrum Next / NextZXOS on the KS2 board, booting from its attached SD card image.
specnext_ks3: ZX Spectrum Next / NextZXOS on the KS3 board, booting from its attached SD card image.
specpl2a: ZX Spectrum +2a startup menu (Loader, +3 BASIC, Calculator, 48 BASIC) — the +3's firmware in the +2's cassette case.
specpls2: ZX Spectrum +2 startup menu — Amstrad's grey 128.
specpls3: ZX Spectrum +3 startup menu (Loader, +3 BASIC, Calculator, 48 BASIC; drives A: and M:) — the same firmware with the built-in 3" floppy drive.
spectrum: 48K ZX Spectrum BASIC.
sprinter: A Z84C015-plus-FPGA Spectrum-compatible, its Sprinter BIOS v3.04.253 powers on to a BIOS report (model name, board ID, 4096K memory, CMOS clock) and, with no CF/IDE media shipped, `Detecting IDE Primary Master ... None` and `Start from Hard disk...fail` / `Alternative Start from Diskette...fail`, on the PAL canvas.
tbblue: ZX Spectrum Next / NextZXOS, booting from its attached SD card image.
tc2048: A 48K-compatible Spectrum, boots to `© 1982 Sinclair Research Ltd`.
ts1000: The American ZX-81, the inverse-video K cursor on the NTSC canvas.
ts1500: The ZX-81 with 16K on board in a TS-1000 case, the inverse-video K cursor on the NTSC canvas.
ts2068: The American 60Hz machine, boots to `© 1982 Sinclair Research Ltd` / `© 1983 Timex Computer Corp` on the NTSC canvas.
tsconf: An FPGA-based Spectrum clone with the TS-Configuration video/DMA extensions, boots its TS-BIOS on the PAL canvas.
zx80: Sinclair ZX-80 BASIC — the inverse-video K cursor.
zx81: Sinclair ZX-81 BASIC — the same K cursor, one year on.

## machine_notes
byte: Self-contained: Prusak boot ROMs + the DD66/DD71 and TBD PROMs.
elwro800: Self-contained: BASIC/boot EPROMs + I/O, memory, and TV PROMs.
pentagon: Its built-in Beta Disk interface carries a TR-DOS entry on the startup menu.
tbblue: `specnext_ks1`, `specnext_ks2`, and `specnext_ks3` are ROM-compatible clones that also need this zip — see their own pages.
tsconf: Self-contained: TS-BIOS + CRAM init, no shared parent romset.

## machine_sections
### specpls3: Booting media
![ZX Spectrum +3 running Janosik](images/specpls3-janosik.jpg)

Janosik (Rafal Miazga / Alex Heather, 2013, freeware) loaded from a `.dsk` floppy via the +3 Loader, showing its title screen — its credit line still reads the game's original Atari XL release (R.M., 2013, Mirage).
