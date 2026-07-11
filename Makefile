#
# pi-mame — top-level build orchestration.
#
#   make deps                    circle-stdlib (multicore) + the SDL2 shim
#   make mame                    the MAME archives (long; log in build/)
#   make kernel MACHINE=<m>      one kernel image (spectrum|spec128|specpls2|specpl2a|specpls3|tbblue|specnext_ks1|zx80|zx81|tc2048|ts2068|ts1000|ts1500|picker)
#   make kernels                 all fourteen
#   make sd MACHINE=<m> [ASSETS=<dir>]   copy-to-card tree in build/sd/
#
# Requires the Arm GNU aarch64-none-elf toolchain on PATH (see README.md).

MACHINE ?= spectrum

.PHONY: deps mame kernel kernels sd

# `bash ./configure` (not ./configure): the shebang would pin macOS's
# bash 3.2; PATH resolution finds a modern bash when one is installed.
# MAKEINFO=true: newlib insists on building its manuals otherwise, which
# fails on any system without texinfo — the manuals aren't the product.
deps:
	cd circle-stdlib && bash ./configure -r 4 -p aarch64-none-elf- --libcxx \
		--kernel-max-size 64 -o ARM_ALLOW_MULTI_CORE && $(MAKE) MAKEINFO=true
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
	$(MAKE) -C host MACHINE=zx80
	$(MAKE) -C host MACHINE=zx81
	$(MAKE) -C host MACHINE=tc2048
	$(MAKE) -C host MACHINE=ts2068
	$(MAKE) -C host MACHINE=ts1000
	$(MAKE) -C host MACHINE=ts1500
	$(MAKE) -C host MACHINE=picker

sd:
	scripts/mksd.sh $(MACHINE) $(ASSETS)
