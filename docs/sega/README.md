# Sega

Sega's arcade racing hardware: the coin-operated board behind Out Run and the games Sega built on the same design (`segaorun.cpp` in MAME). Two Motorola 68000 processors, a video board that scales sprites to draw the road and the scenery, and a Z80 with a Yamaha FM sound chip for the music. Some of these machines use an encrypted processor, and where they do, the decryption key is a required part of the romset — the machine's own page says so. Sega's directory in MAME covers a great deal of other hardware as well; the machines listed below are the ones brought over so far. Each `make kernel MACHINE=<name>` below bakes one machine into its own `kernel8-<name>.img` — see the [top-level README](../../README.md) for the build and the regional canvas.

Public-tier only: every asset this platform needs is a public-tier (grey-mirror) source — see [the top-level README](../../README.md#-fetching-them) for what that means.

## Machines

| `make kernel` | System | Year | Romset | Extra assets | TV | |
|---|---|---|---|---|---|---|
| `MACHINE=outrun` | Out Run (sitdown/upright, Rev B) | 1986 | `outrun.zip` | — | — | [details](outrun.md) |
| `MACHINE=shangon` | Super Hang-On (sitdown/upright) (unprotected) | 1987 | `shangon.zip` | — | — | [details](shangon.md) |
| `MACHINE=toutrun` | Turbo Out Run (Out Run upgrade) (FD1094 317-0118) | 1989 | `toutrun.zip` | — | — | [details](toutrun.md) |

Click through to a machine's details page for its exact romset (CRC32 per ROM).

## Assets

```
my-assets/
└── roms/
    ├── outrun.zip
    ├── shangon.zip
    └── toutrun.zip
```

`scripts/fetch-assets.sh` (see the [README](../../README.md#-fetching-them)) can fetch these for you — `make assets ASSETS=~/my-assets`.

[← back to the top-level README](../../README.md)
