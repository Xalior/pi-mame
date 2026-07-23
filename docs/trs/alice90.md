# Alice 90

- **`make kernel MACHINE=alice90`** — TRS / Tandy
- **Year**: 1985
- **Manufacturer**: Matra & Hachette

## At power-on

Built into the platform kernel, awaiting hardware verification — no boot capture yet, so no boot behaviour is claimed here.

## Required assets

- `roms/alice90.zip`

  | ROM | CRC32 |
  |---|---|
  | `alice32.rom` | `c3854ddf` |
  | `charset.rom` | `b2f49eb3` |

## Notes

- MAME driver: `mc10.cpp`.
- MAME clone of `alice32` (Alice 32) — the system macro's parent field in the driver source. The ROM table above lists every member this machine's own zip needs.

[← back to TRS / Tandy](README.md)
