# Commodore 64C (Spain)

![Commodore 64C (Spain) at power-on](images/c64c_es.jpg)

- **`make MACHINE=c64c_es`** — Commodore Business Machines
- **Year**: 1988
- **Manufacturer**: Commodore Business Machines
- **Television**: PAL

## At power-on

Commodore 64 BASIC V2, `READY.` — the IEC disk bus boots empty (`-iec8
""`), so no drive romset is required to reach BASIC. The Spanish 64C is a
distinct romset carrying its own character generator (`325056-03.u5`,
aka `325245-01`); the sign-on banner and free-memory figure match the
64C, and the Spanish glyphs live in the chargen, which the sign-on text
does not exercise. Like every 64C it merges BASIC and the KERNAL into a
single 16 KB part (`251913-01.u4`).

## Required assets

- `roms/c64c_es.zip`

  | ROM | CRC32 |
  |---|---|
  | `251913-01.u4` (basic+kernal) | `0010ec31` |
  | `325056-03.u5` (chargen ES) | `c890c175` |
  | `252715-01.u8` (PLA) | `54c89351` |

  A distinct romset — not a `#define` alias of `rom_c64c`. The Spanish
  chargen (`325056-03.u5`) is unique to this machine; the combined
  basic+kernal (`251913-01.u4`) is byte-identical to the `c64c`, and the
  PLA content is the standard C64 PLA (identical to `c64`'s
  `906114-01.u17`), which the driver expects here under the `252715-01.u8`
  filename.

[← back to Commodore](README.md)
