# Color Computer 3 (NTSC)

- **`make kernel MACHINE=coco3`** — TRS / Tandy
- **Year**: 1986
- **Manufacturer**: Tandy Radio Shack

## At power-on

Built into the platform kernel, awaiting hardware verification — no boot capture yet, so no boot behaviour is claimed here.

## Required assets

- `roms/coco3.zip`

  | ROM | CRC32 |
  |---|---|
  | `coco3.rom` | `b4c88d6c` |
- `roms/coco_fdc.zip`

## Notes

- MAME driver: `coco3.cpp`.
- MAME clone of `coco` (Color Computer 1/2) — the system macro's parent field in the driver source. The ROM table above lists every member this machine's own zip needs.

[← back to TRS / Tandy](README.md)
