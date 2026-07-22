# BBC Master Compact (Arabic)

- **`make kernel MACHINE=bbcmc_ar`** — Acorn
- **Year**: 1986
- **Manufacturer**: Acorn Computers

## At power-on

Built into the platform kernel, awaiting hardware verification — no boot capture yet, so no boot behaviour is claimed here.

## Required assets

- `roms/bbcmc_ar.zip`

  | ROM | CRC32 |
  |---|---|
  | `mos511.ic49` | `8708803c` |
  | `international16.rom` | `0ef527b1` |
  | `arabian-c22.rom` | `4f3aadff` |

## Notes

- MAME driver: `bbcmc.cpp`.
- MAME clone of `bbcmc` (BBC Master Compact) — the system macro's parent field in the driver source. The ROM table above lists every member this machine's own zip needs.

[← back to Acorn](README.md)
