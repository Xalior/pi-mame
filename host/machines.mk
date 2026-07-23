#
# machines.mk — the per-machine facts, one place.
#
# Under the patchable-defaults string there is ONE binary per vendor-class
# platform (kernel8-<platform>.img): no machine is compiled in. Everything that
# used to be a per-machine compile-time bake is now data here —
#
#   PLATFORM_MACHINES_<platform>  which machines belong to which card
#   PLATFORM_SUBTARGET_<platform> the platform's MAME SUBTARGET name (kept as
#                                 the per-platform identity / PLATFORM validity)
#   PLATFORM_SOURCES_<platform>   the platform's driver SOURCES (only that
#                                 vendor's src/mame/<vendor>/ files) — feed both
#                                 the mamedrivers engine (PLATFORM_SOURCES_MAMEDRIVERS) and
#                                 the platform's own generated drivlist
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
# (kernel8-<platform>.img). The MAME engine underneath is built ONCE per board
# as a single mamedrivers engine over every platform's SOURCES (scripts/build-mame.sh); each
# platform kernel links that shared engine with its OWN generated drivlist, so
# it carries only its own machines (host/Makefile). A machine's single-purpose
# image is patched from ITS platform's binary, never a shared one.
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

PLATFORMS = sinclair amstrad commodore amiga atari acorn eaca samcoupe camputers tatung memotech enterprise sord vtech trs

PLATFORM_MACHINES_sinclair = spectrum spec128 specpls2 specpl2a specpls3 \
	tbblue specnext_ks1 specnext_ks2 specnext_ks3 zx80 zx81 tc2048 ts2068 \
	ts1000 ts1500 pentagon scorpio atmtb2 pentevo tsconf elwro800 byte sprinter

PLATFORM_MACHINES_amstrad = cpc464 cpc664 cpc6128 cpc464p cpc6128p gx4000 \
	kccomp nc100 nc200 pc1512

PLATFORM_MACHINES_commodore = c64 c64p c64_jp c64_se c64c c64cp c64g c64c_es \
	c64c_se c64gs sx64 sx64p dx64 vip64 tesa6240 pet64 edu64 vic20 vic20p \
	vic20_se vic1001 c264 plus4 plus4p c16 c16p c116 c232 v364

PLATFORM_MACHINES_amiga = ar_blast ar_airh ar_bowl ar_dart ar_fast ar_fasta \
	ar_ldrb ar_ldrba ar_ldrbb ar_ninj ar_rdwr ar_sdwr ar_socc ar_spot \
	ar_sprg ar_xeon ar_pm ar_dlta ar_argh

# The 8-bit Atari computer line (src/mame/atari/atari400.cpp): the A400/A800/
# XL/XE family. Excluded as MACHINE_NOT_WORKING: a1200xl, a65xea, a130xe. The
# a5200/a5200a consoles share the driver file (their code rides in the binary)
# but are not computer-line machines and are not rostered.
PLATFORM_MACHINES_atari = a400 a400pal a800 a800pal a600xl a800xl a800xlp \
	a65xe a800xe xegs

# Acorn's 8-bit line (src/mame/acorn/): the BBC Micro family (bbcb/bbcbp/
# bbcm/bbcmc.cpp), the Electron (electron.cpp) and the Atom (atom.cpp).
# Excluded as MACHINE_NOT_WORKING: torch301 torch725 sist1 (bbcb.cpp);
# abc110 acw443 abc310 econx25 cfa3000bp (bbcbp.cpp); bbcmaiv bbcmarm
# mpc800 mpc900 mpc900gx se3010 discmon discmate daisy cfa3000 ht280
# (bbcm.cpp); autoc15 (bbcmc.cpp, also carries the roster's only NO_DUMP
# member); btm2105 (electron.cpp); atomes atomrr (atom.cpp); and the whole
# reutapm.cpp driver (its sole machine reutapm is MACHINE_NOT_WORKING, so
# the driver is not in PLATFORM_SOURCES_acorn at all).
PLATFORM_MACHINES_acorn = bbcb bbca bbcb_de bbcb_no bbcb_us dolphinm \
	torchf torchh bbcbp bbcbp128 ltmpbp bbcm bbcmt bbcmet bbcm512 ltmpm \
	bbcmc bbcmc_ar pro128s electron electront electron64 electronsp \
	atom atombbc prophet2

# EACA (src/mame/eaca/): the Colour Genie EG2000 line, one driver
# (cgenie.cpp), two machines — the European original and its New Zealand
# sibling. Both carry flags 0 (no MACHINE_NOT_WORKING, no IMPERFECT), so
# nothing is excluded: the driver directory's whole catalog is the roster.
PLATFORM_MACHINES_eaca = cgenie cgenienz

# MGT SAM Coupé (src/mame/samcoupe/): one driver (samcoupe.cpp), one machine.
# Its flags are MACHINE_SUPPORTS_SAVE only — no MACHINE_NOT_WORKING, no
# IMPERFECT flags — so nothing is excluded: the directory's whole catalog is
# the roster.
PLATFORM_MACHINES_samcoupe = samcoupe

# Camputers Lynx (src/mame/camputers/): one driver (camplynx.cpp), three
# machines — the 48k original and its 96k/128k siblings. All three carry
# MACHINE_SUPPORTS_SAVE only — no MACHINE_NOT_WORKING, no IMPERFECT flags —
# so nothing is excluded: the driver directory's whole catalog is the roster.
PLATFORM_MACHINES_camputers = lynx48k lynx96k lynx128k

# Tatung Einstein (src/mame/tatung/): one driver (einstein.cpp), two
# machines — the Einstein TC-01 (1984) and the Einstein 256 (1986). Both
# carry flags 0 — no MACHINE_NOT_WORKING, no IMPERFECT flags — so nothing
# is excluded: the driver directory's whole catalog is the roster.
PLATFORM_MACHINES_tatung = einstein einst256

# Memotech MTX (src/mame/memotech/): one driver (mtx.cpp), three machines —
# the MTX 512 (1983, parent), the MTX 500 (1983) and the RS 128 (1984). All
# three carry flags 0 — no MACHINE_NOT_WORKING, no IMPERFECT flags — so
# nothing is excluded: the driver directory's whole catalog is the roster.
PLATFORM_MACHINES_memotech = mtx512 mtx500 rs128

# Enterprise (src/mame/enterprise/): one driver (ep64.cpp), three machines —
# the Enterprise Sixty Four (ep64, 1985), its German Mephisto PHC 64 OEM
# sibling (phc64, 1985) and the Enterprise One Two Eight (ep128, 1986). All
# three carry MACHINE_IMPERFECT_GRAPHICS | MACHINE_IMPERFECT_SOUND — no
# MACHINE_NOT_WORKING — so nothing is excluded: the driver directory's whole
# catalog is the roster.
PLATFORM_MACHINES_enterprise = ep64 phc64 ep128

# Sord (src/mame/sord/): two drivers. m5.cpp carries the m.5 line — the
# m.5 Japan (m5, 1983, parent), the m.5 Europe (m5p, 1983) and the Czech
# BRNO mod (m5p_brno, 1983) — all flags 0 (no MACHINE_NOT_WORKING, no
# IMPERFECT), so all three are rostered. future32.cpp's sole machine
# (future32a) is MACHINE_NOT_WORKING, so the whole driver is excluded and
# not in PLATFORM_SOURCES_sord at all (the reutapm precedent).
PLATFORM_MACHINES_sord = m5 m5p m5p_brno

# VTech (src/mame/vtech/): the Laser/VZ home-computer family and the wider
# VTech catalog — 32 driver files, of which only SIX carry any machine not
# flagged MACHINE_NOT_WORKING. The roster is what survives that rule (ruled)
# minus the netlist park below, 24 machines off five drivers:
#  - vtech1.cpp (Laser 110/200/210/310, VZ-200/300 and OEM clones) — 9
#    rostered; excluded: vz200de (NOT_WORKING, also the roster line's only
#    NO_DUMP set — its German/Dutch BASIC V1.1 is undumped).
#  - vtech2.cpp (Laser 350/500/700) — all 3 rostered.
#  - crvision.cpp (CreatiVision console family + the Laser 2001/Salora
#    Manager computers) — all 9 rostered.
#  - vsmile.cpp (V.Smile, V.Smile Motion) — both rostered.
#  - geniusiq.cpp — itunlim only (MACHINE_NO_SOUND, not NOT_WORKING);
#    excluded: pcunlim iq128 iq128_fr iqtv512 (all NOT_WORKING).
#  - gamemachine.cpp (The Game Machine, 4 in 1 Electronic Games — screenless
#    PWM-LED tabletops) survives the flag rule but is PARKED at compile
#    stage: its NETLIST_SOUND pulls src/lib/netlist, whose
#    plib/pconfig.h:123 whitelists exact __cplusplus values ending at
#    202002L while this port's cross wrappers force -std=gnu++23 (202302L,
#    required by the circle libc++), and plib/ptypes.h also relies on
#    libstdc++'s transitive <algorithm> include (std::copy) that circle
#    libc++ doesn't provide. Netlist can never compile here without a mame
#    rapi-circle patch (or upstream fix) — a ruling, not a port decision —
#    so the driver is NOT in PLATFORM_SOURCES_vtech and gamemach/v4in1eg
#    are not rostered until that ruling lands.
# The other 26 drivers are excluded WHOLE — every machine NOT_WORKING (the
# reutapm precedent, so none is in PLATFORM_SOURCES_vtech): clickstart
# geniuscolor geniusjr gkidabc glcx innotv_innotabmax inteladv iqunlim
# kidsupstar laser3k lcmate2 learnwin magibook pc1000 pc2000 pc4 phusion
# prestige primusex socrates storio vsmileb vsmilepro vtech5303 vtech_eu3a12
# vtech_innotab.
PLATFORM_MACHINES_vtech = laser110 laser200 fellow tx8000 laser210 vz200 \
	laser310 vz300 laser310h laser350 laser500 laser700 \
	crvision fnvision crvisioj wizzard rameses vz2000 crvisio2 lasr2001 \
	manager vsmile vsmilem itunlim

# TRS / Tandy (src/mame/trs/): the Radio Shack catalog — the TRS-80 line,
# the Color Computer family with its Dragon offshoots, the MC-10 line and
# the VIS. 17 driver files carry machines (all via plain COMP); the roster
# is what survives the MACHINE_NOT_WORKING rule (ruled), 38 machines:
#  - trs80.cpp: trs80 only (Model I, Level I BASIC); excluded NOT_WORKING:
#    trs80l2 eg3003 sys80 sys80p ht1080z ht1080z2 ht108064.
#  - trs80m2.cpp: EXCLUDED WHOLE. trs80m16 is NOT_WORKING, and trs80m2 —
#    though flagged working — is PARKED: its keyboard (trs80m2kb.h, ridden
#    by the driver) is the superset closure's ONLY user of MAME's discrete
#    sound core, and src/devices/sound/discrete.cpp does not compile under
#    this toolchain (GCC 15 -Werror=format-overflow at disc_sys.hxx:37/:83,
#    sprintf "%s_%d.csv" into a 32-byte buffer). Exact unblock: a mame
#    rapi-circle snprintf/buffer fix (or upstream) — a ruling, not a port
#    decision (the vtech gamemachine netlist park precedent), so the driver
#    is NOT in PLATFORM_SOURCES_trs until that ruling lands.
#  - trs80dt1.cpp (DT-1 data terminal), agvision.cpp (AgVision/Videotex),
#    coco12.cpp (12 machines), coco3.cpp (4), dragon.cpp (8),
#    dgnalpha.cpp, mc10.cpp (4), meritum.cpp (3), vis.cpp — nothing
#    excluded.
# Whole drivers excluded — every machine NOT_WORKING (the reutapm
# precedent, so none is in PLATFORM_SOURCES_trs): dgn_beta.cpp (dgnbeta),
# lnw80.cpp (lnw80), max80.cpp (max80), radionic.cpp (radionic),
# tandy2k.cpp (tandy2k tandy2khd), trs80m3.cpp (trs80m3 trs80m4 trs80m4p
# cp500).
PLATFORM_MACHINES_trs = trs80 trs80dt1 agvision trsvidtx \
	coco cocoh deluxecoco coco2b coco2bh cp400 cp400c2 mx1600 t4426 \
	lzcolor64 cd6809 ms1600 coco3 coco3p coco3h msm3 \
	dragon32 dragon64 dragon64h dragon200 dragon200e d64plus tanodr64 \
	tanodr64h dgnalpha mc10 alice alice32 alice90 \
	meritum1 meritum2 meritum_net vis

# All machines, every platform — the roster `make kernels` bakes and CI verifies.
MACHINES = $(foreach p,$(PLATFORMS),$(PLATFORM_MACHINES_$(p)))

# The reverse map: which platform a machine belongs to. Derived, never hand-
# maintained — the host Makefile reads MACHINE_PLATFORM_<m> to pick the machine's
# platform binary (which is patched to make the machine's single-purpose image).
$(foreach p,$(PLATFORMS),$(foreach m,$(PLATFORM_MACHINES_$(p)),\
	$(eval MACHINE_PLATFORM_$(m) := $(p))))

# --- Per-platform SOURCES and subtarget identity ---
#
# PLATFORM_SUBTARGET names the platform (retained as its identity and as the
# PLATFORM validity check in host/Makefile). PLATFORM_SOURCES is ONLY that
# vendor's src/mame/<vendor>/ drivers, with no crossover. These lists feed two
# consumers: PLATFORM_SOURCES_MAMEDRIVERS (below) joins them into the ONE mamedrivers engine
# scripts/build-mame.sh compiles per board, and host/Makefile passes a single
# platform's list to makedep.py to generate that platform's drivlist. The lists
# are space-separated (build-mame.sh joins with commas for MAME's SOURCES=; a
# comma-separated value cannot carry make's line-continuation spaces, a
# space-separated one can, and makedep.py takes them space-separated directly).
PLATFORM_SUBTARGET_sinclair  = sinclair
PLATFORM_SUBTARGET_amstrad   = amstrad
PLATFORM_SUBTARGET_commodore = commodore
PLATFORM_SUBTARGET_amiga     = amiga
PLATFORM_SUBTARGET_atari     = atari
PLATFORM_SUBTARGET_acorn     = acorn
PLATFORM_SUBTARGET_eaca      = eaca
PLATFORM_SUBTARGET_samcoupe  = samcoupe
PLATFORM_SUBTARGET_camputers = camputers
PLATFORM_SUBTARGET_tatung    = tatung
PLATFORM_SUBTARGET_memotech  = memotech
PLATFORM_SUBTARGET_enterprise = enterprise
PLATFORM_SUBTARGET_sord      = sord
PLATFORM_SUBTARGET_vtech     = vtech
PLATFORM_SUBTARGET_trs       = trs

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
	src/mame/commodore/c64.cpp src/mame/commodore/vic20.cpp \
	src/mame/commodore/plus4.cpp

PLATFORM_SOURCES_amiga = \
	src/mame/amiga/amiga.cpp src/mame/amiga/arsystems.cpp \
	src/mame/amiga/cubo.cpp src/mame/amiga/mquake.cpp \
	src/mame/amiga/alg.cpp src/mame/amiga/upscope.cpp

# atari400.cpp alone: makedep's split-driver sibling scan pulls the
# atari400_m/_v companions (and antic/gtia via their headers) automatically.
PLATFORM_SOURCES_atari = \
	src/mame/atari/atari400.cpp

# Driver files only: makedep's sibling scan pulls the support files (bbc.h ->
# bbc_m.cpp/bbc_v.cpp via the _m/_v aspect scan; bbc_kbd/electron_ula/
# acorn_serproc via their same-stem headers) automatically.
PLATFORM_SOURCES_acorn = \
	src/mame/acorn/bbcb.cpp src/mame/acorn/bbcbp.cpp \
	src/mame/acorn/bbcm.cpp src/mame/acorn/bbcmc.cpp \
	src/mame/acorn/electron.cpp src/mame/acorn/atom.cpp

# The whole eaca directory is this one driver file.
PLATFORM_SOURCES_eaca = \
	src/mame/eaca/cgenie.cpp

# The whole samcoupe directory is this one driver file.
PLATFORM_SOURCES_samcoupe = \
	src/mame/samcoupe/samcoupe.cpp

# The whole camputers directory is this one driver file.
PLATFORM_SOURCES_camputers = \
	src/mame/camputers/camplynx.cpp

# The whole tatung directory is this one driver file (the einstein bus
# devices under src/devices/bus/einstein/ ride the device closure).
PLATFORM_SOURCES_tatung = \
	src/mame/tatung/einstein.cpp

# The whole memotech directory is this one driver file: makedep's sibling
# scan pulls the mtx_m.cpp machine-aspect companion via mtx.h, and the MTX
# expansion-bus devices under src/devices/bus/mtx/ ride the device closure.
PLATFORM_SOURCES_memotech = \
	src/mame/memotech/mtx.cpp

# The whole enterprise directory is this one driver file: makedep's sibling
# scan pulls the NICK video and DAVE sound custom-chip companions
# (nick.cpp/dave.cpp, devices living in the driver directory) via their
# same-stem headers, and the EP64 expansion-bus devices under
# src/devices/bus/ep64/ ride the device closure.
PLATFORM_SOURCES_enterprise = \
	src/mame/enterprise/ep64.cpp

# m5.cpp only — future32.cpp is excluded because its sole machine
# (future32a) is MACHINE_NOT_WORKING (the reutapm precedent). The m.5
# cartridge-bus devices under src/devices/bus/m5/ ride the device closure.
PLATFORM_SOURCES_sord = \
	src/mame/sord/m5.cpp

# The five compilable vtech drivers with any non-NOT_WORKING machine (the
# excluded 26 drivers, and gamemachine.cpp's netlist park, are covered in
# the roster comment above). makedep's sibling scan pulls the companions:
# vtech2.h -> vtech2_m.cpp/vtech2_v.cpp via the _m/_v aspect scan, and
# crvision.h/vsmile.h ride with their own drivers. The vtech ioexp/memexp
# bus devices under src/devices/bus/vtech/ and the crvision/vsmile
# cartridge slots ride the device closure.
PLATFORM_SOURCES_vtech = \
	src/mame/vtech/vtech1.cpp src/mame/vtech/vtech2.cpp \
	src/mame/vtech/crvision.cpp src/mame/vtech/vsmile.cpp \
	src/mame/vtech/geniusiq.cpp

# The ten trs drivers in the build (the six all-NOT_WORKING drivers and the
# parked trs80m2.cpp are covered in the roster comment above). makedep's
# sibling scan
# pulls the companions: trs80.h -> trs80_m.cpp/trs80_v.cpp via the _m/_v
# aspect scan plus trs80_quik.cpp via its same-stem header; coco12.h/coco3.h
# pull coco12_m.cpp/coco3_m.cpp and, via coco.h/gime.h/coco_vhd.h, the
# coco.cpp base class, the GIME video device and the CoCo virtual hard
# disk. The CoCo/Dragon cartridge-bus devices under src/devices/bus/coco/,
# the MC-10 devices under src/devices/bus/mc10/ and vis's fixed ISA16
# cards (pc_isa16_cards) ride the device closure. trs80m2.cpp is absent —
# its trs80m2 machine is parked on the discrete-sound-core compile blocker
# (see the roster comment above).
PLATFORM_SOURCES_trs = \
	src/mame/trs/trs80.cpp \
	src/mame/trs/trs80dt1.cpp src/mame/trs/agvision.cpp \
	src/mame/trs/coco12.cpp src/mame/trs/coco3.cpp \
	src/mame/trs/dragon.cpp src/mame/trs/dgnalpha.cpp \
	src/mame/trs/mc10.cpp src/mame/trs/meritum.cpp \
	src/mame/trs/vis.cpp

# Every shipped platform's SOURCES, joined. The shared-engine build
# (scripts/build-mame.sh) compiles ONE mamedrivers SUBTARGET from this — the
# SOURCES-invariant engine + 3rdparty, plus the superset device closure of every
# platform — exactly once per board. Each platform's kernel then links that one
# tree, trimmed to its own machines by its per-platform drivlist seed (the
# linker's --start-group member selection drops everything the drivlist doesn't
# reference, so the kernel stays the size it always was). Data-driven from
# PLATFORMS, so it never needs hand-maintaining.
PLATFORM_SOURCES_MAMEDRIVERS = $(foreach p,$(PLATFORMS),$(PLATFORM_SOURCES_$(p)))

# The subtarget name of that one mamedrivers engine. scripts/build-mame.sh builds it
# once per board (SUBTARGET=$(MAMEDRIVERS_SUBTARGET), SOURCES=$(PLATFORM_SOURCES_MAMEDRIVERS))
# into mame-<board>/build/mamedrivers/rapi-circle; genie scopes the driver archive and
# generated dir by it (bin/mame_$(MAMEDRIVERS_SUBTARGET)/, generated/mame/$(MAMEDRIVERS_SUBTARGET)/).
# host/Makefile links that shared engine and swaps in a per-PLATFORM drivlist it
# generates itself, so each kernel carries only its own platform's machines.
MAMEDRIVERS_SUBTARGET = mamedrivers

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
# The C64/VIC-20/264/128 lines' IEC serial bus defaults to a disk drive at
# device 8 that models an EXTERNAL, plug-in option. On those machines a real
# unit with nothing plugged into the serial port is a completely valid, far
# more common configuration, so device 8 is baked empty. The "" token is the
# defaults-string spelling of an empty argv entry (defaults.cpp maps it) —
# MAME accepts only an empty value to empty a slot, "none" is rejected.
#
# This empty-slot bake applies to EXTERNAL-drive defaults ONLY. Where the drive
# is BUILT-IN hardware — the SX-64 family's internal SX1541 (sx64/sx64p/vip64/
# tesa6240, and TWO of them on dx64) — D.'s ruling stands: built-in hardware is
# NEVER removed. Those machines carry NO -iec8/-iec9 override; MAME's built-in-
# drive default stands and each ships the sx1541 device romset (MACHINE_ASSETS).
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
# The SX-64 is the portable C64 with a BUILT-IN 1541: ntsc_sx replaces the iec8
# slot's default with the internal sx1541 drive. That drive is built-in
# hardware and is NEVER removed (D.'s ruling) — no -iec8 override; MAME's
# built-in sx1541 default stands, so the machine ships the sx1541 device romset
# (MACHINE_ASSETS_sx64) and boots to the SX kernal's sign-on with its internal
# drive present.
MACHINE_STRING_sx64         = sx64
# The PAL SX-64 (rom_sx64p == rom_sx64): pal_sx wires the same built-in sx1541
# at iec8. Built-in hardware is never removed — no -iec8 override; the drive
# romset ships and the internal drive is present.
MACHINE_STRING_sx64p        = sx64p
# The DX-64 (rom_dx64 == rom_sx64): ntsc_dx builds on ntsc_sx and adds a SECOND
# built-in sx1541 drive on slot iec9 (the twin-drive prototype), on top of
# ntsc_sx's iec8 drive. BOTH drives are built-in hardware and are never removed
# — no -iec8/-iec9 override; MAME's twin built-in defaults stand and both
# internal drives come up. The single sx1541 device romset serves both.
MACHINE_STRING_dx64         = dx64
# The VIP-64 (Swedish/Finnish SX-64): a distinct romset carrying its own unique
# Swedish SX kernal and Swedish chargen. pal_sx wires the built-in sx1541 at
# iec8 — built-in hardware, never removed; no -iec8 override, the drive romset
# ships and the internal drive is present under the Swedish SX kernal.
MACHINE_STRING_vip64        = vip64
# The Tesa Etikett Etikettendrucker 6240 (PAL label printer): SX-64 hardware
# running bespoke industrial firmware — its own unique BASIC, KERNAL and
# chargen (all three main ROMs distinct from the c64 parent). pal_sx wires the
# built-in sx1541 at iec8 — built-in hardware, never removed; no -iec8
# override, the drive romset ships and the internal drive is present under the
# Tesa firmware.
MACHINE_STRING_tesa6240     = tesa6240
# The PET 64 / CBM 4064 (NTSC): a c64_state pet64-config machine (ntsc()
# plus a TODO monochrome-green palette). Same iec8 slot as the base c64,
# baked empty via -iec8 "" — no drive romset required to reach BASIC.
MACHINE_STRING_pet64        = pet64 -iec8 ""
# The Educator 64 (NTSC): a c64_state machine sharing the pet64 config (ntsc()
# plus a TODO monochrome-green palette), byte-identical romset to the base c64
# (#define rom_edu64 rom_c64). Same iec8 slot as the base c64, baked empty via
# -iec8 "" — no drive romset required to reach BASIC.
MACHINE_STRING_edu64        = edu64 -iec8 ""
# The VIC-20 (NTSC): the first non-c64.cpp machine on the commodore platform
# (driver src/mame/commodore/vic20.cpp, vic20_state). It wires the SAME cbm_iec
# serial bus as the C64 line — cbm_iec_slot_device::add(config, m_iec, "c1541")
# defaults a C1541 drive at device 8 — so the same -iec8 "" empties device 8 and
# reaches BASIC with no drive romset required. Default kernal is BIOS 0 "cbm".
MACHINE_STRING_vic20        = vic20 -iec8 ""
# The VIC-20 / VC-20 (PAL): the vic20p clone of the same vic20_state driver
# (src/mame/commodore/vic20.cpp), PAL sibling of the NTSC vic20. Same cbm_iec
# serial bus with a C1541 defaulted at device 8, so the same -iec8 "" empties
# device 8 and reaches BASIC with no drive romset required. Default kernal is
# BIOS 0 "cbm" — the PAL kernal 901486-07 (vs NTSC's 901486-06).
MACHINE_STRING_vic20p       = vic20p -iec8 ""
# The VIC-20 (Sweden/Finland, PAL): the vic20_se clone of the same vic20_state
# driver (src/mame/commodore/vic20.cpp), the last VIC-20 family machine — the
# Nordic-market sibling of vic20p. Same cbm_iec serial bus with a C1541
# defaulted at device 8, so the same -iec8 "" empties device 8 and reaches
# BASIC with no drive romset required. No ROM_SYSTEM_BIOS alternates: a single
# Swedish/Finnish kernal (nec22081.206) + national charom (nec22101.207), with
# Swedish keyboard input (vic20s).
MACHINE_STRING_vic20_se     = vic20_se -iec8 ""
# The VIC-1001 (Japan, NTSC): the family PARENT of the vic20_state driver
# (src/mame/commodore/vic20.cpp) — the Japanese-market original the vic20/vic20p
# clones descend from. Same cbm_iec serial bus with a C1541 defaulted at device
# 8, so the same -iec8 "" empties device 8 and reaches BASIC with no drive romset
# required. Single Japanese kernal (901486-02) + katakana charom (901460-02); no
# ROM_SYSTEM_BIOS alternates — the parent romset is self-contained in vic1001.zip.
MACHINE_STRING_vic1001      = vic1001 -iec8 ""
# The Commodore 264 (NTSC, prototype): the family PARENT of
# src/mame/commodore/plus4.cpp (plus4_state, machine config plus4n) — the
# pre-production 264 prototype the plus4/plus4p/c16/c116/c232/v364 machines
# clone. It wires the SAME cbm_iec serial bus as the C64/VIC-20 line —
# cbm_iec_slot_device::add(config, m_iec, "c1541") defaults a C1541 drive at
# device 8 — so the same -iec8 "" empties device 8 and reaches BASIC with no
# drive romset required. Self-contained romset (basic-264/kernal-264/PLA, no
# ROM_SYSTEM_BIOS alternates) and, unlike the production Plus/4, no 3-PLUS-1
# function ROMs (the "function" region is ROMREGION_ERASE00), so it boots to the
# 264 prototype's own bare BASIC sign-on. The family's only
# MACHINE_IMPERFECT_GRAPHICS entry.
MACHINE_STRING_c264         = c264 -iec8 ""
# The Plus/4 (NTSC): the first machine off src/mame/commodore/plus4.cpp
# (plus4_state, machine config plus4n), opening the TED/264 family — a clone of
# the c264 prototype parent. Despite the different TED-based hardware it wires
# the SAME cbm_iec serial bus as the C64/VIC-20 line —
# cbm_iec_slot_device::add(config, m_iec, "c1541") defaults a C1541 drive at
# device 8 — so the same -iec8 "" empties device 8 and reaches BASIC with no
# drive romset required. Default kernal is ROM_DEFAULT_BIOS("r5") (BIOS 1). The
# baked romset carries the machine's own 3-PLUS-1 productivity suite (the
# "function" ROMs 317053/317054), so it boots to the Plus/4's own sign-on.
MACHINE_STRING_plus4        = plus4 -iec8 ""
# The Plus/4 (PAL): the plus4p clone of the same plus4_state driver
# (src/mame/commodore/plus4.cpp), PAL sibling of the NTSC plus4. Same TED/264
# hardware wiring the SAME cbm_iec serial bus — a C1541 defaulted at device 8 —
# so the same -iec8 "" empties device 8 and reaches BASIC with no drive romset
# required. Default kernal is ROM_DEFAULT_BIOS("r5") (BIOS 2) — the PAL r5
# kernal 318004-05 (vs NTSC's 318005-05); everything else (basic, the 3-PLUS-1
# function ROMs, the PLA) is byte-identical to plus4, so it boots to the same
# Plus/4 sign-on on the PAL canvas.
MACHINE_STRING_plus4p       = plus4p -iec8 ""
# The Commodore 16 (NTSC): the cut-down 16K sibling on the same TED/264 driver
# (src/mame/commodore/plus4.cpp, c16_state, machine config c16n) — a clone of
# the c264 prototype parent. The c16n config nops the ATN callback and removes
# the user port but KEEPS the same cbm_iec serial bus (a C1541 defaulted at
# device 8), so the same -iec8 "" empties device 8 and reaches BASIC with no
# drive romset required. Default kernal is ROM_DEFAULT_BIOS("r5") (BIOS 1) — the
# r5 kernal, basic and PLA are byte-identical to plus4, but the C16 omits the
# 3-PLUS-1 function ROMs and has only 16K RAM, so it boots to BASIC V3.5 with
# 12277 BYTES FREE (vs the Plus/4's 60671).
MACHINE_STRING_c16          = c16 -iec8 ""
# The Commodore 16 (PAL): the PAL machine of the cut-down 16K sibling on the same
# TED/264 driver (src/mame/commodore/plus4.cpp, c16_state, machine config c16) —
# the PAL counterpart of the NTSC c16. Same c264-clone lineage; the c16 config
# keeps the same cbm_iec serial bus (a C1541 defaulted at device 8), so the same
# -iec8 "" empties device 8 and reaches BASIC with no drive romset required.
# Default kernal is ROM_DEFAULT_BIOS("r5") (BIOS 2) — the PAL r5 kernal 318004-05
# (part 318004, vs NTSC's 318005-05); basic and PLA are byte-identical to the
# 264 line, but the C16 omits the 3-PLUS-1 function ROMs and has only 16K RAM, so
# it boots to BASIC V3.5 with 12277 BYTES FREE on the PAL canvas.
MACHINE_STRING_c16p         = c16p -iec8 ""
# The Commodore 116: the cost-reduced, rubber-key sibling of the C16 on the same
# TED/264 driver (src/mame/commodore/plus4.cpp, c16_state, machine config c16p —
# it shares the PAL C16's config). Same 16K RAM, same cbm_iec serial bus (a C1541
# defaulted at device 8), so the same -iec8 "" empties device 8 and reaches BASIC
# with no drive romset required. Default kernal is ROM_DEFAULT_BIOS("r5") (BIOS 2)
# — the PAL r5 kernal 318004-05, basic 318006-01 and PLA 251641-02 are all
# byte-identical to c16p (the only ROM_START difference is the PLA member name,
# 251641-02.u101 vs c16p's .u16). Like the C16 it omits the 3-PLUS-1 function ROMs,
# so it boots to BASIC V3.5 with 12277 BYTES FREE on the PAL canvas.
MACHINE_STRING_c116         = c116 -iec8 ""
# The Commodore 232 (PAL, prototype): a pre-production 264-line prototype on the
# same TED/264 driver (src/mame/commodore/plus4.cpp, c16_state, machine config
# c232 — c16p with the RAM default raised to 32K). A clone of the c264 prototype
# parent; the config chain c232 -> c16p -> plus4p makes it a PAL machine. It
# keeps the same cbm_iec serial bus (a C1541 defaulted at device 8), so the same
# -iec8 "" empties device 8 and reaches BASIC with no drive romset required. Its
# kernal 318004-01 (CRC dbdc3319) is UNIQUE to c232; basic 318006-01 and PLA
# 251641-02 are byte-identical to the rest of the 264 line. Like the C16 it omits
# the 3-PLUS-1 function ROMs, but with 32K RAM (vs the C16's 16K) it boots to
# BASIC V3.5 with 28661 BYTES FREE on the PAL canvas.
MACHINE_STRING_c232         = c232 -iec8 ""
# The Commodore V364 (NTSC, prototype): the LAST machine of the TED/264 driver
# (src/mame/commodore/plus4.cpp, c16_state, machine config v364). A clone of the
# c264 prototype parent; the v364 config calls plus4n (the NTSC Plus/4 config),
# then adds the T6721A speech synthesiser and MOS8706 speech/voice LSI — the
# V364 is the speaking prototype of the 264 line. It keeps the same cbm_iec
# serial bus (a C1541 defaulted at device 8), so the same -iec8 "" empties device
# 8 and reaches BASIC with no drive romset required. Unlike the cut-down
# C16/232/116 it carries the full Plus/4 3-PLUS-1 function ROMs (317053-01 +
# 317054-01), so it boots to BASIC V3.5 with the 3-PLUS-1 line. Its kernal
# kern364p (CRC 84fd4f7a) and speech ROM spk3cc4.bin (5227c2ee) are UNIQUE to
# v364; basic 318006-01, the function pair and PLA 251641-02 are byte-identical
# to the rest of the 264 line. NTSC canvas.
MACHINE_STRING_v364         = v364 -iec8 ""

# --- Amiga defaults strings ---
MACHINE_STRING_ar_blast     = ar_blast
MACHINE_STRING_ar_airh      = ar_airh
MACHINE_STRING_ar_bowl      = ar_bowl
MACHINE_STRING_ar_dart      = ar_dart
MACHINE_STRING_ar_fast      = ar_fast
MACHINE_STRING_ar_fasta     = ar_fasta
MACHINE_STRING_ar_ldrb      = ar_ldrb
MACHINE_STRING_ar_ldrba     = ar_ldrba
MACHINE_STRING_ar_ldrbb     = ar_ldrbb
MACHINE_STRING_ar_ninj      = ar_ninj
MACHINE_STRING_ar_rdwr      = ar_rdwr
MACHINE_STRING_ar_sdwr      = ar_sdwr
MACHINE_STRING_ar_socc      = ar_socc
MACHINE_STRING_ar_spot      = ar_spot
MACHINE_STRING_ar_sprg      = ar_sprg
MACHINE_STRING_ar_xeon      = ar_xeon
MACHINE_STRING_ar_pm        = ar_pm
MACHINE_STRING_ar_dlta      = ar_dlta
MACHINE_STRING_ar_argh      = ar_argh

# --- Atari defaults strings ---
# The A8SIO bus defaults to "fdc" (ATARI_FDC, MAME's high-level 810/1050 FDC —
# no device ROMs). It models an EXTERNAL SIO drive; whether to bake it empty
# (the commodore -iec8 "" precedent was ruled for the IEC lines only) is
# staged for D.'s ruling — until then MAME's defaults stand unmodified.
# Cart slots default empty (nullptr, no must_be_loaded); no media is baked.
MACHINE_STRING_a400         = a400
MACHINE_STRING_a400pal      = a400pal
MACHINE_STRING_a800         = a800
MACHINE_STRING_a800pal      = a800pal
MACHINE_STRING_a600xl       = a600xl
MACHINE_STRING_a800xl       = a800xl
MACHINE_STRING_a800xlp      = a800xlp
MACHINE_STRING_a65xe        = a65xe
MACHINE_STRING_a800xe       = a800xe
MACHINE_STRING_xegs         = xegs

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
MACHINE_ASSETS_sx64         = sx64 sx1541
MACHINE_ASSETS_sx64p        = sx64p sx1541
MACHINE_ASSETS_dx64         = dx64 sx1541
MACHINE_ASSETS_vip64        = vip64 sx1541
MACHINE_ASSETS_tesa6240     = tesa6240 sx1541
MACHINE_ASSETS_pet64        = pet64
MACHINE_ASSETS_edu64        = edu64
MACHINE_ASSETS_vic20        = vic20
MACHINE_ASSETS_vic20p       = vic20p
MACHINE_ASSETS_vic20_se     = vic20_se
MACHINE_ASSETS_vic1001      = vic1001
MACHINE_ASSETS_c264         = c264
MACHINE_ASSETS_plus4        = plus4
MACHINE_ASSETS_plus4p       = plus4p
MACHINE_ASSETS_c16          = c16
MACHINE_ASSETS_c16p         = c16p
MACHINE_ASSETS_c116         = c116
MACHINE_ASSETS_c232         = c232
MACHINE_ASSETS_v364         = v364

# --- Amiga asset dependencies (each Arcadia game needs the shared ar_bios) ---
MACHINE_ASSETS_ar_blast     = ar_bios ar_blast
MACHINE_ASSETS_ar_airh      = ar_bios ar_airh
MACHINE_ASSETS_ar_bowl      = ar_bios ar_bowl
MACHINE_ASSETS_ar_dart      = ar_bios ar_dart
MACHINE_ASSETS_ar_fast      = ar_bios ar_fast
MACHINE_ASSETS_ar_fasta     = ar_bios ar_fasta
MACHINE_ASSETS_ar_ldrb      = ar_bios ar_ldrb
MACHINE_ASSETS_ar_ldrba     = ar_bios ar_ldrba
MACHINE_ASSETS_ar_ldrbb     = ar_bios ar_ldrbb
MACHINE_ASSETS_ar_ninj      = ar_bios ar_ninj
MACHINE_ASSETS_ar_rdwr      = ar_bios ar_rdwr
MACHINE_ASSETS_ar_sdwr      = ar_bios ar_sdwr
MACHINE_ASSETS_ar_socc      = ar_bios ar_socc
MACHINE_ASSETS_ar_spot      = ar_bios ar_spot
MACHINE_ASSETS_ar_sprg      = ar_bios ar_sprg
MACHINE_ASSETS_ar_xeon      = ar_bios ar_xeon
MACHINE_ASSETS_ar_pm        = ar_bios ar_pm
MACHINE_ASSETS_ar_dlta      = ar_bios ar_dlta
MACHINE_ASSETS_ar_argh      = ar_bios ar_argh

# --- Atari asset dependencies (manifest asset names) ---
# One romset per machine; a800xlp aliases rom_a800xl in the driver but keeps
# its own zip name. The SIO fdc default is ROM-less, so no device assets.
MACHINE_ASSETS_a400         = a400
MACHINE_ASSETS_a400pal      = a400pal
MACHINE_ASSETS_a800         = a800
MACHINE_ASSETS_a800pal      = a800pal
MACHINE_ASSETS_a600xl       = a600xl
MACHINE_ASSETS_a800xl       = a800xl
MACHINE_ASSETS_a800xlp      = a800xlp
MACHINE_ASSETS_a65xe        = a65xe
MACHINE_ASSETS_a800xe       = a800xe
MACHINE_ASSETS_xegs         = xegs

# --- Acorn defaults strings ---
# Bare machine names, no media, no slot overrides: no Acorn roster machine has
# a must_be_loaded slot, so every one boots to its own firmware prompt. MAME's
# slot defaults stand untouched (the bbcb line wires an acorn8271 FDC board and
# a speech upgrade by default; the Electron wires the Plus 3 expansion) —
# whether any of those external add-on defaults gets baked empty, and which DFS
# ROM configuration ships, are D.'s policy calls, staged as open questions, not
# decided here.
MACHINE_STRING_bbcb         = bbcb
MACHINE_STRING_bbca         = bbca
MACHINE_STRING_bbcb_de      = bbcb_de
MACHINE_STRING_bbcb_no      = bbcb_no
MACHINE_STRING_bbcb_us      = bbcb_us
MACHINE_STRING_dolphinm     = dolphinm
MACHINE_STRING_torchf       = torchf
MACHINE_STRING_torchh       = torchh
MACHINE_STRING_bbcbp        = bbcbp
MACHINE_STRING_bbcbp128     = bbcbp128
MACHINE_STRING_ltmpbp       = ltmpbp
MACHINE_STRING_bbcm         = bbcm
MACHINE_STRING_bbcmt        = bbcmt
MACHINE_STRING_bbcmet       = bbcmet
MACHINE_STRING_bbcm512      = bbcm512
MACHINE_STRING_ltmpm        = ltmpm
MACHINE_STRING_bbcmc        = bbcmc
MACHINE_STRING_bbcmc_ar     = bbcmc_ar
MACHINE_STRING_pro128s      = pro128s
MACHINE_STRING_electron     = electron
MACHINE_STRING_electront    = electront
MACHINE_STRING_electron64   = electron64
MACHINE_STRING_electronsp   = electronsp
MACHINE_STRING_atom         = atom
MACHINE_STRING_atombbc      = atombbc
MACHINE_STRING_prophet2     = prophet2

# --- Acorn asset dependencies (manifest asset names) ---
# Each machine lists every romset MAME's stock config REQUIRES to boot:
# its own, plus device romsets that are either hardwired (saa5050 — the
# Teletext character generator wired unconditionally into every BBC
# Micro/Master/Compact video path; booting without it is a fatal
# missing-ROM stop) or MAME's own slot defaults (bbcb's acorn8271 DFS
# board, atom's discpack, electron's plus3 with its nested plus1). The
# country-variant and Torch BBCs bake their DFS into their own romset
# (set_insert_rom(false)) and need no board asset. Whether any slot is
# instead baked EMPTY is a policy ruling — until then MAME's defaults
# stand, and these lines name what those defaults load.
MACHINE_ASSETS_bbcb         = bbcb bbc_acorn8271 saa5050
MACHINE_ASSETS_bbca         = bbca saa5050
MACHINE_ASSETS_bbcb_de      = bbcb_de saa5050
MACHINE_ASSETS_bbcb_no      = bbcb_no saa5050
MACHINE_ASSETS_bbcb_us      = bbcb_us saa5050
MACHINE_ASSETS_dolphinm     = dolphinm saa5050
MACHINE_ASSETS_torchf       = torchf saa5050
MACHINE_ASSETS_torchh       = torchh saa5050
MACHINE_ASSETS_bbcbp        = bbcbp saa5050
MACHINE_ASSETS_bbcbp128     = bbcbp128 saa5050
MACHINE_ASSETS_ltmpbp       = ltmpbp saa5050
MACHINE_ASSETS_bbcm         = bbcm saa5050
MACHINE_ASSETS_bbcmt        = bbcmt saa5050
MACHINE_ASSETS_bbcmet       = bbcmet saa5050
MACHINE_ASSETS_bbcm512      = bbcm512 saa5050
MACHINE_ASSETS_ltmpm        = ltmpm saa5050
MACHINE_ASSETS_bbcmc        = bbcmc saa5050
MACHINE_ASSETS_bbcmc_ar     = bbcmc_ar saa5050
MACHINE_ASSETS_pro128s      = pro128s saa5050
MACHINE_ASSETS_electron     = electron electron_plus3 electron_plus1
MACHINE_ASSETS_electront    = electront electron_plus3 electron_plus1
MACHINE_ASSETS_electron64   = electron64 electron_plus3 electron_plus1
MACHINE_ASSETS_electronsp   = electronsp electron_plus3 electron_plus1
MACHINE_ASSETS_atom         = atom atom_discpack
MACHINE_ASSETS_atombbc      = atombbc atom_discpack
MACHINE_ASSETS_prophet2     = prophet2

# --- EACA defaults strings ---
# Bare machine names: the cassette deck defaults empty (CASSETTE_STOPPED, not
# must_be_loaded), and both option slots — the cartridge/expansion port
# (CG_EXP_SLOT) and the parallel port (CG_PARALLEL_SLOT) — default to nullptr
# in the driver, so there is nothing to bake and no device romset to ship.
# Both machines are PAL (17.734470 MHz master crystal; ~50Hz raster), so the
# regional canvas is the PAL one — no mksd.sh NTSC case entry.
MACHINE_STRING_cgenie       = cgenie
MACHINE_STRING_cgenienz     = cgenienz

# --- EACA asset dependencies (manifest asset names) ---
# Each machine's own romset only: cgenienz is a clone of cgenie but carries a
# self-contained ROM_START (its own BASIC ROM alternates via ROM_SYSTEM_BIOS +
# the shared character-set image by content), so no cross-zip dependency. The
# manifest stanzas await the ROM-sourcing parcel.
MACHINE_ASSETS_cgenie       = cgenie
MACHINE_ASSETS_cgenienz     = cgenienz

# --- SAM Coupé defaults string ---
# Bare machine name: the machine boots to SAM BASIC from ROM with no
# must_be_loaded slot anywhere (no media is mandatory). MAME's slot defaults
# stand untouched: the driver wires BOTH front drive bays with the "floppy"
# module (samcoupe.cpp's SAMCOUPE_DRIVE_PORT defaults; the real machine's
# drives were optional slide-in modules — a drive-less SAM existed), and the
# mouse port and rear expansion port default empty. Whether the drive-bay
# defaults get baked empty is D.'s policy call, staged as an open question,
# not decided here. No samcoupe bus device carries a ROM_START, so no device
# romset rides on any of these defaults. PAL-only machine (312-line raster) —
# no mksd.sh NTSC case entry.
MACHINE_STRING_samcoupe     = samcoupe

# --- SAM Coupé asset dependencies (manifest asset names) ---
# Its own romset only: samcoupe.zip carries the 15 BIOS-alternate 32K ROM
# images (ROM_SYSTEM_BIOS v0.1..v3.1 + the ATOM HDD auto-boot ROM), default
# BIOS v3.1. The manifest stanza awaits the ROM-sourcing parcel.
MACHINE_ASSETS_samcoupe     = samcoupe

# --- Camputers Lynx defaults strings ---
# Bare machine names: every machine boots to Lynx BASIC from ROM with no
# must_be_loaded slot anywhere (no media is mandatory). MAME's slot defaults
# stand untouched: the cassette deck defaults to CASSETTE_PLAY with no image
# mounted, and the 96k/128k models wire both floppy connectors with the
# ROM-less generic "525qd" module (camplynx.cpp's lynx_disk config; the drive
# was an optional add-on on the real machines — a drive-less Lynx existed).
# Whether the floppy-connector defaults get baked empty is D.'s policy call,
# staged as an open question, not decided here. No camputers device carries a
# ROM_START, so no device romset rides on any of these defaults. PAL-only
# machines (50Hz raster) — no mksd.sh NTSC case entry.
MACHINE_STRING_lynx48k      = lynx48k
MACHINE_STRING_lynx96k      = lynx96k
MACHINE_STRING_lynx128k     = lynx128k

# --- Camputers Lynx asset dependencies (manifest asset names) ---
# One self-contained romset per machine: lynx96k and lynx128k are clones of
# lynx48k in MAME's tree, but each ROM_START loads only its own uniquely-named
# members (no member falls through to the parent zip), so no cross-zip
# dependency. lynx48k.zip carries two BIOS-alternate ROM pairs (default Set1);
# lynx96k.zip carries three alternate ic44 EXT ROMs (default Original) plus
# dosrom.rom; lynx128k.zip shares that same dosrom.rom image by content. The
# manifest stanzas await the ROM-sourcing parcel.
MACHINE_ASSETS_lynx48k      = lynx48k
MACHINE_ASSETS_lynx96k      = lynx96k
MACHINE_ASSETS_lynx128k     = lynx128k

# --- Tatung Einstein defaults strings ---
# Bare machine names: no slot anywhere is must_be_loaded — with no disc both
# machines boot from their MOS ROM to the machine's own face (the Einstein is
# a floppy-CP/M machine; reaching Xtal DOS/CP/M needs a system disc in drive
# 0, and whether a boot disc gets baked into the defaults string is D.'s
# policy call, staged as an open question, not decided here). MAME's slot
# defaults stand untouched: the TC-01 wires all four WD1770 floppy connectors
# (0/1 as the 3" "3ss" TEAC FD-30A, 2/3 as "525qd" — the real machine had one
# built-in 3" drive, the rest optional; all modules ROM-less), and the 256
# keeps connectors 0/1 only. The pipe (tatung_pipe_cards), user port and
# rs232 default to nullptr; centronics defaults to the ROM-less "printer".
# No default slot device carries a ROM_START, so no device romset ships.
# The TC-01 is PAL (TMS9129, 50Hz) — no mksd.sh NTSC case entry. The 256's
# line standard is a dipswitch (S:1, 525/60 vs 625/50) whose MAME default is
# "525 lines 60Hz" on its V9938: which regional canvas it fills is staged as
# an open question — no mksd.sh entry until ruled.
MACHINE_STRING_einstein     = einstein
MACHINE_STRING_einst256     = einst256

# --- Tatung Einstein asset dependencies (manifest asset names) ---
# One self-contained romset per machine (einst256 is its own parent, not a
# clone): einstein.zip carries the two BIOS-alternate MOS images (default
# "mos12"); einst256.zip carries the single 16K MOS 2.1 image. The driver's
# #if 0 diagnostic ROM is not compiled and is not a member. The manifest
# stanzas await the ROM-sourcing parcel.
MACHINE_ASSETS_einstein     = einstein
MACHINE_ASSETS_einst256     = einst256

# --- Memotech MTX defaults strings ---
# Bare machine names: every machine boots to MTX BASIC from ROM with no
# must_be_loaded slot anywhere (no media is mandatory). MAME's slot defaults
# stand untouched: the cassette deck defaults to CASSETTE_PLAY with no image
# mounted, the ROM-extension socket and both MTX expansion slots (J10
# external, J0 internal — mtx.cpp's MTX_EXP_SLOT pair) default to nullptr,
# and centronics defaults to the ROM-less "printer". No default slot device
# carries a ROM_START (the sdx/cfx expansion ROMs under src/devices/bus/mtx/
# ride only if a slot is filled), so no device romset ships. All three are
# PAL machines (TMS9929A video) — no mksd.sh NTSC case entry.
MACHINE_STRING_mtx512       = mtx512
MACHINE_STRING_mtx500       = mtx500
MACHINE_STRING_rs128        = rs128

# --- Memotech MTX asset dependencies (manifest asset names) ---
# One romset zip name per machine, all three byte-identical in content:
# mtx500 and rs128 alias the parent's ROM_START in the driver
# (#define rom_mtx500 rom_mtx512, #define rom_rs128 rom_mtx512) but keep
# their own zip names (the a800xlp/edu64 precedent). The set carries both
# BIOS alternates (UK default, German), the ASSEM ROM, the Danish/Finnish
# keyboard PROMs and the PLD image. The manifest stanzas await the
# ROM-sourcing parcel.
MACHINE_ASSETS_mtx512       = mtx512
MACHINE_ASSETS_mtx500       = mtx500
MACHINE_ASSETS_rs128        = rs128

# --- Enterprise defaults strings ---
# Bare machine names: every machine boots to the EXOS firmware face from ROM
# with no must_be_loaded slot anywhere (no media is mandatory). MAME's slot
# defaults stand untouched: both cassette decks default to CASSETTE_STOPPED
# with no image mounted, the cartridge slot (generic_linear_slot) and the
# EP64 expansion bus (EP64_EXPANSION_BUS_SLOT) default to nullptr, rs232
# defaults to nullptr, and centronics defaults to the ROM-less "printer".
# No default slot device carries a ROM_START (the EXDOS disk-controller
# card ROM under src/devices/bus/ep64/exdos.cpp rides only if the expansion
# slot is filled), so no device romset ships. All three are PAL machines
# (50Hz raster) — no mksd.sh NTSC case entry.
MACHINE_STRING_ep64         = ep64
MACHINE_STRING_phc64        = phc64
MACHINE_STRING_ep128        = ep128

# --- Enterprise asset dependencies (manifest asset names) ---
# One romset zip name per machine: phc64 aliases the parent's ROM_START in
# the driver (#define rom_phc64 rom_ep64) but keeps its own zip name (the
# a800xlp/mtx500 precedent). Each set is a single 32K EXOS mask ROM —
# ep64/phc64 carry EXOS ENTER 05-23-A, ep128 carries EXOS ENTER 08-45-A.
# The manifest stanzas await the ROM-sourcing parcel.
MACHINE_ASSETS_ep64         = ep64
MACHINE_ASSETS_phc64        = phc64
MACHINE_ASSETS_ep128        = ep128

# --- Sord m.5 defaults strings ---
# Bare machine names: no slot anywhere is must_be_loaded — every machine
# boots from its monitor ROM to its own face. MAME's slot defaults stand
# untouched: both cartridge slots (M5_CART_SLOT, m5_cart) default to
# nullptr, the cassette deck defaults to CASSETTE_PLAY with no image
# mounted, and centronics defaults to the ROM-less "printer". The FD-5
# floppy subsystem (z80fd5 CPU + upd765 + one "3ssdd" connector) is
# HARDWIRED by the driver, not a removable slot (m5.cpp's own TODO:
# "rewrite fd5 floppy as unpluggable device"), and its controller ROM
# (sordfd5.rom) is a member of the machine's own romset, not a device
# romset; the BRNO mod replaces it with a WD2797 + two ROM-less "35hd"
# connectors and a 512K RAM disk. Whether a BASIC cartridge gets baked
# into the defaults string (the real m.5 shipped with the BASIC-I cart;
# bare it boots to the monitor) is D.'s policy call, staged as an open
# question, not decided here. m5 is NTSC (TMS9928A) — it joins the NTSC
# canvas case in scripts/mksd.sh; m5p and m5p_brno are PAL (TMS9929A).
MACHINE_STRING_m5           = m5
MACHINE_STRING_m5p          = m5p
MACHINE_STRING_m5p_brno     = m5p_brno

# --- Sord m.5 asset dependencies (manifest asset names) ---
# m5.zip (parent) carries sordjap.ic21 + sordfd5.rom. m5p is a clone whose
# ROM_START loads its own sordint.ic21 plus the parent's sordfd5.rom (same
# name and hashes), which falls through to m5.zip in split-set mirrors —
# so m5p lists both (the pentagon/spec128 precedent). m5p_brno's two
# members (sordint.ic21 + brno_rom12.rom) are both absent from the PARENT
# zip, so its split zip is self-contained — one asset. The manifest
# stanzas await the ROM-sourcing parcel.
MACHINE_ASSETS_m5           = m5
MACHINE_ASSETS_m5p          = m5p m5
MACHINE_ASSETS_m5p_brno     = m5p_brno

# --- VTech defaults strings ---
# Bare machine names: no slot anywhere on the roster is must_be_loaded and no
# surviving driver carries a fatalerror, so every machine boots to its own
# firmware face (or, for the cartridge consoles, to the BIOS's own cart-less
# face). MAME's slot defaults stand untouched: the vtech1/vtech2 ioexp and
# memexp buses default nullptr (src/devices/bus/vtech/), every cassette deck
# defaults CASSETTE_STOPPED (crvision: CASSETTE_PLAY, motor disabled) with no
# image, the crvision/vtech2/geniusiq/vsmile cartridge slots default nullptr,
# centronics (crvision/lasr2001) defaults the ROM-less "printer", and the
# vsmile controller port defaults the ROM-less "joy" pad. The vtech2 5.25"
# drives are HARDWIRED legacy floppy devices (one on laser350/laser500, two
# on laser700), not slots — built-in per the driver, ROM-less. Whether a
# cartridge gets baked for the crvision consoles or the V.Smiles (bare, the
# CreatiVision boots only its 2K BIOS; the V.Smile shows its "please insert
# a Learning Game" face) is D.'s policy call, staged as an open question,
# not decided here.
# Regions: crvisioj (TMS9918), vsmile and vsmilem (60Hz/262-line) are NTSC
# and join the NTSC canvas case in scripts/mksd.sh; all vtech1 machines
# (MC6847 in 312-line PAL mode), vtech2 (50Hz), the other crvision machines
# (TMS9929/9929A) and itunlim (50Hz) are PAL.
MACHINE_STRING_laser110     = laser110
MACHINE_STRING_laser200     = laser200
MACHINE_STRING_fellow       = fellow
MACHINE_STRING_tx8000       = tx8000
MACHINE_STRING_laser210     = laser210
MACHINE_STRING_vz200        = vz200
MACHINE_STRING_laser310     = laser310
MACHINE_STRING_vz300        = vz300
MACHINE_STRING_laser310h    = laser310h
MACHINE_STRING_laser350     = laser350
MACHINE_STRING_laser500     = laser500
MACHINE_STRING_laser700     = laser700
MACHINE_STRING_crvision     = crvision
MACHINE_STRING_fnvision     = fnvision
MACHINE_STRING_crvisioj     = crvisioj
MACHINE_STRING_wizzard      = wizzard
MACHINE_STRING_rameses      = rameses
MACHINE_STRING_vz2000       = vz2000
MACHINE_STRING_crvisio2     = crvisio2
MACHINE_STRING_lasr2001     = lasr2001
MACHINE_STRING_manager      = manager
MACHINE_STRING_vsmile       = vsmile
MACHINE_STRING_vsmilem      = vsmilem
MACHINE_STRING_itunlim      = itunlim

# --- VTech asset dependencies (manifest asset names) ---
# One self-contained romset zip name per machine. The aliased ROM_STARTs
# keep their own zip names carrying the same content (the a800xlp/mtx500
# precedent): laser200/fellow/tx8000 alias rom_laser110, vz300/laser310h
# alias rom_laser310, wizzard/crvisioj/crvisio2 alias rom_crvision,
# rameses/vz2000 alias rom_fnvision. The three vtech2 sets load identical
# members by content under their own names. itunlim's single 2MB member is
# unique to it (no fall-through to the excluded pcunlim parent). No device
# romset rides any slot default (all ROM-less). The manifest stanzas await
# the ROM-sourcing parcel.
MACHINE_ASSETS_laser110     = laser110
MACHINE_ASSETS_laser200     = laser200
MACHINE_ASSETS_fellow       = fellow
MACHINE_ASSETS_tx8000       = tx8000
MACHINE_ASSETS_laser210     = laser210
MACHINE_ASSETS_vz200        = vz200
MACHINE_ASSETS_laser310     = laser310
MACHINE_ASSETS_vz300        = vz300
MACHINE_ASSETS_laser310h    = laser310h
MACHINE_ASSETS_laser350     = laser350
MACHINE_ASSETS_laser500     = laser500
MACHINE_ASSETS_laser700     = laser700
MACHINE_ASSETS_crvision     = crvision
MACHINE_ASSETS_fnvision     = fnvision
MACHINE_ASSETS_crvisioj     = crvisioj
MACHINE_ASSETS_wizzard      = wizzard
MACHINE_ASSETS_rameses      = rameses
MACHINE_ASSETS_vz2000       = vz2000
MACHINE_ASSETS_crvisio2     = crvisio2
MACHINE_ASSETS_lasr2001     = lasr2001
MACHINE_ASSETS_manager      = manager
MACHINE_ASSETS_vsmile       = vsmile
MACHINE_ASSETS_vsmilem      = vsmilem
MACHINE_ASSETS_itunlim      = itunlim

# --- TRS / Tandy defaults strings ---
# Bare machine names: no slot anywhere is must_be_loaded — every machine
# boots from its own ROM to its own face (vis's firmware runs without a CD
# in its built-in drive).
# MAME's slot defaults stand untouched, and several are EXTERNAL add-on
# cartridges carrying their own device romset (the acorn precedent — the
# assets lines below name what those defaults load): the CoCo lines'
# cartridge slot defaults to the "fdc" CoCo FDC (cp400/cp400c2 override to
# "cp450_fdc", cd6809 to "cd6809_fdc"), the Dragons default to
# "dragon_fdc" (tanodr64/tanodr64h to "sdtandy_fdc"), and t4426's
# cartridge is FIXED by the driver (set_options(..., true)) to the Terco
# t4426 multi-cart — fixed hardware, never removed. Whether any external
# FDC default gets baked empty is D.'s policy call, staged as an open
# question, not decided here. Built-in hardware stands per the ruling:
# dgnalpha's internal WD2797 (its cart slot defaults nullptr) and vis's
# three fixed ISA cards (mcd/visaudio/visvga — all ROM-less, vis's
# firmware lives in its own romset). The mc10/alice cart slots default
# nullptr; cassette decks, centronics "printer" and the rs232 defaults
# (agvision's "null_modem", mc10's "rs_printer") are all ROM-less.
# NTSC (60Hz-raster) machines join the NTSC canvas case in
# scripts/mksd.sh: everything here EXCEPT the PAL machines — dragon32/
# dragon64/dragon64h/dragon200/dragon200e/d64plus/dgnalpha, coco3p and
# the 50Hz meritum line. MAME models the French Alice family and the
# Brazilian PAL-M clones at 60Hz, so those fill the NTSC canvas.
MACHINE_STRING_trs80        = trs80
MACHINE_STRING_trs80dt1     = trs80dt1
MACHINE_STRING_agvision     = agvision
MACHINE_STRING_trsvidtx     = trsvidtx
MACHINE_STRING_coco         = coco
MACHINE_STRING_cocoh        = cocoh
MACHINE_STRING_deluxecoco   = deluxecoco
MACHINE_STRING_coco2b       = coco2b
MACHINE_STRING_coco2bh      = coco2bh
MACHINE_STRING_cp400        = cp400
MACHINE_STRING_cp400c2      = cp400c2
MACHINE_STRING_mx1600       = mx1600
MACHINE_STRING_t4426        = t4426
MACHINE_STRING_lzcolor64    = lzcolor64
MACHINE_STRING_cd6809       = cd6809
MACHINE_STRING_ms1600       = ms1600
MACHINE_STRING_coco3        = coco3
MACHINE_STRING_coco3p       = coco3p
MACHINE_STRING_coco3h       = coco3h
MACHINE_STRING_msm3         = msm3
MACHINE_STRING_dragon32     = dragon32
MACHINE_STRING_dragon64     = dragon64
MACHINE_STRING_dragon64h    = dragon64h
MACHINE_STRING_dragon200    = dragon200
MACHINE_STRING_dragon200e   = dragon200e
MACHINE_STRING_d64plus      = d64plus
MACHINE_STRING_tanodr64     = tanodr64
MACHINE_STRING_tanodr64h    = tanodr64h
MACHINE_STRING_dgnalpha     = dgnalpha
MACHINE_STRING_mc10         = mc10
MACHINE_STRING_alice        = alice
MACHINE_STRING_alice32      = alice32
MACHINE_STRING_alice90      = alice90
MACHINE_STRING_meritum1     = meritum1
MACHINE_STRING_meritum2     = meritum2
MACHINE_STRING_meritum_net  = meritum_net
MACHINE_STRING_vis          = vis

# --- TRS / Tandy asset dependencies (manifest asset names) ---
# Own romset first, then split-set fall-through parents (the m5p/pentagon
# precedent) and the device romsets MAME's stock slot defaults load (the
# acorn precedent): coco_fdc (the coco/coco3 lines' default cart),
# cp450_fdc, cd6809_fdc, dragon_fdc, sdtandy_fdc, and t4426's fixed
# coco_t4426 multi-cart. coco2b/coco2bh load the parent's extbas11.rom
# (same name+hash), so they list coco too; every other set's members are
# self-carried. The pure-alias ROM_STARTs keep their own zip names (the
# a800xlp/mtx500 precedent): cocoh=coco, coco2bh=coco2b, coco3h=coco3,
# dragon64h=dragon64, tanodr64h=tanodr64, alice90=alice32. alice32 (and
# alias alice90) carry a BAD_DUMP charset.rom (borrowed from dcvg5k) — it
# loads, and whether it shows a blocking box is per-machine, the glass
# decides. The manifest stanzas await the ROM-sourcing parcel.
MACHINE_ASSETS_trs80        = trs80
MACHINE_ASSETS_trs80dt1     = trs80dt1
MACHINE_ASSETS_agvision     = agvision
MACHINE_ASSETS_trsvidtx     = trsvidtx
MACHINE_ASSETS_coco         = coco coco_fdc
MACHINE_ASSETS_cocoh        = cocoh coco_fdc
MACHINE_ASSETS_deluxecoco   = deluxecoco coco_fdc
MACHINE_ASSETS_coco2b       = coco2b coco coco_fdc
MACHINE_ASSETS_coco2bh      = coco2bh coco coco_fdc
MACHINE_ASSETS_cp400        = cp400 cp450_fdc
MACHINE_ASSETS_cp400c2      = cp400c2 cp450_fdc
MACHINE_ASSETS_mx1600       = mx1600 coco_fdc
MACHINE_ASSETS_t4426        = t4426 coco_t4426
MACHINE_ASSETS_lzcolor64    = lzcolor64 coco_fdc
MACHINE_ASSETS_cd6809       = cd6809 cd6809_fdc
MACHINE_ASSETS_ms1600       = ms1600 coco_fdc
MACHINE_ASSETS_coco3        = coco3 coco_fdc
MACHINE_ASSETS_coco3p       = coco3p coco_fdc
MACHINE_ASSETS_coco3h       = coco3h coco_fdc
MACHINE_ASSETS_msm3         = msm3 coco_fdc
MACHINE_ASSETS_dragon32     = dragon32 dragon_fdc
MACHINE_ASSETS_dragon64     = dragon64 dragon_fdc
MACHINE_ASSETS_dragon64h    = dragon64h dragon_fdc
MACHINE_ASSETS_dragon200    = dragon200 dragon_fdc
MACHINE_ASSETS_dragon200e   = dragon200e dragon_fdc
MACHINE_ASSETS_d64plus      = d64plus dragon_fdc
MACHINE_ASSETS_tanodr64     = tanodr64 sdtandy_fdc
MACHINE_ASSETS_tanodr64h    = tanodr64h sdtandy_fdc
MACHINE_ASSETS_dgnalpha     = dgnalpha
MACHINE_ASSETS_mc10         = mc10
MACHINE_ASSETS_alice        = alice
MACHINE_ASSETS_alice32      = alice32
MACHINE_ASSETS_alice90      = alice90
MACHINE_ASSETS_meritum1     = meritum1
MACHINE_ASSETS_meritum2     = meritum2
MACHINE_ASSETS_meritum_net  = meritum_net
MACHINE_ASSETS_vis          = vis

# Query helper: `make -f machines.mk -s print-MACHINE_STRING_spectrum`.
# Lets scripts read these facts without pulling in the Circle build.
print-%: ; @echo '$($*)'
