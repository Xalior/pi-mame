# Tatung

The Tatung Einstein line (`einstein.cpp` in MAME): Tatung's 1984 Z80A floppy-CP/M machine, the Einstein TC-01 (TMS9129 video, AY-3-8910 sound, built-in 3" drive), and the 1986 Einstein 256 (V9938 video). Each `make kernel MACHINE=<name>` below bakes one machine into its own `kernel8-<name>.img` — see the [top-level README](../../README.md) for the build and the regional canvas.

Public-tier only: every asset this platform needs is a public-tier (grey-mirror) source — see [the top-level README](../../README.md#-fetching-them) for what that means.

Prefer a download? Every [tagged release](https://github.com/Xalior/pi-mame/releases/latest) carries a ready-to-boot card and a binary per platform — see [Download a ready-made image](../../README.md#-download-a-ready-made-image) in the top-level README. CI proves every release compiles; the table below is the hardware proof, one HDMI capture per machine.

## Machines

| `make kernel` | System | Year | Romset | Extra assets | TV | |
|---|---|---|---|---|---|---|
| `MACHINE=einstein` | Einstein TC-01 | 1984 | `einstein.zip` | — | PAL | [details](einstein.md) |
| `MACHINE=einst256` | Einstein 256 | 1986 | `einst256.zip` | — | PAL | [details](einst256.md) |

Click through to a machine's details page for its exact romset (CRC32 per ROM).

## Assets

```
my-assets/
└── roms/
    ├── einstein.zip
    └── einst256.zip
```

`scripts/fetch-assets.sh` (see the [README](../../README.md#-fetching-them)) can fetch these for you — `make assets ASSETS=~/my-assets`.

[← back to the top-level README](../../README.md)
