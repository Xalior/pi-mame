#
# pi-mame — top-level build orchestration.
#
#   make deps                    circle-stdlib (multicore) + the SDL2 shim
#   make mame                    the MAME archives (long; log in build/)
#   make kernel MACHINE=<m>      one kernel image (spectrum|tbblue|picker)
#   make kernels                 all three
#   make sd MACHINE=<m> [ASSETS=<dir>]   copy-to-card tree in build/sd/
#
# Requires the Arm GNU aarch64-none-elf toolchain on PATH (see README.md).

MACHINE ?= spectrum

.PHONY: deps mame kernel kernels sd

deps:
	cd circle-stdlib && ./configure -r 4 -p aarch64-none-elf- --libcxx \
		--kernel-max-size 64 -o ARM_ALLOW_MULTI_CORE && $(MAKE)
	$(MAKE) -C circle-libsdl2

mame:
	scripts/build-mame.sh

kernel:
	$(MAKE) -C host MACHINE=$(MACHINE)

kernels:
	$(MAKE) -C host MACHINE=spectrum
	$(MAKE) -C host MACHINE=tbblue
	$(MAKE) -C host MACHINE=picker

sd:
	scripts/mksd.sh $(MACHINE) $(ASSETS)
