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

Click through to a machine's details page for its exact romset (CRC32 per
ROM) and what appears on the glass at power-on.

## Assets

```
my-assets/
└── roms/
    ├── c64.zip    # Commodore 64 (NTSC): basic + kernal r3 + chargen + PLA
    │               #   (901226-01.u3, 901227-03.u4, 901225-01.u5, 906114-01.u17)
    └── c64p.zip   # Commodore 64 (PAL): same four ROMs as c64.zip
                    #   (rom_c64p == rom_c64; only the timing is PAL)
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
