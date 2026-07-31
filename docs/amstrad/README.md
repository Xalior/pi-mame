# Amstrad

The Amstrad CPC family — the classic range, the cartridge-booting Plus range and its GX4000 console, and the East German clone — plus another Amstrad-badged machine built on different hardware: the PC1512, Amstrad's 8086 IBM PC-compatible. Each `make kernel MACHINE=<name>` below bakes one machine into its own `kernel8-<name>.img` — see the [top-level README](../../README.md) for the build and the regional canvas.

Prefer a download? Every [tagged release](https://github.com/Xalior/pi-mame/releases/latest) carries a ready-to-boot card and a binary per platform — see [Download a ready-made image](../../README.md#-download-a-ready-made-image) in the top-level README. CI proves every release compiles; the table below is the hardware proof, one HDMI capture per machine.

## Machines

| `make kernel` | System | Year | Romset | Extra assets | TV | |
|---|---|---|---|---|---|---|
| `MACHINE=cpc464` | Amstrad CPC464 | 1984 | `cpc464.zip` | — | PAL | [details](cpc464.md) |
| `MACHINE=cpc664` | Amstrad CPC664 | 1985 | `cpc664.zip` | — | PAL | [details](cpc664.md) |
| `MACHINE=cpc6128` | Amstrad CPC6128 | 1985 | `cpc6128.zip` | — | PAL | [details](cpc6128.md) |
| `MACHINE=cpc464p` | Amstrad CPC464+ | 1990 | — (empty) | `sysukpd.bin` | PAL | [details](cpc464p.md) |
| `MACHINE=cpc6128p` | Amstrad CPC6128+ | 1990 | — (empty) | `sysukpd.bin` | PAL | [details](cpc6128p.md) |
| `MACHINE=gx4000` | Amstrad GX4000 | 1990 | — (empty) | `sysukpd.bin` | PAL | [details](gx4000.md) |
| `MACHINE=kccomp` | KC Compact | 1989 | `kccomp.zip` | — | PAL | [details](kccomp.md) |
| `MACHINE=pc1512` | PC1512 SD | 1986 | `pc1512.zip` | `pc1512kb.zip` | NTSC | [details](pc1512.md) |

Click through to a machine's details page for its exact romset (CRC32 per ROM).

## Assets

```
my-assets/
├── roms/
│   ├── cpc464.zip
│   ├── cpc664.zip
│   ├── cpc6128.zip
│   ├── kccomp.zip
│   ├── pc1512.zip
│   └── pc1512kb.zip
└── carts/
    └── sysukpd.bin
```

`pc1512kb.zip` shared by every machine above:

  | ROM | CRC32 |
  |---|---|
  | `40042.ic801` | `607edaf6` |

`sysukpd.bin` shared by every machine above:

  | ROM | CRC32 |
  |---|---|
  | `sysukpd.bin` | `e9c5e30e` |

`scripts/fetch-assets.sh` (see the [README](../../README.md#-fetching-them)) can fetch these for you — `make assets ASSETS=~/my-assets`.

## Quirks

- **The CPC+ range boots from the baked cart.** `cpc464p`, `cpc6128p`, and
  `gx4000` have empty romsets — no zip, because the Plus firmware lives on
  the cartridge itself. These images bake `-cart /carts/sysukpd.bin`, the
  game-free Locomotive BASIC + ParaDOS homebrew cart (MAME softlist entry
  `sysukpd`: `engpados.bin`, renamed `sysukpd.bin`), which you supply like
  every other asset. Other carts load through MAME's UI at runtime
  (Scroll Lock → Tab → file manager).
- **The GX4000 halts at the sign-on.** The keyboard-less console does not
  drop into BASIC; with the default cart it renders the sign-on and awaits
  a game cart. That is its correct power-on state.
- **The NC100 and NC200 are parked and are not built.** Both notepads are
  withdrawn from this platform: their emulated real-time clock does not
  survive a power cycle. The machine comes back to its main menu with its
  saved memory intact, but the clock reads 1 January 1990, 00:00. For a
  diary and clock organiser that is not shippable. Their pages remain as
  [nc100.md](nc100.md) and [nc200.md](nc200.md) for the record.

[← back to the top-level README](../../README.md)
