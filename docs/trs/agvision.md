# AgVision

![AgVision at power-on](images/agvision.jpg)

- **`make kernel MACHINE=agvision`** — TRS / Tandy
- **Year**: 1979
- **Manufacturer**: Elanco

## At power-on

**PARKED** — stops at MAME's known-problems box (MACHINE_NO_SOUND_HW, "expected behavior" wording); box held across two grabs 15s apart. Box=park rule applies regardless of the box's own wording. The capture above shows the observed stop; the machine is not offered until the park is lifted by a policy ruling.

## Required assets

- `roms/agvision.zip`

  | ROM | CRC32 |
  |---|---|
  | `8041716-1.1-agvision.u13` | `5b11b13e` |

## Notes

- MAME driver: `agvision.cpp`.

[← back to TRS / Tandy](README.md)
