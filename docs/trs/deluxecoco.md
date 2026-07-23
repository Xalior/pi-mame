# Deluxe Color Computer

- **`make kernel MACHINE=deluxecoco`** — TRS / Tandy
- **Year**: 1983
- **Manufacturer**: Tandy Radio Shack

## At power-on

Built into the platform kernel, awaiting hardware verification — no boot capture yet, so no boot behaviour is claimed here.

## Required assets

- `roms/deluxecoco.zip`

  | ROM | CRC32 |
  |---|---|
  | `adv070_u24.rom` | `827fe698` |
  | `adv071_u24.rom` | `0a3942e4` |
  | `adv072_u24.rom` | `c0118da5` |
  | `adv073-2_u24.rom` | `61411227` |
- `roms/coco_fdc.zip`

## Notes

- MAME driver: `coco12.cpp`.
- MAME clone of `coco` (Color Computer 1/2) — the system macro's parent field in the driver source. The ROM table above lists every member this machine's own zip needs.

[← back to TRS / Tandy](README.md)
