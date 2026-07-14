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

// ---- SDL2: windows ---------------------------------------------------------
// (display information, window identity and the software-renderer extras
// are real implementations in circle-libsdl2 now)

int SDL_GetWindowDisplayMode(SDL_Window *, SDL_DisplayMode *) { return -1; }
int SDL_SetWindowDisplayMode(SDL_Window *, const SDL_DisplayMode *) { return -1; }
int SDL_SetWindowFullscreen(SDL_Window *, Uint32) { return -1; }
void SDL_SetWindowSize(SDL_Window *, int, int) {}
void SDL_RaiseWindow(SDL_Window *) {}
void SDL_SetWindowGrab(SDL_Window *, SDL_bool) {}
SDL_bool SDL_GetWindowWMInfo(SDL_Window *, SDL_SysWMinfo *) { return SDL_FALSE; }

// ---- SDL2: mouse / cursor / touch -------------------------------------------

int SDL_ShowCursor(int) { return SDL_DISABLE; }
void SDL_SetCursor(SDL_Cursor *) {}
int SDL_SetRelativeMouseMode(SDL_bool) { return -1; }
void SDL_WarpMouseInWindow(SDL_Window *, int, int) {}
int SDL_GetNumTouchDevices(void) { return 0; }
SDL_TouchID SDL_GetTouchDevice(int) { return 0; }

// ---- SDL2: OpenGL glue -------------------------------------------------------

int SDL_GL_LoadLibrary(const char *) { return -1; }
void *SDL_GL_GetProcAddress(const char *) { return nullptr; }
SDL_GLContext SDL_GL_CreateContext(SDL_Window *) { return nullptr; }
void SDL_GL_DeleteContext(SDL_GLContext) {}
int SDL_GL_MakeCurrent(SDL_Window *, SDL_GLContext) { return -1; }
int SDL_GL_SetAttribute(SDL_GLattr, int) { return -1; }
int SDL_GL_SetSwapInterval(int) { return -1; }
void SDL_GL_SwapWindow(SDL_Window *) {}

// ---- SDL2: joystick / game controller / haptic --------------------------------

int SDL_NumJoysticks(void) { return 0; }
SDL_Joystick *SDL_JoystickOpen(int) { return nullptr; }
void SDL_JoystickClose(SDL_Joystick *) {}
const char *SDL_JoystickName(SDL_Joystick *) { return nullptr; }
const char *SDL_JoystickGetSerial(SDL_Joystick *) { return nullptr; }
Uint16 SDL_JoystickGetVendor(SDL_Joystick *) { return 0; }
Uint16 SDL_JoystickGetProduct(SDL_Joystick *) { return 0; }
Uint16 SDL_JoystickGetProductVersion(SDL_Joystick *) { return 0; }
int SDL_JoystickNumAxes(SDL_Joystick *) { return -1; }
int SDL_JoystickNumBalls(SDL_Joystick *) { return -1; }
int SDL_JoystickNumHats(SDL_Joystick *) { return -1; }
int SDL_JoystickNumButtons(SDL_Joystick *) { return -1; }
SDL_JoystickID SDL_JoystickInstanceID(SDL_Joystick *) { return -1; }
SDL_JoystickID SDL_JoystickGetDeviceInstanceID(int) { return -1; }

SDL_JoystickGUID SDL_JoystickGetGUID(SDL_Joystick *)
{
    SDL_JoystickGUID guid;
    memset(&guid, 0, sizeof(guid));
    return guid;
}

SDL_JoystickGUID SDL_JoystickGetDeviceGUID(int)
{
    SDL_JoystickGUID guid;
    memset(&guid, 0, sizeof(guid));
    return guid;
}

void SDL_JoystickGetGUIDString(SDL_JoystickGUID, char *pszGUID, int cbGUID)
{
    if (pszGUID != nullptr && cbGUID > 0)
        pszGUID[0] = '\0';
}

SDL_bool SDL_IsGameController(int) { return SDL_FALSE; }
SDL_GameController *SDL_GameControllerOpen(int) { return nullptr; }
void SDL_GameControllerClose(SDL_GameController *) {}
const char *SDL_GameControllerName(SDL_GameController *) { return nullptr; }
const char *SDL_GameControllerGetSerial(SDL_GameController *) { return nullptr; }
Uint16 SDL_GameControllerGetVendor(SDL_GameController *) { return 0; }
Uint16 SDL_GameControllerGetProduct(SDL_GameController *) { return 0; }
Uint16 SDL_GameControllerGetProductVersion(SDL_GameController *) { return 0; }
SDL_GameControllerType SDL_GameControllerGetType(SDL_GameController *)
{
    return SDL_CONTROLLER_TYPE_UNKNOWN;
}
SDL_Joystick *SDL_GameControllerGetJoystick(SDL_GameController *) { return nullptr; }
char *SDL_GameControllerMapping(SDL_GameController *) { return nullptr; }
int SDL_GameControllerAddMappingsFromRW(SDL_RWops *, int) { return -1; }
SDL_bool SDL_GameControllerHasAxis(SDL_GameController *, SDL_GameControllerAxis)
{
    return SDL_FALSE;
}
SDL_bool SDL_GameControllerHasButton(SDL_GameController *, SDL_GameControllerButton)
{
    return SDL_FALSE;
}

SDL_GameControllerButtonBind SDL_GameControllerGetBindForAxis(
    SDL_GameController *, SDL_GameControllerAxis)
{
    SDL_GameControllerButtonBind bind;
    memset(&bind, 0, sizeof(bind));
    bind.bindType = SDL_CONTROLLER_BINDTYPE_NONE;
    return bind;
}

SDL_GameControllerButtonBind SDL_GameControllerGetBindForButton(
    SDL_GameController *, SDL_GameControllerButton)
{
    SDL_GameControllerButtonBind bind;
    memset(&bind, 0, sizeof(bind));
    bind.bindType = SDL_CONTROLLER_BINDTYPE_NONE;
    return bind;
}

SDL_Haptic *SDL_HapticOpenFromJoystick(SDL_Joystick *) { return nullptr; }
void SDL_HapticClose(SDL_Haptic *) {}

// ---- SDL2: audio extras --------------------------------------------------------

// SDL_GetDefaultAudioInfo and SDL_GetAudioDeviceSpec are NOT stubbed here:
// the shim implements them (circle-libsdl2 src/audio.cpp), and a stub in this
// object would win the link over the archive member and quietly replace a
// working implementation with a failure return.
int SDL_GetNumAudioDrivers(void) { return 1; }
const char *SDL_GetAudioDriver(int) { return "circle"; }

// ---- SDL2: misc -----------------------------------------------------------------

void SDL_free(void *mem) { free(mem); }

const char *SDL_GetScancodeName(SDL_Scancode) { return ""; }

SDL_RWops *SDL_RWFromFile(const char *, const char *) { return nullptr; }

SDL_bool SDL_HasClipboardText(void) { return SDL_FALSE; }

char *SDL_GetClipboardText(void)
{
    // caller SDL_free()s the result: heap-allocated empty string
    return static_cast<char *>(calloc(1, 1));
}

int SDL_SetClipboardText(const char *) { return 0; }

SDL_bool SDL_IntersectRect(const SDL_Rect *A, const SDL_Rect *B, SDL_Rect *result)
{
    if (A == nullptr || B == nullptr || result == nullptr)
        return SDL_FALSE;

    int left   = A->x > B->x ? A->x : B->x;
    int top    = A->y > B->y ? A->y : B->y;
    int right  = (A->x + A->w) < (B->x + B->w) ? (A->x + A->w) : (B->x + B->w);
    int bottom = (A->y + A->h) < (B->y + B->h) ? (A->y + A->h) : (B->y + B->h);

    result->x = left;
    result->y = top;
    result->w = right - left;
    result->h = bottom - top;
    return (result->w > 0 && result->h > 0) ? SDL_TRUE : SDL_FALSE;
}

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
