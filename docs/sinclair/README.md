# Sinclair

The ZX Spectrum family: Sinclair's own machines, the Amstrad-era +2/+2a/+3,
the Kickstarter-era ZX Spectrum Next boards, the Timex NTSC variants, and
the Eastern Bloc clones (Russian, Polish) that grew their own firmware
around the same hardware. Each `make kernel MACHINE=<name>` below bakes one
machine into its own `kernel8-<name>.img` — see the [top-level
README](../../README.md) for the build and the regional canvas.

Prefer a download? Every [tagged release](https://github.com/Xalior/pi-mame/releases/latest)
ships this platform's ready-to-boot card (free and public tiers) and a
bare `kernel8-<machine>.img` for each machine below — see the [top-level
README](../../README.md#-download-a-ready-made-image). CI proves those
images compile; the table below is the hardware proof, one HDMI capture
per machine.

## Machines

| `make kernel` | System | Year | Romset | Extra assets | TV | |
|---|---|---|---|---|---|---|
| `MACHINE=spectrum` | 48K ZX Spectrum | 1982 | `spectrum.zip` | — | PAL | [details](spectrum.md) |
| `MACHINE=spec128` | ZX Spectrum 128 | 1986 | `spec128.zip` | — | PAL | [details](spec128.md) |
| `MACHINE=specpls2` | ZX Spectrum +2 | 1986 | `specpls2.zip` | — | PAL | [details](specpls2.md) |
| `MACHINE=specpl2a` | ZX Spectrum +2a | 1987 | `specpl2a.zip` | — | PAL | [details](specpl2a.md) |
| `MACHINE=specpls3` | ZX Spectrum +3 | 1987 | `specpls3.zip` | — | PAL | [details](specpls3.md) |
| `MACHINE=tbblue` | ZX Spectrum Next | 2017 | `tbblue.zip` | `next/next.img` | PAL | [details](tbblue.md) |
| `MACHINE=specnext_ks1` | ZX Spectrum Next, KS1 board (2020 Kickstarter) | 2020 | `tbblue.zip` (shared) | `next/next.img` | PAL | [details](specnext_ks1.md) |
| `MACHINE=specnext_ks2` | ZX Spectrum Next, KS2 board (2023 Kickstarter) | 2023 | `tbblue.zip` (shared) | `next/next.img` | PAL | [details](specnext_ks2.md) |
| `MACHINE=specnext_ks3` | ZX Spectrum Next, KS3 board (2025 Kickstarter) | 2025 | `tbblue.zip` (shared) | `next/next.img` | PAL | [details](specnext_ks3.md) |
| `MACHINE=zx80` | Sinclair ZX-80 | 1980 | `zx80.zip` | — | PAL | [details](zx80.md) |
| `MACHINE=zx81` | Sinclair ZX-81 | 1981 | `zx81.zip` | — | PAL | [details](zx81.md) |
| `MACHINE=tc2048` | Timex TC-2048 | 1984 | `tc2048.zip` | — | PAL | [details](tc2048.md) |
| `MACHINE=ts2068` | Timex Sinclair TS-2068 | 1983 | `ts2068.zip` | — | NTSC | [details](ts2068.md) |
| `MACHINE=ts1000` | Timex Sinclair TS-1000 | 1982 | `ts1000.zip` | — | NTSC | [details](ts1000.md) |
| `MACHINE=ts1500` | Timex Sinclair TS-1500 | 1983 | `ts1500.zip` | — | NTSC | [details](ts1500.md) |
| `MACHINE=pentagon` | Pentagon 128K | 1991 | `pentagon.zip` | `spec128.zip`, `betadisk.zip` | PAL | [details](pentagon.md) |
| `MACHINE=scorpio` | Scorpion ZS-256 | 1992 | `scorpio.zip` | `spec128.zip`, `betadisk.zip` | PAL | [details](scorpio.md) |
| `MACHINE=atmtb2` | MicroART ATM-Turbo 2 | 1992 | `atmtb2.zip` | `spec128.zip`, `betadisk.zip` | PAL | [details](atmtb2.md) |
| `MACHINE=pentevo` | ZX Evolution: BASECONF | 2009 | `pentevo.zip` | `spec128.zip`, `betadisk.zip` | PAL | [details](pentevo.md) |
| `MACHINE=tsconf` | ZX Evolution: TS-Configuration | 2011 | `tsconf.zip` | — | PAL | [details](tsconf.md) |
| `MACHINE=elwro800` | Elwro 800-3 Junior | 1986 | `elwro800.zip` | — | PAL | [details](elwro800.md) |
| `MACHINE=byte` | PEVM Byte | 1990 | `byte.zip` | — | PAL | [details](byte.md) |
| `MACHINE=sprinter` | Peters Plus Sprinter | 2000 | `sprinter.zip` | `kb_ms_natural.zip` | PAL | [details](sprinter.md) |

Click through to a machine's details page for its exact romset (CRC32 per
ROM) and what appears on the glass at power-on. Kernel sizes barely differ
per machine: every image carries every compiled driver, so all images are
currently around 85MB.

## Assets

```
my-assets/
├── roms/
│   ├── spectrum.zip     # 48K ZX Spectrum
│   ├── spec128.zip      # ZX Spectrum 128 (also the shared parent for
│   │                     #   pentagon, scorpio, atmtb2, and pentevo)
│   ├── specpls2.zip     # ZX Spectrum +2
│   ├── specpl2a.zip     # ZX Spectrum +2a
│   ├── specpls3.zip     # ZX Spectrum +3
│   ├── tbblue.zip       # ZX Spectrum Next (also specnext_ks1/ks2/ks3)
│   ├── zx80.zip         # Sinclair ZX-80
│   ├── zx81.zip         # Sinclair ZX-81
│   ├── tc2048.zip       # Timex TC-2048
│   ├── ts2068.zip       # Timex Sinclair TS-2068
│   ├── ts1000.zip       # Timex Sinclair TS-1000
│   ├── ts1500.zip       # Timex Sinclair TS-1500
│   ├── pentagon.zip     # Pentagon 128K (needs spec128.zip + betadisk.zip)
│   ├── scorpio.zip      # Scorpion ZS-256 (needs spec128.zip + betadisk.zip)
│   ├── atmtb2.zip       # MicroART ATM-Turbo 2 (needs spec128.zip + betadisk.zip)
│   ├── pentevo.zip      # ZX Evolution: BASECONF (needs spec128.zip + betadisk.zip)
│   ├── tsconf.zip       # ZX Evolution: TS-Configuration (self-contained)
│   ├── elwro800.zip     # Elwro 800-3 Junior (self-contained)
│   ├── byte.zip         # PEVM Byte (self-contained)
│   ├── sprinter.zip     # Peters Plus Sprinter (needs kb_ms_natural.zip)
│   ├── betadisk.zip     # Beta Disk / TR-DOS ROMs — shared by pentagon,
│   │                     #   scorpio, atmtb2, and pentevo
│   └── kb_ms_natural.zip # Microsoft Natural keyboard ROM — the sprinter's PS/2 keyboard device
└── next/
    └── next.img          # ZX Spectrum Next SD-card image (tbblue, specnext_ks1, specnext_ks2, specnext_ks3)
```

Only supplying some assets is fine: machines without their ROMs simply
won't run. `spec128.zip` and `betadisk.zip` are each a single file that
several machines share — put them on the card once.

`scripts/fetch-assets.sh` (see the [README](../../README.md#-fetching-them))
can fetch these for you — `make assets ASSETS=~/my-assets`.

## Quirks

- **The Next needs `next.img`.** `tbblue`, `specnext_ks1`, `specnext_ks2`,
  and `specnext_ks3` all boot NextZXOS from `next/next.img` (distributed by
  the [Spectrum Next project](https://www.specnext.com/latestdistro/)),
  attached as the machine's hard disk. `specnext_ks1` and `specnext_ks2`
  are ROM-compatible clones of `tbblue` and read `tbblue.zip` directly;
  `specnext_ks3`'s trimmed BIOS list names only files `tbblue.zip` already
  carries.
- **The Russian clones share `betadisk.zip`.** `pentagon`, `scorpio`,
  `atmtb2`, and `pentevo` are each a MAME clone of `spec128`: their own zip
  carries only the clone's ROMs, `spec128.zip` supplies the shared 128
  ROMs, and their built-in Beta Disk / TR-DOS interface reads
  `betadisk.zip`.
- **The Timex NTSC machines fill a different canvas.** `ts2068`, `ts1000`,
  and `ts1500` are the 60Hz American Sinclair/Timex machines — they use
  `cmdline-ntsc.txt`'s 720×480 canvas, not the 720×576 PAL canvas every
  other Sinclair machine fills.

[← back to the top-level README](../../README.md)
