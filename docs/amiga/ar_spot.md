# Spot (Arcadia, V 2.0)

![Spot (Arcadia, V 2.0) at power-on](images/ar_spot.jpg)

- **`make kernel MACHINE=ar_spot`** — Amiga
- **Year**: 1990
- **Manufacturer**: Arcadia Systems
- **Television**: NTSC

## At power-on

`Spot (Arcadia, V 2.0)` boots via the shared Arcadia System BIOS into its attract/title sequence — see the capture above.

## Required assets

- `roms/ar_spot.zip`

  | ROM | CRC32 |
  |---|---|
  | `spotv2.1h` | `a8440838` |
  | `spotv2.1l` | `2abd2835` |
  | `spotv2.2h` | `f4c95f77` |
  | `spotv2.2l` | `58d7bf54` |
  | `spotv2.3h` | `c9d2f3b7` |
  | `spotv2.3l` | `adf94e81` |
  | `spotv2.4h` | `cdea2feb` |
  | `spotv2.4l` | `214c353b` |
  | `spotv2.5h` | `809d0f5c` |
  | `spotv2.5l` | `b86d8153` |
  | `spotv2.6h` | `8c221a34` |
  | `spotv2.6l` | `821fa69a` |
  | `spotv2.7h` | `054355db` |
  | `spotv2.7l` | `30d396d8` |
  | `spotv2.8h` | `94dbb239` |
  | `spotv2.8l` | `4d7f8f05` |
- `roms/ar_bios.zip` — the shared Arcadia System BIOS

## Notes

- Arcade coin-op on the Arcadia Multi Select hardware — an Amiga A500 motherboard driving an external ROM cage through the expansion port (see the driver header in `arsystems.cpp`) — hardware-proven on the Pi 4 bench.

[← back to Amiga](README.md)
