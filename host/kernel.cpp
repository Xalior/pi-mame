//
// kernel.cpp — Circle kernel hosting MAME (the pi-mame platform binary).
//
// ONE binary, ANY machine. The machine name and its media
// (-hard1 /next/next.img, -cart /carts/sysukpd.bin) are NOT compiled in:
// they ride the patchable-defaults block at image offset 0x800 (shared ABI
// in rapi-bootloader/defaultsblock/defaultsblock.h), written before boot by whoever holds the
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
#include "xthreading.h"
#include "defaults.h"
#include <circle/startup.h>
#include <circle/machineinfo.h>
#include <SDL2/SDL_circle.h>
#include <cstdio>
#include <thread>

extern "C" int mame_circle_main(int argc, char **argv);
void CGlueStdioInit(CConsole &rConsole);

// --rapi-debug-uart (consumed in defaults.cpp) arms serial key injection: the
// shim types serial-RX bytes into the running machine. Dev bench only — the
// switch is never baked into a shipped image.
extern "C" int rapi_debug_uart;
void SDL2Circle_SetInjectSerial(CSerialDevice *pSerial);

static const char From[] = "mame-host";

// Secondary-core dispatch: MAME's core and the spare worker core run the
// threading library's dispatcher; the presentation core runs the shim's
// worker. Role-to-core binding is a per-world constant.
void CSplitCores::Run(unsigned nCore)
{
    switch (nCore)
    {
    case 1:
    case 3:
        xthread_core_main(nCore);          // never returns
        break;
    case 2:
        SDL2Circle_SplitPresentCore();     // never returns
        break;
    }
}

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
    "-nvram_directory", "/mame/nvram",
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

// Build-timestamp epoch (seconds since 1970-01-01 UTC) from __DATE__/__TIME__.
// Monotonic across releases, always a plausible "now".
static unsigned BuildEpoch(void)
{
    static const char months[] = "JanFebMarAprMayJunJulAugSepOctNovDec";
    const char *d = __DATE__;   // "Mmm dd yyyy"
    const char *t = __TIME__;   // "hh:mm:ss"

    int mon = 1;
    for (int i = 0; i < 12; i++)
        if (d[0] == months[i*3] && d[1] == months[i*3+1] && d[2] == months[i*3+2])
            { mon = i + 1; break; }
    int day  = (d[4] == ' ' ? 0 : d[4] - '0') * 10 + (d[5] - '0');
    int year = (d[7]-'0')*1000 + (d[8]-'0')*100 + (d[9]-'0')*10 + (d[10]-'0');
    int hh = (t[0]-'0')*10 + (t[1]-'0');
    int mm = (t[3]-'0')*10 + (t[4]-'0');
    int ss = (t[6]-'0')*10 + (t[7]-'0');

    // days since 1970-01-01 (civil-to-days, treated as UTC)
    int y = year - (mon <= 2);
    int era = (y >= 0 ? y : y - 399) / 400;
    unsigned yoe = (unsigned)(y - era * 400);
    unsigned doy = (153u * (mon + (mon > 2 ? -3 : 9)) + 2) / 5 + day - 1;
    unsigned doe = yoe*365 + yoe/4 - yoe/100 + doy;
    long days = (long)era*146097 + (long)doe - 719468;
    return (unsigned)(days * 86400L + hh*3600 + mm*60 + ss);
}

boolean CKernel::Initialize(void)
{
    boolean bOK = TRUE;
    if (bOK) bOK = m_Serial.Initialize(115200);
    if (bOK) bOK = m_Logger.Initialize(&m_Serial);
    if (bOK) bOK = m_Interrupt.Initialize();
    if (bOK) bOK = m_Timer.Initialize();
    // The appliance has no battery RTC and no NTP, so the wall-clock starts
    // unset (time() -> 1970). A machine with an emulated RTC (Amstrad NC100/
    // NC200) reads "1970 / clock never set" as power-loss and, on boot, WIPES
    // its battery-backed store even after the NVRAM reloaded correctly. Seed a
    // sane baked wall-clock (the build time) before MAME runs — like a device
    // whose clock was set once at the factory — so the emulated RTC is valid
    // and NVRAM persistence survives. MAME captures time() during machine
    // construction, so this must happen here, ahead of mame_circle_main.
    if (bOK) m_Timer.SetTime(BuildEpoch(), FALSE /* universal */);
    if (bOK) bOK = m_EMMC.Initialize();
    if (bOK) bOK = (f_mount(&m_FileSystem, "SD:", 1) == FR_OK);
    if (bOK)
    {
        // Every directory MAME writes into must exist before it runs:
        // there is no OS to create it, and MAME's next-free-filename scan
        // spins forever when a path component is missing (its probe loop
        // only stops on ENOENT for the file itself). What the machine's
        // runtime writes: cfg (settings on menu-close) and nvram (battery-
        // backed stores on menu-close). FR_EXIST results are fine here.
        f_mkdir("SD:/mame");
        f_mkdir("SD:/mame/cfg");
        f_mkdir("SD:/mame/nvram");
    }
    if (bOK) bOK = m_Console.Initialize();
    if (bOK) CGlueStdioInit(m_Console);
    // Start the secondary cores. They park in CSplitCores::Run until the
    // split's rings and the threading dispatcher are armed, below.
    if (bOK) bOK = m_Cores.Initialize();
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

    // Dev bench: hand the shim our serial so a console can type into the
    // running machine (dismiss a warning box, pick a +3 Loader, LOAD a disk).
    if (rapi_debug_uart)
    {
        SDL2Circle_SetInjectSerial(&m_Serial);
        m_Logger.Write(From, LogNotice,
                       "serial key injection armed (--rapi-debug-uart)");
    }

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

    // Arm the split BEFORE MAME's first instruction: the shim's servo and
    // watchdog tasks (core 0), and the threading library's creator task, so
    // MAME can create its service threads from core 1 and every device call
    // it makes is already being marshaled back to the core that owns the
    // hardware.
    SDL2Circle_SplitInit();
    xthread_init();

    // MAME, alone, on core 1: a pinned thread on the xthreading dispatcher —
    // no pump work, no interrupt jitter, no audio mixing sharing its core.
    xthread_pin_next(1);
    static int s_mame_result = -1;
    std::thread mame([argc]
    {
        s_mame_result = mame_circle_main(argc, const_cast<char **>(s_FinalArgv));
    });

    // Core 0 belongs to its tasks now; this join spins through scheduler
    // yields, which IS this world's idle loop.
    mame.join();
    int res = s_mame_result;

    m_Logger.Write(From, LogNotice, "SoC: %uC, arm %u MHz, core %u MHz",
                   m_CPUThrottle.GetTemperature(),
                   m_CPUThrottle.GetClockRate() / 1000000,
                   CMachineInfo::Get()->GetClockRate(CLOCK_ID_CORE) / 1000000);
    m_Logger.Write(From, LogNotice, "MAME exited with %d, rebooting", res);

    // Back to the chainloader: quitting the emulator returns the machine
    // to its kernel-accepting state.
    return ShutdownReboot;
}
