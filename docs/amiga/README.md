# Amiga

The Arcadia Multi Select arcade platform: Arcadia Systems' ten-interchangeable-game coin-op cabinet built on Amiga A500 hardware (an A500 motherboard driving an external ROM cage through the expansion port). Each `make kernel MACHINE=<name>` below bakes one machine into its own `kernel8-<name>.img` — see the [top-level README](../../README.md) for the build and the regional canvas.

Public-tier only: every asset this platform needs is a public-tier (grey-mirror) source — see [the top-level README](../../README.md#-fetching-them) for what that means.

## Machines

| `make kernel` | System | Year | Romset | Extra assets | TV | |
|---|---|---|---|---|---|---|
| `MACHINE=ar_blast` | Blastaball (Arcadia, V 2.1) | 1988 | `ar_blast.zip` | `ar_bios.zip` | NTSC | [details](ar_blast.md) |
| `MACHINE=ar_airh` | SportTime Table Hockey (Arcadia, set 1, V 2.1) | 1988 | `ar_airh.zip` | `ar_bios.zip` | NTSC | [details](ar_airh.md) |
| `MACHINE=ar_bowl` | SportTime Bowling (Arcadia, V 2.1) | 1988 | `ar_bowl.zip` | `ar_bios.zip` | NTSC | [details](ar_bowl.md) |
| `MACHINE=ar_dart` | World Darts (Arcadia, set 1, V 2.1) | 1987 | `ar_dart.zip` | `ar_bios.zip` | NTSC | [details](ar_dart.md) |
| `MACHINE=ar_fast` | Magic Johnson's Fast Break (Arcadia, V 2.8) | 1988 | `ar_fast.zip` | `ar_bios.zip` | NTSC | [details](ar_fast.md) |
| `MACHINE=ar_fasta` | Magic Johnson's Fast Break (Arcadia, V 2.7) | 1988 | `ar_fasta.zip` | `ar_bios.zip` | NTSC | [details](ar_fasta.md) |
| `MACHINE=ar_ldrb` | Leader Board Golf (Arcadia, set 1, V 2.5) | 1988 | `ar_ldrb.zip` | `ar_bios.zip` | NTSC | [details](ar_ldrb.md) |
| `MACHINE=ar_ldrba` | Leader Board Golf (Arcadia, set 2, V 2.4) | 1988 | `ar_ldrba.zip` | `ar_bios.zip` | NTSC | [details](ar_ldrba.md) |
| `MACHINE=ar_ldrbb` | Leader Board Golf (Arcadia, set 3) | 1988 | `ar_ldrbb.zip` | `ar_bios.zip` | NTSC | [details](ar_ldrbb.md) |
| `MACHINE=ar_ninj` | Ninja Mission (Arcadia, set 1, V 2.5) | 1987 | `ar_ninj.zip` | `ar_bios.zip` | NTSC | [details](ar_ninj.md) |
| `MACHINE=ar_rdwr` | RoadWars (Arcadia, V 2.3) | 1988 | `ar_rdwr.zip` | `ar_bios.zip` | NTSC | [details](ar_rdwr.md) |
| `MACHINE=ar_sdwr` | Sidewinder (Arcadia, set 1, V 2.1) | 1988 | `ar_sdwr.zip` | `ar_bios.zip` | NTSC | [details](ar_sdwr.md) |
| `MACHINE=ar_socc` | World Trophy Soccer (Arcadia, V 3.0) | 1989 | `ar_socc.zip` | `ar_bios.zip` | NTSC | [details](ar_socc.md) |
| `MACHINE=ar_spot` | Spot (Arcadia, V 2.0) | 1990 | `ar_spot.zip` | `ar_bios.zip` | NTSC | [details](ar_spot.md) |
| `MACHINE=ar_sprg` | Space Ranger (Arcadia, V 2.0) | 1987 | `ar_sprg.zip` | `ar_bios.zip` | NTSC | [details](ar_sprg.md) |
| `MACHINE=ar_xeon` | Xenon (Arcadia, V 2.3) | 1988 | `ar_xeon.zip` | `ar_bios.zip` | NTSC | [details](ar_xeon.md) |
| `MACHINE=ar_pm` | Pharaohs Match (Arcadia) | 1988 | `ar_pm.zip` | `ar_bios.zip` | NTSC | [details](ar_pm.md) |
| `MACHINE=ar_dlta` | Delta Command (Arcadia) | 1988 | `ar_dlta.zip` | `ar_bios.zip` | NTSC | [details](ar_dlta.md) |
| `MACHINE=ar_argh` | Aaargh (Arcadia) | 1988 | `ar_argh.zip` | `ar_bios.zip` | NTSC | [details](ar_argh.md) |

Click through to a machine's details page for its exact romset (CRC32 per ROM).

## Assets

```
my-assets/
└── roms/
    ├── ar_blast.zip
    ├── ar_airh.zip
    ├── ar_bowl.zip
    ├── ar_dart.zip
    ├── ar_fast.zip
    ├── ar_fasta.zip
    ├── ar_ldrb.zip
    ├── ar_ldrba.zip
    ├── ar_ldrbb.zip
    ├── ar_ninj.zip
    ├── ar_rdwr.zip
    ├── ar_sdwr.zip
    ├── ar_socc.zip
    ├── ar_spot.zip
    ├── ar_sprg.zip
    ├── ar_xeon.zip
    ├── ar_pm.zip
    ├── ar_dlta.zip
    ├── ar_argh.zip
    └── ar_bios.zip
```

`ar_bios.zip` — Arcadia System BIOS, shared by every machine above:

  | ROM | CRC32 |
  |---|---|
  | `315093-01.u2` | `a6ce1636` |
  | `scpa_01-hi_v3.0.u12` | `2d8e1a06` |
  | `scpa_01-lo_v3.0.u16` | `e4f38fab` |
  | `scpa_01-hi_v2.20.u12` | `79450b4b` |
  | `scpa_01-lo_v2.20.u16` | `d2825511` |
  | `scpa_01-hi_v2.11.u12` | `be9dbdc5` |
  | `scpa_01-lo_v2.11.u16` | `95b84504` |
  | `gcp-1-hi` | `67d44523` |
  | `gcp-1-lo` | `65d9b9cf` |
  | `gcp-2-hi` | `1d7594ae` |
  | `gcp-2-lo` | `e776198d` |
  | `gcp-3-hi` | `3e7364be` |
  | `gcp-3-lo` | `87229e0d` |
  | `gcp_v311_1-hi.u16` | `0b486a85` |
  | `gcp_v311_1-lo.u11` | `80e8e863` |
  | `gcp_v311_2-hi.u17` | `d20a4d7f` |
  | `gcp_v311_2-lo.u12` | `5bf4c74c` |
  | `gcp_v400_1-hi.u16` | `69295167` |
  | `gcp_v400_1-lo.u11` | `504c2171` |
  | `gcp_v400_2-hi.u17` | `13fb4e2d` |
  | `gcp_v400_2-lo.u12` | `a5cc4515` |

`scripts/fetch-assets.sh` (see the [README](../../README.md#-fetching-them)) can fetch these for you — `make assets ASSETS=~/my-assets`.

[← back to the top-level README](../../README.md)
