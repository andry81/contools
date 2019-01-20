#pragma once

// DO NOT REMOVE, exists to avoid private/public headers mixing!
#ifndef UTILITY_PLATFORM_HPP
#define UTILITY_PLATFORM_HPP

#include <tacklelib/tacklelib.hpp>

#include <tacklelib/utility/preprocessor.hpp>

#include <limits.h>


#if defined(linux) || defined(__linux) || defined(__linux__) || defined(__GNU__) || defined(__GLIBC__)
#   define UTILITY_PLATFORM_LINUX
#   define UTILITY_PLATFORM_POSIX
#   if defined(__mcbc__)
#       define UTILITY_PLATFORM_MCBC
#       define UTILITY_PLATFORM_SHORT_NAME "MCBC"
#   elif defined( __astra_linux__ )
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
#elif defined(__CYGWIN__) // cygwin is not win32:
#   define UTILITY_PLATFORM_CYGWIN
#   define UTILITY_PLATFORM_POSIX
#   define UTILITY_PLATFORM_SHORT_NAME "Cygwin"
#elif defined(_WIN32) || defined(__WIN32__) || defined(WIN32) // win32:
#   define UTILITY_PLATFORM_WINDOWS
#   define UTILITY_PLATFORM_SHORT_NAME "Windows"
#   if defined(__MINGW32__)  //  Get the information about the MinGW runtime, i.e. __MINGW32_*VERSION.
#       include <_mingw.h>
#   endif
#elif defined(_WIN64) || defined(__WIN64__) || defined(WIN64) // win64:
#   define UTILITY_PLATFORM_WINDOWS
#   define UTILITY_PLATFORM_SHORT_NAME "Windows"
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

#if defined(__GNUC__)
#   define UTILITY_COMPILER_CXX_GCC
#   define UTILITY_COMPILER_CXX "gcc"
#   define UTILITY_COMPILER_CXX_VERSION __GNUC__
#   if __GNUC__ < 4
#     error unsuported gcc version
#   endif
#elif defined(_MSC_VER)
#   define UTILITY_COMPILER_CXX_MSC
#   define UTILITY_COMPILER_CXX "MS VisualC"
#   define UTILITY_COMPILER_CXX_VERSION _MSC_VER
#else
#   error unknown compiler
#endif


#if defined(UTILITY_COMPILER_CXX_MSC)
#   define UTILITY_PP_FUNCSIG_  __FUNCSIG__
#elif defined(UTILITY_COMPILER_CXX_GCC)
#   define UTILITY_PP_FUNCSIG_  __PRETTY_FUNCTION__
#else
#   define UTILITY_PP_FUNCSIG_  __FUNCSIG__
#endif

#define UTILITY_PP_FUNCSIG UTILITY_PP_FUNCSIG_

#define UTILITY_PP_FUNC_        __FUNCTION__
#define UTILITY_PP_FUNC         UTILITY_PP_FUNC_


// x86 or x64
#if defined(UTILITY_PLATFORM_WINDOWS)
#   if defined(_WIN64) || defined(__WIN64__) || defined(WIN64)
#       define UTILITY_PLATFORM_X64
#   elif defined(_WIN32) || defined(__WIN32__) || defined(WIN32)
#       define UTILITY_PLATFORM_X32
#   endif

#elif defined(UTILITY_COMPILER_CXX_GCC)
#   ifdef __x86_64__
#       define UTILITY_PLATFORM_X64
#   elif __i386__
#       define UTILITY_PLATFORM_X32
#   endif

#else
#   ifdef __x86_64__
#       define UTILITY_PLATFORM_X64
#   elif __i386__
#       define UTILITY_PLATFORM_X32
#   endif

#endif

#if !ERROR_IF_EMPTY_PP_DEF(DEFINE_FORCE_INLINE_TO_FORCE_NO_INLINE)

#if !defined(_DEBUG) && ERROR_IF_EMPTY_PP_DEF(ENABLE_FORCE_INLINE)

#   if defined(UTILITY_COMPILER_CXX_GCC)
#       define FORCE_INLINE             __attribute__((always_inline)) inline
#       define FORCE_INLINE_ALWAYS      FORCE_INLINE
#   elif defined(UTILITY_COMPILER_CXX_MSC)
#       define FORCE_INLINE             __forceinline
#       define FORCE_INLINE_ALWAYS      FORCE_INLINE
#   endif

#else

#   define FORCE_INLINE                 inline
#   define FORCE_INLINE_ALWAYS          FORCE_INLINE

#endif

#else

#if defined(UTILITY_COMPILER_CXX_GCC)
#   define FORCE_INLINE                 inline __attribute__((noinline))
#elif defined(UTILITY_COMPILER_CXX_MSC)
#   define FORCE_INLINE                 inline __declspec(noinline)
#endif

#define FORCE_INLINE_ALWAYS             inline

#endif

#if !defined(_DEBUG) && ERROR_IF_EMPTY_PP_DEF(ENABLE_FORCE_NO_INLINE)

#   if defined(UTILITY_COMPILER_CXX_GCC)
#       define FORCE_NO_INLINE          __attribute__((noinline))
#   elif defined(UTILITY_COMPILER_CXX_MSC)
#       define FORCE_NO_INLINE          __declspec(noinline)
#   endif

#else
#   define FORCE_NO_INLINE
#endif

#if defined(_DEBUG) || !defined(DISABLE_BUILTIN_MAINTAIN_SUPPORT_IN_RELEASE)
#   define BUILTIN_MAINTAIN_OR_PASS_TRUE(x) ((x) ? true : false)
#   define BUILTIN_MAINTAIN_OR_PASS_FALSE(x) ((x) ? false : true)
#else
#   define BUILTIN_MAINTAIN_OR_PASS_TRUE(x) (true)
#   define BUILTIN_MAINTAIN_OR_PASS_FALSE(x) (false)
#endif

#ifdef _DEBUG
#   define DEBUG_RELEASE_EXPR(debug_exp, release_exp) debug_exp
#else
#   define DEBUG_RELEASE_EXPR(debug_exp, release_exp) release_exp
#endif

#define INSTANTIATE_STATIC_ARRAY(prefix, arr_scoped_name) prefix arr_scoped_name[sizeof(arr_scoped_name)]

#endif

#include <tacklelib/utility/platform_features.hpp>
