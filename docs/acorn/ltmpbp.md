# LTM Portable (B+)

- **`make kernel MACHINE=ltmpbp`** — Acorn
- **Year**: 1985
- **Manufacturer**: Lawrie T&M Ltd.

## At power-on

Built into the platform kernel, awaiting hardware verification — no boot capture yet, so no boot behaviour is claimed here.

## Required assets

- `roms/ltmpbp.zip`

  | ROM | CRC32 |
  |---|---|
  | `bpos2.ic71` | `9f356396` |
  | `adfs130.rom` | `d3855588` |
  | `ddfs223.rom` | `7891f9b7` |
  | `cm62024.bin` | `98e1bf9e` |

## Notes

- MAME driver: `bbcbp.cpp`.
- MAME clone of `bbcbp` (BBC Micro Model B+ 64K) — the system macro's parent field in the driver source. The ROM table above lists every member this machine's own zip needs.

[← back to Acorn](README.md)
