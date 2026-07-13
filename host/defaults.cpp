//
// defaults.cpp — the receiver side of the pi-mame patchable-defaults block.
//
// Three responsibilities, all against the shared ABI in
// rapi-bootloader/defaultsblock/defaultsblock.h (the single source of truth — the writer and
// this receiver compile the same header):
//
//  1. CARRY the block: the image's one TDefaultsBlock instance lives in
//     section .pimame.defaults, which mk/ld/circle-defaults.ld pins to
//     image offset 0x800 (runtime 0x80800). It ships with the magic, the
//     capacity, and an empty string — an unpatched image boots straight to
//     MAME's system-selection list through the identical code path.
//
//  2. OPEN the image: the four-byte trampoline in .pimame.entry is the
//     first instruction of the image, branching over the reserved boot
//     furniture and the block to Circle's own _start.
//
//  3. CONSUME the text: DefaultsBuildArgv() verifies magic-at-offset FIRST
//     (the seatbelt: absent or wrong => the block is ignored and MAME boots
//     its system list), tokenises the length-bounded text, consumes the
//     kernel's own --rapi-* switches, and appends the rest (the machine name
//     and its media) to MAME's argv.
//
#include "defaults.h"
#include "../rapi-bootloader/defaultsblock/defaultsblock.h"

#include <circle/memorymap.h>
#include <circle/logger.h>
#include <cstring>

static const char From[] = "defaults";

// ---------------------------------------------------------------------------
// 2. The trampoline: the image's first four bytes. `b _start` is
// PC-relative (±128MB reach; the furniture is 2KB), so the image entry
// stays a single instruction whatever Circle's startup relocates to.
// ---------------------------------------------------------------------------
__asm__ (
	"\t.section .pimame.entry, \"ax\", %progbits\n"
	"\t.globl	_pimame_entry\n"
	"_pimame_entry:\n"
	"\tb	_start\n"
	"\t.previous\n"
);

// ---------------------------------------------------------------------------
// 1. The block instance. 'used' + the linker script's KEEP() keep it alive;
// the script's ASSERTs refuse any link that leaves it off 0x800.
// ---------------------------------------------------------------------------
extern "C"
{

__attribute__ ((section (".pimame.defaults"), used, aligned (8)))
TDefaultsBlock _pimame_defaults =
{
	{DEFAULTS_MAGIC0, DEFAULTS_MAGIC1, DEFAULTS_MAGIC2, DEFAULTS_MAGIC3},
	DEFAULTS_BUFFER_BYTES,
	0,			// Length: empty string
	{0}			// Text: NUL — appends nothing, MAME's system list
};

// Kernel flags settable by injected --rapi-* switches
int rapi_show_fps = 0;
int rapi_debug_uart = 0;

}

// The --rapi-* namespace belongs to the kernel by construction: every such
// token is consumed here (a typo'd kernel switch must not leak into MAME's
// CLI parser, which treats an unknown option as a fatal error). Recognised
// switches set their flag; unrecognised ones are logged and dropped.
static void DispatchKernelSwitch (const char *pSwitch)
{
	if (strcmp (pSwitch, "--rapi-fps") == 0)
	{
		rapi_show_fps = 1;
		CLogger::Get ()->Write (From, LogNotice,
					"--rapi-fps consumed: MAME FPS/speed readout on");
	}
	else if (strcmp (pSwitch, "--rapi-debug-uart") == 0)
	{
		rapi_debug_uart = 1;
		CLogger::Get ()->Write (From, LogNotice,
					"--rapi-debug-uart consumed: serial key injection on");
	}
	else
	{
		CLogger::Get ()->Write (From, LogWarning,
					"unrecognised kernel switch \"%s\" ignored", pSwitch);
	}
}

// ---------------------------------------------------------------------------
// 3. Consumption. The text is copied out of the block before tokenising so
// the block itself stays pristine (it is bench evidence: serial can dump
// it, and a re-read must see what the patcher wrote).
// ---------------------------------------------------------------------------

// Worst case: Capacity-1 text bytes of single-character tokens.
static char s_TokenText[DEFAULTS_BUFFER_BYTES];

int DefaultsBuildArgv (const char **pBaked, unsigned nBaked,
		       const char **ppArgv, unsigned nMax)
{
	CLogger *pLogger = CLogger::Get ();

	unsigned nArgc = 0;
	for (unsigned i = 0; i < nBaked && nArgc < nMax - 1; i++)
	{
		ppArgv[nArgc++] = pBaked[i];
	}

	// Seatbelt FIRST: the block is read at the ABI offset (runtime
	// MEM_KERNEL_START + 0x800), never through the symbol — if a
	// reordered link script moved the data, the magic is not at the
	// offset, and the block is ignored: MAME's system list boots.
	const TDefaultsBlock *pBlock =
		(const TDefaultsBlock *) (MEM_KERNEL_START + DEFAULTS_BLOCK_OFFSET);
	if (   pBlock->Magic[0] != DEFAULTS_MAGIC0
	    || pBlock->Magic[1] != DEFAULTS_MAGIC1
	    || pBlock->Magic[2] != DEFAULTS_MAGIC2
	    || pBlock->Magic[3] != DEFAULTS_MAGIC3)
	{
		pLogger->Write (From, LogWarning,
				"no block magic at 0x%lX — MAME system list",
				(unsigned long) (MEM_KERNEL_START + DEFAULTS_BLOCK_OFFSET));
		ppArgv[nArgc] = nullptr;
		return nArgc;
	}

	// The text is bounded by the block's own Capacity (never beyond this
	// build's buffer) and terminated at its first NUL; Length is the
	// writer's convenience, not the authority.
	unsigned nBound = pBlock->Capacity;
	if (nBound > DEFAULTS_BUFFER_BYTES)
	{
		nBound = DEFAULTS_BUFFER_BYTES;
	}
	memcpy (s_TokenText, pBlock->Text, nBound);
	s_TokenText[nBound - 1] = '\0';

	if (s_TokenText[0] == '\0')
	{
		pLogger->Write (From, LogNotice,
				"empty defaults string — MAME system list");
		ppArgv[nArgc] = nullptr;
		return nArgc;
	}

	pLogger->Write (From, LogNotice, "injected: \"%s\"", s_TokenText);

	// Whitespace-split in the private copy; each token is either a
	// kernel switch (consumed) or a MAME argument (appended). Double
	// quotes group whitespace INTO one token and are stripped from it:
	// the tokens the writer must express carry embedded spaces —
	// -iec8 "" (an EMPTY argv entry, MAME's only way to bake a slot empty)
	// and -view "Screen 1" (a multi-screen view name, its space and all).
	// Quotes are removed as the token is compacted in place; the write
	// cursor never outruns the read cursor (quotes only shrink a token),
	// so the copy is safe within the one buffer.
	unsigned nInjected = 0;
	unsigned nConsumed = 0;
	char *p = s_TokenText;
	while (*p != '\0')
	{
		while (*p == ' ' || *p == '\t')
		{
			p++;
		}
		if (*p == '\0')
		{
			break;
		}

		char *pToken = p;	// start of the compacted token
		char *pWrite = p;	// where the next kept char lands
		while (*p != '\0' && *p != ' ' && *p != '\t')
		{
			if (*p == '"')
			{
				// Quoted run: copy verbatim (spaces and all)
				// until the closing quote, dropping both quotes.
				p++;
				while (*p != '\0' && *p != '"')
				{
					*pWrite++ = *p++;
				}
				if (*p == '"')
				{
					p++;
				}
				continue;
			}
			*pWrite++ = *p++;
		}
		if (*p != '\0')
		{
			p++;		// step past the delimiter
		}
		*pWrite = '\0';		// terminate the compacted token

		if (strncmp (pToken, "--rapi-", 7) == 0)
		{
			DispatchKernelSwitch (pToken);
			nConsumed++;
		}
		else if (nArgc < nMax - 1)
		{
			ppArgv[nArgc++] = pToken;
			nInjected++;
		}
		else
		{
			pLogger->Write (From, LogError,
					"argv full — token \"%s\" dropped", pToken);
		}
	}

	pLogger->Write (From, LogNotice,
			"%u MAME arg(s) appended, %u kernel switch(es) consumed",
			nInjected, nConsumed);

	ppArgv[nArgc] = nullptr;
	return nArgc;
}
