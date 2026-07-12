#
# pi-mame boot picker — the platform card's front door.
#
# A boot-world (single-core) Circle app: it prints the bootmenu.cfg list,
# takes a keyboard pick, patches the chosen defaults-string into a staged
# platform kernel image at offset 0x800, and chain-boots it.
#
# Single-core by design: it links the standalone `circle` submodule (the
# BOOT flavor, plain Circle, no stdlib), never circle-stdlib's multicore
# tree. Circle's EnableChainBoot() refuses ARM_ALLOW_MULTI_CORE builds; this
# kernel complies with that guard. The configuration is pinned by
# ../mk/circle-boot/Config.mk.
#

ROOT = ..
CIRCLEHOME = $(ROOT)/circle

CIRCLE_BOOT_CONFIG = $(ROOT)/mk/circle-boot/Config.mk

# Rules.mk `-include`s $(CIRCLEHOME)/Config.mk (generated, gitignored).
# Keep it a byte-for-byte copy of the pinned boot config BEFORE Rules.mk
# reads it: the copy only happens on content change, and the mtime bump then
# forces the Circle library rebuild below. A foreign configuration written
# into circle/Config.mk can never take effect here.
_config_sync := $(shell cmp -s $(CIRCLE_BOOT_CONFIG) $(CIRCLEHOME)/Config.mk \
	|| cp $(CIRCLE_BOOT_CONFIG) $(CIRCLEHOME)/Config.mk)

OBJS = main.o kernel.o bootmenu.o defaultsblock.o

LIBS = \
	$(CIRCLEHOME)/lib/usb/libusb.a \
	$(CIRCLEHOME)/lib/input/libinput.a \
	$(CIRCLEHOME)/addon/SDCard/libsdcard.a \
	$(CIRCLEHOME)/addon/fatfs/libfatfs.a \
	$(CIRCLEHOME)/lib/fs/libfs.a \
	$(CIRCLEHOME)/lib/sched/libsched.a \
	$(CIRCLEHOME)/lib/libcircle.a

include $(CIRCLEHOME)/Rules.mk

# Backstop: chain-boot is single-core by design. If the multicore define
# ever reaches this kernel's flags, stop the build loudly.
ifneq ($(findstring ARM_ALLOW_MULTI_CORE,$(DEFINE)),)
$(error boot-picker is single-core by design, but ARM_ALLOW_MULTI_CORE is in DEFINE — circle/Config.mk must match mk/circle-boot/Config.mk)
endif

# The boot world's Circle libraries follow the pinned config: a config change
# means a clean rebuild of every library this kernel links.
$(LIBS): $(CIRCLEHOME)/Config.mk
	@echo "  CIRCLE $(@D)"
	@$(MAKE) -C $(@D) clean
	@$(MAKE) -C $(@D) $(@F)

# The kernel's own objects embed the pinned config too (KERNEL_MAX_SIZE sizes
# the staging buffer), so a config change rebuilds them as well.
$(OBJS): $(CIRCLEHOME)/Config.mk

-include $(DEPS)
