## display
Amiga

## intro
The Arcadia Multi Select arcade platform: Arcadia Systems' ten-interchangeable-game coin-op cabinet built on Amiga A500 hardware (an A500 motherboard driving an external ROM cage through the expansion port). Each `make kernel MACHINE=<name>` below bakes one machine into its own `kernel8-<name>.img` — see the [top-level README](../../README.md) for the build and the regional canvas.

## driver_note
Arcade coin-op on the Arcadia Multi Select hardware — an Amiga A500 motherboard driving an external ROM cage through the expansion port (see the driver header in `arsystems.cpp`) — hardware-proven on the Pi 4 bench.

## boot_caption_shared
`{fullname}` boots via the shared Arcadia System BIOS into its attract/title sequence — see the capture above.

## boot_caption_own
`{fullname}` boots directly from its own Kickstart into its attract/title sequence (no shared OnePlay/TenPlay BIOS menu) — see the capture above.

## machine_notes
ar_argh: Plugs directly into the A500 motherboard with its own Kickstart copy — no shared OnePlay/TenPlay BIOS selection, unlike the rest of the roster.
