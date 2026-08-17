//
// kernel.cpp — Circle kernel hosting MAME (the pi-mame platform binary).
//
// ONE binary, ANY machine. The machine name and its media
// (-hard1 /media/hard/tbblue/next.img, -cart /media/cart/cpc6128p/sysukpd.bin)
// are NOT compiled in:
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
// FAT-root cmdline.txt options (width=/height=, socmaxtemp=) — platform boot
// config, not application configuration. The card sets the machine's
// raster (the PAL canvas) as width=/height= on EVERY board and MAME
// renders it 1:1; what lifts it to the glass is per-board — Pi 3/4
// firmware outputs the geometry as the video signal (the panel
// stretches), Pi 5 firmware ignores mode requests (one native-EDID
// surface), so the shim's presentation core scales the canvas onto the
// native scanout, aspect preserved.
//
// The law/policy line is physical: the evergreen decrees below stay compiled
// C, unreachable by any patcher. The string carries only what a machine is
// allowed to be.
//
#include "kernel.h"
#include "defaults.h"
#include <circle/startup.h>
#include <circle/machineinfo.h>
#include <SDL2/SDL_circle.h>
#include <atomic>
#include <cstdio>
#include <unistd.h>     // chdir — MAME's paths are relative to /mame

extern "C" int mame_circle_main(int argc, char **argv);

// The region canvas: the virtual display every machine gets unless its
// defaults block names its own with --rapi-vfb=WxH, which the library reads
// and applies for itself. PAL,
// CRT-shaped — the frame every PAL machine historically filled. (PoC3 rules
// the regional canvas PAL-only; an NTSC canvas arrives with an NTSC card.)
static const int CanvasWidth  = 720;
static const int CanvasHeight = 576;

static const char From[] = "mame-host";

// The baked policy argv: evergreen appliance decrees only, no machine.
// -numprocessors 1: one core, cooperative threads — nothing preempts.
static const char *MameArgv[] = {
    "mame",
    "-video", "soft",
    // keepaspect is desktop application surface; the appliance bakes it
    // off ON EVERY BOARD. The canvas IS the machine's raster (boot-config
    // width=/height=), so the soft renderer blits 1:1 — MAME's
    // assumed-4:3 CRT fit (a scale, glyph-destroying when it shrinks)
    // never engages. What lifts the canvas to the glass is per-board and
    // none of MAME's business: Pi 3/4 firmware outputs it as the video
    // signal (the panel stretches); Pi 5 firmware cannot, so the shim's
    // presentation core scales it onto the native scanout, aspect
    // preserved, off the emulation core entirely.
    "-nokeepaspect",
    "-numprocessors", "1",
    // RELATIVE, resolved against /mame — see the chdir in Initialize(). Every
    // file this appliance owns lives under that one directory, so a card can
    // carry other things beside it without this kernel writing anywhere near
    // them, and a machine's media path in the defaults block is relative for
    // the same reason.
    "-rompath", "roms",
    "-cfg_directory", "cfg",
    "-nvram_directory", "nvram",
    "-skip_gameinfo",
};

// The final argv: the baked policy above plus whatever a pre-boot patcher
// wrote into the 0x800 defaults block (the machine, its media, minus any
// consumed --rapi-* kernel switch). Sized for the block's worst case —
// Capacity-1 single-character tokens — on top of the baked set, plus NULL.
static const char *s_FinalArgv[sizeof(MameArgv) / sizeof(MameArgv[0]) + 256 + 1];

// ---------------------------------------------------------------------------
// The gate between core 0 and MAME's core.
//
// The secondary cores are started at the end of Initialize(), because that is
// where the Circle world is finished. MAME must not begin until the shim's
// split is armed: until then its platform calls would run on a core with no
// mailbox to carry them back to the hardware. So core 1 waits here and core 0
// opens the gate once SDL2Circle_SplitInit has returned.
//
// The result travels back the same way. Core 0 cannot join a core, so core 1
// publishes what MAME returned and core 0 watches for it while yielding to the
// scheduler — which is what keeps the servo, the watchdog and every device
// alive for as long as the machine runs.
// ---------------------------------------------------------------------------
static std::atomic<int> s_MameGate{0};     // core 0 -> MAME's core
static std::atomic<int> s_MameDone{0};     // MAME's core -> core 0
static int s_MameResult = -1;
static int s_MameArgc = 0;

static inline void PublishToOtherCores(void)
{
    asm volatile("dsb ish; sev" ::: "memory");
}

static void ParkCore(void)
{
    for (;;)
        asm volatile("wfe" ::: "memory");
}

// Secondary-core dispatch. MAME is a direct call on its own core, not a
// thread: at -numprocessors 1 it creates no worker threads, so there is
// nothing for a dispatcher to place and nothing to pin.
void CSplitCores::Run(unsigned nCore)
{
    // A freshly started core holds whatever the firmware left in its thread
    // pointer, and C++ exception state is reached through it: arm the runtime
    // before this core executes anything that can throw.
    SDL2Circle_ArmCoreRuntime();

    switch (nCore)
    {
    case 1:
        // The application core. Wait for the gate, run the machine, publish
        // what it returned, then go quiet — this core has no other purpose
        // and must not fall through into anything.
        while (!s_MameGate.load(std::memory_order_acquire))
            asm volatile("wfe" ::: "memory");

        s_MameResult = mame_circle_main(s_MameArgc,
                                        const_cast<char **>(s_FinalArgv));

        s_MameDone.store(1, std::memory_order_release);
        PublishToOtherCores();
        ParkCore();
        break;

    case 2:
        SDL2Circle_SplitPresentCore();     // never returns
        break;

    default:
        ParkCore();
        break;
    }
}

CKernel::CKernel(void)
    // Serial device 0 is the GPIO14/15 header UART on every board. Named
    // explicitly because Circle's RASPPI >= 5 default (SERIAL_DEVICE_DEFAULT
    // = 10) is the Pi 5's dedicated debug connector, not the header.
    : m_Serial(0, FALSE, 0),
      m_Timer(&m_Interrupt),
      m_Logger(m_Options.GetLogLevel(), &m_Timer),
      m_EMMC(&m_Interrupt, &m_Timer, &m_ActLED),
      m_USB(&m_Interrupt, &m_Timer, TRUE /* plug-and-play */)
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

    // The read cache goes in between the card and everything above it, after
    // the card has registered its name and before the first mount reads a
    // sector. FatFs finds its device by name and holds no pointer to the
    // card, so taking the name over is the whole of the interposition: MAME's
    // ROM loading, the C library and FatFs itself all arrive here without
    // knowing. Configure() is what gives it memory.
    //
    // The pool is the library's own default, which the card figures say is
    // already far larger than this program's working set. The READ-AHEAD is
    // ours, and deeper than the library's, because of who owns which core
    // here. The library errs shallow to protect whatever the reading core owes
    // an answer to; under the core split this core owes the sound device its
    // ring, and nothing is drawn on it at all. That deadline is the audio
    // device's hardware queue rather than a frame, which is long enough to
    // absorb a bigger single transaction — while the total time inside the
    // card driver, which is what actually keeps this core away from the ring,
    // keeps falling as the window grows.
    //
    // MAME reads the card in single sectors and the large majority of them
    // run on from the last, which is exactly the shape read-ahead exists for.
    //
    // Not fatal. A refusal leaves the name resolving to the card itself, and
    // the machine runs uncached.
    if (bOK && !m_DiskCache.Install())
        m_Logger.Write(From, LogWarning,
                       "disk cache did not install — the card is unwrapped "
                       "and no disk figures will be reported");
    if (bOK && !m_DiskCache.Configure(DISKCACHE_DEFAULT_KB, 64))
        m_Logger.Write(From, LogWarning,
                       "disk cache refused its memory — running without it");

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

    // EVERYTHING MAME TOUCHES IS UNDER /mame, and it gets there by working
    // from inside it rather than by every path saying so. MAME's own
    // directory options are relative (see MameArgv), a machine's media path in
    // the defaults block is relative, and both resolve from here.
    //
    // The point is what it keeps OUT. A card can carry another project's boot
    // files, its own loader, anything — and this kernel cannot write outside
    // the one directory it was pointed at, because it never names a path that
    // leaves it.
    //
    // chdir() directly rather than through the shim's I/O service: this runs
    // on core 0, which is the core the service would have marshalled it to,
    // and it must be settled before MAME opens anything. Both reach the same
    // C library, so a relative open from MAME's core resolves against it.
    if (bOK && chdir("/mame") != 0)
    {
        m_Logger.Write(From, LogError,
                       "could not enter /mame — every ROM and config path is "
                       "relative to it, so the machine has nothing to read");
        bOK = FALSE;
    }
    // Nothing binds stdio here. SDL2Circle_ArmCoreRuntime below builds the
    // shim's own console — a keyboard on it, and its output following
    // whatever the logging destination is — and binds descriptors 0, 1 and 2
    // to it. The C library binds those three together and asserts inside
    // CGlueInitConsole if they are bound twice, which stops the board with
    // "assertion !stdin->IsOpen() failed" before MAME starts.

    // USB, here and not inside MAME's SDL_Init. Enumeration is slow and
    // interrupt-driven, and right here it has core 0 to itself with nothing
    // waiting on it — which is exactly what it does NOT have once the split
    // is armed and core 0's servo is the only thing answering the other
    // cores. Not fatal: a board with no working USB still runs the machine,
    // with no keyboard and no pad, and that is worth saying rather than
    // dying for.
    if (bOK && !m_USB.Initialize())
        m_Logger.Write(From, LogWarning,
                       "USB did not come up — the machine will run without a "
                       "keyboard or a joystick");

    // Core 0 runs library and application code like any other core, so it
    // arms itself too. Here rather than in main(): the call runs deferred
    // constructors and creates a scheduler where the host has none, so it
    // belongs after the card is mounted and stdio is wired — before the
    // secondary cores start, and before the first thing that can throw.
    if (bOK) SDL2Circle_ArmCoreRuntime();

    // Start the secondary cores last: the world they are about to work in
    // has to be complete first, because core 0 is busy serving them from the
    // moment they run. They park in CSplitCores::Run until Run() below arms
    // the split and opens the gate.
    if (bOK) bOK = m_Cores.Initialize();
    return bOK;
}

TShutdownMode CKernel::Run(void)
{
    // Consume the patchable-defaults block (magic-verified at 0x80800)
    // BEFORE MAME sees argv: patched and unpatched boots run the identical
    // code path — an empty block appends nothing and MAME boots its system
    // list.
    s_MameArgc = DefaultsBuildArgv(MameArgv, sizeof(MameArgv) / sizeof(MameArgv[0]),
                                   s_FinalArgv,
                                   sizeof(s_FinalArgv) / sizeof(s_FinalArgv[0]));

    m_Logger.Write(From, LogNotice, "starting MAME platform binary (%d args)",
                   s_MameArgc - 1);

    // Every --rapi- switch in the defaults block belongs to the library. It
    // reads the block itself, at the same offset, and acts on its own
    // switches — serial key injection, performance reports — with nothing
    // wired here. This kernel only strips them from MAME's argv.

    // Geometry evidence belongs on serial (the HDMI capture dongle is not
    // pixel-faithful): what boot config handed us, read next to the shim's
    // framebuffer-grant line (size/pitch are the scanout truth on boards
    // whose firmware ignores requests) when the window is created. Under
    // the declared-display contract this is the firmware MODE REQUEST
    // only — it plays no part in what MAME is given.
    m_Logger.Write(From, LogNotice, "boot config geometry: %ux%u",
                   m_Options.GetWidth(), m_Options.GetHeight());

    // Declare the region canvas — the resolution MAME is given when the
    // machine does not name one, whatever the glass is doing; the shim's
    // presentation core scales it out, aspect preserved.
    //
    // A machine that has its own raster carries it as --rapi-vfb=WxH in the
    // defaults block, and that switch beats this declaration inside the
    // library: it reads the block itself, before SDL_Init, and holds the
    // value against everything below it. So this is the floor rather than
    // the decision, and the kernel neither reads that switch nor forwards
    // it.
    if (SDL2Circle_DeclareVirtualDevice(32, CanvasWidth, CanvasHeight) == 0)
        m_Logger.Write(From, LogNotice,
                       "region canvas declared: %dx%d (a machine's own raster overrides it)",
                       CanvasWidth, CanvasHeight);
    else
        m_Logger.Write(From, LogError,
                       "region canvas %dx%d REFUSED — SDL_Init will fail",
                       CanvasWidth, CanvasHeight);

    // SoC state around the run: render throughput lives and dies by the
    // ARM/core clocks, and the shim's hardware management (it owns Circle's
    // one CCPUThrottle) clamps them to idle above the socmaxtemp limit
    // (cmdline.txt on the SD card; Circle default 60C).
    m_Logger.Write(From, LogNotice, "SoC: %uC, arm %u MHz, core %u MHz, socmaxtemp %uC",
                   SDL2Circle_SoCTemperature(),
                   SDL2Circle_CPUClockRate() / 1000000,
                   CMachineInfo::Get()->GetClockRate(CLOCK_ID_CORE) / 1000000,
                   CKernelOptions::Get()->GetSoCMaxTemp());

    m_Logger.Write(From, LogNotice,
                   "core split: hardware core 0, MAME core 1, presentation "
                   "core 2, core 3 parked");

    // Arm the split BEFORE MAME's first instruction: the shim's servo and
    // watchdog tasks on core 0, and the mailboxes every marshalled call
    // rides. Then open the gate and core 1 calls MAME.
    SDL2Circle_SplitInit();
    s_MameGate.store(1, std::memory_order_release);
    PublishToOtherCores();

    // Core 0's idle loop for the whole run. Yielding is not politeness: the
    // servo task is what answers core 1, feeds the sound device and pumps
    // USB, and it only runs when this loop gives up the core.
    //
    // The disk cache's report rides here and nowhere else. Printing it from
    // inside a read would put serial output in the middle of a call MAME's
    // core is blocked on; Poll() costs one clock read until its interval is
    // up.
    while (!s_MameDone.load(std::memory_order_acquire))
    {
        m_DiskCache.Poll();
        m_Scheduler.Yield();
    }
    int res = s_MameResult;

    // One last report, so a run that ends quickly still says what it did.
    m_DiskCache.Report();

    m_Logger.Write(From, LogNotice, "SoC: %uC, arm %u MHz, core %u MHz",
                   SDL2Circle_SoCTemperature(),
                   SDL2Circle_CPUClockRate() / 1000000,
                   CMachineInfo::Get()->GetClockRate(CLOCK_ID_CORE) / 1000000);
    m_Logger.Write(From, LogNotice, "MAME exited with %d, rebooting", res);

    // Reboot to whatever the card boots — the dev bench's chainloader, a
    // product card's picker: quitting the emulator hands the machine back.
    return ShutdownReboot;
}
