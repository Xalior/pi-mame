/*
 * Minimal <sys/un.h> for the Circle/newlib cross environment.
 * Circle's socket layer has no AF_UNIX transport; the type exists only so
 * portable networking code (asio) compiles. Binding one at runtime fails
 * in the socket layer.
 */
#ifndef _SYS_UN_H
#define _SYS_UN_H

#include <sys/socket.h>

struct sockaddr_un {
	sa_family_t sun_family; /* AF_UNIX */
	char        sun_path[108];
};

#endif /* _SYS_UN_H */
