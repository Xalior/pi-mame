//
// patch-defaults.cpp — HOST-side patcher for the 0x800 defaults block.
//
// Build tooling, never product surface: stamps a defaults string into a
// built platform kernel image the same way every pre-boot writer does, by
// compiling the boot picker's writer (rapi-bootloader/defaultsblock/defaultsblock.cpp — the
// shared ABI's one implementation) for the build host. The kernel Makefile
// uses it to turn the one platform binary into a per-machine
// kernel8-<machine>.img (patch the machine's defaults string in), and the
// off-bench round-trip check uses it to read a block back.
//
//   c++ -std=c++17 -I ../circle-stdlib/libs/circle/include \
//       -o patch-defaults patch-defaults.cpp ../rapi-bootloader/defaultsblock/defaultsblock.cpp
//
//   patch-defaults <kernel8-*.img> [string]   patch (empty string = clear)
//   patch-defaults -r <kernel8-*.img>         read the block back
//
#include "../rapi-bootloader/defaultsblock/defaultsblock.h"

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <vector>

static std::vector<u8> ReadFile (const char *pPath)
{
	FILE *f = fopen (pPath, "rb");
	if (f == nullptr)
	{
		perror (pPath);
		exit (1);
	}
	fseek (f, 0, SEEK_END);
	long nSize = ftell (f);
	fseek (f, 0, SEEK_SET);
	std::vector<u8> Image (nSize);
	if (fread (Image.data (), 1, nSize, f) != (size_t) nSize)
	{
		perror (pPath);
		exit (1);
	}
	fclose (f);
	return Image;
}

int main (int argc, char **argv)
{
	bool bRead = argc >= 2 && strcmp (argv[1], "-r") == 0;
	const char *pPath = bRead ? (argc == 3 ? argv[2] : nullptr)
				  : (argc >= 2 ? argv[1] : nullptr);
	if (pPath == nullptr)
	{
		fprintf (stderr, "usage: patch-defaults <image> [string]\n"
				 "       patch-defaults -r <image>\n");
		return 2;
	}

	std::vector<u8> Image = ReadFile (pPath);

	if (bRead)
	{
		if (Image.size () < DEFAULTS_BLOCK_OFFSET + sizeof (TDefaultsBlock))
		{
			fprintf (stderr, "%s: too small for a defaults block\n", pPath);
			return 1;
		}
		const TDefaultsBlock *pBlock =
			(const TDefaultsBlock *) (Image.data () + DEFAULTS_BLOCK_OFFSET);
		if (   pBlock->Magic[0] != DEFAULTS_MAGIC0
		    || pBlock->Magic[1] != DEFAULTS_MAGIC1
		    || pBlock->Magic[2] != DEFAULTS_MAGIC2
		    || pBlock->Magic[3] != DEFAULTS_MAGIC3)
		{
			fprintf (stderr, "%s: no defaults magic at 0x%X\n",
				 pPath, DEFAULTS_BLOCK_OFFSET);
			return 1;
		}
		printf ("capacity %u, length %u, text \"%.*s\"\n",
			pBlock->Capacity, pBlock->Length,
			(int) pBlock->Capacity, pBlock->Text);
		return 0;
	}

	const char *pString = argc >= 3 ? argv[2] : "";

	// The write path IS the boot picker's writer: seatbelt, capacity
	// enforcement, refusal semantics — one implementation for every
	// holder of the image.
	TPatchResult Result = PatchDefaults (Image.data (), Image.size (), pString);
	if (Result != PatchOK)
	{
		fprintf (stderr, "%s: %s\n", pPath, PatchResultString (Result));
		return 1;
	}

	FILE *f = fopen (pPath, "r+b");
	if (f == nullptr)
	{
		perror (pPath);
		return 1;
	}
	fseek (f, DEFAULTS_BLOCK_OFFSET, SEEK_SET);
	if (fwrite (Image.data () + DEFAULTS_BLOCK_OFFSET, 1,
		    sizeof (TDefaultsBlock), f) != sizeof (TDefaultsBlock))
	{
		perror (pPath);
		fclose (f);
		return 1;
	}
	fclose (f);

	printf ("%s: patched \"%s\" (%zu bytes) at 0x%X\n",
		pPath, pString, strlen (pString), DEFAULTS_BLOCK_OFFSET);
	return 0;
}
