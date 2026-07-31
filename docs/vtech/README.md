# VTech

The VTech (Video Technology) range: the Laser/VZ Z80 home computers — Laser 110/200/210/310 and the Dick Smith VZ-200/300 (`vtech1.cpp` in MAME), the banked-memory Laser 350/500/700 (`vtech2.cpp`) — plus the 6502-based CreatiVision console family with its Laser 2001/Salora Manager computer siblings (`crvision.cpp`), the SPG24X V.Smile and V.Smile Motion consoles (`vsmile.cpp`) and the VTech IT Unlimited learning computer (`geniusiq.cpp`). Each `make kernel MACHINE=<name>` below bakes one machine into its own `kernel8-<name>.img` — see the [top-level README](../../README.md) for the build and the regional canvas.

Public-tier only: every asset this platform needs is a public-tier (grey-mirror) source — see [the top-level README](../../README.md#-fetching-them) for what that means.

Prefer a download? Every [tagged release](https://github.com/Xalior/pi-mame/releases/latest) carries a ready-to-boot card and a binary per platform — see [Download a ready-made image](../../README.md#-download-a-ready-made-image) in the top-level README. CI proves every release compiles; the table below is the hardware proof, one HDMI capture per machine.

## Machines

| `make kernel` | System | Year | Romset | Extra assets | TV | |
|---|---|---|---|---|---|---|
| `MACHINE=laser110` | Laser 110 | 1983 | `laser110.zip` | — | PAL | [details](laser110.md) |
| `MACHINE=laser200` | Laser 200 | 1983 | `laser200.zip` | `laser110.zip` | PAL | [details](laser200.md) |
| `MACHINE=fellow` | Fellow (Finland) | 1983 | `fellow.zip` | `laser110.zip` | PAL | [details](fellow.md) |
| `MACHINE=tx8000` | TX-8000 (UK) | 1983 | `tx8000.zip` | `laser110.zip` | PAL | [details](tx8000.md) |
| `MACHINE=laser210` | Laser 210 | 1984 | `laser210.zip` | — | PAL | [details](laser210.md) |
| `MACHINE=vz200` | VZ-200 (Oceania) | 1984 | `vz200.zip` | — | PAL | [details](vz200.md) |
| `MACHINE=laser310` | Laser 310 | 1984 | `laser310.zip` | — | PAL | [details](laser310.md) |
| `MACHINE=vz300` | VZ-300 (Oceania) | 1984 | `vz300.zip` | `laser310.zip` | PAL | [details](vz300.md) |
| `MACHINE=laser310h` | Laser 310 (SHRG) | 1984 | `laser310h.zip` | `laser310.zip` | PAL | [details](laser310h.md) |
| `MACHINE=laser350` | Laser 350 | 1985 | `laser350.zip` | — | PAL | [details](laser350.md) |
| `MACHINE=laser500` | Laser 500 | 1985 | `laser500.zip` | — | PAL | [details](laser500.md) |
| `MACHINE=laser700` | Laser 700 | 1985 | `laser700.zip` | — | PAL | [details](laser700.md) |
| `MACHINE=crvision` | CreatiVision | 1982 | `crvision.zip` | — | PAL | [details](crvision.md) |
| `MACHINE=fnvision` | FunVision | 1982 | `fnvision.zip` | — | PAL | [details](fnvision.md) |
| `MACHINE=crvisioj` | CreatiVision (Japan) | 1982 | `crvisioj.zip` | `crvision.zip` | NTSC | [details](crvisioj.md) |
| `MACHINE=wizzard` | Wizzard (Oceania) | 1982 | `wizzard.zip` | `crvision.zip` | PAL | [details](wizzard.md) |
| `MACHINE=rameses` | Rameses HVC6502 (Oceania) | 1982 | `rameses.zip` | `fnvision.zip` | PAL | [details](rameses.md) |
| `MACHINE=vz2000` | VZ 2000 (Oceania) | 1983 | `vz2000.zip` | `fnvision.zip` | PAL | [details](vz2000.md) |
| `MACHINE=crvisio2` | CreatiVision MK-II (Europe) | 1983 | `crvisio2.zip` | `crvision.zip` | PAL | [details](crvisio2.md) |
| `MACHINE=lasr2001` | Laser 2001 | 1983 | `lasr2001.zip` | — | PAL | [details](lasr2001.md) |
| `MACHINE=manager` | Manager (Finland) | 1983 | `manager.zip` | — | PAL | [details](manager.md) |
| `MACHINE=vsmile` | V.Smile | 2005 | `vsmile.zip` | — | NTSC | [details](vsmile.md) |
| `MACHINE=vsmilem` | V.Smile Motion | 2008 | `vsmilem.zip` | — | NTSC | [details](vsmilem.md) |
| `MACHINE=itunlim` | VTech IT Unlimited (UK) | 1998 | `itunlim.zip` | — | PAL | [details](itunlim.md) |

Click through to a machine's details page for its exact romset (CRC32 per ROM).

## Assets

```
my-assets/
└── roms/
    ├── laser110.zip
    ├── laser200.zip
    ├── fellow.zip
    ├── tx8000.zip
    ├── laser210.zip
    ├── vz200.zip
    ├── laser310.zip
    ├── vz300.zip
    ├── laser310h.zip
    ├── laser350.zip
    ├── laser500.zip
    ├── laser700.zip
    ├── crvision.zip
    ├── fnvision.zip
    ├── crvisioj.zip
    ├── wizzard.zip
    ├── rameses.zip
    ├── vz2000.zip
    ├── crvisio2.zip
    ├── lasr2001.zip
    ├── manager.zip
    ├── vsmile.zip
    ├── vsmilem.zip
    └── itunlim.zip
```

`scripts/fetch-assets.sh` (see the [README](../../README.md#-fetching-them)) can fetch these for you — `make assets ASSETS=~/my-assets`.

[← back to the top-level README](../../README.md)
