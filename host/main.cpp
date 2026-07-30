//
// main.cpp — classic Circle kernel entry
//
#include "kernel.h"
#include <circle/startup.h>

int main(void)
{
    // Core 0's runtime is armed before anything that can throw — the same
    // rule CSplitCores::Run applies to the secondary cores.
    SDL2Circle_ArmCoreRuntime();

    CKernel Kernel;
    if (!Kernel.Initialize())
    {
        halt();
        return EXIT_HALT;
    }

    TShutdownMode ShutdownMode = Kernel.Run();

    switch (ShutdownMode)
    {
    case ShutdownReboot:
        reboot();
        return EXIT_REBOOT;

    case ShutdownHalt:
    default:
        halt();
        return EXIT_HALT;
    }
}
