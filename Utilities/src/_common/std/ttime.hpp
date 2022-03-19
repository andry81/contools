#pragma once

#ifndef __STD_TTIME_HPP__
#define __STD_TTIME_HPP__

#include <time.h>
#include <tchar.h>

#ifdef _UNICODE
# define tstrftime  wcsftime
#else
# define tstrftime  strftime
#endif

#endif
