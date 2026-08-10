//
// circle_syscalls.cpp — the console, routed off MAME's core.
//
// ONE SYSCALL. MAME's files already leave this kernel through osd_file:
// circlefile.cpp reimplements that surface over the shim's any-core I/O
// service, so nothing MAME opens ever reaches newlib's Circle glue. What
// still does is the console — every printf, every std::cout, every warning
// MAME prints on its way up — because descriptors 0, 1 and 2 are not files
// and have no route through a file service.
//
// That output is written from core 1, and the serial console is a device.
// Devices belong to core 0: the whole Circle world, interrupts included.
// Writing to one from anywhere else is illegal, and the failure is not a
// clean one.
//
// So descriptors 0 to 2 go to the library's log instead. SDL2Circle_LogBytes
// takes output in whatever pieces it was written in, assembles it into lines
// in a ring belonging to the calling core, and returns; core 0's servo drains
// the ring into the console. Nothing crosses but memory, and the calling core
// is never delayed by a console it is not allowed to touch. On core 0, and
// before the split is armed, the library writes straight through, so the boot
// log is immediate and this file costs a single comparison.
//
// HOW THE INTERPOSITION WORKS. The linker's --wrap (see the Makefile) rather
// than redefining _write. Newlib's Circle glue defines _open, _read, _write,
// _close and the rest in ONE object file, so replacing part of that set either
// collides at link time or, worse, leaves the originals linked in beside the
// replacements with no diagnostic at all. --wrap leaves the vendored glue
// untouched and renames the references: everything calling _write reaches
// __wrap__write here, and __real__write still reaches the genuine
// implementation for every descriptor that is a real file.
//
#include <SDL2/SDL_circle.h>

#include <cstddef>

extern "C" {

// The genuine newlib glue, still reachable under this name because of --wrap.
long __real__write(int fd, const void *buf, size_t len);

} // extern "C"

namespace
{

// Descriptors 0, 1 and 2 are the serial console, not files.
inline bool IsConsole(int fd) { return fd >= 0 && fd <= 2; }

} // namespace

extern "C" {

long __wrap__write(int fd, const void *buf, size_t len)
{
    if (IsConsole(fd))
    {
        SDL2Circle_LogBytes(fd == 2 ? "stderr" : "stdout",
                            (const char *)buf, (unsigned)len);
        return (long)len;
    }

    return __real__write(fd, buf, len);
}

} // extern "C"
