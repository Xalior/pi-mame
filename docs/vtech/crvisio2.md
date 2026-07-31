# CreatiVision MK-II (Europe)

- **`make kernel MACHINE=crvisio2`** — VTech
- **Year**: 1983
- **Manufacturer**: Video Technology
- **Television**: PAL

## At power-on

Built into the platform kernel, awaiting hardware verification — no boot capture yet, so no boot behaviour is claimed here.

## Required assets

- `roms/crvisio2.zip`

  | ROM | CRC32 |
  |---|---|
  | `crvision.u20` | `c3c590c6` |
- `roms/crvision.zip` — the shared CreatiVision

## Notes

- MAME driver: `crvision.cpp`.
- MAME clone of `crvision` (CreatiVision) — the system macro's parent field in the driver source. The ROM table above lists every member this machine's own zip needs.

[← back to VTech](README.md)
