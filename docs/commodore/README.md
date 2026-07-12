# Commodore

The Commodore 8-bit line — PET/CBM, VIC-20, C64, Plus/4, C128, and the
CBM-II business range — built on 6502-family CPUs. Public-tier only: no
free (properly-blessed-redistribution) ROM source exists for this line,
unlike Sinclair's Fuse/proteanthread permission. Each `make MACHINE=<name>`
below bakes one machine into its own `kernel8-<name>.img` — see the
[top-level README](../../README.md) for the build and the regional canvas.

## Machines

| `make` | System | Year | Romset | Extra assets | TV | |
|---|---|---|---|---|---|---|
| `MACHINE=c64` | Commodore 64 (NTSC) | 1982 | `c64.zip` | — | NTSC | [details](c64.md) |
| `MACHINE=c64p` | Commodore 64 (PAL) | 1982 | `c64p.zip` | — | PAL | [details](c64p.md) |
| `MACHINE=c64_jp` | Commodore 64 (Japan) | 1982 | `c64_jp.zip` | — | NTSC | [details](c64_jp.md) |
| `MACHINE=c64_se` | Commodore 64 (Sweden) | 1982 | `c64_se.zip` | — | PAL | [details](c64_se.md) |
| `MACHINE=c64c` | Commodore 64C (NTSC) | 1986 | `c64c.zip` | — | NTSC | [details](c64c.md) |
| `MACHINE=c64cp` | Commodore 64C (PAL) | 1986 | `c64cp.zip` | — | PAL | [details](c64cp.md) |
| `MACHINE=c64g` | Commodore 64G (PAL) | 1986 | `c64g.zip` | — | PAL | [details](c64g.md) |
| `MACHINE=c64c_es` | Commodore 64C (Spain) | 1988 | `c64c_es.zip` | — | PAL | [details](c64c_es.md) |
| `MACHINE=c64c_se` | Commodore 64C (Sweden/Finland) | 1986 | `c64c_se.zip` | — | PAL | [details](c64c_se.md) |
| `MACHINE=c64gs` | Commodore 64 Games System | 1990 | `c64gs.zip` | — | PAL | [details](c64gs.md) |
| `MACHINE=sx64` | SX-64 / Executive 64 (NTSC) | 1984 | `sx64.zip` | — | NTSC | [details](sx64.md) |
| `MACHINE=sx64p` | SX-64 / Executive 64 (PAL) | 1984 | `sx64p.zip` | — | PAL | [details](sx64p.md) |
| `MACHINE=dx64` | DX-64 (NTSC, twin-drive prototype) | 1984 | `dx64.zip` | — | NTSC | [details](dx64.md) |
| `MACHINE=vip64` | VIP-64 (Sweden/Finland SX-64) | 1984 | `vip64.zip` | — | PAL | [details](vip64.md) |
| `MACHINE=tesa6240` | Tesa Etikett Etikettendrucker 6240 | 1984 | `tesa6240.zip` | — | PAL | [details](tesa6240.md) |
| `MACHINE=pet64` | PET 64 / CBM 4064 (NTSC) | 1983 | `pet64.zip` | — | NTSC | [details](pet64.md) |
| `MACHINE=edu64` | Educator 64 (NTSC) | 1983 | `edu64.zip` | — | NTSC | [details](edu64.md) |

Click through to a machine's details page for its exact romset (CRC32 per
ROM) and what appears on the glass at power-on.

## Assets

```
my-assets/
└── roms/
    ├── c64.zip    # Commodore 64 (NTSC): basic + kernal r3 + chargen + PLA
    │               #   (901226-01.u3, 901227-03.u4, 901225-01.u5, 906114-01.u17)
    ├── c64p.zip   # Commodore 64 (PAL): same four ROMs as c64.zip
    │               #   (rom_c64p == rom_c64; only the timing is PAL)
    ├── c64_jp.zip # Commodore 64 (Japan): Japan-specific kernal + chargen
    │               #   (906145-02.u4, 906143-02.u5) + shared basic + PLA
    ├── c64_se.zip # Commodore 64 (Sweden): Swedish kernal + chargen
    │               #   (kernel.u4, charswe.u5) + shared basic + PLA
    ├── c64c.zip   # Commodore 64C (NTSC): combined basic+kernal in one
    │               #   16K part (251913-01.u4) + shared chargen + PLA
    ├── c64cp.zip  # Commodore 64C (PAL): same three ROMs as c64c.zip
    │               #   (rom_c64cp == rom_c64c; only the timing is PAL)
    ├── c64g.zip   # Commodore 64G (PAL): same three ROMs as c64c.zip
    │               #   (rom_c64g == rom_c64c; only the timing is PAL)
    ├── c64c_es.zip # Commodore 64C (Spain): Spanish chargen (325056-03.u5)
    │               #   + shared 64C combined ROM + PLA
    ├── c64c_se.zip # Commodore 64C (Sweden/Finland): own Swedish/Finnish
    │               #   KERNAL (325182-01.u4) + Scandinavian chargen
    │               #   ("cbm 64 skand.gen.u5") + shared PLA
    ├── c64gs.zip  # Commodore 64 Games System: own GS boot KERNAL
    │               #   (390852-01.u4) + shared C64/C64C chargen
    │               #   (901225-01.u5) + shared PLA
    ├── sx64.zip   # SX-64 / Executive 64 (NTSC): own SX boot KERNAL
    │               #   (251104-04.ud3) + shared basic, chargen and PLA
    │               #   (901226-01.ud4, 901225-01.ud1, 906114-01.ue4)
    ├── sx64p.zip  # SX-64 / Executive 64 (PAL): same four ROMs as sx64.zip
    │               #   (rom_sx64p == rom_sx64; only the timing is PAL)
    ├── dx64.zip   # DX-64 (NTSC, twin-drive prototype): same four ROMs as
    │               #   sx64.zip (rom_dx64 == rom_sx64; ntsc_dx just adds a
    │               #   second built-in drive on iec9)
    ├── vip64.zip  # VIP-64 (Sweden/Finland SX-64, PAL): own Swedish SX
    │               #   KERNAL (kernelsx.ud3) + Swedish chargen (charswe.ud1)
    │               #   + shared basic and PLA (901226-01.ud4, 906114-01.ue4)
    ├── tesa6240.zip # Tesa Etikett Etikettendrucker 6240 (PAL label printer):
    │               #   own bespoke basic + kernal + chargen (tesa-basic.ud4,
    │               #   tesa-kernal.ud3, tesa-char.ud1) + shared PLA
    │               #   (906114-01.ue4)
    ├── pet64.zip  # PET 64 / CBM 4064 (NTSC, green-screen education C64):
    │               #   own rev.1 KERNAL (901246-01.u4) + shared basic,
    │               #   chargen and PLA (901226-01.u3, 901225-01.u5,
    │               #   906114-01.u17)
    └── edu64.zip  # Educator 64 (NTSC, PET-cased education C64): #define
                    #   rom_edu64 rom_c64 — byte-identical c64 romset (basic,
                    #   kernal r3, chargen, PLA: 901226-01.u3, 901227-03.u4,
                    #   901225-01.u5, 906114-01.u17)
```

Only supplying some assets is fine: machines without their ROMs simply
won't run.

`scripts/fetch-assets.sh` (see the [README](../../README.md#-fetching-them))
can fetch these for you — `make assets ASSETS=~/my-assets`.

## Quirks

- **The IEC disk bus boots empty.** The driver defaults to a C1541 drive
  plugged into device 8; that drive's own ROM would be a second romset
  this appliance doesn't need to boot to BASIC. The kernel bakes
  `-iec8 ""` — a real C64 with nothing plugged into its serial port is a
  completely valid, common configuration, and needs no drive romset.

[← back to the top-level README](../../README.md)
