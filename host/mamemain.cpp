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
#include "config.h"
#include "ui/uimain.h"

#include "strconv.h"
#include "osdepend.h"

#include <SDL2/SDL.h>

#include <cstdio>
#include <string>
#include <vector>

// referenced by OSD code that sdlmain.cpp normally provides
int sdl_entered_debugger;

// The appliance never exits, so MAME's exit-time cfg/NVRAM save never fires.
// The one trustworthy "the user just made a change" signal is the FALLING EDGE
// of MAME's own menu: the OSD menu was open and is now closed. On that edge we
// checkpoint the machine — save its settings (cfg: input remaps, dip/config
// switches, and skip_warnings timestamps) to the baked -cfg_directory. Zero
// MAME edits: we only observe the public menu-active state from update().
class rapi_osd_interface : public sdl_osd_interface
{
public:
    using sdl_osd_interface::sdl_osd_interface;

    virtual void update(bool skip_redraw) override
    {
        sdl_osd_interface::update(skip_redraw);

        running_machine &m = machine();
        if (m.phase() != machine_phase::RUNNING)
            return;

        const bool menu = m.ui().is_menu_active();
        if (m_prev_menu_active && !menu)
            m.configuration().save_settings();
        m_prev_menu_active = menu;
    }

private:
    bool m_prev_menu_active = false;
};

extern "C" int mame_circle_main(int argc, char **argv)
{
    std::vector<std::string> args = osd_get_command_line(argc, argv);

    setvbuf(stdout, nullptr, _IONBF, 0);
    setvbuf(stderr, nullptr, _IONBF, 0);

    int res;
    {
        sdl_options options;
        rapi_osd_interface osd(options);
        osd.register_options();
        res = emulator_info::start_frontend(options, osd, args);
    }
    return res;
}
