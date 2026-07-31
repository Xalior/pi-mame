# Educator 64 (NTSC)

![Educator 64 (NTSC) at power-on](images/edu64.jpg)

- **`make kernel MACHINE=edu64`** — Commodore
- **Year**: 1983
- **Manufacturer**: Commodore Business Machines
- **Television**: NTSC

## At power-on

The Educator 64 is a Commodore 64 rehoused in a PET-style all-in-one case with a built-in monochrome monitor, aimed at the education market. It shares the PET 64's machine configuration, but — unlike the PET 64 — it carries the **standard C64 KERNAL** (revision 3), so it boots straight to the familiar C64 BASIC sign-on: **`**** COMMODORE 64 BASIC V2 ****`**, `64K RAM SYSTEM 38911 BASIC BYTES FREE`, and the `READY.` prompt. Because it runs the standard KERNAL, the Educator 64 powers on with the classic C64 **light-blue text on a dark-blue screen** — the KERNAL sets those screen colours at boot. MAME still flags this driver `MACHINE_WRONG_COLORS`: the driver shares the PET 64's config, whose green-monochrome palette is a TODO (the real unit drove a monochrome monitor, so the emulated colours do not match the hardware). The flag is a note, not a blocker — the machine boots straight through to BASIC with no blocking warnings box, exactly as it does on the bench. The Educator 64's romset is a `#define` alias of the base C64 (`rom_edu64 rom_c64`): byte-for-byte the same four ROMs the standard Commodore 64 loads.

## Required assets

- `roms/edu64.zip`

  | ROM | CRC32 |
  |---|---|
  | `901226-01.u3` (basic) | `f833d117` |
  | `901227-01.u4` (kernal) | `dce782fa` |
  | `901227-02.u4` (kernal) | `a5c687b3` |
  | `901227-03.u4` (kernal) | `dbe3e7c7` |
  | `jiffydos c64.u4` (kernal) | `2f79984c` |
  | `speed-dos.u4` (kernal) | `5beb9ac8` |
  | `speed-dosplus.u4` (kernal) | `10aee0ae` |
  | `speed-dosplus27.u4` (kernal) | `ff59995e` |
  | `prodos.u4` (kernal) | `37ed83a2` |
  | `prodos24l2.u4` (kernal) | `41dad9fe` |
  | `prodos35l2.u4` (kernal) | `2822eee7` |
  | `turborom.u4` (kernal) | `e6c763a2` |
  | `dosrom12.u4` (kernal) | `ac030fc0` |
  | `turborom2.u4` (kernal) | `ea3ba683` |
  | `mercury3.u4` (kernal) | `6eac46a2` |
  | `kernal-10-mager.u4` (kernal) | `c9bb21bc` |
  | `kernal-20-1_au.u4` (kernal) | `7068bbcc` |
  | `kernal-20-1.u4` (kernal) | `c9c4c44e` |
  | `kernal-20-2.u4` (kernal) | `ffaeb9bc` |
  | `kernal-20-3.u4` (kernal) | `4fd511f2` |
  | `kernal-30.u4` (kernal) | `5402d643` |
  | `turboaccess26.u4` (kernal) | `93de6cd9` |
  | `turboaccess301.u4` (kernal) | `b3304dcf` |
  | `turboaccess302.u4` (kernal) | `9e696a7b` |
  | `turboprocess.u4` (kernal) | `e5610d76` |
  | `turboprocessus.u4` (kernal) | `7480b76a` |
  | `exos3.u4` (kernal) | `4e54d020` |
  | `exos4.u4` (kernal) | `d5cf83a9` |
  | `digidos.u4` (kernal) | `2b0c8e89` |
  | `magnum.u4` (kernal) | `b2cffcc6` |
  | `mercury31s.u4` (kernal) | `97aa5d2f` |
  | `901225-01.u5` (chargen) | `ec4272ee` |
  | `906114-01.u17` | `54c89351` |

## Notes

- MAME driver: `c64.cpp`.
- MAME clone of `c64` (Commodore 64 (NTSC)) — the system macro's parent field in the driver source. The ROM table above lists every member this machine's own zip needs.

[← back to Commodore](README.md)
