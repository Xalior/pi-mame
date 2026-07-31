# Commodore

The Commodore 8-bit line — the VIC-20, the C64 family (including the PET 64 and Educator 64 rehousings), and the Plus/4 / C16 (TED) family — built on 6502-family CPUs. Each `make kernel MACHINE=<name>` below bakes one machine into its own `kernel8-<name>.img` — see the [top-level README](../../README.md) for the build and the regional canvas.

Public-tier only: no free (properly-blessed-redistribution) ROM source exists for this line, unlike Sinclair's Fuse/proteanthread permission.

Prefer a download? Every [tagged release](https://github.com/Xalior/pi-mame/releases/latest) carries a ready-to-boot card and a binary per platform — see [Download a ready-made image](../../README.md#-download-a-ready-made-image) in the top-level README. CI proves every release compiles; the table below is the hardware proof, one HDMI capture per machine.

## Machines

| `make kernel` | System | Year | Romset | Extra assets | TV | |
|---|---|---|---|---|---|---|
| `MACHINE=c64` | Commodore 64 (NTSC) | 1982 | `c64.zip` | — | NTSC | [details](c64.md) |
| `MACHINE=c64p` | Commodore 64 (PAL) | 1982 | `c64p.zip` | — | PAL | [details](c64p.md) |
| `MACHINE=c64_jp` | Commodore 64 (Japan) | 1982 | `c64_jp.zip` | — | NTSC | [details](c64_jp.md) |
| `MACHINE=c64_se` | Commodore 64 / VIC-64S (Sweden/Finland) | 1982 | `c64_se.zip` | — | PAL | [details](c64_se.md) |
| `MACHINE=c64c` | Commodore 64C (NTSC) | 1986 | `c64c.zip` | — | NTSC | [details](c64c.md) |
| `MACHINE=c64cp` | Commodore 64C (PAL) | 1986 | `c64cp.zip` | — | PAL | [details](c64cp.md) |
| `MACHINE=c64g` | Commodore 64G (PAL) | 1986 | `c64g.zip` | — | PAL | [details](c64g.md) |
| `MACHINE=c64c_es` | Commodore 64C (Spain) | 1988 | `c64c_es.zip` | — | PAL | [details](c64c_es.md) |
| `MACHINE=c64c_se` | Commodore 64C (Sweden/Finland) | 1986 | `c64c_se.zip` | — | PAL | [details](c64c_se.md) |
| `MACHINE=c64gs` | Commodore 64 Games System (PAL) | 1990 | `c64gs.zip` | — | PAL | [details](c64gs.md) |
| `MACHINE=sx64` | SX-64 / Executive 64 (NTSC) | 1984 | `sx64.zip` | `sx1541.zip` | NTSC | [details](sx64.md) |
| `MACHINE=sx64p` | SX-64 / Executive 64 (PAL) | 1984 | `sx64p.zip` | `sx1541.zip` | PAL | [details](sx64p.md) |
| `MACHINE=dx64` | DX-64 (NTSC) | 1984 | `dx64.zip` | `sx1541.zip` | NTSC | [details](dx64.md) |
| `MACHINE=vip64` | VIP-64 (Sweden/Finland) | 1984 | `vip64.zip` | `sx1541.zip` | PAL | [details](vip64.md) |
| `MACHINE=tesa6240` | Etikettendrucker 6240 | 1984 | `tesa6240.zip` | `sx1541.zip` | PAL | [details](tesa6240.md) |
| `MACHINE=pet64` | PET 64 / CBM 4064 (NTSC) | 1983 | `pet64.zip` | — | NTSC | [details](pet64.md) |
| `MACHINE=edu64` | Educator 64 (NTSC) | 1983 | `edu64.zip` | — | NTSC | [details](edu64.md) |
| `MACHINE=vic20` | VIC-20 (NTSC) | 1981 | `vic20.zip` | — | NTSC | [details](vic20.md) |
| `MACHINE=vic20p` | VIC-20 / VC-20 (PAL) | 1981 | `vic20p.zip` | — | PAL | [details](vic20p.md) |
| `MACHINE=vic20_se` | VIC-20 (Sweden/Finland) | 1981 | `vic20_se.zip` | — | PAL | [details](vic20_se.md) |
| `MACHINE=vic1001` | VIC-1001 (Japan) | 1980 | `vic1001.zip` | — | NTSC | [details](vic1001.md) |
| `MACHINE=c264` | Commodore 264 (Prototype) | 1984 | `c264.zip` | — | NTSC | [details](c264.md) |
| `MACHINE=plus4` | Plus/4 (NTSC) | 1984 | `plus4.zip` | — | NTSC | [details](plus4.md) |
| `MACHINE=plus4p` | Plus/4 (PAL) | 1984 | `plus4p.zip` | — | PAL | [details](plus4p.md) |
| `MACHINE=c16` | Commodore 16 (NTSC) | 1984 | `c16.zip` | — | NTSC | [details](c16.md) |
| `MACHINE=c16p` | Commodore 16 (PAL) | 1984 | `c16p.zip` | — | PAL | [details](c16p.md) |
| `MACHINE=c116` | Commodore 116 | 1984 | `c116.zip` | — | PAL | [details](c116.md) |
| `MACHINE=c232` | Commodore 232 (Prototype) | 1984 | `c232.zip` | — | PAL | [details](c232.md) |
| `MACHINE=v364` | Commodore V364 (Prototype) | 1984 | `v364.zip` | — | NTSC | [details](v364.md) |

Click through to a machine's details page for its exact romset (CRC32 per ROM).

## Assets

```
my-assets/
└── roms/
    ├── c64.zip
    ├── c64p.zip
    ├── c64_jp.zip
    ├── c64_se.zip
    ├── c64c.zip
    ├── c64cp.zip
    ├── c64g.zip
    ├── c64c_es.zip
    ├── c64c_se.zip
    ├── c64gs.zip
    ├── sx64.zip
    ├── sx64p.zip
    ├── dx64.zip
    ├── vip64.zip
    ├── tesa6240.zip
    ├── pet64.zip
    ├── edu64.zip
    ├── vic20.zip
    ├── vic20p.zip
    ├── vic20_se.zip
    ├── vic1001.zip
    ├── c264.zip
    ├── plus4.zip
    ├── plus4p.zip
    ├── c16.zip
    ├── c16p.zip
    ├── c116.zip
    ├── c232.zip
    ├── v364.zip
    └── sx1541.zip
```

`sx1541.zip` shared by every machine above:

  | ROM | CRC32 |
  |---|---|
  | `325302-01.uab4` | `29ae9752` |
  | `901229-05 ae.uab5` | `361c9f37` |
  | `jiffydos sx1541` | `783575f6` |
  | `1541 flash.uab5` | `22f7757e` |

`scripts/fetch-assets.sh` (see the [README](../../README.md#-fetching-them)) can fetch these for you — `make assets ASSETS=~/my-assets`.

## Quirks

- **The IEC disk bus boots empty — when the drive is external.** On the
  C64/VIC-20/264/128 lines the driver defaults a disk drive into device 8
  that models an *external*, plug-in option; that drive's own ROM would be a
  second romset the appliance doesn't need to reach BASIC. The kernel bakes
  `-iec8 ""` — a real machine with nothing plugged into its serial port is a
  completely valid, common configuration, and needs no drive romset.

- **Built-in drives are never removed.** Where the drive is *built-in*
  hardware, that empty-slot bake does not apply: the machine ships exactly as
  the driver defines it, with the drive present and its device romset staged.
  This covers the SX-64 family's internal SX1541 (`sx64`, `sx64p`, `vip64`,
  `tesa6240`, and *twice* on `dx64`) — shipping `sx1541.zip`.

[← back to the top-level README](../../README.md)
