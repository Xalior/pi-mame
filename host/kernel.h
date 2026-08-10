//
// kernel.h — Circle kernel hosting MAME (rapi-circle payload)
//
// Device ownership: this kernel brings up interrupts, timer, serial
// console (stdio), SD card (FatFs for ROMs/ini/cfg, behind the read cache)
// USB, and the scheduler. Video and audio belong to circle-libsdl2,
// created inside SDL_Init by MAME's OSD; the shim reads the USB controller
// this kernel built and drives input off it.
//
#ifndef _kernel_h
#define _kernel_h

#include <circle/actled.h>
#include <circle/koptions.h>
#include <circle/devicenameservice.h>
#include <circle/serial.h>
#include <circle/exceptionhandler.h>
#include <circle/interrupt.h>
#include <circle/timer.h>
#include <circle/logger.h>
#include <circle/sched/scheduler.h>
#include <circle/input/console.h>
#include <circle/multicore.h>
#include <circle/memory.h>
#include <circle/types.h>
#include <circle/usb/usbhcidevice.h>
#include <SDCard/emmc.h>
#include <fatfs/ff.h>
#include <SDL2/SDL_circle.h>
#include <diskcache.h>

enum TShutdownMode
{
    ShutdownNone,
    ShutdownHalt,
    ShutdownReboot
};

// Secondary-core dispatch. Core 0 keeps the Circle world (devices, scheduler,
// the shim's servo and watchdog); the cores it starts take their roles from
// Run(), below in kernel.cpp:
//   CORE1  MAME, alone — mame_circle_main called directly, once the gate
//          flag says the split is armed.
//   CORE2  the shim's presentation worker: blit + page flip.
//   CORE3  parked. Nothing runs there.
class CSplitCores : public CMultiCoreSupport
{
public:
    CSplitCores(void) : CMultiCoreSupport(CMemorySystem::Get()) {}
    void Run(unsigned nCore) override;
};

class CKernel
{
public:
    CKernel(void);

    boolean Initialize(void);
    TShutdownMode Run(void);

private:
    CActLED             m_ActLED;
    CKernelOptions      m_Options;
    CDeviceNameService  m_DeviceNameService;
    CSerialDevice       m_Serial;
    CExceptionHandler   m_ExceptionHandler;
    CInterruptSystem    m_Interrupt;
    CTimer              m_Timer;
    CLogger             m_Logger;
    CScheduler          m_Scheduler;
    CEMMCDevice         m_EMMC;
    // Slides in between the card and everything that reads it: FatFs looks
    // its device up by name, so taking the name over is the whole of the
    // interposition and no caller above it changes.
    CDiskCacheDevice    m_DiskCache;
    FATFS               m_FileSystem;
    CConsole            m_Console;
    // USB belongs to the host kernel: the shim reads whatever controller it
    // finds and never builds one. Plug-and-play, so a keyboard or pad
    // arriving after boot is still picked up.
    CUSBHCIDevice       m_USB;
    // The shim owns Circle's one CCPUThrottle (creating a second halts the
    // machine). This member brings its hardware management up during kernel
    // construction — full clock before MAME's ROM loading, and the boot log
    // can report real SoC numbers — instead of waiting for SDL_Init.
    CSDL2CircleHardware m_Hardware;
    CSplitCores         m_Cores;
};

#endif
