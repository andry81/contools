#define _CRT_SECURE_NO_WARNINGS
//#define WIN32_LEAN_AND_MEAN // Exclude rarely-used stuff from Windows headers

#include <windows.h>
#include <tchar.h>
#include <stdio.h>
#include <string.h>
#include <memory.h>
#include <io.h>

#include <algorithm>
#include <atomic>

#include "common.hpp"
#include "printf.hpp"

//#ifdef _UNICODE
//#error Unicode is not supported.
//#endif

namespace {
    struct _Flags
    {
        // NOTE: the `tee` applies only to the child process here!
        //
        bool            tee_stdin_file_append;
        bool            tee_stdout_file_append;
        bool            tee_stderr_file_append;
        bool            tee_stdin_file_flush;
        bool            tee_stdout_file_flush;
        bool            tee_stderr_file_flush;
        bool            ret_create_proc;
        bool            ret_win_error;
        bool            ret_child_exit;
        bool            print_win_error_string;
        bool            print_shell_error_string;
        bool            no_print_gen_error_string;
        bool            no_sys_dialog_ui;
        bool            no_wait;                        // has no meaning if a `tee` file is used
        bool            no_window;
        bool            no_expand_env;                  // don't expand `${...}` environment variables
        bool            no_subst_vars;                  // don't substitute `{...}` variables (command line parameters)
        bool            shell_exec_expand_env;
        bool            detach_parent_console;
        bool            use_parent_console;             // has meaning only for ShellExecute, overrides create_child_console
        bool            create_child_console;           // has meaning only for CreateProcess
        bool            eval_backslash_esc;             // evaluate backslash escape characters
        bool            eval_dbl_backslash_esc;         // evaluate double backslash escape characters (`\\`)
        bool            init_com;
        bool            wait_child_start;
    };

    struct _Options
    {
        std::tstring    shell_exec_verb;
        std::tstring    change_current_dir;
        std::tstring    reopen_stdin_as;
        std::tstring    reopen_stdout_as;
        std::tstring    reopen_stderr_as;
        std::tstring    tee_stdin_file;                 // has meaning for disk or pipe handle, does ignore for console input
        std::tstring    tee_stdout_file;
        std::tstring    tee_stderr_file;
        unsigned int    chcp_in;
        unsigned int    chcp_out;
        unsigned int    win_error_langid;
        int             tee_stdin_pipe_buf_size;
        int             tee_stdout_pipe_buf_size;
        int             tee_stderr_pipe_buf_size;
        int             tee_stdin_read_buf_size;
        int             tee_stdout_read_buf_size;
        int             tee_stderr_read_buf_size;
        int             stdin_echo;
        unsigned int    show_as;
    };

    _Flags g_flags                      = {};
    _Options g_options                  = {
        {}, {},
        {}, {}, {},
        {}, {}, {},

        0, 0, 0,

        0, 0, 0, // 0 - to define by system

        // 64K read buffer by default
        65536, 65536, 65536,

        -1, SW_SHOWNORMAL
    };

    FILE * g_stdin_file_handle          = nullptr;
    FILE * g_stdout_file_handle         = nullptr;
    FILE * g_stderr_file_handle         = nullptr;

    FILE * g_tee_stdin_file_handle      = nullptr;
    FILE * g_tee_stdout_file_handle     = nullptr;
    FILE * g_tee_stderr_file_handle     = nullptr;

    HANDLE g_stdin_handle               = INVALID_HANDLE_VALUE;
    HANDLE g_stdout_handle              = INVALID_HANDLE_VALUE;
    HANDLE g_stderr_handle              = INVALID_HANDLE_VALUE;

    bool g_is_stdin_redirected          = false;
    bool g_is_stdout_redirected         = false;
    bool g_is_stderr_redirected         = false;

    HANDLE g_stdin_pipe_read_handle     = INVALID_HANDLE_VALUE;
    HANDLE g_stdin_pipe_write_handle    = INVALID_HANDLE_VALUE;
    HANDLE g_stdout_pipe_read_handle    = INVALID_HANDLE_VALUE;
    HANDLE g_stdout_pipe_write_handle   = INVALID_HANDLE_VALUE;
    HANDLE g_stderr_pipe_read_handle    = INVALID_HANDLE_VALUE;
    HANDLE g_stderr_pipe_write_handle   = INVALID_HANDLE_VALUE;

    HANDLE g_child_process_handle       = INVALID_HANDLE_VALUE;
    DWORD g_child_process_group_id      = -1; // to pass signals into child process

    struct _StreamPipeThreadData
    {
        // TODO
    };

    HANDLE                  g_stream_pipe_thread_handles[3]         = { INVALID_HANDLE_VALUE, INVALID_HANDLE_VALUE, INVALID_HANDLE_VALUE };
    DWORD                   g_stream_pipe_thread_handle_types[3]    = { FILE_TYPE_UNKNOWN, FILE_TYPE_UNKNOWN, FILE_TYPE_UNKNOWN };
    _StreamPipeThreadData   g_stream_pipe_thread_data[3]            = {};
    DWORD                   g_stream_pipe_thread_ids[3]             = {};
    std::atomic_bool        g_stream_pipe_thread_cancel_ios[3]      = { false, false, false };

    inline void _WaitForStreamPipeThreads()
    {
        // CAUTION:
        //  The `WaitForMultipleObjects` can not wait an arrays with `INVALID_HANDLE_VALUE` values.

        HANDLE valid_handles[3];
        size_t num_valid_handles = 0;
        for (int i = 0; i < 3; i++) {
            if (g_stream_pipe_thread_handles[i] && g_stream_pipe_thread_handles[i] != INVALID_HANDLE_VALUE) {
                valid_handles[num_valid_handles] = g_stream_pipe_thread_handles[i];
                num_valid_handles++;
            }
        }

        if (!num_valid_handles) return;

        WaitForMultipleObjects(num_valid_handles, valid_handles, TRUE, INFINITE);
    }

    BOOL WINAPI CtrlHandler(DWORD ctrl_type)
    {
        // CTRL_C_EVENT         = 0
        // CTRL_BREAK_EVENT     = 1
        // CTRL_CLOSE_EVENT     = 2
        // CTRL_LOGOFF_EVENT    = 5
        // CTRL_SHUTDOWN_EVENT  = 6
        if (g_child_process_group_id != -1) {
            GenerateConsoleCtrlEvent(ctrl_type, g_child_process_group_id);
        }

        return TRUE; // ignore
    }

    template <int stream_type>
    DWORD WINAPI _StreamPipeThread(LPVOID lpParam)
    {
        //const _StreamPipeThreadData * stream_pipe_thread_data_ptr = static_cast<_StreamPipeThreadData *>(plParam);

        bool stream_eof = false;

        //DWORD num_bytes_avail = 0;
        DWORD num_bytes_read = 0;
        DWORD num_bytes_write = 0;
        //DWORD num_events_read = 0;
        //DWORD num_events_written = 0;
        DWORD win_error = 0;

        std::vector<std::uint8_t> stdin_byte_buf;
        std::vector<std::uint8_t> stdout_byte_buf;
        std::vector<std::uint8_t> stderr_byte_buf;

        //std::vector<char> stdin_char_buf;
        //std::vector<wchar_t> stdin_wchar_buf;

        // NOTE:
        //  labda to bypass msvc error: `error C2712: Cannot use __try in functions that require object unwinding`
        //
        [&]() { __try {
            switch (stream_type) {
            case 0: // stdin
            {
                switch (g_stream_pipe_thread_handle_types[stream_type]) {
                case FILE_TYPE_DISK:
                case FILE_TYPE_PIPE:
                {
                    stdin_byte_buf.resize(g_options.tee_stdin_read_buf_size);

                    while (!stream_eof) {
                        // in case if child process exit
                        if (WaitForSingleObject(g_child_process_handle, 0) != WAIT_TIMEOUT) {
                            break;
                        }

                        SetLastError(0); // just in case
                        if (!ReadFile(g_stdin_handle, &stdin_byte_buf[0], g_options.tee_stdin_read_buf_size, &num_bytes_read, NULL)) {
                            if (g_stream_pipe_thread_cancel_ios[stream_type]) break;

                            win_error = GetLastError();
                            if (win_error != ERROR_BROKEN_PIPE) {
                                if (!g_flags.no_print_gen_error_string) {
                                    _ftprintf(stderr, _T("error: parent stdin read error: win_error=0x%08X (%d)\n"),
                                        win_error, win_error);
                                }
                                if (g_flags.print_win_error_string && win_error) {
                                    _print_win_error_message(win_error, g_options.win_error_langid);
                                }
                            }

                            stream_eof = true;
                        }

                        if (num_bytes_read) {
                            if (g_tee_stdin_file_handle) {
                                fwrite(&stdin_byte_buf[0], num_bytes_read, 1, g_tee_stdin_file_handle);
                                if (g_stream_pipe_thread_cancel_ios[stream_type]) break;

                                if (g_flags.tee_stdin_file_flush) {
                                    fflush(g_tee_stdin_file_handle);
                                    if (g_stream_pipe_thread_cancel_ios[stream_type]) break;
                                }
                            }

                            if (g_stdin_pipe_write_handle != INVALID_HANDLE_VALUE) {
                                SetLastError(0); // just in case
                                if (!WriteFile(g_stdin_pipe_write_handle, &stdin_byte_buf[0], num_bytes_read, &num_bytes_write, NULL)) {
                                    if (g_stream_pipe_thread_cancel_ios[stream_type]) break;

                                    win_error = GetLastError();
                                    if (win_error) {
                                        if (!g_flags.no_print_gen_error_string) {
                                            _ftprintf(stderr, _T("error: child stdin write error: win_error=0x%08X (%d)\n"),
                                                win_error, win_error);
                                        }
                                        if (g_flags.print_win_error_string && win_error) {
                                            _print_win_error_message(win_error, g_options.win_error_langid);
                                        }
                                    }
                                }
                            }
                        }
                        else {
                            stream_eof = true;
                        }
                    }

                    // explicitly close the child stdin write handle here to trigger the child process reaction
                    if (g_stdin_pipe_write_handle != INVALID_HANDLE_VALUE) {
                        CloseHandle(g_stdin_pipe_write_handle);
                        g_stdin_pipe_write_handle = INVALID_HANDLE_VALUE;
                    }
                } break;

                case FILE_TYPE_CHAR:
                {
                    // CAUTION:
                    //  This branch has no native Win32 implementation portable between Win XP/7/8/10 windows versions.
                    //  The `CreatePseudoConsole` API function is available only after the `Windows 10 October 2018 Update (version 1809) [desktop apps only]`
                    //  The complete implementation which can be provided here can be done through a remote code injection to a child process and is not yet available.
                    //  

//                    if (g_tee_stdin_file_handle) {
//                        const UINT cp_out = GetConsoleOutputCP();
//
//                        CPINFO cp_info{};
//                        if (!GetCPInfo(cp_out, &cp_info)) {
//                            // fallback to module character set
//#ifdef _UNICODE
//                            cp_info.MaxCharSize = 2;
//#else
//                            cp_info.MaxCharSize = 1;
//#endif
//                        }
//
//                        // CAUTION:
//                        //  The `ReadConsoleBuffer` function can fail if the length parameter is too big!
//                        //
//                        const DWORD tee_stdin_read_buf_size = (std::max)(g_options.tee_stdin_read_buf_size, 32767U);
//
//                        stdin_byte_buf.resize(tee_stdin_read_buf_size * sizeof(INPUT_RECORD));
//
//                        if (cp_info.MaxCharSize != 1) {
//                            stdin_wchar_buf.reserve(256);
//                        }
//                        else {
//                            stdin_char_buf.reserve(256);
//                        }
//
//                        INPUT_RECORD tmp_input_record{};
//
//                        while (!stream_eof) {
//                            // in case if child process exit
//                            if (WaitForSingleObject(g_child_process_handle, 0) != WAIT_TIMEOUT) {
//                                break;
//                            }
//
//                            // non blocking read
//                            SetLastError(0); // just in case
//                            if (!PeekConsoleInput(g_stdin_handle, NULL, 0, &num_events_read)) {
//                                win_error = GetLastError();
//                                if (win_error) {
//                                    if (!g_flags.no_print_gen_error_string) {
//                                        _ftprintf(stderr, _T("error: parent stdin console read error: win_error=0x%08X (%d)\n"),
//                                            win_error, win_error);
//                                    }
//                                    if (g_flags.print_win_error_string && win_error) {
//                                        _print_win_error_message(win_error);
//                                    }
//                                }
//                            }
//
//                            if (num_events_read) {
//                                SetLastError(0); // just in case
//                                if (!ReadConsoleInput(g_stdin_handle, (PINPUT_RECORD)&stdin_byte_buf[0], tee_stdin_read_buf_size, &num_events_read)) {
//                                    if (g_stream_pipe_thread_cancel_ios[stream_type]) break;
//
//                                    win_error = GetLastError();
//                                    if (win_error) {
//                                        if (!g_flags.no_print_gen_error_string) {
//                                            _ftprintf(stderr, _T("error: parent stdin console read error: win_error=0x%08X (%d)\n"),
//                                                win_error, win_error);
//                                        }
//                                        if (g_flags.print_win_error_string && win_error) {
//                                            _print_win_error_message(win_error);
//                                        }
//                                    }
//
//                                    stream_eof = true;
//                                }
//
//                                for (size_t i = 0; i < size_t(num_events_read); i++) {
//                                    const INPUT_RECORD & input_record = PINPUT_RECORD(&stdin_byte_buf[0])[i];
//
//                                    if (input_record.EventType == KEY_EVENT) {
//                                        const KEY_EVENT_RECORD & key_event_record = input_record.Event.KeyEvent;
//
//                                        if (key_event_record.bKeyDown) {
//                                            if (key_event_record.wRepeatCount > 0) { // just in case
//                                                if (cp_info.MaxCharSize != 1) {
//                                                    stdin_wchar_buf.resize(size_t(key_event_record.wRepeatCount));
//
//                                                    for (size_t j = 0; j < size_t(key_event_record.wRepeatCount); j++) {
//                                                        stdin_wchar_buf[j] = key_event_record.uChar.UnicodeChar;
//                                                    }
//
//                                                    fwrite(&stdin_wchar_buf[0], sizeof(wchar_t), key_event_record.wRepeatCount, g_tee_stdin_file_handle);
//                                                }
//                                                else {
//                                                    stdin_char_buf.resize(size_t(key_event_record.wRepeatCount));
//
//                                                    for (size_t j = 0; j < size_t(key_event_record.wRepeatCount); j++) {
//                                                        stdin_char_buf[j] = key_event_record.uChar.AsciiChar;
//                                                    }
//
//                                                    fwrite(&stdin_char_buf[0], sizeof(char), key_event_record.wRepeatCount, g_tee_stdin_file_handle);
//                                                }
//
//                                                if (g_stream_pipe_thread_cancel_ios[stream_type]) break;
//
//                                                if (g_flags.tee_stdin_file_flush) {
//                                                    fflush(g_tee_stdin_file_handle);
//                                                    if (g_stream_pipe_thread_cancel_ios[stream_type]) break;
//                                                }
//                                            }
//                                        }
//                                    }
//                                }
//
//                                //SetLastError(0); // just in case
//                                //if (!WriteConsoleInput(g_stdin_child_handle, (PINPUT_RECORD)&stdin_byte_buf[0], num_events_read, &num_events_written)) {
//                                //    if (g_stream_pipe_thread_cancel_ios[stream_type]) break;
//
//                                //    win_error = GetLastError();
//                                //    if (win_error) {
//                                //        if (!g_flags.no_print_gen_error_string) {
//                                //            _ftprintf(stderr, _T("error: child stdin console write error: win_error=0x%08X (%d)\n"),
//                                //                win_error, win_error);
//                                //        }
//                                //        if (g_flags.print_win_error_string && win_error) {
//                                //            _print_win_error_message(win_error);
//                                //        }
//                                //    }
//                                //}
//                            }
//                            else {
//                                Sleep(20); // 20ms input wait
//                            }
//                        }
//                    }
                    break;
                }
                }
            } break;

            case 1: // stdout
            {
                if (g_stdout_pipe_read_handle != INVALID_HANDLE_VALUE) {
                    stdout_byte_buf.resize(g_options.tee_stdout_read_buf_size);

                    while (!stream_eof) {
                        SetLastError(0); // just in case
                        if (!ReadFile(g_stdout_pipe_read_handle, &stdout_byte_buf[0], g_options.tee_stdout_read_buf_size, &num_bytes_read, NULL)) {
                            if (g_stream_pipe_thread_cancel_ios[stream_type]) break;

                            win_error = GetLastError();
                            if (win_error != ERROR_BROKEN_PIPE) {
                                if (!g_flags.no_print_gen_error_string) {
                                    _ftprintf(stderr, _T("error: child stdout read error: win_error=0x%08X (%d)\n"),
                                        win_error, win_error);
                                }
                                if (g_flags.print_win_error_string && win_error) {
                                    _print_win_error_message(win_error, g_options.win_error_langid);
                                }
                            }

                            stream_eof = true;
                        }

                        if (num_bytes_read) {
                            if (g_tee_stdout_file_handle) {
                                fwrite(&stdout_byte_buf[0], num_bytes_read, 1, g_tee_stdout_file_handle);
                                if (g_stream_pipe_thread_cancel_ios[stream_type]) break;

                                if (g_flags.tee_stdout_file_flush) {
                                    fflush(g_tee_stdout_file_handle);
                                    if (g_stream_pipe_thread_cancel_ios[stream_type]) break;
                                }
                            }

                            if (g_stdout_handle != INVALID_HANDLE_VALUE) {
                                SetLastError(0); // just in case
                                if (!WriteFile(g_stdout_handle, &stdout_byte_buf[0], num_bytes_read, &num_bytes_write, NULL)) {
                                    if (g_stream_pipe_thread_cancel_ios[stream_type]) break;

                                    win_error = GetLastError();
                                    if (win_error) {
                                        if (!g_flags.no_print_gen_error_string) {
                                            _ftprintf(stderr, _T("error: parent stdout write error: win_error=0x%08X (%d)\n"),
                                                win_error, win_error);
                                        }
                                        if (g_flags.print_win_error_string && win_error) {
                                            _print_win_error_message(win_error, g_options.win_error_langid);
                                        }
                                    }
                                }
                            }
                        }
                        else {
                            stream_eof = true;
                        }
                    }
                }
                else {
                    // CAUTION:
                    //  This branch has no native Win32 implementation portable between Win XP/7/8/10 windows versions.
                    //  The `CreatePseudoConsole` API function is available only after the `Windows 10 October 2018 Update (version 1809) [desktop apps only]`
                    //  The complete implementation which can be provided here can be done through a remote code injection to a child process and is not yet available.
                    //  
                    ;
                }
            } break;


            case 2: // stderr
            {
                if (g_stderr_pipe_read_handle != INVALID_HANDLE_VALUE) {
                    stderr_byte_buf.resize(g_options.tee_stderr_read_buf_size);

                    while (!stream_eof) {
                        SetLastError(0); // just in case
                        if (!ReadFile(g_stderr_pipe_read_handle, &stderr_byte_buf[0], g_options.tee_stderr_read_buf_size, &num_bytes_read, NULL))
                        {
                            if (g_stream_pipe_thread_cancel_ios[stream_type]) break;

                            win_error = GetLastError();
                            if (win_error != ERROR_BROKEN_PIPE) {
                                if (!g_flags.no_print_gen_error_string) {
                                    _ftprintf(stderr, _T("error: child stderr read error: win_error=0x%08X (%d)\n"),
                                        win_error, win_error);
                                }
                                if (g_flags.print_win_error_string && win_error) {
                                    _print_win_error_message(win_error, g_options.win_error_langid);
                                }
                            }

                            stream_eof = true;
                        }

                        if (num_bytes_read) {
                            if (g_tee_stderr_file_handle) {
                                fwrite(&stderr_byte_buf[0], num_bytes_read, 1, g_tee_stderr_file_handle);
                                if (g_stream_pipe_thread_cancel_ios[stream_type]) break;

                                if (g_flags.tee_stderr_file_flush) {
                                    fflush(g_tee_stderr_file_handle);
                                    if (g_stream_pipe_thread_cancel_ios[stream_type]) break;
                                }
                            }

                            if (g_stderr_handle != INVALID_HANDLE_VALUE) {
                                SetLastError(0); // just in case
                                if (!WriteFile(g_stderr_handle, &stderr_byte_buf[0], num_bytes_read, &num_bytes_write, NULL)) {
                                    if (g_stream_pipe_thread_cancel_ios[stream_type]) break;

                                    win_error = GetLastError();
                                    if (win_error) {
                                        if (!g_flags.no_print_gen_error_string) {
                                            _ftprintf(stderr, _T("error: parent stderr write error: win_error=0x%08X (%d)\n"),
                                                win_error, win_error);
                                        }
                                        if (g_flags.print_win_error_string && win_error) {
                                            _print_win_error_message(win_error, g_options.win_error_langid);
                                        }
                                    }
                                }
                            }
                        }
                        else {
                            stream_eof = true;
                        }
                    }
                }
                else {
                    // CAUTION:
                    //  This branch has no native Win32 implementation portable between Win XP/7/8/10 windows versions.
                    //  The `CreatePseudoConsole` API function is available only after the `Windows 10 October 2018 Update (version 1809) [desktop apps only]`
                    //  The complete implementation which can be provided here can be done through a remote code injection to a child process and is not yet available.
                    //  
                    ;
                }
            } break;
            }
        }
        __finally {
            ;
        } }();

        return 0;
    }

    int _ExecuteProcess(LPCTSTR app, size_t app_len, LPCTSTR cmd, size_t cmd_len, const _Flags & flags, const _Options & options)
    {
#ifdef _DEBUG
        //_tprintf(_T(">%s\n>%s\n---\n"), app ? app : _T(""), cmd ? cmd : _T(""));
#endif

        int ret = err_none;

        if ((!app || !app_len) && (!cmd || !cmd_len)) {
            // just in case
            ret = err_format_empty;
            if (!flags.no_print_gen_error_string) {
                fputs("error: format arguments are empty\n", stderr);
            }
            return ret;
        }

        std::vector<uint8_t> cmd_buf;

        STARTUPINFO si{};
        PROCESS_INFORMATION pi{};

        SECURITY_ATTRIBUTES sa{};
        SECURITY_DESCRIPTOR sd{}; // for pipes

        si.cb = sizeof(si);
        si.dwFlags = STARTF_USESHOWWINDOW;
        si.wShowWindow = g_options.show_as;

        sa.nLength = sizeof(sa);
        sa.bInheritHandle = TRUE;

        if (_is_winnt()) {
            InitializeSecurityDescriptor(&sd, SECURITY_DESCRIPTOR_REVISION);
            SetSecurityDescriptorDacl(&sd, TRUE, NULL, FALSE);
            sa.lpSecurityDescriptor = NULL; // &sd;
        }

        UINT prev_cp_in = 0;
        UINT prev_cp_out = 0;

        DWORD win_error = 0;
        INT shell_error = -1;

        SHELLEXECUTEINFO sei{};
        std::vector<TCHAR> shell_exec_verb;

        // NOTE:
        //  labda to bypass msvc error: `error C2712: Cannot use __try in functions that require object unwinding`
        //
        [&]() { if_break(true) __try {
            if (options.chcp_in) {
                prev_cp_in = GetConsoleCP();
                if (options.chcp_in != prev_cp_in) {
                    SetConsoleCP(options.chcp_in);
                }
            }
            if (options.chcp_out) {
                prev_cp_out = GetConsoleOutputCP();
                if (options.chcp_out != prev_cp_out) {
                    SetConsoleOutputCP(options.chcp_out);
                }
            }

            // std reopen files

            if (!options.reopen_stdin_as.empty()) {
                SetLastError(0); // just in case
                if (!(g_stdin_file_handle = tfreopen(options.reopen_stdin_as.c_str(), _T("r"), stdin))) {
                    if (flags.ret_win_error || flags.print_win_error_string || !flags.no_print_gen_error_string) {
                        win_error = GetLastError();
                    }
                    if (!flags.ret_win_error) {
                        ret = err_win32_error;
                    }
                    else {
                        ret = win_error;
                    }
                    if (!flags.no_print_gen_error_string) {
                        _ftprintf(stderr, _T("error: could not reopen stdin as file: win_error=0x%08X (%d) file=\"%s\"\n"),
                            win_error, win_error, options.reopen_stdout_as.c_str());
                    }
                    if (flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, g_options.win_error_langid);
                    }
                    break;
                }
            }

            if (!options.reopen_stdout_as.empty()) {
                SetLastError(0); // just in case
                if (!(g_stdout_file_handle = tfreopen(options.reopen_stdout_as.c_str(), _T("r"), stdout))) {
                    if (flags.ret_win_error || flags.print_win_error_string || !flags.no_print_gen_error_string) {
                        win_error = GetLastError();
                    }
                    if (!flags.ret_win_error) {
                        ret = err_win32_error;
                    }
                    else {
                        ret = win_error;
                    }
                    if (!flags.no_print_gen_error_string) {
                        _ftprintf(stderr, _T("error: could not reopen stdout as file: win_error=0x%08X (%d) file=\"%s\"\n"),
                            win_error, win_error, options.reopen_stdout_as.c_str());
                    }
                    if (flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, g_options.win_error_langid);
                    }
                    break;
                }
            }

            if (!options.reopen_stderr_as.empty()) {
                SetLastError(0); // just in case
                if (!(g_stderr_file_handle = tfreopen(options.reopen_stderr_as.c_str(), _T("r"), stderr))) {
                    if (flags.ret_win_error || flags.print_win_error_string || !flags.no_print_gen_error_string) {
                        win_error = GetLastError();
                    }
                    if (!flags.ret_win_error) {
                        ret = err_win32_error;
                    }
                    else {
                        ret = win_error;
                    }
                    if (!flags.no_print_gen_error_string) {
                        _ftprintf(stderr, _T("error: could not reopen stderr as file: win_error=0x%08X (%d) file=\"%s\"\n"),
                            win_error, win_error, options.reopen_stderr_as.c_str());
                    }
                    if (flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, g_options.win_error_langid);
                    }
                    break;
                }
            }

            // tee files

            if (!options.tee_stdin_file.empty()) {
                SetLastError(0); // just in case
                g_tee_stdin_file_handle = tfopen(options.tee_stdin_file.c_str(), !flags.tee_stdin_file_append ? _T("wb") : _T("ab"));
                if (!g_tee_stdin_file_handle) {
                    if (flags.ret_win_error || flags.print_win_error_string || !flags.no_print_gen_error_string) {
                        win_error = GetLastError();
                    }
                    if (!flags.ret_win_error) {
                        ret = err_win32_error;
                    }
                    else {
                        ret = win_error;
                    }
                    if (!flags.no_print_gen_error_string) {
                        _ftprintf(stderr, _T("error: could not open stdin tee file: win_error=0x%08X (%d) file=\"%s\"\n"),
                            win_error, win_error, options.tee_stdin_file.c_str());
                    }
                    if (flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, g_options.win_error_langid);
                    }
                    break;
                }
            }

            if (!options.tee_stdout_file.empty()) {
                SetLastError(0); // just in case
                g_tee_stdout_file_handle = tfopen(options.tee_stdout_file.c_str(), !flags.tee_stdout_file_append ? _T("wb") : _T("ab"));
                if (!g_tee_stdout_file_handle) {
                    if (flags.ret_win_error || flags.print_win_error_string || !flags.no_print_gen_error_string) {
                        win_error = GetLastError();
                    }
                    if (!flags.ret_win_error) {
                        ret = err_win32_error;
                    }
                    else {
                        ret = win_error;
                    }
                    if (!flags.no_print_gen_error_string) {
                        _ftprintf(stderr, _T("error: could not open stdout tee file: win_error=0x%08X (%d) file=\"%s\"\n"),
                            win_error, win_error, options.tee_stdout_file.c_str());
                    }
                    if (flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, g_options.win_error_langid);
                    }
                    break;
                }
            }

            if (!options.tee_stderr_file.empty()) {
                SetLastError(0); // just in case
                g_tee_stderr_file_handle = tfopen(options.tee_stderr_file.c_str(), !flags.tee_stderr_file_append ? _T("wb") : _T("ab"));
                if (!g_tee_stderr_file_handle) {
                    if (flags.ret_win_error || flags.print_win_error_string || !flags.no_print_gen_error_string) {
                        win_error = GetLastError();
                    }
                    if (!flags.ret_win_error) {
                        ret = err_win32_error;
                    }
                    else {
                        ret = win_error;
                    }
                    if (!flags.no_print_gen_error_string) {
                        _ftprintf(stderr, _T("error: could not open stderr tee file: win_error=0x%08X (%d) file=\"%s\"\n"),
                            win_error, win_error, options.tee_stderr_file.c_str());
                    }
                    if (flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, g_options.win_error_langid);
                    }
                    break;
                }
            }

            // std handles

            SetLastError(0); // just in case
            g_stdin_handle = GetStdHandle(STD_INPUT_HANDLE);
            if (g_stdin_handle == INVALID_HANDLE_VALUE) {
                if (flags.ret_win_error || flags.print_win_error_string || !flags.no_print_gen_error_string) {
                    win_error = GetLastError();
                }
                if (!flags.ret_win_error) {
                    ret = err_win32_error;
                }
                else {
                    ret = win_error;
                }
                if (!flags.no_print_gen_error_string) {
                    _ftprintf(stderr, _T("error: invalid stdin handle: win_error=0x%08X (%d)\n"),
                        win_error, win_error);
                }
                if (flags.print_win_error_string && win_error) {
                    _print_win_error_message(win_error, g_options.win_error_langid);
                }
                break;
            }

            SetLastError(0); // just in case
            g_stdout_handle = GetStdHandle(STD_OUTPUT_HANDLE);
            if (g_stdout_handle == INVALID_HANDLE_VALUE) {
                if (flags.ret_win_error || flags.print_win_error_string || !flags.no_print_gen_error_string) {
                    win_error = GetLastError();
                }
                if (!flags.ret_win_error) {
                    ret = err_win32_error;
                }
                else {
                    ret = win_error;
                }
                if (!flags.no_print_gen_error_string) {
                    _ftprintf(stderr, _T("error: invalid stdout handle: win_error=0x%08X (%d)\n"),
                        win_error, win_error);
                }
                if (flags.print_win_error_string && win_error) {
                    _print_win_error_message(win_error, g_options.win_error_langid);
                }
                break;
            }

            SetLastError(0); // just in case
            g_stderr_handle = GetStdHandle(STD_ERROR_HANDLE);
            if (g_stderr_handle == INVALID_HANDLE_VALUE) {
                if (flags.ret_win_error || flags.print_win_error_string || !flags.no_print_gen_error_string) {
                    win_error = GetLastError();
                }
                if (!flags.ret_win_error) {
                    ret = err_win32_error;
                }
                else {
                    ret = win_error;
                }
                if (!flags.no_print_gen_error_string) {
                    _ftprintf(stderr, _T("error: invalid stderr handle: win_error=0x%08X (%d)\n"),
                        win_error, win_error);
                }
                if (flags.print_win_error_string && win_error) {
                    _print_win_error_message(win_error, g_options.win_error_langid);
                }
                break;
            }

            // std pipes

            //#define FILE_TYPE_UNKNOWN   0x0000
            //#define FILE_TYPE_DISK      0x0001 // ReadFile
            //#define FILE_TYPE_CHAR      0x0002 // ReadConsoleInput, PeekConsoleInput
            //#define FILE_TYPE_PIPE      0x0003 // ReadFile, PeekNamedPipe
            //#define FILE_TYPE_REMOTE    0x8000
            //
            const DWORD stdin_handle_type = GetFileType(g_stdin_handle);
            const DWORD stdout_handle_type = GetFileType(g_stdout_handle);
            const DWORD stderr_handle_type = GetFileType(g_stderr_handle);

            g_stream_pipe_thread_handle_types[0] = stdin_handle_type;
            g_stream_pipe_thread_handle_types[1] = stdout_handle_type;
            g_stream_pipe_thread_handle_types[2] = stderr_handle_type;

            if (stdin_handle_type == FILE_TYPE_DISK || stdin_handle_type == FILE_TYPE_PIPE) {
                if (!CreatePipe(&g_stdin_pipe_read_handle, &g_stdin_pipe_write_handle, &sa, options.tee_stdin_pipe_buf_size)) {
                    if (flags.ret_win_error || flags.print_win_error_string || !flags.no_print_gen_error_string) {
                        win_error = GetLastError();
                    }
                    if (!flags.ret_win_error) {
                        ret = err_win32_error;
                    }
                    else {
                        ret = win_error;
                    }
                    if (!flags.no_print_gen_error_string) {
                        _ftprintf(stderr, _T("error: could not create stdin pipe: win_error=0x%08X (%d)\n"),
                            win_error, win_error);
                    }
                    if (flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, g_options.win_error_langid);
                    }
                    break;
                }

                // CAUTION:
                //  We must set all handles being passed into the child process as inheritable,
                //  otherwise respective `ReadFile` on the pipe end in the parent process will be blocked!
                //  This is not enough to just pass the handle into the `CreateProcess`.
                //

                SetLastError(0); // just in case
                if (!::SetHandleInformation(g_stdin_pipe_write_handle, HANDLE_FLAG_INHERIT, FALSE)) {
                    if (flags.ret_win_error || flags.print_win_error_string || !flags.no_print_gen_error_string) {
                        win_error = GetLastError();
                    }
                    if (!flags.ret_win_error) {
                        ret = err_win32_error;
                    }
                    else {
                        ret = win_error;
                    }
                    if (!flags.no_print_gen_error_string) {
                        _ftprintf(stderr, _T("error: could not set stdin handle information: win_error=0x%08X (%d) type=%d file=\"%s\"\n"),
                            win_error, win_error, stdin_handle_type, options.reopen_stdin_as.c_str());
                    }
                    if (flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, g_options.win_error_langid);
                    }
                    break;
                }

                if (options.shell_exec_verb.empty()) {
                    si.hStdInput = g_stdin_pipe_read_handle;

                    // CAUTION:
                    //  This flag breaks a child process autocompletion in the call: `callf.exe "" "cmd.exe /k"`
                    //  in case if one of handles is not character handle or console buffer.
                    //
                    si.dwFlags |= STARTF_USESTDHANDLES;
                }
                else {
                    g_is_stdin_redirected = true;
                    SetStdHandle(STD_INPUT_HANDLE, g_stdin_pipe_read_handle);
                }
            }
            else if (stdin_handle_type == FILE_TYPE_CHAR) {
                // NOTE:
                //  The stdin console handle can not be changed for inheritance.
                //

                if (options.stdin_echo != -1) {
                    DWORD stdin_handle_mode = 0;
                    GetConsoleMode(g_stdin_handle, &stdin_handle_mode);
                    if (options.stdin_echo) {
                        SetConsoleMode(g_stdin_handle, stdin_handle_mode | ENABLE_ECHO_INPUT);
                    }
                    else {
                        SetConsoleMode(g_stdin_handle, stdin_handle_mode & ~ENABLE_ECHO_INPUT);
                    }
                }

                if (options.shell_exec_verb.empty()) {
                    // CAUTION:
                    //  Must be the original stdin, can not be a buffer from the CreateConsoleScreenBuffer call,
                    //  otherwise, for example, the `cmd.exe /k` process will exit immediately!
                    //
                    si.hStdInput = g_stdin_handle;

                    // CAUTION:
                    //  This flag breaks a child process autocompletion in the call: `callf.exe "" "cmd.exe /k"`
                    //  in case if one of handles is not character handle or console buffer.
                    //
                    si.dwFlags |= STARTF_USESTDHANDLES;
                }
            }

            if (g_tee_stdout_file_handle != INVALID_HANDLE_VALUE) {
                if (!CreatePipe(&g_stdout_pipe_read_handle, &g_stdout_pipe_write_handle, &sa, options.tee_stdout_pipe_buf_size)) {
                    if (flags.ret_win_error || flags.print_win_error_string || !flags.no_print_gen_error_string) {
                        win_error = GetLastError();
                    }
                    if (!flags.ret_win_error) {
                        ret = err_win32_error;
                    }
                    else {
                        ret = win_error;
                    }
                    if (!flags.no_print_gen_error_string) {
                        _ftprintf(stderr, _T("error: could not create stdout pipe: win_error=0x%08X (%d)\n"),
                            win_error, win_error);
                    }
                    if (flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, g_options.win_error_langid);
                    }
                    break;
                }

                // CAUTION:
                //  We must set all handles being passed into the child process as inheritable,
                //  otherwise respective `ReadFile` on the pipe end in the parent process will be blocked!
                //  This is not enough to just pass the handle into the `CreateProcess`.
                //

                SetLastError(0); // just in case
                if (!::SetHandleInformation(g_stdout_pipe_read_handle, HANDLE_FLAG_INHERIT, FALSE)) {
                    if (flags.ret_win_error || flags.print_win_error_string || !flags.no_print_gen_error_string) {
                        win_error = GetLastError();
                    }
                    if (!flags.ret_win_error) {
                        ret = err_win32_error;
                    }
                    else {
                        ret = win_error;
                    }
                    if (!flags.no_print_gen_error_string) {
                        _ftprintf(stderr, _T("error: could not set stdout pipe handle information: win_error=0x%08X (%d) type=%u file=\"%s\"\n"),
                            win_error, win_error, stdout_handle_type, options.reopen_stdout_as.c_str());
                    }
                    if (flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, g_options.win_error_langid);
                    }
                    break;
                }

                if (options.shell_exec_verb.empty()) {
                    si.hStdOutput = g_stdout_pipe_write_handle;

                    // CAUTION:
                    //  This flag breaks a child process autocompletion in the call: `callf.exe "" "cmd.exe /k"`
                    //  in case if one of handles is not character handle or console buffer.
                    //
                    si.dwFlags |= STARTF_USESTDHANDLES;
                }
                else {
                    g_is_stdout_redirected = true;
                    SetStdHandle(STD_OUTPUT_HANDLE, g_stdout_pipe_write_handle);
                }
            }

            if (g_tee_stderr_file_handle != INVALID_HANDLE_VALUE) {
                if (!CreatePipe(&g_stderr_pipe_read_handle, &g_stderr_pipe_write_handle, &sa, options.tee_stderr_pipe_buf_size)) {
                    if (flags.ret_win_error || flags.print_win_error_string || !flags.no_print_gen_error_string) {
                        win_error = GetLastError();
                    }
                    if (!flags.ret_win_error) {
                        ret = err_win32_error;
                    }
                    else {
                        ret = win_error;
                    }
                    if (!flags.no_print_gen_error_string) {
                        _ftprintf(stderr, _T("error: could not create stderr pipe: win_error=0x%08X (%d)\n"),
                            win_error, win_error);
                    }
                    if (flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, g_options.win_error_langid);
                    }
                    break;
                }

                // CAUTION:
                //  We must set all handles being passed into the child process as inheritable,
                //  otherwise respective `ReadFile` on the pipe end in the parent process will be blocked!
                //  This is not enough to just pass the handle into the `CreateProcess`.
                //

                SetLastError(0); // just in case
                if (!::SetHandleInformation(g_stderr_pipe_read_handle, HANDLE_FLAG_INHERIT, FALSE)) {
                    if (flags.ret_win_error || flags.print_win_error_string || !flags.no_print_gen_error_string) {
                        win_error = GetLastError();
                    }
                    if (!flags.ret_win_error) {
                        ret = err_win32_error;
                    }
                    else {
                        ret = win_error;
                    }
                    if (!flags.no_print_gen_error_string) {
                        _ftprintf(stderr, _T("error: could not set stderr pipe handle information: win_error=0x%08X (%d) type=%u file=\"%s\"\n"),
                            win_error, win_error, stderr_handle_type, options.reopen_stderr_as.c_str());
                    }
                    if (flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, g_options.win_error_langid);
                    }
                    break;
                }

                if (options.shell_exec_verb.empty()) {
                    si.hStdError = g_stderr_pipe_write_handle;

                    // CAUTION:
                    //  This flag breaks a child process autocompletion in the call: `callf.exe "" "cmd.exe /k"`
                    //  in case if one of handles is not character handle or console buffer.
                    //
                    si.dwFlags |= STARTF_USESTDHANDLES;
                }
                else {
                    g_is_stderr_redirected = true;
                    SetStdHandle(STD_ERROR_HANDLE, g_stderr_pipe_write_handle);
                }
            }

            ret = err_none;
            DWORD ret_create_proc = 0;

            if (flags.detach_parent_console) {
                FreeConsole();
            }

            // CAUTION:
            //  DO NOT USE `CREATE_NEW_PROCESS_GROUP` flag in the `CreateProcess`, otherwise a child process would ignore all signals.
            //

            SetConsoleCtrlHandler(CtrlHandler, TRUE);   // update parent console signal handler (does not work as expected)

            if (app && app_len) {
                if (options.shell_exec_verb.empty()) {
                    if (cmd && cmd_len) {
                        // CAUTION:
                        //  cmd argument must be writable!
                        //
                        cmd_buf.resize((std::max)(cmd_len + sizeof(TCHAR), size_t(32768U)));
                        memcpy(&cmd_buf[0], cmd, cmd_buf.size());

                        SetLastError(0); // just in case
                        ret_create_proc = ::CreateProcess(app, (TCHAR *)&cmd_buf[0], NULL, NULL, TRUE,
                            flags.create_child_console ? CREATE_NEW_CONSOLE : 0,
                            NULL,
                            !options.change_current_dir.empty() ? options.change_current_dir.c_str() : NULL,
                            &si, &pi);
                    }
                    else {
                        // CAUTION:
                        //  cmd argument must be writable!
                        //
                        SetLastError(0); // just in case
                        ret_create_proc = ::CreateProcess(app, NULL, NULL, NULL, TRUE,
                            flags.create_child_console ? CREATE_NEW_CONSOLE : 0,
                            NULL,
                            !options.change_current_dir.empty() ? options.change_current_dir.c_str() : NULL,
                            &si, &pi);
                    }
                }
                else {
                    sei.cbSize = sizeof(sei);
                    sei.fMask = SEE_MASK_NOCLOSEPROCESS; // use hProcess
                    if (flags.wait_child_start && !flags.no_wait) {
                        sei.fMask |= SEE_MASK_NOASYNC | SEE_MASK_FLAG_DDEWAIT;
                    }
                    if (flags.shell_exec_expand_env) {
                        sei.fMask |= SEE_MASK_DOENVSUBST;
                    }
                    if (flags.no_sys_dialog_ui) {
                        sei.fMask |= SEE_MASK_FLAG_NO_UI;
                    }
                    if (flags.use_parent_console) {
                        sei.fMask |= SEE_MASK_NO_CONSOLE;
                    }
                    if (flags.no_wait) {
                        sei.fMask |= SEE_MASK_ASYNCOK;
                    }

                    if (!options.shell_exec_verb.empty()) {
                        shell_exec_verb.resize(options.shell_exec_verb.length() + 1);
                        memcpy(&shell_exec_verb[0], options.shell_exec_verb.c_str(), shell_exec_verb.size() * sizeof(shell_exec_verb[0]));
                        sei.lpVerb = &shell_exec_verb[0];
                    }

                    sei.lpFile = app;
                    sei.lpParameters = cmd;
                    sei.lpDirectory = !options.change_current_dir.empty() ? options.change_current_dir.c_str() : NULL;
                    sei.nShow = options.show_as;

                    if (flags.init_com) {
                        CoInitializeEx(NULL, COINIT_APARTMENTTHREADED | COINIT_DISABLE_OLE1DDE);
                    }

                    SetLastError(0); // just in case
                    ret_create_proc = ::ShellExecuteEx(&sei);

                    shell_error = (INT)sei.hInstApp;

                    if (sei.hProcess && sei.hProcess != INVALID_HANDLE_VALUE) {
                        g_child_process_handle = sei.hProcess;
                        g_child_process_group_id = GetProcessId(sei.hProcess);  // to pass parent console signal events into child process
                    }

                    // restore standard handles
                    if (g_is_stdin_redirected) {
                        SetStdHandle(STD_INPUT_HANDLE, g_stdin_handle);
                        g_is_stdin_redirected = false;
                    }

                    if (g_is_stdout_redirected) {
                        SetStdHandle(STD_OUTPUT_HANDLE, g_stdout_handle);
                        g_is_stdout_redirected = false;
                    }

                    if (g_is_stderr_redirected) {
                        SetStdHandle(STD_ERROR_HANDLE, g_stderr_handle);
                        g_is_stderr_redirected = false;
                    }
                }
            }
            else if (cmd && cmd_len) {
                cmd_buf.resize((std::max)(cmd_len + sizeof(TCHAR), size_t(32768U)));
                memcpy(&cmd_buf[0], cmd, cmd_buf.size());


                SetLastError(0); // just in case
                ret_create_proc = ::CreateProcess(NULL, (TCHAR *)&cmd_buf[0], NULL, NULL, TRUE,
                    flags.create_child_console ? CREATE_NEW_CONSOLE : 0,
                    NULL,
                    !options.change_current_dir.empty() ? options.change_current_dir.c_str() : NULL,
                    &si, &pi);
            }

            if (flags.ret_win_error || flags.print_win_error_string || !flags.no_print_gen_error_string) {
                win_error = GetLastError();
            }

            if (pi.hProcess && pi.hProcess != INVALID_HANDLE_VALUE) {
                g_child_process_handle = pi.hProcess;       // to check the process status from stream pipe threads
                g_child_process_group_id = pi.dwProcessId;  // to pass parent console signal events into child process
            }

            if (g_child_process_handle && g_child_process_handle != INVALID_HANDLE_VALUE) {
                // CAUTION:
                //  We must close all handles passed into the child process as inheritable,
                //  otherwise the `ReadFile` in the parent process will be blocked on the pipe
                //  even if the child process is closed.
                //

                //if (g_stdin_handle != INVALID_HANDLE_VALUE && stderr_handle_type == FILE_TYPE_CHAR) {
                //    CloseHandle(g_stdin_handle);
                //    g_stdin_handle = INVALID_HANDLE_VALUE;
                //}

                if (g_stdin_pipe_read_handle != INVALID_HANDLE_VALUE) {
                    CloseHandle(g_stdin_pipe_read_handle);
                    g_stdin_pipe_read_handle = INVALID_HANDLE_VALUE;
                }
                if (g_stdout_pipe_write_handle != INVALID_HANDLE_VALUE) {
                    CloseHandle(g_stdout_pipe_write_handle);
                    g_stdout_pipe_write_handle = INVALID_HANDLE_VALUE;
                }
                if (g_stderr_pipe_write_handle != INVALID_HANDLE_VALUE) {
                    CloseHandle(g_stderr_pipe_write_handle);
                    g_stderr_pipe_write_handle = INVALID_HANDLE_VALUE;
                }
            }

            if (!ret_create_proc || !g_child_process_handle || g_child_process_handle == INVALID_HANDLE_VALUE) {
                if (flags.ret_create_proc) {
                    ret = ret_create_proc;
                }
                else if (flags.ret_win_error) {
                    ret = win_error;
                }
                else {
                    ret = err_win32_error;
                }
                if (!flags.no_print_gen_error_string) {
                    if (options.shell_exec_verb.empty()) {
                        _ftprintf(stderr, _T("error: could not create child process: win_error=0x%08X (%d) app=\"%s\" cmd=\"%s\"\n"),
                            win_error, win_error, app, cmd_buf.size() ? (TCHAR *)&cmd_buf[0] : _T(""));
                    }
                    else {
                        _ftprintf(stderr, _T("error: could not shell execute child process: win_error=0x%08X (%d) shell_error=0x%08X (%d) file=\"%s\" params=\"%s\"\n"),
                            win_error, win_error, shell_error, shell_error, app, cmd);
                    }
                }
                if (flags.print_win_error_string && win_error) {
                    _print_win_error_message(win_error, g_options.win_error_langid);
                }
                if (flags.print_shell_error_string && shell_error != -1 && shell_error <= 32) {
                    _print_shell_exec_error_message(shell_error, sei);
                }
                break;
            }

            if (!flags.ret_create_proc && !flags.ret_win_error) {
                ret = err_none;
            }

            if (g_stdin_handle != INVALID_HANDLE_VALUE &&
                (g_stdin_file_handle != NULL || /*g_tee_stdin_file_handle != INVALID_HANDLE_VALUE ||*/ g_stdin_pipe_write_handle != INVALID_HANDLE_VALUE)) {
                g_stream_pipe_thread_handles[0] = CreateThread(
                    NULL, 0,
                    _StreamPipeThread<0>, &g_stream_pipe_thread_data[0],
                    0,
                    &g_stream_pipe_thread_ids[0]
                );
            }

            if (g_stdout_handle != INVALID_HANDLE_VALUE &&
                (g_stdout_file_handle != NULL || g_stdout_pipe_read_handle != INVALID_HANDLE_VALUE)) {
                g_stream_pipe_thread_handles[1] = CreateThread(
                    NULL, 0,
                    _StreamPipeThread<1>, &g_stream_pipe_thread_data[1],
                    0,
                    &g_stream_pipe_thread_ids[1]
                );
            }

            if (g_stderr_handle != INVALID_HANDLE_VALUE &&
                (g_stderr_file_handle != NULL || g_stderr_pipe_read_handle != INVALID_HANDLE_VALUE)) {
                g_stream_pipe_thread_handles[2] = CreateThread(
                    NULL, 0,
                    _StreamPipeThread<2>, &g_stream_pipe_thread_data[2],
                    0,
                    &g_stream_pipe_thread_ids[2]
                );
            }

            if (g_child_process_handle && g_child_process_handle != INVALID_HANDLE_VALUE &&
                (g_tee_stdin_file_handle != INVALID_HANDLE_VALUE ||
                 g_tee_stdout_file_handle != INVALID_HANDLE_VALUE ||
                 g_tee_stderr_file_handle != INVALID_HANDLE_VALUE ||
                 !flags.no_wait)) {
                WaitForSingleObject(g_child_process_handle, INFINITE);
            }

            //// ensure all threads are closed before threads wait
            //for (int i = 0; i < 3; i++) {
            //    if (g_stream_pipe_thread_handles[i] && g_stream_pipe_thread_handles[i] != INVALID_HANDLE_VALUE) {
            //        g_stream_pipe_thread_cancel_ios[i] = true;
            //        CancelSynchronousIo(g_stream_pipe_thread_handles[i]);
            //    }
            //}

            _WaitForStreamPipeThreads();

            if (!flags.ret_create_proc) {
                if (!flags.no_wait) {
                    if (ret_create_proc && g_child_process_handle) {
                        if (flags.ret_child_exit) {
                            DWORD exit_code = 0;
                            SetLastError(0); // just in case
                            if (GetExitCodeProcess(g_child_process_handle, &exit_code)) {
                                ret = exit_code;
                            }
                            else {
                                win_error = GetLastError();
                                if (!flags.no_print_gen_error_string) {
                                    _ftprintf(stderr, _T("error: could not get child process exit code: win_error=0x%08X (%u)\n"),
                                        win_error, win_error);
                                }
                                if (flags.print_win_error_string && win_error) {
                                    _print_win_error_message(win_error, g_options.win_error_langid);
                                }
                                break;
                            }
                        }
                    }
                }
            }

            if (flags.ret_create_proc) {
                ret = ret_create_proc;
            }
            else if (flags.ret_win_error) {
                ret = win_error;
                if (flags.print_win_error_string && win_error) {
                    _print_win_error_message(win_error, g_options.win_error_langid);
                }
            }
        }
        __finally {
            // close shared resources at first
            if (options.chcp_in && options.chcp_in != prev_cp_in) {
                SetConsoleCP(prev_cp_in);
            }
            if (options.chcp_out && options.chcp_out != prev_cp_out) {
                SetConsoleCP(prev_cp_out);
            }

            //// ensure all threads are closed before file handles close
            //for (int i = 0; i < 3; i++) {
            //    if (g_stream_pipe_thread_handles[i] != INVALID_HANDLE_VALUE) {
            //        g_stream_pipe_thread_cancel_ios[i] = true;
            //        CancelSynchronousIo(g_stream_pipe_thread_handles[i]);
            //    }
            //}

            _WaitForStreamPipeThreads();

            // not shared resources
            if (g_tee_stdin_file_handle) {
                fclose(g_tee_stdin_file_handle);
                g_tee_stdin_file_handle = NULL; // just in case
            }
            if (g_tee_stdout_file_handle) {
                fclose(g_tee_stdout_file_handle);
                g_tee_stdout_file_handle = NULL; // just in case
            }
            if (g_tee_stderr_file_handle) {
                fclose(g_tee_stderr_file_handle);
                g_tee_stderr_file_handle = NULL; // just in case
            }

            if (g_stdin_file_handle) {
                fclose(g_stdin_file_handle);
                g_stdin_file_handle = NULL; // just in case
            }
            if (g_stdout_file_handle) {
                fclose(g_stdout_file_handle);
                g_stdout_file_handle = NULL; // just in case
            }
            if (g_stderr_file_handle) {
                fclose(g_stderr_file_handle);
                g_stderr_file_handle = NULL; // just in case
            }

            // restore standard handles (again)
            if (g_is_stdin_redirected) {
                SetStdHandle(STD_INPUT_HANDLE, g_stdin_handle);
                g_is_stdin_redirected = false;
            }

            if (g_is_stdout_redirected) {
                SetStdHandle(STD_OUTPUT_HANDLE, g_stdout_handle);
                g_is_stdout_redirected = false;
            }

            if (g_is_stderr_redirected) {
                SetStdHandle(STD_ERROR_HANDLE, g_stderr_handle);
                g_is_stderr_redirected = false;
            }

            // close pipe handles
            if (g_stdin_pipe_read_handle != INVALID_HANDLE_VALUE) {
                CloseHandle(g_stdin_pipe_read_handle);
                g_stdin_pipe_read_handle = NULL; // just in case
            }
            if (g_stdin_pipe_write_handle != INVALID_HANDLE_VALUE) {
                CloseHandle(g_stdin_pipe_write_handle);
                g_stdin_pipe_write_handle = NULL; // just in case
            }
            if (g_stdout_pipe_read_handle != INVALID_HANDLE_VALUE) {
                CloseHandle(g_stdout_pipe_read_handle);
                g_stdout_pipe_read_handle = NULL; // just in case
            }
            if (g_stdout_pipe_write_handle != INVALID_HANDLE_VALUE) {
                CloseHandle(g_stdout_pipe_write_handle);
                g_stdout_pipe_write_handle = NULL; // just in case
            }
            if (g_stderr_pipe_read_handle != INVALID_HANDLE_VALUE) {
                CloseHandle(g_stderr_pipe_read_handle);
                g_stderr_pipe_read_handle = NULL; // just in case
            }
            if (g_stderr_pipe_write_handle != INVALID_HANDLE_VALUE) {
                CloseHandle(g_stderr_pipe_write_handle);
                g_stderr_pipe_write_handle = NULL; // just in case
            }

            // must close
            if (g_child_process_handle && g_child_process_handle != INVALID_HANDLE_VALUE) {
                CloseHandle(g_child_process_handle);
                pi.hProcess = g_child_process_handle = INVALID_HANDLE_VALUE; // just in case
            }
            if (pi.hThread && pi.hThread != INVALID_HANDLE_VALUE) {
                CloseHandle(pi.hThread);
                pi.hThread = INVALID_HANDLE_VALUE; // just in case
            }
        } }();

        return ret;
    }
}

int _tmain(int argc, const TCHAR * argv[])
{
    //MessageBoxA(NULL, "", "", MB_OK);

    if (!argc || !argv[0]) {
        return err_unspecified;
    }

    const TCHAR * arg;
    int arg_offset = 1;

    if(argc >= arg_offset + 1 && argv[arg_offset] && !tstrcmp(argv[arg_offset], _T("/?"))) {
        if (argc >= arg_offset + 2) return err_invalid_format;

        ::puts(
#include "help_inl.hpp"
        );

        return err_help_output;
    }

    // read flags
    while (argc >= arg_offset + 1)
    {
        arg = argv[arg_offset];
        if (!arg) {
            if (!g_flags.no_print_gen_error_string) {
                fputs("error: flag is invalid\n", stderr);
            }
            return err_invalid_format;
        }

        if (tstrncmp(arg, _T("/"), 1)) {
            break;
        }

        if (!tstrncmp(arg, _T("//"), 2)) {
            arg_offset += 1;
            break;
        }

        if (!tstrcmp(arg, _T("/chcp-in"))) {
            arg_offset += 1;
            if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                g_options.chcp_in = _ttoi(arg);
            }
            else {
                if (!g_flags.no_print_gen_error_string) {
                    _ftprintf(stderr, _T("error: flag format is invalid: \"%s\"\n"), arg);
                }
                return err_invalid_format;
            }
        }
        else if (!tstrcmp(arg, _T("/chcp-out"))) {
            arg_offset += 1;
            if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                g_options.chcp_out = _ttoi(arg);
            }
            else {
                if (!g_flags.no_print_gen_error_string) {
                    _ftprintf(stderr, _T("error: flag format is invalid: \"%s\"\n"), arg);
                }
                return err_invalid_format;
            }
        }
        else if (!tstrcmp(arg, _T("/ret-create-proc"))) {
            g_flags.ret_create_proc = true;
        }
        else if (!tstrcmp(arg, _T("/ret-win-error"))) {
            g_flags.ret_win_error= true;
        }
        else if (!tstrcmp(arg, _T("/win-error-langid"))) {
            arg_offset += 1;
            if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                g_options.win_error_langid = _ttoi(arg);
            }
            else {
                if (!g_flags.no_print_gen_error_string) {
                    _ftprintf(stderr, _T("error: flag format is invalid: \"%s\"\n"), arg);
                }
                return err_invalid_format;
            }
        }
        else if (!tstrcmp(arg, _T("/ret-child-exit"))) {
            g_flags.ret_child_exit = true;
        }
        else if (!tstrcmp(arg, _T("/print-win-error-string"))) {
            g_flags.print_win_error_string = true;
        }
        else if (!tstrcmp(arg, _T("/print-shell-error-string"))) {
            g_flags.print_shell_error_string = true;
        }
        else if (!tstrcmp(arg, _T("/no-print-gen-error-string"))) {
            g_flags.no_print_gen_error_string = true;
        }
        else if (!tstrcmp(arg, _T("/no-sys-dialog-ui"))) {
            g_flags.no_sys_dialog_ui = true;
        }
        else if (!tstrcmp(arg, _T("/shell-exec"))) {
            arg_offset += 1;
            if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                g_options.shell_exec_verb = arg;
            }
            else {
                if (!g_flags.no_print_gen_error_string) {
                    _ftprintf(stderr, _T("error: flag format is invalid: \"%s\"\n"), arg);
                }
                return err_invalid_format;
            }
        }
        else if (!tstrcmp(arg, _T("/D"))) {
            arg_offset += 1;
            if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                g_options.change_current_dir = arg;
            }
            else {
                if (!g_flags.no_print_gen_error_string) {
                    _ftprintf(stderr, _T("error: flag format is invalid: \"%s\"\n"), arg);
                }
                return err_invalid_format;
            }
        }
        else if (!tstrcmp(arg, _T("/no-wait"))) {
            g_flags.no_wait = true;
        }
        else if (!tstrcmp(arg, _T("/no-window"))) {
            g_flags.no_window = true;
        }
        else if (!tstrcmp(arg, _T("/no-expand-env"))) {
            g_flags.no_expand_env = true;
        }
        else if (!tstrcmp(arg, _T("/no-subst-vars"))) {
            g_flags.no_subst_vars = true;
        }
        else if (!tstrcmp(arg, _T("/shell-exec-expand-env"))) {
            g_flags.shell_exec_expand_env = true;
        }
        else if (!tstrcmp(arg, _T("/init-com"))) {
            g_flags.init_com = true;
        }
        else if (!tstrcmp(arg, _T("/wait-child-start"))) {
            g_flags.wait_child_start = true;
        }
        else if (!tstrcmp(arg, _T("/showas"))) {
            arg_offset += 1;
            if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                const int showas_value = _ttoi(arg);
                if (showas_value > 0) {
                    g_options.show_as = showas_value;
                }
            }
            else {
                if (!g_flags.no_print_gen_error_string) {
                    _ftprintf(stderr, _T("error: flag format is invalid: \"%s\"\n"), arg);
                }
                return err_invalid_format;
            }
        }
        else if (!tstrcmp(arg, _T("/detach-parent-console"))) {
            g_flags.detach_parent_console = true;
        }
        else if (!tstrcmp(arg, _T("/use-parent-console"))) {
            g_flags.use_parent_console = true;
        }
        else if (!tstrcmp(arg, _T("/create-child-console"))) {
            g_flags.create_child_console = true;
        }
        else if (!tstrcmp(arg, _T("/reopen-stdin-as"))) {
            arg_offset += 1;
            if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                g_options.reopen_stdin_as = arg;
            }
            else {
                if (!g_flags.no_print_gen_error_string) {
                    _ftprintf(stderr, _T("error: flag format is invalid: \"%s\"\n"), arg);
                }
                return err_invalid_format;
            }
        }
        else if (!tstrcmp(arg, _T("/reopen-stdout-as"))) {
            arg_offset += 1;
            if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                g_options.reopen_stdout_as = arg;
            }
            else {
                if (!g_flags.no_print_gen_error_string) {
                    _ftprintf(stderr, _T("error: flag format is invalid: \"%s\"\n"), arg);
                }
                return err_invalid_format;
            }
        }
        else if (!tstrcmp(arg, _T("/reopen-stderr-as"))) {
            arg_offset += 1;
            if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                g_options.reopen_stderr_as = arg;
            }
            else {
                if (!g_flags.no_print_gen_error_string) {
                    _ftprintf(stderr, _T("error: flag format is invalid: \"%s\"\n"), arg);
                }
                return err_invalid_format;
            }
        }
        else if(!tstrcmp(arg, _T("/tee-stdin"))) {
            arg_offset += 1;
            if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                g_options.tee_stdin_file = arg;
            }
            else {
                if (!g_flags.no_print_gen_error_string) {
                    _ftprintf(stderr, _T("error: flag format is invalid: \"%s\"\n"), arg);
                }
                return err_invalid_format;
            }
        }
        else if (!tstrcmp(arg, _T("/tee-stdout"))) {
            arg_offset += 1;
            if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                g_options.tee_stdout_file = arg;
            }
            else {
                if (!g_flags.no_print_gen_error_string) {
                    _ftprintf(stderr, _T("error: flag format is invalid: \"%s\"\n"), arg);
                }
                return err_invalid_format;
            }
        }
        else if (!tstrcmp(arg, _T("/tee-stderr"))) {
            arg_offset += 1;
            if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                g_options.tee_stderr_file = arg;
            }
            else {
                if (!g_flags.no_print_gen_error_string) {
                    _ftprintf(stderr, _T("error: flag format is invalid: \"%s\"\n"), arg);
                }
                return err_invalid_format;
            }
        }
        else if (!tstrcmp(arg, _T("/tee-stdin-append"))) {
            g_flags.tee_stdin_file_append = true;
        }
        else if (!tstrcmp(arg, _T("/tee-stdout-append"))) {
            g_flags.tee_stdout_file_append = true;
        }
        else if (!tstrcmp(arg, _T("/tee-stderr-append"))) {
            g_flags.tee_stderr_file_append = true;
        }
        else if (!tstrcmp(arg, _T("/tee-stdin-flush"))) {
            g_flags.tee_stdin_file_flush = true;
        }
        else if (!tstrcmp(arg, _T("/tee-stdout-flush"))) {
            g_flags.tee_stdout_file_flush = true;
        }
        else if (!tstrcmp(arg, _T("/tee-stderr-flush"))) {
            g_flags.tee_stderr_file_flush = true;
        }
        else if (!tstrcmp(arg, _T("/tee-stdin-pipe-buf-size"))) {
            arg_offset += 1;
            if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                const int buf_size = _ttoi(arg);
                if (buf_size > 0) {
                    g_options.tee_stdin_pipe_buf_size = buf_size;
                }
            }
            else {
                if (!g_flags.no_print_gen_error_string) {
                    _ftprintf(stderr, _T("error: flag format is invalid: \"%s\"\n"), arg);
                }
                return err_invalid_format;
            }
        }
        else if (!tstrcmp(arg, _T("/tee-stdout-pipe-buf-size"))) {
            arg_offset += 1;
            if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                const int buf_size = _ttoi(arg);
                if (buf_size > 0) {
                    g_options.tee_stdout_pipe_buf_size = buf_size;
                }
            }
            else {
                if (!g_flags.no_print_gen_error_string) {
                    _ftprintf(stderr, _T("error: flag format is invalid: \"%s\"\n"), arg);
                }
                return err_invalid_format;
            }
        }
        else if (!tstrcmp(arg, _T("/tee-stderr-pipe-buf-size"))) {
            arg_offset += 1;
            if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                const int buf_size = _ttoi(arg);
                if (buf_size > 0) {
                    g_options.tee_stderr_pipe_buf_size = buf_size;
                }
            }
            else {
                if (!g_flags.no_print_gen_error_string) {
                    _ftprintf(stderr, _T("error: flag format is invalid: \"%s\"\n"), arg);
                }
                return err_invalid_format;
            }
        }
        else if (!tstrcmp(arg, _T("/tee-stdin-read-buf-size"))) {
            arg_offset += 1;
            if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                const int buf_size = _ttoi(arg);
                if (buf_size > 0) {
                    g_options.tee_stdin_read_buf_size = buf_size;
                }
            }
            else {
                if (!g_flags.no_print_gen_error_string) {
                    _ftprintf(stderr, _T("error: flag format is invalid: \"%s\"\n"), arg);
                }
                return err_invalid_format;
            }
        }
        else if (!tstrcmp(arg, _T("/tee-stdout-read-buf-size"))) {
            arg_offset += 1;
            if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                const int buf_size = _ttoi(arg);
                if (buf_size > 0) {
                    g_options.tee_stdout_read_buf_size = buf_size;
                }
            }
            else {
                if (!g_flags.no_print_gen_error_string) {
                    _ftprintf(stderr, _T("error: flag format is invalid: \"%s\"\n"), arg);
                }
                return err_invalid_format;
            }
        }
        else if (!tstrcmp(arg, _T("/tee-stderr-read-buf-size"))) {
            arg_offset += 1;
            if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                const int buf_size = _ttoi(arg);
                if (buf_size > 0) {
                    g_options.tee_stderr_read_buf_size = buf_size;
                }
            }
            else {
                if (!g_flags.no_print_gen_error_string) {
                    _ftprintf(stderr, _T("error: flag format is invalid: \"%s\"\n"), arg);
                }
                return err_invalid_format;
            }
        }
        else if (!tstrcmp(arg, _T("/stdin-echo"))) {
            arg_offset += 1;
            if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                const int stdin_echo = _ttoi(arg);
                if (stdin_echo >= 0) {
                    g_options.stdin_echo = stdin_echo;
                }
            }
            else {
                if (!g_flags.no_print_gen_error_string) {
                    _ftprintf(stderr, _T("error: flag format is invalid: \"%s\"\n"), arg);
                }
                return err_invalid_format;
            }
        }
        else if (!tstrcmp(arg, _T("/eval-backslash-esc")) || !tstrcmp(arg, _T("/e"))) {
            g_flags.eval_backslash_esc = true;
        }
        else if (!tstrcmp(arg, _T("/eval-dbl-backslash-esc")) || !tstrcmp(arg, _T("/e\\\\"))) {
            g_flags.eval_dbl_backslash_esc = true;
        }
        else {
            if (!g_flags.no_print_gen_error_string) {
                _ftprintf(stderr, _T("error: flag is not known: \"%s\"\n"), arg);
            }
            return err_invalid_format;
        }

        arg_offset += 1;
    }

    if (g_flags.no_window) {
        g_options.show_as = SW_HIDE;
    }

    // environment variable buffer
    TCHAR env_buf[MAX_ENV_BUF_SIZE];

    // <ApplicationNameFormatString> or <FilePathFormatString>
    InArgs app_args = InArgs();
    OutArgs app_out_args = OutArgs();

    // <CommandLineFormatString> or <ParametersFormatString>
    //
    // CAUTION:
    //  In case of ShellExecute the <ParametersFormatString> must contain only a command line arguments,
    //  but not the path to the executable itself which is part of <CommandLineFormatString>!
    //
    InArgs cmd_args = InArgs();
    OutArgs cmd_out_args = OutArgs();

    if (argc >= arg_offset + 1 && (arg = argv[arg_offset]) && tstrlen(arg)) {
        app_args.fmt_str = arg;
        if (!tstrcmp(app_args.fmt_str , _T(""))) {
            app_args.fmt_str = nullptr;
        }
    }

    arg_offset += 1;

    if (argc >= arg_offset + 1 && (arg = argv[arg_offset]) && tstrlen(arg)) {
        cmd_args.fmt_str = arg;
        if (!tstrcmp(cmd_args.fmt_str, _T(""))) {
            cmd_args.fmt_str = nullptr;
        }
    }

    arg_offset += 1;

    if (g_options.shell_exec_verb.empty()) {
        if (!app_args.fmt_str && !cmd_args.fmt_str) {
            if (!g_flags.no_print_gen_error_string) {
                fputs("error: format arguments are empty\n", stderr);
            }
            if (!g_flags.ret_win_error) {
                return err_format_empty;
            }
            else {
                return GetLastError();
            }
        }
    }
    else {
        if (!app_args.fmt_str) {
            if (!g_flags.no_print_gen_error_string) {
                fputs("error: file path format argument is empty\n", stderr);
            }
            if (!g_flags.ret_win_error) {
                return err_format_empty;
            }
            else {
                return GetLastError();
            }
        }
    }

    // read and parse tail arguments
    if (argc >= arg_offset + 1 && app_args.fmt_str) {
        const int num_args = argc - arg_offset;

        app_args.args.resize(num_args);
        app_out_args.args.resize(num_args);

        for (int i = 0; i < num_args; i++) {
            app_args.args[i] = argv[arg_offset + i];
        }
        // double pass to expand ${...} variables before {...} variables
        if (!g_flags.no_expand_env && !g_flags.no_subst_vars) {
            std::tstring tmp;

            for (int i = 0; i < num_args; i++) {
                if (tstrcmp(app_args.args[i], _T(""))) {
                    _parse_string(i, app_args.args[i], app_out_args.args[i], env_buf,
                        false, true, true, app_args, app_out_args);
                }
                else {
                    app_args.args[i] = nullptr;
                }
            }
            for (int i = 0; i < num_args; i++) {
                tmp.clear();
                _parse_string(i, app_out_args.args[i].c_str(), tmp, env_buf,
                    true, false, false, InArgs{}, app_out_args);
                app_out_args.args[i] = std::move(tmp);
            }
        }
        else {
            for (int i = 0; i < num_args; i++) {
                if (tstrcmp(app_args.args[i], _T(""))) {
                    _parse_string(i, app_args.args[i], app_out_args.args[i], env_buf,
                        g_flags.no_expand_env, g_flags.no_subst_vars, true, app_args, app_out_args);
                }
                else {
                    app_args.args[i] = nullptr;
                }
            }
        }
    }

    if (argc >= arg_offset + 1 && cmd_args.fmt_str) {
        const int num_args = argc - arg_offset;

        cmd_args.args.resize(num_args);
        cmd_out_args.args.resize(num_args);

        for (int i = 0; i < num_args; i++) {
            cmd_args.args[i] = argv[arg_offset + i];
        }
        // double pass to expand ${...} variables before {...} variables
        if (!g_flags.no_expand_env && !g_flags.no_subst_vars) {
            std::tstring tmp;

            for (int i = 0; i < num_args; i++) {
                if (tstrcmp(cmd_args.args[i], _T(""))) {
                    _parse_string(i, cmd_args.args[i], cmd_out_args.args[i], env_buf,
                        false, true, true, cmd_args, cmd_out_args);
                }
                else {
                    cmd_args.args[i] = nullptr;
                }
            }
            for (int i = 0; i < num_args; i++) {
                tmp.clear();
                _parse_string(i, cmd_out_args.args[i].c_str(), tmp, env_buf,
                    true, false, false, InArgs{}, cmd_out_args);
                cmd_out_args.args[i] = std::move(tmp);
            }
        }
        else {
            for (int i = 0; i < num_args; i++) {
                if (tstrcmp(cmd_args.args[i], _T(""))) {
                    _parse_string(i, cmd_args.args[i], cmd_out_args.args[i], env_buf,
                        g_flags.no_expand_env, g_flags.no_subst_vars, true, cmd_args, cmd_out_args);
                }
                else {
                    cmd_args.args[i] = nullptr;
                }
            }
        }
    }

    if (app_args.fmt_str) {
        _parse_string(-2, app_args.fmt_str, app_out_args.fmt_str, env_buf,
            g_flags.no_expand_env, g_flags.no_subst_vars, false, app_args, app_out_args);
    }
    if (cmd_args.fmt_str) {
        _parse_string(-1, cmd_args.fmt_str, cmd_out_args.fmt_str, env_buf,
            g_flags.no_expand_env, g_flags.no_subst_vars, false, cmd_args, cmd_out_args);
    }

    if (g_flags.eval_backslash_esc || g_flags.eval_dbl_backslash_esc) {
        if (app_args.fmt_str) {
            app_out_args.fmt_str = _eval_escape_chars(app_out_args.fmt_str, g_flags.eval_backslash_esc, g_flags.eval_dbl_backslash_esc);
        }
        if (cmd_args.fmt_str) {
            cmd_out_args.fmt_str = _eval_escape_chars(cmd_out_args.fmt_str, g_flags.eval_backslash_esc, g_flags.eval_dbl_backslash_esc);
        }
    }

    return _ExecuteProcess(
        app_args.fmt_str ? app_out_args.fmt_str.c_str() : (LPCTSTR)NULL,
        app_args.fmt_str ? app_out_args.fmt_str.length() : 0,
        cmd_args.fmt_str ? cmd_out_args.fmt_str.c_str() : (LPCTSTR)NULL,
        cmd_args.fmt_str ? cmd_out_args.fmt_str.length() : 0,
        g_flags, g_options
    );
}
