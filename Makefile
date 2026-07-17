#
# pi-mame — top-level build orchestration.
#
#   make deps                    the two Circle worlds, each owned by its
#                                consumer: circle-libsdl2 (multicore, + the SDL2
#                                shim) and rapi-bootloader (single-core, the
#                                picker links it)
#   make mame [RAPI_BOARD=<b>]    the board's ONE shared mamedrivers MAME engine
#                                (mame-<b>/build/mamedrivers; long; log in build/).
#                                Every platform kernel links it (build once,
#                                link drivers per platform).
#   make platform                one platform binary per vendor-class
#                                (host/kernel8-<platform>.img); unpatched each
#                                is that platform's no-options kernel (MAME's
#                                own system list)
#   make picker                  the boot picker (rapi-bootloader/menu-loader/kernel8-rpi4.img)
#   make kernel MACHINE=<m>      one single-purpose image — a copy of the
#                                machine's PLATFORM binary with machine <m>'s
#                                defaults patched in (machines are the tables in
#                                docs/sinclair/ and docs/amstrad/)
#   make machines                every single-purpose image (one link per
#                                platform, then a byte-patch per machine)
#   make kernels                 platform + machines + picker (all CI verifies)
#   make bootmenu PLATFORM=<p> TIER=<free|public>   a card's bootmenu.cfg -> stdout
#   make card PLATFORM=<p> TIER=<free|public> [ASSETS=<dir>]
#                                a platform card tree: the picker on-card as
#                                pi-mame-boot-rpi4.img (firmware boots it), the
#                                platform binary as pi-mame-core-rpi4.img,
#                                a generated bootmenu.cfg, and the tier's assets
#   make sd MACHINE=<m> [ASSETS=<dir>]   single-purpose copy-to-card tree
#   make assets-free  [ASSETS=<dir>]     fetch the properly-redistributable ROMs
#   make assets-public [ASSETS=<dir>]    fetch from public MAME-set mirrors
#   make assets       [ASSETS=<dir>]     fetch both (free + public)
#   make docs [DOCS_PLATFORM=<p>]        regenerate docs/<p>/README.md and
#                                every docs/<p>/<machine>.md from source
#                                (host/machines.mk, scripts/assets.manifest,
#                                the platform's MAME driver) — nothing
#                                hand-typed, so the pages can't drift
#
# Requires the Arm GNU aarch64-none-elf toolchain on PATH (see README.md).

# The per-platform facts (PLATFORMS, MACHINE_PLATFORM_<m>) live in one place.
include host/machines.mk

MACHINE    ?= spectrum
PLATFORM   ?= sinclair
TIER       ?= free
ASSETS     ?= ./my-assets
# Separate from PLATFORM above: gen-machine-docs.py only covers amiga so far
# (sinclair/amstrad/commodore stay hand-maintained until PoC4 ports them on).
DOCS_PLATFORM ?= amiga
# Which board this build targets: rpi3 | rpi4 | rpi5. Selects the MAME source
# tree (mame-<board>), the circle world, RASPPI and -mcpu. One board per
# invocation; CI dispatches a job per board. Default rpi4 (the proven board).
RAPI_BOARD ?= rpi4

# `make kernel MACHINE=<m>` builds <m>'s image from its own platform's binary.
KERNEL_PLATFORM = $(MACHINE_PLATFORM_$(MACHINE))

.PHONY: deps mame platform picker kernel machines kernels bootmenu card \
	sd assets assets-free assets-public docs

# Each consumer owns its Circle world as a submodule, one per threading model,
# so deps is just two self-contained builds — neither is configured here:
#
#   - circle-libsdl2 owns the MULTICORE circle-stdlib: the shim's core-split
#     runs a presentation worker on a second physical core. The payload kernels
#     link the shim AND that world (host/Makefile).
#   - rapi-bootloader owns the SINGLE-CORE circle-stdlib: Circle's
#     EnableChainBoot() refuses ARM_ALLOW_MULTI_CORE. The boot picker links it.
#
# Each repo's own `make deps` configures and builds its world (including the
# immutable-tagged LLVM/libc++ checkout), so a fresh --recursive clone needs
# nothing here but these two calls.
deps:
	$(MAKE) -C circle-libsdl2 deps
	$(MAKE) -C rapi-bootloader deps

mame:
	scripts/build-mame.sh $(RAPI_BOARD)

# One platform binary per vendor-class: each its own link against its own
# isolated MAME tree, no machine baked. Unpatched, each is that platform's
# no-options kernel (MAME's own system list).
platform:
	@for p in $(PLATFORMS); do $(MAKE) -C host RAPI_BOARD=$(RAPI_BOARD) PLATFORM=$$p || exit 1; done

# The platform card's front door (single-core boot world).
picker:
	$(MAKE) -C rapi-bootloader/menu-loader

# One single-purpose image: the machine's PLATFORM binary patched with <m>'s
# defaults string.
kernel:
	@if [ -z "$(KERNEL_PLATFORM)" ]; then \
		echo "unknown machine '$(MACHINE)' — not in host/machines.mk"; exit 1; fi
	$(MAKE) -C host RAPI_BOARD=$(RAPI_BOARD) PLATFORM=$(KERNEL_PLATFORM) kernel8-$(MACHINE).img

# Every single-purpose image — one link per platform, then a byte-patch per
# machine of that platform.
machines:
	@for p in $(PLATFORMS); do $(MAKE) -C host RAPI_BOARD=$(RAPI_BOARD) PLATFORM=$$p machines || exit 1; done

# Everything CI verifies: every platform binary, every patched machine image,
# and the picker.
kernels: platform machines picker

# A platform card's menu, derived per tier from the manifest (free = only
# all-free machines; public = the full roster). Writes to stdout.
bootmenu:
	scripts/gen-bootmenu.sh $(PLATFORM) $(TIER)

# A platform card tree (build/card-<platform>-<tier>/): the picker on-card as
# pi-mame-boot-rpi4.img (firmware boots it), the platform binary as
# pi-mame-core-rpi4.img, a generated bootmenu.cfg for the tier, and the tier's
# assets. The free and public cards share the one platform binary — only the
# menu and the asset bundle differ.
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

# Regenerate one platform's docs/<p>/ pages straight from source (see
# scripts/gen-machine-docs.py's header for the exact ground truth read).
# Idempotent: re-running with unchanged source reproduces byte-identical
# output.
docs:
	scripts/gen-machine-docs.py $(DOCS_PLATFORM)
