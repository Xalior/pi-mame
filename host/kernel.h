//
// kernel.h — Circle kernel hosting MAME (rapi-circle payload)
//
// Device ownership: this kernel brings up interrupts, timer, serial
// console (stdio), SD card (FatFs for ROMs/ini/cfg) and the scheduler
// (cooperative std::thread). Video, USB input and audio belong to
// circle-libsdl2, created inside SDL_Init by MAME's OSD.
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
#include <circle/cputhrottle.h>
#include <circle/types.h>
#include <SDCard/emmc.h>
#include <fatfs/ff.h>

enum TShutdownMode
{
    ShutdownNone,
    ShutdownHalt,
    ShutdownReboot
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
    FATFS               m_FileSystem;
    CConsole            m_Console;
    CCPUThrottle        m_CPUThrottle;   // full clock: Circle boots at idle speed
};

#endif
