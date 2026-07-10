/*
 * Minimal <sys/uio.h> for the Circle/newlib cross environment.
 * Circle's <sys/socket.h> declares msghdr with a `struct iovec *` member
 * but never defines the type; this header supplies it plus the readv/
 * writev prototypes portable code expects. Runtime callers must be linked
 * against implementations (or stubs).
 */
#ifndef _SYS_UIO_H
#define _SYS_UIO_H

#include <sys/types.h>

#ifdef __cplusplus
extern "C" {
#endif

struct iovec {
	void  *iov_base; /* start of memory region */
	size_t iov_len;  /* length of region in bytes */
};

ssize_t readv(int __fd, const struct iovec *__iov, int __iovcnt);
ssize_t writev(int __fd, const struct iovec *__iov, int __iovcnt);

#ifdef __cplusplus
}
#endif

#endif /* _SYS_UIO_H */
