# The patchable-defaults ABI

Every pi-mame kernel image — a single-machine `kernel8-<machine>.img`, a
platform's no-options `kernel8-<platform>.img`, or a platform card's
`pi-mame-rpi4.img` — carries a small patchable block at a fixed offset.
Writing to it is how "which machine, and what media" gets baked into an
image without a rebuild: the build system does it once at packaging time,
and the boot picker does it again at boot, patching the same bytes by the
same rule. This page is for anyone writing their own tool against that
block — a menu, a launcher, a TFTP dev chainloader, anything that needs to
read or write a pi-mame image before it runs.

The single source of truth is `boot-picker/defaultsblock.h`; every field
and offset below is read from it and cross-checked against a real shipped
image.

## The block

```
image offset 0x800   (runtime address MEM_KERNEL_START + 0x800 = 0x80800)

  +0x00  char  Magic[4]    'P','M','8','D'
  +0x04  u16   Capacity    bytes available in Text[]
  +0x06  u16   Length      bytes used in Text[], excluding the NUL
  +0x08  char  Text[512]   NUL-terminated argv string
```

- **Offset**: `0x800` into the image file. AArch64 kernel images load at
  `MEM_KERNEL_START` (`0x80000`), so the block's runtime address is
  `0x80800`.
- **Magic**: the four bytes `'P'`, `'M'`, `'8'`, `'D'` (ASCII "PM8D"),
  the seatbelt every reader and writer checks before touching anything
  else at the offset.
- **Capacity**: a little-endian `u16`, the number of bytes available in
  `Text[]`. The first ABI revision ships `512` (`DEFAULTS_BUFFER_BYTES`
  in the header) but a writer must read this field rather than assume
  the constant — it is the block's own declared size, and lets the
  buffer grow in a future image without every tool needing to change in
  lockstep.
- **Length**: a little-endian `u16`, the number of bytes used in `Text[]`
  excluding the terminating NUL. This is the writer's convenience field,
  not the authority — see the receiver contract below.
- **Text**: a NUL-terminated plain-text string, up to `Capacity` bytes
  including the NUL.

The struct is declared `PACKED` (`circle/macros.h`'s packing attribute):
there is no padding between fields, and the layout above is exact.
Everything is little-endian, matching AArch64.

The struct's `sizeof` is `4 + 2 + 2 + 512 = 520` bytes, so a valid image
must be at least `0x800 + 520` bytes long before any writer may
dereference the block.

### Verified against a shipped image

`host/kernel8-c64.img`, bytes at offset `0x800`:

```
00000800: 504d 3844 0002 0c00 6336 3420 2d69 6563  PM8D....c64 -iec
00000810: 3820 2222 0000 0000 0000 0000 0000 0000  8 ""............
```

`PM8D` at `+0x00`; `Capacity` bytes `00 02` (little-endian `0x0200` =
512); `Length` bytes `0c 00` (little-endian `0x000c` = 12, the length of
`c64 -iec8 ""`); `Text` from `+0x08` holding exactly that string, NUL
padded to the end of the 512-byte buffer.

The image's first four bytes are the entry trampoline, not part of the
block:

```
00000000: 8202 0014 0000 0000 0000 0000 0000 0000
```

`14000282` (little-endian) is an AArch64 `b` (unconditional branch)
instruction. It is the image's very first instruction — a `b _start`
branch over the reserved boot furniture and the defaults block at
`0x800`, landing on Circle's own `_start`. This is what lets the block
occupy fixed, addressable space near the head of the image without
displacing Circle's startup contract: whatever else lives between the
trampoline and `_start`, the entry point always executes that one branch
first.

## Writer contract

Any tool that patches an image before it boots must follow this contract
(`boot-picker/defaultsblock.cpp`, the one implementation every writer
calls):

1. **Verify the magic at the offset before writing a single byte.** If
   the four bytes at image offset `0x800` are not exactly `PM8D`, refuse
   — this is not a pi-mame image (or its layout has changed), and
   stamping text there would corrupt whatever actually lives at that
   offset.
2. **Read the block's own `Capacity` field and enforce against it** —
   never assume 512. If the string plus its terminating NUL would not
   fit in `Capacity` bytes, refuse.
3. **Write the string NUL-terminated** into `Text[]`, and set `Length` to
   the string's byte length (excluding the NUL).

The reference writers, both compiling the identical
`boot-picker/defaultsblock.cpp`:

- **`host/patch-defaults`** (built from `host/patch-defaults.cpp`) — the
  host-side tool the build system uses to turn one platform binary into
  a per-machine `kernel8-<machine>.img` by patching in that machine's
  defaults string. It also has a read-back mode (`patch-defaults -r
  <image>`) that prints the current `Capacity`, `Length`, and `Text` of
  an image's block. An empty string clears the block back to booting
  MAME's own system list.
- **The boot picker's in-memory patch** (`boot-picker/kernel.cpp`,
  `CKernel::BootSelection`) — the same `PatchDefaults()` call, run
  against the platform image staged in RAM after a menu pick, immediately
  before chain-booting it.

A third existence proof, mentioned for completeness: a TFTP dev
chainloader used during development injects a defaults string into a
kernel image over the wire before booting it, using this same contract.
It is bench tooling, not part of this repository's build or card layout.

## Receiver contract

What a patched (or unpatched) image does with the block at boot
(`host/defaults.cpp`, `DefaultsBuildArgv()`):

1. **The magic is verified at the ABI offset first**, read at runtime
   address `MEM_KERNEL_START + 0x800`, never through a linker symbol —
   this way a relocated or corrupted block is caught the same way a
   writer would catch it. If the magic is absent or wrong, the block is
   ignored entirely and MAME boots its own system-selection list.
2. **The text is bounded by `Capacity` and terminated at its first
   NUL.** `Length` is the writer's convenience field, not the authority
   the receiver trusts — a reader that only reads `Length` bytes could
   under-read a writer that got `Length` wrong; the receiver instead
   copies up to `Capacity` bytes and then treats the first NUL as the
   end of the string.
3. **The text is tokenised** using the same grammar a menu author writes
   (see [bootmenu.md](bootmenu.md#the-defaults-string-grammar)):
   whitespace-separated tokens, double quotes group embedded whitespace
   into one token and are stripped, and `""` yields an empty argv entry.
4. **The `--rapi-*` namespace belongs to the kernel.** Any token starting
   `--rapi-` is consumed here and never reaches MAME's argv; everything
   else is appended to MAME's argv, where MAME's own CLI frontend parses
   it.

An unpatched image (the block still holding its zero-length default) is
therefore not a special case — it takes the same "empty string" branch as
a deliberately-cleared block, and boots MAME's own system list.

## Worked example

Reading and patching the block needs nothing beyond basic binary file
I/O. This reads a block, then writes a new machine string into it,
using the offsets derived from the struct above (`Capacity` at `+0x04`,
`Length` at `+0x06`, `Text` at `+0x08`):

```sh
# Read the magic and the current text (xxd, read-only, no dd needed).
xxd -l 8 -s 0x800 kernel8-c64.img
xxd -l 512 -s 0x808 kernel8-c64.img | head -1
```

```python
#!/usr/bin/env python3
import struct, sys

OFFSET   = 0x800
CAPACITY_OFF = OFFSET + 4
LENGTH_OFF   = OFFSET + 6
TEXT_OFF     = OFFSET + 8

def patch(path, text):
    data = bytearray(open(path, "rb").read())

    magic = bytes(data[OFFSET:OFFSET + 4])
    if magic != b"PM8D":
        sys.exit(f"{path}: no PM8D magic at 0x{OFFSET:x} — not a pi-mame image")

    capacity = struct.unpack_from("<H", data, CAPACITY_OFF)[0]
    encoded = text.encode("ascii") + b"\x00"
    if len(encoded) > capacity:
        sys.exit(f"{path}: string too long ({len(encoded)} bytes, capacity {capacity})")

    data[TEXT_OFF:TEXT_OFF + len(encoded)] = encoded
    struct.pack_into("<H", data, LENGTH_OFF, len(encoded) - 1)  # excludes the NUL

    with open(path, "r+b") as f:
        f.seek(OFFSET)
        f.write(data[OFFSET:TEXT_OFF + capacity])

if __name__ == "__main__":
    patch(sys.argv[1], sys.argv[2])
```

```sh
python3 patch.py kernel8-c64.img 'c64 -iec8 ""'
```

This is exactly what `host/patch-defaults` and the boot picker do in
C++: verify the magic, enforce `Capacity`, write `Text` NUL-terminated,
update `Length`. Any language that can seek and write a file (or a RAM
image before jumping to it) can implement a pi-mame defaults writer.
