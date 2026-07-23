# Memotech

The Memotech MTX line (`mtx.cpp` in MAME): Memotech's 1983 Z80A home computers (TMS9929A video, SN76489A sound, aluminium case) — the MTX 512, the 32K MTX 500 and the 1984 RS 128 with its serial-board Z80DART. Each `make kernel MACHINE=<name>` below bakes one machine into its own `kernel8-<name>.img` — see the [top-level README](../../README.md) for the build and the regional canvas.

## Machines

| `make kernel` | System | Year | Romset | Extra assets | TV | |
|---|---|---|---|---|---|---|
| `MACHINE=mtx512` | MTX 512 | 1983 | `mtx512.zip` | — | — | [details](mtx512.md) |
| `MACHINE=mtx500` | MTX 500 | 1983 | `mtx500.zip` | — | — | [details](mtx500.md) |
| `MACHINE=rs128` | RS 128 | 1984 | `rs128.zip` | — | — | [details](rs128.md) |

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
