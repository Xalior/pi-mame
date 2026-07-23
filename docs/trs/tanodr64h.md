# Tano Dragon 64 (NTSC; HD6309E)

![Tano Dragon 64 (NTSC; HD6309E) at power-on](images/tanodr64h.jpg)

- **`make kernel MACHINE=tanodr64h`** — TRS / Tandy
- **Year**: 19??
- **Manufacturer**: Dragon Data Ltd / Tano Ltd

## At power-on

`Tano Dragon 64 (NTSC; HD6309E)` at power-on on the real board — see the capture above.

## Required assets

- `roms/tanodr64h.zip`

  | ROM | CRC32 |
  |---|---|
  | `tano_1.ic18` | `84f68bf9` |
  | `tano_2.ic17` | `17893a42` |
- `roms/sdtandy_fdc.zip`

## Notes

- MAME driver: `dragon.cpp`.
- MAME clone of `dragon32` (Dragon 32) — the system macro's parent field in the driver source. The ROM table above lists every member this machine's own zip needs.

[← back to TRS / Tandy](README.md)
