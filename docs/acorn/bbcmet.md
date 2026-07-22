# BBC Master ET

- **`make kernel MACHINE=bbcmet`** — Acorn
- **Year**: 1986
- **Manufacturer**: Acorn Computers

## At power-on

Built into the platform kernel, awaiting hardware verification — no boot capture yet, so no boot behaviour is claimed here.

## Required assets

- `roms/bbcmet.zip`

  | ROM | CRC32 |
  |---|---|
  | `mos400.ic24` | `81729034` |
  | `mos400.cmos` | `fff41cc5` |
- `roms/saa5050.zip`

## Notes

- MAME driver: `bbcm.cpp`.
- MAME clone of `bbcm` (BBC Master 128) — the system macro's parent field in the driver source. The ROM table above lists every member this machine's own zip needs.

[← back to Acorn](README.md)
