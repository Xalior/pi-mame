# Amstrad

The Amstrad CPC family — the classic range, the cartridge-booting Plus
range and its GX4000 console, and the East German clone — plus two other
Amstrad-badged machines built on different hardware: the NC notepad
organisers and the PC1512, Amstrad's 8086 IBM PC-compatible. Each
`make MACHINE=<name>` below bakes one machine into its own
`kernel8-<name>.img` — see the [top-level README](../../README.md) for the
build and the regional canvas.

## Machines

| `make` | System | Year | Romset | Extra assets | TV | |
|---|---|---|---|---|---|---|
| `MACHINE=cpc464` | Amstrad CPC464 | 1984 | `cpc464.zip` | — | PAL | [details](cpc464.md) |
| `MACHINE=cpc664` | Amstrad CPC664 | 1985 | `cpc664.zip` | — | PAL | [details](cpc664.md) |
| `MACHINE=cpc6128` | Amstrad CPC6128 | 1985 | `cpc6128.zip` | — | PAL | [details](cpc6128.md) |
| `MACHINE=cpc464p` | Amstrad CPC464+ | 1990 | — (empty) | `carts/sysukpd.bin` | PAL | [details](cpc464p.md) |
| `MACHINE=cpc6128p` | Amstrad CPC6128+ | 1990 | — (empty) | `carts/sysukpd.bin` | PAL | [details](cpc6128p.md) |
| `MACHINE=gx4000` | Amstrad GX4000 | 1990 | — (empty) | `carts/sysukpd.bin` | PAL | [details](gx4000.md) |
| `MACHINE=kccomp` | KC Compact | 1989 | `kccomp.zip` | — | PAL | [details](kccomp.md) |
| `MACHINE=nc100` | Amstrad NC100 | 1992 | `nc100.zip` | — | PAL | [details](nc100.md) |
| `MACHINE=nc200` | Amstrad NC200 | 1993 | `nc200.zip` | — | PAL | [details](nc200.md) |
| `MACHINE=pc1512` | Amstrad PC1512 SD | 1986 | `pc1512.zip` | `pc1512kb.zip` | PAL | [details](pc1512.md) |

Click through to a machine's details page for its exact romset (CRC32 per
ROM) and what appears on the glass at power-on. Kernel sizes barely differ
per machine: every image carries every compiled driver, so all images are
currently around 85MB.

## Assets

```
my-assets/
├── roms/
│   ├── cpc464.zip    # Amstrad CPC464 (self-contained: the 32K OS + Locomotive BASIC ROM)
│   ├── cpc664.zip    # Amstrad CPC664 (self-contained: its own 32K OS + BASIC 1.1 + 16K AMSDOS ROM)
│   ├── cpc6128.zip   # Amstrad CPC6128 (self-contained: its own 32K OS + BASIC 1.1 + 16K AMSDOS ROM)
│   ├── kccomp.zip    # KC Compact (self-contained: its own 32K OS + BASIC 1.1 + colour PROM)
│   ├── nc100.zip     # Amstrad NC100 (self-contained: its own 256K organiser firmware ROM)
│   ├── nc200.zip     # Amstrad NC200 (self-contained: its own 512K organiser firmware ROM)
│   ├── pc1512.zip    # Amstrad PC1512 SD (self-contained for its BIOS)
│   └── pc1512kb.zip  # PC1512's keyboard-controller ROM — a separate MAME device set
└── carts/
    └── sysukpd.bin   # the CPC+ default cartridge (cpc464p, cpc6128p, gx4000)
                      #   — Locomotive BASIC + ParaDOS
```

Only supplying some assets is fine: machines without their ROMs simply
won't run.

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
- **The NC machines are stretched LCDs.** `nc100` and `nc200` each carry a
  built-in monochrome LCD (480×64 and 480×128 respectively) rather than a
  TV output; both are stretched to fill the PAL canvas the way every other
  PAL machine here is.

[← back to the top-level README](../../README.md)
