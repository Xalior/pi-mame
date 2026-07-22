# BBC Micro Model B (US)

- **`make kernel MACHINE=bbcb_us`** — Acorn
- **Year**: 1983
- **Manufacturer**: Acorn Computers

## At power-on

Built into the platform kernel, awaiting hardware verification — no boot capture yet, so no boot behaviour is claimed here.

## Required assets

- `roms/bbcb_us.zip`

  | ROM | CRC32 |
  |---|---|
  | `usmos10.rom` | `c8e946a9` |
  | `usbasic3.rom` | `161b9539` |
  | `viewa210.rom` | `4345359f` |
  | `usdnfs10.rom` | `7e367e8c` |
  | `vm61002.bin` | `bf4b3b64` |
- `roms/saa5050.zip`

## Notes

- MAME driver: `bbcb.cpp`.
- MAME clone of `bbcb` (BBC Micro Model B) — the system macro's parent field in the driver source. The ROM table above lists every member this machine's own zip needs.

[← back to Acorn](README.md)
