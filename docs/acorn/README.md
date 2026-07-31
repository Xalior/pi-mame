# Acorn

The Acorn 8-bit line: the BBC Micro family — Model A/B, B+, Master, Master Compact and their rehousings (`bbcb`/`bbcbp`/`bbcm`/`bbcmc.cpp` in MAME) — plus the Electron (`electron.cpp`) and the Atom (`atom.cpp`), all built on the 6502. Each `make kernel MACHINE=<name>` below bakes one machine into its own `kernel8-<name>.img` — see the [top-level README](../../README.md) for the build and the regional canvas.

Public-tier only: every asset this platform needs is a public-tier (grey-mirror) source — see [the top-level README](../../README.md#-fetching-them) for what that means.

Prefer a download? Every [tagged release](https://github.com/Xalior/pi-mame/releases/latest) carries a ready-to-boot card and a binary per platform — see [Download a ready-made image](../../README.md#-download-a-ready-made-image) in the top-level README. CI proves every release compiles; the table below is the hardware proof, one HDMI capture per machine.

## Machines

| `make kernel` | System | Year | Romset | Extra assets | TV | |
|---|---|---|---|---|---|---|
| `MACHINE=bbcb` | BBC Micro Model B | 1981 | `bbcb.zip` | `bbc_acorn8271.zip`, `saa5050.zip` | PAL | [details](bbcb.md) |
| `MACHINE=bbca` | BBC Micro Model A | 1981 | `bbca.zip` | `saa5050.zip` | PAL | [details](bbca.md) |
| `MACHINE=bbcb_de` | BBC Micro Model B (German) | 1982 | `bbcb_de.zip` | `saa5050.zip` | PAL | [details](bbcb_de.md) |
| `MACHINE=bbcb_no` | BBC Micro Model B (Norway) | 1984 | `bbcb_no.zip` | `saa5050.zip` | PAL | [details](bbcb_no.md) |
| `MACHINE=bbcb_us` | BBC Micro Model B (US) | 1983 | `bbcb_us.zip` | `saa5050.zip` | NTSC | [details](bbcb_us.md) |
| `MACHINE=dolphinm` | Dolphin Microcomputer | 1989 | `dolphinm.zip` | `saa5050.zip` | PAL | [details](dolphinm.md) |
| `MACHINE=torchf` | Torch CF240 | 1982 | `torchf.zip` | `saa5050.zip` | PAL | [details](torchf.md) |
| `MACHINE=torchh` | Torch CH240 | 1983 | `torchh.zip` | `saa5050.zip` | PAL | [details](torchh.md) |
| `MACHINE=bbcbp` | BBC Micro Model B+ 64K | 1985 | `bbcbp.zip` | `saa5050.zip` | PAL | [details](bbcbp.md) |
| `MACHINE=bbcbp128` | BBC Micro Model B+ 128K | 1985 | `bbcbp128.zip` | `bbcbp.zip`, `saa5050.zip` | PAL | [details](bbcbp128.md) |
| `MACHINE=ltmpbp` | LTM Portable (B+) | 1985 | `ltmpbp.zip` | `bbcbp.zip`, `saa5050.zip` | PAL | [details](ltmpbp.md) |
| `MACHINE=bbcm` | BBC Master 128 | 1986 | `bbcm.zip` | `saa5050.zip` | PAL | [details](bbcm.md) |
| `MACHINE=bbcmt` | BBC Master Turbo | 1986 | `bbcmt.zip` | `bbcm.zip`, `saa5050.zip` | PAL | [details](bbcmt.md) |
| `MACHINE=bbcmet` | BBC Master ET | 1986 | `bbcmet.zip` | `saa5050.zip` | PAL | [details](bbcmet.md) |
| `MACHINE=bbcm512` | BBC Master 512 | 1986 | `bbcm512.zip` | `bbcm.zip`, `saa5050.zip` | PAL | [details](bbcm512.md) |
| `MACHINE=ltmpm` | LTM Portable (Master) | 1986 | `ltmpm.zip` | `bbcm.zip`, `saa5050.zip` | PAL | [details](ltmpm.md) |
| `MACHINE=bbcmc` | BBC Master Compact | 1986 | `bbcmc.zip` | `saa5050.zip` | PAL | [details](bbcmc.md) |
| `MACHINE=bbcmc_ar` | BBC Master Compact (Arabic) | 1986 | `bbcmc_ar.zip` | `saa5050.zip` | PAL | [details](bbcmc_ar.md) |
| `MACHINE=pro128s` | Prodest PC 128S | 1987 | `pro128s.zip` | `saa5050.zip` | PAL | [details](pro128s.md) |
| `MACHINE=electron` | Acorn Electron | 1983 | `electron.zip` | `electron_plus3.zip`, `electron_plus1.zip` | PAL | [details](electron.md) |
| `MACHINE=electront` | Acorn Electron (Trial) | 1983 | `electront.zip` | `electron_plus3.zip`, `electron_plus1.zip` | PAL | [details](electront.md) |
| `MACHINE=electron64` | Acorn Electron (64K Master RAM Board) | 1987 | `electron64.zip` | `electron_plus3.zip`, `electron_plus1.zip` | PAL | [details](electron64.md) |
| `MACHINE=electronsp` | Acorn Electron (Stop Press 64i) | 1991 | `electronsp.zip` | `electron_plus3.zip`, `electron_plus1.zip` | PAL | [details](electronsp.md) |
| `MACHINE=atom` | Atom | 1979 | `atom.zip` | `atom_discpack.zip` | NTSC | [details](atom.md) |
| `MACHINE=atombbc` | Atom with BBC Basic | 1982 | `atombbc.zip` | `atom_discpack.zip` | NTSC | [details](atombbc.md) |
| `MACHINE=prophet2` | Prophet 2 | 1983 | `prophet2.zip` | — | NTSC | [details](prophet2.md) |

Click through to a machine's details page for its exact romset (CRC32 per ROM).

## Assets

```
my-assets/
└── roms/
    ├── bbcb.zip
    ├── bbca.zip
    ├── bbcb_de.zip
    ├── bbcb_no.zip
    ├── bbcb_us.zip
    ├── dolphinm.zip
    ├── torchf.zip
    ├── torchh.zip
    ├── bbcbp.zip
    ├── bbcbp128.zip
    ├── ltmpbp.zip
    ├── bbcm.zip
    ├── bbcmt.zip
    ├── bbcmet.zip
    ├── bbcm512.zip
    ├── ltmpm.zip
    ├── bbcmc.zip
    ├── bbcmc_ar.zip
    ├── pro128s.zip
    ├── electron.zip
    ├── electront.zip
    ├── electron64.zip
    ├── electronsp.zip
    ├── atom.zip
    ├── atombbc.zip
    ├── prophet2.zip
    ├── atom_discpack.zip
    ├── bbc_acorn8271.zip
    ├── electron_plus1.zip
    ├── electron_plus3.zip
    └── saa5050.zip
```

`atom_discpack.zip` shared by every machine above:

  | ROM | CRC32 |
  |---|---|
  | `dosrom.ic15` | `c431a9b7` |

`bbc_acorn8271.zip` shared by every machine above:

  | ROM | CRC32 |
  |---|---|
  | `dnfs120.rom` | `8ccd2157` |

`electron_plus1.zip` shared by every machine above:

  | ROM | CRC32 |
  |---|---|
  | `plus1.rom` | `ac30b0ed` |

`electron_plus3.zip` shared by every machine above:

  | ROM | CRC32 |
  |---|---|
  | `adfs.rom` | `3289bdc6` |

`saa5050.zip` shared by every machine above:

  | ROM | CRC32 |
  |---|---|
  | `saa5050` | `201490f3` |

`scripts/fetch-assets.sh` (see the [README](../../README.md#-fetching-them)) can fetch these for you — `make assets ASSETS=~/my-assets`.

[← back to the top-level README](../../README.md)
