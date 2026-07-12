//
// kernel.cpp — Circle kernel hosting MAME (the pi-mame platform binary).
//
// ONE binary, ANY machine. The machine name and its media
// (-hard1 /next/next.img, -cart /carts/sysukpd.bin) are NOT compiled in:
// they ride the patchable-defaults block at image offset 0x800 (shared ABI
// in boot-picker/defaultsblock.h), written before boot by whoever holds the
// image — the build system (baking a per-machine kernel8-<machine>.img), the
// boot picker (a menu pick), or the dev loader. DefaultsBuildArgv() appends
// that text to argv before MAME's first instruction; MAME's own CLI frontend
// parses it, exactly as it parses the baked policy flags below.
//
// An empty (or absent) block appends nothing, so MAME boots its own
// system-selection list — the degenerate "no-options" personality is just
// the unpatched platform binary. The only other boot-time knobs are Circle's
// FAT-root cmdline.txt options (framebuffer geometry via width=/height=,
// socmaxtemp=) — platform boot config, not application configuration.
//
// The law/policy line is physical: the evergreen decrees below stay compiled
// C, unreachable by any patcher. The string carries only what a machine is
// allowed to be.
//
#include "kernel.h"
#include "defaults.h"
#include <circle/startup.h>
#include <circle/machineinfo.h>
#include <cstdio>

extern "C" int mame_circle_main(int argc, char **argv);
void CGlueStdioInit(CConsole &rConsole);

static const char From[] = "mame-host";

// The baked policy argv: evergreen appliance decrees only, no machine.
// -numprocessors 1: one core, cooperative threads — nothing preempts.
static const char *MameArgv[] = {
    "mame",
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

// The final argv: the baked policy above plus whatever a pre-boot patcher
// wrote into the 0x800 defaults block (the machine, its media, minus any
// consumed --rapi-* kernel switch). Sized for the block's worst case —
// Capacity-1 single-character tokens — on top of the baked set, plus NULL.
static const char *s_FinalArgv[sizeof(MameArgv) / sizeof(MameArgv[0]) + 256 + 1];

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
    // Consume the patchable-defaults block (magic-verified at 0x80800)
    // BEFORE MAME sees argv: patched and unpatched boots run the identical
    // code path — an empty block appends nothing and MAME boots its system
    // list.
    int argc = DefaultsBuildArgv(MameArgv, sizeof(MameArgv) / sizeof(MameArgv[0]),
                                 s_FinalArgv,
                                 sizeof(s_FinalArgv) / sizeof(s_FinalArgv[0]));

    m_Logger.Write(From, LogNotice, "starting MAME platform binary (%d args)",
                   argc - 1);

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

    int res = mame_circle_main(argc, const_cast<char **>(s_FinalArgv));

    m_Logger.Write(From, LogNotice, "SoC: %uC, arm %u MHz, core %u MHz",
                   m_CPUThrottle.GetTemperature(),
                   m_CPUThrottle.GetClockRate() / 1000000,
                   CMachineInfo::Get()->GetClockRate(CLOCK_ID_CORE) / 1000000);
    m_Logger.Write(From, LogNotice, "MAME exited with %d, rebooting", res);

    // Back to the chainloader: quitting the emulator returns the machine
    // to its kernel-accepting state.
    return ShutdownReboot;
}
