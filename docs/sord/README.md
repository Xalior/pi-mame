# Sord

The Sord m.5 line (`m5.cpp` in MAME): Sord's 1983 Z80A home computer (TMS9928A/9929A video, SN76489A sound, twin cartridge slots) — the Japanese m.5, the European m.5p and the Czech BRNO mod with its WD2797 floppy and RAM disk. Each `make kernel MACHINE=<name>` below bakes one machine into its own `kernel8-<name>.img` — see the [top-level README](../../README.md) for the build and the regional canvas.

## Machines

| `make kernel` | System | Year | Romset | Extra assets | TV | |
|---|---|---|---|---|---|---|
| `MACHINE=m5` | m.5 (Japan) | 1983 | `m5.zip` | — | — | [details](m5.md) |
| `MACHINE=m5p` | m.5 (Europe) | 1983 | `m5p.zip` | `m5.zip` | — | [details](m5p.md) |
| `MACHINE=m5p_brno` | m.5 (Europe) BRNO mod | 1983 | `m5p_brno.zip` | — | — | [details](m5p_brno.md) |

Click through to a machine's details page for its exact romset (CRC32 per ROM).

## Assets

```
my-assets/
└── roms/
    ├── m5.zip
    ├── m5p.zip
    └── m5p_brno.zip
```

`scripts/fetch-assets.sh` (see the [README](../../README.md#-fetching-them)) can fetch these for you — `make assets ASSETS=~/my-assets`.

[← back to the top-level README](../../README.md)
