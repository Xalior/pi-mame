//
// mamemain.cpp — entry into MAME's frontend from the Circle kernel.
//
// Performs what src/osd/sdl/sdlmain.cpp's main() does, minus the pieces
// that don't exist bare-metal (fontconfig, crash diagnostics). Compiled
// against MAME's headers with the same defines as the MAME build; the
// object replaces genie's sdlmain.o at link time.
//
#include "osdsdl.h"

#include "emu.h"
#include "emuopts.h"
#include "main.h"

#include "strconv.h"
#include "osdepend.h"

#include <SDL2/SDL.h>

#include <cstdio>
#include <string>
#include <vector>

// referenced by OSD code that sdlmain.cpp normally provides
int sdl_entered_debugger;

extern "C" int mame_circle_main(int argc, char **argv)
{
    std::vector<std::string> args = osd_get_command_line(argc, argv);

    setvbuf(stdout, nullptr, _IONBF, 0);
    setvbuf(stderr, nullptr, _IONBF, 0);

    int res;
    {
        sdl_options options;
        sdl_osd_interface osd(options);
        osd.register_options();
        res = emulator_info::start_frontend(options, osd, args);
    }
    return res;
}
