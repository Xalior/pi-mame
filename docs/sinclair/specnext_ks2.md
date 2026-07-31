# ZX Spectrum Next: KS2

![ZX Spectrum Next: KS2 at power-on](images/specnext_ks2.jpg)

- **`make kernel MACHINE=specnext_ks2`** — Sinclair
- **Year**: 2023
- **Manufacturer**: SpecNext Ltd., Victor Trucco, Fabio Belavenuto
- **Television**: PAL

## At power-on

ZX Spectrum Next / NextZXOS on the KS2 board, booting from its attached SD card image.

## Required assets

- `roms/specnext_ks2.zip`

  | ROM | CRC32 |
  |---|---|
  | `boot-30100.bin` | `ccbd55ba` |
  | `boot-30200-ab.bin` | `1d16e9d4` |
  | `boot-30204.bin` | `95118eb6` |
  | `boot-30204-ab.bin` | `96c32007` |
- `roms/tbblue.zip` — the shared ZX Spectrum Next: Emulators ID
- `media/hard/tbblue/next.img`

## Notes

- MAME driver: `specnext.cpp`.
- MAME clone of `tbblue` (ZX Spectrum Next: Emulators ID) — the system macro's parent field in the driver source. The ROM table above lists every member this machine's own zip needs.

[← back to Sinclair](README.md)
