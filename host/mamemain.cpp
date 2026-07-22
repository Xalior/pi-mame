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
#include "fileio.h"
#include "mame.h"
#include "ui/ui.h"
#include "ui/uimain.h"

#include "defaults.h"

#include "corestr.h"
#include "strconv.h"
#include "strformat.h"
#include "osdepend.h"

#include <sstream>

#include <SDL2/SDL.h>

#include <cstdio>
#include <string>
#include <vector>

// referenced by OSD code that sdlmain.cpp normally provides
int sdl_entered_debugger;

// running_machine::nvram_save() and its nvram_filename() helper are private, so
// we replicate them from the public nvram_interface_enumerator. The filename
// MUST match byte-for-byte what MAME's own nvram_load() reconstructs at boot
// (it is private too, same convention) or the store never reloads. Kept a
// faithful copy of machine.cpp's logic; diverging here silently breaks reload.
static std::string rapi_nvram_filename(running_machine &m, device_t &device)
{
    std::ostringstream result;
    result << m.basename();
    if (m.root_device().system_bios() != 0 &&
        m.root_device().default_bios() != m.root_device().system_bios())
        util::stream_format(result, "_%d", m.root_device().system_bios() - 1);

    // device-based NVRAM gets its own name in a subdirectory
    if (device.owner() != nullptr)
    {
        const char *software = nullptr;
        for (device_t *dev = &device; dev->owner() != nullptr; dev = dev->owner())
        {
            device_image_interface *intf;
            if (dev->interface(intf)) { software = intf->basename_noext(); break; }
        }
        if (software != nullptr && *software != '\0')
            result << PATH_SEPARATOR << software;

        std::string tag(device.tag());
        tag.erase(0, 1);
        strreplacechr(tag, ':', '_');
        result << PATH_SEPARATOR << tag;
    }
    return result.str();
}

static void rapi_nvram_save(running_machine &m)
{
    for (device_nvram_interface &nvram : nvram_interface_enumerator(m.root_device()))
    {
        if (!nvram.nvram_can_save())
            continue;
        emu_file file(m.options().nvram_directory(),
                      OPEN_FLAG_WRITE | OPEN_FLAG_CREATE | OPEN_FLAG_CREATE_PATHS);
        if (file.open(rapi_nvram_filename(m, nvram.device())))
            continue;                    // open failed; nothing to write
        bool error = !nvram.nvram_save(file);
        if (error || file.size() == 0)
            file.remove_on_close();      // don't leave a broken/empty store
        file.close();
    }
}

// The appliance never exits, so MAME's exit-time cfg/NVRAM save never fires.
// The one trustworthy "the user just made a change" signal is the FALLING EDGE
// of MAME's own menu: the OSD menu was open and is now closed. On that edge we
// checkpoint the machine:
//   - save_settings() writes cfg (input remaps, dip/config switches) to the
//     baked -cfg_directory;
//   - nvram_save() walks the machine's nvram_interface devices and writes each
//     battery-backed store to the baked -nvram_directory.
// Both are public running_machine calls MAME itself uses at exit — we only
// change WHEN they fire. Zero MAME edits: we observe the public menu-active
// state from update(). The menu is the appliance's settling point; NVRAM that
// changes purely in-game is captured the next time the user visits the menu.
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

        // --rapi-fps (bench switch, defaults.cpp): light MAME's own
        // FPS/speed readout once the machine runs, via the public
        // mame_ui_manager::set_show_fps setter.
        if (rapi_show_fps && !m_fps_applied)
        {
            mame_machine_manager::instance()->ui().set_show_fps(true);
            m_fps_applied = true;
        }

        const bool menu = m.ui().is_menu_active();
        if (m_prev_menu_active && !menu)
        {
            m.configuration().save_settings();
            rapi_nvram_save(m);
        }
        m_prev_menu_active = menu;
    }

private:
    bool m_prev_menu_active = false;
    bool m_fps_applied = false;
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
