# Laser 700

- **`make kernel MACHINE=laser700`** — VTech
- **Year**: 1985
- **Manufacturer**: Video Technology

## At power-on

Built into the platform kernel, awaiting hardware verification — no boot capture yet, so no boot behaviour is claimed here.

## Required assets

- `roms/laser700.zip`

  | ROM | CRC32 |
  |---|---|
  | `27-0401-00-00.u6` | `9bed01f7` |
  | `27-393-00.u10` | `d47313a2` |

## Notes

- MAME driver: `vtech2.cpp`.
- MAME clone of `laser350` (Laser 350) — the system macro's parent field in the driver source. The ROM table above lists every member this machine's own zip needs.

[← back to VTech](README.md)
