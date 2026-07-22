# BBC Micro Model B (Norway)

- **`make kernel MACHINE=bbcb_no`** — Acorn
- **Year**: 1984
- **Manufacturer**: Acorn Computers

## At power-on

Built into the platform kernel, awaiting hardware verification — no boot capture yet, so no boot behaviour is claimed here.

## Required assets

- `roms/bbcb_no.zip`

  | ROM | CRC32 |
  |---|---|
  | `nos12.rom` | `49859294` |
  | `dfs0.9h.rom` | `af2fa873` |
  | `viewa210.rom` | `4345359f` |
  | `basic2.rom` | `79434781` |
  | `vm61002.bin` | `bf4b3b64` |

## Notes

- MAME driver: `bbcb.cpp`.
- MAME clone of `bbcb` (BBC Micro Model B) — the system macro's parent field in the driver source. The ROM table above lists every member this machine's own zip needs.

[← back to Acorn](README.md)
