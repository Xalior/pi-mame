#
# machines.mk — the per-machine facts, one place.
#
# Under the patchable-defaults string there is ONE binary per vendor-class
# platform (kernel8-<platform>.img): no machine is compiled in. Everything that
# used to be a per-machine compile-time bake is now data here —
#
#   PLATFORM_MACHINES_<platform>  which machines belong to which card
#   PLATFORM_SUBTARGET_<platform> the platform's isolated MAME SUBTARGET
#   PLATFORM_SOURCES_<platform>   the platform's driver SOURCES (only that
#                                 vendor's src/mame/<vendor>/ files)
#   MACHINE_PLATFORM_<machine>    the vendor-class a machine belongs to
#                                 (derived from PLATFORM_MACHINES_*, below)
#   MACHINE_STRING_<machine>      the defaults-string patched into the block
#                                 (machine name + its media: -hard1 / -cart)
#   MACHINE_ASSETS_<machine>      the assets.manifest asset names the machine
#                                 needs — used to DERIVE its free/public tier
#                                 (a machine is free only if EVERY asset it
#                                 needs is free-tier; scripts/gen-bootmenu.sh
#                                 reads the per-asset tier from the manifest)
#
# PLATFORM IS THE LOGICAL UNIT — a MAME src/mame/<vendor>/ directory, and
# there is never crossover. Each platform is its own binary
# (kernel8-<platform>.img), built from its own isolated MAME archive tree
# (scripts/build-mame.sh gives each platform its own SUBTARGET, its own SOURCES,
# and its own BUILDDIR mame/build/<platform> — because MAME's genie build output
# is scoped by TARGETOS, not by SUBTARGET, so two platforms sharing one tree
# would share their engine libraries and one rebuild could silently invalidate
# the other). A machine's single-purpose image is patched from ITS platform's
# binary, never a shared one.
#
# host/Makefile includes this to bake per-machine images by patching, and
# scripts/gen-bootmenu.sh reads it (via `make -f machines.mk print-VAR`) to
# generate each platform card's bootmenu.cfg.
#
# The MACHINE_STRING media paths mirror what those machines mount on the
# card: the Next boards attach /next/next.img as their SD card; the CPC+
# range boots the game-free /carts/sysukpd.bin cartridge. The MACHINE_ASSETS
# lists mirror docs/sinclair/README.md and docs/amstrad/README.md (romset +
# "Extra assets"): the Russian clones share spec128.zip + betadisk.zip, the
# Next boards share tbblue.zip + next.img, sprinter needs kb_ms_natural.zip,
# pc1512 needs pc1512kb.zip, and the CPC+ range needs only sysukpd.bin.

PLATFORMS = sinclair amstrad commodore

PLATFORM_MACHINES_sinclair = spectrum spec128 specpls2 specpl2a specpls3 \
	tbblue specnext_ks1 specnext_ks2 specnext_ks3 zx80 zx81 tc2048 ts2068 \
	ts1000 ts1500 pentagon scorpio atmtb2 pentevo tsconf elwro800 byte sprinter

PLATFORM_MACHINES_amstrad = cpc464 cpc664 cpc6128 cpc464p cpc6128p gx4000 \
	kccomp nc100 nc200 pc1512

PLATFORM_MACHINES_commodore = c64 c64p c64_jp c64_se c64c c64cp c64g c64c_es \
	c64c_se c64gs sx64 sx64p

# All machines, every platform — the roster `make kernels` bakes and CI verifies.
MACHINES = $(foreach p,$(PLATFORMS),$(PLATFORM_MACHINES_$(p)))

# The reverse map: which platform a machine belongs to. Derived, never hand-
# maintained — the host Makefile reads MACHINE_PLATFORM_<m> to pick the machine's
# platform binary and its isolated MAME tree.
$(foreach p,$(PLATFORMS),$(foreach m,$(PLATFORM_MACHINES_$(p)),\
	$(eval MACHINE_PLATFORM_$(m) := $(p))))

# --- Per-platform isolated MAME build (own SUBTARGET, own SOURCES) ---
#
# The SUBTARGET names the platform's archive tree (mame/build/<platform>/
# rapi-circle/bin/mame_<subtarget>/) and its generated drivlist; it is a
# SOURCES-based subtarget, so the name is ours to choose — one per vendor-class.
# The SOURCES list is ONLY that vendor's src/mame/<vendor>/ drivers: there is no
# crossover, and a platform's rebuild recompiles only its own drivers. The list
# is space-separated here (build-mame.sh joins it with commas for MAME's
# SOURCES= — a comma-separated value cannot carry make's line-continuation
# spaces, a space-separated one can).
PLATFORM_SUBTARGET_sinclair  = sinclair
PLATFORM_SUBTARGET_amstrad   = amstrad
PLATFORM_SUBTARGET_commodore = commodore

PLATFORM_SOURCES_sinclair = \
	src/mame/sinclair/spectrum.cpp src/mame/sinclair/spec128.cpp \
	src/mame/sinclair/next/specnext.cpp src/mame/sinclair/specpls3.cpp \
	src/mame/sinclair/zx.cpp src/mame/sinclair/timex.cpp \
	src/mame/sinclair/pentagon.cpp src/mame/sinclair/scorpion.cpp \
	src/mame/sinclair/atm.cpp src/mame/sinclair/evo/pentevo.cpp \
	src/mame/sinclair/evo/tsconf.cpp src/mame/sinclair/elwro800.cpp \
	src/mame/sinclair/byte.cpp src/mame/sinclair/sprinter.cpp

PLATFORM_SOURCES_amstrad = \
	src/mame/amstrad/amstrad.cpp src/mame/amstrad/nc.cpp \
	src/mame/amstrad/pc1512.cpp

PLATFORM_SOURCES_commodore = \
	src/mame/commodore/c64.cpp

# --- Sinclair defaults strings ---
MACHINE_STRING_spectrum     = spectrum
MACHINE_STRING_spec128      = spec128
MACHINE_STRING_specpls2     = specpls2
MACHINE_STRING_specpl2a     = specpl2a
MACHINE_STRING_specpls3     = specpls3
MACHINE_STRING_tbblue       = tbblue -hard1 /next/next.img
MACHINE_STRING_specnext_ks1 = specnext_ks1 -hard1 /next/next.img
MACHINE_STRING_specnext_ks2 = specnext_ks2 -hard1 /next/next.img
MACHINE_STRING_specnext_ks3 = specnext_ks3 -hard1 /next/next.img
MACHINE_STRING_zx80         = zx80
MACHINE_STRING_zx81         = zx81
MACHINE_STRING_tc2048       = tc2048
MACHINE_STRING_ts2068       = ts2068
MACHINE_STRING_ts1000       = ts1000
MACHINE_STRING_ts1500       = ts1500
MACHINE_STRING_pentagon     = pentagon
MACHINE_STRING_scorpio      = scorpio
MACHINE_STRING_atmtb2       = atmtb2
MACHINE_STRING_pentevo      = pentevo
MACHINE_STRING_tsconf       = tsconf
MACHINE_STRING_elwro800     = elwro800
MACHINE_STRING_byte         = byte
MACHINE_STRING_sprinter     = sprinter

# --- Amstrad defaults strings ---
MACHINE_STRING_cpc464       = cpc464
MACHINE_STRING_cpc664       = cpc664
MACHINE_STRING_cpc6128      = cpc6128
MACHINE_STRING_cpc464p      = cpc464p -cart /carts/sysukpd.bin
MACHINE_STRING_cpc6128p     = cpc6128p -cart /carts/sysukpd.bin
MACHINE_STRING_gx4000       = gx4000 -cart /carts/sysukpd.bin
MACHINE_STRING_kccomp       = kccomp
MACHINE_STRING_nc100        = nc100
MACHINE_STRING_nc200        = nc200
MACHINE_STRING_pc1512       = pc1512

# --- Commodore defaults strings ---
# The C64 line's IEC serial bus defaults to a C1541 drive at device 8, whose
# own romset is then required just to reach BASIC (hardware-proven). A real
# machine with nothing plugged into the serial port is a completely valid,
# far more common configuration: device 8 is baked empty. The "" token is the
# defaults-string spelling of an empty argv entry (defaults.cpp maps it) —
# MAME accepts only an empty value to empty a slot, "none" is rejected.
MACHINE_STRING_c64          = c64 -iec8 ""
MACHINE_STRING_c64p         = c64p -iec8 ""
MACHINE_STRING_c64_jp       = c64_jp -iec8 ""
MACHINE_STRING_c64_se       = c64_se -iec8 ""
MACHINE_STRING_c64c         = c64c -iec8 ""
MACHINE_STRING_c64cp        = c64cp -iec8 ""
MACHINE_STRING_c64g         = c64g -iec8 ""
MACHINE_STRING_c64c_es      = c64c_es -iec8 ""
MACHINE_STRING_c64c_se      = c64c_se -iec8 ""
MACHINE_STRING_c64gs        = c64gs -iec8 ""
# The SX-64 is the portable C64 with a built-in 1541: ntsc_sx replaces the
# iec8 slot's default with the internal sx1541 drive. It is still the iec8
# slot, emptied the same way — device 8 is baked empty, so no drive romset is
# required to reach BASIC (the internal drive absent is a documented quirk,
# not a real hardware configuration, but it is the smallest honest parcel and
# it boots to the SX kernal's sign-on).
MACHINE_STRING_sx64         = sx64 -iec8 ""
# The PAL SX-64 (rom_sx64p == rom_sx64): pal_sx replaces the same iec8 slot's
# default with the built-in sx1541 drive, emptied identically via -iec8 "".
MACHINE_STRING_sx64p        = sx64p -iec8 ""

# --- Sinclair asset dependencies (manifest asset names) ---
MACHINE_ASSETS_spectrum     = spectrum
MACHINE_ASSETS_spec128      = spec128
MACHINE_ASSETS_specpls2     = specpls2
MACHINE_ASSETS_specpl2a     = specpl2a
MACHINE_ASSETS_specpls3     = specpls3
MACHINE_ASSETS_tbblue       = tbblue next
MACHINE_ASSETS_specnext_ks1 = tbblue next
MACHINE_ASSETS_specnext_ks2 = tbblue next
MACHINE_ASSETS_specnext_ks3 = tbblue next
MACHINE_ASSETS_zx80         = zx80
MACHINE_ASSETS_zx81         = zx81
MACHINE_ASSETS_tc2048       = tc2048
MACHINE_ASSETS_ts2068       = ts2068
MACHINE_ASSETS_ts1000       = ts1000
MACHINE_ASSETS_ts1500       = ts1500
MACHINE_ASSETS_pentagon     = pentagon spec128 betadisk
MACHINE_ASSETS_scorpio      = scorpio spec128 betadisk
MACHINE_ASSETS_atmtb2       = atmtb2 spec128 betadisk
MACHINE_ASSETS_pentevo      = pentevo spec128 betadisk
MACHINE_ASSETS_tsconf       = tsconf
MACHINE_ASSETS_elwro800     = elwro800
MACHINE_ASSETS_byte         = byte
MACHINE_ASSETS_sprinter     = sprinter kb_ms_natural

# --- Amstrad asset dependencies (manifest asset names) ---
MACHINE_ASSETS_cpc464       = cpc464
MACHINE_ASSETS_cpc664       = cpc664
MACHINE_ASSETS_cpc6128      = cpc6128
MACHINE_ASSETS_cpc464p      = sysukpd
MACHINE_ASSETS_cpc6128p     = sysukpd
MACHINE_ASSETS_gx4000       = sysukpd
MACHINE_ASSETS_kccomp       = kccomp
MACHINE_ASSETS_nc100        = nc100
MACHINE_ASSETS_nc200        = nc200
MACHINE_ASSETS_pc1512       = pc1512 pc1512kb

# --- Commodore asset dependencies (manifest asset names) ---
MACHINE_ASSETS_c64          = c64
MACHINE_ASSETS_c64p         = c64p
MACHINE_ASSETS_c64_jp       = c64_jp
MACHINE_ASSETS_c64_se       = c64_se
MACHINE_ASSETS_c64c         = c64c
MACHINE_ASSETS_c64cp        = c64cp
MACHINE_ASSETS_c64g         = c64g
MACHINE_ASSETS_c64c_es      = c64c_es
MACHINE_ASSETS_c64c_se      = c64c_se
MACHINE_ASSETS_c64gs        = c64gs
MACHINE_ASSETS_sx64         = sx64
MACHINE_ASSETS_sx64p        = sx64p

# Query helper: `make -f machines.mk -s print-MACHINE_STRING_spectrum`.
# Lets scripts read these facts without pulling in the Circle build.
print-%: ; @echo '$($*)'
