# Lynx 96k

![Lynx 96k at power-on](images/lynx96k.jpg)

- **`make kernel MACHINE=lynx96k`** — Camputers
- **Year**: 1983
- **Manufacturer**: Camputers

## At power-on

`Lynx 96k` at power-on on the real board — see the capture above.

## Required assets

- `roms/lynx96k.zip`

  | ROM | CRC32 |
  |---|---|
  | `lynx9646.ic46` | `f86c5514` |
  | `lynx9645.ic45` | `f596b9a3` |
  | `lynx9644.ic44` | `4b96b0de` |
  | `skorprom.ic44` | `698d3de9` |
  | `danish96k3.ic44` | `795c22ea` |
  | `dosrom.rom` | `011e106a` |

## Notes

- MAME driver: `camplynx.cpp`.
- MAME clone of `lynx48k` (Lynx 48k) — the system macro's parent field in the driver source. The ROM table above lists every member this machine's own zip needs.

[← back to Camputers](README.md)
