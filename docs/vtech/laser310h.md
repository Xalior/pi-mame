# Laser 310 (SHRG)

- **`make kernel MACHINE=laser310h`** — VTech
- **Year**: 1984
- **Manufacturer**: Video Technology

## At power-on

Built into the platform kernel, awaiting hardware verification — no boot capture yet, so no boot behaviour is claimed here.

## Required assets

- `roms/laser310h.zip`

  | ROM | CRC32 |
  |---|---|
  | `vtechv20.u12` | `613de12c` |
  | `vtechv21.u12` | `f7df980f` |

## Notes

- MAME driver: `vtech1.cpp`.
- MAME clone of `laser310` (Laser 310) — the system macro's parent field in the driver source. The ROM table above lists every member this machine's own zip needs.

[← back to VTech](README.md)
