# m.5 (Europe)

- **`make kernel MACHINE=m5p`** — Sord
- **Year**: 1983
- **Manufacturer**: Sord

## At power-on

Built into the platform kernel, awaiting hardware verification — no boot capture yet, so no boot behaviour is claimed here.

## Required assets

- `roms/m5p.zip`

  | ROM | CRC32 |
  |---|---|
  | `sordint.ic21` | `78848d39` |
  | `sordfd5.rom` | `7263bbc5` |
- `roms/m5.zip` — the shared m.5 (Japan)

## Notes

- MAME driver: `m5.cpp`.
- MAME clone of `m5` (m.5 (Japan)) — the system macro's parent field in the driver source. The ROM table above lists every member this machine's own zip needs.

[← back to Sord](README.md)
