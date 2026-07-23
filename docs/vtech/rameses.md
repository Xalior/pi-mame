# Rameses HVC6502 (Oceania)

- **`make kernel MACHINE=rameses`** — VTech
- **Year**: 1982
- **Manufacturer**: Hanimex

## At power-on

Built into the platform kernel, awaiting hardware verification — no boot capture yet, so no boot behaviour is claimed here.

## Required assets

- `roms/rameses.zip`

  | ROM | CRC32 |
  |---|---|
  | `funboot.rom` | `05602697` |

## Notes

- MAME driver: `crvision.cpp`.
- MAME clone of `crvision` (CreatiVision) — the system macro's parent field in the driver source. The ROM table above lists every member this machine's own zip needs.

[← back to VTech](README.md)
