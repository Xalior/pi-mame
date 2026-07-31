# Commodore 64C (PAL)

![Commodore 64C (PAL) at power-on](images/c64cp.jpg)

- **`make kernel MACHINE=c64cp`** — Commodore
- **Year**: 1986
- **Manufacturer**: Commodore Business Machines
- **Television**: PAL

## At power-on

Commodore 64 BASIC V2, `READY.` — the IEC disk bus boots empty (`-iec8 ""`), so no drive romset is required to reach BASIC. The `c64cp` is the PAL cost-reduced 64C — the same restyled machine as the NTSC `c64c`, differing only in video/CIA timing (PAL vs. NTSC), which is machine config, not ROM data. Its sign-on banner and free-memory figure match the NTSC 64C. The visible difference is inside the case, not on the screen: the 64C merges BASIC and the KERNAL into a single 16 KB part.

## Required assets

- `roms/c64cp.zip`

  | ROM | CRC32 |
  |---|---|
  | `251913-01.u4` (kernal) | `0010ec31` |
  | `pdc.u4` (kernal) | `6b653b9c` |
  | `901225-01.u5` (chargen) | `ec4272ee` |
  | `252715-01.u8` | `54c89351` |

## Notes

- MAME driver: `c64.cpp`.
- MAME clone of `c64` (Commodore 64 (NTSC)) — the system macro's parent field in the driver source. The ROM table above lists every member this machine's own zip needs.

[← back to Commodore](README.md)
