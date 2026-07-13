# The patchable-defaults ABI

Every pi-mame kernel image — a single-machine `kernel8-<machine>.img`, a
platform's no-options `kernel8-<platform>.img`, or a platform card's
`pi-mame-core-rpi4.img` — carries a small patchable block at image offset
`0x800`. Writing to it is how "which machine, and what media" gets baked into
an image without a rebuild: the build system does it once at packaging time,
and the boot picker does it again at boot, patching the same bytes by the same
rule.

## The protocol is owned by rapi-bootloader

The block's layout, magic, and writer contract are **defined and owned by the
[rapi-bootloader](https://github.com/Xalior/rapi-bootloader) project** — the
building block that owns the ABI both loaders and the build system write
through. That is the single source of truth; this page does not restate it:

- **[The 0x800 defaults-block ABI](https://github.com/Xalior/rapi-bootloader#the-0x800-defaults-block-abi)**
  — the authoritative field table (`Magic` / `Capacity` / `Length` / `Text` at
  offset `0x800`) and the writer contract: verify the `PM8D` magic before
  writing a byte, enforce the block's own `Capacity`, write `Text`
  NUL-terminated.
- **`rapi-bootloader/defaultsblock/`** (`defaultsblock.h`, `defaultsblock.cpp`)
  — the one reference implementation, `PatchDefaults()`, that every writer
  calls: the build system's `host/patch-defaults`, the menu-loader's boot
  picker, and the network-loader's over-the-wire inject.

rapi-bootloader is a submodule of this repo at
[`rapi-bootloader/`](../rapi-bootloader).

## How a pi-mame kernel consumes it

rapi-bootloader owns the *writer*; the pi-mame kernel is the *receiver*. What a
pi-mame image does with the block at boot (`host/defaults.cpp`,
`DefaultsBuildArgv()`) is specific to this repo:

1. **The magic is verified at the ABI offset first**, read at the runtime
   address `MEM_KERNEL_START + 0x800`. If it is absent or wrong, the block is
   ignored entirely and MAME boots its own system-selection list — so an
   unpatched image is not a special case; it takes the same empty-string branch
   as a deliberately-cleared block.
2. **The text is bounded by `Capacity` and terminated at its first NUL.**
   `Length` is the writer's convenience field, not the authority the receiver
   trusts.
3. **The text is tokenised** with the grammar a menu author writes — see
   [bootmenu.md](bootmenu.md#the-defaults-string-grammar).
4. **The `--rapi-*` namespace belongs to the kernel.** Any token starting
   `--rapi-` is consumed by the kernel and never reaches MAME; everything else
   is appended to MAME's argv, where MAME's own CLI frontend parses it.
