# TRS / Tandy

The TRS / Tandy Radio Shack catalog (`src/mame/trs/` in MAME): the TRS-80 Model I (`trs80.cpp`) and DT-1 data terminal (`trs80dt1.cpp`); the 6809 Color Computer family — CoCo 1/2 and its Brazilian/Mexican/Swedish clones (`coco12.cpp`), the GIME-based CoCo 3 line (`coco3.cpp`), the AgVision/Videotex terminals (`agvision.cpp`) — with its Dragon offshoots (`dragon.cpp`, `dgnalpha.cpp`); the 6803 MC-10 and the Matra Alice family (`mc10.cpp`); the Polish Meritum I TRS-80 clones (`meritum.cpp`); and the Tandy/Memorex VIS CD player (`vis.cpp`). Each `make kernel MACHINE=<name>` below bakes one machine into its own `kernel8-<name>.img` — see the [top-level README](../../README.md) for the build and the regional canvas.

## Machines

| `make kernel` | System | Year | Romset | Extra assets | TV | |
|---|---|---|---|---|---|---|
| `MACHINE=trs80` | TRS-80 Model I (Level I Basic) | 1977 | `trs80.zip` | — | — | [details](trs80.md) |
| `MACHINE=trs80dt1` | TRS-80 DT-1 Data Terminal | 1982 | `trs80dt1.zip` | — | — | [details](trs80dt1.md) |
| `MACHINE=agvision` | AgVision | 1979 | `agvision.zip` | — | — | [details](agvision.md) |
| `MACHINE=trsvidtx` | Videotex | 1980 | `trsvidtx.zip` | — | — | [details](trsvidtx.md) |
| `MACHINE=coco` | Color Computer 1/2 | 1980 | `coco.zip` | `coco_fdc.zip` | — | [details](coco.md) |
| `MACHINE=cocoh` | Color Computer 1/2 (HD6309) | 19?? | `cocoh.zip` | `coco_fdc.zip` | — | [details](cocoh.md) |
| `MACHINE=deluxecoco` | Deluxe Color Computer | 1983 | `deluxecoco.zip` | `coco_fdc.zip` | — | [details](deluxecoco.md) |
| `MACHINE=coco2b` | Color Computer 2B | 1985? | `coco2b.zip` | `coco.zip`, `coco_fdc.zip` | — | [details](coco2b.md) |
| `MACHINE=coco2bh` | Color Computer 2B (HD6309) | 19?? | `coco2bh.zip` | `coco.zip`, `coco_fdc.zip` | — | [details](coco2bh.md) |
| `MACHINE=cp400` | CP400 | 1983 | `cp400.zip` | `cp450_fdc.zip` | — | [details](cp400.md) |
| `MACHINE=cp400c2` | CP400 Color II | 1985 | `cp400c2.zip` | `cp450_fdc.zip` | — | [details](cp400c2.md) |
| `MACHINE=mx1600` | MX-1600 | 1984 | `mx1600.zip` | `coco_fdc.zip` | — | [details](mx1600.md) |
| `MACHINE=t4426` | Terco 4426 CNC Programming station | 1986 | `t4426.zip` | `coco_t4426.zip` | — | [details](t4426.md) |
| `MACHINE=lzcolor64` | Color64 | 1983 | `lzcolor64.zip` | `coco_fdc.zip` | — | [details](lzcolor64.md) |
| `MACHINE=cd6809` | CD-6809 | 1983 | `cd6809.zip` | `cd6809_fdc.zip` | — | [details](cd6809.md) |
| `MACHINE=ms1600` | Micro-SEP 1600 | 1987 | `ms1600.zip` | `coco_fdc.zip` | — | [details](ms1600.md) |
| `MACHINE=coco3` | Color Computer 3 (NTSC) | 1986 | `coco3.zip` | `coco_fdc.zip` | — | [details](coco3.md) |
| `MACHINE=coco3p` | Color Computer 3 (PAL) | 1986 | `coco3p.zip` | `coco_fdc.zip` | — | [details](coco3p.md) |
| `MACHINE=coco3h` | Color Computer 3 (NTSC; HD6309) | 19?? | `coco3h.zip` | `coco_fdc.zip` | — | [details](coco3h.md) |
| `MACHINE=msm3` | Micro-Sep Model 3 | 1987 | `msm3.zip` | `coco_fdc.zip` | — | [details](msm3.md) |
| `MACHINE=dragon32` | Dragon 32 | 1982 | `dragon32.zip` | `dragon_fdc.zip` | — | [details](dragon32.md) |
| `MACHINE=dragon64` | Dragon 64 | 1983 | `dragon64.zip` | `dragon_fdc.zip` | — | [details](dragon64.md) |
| `MACHINE=dragon64h` | Dragon 64 (HD6309E) | 19?? | `dragon64h.zip` | `dragon_fdc.zip` | — | [details](dragon64h.md) |
| `MACHINE=dragon200` | Dragon 200 | 1985 | `dragon200.zip` | `dragon_fdc.zip` | — | [details](dragon200.md) |
| `MACHINE=dragon200e` | Dragon 200-E | 1985 | `dragon200e.zip` | `dragon_fdc.zip` | — | [details](dragon200e.md) |
| `MACHINE=d64plus` | Dragon 64 Plus | 1985 | `d64plus.zip` | `dragon_fdc.zip` | — | [details](d64plus.md) |
| `MACHINE=tanodr64` | Tano Dragon 64 (NTSC) | 1983 | `tanodr64.zip` | `sdtandy_fdc.zip` | — | [details](tanodr64.md) |
| `MACHINE=tanodr64h` | Tano Dragon 64 (NTSC; HD6309E) | 19?? | `tanodr64h.zip` | `sdtandy_fdc.zip` | — | [details](tanodr64h.md) |
| `MACHINE=dgnalpha` | Dragon Professional (Alpha) | 1984 | `dgnalpha.zip` | — | — | [details](dgnalpha.md) |
| `MACHINE=mc10` | MC-10 | 1983 | `mc10.zip` | — | — | [details](mc10.md) |
| `MACHINE=alice` | Alice | 1983 | `alice.zip` | — | — | [details](alice.md) |
| `MACHINE=alice32` | Alice 32 | 1984 | `alice32.zip` | — | — | [details](alice32.md) |
| `MACHINE=alice90` | Alice 90 | 1985 | `alice90.zip` | — | — | [details](alice90.md) |
| `MACHINE=meritum1` | Meritum I (Model 1) | 1983 | `meritum1.zip` | — | — | [details](meritum1.md) |
| `MACHINE=meritum2` | Meritum I (Model 2) | 1985 | `meritum2.zip` | — | — | [details](meritum2.md) |
| `MACHINE=meritum_net` | Meritum I (Model 2) (network) | 1985 | `meritum_net.zip` | — | — | [details](meritum_net.md) |
| `MACHINE=vis` | Video Information System MD-2500 | 1992 | `vis.zip` | — | — | [details](vis.md) |

Click through to a machine's details page for its exact romset (CRC32 per ROM).

## Assets

```
my-assets/
└── roms/
    ├── trs80.zip
    ├── trs80dt1.zip
    ├── agvision.zip
    ├── trsvidtx.zip
    ├── coco.zip
    ├── cocoh.zip
    ├── deluxecoco.zip
    ├── coco2b.zip
    ├── coco2bh.zip
    ├── cp400.zip
    ├── cp400c2.zip
    ├── mx1600.zip
    ├── t4426.zip
    ├── lzcolor64.zip
    ├── cd6809.zip
    ├── ms1600.zip
    ├── coco3.zip
    ├── coco3p.zip
    ├── coco3h.zip
    ├── msm3.zip
    ├── dragon32.zip
    ├── dragon64.zip
    ├── dragon64h.zip
    ├── dragon200.zip
    ├── dragon200e.zip
    ├── d64plus.zip
    ├── tanodr64.zip
    ├── tanodr64h.zip
    ├── dgnalpha.zip
    ├── mc10.zip
    ├── alice.zip
    ├── alice32.zip
    ├── alice90.zip
    ├── meritum1.zip
    ├── meritum2.zip
    ├── meritum_net.zip
    ├── vis.zip
    ├── cd6809_fdc.zip
    ├── coco_fdc.zip
    ├── coco_t4426.zip
    ├── cp450_fdc.zip
    ├── dragon_fdc.zip
    └── sdtandy_fdc.zip
```

`cd6809_fdc.zip` — cd6809_fdc, shared by every machine above:

  | ROM | CRC32 |
  |---|---|

`coco_fdc.zip` — coco_fdc, shared by every machine above:

  | ROM | CRC32 |
  |---|---|

`coco_t4426.zip` — coco_t4426, shared by every machine above:

  | ROM | CRC32 |
  |---|---|

`cp450_fdc.zip` — cp450_fdc, shared by every machine above:

  | ROM | CRC32 |
  |---|---|

`dragon_fdc.zip` — dragon_fdc, shared by every machine above:

  | ROM | CRC32 |
  |---|---|

`sdtandy_fdc.zip` — sdtandy_fdc, shared by every machine above:

  | ROM | CRC32 |
  |---|---|

`scripts/fetch-assets.sh` (see the [README](../../README.md#-fetching-them)) can fetch these for you — `make assets ASSETS=~/my-assets`.

[← back to the top-level README](../../README.md)
