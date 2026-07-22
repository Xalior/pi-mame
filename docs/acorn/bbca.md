# BBC Micro Model A

- **`make kernel MACHINE=bbca`** — Acorn
- **Year**: 1981
- **Manufacturer**: Acorn Computers

## At power-on

Built into the platform kernel, awaiting hardware verification — no boot capture yet, so no boot behaviour is claimed here.

## Required assets

- `roms/bbca.zip`

  | ROM | CRC32 |
  |---|---|
  | `os12.rom` | `3c14fc70` |
  | `os10.rom` | `9679b8f8` |
  | `os092.rom` | `59ef7eb8` |
  | `os01.rom` | `45ee0980` |
  | `basic2.rom` | `79434781` |
  | `basic1.rom` | `b3364108` |

## Notes

- MAME driver: `bbcb.cpp`.
- MAME clone of `bbcb` (BBC Micro Model B) — the system macro's parent field in the driver source. The ROM table above lists every member this machine's own zip needs.

[← back to Acorn](README.md)
