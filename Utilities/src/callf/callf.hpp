#pragma once

#ifndef __CALLF_HPP__
#define __CALLF_HPP__

#define _CRT_SECURE_NO_WARNINGS
//#define WIN32_LEAN_AND_MEAN // Exclude rarely-used stuff from Windows headers

#include <windows.h>
#include <tchar.h>
#include <stdio.h>
#include <string.h>
#include <memory.h>
#include <io.h>
#include <fcntl.h>
#include <tlhelp32.h>

#include <algorithm>
#include <atomic>

#include "common.hpp"
#include "printf.hpp"


extern bool g_is_process_executed;

#endif
