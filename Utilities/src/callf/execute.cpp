#include "execute.hpp"

Flags g_flags                       = {};
Options g_options                   = {};

DWORD g_parent_proc_id              = -1;
HWND  g_current_proc_console_window = NULL;
HWND  g_parent_proc_console_window  = NULL;

HANDLE g_stdin_handle               = INVALID_HANDLE_VALUE;
HANDLE g_stdout_handle              = INVALID_HANDLE_VALUE;
HANDLE g_stderr_handle              = INVALID_HANDLE_VALUE;

DWORD g_stdin_handle_type           = FILE_TYPE_UNKNOWN;
DWORD g_stdout_handle_type          = FILE_TYPE_UNKNOWN;
DWORD g_stderr_handle_type          = FILE_TYPE_UNKNOWN;

HANDLE g_reopen_stdin_handle        = INVALID_HANDLE_VALUE;
HANDLE g_reopen_stdout_handle       = INVALID_HANDLE_VALUE;
HANDLE g_reopen_stderr_handle       = INVALID_HANDLE_VALUE;

HANDLE g_reopen_stdout_mutex        = INVALID_HANDLE_VALUE;
HANDLE g_reopen_stderr_mutex        = INVALID_HANDLE_VALUE;

std::tstring g_reopen_stdout_full_name = {};
std::tstring g_reopen_stderr_full_name = {};

// specialized tee file handles
HANDLE g_tee_file_stdin_handle      = INVALID_HANDLE_VALUE;
HANDLE g_tee_file_stdout_handle     = INVALID_HANDLE_VALUE;
HANDLE g_tee_file_stderr_handle     = INVALID_HANDLE_VALUE;

HANDLE g_tee_file_stdin_mutex       = INVALID_HANDLE_VALUE;
HANDLE g_tee_file_stdout_mutex      = INVALID_HANDLE_VALUE;
HANDLE g_tee_file_stderr_mutex      = INVALID_HANDLE_VALUE;

std::tstring g_tee_file_stdin_full_name = {};
std::tstring g_tee_file_stdout_full_name = {};
std::tstring g_tee_file_stderr_full_name = {};

// specialized tee named pipe handles
HANDLE g_tee_named_pipe_stdin_handle = INVALID_HANDLE_VALUE;
HANDLE g_tee_named_pipe_stdout_handle = INVALID_HANDLE_VALUE;
HANDLE g_tee_named_pipe_stderr_handle = INVALID_HANDLE_VALUE;

bool g_is_stdin_redirected          = false;
bool g_is_stdout_redirected         = false;
bool g_is_stderr_redirected         = false;

bool g_no_std_inherit               = false;
bool g_pipe_stdin_to_stdout         = false;

std::atomic_bool g_ctrl_handler     = false;

HANDLE g_stdin_pipe_read_handle     = INVALID_HANDLE_VALUE;
HANDLE g_stdin_pipe_write_handle    = INVALID_HANDLE_VALUE;
HANDLE g_stdout_pipe_read_handle    = INVALID_HANDLE_VALUE;
HANDLE g_stdout_pipe_write_handle   = INVALID_HANDLE_VALUE;
HANDLE g_stderr_pipe_read_handle    = INVALID_HANDLE_VALUE;
HANDLE g_stderr_pipe_write_handle   = INVALID_HANDLE_VALUE;

HANDLE g_child_process_handle       = INVALID_HANDLE_VALUE;
DWORD g_child_process_group_id      = -1; // to pass signals into child process

StreamPipeThreadLocals g_stream_pipe_thread_locals[3];
StreamPipeThreadLocals g_stdin_to_stdout_thread_locals;
ConnectNamedPipeThreadLocals g_connect_server_named_pipe_thread_locals[2][3]; // <int handle_type, int co_stream_type>
ConnectNamedPipeThreadLocals g_connect_client_named_pipe_thread_locals[2][3]; // <int handle_type, int co_stream_type>

WorkerThreadsReturnData g_worker_threads_return_data;


BOOL WINAPI ChildCtrlHandler(DWORD ctrl_type)
{
    if (g_ctrl_handler) {
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

    return FALSE;
}

template <int stream_type>
DWORD WINAPI StreamPipeThread(LPVOID lpParam)
{
    StreamPipeThreadData & thread_data = *static_cast<StreamPipeThreadData *>(lpParam);

    thread_data.ret = err_unspecified;

    bool stream_eof = false;

    DWORD num_bytes_avail = 0;
    DWORD num_bytes_read = 0;
    DWORD num_bytes_write = 0;
    DWORD num_bytes_written = 0;
    //DWORD num_events_read = 0;
    //DWORD num_events_written = 0;
    DWORD win_error = 0;

    std::vector<std::uint8_t> stdin_byte_buf;
    std::vector<std::uint8_t> stdout_byte_buf;
    std::vector<std::uint8_t> stderr_byte_buf;

    //std::vector<char> stdin_char_buf;
    //std::vector<wchar_t> stdin_wchar_buf;

    bool break_ = false;

    // NOTE:
    //  labda to bypass msvc error: `error C2712: Cannot use __try in functions that require object unwinding`
    //
    [&]() { __try {
        [&]() {
            switch (stream_type) {
            case 0: // stdin
            {
                // Accomplish all server pipe connections before continue.
                //

                {
                    auto & connect_server_named_pipe_thread_local = g_connect_server_named_pipe_thread_locals[0][stream_type];

                    WaitForConnectNamedPipeThreads(connect_server_named_pipe_thread_local, false);

                    // check errors
                    utility::for_each_unroll(make_singular_array(connect_server_named_pipe_thread_local), [&](auto & local) {
                        if (!local.thread_data.is_copied && !local.thread_data.msg.empty()) {
                            g_worker_threads_return_data.add(local.thread_data);
                            local.thread_data.is_copied = true;
                        }
                        if (!break_ && local.thread_data.is_error) {
                            break_ = true;
                        }
                    });
                }

                {
                    auto & connect_server_named_pipe_thread_local = g_connect_server_named_pipe_thread_locals[1][stream_type];

                    WaitForConnectNamedPipeThreads(connect_server_named_pipe_thread_local, false);

                    // check errors
                    utility::for_each_unroll(make_singular_array(connect_server_named_pipe_thread_local), [&](auto & local) {
                        if (!local.thread_data.is_copied && !local.thread_data.msg.empty()) {
                            g_worker_threads_return_data.add(local.thread_data);
                            local.thread_data.is_copied = true;
                        }
                        if (!break_ && local.thread_data.is_error) {
                            break_ = true;
                        }
                    });
                }

                if (break_) break;

                // WORKAROUND:
                //  Synchronous ReadFile function has an issue, where it stays locked on pipe input while the output handle already closed or broken (pipe)!
                //  To fix that, we have to use PeekNamedPipe+ReadFile with the output handle test for write (WriteFile with 0 bytes) instead of
                //  single ReadFile w/o the output handle write test.
                //

                switch (g_stdin_handle_type) {
                case FILE_TYPE_DISK:
                {
                    stdin_byte_buf.resize(g_options.tee_stdin_read_buf_size);

                    while (!stream_eof) {
                        // in case if the child process is exited
                        if (WaitForSingleObject(g_child_process_handle, 0) != WAIT_TIMEOUT) {
                            break;
                        }

                        SetLastError(0); // just in case
                        if (!ReadFile(g_stdin_handle, stdin_byte_buf.data(), g_options.tee_stdin_read_buf_size, &num_bytes_read, NULL)) {
                            if (thread_data.cancel_io) break;

                            win_error = GetLastError();
                            if (win_error != ERROR_BROKEN_PIPE && win_error != ERROR_PIPE_NOT_CONNECTED) {
                                thread_data.ret = err_io_error;
                                thread_data.win_error = win_error;
                                if (!g_flags.no_print_gen_error_string) {
                                    thread_data.msg =
                                        _format_stderr_message(_T("stdin read error: win_error=0x%08X (%d)\n"),
                                            win_error, win_error);
                                }
                                if (g_flags.print_win_error_string && win_error) {
                                    thread_data.msg +=
                                        _format_win_error_message(win_error, g_options.win_error_langid);
                                }
                                thread_data.is_error = true;
                            }

                            stream_eof = true;
                        }

                        if (num_bytes_read) {
                            if (_is_valid_handle(g_tee_file_stdin_handle)) {
                                [&]() { if_break(true) __try {
                                    if (_is_valid_handle(g_tee_file_stdin_mutex)) {
                                        WaitForSingleObject(g_tee_file_stdin_mutex, INFINITE);
                                    }

                                    SetFilePointer(g_tee_file_stdin_handle, 0, NULL, FILE_END);

                                    WriteFile(g_tee_file_stdin_handle, stdin_byte_buf.data(), num_bytes_read, &num_bytes_written, NULL);
                                    if (thread_data.cancel_io) break;

                                    if (g_flags.tee_stdin_file_flush || g_flags.tee_stdin_flush || g_flags.tee_inout_flush) {
                                        FlushFileBuffers(g_tee_file_stdin_handle);
                                        if (thread_data.cancel_io) break;
                                    }
                                }
                                __finally {
                                    if (_is_valid_handle(g_tee_file_stdin_mutex)) {
                                        ReleaseMutex(g_tee_file_stdin_mutex);
                                    }
                                } }();

                                if (thread_data.cancel_io) break;
                            }

                            if (_is_valid_handle(g_tee_named_pipe_stdin_handle)) {
                                WriteFile(g_tee_named_pipe_stdin_handle, stdin_byte_buf.data(), num_bytes_read, &num_bytes_written, NULL);
                                if (thread_data.cancel_io) break;

                                if (g_flags.tee_stdin_pipe_flush || g_flags.tee_stdin_flush || g_flags.tee_inout_flush) {
                                    FlushFileBuffers(g_tee_named_pipe_stdin_handle);
                                    if (thread_data.cancel_io) break;
                                }
                            }

                            if (_is_valid_handle(g_stdin_pipe_write_handle)) {
                                SetLastError(0); // just in case
                                if (WriteFile(g_stdin_pipe_write_handle, stdin_byte_buf.data(), num_bytes_read, &num_bytes_write, NULL)) {
                                    if (g_flags.stdin_output_flush || g_flags.inout_flush) {
                                        FlushFileBuffers(g_stdin_pipe_write_handle);
                                    }

                                    if (thread_data.cancel_io) break;
                                }
                                else {
                                    if (thread_data.cancel_io) break;

                                    win_error = GetLastError();
                                    if (win_error) {
                                        thread_data.ret = err_io_error;
                                        thread_data.win_error = win_error;
                                        if (!g_flags.no_print_gen_error_string) {
                                            thread_data.msg =
                                                _format_stderr_message(_T("child stdin write error: win_error=0x%08X (%d)\n"),
                                                    win_error, win_error);
                                        }
                                        if (g_flags.print_win_error_string && win_error) {
                                            thread_data.msg +=
                                                _format_win_error_message(win_error, g_options.win_error_langid);
                                        }
                                        thread_data.is_error = true;
                                    }

                                    stream_eof = true;
                                }
                            }
                        }
                        else {
                            stream_eof = true;
                        }
                    }

                    // explicitly disconnect/close all stdout handles here to trigger the child process reaction

                    // CAUTION:
                    //  Always flush before disconnection/close, otherwise the last bytes would be lost!
                    //
                    FlushFileBuffers(g_stdin_pipe_write_handle);

                    if (!g_options.create_outbound_pipe_from_stdin.empty()) {
                        DisconnectNamedPipe(g_stdin_pipe_write_handle);
                    }
                    _close_handle(g_stdin_pipe_write_handle);
                } break;

                case FILE_TYPE_PIPE:
                {
                    stdin_byte_buf.resize(g_options.tee_stdin_read_buf_size);

                    while (!stream_eof) {
                        // in case if the child process is exited but the output handle is somehow alive (leaked) and not broken
                        if (WaitForSingleObject(g_child_process_handle, 0) != WAIT_TIMEOUT) {
                            break;
                        }

                        num_bytes_read = num_bytes_avail = 0;

                        // CAUTION:
                        //  We is required `PeekNamedPipe` here before the `ReadFile` because of potential break in the output handle, when
                        //  the input handle has no data to read but the output handle is already closed or broken.
                        //  In that case we must call to `WriteFile` even if has not data on the input.
                        //

                        SetLastError(0); // just in case
                        if (!PeekNamedPipe(g_stdin_handle, NULL, 0, NULL, &num_bytes_avail, NULL)) {
                            if (thread_data.cancel_io) break;

                            win_error = GetLastError();
                            if (win_error != ERROR_BROKEN_PIPE && win_error != ERROR_PIPE_NOT_CONNECTED) {
                                thread_data.ret = err_io_error;
                                thread_data.win_error = win_error;
                                if (!g_flags.no_print_gen_error_string) {
                                    thread_data.msg =
                                        _format_stderr_message(_T("stdin read error: win_error=0x%08X (%d)\n"),
                                            win_error, win_error);
                                }
                                if (g_flags.print_win_error_string && win_error) {
                                    thread_data.msg +=
                                        _format_win_error_message(win_error, g_options.win_error_langid);
                                }
                                thread_data.is_error = true;
                            }

                            stream_eof = true;

                        }

                        if (num_bytes_avail) {
                            SetLastError(0); // just in case
                            if (!ReadFile(g_stdin_handle, stdin_byte_buf.data(), g_options.tee_stdin_read_buf_size, &num_bytes_read, NULL)) {
                                if (thread_data.cancel_io) break;

                                win_error = GetLastError();
                                if (win_error != ERROR_BROKEN_PIPE) {
                                    thread_data.ret = err_io_error;
                                    thread_data.win_error = win_error;
                                    if (!g_flags.no_print_gen_error_string) {
                                        thread_data.msg =
                                            _format_stderr_message(_T("stdin read error: win_error=0x%08X (%d)\n"),
                                                win_error, win_error);
                                    }
                                    if (g_flags.print_win_error_string && win_error) {
                                        thread_data.msg +=
                                            _format_win_error_message(win_error, g_options.win_error_langid);
                                    }
                                    thread_data.is_error = true;
                                }

                                stream_eof = true;
                            }
                        }

                        if (num_bytes_read) {
                            if (_is_valid_handle(g_tee_file_stdin_handle)) {
                                [&]() { if_break(true) __try {
                                    if (_is_valid_handle(g_tee_file_stdin_mutex)) {
                                        WaitForSingleObject(g_tee_file_stdin_mutex, INFINITE);
                                    }

                                    SetFilePointer(g_tee_file_stdin_handle, 0, NULL, FILE_END);

                                    WriteFile(g_tee_file_stdin_handle, stdin_byte_buf.data(), num_bytes_read, &num_bytes_written, NULL);
                                    if (thread_data.cancel_io) break;

                                    if (g_flags.tee_stdin_file_flush || g_flags.tee_stdin_flush || g_flags.tee_inout_flush) {
                                        FlushFileBuffers(g_tee_file_stdin_handle);
                                        if (thread_data.cancel_io) break;
                                    }
                                }
                                __finally {
                                    if (_is_valid_handle(g_tee_file_stdin_mutex)) {
                                        ReleaseMutex(g_tee_file_stdin_mutex);
                                    }
                                } }();

                                if (thread_data.cancel_io) break;
                            }

                            if (_is_valid_handle(g_tee_named_pipe_stdin_handle)) {
                                WriteFile(g_tee_named_pipe_stdin_handle, stdin_byte_buf.data(), num_bytes_read, &num_bytes_written, NULL);
                                if (thread_data.cancel_io) break;

                                if (g_flags.tee_stdin_pipe_flush || g_flags.tee_stdin_flush || g_flags.tee_inout_flush) {
                                    FlushFileBuffers(g_tee_named_pipe_stdin_handle);
                                    if (thread_data.cancel_io) break;
                                }
                            }

                            if (_is_valid_handle(g_stdin_pipe_write_handle)) {
                                SetLastError(0); // just in case
                                if (WriteFile(g_stdin_pipe_write_handle, stdin_byte_buf.data(), num_bytes_read, &num_bytes_write, NULL)) {
                                    if (g_flags.stdin_output_flush || g_flags.inout_flush) {
                                        FlushFileBuffers(g_stdin_pipe_write_handle);
                                    }

                                    if (thread_data.cancel_io) break;
                                }
                                else {
                                    if (thread_data.cancel_io) break;

                                    win_error = GetLastError();
                                    if (win_error) {
                                        thread_data.ret = err_io_error;
                                        thread_data.win_error = win_error;
                                        if (!g_flags.no_print_gen_error_string) {
                                            thread_data.msg =
                                                _format_stderr_message(_T("child stdin write error: win_error=0x%08X (%d)\n"),
                                                    win_error, win_error);
                                        }
                                        if (g_flags.print_win_error_string && win_error) {
                                            thread_data.msg +=
                                                _format_win_error_message(win_error, g_options.win_error_langid);
                                        }
                                        thread_data.is_error = true;
                                    }

                                    stream_eof = true;
                                }
                            }
                        }
                        else if (!num_bytes_avail) {
                            SetLastError(0); // just in case
                            if (!WriteFile(g_stdin_pipe_write_handle, stdin_byte_buf.data(), 0, &num_bytes_write, NULL)) {
                                if (thread_data.cancel_io) break;

                                stream_eof = true;
                            }

                            if (!stream_eof) {
                                // loop wait
                                Sleep(20);

                                if (thread_data.cancel_io) break;
                            }
                        }
                    }

                    // explicitly disconnect/close all stdout handles here to trigger the child process reaction

                    // CAUTION:
                    //  Always flush before disconnection/close, otherwise the last bytes would be lost!
                    //
                    FlushFileBuffers(g_stdin_pipe_write_handle);

                    if (!g_options.create_outbound_pipe_from_stdin.empty()) {
                        DisconnectNamedPipe(g_stdin_pipe_write_handle);
                    }
                    _close_handle(g_stdin_pipe_write_handle);
                } break;

//                case FILE_TYPE_CHAR:
//                {
//                    // CAUTION:
//                    //  This branch has no native Win32 implementation portable between Win XP/7/8/10 windows versions.
//                    //  The `CreatePseudoConsole` API function is available only after the `Windows 10 October 2018 Update (version 1809) [desktop apps only]`
//                    //  The complete implementation which can be provided here can be done through a remote code injection to a child process and is not yet available.
//                    //
//
//                        if (_is_valid_handle(g_tee_file_stdin_handle)) {
//                            const UINT cp_out = GetConsoleOutputCP();
//    
//                            CPINFO cp_info{};
//                            if (!GetCPInfo(cp_out, &cp_info)) {
//                                // fallback to module character set
//#ifdef _UNICODE
//                                cp_info.MaxCharSize = 2;
//#else
//                                cp_info.MaxCharSize = 1;
//#endif
//                            }
//    
//                            // CAUTION:
//                            //  The `ReadConsoleBuffer` function can fail if the length parameter is too big!
//                            //
//                            const DWORD tee_stdin_read_buf_size = (std::max)(g_options.tee_stdin_read_buf_size, 32767U);
//
//                            stdin_byte_buf.resize(tee_stdin_read_buf_size * sizeof(INPUT_RECORD));
//
//                            if (cp_info.MaxCharSize != 1) {
//                                stdin_wchar_buf.reserve(256);
//                            }
//                            else {
//                                stdin_char_buf.reserve(256);
//                            }
//    
//                            INPUT_RECORD tmp_input_record{};
//
//                            while (!stream_eof) {
//                                // in case if child process exit
//                                if (WaitForSingleObject(g_child_process_handle, 0) != WAIT_TIMEOUT) {
//                                    break;
//                                }
//
//                                // non blocking read
//                                SetLastError(0); // just in case
//                                if (!PeekConsoleInput(g_stdin_handle, NULL, 0, &num_events_read)) {
//                                    win_error = GetLastError();
//                                    if (win_error) {
//                                        thread_data.ret = err_io_error;
//                                        thread_data.win_error = win_error;
//                                        if (!g_flags.no_print_gen_error_string) {
//                                            thread_data.msg =
//                                                _format_stderr_message(_T("stdin console read error: win_error=0x%08X (%d)\n"),
//                                                    win_error, win_error);
//                                        }
//                                        if (g_flags.print_win_error_string && win_error) {
//                                            thread_data.msg +=
//                                                _format_win_error_message(win_error);
//                                        }
//                                        thread_data.is_error = true;
//                                    }
//                                }
//
//                                if (num_events_read) {
//                                    SetLastError(0); // just in case
//                                    if (!ReadConsoleInput(g_stdin_handle, (PINPUT_RECORD)stdin_byte_buf.data(), tee_stdin_read_buf_size, &num_events_read)) {
//                                        if (thread_data.cancel_io) break;
//
//                                        win_error = GetLastError();
//                                        if (win_error) {
//                                            thread_data.ret = err_io_error;
//                                            thread_data.win_error = win_error;
//                                            if (!g_flags.no_print_gen_error_string) {
//                                                thread_data.msg =
//                                                    _format_stderr_message(_T("stdin console read error: win_error=0x%08X (%d)\n"),
//                                                        win_error, win_error);
//                                            }
//                                            if (g_flags.print_win_error_string && win_error) {
//                                                thread_data.msg +=
//                                                    _format_win_error_message(win_error);
//                                            }
//                                            thread_data.is_error = true;
//                                        }
//
//                                        stream_eof = true;
//                                    }
//
//                                    for (size_t i = 0; i < size_t(num_events_read); i++) {
//                                        const INPUT_RECORD & input_record = PINPUT_RECORD(stdin_byte_buf.data())[i];
//    
//                                        if (input_record.EventType == KEY_EVENT) {
//                                            const KEY_EVENT_RECORD & key_event_record = input_record.Event.KeyEvent;
//
//                                            if (key_event_record.bKeyDown) {
//                                                if (key_event_record.wRepeatCount > 0) { // just in case
//                                                    if (cp_info.MaxCharSize != 1) {
//                                                        stdin_wchar_buf.resize(size_t(key_event_record.wRepeatCount));
//
//                                                        for (size_t j = 0; j < size_t(key_event_record.wRepeatCount); j++) {
//                                                            stdin_wchar_buf[j] = key_event_record.uChar.UnicodeChar;
//                                                        }
//
//                                                        WriteFile(g_tee_file_stdin_handle, stdin_wchar_buf.data(), sizeof(wchar_t) * key_event_record.wRepeatCount,
//                                                            &num_bytes_written, NULL);
//                                                    }
//                                                    else {
//                                                        stdin_char_buf.resize(size_t(key_event_record.wRepeatCount));
//
//                                                        for (size_t j = 0; j < size_t(key_event_record.wRepeatCount); j++) {
//                                                            stdin_char_buf[j] = key_event_record.uChar.AsciiChar;
//                                                        }
//
//                                                        WriteFile(g_tee_file_stdin_handle, stdin_char_buf.data(), sizeof(char) * key_event_record.wRepeatCount,
//                                                            &num_bytes_written, NULL);
//                                                    }
//
//                                                    if (thread_data.cancel_io) break;
//
//                                                    if (g_flags.tee_stdin_file_flush || g_flags.tee_stdin_flush || g_flags.tee_inout_flush) {
//                                                        FlushFileBuffers(g_tee_file_stdin_handle);
//                                                        if (thread_data.cancel_io) break;
//                                                    }
//                                                }
//                                            }
//                                        }
//                                    }
//
//                                    //SetLastError(0); // just in case
//                                    //if (!WriteConsoleInput(g_stdin_child_handle, (PINPUT_RECORD)stdin_byte_buf.data(), num_events_read, &num_events_written)) {
//                                    //    if (thread_data.cancel_io) break;
//
//                                    //    win_error = GetLastError();
//                                    //    if (win_error) {
//                                    //        thread_data.ret = err_io_error;
//                                    //        thread_data.win_error = win_error;
//                                    //        if (!g_flags.no_print_gen_error_string) {
//                                    //            thread_data.msg =
//                                    //                _format_stderr_message(_T("child stdin console write error: win_error=0x%08X (%d)\n"),
//                                    //                    win_error, win_error);
//                                    //        }
//                                    //        if (g_flags.print_win_error_string && win_error) {
//                                    //            thread_data.msg +=
//                                    //                _format_win_error_message(win_error);
//                                    //        }
//                                    //        thread_data.is_error = true;
//                                    //    }
//                                    //}
//                                }
//                                else {
//                                    Sleep(20); // 20ms input wait
//                                }
//                            }
//                        }
//                   } break;
                }
            } break;

            case 1: // stdout
            {
                // Accomplish all server pipe connections before continue.
                //

                {
                    auto & connect_server_named_pipe_thread_local = g_connect_server_named_pipe_thread_locals[0][stream_type];

                    WaitForConnectNamedPipeThreads(connect_server_named_pipe_thread_local, false);

                    // check errors
                    utility::for_each_unroll(make_singular_array(connect_server_named_pipe_thread_local), [&](auto & local) {
                        if (!local.thread_data.is_copied && !local.thread_data.msg.empty()) {
                            g_worker_threads_return_data.add(local.thread_data);
                            local.thread_data.is_copied = true;
                        }
                        if (!break_ && local.thread_data.is_error) {
                            break_ = true;
                        }
                    });
                }

                {
                    auto & connect_server_named_pipe_thread_local = g_connect_server_named_pipe_thread_locals[1][stream_type];

                    WaitForConnectNamedPipeThreads(connect_server_named_pipe_thread_local, false);

                    // check errors
                    utility::for_each_unroll(make_singular_array(connect_server_named_pipe_thread_local), [&](auto & local) {
                        if (!local.thread_data.is_copied && !local.thread_data.msg.empty()) {
                            g_worker_threads_return_data.add(local.thread_data);
                            local.thread_data.is_copied = true;
                        }
                        if (!break_ && local.thread_data.is_error) {
                            break_ = true;
                        }
                    });
                }

                if (break_) break;

                if (_is_valid_handle(g_stdout_pipe_read_handle)) {
                    stdout_byte_buf.resize(g_options.tee_stdout_read_buf_size);

                    while (!stream_eof) {
                        SetLastError(0); // just in case
                        if (!ReadFile(g_stdout_pipe_read_handle, stdout_byte_buf.data(), g_options.tee_stdout_read_buf_size, &num_bytes_read, NULL)) {
                            if (thread_data.cancel_io) break;

                            win_error = GetLastError();
                            if (win_error != ERROR_BROKEN_PIPE && win_error != ERROR_PIPE_NOT_CONNECTED) {
                                thread_data.ret = err_io_error;
                                thread_data.win_error = win_error;
                                if (!g_flags.no_print_gen_error_string) {
                                    thread_data.msg =
                                        _format_stderr_message(_T("child stdout read error: win_error=0x%08X (%d)\n"),
                                            win_error, win_error);
                                }
                                if (g_flags.print_win_error_string && win_error) {
                                    thread_data.msg +=
                                        _format_win_error_message(win_error, g_options.win_error_langid);
                                }
                                thread_data.is_error = true;
                            }

                            stream_eof = true;
                        }

                        if (num_bytes_read) {
                            if (_is_valid_handle(g_tee_file_stdout_handle)) {
                                [&]() { if_break(true) __try {
                                    if (_is_valid_handle(g_tee_file_stdout_mutex)) {
                                        WaitForSingleObject(g_tee_file_stdout_mutex, INFINITE);
                                    }

                                    SetFilePointer(g_tee_file_stdout_handle, 0, NULL, FILE_END);

                                    WriteFile(g_tee_file_stdout_handle, stdout_byte_buf.data(), num_bytes_read, &num_bytes_written, NULL);
                                    if (thread_data.cancel_io) break;

                                    if (g_flags.tee_stdout_file_flush || g_flags.tee_stdout_flush || g_flags.tee_output_flush || g_flags.tee_inout_flush) {
                                        FlushFileBuffers(g_tee_file_stdout_handle);
                                        if (thread_data.cancel_io) break;
                                    }
                                }
                                __finally {
                                    if (_is_valid_handle(g_tee_file_stdout_mutex)) {
                                        ReleaseMutex(g_tee_file_stdout_mutex);
                                    }
                                } }();

                                if (thread_data.cancel_io) break;
                            }

                            if (_is_valid_handle(g_tee_named_pipe_stdout_handle)) {
                                WriteFile(g_tee_named_pipe_stdout_handle, stdin_byte_buf.data(), num_bytes_read, &num_bytes_written, NULL);
                                if (thread_data.cancel_io) break;

                                if (g_flags.tee_stdout_pipe_flush || g_flags.tee_stdout_flush || g_flags.tee_inout_flush) {
                                    FlushFileBuffers(g_tee_named_pipe_stdout_handle);
                                    if (thread_data.cancel_io) break;
                                }
                            }

                            if (_is_valid_handle(g_stdout_handle)) {
                                [&]() { if_break(true) __try {
                                    if (_is_valid_handle(g_reopen_stdout_mutex)) {
                                        WaitForSingleObject(g_reopen_stdout_mutex, INFINITE);
                                    }

                                    if (_is_valid_handle(g_reopen_stdout_handle)) {
                                        SetFilePointer(g_reopen_stdout_handle, 0, NULL, FILE_END);
                                    }

                                    SetLastError(0); // just in case
                                    if (WriteFile(g_stdout_handle, stdout_byte_buf.data(), num_bytes_read, &num_bytes_write, NULL)) {
                                        if (g_flags.stdout_flush || g_flags.output_flush || g_flags.inout_flush) {
                                            FlushFileBuffers(g_stdout_handle);
                                        }

                                        if (thread_data.cancel_io) break;
                                    }
                                    else {
                                        if (thread_data.cancel_io) break;

                                        win_error = GetLastError();
                                        if (win_error) {
                                            [&]() {
                                                thread_data.ret = err_io_error;
                                                thread_data.win_error = win_error;
                                                if (!g_flags.no_print_gen_error_string) {
                                                    thread_data.msg =
                                                        _format_stderr_message(_T("stdout write error: win_error=0x%08X (%d)\n"),
                                                            win_error, win_error);
                                                }
                                                if (g_flags.print_win_error_string && win_error) {
                                                    thread_data.msg +=
                                                        _format_win_error_message(win_error, g_options.win_error_langid);
                                                }
                                                thread_data.is_error = true;
                                            }();
                                        }

                                        stream_eof = true;
                                    }
                                }
                                __finally {
                                    if (_is_valid_handle(g_reopen_stdout_mutex)) {
                                        ReleaseMutex(g_reopen_stdout_mutex);
                                    }
                                } }();

                                if (thread_data.cancel_io) break;
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
                // Accomplish all server pipe connections before continue.
                //

                {
                    auto & connect_server_named_pipe_thread_local = g_connect_server_named_pipe_thread_locals[0][stream_type];

                    WaitForConnectNamedPipeThreads(connect_server_named_pipe_thread_local, false);

                    // check errors
                    utility::for_each_unroll(make_singular_array(connect_server_named_pipe_thread_local), [&](auto & local) {
                        if (!local.thread_data.is_copied && !local.thread_data.msg.empty()) {
                            g_worker_threads_return_data.add(local.thread_data);
                            local.thread_data.is_copied = true;
                        }
                        if (!break_ && local.thread_data.is_error) {
                            break_ = true;
                        }
                    });
                }

                {
                    auto & connect_server_named_pipe_thread_local = g_connect_server_named_pipe_thread_locals[1][stream_type];

                    WaitForConnectNamedPipeThreads(connect_server_named_pipe_thread_local, false);

                    // check errors
                    utility::for_each_unroll(make_singular_array(connect_server_named_pipe_thread_local), [&](auto & local) {
                        if (!local.thread_data.is_copied && !local.thread_data.msg.empty()) {
                            g_worker_threads_return_data.add(local.thread_data);
                            local.thread_data.is_copied = true;
                        }
                        if (!break_ && local.thread_data.is_error) {
                            break_ = true;
                        }
                    });
                }

                if (break_) break;

                if (_is_valid_handle(g_stderr_pipe_read_handle)) {
                    stderr_byte_buf.resize(g_options.tee_stderr_read_buf_size);

                    while (!stream_eof) {
                        SetLastError(0); // just in case
                        if (!ReadFile(g_stderr_pipe_read_handle, stderr_byte_buf.data(), g_options.tee_stderr_read_buf_size, &num_bytes_read, NULL))
                        {
                            if (thread_data.cancel_io) break;

                            win_error = GetLastError();
                            if (win_error != ERROR_BROKEN_PIPE && win_error != ERROR_PIPE_NOT_CONNECTED) {
                                thread_data.ret = err_io_error;
                                thread_data.win_error = win_error;
                                if (!g_flags.no_print_gen_error_string) {
                                    thread_data.msg =
                                        _format_stderr_message(_T("child stderr read error: win_error=0x%08X (%d)\n"),
                                            win_error, win_error);
                                }
                                if (g_flags.print_win_error_string && win_error) {
                                    thread_data.msg +=
                                        _format_win_error_message(win_error, g_options.win_error_langid);
                                }
                                thread_data.is_error = true;
                            }

                            stream_eof = true;
                        }

                        if (num_bytes_read) {
                            if (_is_valid_handle(g_tee_file_stderr_handle)) {
                                [&]() { if_break(true) __try {
                                    if (_is_valid_handle(g_tee_file_stderr_mutex)) {
                                        WaitForSingleObject(g_tee_file_stderr_mutex, INFINITE);
                                    }

                                    SetFilePointer(g_tee_file_stderr_handle, 0, NULL, FILE_END);

                                    WriteFile(g_tee_file_stderr_handle, stderr_byte_buf.data(), num_bytes_read, &num_bytes_written, NULL);
                                    if (thread_data.cancel_io) break;

                                    if (g_flags.tee_stderr_file_flush || g_flags.tee_stderr_flush || g_flags.tee_output_flush || g_flags.tee_inout_flush) {
                                        FlushFileBuffers(g_tee_file_stderr_handle);
                                        if (thread_data.cancel_io) break;
                                    }
                                }
                                __finally {
                                    if (_is_valid_handle(g_tee_file_stderr_mutex)) {
                                        ReleaseMutex(g_tee_file_stderr_mutex);
                                    }
                                } }();

                                if (thread_data.cancel_io) break;
                            }

                            if (_is_valid_handle(g_tee_named_pipe_stderr_handle)) {
                                WriteFile(g_tee_named_pipe_stderr_handle, stdin_byte_buf.data(), num_bytes_read, &num_bytes_written, NULL);
                                if (thread_data.cancel_io) break;

                                if (g_flags.tee_stderr_pipe_flush || g_flags.tee_stderr_flush || g_flags.tee_inout_flush) {
                                    FlushFileBuffers(g_tee_named_pipe_stderr_handle);
                                    if (thread_data.cancel_io) break;
                                }
                            }

                            if (_is_valid_handle(g_stderr_handle)) {
                                [&]() { if_break(true) __try {
                                    if (_is_valid_handle(g_reopen_stderr_mutex)) {
                                        WaitForSingleObject(g_reopen_stderr_mutex, INFINITE);
                                    }

                                    if (_is_valid_handle(g_reopen_stderr_handle)) {
                                        SetFilePointer(g_reopen_stderr_handle, 0, NULL, FILE_END);
                                    }

                                    SetLastError(0); // just in case
                                    if (WriteFile(g_stderr_handle, stderr_byte_buf.data(), num_bytes_read, &num_bytes_write, NULL)) {
                                        if (g_flags.stderr_flush || g_flags.output_flush || g_flags.inout_flush) {
                                            FlushFileBuffers(g_stderr_handle);
                                        }

                                        if (thread_data.cancel_io) break;
                                    }
                                    else {
                                        if (thread_data.cancel_io) break;

                                        win_error = GetLastError();
                                        if (win_error) {
                                            [&]() {
                                                thread_data.ret = err_io_error;
                                                thread_data.win_error = win_error;
                                                if (!g_flags.no_print_gen_error_string) {
                                                    thread_data.msg =
                                                        _format_stderr_message(_T("stderr write error: win_error=0x%08X (%d)\n"),
                                                            win_error, win_error);
                                                }
                                                if (g_flags.print_win_error_string && win_error) {
                                                    thread_data.msg +=
                                                        _format_win_error_message(win_error, g_options.win_error_langid);
                                                }
                                                thread_data.is_error = true;
                                            }();
                                        }
                                    }
                                }
                                __finally {
                                    if (_is_valid_handle(g_reopen_stderr_mutex)) {
                                        ReleaseMutex(g_reopen_stderr_mutex);
                                    }
                                } }();

                                if (thread_data.cancel_io) break;
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
        }();
    }
    __finally {
        ;
    } }();

    return 0;
}

DWORD WINAPI StdinToStdoutThread(LPVOID lpParam)
{
    StreamPipeThreadData & thread_data = *static_cast<StreamPipeThreadData *>(lpParam);

    thread_data.ret = err_unspecified;

    bool stream_eof = false;

    DWORD num_bytes_avail = 0;
    DWORD num_bytes_read = 0;
    DWORD num_bytes_write = 0;
    DWORD num_bytes_written = 0;
    //DWORD num_events_read = 0;
    //DWORD num_events_written = 0;
    DWORD win_error = 0;

    std::vector<std::uint8_t> stdin_byte_buf;

    bool break_ = false;

    // NOTE:
    //  labda to bypass msvc error: `error C2712: Cannot use __try in functions that require object unwinding`
    //
    [&]() { __try {
        [&]() {
            // Accomplish all server pipe connections before continue.
            //

            {
                auto & connect_server_named_pipe_thread_local = g_connect_server_named_pipe_thread_locals[0][0];

                WaitForConnectNamedPipeThreads(connect_server_named_pipe_thread_local, false);

                // check errors
                utility::for_each_unroll(make_singular_array(connect_server_named_pipe_thread_local), [&](auto & local) {
                    if (!local.thread_data.is_copied && !local.thread_data.msg.empty()) {
                        g_worker_threads_return_data.add(local.thread_data);
                        local.thread_data.is_copied = true;
                    }
                    if (!break_ && local.thread_data.is_error) {
                        break_ = true;
                    }
                });
            }

            {
                auto & connect_server_named_pipe_thread_local = g_connect_server_named_pipe_thread_locals[0][1];

                WaitForConnectNamedPipeThreads(connect_server_named_pipe_thread_local, false);

                // check errors
                utility::for_each_unroll(make_singular_array(connect_server_named_pipe_thread_local), [&](auto & local) {
                    if (!local.thread_data.is_copied && !local.thread_data.msg.empty()) {
                        g_worker_threads_return_data.add(local.thread_data);
                        local.thread_data.is_copied = true;
                    }
                    if (!break_ && local.thread_data.is_error) {
                        break_ = true;
                    }
                });
            }

            {
                auto & connect_server_named_pipe_thread_local = g_connect_server_named_pipe_thread_locals[1][0];

                WaitForConnectNamedPipeThreads(connect_server_named_pipe_thread_local, false);

                // check errors
                utility::for_each_unroll(make_singular_array(connect_server_named_pipe_thread_local), [&](auto & local) {
                    if (!local.thread_data.is_copied && !local.thread_data.msg.empty()) {
                        g_worker_threads_return_data.add(local.thread_data);
                        local.thread_data.is_copied = true;
                    }
                    if (!break_ && local.thread_data.is_error) {
                        break_ = true;
                    }
                });
            }

            {
                auto & connect_server_named_pipe_thread_local = g_connect_server_named_pipe_thread_locals[1][1];

                WaitForConnectNamedPipeThreads(connect_server_named_pipe_thread_local, false);

                // check errors
                utility::for_each_unroll(make_singular_array(connect_server_named_pipe_thread_local), [&](auto & local) {
                    if (!local.thread_data.is_copied && !local.thread_data.msg.empty()) {
                        g_worker_threads_return_data.add(local.thread_data);
                        local.thread_data.is_copied = true;
                    }
                    if (!break_ && local.thread_data.is_error) {
                        break_ = true;
                    }
                });
            }

            if (break_) return;

            // WORKAROUND:
            //  Synchronous ReadFile function has an issue, where it stays locked on pipe input while the output handle already closed or broken (pipe)!
            //  To fix that, we have to use PeekNamedPipe+ReadFile with the output handle test for write (WriteFile with 0 bytes) instead of
            //  single ReadFile w/o the output handle write test.
            //

            switch (g_stdin_handle_type) {
            case FILE_TYPE_DISK:
            {
                stdin_byte_buf.resize(g_options.tee_stdin_read_buf_size);

                while (!stream_eof) {
                    SetLastError(0); // just in case
                    if (!ReadFile(g_stdin_handle, stdin_byte_buf.data(), g_options.tee_stdin_read_buf_size, &num_bytes_read, NULL)) {
                        if (thread_data.cancel_io) break;

                        win_error = GetLastError();
                        if (win_error != ERROR_BROKEN_PIPE && win_error != ERROR_PIPE_NOT_CONNECTED) {
                            thread_data.ret = err_io_error;
                            thread_data.win_error = win_error;
                            if (!g_flags.no_print_gen_error_string) {
                                thread_data.msg =
                                    _format_stderr_message(_T("stdin read error: win_error=0x%08X (%d)\n"),
                                        win_error, win_error);
                            }
                            if (g_flags.print_win_error_string && win_error) {
                                thread_data.msg +=
                                    _format_win_error_message(win_error, g_options.win_error_langid);
                            }
                            thread_data.is_error = true;
                        }

                        stream_eof = true;
                    }

                    if (num_bytes_read) {
                        if (_is_valid_handle(g_tee_file_stdin_handle)) {
                            [&]() { if_break(true) __try {
                                if (_is_valid_handle(g_tee_file_stdin_mutex)) {
                                    WaitForSingleObject(g_tee_file_stdin_mutex, INFINITE);
                                }

                                SetFilePointer(g_tee_file_stdin_handle, 0, NULL, FILE_END);

                                WriteFile(g_tee_file_stdin_handle, stdin_byte_buf.data(), num_bytes_read, &num_bytes_written, NULL);
                                if (thread_data.cancel_io) break;

                                if (g_flags.tee_stdin_file_flush || g_flags.tee_stdin_flush || g_flags.tee_inout_flush) {
                                    FlushFileBuffers(g_tee_file_stdin_handle);
                                    if (thread_data.cancel_io) break;
                                }
                            }
                            __finally {
                                if (_is_valid_handle(g_tee_file_stdin_mutex)) {
                                    ReleaseMutex(g_tee_file_stdin_mutex);
                                }
                            } }();

                            if (thread_data.cancel_io) break;
                        }

                        if (_is_valid_handle(g_tee_file_stdout_handle)) {
                            [&]() { if_break(true) __try {
                                if (_is_valid_handle(g_tee_file_stdout_mutex)) {
                                    WaitForSingleObject(g_tee_file_stdout_mutex, INFINITE);
                                }

                                SetFilePointer(g_tee_file_stdout_handle, 0, NULL, FILE_END);

                                WriteFile(g_tee_file_stdout_handle, stdin_byte_buf.data(), num_bytes_read, &num_bytes_written, NULL);
                                if (thread_data.cancel_io) break;

                                if (g_flags.tee_stdout_file_flush || g_flags.tee_stdout_flush || g_flags.tee_inout_flush || g_flags.tee_output_flush) {
                                    FlushFileBuffers(g_tee_file_stdout_handle);
                                    if (thread_data.cancel_io) break;
                                }
                            }
                            __finally {
                                if (_is_valid_handle(g_tee_file_stdout_mutex)) {
                                    ReleaseMutex(g_tee_file_stdout_mutex);
                                }
                            } }();

                            if (thread_data.cancel_io) break;
                        }

                        if (_is_valid_handle(g_tee_named_pipe_stdin_handle)) {
                            WriteFile(g_tee_named_pipe_stdin_handle, stdin_byte_buf.data(), num_bytes_read, &num_bytes_written, NULL);
                            if (thread_data.cancel_io) break;

                            if (g_flags.tee_stdin_pipe_flush || g_flags.tee_stdin_flush || g_flags.tee_inout_flush) {
                                FlushFileBuffers(g_tee_named_pipe_stdin_handle);
                                if (thread_data.cancel_io) break;
                            }
                        }

                        if (_is_valid_handle(g_tee_named_pipe_stdout_handle)) {
                            WriteFile(g_tee_named_pipe_stdout_handle, stdin_byte_buf.data(), num_bytes_read, &num_bytes_written, NULL);
                            if (thread_data.cancel_io) break;

                            if (g_flags.tee_stdout_pipe_flush || g_flags.tee_stdout_flush || g_flags.tee_inout_flush || g_flags.tee_output_flush) {
                                FlushFileBuffers(g_tee_named_pipe_stdout_handle);
                                if (thread_data.cancel_io) break;
                            }
                        }

                        if (_is_valid_handle(g_stdout_handle)) {
                            SetLastError(0); // just in case
                            if (WriteFile(g_stdout_handle, stdin_byte_buf.data(), num_bytes_read, &num_bytes_write, NULL)) {
                                if (g_flags.stdin_output_flush || g_flags.stdout_flush || g_flags.inout_flush || g_flags.output_flush) {
                                    FlushFileBuffers(g_stdout_handle);
                                }

                                if (thread_data.cancel_io) break;
                            }
                            else {
                                if (thread_data.cancel_io) break;

                                win_error = GetLastError();
                                if (win_error) {
                                    thread_data.ret = err_io_error;
                                    thread_data.win_error = win_error;
                                    if (!g_flags.no_print_gen_error_string) {
                                        thread_data.msg =
                                            _format_stderr_message(_T("stdout write error: win_error=0x%08X (%d)\n"),
                                                win_error, win_error);
                                    }
                                    if (g_flags.print_win_error_string && win_error) {
                                        thread_data.msg +=
                                            _format_win_error_message(win_error, g_options.win_error_langid);
                                    }
                                    thread_data.is_error = true;
                                }

                                stream_eof = true;
                            }
                        }
                    }
                    else {
                        stream_eof = true;
                    }
                }

                // explicitly disconnect/close all stdout handles here to trigger the child process reaction

                // CAUTION:
                //  Always flush before disconnection/close, otherwise the last bytes would be lost!
                //
                FlushFileBuffers(g_stdout_handle);

                if (!g_options.reopen_stdout_as_server_pipe.empty()) {
                    DisconnectNamedPipe(g_stdout_handle);
                }
                _close_handle(g_stdout_handle);
                //_close(STDOUT_FILENO);
            } break;

            case FILE_TYPE_PIPE:
            {
                stdin_byte_buf.resize(g_options.tee_stdin_read_buf_size);

                while (!stream_eof) {
                    num_bytes_read = num_bytes_avail = 0;

                    // CAUTION:
                    //  We is required `PeekNamedPipe` here before the `ReadFile` because of potential break in the output handle, when
                    //  the input handle has no data to read but the output handle is already closed or broken.
                    //  In that case we must call to `WriteFile` even if has not data on the input.
                    //

                    SetLastError(0); // just in case
                    if (!PeekNamedPipe(g_stdin_handle, NULL, 0, NULL, &num_bytes_avail, NULL)) {
                        if (thread_data.cancel_io) break;

                        win_error = GetLastError();
                        if (win_error != ERROR_BROKEN_PIPE && win_error != ERROR_PIPE_NOT_CONNECTED) {
                            thread_data.ret = err_io_error;
                            thread_data.win_error = win_error;
                            if (!g_flags.no_print_gen_error_string) {
                                thread_data.msg =
                                    _format_stderr_message(_T("stdin read error: win_error=0x%08X (%d)\n"),
                                        win_error, win_error);
                            }
                            if (g_flags.print_win_error_string && win_error) {
                                thread_data.msg +=
                                    _format_win_error_message(win_error, g_options.win_error_langid);
                            }
                            thread_data.is_error = true;
                        }

                        stream_eof = true;

                    }

                    if (num_bytes_avail) {
                        SetLastError(0); // just in case
                        if (!ReadFile(g_stdin_handle, stdin_byte_buf.data(), g_options.tee_stdin_read_buf_size, &num_bytes_read, NULL)) {
                            if (thread_data.cancel_io) break;

                            win_error = GetLastError();
                            if (win_error != ERROR_BROKEN_PIPE && win_error != ERROR_PIPE_NOT_CONNECTED) {
                                thread_data.ret = err_io_error;
                                thread_data.win_error = win_error;
                                if (!g_flags.no_print_gen_error_string) {
                                    thread_data.msg =
                                        _format_stderr_message(_T("stdin read error: win_error=0x%08X (%d)\n"),
                                            win_error, win_error);
                                }
                                if (g_flags.print_win_error_string && win_error) {
                                    thread_data.msg +=
                                        _format_win_error_message(win_error, g_options.win_error_langid);
                                }
                                thread_data.is_error = true;
                            }

                            stream_eof = true;
                        }
                    }

                    if (num_bytes_read) {
                        if (_is_valid_handle(g_tee_file_stdin_handle)) {
                            [&]() { if_break(true) __try {
                                if (_is_valid_handle(g_tee_file_stdin_mutex)) {
                                    WaitForSingleObject(g_tee_file_stdin_mutex, INFINITE);
                                }

                                SetFilePointer(g_tee_file_stdin_handle, 0, NULL, FILE_END);

                                WriteFile(g_tee_file_stdin_handle, stdin_byte_buf.data(), num_bytes_read, &num_bytes_written, NULL);
                                if (thread_data.cancel_io) break;

                                if (g_flags.tee_stdin_file_flush || g_flags.tee_stdin_flush || g_flags.tee_inout_flush) {
                                    FlushFileBuffers(g_tee_file_stdin_handle);
                                    if (thread_data.cancel_io) break;
                                }
                            }
                            __finally {
                                if (_is_valid_handle(g_tee_file_stdin_mutex)) {
                                    ReleaseMutex(g_tee_file_stdin_mutex);
                                }
                            } }();

                            if (thread_data.cancel_io) break;
                        }

                        if (_is_valid_handle(g_tee_file_stdout_handle)) {
                            [&]() { if_break(true) __try {
                                if (_is_valid_handle(g_tee_file_stdout_mutex)) {
                                    WaitForSingleObject(g_tee_file_stdout_mutex, INFINITE);
                                }

                                SetFilePointer(g_tee_file_stdout_handle, 0, NULL, FILE_END);

                                WriteFile(g_tee_file_stdout_handle, stdin_byte_buf.data(), num_bytes_read, &num_bytes_written, NULL);
                                if (thread_data.cancel_io) break;

                                if (g_flags.tee_stdout_file_flush || g_flags.tee_stdout_flush || g_flags.tee_inout_flush || g_flags.tee_output_flush) {
                                    FlushFileBuffers(g_tee_file_stdout_handle);
                                    if (thread_data.cancel_io) break;
                                }
                            }
                            __finally {
                                if (_is_valid_handle(g_tee_file_stdout_mutex)) {
                                    ReleaseMutex(g_tee_file_stdout_mutex);
                                }
                            } }();

                            if (thread_data.cancel_io) break;
                        }

                        if (_is_valid_handle(g_tee_named_pipe_stdin_handle)) {
                            WriteFile(g_tee_named_pipe_stdin_handle, stdin_byte_buf.data(), num_bytes_read, &num_bytes_written, NULL);
                            if (thread_data.cancel_io) break;

                            if (g_flags.tee_stdin_pipe_flush || g_flags.tee_stdin_flush || g_flags.tee_inout_flush) {
                                FlushFileBuffers(g_tee_named_pipe_stdin_handle);
                                if (thread_data.cancel_io) break;
                            }
                        }

                        if (_is_valid_handle(g_tee_named_pipe_stdout_handle)) {
                            WriteFile(g_tee_named_pipe_stdout_handle, stdin_byte_buf.data(), num_bytes_read, &num_bytes_written, NULL);
                            if (thread_data.cancel_io) break;

                            if (g_flags.tee_stdout_pipe_flush || g_flags.tee_stdout_flush || g_flags.tee_inout_flush || g_flags.tee_output_flush) {
                                FlushFileBuffers(g_tee_named_pipe_stdout_handle);
                                if (thread_data.cancel_io) break;
                            }
                        }

                        if (_is_valid_handle(g_stdout_handle)) {
                            SetLastError(0); // just in case
                            if (WriteFile(g_stdout_handle, stdin_byte_buf.data(), num_bytes_read, &num_bytes_write, NULL)) {
                                if (g_flags.stdin_output_flush || g_flags.stdout_flush || g_flags.inout_flush || g_flags.output_flush) {
                                    FlushFileBuffers(g_stdout_handle);
                                }

                                if (thread_data.cancel_io) break;
                            }
                            else {
                                if (thread_data.cancel_io) break;

                                win_error = GetLastError();
                                if (win_error) {
                                    thread_data.ret = err_io_error;
                                    thread_data.win_error = win_error;
                                    if (!g_flags.no_print_gen_error_string) {
                                        thread_data.msg =
                                            _format_stderr_message(_T("stdout write error: win_error=0x%08X (%d)\n"),
                                                win_error, win_error);
                                    }
                                    if (g_flags.print_win_error_string && win_error) {
                                        thread_data.msg +=
                                            _format_win_error_message(win_error, g_options.win_error_langid);
                                    }
                                    thread_data.is_error = true;
                                }

                                stream_eof = true;
                            }
                        }
                    }
                    else if (!num_bytes_avail) {
                        SetLastError(0); // just in case
                        if (!WriteFile(g_stdout_handle, stdin_byte_buf.data(), 0, &num_bytes_write, NULL)) {
                            if (thread_data.cancel_io) break;

                            stream_eof = true;
                        }

                        if (!stream_eof) {
                            // loop wait
                            Sleep(20);

                            if (thread_data.cancel_io) break;
                        }
                    }
                }

                // explicitly disconnect/close all stdout handles here to trigger the child process reaction

                // CAUTION:
                //  Always flush before disconnection/close, otherwise the last bytes would be lost!
                //
                FlushFileBuffers(g_stdout_handle);

                if (!g_options.reopen_stdout_as_server_pipe.empty()) {
                    DisconnectNamedPipe(g_stdout_handle);
                }
                _close_handle(g_stdout_handle);
                //_close(STDOUT_FILENO);
            } break;
            }
        }();
    }
    __finally {
        ;
    } }();

    return 0;
}

// handle_type:
//  0 - standard handle reopen
//  1 - tee output handle open
//
// co_stream_type:
//  0 - stdin
//  1 - stdout
//  2 - stderr
//
template <int handle_type, int co_stream_type>
DWORD WINAPI ConnectServerNamedPipeThread(LPVOID lpParam)
{
    ConnectNamedPipeThreadData & thread_data = *static_cast<ConnectNamedPipeThreadData *>(lpParam);

    thread_data.ret = err_unspecified;
    thread_data.is_error = true;

    OVERLAPPED connection_await_overlapped{};

    DWORD win_error = 0;

    // NOTE:
    //  labda to bypass msvc error: `error C2712: Cannot use __try in functions that require object unwinding`
    //
    return [&]() -> DWORD { __try {
        return [&]() -> DWORD {
            switch (co_stream_type) {
            case 0: // stdin
            {
                switch (handle_type) {
                case 0: {
                    SetLastError(0); // just in case
                    if (!ConnectNamedPipe(g_reopen_stdin_handle, &connection_await_overlapped)) {
                        win_error = GetLastError();
                        if (win_error != ERROR_IO_PENDING && win_error != ERROR_PIPE_LISTENING) {
                            thread_data.ret = err_named_pipe_connect_error;
                            thread_data.win_error = win_error;
                            if (!g_flags.no_print_gen_error_string) {
                                thread_data.msg =
                                    _format_stderr_message(_T("could not initiate connection of reopened stdin as server named pipe end: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                                        win_error, win_error, g_options.reopen_stdin_as_server_pipe.c_str());
                            }
                            if (g_flags.print_win_error_string && win_error) {
                                thread_data.msg +=
                                    _format_win_error_message(win_error, g_options.win_error_langid);
                            }
                            return 1;
                        }
                    }

                    // server named pipe end wait loop
                    const auto start_time_ms = g_options.win_ver_major >= 6 ? GetTickCount64() : GetTickCount();

                    while (true) {
                        if (thread_data.cancel_io) return -1;

                        // NOTE:
                        //  Based on:
                        //    `HasOverlappedIoCompleted macro (winbase.h)` : https://docs.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-hasoverlappediocompleted:
                        //
                        //    Do not call this macro unless the call to GetLastError returns ERROR_IO_PENDING, indicating that the overlapped I/O has started.
                        //

                        if (HasOverlappedIoCompleted(&connection_await_overlapped)) {
                            break;
                        }

                        const auto end_time_ms = g_options.win_ver_major >= 6 ? GetTickCount64() : GetTickCount();

                        const auto time_delta_ms = end_time_ms >= start_time_ms ? end_time_ms - start_time_ms : 0;

                        if (time_delta_ms >= g_options.reopen_stdin_as_server_pipe_connect_timeout_ms) {
                            thread_data.ret = err_named_pipe_connect_timeout;
                            if (!g_flags.no_print_gen_error_string) {
                                thread_data.msg =
                                    _format_stderr_message(_T("server connection timeout of reopened stdin as server named pipe end: pipe=\"%s\" timeout=%u ms\n"),
                                        g_options.reopen_stdin_as_server_pipe.c_str(), g_options.reopen_stdin_as_server_pipe_connect_timeout_ms);
                            }
                            return 1;
                        }

                        Sleep(20);
                    }
                } break;

                case 1: {
                    SetLastError(0); // just in case
                    if (!ConnectNamedPipe(g_tee_named_pipe_stdin_handle, &connection_await_overlapped)) {
                        win_error = GetLastError();
                        if (win_error != ERROR_IO_PENDING && win_error != ERROR_PIPE_LISTENING) {
                            thread_data.ret = err_named_pipe_connect_error;
                            thread_data.win_error = win_error;
                            if (!g_flags.no_print_gen_error_string) {
                                thread_data.msg =
                                    _format_stderr_message(_T("could not initiate connection of stdin tee as server named pipe end: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                                        win_error, win_error, g_options.tee_stdin_to_server_pipe.c_str());
                            }
                            if (g_flags.print_win_error_string && win_error) {
                                thread_data.msg +=
                                    _format_win_error_message(win_error, g_options.win_error_langid);
                            }
                            return 1;
                        }
                    }

                    // server named pipe end wait loop
                    const auto start_time_ms = g_options.win_ver_major >= 6 ? GetTickCount64() : GetTickCount();

                    while (true) {
                        if (thread_data.cancel_io) return -1;

                        // NOTE:
                        //  Based on:
                        //    `HasOverlappedIoCompleted macro (winbase.h)` : https://docs.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-hasoverlappediocompleted:
                        //
                        //    Do not call this macro unless the call to GetLastError returns ERROR_IO_PENDING, indicating that the overlapped I/O has started.
                        //

                        if (HasOverlappedIoCompleted(&connection_await_overlapped)) {
                            break;
                        }

                        const auto end_time_ms = g_options.win_ver_major >= 6 ? GetTickCount64() : GetTickCount();

                        const auto time_delta_ms = end_time_ms >= start_time_ms ? end_time_ms - start_time_ms : 0;

                        if (time_delta_ms >= g_options.tee_stdin_to_server_pipe_connect_timeout_ms) {
                            thread_data.ret = err_named_pipe_connect_timeout;
                            if (!g_flags.no_print_gen_error_string) {
                                thread_data.msg =
                                    _format_stderr_message(_T("server connection timeout of stdin tee as server named pipe end: pipe=\"%s\" timeout=%u ms\n"),
                                        g_options.tee_stdin_to_server_pipe.c_str(), g_options.tee_stdin_to_server_pipe_connect_timeout_ms);
                            }
                            return 1;
                        }

                        Sleep(20);
                    }
                } break;

                default:
                    return 1;
                }
            } break;

            case 1: // stdout
            {
                switch (handle_type) {
                case 0: {
                    SetLastError(0); // just in case
                    if (!ConnectNamedPipe(g_reopen_stdout_handle, &connection_await_overlapped)) {
                        win_error = GetLastError();
                        if (win_error != ERROR_IO_PENDING && win_error != ERROR_PIPE_LISTENING) {
                            thread_data.ret = err_named_pipe_connect_error;
                            thread_data.win_error = win_error;
                            if (!g_flags.no_print_gen_error_string) {
                                thread_data.msg =
                                    _format_stderr_message(_T("could not initiate connection of reopened stdout as server named pipe end: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                                        win_error, win_error, g_options.reopen_stdout_as_server_pipe.c_str());
                            }
                            if (g_flags.print_win_error_string && win_error) {
                                thread_data.msg +=
                                    _format_win_error_message(win_error, g_options.win_error_langid);
                            }
                            return 1;
                        }
                    }

                    // server named pipe end wait loop
                    const auto start_time_ms = g_options.win_ver_major >= 6 ? GetTickCount64() : GetTickCount();

                    while (true) {
                        if (thread_data.cancel_io) return -1;

                        // NOTE:
                        //  Based on:
                        //    `HasOverlappedIoCompleted macro (winbase.h)` : https://docs.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-hasoverlappediocompleted:
                        //
                        //    Do not call this macro unless the call to GetLastError returns ERROR_IO_PENDING, indicating that the overlapped I/O has started.
                        //

                        if (HasOverlappedIoCompleted(&connection_await_overlapped)) {
                            break;
                        }

                        const auto end_time_ms = g_options.win_ver_major >= 6 ? GetTickCount64() : GetTickCount();

                        const auto time_delta_ms = end_time_ms >= start_time_ms ? end_time_ms - start_time_ms : 0;

                        if (time_delta_ms >= g_options.reopen_stdout_as_server_pipe_connect_timeout_ms) {
                            thread_data.ret = err_named_pipe_connect_timeout;
                            if (!g_flags.no_print_gen_error_string) {
                                thread_data.msg =
                                    _format_stderr_message(_T("server connection timeout of reopened stdout as server named pipe end: pipe=\"%s\" timeout=%u ms\n"),
                                        g_options.reopen_stdout_as_server_pipe.c_str(), g_options.reopen_stdout_as_server_pipe_connect_timeout_ms);
                            }
                            return 1;
                        }

                        Sleep(20);
                    }
                } break;

                case 1: {
                    SetLastError(0); // just in case
                    if (!ConnectNamedPipe(g_tee_named_pipe_stdout_handle, &connection_await_overlapped)) {
                        win_error = GetLastError();
                        if (win_error != ERROR_IO_PENDING && win_error != ERROR_PIPE_LISTENING) {
                            thread_data.ret = err_named_pipe_connect_error;
                            thread_data.win_error = win_error;
                            if (!g_flags.no_print_gen_error_string) {
                                thread_data.msg =
                                    _format_stderr_message(_T("could not initiate connection of stdout tee as server named pipe end: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                                        win_error, win_error, g_options.tee_stdout_to_server_pipe.c_str());
                            }
                            if (g_flags.print_win_error_string && win_error) {
                                thread_data.msg +=
                                    _format_win_error_message(win_error, g_options.win_error_langid);
                            }
                            return 1;
                        }
                    }

                    // server named pipe end wait loop
                    const auto start_time_ms = g_options.win_ver_major >= 6 ? GetTickCount64() : GetTickCount();

                    while (true) {
                        if (thread_data.cancel_io) return -1;

                        // NOTE:
                        //  Based on:
                        //    `HasOverlappedIoCompleted macro (winbase.h)` : https://docs.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-hasoverlappediocompleted:
                        //
                        //    Do not call this macro unless the call to GetLastError returns ERROR_IO_PENDING, indicating that the overlapped I/O has started.
                        //

                        if (HasOverlappedIoCompleted(&connection_await_overlapped)) {
                            break;
                        }

                        const auto end_time_ms = g_options.win_ver_major >= 6 ? GetTickCount64() : GetTickCount();

                        const auto time_delta_ms = end_time_ms >= start_time_ms ? end_time_ms - start_time_ms : 0;

                        if (time_delta_ms >= g_options.tee_stdout_to_server_pipe_connect_timeout_ms) {
                            thread_data.ret = err_named_pipe_connect_timeout;
                            if (!g_flags.no_print_gen_error_string) {
                                thread_data.msg =
                                    _format_stderr_message(_T("server connection timeout of stdout tee as server named pipe end: pipe=\"%s\" timeout=%u ms\n"),
                                        g_options.tee_stdout_to_server_pipe.c_str(), g_options.tee_stdout_to_server_pipe_connect_timeout_ms);
                            }
                            return 1;
                        }

                        Sleep(20);
                    }
                } break;

                default:
                    return 1;
                }
            } break;

            case 2: // stderr
            {
                switch (handle_type) {
                case 0: {
                    SetLastError(0); // just in case
                    if (!ConnectNamedPipe(g_reopen_stderr_handle, &connection_await_overlapped)) {
                        win_error = GetLastError();
                        if (win_error != ERROR_IO_PENDING && win_error != ERROR_PIPE_LISTENING) {
                            thread_data.ret = err_named_pipe_connect_error;
                            thread_data.win_error = win_error;
                            if (!g_flags.no_print_gen_error_string) {
                                thread_data.msg =
                                    _format_stderr_message(_T("could not initiate connection of reopened stderr as server named pipe end: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                                        win_error, win_error, g_options.reopen_stderr_as_server_pipe.c_str());
                            }
                            if (g_flags.print_win_error_string && win_error) {
                                thread_data.msg +=
                                    _format_win_error_message(win_error, g_options.win_error_langid);
                            }
                            return 1;
                        }
                    }

                    // server named pipe end wait loop
                    const auto start_time_ms = g_options.win_ver_major >= 6 ? GetTickCount64() : GetTickCount();

                    while (true) {
                        if (thread_data.cancel_io) return -1;

                        // NOTE:
                        //  Based on:
                        //    `HasOverlappedIoCompleted macro (winbase.h)` : https://docs.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-hasoverlappediocompleted:
                        //
                        //    Do not call this macro unless the call to GetLastError returns ERROR_IO_PENDING, indicating that the overlapped I/O has started.
                        //

                        if (HasOverlappedIoCompleted(&connection_await_overlapped)) {
                            break;
                        }

                        const auto end_time_ms = g_options.win_ver_major >= 6 ? GetTickCount64() : GetTickCount();

                        const auto time_delta_ms = end_time_ms >= start_time_ms ? end_time_ms - start_time_ms : 0;

                        if (time_delta_ms >= g_options.reopen_stderr_as_server_pipe_connect_timeout_ms) {
                            thread_data.ret = err_named_pipe_connect_timeout;
                            if (!g_flags.no_print_gen_error_string) {
                                thread_data.msg =
                                    _format_stderr_message(_T("server connection timeout of reopened stderr as server named pipe end: pipe=\"%s\" timeout=%u ms\n"),
                                        g_options.reopen_stderr_as_server_pipe.c_str(), g_options.reopen_stderr_as_server_pipe_connect_timeout_ms);
                            }
                            return 1;
                        }

                        Sleep(20);
                    }
                } break;

                case 1: {
                    SetLastError(0); // just in case
                    if (!ConnectNamedPipe(g_tee_named_pipe_stderr_handle, &connection_await_overlapped)) {
                        win_error = GetLastError();
                        if (win_error != ERROR_IO_PENDING && win_error != ERROR_PIPE_LISTENING) {
                            thread_data.ret = err_named_pipe_connect_error;
                            thread_data.win_error = win_error;
                            if (!g_flags.no_print_gen_error_string) {
                                thread_data.msg =
                                    _format_stderr_message(_T("could not initiate connection of stderr tee as server named pipe end: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                                        win_error, win_error, g_options.tee_stderr_to_server_pipe.c_str());
                            }
                            if (g_flags.print_win_error_string && win_error) {
                                thread_data.msg +=
                                    _format_win_error_message(win_error, g_options.win_error_langid);
                            }
                            return 1;
                        }
                    }

                    // server named pipe end wait loop
                    const auto start_time_ms = g_options.win_ver_major >= 6 ? GetTickCount64() : GetTickCount();

                    while (true) {
                        if (thread_data.cancel_io) return -1;

                        // NOTE:
                        //  Based on:
                        //    `HasOverlappedIoCompleted macro (winbase.h)` : https://docs.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-hasoverlappediocompleted:
                        //
                        //    Do not call this macro unless the call to GetLastError returns ERROR_IO_PENDING, indicating that the overlapped I/O has started.
                        //

                        if (HasOverlappedIoCompleted(&connection_await_overlapped)) {
                            break;
                        }

                        const auto end_time_ms = g_options.win_ver_major >= 6 ? GetTickCount64() : GetTickCount();

                        const auto time_delta_ms = end_time_ms >= start_time_ms ? end_time_ms - start_time_ms : 0;

                        if (time_delta_ms >= g_options.tee_stderr_to_server_pipe_connect_timeout_ms) {
                            thread_data.ret = err_named_pipe_connect_timeout;
                            if (!g_flags.no_print_gen_error_string) {
                                thread_data.msg =
                                    _format_stderr_message(_T("server connection timeout of stderr tee as server named pipe end: pipe=\"%s\" timeout=%u ms\n"),
                                        g_options.tee_stderr_to_server_pipe.c_str(), g_options.tee_stderr_to_server_pipe_connect_timeout_ms);
                            }
                            return 1;
                        }

                        Sleep(20);
                    }
                } break;

                default:
                    return 1;
                }
            } break;

            default:
                return 1;
            }

            thread_data.is_error = false;

            return 0;
        }();
    }
    __finally {
        ;
    }

    return 0;
    }();
}

// handle_type:
//  0 - standard handle reopen
//  1 - tee output handle open
//
// co_stream_type:
//  0 - stdin
//  1 - stdout
//  2 - stderr
//
template <int handle_type, int co_stream_type>
DWORD WINAPI ConnectClientNamedPipeThread(LPVOID lpParam)
{
    ConnectNamedPipeThreadData & thread_data = *static_cast<ConnectNamedPipeThreadData *>(lpParam);

    thread_data.ret = err_unspecified;
    thread_data.is_error = true;

    SECURITY_ATTRIBUTES sa{};

    sa.nLength = sizeof(sa);
    sa.bInheritHandle = g_no_std_inherit ? FALSE : TRUE;

    DWORD win_error = 0;

    // NOTE:
    //  labda to bypass msvc error: `error C2712: Cannot use __try in functions that require object unwinding`
    //
    return [&]() -> DWORD { __try {
        return [&]() -> DWORD {
            switch (co_stream_type) {
            case 0: // stdin
            {
                switch (handle_type) {
                case 0: {
                    const auto pipe_name_str = std::tstring(_T("\\\\.\\pipe\\")) + g_options.reopen_stdin_as_client_pipe;

                    // client named pipe end wait loop
                    const auto start_time_ms = g_options.win_ver_major >= 6 ? GetTickCount64() : GetTickCount();

                    while (true) {
                        if (thread_data.cancel_io) return -1;

                        // CAUTION:
                        //  Based on:
                        //    https://stackoverflow.com/questions/8529193/named-pipe-createfile-returns-invalid-handle-value-and-getlasterror-returns/8533189#8533189
                        //    `Named Pipe Client` : https://docs.microsoft.com/en-us/windows/win32/ipc/named-pipe-client
                        //
                        //    A named pipe client uses the CreateFile function to open a handle to a named pipe.
                        //    If the pipe exists but all of its instances are busy, CreateFile returns INVALID_HANDLE_VALUE and
                        //    the GetLastError function returns ERROR_PIPE_BUSY. When this happens, the named pipe client uses
                        //    the WaitNamedPipe function to wait for an instance of the named pipe to become available.
                        //
                        //  So, we still use `CreateFile` in the loop just in case of `ERROR_PIPE_BUSY` error.
                        //

                        SetLastError(0); // just in case
                        if (_is_valid_handle(g_reopen_stdin_handle =
                            CreateFile(pipe_name_str.c_str(),
                                GENERIC_READ, FILE_SHARE_READ, &sa, // must use `sa` to setup inheritance
                                OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL))) {
                            break;
                        }

                        win_error = GetLastError();
                        if (win_error != ERROR_PIPE_BUSY) {
                            thread_data.ret = err_named_pipe_connect_error;
                            thread_data.win_error = win_error;
                            if (!g_flags.no_print_gen_error_string) {
                                thread_data.msg =
                                    _format_stderr_message(_T("could not client connect to reopened stdin as client named pipe end: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                                        win_error, win_error, g_options.reopen_stdin_as_client_pipe.c_str());
                            }
                            if (g_flags.print_win_error_string && win_error) {
                                thread_data.msg +=
                                    _format_win_error_message(win_error, g_options.win_error_langid);
                            }
                            return 1;
                        }

                        {
                            const auto end_time_ms = g_options.win_ver_major >= 6 ? GetTickCount64() : GetTickCount();

                            const auto time_delta_ms = end_time_ms >= start_time_ms ? end_time_ms - start_time_ms : 0;

                            if (time_delta_ms >= g_options.reopen_stdin_as_client_pipe_connect_timeout_ms) {
                                thread_data.ret = err_named_pipe_connect_timeout;
                                if (!g_flags.no_print_gen_error_string) {
                                    thread_data.msg =
                                        _format_stderr_message(_T("client connection timeout of reopened stdin as client named pipe end: pipe=\"%s\" timeout=%u ms\n"),
                                            g_options.reopen_stdin_as_client_pipe.c_str(), g_options.reopen_stdin_as_client_pipe_connect_timeout_ms);
                                }
                                return 1;
                            }

                            const auto wait_named_pipe_timeout_ms = decltype(time_delta_ms){ g_options.reopen_stdin_as_client_pipe_connect_timeout_ms } -time_delta_ms;

                            if (WaitNamedPipe(pipe_name_str.c_str(), (DWORD)wait_named_pipe_timeout_ms)) {
                                continue;
                            }
                        }

                        // check for timeout again
                        {
                            const auto end_time_ms = g_options.win_ver_major >= 6 ? GetTickCount64() : GetTickCount();

                            const auto time_delta_ms = end_time_ms >= start_time_ms ? end_time_ms - start_time_ms : 0;

                            if (time_delta_ms >= g_options.reopen_stdin_as_client_pipe_connect_timeout_ms) {
                                thread_data.ret = err_named_pipe_connect_timeout;
                                if (!g_flags.no_print_gen_error_string) {
                                    thread_data.msg =
                                        _format_stderr_message(_T("client connection timeout of reopened stdin as client named pipe end: pipe=\"%s\" timeout=%u ms\n"),
                                            g_options.reopen_stdin_as_client_pipe.c_str(), g_options.reopen_stdin_as_client_pipe_connect_timeout_ms);
                                }
                                return 1;
                            }
                        }
                    }
                } break;

                case 1: {
                    const auto pipe_name_str = std::tstring(_T("\\\\.\\pipe\\")) + g_options.tee_stdin_to_client_pipe;

                    // client named pipe end wait loop
                    const auto start_time_ms = g_options.win_ver_major >= 6 ? GetTickCount64() : GetTickCount();

                    while (true) {
                        if (thread_data.cancel_io) return -1;

                        // CAUTION:
                        //  Based on:
                        //    https://stackoverflow.com/questions/8529193/named-pipe-createfile-returns-invalid-handle-value-and-getlasterror-returns/8533189#8533189
                        //    `Named Pipe Client` : https://docs.microsoft.com/en-us/windows/win32/ipc/named-pipe-client
                        //
                        //    A named pipe client uses the CreateFile function to open a handle to a named pipe.
                        //    If the pipe exists but all of its instances are busy, CreateFile returns INVALID_HANDLE_VALUE and
                        //    the GetLastError function returns ERROR_PIPE_BUSY. When this happens, the named pipe client uses
                        //    the WaitNamedPipe function to wait for an instance of the named pipe to become available.
                        //
                        //  So, we still use `CreateFile` in the loop just in case of `ERROR_PIPE_BUSY` error.
                        //

                        SetLastError(0); // just in case
                        if (_is_valid_handle(g_tee_named_pipe_stdin_handle =
                            CreateFile(pipe_name_str.c_str(),
                                GENERIC_WRITE, FILE_SHARE_WRITE, NULL,
                                OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL))) {
                            break;
                        }

                        win_error = GetLastError();
                        if (win_error != ERROR_PIPE_BUSY) {
                            thread_data.ret = err_named_pipe_connect_error;
                            thread_data.win_error = win_error;
                            if (!g_flags.no_print_gen_error_string) {
                                thread_data.msg =
                                    _format_stderr_message(_T("could not client connect to stdin tee as client named pipe end: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                                        win_error, win_error, g_options.tee_stdin_to_client_pipe.c_str());
                            }
                            if (g_flags.print_win_error_string && win_error) {
                                thread_data.msg +=
                                    _format_win_error_message(win_error, g_options.win_error_langid);
                            }
                            return 1;
                        }

                        {
                            const auto end_time_ms = g_options.win_ver_major >= 6 ? GetTickCount64() : GetTickCount();

                            const auto time_delta_ms = end_time_ms >= start_time_ms ? end_time_ms - start_time_ms : 0;

                            if (time_delta_ms >= g_options.tee_stdin_to_server_pipe_connect_timeout_ms) {
                                thread_data.ret = err_named_pipe_connect_timeout;
                                if (!g_flags.no_print_gen_error_string) {
                                    thread_data.msg =
                                        _format_stderr_message(_T("client connection timeout of stdin tee as client named pipe end: pipe=\"%s\" timeout=%u ms\n"),
                                            g_options.tee_stdin_to_client_pipe.c_str(), g_options.tee_stdin_to_server_pipe_connect_timeout_ms);
                                }
                                return 1;
                            }

                            const auto wait_named_pipe_timeout_ms = decltype(time_delta_ms){ g_options.tee_stdin_to_server_pipe_connect_timeout_ms } -time_delta_ms;

                            if (WaitNamedPipe(pipe_name_str.c_str(), (DWORD)wait_named_pipe_timeout_ms)) {
                                continue;
                            }
                        }

                        // check for timeout again
                        {
                            const auto end_time_ms = g_options.win_ver_major >= 6 ? GetTickCount64() : GetTickCount();

                            const auto time_delta_ms = end_time_ms >= start_time_ms ? end_time_ms - start_time_ms : 0;

                            if (time_delta_ms >= g_options.tee_stdin_to_server_pipe_connect_timeout_ms) {
                                thread_data.ret = err_named_pipe_connect_timeout;
                                if (!g_flags.no_print_gen_error_string) {
                                    thread_data.msg =
                                        _format_stderr_message(_T("client connection timeout of stdin tee as client named pipe end: pipe=\"%s\" timeout=%u ms\n"),
                                            g_options.tee_stdin_to_client_pipe.c_str(), g_options.tee_stdin_to_server_pipe_connect_timeout_ms);
                                }
                                return 1;
                            }
                        }
                    }
                } break;

                default:
                    return 1;
                }
            } break;

            case 1: // stdout
            {
                switch (handle_type) {
                case 0: {
                    const auto pipe_name_str = std::tstring(_T("\\\\.\\pipe\\")) + g_options.reopen_stdout_as_client_pipe;

                    // client named pipe end wait loop
                    const auto start_time_ms = g_options.win_ver_major >= 6 ? GetTickCount64() : GetTickCount();

                    while (true) {
                        if (thread_data.cancel_io) return -1;

                        // CAUTION:
                        //  Based on:
                        //    https://stackoverflow.com/questions/8529193/named-pipe-createfile-returns-invalid-handle-value-and-getlasterror-returns/8533189#8533189
                        //    `Named Pipe Client` : https://docs.microsoft.com/en-us/windows/win32/ipc/named-pipe-client
                        //
                        //    A named pipe client uses the CreateFile function to open a handle to a named pipe.
                        //    If the pipe exists but all of its instances are busy, CreateFile returns INVALID_HANDLE_VALUE and
                        //    the GetLastError function returns ERROR_PIPE_BUSY. When this happens, the named pipe client uses
                        //    the WaitNamedPipe function to wait for an instance of the named pipe to become available.
                        //
                        //  So, we still use `CreateFile` in the loop just in case of `ERROR_PIPE_BUSY` error.
                        //

                        SetLastError(0); // just in case
                        if (_is_valid_handle(g_reopen_stdout_handle =
                            CreateFile(pipe_name_str.c_str(),
                                GENERIC_WRITE, FILE_SHARE_WRITE, &sa, // must use `sa` to setup inheritance
                                OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL))) {
                            break;
                        }

                        win_error = GetLastError();
                        if (win_error != ERROR_PIPE_BUSY) {
                            thread_data.ret = err_named_pipe_connect_error;
                            thread_data.win_error = win_error;
                            if (!g_flags.no_print_gen_error_string) {
                                thread_data.msg =
                                    _format_stderr_message(_T("could not client connect to reopened stdout as client named pipe end: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                                        win_error, win_error, g_options.reopen_stdout_as_client_pipe.c_str());
                            }
                            if (g_flags.print_win_error_string && win_error) {
                                thread_data.msg +=
                                    _format_win_error_message(win_error, g_options.win_error_langid);
                            }
                            return 1;
                        }

                        {
                            const auto end_time_ms = g_options.win_ver_major >= 6 ? GetTickCount64() : GetTickCount();

                            const auto time_delta_ms = end_time_ms >= start_time_ms ? end_time_ms - start_time_ms : 0;

                            if (time_delta_ms >= g_options.reopen_stdout_as_client_pipe_connect_timeout_ms) {
                                thread_data.ret = err_named_pipe_connect_timeout;
                                if (!g_flags.no_print_gen_error_string) {
                                    thread_data.msg =
                                        _format_stderr_message(_T("client connection timeout of reopened stdout as client named pipe end: pipe=\"%s\" timeout=%u ms\n"),
                                            g_options.reopen_stdout_as_client_pipe.c_str(), g_options.reopen_stdout_as_client_pipe_connect_timeout_ms);
                                }
                                return 1;
                            }

                            const auto wait_named_pipe_timeout_ms = decltype(time_delta_ms){ g_options.reopen_stdout_as_client_pipe_connect_timeout_ms } -time_delta_ms;

                            if (WaitNamedPipe(pipe_name_str.c_str(), (DWORD)wait_named_pipe_timeout_ms)) {
                                continue;
                            }
                        }

                        // check for timeout again
                        {
                            const auto end_time_ms = g_options.win_ver_major >= 6 ? GetTickCount64() : GetTickCount();

                            const auto time_delta_ms = end_time_ms >= start_time_ms ? end_time_ms - start_time_ms : 0;

                            if (time_delta_ms >= g_options.reopen_stdout_as_client_pipe_connect_timeout_ms) {
                                thread_data.ret = err_named_pipe_connect_timeout;
                                if (!g_flags.no_print_gen_error_string) {
                                    thread_data.msg =
                                        _format_stderr_message(_T("client connection timeout of reopened stdout as client named pipe end: pipe=\"%s\" timeout=%u ms\n"),
                                            g_options.reopen_stdout_as_client_pipe.c_str(), g_options.reopen_stdout_as_client_pipe_connect_timeout_ms);
                                }
                                return 1;
                            }
                        }
                    }
                } break;

                case 1: {
                    const auto pipe_name_str = std::tstring(_T("\\\\.\\pipe\\")) + g_options.tee_stdout_to_client_pipe;

                    // client named pipe end wait loop
                    const auto start_time_ms = g_options.win_ver_major >= 6 ? GetTickCount64() : GetTickCount();

                    while (true) {
                        if (thread_data.cancel_io) return -1;

                        // CAUTION:
                        //  Based on:
                        //    https://stackoverflow.com/questions/8529193/named-pipe-createfile-returns-invalid-handle-value-and-getlasterror-returns/8533189#8533189
                        //    `Named Pipe Client` : https://docs.microsoft.com/en-us/windows/win32/ipc/named-pipe-client
                        //
                        //    A named pipe client uses the CreateFile function to open a handle to a named pipe.
                        //    If the pipe exists but all of its instances are busy, CreateFile returns INVALID_HANDLE_VALUE and
                        //    the GetLastError function returns ERROR_PIPE_BUSY. When this happens, the named pipe client uses
                        //    the WaitNamedPipe function to wait for an instance of the named pipe to become available.
                        //
                        //  So, we still use `CreateFile` in the loop just in case of `ERROR_PIPE_BUSY` error.
                        //

                        SetLastError(0); // just in case
                        if (_is_valid_handle(g_tee_named_pipe_stdout_handle =
                            CreateFile(pipe_name_str.c_str(),
                                GENERIC_WRITE, FILE_SHARE_WRITE, NULL,
                                OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL))) {
                            break;
                        }

                        win_error = GetLastError();
                        if (win_error != ERROR_PIPE_BUSY) {
                            thread_data.ret = err_named_pipe_connect_error;
                            thread_data.win_error = win_error;
                            if (!g_flags.no_print_gen_error_string) {
                                thread_data.msg =
                                    _format_stderr_message(_T("could not client connect to stdout tee as client named pipe end: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                                        win_error, win_error, g_options.tee_stdout_to_client_pipe.c_str());
                            }
                            if (g_flags.print_win_error_string && win_error) {
                                thread_data.msg +=
                                    _format_win_error_message(win_error, g_options.win_error_langid);
                            }
                            return 1;
                        }

                        {
                            const auto end_time_ms = g_options.win_ver_major >= 6 ? GetTickCount64() : GetTickCount();

                            const auto time_delta_ms = end_time_ms >= start_time_ms ? end_time_ms - start_time_ms : 0;

                            if (time_delta_ms >= g_options.tee_stdout_to_server_pipe_connect_timeout_ms) {
                                thread_data.ret = err_named_pipe_connect_timeout;
                                if (!g_flags.no_print_gen_error_string) {
                                    thread_data.msg =
                                        _format_stderr_message(_T("client connection timeout of stdout tee as client named pipe end: pipe=\"%s\" timeout=%u ms\n"),
                                            g_options.tee_stdout_to_client_pipe.c_str(), g_options.tee_stdout_to_server_pipe_connect_timeout_ms);
                                }
                                return 1;
                            }

                            const auto wait_named_pipe_timeout_ms = decltype(time_delta_ms){ g_options.tee_stdout_to_server_pipe_connect_timeout_ms } -time_delta_ms;

                            if (WaitNamedPipe(pipe_name_str.c_str(), (DWORD)wait_named_pipe_timeout_ms)) {
                                continue;
                            }
                        }

                        // check for timeout again
                        {
                            const auto end_time_ms = g_options.win_ver_major >= 6 ? GetTickCount64() : GetTickCount();

                            const auto time_delta_ms = end_time_ms >= start_time_ms ? end_time_ms - start_time_ms : 0;

                            if (time_delta_ms >= g_options.tee_stdout_to_server_pipe_connect_timeout_ms) {
                                thread_data.ret = err_named_pipe_connect_timeout;
                                if (!g_flags.no_print_gen_error_string) {
                                    thread_data.msg =
                                        _format_stderr_message(_T("client connection timeout of stdout tee as client named pipe end: pipe=\"%s\" timeout=%u ms\n"),
                                            g_options.tee_stdout_to_client_pipe.c_str(), g_options.tee_stdout_to_server_pipe_connect_timeout_ms);
                                }
                                return 1;
                            }
                        }
                    }
                } break;

                default:
                    return 1;
                }
            } break;

            case 2: // stderr
            {
                switch (handle_type) {
                case 0: {
                    const auto pipe_name_str = std::tstring(_T("\\\\.\\pipe\\")) + g_options.reopen_stderr_as_client_pipe;

                    // client named pipe end wait loop
                    const auto start_time_ms = g_options.win_ver_major >= 6 ? GetTickCount64() : GetTickCount();

                    while (true) {
                        if (thread_data.cancel_io) return -1;

                        // CAUTION:
                        //  Based on:
                        //    https://stackoverflow.com/questions/8529193/named-pipe-createfile-returns-invalid-handle-value-and-getlasterror-returns/8533189#8533189
                        //    `Named Pipe Client` : https://docs.microsoft.com/en-us/windows/win32/ipc/named-pipe-client
                        //
                        //    A named pipe client uses the CreateFile function to open a handle to a named pipe.
                        //    If the pipe exists but all of its instances are busy, CreateFile returns INVALID_HANDLE_VALUE and
                        //    the GetLastError function returns ERROR_PIPE_BUSY. When this happens, the named pipe client uses
                        //    the WaitNamedPipe function to wait for an instance of the named pipe to become available.
                        //
                        //  So, we still use `CreateFile` in the loop just in case of `ERROR_PIPE_BUSY` error.
                        //

                        SetLastError(0); // just in case
                        if (_is_valid_handle(g_reopen_stderr_handle =
                            CreateFile(pipe_name_str.c_str(),
                                GENERIC_WRITE, FILE_SHARE_WRITE, &sa, // must use `sa` to setup inheritance
                                OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL))) {
                            break;
                        }

                        win_error = GetLastError();
                        if (win_error != ERROR_PIPE_BUSY) {
                            thread_data.ret = err_named_pipe_connect_error;
                            thread_data.win_error = win_error;
                            if (!g_flags.no_print_gen_error_string) {
                                thread_data.msg =
                                    _format_stderr_message(_T("could not client connect to reopened stderr as client named pipe end: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                                        win_error, win_error, g_options.reopen_stderr_as_client_pipe.c_str());
                            }
                            if (g_flags.print_win_error_string && win_error) {
                                thread_data.msg +=
                                    _format_win_error_message(win_error, g_options.win_error_langid);
                            }
                            return 1;
                        }

                        {
                            const auto end_time_ms = g_options.win_ver_major >= 6 ? GetTickCount64() : GetTickCount();

                            const auto time_delta_ms = end_time_ms >= start_time_ms ? end_time_ms - start_time_ms : 0;

                            if (time_delta_ms >= g_options.reopen_stderr_as_client_pipe_connect_timeout_ms) {
                                thread_data.ret = err_named_pipe_connect_timeout;
                                if (!g_flags.no_print_gen_error_string) {
                                    thread_data.msg =
                                        _format_stderr_message(_T("client connection timeout of reopened stderr as client named pipe end: pipe=\"%s\" timeout=%u ms\n"),
                                            g_options.reopen_stderr_as_client_pipe.c_str(), g_options.reopen_stderr_as_client_pipe_connect_timeout_ms);
                                }
                                return 1;
                            }

                            const auto wait_named_pipe_timeout_ms = decltype(time_delta_ms){ g_options.reopen_stderr_as_client_pipe_connect_timeout_ms } -time_delta_ms;

                            if (WaitNamedPipe(pipe_name_str.c_str(), (DWORD)wait_named_pipe_timeout_ms)) {
                                continue;
                            }
                        }

                        // check for timeout again
                        {
                            const auto end_time_ms = g_options.win_ver_major >= 6 ? GetTickCount64() : GetTickCount();

                            const auto time_delta_ms = end_time_ms >= start_time_ms ? end_time_ms - start_time_ms : 0;

                            if (time_delta_ms >= g_options.reopen_stderr_as_client_pipe_connect_timeout_ms) {
                                thread_data.ret = err_named_pipe_connect_timeout;
                                if (!g_flags.no_print_gen_error_string) {
                                    thread_data.msg =
                                        _format_stderr_message(_T("client connection timeout of reopened stderr as client named pipe end: pipe=\"%s\" timeout=%u ms\n"),
                                            g_options.reopen_stderr_as_client_pipe.c_str(), g_options.reopen_stderr_as_client_pipe_connect_timeout_ms);
                                }
                                return 1;
                            }
                        }
                    }
                } break;

                case 1: {
                    const auto pipe_name_str = std::tstring(_T("\\\\.\\pipe\\")) + g_options.tee_stderr_to_client_pipe;

                    // client named pipe end wait loop
                    const auto start_time_ms = g_options.win_ver_major >= 6 ? GetTickCount64() : GetTickCount();

                    while (true) {
                        if (thread_data.cancel_io) return -1;

                        // CAUTION:
                        //  Based on:
                        //    https://stackoverflow.com/questions/8529193/named-pipe-createfile-returns-invalid-handle-value-and-getlasterror-returns/8533189#8533189
                        //    `Named Pipe Client` : https://docs.microsoft.com/en-us/windows/win32/ipc/named-pipe-client
                        //
                        //    A named pipe client uses the CreateFile function to open a handle to a named pipe.
                        //    If the pipe exists but all of its instances are busy, CreateFile returns INVALID_HANDLE_VALUE and
                        //    the GetLastError function returns ERROR_PIPE_BUSY. When this happens, the named pipe client uses
                        //    the WaitNamedPipe function to wait for an instance of the named pipe to become available.
                        //
                        //  So, we still use `CreateFile` in the loop just in case of `ERROR_PIPE_BUSY` error.
                        //

                        SetLastError(0); // just in case
                        if (_is_valid_handle(g_tee_named_pipe_stderr_handle =
                            CreateFile(pipe_name_str.c_str(),
                                GENERIC_WRITE, FILE_SHARE_WRITE, NULL,
                                OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL))) {
                            break;
                        }

                        win_error = GetLastError();
                        if (win_error != ERROR_PIPE_BUSY) {
                            thread_data.ret = err_named_pipe_connect_error;
                            thread_data.win_error = win_error;
                            if (!g_flags.no_print_gen_error_string) {
                                thread_data.msg =
                                    _format_stderr_message(_T("could not client connect to stderr tee as client named pipe end: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                                        win_error, win_error, g_options.tee_stderr_to_client_pipe.c_str());
                            }
                            if (g_flags.print_win_error_string && win_error) {
                                thread_data.msg +=
                                    _format_win_error_message(win_error, g_options.win_error_langid);
                            }
                            return 1;
                        }

                        {
                            const auto end_time_ms = g_options.win_ver_major >= 6 ? GetTickCount64() : GetTickCount();

                            const auto time_delta_ms = end_time_ms >= start_time_ms ? end_time_ms - start_time_ms : 0;

                            if (time_delta_ms >= g_options.tee_stderr_to_server_pipe_connect_timeout_ms) {
                                thread_data.ret = err_named_pipe_connect_timeout;
                                if (!g_flags.no_print_gen_error_string) {
                                    thread_data.msg =
                                        _format_stderr_message(_T("client connection timeout of stderr tee as client named pipe end: pipe=\"%s\" timeout=%u ms\n"),
                                            g_options.tee_stderr_to_client_pipe.c_str(), g_options.tee_stderr_to_server_pipe_connect_timeout_ms);
                                }
                                return 1;
                            }

                            const auto wait_named_pipe_timeout_ms = decltype(time_delta_ms){ g_options.tee_stderr_to_server_pipe_connect_timeout_ms } -time_delta_ms;

                            if (WaitNamedPipe(pipe_name_str.c_str(), (DWORD)wait_named_pipe_timeout_ms)) {
                                continue;
                            }
                        }

                        // check for timeout again
                        {
                            const auto end_time_ms = g_options.win_ver_major >= 6 ? GetTickCount64() : GetTickCount();

                            const auto time_delta_ms = end_time_ms >= start_time_ms ? end_time_ms - start_time_ms : 0;

                            if (time_delta_ms >= g_options.tee_stderr_to_server_pipe_connect_timeout_ms) {
                                thread_data.ret = err_named_pipe_connect_timeout;
                                if (!g_flags.no_print_gen_error_string) {
                                    thread_data.msg =
                                        _format_stderr_message(_T("client connection timeout of stderr tee as client named pipe end: pipe=\"%s\" timeout=%u ms\n"),
                                            g_options.tee_stderr_to_client_pipe.c_str(), g_options.tee_stderr_to_server_pipe_connect_timeout_ms);
                                }
                                return 1;
                            }
                        }
                    }
                } break;

                default:
                    return 1;
                }
            } break;
            }

            thread_data.is_error = false;

            return 0;
        }();
    }
    __finally {
        ;
    }
    return 0;
    }();
}

bool ReopenStdin(int & ret, DWORD & win_error, const Flags & flags, const Options & options, UINT cp_in)
{
    // intercept here specific global variables accidental usage instead of local variables
    static struct {} g_options;
    static struct {} g_flags;

    ret = err_none;
    win_error = 0;

    SECURITY_ATTRIBUTES sa{};

    sa.nLength = sizeof(sa);
    sa.bInheritHandle = g_no_std_inherit ? FALSE : TRUE;

    if (!options.reopen_stdin_as_file.empty()) {
        SetLastError(0); // just in case
        if (!_is_valid_handle(g_reopen_stdin_handle =
                CreateFile(options.reopen_stdin_as_file.c_str(),
                    GENERIC_READ, FILE_SHARE_READ, &sa, // must use `sa` to setup inheritance
                    OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL))) {
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
                _print_stderr_message(_T("could not reopen stdin as file to read: win_error=0x%08X (%d) file=\"%s\"\n"),
                    win_error, win_error, options.reopen_stdin_as_file.c_str());
            }
            if (flags.print_win_error_string && win_error) {
                _print_win_error_message(win_error, options.win_error_langid);
            }
            return false;
        }

        if (!_set_crt_std_handle(g_reopen_stdin_handle, 0, true, !g_no_std_inherit)) {
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
                _print_stderr_message(_T("could not duplicate reopened stdin as file before transfer handle ownership to CRT: win_error=0x%08X (%d) file=\"%s\"\n"),
                    win_error, win_error, options.reopen_stdin_as_file.c_str());
            }
            if (flags.print_win_error_string && win_error) {
                _print_win_error_message(win_error, options.win_error_langid);
            }
            return false;
        }
    }
    else if (!options.reopen_stdin_as_server_pipe.empty()) {
        SetLastError(0); // just in case
        if (!_is_valid_handle(g_reopen_stdin_handle =
            CreateNamedPipe((std::tstring(_T("\\\\.\\pipe\\")) + options.reopen_stdin_as_server_pipe).c_str(),
                PIPE_ACCESS_INBOUND | FILE_FLAG_FIRST_PIPE_INSTANCE | FILE_FLAG_OVERLAPPED,
                PIPE_TYPE_BYTE | PIPE_READMODE_BYTE | PIPE_WAIT | PIPE_REJECT_REMOTE_CLIENTS,
                1, options.reopen_stderr_as_server_pipe_out_buf_size, options.reopen_stderr_as_server_pipe_in_buf_size,
                0, &sa))) {
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
                _print_stderr_message(_T("could not reopen stdin as server named pipe end to read: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                    win_error, win_error, options.reopen_stdin_as_server_pipe.c_str());
            }
            if (flags.print_win_error_string && win_error) {
                _print_win_error_message(win_error, options.win_error_langid);
            }
            return false;
        }

        if (!_set_crt_std_handle(g_reopen_stdin_handle, 0, true, !g_no_std_inherit)) {
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
                _print_stderr_message(_T("could not duplicate reopened stdin as server named pipe end before transfer handle ownership to CRT: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                    win_error, win_error, options.reopen_stdin_as_server_pipe.c_str());
            }
            if (flags.print_win_error_string && win_error) {
                _print_win_error_message(win_error, options.win_error_langid);
            }
            return false;
        }

        g_connect_server_named_pipe_thread_locals[0][0].thread_handle = CreateThread(
            NULL, 0,
            ConnectServerNamedPipeThread<0, 0>, &g_connect_server_named_pipe_thread_locals[0][0].thread_data,
            0,
            &g_connect_server_named_pipe_thread_locals[0][0].thread_id
        );
    }
    else if (!options.reopen_stdin_as_client_pipe.empty()) {
        g_connect_client_named_pipe_thread_locals[0][0].thread_handle = CreateThread(
            NULL, 0,
            ConnectClientNamedPipeThread<0, 0>, &g_connect_client_named_pipe_thread_locals[0][0].thread_data,
            0,
            &g_connect_client_named_pipe_thread_locals[0][0].thread_id
        );
    }

    return true;
}

bool ReopenStdout(int & ret, DWORD & win_error, const Flags & flags, const Options & options, UINT cp_in)
{
    // intercept here specific global variables accidental usage instead of local variables
    static struct {} g_options;
    static struct {} g_flags;

    ret = err_none;
    win_error = 0;

    SECURITY_ATTRIBUTES sa{};

    sa.nLength = sizeof(sa);
    sa.bInheritHandle = g_no_std_inherit ? FALSE : TRUE;

    std::vector<TCHAR> tmp_buf;

    if (!options.reopen_stdout_as_file.empty()) {
        SetLastError(0); // just in case
        if (_is_valid_handle(g_reopen_stdout_handle =
                CreateFile(options.reopen_stdout_as_file.c_str(),
                    GENERIC_WRITE, FILE_SHARE_READ | FILE_SHARE_WRITE, &sa, // must use `sa` to setup inheritance
                    flags.reopen_stdout_file_truncate ? CREATE_ALWAYS : OPEN_ALWAYS,
                    FILE_ATTRIBUTE_NORMAL, NULL))) {
            if (!flags.reopen_stdout_file_truncate) {
                SetFilePointer(g_reopen_stdout_handle, 0, NULL, FILE_END);
            }

            tmp_buf.resize(MAX_PATH);
            tmp_buf[0] = _T('\0');
            const DWORD num_chars = GetFullPathName(options.reopen_stdout_as_file.c_str(), MAX_PATH, tmp_buf.data(), NULL);
            g_reopen_stdout_full_name.assign(tmp_buf.data(), &tmp_buf[num_chars]);

            g_reopen_stdout_full_name = _to_lower(g_reopen_stdout_full_name, cp_in);

            // create associated write mutex
            if (flags.mutex_std_writes) {
                // generate file name hash
                const uint64_t reopen_stdout_file_name_hash = _hash_string_to_u64(g_reopen_stdout_full_name, cp_in);

                g_reopen_stdout_mutex = CreateMutex(NULL, FALSE,
                    (std::tstring(_T(STD_FILE_WRITE_MUTEX_NAME_PREFIX) _T("-")) + std::to_tstring(reopen_stdout_file_name_hash)).c_str());
            }
        }
        else {
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
                _print_stderr_message(_T("could not reopen stdout as file to write: win_error=0x%08X (%d) file=\"%s\"\n"),
                    win_error, win_error, options.reopen_stdout_as_file.c_str());
            }
            if (flags.print_win_error_string && win_error) {
                _print_win_error_message(win_error, options.win_error_langid);
            }
            return false;
        }

        if (!_set_crt_std_handle(g_reopen_stdout_handle, 1, true, !g_no_std_inherit)) {
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
                _print_stderr_message(_T("could not duplicate reopened stdout as file before transfer handle ownership to CRT: win_error=0x%08X (%d) file=\"%s\"\n"),
                    win_error, win_error, options.reopen_stdout_as_file.c_str());
            }
            if (flags.print_win_error_string && win_error) {
                _print_win_error_message(win_error, options.win_error_langid);
            }
            return false;
        }
    }
    else if (!options.reopen_stdout_as_server_pipe.empty()) {
        SetLastError(0); // just in case
        if (!_is_valid_handle(g_reopen_stdout_handle =
            CreateNamedPipe((std::tstring(_T("\\\\.\\pipe\\")) + options.reopen_stdout_as_server_pipe).c_str(),
                PIPE_ACCESS_OUTBOUND | FILE_FLAG_FIRST_PIPE_INSTANCE | FILE_FLAG_OVERLAPPED,
                PIPE_TYPE_BYTE | PIPE_READMODE_BYTE | PIPE_WAIT | PIPE_REJECT_REMOTE_CLIENTS,
                1, options.reopen_stderr_as_server_pipe_out_buf_size, options.reopen_stderr_as_server_pipe_in_buf_size,
                0, &sa))) {
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
                _print_stderr_message(_T("could not reopen stdout as server named pipe end to write: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                    win_error, win_error, options.reopen_stdout_as_server_pipe.c_str());
            }
            if (flags.print_win_error_string && win_error) {
                _print_win_error_message(win_error, options.win_error_langid);
            }
            return false;
        }

        if (!_set_crt_std_handle(g_reopen_stdout_handle, 1, true, !g_no_std_inherit)) {
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
                _print_stderr_message(_T("could not duplicate reopened stdout as server named pipe end before transfer handle ownership to CRT: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                    win_error, win_error, options.reopen_stdout_as_server_pipe.c_str());
            }
            if (flags.print_win_error_string && win_error) {
                _print_win_error_message(win_error, options.win_error_langid);
            }
            return false;
        }

        g_connect_server_named_pipe_thread_locals[0][1].thread_handle = CreateThread(
            NULL, 0,
            ConnectServerNamedPipeThread<0, 1>, &g_connect_server_named_pipe_thread_locals[0][1].thread_data,
            0,
            &g_connect_server_named_pipe_thread_locals[0][1].thread_id
        );
    }
    else if (!options.reopen_stdout_as_client_pipe.empty()) {
        g_connect_client_named_pipe_thread_locals[0][1].thread_handle = CreateThread(
            NULL, 0,
            ConnectClientNamedPipeThread<0, 1>, &g_connect_client_named_pipe_thread_locals[0][1].thread_data,
            0,
            &g_connect_client_named_pipe_thread_locals[0][1].thread_id
        );
    }

    return true;
}

bool ReopenStderr(int & ret, DWORD & win_error, const Flags & flags, const Options & options, UINT cp_in)
{
    // intercept here specific global variables accidental usage instead of local variables
    static struct {} g_options;
    static struct {} g_flags;

    ret = err_none;
    win_error = 0;

    SECURITY_ATTRIBUTES sa{};

    sa.nLength = sizeof(sa);
    sa.bInheritHandle = g_no_std_inherit ? FALSE : TRUE;

    std::vector<TCHAR> tmp_buf;

    if (!options.reopen_stderr_as_file.empty()) {
        tmp_buf.resize(MAX_PATH);
        tmp_buf[0] = _T('\0');
        const DWORD num_chars = GetFullPathName(options.reopen_stderr_as_file.c_str(), MAX_PATH, tmp_buf.data(), NULL);
        g_reopen_stderr_full_name.assign(tmp_buf.data(), &tmp_buf[num_chars]);

        g_reopen_stderr_full_name = _to_lower(g_reopen_stderr_full_name, cp_in);

        // create associated write mutex
        if (flags.mutex_std_writes) {
            // generate file name hash
            const uint64_t reopen_stderr_file_name_hash = _hash_string_to_u64(g_reopen_stderr_full_name, cp_in);

            g_reopen_stdout_mutex = CreateMutex(NULL, FALSE,
                (std::tstring(_T(STD_FILE_WRITE_MUTEX_NAME_PREFIX) _T("-")) + std::to_tstring(reopen_stderr_file_name_hash)).c_str());
        }

        // compare full names and if equal, then duplicate instead create
        if (_is_valid_handle(g_reopen_stdout_handle)) {
            if (g_reopen_stdout_full_name == g_reopen_stderr_full_name) {
                SetLastError(0); // just in case
                if (!DuplicateHandle(GetCurrentProcess(), g_reopen_stdout_handle, GetCurrentProcess(), &g_reopen_stderr_handle, 0, g_no_std_inherit ? FALSE : TRUE, DUPLICATE_SAME_ACCESS)) {
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
                        _print_stderr_message(_T("could not auto duplicate (merge) stdout into stderr: win_error=0x%08X (%d) file=\"%s\"\n"),
                            win_error, win_error, options.reopen_stdout_as_file.c_str());
                    }
                    if (flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, options.win_error_langid);
                    }
                    return false;
                }
            }
        }

        if (!_is_valid_handle(g_reopen_stderr_handle)) {
            SetLastError(0); // just in case
            if (_is_valid_handle(g_reopen_stderr_handle =
                CreateFile(options.reopen_stderr_as_file.c_str(),
                    GENERIC_WRITE, FILE_SHARE_READ | FILE_SHARE_WRITE, &sa, // must use `sa` to setup inheritance
                    flags.reopen_stderr_file_truncate ? CREATE_ALWAYS : OPEN_ALWAYS,
                    FILE_ATTRIBUTE_NORMAL, NULL))) {
                if (!flags.reopen_stderr_file_truncate) {
                    SetFilePointer(g_reopen_stderr_handle, 0, NULL, FILE_END);
                }
            }
            else {
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
                    _print_stderr_message(_T("could not reopen stderr as file to write: win_error=0x%08X (%d) file=\"%s\"\n"),
                        win_error, win_error, options.reopen_stderr_as_file.c_str());
                }
                if (flags.print_win_error_string && win_error) {
                    _print_win_error_message(win_error, options.win_error_langid);
                }
                return false;
            }
        }

        if (!_set_crt_std_handle(g_reopen_stderr_handle, 2, true, !g_no_std_inherit)) {
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
                _print_stderr_message(_T("could not duplicate reopened stderr as file before transfer handle ownership to CRT: win_error=0x%08X (%d) file=\"%s\"\n"),
                    win_error, win_error, options.reopen_stderr_as_file.c_str());
            }
            if (flags.print_win_error_string && win_error) {
                _print_win_error_message(win_error, options.win_error_langid);
            }
            return false;
        }
    }
    else if (!options.reopen_stderr_as_server_pipe.empty()) {
        SetLastError(0); // just in case
        if (!_is_valid_handle(g_reopen_stderr_handle =
            CreateNamedPipe((std::tstring(_T("\\\\.\\pipe\\")) + options.reopen_stderr_as_server_pipe).c_str(),
                PIPE_ACCESS_OUTBOUND | FILE_FLAG_FIRST_PIPE_INSTANCE | FILE_FLAG_OVERLAPPED,
                PIPE_TYPE_BYTE | PIPE_READMODE_BYTE | PIPE_WAIT | PIPE_REJECT_REMOTE_CLIENTS,
                1, options.reopen_stderr_as_server_pipe_out_buf_size, options.reopen_stderr_as_server_pipe_in_buf_size,
                0, &sa))) {
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
                _print_stderr_message(_T("could not reopen stderr as server named pipe end to write: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                    win_error, win_error, options.reopen_stderr_as_server_pipe.c_str());
            }
            if (flags.print_win_error_string && win_error) {
                _print_win_error_message(win_error, options.win_error_langid);
            }
            return false;
        }

        if (!_set_crt_std_handle(g_reopen_stderr_handle, 2, true, !g_no_std_inherit)) {
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
                _print_stderr_message(_T("could not duplicate reopened stderr as server named pipe end before transfer handle ownership to CRT: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                    win_error, win_error, options.reopen_stderr_as_server_pipe.c_str());
            }
            if (flags.print_win_error_string && win_error) {
                _print_win_error_message(win_error, options.win_error_langid);
            }
            return false;
        }

        g_connect_server_named_pipe_thread_locals[0][2].thread_handle = CreateThread(
            NULL, 0,
            ConnectServerNamedPipeThread<0, 2>, &g_connect_server_named_pipe_thread_locals[0][2].thread_data,
            0,
            &g_connect_server_named_pipe_thread_locals[0][2].thread_id
        );
    }
    else if (!options.reopen_stderr_as_client_pipe.empty()) {
        g_connect_client_named_pipe_thread_locals[0][2].thread_handle = CreateThread(
            NULL, 0,
            ConnectClientNamedPipeThread<0, 2>, &g_connect_client_named_pipe_thread_locals[0][2].thread_data,
            0,
            &g_connect_client_named_pipe_thread_locals[0][2].thread_id
        );
    }

    return true;
}

bool CreateOutboundPipeFromConsoleInput(int & ret, DWORD & win_error, const Flags & flags, const Options & options)
{
    // intercept here specific global variables accidental usage instead of local variables
    static struct {} g_options;
    static struct {} g_flags;

    ret = err_none;
    win_error = 0;

    SECURITY_ATTRIBUTES sa{};

    sa.nLength = sizeof(sa);
    sa.bInheritHandle = g_no_std_inherit ? FALSE : TRUE; // just in case

    OVERLAPPED connection_await_overlapped{};

    if (options.create_outbound_pipe_from_stdin.empty()) {
        // create anonymous pipe
        SetLastError(0); // just in case
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
                _print_stderr_message(_T("could not create outbound anonymous pipe from stdin: win_error=0x%08X (%d)\n"),
                    win_error, win_error);
            }
            if (flags.print_win_error_string && win_error) {
                _print_win_error_message(win_error, options.win_error_langid);
            }
            return false;
        }
    }
    else {
        // create named pipe
        const auto pipe_name_str = std::tstring(_T("\\\\.\\pipe\\")) + options.create_outbound_pipe_from_stdin;

        SetLastError(0); // just in case
        if (!_is_valid_handle(g_stdin_pipe_write_handle =
            CreateNamedPipe(pipe_name_str.c_str(),
                PIPE_ACCESS_OUTBOUND | FILE_FLAG_FIRST_PIPE_INSTANCE | FILE_FLAG_OVERLAPPED,
                PIPE_TYPE_BYTE | PIPE_READMODE_BYTE | PIPE_WAIT | PIPE_REJECT_REMOTE_CLIENTS,
                1, options.create_outbound_pipe_from_stdin_in_buf_size, options.create_outbound_pipe_from_stdin_out_buf_size,
                0, &sa))) {
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
                _print_stderr_message(_T("could not create outbound server named pipe from stdin: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                    win_error, win_error, options.create_outbound_pipe_from_stdin.c_str());
            }
            if (flags.print_win_error_string && win_error) {
                _print_win_error_message(win_error, options.win_error_langid);
            }
            return false;
        }

        // start server pipe connection await
        SetLastError(0); // just in case
        if (!ConnectNamedPipe(g_stdin_pipe_write_handle, &connection_await_overlapped)) {
            win_error = GetLastError();
            if (win_error != ERROR_IO_PENDING && win_error != ERROR_PIPE_LISTENING) {
                if (!flags.ret_win_error) {
                    ret = err_win32_error;
                }
                else {
                    ret = win_error;
                }
                if (!flags.no_print_gen_error_string) {
                    _print_stderr_message(_T("could not initiate connection of outbound client named pipe end from stdin: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                        win_error, win_error, options.create_outbound_pipe_from_stdin.c_str());
                }
                if (flags.print_win_error_string && win_error) {
                    _print_win_error_message(win_error, options.win_error_langid);
                }
                return false;
            }
        }

        const auto start_time_ms = options.win_ver_major >= 6 ? GetTickCount64() : GetTickCount();

        // client named pipe end wait loop
        while (true) {
            // CAUTION:
            //  Based on:
            //    https://stackoverflow.com/questions/8529193/named-pipe-createfile-returns-invalid-handle-value-and-getlasterror-returns/8533189#8533189
            //    `Named Pipe Client` : https://docs.microsoft.com/en-us/windows/win32/ipc/named-pipe-client
            //
            //    A named pipe client uses the CreateFile function to open a handle to a named pipe.
            //    If the pipe exists but all of its instances are busy, CreateFile returns INVALID_HANDLE_VALUE and
            //    the GetLastError function returns ERROR_PIPE_BUSY. When this happens, the named pipe client uses
            //    the WaitNamedPipe function to wait for an instance of the named pipe to become available.
            //
            //  So, we still use `CreateFile` in the loop just in case of `ERROR_PIPE_BUSY` error.
            //

            SetLastError(0); // just in case
            if (_is_valid_handle(g_stdin_pipe_read_handle =
                CreateFile(pipe_name_str.c_str(),
                    GENERIC_READ, FILE_SHARE_READ, &sa, // must use `sa` to setup inheritance
                    OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL))) {
                break;
            }

            win_error = GetLastError();
            if (win_error != ERROR_PIPE_BUSY) {
                if (!flags.ret_win_error) {
                    ret = err_win32_error;
                }
                else {
                    ret = win_error;
                }
                if (!flags.no_print_gen_error_string) {
                    _print_stderr_message(_T("could not client connect to inbound named pipe end from stdin: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                        win_error, win_error, options.create_outbound_pipe_from_stdin.c_str());
                }
                if (flags.print_win_error_string && win_error) {
                    _print_win_error_message(win_error, options.win_error_langid);
                }
                return false;
            }

            {
                const auto end_time_ms = options.win_ver_major >= 6 ? GetTickCount64() : GetTickCount();

                const auto time_delta_ms = end_time_ms >= start_time_ms ? end_time_ms - start_time_ms : 0;

                if (time_delta_ms >= options.create_outbound_pipe_from_stdin_connect_timeout_ms) {
                    ret = err_named_pipe_connect_timeout;
                    if (!flags.no_print_gen_error_string) {
                        _print_stderr_message(_T("client connection timeout of inbound named pipe end from stdin: pipe=\"%s\" timeout=%u ms\n"),
                            options.create_outbound_pipe_from_stdin.c_str(), options.create_outbound_pipe_from_stdin_connect_timeout_ms);
                    }
                    return false;
                }

                const auto wait_named_pipe_timeout_ms = decltype(time_delta_ms){ options.create_outbound_pipe_from_stdin_connect_timeout_ms } - time_delta_ms;

                if (WaitNamedPipe(pipe_name_str.c_str(), (DWORD)wait_named_pipe_timeout_ms)) {
                    continue;
                }
            }

            // check for timeout again
            {
                const auto end_time_ms = options.win_ver_major >= 6 ? GetTickCount64() : GetTickCount();

                const auto time_delta_ms = end_time_ms >= start_time_ms ? end_time_ms - start_time_ms : 0;

                if (time_delta_ms >= options.create_outbound_pipe_from_stdin_connect_timeout_ms) {
                    ret = err_named_pipe_connect_timeout;
                    if (!flags.no_print_gen_error_string) {
                        _print_stderr_message(_T("client connection timeout of inbound named pipe end from stdin: pipe=\"%s\" timeout=%u ms\n"),
                            options.create_outbound_pipe_from_stdin.c_str(), options.create_outbound_pipe_from_stdin_connect_timeout_ms);
                    }
                    return false;
                }
            }
        }

        // server named pipe end wait loop
        while (true) {
            // NOTE:
            //  Based on:
            //    `HasOverlappedIoCompleted macro (winbase.h)` : https://docs.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-hasoverlappediocompleted:
            //
            //    Do not call this macro unless the call to GetLastError returns ERROR_IO_PENDING, indicating that the overlapped I/O has started.
            //
            //  We call both the `WaitNamedPipe` function and after the `HasOverlappedIoCompleted` macro to be sure for the both named pipe ends.
            //

            if (HasOverlappedIoCompleted(&connection_await_overlapped)) {
                break;
            }

            const auto end_time_ms = options.win_ver_major >= 6 ? GetTickCount64() : GetTickCount();

            const auto time_delta_ms = end_time_ms >= start_time_ms ? end_time_ms - start_time_ms : 0;

            if (time_delta_ms >= options.create_outbound_pipe_from_stdin_connect_timeout_ms) {
                ret = err_named_pipe_connect_timeout;
                if (!flags.no_print_gen_error_string) {
                    _print_stderr_message(_T("server connection timeout of outbound named pipe end from stdin: pipe=\"%s\" timeout=%u ms\n"),
                        options.create_outbound_pipe_from_stdin.c_str(), options.create_outbound_pipe_from_stdin_connect_timeout_ms);
                }
                return false;
            }

            Sleep(20);
        }
    }

    return true;
}

template <int stream_type>
bool CreateInboundPipeToConsoleOutput(int & ret, DWORD & win_error, const Flags & flags, const Options & options)
{
    // intercept here specific global variables accidental usage instead of local variables
    static struct {} g_options;
    static struct {} g_flags;

    ret = err_none;
    win_error = 0;

    SECURITY_ATTRIBUTES sa{};

    sa.nLength = sizeof(sa);
    sa.bInheritHandle = g_no_std_inherit ? FALSE : TRUE; // just in case

    OVERLAPPED connection_await_overlapped{};

    const auto & conout_name_token_str = UTILITY_CONSTEXPR(stream_type == 1) ? _T("stdout") : _T("stderr");

    const auto & create_inbound_pipe_to_conout = UTILITY_CONSTEXPR(stream_type == 1) ? options.create_inbound_pipe_to_stdout : options.create_inbound_pipe_to_stderr;

    auto & conout_pipe_read_handle = UTILITY_CONSTEXPR(stream_type == 1) ? g_stdout_pipe_read_handle : g_stderr_pipe_read_handle;
    auto & conout_pipe_write_handle = UTILITY_CONSTEXPR(stream_type == 1) ? g_stdout_pipe_write_handle : g_stderr_pipe_write_handle;

    if (create_inbound_pipe_to_conout.empty()) {
        // create anonymous pipe
        const auto tee_conout_pipe_buf_size = UTILITY_CONSTEXPR(stream_type == 1) ? options.tee_stdout_pipe_buf_size : options.tee_stderr_pipe_buf_size;

        SetLastError(0); // just in case
        if (!CreatePipe(&conout_pipe_read_handle, &conout_pipe_write_handle, &sa, // must use `sa` to setup inheritance
            tee_conout_pipe_buf_size)) {
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
                _print_stderr_message(_T("could not create inbound anonymous pipe to %s: win_error=0x%08X (%d)\n"),
                    conout_name_token_str, win_error, win_error);
            }
            if (flags.print_win_error_string && win_error) {
                _print_win_error_message(win_error, options.win_error_langid);
            }
            return false;
        }
    }
    else {
        // create named pipe
        const auto pipe_name_str = std::tstring(_T("\\\\.\\pipe\\")) + create_inbound_pipe_to_conout;

        const auto create_inbound_pipe_to_conout_in_buf_size = UTILITY_CONSTEXPR(stream_type == 1) ?
            options.create_inbound_pipe_to_stdout_in_buf_size : options.create_inbound_pipe_to_stderr_in_buf_size;
        const auto create_inbound_pipe_to_conout_out_buf_size = UTILITY_CONSTEXPR(stream_type == 1) ?
            options.create_inbound_pipe_to_stdout_out_buf_size : options.create_inbound_pipe_to_stderr_out_buf_size;
        const auto create_inbound_pipe_to_conout_connect_timeout_ms = UTILITY_CONSTEXPR(stream_type == 1) ?
            options.create_inbound_pipe_to_stdout_connect_timeout_ms : options.create_inbound_pipe_to_stderr_connect_timeout_ms;

        SetLastError(0); // just in case
        if (!_is_valid_handle(conout_pipe_read_handle =
            CreateNamedPipe(pipe_name_str.c_str(),
                PIPE_ACCESS_INBOUND | FILE_FLAG_FIRST_PIPE_INSTANCE | FILE_FLAG_OVERLAPPED,
                PIPE_TYPE_BYTE | PIPE_READMODE_BYTE | PIPE_WAIT | PIPE_REJECT_REMOTE_CLIENTS,
                1, create_inbound_pipe_to_conout_in_buf_size, create_inbound_pipe_to_conout_out_buf_size,
                0, &sa))) {
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
                _print_stderr_message(_T("could not create inbound server named pipe end to %s: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                    conout_name_token_str, win_error, win_error, create_inbound_pipe_to_conout.c_str());
            }
            if (flags.print_win_error_string && win_error) {
                _print_win_error_message(win_error, options.win_error_langid);
            }
            return false;
        }

        // start server pipe connection await
        SetLastError(0); // just in case
        if (!ConnectNamedPipe(conout_pipe_read_handle, &connection_await_overlapped)) {
            win_error = GetLastError();
            if (win_error != ERROR_IO_PENDING && win_error != ERROR_PIPE_LISTENING) {
                if (!flags.ret_win_error) {
                    ret = err_win32_error;
                }
                else {
                    ret = win_error;
                }
                if (!flags.no_print_gen_error_string) {
                    _print_stderr_message(_T("could not initiate connection of inbound client named pipe end from %s: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                        conout_name_token_str, win_error, win_error, create_inbound_pipe_to_conout.c_str());
                }
                if (flags.print_win_error_string && win_error) {
                    _print_win_error_message(win_error, options.win_error_langid);
                }
                return false;
            }
        }

        const auto start_time_ms = options.win_ver_major >= 6 ? GetTickCount64() : GetTickCount();

        // client named pipe end wait loop
        while (true) {
            // CAUTION:
            //  Based on:
            //    https://stackoverflow.com/questions/8529193/named-pipe-createfile-returns-invalid-handle-value-and-getlasterror-returns/8533189#8533189
            //    `Named Pipe Client` : https://docs.microsoft.com/en-us/windows/win32/ipc/named-pipe-client
            //
            //    A named pipe client uses the CreateFile function to open a handle to a named pipe.
            //    If the pipe exists but all of its instances are busy, CreateFile returns INVALID_HANDLE_VALUE and
            //    the GetLastError function returns ERROR_PIPE_BUSY. When this happens, the named pipe client uses
            //    the WaitNamedPipe function to wait for an instance of the named pipe to become available.
            //
            //  So, we still use `CreateFile` in the loop just in case of `ERROR_PIPE_BUSY` error.
            //

            SetLastError(0); // just in case
            if (_is_valid_handle(conout_pipe_write_handle =
                CreateFile(pipe_name_str.c_str(),
                    GENERIC_WRITE, FILE_SHARE_WRITE, &sa, // must use `sa` to setup inheritance
                    OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL))) {
                break;
            }

            win_error = GetLastError();
            if (win_error != ERROR_PIPE_BUSY) {
                if (!flags.ret_win_error) {
                    ret = err_win32_error;
                }
                else {
                    ret = win_error;
                }
                if (!flags.no_print_gen_error_string) {
                    _print_stderr_message(_T("could not client connect to outbound named pipe end to %s: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                        conout_name_token_str, win_error, win_error, create_inbound_pipe_to_conout.c_str());
                }
                if (flags.print_win_error_string && win_error) {
                    _print_win_error_message(win_error, options.win_error_langid);
                }
                return false;
            }

            {
                const auto end_time_ms = options.win_ver_major >= 6 ? GetTickCount64() : GetTickCount();

                const auto time_delta_ms = end_time_ms >= start_time_ms ? end_time_ms - start_time_ms : 0;

                if (time_delta_ms >= create_inbound_pipe_to_conout_connect_timeout_ms) {
                    ret = err_named_pipe_connect_timeout;
                    if (!flags.no_print_gen_error_string) {
                        _print_stderr_message(_T("client connection timeout of outbound named pipe end to %s: pipe=\"%s\" timeout=%u ms\n"),
                            conout_name_token_str, create_inbound_pipe_to_conout.c_str(), create_inbound_pipe_to_conout_connect_timeout_ms);
                    }
                    return false;
                }

                const auto wait_named_pipe_timeout_ms = decltype(time_delta_ms){ create_inbound_pipe_to_conout_connect_timeout_ms } - time_delta_ms;

                if (WaitNamedPipe(pipe_name_str.c_str(), (DWORD)wait_named_pipe_timeout_ms)) {
                    continue;
                }
            }

            // check for timeout again
            {
                const auto end_time_ms = options.win_ver_major >= 6 ? GetTickCount64() : GetTickCount();

                const auto time_delta_ms = end_time_ms >= start_time_ms ? end_time_ms - start_time_ms : 0;

                if (time_delta_ms >= create_inbound_pipe_to_conout_connect_timeout_ms) {
                    ret = err_named_pipe_connect_timeout;
                    if (!flags.no_print_gen_error_string) {
                        _print_stderr_message(_T("client connection timeout of outbound named pipe end to %s: pipe=\"%s\" timeout=%u ms\n"),
                            conout_name_token_str, create_inbound_pipe_to_conout.c_str(), create_inbound_pipe_to_conout_connect_timeout_ms);
                    }
                    return false;
                }
            }
        }

        // server named pipe end wait loop
        while (true) {
            // NOTE:
            //  Based on:
            //    `HasOverlappedIoCompleted macro (winbase.h)` : https://docs.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-hasoverlappediocompleted:
            //
            //    Do not call this macro unless the call to GetLastError returns ERROR_IO_PENDING, indicating that the overlapped I/O has started.
            //
            //  We call both the `WaitNamedPipe` function and after the `HasOverlappedIoCompleted` macro to be sure for the both named pipe ends.
            //

            if (HasOverlappedIoCompleted(&connection_await_overlapped)) {
                break;
            }

            const auto end_time_ms = options.win_ver_major >= 6 ? GetTickCount64() : GetTickCount();

            const auto time_delta_ms = end_time_ms >= start_time_ms ? end_time_ms - start_time_ms : 0;

            if (time_delta_ms >= create_inbound_pipe_to_conout_connect_timeout_ms) {
                ret = err_named_pipe_connect_timeout;
                if (!flags.no_print_gen_error_string) {
                    _print_stderr_message(_T("server connection timeout of inbound named pipe end to %s: pipe=\"%s\" timeout=%u ms\n"),
                        conout_name_token_str, create_inbound_pipe_to_conout.c_str(), create_inbound_pipe_to_conout_connect_timeout_ms);
                }
                return false;
            }

            Sleep(20);
        }
    }

    return true;
}

bool CreateTeeOutputFromStdin(int & ret, DWORD & win_error, const Flags & flags, const Options & options, UINT cp_in)
{
    // intercept here specific global variables accidental usage instead of local variables
    static struct {} g_options;
    static struct {} g_flags;

    ret = err_none;
    win_error = 0;

    std::vector<TCHAR> tmp_buf;

    if (!options.tee_stdin_to_file.empty()) {
        SetLastError(0); // just in case
        if (_is_valid_handle(g_tee_file_stdin_handle =
            CreateFile(options.tee_stdin_to_file.c_str(),
                GENERIC_WRITE, FILE_SHARE_READ | FILE_SHARE_WRITE, NULL,
                flags.tee_stdin_file_truncate ? CREATE_ALWAYS : OPEN_ALWAYS,
                FILE_ATTRIBUTE_NORMAL, NULL))) {
            if (!flags.tee_stdin_file_truncate) {
                SetFilePointer(g_tee_file_stdin_handle, 0, NULL, FILE_END);
            }

            tmp_buf.resize(MAX_PATH);
            tmp_buf[0] = _T('\0');
            const DWORD num_chars = GetFullPathName(options.tee_stdin_to_file.c_str(), MAX_PATH, tmp_buf.data(), NULL);
            g_tee_file_stdin_full_name.assign(tmp_buf.data(), &tmp_buf[num_chars]);

            g_tee_file_stdin_full_name = _to_lower(g_tee_file_stdin_full_name, cp_in);

            // create associated write mutex
            if (flags.mutex_tee_file_writes) {
                // generate file name hash
                const uint64_t tee_stdin_file_name_hash = _hash_string_to_u64(g_tee_file_stdin_full_name, cp_in);

                g_tee_file_stdin_mutex = CreateMutex(NULL, FALSE,
                    (std::tstring(_T(TEE_FILE_WRITE_MUTEX_NAME_PREFIX) _T("-")) + std::to_tstring(tee_stdin_file_name_hash)).c_str());
            }
        }
        else {
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
                _print_stderr_message(_T("could not open stdin tee file to write: win_error=0x%08X (%d) file=\"%s\"\n"),
                    win_error, win_error, options.tee_stdin_to_file.c_str());
            }
            if (flags.print_win_error_string && win_error) {
                _print_win_error_message(win_error, options.win_error_langid);
            }
            return false;
        }
    }
    else if (!options.tee_stdin_to_server_pipe.empty()) {
        SetLastError(0); // just in case
        if (!_is_valid_handle(g_tee_named_pipe_stdin_handle =
            CreateNamedPipe((std::tstring(_T("\\\\.\\pipe\\")) + options.tee_stdin_to_server_pipe).c_str(),
                PIPE_ACCESS_OUTBOUND | FILE_FLAG_FIRST_PIPE_INSTANCE | FILE_FLAG_OVERLAPPED,
                PIPE_TYPE_BYTE | PIPE_READMODE_BYTE | PIPE_WAIT | PIPE_REJECT_REMOTE_CLIENTS,
                1, options.tee_stderr_to_server_pipe_out_buf_size, options.tee_stderr_to_server_pipe_in_buf_size,
                0, NULL))) {
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
                _print_stderr_message(_T("could not open stdin tee as server named pipe end to write: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                    win_error, win_error, options.tee_stdin_to_server_pipe.c_str());
            }
            if (flags.print_win_error_string && win_error) {
                _print_win_error_message(win_error, options.win_error_langid);
            }
            return false;
        }

        // start server pipe connection await
        g_connect_server_named_pipe_thread_locals[1][0].thread_handle = CreateThread(
            NULL, 0,
            ConnectServerNamedPipeThread<1, 0>, &g_connect_server_named_pipe_thread_locals[1][0].thread_data,
            0,
            &g_connect_server_named_pipe_thread_locals[1][0].thread_id
        );
    }
    else if (!options.tee_stdin_to_client_pipe.empty()) {
        g_connect_client_named_pipe_thread_locals[1][0].thread_handle = CreateThread(
            NULL, 0,
            ConnectClientNamedPipeThread<1, 0>, &g_connect_client_named_pipe_thread_locals[1][0].thread_data,
            0,
            &g_connect_client_named_pipe_thread_locals[1][0].thread_id
        );
    }

    return true;
}

bool CreateTeeOutputFromStdout(int & ret, DWORD & win_error, const Flags & flags, const Options & options, UINT cp_in)
{
    // intercept here specific global variables accidental usage instead of local variables
    static struct {} g_options;
    static struct {} g_flags;

    ret = err_none;
    win_error = 0;

    std::vector<TCHAR> tmp_buf;

    if (!options.tee_stdout_to_file.empty()) {
        tmp_buf.resize(MAX_PATH);
        tmp_buf[0] = _T('\0');
        const DWORD num_chars = GetFullPathName(options.tee_stdout_to_file.c_str(), MAX_PATH, tmp_buf.data(), NULL);
        g_tee_file_stdout_full_name.assign(tmp_buf.data(), &tmp_buf[num_chars]);

        g_tee_file_stdout_full_name = _to_lower(g_tee_file_stdout_full_name, cp_in);

        // create associated write mutex
        if (flags.mutex_tee_file_writes) {
            // generate file name hash
            const uint64_t tee_stdout_file_name_hash = _hash_string_to_u64(g_tee_file_stdout_full_name, cp_in);

            g_tee_file_stdout_mutex = CreateMutex(NULL, FALSE,
                (std::tstring(_T(TEE_FILE_WRITE_MUTEX_NAME_PREFIX) _T("-")) + std::to_tstring(tee_stdout_file_name_hash)).c_str());
        }

        // compare full names and if equal, then duplicate instead create
        if (_is_valid_handle(g_tee_file_stdin_handle)) {
            if (g_tee_file_stdin_full_name == g_tee_file_stdout_full_name) {
                SetLastError(0); // just in case
                if (!DuplicateHandle(GetCurrentProcess(), g_tee_file_stdin_handle, GetCurrentProcess(), &g_tee_file_stdout_handle, 0, FALSE, DUPLICATE_SAME_ACCESS)) {
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
                        _print_stderr_message(_T("could not auto duplicate (merge) stdin tee into stdout tee: win_error=0x%08X (%d) file=\"%s\"\n"),
                            win_error, win_error, options.tee_stdin_to_file.c_str());
                    }
                    if (flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, options.win_error_langid);
                    }
                    return false;
                }
            }
        }

        if (!_is_valid_handle(g_tee_file_stdout_handle)) {
            SetLastError(0); // just in case
            if (_is_valid_handle(g_tee_file_stdout_handle =
                CreateFile(options.tee_stdout_to_file.c_str(),
                    GENERIC_WRITE, FILE_SHARE_READ | FILE_SHARE_WRITE, NULL,
                    flags.tee_stdout_file_truncate ? CREATE_ALWAYS : OPEN_ALWAYS,
                    FILE_ATTRIBUTE_NORMAL, NULL))) {
                if (!flags.tee_stdout_file_truncate) {
                    SetFilePointer(g_tee_file_stdout_handle, 0, NULL, FILE_END);
                }
            }
            else {
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
                    _print_stderr_message(_T("could not open stdout tee file to write: win_error=0x%08X (%d) file=\"%s\"\n"),
                        win_error, win_error, options.tee_stdout_to_file.c_str());
                }
                if (flags.print_win_error_string && win_error) {
                    _print_win_error_message(win_error, options.win_error_langid);
                }
                return false;
            }
        }
    }
    else if (!options.tee_stdout_to_server_pipe.empty()) {
        SetLastError(0); // just in case
        if (!_is_valid_handle(g_tee_named_pipe_stdout_handle =
            CreateNamedPipe((std::tstring(_T("\\\\.\\pipe\\")) + options.tee_stdout_to_server_pipe).c_str(),
                PIPE_ACCESS_OUTBOUND | FILE_FLAG_FIRST_PIPE_INSTANCE | FILE_FLAG_OVERLAPPED,
                PIPE_TYPE_BYTE | PIPE_READMODE_BYTE | PIPE_WAIT | PIPE_REJECT_REMOTE_CLIENTS,
                1, options.tee_stderr_to_server_pipe_out_buf_size, options.tee_stderr_to_server_pipe_in_buf_size,
                0, NULL))) {
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
                _print_stderr_message(_T("could not open stdout tee as server named pipe end to write: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                    win_error, win_error, options.tee_stdout_to_server_pipe.c_str());
            }
            if (flags.print_win_error_string && win_error) {
                _print_win_error_message(win_error, options.win_error_langid);
            }
            return false;
        }

        g_connect_server_named_pipe_thread_locals[1][1].thread_handle = CreateThread(
            NULL, 0,
            ConnectServerNamedPipeThread<1, 1>, &g_connect_server_named_pipe_thread_locals[1][1].thread_data,
            0,
            &g_connect_server_named_pipe_thread_locals[1][1].thread_id
        );
    }
    else if (!options.tee_stdout_to_client_pipe.empty()) {
        g_connect_client_named_pipe_thread_locals[1][1].thread_handle = CreateThread(
            NULL, 0,
            ConnectClientNamedPipeThread<1, 1>, &g_connect_client_named_pipe_thread_locals[1][1].thread_data,
            0,
            &g_connect_client_named_pipe_thread_locals[1][1].thread_id
        );
    }

    return true;
}

bool CreateTeeOutputFromStderr(int & ret, DWORD & win_error, const Flags & flags, const Options & options, UINT cp_in)
{
    // intercept here specific global variables accidental usage instead of local variables
    static struct {} g_options;
    static struct {} g_flags;

    ret = err_none;
    win_error = 0;

    std::vector<TCHAR> tmp_buf;

    if (!options.tee_stderr_to_file.empty()) {
        tmp_buf.resize(MAX_PATH);
        tmp_buf[0] = _T('\0');
        const DWORD num_chars = GetFullPathName(options.tee_stderr_to_file.c_str(), MAX_PATH, tmp_buf.data(), NULL);
        g_tee_file_stderr_full_name.assign(tmp_buf.data(), &tmp_buf[num_chars]);

        g_tee_file_stderr_full_name = _to_lower(g_tee_file_stderr_full_name, cp_in);

        // create associated write mutex
        if (flags.mutex_tee_file_writes) {
            // generate file name hash
            const uint64_t tee_stderr_file_name_hash = _hash_string_to_u64(g_tee_file_stderr_full_name, cp_in);

            g_tee_file_stderr_mutex = CreateMutex(NULL, FALSE,
                (std::tstring(_T(TEE_FILE_WRITE_MUTEX_NAME_PREFIX) _T("-")) + std::to_tstring(tee_stderr_file_name_hash)).c_str());
        }

        // compare full names and if equal, then duplicate instead create
        if (_is_valid_handle(g_tee_file_stdout_handle)) {
            if (g_tee_file_stdout_full_name == g_tee_file_stderr_full_name) {
                SetLastError(0); // just in case
                if (!DuplicateHandle(GetCurrentProcess(), g_tee_file_stdout_handle, GetCurrentProcess(), &g_tee_file_stderr_handle, 0, FALSE, DUPLICATE_SAME_ACCESS)) {
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
                        _print_stderr_message(_T("could not auto duplicate (merge) stdout tee into stderr tee: win_error=0x%08X (%d) file=\"%s\"\n"),
                            win_error, win_error, options.tee_stdout_to_file.c_str());
                    }
                    if (flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, options.win_error_langid);
                    }
                    return false;
                }
            }
        }

        if (!_is_valid_handle(g_tee_file_stderr_handle)) {
            if (_is_valid_handle(g_tee_file_stdin_handle)) {
                if (g_tee_file_stdin_full_name == g_tee_file_stderr_full_name) {
                    SetLastError(0); // just in case
                    if (!DuplicateHandle(GetCurrentProcess(), g_tee_file_stdin_handle, GetCurrentProcess(), &g_tee_file_stderr_handle, 0, FALSE, DUPLICATE_SAME_ACCESS)) {
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
                            _print_stderr_message(_T("could not auto duplicate (merge) stdin tee into stderr tee: win_error=0x%08X (%d) file=\"%s\"\n"),
                                win_error, win_error, options.tee_stdin_to_file.c_str());
                        }
                        if (flags.print_win_error_string && win_error) {
                            _print_win_error_message(win_error, options.win_error_langid);
                        }
                        return false;
                    }
                }
            }
        }

        if (!_is_valid_handle(g_tee_file_stderr_handle)) {
            SetLastError(0); // just in case
            if (_is_valid_handle(g_tee_file_stderr_handle =
                CreateFile(options.tee_stderr_to_file.c_str(),
                    GENERIC_WRITE, FILE_SHARE_READ | FILE_SHARE_WRITE, NULL,
                    flags.tee_stderr_file_truncate ? CREATE_ALWAYS : OPEN_ALWAYS,
                    FILE_ATTRIBUTE_NORMAL, NULL))) {
                if (!flags.tee_stderr_file_truncate) {
                    SetFilePointer(g_tee_file_stderr_handle, 0, NULL, FILE_END);
                }
            }
            else {
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
                    _print_stderr_message(_T("could not open stderr tee file to write: win_error=0x%08X (%d) file=\"%s\"\n"),
                        win_error, win_error, options.tee_stderr_to_file.c_str());
                }
                if (flags.print_win_error_string && win_error) {
                    _print_win_error_message(win_error, options.win_error_langid);
                }
                return false;
            }
        }
    }
    else if (!options.tee_stderr_to_server_pipe.empty()) {
        SetLastError(0); // just in case
        if (!_is_valid_handle(g_tee_named_pipe_stderr_handle =
            CreateNamedPipe((std::tstring(_T("\\\\.\\pipe\\")) + options.tee_stderr_to_server_pipe).c_str(),
                PIPE_ACCESS_OUTBOUND | FILE_FLAG_FIRST_PIPE_INSTANCE | FILE_FLAG_OVERLAPPED,
                PIPE_TYPE_BYTE | PIPE_READMODE_BYTE | PIPE_WAIT | PIPE_REJECT_REMOTE_CLIENTS,
                1, options.tee_stderr_to_server_pipe_out_buf_size, options.tee_stderr_to_server_pipe_in_buf_size,
                0, NULL))) {
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
                _print_stderr_message(_T("could not open stderr tee as server named pipe end to write: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                    win_error, win_error, options.tee_stderr_to_server_pipe.c_str());
            }
            if (flags.print_win_error_string && win_error) {
                _print_win_error_message(win_error, options.win_error_langid);
            }
            return false;
        }

        g_connect_server_named_pipe_thread_locals[1][2].thread_handle = CreateThread(
            NULL, 0,
            ConnectServerNamedPipeThread<1, 2>, &g_connect_server_named_pipe_thread_locals[1][2].thread_data,
            0,
            &g_connect_server_named_pipe_thread_locals[1][2].thread_id
        );
    }
    else if (!options.tee_stderr_to_client_pipe.empty()) {
        g_connect_client_named_pipe_thread_locals[1][2].thread_handle = CreateThread(
            NULL, 0,
            ConnectClientNamedPipeThread<1, 2>, &g_connect_client_named_pipe_thread_locals[1][2].thread_data,
            0,
            &g_connect_client_named_pipe_thread_locals[1][2].thread_id
        );
    }

    return true;
}

int ExecuteProcess(LPCTSTR app, size_t app_len, LPCTSTR cmd, size_t cmd_len, const Flags & flags, const Options & options_)
{
    // intercept here specific global variables accidental usage instead of local variables
    static struct {} g_options;
    static struct {} g_flags;

#ifdef _DEBUG
    //_tprintf(_T(">%s\n>%s\n---\n"), app ? app : _T(""), cmd ? cmd : _T(""));
#endif

    int ret = err_none;

    if ((!app || !app_len) && (!cmd || !cmd_len)) {
        // just in case
        ret = err_format_empty;
        if (!flags.no_print_gen_error_string) {
            _print_stderr_message(_T("format arguments are empty\n"));
        }
        return ret;
    }

    Options options = options_;

    // CAUTION:
    //  Has effect only for Windows version up to 8.1 (read MSDN documentation)
    //
    _get_win_ver(options.win_ver_major, options.win_ver_minor, options.win_ver_build);

    std::vector<uint8_t> cmd_buf;

    STARTUPINFO si{};
    PROCESS_INFORMATION pi{};

    SECURITY_ATTRIBUTES sa{};
    SECURITY_DESCRIPTOR sd{}; // for pipes

    si.cb = sizeof(si);
    si.dwFlags = STARTF_USESHOWWINDOW;
    si.wShowWindow = options.show_as;

    sa.nLength = sizeof(sa);
    sa.bInheritHandle = TRUE;

    //if (_is_winnt()) {
    //    InitializeSecurityDescriptor(&sd, SECURITY_DESCRIPTOR_REVISION);
    //    SetSecurityDescriptorDacl(&sd, TRUE, NULL, FALSE);
    //    sa.lpSecurityDescriptor = &sd;
    //}

    UINT prev_cp_in = 0;
    UINT prev_cp_out = 0;

    DWORD win_error = 0;
    INT shell_error = -1;

    SHELLEXECUTEINFO sei{};
    std::vector<TCHAR> shell_exec_verb;

    bool is_idle_execute = false;
    if (app && app_len) {
        if (!tstrcmp(app, _T("."))) {
            is_idle_execute = true;
        }
    }

    // update globals
    g_no_std_inherit = flags.no_std_inherit || flags.pipe_stdin_to_stdout;

    // on idle execution always pipe stdin to stdout
    g_pipe_stdin_to_stdout = is_idle_execute || flags.pipe_stdin_to_stdout;

    bool break_ = false;

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

        const UINT cp_in = GetConsoleCP();
        const UINT cp_out = GetConsoleOutputCP();

        // reopen std

        if (!ReopenStdin(ret, win_error, flags, options, cp_in)) {
            break;
        }

        if (break_) break;

        if (!ReopenStdout(ret, win_error, flags, options, cp_in)) {
            break;
        }

        if (break_) break;

        if (!ReopenStderr(ret, win_error, flags, options, cp_in)) {
            break;
        }

        if (break_) break;

        // tee std

        if (!CreateTeeOutputFromStdin(ret, win_error, flags, options, cp_in)) {
            break;
        }

        if (break_) break;

        if (!CreateTeeOutputFromStdout(ret, win_error, flags, options, cp_in)) {
            break;
        }

        if (break_) break;

        if (!CreateTeeOutputFromStderr(ret, win_error, flags, options, cp_in)) {
            break;
        }

        if (break_) break;

        // Accomplish all client pipe connections for all standard handles from here before duplicate them.
        //

        {
            auto & connect_client_named_pipe_thread_locals = g_connect_client_named_pipe_thread_locals[0];

            WaitForConnectNamedPipeThreads(connect_client_named_pipe_thread_locals, false);

            // check errors
            utility::for_each_unroll(connect_client_named_pipe_thread_locals, [&](auto & local) {
                if (!break_) {
                    // return error code from the first thread
                    if (local.thread_data.is_error) {
                        ret = local.thread_data.ret;
                        break_ = true;
                    }
                }
                if (!local.thread_data.is_copied && !local.thread_data.msg.empty()) {
                    g_worker_threads_return_data.add(local.thread_data);
                    local.thread_data.is_copied = true;
                }
            });

            if (break_) break;
        }

        // assign reopened std handles to CRT

        if (!options.reopen_stdin_as_client_pipe.empty()) {
            if (_is_valid_handle(g_reopen_stdin_handle) && !_set_crt_std_handle(g_reopen_stdin_handle, 0, true, !g_no_std_inherit)) {
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
                    _print_stderr_message(_T("could not duplicate reopened stdin as client named pipe end before transfer handle ownership to CRT: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                        win_error, win_error, options.reopen_stdin_as_server_pipe.c_str());
                }
                if (flags.print_win_error_string && win_error) {
                    _print_win_error_message(win_error, options.win_error_langid);
                }
                break;
            }
        }

        if (!options.reopen_stdout_as_client_pipe.empty()) {
            if (_is_valid_handle(g_reopen_stdout_handle) && !_set_crt_std_handle(g_reopen_stdout_handle, 1, true, !g_no_std_inherit)) {
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
                    _print_stderr_message(_T("could not duplicate reopened stdout as client named pipe end before transfer handle ownership to CRT: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                        win_error, win_error, options.reopen_stdout_as_server_pipe.c_str());
                }
                if (flags.print_win_error_string && win_error) {
                    _print_win_error_message(win_error, options.win_error_langid);
                }
                break;
            }
        }

        if (!options.reopen_stderr_as_client_pipe.empty()) {
            if (_is_valid_handle(g_reopen_stderr_handle) && !_set_crt_std_handle(g_reopen_stderr_handle, 2, true, !g_no_std_inherit)) {
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
                    _print_stderr_message(_T("could not duplicate reopened stderr as client named pipe end before transfer handle ownership to CRT: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                        win_error, win_error, options.reopen_stderr_as_server_pipe.c_str());
                }
                if (flags.print_win_error_string && win_error) {
                    _print_win_error_message(win_error, options.win_error_langid);
                }
                break;
            }
        }

        // std handles get

        DWORD stdin_handle_type;
        DWORD stdout_handle_type;
        DWORD stderr_handle_type;

        for (int read_std_handles_iter = 0; read_std_handles_iter < 2; read_std_handles_iter++) {
            SetLastError(0); // just in case
            g_stdin_handle = GetStdHandle(STD_INPUT_HANDLE);
            if (!_is_valid_handle(g_stdin_handle)) {
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
                    _print_stderr_message(_T("invalid stdin handle: win_error=0x%08X (%d)\n"),
                        win_error, win_error);
                }
                if (flags.print_win_error_string && win_error) {
                    _print_win_error_message(win_error, options.win_error_langid);
                }
                break;
            }

            SetLastError(0); // just in case
            g_stdout_handle = GetStdHandle(STD_OUTPUT_HANDLE);
            if (!_is_valid_handle(g_stdout_handle)) {
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
                    _print_stderr_message(_T("invalid stdout handle: win_error=0x%08X (%d)\n"),
                        win_error, win_error);
                }
                if (flags.print_win_error_string && win_error) {
                    _print_win_error_message(win_error, options.win_error_langid);
                }
                break;
            }

            SetLastError(0); // just in case
            g_stderr_handle = GetStdHandle(STD_ERROR_HANDLE);
            if (!_is_valid_handle(g_stderr_handle)) {
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
                    _print_stderr_message(_T("invalid stderr handle: win_error=0x%08X (%d)\n"),
                        win_error, win_error);
                }
                if (flags.print_win_error_string && win_error) {
                    _print_win_error_message(win_error, options.win_error_langid);
                }
                break;
            }

            if (read_std_handles_iter > 0) break;

            // reopen closed std handles from `CONIN$`/`CONOUT$` files

            //#define FILE_TYPE_UNKNOWN   0x0000
            //#define FILE_TYPE_DISK      0x0001 // ReadFile
            //#define FILE_TYPE_CHAR      0x0002 // ReadConsoleInput, PeekConsoleInput
            //#define FILE_TYPE_PIPE      0x0003 // ReadFile, PeekNamedPipe
            //#define FILE_TYPE_REMOTE    0x8000
            //
            stdin_handle_type = GetFileType(g_stdin_handle);
            stdout_handle_type = GetFileType(g_stdout_handle);
            stderr_handle_type = GetFileType(g_stderr_handle);

            if (stdin_handle_type == FILE_TYPE_UNKNOWN) {
                _reattach_stdin_to_console(!g_no_std_inherit);
            }
            if (stdout_handle_type == FILE_TYPE_UNKNOWN) {
                _reattach_stdout_to_console(!g_no_std_inherit);
            }
            if (stderr_handle_type == FILE_TYPE_UNKNOWN) {
                _reattach_stderr_to_console(!g_no_std_inherit);
            }
        }

        if (g_no_std_inherit) {
            // reset std handles inheritance

            if (!options.reopen_stdin_as_file.empty() || !options.reopen_stdin_as_server_pipe.empty() || !options.reopen_stdin_as_client_pipe.empty()) {
                SetLastError(0); // just in case
                if (!::SetHandleInformation(g_stdin_handle, HANDLE_FLAG_INHERIT, FALSE)) {
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
                        _print_stderr_message(_T("could not set stdin handle information: win_error=0x%08X (%d) type=%u file=\"%s\"\n"),
                            win_error, win_error, GetFileType(g_stdin_handle), options.reopen_stdin_as_file.c_str());
                    }
                    if (flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, options.win_error_langid);
                    }
                    break;
                }
            }

            if (!options.reopen_stdout_as_file.empty() || !options.reopen_stdout_as_server_pipe.empty() || !options.reopen_stdout_as_client_pipe.empty()) {
                SetLastError(0); // just in case
                if (!::SetHandleInformation(g_stdout_handle, HANDLE_FLAG_INHERIT, FALSE)) {
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
                        _print_stderr_message(_T("could not set stdout handle information: win_error=0x%08X (%d) type=%u file=\"%s\"\n"),
                            win_error, win_error, GetFileType(g_stdout_handle), options.reopen_stdout_as_file.c_str());
                    }
                    if (flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, options.win_error_langid);
                    }
                    break;
                }
            }

            if (!options.reopen_stderr_as_file.empty() || !options.reopen_stderr_as_server_pipe.empty() || !options.reopen_stderr_as_client_pipe.empty()) {
                SetLastError(0); // just in case
                if (!::SetHandleInformation(g_stderr_handle, HANDLE_FLAG_INHERIT, FALSE)) {
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
                        _print_stderr_message(_T("could not set stderr handle information: win_error=0x%08X (%d) type=%u file=\"%s\"\n"),
                            win_error, win_error, GetFileType(g_stderr_handle), options.reopen_stderr_as_file.c_str());
                    }
                    if (flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, options.win_error_langid);
                    }
                    break;
                }
            }
        }

        // std handles dup

        if (!_is_valid_handle(g_stdout_handle)) {
            switch (options.stdout_dup) {
            case 2:
                SetLastError(0); // just in case
                if (!DuplicateHandle(GetCurrentProcess(), g_stderr_handle, GetCurrentProcess(), &g_stdout_handle, 0, g_no_std_inherit ? FALSE : TRUE, DUPLICATE_SAME_ACCESS)) {
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
                        _print_stderr_message(_T("could not duplicate stderr into stdout: win_error=0x%08X (%d) file=\"%s\"\n"),
                            win_error, win_error, options.tee_stderr_to_file.c_str());
                    }
                    if (flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, options.win_error_langid);
                    }
                    break_ = true;
                    break;
                }

                if (!_set_crt_std_handle(g_stdout_handle, 1, true, !g_no_std_inherit)) {
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
                        _print_stderr_message(_T("could not duplicate stdout before transfer handle ownership to CRT: win_error=0x%08X (%d) file=\"%s\"\n"),
                            win_error, win_error, options.reopen_stderr_as_file.c_str());
                    }
                    if (flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, options.win_error_langid);
                    }
                    break_ = true;
                    break;
                }
                break;
            }
        }

        if (break_) break;

        if (!_is_valid_handle(g_stderr_handle)) {
            switch (options.stderr_dup) {
            case 1:
                SetLastError(0); // just in case
                if (!DuplicateHandle(GetCurrentProcess(), g_stdout_handle, GetCurrentProcess(), &g_stderr_handle, 0, g_no_std_inherit ? FALSE : TRUE, DUPLICATE_SAME_ACCESS)) {
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
                        _print_stderr_message(_T("could not duplicate stdout into stderr: win_error=0x%08X (%d) file=\"%s\"\n"),
                            win_error, win_error, options.tee_stdout_to_file.c_str());
                    }
                    if (flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, options.win_error_langid);
                    }
                    break_ = true;
                    break;
                }

                if (!_set_crt_std_handle(g_stderr_handle, 2, true, !g_no_std_inherit)) {
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
                        _print_stderr_message(_T("could not duplicate stderr before transfer handle ownership to CRT: win_error=0x%08X (%d) file=\"%s\"\n"),
                            win_error, win_error, options.reopen_stdout_as_file.c_str());
                    }
                    if (flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, options.win_error_langid);
                    }
                    break_ = true;
                    break;
                }
                break;
            }
        }

        if (break_) break;

        // Accomplish all client pipe connections for all tee handles from here before duplicate them.
        //

        {
            auto & connect_client_named_pipe_thread_locals = g_connect_client_named_pipe_thread_locals[1];

            WaitForConnectNamedPipeThreads(connect_client_named_pipe_thread_locals, false);

            // check errors
            utility::for_each_unroll(connect_client_named_pipe_thread_locals, [&](auto & local) {
                if (!break_) {
                    // return error code from the first thread
                    if (local.thread_data.is_error) {
                        ret = local.thread_data.ret;
                        break_ = true;
                    }
                }
                if (!local.thread_data.is_copied && !local.thread_data.msg.empty()) {
                    g_worker_threads_return_data.add(local.thread_data);
                    local.thread_data.is_copied = true;
                }
            });

            if (break_) break;
        }

        // tee file handles dup

        if (!_is_valid_handle(g_tee_file_stdin_handle)) {
            switch (options.tee_stdin_dup) {
            case 1:
                SetLastError(0); // just in case
                if (!DuplicateHandle(GetCurrentProcess(), g_tee_file_stdout_handle, GetCurrentProcess(), &g_tee_file_stdin_handle, 0, FALSE, DUPLICATE_SAME_ACCESS)) {
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
                        _print_stderr_message(_T("could not duplicate stdout tee as file into stdin tee: win_error=0x%08X (%d) file=\"%s\"\n"),
                            win_error, win_error, options.tee_stdout_to_file.c_str());
                    }
                    if (flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, options.win_error_langid);
                    }
                    break_ = true;
                    break;
                }
                break;
            case 2:
                SetLastError(0); // just in case
                if (!DuplicateHandle(GetCurrentProcess(), g_tee_file_stderr_handle, GetCurrentProcess(), &g_tee_file_stdin_handle, 0, FALSE, DUPLICATE_SAME_ACCESS)) {
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
                        _print_stderr_message(_T("could not duplicate stderr tee as file into stdin tee: win_error=0x%08X (%d) file=\"%s\"\n"),
                            win_error, win_error, options.tee_stderr_to_file.c_str());
                    }
                    if (flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, options.win_error_langid);
                    }
                    break_ = true;
                    break;
                }
                break;
            }
        }

        if (break_) break;

        if (!_is_valid_handle(g_tee_file_stdout_handle)) {
            switch (options.tee_stdout_dup) {
            case 0:
                SetLastError(0); // just in case
                if (!DuplicateHandle(GetCurrentProcess(), g_tee_file_stdin_handle, GetCurrentProcess(), &g_tee_file_stdout_handle, 0, FALSE, DUPLICATE_SAME_ACCESS)) {
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
                        _print_stderr_message(_T("could not duplicate stdin tee as file into stdout tee: win_error=0x%08X (%d) file=\"%s\"\n"),
                            win_error, win_error, options.tee_stdin_to_file.c_str());
                    }
                    if (flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, options.win_error_langid);
                    }
                    break_ = true;
                    break;
                }
                break;
            case 2:
                SetLastError(0); // just in case
                if (!DuplicateHandle(GetCurrentProcess(), g_tee_file_stderr_handle, GetCurrentProcess(), &g_tee_file_stdout_handle, 0, FALSE, DUPLICATE_SAME_ACCESS)) {
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
                        _print_stderr_message(_T("could not duplicate stderr tee as file into stdout tee: win_error=0x%08X (%d) file=\"%s\"\n"),
                            win_error, win_error, options.tee_stderr_to_file.c_str());
                    }
                    if (flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, options.win_error_langid);
                    }
                    break_ = true;
                    break;
                }
                break;
            }
        }

        if (break_) break;

        if (!_is_valid_handle(g_tee_file_stderr_handle)) {
            switch (options.tee_stderr_dup) {
            case 0:
                SetLastError(0); // just in case
                if (!DuplicateHandle(GetCurrentProcess(), g_tee_file_stdin_handle, GetCurrentProcess(), &g_tee_file_stderr_handle, 0, FALSE, DUPLICATE_SAME_ACCESS)) {
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
                        _print_stderr_message(_T("could not duplicate stdin tee as file into stderr tee: win_error=0x%08X (%d) file=\"%s\"\n"),
                            win_error, win_error, options.tee_stdin_to_file.c_str());
                    }
                    if (flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, options.win_error_langid);
                    }
                    break_ = true;
                    break;
                }
                break;
            case 1:
                SetLastError(0); // just in case
                if (!DuplicateHandle(GetCurrentProcess(), g_tee_file_stdout_handle, GetCurrentProcess(), &g_tee_file_stderr_handle, 0, FALSE, DUPLICATE_SAME_ACCESS)) {
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
                        _print_stderr_message(_T("could not duplicate stdout tee as file into stderr tee: win_error=0x%08X (%d) file=\"%s\"\n"),
                            win_error, win_error, options.tee_stdout_to_file.c_str());
                    }
                    if (flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, options.win_error_langid);
                    }
                    break_ = true;
                    break;
                }
                break;
            }
        }

        if (break_) break;

        // tee named pipe handles dup

        if (!_is_valid_handle(g_tee_named_pipe_stdin_handle)) {
            switch (options.tee_stdin_dup) {
            case 1:
                SetLastError(0); // just in case
                if (!DuplicateHandle(GetCurrentProcess(), g_tee_named_pipe_stdout_handle, GetCurrentProcess(), &g_tee_named_pipe_stdin_handle, 0, FALSE, DUPLICATE_SAME_ACCESS)) {
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
                        if (!options.tee_stdout_to_server_pipe.empty()) {
                            _print_stderr_message(_T("could not duplicate stdout tee as server named pipe end into stdin tee: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                                win_error, win_error, options.tee_stdout_to_server_pipe.c_str());
                        }
                        else if (!options.tee_stdout_to_client_pipe.empty()) {
                            _print_stderr_message(_T("could not duplicate stdout tee as client named pipe end into stdin tee: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                                win_error, win_error, options.tee_stdout_to_client_pipe.c_str());
                        }
                    }
                    if (flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, options.win_error_langid);
                    }
                    break_ = true;
                    break;
                }
                break;
            case 2:
                SetLastError(0); // just in case
                if (!DuplicateHandle(GetCurrentProcess(), g_tee_named_pipe_stderr_handle, GetCurrentProcess(), &g_tee_named_pipe_stdin_handle, 0, FALSE, DUPLICATE_SAME_ACCESS)) {
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
                        if (!options.tee_stderr_to_server_pipe.empty()) {
                            _print_stderr_message(_T("could not duplicate stderr tee as server named pipe end into stdin tee: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                                win_error, win_error, options.tee_stderr_to_server_pipe.c_str());
                        }
                        else if (!options.tee_stderr_to_client_pipe.empty()) {
                            _print_stderr_message(_T("could not duplicate stderr tee as client named pipe end into stdin tee: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                                win_error, win_error, options.tee_stderr_to_client_pipe.c_str());
                        }
                    }
                    if (flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, options.win_error_langid);
                    }
                    break_ = true;
                    break;
                }
                break;
            }
        }

        if (break_) break;

        if (!_is_valid_handle(g_tee_named_pipe_stdout_handle)) {
            switch (options.tee_stdout_dup) {
            case 0:
                SetLastError(0); // just in case
                if (!DuplicateHandle(GetCurrentProcess(), g_tee_named_pipe_stdin_handle, GetCurrentProcess(), &g_tee_named_pipe_stdout_handle, 0, FALSE, DUPLICATE_SAME_ACCESS)) {
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
                        if (!options.tee_stdin_to_server_pipe.empty()) {
                            _print_stderr_message(_T("could not duplicate stdin tee as server named pipe end into stdout tee: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                                win_error, win_error, options.tee_stdin_to_server_pipe.c_str());
                        }
                        else if (!options.tee_stdin_to_client_pipe.empty()) {
                            _print_stderr_message(_T("could not duplicate stdin tee as client named pipe end into stdout tee: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                                win_error, win_error, options.tee_stdin_to_client_pipe.c_str());
                        }
                    }
                    if (flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, options.win_error_langid);
                    }
                    break_ = true;
                    break;
                }
                break;
            case 2:
                SetLastError(0); // just in case
                if (!DuplicateHandle(GetCurrentProcess(), g_tee_named_pipe_stderr_handle, GetCurrentProcess(), &g_tee_named_pipe_stdout_handle, 0, FALSE, DUPLICATE_SAME_ACCESS)) {
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
                        if (!options.tee_stderr_to_server_pipe.empty()) {
                            _print_stderr_message(_T("could not duplicate stderr tee as server named pipe end into stdout tee: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                                win_error, win_error, options.tee_stderr_to_server_pipe.c_str());
                        }
                        else if (!options.tee_stderr_to_client_pipe.empty()) {
                            _print_stderr_message(_T("could not duplicate stderr tee as client named pipe end into stdout tee: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                                win_error, win_error, options.tee_stderr_to_client_pipe.c_str());
                        }
                    }
                    if (flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, options.win_error_langid);
                    }
                    break_ = true;
                    break;
                }
                break;
            }
        }

        if (break_) break;

        if (!_is_valid_handle(g_tee_named_pipe_stderr_handle)) {
            switch (options.tee_stderr_dup) {
            case 0:
                SetLastError(0); // just in case
                if (!DuplicateHandle(GetCurrentProcess(), g_tee_named_pipe_stdin_handle, GetCurrentProcess(), &g_tee_named_pipe_stderr_handle, 0, FALSE, DUPLICATE_SAME_ACCESS)) {
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
                        if (!options.tee_stdin_to_server_pipe.empty()) {
                            _print_stderr_message(_T("could not duplicate stdin tee as server named pipe end into stderr tee: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                                win_error, win_error, options.tee_stdin_to_server_pipe.c_str());
                        }
                        else if (!options.tee_stdin_to_client_pipe.empty()) {
                            _print_stderr_message(_T("could not duplicate stdin tee as client named pipe end into stderr tee: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                                win_error, win_error, options.tee_stdin_to_client_pipe.c_str());
                        }
                    }
                    if (flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, options.win_error_langid);
                    }
                    break_ = true;
                    break;
                }
                break;
            case 1:
                SetLastError(0); // just in case
                if (!DuplicateHandle(GetCurrentProcess(), g_tee_file_stdout_handle, GetCurrentProcess(), &g_tee_file_stderr_handle, 0, FALSE, DUPLICATE_SAME_ACCESS)) {
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
                        if (!options.tee_stdout_to_server_pipe.empty()) {
                            _print_stderr_message(_T("could not duplicate stdout tee as server named pipe end into stderr tee: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                                win_error, win_error, options.tee_stdout_to_server_pipe.c_str());
                        }
                        else if (!options.tee_stdout_to_client_pipe.empty()) {
                            _print_stderr_message(_T("could not duplicate stdout tee as client named pipe end into stderr tee: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                                win_error, win_error, options.tee_stdout_to_client_pipe.c_str());
                        }
                    }
                    if (flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, options.win_error_langid);
                    }
                    break_ = true;
                    break;
                }
                break;
            }
        }

        if (break_) break;

        //#define FILE_TYPE_UNKNOWN   0x0000
        //#define FILE_TYPE_DISK      0x0001 // ReadFile
        //#define FILE_TYPE_CHAR      0x0002 // ReadConsoleInput, PeekConsoleInput
        //#define FILE_TYPE_PIPE      0x0003 // ReadFile, PeekNamedPipe
        //#define FILE_TYPE_REMOTE    0x8000
        //
        stdin_handle_type = g_stdin_handle_type = GetFileType(g_stdin_handle);
        stdout_handle_type = g_stdout_handle_type = GetFileType(g_stdout_handle);
        stderr_handle_type = g_stderr_handle_type = GetFileType(g_stderr_handle);

        bool has_outbound_pipe_from_conin = false;

        if (!g_no_std_inherit && !g_pipe_stdin_to_stdout) {
            if (stdin_handle_type == FILE_TYPE_DISK || stdin_handle_type == FILE_TYPE_PIPE) {
                if (!CreateOutboundPipeFromConsoleInput(ret, win_error, flags, options)) {
                    break;
                }

                has_outbound_pipe_from_conin = true;

                // CAUTION:
                //  We must set all handles being passed into a child process as inheritable,
                //  otherwise respective `ReadFile` on the pipe end in the parent process will be blocked!
                //  There is not enough to just pass a handle into the `CreateProcess`.
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
                        if (options.create_outbound_pipe_from_stdin.empty()) {
                            _print_stderr_message(_T("could not set stdin outbound anonymous pipe handle information: win_error=0x%08X (%d) type=%u file=\"%s\"\n"),
                                win_error, win_error, stdin_handle_type, options.reopen_stdin_as_file.c_str());
                        }
                        else {
                            _print_stderr_message(_T("could not set stdin outbound named pipe handle information: win_error=0x%08X (%d) type=%u file=\"%s\"\n"),
                                win_error, win_error, stdin_handle_type, options.reopen_stdin_as_file.c_str());
                        }
                    }
                    if (flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, options.win_error_langid);
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

            if (has_outbound_pipe_from_conin || _is_valid_handle(g_tee_file_stdout_handle)) {
                if (!CreateInboundPipeToConsoleOutput<1>(ret, win_error, flags, options)) {
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
                        if (options.create_inbound_pipe_to_stdout.empty()) {
                            _print_stderr_message(_T("could not set stdout inbound anonymous pipe handle information: win_error=0x%08X (%d) type=%u file=\"%s\"\n"),
                                win_error, win_error, stdout_handle_type, options.reopen_stdout_as_file.c_str());
                        }
                        else {
                            _print_stderr_message(_T("could not set stdout inbound named pipe handle information: win_error=0x%08X (%d) type=%u file=\"%s\"\n"),
                                win_error, win_error, stdout_handle_type, options.reopen_stdout_as_file.c_str());
                        }
                    }
                    if (flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, options.win_error_langid);
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
            else if (options.shell_exec_verb.empty()) {
                si.hStdOutput = g_stdout_handle;

                // CAUTION:
                //  This flag breaks a child process autocompletion in the call: `callf.exe "" "cmd.exe /k"`
                //  in case if one of handles is not character handle or console buffer.
                //
                si.dwFlags |= STARTF_USESTDHANDLES;
            }

            if (has_outbound_pipe_from_conin || _is_valid_handle(g_tee_file_stderr_handle)) {
                if (!CreateInboundPipeToConsoleOutput<2>(ret, win_error, flags, options)) {
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
                        if (options.create_inbound_pipe_to_stderr.empty()) {
                            _print_stderr_message(_T("could not set stderr inbound anonymous pipe handle information: win_error=0x%08X (%d) type=%u file=\"%s\"\n"),
                                win_error, win_error, stderr_handle_type, options.reopen_stderr_as_file.c_str());
                        }
                        else {
                            _print_stderr_message(_T("could not set stderr inbound named pipe handle information: win_error=0x%08X (%d) type=%u file=\"%s\"\n"),
                                win_error, win_error, stderr_handle_type, options.reopen_stderr_as_file.c_str());
                        }
                    }
                    if (flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, options.win_error_langid);
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
            else if (options.shell_exec_verb.empty()) {
                si.hStdError = g_stderr_handle;

                // CAUTION:
                //  This flag breaks a child process autocompletion in the call: `callf.exe "" "cmd.exe /k"`
                //  in case if one of handles is not character handle or console buffer.
                //
                si.dwFlags |= STARTF_USESTDHANDLES;
            }

            if (break_) break;
        }

        ret = err_none;
        win_error = 0;

        DWORD ret_create_proc = 0;
        const bool do_wait_child = !is_idle_execute &&
            (_is_valid_handle(g_tee_file_stdin_handle) || _is_valid_handle(g_tee_file_stdout_handle) || _is_valid_handle(g_tee_file_stderr_handle) ||
             _is_valid_handle(g_tee_named_pipe_stdin_handle) || _is_valid_handle(g_tee_named_pipe_stdout_handle) || _is_valid_handle(g_tee_named_pipe_stderr_handle) ||
             !flags.no_wait);

        // CAUTION:
        //  DO NOT USE `CREATE_NEW_PROCESS_GROUP` flag in the `CreateProcess`, otherwise a child process would ignore all signals.
        //

        if (!is_idle_execute) {
            if_break (app && app_len) {
                g_ctrl_handler = true;
                SetConsoleCtrlHandler(ChildCtrlHandler, TRUE);   // update parent console signal handler (does not work as expected)

                if (options.shell_exec_verb.empty()) {
                    if (cmd && cmd_len) {
                        // CAUTION:
                        //  cmd argument must be writable!
                        //
                        cmd_buf.resize((std::max)(cmd_len + sizeof(TCHAR), size_t(32768U)));
                        memcpy(cmd_buf.data(), cmd, cmd_buf.size());

                        SetLastError(0); // just in case
                        ret_create_proc = ::CreateProcess(app, (TCHAR *)cmd_buf.data(), NULL, NULL, TRUE,
                            flags.create_child_console ? CREATE_NEW_CONSOLE : 0,
                            NULL,
                            !options.change_current_dir.empty() ? options.change_current_dir.c_str() : NULL,
                            &si, &pi);

                        win_error = GetLastError();
                    }
                    else {
                        SetLastError(0); // just in case
                        ret_create_proc = ::CreateProcess(app, NULL, NULL, NULL, TRUE,
                            flags.create_child_console ? CREATE_NEW_CONSOLE : 0,
                            NULL,
                            !options.change_current_dir.empty() ? options.change_current_dir.c_str() : NULL,
                            &si, &pi);

                        win_error = GetLastError();
                    }
                }
                else {
                    sei.cbSize = sizeof(sei);
                    sei.fMask = SEE_MASK_NOCLOSEPROCESS; // use hProcess
                    if (flags.wait_child_start && do_wait_child) {
                        sei.fMask |= SEE_MASK_NOASYNC | SEE_MASK_FLAG_DDEWAIT;
                    }
                    if (flags.shell_exec_expand_env) {
                        sei.fMask |= SEE_MASK_DOENVSUBST;
                    }
                    if (flags.no_sys_dialog_ui) {
                        sei.fMask |= SEE_MASK_FLAG_NO_UI;
                    }
                    if (!flags.create_child_console) {
                        sei.fMask |= SEE_MASK_NO_CONSOLE;
                    }
                    if (!do_wait_child) {
                        sei.fMask |= SEE_MASK_ASYNCOK;
                    }

                    if (!options.shell_exec_verb.empty()) {
                        shell_exec_verb.resize(options.shell_exec_verb.length() + 1);
                        memcpy(shell_exec_verb.data(), options.shell_exec_verb.c_str(), shell_exec_verb.size() * sizeof(shell_exec_verb[0]));
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

                    win_error = GetLastError();

                    shell_error = (INT)sei.hInstApp;

                    if (_is_valid_handle(sei.hProcess)) {
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
                g_ctrl_handler = true;
                SetConsoleCtrlHandler(ChildCtrlHandler, TRUE);   // update parent console signal handler (does not work as expected)

                cmd_buf.resize((std::max)(cmd_len + sizeof(TCHAR), size_t(32768U)));
                memcpy(cmd_buf.data(), cmd, cmd_buf.size());

                SetLastError(0); // just in case
                ret_create_proc = ::CreateProcess(NULL, (TCHAR *)cmd_buf.data(), NULL, NULL, TRUE,
                    flags.create_child_console ? CREATE_NEW_CONSOLE : 0,
                    NULL,
                    !options.change_current_dir.empty() ? options.change_current_dir.c_str() : NULL,
                    &si, &pi);

                win_error = GetLastError();
            }

            if (_is_valid_handle(pi.hProcess)) {
                g_child_process_handle = pi.hProcess;       // to check the process status from stream pipe threads
                g_child_process_group_id = pi.dwProcessId;  // to pass parent console signal events into child process
            }
        }

        const bool is_child_executed = !is_idle_execute && ret_create_proc && _is_valid_handle(g_child_process_handle);

        if (!is_idle_execute) {
            if (is_child_executed) {
                g_is_process_executed = true;
            }
            else {
                if (!flags.no_print_gen_error_string) {
                    if (options.shell_exec_verb.empty()) {
                        _print_stderr_message(_T("could not create child process: win_error=0x%08X (%d) app=\"%s\" cmd=\"%s\"\n"),
                            win_error, win_error, app, cmd_buf.size() ? (TCHAR *)cmd_buf.data() : _T(""));
                    }
                    else {
                        _print_stderr_message(_T("could not shell execute child process: win_error=0x%08X (%d) shell_error=0x%08X (%d) file=\"%s\" params=\"%s\"\n"),
                            win_error, win_error, shell_error, shell_error, app, cmd);
                    }
                }

                if (flags.print_win_error_string && win_error) {
                    _print_win_error_message(win_error, options.win_error_langid);
                }

                if (flags.print_shell_error_string && shell_error != -1 && shell_error <= 32) {
                    _print_shell_exec_error_message(shell_error, sei);
                }
            }

            if (flags.ret_create_proc) {
                ret = ret_create_proc;
            }
            else if (flags.ret_win_error) {
                ret = win_error;
            }
            else if (!is_child_executed) {
                ret = err_win32_error;
            }
        }
        else {
            g_is_process_executed = true; // nop execution is a success
        }

        if (is_child_executed && !g_no_std_inherit) {
            // CAUTION:
            //  We must close all handles passed into a child process as inheritable,
            //  otherwise the `ReadFile` in the parent process will be blocked on the pipe end
            //  even if a child process is closed.
            //

            //if (stderr_handle_type == FILE_TYPE_CHAR) {
            //    _close_handle(g_stdin_handle);
            //}

            _close_handle(g_stdin_pipe_read_handle);
            _close_handle(g_stdout_pipe_write_handle);
            _close_handle(g_stderr_pipe_write_handle);
        }

        if (!g_pipe_stdin_to_stdout) {
            if (_is_valid_handle(g_stdin_handle) &&
                (_is_valid_handle(g_tee_file_stdin_handle) || _is_valid_handle(g_tee_named_pipe_stdin_handle) || _is_valid_handle(g_stdin_pipe_write_handle))) {
                g_stream_pipe_thread_locals[0].thread_handle = CreateThread(
                    NULL, 0,
                    StreamPipeThread<0>, &g_stream_pipe_thread_locals[0].thread_data,
                    0,
                    &g_stream_pipe_thread_locals[0].thread_id
                );
            }

            if (_is_valid_handle(g_stdout_pipe_read_handle) &&
                (_is_valid_handle(g_tee_file_stdout_handle) || _is_valid_handle(g_tee_named_pipe_stdout_handle) || _is_valid_handle(g_stdout_handle))) {
                g_stream_pipe_thread_locals[1].thread_handle = CreateThread(
                    NULL, 0,
                    StreamPipeThread<1>, &g_stream_pipe_thread_locals[1].thread_data,
                    0,
                    &g_stream_pipe_thread_locals[1].thread_id
                );
            }

            if (_is_valid_handle(g_stderr_pipe_read_handle) &&
                (_is_valid_handle(g_tee_file_stderr_handle) || _is_valid_handle(g_tee_named_pipe_stderr_handle) || _is_valid_handle(g_stderr_handle))) {
                g_stream_pipe_thread_locals[2].thread_handle = CreateThread(
                    NULL, 0,
                    StreamPipeThread<2>, &g_stream_pipe_thread_locals[2].thread_data,
                    0,
                    &g_stream_pipe_thread_locals[2].thread_id
                );
            }
        }
        else {
            if (_is_valid_handle(g_stdin_handle) && _is_valid_handle(g_stdout_handle) &&
                (stdin_handle_type == FILE_TYPE_DISK || stdin_handle_type == FILE_TYPE_PIPE)) {
                g_stdin_to_stdout_thread_locals.thread_handle = CreateThread(
                    NULL, 0,
                    StdinToStdoutThread, &g_stdin_to_stdout_thread_locals.thread_data,
                    0,
                    &g_stdin_to_stdout_thread_locals.thread_id);
            }
        }

        if (is_child_executed && do_wait_child) {
            WaitForSingleObject(g_child_process_handle, INFINITE);

            if (flags.ret_child_exit) {
                // read child process return code
                DWORD exit_code = 0;
                SetLastError(0); // just in case
                if (GetExitCodeProcess(g_child_process_handle, &exit_code)) {
                    ret = exit_code;
                }
                else {
                    ret = err_win32_error;
                    win_error = GetLastError();
                    if (!flags.no_print_gen_error_string) {
                        _print_stderr_message(_T("could not get child process exit code: win_error=0x%08X (%u)\n"),
                            win_error, win_error);
                    }
                    if (flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, options.win_error_langid);
                    }
                    break;
                }
            }
        }

        g_ctrl_handler = false;

        if (!g_pipe_stdin_to_stdout) {
            WaitForStreamPipeThreads(g_stream_pipe_thread_locals, false);
        }
        else {
            WaitForStreamPipeThreads(g_stdin_to_stdout_thread_locals, false);
        }
    }
    __finally {
        [&]() {
            g_ctrl_handler = false;

            // collect all threads return data

            if (!g_pipe_stdin_to_stdout) {
                auto & stream_pipe_thread_locals = g_stream_pipe_thread_locals;

                // suppress all exceptions while waiting after an exception
                [&]() { __try {
                    WaitForStreamPipeThreads(stream_pipe_thread_locals, true); // wait again with I/O cancel
                }
                __finally {
                    ;
                }
                }();

                // check errors
                utility::for_each_unroll(stream_pipe_thread_locals, [&](auto & local) {
                    if (!local.thread_data.is_copied && !local.thread_data.msg.empty()) {
                        g_worker_threads_return_data.add(local.thread_data);
                        local.thread_data.is_copied = true;
                    }
                });
            }
            else {
                auto & stdin_to_stdout_thread_locals = g_stdin_to_stdout_thread_locals;

                // suppress all exceptions while waiting after an exception
                [&]() { __try {
                    WaitForStreamPipeThreads(stdin_to_stdout_thread_locals, true); // wait again with I/O cancel
                }
                __finally {
                    ;
                }
                }();

                // check errors
                utility::for_each_unroll(make_singular_array(stdin_to_stdout_thread_locals), [&](auto & local) {
                    if (!local.thread_data.is_copied && !local.thread_data.msg.empty()) {
                        g_worker_threads_return_data.add(local.thread_data);
                        local.thread_data.is_copied = true;
                    }
                });
            }

            // Accomplish all server pipe connections before continue if not done yet.
            //

            {
                auto & connect_server_named_pipe_thread_locals = g_connect_server_named_pipe_thread_locals;

                // suppress all exceptions while waiting after an exception
                [&]() { __try {
                    WaitForConnectNamedPipeThreads(connect_server_named_pipe_thread_locals, true);
                }
                __finally {
                    ;
                }
                }();

                // check errors
                utility::for_each_unroll(connect_server_named_pipe_thread_locals, [&](auto & local) {
                    if (!local.thread_data.is_copied && !local.thread_data.msg.empty()) {
                        g_worker_threads_return_data.add(local.thread_data);
                        local.thread_data.is_copied = true;
                    }
                });
            }

            // print all registered messages
            if (!g_worker_threads_return_data.datas.empty()) {
                bool is_ret_updated = false;
                for (const auto & ret_data : g_worker_threads_return_data.datas) {
                    if (!flags.ret_create_proc && !flags.ret_child_exit) {
                        // return the first error code
                        if (!ret && !is_ret_updated && ret_data.is_error) {
                            if (!flags.ret_win_error) {
                                ret = ret_data.ret;
                            }
                            else {
                                ret = ret_data.win_error;
                            }
                            is_ret_updated = true;
                        }
                    }

                    if (!ret_data.is_error) {
                        _print_raw_message(1, _T("%s"), ret_data.msg.c_str());
                    }
                    else {
                        _print_raw_message(2, _T("%s"), ret_data.msg.c_str());
                    }
                }
            }

            // close shared resources at first
            if (options.chcp_in && options.chcp_in != prev_cp_in) {
                SetConsoleCP(prev_cp_in);
            }
            if (options.chcp_out && options.chcp_out != prev_cp_out) {
                SetConsoleCP(prev_cp_out);
            }

            // not shared resources

            // close reopened standard handles
            _close_handle(g_reopen_stdin_handle);
            _close_handle(g_reopen_stdout_handle);
            _close_handle(g_reopen_stderr_handle);

            // close tee file handles
            _close_handle(g_tee_file_stdin_handle);
            _close_handle(g_tee_file_stdout_handle);
            _close_handle(g_tee_file_stderr_handle);

            // close tee named pipe handles
            if (!options.tee_stdin_to_server_pipe.empty()) {
                CancelIo(g_tee_named_pipe_stdin_handle);
                DisconnectNamedPipe(g_tee_named_pipe_stdin_handle);
            }
            _close_handle(g_tee_named_pipe_stdin_handle);

            if (!options.tee_stdout_to_server_pipe.empty()) {
                CancelIo(g_tee_named_pipe_stdout_handle);
                DisconnectNamedPipe(g_tee_named_pipe_stdout_handle);
            }
            _close_handle(g_tee_named_pipe_stdout_handle);

            if (!options.tee_stderr_to_server_pipe.empty()) {
                CancelIo(g_tee_named_pipe_stderr_handle);
                DisconnectNamedPipe(g_tee_named_pipe_stderr_handle);
            }
            _close_handle(g_tee_named_pipe_stderr_handle);

            if (!is_idle_execute) {
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

                // close anonymous/named pipe handles connected with child process standard handles
                if (!options.create_outbound_pipe_from_stdin.empty()) {
                    CancelIo(g_stdin_pipe_write_handle);
                    DisconnectNamedPipe(g_stdin_pipe_write_handle);
                }
                _close_handle(g_stdin_pipe_write_handle);
                _close_handle(g_stdin_pipe_read_handle);

                if (!options.create_inbound_pipe_to_stdout.empty()) {
                    CancelIo(g_stdout_pipe_read_handle);
                    DisconnectNamedPipe(g_stdout_pipe_read_handle);
                }
                _close_handle(g_stdout_pipe_read_handle);
                _close_handle(g_stdout_pipe_write_handle);

                if (!options.create_inbound_pipe_to_stderr.empty()) {
                    CancelIo(g_stderr_pipe_read_handle);
                    DisconnectNamedPipe(g_stderr_pipe_read_handle);
                }
                _close_handle(g_stderr_pipe_read_handle);
                _close_handle(g_stderr_pipe_write_handle);
            }

            // in reverse order from threads to a process
            _close_handle(pi.hThread);
            _close_handle(g_child_process_handle, pi.hProcess);

            // close mutexes
            _close_handle(g_reopen_stdout_mutex);
            _close_handle(g_reopen_stderr_mutex);

            _close_handle(g_tee_file_stdin_mutex);
            _close_handle(g_tee_file_stdout_mutex);
            _close_handle(g_tee_file_stderr_mutex);
        }();
    } }();

    // TODO:
    //  Use break_ variable to break from lambda-with-seh-try:
    //  bool break_ = false;
    //  [&]() { if_break(true) __try {
    //    break_ = true; break;
    //  } }();
    //  if (break_) ...;
    //

    return ret;
}

std::tstring SubstNamePlaceholders(std::tstring str)
{
    std::tstring pid_str = std::to_tstring(GetCurrentProcessId());
    std::tstring ppid_str = std::to_tstring(g_parent_proc_id);

    std::tstring replaced_str = _replace_strings(str, _T("{pid}"), pid_str);
    return _replace_strings(replaced_str, _T("{ppid}"), ppid_str);
}

template DWORD WINAPI StreamPipeThread<0>(LPVOID lpParam);
template DWORD WINAPI StreamPipeThread<1>(LPVOID lpParam);
template DWORD WINAPI StreamPipeThread<2>(LPVOID lpParam);

template DWORD WINAPI ConnectServerNamedPipeThread<0, 0>(LPVOID lpParam);
template DWORD WINAPI ConnectServerNamedPipeThread<0, 1>(LPVOID lpParam);
template DWORD WINAPI ConnectServerNamedPipeThread<1, 0>(LPVOID lpParam);
template DWORD WINAPI ConnectServerNamedPipeThread<1, 1>(LPVOID lpParam);

template DWORD WINAPI ConnectClientNamedPipeThread<0, 0>(LPVOID lpParam);
template DWORD WINAPI ConnectClientNamedPipeThread<0, 1>(LPVOID lpParam);
template DWORD WINAPI ConnectClientNamedPipeThread<1, 0>(LPVOID lpParam);
template DWORD WINAPI ConnectClientNamedPipeThread<1, 1>(LPVOID lpParam);

template bool CreateInboundPipeToConsoleOutput<1>(int & ret, DWORD & win_error, const Flags & flags, const Options & options);
template bool CreateInboundPipeToConsoleOutput<2>(int & ret, DWORD & win_error, const Flags & flags, const Options & options);
