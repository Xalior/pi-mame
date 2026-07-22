# Dolphin Microcomputer

- **`make kernel MACHINE=dolphinm`** — Acorn
- **Year**: 1989
- **Manufacturer**: Hope Computers

## At power-on

Built into the platform kernel, awaiting hardware verification — no boot capture yet, so no boot behaviour is claimed here.

## Required assets

- `roms/dolphinm.zip`

  | ROM | CRC32 |
  |---|---|
  | `hope_os_basic.rom` | `8b30f9e5` |
  | `hope_dfs.rom` | `5d404973` |

## Notes

- MAME driver: `bbcb.cpp`.
- MAME clone of `bbcb` (BBC Micro Model B) — the system macro's parent field in the driver source. The ROM table above lists every member this machine's own zip needs.

[← back to Acorn](README.md)
