#pragma once

#ifndef __STD_TSTDLIB_HPP__
#define __STD_TSTDLIB_HPP__

#include <stdlib.h>
#include <tchar.h>

#ifdef _UNICODE
# define tstrtoul   wcstoul
# define ultot      _ultow
#else
# define tstrtoul   strtoul
# define ultot      _ultoa
#endif


// templates

template <typename t_char>
unsigned long t_strtoul(const t_char * str, t_char ** str_end, int base);

template <>
inline unsigned long t_strtoul(const char * str, char ** str_end, int base)
{
    return ::strtoul(str, str_end, base);
}

template <>
inline unsigned long t_strtoul(const wchar_t * str, wchar_t ** str_end, int base)
{
    return ::wcstoul(str, str_end, base);
}


template <typename t_char>
t_char * t_ultostr(unsigned long num, t_char * str, int radix);

template <>
inline char * t_ultostr(unsigned long num, char * str, int radix)
{
    return ::_ultoa(num, str, radix);
}

template <>
inline wchar_t * t_ultostr(unsigned long num, wchar_t * str, int radix)
{
    return ::_ultow(num, str, radix);
}


// overloads

inline unsigned long strtoul(const wchar_t * str, wchar_t ** str_end, int base)
{
    return t_strtoul(str, str_end, base);
}

inline char * ultostr(unsigned long num, char * str, int radix)
{
    return t_ultostr(num, str, radix);
}

inline wchar_t * ultostr(unsigned long num, wchar_t * str, int radix)
{
    return t_ultostr(num, str, radix);
}

#endif
