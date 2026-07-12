/*
 * circle-defaults.ld — pi-mame platform linker script with the
 * patchable-defaults block (docs/pi-mame-poc2.html, shared ABI in
 * boot-picker/defaultsblock.h).
 *
 * Derived from circle-tls.ld (itself from Circle's circle.ld, GPLv3,
 * (C) R. Stange); differs in the .init layout only:
 *
 *   image offset 0x000  four-byte trampoline (`b _start`) — the image
 *                       opens with a branch over the boot furniture
 *   0x004..0x7ff        reserved boot furniture (room for an arm64-style
 *                       image header and anything not yet thought of)
 *   image offset 0x800  the defaults block: magic 'PM8D' + capacity +
 *                       length + Text[512] — the fixed offset every
 *                       pre-boot patcher writes (runtime 0x80800)
 *   ~0xa08              Circle's startup (_start), displaced past the
 *                       block; PC-relative and linker-symbol addressed
 *
 * The ASSERTs are the link-time half of the build gate: a kernel that
 * links this script without the trampoline/block objects, or with the
 * block anywhere but 0x800, refuses to link. The image-byte half
 * (magic verified in the produced .img) lives in mk/ld/circle-app.mk.
 */

ENTRY(_pimame_entry)

SECTIONS
{
	.init : {
		KEEP(*(.pimame.entry))

		/* first 2KB reserved boot furniture; offset is relative to
		   the section start (= the image start) */
		. = 0x800;

		KEEP(*(.pimame.defaults))

		*(.init)
	}

	ASSERT(DEFINED(_pimame_entry), "pi-mame: trampoline missing — link the defaults receiver object (defaults.o)")
	ASSERT(DEFINED(_pimame_defaults), "pi-mame: defaults block missing — link the defaults receiver object (defaults.o)")
	ASSERT(_pimame_entry == 0x80000, "pi-mame: trampoline is not at the image start")
	ASSERT(_pimame_defaults == 0x80800, "pi-mame: defaults block is not at image offset 0x800 (runtime 0x80800)")

	.text : {
		*(.text*)

		_etext = .;
	}

	.rodata : {
		*(.rodata*)
	}

	.init_array : {
		__init_start = .;

		KEEP(*(.init_array*))

		__init_end = .;
	}

	.ARM.exidx : {
		__exidx_start = .;

		*(.ARM.exidx*)

		__exidx_end = .;
	}

	.eh_frame_hdr : {
		__eh_frame_hdr_start = .;

		*(.eh_frame_hdr) *(.eh_frame_hdr.*)

		__eh_frame_hdr_end = .;
	}

	.eh_frame : {
		__eh_frame_start = .;

		*(.eh_frame) *(.eh_frame.*)

		__eh_frame_end = .;
	}

	.data : {
		*(.data*)
	}

	.tdata : ALIGN(8) {
		__tdata_start = .;

		*(.tdata .tdata.*)

		__tdata_end = .;
	}

	/* pi-mame: .tbss must directly follow .tdata — binutils 2.44+ refuses
	   to map a PT_TLS segment from non-adjacent TLS sections. */
	.tbss (NOLOAD) : ALIGN(8) {
		__tbss_start = .;

		*(.tbss .tbss.*)

		__tbss_end = .;
	}

	.bss : {
		__bss_start = .;

		*(.bss*)
		*(COMMON)

		__bss_end = .;
	}

	_end = .;
}
