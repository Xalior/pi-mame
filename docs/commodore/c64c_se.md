# Commodore 64C (Sweden/Finland)

![Commodore 64C (Sweden/Finland) at power-on](images/c64c_se.jpg)

- **`make kernel MACHINE=c64c_se`** — Commodore
- **Year**: 1986
- **Manufacturer**: Commodore Business Machines
- **Television**: PAL

## At power-on

Commodore 64 BASIC V2, `READY.` — the IEC disk bus boots empty (`-iec8 ""`), so no drive romset is required to reach BASIC. The Swedish/Finnish 64C is a distinct romset carrying its own KERNAL (`325182-01.u4`, the "128/64 FI" part) and its own Scandinavian character generator (`cbm 64 skand.gen.u5`). Both are unique to this machine — unlike the Spanish `c64c_es`, it does not share the combined BASIC+KERNAL part with the `c64c`. The sign-on banner and free-memory figure match the 64C; the Scandinavian glyphs live in the chargen, which the sign-on text does not exercise.

## Required assets

- `roms/c64c_se.zip`

  | ROM | CRC32 |
  |---|---|
  | `325182-01.u4` | `2aff27d3` |
  | `cbm 64 skand.gen.u5` | `377a382b` |
  | `252715-01.u8` | `54c89351` |

## Notes

- MAME driver: `c64.cpp`.
- MAME clone of `c64` (Commodore 64 (NTSC)) — the system macro's parent field in the driver source. The ROM table above lists every member this machine's own zip needs.

[← back to Commodore](README.md)
