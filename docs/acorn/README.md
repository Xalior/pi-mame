# Acorn

The Acorn 8-bit line: the BBC Micro family — Model A/B, B+, Master, Master Compact and their rehousings (`bbcb`/`bbcbp`/`bbcm`/`bbcmc.cpp` in MAME) — plus the Electron (`electron.cpp`) and the Atom (`atom.cpp`), all built on the 6502. Each `make kernel MACHINE=<name>` below bakes one machine into its own `kernel8-<name>.img` — see the [top-level README](../../README.md) for the build and the regional canvas.

## Machines

| `make kernel` | System | Year | Romset | Extra assets | TV | |
|---|---|---|---|---|---|---|
| `MACHINE=bbcb` | BBC Micro Model B | 1981 | `bbcb.zip` | — | — | [details](bbcb.md) |
| `MACHINE=bbca` | BBC Micro Model A | 1981 | `bbca.zip` | — | — | [details](bbca.md) |
| `MACHINE=bbcb_de` | BBC Micro Model B (German) | 1982 | `bbcb_de.zip` | — | — | [details](bbcb_de.md) |
| `MACHINE=bbcb_no` | BBC Micro Model B (Norway) | 1984 | `bbcb_no.zip` | — | — | [details](bbcb_no.md) |
| `MACHINE=bbcb_us` | BBC Micro Model B (US) | 1983 | `bbcb_us.zip` | — | — | [details](bbcb_us.md) |
| `MACHINE=dolphinm` | Dolphin Microcomputer | 1989 | `dolphinm.zip` | — | — | [details](dolphinm.md) |
| `MACHINE=torchf` | Torch CF240 | 1982 | `torchf.zip` | — | — | [details](torchf.md) |
| `MACHINE=torchh` | Torch CH240 | 1983 | `torchh.zip` | — | — | [details](torchh.md) |
| `MACHINE=bbcbp` | BBC Micro Model B+ 64K | 1985 | `bbcbp.zip` | — | — | [details](bbcbp.md) |
| `MACHINE=bbcbp128` | BBC Micro Model B+ 128K | 1985 | `bbcbp128.zip` | — | — | [details](bbcbp128.md) |
| `MACHINE=ltmpbp` | LTM Portable (B+) | 1985 | `ltmpbp.zip` | — | — | [details](ltmpbp.md) |
| `MACHINE=bbcm` | BBC Master 128 | 1986 | `bbcm.zip` | — | — | [details](bbcm.md) |
| `MACHINE=bbcmt` | BBC Master Turbo | 1986 | `bbcmt.zip` | — | — | [details](bbcmt.md) |
| `MACHINE=bbcmet` | BBC Master ET | 1986 | `bbcmet.zip` | — | — | [details](bbcmet.md) |
| `MACHINE=bbcm512` | BBC Master 512 | 1986 | `bbcm512.zip` | — | — | [details](bbcm512.md) |
| `MACHINE=ltmpm` | LTM Portable (Master) | 1986 | `ltmpm.zip` | — | — | [details](ltmpm.md) |
| `MACHINE=bbcmc` | BBC Master Compact | 1986 | `bbcmc.zip` | — | — | [details](bbcmc.md) |
| `MACHINE=bbcmc_ar` | BBC Master Compact (Arabic) | 1986 | `bbcmc_ar.zip` | — | — | [details](bbcmc_ar.md) |
| `MACHINE=pro128s` | Prodest PC 128S | 1987 | `pro128s.zip` | — | — | [details](pro128s.md) |
| `MACHINE=electron` | Acorn Electron | 1983 | `electron.zip` | — | — | [details](electron.md) |
| `MACHINE=electront` | Acorn Electron (Trial) | 1983 | `electront.zip` | — | — | [details](electront.md) |
| `MACHINE=electron64` | Acorn Electron (64K Master RAM Board) | 1987 | `electron64.zip` | — | — | [details](electron64.md) |
| `MACHINE=electronsp` | Acorn Electron (Stop Press 64i) | 1991 | `electronsp.zip` | — | — | [details](electronsp.md) |
| `MACHINE=atom` | Atom | 1979 | `atom.zip` | — | — | [details](atom.md) |
| `MACHINE=atombbc` | Atom with BBC Basic | 1982 | `atombbc.zip` | — | — | [details](atombbc.md) |
| `MACHINE=prophet2` | Prophet 2 | 1983 | `prophet2.zip` | — | — | [details](prophet2.md) |

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
    └── prophet2.zip
```

`scripts/fetch-assets.sh` (see the [README](../../README.md#-fetching-them)) can fetch these for you — `make assets ASSETS=~/my-assets`.

[← back to the top-level README](../../README.md)
