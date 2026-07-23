# Mephisto PHC 64 (Germany)

- **`make kernel MACHINE=phc64`** — Enterprise
- **Year**: 1985
- **Manufacturer**: Intelligent Software / Hegener + Glaser

## At power-on

Built into the platform kernel, awaiting hardware verification — no boot capture yet, so no boot behaviour is claimed here.

## Required assets

- `roms/phc64.zip`

  | ROM | CRC32 |
  |---|---|
  | `9256ds-0038_enter05-23-a.u2` | `d421795f` |

## Notes

- MAME driver: `ep64.cpp`.
- MAME clone of `ep64` (Enterprise Sixty Four) — the system macro's parent field in the driver source. The ROM table above lists every member this machine's own zip needs.

[← back to Enterprise](README.md)
