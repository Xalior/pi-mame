#
# machines.mk — the per-machine facts, one place.
#
# Under the patchable-defaults string there is ONE platform binary
# (kernel8-platform.img): no machine is compiled in. Everything that used to
# be a per-machine compile-time bake is now data here —
#
#   PLATFORM_MACHINES_<platform>  which machines belong to which card
#   MACHINE_STRING_<machine>      the defaults-string patched into the block
#                                 (machine name + its media: -hard1 / -cart)
#   MACHINE_ASSETS_<machine>      the assets.manifest asset names the machine
#                                 needs — used to DERIVE its free/public tier
#                                 (a machine is free only if EVERY asset it
#                                 needs is free-tier; scripts/gen-bootmenu.sh
#                                 reads the per-asset tier from the manifest)
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

PLATFORMS = sinclair amstrad

PLATFORM_MACHINES_sinclair = spectrum spec128 specpls2 specpl2a specpls3 \
	tbblue specnext_ks1 specnext_ks2 specnext_ks3 zx80 zx81 tc2048 ts2068 \
	ts1000 ts1500 pentagon scorpio atmtb2 pentevo tsconf elwro800 byte sprinter

PLATFORM_MACHINES_amstrad = cpc464 cpc664 cpc6128 cpc464p cpc6128p gx4000 \
	kccomp nc100 nc200 pc1512

# All machines, both platforms — the roster `make kernels` bakes and CI verifies.
MACHINES = $(PLATFORM_MACHINES_sinclair) $(PLATFORM_MACHINES_amstrad)

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

# Query helper: `make -f machines.mk -s print-MACHINE_STRING_spectrum`.
# Lets scripts read these facts without pulling in the Circle build.
print-%: ; @echo '$($*)'
