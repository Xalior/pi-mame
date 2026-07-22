# Tatung

The Tatung Einstein line (`einstein.cpp` in MAME): Tatung's 1984 Z80A floppy-CP/M machine, the Einstein TC-01 (TMS9129 video, AY-3-8910 sound, built-in 3" drive), and the 1986 Einstein 256 (V9938 video). Each `make kernel MACHINE=<name>` below bakes one machine into its own `kernel8-<name>.img` — see the [top-level README](../../README.md) for the build and the regional canvas.

## Machines

| `make kernel` | System | Year | Romset | Extra assets | TV | |
|---|---|---|---|---|---|---|
| `MACHINE=einstein` | Einstein TC-01 | 1984 | `einstein.zip` | — | — | [details](einstein.md) |
| `MACHINE=einst256` | Einstein 256 | 1986 | `einst256.zip` | — | — | [details](einst256.md) |

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
