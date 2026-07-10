/*
 * Minimal <sys/mman.h> for the Circle/newlib cross environment.
 * Bare metal has no MMU-backed anonymous mappings; the linked
 * implementation must provide mmap/munmap/mprotect over the heap
 * (anonymous, non-executable use only).
 */
#ifndef _SYS_MMAN_H
#define _SYS_MMAN_H

#include <sys/types.h>

#ifdef __cplusplus
extern "C" {
#endif

#define PROT_NONE  0x0
#define PROT_READ  0x1
#define PROT_WRITE 0x2
#define PROT_EXEC  0x4

#define MAP_SHARED    0x01
#define MAP_PRIVATE   0x02
#define MAP_FIXED     0x10
#define MAP_ANON      0x20
#define MAP_ANONYMOUS MAP_ANON

#define MAP_FAILED ((void *)-1)

void *mmap(void *__addr, size_t __len, int __prot, int __flags, int __fd, off_t __offset);
int   munmap(void *__addr, size_t __len);
int   mprotect(void *__addr, size_t __len, int __prot);

#ifdef __cplusplus
}
#endif

#endif /* _SYS_MMAN_H */
