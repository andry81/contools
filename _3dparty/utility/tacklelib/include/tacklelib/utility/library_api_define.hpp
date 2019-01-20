// multiusage header, DO NOT USE pragma guard here!

#include <tacklelib/tacklelib.hpp>

#include <tacklelib/utility/platform.hpp>
#include <tacklelib/utility/library.hpp>

// INTERFACE INPUT DEFINITIONS:
//  * LIBRARY_API
//      - defines a library linkage state.
//      - should be defined only from static/shared library targets.
//      - should NOT be defined from not a library target.
//      - must be private and defined separately per each library target.
//  * LIBRARY_API_NAMESPACE
//      - defines a library inner token namespace associated with a particular library.
//      - must be unique per library.
//      - should be defined only from static/shared library targets.
//      - should NOT be defined from not a library target.
//      - must be defined in a library interface header, but before `library_api_define.hpp` header inclusion
//        (automatically undefines in the `library_api_define.hpp` header).
//  * LIBRARY_API_EXPORTS_<library_api_namespace>
//      - defines export state of a library target defined in LIBRARY_API_NAMESPACE.
//      - should be defined only from static/shared library targets.
//      - should NOT be defined from not a library target.
//      - must be private and defined separately per each library target.
//  * LIBRARY_API_DYNAMIC_<library_api_namespace>
//      - defines a shared library type for a target defined in LIBRARY_API_NAMESPACE.
//      - should be defined only from static/shared library targets.
//      - should NOT be defined from not a library target.
//      - must be public and transitively visible from all interfaced targets has imported target defined or forwarded this definition.
//  * LIBRARY_API_IMPORT_NO_LINKAGE_CHECK
//      - disables LIBRARY_API_DECLARE_HEADER_*_IMPORT definitions from a specific linkage symbol existence check which has
//        being exported by the LIBRARY_API_DECLARE_HEADER_*_EXPORT definitions.
//      - must be defined separately before each `library_api_define.hpp` header inclusion, undefines automatically.
//  * LIBRARY_API_IMPORT_ALL_NO_LINKAGE_CHECK
//      - disables LIBRARY_API_DECLARE_HEADER_*_IMPORT definitions from a specific linkage symbol existence check which has
//        being exported by the LIBRARY_API_DECLARE_HEADER_*_EXPORT definitions.
//      - defines behaviour for all interface headers of a library, because does not undefine automatically at the end.
// 

// INTERFACE OUTPUT DEFINITIONS:
//  * LIBRARY_API_DECL
//      - defines a declaration expression for a library symbols from single or multiple headers where symbols must be exported or imported.
//      - must not be used without prepended `library_api_define.hpp` header inclusion in the same header.
//  * LIBRARY_API_DECL_DEFINED_EXPORT/LIBRARY_API_DECL_DEFINED_IMPORT
//      - defines state of library to export or to import inside a header.
//      - must not be used without prepended `library_api_define.hpp` header inclusion in the same header.
//  * LIBRARY_API_DECL_DEFINED_NOT_EMPTY/LIBRARY_API_DECL_DEFINED_EMPTY
//      - defines emptiness of the LIBRARY_API_DECL definition.
//      - must not be used without prepended `library_api_define.hpp` header inclusion in the same header.
//  * LIBRARY_API_DECL_DEFINED_DYNAMIC_EXPORT/LIBRARY_API_DECL_DEFINED_STATIC_EXPORT
//      - defines type of library to export inside a header.
//      - must not be used without prepended `library_api_define.hpp` header inclusion in the same header.
//  * LIBRARY_API_DECL_DEFINED_DYNAMIC_IMPORT/LIBRARY_API_DECL_DEFINED_STATIC_IMPORT
//      - defines type of library to import inside a header.
//      - must not be used without prepended `library_api_define.hpp` header inclusion in the same header.
//  * LIBRARY_API_DECLARE_HEADER_LIB_INSTANCE_TOKEN/LIBRARY_API_DECLARE_HEADER_LIB_BUILD_VERSION_DATE_TIME_TOKEN
//      - switches to a respective macro to import/export a library specific linkage symbol from header.
//      - must not be used without prepended `library_api_define.hpp` header inclusion in the same header.
//

#if defined(LIBRARY_API) && !defined(LIBRARY_API_NAMESPACE)
#   error You must define LIBRARY_API_NAMESPACE macro if LIBRARY_API was defined to declare library api namespace before this include
#endif

#undef LIBRARY_API_DECL

#undef LIBRARY_API_DECLARE_HEADER_LIB_INSTANCE_TOKEN
#undef LIBRARY_API_DECLARE_HEADER_LIB_BUILD_VERSION_DATE_TIME_TOKEN

#undef LIBRARY_API_DECL_DEFINED_DYNAMIC
#undef LIBRARY_API_DECL_DEFINED_STATIC

#undef LIBRARY_API_DECL_DEFINED_EXPORT
#undef LIBRARY_API_DECL_DEFINED_IMPORT

#undef LIBRARY_API_DECL_STATIC_EXPORT
#undef LIBRARY_API_DECL_DYNAMIC_EXPORT

#undef LIBRARY_API_DECL_STATIC_IMPORT
#undef LIBRARY_API_DECL_DYNAMIC_IMPORT

#undef LIBRARY_API_DECL_STATIC
#undef LIBRARY_API_DECL_DYNAMIC

#undef LIBRARY_API_DECL_DEFINED_NOT_EMPTY
#undef LIBRARY_API_DECL_DEFINED_EMPTY

#undef LIBRARY_API_DECL_DEFINED_DYNAMIC_EXPORT
#undef LIBRARY_API_DECL_DEFINED_STATIC_EXPORT

#undef LIBRARY_API_DECL_DEFINED_DYNAMIC_IMPORT
#undef LIBRARY_API_DECL_DEFINED_STATIC_IMPORT

// just in case
#undef LIBRARY_API_EXPORTS_
#undef LIBRARY_API_DYNAMIC_

#define DEFINED_LIBRARY_API_EXPORTS_(library_api_namespace)             LIBRARY_API_EXPORTS_ ## library_api_namespace != 0
#define DEFINED_LIBRARY_API_DYNAMIC_(library_api_namespace)             LIBRARY_API_DYNAMIC_ ## library_api_namespace != 0

#define DEFINED_LIBRARY_API_EXPORTS(library_api_namespace)              DEFINED_LIBRARY_API_EXPORTS_(library_api_namespace)
#define DEFINED_LIBRARY_API_DYNAMIC(library_api_namespace)              DEFINED_LIBRARY_API_DYNAMIC_(library_api_namespace)

#if DEFINED_LIBRARY_API_DYNAMIC(LIBRARY_API_NAMESPACE)
//  * Dynamic type of export enabled *
#   define LIBRARY_API_DECL_DEFINED_DYNAMIC
#else
//  * Static type of export enabled *
#   define LIBRARY_API_DECL_DEFINED_STATIC
#endif

#if DEFINED_LIBRARY_API_EXPORTS(LIBRARY_API_NAMESPACE)
// * Export mode enabled *
#   define LIBRARY_API_DECL_DEFINED_EXPORT
#else
// * Import mode enabled *
#   define LIBRARY_API_DECL_DEFINED_IMPORT
#endif

// per public header import definitions
#if defined(LIBRARY_API) && defined(LIBRARY_API_DECL_DEFINED_EXPORT)
#   define LIBRARY_API_DECL_STATIC_EXPORT
#   define LIBRARY_API_DECL_DYNAMIC_EXPORT                              LIBRARY_API_DECL_EXPORT_ATTR

#   define LIBRARY_API_DECL_STATIC                                      LIBRARY_API_DECL_STATIC_EXPORT
#   define LIBRARY_API_DECL_DYNAMIC                                     LIBRARY_API_DECL_DYNAMIC_EXPORT

#   ifdef LIBRARY_API_DECL_DEFINED_DYNAMIC
#       define LIBRARY_API_DECL                                         LIBRARY_API_DECL_DYNAMIC_EXPORT
#       define LIBRARY_API_DECL_DEFINED_NOT_EMPTY
#       define LIBRARY_API_DECL_DEFINED_DYNAMIC_EXPORT
#   else
#       define LIBRARY_API_DECL                                         LIBRARY_API_DECL_STATIC_EXPORT
#       define LIBRARY_API_DECL_DEFINED_EMPTY
#       define LIBRARY_API_DECL_DEFINED_STATIC_EXPORT
#   endif

#   define LIBRARY_API_DECLARE_HEADER_LIB_INSTANCE_TOKEN                LIBRARY_API_DECLARE_HEADER_LIB_INSTANCE_TOKEN_EXPORT
#   define LIBRARY_API_DECLARE_HEADER_LIB_BUILD_VERSION_DATE_TIME_TOKEN LIBRARY_API_DECLARE_HEADER_LIB_BUILD_VERSION_DATE_TIME_TOKEN_EXPORT

#else
#   define LIBRARY_API_DECL_STATIC_IMPORT
#   define LIBRARY_API_DECL_DYNAMIC_IMPORT                              LIBRARY_API_DECL_IMPORT_ATTR

#   define LIBRARY_API_DECL_STATIC                                      LIBRARY_API_DECL_STATIC_IMPORT
#   define LIBRARY_API_DECL_DYNAMIC                                     LIBRARY_API_DECL_DYNAMIC_IMPORT

#   ifdef LIBRARY_API_DECL_DEFINED_DYNAMIC
#       define LIBRARY_API_DECL                                         LIBRARY_API_DECL_DYNAMIC_IMPORT
#       define LIBRARY_API_DECL_DEFINED_NOT_EMPTY
#       define LIBRARY_API_DECL_DEFINED_DYNAMIC_IMPORT
#   else
#       define LIBRARY_API_DECL                                         LIBRARY_API_DECL_STATIC_IMPORT
#       define LIBRARY_API_DECL_DEFINED_EMPTY
#       define LIBRARY_API_DECL_DEFINED_STATIC_IMPORT
#   endif

#   define LIBRARY_API_DECLARE_HEADER_LIB_INSTANCE_TOKEN                LIBRARY_API_DECLARE_HEADER_LIB_INSTANCE_TOKEN_IMPORT

#   if !defined(LIBRARY_API_IMPORT_NO_LINKAGE_CHECK) && !defined(LIBRARY_API_IMPORT_ALL_NO_LINKAGE_CHECK)
#       define LIBRARY_API_DECLARE_HEADER_LIB_BUILD_VERSION_DATE_TIME_TOKEN LIBRARY_API_DECLARE_HEADER_LIB_BUILD_VERSION_DATE_TIME_TOKEN_IMPORT
#   else
#       define LIBRARY_API_DECLARE_HEADER_LIB_BUILD_VERSION_DATE_TIME_TOKEN LIBRARY_API_DECLARE_HEADER_LIB_BUILD_VERSION_DATE_TIME_TOKEN_IMPORT_NO_LINKAGE_CHECK
#   endif

#endif

#undef LIBRARY_API_DECL_IS_DYNAMIC
#ifdef LIBRARY_API_DECL_DEFINED_DYNAMIC
#   define LIBRARY_API_DECL_IS_DYNAMIC                                  1
#else
#   define LIBRARY_API_DECL_IS_DYNAMIC                                  0
#endif

#undef LIBRARY_API_DECL_IS_STATIC
#ifdef LIBRARY_API_DECL_DEFINED_STATIC
#   define LIBRARY_API_DECL_IS_STATIC                                   1
#else
#   define LIBRARY_API_DECL_IS_STATIC                                   0
#endif

#undef LIBRARY_API_DECL_IS_EXPORT
#ifdef LIBRARY_API_DECL_DEFINED_EXPORT
#   define LIBRARY_API_DECL_IS_EXPORT                                   1
#else
#   define LIBRARY_API_DECL_IS_EXPORT                                   0
#endif

#undef LIBRARY_API_DECL_IS_IMPORT
#ifdef LIBRARY_API_DECL_DEFINED_IMPORT
#   define LIBRARY_API_DECL_IS_IMPORT                                   1
#else
#   define LIBRARY_API_DECL_IS_IMPORT                                   0
#endif

#undef LIBRARY_API_DECL_IS_NOT_EMPTY
#undef LIBRARY_API_DECL_IS_EMPTY
#ifdef LIBRARY_API_DECL_DEFINED_NOT_EMPTY
#   define LIBRARY_API_DECL_IS_NOT_EMPTY                                1
#   define LIBRARY_API_DECL_IS_EMPTY                                    0
#endif
#ifdef LIBRARY_API_DECL_DEFINED_EMPTY
#   define LIBRARY_API_DECL_IS_NOT_EMPTY                                0
#   define LIBRARY_API_DECL_IS_EMPTY                                    1
#endif

#undef DEFINED_LIBRARY_API_EXPORTS
#undef DEFINED_LIBRARY_API_DYNAMIC
#undef DEFINED_LIBRARY_API_EXPORTS_
#undef DEFINED_LIBRARY_API_DYNAMIC_

// undefine because definition must be set per single header basis
#undef LIBRARY_API_IMPORT_NO_LINKAGE_CHECK // do not check symbol for linkage directly from header

//#pragma message(\
//    "NAMESPACE=" UTILITY_PP_STRINGIZE(LIBRARY_API_NAMESPACE)\
//    "; STATIC=" UTILITY_PP_STRINGIZE(LIBRARY_API_DECL_IS_STATIC)\
//    "; DYNAMIC=" UTILITY_PP_STRINGIZE(LIBRARY_API_DECL_IS_DYNAMIC)\
//    "; EXPORT=" UTILITY_PP_STRINGIZE(LIBRARY_API_DECL_IS_EXPORT)\
//    "; IMPORT=" UTILITY_PP_STRINGIZE(LIBRARY_API_DECL_IS_IMPORT)\
//    "; LIBRARY_API_DECL=" UTILITY_PP_STRINGIZE_IF(LIBRARY_API_DECL_IS_NOT_EMPTY, LIBRARY_API_DECL))

#undef LIBRARY_API_NAMESPACE
