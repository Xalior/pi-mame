# Color Computer 3 (NTSC; HD6309)

![Color Computer 3 (NTSC; HD6309) at power-on](images/coco3h.jpg)

- **`make kernel MACHINE=coco3h`** — TRS / Tandy
- **Year**: 19??
- **Manufacturer**: Tandy Radio Shack

## At power-on

`Color Computer 3 (NTSC; HD6309)` at power-on on the real board — see the capture above.

## Required assets

- `roms/coco3h.zip`

  | ROM | CRC32 |
  |---|---|
  | `coco3.rom` | `b4c88d6c` |
- `roms/coco_fdc.zip`

## Notes

- MAME driver: `coco3.cpp`.
- MAME clone of `coco` (Color Computer 1/2) — the system macro's parent field in the driver source. The ROM table above lists every member this machine's own zip needs.

[← back to TRS / Tandy](README.md)
