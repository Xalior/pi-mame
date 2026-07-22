# Atari

The 8-bit Atari computer line: the 400/800 originals and the XL/XE range that followed them (MOS 6502C SALLY + ANTIC/GTIA/POKEY, `atari400.cpp` in MAME). Each `make kernel MACHINE=<name>` below bakes one machine into its own `kernel8-<name>.img` — see the [top-level README](../../README.md) for the build and the regional canvas.

## Machines

| `make kernel` | System | Year | Romset | Extra assets | TV | |
|---|---|---|---|---|---|---|
| `MACHINE=a400` | Atari 400 (NTSC) | 1979 | `a400.zip` | — | — | [details](a400.md) |
| `MACHINE=a400pal` | Atari 400 (PAL) | 1979 | `a400pal.zip` | — | — | [details](a400pal.md) |
| `MACHINE=a800` | Atari 800 (NTSC) | 1979 | `a800.zip` | — | — | [details](a800.md) |
| `MACHINE=a800pal` | Atari 800 (PAL) | 1979 | `a800pal.zip` | — | — | [details](a800pal.md) |
| `MACHINE=a600xl` | Atari 600XL | 1983 | `a600xl.zip` | — | — | [details](a600xl.md) |
| `MACHINE=a800xl` | Atari 800XL (NTSC) | 1983 | `a800xl.zip` | — | — | [details](a800xl.md) |
| `MACHINE=a800xlp` | Atari 800XL (PAL) | 1983 | `a800xlp.zip` | — | — | [details](a800xlp.md) |
| `MACHINE=a65xe` | Atari 65XE | 1986 | `a65xe.zip` | — | — | [details](a65xe.md) |
| `MACHINE=a800xe` | Atari 800XE | 1986 | `a800xe.zip` | — | — | [details](a800xe.md) |
| `MACHINE=xegs` | Atari XE Game System | 1987 | `xegs.zip` | — | — | [details](xegs.md) |

Click through to a machine's details page for its exact romset (CRC32 per ROM).

## Assets

```
my-assets/
└── roms/
    ├── a400.zip
    ├── a400pal.zip
    ├── a800.zip
    ├── a800pal.zip
    ├── a600xl.zip
    ├── a800xl.zip
    ├── a800xlp.zip
    ├── a65xe.zip
    ├── a800xe.zip
    └── xegs.zip
```

`scripts/fetch-assets.sh` (see the [README](../../README.md#-fetching-them)) can fetch these for you — `make assets ASSETS=~/my-assets`.

[← back to the top-level README](../../README.md)
