# Memotech

The Memotech MTX line (`mtx.cpp` in MAME): Memotech's 1983 Z80A home computers (TMS9929A video, SN76489A sound, aluminium case) — the MTX 512, the 32K MTX 500 and the 1984 RS 128 with its serial-board Z80DART. Each `make kernel MACHINE=<name>` below bakes one machine into its own `kernel8-<name>.img` — see the [top-level README](../../README.md) for the build and the regional canvas.

Public-tier only: every asset this platform needs is a public-tier (grey-mirror) source — see [the top-level README](../../README.md#-fetching-them) for what that means.

Prefer a download? Every [tagged release](https://github.com/Xalior/pi-mame/releases/latest) carries a ready-to-boot card and a binary per platform — see [Download a ready-made image](../../README.md#-download-a-ready-made-image) in the top-level README. CI proves every release compiles; the table below is the hardware proof, one HDMI capture per machine.

## Machines

| `make kernel` | System | Year | Romset | Extra assets | TV | |
|---|---|---|---|---|---|---|
| `MACHINE=mtx512` | MTX 512 | 1983 | `mtx512.zip` | — | PAL | [details](mtx512.md) |
| `MACHINE=mtx500` | MTX 500 | 1983 | `mtx500.zip` | `mtx512.zip` | PAL | [details](mtx500.md) |
| `MACHINE=rs128` | RS 128 | 1984 | `rs128.zip` | `mtx512.zip` | PAL | [details](rs128.md) |

Click through to a machine's details page for its exact romset (CRC32 per ROM).

## Assets

```
my-assets/
└── roms/
    ├── mtx512.zip
    ├── mtx500.zip
    └── rs128.zip
```

`scripts/fetch-assets.sh` (see the [README](../../README.md#-fetching-them)) can fetch these for you — `make assets ASSETS=~/my-assets`.

[← back to the top-level README](../../README.md)
