#ifndef __STD_TCTYPE_HPP__
#define __STD_TCTYPE_HPP__

#include <ctype.h>
#include <tchar.h>

#ifdef _UNICODE
# define tisdigit   iswdigit
# define tisxdigit  iswxdigit
#else
# define tisdigit   isdigit
# define tisxdigit  isxdigit
#endif

#endif
