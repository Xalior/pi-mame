# BBC Micro Model B

![BBC Micro Model B at power-on](images/bbcb.jpg)

- **`make kernel MACHINE=bbcb`** — Acorn
- **Year**: 1981
- **Manufacturer**: Acorn Computers

## At power-on

**PARKED** — stops at MAME's known-problems box (imperfectly emulated graphics). The capture above shows the observed stop; the machine is not offered until the park is lifted by a policy ruling.

## Required assets

- `roms/bbcb.zip`

  | ROM | CRC32 |
  |---|---|
  | `os12.rom` | `3c14fc70` |
  | `os10.rom` | `9679b8f8` |
  | `os092.rom` | `59ef7eb8` |
  | `os01.rom` | `45ee0980` |
  | `basic2.rom` | `79434781` |
  | `basic1.rom` | `b3364108` |
  | `cm62024.bin` | `98e1bf9e` |
- `roms/bbc_acorn8271.zip`
- `roms/saa5050.zip`

## Notes

- MAME driver: `bbcb.cpp`.

[← back to Acorn](README.md)
