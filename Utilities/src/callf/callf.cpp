#define _CRT_SECURE_NO_WARNINGS
//#define WIN32_LEAN_AND_MEAN // Exclude rarely-used stuff from Windows headers

#include <windows.h>
#include <stdio.h>
#include <string.h>
#include <memory.h>
#include <algorithm>

#include "common.hpp"
#include "printf.hpp"

#ifdef _UNICODE
#error Unicode is not supported.
#endif

extern "C" int _CreateProcess(LPCSTR app, size_t app_len, LPCSTR cmd, size_t cmd_len)
{
#ifdef _DEBUG
    printf(">%s\n>%s\n---\n", app ? app : "", cmd ? cmd : "");
#endif

    int res = -1;
    size_t cmd_buf_size = 0;
    void * cmd_buf = NULL;
    STARTUPINFO si;
    PROCESS_INFORMATION pi;

    memset(&si, 0, sizeof(si));
    si.cb = sizeof(si);
    //si.wShowWindow = SW_SHOWDEFAULT;

    __try {
        if (app && app_len) {
            if (cmd && cmd_len) {
                cmd_buf_size = (std::max)(cmd_len + sizeof(TCHAR), size_t(32768U));
                cmd_buf = malloc(cmd_buf_size);
                memcpy(cmd_buf, cmd, cmd_buf_size);
                res = ::CreateProcess(app, (TCHAR *)cmd_buf, NULL, NULL, TRUE, 0, NULL, NULL, &si, &pi);
            }
            else {
                res = ::CreateProcess(app, NULL, NULL, NULL, TRUE, 0, NULL, NULL, &si, &pi);
            }
        }
        else if (cmd && cmd_len) {
            cmd_buf_size = (std::max)(cmd_len + sizeof(TCHAR), size_t(32768U));
            cmd_buf = malloc(cmd_buf_size);
            memcpy(cmd_buf, cmd, cmd_buf_size);
            res = ::CreateProcess(NULL, (TCHAR *)cmd_buf, NULL, NULL, TRUE, 0, NULL, NULL, &si, &pi);
        }
    }
    __finally {
        if (cmd_buf) {
            free(cmd_buf);
            cmd_buf = NULL; // just in case
        }
    }

    WaitForSingleObject(pi.hProcess, INFINITE);

    CloseHandle(pi.hProcess);
    CloseHandle(pi.hThread);

    return res;
}

int main(int argc,const char* argv[])
{
    if(!argc || !argv[0])
        return 255;

    bool do_show_help = false;

    if(argc >= 2 && argv[1] && !strcmp(argv[1], "/?")) {
        if (argc >= 3) return 2;
        do_show_help = true; // /?
    }

    if(do_show_help) {
        ::puts(
#include "help_inl.hpp"
        );

        return 1;
    }

    // environment variable buffer
    char env_buf[MAX_ENV_BUF_SIZE];

    InArgs app_args = InArgs();
    OutArgs app_out_args = OutArgs();

    InArgs cmd_args = InArgs();
    OutArgs cmd_out_args = OutArgs();

    if (argc >= 2 && argv[1] && strlen(argv[1])) {
        app_args.fmt_str = argv[1];
        if (!strcmp(app_args.fmt_str , "")) {
            app_args.fmt_str  = 0;
        }
    }

    if (argc >= 3 && argv[2] && strlen(argv[2])) {
        cmd_args.fmt_str = argv[2];
        if (!strcmp(cmd_args.fmt_str, "")) {
            cmd_args.fmt_str = 0;
        }
    }

    if (!app_args.fmt_str && !cmd_args.fmt_str) return -1;

    // read and parse input arguments
    if (app_args.fmt_str && argc >= 4) {
        app_args.args.resize(argc - 3);
        app_out_args.args.resize(argc - 3);
        for (int i = 0; i < argc - 3; i++) {
            app_args.args[i] = argv[i + 3];
        }
        for (int i = 0; i < argc - 3; i++) {
            if (strcmp(app_args.args[i] , "")) {
                _parse_string(i, app_args.args[i], app_out_args.args[i], env_buf, true, app_args, app_out_args);
            } else {
                app_args.args[i] = nullptr;
            }
        }
    }

    if (cmd_args.fmt_str && argc >= 5) {
        cmd_args.args.resize(argc - 3);
        cmd_out_args.args.resize(argc - 3);
        for (int i = 0; i < argc - 3; i++) {
            cmd_args.args[i] = argv[i + 3];
        }
        for (int i = 0; i < argc - 3; i++) {
            if (strcmp(cmd_args.args[i], "")) {
                _parse_string(i, cmd_args.args[i], cmd_out_args.args[i], env_buf, true, cmd_args, cmd_out_args);
            } else {
                cmd_args.args[i] = nullptr;
            }
        }
    }

    if (app_args.fmt_str) {
        _parse_string(-2, app_args.fmt_str, app_out_args.fmt_str, env_buf, false, app_args, app_out_args);
    }
    if (cmd_args.fmt_str) {
        _parse_string(-1, cmd_args.fmt_str, cmd_out_args.fmt_str, env_buf, false, cmd_args, cmd_out_args);
    }

    return _CreateProcess(
        app_args.fmt_str ? app_out_args.fmt_str.c_str() : (LPCSTR)NULL,
        app_args.fmt_str ? app_out_args.fmt_str.length() : 0,
        cmd_args.fmt_str ? cmd_out_args.fmt_str.c_str() : (LPCSTR)NULL,
        cmd_args.fmt_str ? cmd_out_args.fmt_str.length() : 0
    );
}
