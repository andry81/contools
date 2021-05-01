#ifndef __STD_TSTDIO_HPP__
#define __STD_TSTDIO_HPP__

#include <stdio.h>
#include <tchar.h>

#ifdef _UNICODE
# define tfopen   _wfopen
# define tfreopen _wfreopen
# define tputs    _putws
#else
# define tfopen   fopen
# define tfreopen freopen
# define tputs    puts
#endif

#endif
