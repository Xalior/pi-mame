# V.Smile Motion

- **`make kernel MACHINE=vsmilem`** — VTech
- **Year**: 2008
- **Manufacturer**: VTech

## At power-on

Built into the platform kernel, awaiting hardware verification — no boot capture yet, so no boot behaviour is claimed here.

## Required assets

- `roms/vsmilem.zip`

  | ROM | CRC32 |
  |---|---|
  | `vsmilemotion.bin` | `60fa5426` |
  | `vmotionbios.bin` | `427087ea` |

## Notes

- MAME driver: `vsmile.cpp`.
- MAME clone of `vsmile` (V.Smile) — the system macro's parent field in the driver source. The ROM table above lists every member this machine's own zip needs.

[← back to VTech](README.md)
