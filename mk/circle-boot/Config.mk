#
# Config.mk — the BOOT flavor of Circle (pinned, tracked).
#
# Two Circle worlds exist in this repo, one per kernel design:
#
#   - BOOT (this file): the standalone `circle` submodule, single-core.
#     The boot picker (boot-picker/) never starts a secondary core, and
#     Circle's EnableChainBoot() asserts under ARM_ALLOW_MULTI_CORE — so
#     this flavor simply must not carry it. The picker's Makefile installs
#     this file as circle/Config.mk (a generated, gitignored file) before
#     Circle's Rules.mk reads it, and clean-rebuilds the Circle libraries
#     whenever it changes: the boot world cannot silently inherit someone
#     else's configuration.
#
#   - PAYLOAD: circle-stdlib (its own generated Config.mk files carry
#     ARM_ALLOW_MULTI_CORE), linked by the MAME platform kernel via
#     circle-stdlib/Config.mk.
#
# STDLIB_SUPPORT=1: freestanding Circle plus the toolchain's libgcc. The
# picker is pure Circle code (sample/38-bootloader lineage); it needs no
# newlib and no libc++.
#
# KERNEL_MAX_SIZE is 256MB in BOTH Circle worlds: the picker's image
# staging buffer is sized by it, so it must never be smaller than the
# payload world's. 256MB is half the RAM of the smallest Pi ever made
# (the 512MB Zero) — the ceiling holds even if the smallest board is ever
# targeted, and MAME machines that drag in fat device catalogs (ISA, m68k)
# fit under it.
#

RASPPI = 4
AARCH = 64
PREFIX64 = aarch64-none-elf-
FLOAT_ABI = hard
STDLIB_SUPPORT = 1
DEFINE += -DKERNEL_MAX_SIZE=0x10000000
