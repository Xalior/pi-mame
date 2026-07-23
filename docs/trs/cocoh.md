# Color Computer 1/2 (HD6309)

![Color Computer 1/2 (HD6309) at power-on](images/cocoh.jpg)

- **`make kernel MACHINE=cocoh`** — TRS / Tandy
- **Year**: 19??
- **Manufacturer**: Tandy Radio Shack

## At power-on

`Color Computer 1/2 (HD6309)` at power-on on the real board — see the capture above.

## Required assets

- `roms/cocoh.zip`

  | ROM | CRC32 |
  |---|---|
  | `bas10.rom` | `00b50aaa` |
  | `bas11.rom` | `6270955a` |
  | `bas12.rom` | `54368805` |
  | `extbas10.rom` | `6111a086` |
  | `extbas11.rom` | `a82a6254` |
- `roms/coco_fdc.zip`

## Notes

- MAME driver: `coco12.cpp`.
- MAME clone of `coco` (Color Computer 1/2) — the system macro's parent field in the driver source. The ROM table above lists every member this machine's own zip needs.

[← back to TRS / Tandy](README.md)
