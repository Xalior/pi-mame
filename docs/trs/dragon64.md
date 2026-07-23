# Dragon 64

![Dragon 64 at power-on](images/dragon64.jpg)

- **`make kernel MACHINE=dragon64`** — TRS / Tandy
- **Year**: 1983
- **Manufacturer**: Dragon Data Ltd

## At power-on

`Dragon 64` at power-on on the real board — see the capture above.

## Required assets

- `roms/dragon64.zip`

  | ROM | CRC32 |
  |---|---|
  | `d64_1.rom` | `60a4634c` |
  | `d64_2.rom` | `17893a42` |
- `roms/dragon_fdc.zip`

## Notes

- MAME driver: `dragon.cpp`.
- MAME clone of `dragon32` (Dragon 32) — the system macro's parent field in the driver source. The ROM table above lists every member this machine's own zip needs.

[← back to TRS / Tandy](README.md)
