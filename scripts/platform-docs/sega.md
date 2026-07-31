## display
Sega

## intro
Sega's mid-1980s arcade racing hardware — the boards behind Hang-On and Out Run (`segahang.cpp` and `segaorun.cpp` in MAME). They share a design: two Motorola 68000 processors, a video board that draws the road and the scenery by scaling sprites, and a Z80 with a Yamaha FM sound chip for the music. Scaling sprites is how these games created a sense of speed and distance years before arcade hardware could draw 3D. Some of these machines use an encrypted processor, and where they do, the decryption key is a required part of the romset — the machine's own page says so. Sega's directory in MAME covers a great deal of other hardware as well; the machines listed below are the ones brought over so far. Each `make kernel MACHINE=<name>` below bakes one machine into its own `kernel8-<name>.img` — see the [top-level README](../../README.md) for the build and the regional canvas.
