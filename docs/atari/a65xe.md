# Atari 65XE

- **`make kernel MACHINE=a65xe`** — Atari
- **Year**: 1986
- **Manufacturer**: Atari

## At power-on

Built into the platform kernel, awaiting hardware verification — no boot capture yet, so no boot behaviour is claimed here.

## Required assets

- `roms/a65xe.zip`

  | ROM | CRC32 |
  |---|---|
  | `co24947a.rom` | `7d684184` |
  | `co61598b.rom` | `1f9cd270` |

## Notes

- MAME driver: `atari400.cpp`.
- MAME clone of `a800xl` (Atari 800XL (NTSC)) — the system macro's parent field in the driver source. The ROM table above lists every member this machine's own zip needs.

[← back to Atari](README.md)
