# Commodore 64 (Sweden)

![Commodore 64 (Sweden) at power-on](images/c64_se.jpg)

- **`make MACHINE=c64_se`** — Commodore Business Machines
- **Year**: 1982
- **Manufacturer**: Commodore Business Machines
- **Television**: PAL

## At power-on

Commodore 64 BASIC V2, `READY.` — the IEC disk bus boots empty (`-iec8
""`), so no drive romset is required to reach BASIC. The Swedish/Finnish
machine (VIC-64S) carries its own kernal and a Swedish character generator
(the default of two Swedish chargen options in the driver); the sign-on
banner is the same shape as the standard c64.

## Required assets

- `roms/c64_se.zip`

  | ROM | CRC32 |
  |---|---|
  | `901226-01.u3` (basic) | `f833d117` |
  | `kernel.u4` (kernal) | `f10c2c25` |
  | `charswe.u5` (chargen) | `bee9b3fd` |
  | `906114-01.u17` (PLA) | `54c89351` |

  A distinct romset — not a `#define` alias of `rom_c64`. The Swedish
  kernal (`kernel.u4`) and character generator (`charswe.u5`, the default
  BIOS of two Swedish chargen choices) are unique to this machine; the
  basic and PLA are byte-identical to `c64`.

[← back to Commodore](README.md)
