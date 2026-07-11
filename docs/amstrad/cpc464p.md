# Amstrad CPC464+

- **`make MACHINE=cpc464p`** — Amstrad
- **Year**: 1990
- **Manufacturer**: Amstrad plc
- **Television**: PAL

## At power-on

The Plus-range CPC, whose hardware boots from a cartridge: the image bakes `-cart /carts/sysukpd.bin` (the game-free Locomotive BASIC + ParaDOS cart), which signs on yellow-on-blue as `Amstrad Microcomputer (v4)` / `©1985 Amstrad plc and Locomotive Software Ltd.` / `PARADOS V1.1. ©1997 QUANTUM Solutions.` over `BASIC 1.1` / `Ready`, on the PAL canvas.

## Required assets

No romset zip: the `cpc464p` romset is empty — the Plus firmware lives on the cartridge.

- `carts/sysukpd.bin` — the baked default cartridge, Locomotive BASIC + ParaDOS (MAME softlist entry `sysukpd`: `engpados.bin`, renamed)

  | File | CRC32 |
  |---|---|
  | `sysukpd.bin` | `e9c5e30e` |

## Notes

- Other carts load through MAME's UI at runtime (Scroll Lock → Tab → file manager).

[← back to Amstrad](README.md)
