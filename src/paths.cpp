// Asciiverse: see paths.h.
#include "paths.h"

#include <cstdlib>
#include <filesystem>
#include <system_error>

#if defined(_WIN32)
#  include <windows.h>
#elif defined(__APPLE__)
#  include <mach-o/dyld.h>
#endif

namespace fs = std::filesystem;

namespace
{
std::string with_slash(const fs::path &p)
{
  std::string s = p.string();
  if(!s.empty() && s.back() != '/' && s.back() != '\\')
  {
    s += static_cast<char>(fs::path::preferred_separator);
  }
  return s;
}

fs::path executable_dir()
{
  std::error_code ec;
#if defined(_WIN32)
  wchar_t buf[MAX_PATH];
  DWORD n = GetModuleFileNameW(nullptr, buf, MAX_PATH);
  if(n > 0 && n < MAX_PATH)
  {
    return fs::path(buf).parent_path();
  }
#elif defined(__APPLE__)
  char buf[4096];
  uint32_t size = sizeof buf;
  if(_NSGetExecutablePath(buf, &size) == 0)
  {
    fs::path p = fs::weakly_canonical(buf, ec);
    return ec ? fs::path(buf).parent_path() : p.parent_path();
  }
#else
  fs::path p = fs::read_symlink("/proc/self/exe", ec);
  if(!ec)
  {
    return p.parent_path();
  }
#endif
  return {};
}

const char *env(const char *name)
{
  const char *v = std::getenv(name);
  return v && *v ? v : nullptr;
}
} // namespace

std::string find_lib_dir()
{
  if(const char *v = env("OMEGALIB"))
  {
    return with_slash(v);
  }
  std::error_code ec;
  fs::path beside = executable_dir() / "lib";
  if(!executable_dir().empty() && fs::is_regular_file(beside / "city.dat", ec))
  {
    return with_slash(beside);
  }
  if(fs::is_regular_file("/usr/share/omega/city.dat", ec))
  {
    return "/usr/share/omega/";
  }
  return "./lib/";
}

std::string find_data_dir(const std::string &lib_dir)
{
  fs::path dir;
#if defined(_WIN32)
  if(const char *v = env("APPDATA"))
  {
    dir = fs::path(v) / "omega";
  }
#else
  if(const char *v = env("XDG_DATA_HOME"))
  {
    dir = fs::path(v) / "omega";
  }
  else if(const char *home = env("HOME"))
  {
    dir = fs::path(home) / ".local" / "share" / "omega";
  }
#endif
  std::error_code ec;
  if(dir.empty() || (fs::create_directories(dir, ec), !fs::is_directory(dir, ec)))
  {
    return lib_dir; // nowhere better to write: keep upstream's behaviour
  }
  for(const char *name : {"omega.hi", "omega.log"})
  {
    if(!fs::exists(dir / name, ec))
    {
      fs::copy_file(fs::path(lib_dir) / name, dir / name, ec);
    }
  }
  return with_slash(dir);
}
