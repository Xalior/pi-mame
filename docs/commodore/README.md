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
| `MACHINE=vic20` | VIC-20 (NTSC) | 1981 | `vic20.zip` | — | NTSC | [details](vic20.md) |
| `MACHINE=vic20p` | VIC-20 / VC-20 (PAL) | 1981 | `vic20p.zip` | — | PAL | [details](vic20p.md) |
| `MACHINE=vic20_se` | VIC-20 (Sweden/Finland) | 1981 | `vic20_se.zip` | — | PAL | [details](vic20_se.md) |
| `MACHINE=vic1001` | VIC-1001 (Japan) | 1980 | `vic1001.zip` | — | NTSC | [details](vic1001.md) |
| `MACHINE=c264` | Commodore 264 (NTSC, prototype) | 1984 | `c264.zip` | — | NTSC | [details](c264.md) |
| `MACHINE=plus4` | Plus/4 (NTSC) | 1984 | `plus4.zip` | — | NTSC | [details](plus4.md) |
| `MACHINE=plus4p` | Plus/4 (PAL) | 1984 | `plus4p.zip` | — | PAL | [details](plus4p.md) |
| `MACHINE=c16` | Commodore 16 (NTSC) | 1984 | `c16.zip` | — | NTSC | [details](c16.md) |
| `MACHINE=c16p` | Commodore 16 (PAL) | 1984 | `c16p.zip` | — | PAL | [details](c16p.md) |
| `MACHINE=c116` | Commodore 116 | 1984 | `c116.zip` | — | PAL | [details](c116.md) |
| `MACHINE=c232` | Commodore 232 (PAL, prototype) | 1984 | `c232.zip` | — | PAL | [details](c232.md) |
| `MACHINE=v364` | Commodore V364 (NTSC, prototype) | 1984 | `v364.zip` | — | NTSC | [details](v364.md) |
| `MACHINE=c128` | Commodore 128 (NTSC) | 1985 | `c128.zip` | — | NTSC | [details](c128.md) |
| `MACHINE=c128p` | Commodore 128 (PAL) | 1985 | `c128p.zip` | — | PAL | [details](c128p.md) |
| `MACHINE=c128d` | Commodore 128D (NTSC, prototype) | 1986 | `c128d.zip` | — | NTSC | [details](c128d.md) |

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
    ├── edu64.zip  # Educator 64 (NTSC, PET-cased education C64): #define
    │               #   rom_edu64 rom_c64 — byte-identical c64 romset (basic,
    │               #   kernal r3, chargen, PLA: 901226-01.u3, 901227-03.u4,
    │               #   901225-01.u5, 906114-01.u17)
    ├── vic20.zip  # VIC-20 (NTSC): the first non-c64.cpp Commodore machine.
    │               #   Split-set clone of vic1001 — unique kernal + chargen
    │               #   from vic20.zip (901486-06.ue12, 901460-03.ud7), shared
    │               #   basic from the parent vic1001.zip (901486-01.ue11)
    ├── vic20p.zip # VIC-20 / VC-20 (PAL): the vic20p clone of the same driver.
    │               #   Unique PAL kernal from vic20p.zip (901486-07.ue12, -07
    │               #   vs NTSC's -06), chargen shared with vic20 (901460-03.ud7),
    │               #   shared basic from the parent vic1001.zip (901486-01.ue11)
    ├── vic20_se.zip # VIC-20 (Sweden/Finland, PAL): the vic20_se clone of the
    │               #   same driver, last of the VIC-20 family. Unique Nordic
    │               #   kernal + national chargen from vic20_se.zip (nec22081.206,
    │               #   nec22101.207 — its own character generator, not vic20's),
    │               #   shared basic from the parent vic1001.zip (901486-01.ue11)
    ├── vic1001.zip # VIC-1001 (Japan, NTSC): the family parent — self-contained
    │               #   romset, all three members in vic1001.zip (Japanese kernal
    │               #   901486-02, katakana chargen 901460-02, shared basic
    │               #   901486-01)
    ├── c264.zip   # Commodore 264 (NTSC, prototype): the TED/264 family PARENT
    │               #   (plus4.cpp, plus4_state). Self-contained romset — all three
    │               #   members in c264.zip (prototype basic-264.bin, kernal-264.bin,
    │               #   and the 251641-02 PLA the clones borrow back). No 3-PLUS-1
    │               #   function ROMs (unpopulated on the prototype). The only
    │               #   MACHINE_IMPERFECT_GRAPHICS entry in the family
    ├── plus4.zip  # Plus/4 (NTSC): the first machine off plus4.cpp, opening the
    │               #   TED/264 family. Split-set clone of the c264 prototype —
    │               #   unique r5 kernal, basic and the two 3-PLUS-1 function
    │               #   ROMs from plus4.zip (318005-05.u24, 318006-01.u23,
    │               #   317053-01.u25, 317054-01.u26), shared PLA from the parent
    │               #   c264.zip (251641-02.u19)
    ├── plus4p.zip # Plus/4 (PAL): the plus4p clone of the same plus4_state
    │               #   driver, PAL sibling of plus4. Split-set clone of the c264
    │               #   prototype — unique PAL r5 kernal from plus4p.zip
    │               #   (318004-05.u24, part 318004 vs the NTSC plus4's 318005),
    │               #   basic and the two 3-PLUS-1 function ROMs also from
    │               #   plus4p.zip (318006-01.u23, 317053-01.u25, 317054-01.u26),
    │               #   shared PLA from the parent c264.zip (251641-02.u19)
    ├── c16.zip    # Commodore 16 (NTSC): the cut-down 16K sibling on the same
    │               #   plus4.cpp TED/264 driver (c16_state). Split-set clone of
    │               #   the c264 prototype, and a subset of plus4 — the r5 kernal
    │               #   and basic (byte-identical to plus4's) from plus4.zip
    │               #   (318005-05.u24, 318006-01.u23), shared PLA from the parent
    │               #   c264.zip (251641-02.u19). No 3-PLUS-1 function ROMs — the
    │               #   C16 has none (12277 bytes free vs the Plus/4's 60671)
    ├── c16p.zip   # Commodore 16 (PAL): the PAL machine of that same 16K sibling
    │               #   (c16_state). Split-set clone of the c264 prototype, and a
    │               #   subset of plus4p — the PAL r5 kernal and basic (byte-
    │               #   identical to plus4p's) from plus4p.zip (318004-05.u4, part
    │               #   318004 vs the NTSC c16's 318005, 318006-01.u3), shared PLA
    │               #   from the parent c264.zip (251641-02.u16). No 3-PLUS-1
    │               #   function ROMs — the C16 has none (12277 bytes free)
    ├── c116.zip   # Commodore 116: the cost-reduced, rubber-key sibling of the C16
    │               #   on the same plus4.cpp TED/264 driver (c16_state, config
    │               #   c16p). ROM_START( c116 ) is byte-identical to c16p by
    │               #   checksum — same PAL r5 kernal, basic and PLA — differing
    │               #   only in the PLA member name (251641-02.u101 vs c16p's .u16).
    │               #   No 3-PLUS-1 function ROMs — the C116 has none (12277 bytes
    │               #   free)
    ├── c232.zip   # Commodore 232 (PAL, prototype): a pre-production 264-line
    │               #   prototype on the same plus4.cpp TED/264 driver (c16_state,
    │               #   config c232 = c16p with RAM raised to 32K). Split-set clone
    │               #   of the c264 prototype — its UNIQUE kernal 318004-01.u5
    │               #   (dbdc3319) and shared basic 318006-01.u4 come from c232.zip,
    │               #   the shared PLA from the parent c264.zip (251641-02.u7). No
    │               #   3-PLUS-1 function ROMs, but 32K RAM (28661 bytes free)
    ├── v364.zip   # Commodore V364 (NTSC, prototype): the LAST machine of the
    │               #   plus4.cpp TED/264 driver (c16_state, config v364 = the NTSC
    │               #   plus4n config plus a T6721A speech synthesiser). Split-set
    │               #   clone of the c264 prototype — its UNIQUE kernal kern364p
    │               #   (84fd4f7a) and UNIQUE speech ROM spk3cc4.bin (5227c2ee), with
    │               #   the shared basic 318006-01 and the full Plus/4 3-PLUS-1
    │               #   function pair 317053-01/317054-01, come from v364.zip; the
    │               #   shared PLA from the parent c264.zip (251641-02). Full 64K
    │               #   (60671 bytes free), with the 3-PLUS-1 suite
    ├── c128.zip   # Commodore 128 (NTSC): the FIRST machine of a NEW driver family
    │               #   (c128.cpp, c128_state, config c128) — dual-CPU (Z80 CP/M +
    │               #   8502 128/64 modes) sharing one kernal complement, no separate
    │               #   Z80 BIOS region. Self-contained family-parent romset: MAME's
    │               #   default BIOS is r4, so the shipped set is the always-loaded
    │               #   251913-01 (0010ec31), the r4 kernal triple 318018-04/318019-04/
    │               #   318020-05 (9f9c355b/6e2c91a7/ba456b8e), the 390059-01 chargen
    │               #   (6aaaafe6) and the 8721 PLA 8721r3.u11 (154db186, a MAME
    │               #   BAD_DUMP that loads and boots straight through). BASIC 7.0,
    │               #   122365 bytes free
    ├── c128p.zip  # Commodore 128 (PAL): the c128 family's PAL sibling (c128.cpp,
    │               #   config c128pal). Same six ROMs as c128.zip — the driver aliases
    │               #   the romset (rom_c128p == rom_c128); only the timing/canvas is
    │               #   PAL. BASIC 7.0, 122365 bytes free
    └── c128d.zip  # Commodore 128D (NTSC, prototype): a clone of c128 in the same
                    #   family (c128.cpp, config c128). The 128D is a 128 with a
                    #   built-in C1571 drive; the NTSC prototype is functionally an
                    #   NTSC 128. Same six ROMs as c128.zip — the driver aliases the
                    #   romset (rom_c128d == rom_c128). BASIC 7.0, 122365 bytes free
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
