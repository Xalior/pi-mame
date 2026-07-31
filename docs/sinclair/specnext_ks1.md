# ZX Spectrum Next: KS1

![ZX Spectrum Next: KS1 at power-on](images/specnext_ks1.jpg)

- **`make kernel MACHINE=specnext_ks1`** — Sinclair
- **Year**: 2020
- **Manufacturer**: SpecNext Ltd., Victor Trucco, Fabio Belavenuto
- **Television**: PAL

## At power-on

ZX Spectrum Next / NextZXOS on the KS1 board, booting from its attached SD card image.

## Required assets

- `roms/specnext_ks1.zip`

  | ROM | CRC32 |
  |---|---|
  | `boot-30100.bin` | `ccbd55ba` |
  | `boot-30200-ab.bin` | `1d16e9d4` |
  | `boot-30204.bin` | `95118eb6` |
  | `boot-30204-ab.bin` | `96c32007` |
- `roms/tbblue.zip` — the shared ZX Spectrum Next: Emulators ID
- `next/next.img`

## Notes

- MAME driver: `specnext.cpp`.
- MAME clone of `tbblue` (ZX Spectrum Next: Emulators ID) — the system macro's parent field in the driver source. The ROM table above lists every member this machine's own zip needs.

[← back to Sinclair](README.md)
