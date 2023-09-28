#pragma once

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

# define to_tstring to_wstring
#else
# define tstrlen  strlen
# define tstrstr  strstr
# define tstrcpy  strcpy
# define tstrcat  strcat
# define tstrcmp  strcmp
# define tstrncmp strncmp

# define to_tstring to_string
#endif


namespace std {
    using tstring = std::basic_string<TCHAR, std::char_traits<TCHAR>, allocator<TCHAR> >;
}

// templates

template <typename t_char>
size_t t_strlen(const t_char * str);

template <>
inline size_t t_strlen(const char * str)
{
    return ::strlen(str);
}

template <>
inline size_t t_strlen(const wchar_t * str)
{
    return ::wcslen(str);
}


template <typename t_char>
const t_char * t_strstr(const t_char * str1, const t_char * str2);

template <>
inline const char * t_strstr(const char * str1, const char * str2)
{
    return ::strstr(str1, str2);
}

template <>
inline const wchar_t * t_strstr(const wchar_t * str1, const wchar_t * str2)
{
    return ::wcsstr(str1, str2);
}


template <typename t_char>
t_char * t_strcpy(t_char * dest, const t_char * src);

template <>
inline char * t_strcpy(char * dest, const char * src)
{
    return ::strcpy(dest, src);
}

template <>
inline wchar_t * t_strcpy(wchar_t * dest, const wchar_t * src)
{
    return ::wcscpy(dest, src);
}


template <typename t_char>
t_char * t_strcat(t_char * dest, const t_char * src);

template <>
inline char * t_strcat(char * dest, const char * src)
{
    return ::strcat(dest, src);
}

template <>
inline wchar_t * t_strcat(wchar_t * dest, const wchar_t * src)
{
    return ::wcscat(dest, src);
}


template <typename t_char>
inline int t_strcmp(const t_char * str1, const t_char * str2);

template <>
inline int t_strcmp(const char * str1, const char * str2)
{
    return ::strcmp(str1, str2);
}

template <>
inline int t_strcmp(const wchar_t * str1, const wchar_t * str2)
{
    return ::wcscmp(str1, str2);
}


template <typename t_char>
inline int t_strncmp(const t_char * str1, const t_char * str2, size_t num);

template <>
inline int t_strncmp(const char * str1, const char * str2, size_t num)
{
    return ::strncmp(str1, str2, num);
}

template <>
inline int t_strncmp(const wchar_t * str1, const wchar_t * str2, size_t num)
{
    return ::wcsncmp(str1, str2, num);
}

// overloads

inline size_t strlen(const wchar_t * str)
{
    return t_strlen(str);
}

inline const wchar_t * strstr(const wchar_t * str1, const wchar_t * str2)
{
    return t_strstr(str1, str2);
}

inline wchar_t * strcpy(wchar_t * dest, const wchar_t * src)
{
    return t_strcpy(dest, src);
}

inline wchar_t * strcat(wchar_t * dest, const wchar_t * src)
{
    return t_strcat(dest, src);
}

inline int strcmp(const wchar_t * str1, const wchar_t * str2)
{
    return t_strcmp(str1, str2);
}

#endif
