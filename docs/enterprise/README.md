# Enterprise

The Enterprise line (`ep64.cpp` in MAME): Enterprise Computers' 1985 Z80A home computer with its NICK video and DAVE sound custom chips — the Enterprise Sixty Four, its German Mephisto PHC 64 OEM sibling, and the 1986 Enterprise One Two Eight. Each `make kernel MACHINE=<name>` below bakes one machine into its own `kernel8-<name>.img` — see the [top-level README](../../README.md) for the build and the regional canvas.

## Machines

| `make kernel` | System | Year | Romset | Extra assets | TV | |
|---|---|---|---|---|---|---|
| `MACHINE=ep64` | Enterprise Sixty Four | 1985 | `ep64.zip` | — | — | [details](ep64.md) |
| `MACHINE=phc64` | Mephisto PHC 64 (Germany) | 1985 | `phc64.zip` | — | — | [details](phc64.md) |
| `MACHINE=ep128` | Enterprise One Two Eight | 1986 | `ep128.zip` | — | — | [details](ep128.md) |

Click through to a machine's details page for its exact romset (CRC32 per ROM).

## Assets

```
my-assets/
└── roms/
    ├── ep64.zip
    ├── phc64.zip
    └── ep128.zip
```

`scripts/fetch-assets.sh` (see the [README](../../README.md#-fetching-them)) can fetch these for you — `make assets ASSETS=~/my-assets`.

[← back to the top-level README](../../README.md)
