# Acorn Electron (Stop Press 64i)

- **`make kernel MACHINE=electronsp`** — Acorn
- **Year**: 1991
- **Manufacturer**: Acorn Computers / Slogger

## At power-on

Built into the platform kernel, awaiting hardware verification — no boot capture yet, so no boot behaviour is claimed here.

## Required assets

- `roms/electronsp.zip`

  | ROM | CRC32 |
  |---|---|
  | `basic.rom` | `79434781` |
  | `os_310.rom` | `8b7a9003` |
  | `sp64_101_1.rom` | `07e2c5d6` |
  | `sp64_101_2.rom` | `3d0e5dc1` |
  | `sp64_100.rom` | `4918221c` |
  | `sp64_100_1.rom` | `6053e5a0` |
  | `sp64_100_2.rom` | `25d11d8e` |
- `roms/electron_plus3.zip`
- `roms/electron_plus1.zip`

## Notes

- MAME driver: `electron.cpp`.
- MAME clone of `electron` (Acorn Electron) — the system macro's parent field in the driver source. The ROM table above lists every member this machine's own zip needs.

[← back to Acorn](README.md)
