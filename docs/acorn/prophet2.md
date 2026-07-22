# Prophet 2

- **`make kernel MACHINE=prophet2`** — Acorn
- **Year**: 1983
- **Manufacturer**: Busicomputers

## At power-on

Built into the platform kernel, awaiting hardware verification — no boot capture yet, so no boot behaviour is claimed here.

## Required assets

- `roms/prophet2.zip`

  | ROM | CRC32 |
  |---|---|
  | `abasic.ic20` | `289b7791` |
  | `p2fp.ic21` | `8be45181` |
  | `a_69ed.rom` | `006010b7` |
  | `e_61e5.rom` | `ecd2d08b` |

## Notes

- MAME driver: `atom.cpp`.
- MAME clone of `atom` (Atom) — the system macro's parent field in the driver source. The ROM table above lists every member this machine's own zip needs.

[← back to Acorn](README.md)
