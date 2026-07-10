/*
 * Wrapper over the C library's <signal.h> for the Circle/newlib cross
 * environment: supplies sigaction flags newlib omits, for code that
 * names them at compile time. There is no signal delivery on bare
 * metal, so the values only need to be distinct.
 */
#ifndef _COMPAT_SIGNAL_H
#define _COMPAT_SIGNAL_H

#include_next <signal.h>

#ifndef SA_NOCLDWAIT
#define SA_NOCLDWAIT 0x0004
#endif

#ifndef SA_RESTART
#define SA_RESTART 0x10000000
#endif

#endif /* _COMPAT_SIGNAL_H */
