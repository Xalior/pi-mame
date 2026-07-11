#
# MAME payload kernel: links MAME's archives + circle-libsdl2 + circle-stdlib
# into one image per personality — the machine and its fixed facts are baked.
#
#   make MACHINE=<name>   -> kernel8-<name>.img — one image per machine.
#                            The machines are the MACHINE_DEFS_* table below,
#                            documented per machine in docs/sinclair/ and
#                            docs/amstrad/. Media a machine cannot boot
#                            without is baked into its defs: the Next boards
#                            attach /next/next.img as their SD card
#                            (MAME_HARDDISK); the CPC+ range boots from the
#                            game-free /carts/sysukpd.bin cartridge
#                            (MAME_CART).
#   make MACHINE=picker   -> kernel8-picker.img (nothing baked: MAME boots
#                            into its system list; the family is the menu)
#
# Framebuffer geometry is NOT in here: it is Circle boot config (width=/
# height= in the SD card's FAT-root cmdline.txt), set PER REGION, not per
# machine — cmdline-pal.txt is the PAL canvas (720x576) every PAL machine
# fills, cmdline-ntsc.txt the NTSC canvas (720x480) the American 60Hz
# machines fill, the way a CRT was filled.
#
# Prerequisite: scripts/build-mame.sh has produced mame/build/rapi-circle/.
#

include ../circle-stdlib/Config.mk

ROOT = ..
MAMEBUILD = $(ROOT)/mame/build/rapi-circle

MACHINE ?= spectrum

# Per-personality fixed facts, compiled into the kernel (kernel.cpp).
MACHINE_DEFS_spectrum = -DMAME_MACHINE='"spectrum"'
MACHINE_DEFS_spec128  = -DMAME_MACHINE='"spec128"'
MACHINE_DEFS_specpls2 = -DMAME_MACHINE='"specpls2"'
MACHINE_DEFS_specpl2a = -DMAME_MACHINE='"specpl2a"'
MACHINE_DEFS_specpls3 = -DMAME_MACHINE='"specpls3"'
MACHINE_DEFS_tbblue   = -DMAME_MACHINE='"tbblue"' -DMAME_HARDDISK='"/next/next.img"'
MACHINE_DEFS_specnext_ks1 = -DMAME_MACHINE='"specnext_ks1"' -DMAME_HARDDISK='"/next/next.img"'
MACHINE_DEFS_specnext_ks2 = -DMAME_MACHINE='"specnext_ks2"' -DMAME_HARDDISK='"/next/next.img"'
MACHINE_DEFS_specnext_ks3 = -DMAME_MACHINE='"specnext_ks3"' -DMAME_HARDDISK='"/next/next.img"'
MACHINE_DEFS_zx80     = -DMAME_MACHINE='"zx80"'
MACHINE_DEFS_zx81     = -DMAME_MACHINE='"zx81"'
MACHINE_DEFS_tc2048   = -DMAME_MACHINE='"tc2048"'
MACHINE_DEFS_ts2068   = -DMAME_MACHINE='"ts2068"'
MACHINE_DEFS_ts1000   = -DMAME_MACHINE='"ts1000"'
MACHINE_DEFS_ts1500   = -DMAME_MACHINE='"ts1500"'
MACHINE_DEFS_pentagon = -DMAME_MACHINE='"pentagon"'
MACHINE_DEFS_scorpio  = -DMAME_MACHINE='"scorpio"'
MACHINE_DEFS_atmtb2   = -DMAME_MACHINE='"atmtb2"'
MACHINE_DEFS_pentevo  = -DMAME_MACHINE='"pentevo"'
MACHINE_DEFS_tsconf   = -DMAME_MACHINE='"tsconf"'
MACHINE_DEFS_elwro800 = -DMAME_MACHINE='"elwro800"'
MACHINE_DEFS_byte     = -DMAME_MACHINE='"byte"'
MACHINE_DEFS_cpc464   = -DMAME_MACHINE='"cpc464"'
MACHINE_DEFS_cpc664   = -DMAME_MACHINE='"cpc664"'
MACHINE_DEFS_cpc6128  = -DMAME_MACHINE='"cpc6128"'
MACHINE_DEFS_cpc464p  = -DMAME_MACHINE='"cpc464p"' -DMAME_CART='"/carts/sysukpd.bin"'
MACHINE_DEFS_cpc6128p = -DMAME_MACHINE='"cpc6128p"' -DMAME_CART='"/carts/sysukpd.bin"'
MACHINE_DEFS_gx4000   = -DMAME_MACHINE='"gx4000"' -DMAME_CART='"/carts/sysukpd.bin"'
MACHINE_DEFS_kccomp   = -DMAME_MACHINE='"kccomp"'
MACHINE_DEFS_nc100    = -DMAME_MACHINE='"nc100"'
MACHINE_DEFS_nc200    = -DMAME_MACHINE='"nc200"'
MACHINE_DEFS_sprinter = -DMAME_MACHINE='"sprinter"'
MACHINE_DEFS_pc1512   = -DMAME_MACHINE='"pc1512"'
MACHINE_DEFS_picker   = -DMAME_PICKER

KERNEL_DEFS = $(MACHINE_DEFS_$(MACHINE))
ifeq ($(strip $(KERNEL_DEFS)),)
$(error unknown MACHINE '$(MACHINE)' — spectrum, spec128, specpls2, specpl2a, specpls3, tbblue, specnext_ks1, specnext_ks2, specnext_ks3, zx80, zx81, tc2048, ts2068, ts1000, ts1500, pentagon, scorpio, atmtb2, pentevo, tsconf, elwro800, byte, sprinter, pc1512, gx4000, or picker)
endif

TARGET = kernel8-$(MACHINE)

OBJS = main.o kernel-$(MACHINE).o mamemain.o circle_stubs.o

STANDARD = -std=gnu++23 -Wno-volatile

# The three objects genie links directly into the final binary.
MAME_OBJS = \
	$(MAMEBUILD)/obj/Release/src/mame/mame.o \
	$(MAMEBUILD)/obj/Release/generated/mame/spectrum/drivlist.o \
	$(MAMEBUILD)/obj/Release/generated/version.o

# libosd_sdl.a ships sdlmain.o (MAME's own main() + sdl_entered_debugger,
# which mamemain.cpp provides instead). Link a local copy with that member
# deleted; the mame tree stays untouched.
LIBOSD_NOMAIN = libosd_sdl-nomain.a

# libprecompile.a is excluded (PCH carrier, nothing to link). libqtdbg_sdl.a
# stays in: built with USE_QTDEBUG=0 it holds only the not-supported debugger
# module (DEBUG_QT), which osdobj_common.cpp registers unconditionally.
MAME_ARCHIVES = \
	$(wildcard $(MAMEBUILD)/bin/mame_spectrum/*.a) \
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

include $(CIRCLEHOME)/Rules.mk

# MAME is multicore by design: this kernel must link a multicore-configured
# circle-stdlib world (configure with -o ARM_ALLOW_MULTI_CORE).
ifeq ($(findstring ARM_ALLOW_MULTI_CORE,$(DEFINE)),)
$(error the payload requires a multicore circle-stdlib world — reconfigure circle-stdlib with -o ARM_ALLOW_MULTI_CORE)
endif

INCLUDE := -I $(ROOT)/circle-libsdl2/include $(CIRCLE_STDLIB_INCLUDES) $(INCLUDE)

# The kernel object is per-personality: the baked facts live in it, and
# distinct object names keep the personalities from inheriting each
# other's bake.
kernel-$(MACHINE).o: kernel.cpp
	@echo "  CPP   $@ ($(KERNEL_DEFS))"
	@$(CPP) $(CPPFLAGS) $(KERNEL_DEFS) -c -o $@ $<

kernel-$(MACHINE).d: kernel.cpp
	@$(CPP) $(CPPFLAGS) $(KERNEL_DEFS) -M -MG -MT kernel-$(MACHINE).o -MT $@ -MF $@ $<

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

mamemain.o: mamemain.cpp
	@echo "  CPP   $@ (MAME env)"
	@$(MAME_CXX) $(MAME_DEFINES) $(MAME_INCLUDES) \
		-O3 -fno-strict-aliasing -Wall -Wno-unknown-pragmas \
		-c -o $@ $<

# Overrides Rules.mk's %.d rule, whose Circle flags can't see MAME headers.
mamemain.d: mamemain.cpp
	@$(MAME_CXX) $(MAME_DEFINES) $(MAME_INCLUDES) \
		-M -MT mamemain.o -MT $@ -MF $@ $<

-include $(DEPS)

# pi-mame link rule: pristine Circle tree, TLS-adjacent linker script
include ../mk/ld/circle-app.mk
