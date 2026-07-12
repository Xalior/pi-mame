#
# pi-mame — top-level build orchestration.
#
#   make deps                    circle-stdlib (multicore) + the SDL2 shim
#   make mame                    the MAME archives (long; log in build/)
#   make platform                the ONE universal platform binary
#                                (host/kernel8-platform.img); unpatched it is
#                                the no-options kernel (MAME's own system list)
#   make picker                  the boot picker (boot-picker/kernel8-rpi4.img)
#   make kernel MACHINE=<m>      one single-purpose image — a copy of the
#                                platform binary with machine <m>'s defaults
#                                patched in (machines are the tables in
#                                docs/sinclair/ and docs/amstrad/)
#   make machines                every single-purpose image (one link, patched)
#   make kernels                 platform + machines + picker (all CI verifies)
#   make bootmenu PLATFORM=<p> TIER=<free|public>   a card's bootmenu.cfg -> stdout
#   make sd MACHINE=<m> [ASSETS=<dir>]   single-purpose copy-to-card tree
#   make assets-free  [ASSETS=<dir>]     fetch the properly-redistributable ROMs
#   make assets-public [ASSETS=<dir>]    fetch from public MAME-set mirrors
#   make assets       [ASSETS=<dir>]     fetch both (free + public)
#
# Requires the Arm GNU aarch64-none-elf toolchain on PATH (see README.md).

MACHINE  ?= spectrum
PLATFORM ?= sinclair
TIER     ?= free
ASSETS   ?= ./my-assets

.PHONY: deps mame platform picker kernel machines kernels bootmenu \
	sd assets assets-free assets-public

# `bash ./configure` (not ./configure): the shebang would pin macOS's
# bash 3.2; PATH resolution finds a modern bash when one is installed.
# MAKEINFO=true: newlib insists on building its manuals otherwise, which
# fails on any system without texinfo — the manuals aren't the product.
deps:
	cd circle-stdlib && bash ./configure -r 4 -p aarch64-none-elf- --libcxx \
		--kernel-max-size 256 -o ARM_ALLOW_MULTI_CORE && $(MAKE) MAKEINFO=true
	$(MAKE) -C circle-libsdl2

mame:
	scripts/build-mame.sh

# The universal binary: one link, all drivers, no machine baked.
platform:
	$(MAKE) -C host

# The platform card's front door (single-core boot world).
picker:
	$(MAKE) -C boot-picker

# One single-purpose image: the platform binary patched with <m>'s string.
kernel:
	$(MAKE) -C host kernel8-$(MACHINE).img

# Every single-purpose image — one link (the platform binary), then a
# byte-patch per machine.
machines:
	$(MAKE) -C host machines

# Everything CI verifies: the universal binary, every patched machine image,
# and the picker.
kernels: platform machines picker

# A platform card's menu, derived per tier from the manifest (free = only
# all-free machines; public = the full roster). Writes to stdout.
bootmenu:
	scripts/gen-bootmenu.sh $(PLATFORM) $(TIER)

sd:
	scripts/mksd.sh $(MACHINE) $(ASSETS)

# Fetch assets into $(ASSETS) (default ./my-assets). The script offers; you
# choose the tier. See scripts/assets.manifest for every source and checksum.
assets-free:
	scripts/fetch-assets.sh free $(ASSETS)

assets-public:
	scripts/fetch-assets.sh public $(ASSETS)

assets:
	scripts/fetch-assets.sh all $(ASSETS)
