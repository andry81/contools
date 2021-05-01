#ifndef __STD_TSTRING_HPP__
#define __STD_TSTRING_HPP__

#include <string>
#include <tchar.h>

#ifdef _UNICODE
# define tstrlen  wcslen
# define tstrstr  wcsstr
# define tstrcpy  wcscpy
# define tstrcat  wcscat
# define tstrcmp  wcscmp
# define tstrncmp wcsncmp
#else
# define tstrlen  strlen
# define tstrstr  strstr
# define tstrcpy  strcpy
# define tstrcat  strcat
# define tstrcmp  strcmp
# define tstrncmp strncmp
#endif

namespace std {
    using tstring = std::basic_string<TCHAR, std::char_traits<TCHAR>, allocator<TCHAR> >;
}

#endif
