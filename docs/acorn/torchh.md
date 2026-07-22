# Torch CH240

- **`make kernel MACHINE=torchh`** — Acorn
- **Year**: 1983
- **Manufacturer**: Torch Computers

## At power-on

Built into the platform kernel, awaiting hardware verification — no boot capture yet, so no boot behaviour is claimed here.

## Required assets

- `roms/torchh.zip`

  | ROM | CRC32 |
  |---|---|
  | `os12.rom` | `3c14fc70` |
  | `basic2.rom` | `79434781` |
  | `dnfs120-201666.rom` | `8ccd2157` |
  | `vm61002.bin` | `bf4b3b64` |

## Notes

- MAME driver: `bbcb.cpp`.
- MAME clone of `bbcb` (BBC Micro Model B) — the system macro's parent field in the driver source. The ROM table above lists every member this machine's own zip needs.

[← back to Acorn](README.md)
