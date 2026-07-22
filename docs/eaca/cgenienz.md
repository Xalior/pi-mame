# Colour Genie EG2000 (New Zealand)

- **`make kernel MACHINE=cgenienz`** — EACA
- **Year**: 1982
- **Manufacturer**: EACA

## At power-on

Built into the platform kernel, awaiting hardware verification — no boot capture yet, so no boot behaviour is claimed here.

## Required assets

- `roms/cgenienz.zip`

  | ROM | CRC32 |
  |---|---|
  | `cg-basic-rom-v1-pal-en.rom` | `844aaedd` |
  | `cgromv2.rom` | `cfb84e09` |
  | `cgenie1.fnt` | `4fed774a` |

## Notes

- MAME driver: `cgenie.cpp`.
- MAME clone of `cgenie` (Colour Genie EG2000) — the system macro's parent field in the driver source. The ROM table above lists every member this machine's own zip needs.

[← back to EACA](README.md)
