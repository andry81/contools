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
extern bool g_is_process_self_elevation;
extern bool g_is_process_elevating;
extern bool g_is_process_unelevating;
extern bool g_is_process_elevated;

extern struct StdHandles      g_detached_std_handles;
extern struct StdHandlesState g_detached_std_handles_state;

namespace
{
    enum _error
    {
        err_none                        = 0,

        err_unspecified                 = -255,

        err_seh_exception               = -254,

        err_named_pipe_connect_timeout  = -7,
        err_named_pipe_connect_error    = -6,
        err_io_error                    = -5,
        err_win32_error                 = -4,
        err_invalid_params              = -3,
        err_invalid_format              = -2,

        err_help_output                 = -1
    };
}

#endif
