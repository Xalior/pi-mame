# Leader Board Golf (Arcadia, set 2, V 2.4)

![Leader Board Golf (Arcadia, set 2, V 2.4) at power-on](images/ar_ldrba.jpg)

- **`make kernel MACHINE=ar_ldrba`** — Amiga
- **Year**: 1988
- **Manufacturer**: Arcadia Systems
- **Television**: NTSC

## At power-on

`Leader Board Golf (Arcadia, set 2, V 2.4)` boots via the shared Arcadia System BIOS into its attract/title sequence — see the capture above.

## Required assets

- `roms/ar_ldrba.zip`

  | ROM | CRC32 |
  |---|---|
  | `leader_board_01-hi_v2.4.u11` | `fe1287e9` |
  | `leader_board_01-lo_v2.4.u15` | `7c7bb9ee` |
  | `leader_board_02-hi_v2.4.u10` | `64e5fbae` |
  | `leader_board_02-lo_v2.4.u14` | `bb115e1c` |
  | `leader_board_03-hi_v2.4.u9` | `1d290e28` |
  | `leader_board_03-lo_v2.4.u13` | `b1352a77` |
  | `leader_board_04-hi_v2.4.u20` | `b621c688` |
  | `leader_board_04-lo_v2.4.u24` | `13f9c4b0` |
  | `leader_board_05-hi_v2.4.u19` | `71273172` |
  | `leader_board_05-lo_v2.4.u23` | `d9028183` |
  | `leader_board_06-hi_v2.4.u18` | `a6ce61a4` |
  | `leader_board_06-lo_v2.4.u22` | `13c71422` |
  | `leader_board_07-hi_v2.4.u17` | `61807fa9` |
  | `leader_board_07-lo_v2.4.u21` | `c62dae9f` |
  | `leader_board_08-hi_v2.4.u28` | `b5911807` |
  | `leader_board_08-lo_v2.4.u32` | `1f1ea828` |
  | `pal16l8-sec-scpa.u8` | `3a4df3aa` |
- `roms/ar_bios.zip` — the shared Arcadia System BIOS

## Notes

- Arcade coin-op on the Arcadia Multi Select hardware — an Amiga A500 motherboard driving an external ROM cage through the expansion port (see the driver header in `arsystems.cpp`) — hardware-proven on the Pi 4 bench.
- MAME clone of `ar_ldrb` (Leader Board Golf (Arcadia, set 1, V 2.5)) — see the `GAME()` parent field in `arsystems.cpp`. Its own `ROM_START` fully lists every ROM this zip needs; none are borrowed from the parent zip.

[← back to Amiga](README.md)
