#pragma once

// DO NOT REMOVE, exists to avoid private/public headers mixing!
#ifndef UTILITY_LIBRARY_HPP
#define UTILITY_LIBRARY_HPP

#include <tacklelib/tacklelib.hpp>

#include <tacklelib/utility/preprocessor.hpp>
#include <tacklelib/utility/platform.hpp>
#include <tacklelib/utility/optimization.hpp>


#if defined(UTILITY_COMPILER_CXX_GCC)
#   define STDCALL                          __attribute__((stdcall))
#   define LIBRARY_API_DECL_EXPORT_ATTR     __attribute__((visibility("default"))) //__attribute__((dllexport))
#   define LIBRARY_API_DECL_IMPORT_ATTR     //__attribute__((dllimport))

#elif defined(UTILITY_COMPILER_CXX_MSC)
#   define STDCALL                          __stdcall
#   define LIBRARY_API_DECL_EXPORT_ATTR     __declspec(dllexport)
#   define LIBRARY_API_DECL_IMPORT_ATTR     __declspec(dllimport)

#endif

#define LIBRARY_API_NONE // not a library

// common implementation
#ifdef LIBRARY_API_EXPORTS
#   ifdef LIBRARY_API_DYNAMIC
#       define LIBRARY_API_DECL_COMMON LIBRARY_API_DECL_EXPORT_ATTR
#   else
#       define LIBRARY_API_DECL_COMMON
#   endif
#else
#   ifdef LIBRARY_API_DYNAMIC
#       define LIBRARY_API_DECL_COMMON LIBRARY_API_DECL_IMPORT_ATTR
#   else
#       define LIBRARY_API_DECL_COMMON
#   endif
#endif

// CAUTION:
//  `extern "C"` is required to link dynamic library symbol directly w/o name mangling
//

// to make the unique link between a library implementation and it's headers
#define LIBRARY_API_DECLARE_HEADER_LIB_INSTANCE_TOKEN_EXPORT(module_instance_name, local_header_scope, instance_token, token_suffix, token_c_str) \
    extern "C" const char LIBRARY_API_DECL UTILITY_PP_CONCAT4(g_build_version_date_time_str_c_$_, module_instance_name, instance_token, token_suffix)[sizeof(token_c_str)]

// do check symbol for linkage directly from header
#define LIBRARY_API_DECLARE_HEADER_LIB_INSTANCE_TOKEN_IMPORT(module_instance_name, local_header_scope, instance_token, token_suffix, token_c_str) \
    extern "C" const char LIBRARY_API_DECL UTILITY_PP_CONCAT4(g_build_version_date_time_str_c_$_, module_instance_name, instance_token, token_suffix)[sizeof(token_c_str)]; \
    static ::utility::unused_param_by_lref<const char [sizeof(token_c_str)]> \
        UTILITY_PP_CONCAT4(s_static_link_enforcer_c_, module_instance_name, _, local_header_scope)(( UTILITY_PP_CONCAT4(g_build_version_date_time_str_c_$_, module_instance_name, instance_token, token_suffix) ))

// do NOT check symbol for linkage directly from header
#define LIBRARY_API_DECLARE_HEADER_LIB_INSTANCE_TOKEN_IMPORT_NO_LINKAGE_CHECK(module_instance_name, local_header_scope, instance_token, token_suffix, token_c_str) \
    extern "C" const char LIBRARY_API_DECL UTILITY_PP_CONCAT4(g_build_version_date_time_str_c_$_, module_instance_name, instance_token, token_suffix)[sizeof(token_c_str)]

#define LIBRARY_API_IMPLEMENT_LIB_GLOBAL_INSTANCE_TOKEN(module_instance_name, instance_token, token_suffix, token_c_str) \
    extern "C" const char UTILITY_PP_CONCAT4(g_build_version_date_time_str_c_$_, module_instance_name, instance_token, token_suffix)[sizeof(token_c_str)] = token_c_str;


// to make the unique link between a library implementation and it's headers
#define LIBRARY_API_DECLARE_HEADER_LIB_BUILD_VERSION_DATE_TIME_TOKEN_EXPORT(module_instance_name, local_header_scope) \
    LIBRARY_API_DECLARE_HEADER_LIB_INSTANCE_TOKEN_EXPORT(module_instance_name, local_header_scope, _, BUILD_VERSION_DATE_TIME_TOKEN, \
        "**build_version**: " BUILD_VERSION_DATE_TIME_STR)

#define LIBRARY_API_DECLARE_HEADER_LIB_BUILD_VERSION_DATE_TIME_TOKEN_IMPORT(module_instance_name, local_header_scope) \
    LIBRARY_API_DECLARE_HEADER_LIB_INSTANCE_TOKEN_IMPORT(module_instance_name, local_header_scope, _, BUILD_VERSION_DATE_TIME_TOKEN, \
        "**build_version**: " BUILD_VERSION_DATE_TIME_STR)

#define LIBRARY_API_DECLARE_HEADER_LIB_BUILD_VERSION_DATE_TIME_TOKEN_IMPORT_NO_LINKAGE_CHECK(module_instance_name, local_header_scope) \
    LIBRARY_API_DECLARE_HEADER_LIB_INSTANCE_TOKEN_IMPORT_NO_LINKAGE_CHECK(module_instance_name, local_header_scope, _, BUILD_VERSION_DATE_TIME_TOKEN, \
        "**build_version**: " BUILD_VERSION_DATE_TIME_STR)

#define LIBRARY_API_IMPLEMENT_LIB_GLOBAL_BUILD_VERSION_DATE_TIME_TOKEN(module_instance_name) \
    LIBRARY_API_IMPLEMENT_LIB_GLOBAL_INSTANCE_TOKEN(module_instance_name, _, BUILD_VERSION_DATE_TIME_TOKEN, \
        "**build_version**: " BUILD_VERSION_DATE_TIME_STR)

#endif
