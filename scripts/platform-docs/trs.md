## display
TRS / Tandy

## intro
The TRS / Tandy Radio Shack catalog (`src/mame/trs/` in MAME): the TRS-80 Model I (`trs80.cpp`) and DT-1 data terminal (`trs80dt1.cpp`); the 6809 Color Computer family — CoCo 1/2 and its Brazilian/Mexican/Swedish clones (`coco12.cpp`), the GIME-based CoCo 3 line (`coco3.cpp`), the AgVision/Videotex terminals (`agvision.cpp`) — with its Dragon offshoots (`dragon.cpp`, `dgnalpha.cpp`); the 6803 MC-10 and the Matra Alice family (`mc10.cpp`); the Polish Meritum I TRS-80 clones (`meritum.cpp`); and the Tandy/Memorex VIS CD player (`vis.cpp`). Each `make kernel MACHINE=<name>` below bakes one machine into its own `kernel8-<name>.img` — see the [top-level README](../../README.md) for the build and the regional canvas.
