#pragma once

// DO NOT REMOVE, exists to avoid private/public headers mixing!
#ifndef UTILITY_PLATFORM_HPP
#define UTILITY_PLATFORM_HPP

#include <limits.h>


#if defined(linux) || defined(__linux) || defined(__linux__) || defined(__GNU__) || defined(__GLIBC__)
#   define UTILITY_PLATFORM_LINUX
#   define UTILITY_PLATFORM_POSIX
#   if defined(__mcbc__)
#       define UTILITY_PLATFORM_MCBC
#       define UTILITY_PLATFORM_SHORT_NAME "MCBC"
#   elif defined(__astra_linux__)
#       define UTILITY_PLATFORM_ASTRA_LINUX
#       define UTILITY_PLATFORM_SHORT_NAME "Astra Linux"
#   else
#       define UTILITY_PLATFORM_SHORT_NAME "Linux"
#   endif
#elif defined(__FreeBSD__) || defined(__NetBSD__) || defined(__OpenBSD__) || defined(__DragonFly__) // BSD:
#   define UTILITY_PLATFORM_BSD
#   define UTILITY_PLATFORM_POSIX
#   define UTILITY_PLATFORM_SHORT_NAME "BSD"
#elif defined(sun) || defined(__sun) // solaris:
#   define UTILITY_PLATFORM_SOLARIS
#   define UTILITY_PLATFORM_POSIX
#   define UTILITY_PLATFORM_SHORT_NAME "Solaris"
#elif defined(__MSYS__)
#   define UTILITY_PLATFORM_MSYS
#   define UTILITY_PLATFORM_POSIX
#   define UTILITY_PLATFORM_SHORT_NAME "Msys"
#   if defined(__MINGW32__) || defined(__MINGW64__) || defined(MINGW)
#       include <_mingw.h>  //  Get the information about the MinGW runtime, i.e. __MINGW32_*VERSION.
#       define UTILITY_PLATFORM_MINGW
#   endif
#elif defined(__CYGWIN__)   // cygwin is not win32, but can be msys or with mingw
#   define UTILITY_PLATFORM_CYGWIN
#   define UTILITY_PLATFORM_POSIX
#   define UTILITY_PLATFORM_SHORT_NAME "Cygwin"
#   if defined(__MINGW32__) || defined(__MINGW64__) || defined(MINGW)
#       include <_mingw.h>  //  Get the information about the MinGW runtime, i.e. __MINGW32_*VERSION.
#       define UTILITY_PLATFORM_MINGW
#   endif
#elif defined(_WIN32) || defined(__WIN32__) || defined(WIN32) || \
      defined(_WIN64) || defined(__WIN64__) || defined(WIN64)
#   define UTILITY_PLATFORM_WINDOWS
#   if defined(__MINGW32__) || defined(__MINGW64__) || defined(MINGW)
#       include <_mingw.h>  //  Get the information about the MinGW runtime, i.e. __MINGW32_*VERSION.
#       define UTILITY_PLATFORM_MINGW
#       define UTILITY_PLATFORM_SHORT_NAME "Mingw"
#   else
#       define UTILITY_PLATFORM_SHORT_NAME "Windows"
#   endif
#elif defined(macintosh) || defined(__APPLE__) || defined(__APPLE_CC__) // MacOS
#   define UTILITY_PLATFORM_APPLE
#   define UTILITY_PLATFORM_POSIX
#   define UTILITY_PLATFORM_SHORT_NAME "MacOS"
#elif defined(__QNXNTO__)  // QNX:
#   define UTILITY_PLATFORM_QNIX
#   define UTILITY_PLATFORM_POSIX
#   define UTILITY_PLATFORM_SHORT_NAME "QNX"
#elif defined(unix) || defined(__unix) || defined(_XOPEN_SOURCE) || defined(_POSIX_SOURCE)
#   define UTILITY_PLATFORM_UNIX
#   define UTILITY_PLATFORM_POSIX
#   define UTILITY_PLATFORM_SHORT_NAME "Unix"
#else
#   error unknown platform
#endif

#endif
