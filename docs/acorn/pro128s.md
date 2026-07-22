# Prodest PC 128S

- **`make kernel MACHINE=pro128s`** — Acorn
- **Year**: 1987
- **Manufacturer**: Olivetti

## At power-on

Built into the platform kernel, awaiting hardware verification — no boot capture yet, so no boot behaviour is claimed here.

## Required assets

- `roms/pro128s.zip`

  | ROM | CRC32 |
  |---|---|
  | `mos510o.ic49` | `c16858d3` |
- `roms/saa5050.zip`

## Notes

- MAME driver: `bbcmc.cpp`.
- MAME clone of `bbcmc` (BBC Master Compact) — the system macro's parent field in the driver source. The ROM table above lists every member this machine's own zip needs.

[← back to Acorn](README.md)
