# VIP-64 (Sweden/Finland)

![VIP-64 (Sweden/Finland) at power-on](images/vip64.jpg)

- **`make kernel MACHINE=vip64`** — Commodore
- **Year**: 1984
- **Manufacturer**: Commodore Business Machines
- **Television**: PAL

## At power-on

The VIP-64 is the Swedish/Finnish-market portable SX-64. It carries the SX-64's KERNAL — so it draws the same **distinct sign-on**: `***** SX-64 BASIC V2.0 *****`, `64K RAM SYSTEM  38911 BASIC BYTES FREE`, `READY.`, the SX kernal's inverted colour scheme (dark-blue text on a white screen) — but its kernal (`kernelsx.ud3`) is a *Swedish* variant, paired with a Swedish character generator (`charswe.ud1`), the appliance's proof this is the Swedish SX romset and not a plain SX-64.

## Required assets

- `roms/vip64.zip`

  | ROM | CRC32 |
  |---|---|
  | `901226-01.ud4` (basic) | `f833d117` |
  | `kernelsx.ud3` (kernal) | `7858d3d7` |
  | `charswe.ud1` (chargen) | `bee9b3fd` |
  | `906114-01.ue4` | `54c89351` |
- `roms/sx1541.zip`

## Notes

- MAME driver: `c64.cpp`.
- MAME clone of `c64` (Commodore 64 (NTSC)) — the system macro's parent field in the driver source. The ROM table above lists every member this machine's own zip needs.

## The built-in drive

Like every machine in the `sx64_state` family, the VIP-64's defining
hardware is its internal 1541. The `pal_sx` machine config **replaces the
iec8 slot's default** with the built-in drive (`sx1541`):

```
CBM_IEC_SLOT(config.replace(), "iec8", 8, sx1541_iec_devices, "sx1541");
```

This drive is **built-in hardware**, and built-in hardware is never removed:
the appliance ships the machine as the driver defines it, with no `-iec8`
override. MAME's `sx1541` default at device 8 stands, so the machine requires
the `sx1541` drive romset and boots to the Swedish SX kernal's own sign-on
**with its internal drive present**. (The C64-line `-iec8 ""` bake applies
only to machines whose device-8 default models an *external*, plug-in drive —
never to a built-in one.)

[← back to Commodore](README.md)
