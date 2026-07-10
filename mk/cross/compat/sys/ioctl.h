/*
 * Minimal <sys/ioctl.h> for the Circle/newlib cross environment.
 * Circle's socket layer has no ioctl entry point; this header exists so
 * that portable networking code (asio) compiles. Any runtime caller must
 * be linked against an ioctl() implementation (or stub returning -1).
 */
#ifndef _SYS_IOCTL_H
#define _SYS_IOCTL_H

#ifdef __cplusplus
extern "C" {
#endif

#define FIONREAD 0x541B /* bytes readable, int * argument */
#define FIONBIO  0x5421 /* set/clear non-blocking, int * argument */

#define TIOCGWINSZ 0x5413 /* get window size, struct winsize * argument */

struct winsize {
	unsigned short ws_row;
	unsigned short ws_col;
	unsigned short ws_xpixel;
	unsigned short ws_ypixel;
};

int ioctl(int __fd, unsigned long __request, ...);

#ifdef __cplusplus
}
#endif

#endif /* _SYS_IOCTL_H */
