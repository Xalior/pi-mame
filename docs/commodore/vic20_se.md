# VIC-20 (Sweden/Finland)

![VIC-20 (Sweden/Finland) at power-on](images/vic20_se.jpg)

- **`make kernel MACHINE=vic20_se`** — Commodore Business Machines
- **Year**: 1981
- **Manufacturer**: Commodore Business Machines
- **Television**: PAL

## At power-on

This is the Nordic VIC-20 — the machine Commodore sold in **Sweden and
Finland** with a national kernal and character generator (the pan-European
PAL sibling is [`vic20p`](vic20p.md); the NTSC original, marketed in Japan as
the VIC-1001, is [`vic20`](vic20.md)). It is the last machine of the VIC-20
family. Same 6502 and 6560/6561 "VIC" video chip, same first colour home
computer that became the first computer of any kind to sell a million units;
the difference from `vic20p` is the Swedish/Finnish kernal (`nec22081.206`)
and its own national character generator (`nec22101.207`), paired with the
Swedish keyboard layout. It boots straight to the sign-on and `READY.`
prompt, here reading **`**** CBM BASIC V2 ****`** with **`3583 BYTES FREE`**:
the unexpanded VIC-20 ships with only ~3.5 KB of BASIC RAM (versus the C64's
38911), a defining constraint of the machine.

The glass shows the VIC-20's own palette — a **cyan border**, a **white
screen**, and **dark-blue text** — distinct from the C64's blue-on-blue. It
renders on the PAL canvas. This is the `vic20_se` clone of the same
`src/mame/commodore/vic20.cpp` `vic20_state` driver that carries the NTSC
`vic20` and PAL `vic20p`.

MAME flags this driver `MACHINE_IMPERFECT_GRAPHICS | MACHINE_IMPERFECT_SOUND`,
but — like the rest of this line on this appliance — it boots straight through
to BASIC with no blocking warnings box.

## Required assets

- `roms/vic20_se.zip`

  | ROM | CRC32 |
  |---|---|
  | `901486-01.ue11` (basic) | `db4c43c1` |
  | `nec22081.206` (kernal) | `b2a60662` |
  | `nec22101.207` (chargen) | `d808551d` |

  `vic20_se` is a clone of the parent `vic1001` under MAME's split-set
  convention, so its members span source zips: the unique **Swedish/Finnish**
  kernal (`nec22081.206`) and national character generator (`nec22101.207` —
  the Nordic set carries its own chargen, distinct from the `vic20`/`vic20p`
  `901460-03.ud7`) both come from `vic20_se.zip`, while the BASIC ROM
  (`901486-01.ue11`) is byte-identical to the parent's (CRC `db4c43c1`) and is
  packed only in `vic1001.zip`. All three are located by checksum and repacked
  under the exact filenames this driver expects. `vic20_se` has no
  `ROM_SYSTEM_BIOS` alternates — its single kernal is the default.

## Quirks

- **The IEC disk bus boots empty.** The VIC-20 wires the same Commodore serial
  bus as the C64 line — a C1541 drive defaulting to device 8, whose own ROM
  would be a second romset this appliance doesn't need to reach BASIC. The
  kernel bakes `-iec8 ""`, exactly as the C64 machines do; a real VIC-20 with
  nothing plugged into its serial port is a completely valid, common
  configuration.

[← back to Commodore](README.md)
