# BBC Micro Model B (German)

- **`make kernel MACHINE=bbcb_de`** — Acorn
- **Year**: 1982
- **Manufacturer**: Acorn Computers

## At power-on

Built into the platform kernel, awaiting hardware verification — no boot capture yet, so no boot behaviour is claimed here.

## Required assets

- `roms/bbcb_de.zip`

  | ROM | CRC32 |
  |---|---|
  | `os_de.rom` | `b7262caf` |
  | `basic2.rom` | `79434781` |
  | `dfs10.rom` | `7e367e8c` |
  | `cm62024.bin` | `98e1bf9e` |
- `roms/saa5050.zip`

## Notes

- MAME driver: `bbcb.cpp`.
- MAME clone of `bbcb` (BBC Micro Model B) — the system macro's parent field in the driver source. The ROM table above lists every member this machine's own zip needs.

[← back to Acorn](README.md)
