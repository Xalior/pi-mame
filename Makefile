#
# pi-mame — top-level build orchestration.
#
#   make deps                    circle-stdlib (multicore) + the SDL2 shim
#   make mame                    every platform's MAME archives, each in its
#                                own isolated tree (long; logs in build/)
#   make platform                one platform binary per vendor-class
#                                (host/kernel8-<platform>.img); unpatched each
#                                is that platform's no-options kernel (MAME's
#                                own system list)
#   make picker                  the boot picker (boot-picker/kernel8-rpi4.img)
#   make kernel MACHINE=<m>      one single-purpose image — a copy of the
#                                machine's PLATFORM binary with machine <m>'s
#                                defaults patched in (machines are the tables in
#                                docs/sinclair/ and docs/amstrad/)
#   make machines                every single-purpose image (one link per
#                                platform, then a byte-patch per machine)
#   make kernels                 platform + machines + picker (all CI verifies)
#   make bootmenu PLATFORM=<p> TIER=<free|public>   a card's bootmenu.cfg -> stdout
#   make card PLATFORM=<p> TIER=<free|public> [ASSETS=<dir>]
#                                a platform card tree: the picker as the boot
#                                kernel, the platform binary as pi-mame-rpi4.img,
#                                a generated bootmenu.cfg, and the tier's assets
#   make sd MACHINE=<m> [ASSETS=<dir>]   single-purpose copy-to-card tree
#   make assets-free  [ASSETS=<dir>]     fetch the properly-redistributable ROMs
#   make assets-public [ASSETS=<dir>]    fetch from public MAME-set mirrors
#   make assets       [ASSETS=<dir>]     fetch both (free + public)
#
# Requires the Arm GNU aarch64-none-elf toolchain on PATH (see README.md).

# The per-platform facts (PLATFORMS, MACHINE_PLATFORM_<m>) live in one place.
include host/machines.mk

MACHINE  ?= spectrum
PLATFORM ?= sinclair
TIER     ?= free
ASSETS   ?= ./my-assets

# `make kernel MACHINE=<m>` builds <m>'s image from its own platform's binary.
KERNEL_PLATFORM = $(MACHINE_PLATFORM_$(MACHINE))

.PHONY: deps mame platform picker kernel machines kernels bootmenu card \
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

# One platform binary per vendor-class: each its own link against its own
# isolated MAME tree, no machine baked. Unpatched, each is that platform's
# no-options kernel (MAME's own system list).
platform:
	@for p in $(PLATFORMS); do $(MAKE) -C host PLATFORM=$$p || exit 1; done

# The platform card's front door (single-core boot world).
picker:
	$(MAKE) -C boot-picker

# One single-purpose image: the machine's PLATFORM binary patched with <m>'s
# defaults string.
kernel:
	@if [ -z "$(KERNEL_PLATFORM)" ]; then \
		echo "unknown machine '$(MACHINE)' — not in host/machines.mk"; exit 1; fi
	$(MAKE) -C host PLATFORM=$(KERNEL_PLATFORM) kernel8-$(MACHINE).img

# Every single-purpose image — one link per platform, then a byte-patch per
# machine of that platform.
machines:
	@for p in $(PLATFORMS); do $(MAKE) -C host PLATFORM=$$p machines || exit 1; done

# Everything CI verifies: the universal binary, every patched machine image,
# and the picker.
kernels: platform machines picker

# A platform card's menu, derived per tier from the manifest (free = only
# all-free machines; public = the full roster). Writes to stdout.
bootmenu:
	scripts/gen-bootmenu.sh $(PLATFORM) $(TIER)

# A platform card tree (build/card-<platform>-<tier>/): the picker as the boot
# kernel, the platform binary as pi-mame-rpi4.img, a generated bootmenu.cfg for
# the tier, and the tier's assets. The free and public cards share the one
# platform binary — only the menu and the asset bundle differ.
card:
	scripts/mkcard.sh $(PLATFORM) $(TIER) $(ASSETS)

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
