#
# pi-mame — top-level build orchestration.
#
#   make deps                    circle-stdlib (multicore) + the SDL2 shim
#   make mame                    the MAME archives (long; log in build/)
#   make kernel MACHINE=<m>      one kernel image — machines are the
#                                platform tables in docs/sinclair/ and
#                                docs/amstrad/, plus `picker`
#   make kernels                 every machine in those tables, plus the picker
#   make sd MACHINE=<m> [ASSETS=<dir>]   copy-to-card tree in build/sd/
#   make assets-free  [ASSETS=<dir>]     fetch the properly-redistributable ROMs
#   make assets-public [ASSETS=<dir>]    fetch from public MAME-set mirrors
#   make assets       [ASSETS=<dir>]     fetch both (free + public)
#
# Requires the Arm GNU aarch64-none-elf toolchain on PATH (see README.md).

MACHINE ?= spectrum
ASSETS  ?= ./my-assets

.PHONY: deps mame kernel kernels sd assets assets-free assets-public

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

kernel:
	$(MAKE) -C host MACHINE=$(MACHINE)

kernels:
	$(MAKE) -C host MACHINE=spectrum
	$(MAKE) -C host MACHINE=spec128
	$(MAKE) -C host MACHINE=specpls2
	$(MAKE) -C host MACHINE=specpl2a
	$(MAKE) -C host MACHINE=specpls3
	$(MAKE) -C host MACHINE=tbblue
	$(MAKE) -C host MACHINE=specnext_ks1
	$(MAKE) -C host MACHINE=specnext_ks2
	$(MAKE) -C host MACHINE=specnext_ks3
	$(MAKE) -C host MACHINE=zx80
	$(MAKE) -C host MACHINE=zx81
	$(MAKE) -C host MACHINE=tc2048
	$(MAKE) -C host MACHINE=ts2068
	$(MAKE) -C host MACHINE=ts1000
	$(MAKE) -C host MACHINE=ts1500
	$(MAKE) -C host MACHINE=pentagon
	$(MAKE) -C host MACHINE=scorpio
	$(MAKE) -C host MACHINE=atmtb2
	$(MAKE) -C host MACHINE=pentevo
	$(MAKE) -C host MACHINE=tsconf
	$(MAKE) -C host MACHINE=elwro800
	$(MAKE) -C host MACHINE=byte
	$(MAKE) -C host MACHINE=cpc464
	$(MAKE) -C host MACHINE=cpc664
	$(MAKE) -C host MACHINE=cpc6128
	$(MAKE) -C host MACHINE=cpc464p
	$(MAKE) -C host MACHINE=cpc6128p
	$(MAKE) -C host MACHINE=kccomp
	$(MAKE) -C host MACHINE=nc100
	$(MAKE) -C host MACHINE=nc200
	$(MAKE) -C host MACHINE=sprinter
	$(MAKE) -C host MACHINE=pc1512
	$(MAKE) -C host MACHINE=gx4000
	$(MAKE) -C host MACHINE=picker

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
