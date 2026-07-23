# m.5 (Europe) BRNO mod

- **`make kernel MACHINE=m5p_brno`** — Sord
- **Year**: 1983
- **Manufacturer**: Sord

## At power-on

Built into the platform kernel, awaiting hardware verification — no boot capture yet, so no boot behaviour is claimed here.

## Required assets

- `roms/m5p_brno.zip`

  | ROM | CRC32 |
  |---|---|
  | `sordint.ic21` | `78848d39` |
  | `brno_rom12.rom` | `cac52406` |

## Notes

- MAME driver: `m5.cpp`.
- MAME clone of `m5` (m.5 (Japan)) — the system macro's parent field in the driver source. The ROM table above lists every member this machine's own zip needs.

[← back to Sord](README.md)
