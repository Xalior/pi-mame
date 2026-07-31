# Camputers

The Camputers Lynx line (`camplynx.cpp` in MAME): the British 1983 Z80A home computer (Motorola 6845 video, one-voice beeper) in its 48k original and the 96k/128k models that followed it. Each `make kernel MACHINE=<name>` below bakes one machine into its own `kernel8-<name>.img` — see the [top-level README](../../README.md) for the build and the regional canvas.

Public-tier only: every asset this platform needs is a public-tier (grey-mirror) source — see [the top-level README](../../README.md#-fetching-them) for what that means.

Prefer a download? Every [tagged release](https://github.com/Xalior/pi-mame/releases/latest) carries a ready-to-boot card and a binary per platform — see [Download a ready-made image](../../README.md#-download-a-ready-made-image) in the top-level README. CI proves every release compiles; the table below is the hardware proof, one HDMI capture per machine.

## Machines

| `make kernel` | System | Year | Romset | Extra assets | TV | |
|---|---|---|---|---|---|---|
| `MACHINE=lynx48k` | Lynx 48k | 1983 | `lynx48k.zip` | — | PAL | [details](lynx48k.md) |
| `MACHINE=lynx96k` | Lynx 96k | 1983 | `lynx96k.zip` | — | PAL | [details](lynx96k.md) |
| `MACHINE=lynx128k` | Lynx 128k | 1983 | `lynx128k.zip` | — | PAL | [details](lynx128k.md) |

Click through to a machine's details page for its exact romset (CRC32 per ROM).

## Assets

```
my-assets/
└── roms/
    ├── lynx48k.zip
    ├── lynx96k.zip
    └── lynx128k.zip
```

`scripts/fetch-assets.sh` (see the [README](../../README.md#-fetching-them)) can fetch these for you — `make assets ASSETS=~/my-assets`.

[← back to the top-level README](../../README.md)
