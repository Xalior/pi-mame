# Meritum I (Model 2)

- **`make kernel MACHINE=meritum2`** — TRS / Tandy
- **Year**: 1985
- **Manufacturer**: Mera-Elzab

## At power-on

Built into the platform kernel, awaiting hardware verification — no boot capture yet, so no boot behaviour is claimed here.

## Required assets

- `roms/meritum2.zip`

  | ROM | CRC32 |
  |---|---|
  | `01.ic7` | `ed705a47` |
  | `02.ic8` | `ac297d99` |
  | `03.ic9` | `a21d0d62` |
  | `04.ic10` | `3610bdda` |
  | `05.ic11` | `461fbf0d` |
  | `06.ic12` | `ed547445` |
  | `07.ic13` | `044b1459` |
  | `chargen.ic72` | `3dfc6439` |

## Notes

- MAME driver: `meritum.cpp`.
- MAME clone of `meritum1` (Meritum I (Model 1)) — the system macro's parent field in the driver source. The ROM table above lists every member this machine's own zip needs.

[← back to TRS / Tandy](README.md)
