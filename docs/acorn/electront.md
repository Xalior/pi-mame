# Acorn Electron (Trial)

- **`make kernel MACHINE=electront`** — Acorn
- **Year**: 1983
- **Manufacturer**: Acorn Computers

## At power-on

Built into the platform kernel, awaiting hardware verification — no boot capture yet, so no boot behaviour is claimed here.

## Required assets

- `roms/electront.zip`

  | ROM | CRC32 |
  |---|---|
  | `basic.rom` | `79434781` |
  | `elk_036.rom` | `dd1a99c3` |
- `roms/electron_plus3.zip`
- `roms/electron_plus1.zip`

## Notes

- MAME driver: `electron.cpp`.
- MAME clone of `electron` (Acorn Electron) — the system macro's parent field in the driver source. The ROM table above lists every member this machine's own zip needs.

[← back to Acorn](README.md)
