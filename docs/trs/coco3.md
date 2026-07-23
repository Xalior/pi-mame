# Color Computer 3 (NTSC)

![Color Computer 3 (NTSC) at power-on](images/coco3.jpg)

- **`make kernel MACHINE=coco3`** — TRS / Tandy
- **Year**: 1986
- **Manufacturer**: Tandy Radio Shack

## At power-on

`Color Computer 3 (NTSC)` at power-on on the real board — see the capture above.

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
