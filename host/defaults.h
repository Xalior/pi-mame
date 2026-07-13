//
// defaults.h — the receiver side of the pi-mame patchable-defaults block.
//
// The block itself (layout, magic, capacity contract) is the shared ABI in
// rapi-bootloader/defaultsblock/defaultsblock.h — the writer (build system, boot picker) and
// this receiver share that one header; this header only declares how the
// platform kernel consumes it.
//
// The kernel calls DefaultsBuildArgv() once, before MAME's first
// instruction: the baked policy argv is copied, the block's text is
// verified (magic-at-offset first — the seatbelt), tokenised, and appended.
// The machine name and its media (-hard1, -cart) ride the block's text, so
// one platform binary runs any machine — an empty or absent string appends
// nothing and MAME boots its own system-selection list. Tokens in the
// kernel's own `--rapi-*` namespace are consumed here (they set kernel flags
// and never reach MAME); everything else passes through to MAME's argv,
// where MAME's own CLI frontend does all parsing.
//
#ifndef _pimame_defaults_h
#define _pimame_defaults_h

// Builds the final MAME argv: pBaked[0..nBaked) first, then the defaults
// block's tokens minus the consumed --rapi-* switches. ppArgv must hold
// nMax pointers; the returned argc never exceeds nMax. Token storage is
// static — call once, from one core, before MAME starts.
int DefaultsBuildArgv (const char **pBaked, unsigned nBaked,
		       const char **ppArgv, unsigned nMax);

// Kernel flags set by consumed --rapi-* switches. Plain ints with C
// linkage: the OSD glue (mamemain.cpp, compiled in the MAME environment)
// reads them without seeing any Circle header.
//
// --rapi-fps: turn on MAME's built-in FPS/speed readout (the public
// mame_ui_manager::set_show_fps setter, called from the OSD glue).
extern "C" int rapi_show_fps;

#endif
