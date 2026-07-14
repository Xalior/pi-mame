//
// xthreading.cpp — libc++ external-threading ABI, pi-mame implementation.
//
// Implements every symbol liblibcxx-threading.a exports (the ~30
// __libcpp_* functions + __cxa_thread_atexit) against the SAME
// __external_threading header — the opaque storage sizes are baked into
// libc++ and its users, so the types must be bit-compatible; only the
// implementation behind them changes.
//
// Primitives are futex-shaped: a mutex is one atomic word (CAS + WFE on
// contention, SEV on release), a condvar is a generation counter + waiter
// count. They work from ANY core; a blocked caller on core 0 yields to
// Circle's cooperative scheduler so the core-0 world never starves, and a
// blocked caller on a secondary core sleeps in WFE.
//
// M4 growth over the E5 spike: unpinned creation from a secondary core
// proxies to a core-0 creator task (xthread_init), so the application on
// its dedicated core creates service threads freely — they become
// cooperative CTasks on core 0, exactly the placement the single-core
// milestone proved. The thread_local destructor table grew to application
// scale.
//
// Remaining limits (documented, enforced honestly):
//   - one pinned thread per secondary core at a time (EAGAIN otherwise);
//   - timed waits on secondary cores poll CNTVCT between WFEs armed by
//     the signaller only (production wants the CNTKCTL_EL1 event stream
//     for periodic WFE wakeups — a per-core sysreg our code can set);
//   - __cxa_thread_atexit on core-0 tasks records but never runs (the
//     core-0 main thread and kernel never exit).
//
#include <__external_threading>
#include "xthreading.h"

#include <circle/multicore.h>
#include <circle/sched/scheduler.h>
#include <circle/sched/task.h>
#include <circle/sysconfig.h>
#include <atomic>
#include <cstring>
#include <sys/time.h>
#include <new>

static inline void wfe(void) { asm volatile("wfe" ::: "memory"); }
static inline void sevp(void) { asm volatile("dsb ish; sev" ::: "memory"); }
static inline u64 cntvct(void)
{
    u64 v;
    asm volatile("isb; mrs %0, cntvct_el0" : "=r"(v));
    return v;
}
static inline u64 cntfrq(void)
{
    u64 v;
    asm volatile("mrs %0, cntfrq_el0" : "=r"(v));
    return v;
}

unsigned xthread_this_core(void)
{
    return CMultiCoreSupport::ThisCore();
}

// Block-idle appropriate to the calling core: scheduler yield on core 0,
// WFE elsewhere.
static inline void idle_wait(void)
{
    if (CMultiCoreSupport::ThisCore() == 0)
        CScheduler::Get()->Yield();
    else
        wfe();
}

_LIBCPP_BEGIN_NAMESPACE_STD

// ---------------------------------------------------------------------------
// Non-recursive mutex: one atomic word in the opaque storage.
// Zero-initialized == unlocked (matches _LIBCPP_MUTEX_INITIALIZER).
// ---------------------------------------------------------------------------

struct XMutex
{
    std::atomic<u32> state;   // 0 free, 1 held
};
static_assert(sizeof(XMutex) <= sizeof(__libcpp_mutex_t::__storage));

static inline XMutex *as_mutex(__libcpp_mutex_t *m)
{
    return reinterpret_cast<XMutex *>(m->__storage);
}

static void xmutex_lock(XMutex *m)
{
    for (;;)
    {
        u32 expect = 0;
        if (m->state.compare_exchange_weak(expect, 1,
                                           std::memory_order_acquire,
                                           std::memory_order_relaxed))
            return;
        idle_wait();
    }
}

static bool xmutex_trylock(XMutex *m)
{
    u32 expect = 0;
    return m->state.compare_exchange_strong(expect, 1,
                                            std::memory_order_acquire,
                                            std::memory_order_relaxed);
}

static void xmutex_unlock(XMutex *m)
{
    m->state.store(0, std::memory_order_release);
    sevp();
}

int __libcpp_mutex_lock(__libcpp_mutex_t *__m)
{
    xmutex_lock(as_mutex(__m));
    return 0;
}

bool __libcpp_mutex_trylock(__libcpp_mutex_t *__m)
{
    return xmutex_trylock(as_mutex(__m));
}

int __libcpp_mutex_unlock(__libcpp_mutex_t *__m)
{
    xmutex_unlock(as_mutex(__m));
    return 0;
}

int __libcpp_mutex_destroy(__libcpp_mutex_t *)
{
    return 0;
}

// ---------------------------------------------------------------------------
// Recursive mutex: word + owner + depth.
// ---------------------------------------------------------------------------

struct XRecMutex
{
    std::atomic<u32> state;
    u32 depth;
    std::atomic<uintptr_t> owner;
};
static_assert(sizeof(XRecMutex) <= sizeof(__libcpp_recursive_mutex_t::__storage));

static inline XRecMutex *as_rec(__libcpp_recursive_mutex_t *m)
{
    return reinterpret_cast<XRecMutex *>(m->__storage);
}

int __libcpp_recursive_mutex_init(__libcpp_recursive_mutex_t *__m)
{
    ::new (__m->__storage) XRecMutex{};
    return 0;
}

int __libcpp_recursive_mutex_lock(__libcpp_recursive_mutex_t *__m)
{
    XRecMutex *m = as_rec(__m);
    uintptr_t self = __libcpp_thread_get_current_id();
    if (m->owner.load(std::memory_order_relaxed) == self)
    {
        m->depth++;
        return 0;
    }
    for (;;)
    {
        u32 expect = 0;
        if (m->state.compare_exchange_weak(expect, 1,
                                           std::memory_order_acquire,
                                           std::memory_order_relaxed))
            break;
        idle_wait();
    }
    m->owner.store(self, std::memory_order_relaxed);
    m->depth = 1;
    return 0;
}

bool __libcpp_recursive_mutex_trylock(__libcpp_recursive_mutex_t *__m)
{
    XRecMutex *m = as_rec(__m);
    uintptr_t self = __libcpp_thread_get_current_id();
    if (m->owner.load(std::memory_order_relaxed) == self)
    {
        m->depth++;
        return true;
    }
    u32 expect = 0;
    if (!m->state.compare_exchange_strong(expect, 1,
                                          std::memory_order_acquire,
                                          std::memory_order_relaxed))
        return false;
    m->owner.store(self, std::memory_order_relaxed);
    m->depth = 1;
    return true;
}

int __libcpp_recursive_mutex_unlock(__libcpp_recursive_mutex_t *__m)
{
    XRecMutex *m = as_rec(__m);
    if (--m->depth == 0)
    {
        m->owner.store(0, std::memory_order_relaxed);
        m->state.store(0, std::memory_order_release);
        sevp();
    }
    return 0;
}

int __libcpp_recursive_mutex_destroy(__libcpp_recursive_mutex_t *)
{
    return 0;
}

// ---------------------------------------------------------------------------
// Condition variable: generation counter + waiter count. signal ==
// broadcast (a generation bump wakes every waiter; spurious wakeups are
// permitted by the C++ contract). Zero-initialized is valid.
// ---------------------------------------------------------------------------

struct XCondvar
{
    std::atomic<u64> gen;
    std::atomic<u32> waiters;
};
static_assert(sizeof(XCondvar) <= sizeof(__libcpp_condvar_t::__storage));

static inline XCondvar *as_cv(__libcpp_condvar_t *cv)
{
    return reinterpret_cast<XCondvar *>(cv->__storage);
}

int __libcpp_condvar_signal(__libcpp_condvar_t *__cv)
{
    XCondvar *cv = as_cv(__cv);
    if (cv->waiters.load(std::memory_order_acquire))
    {
        cv->gen.fetch_add(1, std::memory_order_release);
        sevp();
    }
    return 0;
}

int __libcpp_condvar_broadcast(__libcpp_condvar_t *__cv)
{
    return __libcpp_condvar_signal(__cv);
}

int __libcpp_condvar_wait(__libcpp_condvar_t *__cv, __libcpp_mutex_t *__m)
{
    XCondvar *cv = as_cv(__cv);
    XMutex *m = as_mutex(__m);

    u64 g0 = cv->gen.load(std::memory_order_acquire);
    cv->waiters.fetch_add(1, std::memory_order_release);
    xmutex_unlock(m);

    while (cv->gen.load(std::memory_order_acquire) == g0)
        idle_wait();

    cv->waiters.fetch_sub(1, std::memory_order_release);
    xmutex_lock(m);
    return 0;
}

// Absolute CLOCK_REALTIME timespec -> remaining microseconds from now.
static long long timespec_delta_us(const timespec *ts)
{
    struct timeval now;
    gettimeofday(&now, nullptr);
    long long want = (long long)ts->tv_sec * 1000000 + ts->tv_nsec / 1000;
    long long have = (long long)now.tv_sec * 1000000 + now.tv_usec;
    return want - have;
}

int __libcpp_condvar_timedwait(__libcpp_condvar_t *__cv, __libcpp_mutex_t *__m,
                               __libcpp_timespec_t *__ts)
{
    XCondvar *cv = as_cv(__cv);
    XMutex *m = as_mutex(__m);

    long long delta_us = timespec_delta_us(__ts);
    const u64 frq = cntfrq();
    u64 deadline = cntvct() + (delta_us <= 0 ? 0 : (u64)delta_us * frq / 1000000);

    u64 g0 = cv->gen.load(std::memory_order_acquire);
    cv->waiters.fetch_add(1, std::memory_order_release);
    xmutex_unlock(m);

    bool timed_out = false;
    while (cv->gen.load(std::memory_order_acquire) == g0)
    {
        if (cntvct() >= deadline)
        {
            timed_out = cv->gen.load(std::memory_order_acquire) == g0;
            break;
        }
        // Core 0 yields; a secondary core WFE-naps but must re-check the
        // clock, so it relies on stray SEVs/events to pop out — bounded
        // by the next signal or, worst case, spin granularity.
        if (CMultiCoreSupport::ThisCore() == 0)
            CScheduler::Get()->Yield();
        else
            asm volatile("yield" ::: "memory");
    }

    cv->waiters.fetch_sub(1, std::memory_order_release);
    xmutex_lock(m);
    return timed_out ? ETIMEDOUT : 0;
}

int __libcpp_condvar_destroy(__libcpp_condvar_t *)
{
    return 0;
}

// ---------------------------------------------------------------------------
// execute_once
// ---------------------------------------------------------------------------

int __libcpp_execute_once(__libcpp_exec_once_flag *__flag,
                          void (*__init_routine)())
{
    auto *flag = reinterpret_cast<std::atomic<int> *>(__flag);
    int expect = 0;
    if (flag->compare_exchange_strong(expect, 1, std::memory_order_acquire))
    {
        __init_routine();
        flag->store(2, std::memory_order_release);
        sevp();
        return 0;
    }
    while (flag->load(std::memory_order_acquire) != 2)
        idle_wait();
    return 0;
}

// ---------------------------------------------------------------------------
// Threads
// ---------------------------------------------------------------------------

// Hardware TLS: each thread gets its own block (16-byte TCB + .tdata copy
// + zeroed .tbss, aarch64 variant-1 layout; linker script keeps .tbss
// adjacent to .tdata so tprel offsets land correctly). TPIDR_EL0 points at
// the block: Circle's task switch preserves it per task on core 0; pinned
// threads set/clear it around the entry function.

extern "C" char __tdata_start[];
extern "C" char __tdata_end[];
extern "C" char __tbss_start[];
extern "C" char __tbss_end[];

static const unsigned TLS_TCB_SIZE = 16;

static void *alloc_tls_block(void)
{
    size_t tdata = (size_t)(__tdata_end - __tdata_start);
    size_t span = (size_t)(__tbss_end - __tdata_start);
    u8 *block = new u8[TLS_TCB_SIZE + span]();
    if (tdata)
        memcpy(block + TLS_TCB_SIZE, __tdata_start, tdata);
    return block;
}

static inline void set_tp(void *p)
{
    asm volatile("msr tpidr_el0, %0" ::"r"(p));
}

static const unsigned XTLS_MAX = 8;

struct XTlsBlock
{
    void *val[XTLS_MAX];
};

struct XDtor
{
    void (*fn)(void *);
    void *obj;
};

// thread_local destructor capacity per thread: application scale (MAME's
// main thread registers dozens across its libraries).
static const unsigned XATEXIT_MAX = 64;

struct XThread
{
    void *(*fn)(void *);
    void *arg;
    unsigned core;                    // 1..3 pinned; 0 cooperative
    std::atomic<u32> state;           // 0 queued, 1 running, 2 finished
    std::atomic<u32> refs;            // join/detach bookkeeping
    XTlsBlock tls;
    XDtor atexit[XATEXIT_MAX];
    unsigned natexit;
    class XTask *task;                // cooperative variant
};

// Pinned dispatch: one job slot + one current pointer per core.
static std::atomic<XThread *> g_job[CORES];
static XThread *g_current[CORES];

// One-shot pin request (global: creation happens on one core at a time in
// the spike; MAME's adapter can widen this to per-core state).
static std::atomic<unsigned> g_pin_next{0};

static void xthread_finish(XThread *t)
{
    while (t->natexit)
    {
        XDtor &d = t->atexit[--t->natexit];
        d.fn(d.obj);
    }
    t->state.store(2, std::memory_order_release);
    sevp();
}

static void xthread_core_main_impl(unsigned nCore)
{
    for (;;)
    {
        XThread *t = g_job[nCore].load(std::memory_order_acquire);
        if (!t)
        {
            wfe();
            continue;
        }
        g_current[nCore] = t;
        void *tb = alloc_tls_block();
        set_tp(tb);
        t->state.store(1, std::memory_order_release);
        t->fn(t->arg);
        xthread_finish(t);              // dtors first: they may use TLS,
        g_current[nCore] = nullptr;     // which needs the current pointer
        set_tp(nullptr);
        delete[] (u8 *)tb;
        g_job[nCore].store(nullptr, std::memory_order_release);
    }
}

// Cooperative variant: Circle CTask wrapper (core 0 only).
class XTask : public CTask
{
public:
    // 4x stack: C++ unwinder state (upstream sizing).
    XTask(XThread *t) : CTask(TASK_STACK_SIZE * 4), m_t(t) {}
    void Run(void) override
    {
        void *tb = alloc_tls_block();
        set_tp(tb);                     // task switch preserves it from here
        m_t->state.store(1, std::memory_order_release);
        m_t->fn(m_t->arg);
        xthread_finish(m_t);
        delete[] (u8 *)tb;
    }
private:
    XThread *m_t;
};

// Creation proxy: the CTask constructor registers with the core-0-only
// scheduler, so an unpinned create issued on a secondary core posts the
// XThread here and a core-0 creator task constructs the CTask. One
// outstanding request, client-locked; creation is rare.
static struct alignas(64) XCreateBox
{
    std::atomic<u64> req{0};
    std::atomic<u64> ack{0};
    XThread *t;
} g_create;

static std::atomic<u32> g_create_lock{0};
static std::atomic<bool> g_creator_up{false};

class XCreatorTask : public CTask
{
public:
    XCreatorTask(void) : CTask(TASK_STACK_SIZE) {}
    void Run(void) override
    {
        for (;;)
        {
            u64 req = g_create.req.load(std::memory_order_acquire);
            if (req > g_create.ack.load(std::memory_order_relaxed))
            {
                g_create.t->task = new XTask(g_create.t);
                g_create.ack.store(req, std::memory_order_release);
                sevp();
            }
            CScheduler::Get()->Yield();
        }
    }
};

int __libcpp_thread_create(__libcpp_thread_t *__t, void *(*__func)(void *),
                           void *__arg)
{
    // First create: the core-0 main task predates this library, so its
    // TPIDR_EL0 still points nowhere. Give it a real TLS block once;
    // Circle's task switch preserves it per task from then on.
    static bool s_main_tls = false;
    if (!s_main_tls && CMultiCoreSupport::ThisCore() == 0)
    {
        s_main_tls = true;
        set_tp(alloc_tls_block());
    }

    XThread *t = new XThread{};
    t->fn = __func;
    t->arg = __arg;
    t->natexit = 0;

    unsigned pin = g_pin_next.exchange(0, std::memory_order_acq_rel);
    if (pin >= 1 && pin < CORES)
    {
        t->core = pin;
        XThread *expect = nullptr;
        if (!g_job[pin].compare_exchange_strong(expect, t,
                                                std::memory_order_release))
        {
            delete t;
            return EAGAIN;   // core busy: one pinned thread per core
        }
        sevp();
    }
    else if (CMultiCoreSupport::ThisCore() != 0)
    {
        // Cooperative tasks belong to core 0: proxy the construction to
        // the creator task (xthread_init) and wait for it.
        if (!g_creator_up.load(std::memory_order_acquire))
        {
            delete t;
            return EAGAIN;   // no creator task: kernel forgot xthread_init
        }
        t->core = 0;

        for (;;)
        {
            u32 expect = 0;
            if (g_create_lock.compare_exchange_weak(expect, 1,
                                                    std::memory_order_acquire,
                                                    std::memory_order_relaxed))
                break;
            wfe();
        }
        g_create.t = t;
        u64 seq = g_create.req.load(std::memory_order_relaxed) + 1;
        g_create.req.store(seq, std::memory_order_release);
        sevp();
        while (g_create.ack.load(std::memory_order_acquire) < seq)
            wfe();
        g_create_lock.store(0, std::memory_order_release);
        sevp();
    }
    else
    {
        t->core = 0;
        t->task = new XTask(t);
    }

    __t->__opaque = t;
    return 0;
}

__libcpp_thread_id __libcpp_thread_get_current_id()
{
    unsigned core = CMultiCoreSupport::ThisCore();
    if (core != 0 && g_current[core])
        return (uintptr_t)g_current[core];
    return (uintptr_t)CScheduler::Get()->GetCurrentTask();
}

__libcpp_thread_id __libcpp_thread_get_id(__libcpp_thread_t const *__t)
{
    XThread *t = (XThread *)__t->__opaque;
    return t->core ? (uintptr_t)t : (uintptr_t)t->task;
}

int __libcpp_thread_join(__libcpp_thread_t *__t)
{
    XThread *t = (XThread *)__t->__opaque;
    while (t->state.load(std::memory_order_acquire) != 2)
        idle_wait();
    // The CTask deletes itself on return (Circle semantics); the XThread
    // bookkeeping is ours to free.
    delete t;
    __t->__opaque = nullptr;
    return 0;
}

int __libcpp_thread_detach(__libcpp_thread_t *__t)
{
    // Spike: detached pinned threads release their slot on finish; the
    // XThread record leaks (documented — MAME joins its threads).
    __t->__opaque = nullptr;
    return 0;
}

void __libcpp_thread_yield()
{
    if (CMultiCoreSupport::ThisCore() == 0)
        CScheduler::Get()->Yield();
    else
        asm volatile("yield" ::: "memory");
}

void __libcpp_thread_sleep_for(chrono::nanoseconds const &__ns)
{
    long long ns = __ns.count();
    if (ns <= 0)
        return;
    if (CMultiCoreSupport::ThisCore() == 0)
    {
        unsigned ms = (unsigned)(ns / 1000000);
        CScheduler::Get()->MsSleep(ms ? ms : 1);
    }
    else
    {
        u64 deadline = cntvct() + (u64)ns * cntfrq() / 1000000000ull;
        while (cntvct() < deadline)
            asm volatile("yield" ::: "memory");
    }
}

// ---------------------------------------------------------------------------
// TLS
// ---------------------------------------------------------------------------

static void (*g_tls_dtor[XTLS_MAX])(void *);
static std::atomic<unsigned> g_tls_next{0};

static XTlsBlock *tls_block(void)
{
    unsigned core = CMultiCoreSupport::ThisCore();
    if (core != 0 && g_current[core])
        return &g_current[core]->tls;

    // Core-0 cooperative task: block hangs off the task's libc++ slot.
    CTask *task = CScheduler::Get()->GetCurrentTask();
    auto *blk = (XTlsBlock *)task->GetUserData(TASK_USER_DATA_LIBCXX);
    if (!blk)
    {
        blk = new XTlsBlock{};
        task->SetUserData(blk, TASK_USER_DATA_LIBCXX);
    }
    return blk;
}

int __libcpp_tls_create(__libcpp_tls_key *__key, void (*__at_exit)(void *))
{
    unsigned k = g_tls_next.fetch_add(1, std::memory_order_relaxed);
    if (k >= XTLS_MAX)
        return EAGAIN;
    g_tls_dtor[k] = __at_exit;
    *__key = k;
    return 0;
}

void *__libcpp_tls_get(__libcpp_tls_key __key)
{
    return __key < XTLS_MAX ? tls_block()->val[__key] : nullptr;
}

int __libcpp_tls_set(__libcpp_tls_key __key, void *__p)
{
    if (__key >= XTLS_MAX)
        return EINVAL;
    tls_block()->val[__key] = __p;
    return 0;
}

_LIBCPP_END_NAMESPACE_STD

// ---------------------------------------------------------------------------
// __cxa_thread_atexit — thread_local destructor registration.
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// Global entry points (declared in xthreading.h; internals live in std::__1)
// ---------------------------------------------------------------------------

void xthread_init(void)
{
    if (std::__1::g_creator_up.load(std::memory_order_relaxed))
        return;
    new std::__1::XCreatorTask;   // CTask registers itself with the scheduler
    std::__1::g_creator_up.store(true, std::memory_order_release);
}

void xthread_pin_next(unsigned nCore)
{
    std::__1::g_pin_next.store(nCore, std::memory_order_release);
}

void xthread_core_main(unsigned nCore)
{
    std::__1::xthread_core_main_impl(nCore);
}

extern "C" int __cxa_thread_atexit(void (*dtor)(void *), void *obj, void *)
{
    unsigned core = CMultiCoreSupport::ThisCore();
    if (core != 0 && std::__1::g_current[core])
    {
        std::__1::XThread *t = std::__1::g_current[core];
        if (t->natexit < std::__1::XATEXIT_MAX)
        {
            t->atexit[t->natexit++] = {dtor, obj};
            return 0;
        }
        return -1;
    }
    // Core-0 main/tasks never exit in this world; record nothing.
    return 0;
}
