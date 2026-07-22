# Atari 400 (PAL)

- **`make kernel MACHINE=a400pal`** — Atari
- **Year**: 1979
- **Manufacturer**: Atari

## At power-on

Built into the platform kernel, awaiting hardware verification — no boot capture yet, so no boot behaviour is claimed here.

## Required assets

- `roms/a400pal.zip`

  | ROM | CRC32 |
  |---|---|
  | `co12399b.rom` | `6a5d766e` |
  | `co15199.rom` | `8e547f56` |
  | `co15299.rom` | `be55b413` |

## Notes

- MAME driver: `atari400.cpp`.
- MAME clone of `a400` (Atari 400 (NTSC)) — the system macro's parent field in the driver source. The ROM table above lists every member this machine's own zip needs.

[← back to Atari](README.md)
