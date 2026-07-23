# Dragon 64 (HD6309E)

![Dragon 64 (HD6309E) at power-on](images/dragon64h.jpg)

- **`make kernel MACHINE=dragon64h`** — TRS / Tandy
- **Year**: 19??
- **Manufacturer**: Dragon Data Ltd

## At power-on

`Dragon 64 (HD6309E)` at power-on on the real board — see the capture above.

## Required assets

- `roms/dragon64h.zip`

  | ROM | CRC32 |
  |---|---|
  | `d64_1.rom` | `60a4634c` |
  | `d64_2.rom` | `17893a42` |
- `roms/dragon_fdc.zip`

## Notes

- MAME driver: `dragon.cpp`.
- MAME clone of `dragon32` (Dragon 32) — the system macro's parent field in the driver source. The ROM table above lists every member this machine's own zip needs.

[← back to TRS / Tandy](README.md)
