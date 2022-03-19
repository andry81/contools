#pragma once

#ifndef __CALLF_HPP__
#define __CALLF_HPP__

#define _CRT_SECURE_NO_WARNINGS
//#define WIN32_LEAN_AND_MEAN // Exclude rarely-used stuff from Windows headers

#include <windows.h>
#include <tchar.h>

#include "common.hpp"
#include "printf.hpp"

extern bool g_is_process_executed;
extern bool g_is_process_elevating;
extern bool g_is_process_unelevating;
extern bool g_is_process_elevated;

extern struct StdHandles      g_detached_std_handles;
extern struct StdHandlesState g_detached_std_handles_state;

#endif
