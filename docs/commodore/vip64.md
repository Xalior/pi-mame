# VIP-64 (Sweden/Finland SX-64, PAL)

![VIP-64 at power-on](images/vip64.jpg)

- **`make MACHINE=vip64`** — Commodore Business Machines
- **Year**: 1984
- **Manufacturer**: Commodore Business Machines
- **Television**: PAL

## At power-on

The VIP-64 is the Swedish/Finnish-market portable SX-64. It carries the
SX-64's KERNAL — so it draws the same **distinct sign-on**: `***** SX-64
BASIC V2.0 *****`, `64K RAM SYSTEM  38911 BASIC BYTES FREE`, `READY.`, the
SX kernal's inverted colour scheme (dark-blue text on a white screen) — but
its kernal (`kernelsx.ud3`) is a *Swedish* variant, paired with a Swedish
character generator (`charswe.ud1`), the appliance's proof this is the
Swedish SX romset and not a plain SX-64.

## The built-in drive

Like every machine in the `sx64_state` family, the VIP-64's defining
hardware is its internal 1541. The `pal_sx` machine config **replaces the
iec8 slot's default** with the built-in drive (`sx1541`):

```
CBM_IEC_SLOT(config.replace(), "iec8", 8, sx1541_iec_devices, "sx1541");
```

It is still the **iec8 slot**, emptied the same way as every other C64 in
this line — `-iec8 ""`. Device 8 is baked empty, so no 1541 drive romset is
required to reach BASIC. A real VIP-64 always has its internal drive, so an
empty bus is a documented appliance quirk rather than a faithful hardware
configuration; it is the smallest honest parcel and boots straight to the
Swedish SX kernal's own sign-on.

## Required assets

- `roms/vip64.zip`

  | ROM | CRC32 |
  |---|---|
  | `901226-01.ud4` (basic) | `f833d117` |
  | `kernelsx.ud3` (kernal SX Swedish) | `7858d3d7` |
  | `charswe.ud1` (chargen Swedish) | `bee9b3fd` |
  | `906114-01.ue4` (PLA) | `54c89351` |

  A distinct romset — not a `#define` alias of `rom_sx64`. The Swedish SX
  KERNAL (`kernelsx.ud3`) and the Swedish character generator
  (`charswe.ud1`) are unique to this machine and come from its own
  split-set zip; the chargen is byte-identical in content to `c64_se`'s
  `charswe.u5`. The basic and PLA are byte-identical to `c64`'s members,
  located by CRC32 in the parent `c64.zip` and repacked under the
  `ud4`/`ue4` board-position names vip64 expects.

[← back to Commodore](README.md)
