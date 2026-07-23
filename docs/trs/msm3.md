# Micro-Sep Model 3

- **`make kernel MACHINE=msm3`** — TRS / Tandy
- **Year**: 1987
- **Manufacturer**: ILCE / SEP

## At power-on

Built into the platform kernel, awaiting hardware verification — no boot capture yet, so no boot behaviour is claimed here.

## Required assets

- `roms/msm3.zip`

  | ROM | CRC32 |
  |---|---|
  | `msm3.rom` | `26d67890` |
- `roms/coco_fdc.zip`

## Notes

- MAME driver: `coco3.cpp`.
- MAME clone of `coco` (Color Computer 1/2) — the system macro's parent field in the driver source. The ROM table above lists every member this machine's own zip needs.

[← back to TRS / Tandy](README.md)
