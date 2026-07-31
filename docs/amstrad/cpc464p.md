# Amstrad CPC464+

![Amstrad CPC464+ at power-on](images/cpc464p.jpg)

- **`make kernel MACHINE=cpc464p`** — Amstrad
- **Year**: 1990
- **Manufacturer**: Amstrad plc
- **Television**: PAL

## At power-on

The Plus-range CPC, whose hardware boots from a cartridge: the image bakes `-cart /carts/sysukpd.bin` (the game-free Locomotive BASIC + ParaDOS cart), which signs on yellow-on-blue as `Amstrad Microcomputer (v4)` / `©1985 Amstrad plc and Locomotive Software Ltd.` / `PARADOS V1.1. ©1997 QUANTUM Solutions.` over `BASIC 1.1` / `Ready`, on the PAL canvas.

## Required assets

No romset zip: the `cpc464p` romset is empty.

- `carts/sysukpd.bin`

## Notes

- MAME driver: `amstrad.cpp`.
- Other carts load through MAME's UI at runtime (Scroll Lock → Tab → file manager).

[← back to Amstrad](README.md)
