//
// circle_stubs.cpp — the surface MAME's objects reference but newlib/Circle
// and circle-libsdl2 don't provide. Three groups, each with a behavior
// contract:
//
//   POSIX (matches declarations in build/cross/compat/):
//   - dlopen family: dynamic loading doesn't exist; loads fail cleanly.
//   - mmap family: anonymous, non-executable mappings only, malloc-backed
//     (DRC is compiled to the C backend and never needs executable pages).
//   - termios/ioctl: no ttys; calls fail with ENOTTY.
//   - readv/writev: composed from read/write.
//   - processes/users don't exist: popen/execvp/waitpid fail, geteuid is 0,
//     fchown is a no-op (FAT has no ownership).
//   - sleep/nanosleep/sched_yield delegate to std::this_thread (cooperative
//     scheduler via libcxx-threading).
//
//   SDL2 (entry points circle-libsdl2 doesn't implement): honest failure —
//   device enumerations report nothing, opens fail, queries return errors.
//   Exceptions: SDL_IntersectRect is pure geometry and implemented for real;
//   driver-name queries report "circle"; the clipboard reads as empty.
//   A stub here is superseded by deleting it when the shim grows the real
//   implementation.
//
//   OpenGL 1.x (referenced directly by MAME's drawogl/gl_shader_tool):
//   no-ops. Unreachable at runtime — SDL_GL_CreateContext fails, so the
//   OpenGL renderer never initializes.
//
#include <cerrno>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <chrono>
#include <thread>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

#include <SDL2/SDL.h>
#include <SDL2/SDL_syswm.h>
#include <SDL2/SDL_opengl.h>

extern "C" {

// ---- dlfcn ----------------------------------------------------------------

void *dlopen(const char *, int) { return nullptr; }
void *dlsym(void *, const char *) { return nullptr; }
int dlclose(void *) { return 0; }
const char *dlerror(void) { return "dynamic loading is not available"; }

// ---- sys/mman -------------------------------------------------------------

#define MAP_FAILED ((void *)-1)

void *mmap(void *, size_t length, int, int, int fd, off_t)
{
    if (fd != -1)   // file-backed mappings don't exist here
    {
        errno = ENODEV;
        return MAP_FAILED;
    }
    void *p = calloc(1, length);
    return p ? p : MAP_FAILED;
}

int munmap(void *addr, size_t)
{
    free(addr);
    return 0;
}

int mprotect(void *, size_t, int) { return 0; }

// ---- sys/uio --------------------------------------------------------------

struct iovec_
{
    void *iov_base;
    size_t iov_len;
};

ssize_t readv(int fd, const struct iovec_ *iov, int iovcnt)
{
    ssize_t total = 0;
    for (int i = 0; i < iovcnt; i++)
    {
        ssize_t n = read(fd, iov[i].iov_base, iov[i].iov_len);
        if (n < 0)
            return total > 0 ? total : n;
        total += n;
        if ((size_t)n < iov[i].iov_len)
            break;
    }
    return total;
}

ssize_t writev(int fd, const struct iovec_ *iov, int iovcnt)
{
    ssize_t total = 0;
    for (int i = 0; i < iovcnt; i++)
    {
        ssize_t n = write(fd, iov[i].iov_base, iov[i].iov_len);
        if (n < 0)
            return total > 0 ? total : n;
        total += n;
        if ((size_t)n < iov[i].iov_len)
            break;
    }
    return total;
}

// ---- ioctl / termios -------------------------------------------------------

int ioctl(int, unsigned long, ...)
{
    errno = ENOTTY;
    return -1;
}

struct termios_;

int tcgetattr(int, struct termios_ *)
{
    errno = ENOTTY;
    return -1;
}

int tcsetattr(int, int, const struct termios_ *)
{
    errno = ENOTTY;
    return -1;
}

// ---- stdio locking ---------------------------------------------------------

// stdio is not lock-protected; MAME serializes its own logging.
void flockfile(FILE *) {}
void funlockfile(FILE *) {}

// ---- memory ----------------------------------------------------------------

int posix_memalign(void **memptr, size_t alignment, size_t size)
{
    if (alignment == 0 || (alignment & (alignment - 1)) != 0
        || alignment % sizeof(void *) != 0)
        return EINVAL;
    size_t rounded = (size + alignment - 1) & ~(alignment - 1);
    void *p = aligned_alloc(alignment, rounded);
    if (p == nullptr)
        return ENOMEM;
    *memptr = p;
    return 0;
}

// ---- filesystem ------------------------------------------------------------

// POSIX stat("/") succeeds; FatFs f_stat refuses a volume root by design
// (FR_INVALID_NAME), so the glue's _stat reports ENOENT and every volume
// root looks nonexistent to path-walking code (MAME's zippath). A volume
// root IS a directory: answer it here, delegate everything else. Because
// the kernel links this object directly, this definition preempts
// newlib's stat wrapper.
int _stat(const char *file, struct stat *statbuf);

static bool is_volume_root(const char *path)
{
    if (!path || !*path)
        return false;
    // "/", "SD:", "SD:/" and the like: nothing but an optional volume
    // prefix and slashes.
    const char *p = strchr(path, ':');
    p = p ? p + 1 : path;
    while (*p == '/')
        p++;
    return *p == '\0';
}

int stat(const char *path, struct stat *statbuf)
{
    if (is_volume_root(path))
    {
        memset(statbuf, 0, sizeof(*statbuf));
        statbuf->st_mode = S_IFDIR | 0755;
        statbuf->st_nlink = 1;
        return 0;
    }
    return _stat(path, statbuf);
}

// FAT has no permission bits: existence (via stat) answers every mode.
int access(const char *path, int)
{
    struct stat st;
    return stat(path, &st);
}

int fchown(int, uid_t, gid_t) { return 0; }

// ---- processes / users -----------------------------------------------------

uid_t geteuid(void) { return 0; }

pid_t waitpid(pid_t, int *, int)
{
    errno = ECHILD;
    return -1;
}

FILE *popen(const char *, const char *)
{
    errno = ENOSYS;
    return nullptr;
}

int pclose(FILE *)
{
    errno = ENOSYS;
    return -1;
}

int execvp(const char *, char *const[])
{
    errno = ENOSYS;
    return -1;
}

// ---- scheduling / time -----------------------------------------------------

int sched_yield(void)
{
    std::this_thread::yield();
    return 0;
}

unsigned int sleep(unsigned int seconds)
{
    std::this_thread::sleep_for(std::chrono::seconds(seconds));
    return 0;
}

int nanosleep(const struct timespec *req, struct timespec *rem)
{
    if (req == nullptr || req->tv_nsec < 0 || req->tv_nsec > 999999999L)
    {
        errno = EINVAL;
        return -1;
    }
    std::this_thread::sleep_for(std::chrono::seconds(req->tv_sec)
                                + std::chrono::nanoseconds(req->tv_nsec));
    if (rem != nullptr)
    {
        rem->tv_sec = 0;
        rem->tv_nsec = 0;
    }
    return 0;
}

// ---- SDL2 ------------------------------------------------------------------
//
// Nothing of SDL is stubbed here any more. Windows, the mouse and cursor,
// touch, the OpenGL entry points, haptics, the audio driver list, clipboard,
// scancode names and rectangle arithmetic are all circle-libsdl2's, and a stub
// of any of them is a duplicate-symbol error at link time — the library is
// linked whole (LIBS in the Makefile) for exactly that seatbelt. An object
// linked straight into the kernel beats an archive member of the same name and
// does it silently, so without the whole-archive link a stub left here would go
// on being called and nothing would say so.
//
// What remains below is what the library does not implement and never will:
// OpenGL 1.x itself, which MAME's renderer references and this appliance never
// uses.

// ---- OpenGL 1.x -----------------------------------------------------------------

void glBegin(GLenum) {}
void glBindTexture(GLenum, GLuint) {}
void glBlendFunc(GLenum, GLenum) {}
void glClear(GLbitfield) {}
void glClearColor(GLclampf, GLclampf, GLclampf, GLclampf) {}
void glClearDepth(GLclampd) {}
void glColor4f(GLfloat, GLfloat, GLfloat, GLfloat) {}
void glDeleteTextures(GLsizei, const GLuint *) {}
void glDepthFunc(GLenum) {}
void glDisable(GLenum) {}
void glDisableClientState(GLenum) {}
void glDrawArrays(GLenum, GLint, GLsizei) {}
void glEnable(GLenum) {}
void glEnableClientState(GLenum) {}
void glEnd(void) {}
void glFinish(void) {}

void glGenTextures(GLsizei n, GLuint *textures)
{
    if (textures != nullptr && n > 0)
        memset(textures, 0, sizeof(GLuint) * n);
}

GLenum glGetError(void) { return GL_NO_ERROR; }

void glGetIntegerv(GLenum, GLint *params)
{
    if (params != nullptr)
        *params = 0;
}

const GLubyte *glGetString(GLenum) { return nullptr; }

void glGetTexLevelParameteriv(GLenum, GLint, GLenum, GLint *params)
{
    if (params != nullptr)
        *params = 0;
}

void glHint(GLenum, GLenum) {}
void glLineWidth(GLfloat) {}
void glLoadIdentity(void) {}
void glMatrixMode(GLenum) {}
void glOrtho(GLdouble, GLdouble, GLdouble, GLdouble, GLdouble, GLdouble) {}
void glPixelStorei(GLenum, GLint) {}
void glPointSize(GLfloat) {}
void glPopAttrib(void) {}
void glPushAttrib(GLbitfield) {}
void glShadeModel(GLenum) {}
void glTexCoordPointer(GLint, GLenum, GLsizei, const GLvoid *) {}
void glTexImage2D(GLenum, GLint, GLint, GLsizei, GLsizei, GLint, GLenum, GLenum,
                  const GLvoid *) {}
void glTexParameteri(GLenum, GLenum, GLint) {}
void glTexSubImage2D(GLenum, GLint, GLint, GLint, GLsizei, GLsizei, GLenum, GLenum,
                     const GLvoid *) {}
void glVertex2f(GLfloat, GLfloat) {}
void glVertexPointer(GLint, GLenum, GLsizei, const GLvoid *) {}
void glViewport(GLint, GLint, GLsizei, GLsizei) {}

} // extern "C"
