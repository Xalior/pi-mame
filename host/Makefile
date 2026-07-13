#
# MAME payload: ONE binary per vendor-class platform, ANY machine on it.
#
# This Makefile is scoped to ONE platform per invocation (PLATFORM=sinclair by
# default; the top Makefile drives every platform). Platform is the logical
# unit — a MAME src/mame/<vendor>/ directory, with no crossover — so each
# platform is its own binary, linked from its own isolated MAME archive tree
# (mame/build/<platform>/rapi-circle, built by scripts/build-mame.sh).
#
# Under the patchable-defaults string (docs/pi-mame-poc2.html) no machine is
# compiled in. kernel8-<platform>.img links that platform's MAME archives +
# circle-libsdl2 + circle-stdlib once, carrying the 0x800 defaults block; the
# machine name and its media ride that block as plain text, written before boot.
#
#   make PLATFORM=<p>        -> kernel8-<p>.img — the platform binary.
#                               Unpatched (empty block) it IS that platform's
#                               no-options kernel: MAME boots its own system-
#                               selection list. Ships on the platform card as
#                               pi-mame-core-rpi4.img, chain-booted by the picker.
#   make PLATFORM=<p> machines
#                            -> kernel8-<machine>.img for every machine of that
#                               platform, each a copy of kernel8-<p>.img with
#                               the machine's defaults string patched in at
#                               0x800 (host tool patch-defaults). ONE link per
#                               platform, then one byte-patch per machine — no
#                               per-machine compile.
#   make PLATFORM=<p> kernel8-<machine>.img  -> that single machine's image.
#
# The per-machine facts (which platform a machine belongs to, its defaults
# string, its asset dependencies) are data in machines.mk, not compile-time
# bakes. Framebuffer geometry is NOT here: it is Circle boot config (width=/
# height= in the SD card's FAT-root cmdline.txt), set PER REGION, not per
# machine — cmdline-pal.txt is the PAL canvas (720x576) every PAL machine
# fills, cmdline-ntsc.txt the NTSC canvas (720x480) the American 60Hz machines
# fill, the way a CRT was filled.
#
# Prerequisite: scripts/build-mame.sh has produced mame/build/<platform>/rapi-circle/.
#

include ../circle-libsdl2/circle-stdlib/Config.mk
include machines.mk

ROOT = ..

# The platform this invocation builds. Every path below is scoped to it.
PLATFORM ?= sinclair
SUBTARGET := $(PLATFORM_SUBTARGET_$(PLATFORM))
ifeq ($(SUBTARGET),)
$(error unknown PLATFORM '$(PLATFORM)' — not in machines.mk PLATFORMS ($(PLATFORMS)))
endif

# The platform's OWN isolated MAME archive tree (per-platform BUILDDIR: genie
# scopes obj/bin by TARGETOS, so a shared tree would share engine libraries).
MAMEBUILD = $(ROOT)/mame/build/$(PLATFORM)/rapi-circle

TARGET = kernel8-$(PLATFORM)

# No machine is baked: the kernel object is the same for every image and every
# platform. The defaults receiver (defaults.o) carries the 0x800 block and the
# entry trampoline the linker script pins.
OBJS = main.o kernel.o defaults.o mamemain.o circle_stubs.o

STANDARD = -std=gnu++23 -Wno-volatile

# The three objects genie links directly into the final binary. The drivlist
# is subtarget-scoped (this platform's driver list); mame.o and version.o are
# the platform's own copies in its isolated tree.
MAME_OBJS = \
	$(MAMEBUILD)/obj/Release/src/mame/mame.o \
	$(MAMEBUILD)/obj/Release/generated/mame/$(SUBTARGET)/drivlist.o \
	$(MAMEBUILD)/obj/Release/generated/version.o

# libosd_sdl.a ships sdlmain.o (MAME's own main() + sdl_entered_debugger,
# which mamemain.cpp provides instead). Link a local copy with that member
# deleted; the mame tree stays untouched. Named per platform so the two
# platforms' copies never collide in this shared build directory.
LIBOSD_NOMAIN = libosd_sdl-nomain-$(PLATFORM).a

# libprecompile.a is excluded (PCH carrier, nothing to link). libqtdbg_sdl.a
# stays in: built with USE_QTDEBUG=0 it holds only the not-supported debugger
# module (DEBUG_QT), which osdobj_common.cpp registers unconditionally. The
# driver archive is subtarget-scoped (bin/mame_<subtarget>/); the engine
# archives (bin/*.a) are this platform's own, isolated by its BUILDDIR.
MAME_ARCHIVES = \
	$(wildcard $(MAMEBUILD)/bin/mame_$(SUBTARGET)/*.a) \
	$(filter-out %/libosd_sdl.a %/libprecompile.a, \
		$(wildcard $(MAMEBUILD)/bin/*.a))

# Rules.mk's link recipe already wraps $(LIBS) in --start-group/--end-group,
# which covers MAME's mutually referential archives. LIBS is also part of
# the .img rule's prerequisite list: file paths only, defined before Rules.mk.
LIBS = $(MAME_OBJS) \
	$(LIBOSD_NOMAIN) \
	$(MAME_ARCHIVES) \
	$(ROOT)/circle-libsdl2/libSDL2.a \
	$(CIRCLEHOME)/lib/sound/libsound.a \
	$(CIRCLE_STDLIB_LIBS)

# The platform image carries the patchable-defaults block: link with the
# defaults linker script (trampoline + block pinned at 0x800) and gate every
# produced image on the 0x800 magic (mk/ld/circle-app.mk).
APP_LDSCRIPT = ../mk/ld/circle-defaults.ld
APP_DEFAULTS_BLOCK = 1

include $(CIRCLEHOME)/Rules.mk

# MAME is multicore by design: this kernel must link a multicore-configured
# circle-stdlib world. circle-libsdl2 owns it (ARM_ALLOW_MULTI_CORE); build it
# with `make -C ../circle-libsdl2 deps`.
ifeq ($(findstring ARM_ALLOW_MULTI_CORE,$(DEFINE)),)
$(error the payload requires the multicore circle-stdlib world — build it with 'make -C ../circle-libsdl2 deps')
endif

INCLUDE := -I $(ROOT)/circle-libsdl2/include $(CIRCLE_STDLIB_INCLUDES) $(INCLUDE)

$(LIBOSD_NOMAIN): $(MAMEBUILD)/bin/libosd_sdl.a
	@echo "  AR    $@ (libosd_sdl.a minus sdlmain.o)"
	@cp $< $@
	@chmod u+w $@
	@$(AR) d $@ sdlmain.o

# mamemain.cpp compiles the way genie compiled sdlmain.cpp: same cross
# wrapper, and the `release` config's DEFINES/INCLUDES from
# mame/build/projects/sdl/mamespectrum/gmake-rapi-circle/osd_sdl.make.
MAME_CXX = $(ROOT)/mk/cross/aarch64-circle-g++

MAME_DEFINES = -DNDEBUG -DCRLF=2 -DLSB_FIRST -DFLAC__NO_DLL \
	-DPUGIXML_HEADER_ONLY -DMAME_NOASM -DNATIVE_DRC=drcbe_c \
	-DASIO_HAS_THREAD_KEYWORD_EXTENSION -DSDLMAME_NO_X11 -DUSE_XINPUT=0 \
	-DUSE_XINPUT_WII_LIGHTGUN_HACK=0 -DSDLMAME_SDL2=1 -DOSD_SDL \
	-DSDLMAME_UNIX -DUSE_OPENGL=1 -D__STDC_LIMIT_MACROS \
	-D__STDC_FORMAT_MACROS -D__STDC_CONSTANT_MACROS -DBX_CONFIG_DEBUG=0 \
	-DNO_USE_PORTAUDIO -DNO_USE_PULSEAUDIO -DNO_USE_PIPEWIRE \
	-DNO_USE_MIDI -DUSE_QTDEBUG=0

MAME_INCLUDES = \
	-I $(ROOT)/mame/src/osd \
	-I $(ROOT)/mame/3rdparty/asio/include \
	-I $(ROOT)/mame/3rdparty/bgfx/examples/common \
	-I $(ROOT)/mame/3rdparty/bgfx/include \
	-I $(ROOT)/mame/3rdparty/bgfx/3rdparty \
	-I $(ROOT)/mame/3rdparty/bgfx/3rdparty/khronos \
	-I $(ROOT)/mame/3rdparty/bx/include \
	-I $(ROOT)/mame/3rdparty/rapidjson/include \
	-I $(ROOT)/mame/src/emu \
	-I $(ROOT)/mame/src/devices \
	-I $(ROOT)/mame/src/lib \
	-I $(ROOT)/mame/src/lib/util \
	-I $(ROOT)/mame/src/osd/modules/file \
	-I $(ROOT)/mame/src/osd/modules/render \
	-I $(ROOT)/mame/3rdparty \
	-I $(ROOT)/mame/src/osd/sdl \
	-I $(ROOT)/circle-libsdl2/include

# The same -Wall + suppression set genie applies to the osd_sdl project (the
# group that compiled sdlmain.cpp, which mamemain.o replaces). Without these,
# MAME's own headers pulled in by mamemain.cpp warn in our build though they
# never do in MAME's — so we lint MAME's code exactly as MAME does, no more.
MAME_WARNINGS = -Wall -Wno-cast-align -Wno-conversion -Wno-nonnull \
	-Wno-sign-compare -Wno-stringop-overflow -Wno-stringop-overread \
	-Wno-unknown-pragmas -Wno-xor-used-as-pow

mamemain.o: mamemain.cpp
	@echo "  CPP   $@ (MAME env)"
	@$(MAME_CXX) $(MAME_DEFINES) $(MAME_INCLUDES) \
		-O3 -fno-strict-aliasing $(MAME_WARNINGS) \
		-c -o $@ $<

# Overrides Rules.mk's %.d rule, whose Circle flags can't see MAME headers.
mamemain.d: mamemain.cpp
	@$(MAME_CXX) $(MAME_DEFINES) $(MAME_INCLUDES) \
		-M -MT mamemain.o -MT $@ -MF $@ $<

-include $(DEPS)

# pi-mame link rule: pristine Circle tree, TLS-adjacent linker script.
include ../mk/ld/circle-app.mk

# ---------------------------------------------------------------------------
# Per-machine single-purpose images: one byte-patch of the platform binary.
# ---------------------------------------------------------------------------
#
# A downloadable kernel8-<machine>.img is what makes the "embedded, replace a
# dead motherboard" appliance easy — the string changes the factory, never the
# shelf. Each is a verbatim copy of this platform's kernel8-$(PLATFORM).img with
# that machine's defaults string stamped into the 0x800 block by the host
# patcher, which
# reuses the boot picker's one writer (magic seatbelt, capacity enforcement).
#
# patch-defaults is host-native (it edits an image on the build host, it never
# runs on the Pi), so it compiles with the host toolchain, not the cross one.
HOST_CXX ?= c++
patch-defaults: patch-defaults.cpp ../rapi-bootloader/defaultsblock/defaultsblock.cpp \
		../rapi-bootloader/defaultsblock/defaultsblock.h
	@echo "  HOSTCXX $@"
	@$(HOST_CXX) -std=c++17 -I $(CIRCLEHOME)/include \
		-o $@ patch-defaults.cpp ../rapi-bootloader/defaultsblock/defaultsblock.cpp

# The explicit kernel8-$(PLATFORM).img rule (Rules.mk + circle-app.mk) wins for
# the platform binary, so this pattern only ever fires for real machines. Each
# machine is patched from ITS platform's binary ($(TARGET).img, this invocation's
# platform); a machine belonging to another platform is refused, because its
# defaults must never be stamped into the wrong vendor's engine.
kernel8-%.img: $(TARGET).img patch-defaults machines.mk
	@if [ -z "$(MACHINE_STRING_$*)" ]; then \
		echo "unknown machine '$*' — not in machines.mk MACHINE_STRING_*"; \
		exit 1; \
	fi
	@if [ "$(MACHINE_PLATFORM_$*)" != "$(PLATFORM)" ]; then \
		echo "machine '$*' belongs to platform '$(MACHINE_PLATFORM_$*)', not '$(PLATFORM)'"; \
		echo "  build it with: make -C host PLATFORM=$(MACHINE_PLATFORM_$*) $@"; \
		exit 1; \
	fi
	@echo '  PATCH $@ <= [$(MACHINE_STRING_$*)]'
	@cp $(TARGET).img $@
	@./patch-defaults $@ '$(MACHINE_STRING_$*)'

# This platform's machines, each patched from this platform's binary. (The top
# Makefile invokes `machines` once per platform, so the full roster is covered.)
MACHINE_IMAGES = $(patsubst %,kernel8-%.img,$(PLATFORM_MACHINES_$(PLATFORM)))

.PHONY: machines
machines: $(MACHINE_IMAGES)

.PHONY: clean-machines
clean-machines:
	rm -f $(MACHINE_IMAGES) patch-defaults
