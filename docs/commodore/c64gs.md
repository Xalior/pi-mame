# Commodore 64 Games System (PAL)

![Commodore 64 Games System (PAL) at power-on](images/c64gs.jpg)

- **`make kernel MACHINE=c64gs`** — Commodore
- **Year**: 1990
- **Manufacturer**: Commodore Business Machines
- **Television**: PAL

## At power-on

The C64GS is the keyboard-less, cartridge-only console built on Commodore 64C internals. With no cartridge inserted it runs its own boot ROM, which draws the built-in **"insert cartridge"** animation — the `Commodore C64 Games System` title bar, a cartridge sliding into the slot, the power switch, and a red cross. **This is the console's correct power-on state, not a fault**: a real C64GS with an empty slot shows exactly this screen (the same way the Amstrad GX4000 halts at its own cart-less sign-on). The appliance bakes no cartridge, so the animation is what the glass shows. The C64GS carries its own unique KERNAL (`390852-01.u4`) — the GS boot ROM that produces this animation — and shares its character generator and PLA with the rest of the 64C line by checksum. The cartridge slot is **not** mandatory in the driver (`pal_gs` sets no `set_must_be_loaded`), so the machine boots straight to its animation with no blocking file manager.

## Required assets

- `roms/c64gs.zip`

  | ROM | CRC32 |
  |---|---|
  | `390852-01.u4` (kernal) | `b0a9c2da` |
  | `901225-01.u5` (chargen) | `ec4272ee` |
  | `252535-01.u8` | `54c89351` |

## Notes

- MAME driver: `c64.cpp`.
- MAME clone of `c64` (Commodore 64 (NTSC)) — the system macro's parent field in the driver source. The ROM table above lists every member this machine's own zip needs.

[← back to Commodore](README.md)
