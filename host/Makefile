#
# MAME payload: ONE binary per vendor-class platform, ANY machine on it.
#
# This Makefile is scoped to ONE platform and ONE board per invocation
# (PLATFORM=sinclair, RAPI_BOARD=rpi4 by default; the top Makefile drives every
# platform, CI a job per board). Platform is the logical unit — a MAME
# src/mame/<vendor>/ directory, with no crossover — so each platform is its own
# binary. All platforms of a board link the ONE shared mamedrivers engine that
# scripts/build-mame.sh builds once into mame-<board>/build/mamedrivers/rapi-circle;
# this Makefile swaps in a per-platform drivlist it generates itself, so each
# kernel carries only its own machines (build the engine once, link per platform).
# Board picks the MAME source tree (mame-<board>), the circle world
# (circle-libsdl2/circle-stdlib-<board>) and, via mk/cross reading RAPI_BOARD,
# the RASPPI value and -mcpu.
#
# Under the patchable-defaults string (docs/pi-mame-poc2.html) no machine is
# compiled in. kernel8-<platform>.img links that platform's MAME archives +
# circle-libsdl2 + circle-stdlib once, carrying the 0x800 defaults block; the
# machine name and its media ride that block as plain text, written before boot.
#
# Every image lands under build/<board>/ (RAPI_BOARD, default rpi4), so the
# three boards' outputs never collide:
#   make PLATFORM=<p>        -> build/<board>/kernel8-<p>.img — the platform
#                               binary. Unpatched (empty block) it IS that
#                               platform's no-options kernel: MAME boots its own
#                               system-selection list. Ships on the platform card
#                               as pi-mame-core-<board>.img, chain-booted by the picker.
#   make PLATFORM=<p> machines
#                            -> build/<board>/kernel8-<machine>.img for every
#                               machine of that platform, each a copy of
#                               build/<board>/kernel8-<p>.img with the machine's
#                               defaults string patched in at 0x800 (host tool
#                               patch-defaults). ONE link per platform, then one
#                               byte-patch per machine — no per-machine compile.
#   make PLATFORM=<p> build/<board>/kernel8-<machine>.img -> that single image.
#   make clean-board         -> drop just this board's build/<board>/ tree.
#
# The per-machine facts (which platform a machine belongs to, its defaults
# string, its asset dependencies) are data in machines.mk, not compile-time
# bakes. Framebuffer geometry is NOT here: it is Circle boot config (width=/
# height= in the SD card's FAT-root cmdline.txt), set PER REGION, not per
# machine — cmdline-pal.txt is the PAL canvas (720x576) every PAL machine
# fills, cmdline-ntsc.txt the NTSC canvas (720x480) the American 60Hz machines
# fill, the way a CRT was filled.
#
# Prerequisite: scripts/build-mame.sh <board> has produced
# mame-<board>/build/mamedrivers/rapi-circle/, and circle-libsdl2 has built the board's
# world + libSDL2-<board>.a (make -C ../circle-libsdl2 deps).
#

# Board selects the circle world, the MAME source tree, and (via mk/cross,
# which reads RAPI_BOARD from the environment) the RASPPI value and -mcpu. Each
# board's newlib+libc++ sysroot is baked per architecture, so the kernel is
# per-board; the three build in complete isolation (own tree, own world). One
# board per invocation — CI dispatches a job per board. Default rpi4.
RAPI_BOARD ?= rpi4
export RAPI_BOARD

include ../circle-libsdl2/circle-stdlib-$(RAPI_BOARD)/Config.mk
include machines.mk

ROOT = ..

# Board-scoped build directory. EVERY artifact this invocation generates —
# the fixed-name objects (kernel.o, main.o, …), the per-platform driver
# archives and drivlist, the host patch tool, and the final .elf/.map/.lst/.img
# — lands under build/<board>/. The fixed-name objects are board-specific
# (compiled against a per-board circle world, -mcpu and -DRASPPI) yet share one
# name across boards, so a flat build dir silently relinks one board's stale
# objects into another board's kernel (a corrupt image, no build error). A dir
# per board keeps all three boards' outputs isolated: no `make clean` between
# boards, each board its own cacheable unit, and building one never touches a
# sibling board's images. Mirrors circle-libsdl2's build/<board>/ isolation.
OBJDIR = build/$(RAPI_BOARD)

# The platform this invocation links. Every driver-scoped path below is scoped
# to it; the ENGINE it links against is the board's shared mamedrivers tree.
PLATFORM ?= sinclair
SUBTARGET := $(PLATFORM_SUBTARGET_$(PLATFORM))
ifeq ($(SUBTARGET),)
$(error unknown PLATFORM '$(PLATFORM)' — not in machines.mk PLATFORMS ($(PLATFORMS)))
endif

# This board's MAME source tree, and its ONE shared mamedrivers engine tree. The
# engine + 3rdparty + superset device closure are built once per board by
# scripts/build-mame.sh (SUBTARGET=$(MAMEDRIVERS_SUBTARGET)); every platform kernel of
# this board links that same tree and swaps in its own per-platform drivlist.
MAMESRC   = $(ROOT)/mame-$(RAPI_BOARD)
MAMEBUILD = $(MAMESRC)/build/mamedrivers/rapi-circle

TARGET = $(OBJDIR)/kernel8-$(PLATFORM)

# No machine is baked: the kernel object is the same for every image and every
# platform. The defaults receiver (defaults.o) carries the 0x800 block and the
# entry trampoline the linker script pins. All board-scoped, under $(OBJDIR).
OBJS = $(addprefix $(OBJDIR)/,main.o kernel.o defaults.o mamemain.o circlefile.o circle_stubs.o xthreading.o)

STANDARD = -std=gnu++23 -Wno-volatile

# The three objects that link directly into the final binary. mame.o and
# version.o are SOURCES-invariant — the same for every platform — so they come
# straight from the board's shared mamedrivers tree. drivlist.o is the ONE per-platform
# object: DRIVLIST_OBJ is generated below from this platform's SOURCES only, so
# it references just this platform's machines and the linker pulls only those
# from the shared mamedrivers archives (the mamedrivers's own drivlist.o is never linked).
MAME_OBJS = \
	$(MAMEBUILD)/obj/Release/src/mame/mame.o \
	$(DRIVLIST_OBJ) \
	$(MAMEBUILD)/obj/Release/generated/version.o

# Archive surgery, mame tree untouched:
#  - libosd_sdl.a ships sdlmain.o (MAME's own main() + sdl_entered_debugger,
#    which mamemain.cpp provides instead);
#  - libocore_sdl.a ships posixfile.o/posixdir.o (the osd_file surface, which
#    circlefile.cpp reimplements over the shim's core-0 I/O service — the core
#    split's file seam: the cut is osd_file, never below. MAME runs on core 1
#    and must not touch FatFs directly).
# Both are local copies with the member deleted, named per platform so the
# platforms' copies never collide in this shared build directory.
LIBOSD_NOMAIN   = $(OBJDIR)/libosd_sdl-nomain-$(PLATFORM).a
LIBOCORE_NOFILE = $(OBJDIR)/libocore_sdl-nofile-$(PLATFORM).a

# libprecompile.a is excluded (PCH carrier, nothing to link). libqtdbg_sdl.a
# stays in: built with USE_QTDEBUG=0 it holds only the not-supported debugger
# module (DEBUG_QT), which osdobj_common.cpp registers unconditionally. The
# driver archives are the mamedrivers set (bin/mame_$(MAMEDRIVERS_SUBTARGET)/) carrying every
# platform's drivers and the superset device closure; the engine archives
# (bin/*.a) are SOURCES-invariant. Both are shared by every platform of this
# board — the per-platform drivlist.o alone decides which members link in.
MAME_ARCHIVES = \
	$(wildcard $(MAMEBUILD)/bin/mame_$(MAMEDRIVERS_SUBTARGET)/*.a) \
	$(filter-out %/libosd_sdl.a %/libocore_sdl.a %/libprecompile.a, \
		$(wildcard $(MAMEBUILD)/bin/*.a))

# Rules.mk's link recipe already wraps $(LIBS) in --start-group/--end-group,
# which covers MAME's mutually referential archives. LIBS is also part of
# the .img rule's prerequisite list: file paths only, defined before Rules.mk.
# liblibcxx-threading.a is filtered out: xthreading.o provides the complete
# external-threading ABI (objects always beat archive members), giving MAME
# hardware threads pinned to cores by pure link substitution — no
# circle-stdlib change.
LIBS = $(MAME_OBJS) \
	$(LIBOSD_NOMAIN) \
	$(LIBOCORE_NOFILE) \
	$(MAME_ARCHIVES) \
	$(ROOT)/circle-libsdl2/libSDL2-$(RAPI_BOARD).a \
	$(CIRCLEHOME)/lib/sound/libsound.a \
	$(filter-out %/liblibcxx-threading.a,$(CIRCLE_STDLIB_LIBS))

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

$(LIBOSD_NOMAIN): $(MAMEBUILD)/bin/libosd_sdl.a | $(OBJDIR)
	@echo "  AR    $@ (libosd_sdl.a minus sdlmain.o)"
	@cp $< $@
	@chmod u+w $@
	@$(AR) d $@ sdlmain.o

$(LIBOCORE_NOFILE): $(MAMEBUILD)/bin/libocore_sdl.a | $(OBJDIR)
	@echo "  AR    $@ (libocore_sdl.a minus posixfile.o posixdir.o)"
	@cp $< $@
	@chmod u+w $@
	@$(AR) d $@ posixfile.o posixdir.o

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
	-I $(MAMESRC)/src/osd \
	-I $(MAMESRC)/3rdparty/asio/include \
	-I $(MAMESRC)/3rdparty/bgfx/examples/common \
	-I $(MAMESRC)/3rdparty/bgfx/include \
	-I $(MAMESRC)/3rdparty/bgfx/3rdparty \
	-I $(MAMESRC)/3rdparty/bgfx/3rdparty/khronos \
	-I $(MAMESRC)/3rdparty/bx/include \
	-I $(MAMESRC)/3rdparty/rapidjson/include \
	-I $(MAMESRC)/src/emu \
	-I $(MAMESRC)/src/frontend/mame \
	-I $(MAMESRC)/src/devices \
	-I $(MAMESRC)/src/lib \
	-I $(MAMESRC)/src/lib/util \
	-I $(MAMESRC)/src/osd/modules/file \
	-I $(MAMESRC)/src/osd/modules/render \
	-I $(MAMESRC)/3rdparty \
	-I $(MAMESRC)/src/osd/sdl \
	-I $(ROOT)/circle-libsdl2/include

# The same -Wall + suppression set genie applies to the osd_sdl project (the
# group that compiled sdlmain.cpp, which mamemain.o replaces). Without these,
# MAME's own headers pulled in by mamemain.cpp warn in our build though they
# never do in MAME's — so we lint MAME's code exactly as MAME does, no more.
MAME_WARNINGS = -Wall -Wno-cast-align -Wno-conversion -Wno-nonnull \
	-Wno-sign-compare -Wno-stringop-overflow -Wno-stringop-overread \
	-Wno-unknown-pragmas -Wno-xor-used-as-pow

$(OBJDIR)/mamemain.o: mamemain.cpp | $(OBJDIR)
	@echo "  CPP   $@ (MAME env)"
	@$(MAME_CXX) $(MAME_DEFINES) $(MAME_INCLUDES) \
		-O3 -fno-strict-aliasing $(MAME_WARNINGS) \
		-c -o $@ $<

# Overrides Rules.mk's %.d rule, whose Circle flags can't see MAME headers.
$(OBJDIR)/mamemain.d: mamemain.cpp | $(OBJDIR)
	@$(MAME_CXX) $(MAME_DEFINES) $(MAME_INCLUDES) \
		-M -MT $(OBJDIR)/mamemain.o -MT $@ -MF $@ $<

# circlefile.cpp is MAME's osd_file/osd::directory surface reimplemented over
# the shim's core-0 I/O service, so it compiles in the same MAME environment
# as the code it replaces (posixfile.cpp), not the Circle one.
$(OBJDIR)/circlefile.o: circlefile.cpp | $(OBJDIR)
	@echo "  CPP   $@ (MAME env)"
	@$(MAME_CXX) $(MAME_DEFINES) $(MAME_INCLUDES) \
		-O3 -fno-strict-aliasing $(MAME_WARNINGS) \
		-c -o $@ $<

$(OBJDIR)/circlefile.d: circlefile.cpp | $(OBJDIR)
	@$(MAME_CXX) $(MAME_DEFINES) $(MAME_INCLUDES) \
		-M -MT $(OBJDIR)/circlefile.o -MT $@ -MF $@ $<

# --- Per-platform drivlist, generated against the shared mamedrivers engine ---
# The board's mamedrivers build compiled every platform's drivers into shared
# archives. To link a kernel carrying only THIS platform's machines, regenerate
# MAME's own drivlist for just this platform's SOURCES — the exact two makedep.py
# steps genie runs for a SOURCES= build, but standalone, touching no engine:
# `sourcesfilter` turns the platform's driver files into a .flt; `driverlist`
# turns mame.lst + that .flt into drivlist.cpp. The object references only this
# platform's drivers, so the linker pulls only those (and their device closure)
# from the mamedrivers archives — the kernel stays the size it always was.
PYTHON  ?= python3
MAKEDEP  = $(MAMESRC)/scripts/build/makedep.py
MAMELST  = $(MAMESRC)/src/mame/mame.lst
DRIVLIST_FLT = $(OBJDIR)/drivlist-$(PLATFORM).flt
DRIVLIST_SRC = $(OBJDIR)/drivlist-$(PLATFORM).cpp
DRIVLIST_OBJ = $(OBJDIR)/drivlist-$(PLATFORM).o

$(DRIVLIST_FLT): machines.mk $(MAMELST) | $(OBJDIR)
	@echo "  FLT   $@ ($(PLATFORM) sources)"
	@$(PYTHON) $(MAKEDEP) -r $(MAMESRC) sourcesfilter -l $(MAMELST) \
		$(PLATFORM_SOURCES_$(PLATFORM)) > $@

$(DRIVLIST_SRC): $(DRIVLIST_FLT) $(MAMELST) | $(OBJDIR)
	@echo "  DRVL  $@"
	@$(PYTHON) $(MAKEDEP) -r $(MAMESRC) driverlist $(MAMELST) -f $(DRIVLIST_FLT) > $@

# Compiled in the same MAME environment as mamemain.o (drivlist.cpp is stock
# generated MAME source: emu.h + the driver_list array). Board-specific tuning
# (-mcpu, -DRASPPI) rides the cross wrapper via RAPI_BOARD, so switching boards
# in this dir needs a clean first, exactly as the fixed-name Circle objects do.
$(DRIVLIST_OBJ): $(DRIVLIST_SRC) | $(OBJDIR)
	@echo "  CPP   $@ (MAME env, $(PLATFORM) drivlist)"
	@$(MAME_CXX) $(MAME_DEFINES) $(MAME_INCLUDES) \
		-O3 -fno-strict-aliasing $(MAME_WARNINGS) \
		-c -o $@ $<

# Board-scoped compile into $(OBJDIR) for the plain (Circle-env) objects and
# their deps — kernel.o, main.o, defaults.o, circle_stubs.o, xthreading.o. These
# more-specific pattern rules win over Rules.mk's in-place %.o/%.d (GNU make
# prefers the shortest stem), so nothing lands in the source dir. The MAME-env
# objects (mamemain.o, circlefile.o, the drivlist) have explicit rules above
# that override these for their targets.
$(OBJDIR)/%.o: %.cpp | $(OBJDIR)
	@echo "  CPP   $@"
	@$(CPP) $(CPPFLAGS) -c -o $@ $<

$(OBJDIR)/%.d: %.cpp | $(OBJDIR)
	@$(CPP) $(CPPFLAGS) -M -MG -MT $(@:.d=.o) -MT $@ -MF $@ $<

$(OBJDIR):
	@mkdir -p $(OBJDIR)

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
PATCH_DEFAULTS = $(OBJDIR)/patch-defaults
$(PATCH_DEFAULTS): patch-defaults.cpp ../rapi-bootloader/defaultsblock/defaultsblock.cpp \
		../rapi-bootloader/defaultsblock/defaultsblock.h | $(OBJDIR)
	@echo "  HOSTCXX $@"
	@$(HOST_CXX) -std=c++17 -I $(CIRCLEHOME)/include \
		-o $@ patch-defaults.cpp ../rapi-bootloader/defaultsblock/defaultsblock.cpp

# The explicit kernel8-$(PLATFORM).img rule (Rules.mk + circle-app.mk) wins for
# the platform binary, so this pattern only ever fires for real machines. Each
# machine is patched from ITS platform's binary ($(TARGET).img, this invocation's
# platform); a machine belonging to another platform is refused, because its
# defaults must never be stamped into the wrong vendor's engine.
$(OBJDIR)/kernel8-%.img: $(TARGET).img $(PATCH_DEFAULTS) machines.mk | $(OBJDIR)
	@if [ -z "$(MACHINE_STRING_$*)" ]; then \
		echo "unknown machine '$*' — not in machines.mk MACHINE_STRING_*"; \
		exit 1; \
	fi
	@if [ "$(MACHINE_PLATFORM_$*)" != "$(PLATFORM)" ]; then \
		echo "machine '$*' belongs to platform '$(MACHINE_PLATFORM_$*)', not '$(PLATFORM)'"; \
		echo "  build it with: make -C host RAPI_BOARD=$(RAPI_BOARD) PLATFORM=$(MACHINE_PLATFORM_$*) $@"; \
		exit 1; \
	fi
	@echo '  PATCH $@ <= [$(MACHINE_STRING_$*)]'
	@cp $(TARGET).img $@
	@$(PATCH_DEFAULTS) $@ '$(MACHINE_STRING_$*)'

# This platform's machines, each patched from this platform's binary. (The top
# Makefile invokes `machines` once per platform, so the full roster is covered.)
MACHINE_IMAGES = $(patsubst %,$(OBJDIR)/kernel8-%.img,$(PLATFORM_MACHINES_$(PLATFORM)))

.PHONY: machines
machines: $(MACHINE_IMAGES)

.PHONY: clean-machines
clean-machines:
	rm -f $(MACHINE_IMAGES) $(PATCH_DEFAULTS) \
		$(DRIVLIST_FLT) $(DRIVLIST_SRC) $(DRIVLIST_OBJ) \
		$(LIBOSD_NOMAIN) $(LIBOCORE_NOFILE)

# Board-scoped clean: drop just THIS board's entire build tree (build/<board>/),
# leaving the sibling boards' images and objects untouched. The whole reason for
# the per-board dir — rebuild one board from scratch without disturbing another.
.PHONY: clean-board
clean-board:
	rm -rf $(OBJDIR)
