# BBC Micro Model B+ 128K

- **`make kernel MACHINE=bbcbp128`** — Acorn
- **Year**: 1985
- **Manufacturer**: Acorn Computers

## At power-on

Built into the platform kernel, awaiting hardware verification — no boot capture yet, so no boot behaviour is claimed here.

## Required assets

- `roms/bbcbp128.zip`

  | ROM | CRC32 |
  |---|---|
  | `bpos2.ic71` | `9f356396` |
  | `ddfs223.rom` | `7891f9b7` |
  | `cm62024.bin` | `98e1bf9e` |
- `roms/saa5050.zip`

## Notes

- MAME driver: `bbcbp.cpp`.
- MAME clone of `bbcbp` (BBC Micro Model B+ 64K) — the system macro's parent field in the driver source. The ROM table above lists every member this machine's own zip needs.

[← back to Acorn](README.md)
