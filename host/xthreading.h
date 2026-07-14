//
// xthreading.h — pi-mame threading library (M4 core split; grown from the
// E5 spike): our implementation of libc++'s external-threading ABI,
// replacing circle-stdlib's libcxx-threading at link time (the kernel
// simply links xthreading.o and filters liblibcxx-threading.a out of the
// library list — no circle-stdlib change).
//
// Thread model:
//   - unpinned std::thread  -> cooperative Circle CTask on core 0.
//                              Creation from a secondary core proxies to a
//                              core-0 creator task (the CTask constructor
//                              registers with the core-0-only scheduler),
//                              so an application running on a dedicated
//                              core creates service threads freely.
//   - pinned std::thread    -> runs bare on a dedicated secondary core;
//                              one thread per core at a time
//   - mutex/condvar         -> atomics + WFE/SEV, valid from ANY core;
//                              blocked core-0 callers yield to the
//                              scheduler instead of sleeping the core
//
#ifndef _xthreading_h
#define _xthreading_h

// Start the core-0 creator task (enables std::thread creation from
// secondary cores). Call once on core 0, scheduler live, before releasing
// any thread that may create threads.
void xthread_init(void);

// Route the NEXT __libcpp_thread_create on this core to the given
// secondary core (1..3). One-shot; cleared by the create.
void xthread_pin_next(unsigned nCore);

// Per-core dispatcher: the kernel's CMultiCoreSupport::Run() calls this
// for every secondary core. Never returns.
void xthread_core_main(unsigned nCore);

// Core the calling thread is executing on (0..3).
unsigned xthread_this_core(void);

#endif
