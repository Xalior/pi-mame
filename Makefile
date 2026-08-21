#
# pi-mame — top-level build orchestration.
#
#   make deps                    the two Circle worlds, each owned by its
#                                consumer: circle-libsdl2 (multicore, + the SDL2
#                                shim) and rapi-bootloader (single-core, the
#                                picker links it)
#   make mame [RAPI_BOARD=<b>]    the board's ONE shared mamedrivers MAME engine
#                                (mame/build/<b>; long; log in build/).
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
#   make ci [BOARDS="rpi3 rpi4 rpi5"]    the CI matrix, locally: every board
#                                through CI's exact job steps (mame, verify-mame,
#                                platform, picker, verify-kernels scope=platform),
#                                boards fanned out in parallel like the matrix
#   make verify-mame [RAPI_BOARD=<b>]     truth-gate: the board's mamedrivers
#                                archives exist (genie's host link fails by design)
#   make verify-kernels [RAPI_BOARD=<b>] [VERIFY_SCOPE=all|platform]
#                                truth-gate: every kernel image exists, each
#                                under the 255MB ceiling. Scope `platform`
#                                gates only what a release ships (platform
#                                binaries + picker); per-machine images are a
#                                local `make kernel MACHINE=<m>` byte-patch
#   make bootmenu PLATFORM=<p> TIER=<free|public>   a card's bootmenu.cfg -> stdout
#   make card PLATFORM=<p> TIER=<free|public> [RAPI_BOARD=<b>] [ASSETS=<dir>]
#                                a per-board platform card tree
#                                (build/card-<p>-<tier>-<board>/): the picker
#                                on-card as pi-mame-boot-<board>.img (firmware
#                                boots it), the platform binary as the generic
#                                kernel-<board>.img (the picker chain-boots it),
#                                a generated bootmenu.cfg, and the tier's assets
#   make sd MACHINE=<m> [RAPI_BOARD=<b>] [ASSETS=<dir>]  single-purpose per-board
#                                copy-to-card tree (build/sd-<m>-<board>/)
#   make dist [TAG=<t>] [BOARDS="rpi3 rpi4 rpi5"]   the whole release: one
#                                platform-card zip per board × platform × tier
#                                into dist/ (pi-mame-<TAG>-<platform>-<tier>-<board>.zip)
#   make assets-free  [ASSETS=<dir>]     fetch the properly-redistributable ROMs
#   make assets-public [ASSETS=<dir>]    fetch from public MAME-set mirrors
#   make assets       [ASSETS=<dir>]     fetch both (free + public)
#   make media        [ASSETS=<dir>]     fetch the curated extra-game titles
#                                (scripts/trial-games.manifest) — media a
#                                platform's own romset doesn't carry. A title
#                                with no recorded source prints UNAVAILABLE,
#                                not FAILED.
#   make docs [DOCS_PLATFORM=<p>]        regenerate docs/<p>/README.md and
#                                every docs/<p>/<machine>.md from source
#                                (host/machines.mk, scripts/assets.manifest,
#                                the platform's MAME driver) — nothing
#                                hand-typed, so the pages can't drift
#
# Requires the Arm GNU aarch64-none-elf toolchain on PATH (see README.md).

# ---------------------------------------------------------------------------
# Shared build resources.
#
# One toolchain, one libc++ checkout, one set of per-board worlds and one build
# of the shim serve every consumer on a machine that is building several. All
# four are honoured with ?=, so unset each resolves inside this repository and
# a fresh clone and CI stay self-contained. Overriding them is a local
# development convenience and changes nothing about the rule that every repo
# carries its own nested submodule copy.
# ---------------------------------------------------------------------------

# Where the Arm GNU cross toolchain lives. The default is this repository's
# own; a meta checkout carrying one for several projects names that instead.
export RAPI_TOOLCHAIN_DIR ?= $(CURDIR)/toolchains

# The libc++ sources the board worlds are built from. Named here rather than
# left to circle-libsdl2's own default so every world on a machine shares a
# single checkout — one fetch off a small volunteer-run forge instead of one
# per world per project.
export CIRCLE_LLVM ?= $(abspath $(CURDIR)/../circle-llvm)

# One build of the shim, and one set of built worlds. A world is a configured,
# compiled circle-stdlib: newlib and libc++ from source, gigabytes of it, one
# per board. Unset, both are this repository's own pinned copy, which is what a
# clone and a CI runner get and the whole point of pinning it.
export SHIM ?= $(abspath $(CURDIR)/circle-libsdl2)
export CIRCLE_WORLDS ?= $(SHIM)

# The Arm GNU aarch64-none-elf toolchain: a stranger installs it on PATH
# (README) and CI does the same, but a meta checkout carries a project-local
# copy. If the compiler is NOT already on PATH and a local install exists,
# prepend it — conditionally, same pattern as the sub-Makefiles' keg-only
# gnu-getopt handling, so CI and stranger builds are untouched and a meta
# checkout needs no manual PATH exports.
ifeq ($(shell command -v aarch64-none-elf-gcc 2>/dev/null),)
TOOLCHAIN_BIN := $(firstword \
	$(wildcard $(RAPI_TOOLCHAIN_DIR)/arm-gnu-toolchain-*-aarch64-none-elf/bin) \
	$(wildcard $(RAPI_TOOLCHAIN_DIR)/bin) \
	$(wildcard ../toolchains/arm-gnu-toolchain-*-aarch64-none-elf/bin))
ifneq ($(TOOLCHAIN_BIN),)
export PATH := $(abspath $(TOOLCHAIN_BIN)):$(PATH)
endif
endif

# The per-platform facts (PLATFORMS, MACHINE_PLATFORM_<m>) live in one place.
include host/machines.mk

MACHINE    ?= spectrum
PLATFORM   ?= sinclair
TIER       ?= free
ASSETS     ?= ./my-assets
# Separate from PLATFORM above: which platform(s) `make docs` regenerates.
# Every platform in host/machines.mk's PLATFORMS list is generated from its
# own scripts/platform-docs/<p>.md data file — none are hand-maintained.
# `all` (the default) regenerates every platform in one pass.
DOCS_PLATFORM ?= all
# Which board this build targets: rpi3 | rpi4 | rpi5. Selects the MAME source
# artifact tree (mame/build/<board>), the circle world, RASPPI and -mcpu, and the board-scoped
# build tree every artifact lands in (host/build/<board>/, the picker's
# menu-loader/build/<board>/). One board per invocation; CI dispatches a job per
# board. Default rpi4 (the proven board). Exported so the card/sd/dist scripts
# and the host sub-make all see the same board.
RAPI_BOARD ?= rpi4
export RAPI_BOARD
# Every board pi-mame targets. `make dist` fans the whole card matrix across
# these (board × platform × tier); override to build a subset (BOARDS=rpi4).
BOARDS ?= rpi3 rpi4 rpi5
export BOARDS
# Release tag naming the card zips (pi-mame-<TAG>-<platform>-<tier>.zip). CI
# passes the ref name; locally it defaults to `git describe` (else "dev").
TAG ?= $(shell git describe --tags --always --dirty 2>/dev/null || echo dev)

# `make kernel MACHINE=<m>` builds <m>'s image from its own platform's binary.
KERNEL_PLATFORM = $(MACHINE_PLATFORM_$(MACHINE))

.PHONY: deps mame platform picker kernel machines kernels ci verify-mame \
	verify-kernels bootmenu card sd dist assets assets-free assets-public \
	media docs

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

# ---------------------------------------------------------------------------
# The two halves of MAME, as two kernels.
# ---------------------------------------------------------------------------
#
# `computers` and `arcade` divide MAME's whole driver set in two by what the
# drivers say they are, using MAME's own macros (scripts/driver-class.sh; the
# two are declared in host/machines.mk as VIRTUAL_PLATFORMS). Between them they
# carry every machine MAME supports, so a pull that adds drivers adds machines
# here with nothing to edit.
#
# THEY NEED THE WHOLE-TREE ENGINE. An ordinary `make mame` compiles only the
# drivers the roster names, and a kernel may link no driver its engine does not
# carry, so these link against the `mame-all` engine instead. It lives in its
# own build directory, so both engines can exist at once.
#
# WHY TWO KERNELS AND NOT ONE. On a Pi 5 the halves measure 219 MB and 242 MB;
# together as a single kernel they are 335 MB, past the 255 MB ceiling a kernel
# has to stay under. Split, each half fits.
ALL_ENGINE = $(CURDIR)/mame/build/$(RAPI_BOARD)-all/rapi-circle

mame-all:
	scripts/build-mame.sh $(RAPI_BOARD) --all

# MAMEBUILD and MAMEDRIVERS_SUBTARGET are the whole of what points host's
# Makefile at the other engine. It needs no change to build these.
.PHONY: mame-all computers arcade halves
computers arcade:
	@[ -d "$(ALL_ENGINE)/bin/mame_mame" ] || { \
		echo "$@: no whole-tree engine for $(RAPI_BOARD) — run 'make mame-all' first" >&2; \
		exit 1; }
	$(MAKE) -C host RAPI_BOARD=$(RAPI_BOARD) PLATFORM=$@ \
		MAMEBUILD=$(ALL_ENGINE) MAMEDRIVERS_SUBTARGET=mame
	@echo "  SIZE  $@: $$(wc -c < host/build/$(RAPI_BOARD)/kernel8-$@.img) bytes"

halves: computers arcade

# One platform binary per vendor-class: each its own link against its own
# isolated MAME tree, no machine baked. Unpatched, each is that platform's
# no-options kernel (MAME's own system list).
platform:
	@for p in $(PLATFORMS); do $(MAKE) -C host RAPI_BOARD=$(RAPI_BOARD) PLATFORM=$$p || exit 1; done

# The platform card's front door (single-core boot world), built for this
# board. The bootloader owns the per-board build (menu-loader/build/<board>/,
# Circle-named image per RASPPI); it is board-generic and chain-boots the
# generic kernel-<board>.img the card carries the core as.
picker:
	$(MAKE) -C rapi-bootloader menu-loader-$(RAPI_BOARD)

# One single-purpose image: the machine's PLATFORM binary patched with <m>'s
# defaults string. Every image lands under host/build/<board>/, so the goal
# carries that path — host's per-machine rule is anchored there.
kernel:
	@if [ -z "$(KERNEL_PLATFORM)" ]; then \
		echo "unknown machine '$(MACHINE)' — not in host/machines.mk"; exit 1; fi
	$(MAKE) -C host RAPI_BOARD=$(RAPI_BOARD) PLATFORM=$(KERNEL_PLATFORM) \
		build/$(RAPI_BOARD)/kernel8-$(MACHINE).img

# Every single-purpose image — one link per platform, then a byte-patch per
# machine of that platform.
machines:
	@for p in $(PLATFORMS); do $(MAKE) -C host RAPI_BOARD=$(RAPI_BOARD) PLATFORM=$$p machines || exit 1; done

# Everything CI verifies: every platform binary, every patched machine image,
# and the picker.
kernels: platform machines picker

# The CI matrix, locally. Each ci-board-<b> chain runs the workflow's job
# steps in the workflow's order, against the same targets CI calls — the same
# code path, on this machine.
#
# ONE BOARD AT A TIME. The workflow gives every board its own runner and its
# own checkout, so its matrix is genuinely parallel; here the three boards
# share one working tree. Their ARTIFACTS are disjoint (mame/build/<board>,
# host/build/<board>/, per-board picker build and mame-build log), but the
# generators that produce them are not: MAME's build compiles genie itself into
# the shared 3rdparty/genie, and two boards racing on that build one binary over
# the other. Running the boards in sequence costs wall-clock and nothing else.
ci:
	@for b in $(BOARDS); do $(MAKE) ci-board-$$b || exit 1; done

ci-board-%:
	$(MAKE) mame RAPI_BOARD=$*
	$(MAKE) verify-mame RAPI_BOARD=$*
	$(MAKE) platform RAPI_BOARD=$*
	$(MAKE) picker RAPI_BOARD=$*
	$(MAKE) verify-kernels RAPI_BOARD=$* VERIFY_SCOPE=platform
	@echo "CI-BOARD-GREEN $*"

# Truth-gates, runnable locally and in CI (CI just calls these). verify-mame
# checks the board's mamedrivers archives survived genie's by-design host-link
# failure; verify-kernels checks every image exists and fits the 255MB ceiling.
verify-mame:
	scripts/verify-mame.sh $(RAPI_BOARD)

VERIFY_SCOPE ?= all
verify-kernels:
	scripts/verify-kernels.sh $(RAPI_BOARD) $(VERIFY_SCOPE)

# A platform card's menu, derived per tier from the manifest (free = only
# all-free machines; public = the full roster). Writes to stdout.
bootmenu:
	scripts/gen-bootmenu.sh $(PLATFORM) $(TIER)

# A platform card tree (build/card-<platform>-<tier>-<board>/): the picker
# on-card as pi-mame-boot-<board>.img (firmware boots it), the platform binary
# as the generic kernel-<board>.img (the picker chain-boots it), a generated
# bootmenu.cfg for the tier, and the assets that menu needs. The free and
# public cards share the one platform binary — only the menu and the asset
# set differ.
card:
	scripts/mkcard.sh $(PLATFORM) $(TIER) $(ASSETS)

sd:
	scripts/mksd.sh $(MACHINE) $(ASSETS)

# The whole release: every platform-card zip into dist/. The SAME target a
# local user runs, so the release path is tested locally and in CI alike.
dist:
	scripts/mkdist.sh $(TAG)

# Fetch assets into $(ASSETS) (default ./my-assets). The script offers; you
# choose the tier. See scripts/assets.manifest for every source and checksum.
assets-free:
	scripts/fetch-assets.sh free $(ASSETS)

assets-public:
	scripts/fetch-assets.sh public $(ASSETS)

assets:
	scripts/fetch-assets.sh all $(ASSETS)

# Fetch the curated extra-game titles (scripts/trial-games.manifest) into
# $(ASSETS), in the same /media/<mediatype>/<driver>/ layout the card
# builders (mkcard.sh/mksd.sh) already read. Separate from the ROM fetchers
# above because this content never comes from a MAME romset — see
# scripts/assets.manifest's own "trial games" section for per-title sources
# and, where none was ever recorded, why.
media:
	scripts/fetch-assets.sh media $(ASSETS)

# Regenerate one platform's docs/<p>/ pages straight from source (see
# scripts/gen-machine-docs.py's header for the exact ground truth read).
# Idempotent: re-running with unchanged source reproduces byte-identical
# output.
docs:
	scripts/gen-machine-docs.py $(DOCS_PLATFORM)
