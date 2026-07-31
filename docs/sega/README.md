# Sega

Sega's mid-1980s arcade racing hardware — the boards behind Hang-On and Out Run (`segahang.cpp` and `segaorun.cpp` in MAME). They share a design: two Motorola 68000 processors, a video board that draws the road and the scenery by scaling sprites, and a Z80 with a Yamaha FM sound chip for the music. Scaling sprites is how these games created a sense of speed and distance years before arcade hardware could draw 3D. Some of these machines use an encrypted processor, and where they do, the decryption key is a required part of the romset — the machine's own page says so. Sega's directory in MAME covers a great deal of other hardware as well; the machines listed below are the ones brought over so far. Each `make kernel MACHINE=<name>` below bakes one machine into its own `kernel8-<name>.img` — see the [top-level README](../../README.md) for the build and the regional canvas.

Public-tier only: every asset this platform needs is a public-tier (grey-mirror) source — see [the top-level README](../../README.md#-fetching-them) for what that means.

## Machines

| `make kernel` | System | Year | Romset | Extra assets | TV | |
|---|---|---|---|---|---|---|
| `MACHINE=outrun` | Out Run (sitdown/upright, Rev B) | 1986 | `outrun.zip` | — | — | [details](outrun.md) |
| `MACHINE=shangon` | Super Hang-On (sitdown/upright) (unprotected) | 1987 | `shangon.zip` | — | — | [details](shangon.md) |
| `MACHINE=toutrun` | Turbo Out Run (Out Run upgrade) (FD1094 317-0118) | 1989 | `toutrun.zip` | — | — | [details](toutrun.md) |
| `MACHINE=outrunra` | Out Run (sitdown/upright, Rev A) | 1986 | `outrunra.zip` | — | — | [details](outrunra.md) |
| `MACHINE=outrundx` | Out Run (deluxe sitdown) | 1986 | `outrundx.zip` | — | — | [details](outrundx.md) |
| `MACHINE=hangon` | Hang-On (Rev A) | 1985 | `hangon.zip` | — | — | [details](hangon.md) |

Click through to a machine's details page for its exact romset (CRC32 per ROM).

## Assets

```
my-assets/
└── roms/
    ├── outrun.zip
    ├── shangon.zip
    ├── toutrun.zip
    ├── outrunra.zip
    ├── outrundx.zip
    └── hangon.zip
```

`scripts/fetch-assets.sh` (see the [README](../../README.md#-fetching-them)) can fetch these for you — `make assets ASSETS=~/my-assets`.

[← back to the top-level README](../../README.md)
