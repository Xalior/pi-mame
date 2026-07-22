# Acorn Electron (64K Master RAM Board)

- **`make kernel MACHINE=electron64`** — Acorn
- **Year**: 1987
- **Manufacturer**: Acorn Computers / Slogger

## At power-on

Built into the platform kernel, awaiting hardware verification — no boot capture yet, so no boot behaviour is claimed here.

## Required assets

- `roms/electron64.zip`

  | ROM | CRC32 |
  |---|---|
  | `basic.rom` | `79434781` |
  | `os_300.rom` | `f80a0cea` |
- `roms/electron_plus3.zip`
- `roms/electron_plus1.zip`

## Notes

- MAME driver: `electron.cpp`.
- MAME clone of `electron` (Acorn Electron) — the system macro's parent field in the driver source. The ROM table above lists every member this machine's own zip needs.

[← back to Acorn](README.md)
