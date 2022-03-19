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
# define ultot      ultoa
#endif

#endif
