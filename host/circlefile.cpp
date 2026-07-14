//
// circlefile.cpp — MAME's osd_file / osd::directory surface as a thin
// adapter over circle-libsdl2's I/O service (SDL2/SDL_circle.h).
//
// This is the core split's file seam (docs/pi-mame-core-split.html §3):
// MAME runs on a dedicated core, and every file operation it issues enters
// the shim's blocking I/O API, which marshals to the core-0 servo — the
// only context that ever touches FatFs/EMMC (whose interrupts live on
// core 0). The cut is osd_file, never below.
//
// The object replaces posixfile.o and posixdir.o at link time (the kernel
// Makefile links a libocore_sdl copy with those members deleted — the same
// archive surgery that replaces sdlmain.o); the mame tree stays untouched.
// Semantics mirror posixfile.cpp/posixdir.cpp on this platform: single
// volume "/", no ptys, no sockets, FAT timestamps, every directory entry
// stat()ed (this platform's dirent carries no type).
//
#include "osdfile.h"
#include "osdcore.h"
#include "unicode.h"

#include <SDL2/SDL_circle.h>

#include <cctype>
#include <cerrno>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <memory>
#include <new>
#include <string>
#include <string_view>
#include <vector>

namespace {

constexpr char PATHSEPCH = '/';

inline std::error_condition error_from(long negerrno) noexcept
{
	return std::error_condition(int(-negerrno), std::generic_category());
}


class circle_osd_file : public osd_file
{
public:
	circle_osd_file(circle_osd_file const &) = delete;
	circle_osd_file(circle_osd_file &&) = delete;
	circle_osd_file &operator=(circle_osd_file const &) = delete;
	circle_osd_file &operator=(circle_osd_file &&) = delete;

	circle_osd_file(int handle) noexcept : m_handle(handle) { }

	virtual ~circle_osd_file() override
	{
		SDL2Circle_IOClose(m_handle);
	}

	virtual std::error_condition read(void *buffer, std::uint64_t offset, std::uint32_t count, std::uint32_t &actual) noexcept override
	{
		long const result = SDL2Circle_IORead(m_handle, buffer, offset, count);
		if (result < 0)
			return error_from(result);
		actual = std::uint32_t(result);
		return std::error_condition();
	}

	virtual std::error_condition write(void const *buffer, std::uint64_t offset, std::uint32_t count, std::uint32_t &actual) noexcept override
	{
		long const result = SDL2Circle_IOWrite(m_handle, buffer, offset, count);
		if (result < 0)
			return error_from(result);
		actual = std::uint32_t(result);
		return std::error_condition();
	}

	virtual std::error_condition truncate(std::uint64_t offset) noexcept override
	{
		int const result = SDL2Circle_IOTruncate(m_handle, offset);
		return result < 0 ? error_from(result) : std::error_condition();
	}

	virtual std::error_condition flush() noexcept override
	{
		// no user-space buffering in the I/O service
		return std::error_condition();
	}

private:
	int m_handle;
};


// Create every missing directory on the way to path (the caller passed
// OPEN_FLAG_CREATE_PATHS; there is no OS to create anything implicitly).
std::error_condition create_path_recursive(std::string_view path) noexcept
{
	auto const sep = path.rfind(PATHSEPCH);
	if ((sep != std::string_view::npos) && (sep > 0) && (path[sep - 1] != PATHSEPCH))
	{
		std::error_condition err = create_path_recursive(path.substr(0, sep));
		if (err)
			return err;
	}

	std::string p;
	try { p = path; }
	catch (...) { return std::errc::not_enough_memory; }

	SDL2Circle_IOStat st;
	if (SDL2Circle_IOStatPath(p.c_str(), &st) == 0)
		return std::error_condition();

	int const result = SDL2Circle_IOMkdir(p.c_str());
	return result < 0 ? error_from(result) : std::error_condition();
}

} // anonymous namespace


std::error_condition osd_file::open(std::string const &path, std::uint32_t openflags, ptr &file, std::uint64_t &filesize) noexcept
{
	unsigned flags = 0;
	if (openflags & OPEN_FLAG_READ)
		flags |= SDL2CIRCLE_IO_READ;
	if (openflags & OPEN_FLAG_WRITE)
		flags |= SDL2CIRCLE_IO_WRITE;
	if (openflags & OPEN_FLAG_CREATE)
		flags |= SDL2CIRCLE_IO_CREATE;
	if (!(flags & (SDL2CIRCLE_IO_READ | SDL2CIRCLE_IO_WRITE)))
		return std::errc::invalid_argument;

	std::uint64_t size = 0;
	int handle = SDL2Circle_IOOpen(path.c_str(), flags, &size);
	if (handle < 0)
	{
		std::error_condition const openerr = error_from(handle);

		if ((openflags & OPEN_FLAG_CREATE) && (openflags & OPEN_FLAG_CREATE_PATHS))
		{
			auto const pathsep = path.rfind(PATHSEPCH);
			if (pathsep != std::string::npos)
			{
				std::error_condition const createrr = create_path_recursive(std::string_view(path).substr(0, pathsep));
				if (!createrr)
					handle = SDL2Circle_IOOpen(path.c_str(), flags, &size);
			}
		}

		if (handle < 0)
			return openerr;
	}

	osd_file::ptr result(new (std::nothrow) circle_osd_file(handle));
	if (!result)
	{
		SDL2Circle_IOClose(handle);
		return std::errc::not_enough_memory;
	}
	file = std::move(result);
	filesize = size;
	return std::error_condition();
}


std::error_condition osd_file::openpty(ptr &file, std::string &name) noexcept
{
	return std::errc::not_supported;   // no ttys on this machine
}


std::error_condition osd_file::remove(std::string const &filename) noexcept
{
	int const result = SDL2Circle_IOUnlink(filename.c_str());
	return result < 0 ? error_from(result) : std::error_condition();
}


bool osd_get_physical_drive_geometry(const char *filename, uint32_t *cylinders, uint32_t *heads, uint32_t *sectors, uint32_t *bps) noexcept
{
	return false;   // no physical drives behind the FAT
}


osd::directory::entry::ptr osd_stat(const std::string &path)
{
	SDL2Circle_IOStat st;
	if (SDL2Circle_IOStatPath(path.c_str(), &st) < 0)
		return nullptr;

	// one allocation carries the entry and its name (caller frees the pair)
	auto const result = reinterpret_cast<osd::directory::entry *>(
			::operator new(
				sizeof(osd::directory::entry) + path.length() + 1,
				std::align_val_t(alignof(osd::directory::entry)),
				std::nothrow));
	if (!result)
		return nullptr;
	new (result) osd::directory::entry;

	auto const resultname = reinterpret_cast<char *>(result) + sizeof(*result);
	std::strcpy(resultname, path.c_str());
	result->name = resultname;
	result->type = st.isdir ? osd::directory::entry::entry_type::DIR : osd::directory::entry::entry_type::FILE;
	result->size = st.size;
	result->last_modified = std::chrono::system_clock::from_time_t(time_t(st.mtime));

	return osd::directory::entry::ptr(result);
}


std::error_condition osd_get_full_path(std::string &dst, std::string const &path) noexcept
{
	// the appliance's working directory is the volume root
	try
	{
		if (osd_is_absolute_path(path))
			dst = path;
		else
		{
			dst.assign(1, PATHSEPCH);
			dst.append(path);
		}
		return std::error_condition();
	}
	catch (...)
	{
		return std::errc::not_enough_memory;
	}
}


bool osd_is_absolute_path(std::string const &path) noexcept
{
	if (!path.empty() && (path[0] == PATHSEPCH))
		return true;
	else if (!path.empty() && (path[0] == '.') && (!path[1] || (path[1] == PATHSEPCH)))
		return true;
	else
		return false;
}


std::string osd_get_volume_name(int idx)
{
	if (idx == 0)
		return "/";
	else
		return std::string();
}


std::vector<std::string> osd_get_volume_names()
{
	return std::vector<std::string>{ "/" };
}


bool osd_is_valid_filename_char(char32_t uchar) noexcept
{
	return osd_is_valid_filepath_char(uchar)
		&& uchar != PATHSEPCH
		&& uchar != '\\'
		&& uchar != ':';
}


bool osd_is_valid_filepath_char(char32_t uchar) noexcept
{
	return uchar >= 0x20
		&& !(uchar >= '\x7F' && uchar <= '\x9F')
		&& uchar_isvalid(uchar);
}


//============================================================
//  osd::directory
//============================================================

namespace osd {

namespace {

class circle_directory : public directory
{
public:
	circle_directory(intptr_t dir, std::string &&path)
		: m_entry()
		, m_dir(dir)
		, m_path(std::move(path))
	{
	}

	virtual ~circle_directory() override
	{
		SDL2Circle_IOCloseDir(m_dir);
	}

	virtual const entry *read() override
	{
		SDL2Circle_IODirEntry de;
		if (SDL2Circle_IOReadDir(m_dir, &de) != 1)
			return nullptr;

		try { m_name = de.name; }
		catch (...) { return nullptr; }
		m_entry.name = m_name.c_str();

		// this platform's dirent carries no type: stat each entry, the way
		// the posix module does on platforms without d_type
		SDL2Circle_IOStat st;
		std::string full;
		try { full = m_path + PATHSEPCH + m_name; }
		catch (...) { return nullptr; }
		if (SDL2Circle_IOStatPath(full.c_str(), &st) == 0)
		{
			m_entry.type = st.isdir ? entry::entry_type::DIR : entry::entry_type::FILE;
			m_entry.size = st.size;
			m_entry.last_modified = std::chrono::system_clock::from_time_t(time_t(st.mtime));
		}
		else
		{
			m_entry.type = entry::entry_type::OTHER;
			m_entry.size = 0;
			m_entry.last_modified = std::chrono::system_clock::time_point();
		}
		return &m_entry;
	}

private:
	entry       m_entry;
	intptr_t    m_dir;
	std::string m_path;
	std::string m_name;   // stable storage behind m_entry.name
};

} // anonymous namespace


directory::ptr directory::open(std::string const &dirname)
{
	intptr_t const dir = SDL2Circle_IOOpenDir(dirname.c_str());
	if (!dir)
		return nullptr;

	try
	{
		std::string path = dirname;
		return ptr(new circle_directory(dir, std::move(path)));
	}
	catch (...)
	{
		SDL2Circle_IOCloseDir(dir);
		return nullptr;
	}
}

} // namespace osd


//============================================================
//  osd_subst_env — no environment exists here; expansion passes
//  literal text through and drops unknown variables the way the
//  posix module does.
//============================================================

std::string osd_subst_env(std::string_view src)
{
	std::string result, var;
	auto start = src.begin();

	if ((src.end() != start) && ('~' == *start))
	{
		char const *const home = std::getenv("HOME");
		if (home)
		{
			++start;
			if ((src.end() == start) || (PATHSEPCH == *start))
				result.append(home);
			else
				result.push_back('~');
		}
	}

	while (src.end() != start)
	{
		auto it = start;
		while ((src.end() != it) && ('$' != *it)) ++it;
		if (start != it) result.append(start, it);
		start = it;

		if (src.end() != start)
		{
			start = ++it;
			if ((src.end() != start) && ('{' == *start))
			{
				start = ++it;
				for (++it; (src.end() != it) && ('}' != *it); ++it) { }
				if (src.end() == it)
				{
					result.append("${").append(start, it);
					start = it;
				}
				else
				{
					var.assign(start, it);
					start = ++it;
					const char *const exp = std::getenv(var.c_str());
					if (exp)
						result.append(exp);
				}
			}
			else if ((src.end() != start) && (('_' == *start) || std::isalnum(*start)))
			{
				for (++it; (src.end() != it) && (('_' == *it) || std::isalnum(*it)); ++it) { }
				var.assign(start, it);
				start = it;
				const char *const exp = std::getenv(var.c_str());
				if (exp)
					result.append(exp);
			}
			else
			{
				result.push_back('$');
			}
		}
	}

	return result;
}
