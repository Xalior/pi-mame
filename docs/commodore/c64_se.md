# Commodore 64 / VIC-64S (Sweden/Finland)

![Commodore 64 / VIC-64S (Sweden/Finland) at power-on](images/c64_se.jpg)

- **`make kernel MACHINE=c64_se`** — Commodore
- **Year**: 1982
- **Manufacturer**: Commodore Business Machines
- **Television**: PAL

## At power-on

Commodore 64 BASIC V2, `READY.` — the IEC disk bus boots empty (`-iec8 ""`), so no drive romset is required to reach BASIC. The Swedish/Finnish machine (VIC-64S) carries its own kernal and a Swedish character generator (the default of two Swedish chargen options in the driver); the sign-on banner is the same shape as the standard c64.

## Required assets

- `roms/c64_se.zip`

  | ROM | CRC32 |
  |---|---|
  | `901226-01.u3` | `f833d117` |
  | `kernel.u4` | `f10c2c25` |
  | `charswe.u5` | `bee9b3fd` |
  | `charswe2.u5` | `377a382b` |
  | `906114-01.u17` | `54c89351` |

## Notes

- MAME driver: `c64.cpp`.
- MAME clone of `c64` (Commodore 64 (NTSC)) — the system macro's parent field in the driver source. The ROM table above lists every member this machine's own zip needs.

[← back to Commodore](README.md)
