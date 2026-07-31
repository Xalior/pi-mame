# Sega

Out Run, the driving game Sega released in 1986, running on the coin-operated board Sega built for it (`segaorun.cpp` in MAME): two Motorola 68000 processors, a video board that scales sprites to draw the road and the scenery, and a Z80 with a Yamaha FM sound chip for the music. Sega's directory in MAME covers a great deal of other hardware as well; Out Run is the only machine taken from it so far. Each `make kernel MACHINE=<name>` below bakes one machine into its own `kernel8-<name>.img` — see the [top-level README](../../README.md) for the build and the regional canvas.

Public-tier only: every asset this platform needs is a public-tier (grey-mirror) source — see [the top-level README](../../README.md#-fetching-them) for what that means.

## Machines

| `make kernel` | System | Year | Romset | Extra assets | TV | |
|---|---|---|---|---|---|---|
| `MACHINE=outrun` | Out Run (sitdown/upright, Rev B) | 1986 | `outrun.zip` | — | — | [details](outrun.md) |

Click through to a machine's details page for its exact romset (CRC32 per ROM).

## Assets

```
my-assets/
└── roms/
    └── outrun.zip
```

`scripts/fetch-assets.sh` (see the [README](../../README.md#-fetching-them)) can fetch these for you — `make assets ASSETS=~/my-assets`.

[← back to the top-level README](../../README.md)
