# SAM Coupé

The MGT SAM Coupé (`samcoupe.cpp` in MAME): Miles Gordon Technology's 1989 Z80 home computer (6 MHz Z80, custom ASIC video, SAA1099 sound, two front drive bays). Each `make kernel MACHINE=<name>` below bakes one machine into its own `kernel8-<name>.img` — see the [top-level README](../../README.md) for the build and the regional canvas.

Public-tier only: every asset this platform needs is a public-tier (grey-mirror) source — see [the top-level README](../../README.md#-fetching-them) for what that means.

Prefer a download? Every [tagged release](https://github.com/Xalior/pi-mame/releases/latest) carries a ready-to-boot card and a binary per platform — see [Download a ready-made image](../../README.md#-download-a-ready-made-image) in the top-level README. CI proves every release compiles; the table below is the hardware proof, one HDMI capture per machine.

## Machines

| `make kernel` | System | Year | Romset | Extra assets | TV | |
|---|---|---|---|---|---|---|
| `MACHINE=samcoupe` | SAM Coupé | 1989 | `samcoupe.zip` | — | PAL | [details](samcoupe.md) |

Click through to a machine's details page for its exact romset (CRC32 per ROM).

## Assets

```
my-assets/
└── roms/
    └── samcoupe.zip
```

`scripts/fetch-assets.sh` (see the [README](../../README.md#-fetching-them)) can fetch these for you — `make assets ASSETS=~/my-assets`.

[← back to the top-level README](../../README.md)
