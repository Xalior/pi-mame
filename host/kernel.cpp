//
// kernel.cpp — Circle kernel hosting MAME.
//
// One machine per image: the emulated machine and its fixed facts are
// compiled-in constants (make MACHINE=spectrum|tbblue), so a shipped
// binary contains zero runtime decisions. The only boot-time knobs are
// Circle's own FAT-root cmdline.txt options (framebuffer geometry via
// width=/height=, socmaxtemp=) — platform boot config, not application
// configuration.
//
// The picker image (make MACHINE=picker) is the one deliberate exception:
// no machine is baked, so MAME boots into its system-selection list and
// the compiled-in family is the menu.
//
#include "kernel.h"
#include <circle/startup.h>
#include <circle/machineinfo.h>
#include <cstdio>

extern "C" int mame_circle_main(int argc, char **argv);
void CGlueStdioInit(CConsole &rConsole);

static const char From[] = "mame-host";

#if !defined(MAME_MACHINE) && !defined(MAME_PICKER)
#error the image's personality is baked: build with make MACHINE=spectrum|tbblue|picker
#endif

#ifndef MAME_MACHINE
#define MAME_MACHINE "picker"   // log label only; no machine enters argv
#endif

// The machine's argv, baked. -numprocessors 1: one core, cooperative
// threads — nothing preempts.
static const char *MameArgv[] = {
    "mame",
#ifndef MAME_PICKER
    MAME_MACHINE,
#endif
#ifdef MAME_HARDDISK
    "-hard1", MAME_HARDDISK,
#endif
    "-video", "soft",
    // keepaspect is desktop application surface; the appliance bakes it
    // off. The framebuffer IS the driver's raster (boot-config width=/
    // height=), so the soft renderer blits 1:1 — MAME's assumed-4:3 CRT
    // fit (a scale, glyph-destroying when it shrinks) never engages.
    // Physical aspect is the GPU scaler's business.
    "-nokeepaspect",
    "-numprocessors", "1",
    "-rompath", "/roms",
    "-cfg_directory", "/mame/cfg",
    "-skip_gameinfo",
};

CKernel::CKernel(void)
    : m_Timer(&m_Interrupt),
      m_Logger(m_Options.GetLogLevel(), &m_Timer),
      m_EMMC(&m_Interrupt, &m_Timer, &m_ActLED),
      m_Console(&m_Serial, &m_Serial),   // stdio over the UART
      m_CPUThrottle(CPUSpeedMaximum)
{
    m_ActLED.Blink(3);
}

boolean CKernel::Initialize(void)
{
    boolean bOK = TRUE;
    if (bOK) bOK = m_Serial.Initialize(115200);
    if (bOK) bOK = m_Logger.Initialize(&m_Serial);
    if (bOK) bOK = m_Interrupt.Initialize();
    if (bOK) bOK = m_Timer.Initialize();
    if (bOK) bOK = m_EMMC.Initialize();
    if (bOK) bOK = (f_mount(&m_FileSystem, "SD:", 1) == FR_OK);
    if (bOK)
    {
        // Every directory MAME writes into must exist before it runs:
        // there is no OS to create it, and MAME's next-free-filename scan
        // spins forever when a path component is missing (its probe loop
        // only stops on ENOENT for the file itself). Only what the
        // machine's runtime actually writes: cfg. FR_EXIST results are
        // fine here.
        f_mkdir("SD:/mame");
        f_mkdir("SD:/mame/cfg");
    }
    if (bOK) bOK = m_Console.Initialize();
    if (bOK) CGlueStdioInit(m_Console);
    return bOK;
}

TShutdownMode CKernel::Run(void)
{
    int argc = sizeof(MameArgv) / sizeof(MameArgv[0]);

    m_Logger.Write(From, LogNotice, "starting MAME: %s (%d baked args)",
                   MAME_MACHINE, argc - 1);

    // Geometry evidence belongs on serial (the HDMI capture dongle is not
    // pixel-faithful): what boot config handed us, next to the shim's
    // "framebuffer WxH" line when the window is created.
    m_Logger.Write(From, LogNotice, "boot config geometry: %ux%u",
                   m_Options.GetWidth(), m_Options.GetHeight());

    // SoC state around the run: render throughput lives and dies by the
    // ARM/core clocks, and CCPUThrottle clamps them to idle above the
    // socmaxtemp limit (cmdline.txt on the SD card; Circle default 60C).
    m_Logger.Write(From, LogNotice, "SoC: %uC, arm %u MHz, core %u MHz, socmaxtemp %uC",
                   m_CPUThrottle.GetTemperature(),
                   m_CPUThrottle.GetClockRate() / 1000000,
                   CMachineInfo::Get()->GetClockRate(CLOCK_ID_CORE) / 1000000,
                   CKernelOptions::Get()->GetSoCMaxTemp());

    int res = mame_circle_main(argc, const_cast<char **>(MameArgv));

    m_Logger.Write(From, LogNotice, "SoC: %uC, arm %u MHz, core %u MHz",
                   m_CPUThrottle.GetTemperature(),
                   m_CPUThrottle.GetClockRate() / 1000000,
                   CMachineInfo::Get()->GetClockRate(CLOCK_ID_CORE) / 1000000);
    m_Logger.Write(From, LogNotice, "MAME exited with %d, rebooting", res);

    // Back to the chainloader: quitting the emulator returns the machine
    // to its kernel-accepting state.
    return ShutdownReboot;
}
