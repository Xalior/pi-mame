//
// main.cpp — classic Circle kernel entry
//
#include "kernel.h"
#include <circle/startup.h>

int main(void)
{
    // Core 0's runtime is armed inside CKernel::Initialize, once the card is
    // mounted and stdio is wired: the call runs deferred constructors and
    // creates a scheduler where the host has none, so it cannot come before
    // the world those need.
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
