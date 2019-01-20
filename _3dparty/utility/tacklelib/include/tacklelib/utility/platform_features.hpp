#pragma once

// DO NOT REMOVE, exists to avoid private/public headers mixing!
#ifndef UTILITY_PLATFORM_FEATURES_HPP
#define UTILITY_PLATFORM_FEATURES_HPP

#include <tacklelib/tacklelib.hpp>

#include <tacklelib/utility/platform.hpp>


// COMPILER FEATURES AND WORKAROUNDS

// common implementation based on: https://stackoverflow.com/questions/26089319/is-there-a-standard-definition-for-cplusplus-in-c14
// msvc implementation based on:
//  https://stackoverflow.com/questions/37503029/cplusplus-is-equal-to-199711-in-msvc-does-it-support-c11
//  and Microsoft `C++ 14 Core Language Features` for the `Visual Studio 2015` workaround
//
#ifdef UTILITY_COMPILER_CXX_MSC

// MSVC specific workarounds, tested on Visual Studio 2015 Update 3
//
// details: https://en.wikipedia.org/wiki/Microsoft_Visual_C%2B%2B
//
//  MSC    1.0   _MSC_VER == 100
//  MSC    2.0   _MSC_VER == 200
//  MSC    3.0   _MSC_VER == 300
//  MSC    4.0   _MSC_VER == 400
//  MSC    5.0   _MSC_VER == 500
//  MSC    6.0   _MSC_VER == 600
//  MSC    7.0   _MSC_VER == 700
//  MSVC++ 1.0   _MSC_VER == 800
//  MSVC++ 2.0   _MSC_VER == 900
//  MSVC++ 4.0   _MSC_VER == 1000 (Developer Studio 4.0)
//  MSVC++ 4.2   _MSC_VER == 1020 (Developer Studio 4.2)
//  MSVC++ 5.0   _MSC_VER == 1100 (Visual Studio 97 version 5.0)
//  MSVC++ 6.0   _MSC_VER == 1200 (Visual Studio 6.0 version 6.0)
//  MSVC++ 7.0   _MSC_VER == 1300 (Visual Studio .NET 2002 version 7.0)
//  MSVC++ 7.1   _MSC_VER == 1310 (Visual Studio .NET 2003 version 7.1)
//  MSVC++ 8.0   _MSC_VER == 1400 (Visual Studio 2005 version 8.0)
//  MSVC++ 9.0   _MSC_VER == 1500 (Visual Studio 2008 version 9.0)
//  MSVC++ 10.0  _MSC_VER == 1600 (Visual Studio 2010 version 10.0)
//  MSVC++ 11.0  _MSC_VER == 1700 (Visual Studio 2012 version 11.0)
//  MSVC++ 12.0  _MSC_VER == 1800 (Visual Studio 2013 version 12.0)
//  MSVC++ 14.0  _MSC_VER == 1900 (Visual Studio 2015 version 14.0)
//  MSVC++ 14.1  _MSC_VER == 1910 (Visual Studio 2017 version 15.0)
//  MSVC++ 14.11 _MSC_VER == 1911 (Visual Studio 2017 version 15.3)
//  MSVC++ 14.12 _MSC_VER == 1912 (Visual Studio 2017 version 15.5)
//  MSVC++ 14.13 _MSC_VER == 1913 (Visual Studio 2017 version 15.6)
//  MSVC++ 14.14 _MSC_VER == 1914 (Visual Studio 2017 version 15.7)
//

#   if UTILITY_COMPILER_CXX_VERSION >= 1915
#       define TEMPLATE_SCOPE template
#   else
#       define TEMPLATE_SCOPE
#   endif

#   if UTILITY_COMPILER_CXX_VERSION >= 1600
#       define UTILITY_PLATFORM_FEATURE_CXX_STANDARD_CPP11
#   endif

#   if UTILITY_COMPILER_CXX_VERSION >= 1900
#       define UTILITY_PLATFORM_FEATURE_CXX_STANDARD_CPP14
#   endif

#   if UTILITY_COMPILER_CXX_VERSION >= 1900
#       define UTILITY_PLATFORM_FEATURE_CXX_STANDARD_CONSTEXPR
#   endif

#   if UTILITY_COMPILER_CXX_VERSION >= 1910
#       define UTILITY_PLATFORM_FEATURE_CXX_STANDARD_CONSTEXPR_RETURN
#   endif


#   if UTILITY_COMPILER_CXX_VERSION >= 1310
#       define UTILITY_PLATFORM_FEATURE_CXX_STANDARD_LLONG
#       define UTILITY_PLATFORM_FEATURE_CXX_STANDARD_ULLONG
#   endif

#   if UTILITY_COMPILER_CXX_VERSION >= 1900
#       define UTILITY_PLATFORM_FEATURE_CXX_STANDARD_INTEGER_SEQUENCE
#   endif

#   if UTILITY_COMPILER_CXX_VERSION >= 1900
#       define UTILITY_PLATFORM_FEATURE_CXX_STANDARD_MAKE_UNIQUE
#   endif

#else

#   define TEMPLATE_SCOPE template

#   if __cplusplus >= 201103L
#       define UTILITY_PLATFORM_FEATURE_CXX_STANDARD_CPP11
#       define UTILITY_PLATFORM_FEATURE_CXX_STANDARD_CONSTEXPR_RETURN
#       define UTILITY_PLATFORM_FEATURE_CXX_STANDARD_CONSTEXPR
#   endif

#   if __cplusplus >= 201402L
#       define UTILITY_PLATFORM_FEATURE_CXX_STANDARD_CPP14
#   endif

#   ifdef LLONG_MAX
#       define UTILITY_PLATFORM_FEATURE_CXX_STANDARD_LLONG
#   endif
#   ifdef ULLONG_MAX
#       define UTILITY_PLATFORM_FEATURE_CXX_STANDARD_ULLONG
#   endif

#   ifdef UTILITY_PLATFORM_FEATURE_CXX_STANDARD_CPP14
#       define UTILITY_PLATFORM_FEATURE_CXX_STANDARD_INTEGER_SEQUENCE
#       define UTILITY_PLATFORM_FEATURE_CXX_STANDARD_MAKE_UNIQUE
#   endif

#endif

#ifdef UTILITY_PLATFORM_FEATURE_CXX_STANDARD_CONSTEXPR_RETURN
#define CONSTEXPR_RETURN constexpr
#else
#define CONSTEXPR_RETURN
#endif

#ifdef UTILITY_PLATFORM_FEATURE_CXX_STANDARD_CONSTEXPR
#define CONSTEXPR constexpr
#else
#define CONSTEXPR
#endif

#endif
