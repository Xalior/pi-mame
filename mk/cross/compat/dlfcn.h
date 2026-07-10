/*
 * Minimal <dlfcn.h> for the Circle/newlib cross environment.
 * There is no dynamic loader on bare metal; this exists so portable
 * code with dlopen fallback paths compiles. The linked implementation
 * must be a stub (dlopen -> NULL, dlerror -> message).
 */
#ifndef _DLFCN_H
#define _DLFCN_H

#ifdef __cplusplus
extern "C" {
#endif

#define RTLD_LAZY   0x0001
#define RTLD_NOW    0x0002
#define RTLD_LOCAL  0x0000
#define RTLD_GLOBAL 0x0100

#define RTLD_DEFAULT ((void *)0)
#define RTLD_NEXT    ((void *)-1)

void *dlopen(const char *__file, int __mode);
int   dlclose(void *__handle);
void *dlsym(void *__handle, const char *__name);
char *dlerror(void);

#ifdef __cplusplus
}
#endif

#endif /* _DLFCN_H */
