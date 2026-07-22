# LTM Portable (Master)

- **`make kernel MACHINE=ltmpm`** — Acorn
- **Year**: 1986
- **Manufacturer**: Lawrie T&M Ltd.

## At power-on

Built into the platform kernel, awaiting hardware verification — no boot capture yet, so no boot behaviour is claimed here.

## Required assets

- `roms/ltmpm.zip`

  | ROM | CRC32 |
  |---|---|
  | `mos320.ic24` | `0f747ebe` |
  | `mos329.ic24` | `8dd7338b` |
  | `caspl_mos343_89.bin` | `fa2b881f` |
  | `caspl_mos343_ab.bin` | `704d86e9` |
  | `caspl_mos343_cd.bin` | `953b7530` |
  | `caspl_mos343_ef.bin` | `ebc09359` |
  | `mos350.ic24` | `141027b9` |
  | `anfs425-2201351.rom` | `c2a6655e` |
  | `mos320.cmos` | `c7f9e85a` |
  | `mos350.cmos` | `e84c1854` |

## Notes

- MAME driver: `bbcm.cpp`.
- MAME clone of `bbcm` (BBC Master 128) — the system macro's parent field in the driver source. The ROM table above lists every member this machine's own zip needs.

[← back to Acorn](README.md)
