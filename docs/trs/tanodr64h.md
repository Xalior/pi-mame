# Tano Dragon 64 (NTSC; HD6309E)

- **`make kernel MACHINE=tanodr64h`** — TRS / Tandy
- **Year**: 19??
- **Manufacturer**: Dragon Data Ltd / Tano Ltd

## At power-on

Built into the platform kernel, awaiting hardware verification — no boot capture yet, so no boot behaviour is claimed here.

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
