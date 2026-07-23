# m.5 (Europe) BRNO mod

- **`make kernel MACHINE=m5p_brno`** — Sord
- **Year**: 1983
- **Manufacturer**: Sord

## At power-on

**PARKED** — same driver family; additionally its brno_rom12.rom is unsourceable (MAME PR #14491 outpaced public mirrors). The capture above shows the observed stop; the machine is not offered until the park is lifted by a policy ruling.

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
