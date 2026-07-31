# Sinclair

The ZX Spectrum family: Sinclair's own machines, the Amstrad-era +2/+2a/+3, the Kickstarter-era ZX Spectrum Next boards, the Timex NTSC variants, and the Eastern Bloc clones (Russian, Polish) that grew their own firmware around the same hardware. Each `make kernel MACHINE=<name>` below bakes one machine into its own `kernel8-<name>.img` — see the [top-level README](../../README.md) for the build and the regional canvas.

Prefer a download? Every [tagged release](https://github.com/Xalior/pi-mame/releases/latest) carries a ready-to-boot card and a binary per platform — see [Download a ready-made image](../../README.md#-download-a-ready-made-image) in the top-level README. CI proves every release compiles; the table below is the hardware proof, one HDMI capture per machine.

## Machines

| `make kernel` | System | Year | Romset | Extra assets | TV | |
|---|---|---|---|---|---|---|
| `MACHINE=spectrum` | ZX Spectrum | 1982 | `spectrum.zip` | — | PAL | [details](spectrum.md) |
| `MACHINE=spec128` | ZX Spectrum 128 | 1986 | `spec128.zip` | — | PAL | [details](spec128.md) |
| `MACHINE=specpls2` | ZX Spectrum +2 | 1986 | `specpls2.zip` | — | PAL | [details](specpls2.md) |
| `MACHINE=specpl2a` | ZX Spectrum +2a | 1987 | `specpl2a.zip` | — | PAL | [details](specpl2a.md) |
| `MACHINE=specpls3` | ZX Spectrum +3 | 1987 | `specpls3.zip` | — | PAL | [details](specpls3.md) |
| `MACHINE=tbblue` | ZX Spectrum Next: Emulators ID | 2017 | `tbblue.zip` | `next.img` | PAL | [details](tbblue.md) |
| `MACHINE=specnext_ks1` | ZX Spectrum Next: KS1 | 2020 | `specnext_ks1.zip` | `tbblue.zip`, `next.img` | PAL | [details](specnext_ks1.md) |
| `MACHINE=specnext_ks2` | ZX Spectrum Next: KS2 | 2023 | `specnext_ks2.zip` | `tbblue.zip`, `next.img` | PAL | [details](specnext_ks2.md) |
| `MACHINE=specnext_ks3` | ZX Spectrum Next: KS3 | 2025 | `specnext_ks3.zip` | `tbblue.zip`, `next.img` | PAL | [details](specnext_ks3.md) |
| `MACHINE=zx80` | ZX-80 | 1980 | `zx80.zip` | — | PAL | [details](zx80.md) |
| `MACHINE=zx81` | ZX-81 | 1981 | `zx81.zip` | — | PAL | [details](zx81.md) |
| `MACHINE=tc2048` | TC-2048 | 1984 | `tc2048.zip` | — | PAL | [details](tc2048.md) |
| `MACHINE=ts2068` | TS-2068 | 1983 | `ts2068.zip` | — | NTSC | [details](ts2068.md) |
| `MACHINE=ts1000` | Timex Sinclair 1000 | 1982 | `ts1000.zip` | — | PAL | [details](ts1000.md) |
| `MACHINE=ts1500` | Timex Sinclair 1500 | 1983 | `ts1500.zip` | — | PAL | [details](ts1500.md) |
| `MACHINE=pentagon` | Pentagon 128K | 1991 | `pentagon.zip` | `betadisk.zip` | PAL | [details](pentagon.md) |
| `MACHINE=scorpio` | Scorpion ZS-256 (Yellow PCB) | 1992 | `scorpio.zip` | `betadisk.zip` | PAL | [details](scorpio.md) |
| `MACHINE=atmtb2` | ATM-Turbo 2 | 1992 | `atmtb2.zip` | `betadisk.zip` | PAL | [details](atmtb2.md) |
| `MACHINE=pentevo` | ZX Evolution: BASECONF | 2009 | `pentevo.zip` | `betadisk.zip` | PAL | [details](pentevo.md) |
| `MACHINE=tsconf` | ZX Evolution: TS-Configuration | 2011 | `tsconf.zip` | — | PAL | [details](tsconf.md) |
| `MACHINE=elwro800` | 800-3 Junior | 1986 | `elwro800.zip` | — | PAL | [details](elwro800.md) |
| `MACHINE=byte` | PEVM Byte | 1990 | `byte.zip` | — | PAL | [details](byte.md) |
| `MACHINE=sprinter` | Sprinter Sp2000 | 2000 | `sprinter.zip` | `kb_ms_natural.zip` | PAL | [details](sprinter.md) |

Click through to a machine's details page for its exact romset (CRC32 per ROM).

## Assets

```
my-assets/
├── roms/
│   ├── spectrum.zip
│   ├── spec128.zip
│   ├── specpls2.zip
│   ├── specpl2a.zip
│   ├── specpls3.zip
│   ├── tbblue.zip
│   ├── specnext_ks1.zip
│   ├── specnext_ks2.zip
│   ├── specnext_ks3.zip
│   ├── zx80.zip
│   ├── zx81.zip
│   ├── tc2048.zip
│   ├── ts2068.zip
│   ├── ts1000.zip
│   ├── ts1500.zip
│   ├── pentagon.zip
│   ├── scorpio.zip
│   ├── atmtb2.zip
│   ├── pentevo.zip
│   ├── tsconf.zip
│   ├── elwro800.zip
│   ├── byte.zip
│   ├── sprinter.zip
│   ├── betadisk.zip
│   └── kb_ms_natural.zip
└── next/
    └── next.img
```

`betadisk.zip` shared by every machine above:

  | ROM | CRC32 |
  |---|---|
  | `trd501.rom` | `3e3cdd4c` |
  | `trd503,a.rom` | `c43d717f` |
  | `trd503,a2.rom` | `121889b0` |
  | `trd503,a3.rom` | `1c5a25b1` |
  | `trd503,a4.rom` | `c2387608` |
  | `trd503.rom` | `10751aba` |
  | `trd503all.rom` | `4c0187ab` |
  | `trd503aut.rom` | `7ff90178` |
  | `trd503beta3.rom` | `561662f2` |
  | `trd503beta4.rom` | `23dbc387` |
  | `trd503ext.rom` | `abb139e7` |
  | `trd503kay.rom` | `77baccbb` |
  | `trd503m.rom` | `2f97fe06` |
  | `trd503xbios.rom` | `8be427cc` |
  | `trd503zxvgs.rom` | `b90ee684` |
  | `trd504-1.rom` | `da170c65` |
  | `trd504.rom` | `ba310874` |
  | `trd5043.rom` | `165d5ef8` |
  | `trd504em,a.rom` | `fcbf11e8` |
  | `trd504em.rom` | `0d3f8b43` |
  | `trd504f.rom` | `ab3100d8` |
  | `trd504m.rom` | `2f2cb630` |
  | `trd504s.rom` | `c5ca0423` |
  | `trd504s2.rom` | `1e9b59aa` |
  | `trd504s3.rom` | `1fe1d003` |
  | `trd504s4.rom` | `522ebbd6` |
  | `trd504t.rom` | `e212d1e0` |
  | `trd504tb2.rom` | `8d943e6b` |
  | `trd504tm.rom` | `2334b8c6` |
  | `trd505,a.rom` | `03b76c8f` |
  | `trd505,a2.rom` | `a102e726` |
  | `trd505.rom` | `fdff3810` |
  | `trd505d.rom` | `31e4be08` |
  | `trd505h.rom` | `9ba15549` |
  | `trd512.rom` | `b615d6c4` |
  | `trd512f.rom` | `edb74f8c` |
  | `trd513f.rom` | `6b1c17f3` |
  | `trd513fm.rom` | `bad0c0a0` |
  | `trd513p.rom` | `eb3196fe` |
  | `trd5613.rom` | `d66cda49` |
  | `trd56661.rom` | `8528c789` |
  | `trd5666hte.rom` | `03841161` |
  | `trd604.rom` | `d8882a8c` |
  | `trd604m.rom` | `e73394cb` |
  | `trd605e-2.rom` | `a064b7f2` |
  | `trd605e-3.rom` | `cff3d06b` |
  | `trd605e.rom` | `56d3c2db` |
  | `trd605h.rom` | `53bb1b4a` |
  | `trd605r.rom` | `f8816a47` |
  | `trd606h.rom` | `6b44fdd7` |
  | `trd607m.rom` | `5a062f03` |
  | `trd608-2.rom` | `3541b280` |
  | `trd608-3.rom` | `d3e91d69` |
  | `trd608.rom` | `5c998d53` |
  | `trd609.rom` | `91028924` |
  | `trd609e.rom` | `46312c8c` |
  | `trd610e.rom` | `95395ca4` |
  | `trd701.rom` | `47f39c0d` |

`kb_ms_natural.zip` shared by every machine above:

  | ROM | CRC32 |
  |---|---|
  | `natural.bin` | `aa8243ab` |

`scripts/fetch-assets.sh` (see the [README](../../README.md#-fetching-them)) can fetch these for you — `make assets ASSETS=~/my-assets`.

## Quirks

- **The Next needs `next.img`.** `tbblue`, `specnext_ks1`, `specnext_ks2`,
  and `specnext_ks3` all boot NextZXOS from `next/next.img` (distributed by
  the [Spectrum Next project](https://www.specnext.com/latestdistro/)),
  attached as the machine's hard disk. `specnext_ks1`, `specnext_ks2`, and
  `specnext_ks3` are each a MAME clone of `tbblue` with their own
  board-specific romset, and each also needs `tbblue.zip` on the card
  alongside its own.
- **The Russian clones share `betadisk.zip`.** `pentagon`, `scorpio`,
  `atmtb2`, and `pentevo` are each a MAME clone of `spec128`, but each
  carries its own complete, self-contained romset — nothing is borrowed
  from `spec128.zip`. What they do share is their built-in Beta Disk /
  TR-DOS interface, which reads `betadisk.zip`.
- **The Timex machines are NTSC, but their card is not.** `ts2068`,
  `ts1000`, and `ts1500` are the 60Hz American Sinclair/Timex machines.
  Every card built today uses the 720×576 PAL canvas, these included;
  giving them `cmdline-ntsc.txt`'s 720×480 canvas is work still to come.

[← back to the top-level README](../../README.md)
