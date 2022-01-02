#include "execute.hpp"


enum TranslationMode {
    tm_unknown          = -1,
    tm_char_to_char     = 1,
    tm_wchar_to_wchar,
    tm_wchar_to_char,
    tm_char_to_wchar
};


#define MERGE_FLAG(flags, flag) \
    if (flags.flag) { \
        flag = flags.flag; \
    } \

#define MERGE_OPTION(options, option, def_value) \
    if (options.option != def_value) { \
        option = options.option; \
    } \

#define MERGE_OPTION_IF(options, option, exp) \
    if (exp) { \
        option = options.option; \
    } \

Flags g_flags                       = {};
Flags g_regular_flags               = {};
Flags g_elevate_parent_flags        = {};
Flags g_elevate_child_flags         = {};
Flags g_promote_flags               = {};
Flags g_promote_parent_flags        = {};

Options g_options                   = {};
Options g_regular_options           = {};
Options g_elevate_parent_options    = {};
Options g_elevate_child_options     = {};
Options g_promote_options           = {};
Options g_promote_parent_options    = {};

DWORD g_parent_proc_id              = -1;
HWND  g_inherited_console_window    = NULL; // may be inherited or owned or NULL
HWND  g_owned_console_window        = NULL; // owned or NULL

HANDLE g_stdin_handle               = INVALID_HANDLE_VALUE;
HANDLE g_stdout_handle              = INVALID_HANDLE_VALUE;
HANDLE g_stderr_handle              = INVALID_HANDLE_VALUE;

HANDLE g_stdout_handle_dup          = INVALID_HANDLE_VALUE;
HANDLE g_stderr_handle_dup          = INVALID_HANDLE_VALUE;

DWORD g_stdin_handle_type           = FILE_TYPE_UNKNOWN;
DWORD g_stdout_handle_type          = FILE_TYPE_UNKNOWN;
DWORD g_stderr_handle_type          = FILE_TYPE_UNKNOWN;

bool g_stdin_handle_inherit         = true;
bool g_stdout_handle_inherit        = true;
bool g_stderr_handle_inherit        = true;

HANDLE g_reopen_stdin_handle        = INVALID_HANDLE_VALUE;
HANDLE g_reopen_stdout_handle       = INVALID_HANDLE_VALUE;
HANDLE g_reopen_stderr_handle       = INVALID_HANDLE_VALUE;

HANDLE g_reopen_stdout_mutex        = INVALID_HANDLE_VALUE;
HANDLE g_reopen_stderr_mutex        = INVALID_HANDLE_VALUE;

_FileId g_reopen_stdout_fileid      = {};
_FileId g_reopen_stderr_fileid      = {};

// specialized tee file handles
HANDLE g_tee_file_stdin_handle      = INVALID_HANDLE_VALUE;
HANDLE g_tee_file_stdout_handle     = INVALID_HANDLE_VALUE;
HANDLE g_tee_file_stderr_handle     = INVALID_HANDLE_VALUE;

HANDLE g_tee_file_stdin_mutex       = INVALID_HANDLE_VALUE;
HANDLE g_tee_file_stdout_mutex      = INVALID_HANDLE_VALUE;
HANDLE g_tee_file_stderr_mutex      = INVALID_HANDLE_VALUE;

_FileId g_tee_file_stdin_fileid     = {};
_FileId g_tee_file_stdout_fileid    = {};
_FileId g_tee_file_stderr_fileid    = {};

// specialized tee named pipe handles
HANDLE g_tee_named_pipe_stdin_handle = INVALID_HANDLE_VALUE;
HANDLE g_tee_named_pipe_stdout_handle = INVALID_HANDLE_VALUE;
HANDLE g_tee_named_pipe_stderr_handle = INVALID_HANDLE_VALUE;

bool g_is_stdin_reopened            = false;
bool g_is_stdout_reopened           = false;
bool g_is_stderr_reopened           = false;

bool g_is_child_stdin_char_type     = false;    // is child process inherited stdin as character device

bool g_is_stdin_redirected          = false;
bool g_is_stdout_redirected         = false;
bool g_is_stderr_redirected         = false;

bool g_no_std_inherit               = false;    // stdin + stdout + stderr
bool g_no_stdin_inherit             = false;    // stdin
bool g_no_stdout_inherit            = false;    // stdout
bool g_no_stderr_inherit            = false;    // stderr

bool g_stdout_vt100                 = false;
bool g_stderr_vt100                 = false;

bool g_pipe_stdin_to_child_stdin    = false;
bool g_pipe_child_stdout_to_stdout  = false;
bool g_pipe_child_stderr_to_stderr  = false;
//bool g_pipe_inout_child             = false;
//bool g_pipe_out_child               = false;
bool g_pipe_stdin_to_stdout         = false;

bool g_tee_stdout_dup_stdin         = false;
bool g_tee_stderr_dup_stdin         = false;

bool g_has_tee_stdin                = false;
bool g_has_tee_stdout               = false;
bool g_has_tee_stderr               = false;

bool g_enable_child_ctrl_handler    = false;
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
ConnectNamedPipeThreadLocals g_connect_bound_server_named_pipe_tofrom_conin_thread_locals[3];
ConnectNamedPipeThreadLocals g_connect_server_named_pipe_thread_locals[2][3]; // <int handle_type, int co_stream_type>
ConnectNamedPipeThreadLocals g_connect_client_named_pipe_thread_locals[2][3]; // <int handle_type, int co_stream_type>

WorkerThreadsReturnData g_worker_threads_return_data;

// NOTE:
//  The `ReadConsole` Win32 API function has an issue when it can be blocked on the console input while the output handle is already closed.
//  To workaround that we have to watch for the output handle in a separate thread and call to `CloseHandle` on console input handle to interrupt the
//  `ReadConsole` and return to check the output handle.
//
WriteHandleWatchThreadLocals g_write_handle_watch_thread_locals[1]; // only for console stdin

Flags::Flags()
{
    // raw initialization
    memset(this, 0, sizeof(*this));
};

void Flags::merge(const Flags & flags)
{
    MERGE_FLAG(flags, disable_wow64_fs_redir);
    MERGE_FLAG(flags, disable_ctrl_signals);
    MERGE_FLAG(flags, disable_ctrl_c_signal);
#ifndef _CONSOLE
    MERGE_FLAG(flags, allow_gui_autoattach_to_parent_console);
#endif
    MERGE_FLAG(flags, disable_conout_reattach_to_visible_console);
    MERGE_FLAG(flags, disable_conout_duplicate_to_parent_console_on_error);

    MERGE_FLAG(flags, write_console_stdin_back);

    MERGE_FLAG(flags, elevate);

    MERGE_FLAG(flags, stdin_output_flush);
    MERGE_FLAG(flags, stdout_flush);
    MERGE_FLAG(flags, stderr_flush);
    MERGE_FLAG(flags, output_flush);
    MERGE_FLAG(flags, inout_flush);

    MERGE_FLAG(flags, stdout_vt100);
    MERGE_FLAG(flags, stderr_vt100);
    MERGE_FLAG(flags, output_vt100);

    MERGE_FLAG(flags, reopen_stdout_file_truncate);
    MERGE_FLAG(flags, reopen_stderr_file_truncate);

    MERGE_FLAG(flags, tee_conout_dup);

    MERGE_FLAG(flags, tee_stdin_file_truncate);
    MERGE_FLAG(flags, tee_stdout_file_truncate);
    MERGE_FLAG(flags, tee_stderr_file_truncate);
    MERGE_FLAG(flags, tee_stdin_file_flush);
    MERGE_FLAG(flags, tee_stdin_pipe_flush);
    MERGE_FLAG(flags, tee_stdin_flush);
    MERGE_FLAG(flags, tee_stdout_file_flush);
    MERGE_FLAG(flags, tee_stdout_pipe_flush);
    MERGE_FLAG(flags, tee_stdout_flush);
    MERGE_FLAG(flags, tee_stderr_file_flush);
    MERGE_FLAG(flags, tee_stderr_pipe_flush);
    MERGE_FLAG(flags, tee_stderr_flush);
    MERGE_FLAG(flags, tee_output_flush);
    MERGE_FLAG(flags, tee_inout_flush);

    MERGE_FLAG(flags, ret_create_proc);
    MERGE_FLAG(flags, ret_win_error);
    MERGE_FLAG(flags, ret_child_exit);

    MERGE_FLAG(flags, print_win_error_string);
    MERGE_FLAG(flags, print_shell_error_string);

    MERGE_FLAG(flags, pause_on_exit_if_error_before_exec);
    MERGE_FLAG(flags, pause_on_exit_if_error);
    MERGE_FLAG(flags, pause_on_exit);

    MERGE_FLAG(flags, no_print_gen_error_string);
    MERGE_FLAG(flags, no_sys_dialog_ui);
    MERGE_FLAG(flags, no_wait);
    MERGE_FLAG(flags, no_window);
    MERGE_FLAG(flags, no_window_console);
    MERGE_FLAG(flags, no_expand_env);
    MERGE_FLAG(flags, no_subst_vars);
    MERGE_FLAG(flags, no_subst_pos_vars);
    MERGE_FLAG(flags, no_subst_empty_tail_vars);
    MERGE_FLAG(flags, no_std_inherit);
    MERGE_FLAG(flags, no_stdin_inherit);
    MERGE_FLAG(flags, no_stdout_inherit);
    MERGE_FLAG(flags, no_stderr_inherit);

    MERGE_FLAG(flags, allow_throw_seh_except);
    MERGE_FLAG(flags, allow_expand_unexisted_env);
    MERGE_FLAG(flags, allow_subst_empty_args);

    MERGE_FLAG(flags, load_parent_proc_init_env_vars);

    MERGE_FLAG(flags, pipe_stdin_to_child_stdin);
    MERGE_FLAG(flags, pipe_child_stdout_to_stdout);
    MERGE_FLAG(flags, pipe_child_stderr_to_stderr);
    MERGE_FLAG(flags, pipe_inout_child);
    MERGE_FLAG(flags, pipe_out_child);
    MERGE_FLAG(flags, pipe_stdin_to_stdout);
    MERGE_FLAG(flags, shell_exec_expand_env);

    MERGE_FLAG(flags, stdin_echo);
    MERGE_FLAG(flags, no_stdin_echo);

    MERGE_FLAG(flags, create_child_console);
    MERGE_FLAG(flags, detach_child_console);
    MERGE_FLAG(flags, create_console);
    MERGE_FLAG(flags, detach_console);
    MERGE_FLAG(flags, attach_parent_console);

    MERGE_FLAG(flags, eval_backslash_esc);
    MERGE_FLAG(flags, eval_dbl_backslash_esc);

    MERGE_FLAG(flags, init_com);

    MERGE_FLAG(flags, wait_child_start);

    MERGE_FLAG(flags, mutex_std_writes);
    MERGE_FLAG(flags, mutex_tee_file_writes);
}

void Flags::clear()
{
    *this = Flags{};
}


Options::Options()
{
    chcp_in = chcp_out = win_error_langid = 0;

    stdout_dup = stderr_dup = -1;
    tee_stdin_dup = tee_stdout_dup = tee_stderr_dup = -1;

    reopen_stdin_as_server_pipe_connect_timeout_ms = DEFAULT_SERVER_NAMED_PIPE_CONNECT_TIMEOUT_MS;
    reopen_stdin_as_client_pipe_connect_timeout_ms = DEFAULT_CLIENT_NAMED_PIPE_CONNECT_TIMEOUT_MS;

    reopen_stdout_as_server_pipe_connect_timeout_ms = DEFAULT_SERVER_NAMED_PIPE_CONNECT_TIMEOUT_MS;
    reopen_stdout_as_client_pipe_connect_timeout_ms = DEFAULT_CLIENT_NAMED_PIPE_CONNECT_TIMEOUT_MS;

    reopen_stderr_as_server_pipe_connect_timeout_ms = DEFAULT_SERVER_NAMED_PIPE_CONNECT_TIMEOUT_MS;
    reopen_stderr_as_client_pipe_connect_timeout_ms = DEFAULT_CLIENT_NAMED_PIPE_CONNECT_TIMEOUT_MS;

    reopen_stdin_as_server_pipe_in_buf_size = DEFAULT_NAMED_PIPE_IN_BUF_SIZE;
    reopen_stdout_as_server_pipe_in_buf_size = DEFAULT_NAMED_PIPE_IN_BUF_SIZE;
    reopen_stderr_as_server_pipe_in_buf_size = DEFAULT_NAMED_PIPE_IN_BUF_SIZE;

    reopen_stdin_as_server_pipe_out_buf_size = DEFAULT_NAMED_PIPE_OUT_BUF_SIZE;
    reopen_stdout_as_server_pipe_out_buf_size = DEFAULT_NAMED_PIPE_OUT_BUF_SIZE;
    reopen_stderr_as_server_pipe_out_buf_size = DEFAULT_NAMED_PIPE_OUT_BUF_SIZE;

    create_outbound_server_pipe_from_stdin_connect_timeout_ms = DEFAULT_CLIENT_NAMED_PIPE_CONNECT_TIMEOUT_MS;
    create_inbound_server_pipe_to_stdout_connect_timeout_ms = DEFAULT_CLIENT_NAMED_PIPE_CONNECT_TIMEOUT_MS;
    create_inbound_server_pipe_to_stderr_connect_timeout_ms = DEFAULT_CLIENT_NAMED_PIPE_CONNECT_TIMEOUT_MS;

    create_outbound_server_pipe_from_stdin_in_buf_size = DEFAULT_NAMED_PIPE_IN_BUF_SIZE;
    create_inbound_server_pipe_to_stdout_in_buf_size = DEFAULT_NAMED_PIPE_IN_BUF_SIZE;
    create_inbound_server_pipe_to_stderr_in_buf_size = DEFAULT_NAMED_PIPE_IN_BUF_SIZE;

    create_outbound_server_pipe_from_stdin_out_buf_size = DEFAULT_NAMED_PIPE_OUT_BUF_SIZE;
    create_inbound_server_pipe_to_stdout_out_buf_size = DEFAULT_NAMED_PIPE_OUT_BUF_SIZE;
    create_inbound_server_pipe_to_stderr_out_buf_size = DEFAULT_NAMED_PIPE_OUT_BUF_SIZE;

    tee_stdin_to_server_pipe_connect_timeout_ms = DEFAULT_SERVER_NAMED_PIPE_CONNECT_TIMEOUT_MS;
    tee_stdin_to_client_pipe_connect_timeout_ms = DEFAULT_CLIENT_NAMED_PIPE_CONNECT_TIMEOUT_MS;

    tee_stdout_to_server_pipe_connect_timeout_ms = DEFAULT_SERVER_NAMED_PIPE_CONNECT_TIMEOUT_MS;
    tee_stdout_to_client_pipe_connect_timeout_ms = DEFAULT_CLIENT_NAMED_PIPE_CONNECT_TIMEOUT_MS;

    tee_stderr_to_server_pipe_connect_timeout_ms = DEFAULT_SERVER_NAMED_PIPE_CONNECT_TIMEOUT_MS;
    tee_stderr_to_client_pipe_connect_timeout_ms = DEFAULT_CLIENT_NAMED_PIPE_CONNECT_TIMEOUT_MS;

    tee_stdin_to_server_pipe_in_buf_size = DEFAULT_NAMED_PIPE_IN_BUF_SIZE;
    tee_stdout_to_server_pipe_in_buf_size = DEFAULT_NAMED_PIPE_IN_BUF_SIZE;
    tee_stderr_to_server_pipe_in_buf_size = DEFAULT_NAMED_PIPE_IN_BUF_SIZE;

    tee_stdin_to_server_pipe_out_buf_size = DEFAULT_NAMED_PIPE_OUT_BUF_SIZE;
    tee_stdout_to_server_pipe_out_buf_size = DEFAULT_NAMED_PIPE_OUT_BUF_SIZE;
    tee_stderr_to_server_pipe_out_buf_size = DEFAULT_NAMED_PIPE_OUT_BUF_SIZE;

    tee_stdin_pipe_buf_size = DEFAULT_ANONYMOUS_PIPE_BUF_SIZE;
    tee_stdout_pipe_buf_size = DEFAULT_ANONYMOUS_PIPE_BUF_SIZE;
    tee_stderr_pipe_buf_size = DEFAULT_ANONYMOUS_PIPE_BUF_SIZE;

    // 64K read buffer by default
    tee_stdin_read_buf_size = DEFAULT_READ_BUF_SIZE;
    tee_stdout_read_buf_size = DEFAULT_READ_BUF_SIZE;
    tee_stderr_read_buf_size = DEFAULT_READ_BUF_SIZE;

    show_as = SW_SHOWNORMAL;
}

void Options::merge(const Options & options)
{
    MERGE_OPTION(options, shell_exec_verb, std::tstring{});
    MERGE_OPTION(options, change_current_dir, std::tstring{});

    MERGE_OPTION(options, reopen_stdin_as_file, std::tstring{});
    MERGE_OPTION(options, reopen_stdin_as_server_pipe, std::tstring{});
    MERGE_OPTION(options, reopen_stdin_as_client_pipe, std::tstring{});
    MERGE_OPTION(options, reopen_stdout_as_file, std::tstring{});
    MERGE_OPTION(options, reopen_stdout_as_server_pipe, std::tstring{});
    MERGE_OPTION(options, reopen_stdout_as_client_pipe, std::tstring{});
    MERGE_OPTION(options, reopen_stderr_as_file, std::tstring{});
    MERGE_OPTION(options, reopen_stderr_as_server_pipe, std::tstring{});
    MERGE_OPTION(options, reopen_stderr_as_client_pipe, std::tstring{});

    MERGE_OPTION(options, tee_stdin_to_file, std::tstring{});
    MERGE_OPTION(options, tee_stdin_to_server_pipe, std::tstring{});
    MERGE_OPTION(options, tee_stdin_to_client_pipe, std::tstring{});
    MERGE_OPTION(options, tee_stdout_to_file, std::tstring{});
    MERGE_OPTION(options, tee_stdout_to_server_pipe, std::tstring{});
    MERGE_OPTION(options, tee_stdout_to_client_pipe, std::tstring{});
    MERGE_OPTION(options, tee_stderr_to_file, std::tstring{});
    MERGE_OPTION(options, tee_stderr_to_server_pipe, std::tstring{});
    MERGE_OPTION(options, tee_stderr_to_client_pipe, std::tstring{});

    MERGE_OPTION_IF(options, create_console_title, options.has.create_console_title);
    MERGE_OPTION_IF(options, own_console_title, options.has.own_console_title);
    MERGE_OPTION_IF(options, console_title, options.has.console_title);

    MERGE_OPTION(options, create_outbound_server_pipe_from_stdin, std::tstring{});
    MERGE_OPTION(options, create_inbound_server_pipe_to_stdout, std::tstring{});
    MERGE_OPTION(options, create_inbound_server_pipe_to_stderr, std::tstring{});

    MERGE_OPTION(options, chcp_in, 0);
    MERGE_OPTION(options, chcp_out, 0);
    MERGE_OPTION(options, win_error_langid, 0);

    MERGE_OPTION(options, stdout_dup, -1);
    MERGE_OPTION(options, stderr_dup, -1);

    MERGE_OPTION(options, tee_stdin_dup, -1);
    MERGE_OPTION(options, tee_stdout_dup, -1);
    MERGE_OPTION(options, tee_stderr_dup, -1);

    MERGE_OPTION(options, reopen_stdin_as_server_pipe_connect_timeout_ms, 0);
    MERGE_OPTION(options, reopen_stdin_as_client_pipe_connect_timeout_ms, 0);
    MERGE_OPTION(options, reopen_stdout_as_server_pipe_connect_timeout_ms, 0);
    MERGE_OPTION(options, reopen_stdout_as_client_pipe_connect_timeout_ms, 0);
    MERGE_OPTION(options, reopen_stderr_as_server_pipe_connect_timeout_ms, 0);
    MERGE_OPTION(options, reopen_stderr_as_client_pipe_connect_timeout_ms, 0);

    MERGE_OPTION(options, reopen_stdin_as_server_pipe_in_buf_size, 0);
    MERGE_OPTION(options, reopen_stdin_as_server_pipe_out_buf_size, 0);
    MERGE_OPTION(options, reopen_stdout_as_server_pipe_in_buf_size, 0);
    MERGE_OPTION(options, reopen_stdout_as_server_pipe_out_buf_size, 0);
    MERGE_OPTION(options, reopen_stderr_as_server_pipe_in_buf_size, 0);
    MERGE_OPTION(options, reopen_stderr_as_server_pipe_out_buf_size, 0);

    MERGE_OPTION(options, create_outbound_server_pipe_from_stdin_connect_timeout_ms, 0);
    MERGE_OPTION(options, create_inbound_server_pipe_to_stdout_connect_timeout_ms, 0);
    MERGE_OPTION(options, create_inbound_server_pipe_to_stderr_connect_timeout_ms, 0);

    MERGE_OPTION(options, create_outbound_server_pipe_from_stdin_in_buf_size, 0);
    MERGE_OPTION(options, create_outbound_server_pipe_from_stdin_out_buf_size, 0);
    MERGE_OPTION(options, create_inbound_server_pipe_to_stdout_in_buf_size, 0);
    MERGE_OPTION(options, create_inbound_server_pipe_to_stdout_out_buf_size, 0);
    MERGE_OPTION(options, create_inbound_server_pipe_to_stderr_in_buf_size, 0);
    MERGE_OPTION(options, create_inbound_server_pipe_to_stderr_out_buf_size, 0);

    MERGE_OPTION(options, tee_stdin_to_server_pipe_connect_timeout_ms, 0);
    MERGE_OPTION(options, tee_stdin_to_client_pipe_connect_timeout_ms, 0);
    MERGE_OPTION(options, tee_stdout_to_server_pipe_connect_timeout_ms, 0);
    MERGE_OPTION(options, tee_stdout_to_client_pipe_connect_timeout_ms, 0);
    MERGE_OPTION(options, tee_stderr_to_server_pipe_connect_timeout_ms, 0);
    MERGE_OPTION(options, tee_stderr_to_client_pipe_connect_timeout_ms, 0);

    MERGE_OPTION(options, tee_stdin_to_server_pipe_in_buf_size, 0);
    MERGE_OPTION(options, tee_stdin_to_server_pipe_out_buf_size, 0);
    MERGE_OPTION(options, tee_stdout_to_server_pipe_in_buf_size, 0);
    MERGE_OPTION(options, tee_stdout_to_server_pipe_out_buf_size, 0);
    MERGE_OPTION(options, tee_stderr_to_server_pipe_in_buf_size, 0);
    MERGE_OPTION(options, tee_stderr_to_server_pipe_out_buf_size, 0);

    MERGE_OPTION(options, tee_stdin_pipe_buf_size, 0);
    MERGE_OPTION(options, tee_stdout_pipe_buf_size, 0);
    MERGE_OPTION(options, tee_stderr_pipe_buf_size, 0);
    MERGE_OPTION(options, tee_stdin_read_buf_size, 0);
    MERGE_OPTION(options, tee_stdout_read_buf_size, 0);
    MERGE_OPTION(options, tee_stderr_read_buf_size, 0);

    MERGE_OPTION(options, show_as, SW_SHOWNORMAL);

    for (const auto & tuple_ref : options.expand_env_args) {
        expand_env_args.push_back(tuple_ref);
    }

    for (const auto & tuple_ref : options.subst_vars_args) {
        subst_vars_args.push_back(tuple_ref);
    }

    for (const auto & tuple_ref : options.replace_args) {
        replace_args.push_back(tuple_ref);
    }

    for (const auto & tuple_ref : options.env_vars) {
        env_vars.push_back(tuple_ref);
    }

    for (const auto & tuple_ref : options.eval_backslash_esc) {
        eval_backslash_esc.push_back(tuple_ref);
    }

    has = options.has;
}

void Options::clear()
{
    *this = Options{};
}


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

DWORD WINAPI WriteHandleWatchThread(LPVOID lpParam)
{
    WriteHandleWatchThreadData & thread_data = *static_cast<WriteHandleWatchThreadData *>(lpParam);

    DWORD num_bytes_written = 0;

    while (!thread_data.cancel_io) {
        // check on write handle error
        SetLastError(0); // just in case
        if (!WriteFile(thread_data.write_handle, "", 0, &num_bytes_written, NULL)) {
            //FreeConsole(); // CAUTION: raises Access Violation under Windows 7
            _close_handle(*thread_data.read_handle_ptr);
            break;
        }

        // loop wait
        Sleep(20);
    }

    return 0;
}

template <int stream_type>
DWORD WINAPI StreamPipeThread(LPVOID lpParam)
{
    StreamPipeThreadData & thread_data = *static_cast<StreamPipeThreadData *>(lpParam);

    thread_data.ret = err_unspecified;

    bool stream_eof = false;

    DWORD num_bytes_avail = 0;
    DWORD num_bytes_read = 0;
    DWORD num_bytes_written = 0;
    //DWORD num_events_avail = 0;
    //DWORD num_events_read = 0;
    DWORD num_events_written = 0;
    DWORD num_chars_read = 0;
    DWORD num_chars_written = 0;
    DWORD win_error = 0;

    std::vector<std::uint8_t> stdin_byte_buf;
    std::vector<std::uint8_t> stdout_byte_buf;
    std::vector<std::uint8_t> stderr_byte_buf;

    bool break_ = false;

    // NOTE:
    //  lambda to bypass msvc error: `error C2712: Cannot use __try in functions that require object unwinding`
    //
    [&]() { __try {
        [&]() {
            switch (stream_type) {
            case STDIN_FILENO: // stdin
            {
                // Accomplish all server pipe connections before continue.
                //

                {
                    auto & connect_server_named_pipe_thread_local = g_connect_bound_server_named_pipe_tofrom_conin_thread_locals[stream_type];

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
                    stdin_byte_buf.resize((std::max)(g_options.tee_stdin_read_buf_size, 1U));

                    while (!stream_eof) {
                        // in case if the child process is exited
                        if (WaitForSingleObject(g_child_process_handle, 0) != WAIT_TIMEOUT) {
                            break;
                        }

                        SetLastError(0); // just in case
                        if (!ReadFile(g_stdin_handle, stdin_byte_buf.data(), g_options.tee_stdin_read_buf_size, &num_bytes_read, NULL)) {
                            if (thread_data.cancel_io) break;

                            win_error = GetLastError();
                            if (win_error && win_error != ERROR_NO_DATA && win_error != ERROR_BROKEN_PIPE && win_error != ERROR_PIPE_NOT_CONNECTED) {
                                thread_data.ret = err_io_error;
                                thread_data.win_error = win_error;
                                if (!g_flags.no_print_gen_error_string) {
                                    thread_data.msg =
                                        _format_stderr_message(_T("stdin file read error: win_error=0x%08X (%d)\n"),
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
                                if (WriteFile(g_stdin_pipe_write_handle, stdin_byte_buf.data(), num_bytes_read, &num_bytes_written, NULL)) {
                                    if (g_flags.stdin_output_flush || g_flags.inout_flush) {
                                        FlushFileBuffers(g_stdin_pipe_write_handle);
                                    }

                                    if (thread_data.cancel_io) break;
                                }
                                else {
                                    if (thread_data.cancel_io) break;

                                    win_error = GetLastError();
                                    if (win_error && win_error != ERROR_NO_DATA && win_error != ERROR_BROKEN_PIPE && win_error != ERROR_PIPE_NOT_CONNECTED) {
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
                } break;

                case FILE_TYPE_PIPE:
                {
                    stdin_byte_buf.resize((std::max)(g_options.tee_stdin_read_buf_size, 1U));

                    while (!stream_eof) {
                        // in case if the child process is exited but the output handle is somehow alive (leaked) and not broken
                        if (WaitForSingleObject(g_child_process_handle, 0) != WAIT_TIMEOUT) {
                            break;
                        }

                        num_bytes_read = num_bytes_avail = 0;

                        // CAUTION:
                        //  We is required `PeekNamedPipe` here before the `ReadFile` because of potential break in the output handle, when
                        //  the input handle has no data to read but the output handle is already closed or broken.
                        //  In that case we must call to `WriteFile` even if has no data on the input.
                        //

                        SetLastError(0); // just in case
                        if (!PeekNamedPipe(g_stdin_handle, NULL, 0, NULL, &num_bytes_avail, NULL)) {
                            if (thread_data.cancel_io) break;

                            win_error = GetLastError();
                            if (win_error && win_error != ERROR_NO_DATA && win_error != ERROR_BROKEN_PIPE && win_error != ERROR_PIPE_NOT_CONNECTED) {
                                thread_data.ret = err_io_error;
                                thread_data.win_error = win_error;
                                if (!g_flags.no_print_gen_error_string) {
                                    thread_data.msg =
                                        _format_stderr_message(_T("stdin pipe peek error: win_error=0x%08X (%d)\n"),
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
                                if (win_error && win_error != ERROR_NO_DATA && win_error != ERROR_BROKEN_PIPE && win_error != ERROR_PIPE_NOT_CONNECTED) {
                                    thread_data.ret = err_io_error;
                                    thread_data.win_error = win_error;
                                    if (!g_flags.no_print_gen_error_string) {
                                        thread_data.msg =
                                            _format_stderr_message(_T("stdin pipe read error: win_error=0x%08X (%d)\n"),
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
                                if (WriteFile(g_stdin_pipe_write_handle, stdin_byte_buf.data(), num_bytes_read, &num_bytes_written, NULL)) {
                                    if (g_flags.stdin_output_flush || g_flags.inout_flush) {
                                        FlushFileBuffers(g_stdin_pipe_write_handle);
                                    }

                                    if (thread_data.cancel_io) break;
                                }
                                else {
                                    if (thread_data.cancel_io) break;

                                    win_error = GetLastError();
                                    if (win_error && win_error != ERROR_NO_DATA && win_error != ERROR_BROKEN_PIPE && win_error != ERROR_PIPE_NOT_CONNECTED) {
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

                        if (_is_valid_handle(g_stdin_pipe_write_handle)) {
                            if (!num_bytes_read && !stream_eof) {
                                // check on outbound write error
                                SetLastError(0); // just in case
                                if (!WriteFile(g_stdin_pipe_write_handle, "", 0, &num_bytes_written, NULL)) {
                                    if (thread_data.cancel_io) break;

                                    stream_eof = true;
                                }
                            }
                        }

                        if (!num_bytes_read && !stream_eof) {
                            // loop wait
                            Sleep(20);

                            if (thread_data.cancel_io) break;
                        }
                    }
                } break;

                case FILE_TYPE_CHAR:
                {
                    // CAUTION:
                    //  This branch has no native Win32 implementation portable between Win XP/7/8/10 windows versions.
                    //  The `CreatePseudoConsole` API function is available only after the `Windows 10 October 2018 Update (version 1809) [desktop apps only]`
                    //  The complete implementation which can be provided here can be done through a remote code injection to a child process and is not yet available.
                    //

                    std::vector<wchar_t> stdin_wchar_buf;

                    std::vector<char> translated_char_buf;
                    std::vector<wchar_t> translated_wchar_buf;

                    std::vector<INPUT_RECORD> input_records;

                    int num_translated_bytes;
                    //int num_translated_chars;

                    TranslationMode translation_mode = tm_unknown;

                    const UINT cp_in = GetConsoleCP();
                    const UINT cp_out = GetConsoleOutputCP();
    
                    // CAUTION:
                    //  The `ReadConsoleInput` function can fail if the length parameter is too big!
                    //
                    const DWORD tee_stdin_read_num_chars = (std::min)((g_options.tee_stdin_read_buf_size + sizeof(wchar_t) - 1) / sizeof(wchar_t), 16384U); // otherwise ReadConsole returns ERROR_NOT_ENOUGH_MEMORY

                    CONSOLE_READCONSOLE_CONTROL console_read_control{};

                    switch (cp_in) {
                    case 1200: // UTF-16LE
                    case 1201: // UTF-16BE
                        switch (cp_out) {
                        case 1200: // UTF-16LE
                        case 1201: // UTF-16BE
                            translation_mode = tm_wchar_to_wchar;
                            break;

                        default:
                            translation_mode = tm_wchar_to_char;

                            translated_char_buf.reserve(256); // just in case
                            break;
                        }
                        break;

                    default:
                        switch (cp_out) {
                        case 1200: // UTF-16LE
                        case 1201: // UTF-16BE
                            translation_mode = tm_char_to_wchar;

                            translated_wchar_buf.reserve(256); // just in case
                            break;

                        default:
                            translation_mode = tm_char_to_char;
                            break;
                        }
                        break;
                    }

                    stdin_wchar_buf.resize(tee_stdin_read_num_chars); // MSDN: ReadConsole

                    console_read_control.nLength = sizeof(console_read_control);

                    // ctrl-d           = (1 << 4)
                    // ctrl-z           = (1 << 26)
                    // carriage return  = (1 << '\r')
                    // line-feed        = (1 << '\n')
                    //
                    //  Details: https://stackoverflow.com/questions/43836040/win-api-readconsole/43836992#43836992
                    //

                    console_read_control.dwCtrlWakeupMask = (1 << 4) | (1 << 26) | (1 << '\n');

                    // write handle watch thread
                    if_break (_is_valid_handle(g_stdin_pipe_write_handle)) {
                        // in case if child process exit
                        if (WaitForSingleObject(g_child_process_handle, 0) != WAIT_TIMEOUT) {
                            stream_eof = true;
                            break;
                        }

                        g_write_handle_watch_thread_locals[0].thread_data.read_handle_ptr = &g_stdin_handle;
                        g_write_handle_watch_thread_locals[0].thread_data.write_handle = g_stdin_pipe_write_handle;

                        g_write_handle_watch_thread_locals[0].thread_handle =
                            CreateThread(
                                NULL, 0,
                                WriteHandleWatchThread, &g_write_handle_watch_thread_locals[0].thread_data,
                                0,
                                &g_write_handle_watch_thread_locals[0].thread_id);
                    }

                    while (!stream_eof) {
                        // in case if child process exit
                        if (WaitForSingleObject(g_child_process_handle, 0) != WAIT_TIMEOUT) {
                            break;
                        }

                        SetLastError(0); // just in case
                        if (!ReadConsoleW(g_stdin_handle, stdin_wchar_buf.data(), tee_stdin_read_num_chars, &num_chars_read, &console_read_control)) { // always use unicode
                            if (thread_data.cancel_io) break;

                            win_error = GetLastError();
                            if (win_error) {
                                thread_data.ret = err_io_error;
                                thread_data.win_error = win_error;
                                if (!g_flags.no_print_gen_error_string) {
                                    thread_data.msg =
                                        _format_stderr_message(_T("stdin character device read error: win_error=0x%08X (%d)\n"),
                                            win_error, win_error);
                                }
                                if (g_flags.print_win_error_string && win_error) {
                                    thread_data.msg +=
                                        _format_win_error_message(win_error);
                                }
                                thread_data.is_error = true;
                            }

                            stream_eof = true;
                        }

                        if (num_chars_read) {
                            switch (translation_mode) {
                            case tm_char_to_char:
                            case tm_wchar_to_char:
                                // Unicode -> Ascii
                                num_translated_bytes = _wide_char_to_multi_byte(cp_out, stdin_wchar_buf.data(), num_chars_read, translated_char_buf);
                                break;

                            case tm_wchar_to_wchar:
                            case tm_char_to_wchar:
                                // Unicode -> Unicode
                                break;
                            }

                            if (_is_valid_handle(g_tee_file_stdin_handle)) {
                                [&]() { __try {
                                    if (_is_valid_handle(g_tee_file_stdin_mutex)) {
                                        WaitForSingleObject(g_tee_file_stdin_mutex, INFINITE);
                                    }

                                    SetFilePointer(g_tee_file_stdin_handle, 0, NULL, FILE_END);

                                    switch (translation_mode) {
                                    case tm_char_to_char:
                                    case tm_wchar_to_char:
                                        WriteFile(g_tee_file_stdin_handle, num_translated_bytes ? translated_char_buf.data() : "", num_translated_bytes, &num_bytes_written, NULL);
                                        break;

                                    case tm_wchar_to_wchar:
                                    case tm_char_to_wchar:
                                        WriteFile(g_tee_file_stdin_handle, stdin_wchar_buf.data(), num_chars_read * sizeof(wchar_t), &num_bytes_written, NULL);
                                        break;
                                    }

                                    if (thread_data.cancel_io) return;

                                    if (g_flags.tee_stdin_file_flush || g_flags.tee_stdin_flush || g_flags.tee_inout_flush) {
                                        FlushFileBuffers(g_tee_file_stdin_handle);
                                        if (thread_data.cancel_io) return;
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
                                switch (translation_mode) {
                                case tm_char_to_char:
                                case tm_wchar_to_char:
                                    WriteFile(g_tee_named_pipe_stdin_handle, num_translated_bytes ? translated_char_buf.data() : "", num_translated_bytes, &num_bytes_written, NULL);
                                    break;

                                case tm_wchar_to_wchar:
                                case tm_char_to_wchar:
                                    WriteFile(g_tee_named_pipe_stdin_handle, stdin_wchar_buf.data(), num_chars_read * sizeof(wchar_t), &num_bytes_written, NULL);
                                    break;
                                }

                                if (thread_data.cancel_io) break;

                                if (g_flags.tee_stdin_pipe_flush || g_flags.tee_stdin_flush || g_flags.tee_inout_flush) {
                                    FlushFileBuffers(g_tee_named_pipe_stdin_handle);
                                    if (thread_data.cancel_io) break;
                                }
                            }

                            if (_is_valid_handle(g_stdin_pipe_write_handle)) {
                                BOOL is_written = FALSE;

                                SetLastError(0); // just in case

                                switch (translation_mode) {
                                case tm_char_to_char:
                                case tm_wchar_to_char:
                                    is_written = WriteFile(g_stdin_pipe_write_handle, num_translated_bytes ? translated_char_buf.data() : "", num_translated_bytes, &num_bytes_written, NULL);
                                    break;

                                case tm_wchar_to_wchar:
                                case tm_char_to_wchar:
                                    is_written = WriteFile(g_stdin_pipe_write_handle, stdin_wchar_buf.data(), num_chars_read * sizeof(wchar_t), &num_bytes_written, NULL);
                                    break;
                                }

                                if (is_written) {
                                    if (g_flags.stdin_output_flush || g_flags.inout_flush) {
                                        FlushFileBuffers(g_stdin_pipe_write_handle);
                                    }

                                    if (thread_data.cancel_io) break;
                                }
                                else {
                                    if (thread_data.cancel_io) break;

                                    win_error = GetLastError();
                                    if (win_error && win_error != ERROR_NO_DATA && win_error != ERROR_BROKEN_PIPE && win_error != ERROR_PIPE_NOT_CONNECTED) {
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

                            if (g_is_child_stdin_char_type && g_flags.write_console_stdin_back) {
                                // return string back to be able to read by a child process ReadConsole

                                input_records.reserve(num_chars_read * 2);
                                input_records.clear();

                                for (size_t i = 0; i < num_chars_read; i++) {
                                    const wchar_t input_char = stdin_wchar_buf[i];

                                    //if (input_char == L'\n') {
                                    //    continue;
                                    //}

                                    input_records.push_back(INPUT_RECORD{ KEY_EVENT, KEY_EVENT_RECORD{ TRUE, 1, 0, 0, (WCHAR)input_char, 0 } });
                                    input_records.push_back(INPUT_RECORD{ KEY_EVENT, KEY_EVENT_RECORD{ FALSE, 1, 0, 0, (WCHAR)input_char, 0 } });
                                }

                                // in case if child process exit
                                if (WaitForSingleObject(g_child_process_handle, 0) != WAIT_TIMEOUT) {
                                    break;
                                }

                                WriteConsoleInput(g_stdin_handle, input_records.data(), input_records.size(), &num_events_written);
                            }
                        }

                        if (_is_valid_handle(g_stdin_pipe_write_handle)) {
                            if (!num_chars_read && !stream_eof) {
                                // check on outbound write error
                                SetLastError(0); // just in case
                                if (!WriteFile(g_stdin_pipe_write_handle, "", 0, &num_bytes_written, NULL)) {
                                    if (thread_data.cancel_io) break;

                                    stream_eof = true;
                                }
                            }
                        }

                        if (!num_chars_read && !stream_eof) {
                            // loop wait
                            Sleep(20);

                            if (thread_data.cancel_io) break;
                        }
                    }
                } break;
                }
            } break;

            case STDOUT_FILENO: // stdout
            {
                // Accomplish all server pipe connections before continue.
                //

                {
                    auto & connect_server_named_pipe_thread_local = g_connect_bound_server_named_pipe_tofrom_conin_thread_locals[stream_type];

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
                            if (win_error && win_error != ERROR_NO_DATA && win_error != ERROR_BROKEN_PIPE && win_error != ERROR_PIPE_NOT_CONNECTED) {
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
                                [&]() { __try {
                                    if (_is_valid_handle(g_tee_file_stdout_mutex)) {
                                        WaitForSingleObject(g_tee_file_stdout_mutex, INFINITE);
                                    }

                                    SetFilePointer(g_tee_file_stdout_handle, 0, NULL, FILE_END);

                                    WriteFile(g_tee_file_stdout_handle, stdout_byte_buf.data(), num_bytes_read, &num_bytes_written, NULL);
                                    if (thread_data.cancel_io) return;

                                    if (g_flags.tee_stdout_file_flush || g_flags.tee_stdout_flush || g_flags.tee_output_flush || g_flags.tee_inout_flush) {
                                        FlushFileBuffers(g_tee_file_stdout_handle);
                                        if (thread_data.cancel_io) return;
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
                                [&]() { __try {
                                    if (_is_valid_handle(g_reopen_stdout_mutex)) {
                                        WaitForSingleObject(g_reopen_stdout_mutex, INFINITE);
                                    }

                                    if (_is_valid_handle(g_reopen_stdout_handle)) {
                                        SetFilePointer(g_reopen_stdout_handle, 0, NULL, FILE_END);
                                    }

                                    SetLastError(0); // just in case
                                    if (WriteFile(g_stdout_handle, stdout_byte_buf.data(), num_bytes_read, &num_bytes_written, NULL)) {
                                        if (g_flags.stdout_flush || g_flags.output_flush || g_flags.inout_flush) {
                                            FlushFileBuffers(g_stdout_handle);
                                        }

                                        if (thread_data.cancel_io) return;
                                    }
                                    else {
                                        if (thread_data.cancel_io) return;

                                        win_error = GetLastError();
                                        if (win_error && win_error != ERROR_NO_DATA && win_error != ERROR_BROKEN_PIPE && win_error != ERROR_PIPE_NOT_CONNECTED) {
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


            case STDERR_FILENO: // stderr
            {
                // Accomplish all server pipe connections before continue.
                //

                {
                    auto & connect_server_named_pipe_thread_local = g_connect_bound_server_named_pipe_tofrom_conin_thread_locals[stream_type];

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
                        if (!ReadFile(g_stderr_pipe_read_handle, stderr_byte_buf.data(), g_options.tee_stderr_read_buf_size, &num_bytes_read, NULL)) {
                            if (thread_data.cancel_io) break;

                            win_error = GetLastError();
                            if (win_error && win_error != ERROR_NO_DATA && win_error != ERROR_BROKEN_PIPE && win_error != ERROR_PIPE_NOT_CONNECTED) {
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
                                [&]() { __try {
                                    if (_is_valid_handle(g_tee_file_stderr_mutex)) {
                                        WaitForSingleObject(g_tee_file_stderr_mutex, INFINITE);
                                    }

                                    SetFilePointer(g_tee_file_stderr_handle, 0, NULL, FILE_END);

                                    WriteFile(g_tee_file_stderr_handle, stderr_byte_buf.data(), num_bytes_read, &num_bytes_written, NULL);
                                    if (thread_data.cancel_io) return;

                                    if (g_flags.tee_stderr_file_flush || g_flags.tee_stderr_flush || g_flags.tee_output_flush || g_flags.tee_inout_flush) {
                                        FlushFileBuffers(g_tee_file_stderr_handle);
                                        if (thread_data.cancel_io) return;
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
                                [&]() { __try {
                                    if (_is_valid_handle(g_reopen_stderr_mutex)) {
                                        WaitForSingleObject(g_reopen_stderr_mutex, INFINITE);
                                    }

                                    if (_is_valid_handle(g_reopen_stderr_handle)) {
                                        SetFilePointer(g_reopen_stderr_handle, 0, NULL, FILE_END);
                                    }

                                    SetLastError(0); // just in case
                                    if (WriteFile(g_stderr_handle, stderr_byte_buf.data(), num_bytes_read, &num_bytes_written, NULL)) {
                                        if (g_flags.stderr_flush || g_flags.output_flush || g_flags.inout_flush) {
                                            FlushFileBuffers(g_stderr_handle);
                                        }

                                        if (thread_data.cancel_io) return;
                                    }
                                    else {
                                        if (thread_data.cancel_io) return;

                                        win_error = GetLastError();
                                        if (win_error && win_error != ERROR_NO_DATA && win_error != ERROR_BROKEN_PIPE && win_error != ERROR_PIPE_NOT_CONNECTED) {
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
        // cleanup

        switch (stream_type) {
        case STDIN_FILENO: // stdin
        {
            if (_is_valid_handle(g_stdin_pipe_write_handle)) {
                if (g_stdin_handle_type == FILE_TYPE_CHAR) {
                    // interrupt write handle watch thread
                    WaitForWorkerThreads(g_write_handle_watch_thread_locals, true);
                }

                // explicitly disconnect/close all pipe outbound handles here to trigger the child process reaction

                // CAUTION:
                //  Always flush before disconnection/close, otherwise the last bytes would be lost!
                //
                FlushFileBuffers(g_stdin_pipe_write_handle);

                if (!g_options.create_outbound_server_pipe_from_stdin.empty()) {
                    DisconnectNamedPipe(g_stdin_pipe_write_handle);
                }
                _close_handle(g_stdin_pipe_write_handle);
            }
        } break;

        // CAUTION:
        //  DO NOT disconnect in output-to-input direction to avoid data early lost because of buffering between input and output.
        //

        //case STDOUT_FILENO: // stdout
        //{
        //    if (_is_valid_handle(g_stdout_pipe_read_handle)) {
        //        // explicitly disconnect/close all pipe inbound handles here to trigger the child process reaction

        //        if (!g_options.create_inbound_server_pipe_to_stdout.empty()) {
        //            DisconnectNamedPipe(g_stdout_pipe_read_handle);
        //        }
        //        _close_handle(g_stdout_pipe_read_handle);
        //    }
        //} break;


        //case STDERR_FILENO: // stderr
        //{
        //    if (_is_valid_handle(g_stderr_pipe_read_handle)) {
        //        // explicitly disconnect/close all pipe inbound handles here to trigger the child process reaction

        //        if (!g_options.create_inbound_server_pipe_to_stderr.empty()) {
        //            DisconnectNamedPipe(g_stderr_pipe_read_handle);
        //        }
        //        _close_handle(g_stderr_pipe_read_handle);
        //    }
        //} break;
        }
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
    DWORD num_bytes_written = 0;
    //DWORD num_events_read = 0;
    //DWORD num_events_written = 0;
    DWORD win_error = 0;

    std::vector<std::uint8_t> stdin_byte_buf;

    bool break_ = false;

    // NOTE:
    //  lambda to bypass msvc error: `error C2712: Cannot use __try in functions that require object unwinding`
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
                        if (win_error && win_error != ERROR_NO_DATA && win_error != ERROR_BROKEN_PIPE && win_error != ERROR_PIPE_NOT_CONNECTED) {
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
                            [&]() { __try {
                                if (_is_valid_handle(g_tee_file_stdin_mutex)) {
                                    WaitForSingleObject(g_tee_file_stdin_mutex, INFINITE);
                                }

                                SetFilePointer(g_tee_file_stdin_handle, 0, NULL, FILE_END);

                                WriteFile(g_tee_file_stdin_handle, stdin_byte_buf.data(), num_bytes_read, &num_bytes_written, NULL);
                                if (thread_data.cancel_io) return;

                                if (g_flags.tee_stdin_file_flush || g_flags.tee_stdin_flush || g_flags.tee_inout_flush) {
                                    FlushFileBuffers(g_tee_file_stdin_handle);
                                    if (thread_data.cancel_io) return;
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
                            [&]() { __try {
                                if (_is_valid_handle(g_tee_file_stdout_mutex)) {
                                    WaitForSingleObject(g_tee_file_stdout_mutex, INFINITE);
                                }

                                SetFilePointer(g_tee_file_stdout_handle, 0, NULL, FILE_END);

                                WriteFile(g_tee_file_stdout_handle, stdin_byte_buf.data(), num_bytes_read, &num_bytes_written, NULL);
                                if (thread_data.cancel_io) return;

                                if (g_flags.tee_stdout_file_flush || g_flags.tee_stdout_flush || g_flags.tee_inout_flush || g_flags.tee_output_flush) {
                                    FlushFileBuffers(g_tee_file_stdout_handle);
                                    if (thread_data.cancel_io) return;
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
                            if (WriteFile(g_stdout_handle, stdin_byte_buf.data(), num_bytes_read, &num_bytes_written, NULL)) {
                                if (g_flags.stdin_output_flush || g_flags.stdout_flush || g_flags.inout_flush || g_flags.output_flush) {
                                    FlushFileBuffers(g_stdout_handle);
                                }

                                if (thread_data.cancel_io) break;
                            }
                            else {
                                if (thread_data.cancel_io) break;

                                win_error = GetLastError();
                                if (win_error && win_error != ERROR_NO_DATA && win_error != ERROR_BROKEN_PIPE && win_error != ERROR_PIPE_NOT_CONNECTED) {
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
            } break;

            case FILE_TYPE_PIPE:
            {
                stdin_byte_buf.resize(g_options.tee_stdin_read_buf_size);

                while (!stream_eof) {
                    num_bytes_read = num_bytes_avail = 0;

                    // CAUTION:
                    //  We is required `PeekNamedPipe` here before the `ReadFile` because of potential break in the output handle, when
                    //  the input handle has no data to read but the output handle is already closed or broken.
                    //  In that case we must call to `WriteFile` even if has no data on the input.
                    //

                    SetLastError(0); // just in case
                    if (!PeekNamedPipe(g_stdin_handle, NULL, 0, NULL, &num_bytes_avail, NULL)) {
                        if (thread_data.cancel_io) break;

                        win_error = GetLastError();
                        if (win_error && win_error != ERROR_NO_DATA && win_error != ERROR_BROKEN_PIPE && win_error != ERROR_PIPE_NOT_CONNECTED) {
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
                            if (win_error && win_error != ERROR_NO_DATA && win_error != ERROR_BROKEN_PIPE && win_error != ERROR_PIPE_NOT_CONNECTED) {
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
                            [&]() { __try {
                                if (_is_valid_handle(g_tee_file_stdin_mutex)) {
                                    WaitForSingleObject(g_tee_file_stdin_mutex, INFINITE);
                                }

                                SetFilePointer(g_tee_file_stdin_handle, 0, NULL, FILE_END);

                                WriteFile(g_tee_file_stdin_handle, stdin_byte_buf.data(), num_bytes_read, &num_bytes_written, NULL);
                                if (thread_data.cancel_io) return;

                                if (g_flags.tee_stdin_file_flush || g_flags.tee_stdin_flush || g_flags.tee_inout_flush) {
                                    FlushFileBuffers(g_tee_file_stdin_handle);
                                    if (thread_data.cancel_io) return;
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
                            [&]() { __try {
                                if (_is_valid_handle(g_tee_file_stdout_mutex)) {
                                    WaitForSingleObject(g_tee_file_stdout_mutex, INFINITE);
                                }

                                SetFilePointer(g_tee_file_stdout_handle, 0, NULL, FILE_END);

                                WriteFile(g_tee_file_stdout_handle, stdin_byte_buf.data(), num_bytes_read, &num_bytes_written, NULL);
                                if (thread_data.cancel_io) return;

                                if (g_flags.tee_stdout_file_flush || g_flags.tee_stdout_flush || g_flags.tee_inout_flush || g_flags.tee_output_flush) {
                                    FlushFileBuffers(g_tee_file_stdout_handle);
                                    if (thread_data.cancel_io) return;
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
                            if (WriteFile(g_stdout_handle, stdin_byte_buf.data(), num_bytes_read, &num_bytes_written, NULL)) {
                                if (g_flags.stdin_output_flush || g_flags.stdout_flush || g_flags.inout_flush || g_flags.output_flush) {
                                    FlushFileBuffers(g_stdout_handle);
                                }

                                if (thread_data.cancel_io) break;
                            }
                            else {
                                if (thread_data.cancel_io) break;

                                win_error = GetLastError();
                                if (win_error && win_error != ERROR_NO_DATA && win_error != ERROR_BROKEN_PIPE && win_error != ERROR_PIPE_NOT_CONNECTED) {
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
                    else if (!stream_eof && !num_bytes_avail) {
                        SetLastError(0); // just in case
                        if (!WriteFile(g_stdout_handle, "", 0, &num_bytes_written, NULL)) {
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
            } break;
            }
        }();
    }
    __finally {
        // cleanup

        switch (g_stdin_handle_type) {
        case FILE_TYPE_DISK:
        case FILE_TYPE_PIPE:
        {
            // explicitly disconnect/close all stdout handles here to trigger the child process reaction

            // CAUTION:
            //  Always flush before disconnection/close, otherwise the last bytes would be lost!
            //
            FlushFileBuffers(g_stdout_handle);

            if (!g_options.reopen_stdout_as_server_pipe.empty()) {
                DisconnectNamedPipe(g_stdout_handle);
            }

            // CAUTION:
            //  Never close standard handle directly, use CRT call instead, otherwise the CRT would be in desync with the Win32!
            //
            //_close_handle(g_stdout_handle);

            // CAUTION:
            //  Never close standard handle through the _close, otherwise stream (FILE*) would be always in use (partially closed)!
            //
            //const int stdout_fileno = _fileno(stdout);
            //_close(stdout_fileno >= 0 ? stdout_fileno : STDOUT_FILENO);

            // CAUTION:
            //  We should not simply close the handle as long as it can be used later even on process exit, but to trigger a child
            //  process we must close it, so we reopen it instead.
            //

            // CAUTION:
            //  We should not close a character device handle, otherwise another process in process inheritance tree may lose the handle buffer to continue interact with it.
            //
            //  Another issues related to this:
            //
            //    `Windows 7 conhost.exe crash with CONOUT$ [win7_conout_crash]` : https://github.com/rprichard/win32-console-docs#windows-7-conhostexe-crash-with-conout-win7_conout_crash
            //
            //      There is a bug in Windows 7 involving CONOUT$ and CloseHandle that can easily crash conhost.exe and/or activate the wrong screen buffer.
            //      The bug is triggered when a process without a handle to the active screen buffer opens CONOUT$ and then closes it using CloseHandle.
            //      
            //      Here's what seems to be going on:
            //      
            //      Each process may have at most one "console object" referencing a particular buffer.A single console object can be shared between multiple processes,
            //      and whenever console handles are imported(CreateProcess and AttachConsole), the objects are reused.
            //      
            //      If a process opens CONOUT$, however, and does not already have a reference to the active screen buffer, then Windows creates a new console object.
            //      The bug in Windows 7 is this: if a process calls CloseHandle on the last handle for a console object, then the screen buffer is freed,
            //      even if there are other handles / objects still referencing it.At that point, the console might display the wrong screen buffer,
            //      but using the other handles to the buffer can return garbage and / or crash conhost.exe. Closing a dangling handle is especially likely to trigger a crash.
            //      
            //      The bug affects Windows 7 SP1, but does not affect Windows Server 2008 R2 SP1, the server version of the OS.
            //

            if (g_stdout_handle_type != FILE_TYPE_CHAR) {
                _StdHandlesState std_handles_state;

                std_handles_state.save_stdout_state(g_stdout_handle);

                _detach_stdout();
                _attach_stdout_from_console(IF_CONSOLE_APP(false, true), !!std_handles_state.is_stdout_inheritable);

                // reread owned by CRT handles
                g_stdout_handle = GetStdHandle(STD_OUTPUT_HANDLE);
                g_stdout_handle_type = _get_file_type(g_stdout_handle);

                std_handles_state.restore_stdout_state(g_stdout_handle, true);
            }
        } break;
        }
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
    //  lambda to bypass msvc error: `error C2712: Cannot use __try in functions that require object unwinding`
    //
    return [&]() -> DWORD { __try {
        return [&]() -> DWORD {
            switch (co_stream_type) {
            case STDIN_FILENO: // stdin
            {
                switch (handle_type) {
                case 0: {
                    SetLastError(0); // just in case
                    if (!ConnectNamedPipe(g_reopen_stdin_handle, &connection_await_overlapped)) {
                        win_error = GetLastError();
                        if (win_error == ERROR_PIPE_CONNECTED) {
                            break;
                        }
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
                    const auto start_time_ms = g_options.win_ver.major >= 6 ? GetTickCount64() : GetTickCount();

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

                        const auto end_time_ms = g_options.win_ver.major >= 6 ? GetTickCount64() : GetTickCount();

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
                        if (win_error == ERROR_PIPE_CONNECTED) {
                            break;
                        }
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
                    const auto start_time_ms = g_options.win_ver.major >= 6 ? GetTickCount64() : GetTickCount();

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

                        const auto end_time_ms = g_options.win_ver.major >= 6 ? GetTickCount64() : GetTickCount();

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

            case STDOUT_FILENO: // stdout
            {
                switch (handle_type) {
                case 0: {
                    SetLastError(0); // just in case
                    if (!ConnectNamedPipe(g_reopen_stdout_handle, &connection_await_overlapped)) {
                        win_error = GetLastError();
                        if (win_error == ERROR_PIPE_CONNECTED) {
                            break;
                        }
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
                    const auto start_time_ms = g_options.win_ver.major >= 6 ? GetTickCount64() : GetTickCount();

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

                        const auto end_time_ms = g_options.win_ver.major >= 6 ? GetTickCount64() : GetTickCount();

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
                        if (win_error == ERROR_PIPE_CONNECTED) {
                            break;
                        }
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
                    const auto start_time_ms = g_options.win_ver.major >= 6 ? GetTickCount64() : GetTickCount();

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

                        const auto end_time_ms = g_options.win_ver.major >= 6 ? GetTickCount64() : GetTickCount();

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

            case STDERR_FILENO: // stderr
            {
                switch (handle_type) {
                case 0: {
                    SetLastError(0); // just in case
                    if (!ConnectNamedPipe(g_reopen_stderr_handle, &connection_await_overlapped)) {
                        win_error = GetLastError();
                        if (win_error == ERROR_PIPE_CONNECTED) {
                            break;
                        }
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
                    const auto start_time_ms = g_options.win_ver.major >= 6 ? GetTickCount64() : GetTickCount();

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

                        const auto end_time_ms = g_options.win_ver.major >= 6 ? GetTickCount64() : GetTickCount();

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
                        if (win_error == ERROR_PIPE_CONNECTED) {
                            break;
                        }
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
                    const auto start_time_ms = g_options.win_ver.major >= 6 ? GetTickCount64() : GetTickCount();

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

                        const auto end_time_ms = g_options.win_ver.major >= 6 ? GetTickCount64() : GetTickCount();

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
        // cleanup

        if (thread_data.is_error) {
            // NOTE:
            //  Always disconnect a server named pipe end together with the handle close even if connection is not accomplished or SEH exception is thrown,
            //  otherwise a client may be blocked on the `PeekNamedPipe` call in an infinite loop.
            //

            // CAUTION:
            //  We should not close a character device handle, otherwise another process in process inheritance tree may lose the handle buffer to continue interact with it.
            //
            //  Another issues related to this:
            //
            //    `Windows 7 conhost.exe crash with CONOUT$ [win7_conout_crash]` : https://github.com/rprichard/win32-console-docs#windows-7-conhostexe-crash-with-conout-win7_conout_crash
            //
            //      There is a bug in Windows 7 involving CONOUT$ and CloseHandle that can easily crash conhost.exe and/or activate the wrong screen buffer.
            //      The bug is triggered when a process without a handle to the active screen buffer opens CONOUT$ and then closes it using CloseHandle.
            //      
            //      Here's what seems to be going on:
            //      
            //      Each process may have at most one "console object" referencing a particular buffer.A single console object can be shared between multiple processes,
            //      and whenever console handles are imported(CreateProcess and AttachConsole), the objects are reused.
            //      
            //      If a process opens CONOUT$, however, and does not already have a reference to the active screen buffer, then Windows creates a new console object.
            //      The bug in Windows 7 is this: if a process calls CloseHandle on the last handle for a console object, then the screen buffer is freed,
            //      even if there are other handles / objects still referencing it.At that point, the console might display the wrong screen buffer,
            //      but using the other handles to the buffer can return garbage and / or crash conhost.exe. Closing a dangling handle is especially likely to trigger a crash.
            //      
            //      The bug affects Windows 7 SP1, but does not affect Windows Server 2008 R2 SP1, the server version of the OS.
            //

            switch (co_stream_type) {
            case STDIN_FILENO: // stdin
            {
                switch (handle_type) {
                case 0: {
                    if (!g_options.reopen_stdin_as_server_pipe.empty()) {
                        DisconnectNamedPipe(g_reopen_stdin_handle);
                    }
                    _close_handle(g_reopen_stdin_handle);
                } break;

                case 1: {
                    if (!g_options.tee_stdin_to_server_pipe.empty()) {
                        DisconnectNamedPipe(g_tee_named_pipe_stdin_handle);
                    }
                    _close_handle(g_reopen_stdin_handle);
                } break;
                }
            } break;

            case STDOUT_FILENO: // stdout
            {
                switch (handle_type) {
                case 0: {
                    if (!g_options.reopen_stdout_as_server_pipe.empty()) {
                        DisconnectNamedPipe(g_reopen_stdout_handle);
                    }
                    _close_handle(g_reopen_stdout_handle);
                } break;

                case 1: {
                    if (!g_options.tee_stdout_to_server_pipe.empty()) {
                        DisconnectNamedPipe(g_tee_named_pipe_stdout_handle);
                    }
                    _close_handle(g_reopen_stdout_handle);
                } break;
                }
            } break;

            case STDERR_FILENO: // stderr
            {
                switch (handle_type) {
                case 0: {
                    if (!g_options.reopen_stderr_as_server_pipe.empty()) {
                        DisconnectNamedPipe(g_reopen_stderr_handle);
                    }
                    _close_handle(g_reopen_stderr_handle);
                } break;

                case 1: {
                    if (!g_options.tee_stderr_to_server_pipe.empty()) {
                        DisconnectNamedPipe(g_tee_named_pipe_stderr_handle);
                    }
                    _close_handle(g_reopen_stderr_handle);
                } break;
                }
            } break;
            }
        }
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

    DWORD win_error = 0;

    // NOTE:
    //  lambda to bypass msvc error: `error C2712: Cannot use __try in functions that require object unwinding`
    //
    return [&]() -> DWORD { __try {
        return [&]() -> DWORD {
            switch (co_stream_type) {
            case STDIN_FILENO: // stdin
            {
                switch (handle_type) {
                case 0: {
                    const auto pipe_name_str = std::tstring(_T("\\\\.\\pipe\\")) + g_options.reopen_stdin_as_client_pipe;

                    // client named pipe end wait loop
                    const auto start_time_ms = g_options.win_ver.major >= 6 ? GetTickCount64() : GetTickCount();

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
                                GENERIC_READ, FILE_SHARE_READ, NULL,
                                OPEN_EXISTING,
                                FILE_ATTRIBUTE_NORMAL, NULL))) {

                            bool reset_handle_inherit = true;
                            DWORD handle_flags = 0;

                            if (GetHandleInformation(g_reopen_stdin_handle, &handle_flags) && !(handle_flags & HANDLE_FLAG_INHERIT)) {
                                reset_handle_inherit = false;
                            }

                            if (reset_handle_inherit) {
                                SetLastError(0); // just in case
                                if (!SetHandleInformation(g_reopen_stdin_handle, HANDLE_FLAG_INHERIT, FALSE)) {
                                    thread_data.win_error = GetLastError();
                                    thread_data.ret = err_win32_error;
                                    if (!g_flags.no_print_gen_error_string) {
                                        thread_data.msg =
                                            _format_stderr_message(_T("could not disable handle inheritance of reopened stdin as client named pipe end: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                                                win_error, win_error, g_options.reopen_stdin_as_client_pipe.c_str());
                                    }
                                    if (g_flags.print_win_error_string && win_error) {
                                        thread_data.msg +=
                                            _format_win_error_message(win_error, g_options.win_error_langid);
                                    }
                                    return 1;
                                }
                            }

                            break;
                        }

                        win_error = GetLastError();
                        if (win_error != ERROR_PIPE_BUSY) {
                            thread_data.ret = err_named_pipe_connect_error;
                            thread_data.win_error = win_error;
                            if (!g_flags.no_print_gen_error_string) {
                                thread_data.msg =
                                    _format_stderr_message(_T("could not client connect of reopened stdin as client named pipe end: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                                        win_error, win_error, g_options.reopen_stdin_as_client_pipe.c_str());
                            }
                            if (g_flags.print_win_error_string && win_error) {
                                thread_data.msg +=
                                    _format_win_error_message(win_error, g_options.win_error_langid);
                            }
                            return 1;
                        }

                        {
                            const auto end_time_ms = g_options.win_ver.major >= 6 ? GetTickCount64() : GetTickCount();

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
                            const auto end_time_ms = g_options.win_ver.major >= 6 ? GetTickCount64() : GetTickCount();

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
                    const auto start_time_ms = g_options.win_ver.major >= 6 ? GetTickCount64() : GetTickCount();

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
                                OPEN_ALWAYS,
                                FILE_ATTRIBUTE_NORMAL, NULL))) {

                            bool reset_handle_inherit = true;
                            DWORD handle_flags = 0;

                            if (GetHandleInformation(g_tee_named_pipe_stdin_handle, &handle_flags) && !(handle_flags & HANDLE_FLAG_INHERIT)) {
                                reset_handle_inherit = false;
                            }

                            if (reset_handle_inherit) {
                                SetLastError(0); // just in case
                                if (!SetHandleInformation(g_tee_named_pipe_stdin_handle, HANDLE_FLAG_INHERIT, FALSE)) {
                                    thread_data.win_error = GetLastError();
                                    thread_data.ret = err_win32_error;
                                    if (!g_flags.no_print_gen_error_string) {
                                        thread_data.msg =
                                            _format_stderr_message(_T("could not disable handle inheritance of stdin tee as client named pipe end: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                                                win_error, win_error, g_options.tee_stdin_to_client_pipe.c_str());
                                    }
                                    if (g_flags.print_win_error_string && win_error) {
                                        thread_data.msg +=
                                            _format_win_error_message(win_error, g_options.win_error_langid);
                                    }
                                    return 1;
                                }
                            }

                            break;
                        }

                        win_error = GetLastError();
                        if (win_error != ERROR_PIPE_BUSY) {
                            thread_data.ret = err_named_pipe_connect_error;
                            thread_data.win_error = win_error;
                            if (!g_flags.no_print_gen_error_string) {
                                thread_data.msg =
                                    _format_stderr_message(_T("could not client connect of stdin tee as client named pipe end: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                                        win_error, win_error, g_options.tee_stdin_to_client_pipe.c_str());
                            }
                            if (g_flags.print_win_error_string && win_error) {
                                thread_data.msg +=
                                    _format_win_error_message(win_error, g_options.win_error_langid);
                            }
                            return 1;
                        }

                        {
                            const auto end_time_ms = g_options.win_ver.major >= 6 ? GetTickCount64() : GetTickCount();

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
                            const auto end_time_ms = g_options.win_ver.major >= 6 ? GetTickCount64() : GetTickCount();

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

            case STDOUT_FILENO: // stdout
            {
                switch (handle_type) {
                case 0: {
                    const auto pipe_name_str = std::tstring(_T("\\\\.\\pipe\\")) + g_options.reopen_stdout_as_client_pipe;

                    // client named pipe end wait loop
                    const auto start_time_ms = g_options.win_ver.major >= 6 ? GetTickCount64() : GetTickCount();

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
                                GENERIC_WRITE, FILE_SHARE_WRITE, NULL,
                                OPEN_ALWAYS,
                                FILE_ATTRIBUTE_NORMAL, NULL))) {

                            bool reset_handle_inherit = true;
                            DWORD handle_flags = 0;

                            if (GetHandleInformation(g_reopen_stdout_handle, &handle_flags) && !(handle_flags & HANDLE_FLAG_INHERIT)) {
                                reset_handle_inherit = false;
                            }

                            if (reset_handle_inherit) {
                                SetLastError(0); // just in case
                                if (!SetHandleInformation(g_reopen_stdout_handle, HANDLE_FLAG_INHERIT, FALSE)) {
                                    thread_data.win_error = GetLastError();
                                    thread_data.ret = err_win32_error;
                                    if (!g_flags.no_print_gen_error_string) {
                                        thread_data.msg =
                                            _format_stderr_message(_T("could not disable handle inheritance of reopened stdout as client named pipe end: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                                                win_error, win_error, g_options.reopen_stdout_as_client_pipe.c_str());
                                    }
                                    if (g_flags.print_win_error_string && win_error) {
                                        thread_data.msg +=
                                            _format_win_error_message(win_error, g_options.win_error_langid);
                                    }
                                    return 1;
                                }
                            }

                            break;
                        }

                        win_error = GetLastError();
                        if (win_error != ERROR_PIPE_BUSY) {
                            thread_data.ret = err_named_pipe_connect_error;
                            thread_data.win_error = win_error;
                            if (!g_flags.no_print_gen_error_string) {
                                thread_data.msg =
                                    _format_stderr_message(_T("could not client connect of reopened stdout as client named pipe end: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                                        win_error, win_error, g_options.reopen_stdout_as_client_pipe.c_str());
                            }
                            if (g_flags.print_win_error_string && win_error) {
                                thread_data.msg +=
                                    _format_win_error_message(win_error, g_options.win_error_langid);
                            }
                            return 1;
                        }

                        {
                            const auto end_time_ms = g_options.win_ver.major >= 6 ? GetTickCount64() : GetTickCount();

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
                            const auto end_time_ms = g_options.win_ver.major >= 6 ? GetTickCount64() : GetTickCount();

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
                    const auto start_time_ms = g_options.win_ver.major >= 6 ? GetTickCount64() : GetTickCount();

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
                                OPEN_ALWAYS,
                                FILE_ATTRIBUTE_NORMAL, NULL))) {

                            bool reset_handle_inherit = true;
                            DWORD handle_flags = 0;

                            if (GetHandleInformation(g_tee_named_pipe_stdout_handle, &handle_flags) && !(handle_flags & HANDLE_FLAG_INHERIT)) {
                                reset_handle_inherit = false;
                            }

                            if (reset_handle_inherit) {
                                SetLastError(0); // just in case
                                if (!SetHandleInformation(g_tee_named_pipe_stdout_handle, HANDLE_FLAG_INHERIT, FALSE)) {
                                    thread_data.win_error = GetLastError();
                                    thread_data.ret = err_win32_error;
                                    if (!g_flags.no_print_gen_error_string) {
                                        thread_data.msg =
                                            _format_stderr_message(_T("could not disable handle inheritance of stdout tee as client named pipe end: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                                                win_error, win_error, g_options.tee_stdout_to_client_pipe.c_str());
                                    }
                                    if (g_flags.print_win_error_string && win_error) {
                                        thread_data.msg +=
                                            _format_win_error_message(win_error, g_options.win_error_langid);
                                    }
                                    return 1;
                                }
                            }

                            break;
                        }

                        win_error = GetLastError();
                        if (win_error != ERROR_PIPE_BUSY) {
                            thread_data.ret = err_named_pipe_connect_error;
                            thread_data.win_error = win_error;
                            if (!g_flags.no_print_gen_error_string) {
                                thread_data.msg =
                                    _format_stderr_message(_T("could not client connect of stdout tee as client named pipe end: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                                        win_error, win_error, g_options.tee_stdout_to_client_pipe.c_str());
                            }
                            if (g_flags.print_win_error_string && win_error) {
                                thread_data.msg +=
                                    _format_win_error_message(win_error, g_options.win_error_langid);
                            }
                            return 1;
                        }

                        {
                            const auto end_time_ms = g_options.win_ver.major >= 6 ? GetTickCount64() : GetTickCount();

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
                            const auto end_time_ms = g_options.win_ver.major >= 6 ? GetTickCount64() : GetTickCount();

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

            case STDERR_FILENO: // stderr
            {
                switch (handle_type) {
                case 0: {
                    const auto pipe_name_str = std::tstring(_T("\\\\.\\pipe\\")) + g_options.reopen_stderr_as_client_pipe;

                    // client named pipe end wait loop
                    const auto start_time_ms = g_options.win_ver.major >= 6 ? GetTickCount64() : GetTickCount();

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
                                GENERIC_WRITE, FILE_SHARE_WRITE, NULL,
                                OPEN_ALWAYS,
                                FILE_ATTRIBUTE_NORMAL, NULL))) {

                            bool reset_handle_inherit = true;
                            DWORD handle_flags = 0;

                            if (GetHandleInformation(g_reopen_stderr_handle, &handle_flags) && !(handle_flags & HANDLE_FLAG_INHERIT)) {
                                reset_handle_inherit = false;
                            }

                            if (reset_handle_inherit) {
                                SetLastError(0); // just in case
                                if (!SetHandleInformation(g_reopen_stderr_handle, HANDLE_FLAG_INHERIT, FALSE)) {
                                    thread_data.win_error = GetLastError();
                                    thread_data.ret = err_win32_error;
                                    if (!g_flags.no_print_gen_error_string) {
                                        thread_data.msg =
                                            _format_stderr_message(_T("could not disable handle inheritance of reopened stderr as client named pipe end: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                                                win_error, win_error, g_options.reopen_stderr_as_client_pipe.c_str());
                                    }
                                    if (g_flags.print_win_error_string && win_error) {
                                        thread_data.msg +=
                                            _format_win_error_message(win_error, g_options.win_error_langid);
                                    }
                                    return 1;
                                }
                            }

                            break;
                        }

                        win_error = GetLastError();
                        if (win_error != ERROR_PIPE_BUSY) {
                            thread_data.ret = err_named_pipe_connect_error;
                            thread_data.win_error = win_error;
                            if (!g_flags.no_print_gen_error_string) {
                                thread_data.msg =
                                    _format_stderr_message(_T("could not client connect of reopened stderr as client named pipe end: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                                        win_error, win_error, g_options.reopen_stderr_as_client_pipe.c_str());
                            }
                            if (g_flags.print_win_error_string && win_error) {
                                thread_data.msg +=
                                    _format_win_error_message(win_error, g_options.win_error_langid);
                            }
                            return 1;
                        }

                        {
                            const auto end_time_ms = g_options.win_ver.major >= 6 ? GetTickCount64() : GetTickCount();

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
                            const auto end_time_ms = g_options.win_ver.major >= 6 ? GetTickCount64() : GetTickCount();

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
                    const auto start_time_ms = g_options.win_ver.major >= 6 ? GetTickCount64() : GetTickCount();

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
                                OPEN_ALWAYS,
                                FILE_ATTRIBUTE_NORMAL, NULL))) {

                            bool reset_handle_inherit = true;
                            DWORD handle_flags = 0;

                            if (GetHandleInformation(g_tee_named_pipe_stderr_handle, &handle_flags) && !(handle_flags & HANDLE_FLAG_INHERIT)) {
                                reset_handle_inherit = false;
                            }

                            if (reset_handle_inherit) {
                                SetLastError(0); // just in case
                                if (!SetHandleInformation(g_tee_named_pipe_stderr_handle, HANDLE_FLAG_INHERIT, FALSE)) {
                                    thread_data.win_error = GetLastError();
                                    thread_data.ret = err_win32_error;
                                    if (!g_flags.no_print_gen_error_string) {
                                        thread_data.msg =
                                            _format_stderr_message(_T("could not disable handle inheritance of stderr tee as client named pipe end: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                                                win_error, win_error, g_options.tee_stderr_to_client_pipe.c_str());
                                    }
                                    if (g_flags.print_win_error_string && win_error) {
                                        thread_data.msg +=
                                            _format_win_error_message(win_error, g_options.win_error_langid);
                                    }
                                    return 1;
                                }
                            }

                            break;
                        }

                        win_error = GetLastError();
                        if (win_error != ERROR_PIPE_BUSY) {
                            thread_data.ret = err_named_pipe_connect_error;
                            thread_data.win_error = win_error;
                            if (!g_flags.no_print_gen_error_string) {
                                thread_data.msg =
                                    _format_stderr_message(_T("could not client connect of stderr tee as client named pipe end: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                                        win_error, win_error, g_options.tee_stderr_to_client_pipe.c_str());
                            }
                            if (g_flags.print_win_error_string && win_error) {
                                thread_data.msg +=
                                    _format_win_error_message(win_error, g_options.win_error_langid);
                            }
                            return 1;
                        }

                        {
                            const auto end_time_ms = g_options.win_ver.major >= 6 ? GetTickCount64() : GetTickCount();

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
                            const auto end_time_ms = g_options.win_ver.major >= 6 ? GetTickCount64() : GetTickCount();

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

bool ReopenStdin(int & ret, DWORD & win_error, UINT cp_in)
{
    ret = err_none;
    win_error = 0;

    const bool is_os_windows_7 = g_options.win_ver.major == 6 && g_options.win_ver.minor == 1;

    if (!g_options.reopen_stdin_as_file.empty()) {
        SetLastError(0); // just in case
        if (!_is_valid_handle(g_reopen_stdin_handle =
                CreateFile(g_options.reopen_stdin_as_file.c_str(),
                    GENERIC_READ, FILE_SHARE_READ, NULL,
                    OPEN_EXISTING,
                    FILE_ATTRIBUTE_NORMAL, NULL))) {
            if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                win_error = GetLastError();
            }
            if (!g_flags.ret_win_error) {
                ret = err_win32_error;
            }
            else {
                ret = win_error;
            }
            if (!g_flags.no_print_gen_error_string) {
                _print_stderr_message(_T("could not reopen stdin as file to read: win_error=0x%08X (%d) file=\"%s\"\n"),
                    win_error, win_error, g_options.reopen_stdin_as_file.c_str());
            }
            if (g_flags.print_win_error_string && win_error) {
                _print_win_error_message(win_error, g_options.win_error_langid);
            }
            return false;
        }

        bool reset_handle_inherit = true;
        DWORD handle_flags = 0;

        // character device must always stay inheritable if not explicitly declared as not inheritable
        const DWORD reopen_stdin_handle_type = _get_file_type(g_reopen_stdin_handle);
        const bool reset_handle_to_inherit = !g_no_stdin_inherit && reopen_stdin_handle_type == FILE_TYPE_CHAR;

        if (reopen_stdin_handle_type != FILE_TYPE_CHAR || !is_os_windows_7) { // specific for Windows 7 workaround
            if (GetHandleInformation(g_reopen_stdin_handle, &handle_flags) && reset_handle_to_inherit ? (handle_flags & HANDLE_FLAG_INHERIT) : !(handle_flags & HANDLE_FLAG_INHERIT)) {
                reset_handle_inherit = false;
            }

            if (reset_handle_inherit) {
                SetLastError(0); // just in case
                if (!SetHandleInformation(g_reopen_stdin_handle, HANDLE_FLAG_INHERIT, reset_handle_to_inherit ? TRUE : FALSE)) {
                    if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                        win_error = GetLastError();
                    }
                    if (!g_flags.ret_win_error) {
                        ret = err_win32_error;
                    }
                    else {
                        ret = win_error;
                    }
                    if (!g_flags.no_print_gen_error_string) {
                        _print_stderr_message(_T("could not %s handle inheritance of reopened stdin as file: win_error=0x%08X (%d) file=\"%s\"\n"),
                            reset_handle_to_inherit ? _T("enable") : _T("disable"), win_error, win_error, g_options.reopen_stdin_as_file.c_str());
                    }
                    if (g_flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, g_options.win_error_langid);
                    }
                    return false;
                }
            }
        }

        if (!_set_crt_std_handle(g_reopen_stdin_handle, -1, STDIN_FILENO, _O_BINARY, true, reset_handle_to_inherit)) {
            if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                win_error = GetLastError();
            }
            if (!g_flags.ret_win_error) {
                ret = err_win32_error;
            }
            else {
                ret = win_error;
            }
            if (!g_flags.no_print_gen_error_string) {
                _print_stderr_message(_T("could not duplicate reopened stdin as file before transfer handle ownership to CRT: win_error=0x%08X (%d) file=\"%s\"\n"),
                    win_error, win_error, g_options.reopen_stdin_as_file.c_str());
            }
            if (g_flags.print_win_error_string && win_error) {
                _print_win_error_message(win_error, g_options.win_error_langid);
            }
            return false;
        }

        g_is_stdin_reopened = true;
    }
    else if (!g_options.reopen_stdin_as_server_pipe.empty()) {
        SetLastError(0); // just in case
        if (!_is_valid_handle(g_reopen_stdin_handle =
            CreateNamedPipe((std::tstring(_T("\\\\.\\pipe\\")) + g_options.reopen_stdin_as_server_pipe).c_str(),
                PIPE_ACCESS_INBOUND | FILE_FLAG_FIRST_PIPE_INSTANCE | FILE_FLAG_OVERLAPPED,
                PIPE_TYPE_BYTE | PIPE_READMODE_BYTE | PIPE_WAIT | PIPE_REJECT_REMOTE_CLIENTS,
                1, g_options.reopen_stderr_as_server_pipe_out_buf_size, g_options.reopen_stderr_as_server_pipe_in_buf_size,
                0, NULL))) {
            if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                win_error = GetLastError();
            }
            if (!g_flags.ret_win_error) {
                ret = err_win32_error;
            }
            else {
                ret = win_error;
            }
            if (!g_flags.no_print_gen_error_string) {
                _print_stderr_message(_T("could not reopen stdin as server named pipe end to read: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                    win_error, win_error, g_options.reopen_stdin_as_server_pipe.c_str());
            }
            if (g_flags.print_win_error_string && win_error) {
                _print_win_error_message(win_error, g_options.win_error_langid);
            }
            return false;
        }

        bool reset_handle_inherit = true;
        DWORD handle_flags = 0;

        if (GetHandleInformation(g_reopen_stdin_handle, &handle_flags) && !(handle_flags & HANDLE_FLAG_INHERIT)) {
            reset_handle_inherit = false;
        }

        if (reset_handle_inherit) {
            SetLastError(0); // just in case
            if (!SetHandleInformation(g_reopen_stdin_handle, HANDLE_FLAG_INHERIT, FALSE)) {
                if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                    win_error = GetLastError();
                }
                if (!g_flags.ret_win_error) {
                    ret = err_win32_error;
                }
                else {
                    ret = win_error;
                }
                if (!g_flags.no_print_gen_error_string) {
                    _print_stderr_message(_T("could not disable handle inheritance of reopened stdin as server named pipe end: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                        win_error, win_error, g_options.reopen_stdin_as_server_pipe.c_str());
                }
                if (g_flags.print_win_error_string && win_error) {
                    _print_win_error_message(win_error, g_options.win_error_langid);
                }
                return false;
            }
        }

        if (!_set_crt_std_handle(g_reopen_stdin_handle, -1, STDIN_FILENO, _O_BINARY, true, false)) {
            if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                win_error = GetLastError();
            }
            if (!g_flags.ret_win_error) {
                ret = err_win32_error;
            }
            else {
                ret = win_error;
            }
            if (!g_flags.no_print_gen_error_string) {
                _print_stderr_message(_T("could not duplicate reopened stdin as server named pipe end before transfer handle ownership to CRT: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                    win_error, win_error, g_options.reopen_stdin_as_server_pipe.c_str());
            }
            if (g_flags.print_win_error_string && win_error) {
                _print_win_error_message(win_error, g_options.win_error_langid);
            }
            return false;
        }

        g_is_stdin_reopened = true;

        g_connect_server_named_pipe_thread_locals[0][0].server_named_pipe_handle_ptr = &g_reopen_stdin_handle;

        // start server pipe connection await thread
        g_connect_server_named_pipe_thread_locals[0][0].thread_handle = CreateThread(
            NULL, 0,
            ConnectServerNamedPipeThread<0, 0>, &g_connect_server_named_pipe_thread_locals[0][0].thread_data,
            0,
            &g_connect_server_named_pipe_thread_locals[0][0].thread_id
        );
    }
    else if (!g_options.reopen_stdin_as_client_pipe.empty()) {
        g_connect_server_named_pipe_thread_locals[0][0].client_named_pipe_handle_ptr = &g_reopen_stdin_handle;

        // start client pipe connection await thread
        g_connect_client_named_pipe_thread_locals[0][0].thread_handle = CreateThread(
            NULL, 0,
            ConnectClientNamedPipeThread<0, 0>, &g_connect_client_named_pipe_thread_locals[0][0].thread_data,
            0,
            &g_connect_client_named_pipe_thread_locals[0][0].thread_id
        );
    }

    return true;
}

bool ReopenStdout(int & ret, DWORD & win_error, UINT cp_in)
{
    ret = err_none;
    win_error = 0;

    const bool is_os_windows_7 = g_options.win_ver.major == 6 && g_options.win_ver.minor == 1;

    if (!g_options.reopen_stdout_as_file.empty()) {
        SetLastError(0); // just in case
        if (_is_valid_handle(g_reopen_stdout_handle =
                CreateFile(g_options.reopen_stdout_as_file.c_str(),
                    GENERIC_WRITE, FILE_SHARE_READ | FILE_SHARE_WRITE, NULL,
                    g_flags.reopen_stdout_file_truncate ? CREATE_ALWAYS : OPEN_ALWAYS,
                    FILE_ATTRIBUTE_NORMAL, NULL))) {

            bool reset_handle_inherit = true;
            DWORD handle_flags = 0;

            // character device must always stay inheritable if not explicitly declared as not inheritable
            const DWORD reopen_stdout_handle_type = _get_file_type(g_reopen_stdout_handle);
            const bool reset_handle_to_inherit = !g_no_stdout_inherit && reopen_stdout_handle_type == FILE_TYPE_CHAR;

            if (reopen_stdout_handle_type != FILE_TYPE_CHAR || !is_os_windows_7) { // specific for Windows 7 workaround
                if (GetHandleInformation(g_reopen_stdout_handle, &handle_flags) && reset_handle_to_inherit ? (handle_flags & HANDLE_FLAG_INHERIT) : !(handle_flags & HANDLE_FLAG_INHERIT)) {
                    reset_handle_inherit = false;
                }

                if (reset_handle_inherit) {
                    SetLastError(0); // just in case
                    if (!SetHandleInformation(g_reopen_stdout_handle, HANDLE_FLAG_INHERIT, reset_handle_to_inherit ? TRUE : FALSE)) {
                        if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                            win_error = GetLastError();
                        }
                        if (!g_flags.ret_win_error) {
                            ret = err_win32_error;
                        }
                        else {
                            ret = win_error;
                        }
                        if (!g_flags.no_print_gen_error_string) {
                            _print_stderr_message(_T("could not %s handle inheritance of reopened stdout as file: win_error=0x%08X (%d) file=\"%s\"\n"),
                                reset_handle_to_inherit ? _T("enable") : _T("disable"), win_error, win_error, g_options.reopen_stdout_as_file.c_str());
                        }
                        if (g_flags.print_win_error_string && win_error) {
                            _print_win_error_message(win_error, g_options.win_error_langid);
                        }
                        return false;
                    }
                }
            }

            if (!g_flags.reopen_stdout_file_truncate) {
                SetFilePointer(g_reopen_stdout_handle, 0, NULL, FILE_END);
            }

            g_reopen_stdout_fileid = _get_fileid_by_file_handle(g_reopen_stdout_handle, g_options.win_ver);

            // create associated write mutex
            if (g_flags.mutex_std_writes) {
                g_reopen_stdout_mutex = CreateMutex(NULL, FALSE,
                    (std::tstring(_T(STD_FILE_WRITE_MUTEX_NAME_PREFIX) _T("-")) + g_reopen_stdout_fileid.to_tstring()).c_str());
            }

            if (!_set_crt_std_handle(g_reopen_stdout_handle, -1, STDOUT_FILENO, _O_BINARY, true, reset_handle_to_inherit)) {
                if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                    win_error = GetLastError();
                }
                if (!g_flags.ret_win_error) {
                    ret = err_win32_error;
                }
                else {
                    ret = win_error;
                }
                if (!g_flags.no_print_gen_error_string) {
                    _print_stderr_message(_T("could not duplicate reopened stdout as file before transfer handle ownership to CRT: win_error=0x%08X (%d) file=\"%s\"\n"),
                        win_error, win_error, g_options.reopen_stdout_as_file.c_str());
                }
                if (g_flags.print_win_error_string && win_error) {
                    _print_win_error_message(win_error, g_options.win_error_langid);
                }
                return false;
            }

            g_is_stdout_reopened = true;
        }
        else {
            if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                win_error = GetLastError();
            }
            if (!g_flags.ret_win_error) {
                ret = err_win32_error;
            }
            else {
                ret = win_error;
            }
            if (!g_flags.no_print_gen_error_string) {
                _print_stderr_message(_T("could not reopen stdout as file to write: win_error=0x%08X (%d) file=\"%s\"\n"),
                    win_error, win_error, g_options.reopen_stdout_as_file.c_str());
            }
            if (g_flags.print_win_error_string && win_error) {
                _print_win_error_message(win_error, g_options.win_error_langid);
            }
            return false;
        }
    }
    else if (!g_options.reopen_stdout_as_server_pipe.empty()) {
        SetLastError(0); // just in case
        if (!_is_valid_handle(g_reopen_stdout_handle =
            CreateNamedPipe((std::tstring(_T("\\\\.\\pipe\\")) + g_options.reopen_stdout_as_server_pipe).c_str(),
                PIPE_ACCESS_OUTBOUND | FILE_FLAG_FIRST_PIPE_INSTANCE | FILE_FLAG_OVERLAPPED,
                PIPE_TYPE_BYTE | PIPE_READMODE_BYTE | PIPE_WAIT | PIPE_REJECT_REMOTE_CLIENTS,
                1, g_options.reopen_stderr_as_server_pipe_out_buf_size, g_options.reopen_stderr_as_server_pipe_in_buf_size,
                0, NULL))) {
            if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                win_error = GetLastError();
            }
            if (!g_flags.ret_win_error) {
                ret = err_win32_error;
            }
            else {
                ret = win_error;
            }
            if (!g_flags.no_print_gen_error_string) {
                _print_stderr_message(_T("could not reopen stdout as server named pipe end to write: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                    win_error, win_error, g_options.reopen_stdout_as_server_pipe.c_str());
            }
            if (g_flags.print_win_error_string && win_error) {
                _print_win_error_message(win_error, g_options.win_error_langid);
            }
            return false;
        }

        bool reset_handle_inherit = true;
        DWORD handle_flags = 0;

        if (GetHandleInformation(g_reopen_stdout_handle, &handle_flags) && !(handle_flags & HANDLE_FLAG_INHERIT)) {
            reset_handle_inherit = false;
        }

        if (reset_handle_inherit) {
            SetLastError(0); // just in case
            if (!SetHandleInformation(g_reopen_stdout_handle, HANDLE_FLAG_INHERIT, FALSE)) {
                if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                    win_error = GetLastError();
                }
                if (!g_flags.ret_win_error) {
                    ret = err_win32_error;
                }
                else {
                    ret = win_error;
                }
                if (!g_flags.no_print_gen_error_string) {
                    _print_stderr_message(_T("could not disable handle inheritance of reopened stdout as server named pipe end: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                        win_error, win_error, g_options.reopen_stdout_as_server_pipe.c_str());
                }
                if (g_flags.print_win_error_string && win_error) {
                    _print_win_error_message(win_error, g_options.win_error_langid);
                }
                return false;
            }
        }

        if (!_set_crt_std_handle(g_reopen_stdout_handle, -1, STDOUT_FILENO, _O_BINARY, true, false)) {
            if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                win_error = GetLastError();
            }
            if (!g_flags.ret_win_error) {
                ret = err_win32_error;
            }
            else {
                ret = win_error;
            }
            if (!g_flags.no_print_gen_error_string) {
                _print_stderr_message(_T("could not duplicate reopened stdout as server named pipe end before transfer handle ownership to CRT: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                    win_error, win_error, g_options.reopen_stdout_as_server_pipe.c_str());
            }
            if (g_flags.print_win_error_string && win_error) {
                _print_win_error_message(win_error, g_options.win_error_langid);
            }
            return false;
        }

        g_is_stdout_reopened = true;

        g_connect_server_named_pipe_thread_locals[0][1].server_named_pipe_handle_ptr = &g_reopen_stdout_handle;

        // start server pipe connection await thread
        g_connect_server_named_pipe_thread_locals[0][1].thread_handle = CreateThread(
            NULL, 0,
            ConnectServerNamedPipeThread<0, 1>, &g_connect_server_named_pipe_thread_locals[0][1].thread_data,
            0,
            &g_connect_server_named_pipe_thread_locals[0][1].thread_id
        );
    }
    else if (!g_options.reopen_stdout_as_client_pipe.empty()) {
        g_connect_server_named_pipe_thread_locals[0][1].client_named_pipe_handle_ptr = &g_reopen_stdout_handle;

        // start client pipe connection await thread
        g_connect_client_named_pipe_thread_locals[0][1].thread_handle = CreateThread(
            NULL, 0,
            ConnectClientNamedPipeThread<0, 1>, &g_connect_client_named_pipe_thread_locals[0][1].thread_data,
            0,
            &g_connect_client_named_pipe_thread_locals[0][1].thread_id
        );
    }

    return true;
}

bool ReopenStderr(int & ret, DWORD & win_error, UINT cp_in)
{
    ret = err_none;
    win_error = 0;

    const bool is_os_windows_7 = g_options.win_ver.major == 6 && g_options.win_ver.minor == 1;

    if (!g_options.reopen_stderr_as_file.empty()) {
        SetLastError(0); // just in case
        if (_is_valid_handle(g_reopen_stderr_handle =
            CreateFile(g_options.reopen_stderr_as_file.c_str(),
                GENERIC_WRITE, FILE_SHARE_READ | FILE_SHARE_WRITE, NULL,
                g_flags.reopen_stderr_file_truncate ? CREATE_ALWAYS : OPEN_ALWAYS,
                FILE_ATTRIBUTE_NORMAL, NULL))) {
            if (!g_flags.reopen_stderr_file_truncate) {
                SetFilePointer(g_reopen_stderr_handle, 0, NULL, FILE_END);
            }

            bool reset_handle_inherit = true;
            DWORD handle_flags = 0;

            // character device must always stay inheritable if not explicitly declared as not inheritable
            const DWORD reopen_stderr_handle_type = _get_file_type(g_reopen_stderr_handle);
            const bool reset_handle_to_inherit = !g_no_stderr_inherit && reopen_stderr_handle_type == FILE_TYPE_CHAR;

            if (reopen_stderr_handle_type != FILE_TYPE_CHAR || !is_os_windows_7) { // specific for Windows 7 workaround
                if (GetHandleInformation(g_reopen_stderr_handle, &handle_flags) && reset_handle_to_inherit ? (handle_flags & HANDLE_FLAG_INHERIT) : !(handle_flags & HANDLE_FLAG_INHERIT)) {
                    reset_handle_inherit = false;
                }

                if (reset_handle_inherit) {
                    SetLastError(0); // just in case
                    if (!SetHandleInformation(g_reopen_stderr_handle, HANDLE_FLAG_INHERIT, reset_handle_to_inherit ? TRUE : FALSE)) {
                        if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                            win_error = GetLastError();
                        }
                        if (!g_flags.ret_win_error) {
                            ret = err_win32_error;
                        }
                        else {
                            ret = win_error;
                        }
                        if (!g_flags.no_print_gen_error_string) {
                            _print_stderr_message(_T("could not %s handle inheritance of reopened stderr as file: win_error=0x%08X (%d) file=\"%s\"\n"),
                                reset_handle_to_inherit ? _T("enable") : _T("disable"), win_error, win_error, g_options.reopen_stderr_as_file.c_str());
                        }
                        if (g_flags.print_win_error_string && win_error) {
                            _print_win_error_message(win_error, g_options.win_error_langid);
                        }
                        return false;
                    }
                }
            }

            g_reopen_stderr_fileid = _get_fileid_by_file_handle(g_reopen_stderr_handle, g_options.win_ver);

            // check opened handles on equality

            if (_is_equal_fileid(g_reopen_stdout_fileid, g_reopen_stderr_fileid)) {
                // reopen handle through the handle duplication
                _close_handle(g_reopen_stderr_handle);

                SetLastError(0); // just in case
                if (!DuplicateHandle(GetCurrentProcess(), g_reopen_stdout_handle, GetCurrentProcess(), &g_reopen_stderr_handle, 0, reset_handle_to_inherit ? TRUE : FALSE, DUPLICATE_SAME_ACCESS)) {
                    if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                        win_error = GetLastError();
                    }
                    if (!g_flags.ret_win_error) {
                        ret = err_win32_error;
                    }
                    else {
                        ret = win_error;
                    }
                    if (!g_flags.no_print_gen_error_string) {
                        _print_stderr_message(_T("could not auto duplicate (merge) stdout into stderr: win_error=0x%08X (%d) file=\"%s\"\n"),
                            win_error, win_error, g_options.reopen_stdout_as_file.c_str());
                    }
                    if (g_flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, g_options.win_error_langid);
                    }
                    return false;
                }

                g_reopen_stderr_mutex = g_reopen_stdout_mutex;
            }
            else {
                // create associated write mutex
                if (g_flags.mutex_std_writes) {
                    g_reopen_stderr_mutex = CreateMutex(NULL, FALSE,
                        (std::tstring(_T(STD_FILE_WRITE_MUTEX_NAME_PREFIX) _T("-")) + g_reopen_stderr_fileid.to_tstring()).c_str());
                }
            }

            if (!_set_crt_std_handle(g_reopen_stderr_handle, -1, STDERR_FILENO, _O_BINARY, true, reset_handle_to_inherit)) {
                if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                    win_error = GetLastError();
                }
                if (!g_flags.ret_win_error) {
                    ret = err_win32_error;
                }
                else {
                    ret = win_error;
                }
                if (!g_flags.no_print_gen_error_string) {
                    _print_stderr_message(_T("could not duplicate reopened stderr as file before transfer handle ownership to CRT: win_error=0x%08X (%d) file=\"%s\"\n"),
                        win_error, win_error, g_options.reopen_stderr_as_file.c_str());
                }
                if (g_flags.print_win_error_string && win_error) {
                    _print_win_error_message(win_error, g_options.win_error_langid);
                }
                return false;
            }

            g_is_stderr_reopened = true;
        }
        else {
            if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                win_error = GetLastError();
            }
            if (!g_flags.ret_win_error) {
                ret = err_win32_error;
            }
            else {
                ret = win_error;
            }
            if (!g_flags.no_print_gen_error_string) {
                _print_stderr_message(_T("could not reopen stderr as file to write: win_error=0x%08X (%d) file=\"%s\"\n"),
                    win_error, win_error, g_options.reopen_stderr_as_file.c_str());
            }
            if (g_flags.print_win_error_string && win_error) {
                _print_win_error_message(win_error, g_options.win_error_langid);
            }
            return false;
        }
    }
    else if (!g_options.reopen_stderr_as_server_pipe.empty()) {
        SetLastError(0); // just in case
        if (!_is_valid_handle(g_reopen_stderr_handle =
            CreateNamedPipe((std::tstring(_T("\\\\.\\pipe\\")) + g_options.reopen_stderr_as_server_pipe).c_str(),
                PIPE_ACCESS_OUTBOUND | FILE_FLAG_FIRST_PIPE_INSTANCE | FILE_FLAG_OVERLAPPED,
                PIPE_TYPE_BYTE | PIPE_READMODE_BYTE | PIPE_WAIT | PIPE_REJECT_REMOTE_CLIENTS,
                1, g_options.reopen_stderr_as_server_pipe_out_buf_size, g_options.reopen_stderr_as_server_pipe_in_buf_size,
                0, NULL))) {
            if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                win_error = GetLastError();
            }
            if (!g_flags.ret_win_error) {
                ret = err_win32_error;
            }
            else {
                ret = win_error;
            }
            if (!g_flags.no_print_gen_error_string) {
                _print_stderr_message(_T("could not reopen stderr as server named pipe end to write: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                    win_error, win_error, g_options.reopen_stderr_as_server_pipe.c_str());
            }
            if (g_flags.print_win_error_string && win_error) {
                _print_win_error_message(win_error, g_options.win_error_langid);
            }
            return false;
        }

        bool reset_handle_inherit = true;
        DWORD handle_flags = 0;

        if (GetHandleInformation(g_reopen_stderr_handle, &handle_flags) && !(handle_flags & HANDLE_FLAG_INHERIT)) {
            reset_handle_inherit = false;
        }

        if (reset_handle_inherit) {
            SetLastError(0); // just in case
            if (!SetHandleInformation(g_reopen_stderr_handle, HANDLE_FLAG_INHERIT, FALSE)) {
                if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                    win_error = GetLastError();
                }
                if (!g_flags.ret_win_error) {
                    ret = err_win32_error;
                }
                else {
                    ret = win_error;
                }
                if (!g_flags.no_print_gen_error_string) {
                    _print_stderr_message(_T("could not disable handle inheritance of reopened stderr as server named pipe end: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                        win_error, win_error, g_options.reopen_stderr_as_server_pipe.c_str());
                }
                if (g_flags.print_win_error_string && win_error) {
                    _print_win_error_message(win_error, g_options.win_error_langid);
                }
                return false;
            }
        }

        if (!_set_crt_std_handle(g_reopen_stderr_handle, -1, STDERR_FILENO, _O_BINARY, true, false)) {
            if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                win_error = GetLastError();
            }
            if (!g_flags.ret_win_error) {
                ret = err_win32_error;
            }
            else {
                ret = win_error;
            }
            if (!g_flags.no_print_gen_error_string) {
                _print_stderr_message(_T("could not duplicate reopened stderr as server named pipe end before transfer handle ownership to CRT: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                    win_error, win_error, g_options.reopen_stderr_as_server_pipe.c_str());
            }
            if (g_flags.print_win_error_string && win_error) {
                _print_win_error_message(win_error, g_options.win_error_langid);
            }
            return false;
        }

        g_is_stderr_reopened = true;

        g_connect_server_named_pipe_thread_locals[0][2].server_named_pipe_handle_ptr = &g_reopen_stderr_handle;

        // start server pipe connection await thread
        g_connect_server_named_pipe_thread_locals[0][2].thread_handle = CreateThread(
            NULL, 0,
            ConnectServerNamedPipeThread<0, 2>, &g_connect_server_named_pipe_thread_locals[0][2].thread_data,
            0,
            &g_connect_server_named_pipe_thread_locals[0][2].thread_id
        );
    }
    else if (!g_options.reopen_stderr_as_client_pipe.empty()) {
        g_connect_server_named_pipe_thread_locals[0][2].client_named_pipe_handle_ptr = &g_reopen_stderr_handle;

        // start client pipe connection await thread
        g_connect_client_named_pipe_thread_locals[0][2].thread_handle = CreateThread(
            NULL, 0,
            ConnectClientNamedPipeThread<0, 2>, &g_connect_client_named_pipe_thread_locals[0][2].thread_data,
            0,
            &g_connect_client_named_pipe_thread_locals[0][2].thread_id
        );
    }

    return true;
}

bool CreateOutboundPipeFromConsoleInput(int & ret, DWORD & win_error)
{
    ret = err_none;
    win_error = 0;

    // CAUTION:
    //  We must set all handles being passed into the child process as inheritable and not inheritable if not being passed,
    //  otherwise respective `ReadFile` on the pipe end in the parent process will be blocked!
    //  There is not enough to just pass a handle into the `CreateProcess`.
    //

    if (g_options.create_outbound_server_pipe_from_stdin.empty()) {
        // create anonymous pipe
        SECURITY_ATTRIBUTES sa{};

        sa.nLength = sizeof(sa);
        sa.bInheritHandle = TRUE;

        SetLastError(0); // just in case
        if (!CreatePipe(&g_stdin_pipe_read_handle, &g_stdin_pipe_write_handle, &sa, g_options.tee_stdin_pipe_buf_size)) {
            if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                win_error = GetLastError();
            }
            if (!g_flags.ret_win_error) {
                ret = err_win32_error;
            }
            else {
                ret = win_error;
            }
            if (!g_flags.no_print_gen_error_string) {
                _print_stderr_message(_T("could not create outbound anonymous pipe from stdin: win_error=0x%08X (%d)\n"),
                    win_error, win_error);
            }
            if (g_flags.print_win_error_string && win_error) {
                _print_win_error_message(win_error, g_options.win_error_langid);
            }
            return false;
        }

        SetLastError(0); // just in case
        if (!SetHandleInformation(g_stdin_pipe_write_handle, HANDLE_FLAG_INHERIT, FALSE)) {
            if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                win_error = GetLastError();
            }
            if (!g_flags.ret_win_error) {
                ret = err_win32_error;
            }
            else {
                ret = win_error;
            }
            if (!g_flags.no_print_gen_error_string) {
                _print_stderr_message(_T("could not disable handle inheritance of stdin outbound anonymous pipe end: win_error=0x%08X (%d) type=%u file=\"%s\"\n"),
                    win_error, win_error, g_stdin_handle_type, g_options.reopen_stdin_as_file.c_str());
            }
            if (g_flags.print_win_error_string && win_error) {
                _print_win_error_message(win_error, g_options.win_error_langid);
            }
            return false;
        }
    }
    else {
        // create named pipe
        const auto pipe_name_str = std::tstring(_T("\\\\.\\pipe\\")) + g_options.create_outbound_server_pipe_from_stdin;

        SetLastError(0); // just in case
        if (!_is_valid_handle(g_stdin_pipe_write_handle =
            CreateNamedPipe(pipe_name_str.c_str(),
                PIPE_ACCESS_OUTBOUND | FILE_FLAG_FIRST_PIPE_INSTANCE | FILE_FLAG_OVERLAPPED,
                PIPE_TYPE_BYTE | PIPE_READMODE_BYTE | PIPE_WAIT | PIPE_REJECT_REMOTE_CLIENTS,
                1, g_options.create_outbound_server_pipe_from_stdin_in_buf_size, g_options.create_outbound_server_pipe_from_stdin_out_buf_size,
                0, NULL))) {
            if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                win_error = GetLastError();
            }
            if (!g_flags.ret_win_error) {
                ret = err_win32_error;
            }
            else {
                ret = win_error;
            }
            if (!g_flags.no_print_gen_error_string) {
                _print_stderr_message(_T("could not create outbound server named pipe from stdin: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                    win_error, win_error, g_options.create_outbound_server_pipe_from_stdin.c_str());
            }
            if (g_flags.print_win_error_string && win_error) {
                _print_win_error_message(win_error, g_options.win_error_langid);
            }
            return false;
        }

        SetLastError(0); // just in case
        if (!SetHandleInformation(g_stdin_pipe_write_handle, HANDLE_FLAG_INHERIT, FALSE)) {
            if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                win_error = GetLastError();
            }
            if (!g_flags.ret_win_error) {
                ret = err_win32_error;
            }
            else {
                ret = win_error;
            }
            if (!g_flags.no_print_gen_error_string) {
                _print_stderr_message(_T("could not disable handle inheritance of stdin outbound server named pipe end: win_error=0x%08X (%d) type=%u file=\"%s\"\n"),
                    win_error, win_error, g_stdin_handle_type, g_options.reopen_stdin_as_file.c_str());
            }
            if (g_flags.print_win_error_string && win_error) {
                _print_win_error_message(win_error, g_options.win_error_langid);
            }
            return false;
        }

        g_connect_bound_server_named_pipe_tofrom_conin_thread_locals[0].server_named_pipe_handle_ptr = &g_stdin_pipe_write_handle;

        // start server pipe connection await thread
        g_connect_bound_server_named_pipe_tofrom_conin_thread_locals[0].thread_handle = CreateThread(
            NULL, 0,
            ConnectOutboundServerPipeFromConsoleInputThread, &g_connect_bound_server_named_pipe_tofrom_conin_thread_locals[0].thread_data,
            0,
            &g_connect_bound_server_named_pipe_tofrom_conin_thread_locals[0].thread_id
        );
    }

    return true;
}

template <int stream_type>
bool CreateInboundPipeToConsoleOutput(int & ret, DWORD & win_error)
{
    ret = err_none;
    win_error = 0;

    const auto & conout_name_token_str = UTILITY_CONSTEXPR(stream_type == 1) ? _T("stdout") : _T("stderr");

    const auto & create_inbound_server_pipe_to_conout = UTILITY_CONSTEXPR(stream_type == 1) ? g_options.create_inbound_server_pipe_to_stdout : g_options.create_inbound_server_pipe_to_stderr;

    auto & conout_pipe_read_handle = UTILITY_CONSTEXPR(stream_type == 1) ? g_stdout_pipe_read_handle : g_stderr_pipe_read_handle;
    auto & conout_pipe_write_handle = UTILITY_CONSTEXPR(stream_type == 1) ? g_stdout_pipe_write_handle : g_stderr_pipe_write_handle;

    const auto conout_handle_type = UTILITY_CONSTEXPR(stream_type == 1) ? g_stdout_handle_type : g_stderr_handle_type;

    const auto reopen_conout_as_file = UTILITY_CONSTEXPR(stream_type == 1) ? g_options.reopen_stdout_as_file : g_options.reopen_stderr_as_file;

    // CAUTION:
    //  We must set all handles being passed into the child process as inheritable and not inheritable if not being passed,
    //  otherwise respective `ReadFile` on the pipe end in the parent process will be blocked!
    //  This is not enough to just pass the handle into the `CreateProcess`.
    //

    if (create_inbound_server_pipe_to_conout.empty()) {
        // create anonymous pipe
        SECURITY_ATTRIBUTES sa{};

        sa.nLength = sizeof(sa);
        sa.bInheritHandle = TRUE;

        const auto tee_conout_pipe_buf_size = UTILITY_CONSTEXPR(stream_type == 1) ? g_options.tee_stdout_pipe_buf_size : g_options.tee_stderr_pipe_buf_size;

        SetLastError(0); // just in case
        if (!CreatePipe(&conout_pipe_read_handle, &conout_pipe_write_handle, &sa, // must use `sa` to setup inheritance
            tee_conout_pipe_buf_size)) {
            if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                win_error = GetLastError();
            }
            if (!g_flags.ret_win_error) {
                ret = err_win32_error;
            }
            else {
                ret = win_error;
            }
            if (!g_flags.no_print_gen_error_string) {
                _print_stderr_message(_T("could not create inbound anonymous pipe to %s: win_error=0x%08X (%d)\n"),
                    conout_name_token_str, win_error, win_error);
            }
            if (g_flags.print_win_error_string && win_error) {
                _print_win_error_message(win_error, g_options.win_error_langid);
            }
            return false;
        }

        SetLastError(0); // just in case
        if (!SetHandleInformation(conout_pipe_read_handle, HANDLE_FLAG_INHERIT, FALSE)) {
            if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                win_error = GetLastError();
            }
            if (!g_flags.ret_win_error) {
                ret = err_win32_error;
            }
            else {
                ret = win_error;
            }
            if (!g_flags.no_print_gen_error_string) {
                _print_stderr_message(_T("could not disable handle inheritance of %s inbound anonymous pipe end: win_error=0x%08X (%d) type=%u file=\"%s\"\n"),
                    conout_name_token_str, win_error, win_error, conout_handle_type, reopen_conout_as_file.c_str());
            }
            if (g_flags.print_win_error_string && win_error) {
                _print_win_error_message(win_error, g_options.win_error_langid);
            }
            return false;
        }
    }
    else {
        // create named pipe
        const auto pipe_name_str = std::tstring(_T("\\\\.\\pipe\\")) + create_inbound_server_pipe_to_conout;

        const auto create_inbound_server_pipe_to_conout_in_buf_size = UTILITY_CONSTEXPR(stream_type == 1) ?
            g_options.create_inbound_server_pipe_to_stdout_in_buf_size : g_options.create_inbound_server_pipe_to_stderr_in_buf_size;
        const auto create_inbound_server_pipe_to_conout_out_buf_size = UTILITY_CONSTEXPR(stream_type == 1) ?
            g_options.create_inbound_server_pipe_to_stdout_out_buf_size : g_options.create_inbound_server_pipe_to_stderr_out_buf_size;

        SetLastError(0); // just in case
        if (!_is_valid_handle(conout_pipe_read_handle =
            CreateNamedPipe(pipe_name_str.c_str(),
                PIPE_ACCESS_INBOUND | FILE_FLAG_FIRST_PIPE_INSTANCE | FILE_FLAG_OVERLAPPED,
                PIPE_TYPE_BYTE | PIPE_READMODE_BYTE | PIPE_WAIT | PIPE_REJECT_REMOTE_CLIENTS,
                1, create_inbound_server_pipe_to_conout_in_buf_size, create_inbound_server_pipe_to_conout_out_buf_size,
                0, NULL))) {
            if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                win_error = GetLastError();
            }
            if (!g_flags.ret_win_error) {
                ret = err_win32_error;
            }
            else {
                ret = win_error;
            }
            if (!g_flags.no_print_gen_error_string) {
                _print_stderr_message(_T("could not create inbound server named pipe end to %s: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                    conout_name_token_str, win_error, win_error, create_inbound_server_pipe_to_conout.c_str());
            }
            if (g_flags.print_win_error_string && win_error) {
                _print_win_error_message(win_error, g_options.win_error_langid);
            }
            return false;
        }

        SetLastError(0); // just in case
        if (!SetHandleInformation(conout_pipe_read_handle, HANDLE_FLAG_INHERIT, FALSE)) {
            if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                win_error = GetLastError();
            }
            if (!g_flags.ret_win_error) {
                ret = err_win32_error;
            }
            else {
                ret = win_error;
            }
            if (!g_flags.no_print_gen_error_string) {
                _print_stderr_message(_T("could not disable handle inheritance of %s inbound server named pipe end: win_error=0x%08X (%d) type=%u file=\"%s\"\n"),
                    conout_name_token_str, win_error, win_error, conout_handle_type, reopen_conout_as_file.c_str());
            }
            if (g_flags.print_win_error_string && win_error) {
                _print_win_error_message(win_error, g_options.win_error_langid);
            }
            return false;
        }

        g_connect_bound_server_named_pipe_tofrom_conin_thread_locals[stream_type].server_named_pipe_handle_ptr = &conout_pipe_read_handle;

        // start server pipe connection await thread
        g_connect_bound_server_named_pipe_tofrom_conin_thread_locals[stream_type].thread_handle = CreateThread(
            NULL, 0,
            ConnectInboundServerPipeToConsoleOutputThread<stream_type>, &g_connect_bound_server_named_pipe_tofrom_conin_thread_locals[stream_type].thread_data,
            0,
            &g_connect_bound_server_named_pipe_tofrom_conin_thread_locals[stream_type].thread_id
        );
    }

    return true;
}

DWORD WINAPI ConnectOutboundServerPipeFromConsoleInputThread(LPVOID lpParam)
{
    ConnectNamedPipeThreadData & thread_data = *static_cast<ConnectNamedPipeThreadData *>(lpParam);

    thread_data.ret = err_unspecified;
    thread_data.is_error = true;

    OVERLAPPED connection_await_overlapped{};

    DWORD win_error = 0;

    // NOTE:
    //  lambda to bypass msvc error: `error C2712: Cannot use __try in functions that require object unwinding`
    //
    return [&]() -> DWORD { __try {
        return [&]() -> DWORD {
            if_break(true) {
                // start server pipe connection await
                SetLastError(0); // just in case
                if (!ConnectNamedPipe(g_stdin_pipe_write_handle, &connection_await_overlapped)) {
                    win_error = GetLastError();
                    if (win_error == ERROR_PIPE_CONNECTED) {
                        break;
                    }
                    if (win_error != ERROR_IO_PENDING && win_error != ERROR_PIPE_LISTENING) {
                        thread_data.ret = err_named_pipe_connect_error;
                        thread_data.win_error = win_error;
                        if (!g_flags.no_print_gen_error_string) {
                            thread_data.msg =
                                _format_stderr_message(_T("could not initiate connection of outbound client named pipe end from stdin: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                                    win_error, win_error, g_options.create_outbound_server_pipe_from_stdin.c_str());
                        }
                        if (g_flags.print_win_error_string && win_error) {
                            thread_data.msg +=
                                _format_win_error_message(win_error, g_options.win_error_langid);
                        }
                        return 1;
                    }
                }

                const auto start_time_ms = g_options.win_ver.major >= 6 ? GetTickCount64() : GetTickCount();

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

                    const auto end_time_ms = g_options.win_ver.major >= 6 ? GetTickCount64() : GetTickCount();

                    const auto time_delta_ms = end_time_ms >= start_time_ms ? end_time_ms - start_time_ms : 0;

                    if (time_delta_ms >= g_options.create_outbound_server_pipe_from_stdin_connect_timeout_ms) {
                        thread_data.ret = err_named_pipe_connect_timeout;
                        if (!g_flags.no_print_gen_error_string) {
                            thread_data.msg =
                                _format_stderr_message(_T("server connection timeout of outbound server named pipe end from stdin: pipe=\"%s\" timeout=%u ms\n"),
                                    g_options.create_outbound_server_pipe_from_stdin.c_str(), g_options.create_outbound_server_pipe_from_stdin_connect_timeout_ms);
                        }

                        return 1;
                    }

                    Sleep(20);
                }
            }

            thread_data.is_error = false;

            return 0;
        }();
    }
    __finally {
        if (thread_data.is_error) {
            // explicitly disconnect/close all pipe outbound handles here to trigger the child process reaction

            // NOTE:
            //  Always disconnect a server named pipe end together with the handle close even if connection is not accomplished or SEH exception is thrown,
            //  otherwise a client may be blocked on the `PeekNamedPipe` call in an infinite loop.
            //
            if (!g_options.create_outbound_server_pipe_from_stdin.empty()) {
                DisconnectNamedPipe(g_stdin_pipe_write_handle);
            }
            _close_handle(g_stdin_pipe_write_handle);
        }
    }

    return 0;
    }();
}

template <int stream_type>
DWORD WINAPI ConnectInboundServerPipeToConsoleOutputThread(LPVOID lpParam)
{
    ConnectNamedPipeThreadData & thread_data = *static_cast<ConnectNamedPipeThreadData *>(lpParam);

    thread_data.ret = err_unspecified;
    thread_data.is_error = true;

    OVERLAPPED connection_await_overlapped{};

    DWORD win_error = 0;

    const auto & conout_name_token_str = UTILITY_CONSTEXPR(stream_type == 1) ? _T("stdout") : _T("stderr");

    const auto & create_inbound_server_pipe_to_conout = UTILITY_CONSTEXPR(stream_type == 1) ? g_options.create_inbound_server_pipe_to_stdout : g_options.create_inbound_server_pipe_to_stderr;

    auto & conout_pipe_read_handle = UTILITY_CONSTEXPR(stream_type == 1) ? g_stdout_pipe_read_handle : g_stderr_pipe_read_handle;
    auto & conout_pipe_write_handle = UTILITY_CONSTEXPR(stream_type == 1) ? g_stdout_pipe_write_handle : g_stderr_pipe_write_handle;

    const auto create_inbound_server_pipe_to_conout_connect_timeout_ms = UTILITY_CONSTEXPR(stream_type == 1) ?
        g_options.create_inbound_server_pipe_to_stdout_connect_timeout_ms : g_options.create_inbound_server_pipe_to_stderr_connect_timeout_ms;

    // NOTE:
    //  lambda to bypass msvc error: `error C2712: Cannot use __try in functions that require object unwinding`
    //
    return [&]() -> DWORD { __try {
        return [&]() -> DWORD {
            if_break(true) {
                // start server pipe connection await
                SetLastError(0); // just in case
                if (!ConnectNamedPipe(conout_pipe_read_handle, &connection_await_overlapped)) {
                    win_error = GetLastError();
                    if (win_error == ERROR_PIPE_CONNECTED) {
                        break;
                    }
                    if (win_error != ERROR_IO_PENDING && win_error != ERROR_PIPE_LISTENING) {
                        thread_data.ret = err_named_pipe_connect_error;
                        thread_data.win_error = win_error;
                        if (!g_flags.no_print_gen_error_string) {
                            thread_data.msg =
                                _format_stderr_message(_T("could not initiate connection of inbound client named pipe end from %s: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                                    conout_name_token_str, win_error, win_error, create_inbound_server_pipe_to_conout.c_str());
                        }
                        if (g_flags.print_win_error_string && win_error) {
                            thread_data.msg +=
                                _format_win_error_message(win_error, g_options.win_error_langid);
                        }
                        return 1;
                    }
                }

                // server named pipe end wait loop
                const auto start_time_ms = g_options.win_ver.major >= 6 ? GetTickCount64() : GetTickCount();

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

                    const auto end_time_ms = g_options.win_ver.major >= 6 ? GetTickCount64() : GetTickCount();

                    const auto time_delta_ms = end_time_ms >= start_time_ms ? end_time_ms - start_time_ms : 0;

                    if (time_delta_ms >= create_inbound_server_pipe_to_conout_connect_timeout_ms) {
                        thread_data.ret = err_named_pipe_connect_timeout;
                        if (!g_flags.no_print_gen_error_string) {
                            thread_data.msg =
                                _format_stderr_message(_T("server connection timeout of inbound server named pipe end to %s: pipe=\"%s\" timeout=%u ms\n"),
                                    conout_name_token_str, create_inbound_server_pipe_to_conout.c_str(), create_inbound_server_pipe_to_conout_connect_timeout_ms);
                        }

                        return 1;
                    }

                    Sleep(20);
                }
            }

            thread_data.is_error = false;

            return 0;
        }();
    }
    __finally {
        if (thread_data.is_error) {
            // explicitly disconnect/close all pipe outbound handles here to trigger the child process reaction

            // NOTE:
            //  Always disconnect a server named pipe end together with the handle close even if connection is not accomplished or SEH exception is thrown,
            //  otherwise a client may be blocked on the `PeekNamedPipe` call in an infinite loop.
            //
            DisconnectNamedPipe(conout_pipe_read_handle);
            _close_handle(conout_pipe_read_handle);
        }
    }

    return 0;
    }();
}

bool CreateTeeOutputFromStdin(int & ret, DWORD & win_error, UINT cp_in)
{
    ret = err_none;
    win_error = 0;

    if (!g_options.tee_stdin_to_file.empty()) {
        SetLastError(0); // just in case
        if (_is_valid_handle(g_tee_file_stdin_handle =
            CreateFile(g_options.tee_stdin_to_file.c_str(),
                GENERIC_WRITE, FILE_SHARE_READ | FILE_SHARE_WRITE, NULL,
                g_flags.tee_stdin_file_truncate ? CREATE_ALWAYS : OPEN_ALWAYS,
                FILE_ATTRIBUTE_NORMAL, NULL))) {
            if (!g_flags.tee_stdin_file_truncate) {
                SetFilePointer(g_tee_file_stdin_handle, 0, NULL, FILE_END);
            }

            g_tee_file_stdin_fileid = _get_fileid_by_file_handle(g_tee_file_stdin_handle, g_options.win_ver);

            // create associated write mutex
            if (g_flags.mutex_tee_file_writes) {
                g_tee_file_stdin_mutex = CreateMutex(NULL, FALSE,
                    (std::tstring(_T(TEE_FILE_WRITE_MUTEX_NAME_PREFIX) _T("-")) + g_tee_file_stdin_fileid.to_tstring()).c_str());
            }
        }
        else {
            if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                win_error = GetLastError();
            }
            if (!g_flags.ret_win_error) {
                ret = err_win32_error;
            }
            else {
                ret = win_error;
            }
            if (!g_flags.no_print_gen_error_string) {
                _print_stderr_message(_T("could not open stdin tee file to write: win_error=0x%08X (%d) file=\"%s\"\n"),
                    win_error, win_error, g_options.tee_stdin_to_file.c_str());
            }
            if (g_flags.print_win_error_string && win_error) {
                _print_win_error_message(win_error, g_options.win_error_langid);
            }
            return false;
        }

        g_has_tee_stdin = true;
    }
    else if (!g_options.tee_stdin_to_server_pipe.empty()) {
        SetLastError(0); // just in case
        if (!_is_valid_handle(g_tee_named_pipe_stdin_handle =
            CreateNamedPipe((std::tstring(_T("\\\\.\\pipe\\")) + g_options.tee_stdin_to_server_pipe).c_str(),
                PIPE_ACCESS_OUTBOUND | FILE_FLAG_FIRST_PIPE_INSTANCE | FILE_FLAG_OVERLAPPED,
                PIPE_TYPE_BYTE | PIPE_READMODE_BYTE | PIPE_WAIT | PIPE_REJECT_REMOTE_CLIENTS,
                1, g_options.tee_stderr_to_server_pipe_out_buf_size, g_options.tee_stderr_to_server_pipe_in_buf_size,
                0, NULL))) {
            if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                win_error = GetLastError();
            }
            if (!g_flags.ret_win_error) {
                ret = err_win32_error;
            }
            else {
                ret = win_error;
            }
            if (!g_flags.no_print_gen_error_string) {
                _print_stderr_message(_T("could not open stdin tee as server named pipe end to write: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                    win_error, win_error, g_options.tee_stdin_to_server_pipe.c_str());
            }
            if (g_flags.print_win_error_string && win_error) {
                _print_win_error_message(win_error, g_options.win_error_langid);
            }
            return false;
        }

        g_has_tee_stdin = true;

        g_connect_server_named_pipe_thread_locals[1][0].server_named_pipe_handle_ptr = &g_tee_named_pipe_stdin_handle;

        // start server pipe connection await thread
        g_connect_server_named_pipe_thread_locals[1][0].thread_handle = CreateThread(
            NULL, 0,
            ConnectServerNamedPipeThread<1, 0>, &g_connect_server_named_pipe_thread_locals[1][0].thread_data,
            0,
            &g_connect_server_named_pipe_thread_locals[1][0].thread_id
        );
    }
    else if (!g_options.tee_stdin_to_client_pipe.empty()) {
        g_has_tee_stdin = true;

        g_connect_server_named_pipe_thread_locals[1][0].client_named_pipe_handle_ptr = &g_tee_named_pipe_stdin_handle;

        // start client pipe connection await thread
        g_connect_client_named_pipe_thread_locals[1][0].thread_handle = CreateThread(
            NULL, 0,
            ConnectClientNamedPipeThread<1, 0>, &g_connect_client_named_pipe_thread_locals[1][0].thread_data,
            0,
            &g_connect_client_named_pipe_thread_locals[1][0].thread_id
        );
    }

    return true;
}

bool CreateTeeOutputFromStdout(int & ret, DWORD & win_error, UINT cp_in)
{
    ret = err_none;
    win_error = 0;

    if (!g_options.tee_stdout_to_file.empty()) {
        SetLastError(0); // just in case
        if (_is_valid_handle(g_tee_file_stdout_handle =
            CreateFile(g_options.tee_stdout_to_file.c_str(),
                GENERIC_WRITE, FILE_SHARE_READ | FILE_SHARE_WRITE, NULL,
                g_flags.tee_stdout_file_truncate ? CREATE_ALWAYS : OPEN_ALWAYS,
                FILE_ATTRIBUTE_NORMAL, NULL))) {
            if (!g_flags.tee_stdout_file_truncate) {
                SetFilePointer(g_tee_file_stdout_handle, 0, NULL, FILE_END);
            }

            g_tee_file_stdout_fileid = _get_fileid_by_file_handle(g_tee_file_stdout_handle, g_options.win_ver);
        }
        else {
            if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                win_error = GetLastError();
            }
            if (!g_flags.ret_win_error) {
                ret = err_win32_error;
            }
            else {
                ret = win_error;
            }
            if (!g_flags.no_print_gen_error_string) {
                _print_stderr_message(_T("could not open stdout tee file to write: win_error=0x%08X (%d) file=\"%s\"\n"),
                    win_error, win_error, g_options.tee_stdout_to_file.c_str());
            }
            if (g_flags.print_win_error_string && win_error) {
                _print_win_error_message(win_error, g_options.win_error_langid);
            }
            return false;
        }

        g_has_tee_stdout = true;

        // check opened handles on equality

        if (_is_equal_fileid(g_tee_file_stdin_fileid, g_tee_file_stdout_fileid)) {
            // reopen handle through the handle duplication
            _close_handle(g_tee_file_stdout_handle);

            SetLastError(0); // just in case
            if (!DuplicateHandle(GetCurrentProcess(), g_tee_file_stdin_handle, GetCurrentProcess(), &g_tee_file_stdout_handle, 0, FALSE, DUPLICATE_SAME_ACCESS)) {
                if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                    win_error = GetLastError();
                }
                if (!g_flags.ret_win_error) {
                    ret = err_win32_error;
                }
                else {
                    ret = win_error;
                }
                if (!g_flags.no_print_gen_error_string) {
                    _print_stderr_message(_T("could not auto duplicate (merge) stdin tee into stdout tee: win_error=0x%08X (%d) file=\"%s\"\n"),
                        win_error, win_error, g_options.tee_stdin_to_file.c_str());
                }
                if (g_flags.print_win_error_string && win_error) {
                    _print_win_error_message(win_error, g_options.win_error_langid);
                }
                return false;
            }

            g_tee_file_stdout_mutex = g_tee_file_stdin_mutex;
        }
        else {
            // create associated write mutex
            if (g_flags.mutex_tee_file_writes) {
                g_tee_file_stdout_mutex = CreateMutex(NULL, FALSE,
                    (std::tstring(_T(TEE_FILE_WRITE_MUTEX_NAME_PREFIX) _T("-")) + g_tee_file_stdout_fileid.to_tstring()).c_str());
            }
        }
    }
    else if (!g_options.tee_stdout_to_server_pipe.empty()) {
        SetLastError(0); // just in case
        if (!_is_valid_handle(g_tee_named_pipe_stdout_handle =
            CreateNamedPipe((std::tstring(_T("\\\\.\\pipe\\")) + g_options.tee_stdout_to_server_pipe).c_str(),
                PIPE_ACCESS_OUTBOUND | FILE_FLAG_FIRST_PIPE_INSTANCE | FILE_FLAG_OVERLAPPED,
                PIPE_TYPE_BYTE | PIPE_READMODE_BYTE | PIPE_WAIT | PIPE_REJECT_REMOTE_CLIENTS,
                1, g_options.tee_stderr_to_server_pipe_out_buf_size, g_options.tee_stderr_to_server_pipe_in_buf_size,
                0, NULL))) {
            if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                win_error = GetLastError();
            }
            if (!g_flags.ret_win_error) {
                ret = err_win32_error;
            }
            else {
                ret = win_error;
            }
            if (!g_flags.no_print_gen_error_string) {
                _print_stderr_message(_T("could not open stdout tee as server named pipe end to write: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                    win_error, win_error, g_options.tee_stdout_to_server_pipe.c_str());
            }
            if (g_flags.print_win_error_string && win_error) {
                _print_win_error_message(win_error, g_options.win_error_langid);
            }
            return false;
        }

        g_has_tee_stdout = true;

        g_connect_server_named_pipe_thread_locals[1][1].server_named_pipe_handle_ptr = &g_tee_named_pipe_stdout_handle;

        // start server pipe connection await thread
        g_connect_server_named_pipe_thread_locals[1][1].thread_handle = CreateThread(
            NULL, 0,
            ConnectServerNamedPipeThread<1, 1>, &g_connect_server_named_pipe_thread_locals[1][1].thread_data,
            0,
            &g_connect_server_named_pipe_thread_locals[1][1].thread_id
        );
    }
    else if (!g_options.tee_stdout_to_client_pipe.empty()) {
        g_has_tee_stdout = true;

        g_connect_server_named_pipe_thread_locals[1][1].client_named_pipe_handle_ptr = &g_tee_named_pipe_stdout_handle;

        // start client pipe connection await thread
        g_connect_client_named_pipe_thread_locals[1][1].thread_handle = CreateThread(
            NULL, 0,
            ConnectClientNamedPipeThread<1, 1>, &g_connect_client_named_pipe_thread_locals[1][1].thread_data,
            0,
            &g_connect_client_named_pipe_thread_locals[1][1].thread_id
        );
    }

    return true;
}

bool CreateTeeOutputFromStderr(int & ret, DWORD & win_error, UINT cp_in)
{
    ret = err_none;
    win_error = 0;

    if (!g_options.tee_stderr_to_file.empty()) {
        SetLastError(0); // just in case
        if (_is_valid_handle(g_tee_file_stderr_handle =
            CreateFile(g_options.tee_stderr_to_file.c_str(),
                GENERIC_WRITE, FILE_SHARE_READ | FILE_SHARE_WRITE, NULL,
                g_flags.tee_stderr_file_truncate ? CREATE_ALWAYS : OPEN_ALWAYS,
                FILE_ATTRIBUTE_NORMAL, NULL))) {
            if (!g_flags.tee_stderr_file_truncate) {
                SetFilePointer(g_tee_file_stderr_handle, 0, NULL, FILE_END);
            }

            g_tee_file_stderr_fileid = _get_fileid_by_file_handle(g_tee_file_stderr_handle, g_options.win_ver);
        }
        else {
            if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                win_error = GetLastError();
            }
            if (!g_flags.ret_win_error) {
                ret = err_win32_error;
            }
            else {
                ret = win_error;
            }
            if (!g_flags.no_print_gen_error_string) {
                _print_stderr_message(_T("could not open stderr tee file to write: win_error=0x%08X (%d) file=\"%s\"\n"),
                    win_error, win_error, g_options.tee_stderr_to_file.c_str());
            }
            if (g_flags.print_win_error_string && win_error) {
                _print_win_error_message(win_error, g_options.win_error_langid);
            }
            return false;
        }

        g_has_tee_stderr = true;

        // check opened handles on equality

        if (_is_equal_fileid(g_tee_file_stdout_fileid, g_tee_file_stderr_fileid)) {
            // reopen handle through the handle duplication
            _close_handle(g_tee_file_stderr_handle);

            SetLastError(0); // just in case
            if (!DuplicateHandle(GetCurrentProcess(), g_tee_file_stdout_handle, GetCurrentProcess(), &g_tee_file_stderr_handle, 0, FALSE, DUPLICATE_SAME_ACCESS)) {
                if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                    win_error = GetLastError();
                }
                if (!g_flags.ret_win_error) {
                    ret = err_win32_error;
                }
                else {
                    ret = win_error;
                }
                if (!g_flags.no_print_gen_error_string) {
                    _print_stderr_message(_T("could not auto duplicate (merge) stdout tee into stderr tee: win_error=0x%08X (%d) file=\"%s\"\n"),
                        win_error, win_error, g_options.tee_stdout_to_file.c_str());
                }
                if (g_flags.print_win_error_string && win_error) {
                    _print_win_error_message(win_error, g_options.win_error_langid);
                }
                return false;
            }

            g_tee_file_stderr_mutex = g_tee_file_stdout_mutex;
        }
        else if (_is_equal_fileid(g_tee_file_stdin_fileid, g_tee_file_stderr_fileid)) {
            // reopen handle through the handle duplication
            _close_handle(g_tee_file_stderr_handle);

            SetLastError(0); // just in case
            if (!DuplicateHandle(GetCurrentProcess(), g_tee_file_stdin_handle, GetCurrentProcess(), &g_tee_file_stderr_handle, 0, FALSE, DUPLICATE_SAME_ACCESS)) {
                if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                    win_error = GetLastError();
                }
                if (!g_flags.ret_win_error) {
                    ret = err_win32_error;
                }
                else {
                    ret = win_error;
                }
                if (!g_flags.no_print_gen_error_string) {
                    _print_stderr_message(_T("could not auto duplicate (merge) stdin tee into stderr tee: win_error=0x%08X (%d) file=\"%s\"\n"),
                        win_error, win_error, g_options.tee_stdin_to_file.c_str());
                }
                if (g_flags.print_win_error_string && win_error) {
                    _print_win_error_message(win_error, g_options.win_error_langid);
                }
                return false;
            }

            g_tee_file_stderr_mutex = g_tee_file_stdin_mutex;
        }
        else {
            // create associated write mutex
            if (g_flags.mutex_tee_file_writes) {
                g_tee_file_stderr_mutex = CreateMutex(NULL, FALSE,
                    (std::tstring(_T(TEE_FILE_WRITE_MUTEX_NAME_PREFIX) _T("-")) + g_tee_file_stderr_fileid.to_tstring()).c_str());
            }
        }
    }
    else if (!g_options.tee_stderr_to_server_pipe.empty()) {
        SetLastError(0); // just in case
        if (!_is_valid_handle(g_tee_named_pipe_stderr_handle =
            CreateNamedPipe((std::tstring(_T("\\\\.\\pipe\\")) + g_options.tee_stderr_to_server_pipe).c_str(),
                PIPE_ACCESS_OUTBOUND | FILE_FLAG_FIRST_PIPE_INSTANCE | FILE_FLAG_OVERLAPPED,
                PIPE_TYPE_BYTE | PIPE_READMODE_BYTE | PIPE_WAIT | PIPE_REJECT_REMOTE_CLIENTS,
                1, g_options.tee_stderr_to_server_pipe_out_buf_size, g_options.tee_stderr_to_server_pipe_in_buf_size,
                0, NULL))) {
            if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                win_error = GetLastError();
            }
            if (!g_flags.ret_win_error) {
                ret = err_win32_error;
            }
            else {
                ret = win_error;
            }
            if (!g_flags.no_print_gen_error_string) {
                _print_stderr_message(_T("could not open stderr tee as server named pipe end to write: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                    win_error, win_error, g_options.tee_stderr_to_server_pipe.c_str());
            }
            if (g_flags.print_win_error_string && win_error) {
                _print_win_error_message(win_error, g_options.win_error_langid);
            }
            return false;
        }

        g_has_tee_stderr = true;

        g_connect_server_named_pipe_thread_locals[1][2].server_named_pipe_handle_ptr = &g_tee_named_pipe_stderr_handle;

        // start server pipe connection await thread
        g_connect_server_named_pipe_thread_locals[1][2].thread_handle = CreateThread(
            NULL, 0,
            ConnectServerNamedPipeThread<1, 2>, &g_connect_server_named_pipe_thread_locals[1][2].thread_data,
            0,
            &g_connect_server_named_pipe_thread_locals[1][2].thread_id
        );
    }
    else if (!g_options.tee_stderr_to_client_pipe.empty()) {
        g_has_tee_stderr = true;

        g_connect_server_named_pipe_thread_locals[1][2].client_named_pipe_handle_ptr = &g_tee_named_pipe_stderr_handle;

        // start client pipe connection await thread
        g_connect_client_named_pipe_thread_locals[1][2].thread_handle = CreateThread(
            NULL, 0,
            ConnectClientNamedPipeThread<1, 2>, &g_connect_client_named_pipe_thread_locals[1][2].thread_data,
            0,
            &g_connect_client_named_pipe_thread_locals[1][2].thread_id
        );
    }

    return true;
}

int ExecuteProcess(LPCTSTR app, size_t app_len, LPCTSTR cmd, size_t cmd_len)
{
#ifdef _DEBUG
    //_print_raw_message_impl(0, STDOUT_FILENO, _T(">%s\n>%s\n---\n"), app ? app : _T(""), cmd ? cmd : _T(""));
#endif

    int ret = err_none;

    if ((!app || !app_len) && (!cmd || !cmd_len)) {
        // just in case
        ret = err_format_empty;
        if (!g_flags.no_print_gen_error_string) {
            _print_stderr_message(_T("format arguments are empty\n"));
        }
        return ret;
    }

    // CAUTION:
    //  Has effect only for Windows version up to 8.1 (read MSDN documentation)
    //
    _get_win_ver(g_options.win_ver);

    const bool is_os_windows_7 = g_options.win_ver.major == 6 && g_options.win_ver.minor == 1;
    const bool is_os_windows_xp_or_lower = g_options.win_ver.major < 6;

    std::vector<uint8_t> cmd_buf;

    STARTUPINFO si{};
    PROCESS_INFORMATION pi{};

    SECURITY_ATTRIBUTES sa{};
    SECURITY_DESCRIPTOR sd{}; // for pipes

    si.cb = sizeof(si);
    si.dwFlags = STARTF_USESHOWWINDOW;

    sa.nLength = sizeof(sa);
    sa.bInheritHandle = TRUE;

    si.wShowWindow = SW_SHOWNORMAL;

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

    std::tstring current_dir;

    std::vector<TCHAR> shell_exec_verb;

    bool is_idle_execute = false;
    if (app && app_len) {
        if (!tstrcmp(app, _T("."))) {
            is_idle_execute = true;
        }
    }

    // update globals
    if(!app || !app_len || g_options.shell_exec_verb.empty()) {
        // CreateProcess
        if (g_flags.no_window) {
            g_options.show_as = SW_HIDE;
        }
    }
    else {
        // ShellExecute
        if (g_flags.no_window || g_flags.no_window_console && !g_flags.create_child_console) {
            g_options.show_as = SW_HIDE;
        }
    }

    g_no_std_inherit = g_is_process_elevating || g_flags.no_std_inherit || is_idle_execute;

    g_no_stdin_inherit = g_no_std_inherit || g_flags.no_stdin_inherit || g_flags.pipe_stdin_to_child_stdin;
    g_no_stdout_inherit = g_no_std_inherit || g_flags.no_stdout_inherit || g_flags.pipe_stdin_to_child_stdin;
    g_no_stderr_inherit = g_no_std_inherit || g_flags.no_stderr_inherit;

    g_stdout_vt100 = g_flags.output_vt100 || g_flags.stdout_vt100;
    g_stderr_vt100 = g_flags.output_vt100 || g_flags.stderr_vt100;

    g_pipe_stdin_to_child_stdin = !is_idle_execute && (g_flags.pipe_inout_child || g_flags.pipe_stdin_to_child_stdin);
    g_pipe_child_stdout_to_stdout = !is_idle_execute && (g_flags.pipe_inout_child || g_flags.pipe_out_child || g_flags.pipe_child_stdout_to_stdout);
    g_pipe_child_stderr_to_stderr = !is_idle_execute && (g_flags.pipe_inout_child || g_flags.pipe_out_child || g_flags.pipe_child_stderr_to_stderr);
    //g_pipe_inout_child = !is_idle_execute && g_flags.pipe_inout_child;
    //g_pipe_out_child = !is_idle_execute && g_flags.pipe_out_child;

    // on idle execution always pipe stdin to stdout
    g_pipe_stdin_to_stdout = !g_is_process_elevating && (g_flags.pipe_stdin_to_stdout || is_idle_execute);

    g_tee_stdout_dup_stdin = g_options.tee_stdout_dup == STDIN_FILENO || g_flags.tee_conout_dup;
    g_tee_stderr_dup_stdin = g_options.tee_stderr_dup == STDIN_FILENO || g_flags.tee_conout_dup;

    g_enable_child_ctrl_handler = !g_flags.disable_ctrl_signals && !g_flags.disable_ctrl_c_signal;

    // update child show state
    si.wShowWindow = g_options.show_as;

    bool break_ = false;

    // NOTE:
    //  lambda to bypass msvc error: `error C2712: Cannot use __try in functions that require object unwinding`
    //
    [&]() { if_break(true) __try {
        if (g_options.chcp_in) {
            prev_cp_in = GetConsoleCP();
            if (g_options.chcp_in != prev_cp_in) {
                SetConsoleCP(g_options.chcp_in);
            }
        }
        if (g_options.chcp_out) {
            prev_cp_out = GetConsoleOutputCP();
            if (g_options.chcp_out != prev_cp_out) {
                SetConsoleOutputCP(g_options.chcp_out);
            }
        }

        const UINT cp_in = GetConsoleCP();
        const UINT cp_out = GetConsoleOutputCP();

        // reopen std

        if (!ReopenStdin(ret, win_error, cp_in)) {
            break;
        }

        if (break_) break;

        if (!ReopenStdout(ret, win_error, cp_in)) {
            break;
        }

        if (break_) break;

        if (!ReopenStderr(ret, win_error, cp_in)) {
            break;
        }

        if (break_) break;

        // tee std

        if (!CreateTeeOutputFromStdin(ret, win_error, cp_in)) {
            break;
        }

        if (break_) break;

        if (!CreateTeeOutputFromStdout(ret, win_error, cp_in)) {
            break;
        }

        if (break_) break;

        if (!CreateTeeOutputFromStderr(ret, win_error, cp_in)) {
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

        // assign reopened client named pipe as std handle to CRT

        if (!g_options.reopen_stdin_as_client_pipe.empty()) {
            if (_is_valid_handle(g_reopen_stdin_handle)) {
                if (!_set_crt_std_handle(g_reopen_stdin_handle, -1, STDIN_FILENO, _O_BINARY, true, false)) {
                    if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                        win_error = GetLastError();
                    }
                    if (!g_flags.ret_win_error) {
                        ret = err_win32_error;
                    }
                    else {
                        ret = win_error;
                    }
                    if (!g_flags.no_print_gen_error_string) {
                        _print_stderr_message(_T("could not duplicate reopened stdin as client named pipe end before transfer handle ownership to CRT: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                            win_error, win_error, g_options.reopen_stdin_as_server_pipe.c_str());
                    }
                    if (g_flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, g_options.win_error_langid);
                    }
                    break;
                }

                g_is_stdin_reopened = true;
            }
        }

        if (!g_options.reopen_stdout_as_client_pipe.empty()) {
            if (_is_valid_handle(g_reopen_stdout_handle)) {
                if (!_set_crt_std_handle(g_reopen_stdout_handle, -1, STDOUT_FILENO, _O_BINARY, true, false)) {
                    if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                        win_error = GetLastError();
                    }
                    if (!g_flags.ret_win_error) {
                        ret = err_win32_error;
                    }
                    else {
                        ret = win_error;
                    }
                    if (!g_flags.no_print_gen_error_string) {
                        _print_stderr_message(_T("could not duplicate reopened stdout as client named pipe end before transfer handle ownership to CRT: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                            win_error, win_error, g_options.reopen_stdout_as_server_pipe.c_str());
                    }
                    if (g_flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, g_options.win_error_langid);
                    }
                    break;
                }

                g_is_stdout_reopened = true;
            }
        }

        if (!g_options.reopen_stderr_as_client_pipe.empty()) {
            if (_is_valid_handle(g_reopen_stderr_handle)) {
                if (!_set_crt_std_handle(g_reopen_stderr_handle, -1, STDERR_FILENO, _O_BINARY, true, false)) {
                    if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                        win_error = GetLastError();
                    }
                    if (!g_flags.ret_win_error) {
                        ret = err_win32_error;
                    }
                    else {
                        ret = win_error;
                    }
                    if (!g_flags.no_print_gen_error_string) {
                        _print_stderr_message(_T("could not duplicate reopened stderr as client named pipe end before transfer handle ownership to CRT: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                            win_error, win_error, g_options.reopen_stderr_as_server_pipe.c_str());
                    }
                    if (g_flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, g_options.win_error_langid);
                    }
                    break;
                }

                g_is_stderr_reopened = true;
            }
        }

#ifdef _DEBUG
        _debug_print_win32_std_handles(4);
        _debug_print_crt_std_handles(4);
#endif

        // std handles update

        bool no_stdin_inherit = false;
        bool no_stdout_inherit = false;
        bool no_stderr_inherit = false;

        if (g_inherited_console_window) {
            if (!_get_std_handles(ret, win_error, g_stdin_handle, g_stdout_handle, g_stderr_handle, g_flags, g_options)) {
                break;
            }

            // update globals
            g_stdin_handle_type = _get_file_type(g_stdin_handle);
            g_stdout_handle_type = _get_file_type(g_stdout_handle);
            g_stderr_handle_type = _get_file_type(g_stderr_handle);

            no_stdin_inherit = g_no_stdin_inherit || g_stdin_handle_type != FILE_TYPE_CHAR;
            no_stdout_inherit = g_no_stdout_inherit || g_stdout_handle_type != FILE_TYPE_CHAR;
            no_stderr_inherit = g_no_stderr_inherit || g_stderr_handle_type != FILE_TYPE_CHAR;

            // change std handles inheritance

            // CAUTION:
            //  We can not change console handle inheritance under Windows 7.
            //
            //  Details:
            //
            //    `Windows 7 inheritability [win7inh]` : https://github.com/rprichard/win32-console-docs#win7inh
            //
            //      * Calling DuplicateHandle(bInheritHandle=FALSE) on an inheritable console handle (and not console handle too) produces an inheritable handle,
            //        but it should be non-inheritable. Previous and later Windows releases work as expected, as does Windows 7 with a non-console handle.
            //      * Calling SetHandleInformation(dwMask=HANDLE_FLAG_INHERIT) fails on console handles, so the inheritability of an existing console handle cannot be changed.
            //

            // CAUTION:
            //  We have to restore console handle inheritance under Windows XP.
            //
            //  Details:
            //
            //    `Windows XP duplication inheritability [xpinh]` : https://github.com/rprichard/win32-console-docs#xpinh
            //
            //      When CreateProcess in XP duplicates an inheritable handle, the duplicated handle is non-inheritable. In Vista and later, the new handle is also inheritable.
            //

            if (g_stdin_handle_type != FILE_TYPE_CHAR || !is_os_windows_7) { // specific for Windows 7 workaround
                if (no_stdin_inherit) {
                    // CAUTION:
                    //  The DuplicateHandle over a not character device handle fails to disable inheritance under Windows 7.
                    //  We must recheck and reset inheritance here again.
                    //
                    bool reset_stdin_handle_inherit = true;
                    DWORD stdin_handle_flags = 0;

                    if (GetHandleInformation(g_stdin_handle, &stdin_handle_flags) && !(stdin_handle_flags & HANDLE_FLAG_INHERIT)) {
                        reset_stdin_handle_inherit = false;
                    }

                    if (reset_stdin_handle_inherit) {
                        SetLastError(0); // just in case
                        if (!SetHandleInformation(g_stdin_handle, HANDLE_FLAG_INHERIT, FALSE)) {
                            if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                                win_error = GetLastError();
                            }
                            if (!g_flags.ret_win_error) {
                                ret = err_win32_error;
                            }
                            else {
                                ret = win_error;
                            }
                            if (!g_flags.no_print_gen_error_string) {
                                _print_stderr_message(_T("could not disable handle inheritance of stdin: win_error=0x%08X (%d) type=%u file=\"%s\"\n"),
                                    win_error, win_error, g_stdin_handle_type, g_options.reopen_stdin_as_file.c_str());
                            }
                            if (g_flags.print_win_error_string && win_error) {
                                _print_win_error_message(win_error, g_options.win_error_langid);
                            }
                            break;
                        }
                    }
                }
                else {
                    bool reset_stdin_handle_inherit = true;
                    DWORD stdin_handle_flags = 0;

                    if (GetHandleInformation(g_stdin_handle, &stdin_handle_flags) && (stdin_handle_flags & HANDLE_FLAG_INHERIT)) {
                        reset_stdin_handle_inherit = false;
                    }

                    if (reset_stdin_handle_inherit) {
                        SetLastError(0); // just in case
                        if (!SetHandleInformation(g_stdin_handle, HANDLE_FLAG_INHERIT, TRUE)) {
                            if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                                win_error = GetLastError();
                            }
                            if (!g_flags.ret_win_error) {
                                ret = err_win32_error;
                            }
                            else {
                                ret = win_error;
                            }
                            if (!g_flags.no_print_gen_error_string) {
                                _print_stderr_message(_T("could not enable handle inheritance of stdin: win_error=0x%08X (%d) type=%u file=\"%s\"\n"),
                                    win_error, win_error, g_stdin_handle_type, g_options.reopen_stdin_as_file.c_str());
                            }
                            if (g_flags.print_win_error_string && win_error) {
                                _print_win_error_message(win_error, g_options.win_error_langid);
                            }
                            break;
                        }
                    }
                }
            }

            if (g_stdout_handle_type != FILE_TYPE_CHAR || !is_os_windows_7) { // specific for Windows 7 workaround
                if (no_stdout_inherit) {
                    // CAUTION:
                    //  The DuplicateHandle over a not character device handle fails to disable inheritance under Windows 7.
                    //  We must recheck and reset inheritance here again.
                    //
                    bool reset_stdout_handle_inherit = true;
                    DWORD stdout_handle_flags = 0;

                    if (GetHandleInformation(g_stdout_handle, &stdout_handle_flags) && !(stdout_handle_flags & HANDLE_FLAG_INHERIT)) {
                        reset_stdout_handle_inherit = false;
                    }

                    if (reset_stdout_handle_inherit) {
                        SetLastError(0); // just in case
                        if (!SetHandleInformation(g_stdout_handle, HANDLE_FLAG_INHERIT, FALSE)) {
                            if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                                win_error = GetLastError();
                            }
                            if (!g_flags.ret_win_error) {
                                ret = err_win32_error;
                            }
                            else {
                                ret = win_error;
                            }
                            if (!g_flags.no_print_gen_error_string) {
                                _print_stderr_message(_T("could not disable handle inheritance of stdout: win_error=0x%08X (%d) type=%u file=\"%s\"\n"),
                                    win_error, win_error, g_stdout_handle_type, g_options.reopen_stdout_as_file.c_str());
                            }
                            if (g_flags.print_win_error_string && win_error) {
                                _print_win_error_message(win_error, g_options.win_error_langid);
                            }
                            break;
                        }
                    }
                }
                else {
                    bool reset_stdout_handle_inherit = true;
                    DWORD stdout_handle_flags = 0;

                    if (GetHandleInformation(g_stdout_handle, &stdout_handle_flags) && (stdout_handle_flags & HANDLE_FLAG_INHERIT)) {
                        reset_stdout_handle_inherit = false;
                    }

                    if (reset_stdout_handle_inherit) {
                        SetLastError(0); // just in case
                        if (!SetHandleInformation(g_stdout_handle, HANDLE_FLAG_INHERIT, TRUE)) {
                            if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                                win_error = GetLastError();
                            }
                            if (!g_flags.ret_win_error) {
                                ret = err_win32_error;
                            }
                            else {
                                ret = win_error;
                            }
                            if (!g_flags.no_print_gen_error_string) {
                                _print_stderr_message(_T("could not enable handle inheritance of stdout: win_error=0x%08X (%d) type=%u file=\"%s\"\n"),
                                    win_error, win_error, g_stdout_handle_type, g_options.reopen_stdout_as_file.c_str());
                            }
                            if (g_flags.print_win_error_string && win_error) {
                                _print_win_error_message(win_error, g_options.win_error_langid);
                            }
                            break;
                        }
                    }
                }
            }

            if (g_stderr_handle_type != FILE_TYPE_CHAR || !is_os_windows_7) { // specific for Windows 7 workaround
                if (no_stderr_inherit) {
                    // CAUTION:
                    //  The DuplicateHandle over a not character device handle fails to disable inheritance under Windows 7.
                    //  We must recheck and reset inheritance here again.
                    //
                    bool reset_stderr_handle_inherit = true;
                    DWORD stderr_handle_flags = 0;

                    if (GetHandleInformation(g_stderr_handle, &stderr_handle_flags) && !(stderr_handle_flags & HANDLE_FLAG_INHERIT)) {
                        reset_stderr_handle_inherit = false;
                    }

                    if (reset_stderr_handle_inherit) {
                        SetLastError(0); // just in case
                        if (!SetHandleInformation(g_stderr_handle, HANDLE_FLAG_INHERIT, FALSE)) {
                            if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                                win_error = GetLastError();
                            }
                            if (!g_flags.ret_win_error) {
                                ret = err_win32_error;
                            }
                            else {
                                ret = win_error;
                            }
                            if (!g_flags.no_print_gen_error_string) {
                                _print_stderr_message(_T("could not disable handle inheritance of stderr: win_error=0x%08X (%d) type=%u file=\"%s\"\n"),
                                    win_error, win_error, g_stderr_handle_type, g_options.reopen_stderr_as_file.c_str());
                            }
                            if (g_flags.print_win_error_string && win_error) {
                                _print_win_error_message(win_error, g_options.win_error_langid);
                            }
                            break;
                        }
                    }
                }
                else {
                    bool reset_stderr_handle_inherit = true;
                    DWORD stderr_handle_flags = 0;

                    if (GetHandleInformation(g_stderr_handle, &stderr_handle_flags) && (stderr_handle_flags & HANDLE_FLAG_INHERIT)) {
                        reset_stderr_handle_inherit = false;
                    }

                    if (reset_stderr_handle_inherit) {
                        SetLastError(0); // just in case
                        if (!SetHandleInformation(g_stderr_handle, HANDLE_FLAG_INHERIT, TRUE)) {
                            if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                                win_error = GetLastError();
                            }
                            if (!g_flags.ret_win_error) {
                                ret = err_win32_error;
                            }
                            else {
                                ret = win_error;
                            }
                            if (!g_flags.no_print_gen_error_string) {
                                _print_stderr_message(_T("could not enable handle inheritance of stderr: win_error=0x%08X (%d) type=%u file=\"%s\"\n"),
                                    win_error, win_error, g_stderr_handle_type, g_options.reopen_stderr_as_file.c_str());
                            }
                            if (g_flags.print_win_error_string && win_error) {
                                _print_win_error_message(win_error, g_options.win_error_langid);
                            }
                            break;
                        }
                    }
                }
            }

            // std handles dup

            switch (g_options.stdout_dup) {
            case STDERR_FILENO:
                SetLastError(0); // just in case
                if (!DuplicateHandle(GetCurrentProcess(), g_stderr_handle, GetCurrentProcess(), &g_stderr_handle_dup, 0, g_is_stderr_reopened ? FALSE : TRUE, DUPLICATE_SAME_ACCESS)) {
                    if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                        win_error = GetLastError();
                    }
                    if (!g_flags.ret_win_error) {
                        ret = err_win32_error;
                    }
                    else {
                        ret = win_error;
                    }
                    if (!g_flags.no_print_gen_error_string) {
                        _print_stderr_message(_T("could not duplicate stderr into stdout: win_error=0x%08X (%d) type=%u file=\"%s\"\n"),
                            win_error, win_error, g_stderr_handle_type, g_options.tee_stderr_to_file.c_str());
                    }
                    if (g_flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, g_options.win_error_langid);
                    }
                    break_ = true;
                    break;
                }

                if (!_set_crt_std_handle(g_stderr_handle_dup, -1, STDOUT_FILENO, _O_BINARY, false, !g_is_stderr_reopened)) {
                    if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                        win_error = GetLastError();
                    }
                    if (!g_flags.ret_win_error) {
                        ret = err_win32_error;
                    }
                    else {
                        ret = win_error;
                    }
                    if (!g_flags.no_print_gen_error_string) {
                        _print_stderr_message(_T("could not duplicate stderr as stdout before transfer handle ownership to CRT: win_error=0x%08X (%d) type=%u file=\"%s\"\n"),
                            win_error, win_error, g_stderr_handle_type, g_options.reopen_stderr_as_file.c_str());
                    }
                    if (g_flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, g_options.win_error_langid);
                    }
                    break_ = true;
                    break;
                }

                g_stderr_handle_dup = INVALID_HANDLE_VALUE; // ownership is passed to CRT

                // reread owned by CRT handles
                g_stdout_handle = GetStdHandle(STD_OUTPUT_HANDLE);
                g_stdout_handle_type = _get_file_type(g_stdout_handle);

                g_is_stdout_reopened = g_is_stderr_reopened;

                break;
            }

            if (break_) break;

            switch (g_options.stderr_dup) {
            case STDOUT_FILENO:
                SetLastError(0); // just in case
                if (!DuplicateHandle(GetCurrentProcess(), g_stdout_handle, GetCurrentProcess(), &g_stdout_handle_dup, 0, g_is_stdout_reopened ? FALSE : TRUE, DUPLICATE_SAME_ACCESS)) {
                    if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                        win_error = GetLastError();
                    }
                    if (!g_flags.ret_win_error) {
                        ret = err_win32_error;
                    }
                    else {
                        ret = win_error;
                    }
                    if (!g_flags.no_print_gen_error_string) {
                        _print_stderr_message(_T("could not duplicate stdout into stderr: win_error=0x%08X (%d) type=%u file=\"%s\"\n"),
                            win_error, win_error, g_stdout_handle_type, g_options.tee_stdout_to_file.c_str());
                    }
                    if (g_flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, g_options.win_error_langid);
                    }
                    break_ = true;
                    break;
                }

                if (!_set_crt_std_handle(g_stdout_handle_dup, -1, STDERR_FILENO, _O_BINARY, false, !g_is_stdout_reopened)) {
                    if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                        win_error = GetLastError();
                    }
                    if (!g_flags.ret_win_error) {
                        ret = err_win32_error;
                    }
                    else {
                        ret = win_error;
                    }
                    if (!g_flags.no_print_gen_error_string) {
                        _print_stderr_message(_T("could not duplicate stderr as stdout before transfer handle ownership to CRT: win_error=0x%08X (%d) type=%u file=\"%s\"\n"),
                            win_error, win_error, g_stdout_handle_type, g_options.reopen_stdout_as_file.c_str());
                    }
                    if (g_flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, g_options.win_error_langid);
                    }
                    break_ = true;
                    break;
                }

                g_stdout_handle_dup = INVALID_HANDLE_VALUE; // ownership is passed to CRT

                // reread owned by CRT handles
                g_stderr_handle = GetStdHandle(STD_ERROR_HANDLE);
                g_stderr_handle_type = _get_file_type(g_stderr_handle);

                g_is_stderr_reopened = g_is_stdout_reopened;

                break;
            }

            if (break_) break;

#ifdef _DEBUG
            _debug_print_win32_std_handles(5);
            _debug_print_crt_std_handles(5);
#endif
        }

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
            if (g_options.tee_stdin_dup == STDOUT_FILENO) {
                SetLastError(0); // just in case
                if (!DuplicateHandle(GetCurrentProcess(), g_tee_file_stdout_handle, GetCurrentProcess(), &g_tee_file_stdin_handle, 0, FALSE, DUPLICATE_SAME_ACCESS)) {
                    if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                        win_error = GetLastError();
                    }
                    if (!g_flags.ret_win_error) {
                        ret = err_win32_error;
                    }
                    else {
                        ret = win_error;
                    }
                    if (!g_flags.no_print_gen_error_string) {
                        _print_stderr_message(_T("could not duplicate stdout tee as file into stdin tee: win_error=0x%08X (%d) file=\"%s\"\n"),
                            win_error, win_error, g_options.tee_stdout_to_file.c_str());
                    }
                    if (g_flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, g_options.win_error_langid);
                    }
                    break;
                }

                g_has_tee_stdin = true;
            } else if (g_options.tee_stdin_dup == STDERR_FILENO) {
                SetLastError(0); // just in case
                if (!DuplicateHandle(GetCurrentProcess(), g_tee_file_stderr_handle, GetCurrentProcess(), &g_tee_file_stdin_handle, 0, FALSE, DUPLICATE_SAME_ACCESS)) {
                    if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                        win_error = GetLastError();
                    }
                    if (!g_flags.ret_win_error) {
                        ret = err_win32_error;
                    }
                    else {
                        ret = win_error;
                    }
                    if (!g_flags.no_print_gen_error_string) {
                        _print_stderr_message(_T("could not duplicate stderr tee as file into stdin tee: win_error=0x%08X (%d) file=\"%s\"\n"),
                            win_error, win_error, g_options.tee_stderr_to_file.c_str());
                    }
                    if (g_flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, g_options.win_error_langid);
                    }
                    break;
                }

                g_has_tee_stdin = true;
            }
        }

        if (!_is_valid_handle(g_tee_file_stdout_handle)) {
            if (g_tee_stdout_dup_stdin) {
                SetLastError(0); // just in case
                if (!DuplicateHandle(GetCurrentProcess(), g_tee_file_stdin_handle, GetCurrentProcess(), &g_tee_file_stdout_handle, 0, FALSE, DUPLICATE_SAME_ACCESS)) {
                    if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                        win_error = GetLastError();
                    }
                    if (!g_flags.ret_win_error) {
                        ret = err_win32_error;
                    }
                    else {
                        ret = win_error;
                    }
                    if (!g_flags.no_print_gen_error_string) {
                        _print_stderr_message(_T("could not duplicate stdin tee as file into stdout tee: win_error=0x%08X (%d) file=\"%s\"\n"),
                            win_error, win_error, g_options.tee_stdin_to_file.c_str());
                    }
                    if (g_flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, g_options.win_error_langid);
                    }
                    break;
                }

                g_has_tee_stdout = true;
            } else if (g_options.tee_stdout_dup == STDERR_FILENO) {
                SetLastError(0); // just in case
                if (!DuplicateHandle(GetCurrentProcess(), g_tee_file_stderr_handle, GetCurrentProcess(), &g_tee_file_stdout_handle, 0, FALSE, DUPLICATE_SAME_ACCESS)) {
                    if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                        win_error = GetLastError();
                    }
                    if (!g_flags.ret_win_error) {
                        ret = err_win32_error;
                    }
                    else {
                        ret = win_error;
                    }
                    if (!g_flags.no_print_gen_error_string) {
                        _print_stderr_message(_T("could not duplicate stderr tee as file into stdout tee: win_error=0x%08X (%d) file=\"%s\"\n"),
                            win_error, win_error, g_options.tee_stderr_to_file.c_str());
                    }
                    if (g_flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, g_options.win_error_langid);
                    }
                    break;
                }

                g_has_tee_stdout = true;
            }
        }

        if (!_is_valid_handle(g_tee_file_stderr_handle)) {
            if (g_tee_stderr_dup_stdin) {
                SetLastError(0); // just in case
                if (!DuplicateHandle(GetCurrentProcess(), g_tee_file_stdin_handle, GetCurrentProcess(), &g_tee_file_stderr_handle, 0, FALSE, DUPLICATE_SAME_ACCESS)) {
                    if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                        win_error = GetLastError();
                    }
                    if (!g_flags.ret_win_error) {
                        ret = err_win32_error;
                    }
                    else {
                        ret = win_error;
                    }
                    if (!g_flags.no_print_gen_error_string) {
                        _print_stderr_message(_T("could not duplicate stdin tee as file into stderr tee: win_error=0x%08X (%d) file=\"%s\"\n"),
                            win_error, win_error, g_options.tee_stdin_to_file.c_str());
                    }
                    if (g_flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, g_options.win_error_langid);
                    }
                    break;
                }

                g_has_tee_stderr = true;
            } else if (g_options.tee_stderr_dup == STDOUT_FILENO) {
                SetLastError(0); // just in case
                if (!DuplicateHandle(GetCurrentProcess(), g_tee_file_stdout_handle, GetCurrentProcess(), &g_tee_file_stderr_handle, 0, FALSE, DUPLICATE_SAME_ACCESS)) {
                    if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                        win_error = GetLastError();
                    }
                    if (!g_flags.ret_win_error) {
                        ret = err_win32_error;
                    }
                    else {
                        ret = win_error;
                    }
                    if (!g_flags.no_print_gen_error_string) {
                        _print_stderr_message(_T("could not duplicate stdout tee as file into stderr tee: win_error=0x%08X (%d) file=\"%s\"\n"),
                            win_error, win_error, g_options.tee_stdout_to_file.c_str());
                    }
                    if (g_flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, g_options.win_error_langid);
                    }
                    break;
                }

                g_has_tee_stderr = true;
            }
        }

        // tee named pipe handles dup

        if (!_is_valid_handle(g_tee_named_pipe_stdin_handle)) {
            if (g_options.tee_stdin_dup == STDOUT_FILENO) {
                SetLastError(0); // just in case
                if (!DuplicateHandle(GetCurrentProcess(), g_tee_named_pipe_stdout_handle, GetCurrentProcess(), &g_tee_named_pipe_stdin_handle, 0, FALSE, DUPLICATE_SAME_ACCESS)) {
                    if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                        win_error = GetLastError();
                    }
                    if (!g_flags.ret_win_error) {
                        ret = err_win32_error;
                    }
                    else {
                        ret = win_error;
                    }
                    if (!g_flags.no_print_gen_error_string) {
                        if (!g_options.tee_stdout_to_server_pipe.empty()) {
                            _print_stderr_message(_T("could not duplicate stdout tee as server named pipe end into stdin tee: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                                win_error, win_error, g_options.tee_stdout_to_server_pipe.c_str());
                        }
                        else if (!g_options.tee_stdout_to_client_pipe.empty()) {
                            _print_stderr_message(_T("could not duplicate stdout tee as client named pipe end into stdin tee: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                                win_error, win_error, g_options.tee_stdout_to_client_pipe.c_str());
                        }
                    }
                    if (g_flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, g_options.win_error_langid);
                    }
                    break;
                }

                g_has_tee_stdin = true;
            } else if (g_options.tee_stdin_dup == STDERR_FILENO) {
                SetLastError(0); // just in case
                if (!DuplicateHandle(GetCurrentProcess(), g_tee_named_pipe_stderr_handle, GetCurrentProcess(), &g_tee_named_pipe_stdin_handle, 0, FALSE, DUPLICATE_SAME_ACCESS)) {
                    if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                        win_error = GetLastError();
                    }
                    if (!g_flags.ret_win_error) {
                        ret = err_win32_error;
                    }
                    else {
                        ret = win_error;
                    }
                    if (!g_flags.no_print_gen_error_string) {
                        if (!g_options.tee_stderr_to_server_pipe.empty()) {
                            _print_stderr_message(_T("could not duplicate stderr tee as server named pipe end into stdin tee: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                                win_error, win_error, g_options.tee_stderr_to_server_pipe.c_str());
                        }
                        else if (!g_options.tee_stderr_to_client_pipe.empty()) {
                            _print_stderr_message(_T("could not duplicate stderr tee as client named pipe end into stdin tee: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                                win_error, win_error, g_options.tee_stderr_to_client_pipe.c_str());
                        }
                    }
                    if (g_flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, g_options.win_error_langid);
                    }
                    break;
                }

                g_has_tee_stdin = true;
            }
        }

        if (!_is_valid_handle(g_tee_named_pipe_stdout_handle)) {
            if (g_tee_stdout_dup_stdin) {
                SetLastError(0); // just in case
                if (!DuplicateHandle(GetCurrentProcess(), g_tee_named_pipe_stdin_handle, GetCurrentProcess(), &g_tee_named_pipe_stdout_handle, 0, FALSE, DUPLICATE_SAME_ACCESS)) {
                    if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                        win_error = GetLastError();
                    }
                    if (!g_flags.ret_win_error) {
                        ret = err_win32_error;
                    }
                    else {
                        ret = win_error;
                    }
                    if (!g_flags.no_print_gen_error_string) {
                        if (!g_options.tee_stdin_to_server_pipe.empty()) {
                            _print_stderr_message(_T("could not duplicate stdin tee as server named pipe end into stdout tee: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                                win_error, win_error, g_options.tee_stdin_to_server_pipe.c_str());
                        }
                        else if (!g_options.tee_stdin_to_client_pipe.empty()) {
                            _print_stderr_message(_T("could not duplicate stdin tee as client named pipe end into stdout tee: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                                win_error, win_error, g_options.tee_stdin_to_client_pipe.c_str());
                        }
                    }
                    if (g_flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, g_options.win_error_langid);
                    }
                    break;
                }

                g_has_tee_stdout = true;
            } else if (g_options.tee_stdout_dup == STDERR_FILENO) {
                SetLastError(0); // just in case
                if (!DuplicateHandle(GetCurrentProcess(), g_tee_named_pipe_stderr_handle, GetCurrentProcess(), &g_tee_named_pipe_stdout_handle, 0, FALSE, DUPLICATE_SAME_ACCESS)) {
                    if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                        win_error = GetLastError();
                    }
                    if (!g_flags.ret_win_error) {
                        ret = err_win32_error;
                    }
                    else {
                        ret = win_error;
                    }
                    if (!g_flags.no_print_gen_error_string) {
                        if (!g_options.tee_stderr_to_server_pipe.empty()) {
                            _print_stderr_message(_T("could not duplicate stderr tee as server named pipe end into stdout tee: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                                win_error, win_error, g_options.tee_stderr_to_server_pipe.c_str());
                        }
                        else if (!g_options.tee_stderr_to_client_pipe.empty()) {
                            _print_stderr_message(_T("could not duplicate stderr tee as client named pipe end into stdout tee: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                                win_error, win_error, g_options.tee_stderr_to_client_pipe.c_str());
                        }
                    }
                    if (g_flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, g_options.win_error_langid);
                    }
                    break;
                }

                g_has_tee_stdout = true;
            }
        }

        if (!_is_valid_handle(g_tee_named_pipe_stderr_handle)) {
            if (g_tee_stderr_dup_stdin) {
                SetLastError(0); // just in case
                if (!DuplicateHandle(GetCurrentProcess(), g_tee_named_pipe_stdin_handle, GetCurrentProcess(), &g_tee_named_pipe_stderr_handle, 0, FALSE, DUPLICATE_SAME_ACCESS)) {
                    if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                        win_error = GetLastError();
                    }
                    if (!g_flags.ret_win_error) {
                        ret = err_win32_error;
                    }
                    else {
                        ret = win_error;
                    }
                    if (!g_flags.no_print_gen_error_string) {
                        if (!g_options.tee_stdin_to_server_pipe.empty()) {
                            _print_stderr_message(_T("could not duplicate stdin tee as server named pipe end into stderr tee: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                                win_error, win_error, g_options.tee_stdin_to_server_pipe.c_str());
                        }
                        else if (!g_options.tee_stdin_to_client_pipe.empty()) {
                            _print_stderr_message(_T("could not duplicate stdin tee as client named pipe end into stderr tee: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                                win_error, win_error, g_options.tee_stdin_to_client_pipe.c_str());
                        }
                    }
                    if (g_flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, g_options.win_error_langid);
                    }
                    break;
                }

                g_has_tee_stderr = true;
            } else if (g_options.tee_stderr_dup == STDOUT_FILENO) {
                SetLastError(0); // just in case
                if (!DuplicateHandle(GetCurrentProcess(), g_tee_file_stdout_handle, GetCurrentProcess(), &g_tee_file_stderr_handle, 0, FALSE, DUPLICATE_SAME_ACCESS)) {
                    if (g_flags.ret_win_error || g_flags.print_win_error_string || !g_flags.no_print_gen_error_string) {
                        win_error = GetLastError();
                    }
                    if (!g_flags.ret_win_error) {
                        ret = err_win32_error;
                    }
                    else {
                        ret = win_error;
                    }
                    if (!g_flags.no_print_gen_error_string) {
                        if (!g_options.tee_stdout_to_server_pipe.empty()) {
                            _print_stderr_message(_T("could not duplicate stdout tee as server named pipe end into stderr tee: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                                win_error, win_error, g_options.tee_stdout_to_server_pipe.c_str());
                        }
                        else if (!g_options.tee_stdout_to_client_pipe.empty()) {
                            _print_stderr_message(_T("could not duplicate stdout tee as client named pipe end into stderr tee: win_error=0x%08X (%d) pipe=\"%s\"\n"),
                                win_error, win_error, g_options.tee_stdout_to_client_pipe.c_str());
                        }
                    }
                    if (g_flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, g_options.win_error_langid);
                    }
                    break;
                }

                g_has_tee_stderr = true;
            }
        }

        if (!g_pipe_stdin_to_stdout) {
            if (_is_valid_handle(g_stdin_handle)) {
                if (!g_options.create_outbound_server_pipe_from_stdin.empty() || g_pipe_stdin_to_child_stdin || g_stdin_handle_type != FILE_TYPE_CHAR) {
                    if (!CreateOutboundPipeFromConsoleInput(ret, win_error)) {
                        break;
                    }

                    if (g_options.shell_exec_verb.empty()) {
                        si.hStdInput = g_stdin_pipe_read_handle;

                        si.dwFlags |= STARTF_USESTDHANDLES;
                    }
                    else {
                        g_is_stdin_redirected = true;
                        SetStdHandle(STD_INPUT_HANDLE, g_stdin_pipe_read_handle);
                    }
                }
                else if (g_options.shell_exec_verb.empty()) {
                    // CAUTION:
                    //  Must be the original stdin, can not be a buffer from the CreateConsoleScreenBuffer call,
                    //  otherwise, for example, the `cmd.exe /k` process will exit immediately!
                    //
                    si.hStdInput = g_stdin_handle;

                    si.dwFlags |= STARTF_USESTDHANDLES;
                }
            }

            if (_is_valid_handle(g_stdout_handle)) {
                if (!g_options.create_inbound_server_pipe_to_stdout.empty() || g_pipe_child_stdout_to_stdout || g_has_tee_stdout || g_stdout_handle_type != FILE_TYPE_CHAR) {
                    if (!CreateInboundPipeToConsoleOutput<1>(ret, win_error)) {
                        break;
                    }

                    if (g_options.shell_exec_verb.empty()) {
                        si.hStdOutput = g_stdout_pipe_write_handle;

                        si.dwFlags |= STARTF_USESTDHANDLES;
                    }
                    else {
                        g_is_stdout_redirected = true;
                        SetStdHandle(STD_OUTPUT_HANDLE, g_stdout_pipe_write_handle);
                    }
                }
                else if (g_options.shell_exec_verb.empty()) {
                    si.hStdOutput = g_stdout_handle;

                    si.dwFlags |= STARTF_USESTDHANDLES;
                }
            }

            if (_is_valid_handle(g_stderr_handle)) {
                if (!g_options.create_inbound_server_pipe_to_stderr.empty() || g_pipe_child_stderr_to_stderr || g_has_tee_stderr || g_stderr_handle_type != FILE_TYPE_CHAR) {
                    if (!CreateInboundPipeToConsoleOutput<2>(ret, win_error)) {
                        break;
                    }

                    if (g_options.shell_exec_verb.empty()) {
                        si.hStdError = g_stderr_pipe_write_handle;

                        si.dwFlags |= STARTF_USESTDHANDLES;
                    }
                    else {
                        g_is_stderr_redirected = true;
                        SetStdHandle(STD_ERROR_HANDLE, g_stderr_pipe_write_handle);
                    }
                }
                else if (g_options.shell_exec_verb.empty()) {
                    si.hStdError = g_stderr_handle;

                    si.dwFlags |= STARTF_USESTDHANDLES;
                }
            }
        }

        if (g_stdin_handle_type == FILE_TYPE_CHAR) {
            if (g_flags.stdin_echo || g_flags.no_stdin_echo) {
                DWORD stdin_handle_mode = 0;
                GetConsoleMode(g_stdin_handle, &stdin_handle_mode);
                if (g_flags.stdin_echo) {
                    SetConsoleMode(g_stdin_handle, stdin_handle_mode | ENABLE_ECHO_INPUT);
                }
                else {
                    SetConsoleMode(g_stdin_handle, stdin_handle_mode & ~ENABLE_ECHO_INPUT);
                }
            }
        }
        if (g_stdout_handle_type == FILE_TYPE_CHAR) {
            if (g_stdout_vt100) {
                DWORD stdout_handle_mode = 0;
                GetConsoleMode(g_stdout_handle, &stdout_handle_mode);
                SetConsoleMode(g_stdout_handle, stdout_handle_mode | ENABLE_VIRTUAL_TERMINAL_PROCESSING);
            }
        }
        if (g_stderr_handle_type == FILE_TYPE_CHAR) {
            if (g_stderr_vt100) {
                DWORD stderr_handle_mode = 0;
                GetConsoleMode(g_stderr_handle, &stderr_handle_mode);
                SetConsoleMode(g_stderr_handle, stderr_handle_mode | ENABLE_VIRTUAL_TERMINAL_PROCESSING);
            }
        }

        if (g_options.change_current_dir != _T(".")) {
            current_dir = g_options.change_current_dir;
        }
        else {
            current_dir.resize(GetCurrentDirectory(0, NULL));

            if (current_dir.size()) {
                current_dir[0] = _T('\0'); // just in case

                GetCurrentDirectory(current_dir.size(), &current_dir[0]);
            }
        }

        ret = err_none;
        win_error = 0;

        DWORD ret_create_proc = 0;
        const bool do_wait_child = !is_idle_execute && (
            g_flags.pipe_stdin_to_child_stdin || g_flags.pipe_child_stdout_to_stdout || g_flags.pipe_child_stderr_to_stderr ||
            g_has_tee_stdout || g_has_tee_stderr || !g_flags.no_wait);

        // CAUTION:
        //  DO NOT USE `CREATE_NEW_PROCESS_GROUP` flag in the `CreateProcess`, otherwise a child process would ignore all signals.
        //

        // CAUTION:
        //  Windows XP and Windows 8 has issues over standard handles inheritance and duplication.
        //
        //  Details:
        //
        //    Windows XP: `Windows XP does not duplicate a pipe's read handle [xppipe]` : https://github.com/rprichard/win32-console-docs#xppipe
        //    Windows 8:  `Footnotes` : https://github.com/rprichard/win32-console-docs#footnotes
        //

        // CAUTION:
        //  ShellExecute elevation (verb=runas) under already elevated environment and parent process console (re)attachment in the child process involves
        //  standard handles inheritance even if standard handles are not character device and declared as not inheritable (Windows 7 bug).
        //  Workaround that by explicitly assign a null handle address to prevent inheritance into child process.
        //

        if (!is_idle_execute) {
            // CreateProcess/ShellExecute standard handles inheritance issue workaround
            if (no_stdin_inherit) {
                SetStdHandle(STD_INPUT_HANDLE, NULL);
                g_is_stdin_redirected = true;

                g_is_child_stdin_char_type = true;
            }
            if (no_stdout_inherit) {
                SetStdHandle(STD_OUTPUT_HANDLE, NULL);
                g_is_stdout_redirected = true;
            }
            if (no_stderr_inherit) {
                SetStdHandle(STD_ERROR_HANDLE, NULL);
                g_is_stderr_redirected = true;
            }

            if_break (app && app_len) {
                if (g_enable_child_ctrl_handler) {
                    g_ctrl_handler = true;
                    SetConsoleCtrlHandler(ChildCtrlHandler, TRUE);   // update console signal handler
                }

                if (g_options.shell_exec_verb.empty()) {
#ifdef _DEBUG
                    _print_raw_message_impl(0, STDOUT_FILENO, "---\n");
                    _print_raw_message_impl(0, STDERR_FILENO, "---\n");
#endif

                    if (si.dwFlags & STARTF_USESTDHANDLES) {
                        if (_is_valid_handle(si.hStdInput)) {
                            if (_get_file_type(si.hStdInput) == FILE_TYPE_CHAR) {
                                g_is_child_stdin_char_type = true;
                            }
                        }
                        else {
                            g_is_child_stdin_char_type = true;
                        }
                    }
                    else if (g_stdin_handle_type == FILE_TYPE_CHAR || !_is_valid_handle(g_stdin_handle)) {
                        g_is_child_stdin_char_type = true;
                    }

                    if (cmd && cmd_len) {
                        // CAUTION:
                        //  cmd argument must be writable!
                        //
                        cmd_buf.resize((std::max)(cmd_len + sizeof(TCHAR), size_t(32768U)));
                        memcpy(cmd_buf.data(), cmd, cmd_buf.size());

                        SetLastError(0); // just in case
                        ret_create_proc = CreateProcess(app, (TCHAR *)cmd_buf.data(), NULL, NULL,
                            TRUE, // must be always TRUE because there can be any arbitrary handle
                            (g_flags.detach_child_console ? DETACHED_PROCESS : 0) |
                                (g_flags.create_child_console ? CREATE_NEW_CONSOLE : 0) |
                                (g_flags.no_window_console ? CREATE_NO_WINDOW : 0),
                            NULL,
                            !current_dir.empty() ? current_dir.c_str() : NULL,
                            &si, &pi);

                        win_error = GetLastError();
                    }
                    else {
                        SetLastError(0); // just in case
                        ret_create_proc = CreateProcess(app, NULL, NULL, NULL,
                            TRUE, // must be always TRUE because there can be any arbitrary handle
                            (g_flags.detach_child_console ? DETACHED_PROCESS : 0) |
                                (g_flags.create_child_console ? CREATE_NEW_CONSOLE : 0) |
                                (g_flags.no_window_console ? CREATE_NO_WINDOW : 0),
                            NULL,
                            !current_dir.empty() ? current_dir.c_str() : NULL,
                            &si, &pi);

                        win_error = GetLastError();
                    }
                }
                else {
                    sei.cbSize = sizeof(sei);
                    sei.fMask = SEE_MASK_NOCLOSEPROCESS; // use hProcess
                    if (g_flags.wait_child_start && do_wait_child) {
                        sei.fMask |= SEE_MASK_NOASYNC | SEE_MASK_FLAG_DDEWAIT;
                    }
                    if (g_flags.shell_exec_expand_env) {
                        sei.fMask |= SEE_MASK_DOENVSUBST;
                    }
                    if (g_flags.no_sys_dialog_ui) {
                        sei.fMask |= SEE_MASK_FLAG_NO_UI;
                    }
                    if (!g_flags.create_child_console && !g_flags.no_window_console) {
                        sei.fMask |= SEE_MASK_NO_CONSOLE;
                    }
                    if (!do_wait_child) {
                        sei.fMask |= SEE_MASK_ASYNCOK;
                    }

                    if (!g_options.shell_exec_verb.empty()) {
                        shell_exec_verb.resize(g_options.shell_exec_verb.length() + 1);
                        memcpy(shell_exec_verb.data(), g_options.shell_exec_verb.c_str(), shell_exec_verb.size() * sizeof(shell_exec_verb[0]));
                        sei.lpVerb = &shell_exec_verb[0];
                    }

                    sei.lpFile = app;
                    sei.lpParameters = cmd;
                    sei.lpDirectory = !current_dir.empty() ? current_dir.c_str() : NULL;
                    sei.nShow = g_options.show_as;

                    if (g_stdin_handle_type == FILE_TYPE_CHAR || !_is_valid_handle(g_stdin_handle)) {
                        g_is_child_stdin_char_type = true;
                    }

#ifdef _DEBUG
                    if (g_is_stdin_redirected || g_is_stdout_redirected || g_is_stderr_redirected) {
                        _debug_print_win32_std_handles(6);
                        _debug_print_crt_std_handles(6);
                    }

                    _print_raw_message_impl(0, STDOUT_FILENO, "---\n");
                    _print_raw_message_impl(0, STDERR_FILENO, "---\n");
#endif

                    if (g_flags.init_com) {
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
                }
            }
            else if (cmd && cmd_len) {
#ifdef _DEBUG
                _print_raw_message_impl(0, STDOUT_FILENO, "---\n");
                _print_raw_message_impl(0, STDERR_FILENO, "---\n");
#endif

                if (si.dwFlags & STARTF_USESTDHANDLES) {
                    if (_is_valid_handle(si.hStdInput)) {
                        if (_get_file_type(si.hStdInput) == FILE_TYPE_CHAR) {
                            g_is_child_stdin_char_type = true;
                        }
                    }
                    else {
                        g_is_child_stdin_char_type = true;
                    }
                }
                else if (g_stdin_handle_type == FILE_TYPE_CHAR || !_is_valid_handle(g_stdin_handle)) {
                    g_is_child_stdin_char_type = true;
                }

                if (g_enable_child_ctrl_handler) {
                    g_ctrl_handler = true;
                    SetConsoleCtrlHandler(ChildCtrlHandler, TRUE);   // update console signal handler
                }

                cmd_buf.resize((std::max)(cmd_len + sizeof(TCHAR), size_t(32768U)));
                memcpy(cmd_buf.data(), cmd, cmd_buf.size());

                SetLastError(0); // just in case
                ret_create_proc = CreateProcess(NULL, (TCHAR *)cmd_buf.data(), NULL, NULL,
                    TRUE, // must be always TRUE because there can be any arbitrary handle
                    (g_flags.detach_child_console ? DETACHED_PROCESS : 0) |
                        (g_flags.create_child_console ? CREATE_NEW_CONSOLE : 0) |
                        (g_flags.no_window_console ? CREATE_NO_WINDOW : 0),
                    NULL,
                    !current_dir.empty() ? current_dir.c_str() : NULL,
                    &si, &pi);

                win_error = GetLastError();
            }

            if (_is_valid_handle(pi.hProcess)) {
                g_child_process_handle = pi.hProcess;       // to check the process status from stream pipe threads
                g_child_process_group_id = pi.dwProcessId;  // to pass parent console signal events into child process
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
#ifdef _DEBUG
        else {
            _print_raw_message_impl(0, STDOUT_FILENO, "---\n");
            _print_raw_message_impl(0, STDERR_FILENO, "---\n");
        }
#endif


        const bool is_child_executed = !is_idle_execute && ret_create_proc && _is_valid_handle(g_child_process_handle);

        if (!is_idle_execute) {
            if (is_child_executed) {
                g_is_process_executed = true;
            }
            else {
                if (!g_flags.no_print_gen_error_string) {
                    if (g_options.shell_exec_verb.empty()) {
                        _print_stderr_message(_T("could not create child process: win_error=0x%08X (%d) app=\"%s\" cmd=\"%s\"\n"),
                            win_error, win_error, app, cmd_buf.size() ? (TCHAR *)cmd_buf.data() : _T(""));
                    }
                    else {
                        _print_stderr_message(_T("could not shell execute child process: win_error=0x%08X (%d) shell_error=0x%08X (%d) file=\"%s\" params=\"%s\"\n"),
                            win_error, win_error, shell_error, shell_error, app, cmd);
                    }
                }

                if (g_flags.print_win_error_string && win_error) {
                    _print_win_error_message(win_error, g_options.win_error_langid);
                }

                if (g_flags.print_shell_error_string && shell_error != -1 && shell_error <= 32) {
                    _print_shell_exec_error_message(shell_error, sei);
                }
            }

            if (g_flags.ret_create_proc) {
                ret = ret_create_proc;
            }
            else if (g_flags.ret_win_error) {
                ret = win_error;
            }
            else if (!is_child_executed) {
                ret = err_win32_error;
            }
        }
        else {
            g_is_process_executed = true; // nop execution is a success
        }

        // CAUTION:
        //  We must always close all handles prepared for a child process even if they are not inheritable or a child process is not executed,
        //  otherwise the `ReadFile` in the parent process will be blocked on the pipe end
        //  even if a child process is closed.
        //

        _close_handle(g_stdin_pipe_read_handle);
        _close_handle(g_stdout_pipe_write_handle);
        _close_handle(g_stderr_pipe_write_handle);

        if (g_is_process_executed) {
            if (!g_pipe_stdin_to_stdout) {
                if (_is_valid_handle(g_stdin_handle) && (g_has_tee_stdin || _is_valid_handle(g_stdin_pipe_write_handle))) {
                    g_stream_pipe_thread_locals[0].thread_handle = CreateThread(
                        NULL, 0,
                        StreamPipeThread<0>, &g_stream_pipe_thread_locals[0].thread_data,
                        0,
                        &g_stream_pipe_thread_locals[0].thread_id
                    );
                }

                if (_is_valid_handle(g_stdout_pipe_read_handle) && (g_has_tee_stdout || _is_valid_handle(g_stdout_handle))) {
                    g_stream_pipe_thread_locals[1].thread_handle = CreateThread(
                        NULL, 0,
                        StreamPipeThread<1>, &g_stream_pipe_thread_locals[1].thread_data,
                        0,
                        &g_stream_pipe_thread_locals[1].thread_id
                    );
                }

                if (_is_valid_handle(g_stderr_pipe_read_handle) && (g_has_tee_stderr || _is_valid_handle(g_stderr_handle))) {
                    g_stream_pipe_thread_locals[2].thread_handle = CreateThread(
                        NULL, 0,
                        StreamPipeThread<2>, &g_stream_pipe_thread_locals[2].thread_data,
                        0,
                        &g_stream_pipe_thread_locals[2].thread_id
                    );
                }
            }
            else {
                if (_is_valid_handle(g_stdin_handle) && _is_valid_handle(g_stdout_handle) && (g_stdin_handle_type == FILE_TYPE_DISK || g_stdin_handle_type == FILE_TYPE_PIPE)) {
                    g_stdin_to_stdout_thread_locals.thread_handle = CreateThread(
                        NULL, 0,
                        StdinToStdoutThread, &g_stdin_to_stdout_thread_locals.thread_data,
                        0,
                        &g_stdin_to_stdout_thread_locals.thread_id);
                }
            }
        }
        else {
            // Cancel all server pipe connections before continue if not done yet.
            //

            {
                auto & connect_server_named_pipe_thread_locals = g_connect_bound_server_named_pipe_tofrom_conin_thread_locals;

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
        }

        if (is_child_executed && do_wait_child) {
            WaitForSingleObject(g_child_process_handle, INFINITE);

            if (g_flags.ret_child_exit) {
                // read child process return code
                DWORD exit_code = 0;
                SetLastError(0); // just in case
                if (GetExitCodeProcess(g_child_process_handle, &exit_code)) {
                    ret = exit_code;
                }
                else {
                    ret = err_win32_error;
                    win_error = GetLastError();
                    if (!g_flags.no_print_gen_error_string) {
                        _print_stderr_message(_T("could not get child process exit code: win_error=0x%08X (%u)\n"),
                            win_error, win_error);
                    }
                    if (g_flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, g_options.win_error_langid);
                    }
                    break;
                }
            }
        }

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

            // Cancel all server pipe connections before continue if not done yet.
            //

            {
                auto & connect_server_named_pipe_thread_locals = g_connect_bound_server_named_pipe_tofrom_conin_thread_locals;

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

            // print all registered messages
            if (!g_worker_threads_return_data.datas.empty()) {
                bool is_ret_updated = false;
                for (const auto & ret_data : g_worker_threads_return_data.datas) {
                    if (!g_flags.ret_create_proc && !g_flags.ret_child_exit) {
                        // return the first error code
                        if (!ret && !is_ret_updated && ret_data.is_error) {
                            if (!g_flags.ret_win_error) {
                                ret = ret_data.ret;
                            }
                            else {
                                ret = ret_data.win_error;
                            }
                            is_ret_updated = true;
                        }
                    }

                    if (!ret_data.is_error) {
                        _put_raw_message(STDOUT_FILENO, ret_data.msg);
                    }
                    else {
                        _put_raw_message(STDERR_FILENO, ret_data.msg);
                    }
                }
            }

            // close shared resources at first
            if (g_options.chcp_in && g_options.chcp_in != prev_cp_in) {
                SetConsoleCP(prev_cp_in);
            }
            if (g_options.chcp_out && g_options.chcp_out != prev_cp_out) {
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
            if (_is_valid_handle(g_tee_named_pipe_stdin_handle) && !g_options.tee_stdin_to_server_pipe.empty()) {
                CancelIo(g_tee_named_pipe_stdin_handle);
                DisconnectNamedPipe(g_tee_named_pipe_stdin_handle);
            }
            _close_handle(g_tee_named_pipe_stdin_handle);

            if (_is_valid_handle(g_tee_named_pipe_stdout_handle) && !g_options.tee_stdout_to_server_pipe.empty()) {
                CancelIo(g_tee_named_pipe_stdout_handle);
                DisconnectNamedPipe(g_tee_named_pipe_stdout_handle);
            }
            _close_handle(g_tee_named_pipe_stdout_handle);

            if (_is_valid_handle(g_tee_named_pipe_stderr_handle) && !g_options.tee_stderr_to_server_pipe.empty()) {
                CancelIo(g_tee_named_pipe_stderr_handle);
                DisconnectNamedPipe(g_tee_named_pipe_stderr_handle);
            }
            _close_handle(g_tee_named_pipe_stderr_handle);

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
            if (_is_valid_handle(g_stdin_pipe_write_handle) && !g_options.create_outbound_server_pipe_from_stdin.empty()) {
                CancelIo(g_stdin_pipe_write_handle);
                DisconnectNamedPipe(g_stdin_pipe_write_handle);
            }
            _close_handle(g_stdin_pipe_write_handle);
            _close_handle(g_stdin_pipe_read_handle);

            if (_is_valid_handle(g_stdout_pipe_read_handle) && !g_options.create_inbound_server_pipe_to_stdout.empty()) {
                CancelIo(g_stdout_pipe_read_handle);
                DisconnectNamedPipe(g_stdout_pipe_read_handle);
            }
            _close_handle(g_stdout_pipe_read_handle);
            _close_handle(g_stdout_pipe_write_handle);

            if (_is_valid_handle(g_stderr_pipe_read_handle) && !g_options.create_inbound_server_pipe_to_stderr.empty()) {
                CancelIo(g_stderr_pipe_read_handle);
                DisconnectNamedPipe(g_stderr_pipe_read_handle);
            }
            _close_handle(g_stderr_pipe_read_handle);
            _close_handle(g_stderr_pipe_write_handle);

            // in backward order from threads to a process
            _close_handle(pi.hThread);
            _close_handle(g_child_process_handle, pi.hProcess);

            // close mutexes
            HANDLE reopen_stdout_mutex = g_reopen_stdout_mutex;
            HANDLE reopen_stderr_mutex = g_reopen_stderr_mutex;

            _close_handle(g_reopen_stdout_mutex);
            if (reopen_stdout_mutex != reopen_stderr_mutex) {
                _close_handle(g_reopen_stderr_mutex);
            }
            else {
                g_reopen_stderr_mutex = INVALID_HANDLE_VALUE;
            }

            HANDLE tee_file_stdin_mutex = g_tee_file_stdin_mutex;
            HANDLE tee_file_stdout_mutex = g_tee_file_stdout_mutex;
            HANDLE tee_file_stderr_mutex = g_tee_file_stderr_mutex;

            _close_handle(g_tee_file_stdin_mutex);
            if (tee_file_stdin_mutex != tee_file_stdout_mutex) {
                _close_handle(g_tee_file_stdout_mutex);
            }
            else {
                g_tee_file_stdout_mutex = INVALID_HANDLE_VALUE;
            }
            if (tee_file_stdin_mutex != tee_file_stderr_mutex && tee_file_stdout_mutex != tee_file_stderr_mutex) {
                _close_handle(g_tee_file_stderr_mutex);
            }
            else {
                g_tee_file_stderr_mutex = INVALID_HANDLE_VALUE;
            }
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

void SubstOptionsPlaceholders(Options & options)
{
    if (!options.reopen_stdin_as_server_pipe.empty()) {
        options.reopen_stdin_as_server_pipe = SubstNamePlaceholders(options.reopen_stdin_as_server_pipe);
    }
    if (!options.reopen_stdin_as_client_pipe.empty()) {
        options.reopen_stdin_as_client_pipe = SubstNamePlaceholders(options.reopen_stdin_as_client_pipe);
    }
    if (!options.reopen_stdout_as_server_pipe.empty()) {
        options.reopen_stdout_as_server_pipe = SubstNamePlaceholders(options.reopen_stdout_as_server_pipe);
    }
    if (!options.reopen_stdout_as_client_pipe.empty()) {
        options.reopen_stdout_as_client_pipe = SubstNamePlaceholders(options.reopen_stdout_as_client_pipe);
    }
    if (!options.reopen_stderr_as_client_pipe.empty()) {
        options.reopen_stderr_as_client_pipe = SubstNamePlaceholders(options.reopen_stderr_as_client_pipe);
    }
    if (!options.create_outbound_server_pipe_from_stdin.empty()) {
        options.create_outbound_server_pipe_from_stdin = SubstNamePlaceholders(options.create_outbound_server_pipe_from_stdin);
    }
    if (!options.create_inbound_server_pipe_to_stdout.empty()) {
        options.create_inbound_server_pipe_to_stdout = SubstNamePlaceholders(options.create_inbound_server_pipe_to_stdout);
    }
    if (!options.create_inbound_server_pipe_to_stderr.empty()) {
        options.create_inbound_server_pipe_to_stderr = SubstNamePlaceholders(options.create_inbound_server_pipe_to_stderr);
    }
    if (!options.tee_stdin_to_server_pipe.empty()) {
        options.tee_stdin_to_server_pipe = SubstNamePlaceholders(options.tee_stdin_to_server_pipe);
    }
    if (!options.tee_stdin_to_client_pipe.empty()) {
        options.tee_stdin_to_client_pipe = SubstNamePlaceholders(options.tee_stdin_to_client_pipe);
    }
    if (!options.tee_stdout_to_server_pipe.empty()) {
        options.tee_stdout_to_server_pipe = SubstNamePlaceholders(options.tee_stdout_to_server_pipe);
    }
    if (!options.tee_stdout_to_client_pipe.empty()) {
        options.tee_stdout_to_client_pipe = SubstNamePlaceholders(options.tee_stdout_to_client_pipe);
    }
    if (!options.tee_stderr_to_server_pipe.empty()) {
        options.tee_stderr_to_server_pipe = SubstNamePlaceholders(options.tee_stderr_to_server_pipe);
    }
    if (!options.tee_stderr_to_client_pipe.empty()) {
        options.tee_stderr_to_client_pipe = SubstNamePlaceholders(options.tee_stderr_to_client_pipe);
    }
}

void TranslateCommandLineToElevated(const std::tstring * app_str_ptr, const std::tstring * cmd_str_ptr, std::tstring * cmd_out_str_ptr,
                                    Flags & regular_flags, Options & regular_options,
                                    const Flags & elevate_child_flags, const Options & elevate_child_options,
                                    const Flags & promote_child_flags, const Options & promote_child_options)
{
    std::tstring options_line;
    std::tstring cmd_line;

    std::tstring tmp_str;

    if (cmd_out_str_ptr) {
        if (app_str_ptr && !app_str_ptr->empty()) {
            cmd_line = std::tstring{ _T("\"") } + _replace_strings(*app_str_ptr, _T("\""), std::tstring{ _T("\\\"") }) + _T("\" ");
        }
        else {
            cmd_line = _T("\"\" ");
        }

        if (cmd_str_ptr && !cmd_str_ptr->empty()) {
            cmd_line += std::tstring{ _T("\"") } + _replace_strings(*cmd_str_ptr, _T("\""), std::tstring{ _T("\\\"") }) + _T("\"");
        }
        else {
            cmd_line += _T("\"\"");
        }
    }

    Flags child_flags = regular_flags;
    Options child_options = regular_options;

    if (g_is_process_elevating) { // just in case
        child_flags.merge(elevate_child_flags);
        child_options.merge(elevate_child_options);
    }

    child_flags.merge(promote_child_flags);
    child_options.merge(promote_child_options);

    // NOTE:
    //  Always apply language features for both processes.
    //

    if (child_options.chcp_in) {
        if (cmd_out_str_ptr) {
            options_line += std::tstring{ _T("/chcp-in ") } + std::to_tstring(child_options.chcp_in) + _T(" ");
        }
    }

    if (child_options.chcp_out) {
        if (cmd_out_str_ptr) {
            options_line += std::tstring{ _T("/chcp-out ") } + std::to_tstring(child_options.chcp_out) + _T(" ");
        }
    }

    if (child_flags.ret_create_proc) {
        if (cmd_out_str_ptr) {
            options_line += _T("/ret-create-proc ");
        }
    }
    regular_flags.ret_create_proc = false; // always reset

    if (child_flags.ret_win_error) {
        if (cmd_out_str_ptr) {
            options_line += _T("/ret-win-error ");
        }
    }
    regular_flags.ret_win_error = false; // always reset

    if (child_options.win_error_langid) {
        if (cmd_out_str_ptr) {
            options_line += std::tstring{ _T("/win-error-langid ") } + std::to_tstring(child_options.win_error_langid) + _T(" ");
        }
    }

    if (child_flags.ret_child_exit) {
        if (cmd_out_str_ptr) {
            options_line += _T("/ret-child-exit ");
        }
    }
    regular_flags.ret_child_exit = true; // always return elevated child exit code

    if (child_flags.print_win_error_string) {
        if (cmd_out_str_ptr) {
            options_line += _T("/print-win-error-string /print-shell-error-string "); // always print shell error if win32 error is flagged
        }
    }
    regular_flags.print_win_error_string = false; // always reset

    if (child_flags.no_print_gen_error_string) {
        if (cmd_out_str_ptr) {
            options_line += _T("/no-print-gen-error-string ");
        }
    }
    regular_flags.no_print_gen_error_string = false; // always reset

    if (child_flags.no_sys_dialog_ui) {
        if (cmd_out_str_ptr) {
            options_line += _T("/no-sys-dialog-ui ");
        }
    }
    regular_flags.no_sys_dialog_ui = false; // always reset

    if (child_flags.pause_on_exit_if_error_before_exec) {
        if (cmd_out_str_ptr) {
            options_line += _T("/pause-on-exit-if-error-before-exec ");
        }
    }
    regular_flags.pause_on_exit_if_error_before_exec = false; // always reset

    if (child_flags.pause_on_exit_if_error) {
        if (cmd_out_str_ptr) {
            options_line += _T("/pause-on-exit-if-error ");
        }
    }
    regular_flags.pause_on_exit_if_error = false; // always reset

    if (child_flags.pause_on_exit) {
        if (cmd_out_str_ptr) {
            options_line += _T("/pause-on-exit ");
        }
    }
    regular_flags.pause_on_exit = false; // always reset

    if (!child_options.shell_exec_verb.empty()) {
        if (cmd_out_str_ptr) {
            options_line += std::tstring{ _T("/shell-exec \"") } + child_options.shell_exec_verb + _T("\" ");
        }
    }
    regular_options.shell_exec_verb.clear(); // always reset

    if (child_flags.shell_exec_expand_env) {
        if (cmd_out_str_ptr) {
            options_line += _T("/shell-exec-expand-env ");
        }
    }
    regular_flags.shell_exec_expand_env = false; // always reset


    //change_current_dir


    if (child_flags.no_wait) {
        if (cmd_out_str_ptr) {
            options_line += _T("/no-wait ");
        }
    }
    regular_flags.no_wait = false; // always reset

    if (child_flags.no_window) {
        if (cmd_out_str_ptr) {
            options_line += _T("/no-window ");
        }
    }
    regular_flags.no_window = false; // always reset

    if (child_flags.no_window_console) {
        if (cmd_out_str_ptr) {
            options_line += _T("/no-window-console ");
        }
    }
    regular_flags.no_window_console = false; // always reset

    if (child_flags.detach_console) {
        if (cmd_out_str_ptr) {
            options_line += _T("/detach-console ");
        }
    }
    regular_flags.detach_console = false; // always reset


    if (child_flags.no_expand_env) {
        if (cmd_out_str_ptr) {
            options_line += _T("/no-expand-env ");
        }
    }
    regular_flags.no_expand_env = false; // always disable expansion for the parent process

    // always disable substitution for a child process
    if (cmd_out_str_ptr) {
        options_line += _T("/no-subst-vars ");
    }

    if (child_flags.no_subst_empty_tail_vars) {
        if (cmd_out_str_ptr) {
            options_line += _T("/no-subst-empty-tail-vars ");
        }
    }
    regular_flags.no_subst_empty_tail_vars = false; // always reset

    if (child_flags.no_std_inherit) {
        if (cmd_out_str_ptr) {
            options_line += _T("/no-std-inherit ");
        }
    }
    regular_flags.no_std_inherit = false; // always reset

    if (child_flags.no_stdin_inherit) {
        if (cmd_out_str_ptr) {
            options_line += _T("/no-stdin-inherit ");
        }
    }
    regular_flags.no_stdin_inherit = false; // always reset

    if (child_flags.no_stdout_inherit) {
        if (cmd_out_str_ptr) {
            options_line += _T("/no-stdout-inherit ");
        }
    }
    regular_flags.no_stdout_inherit = false; // always reset

    if (child_flags.no_stderr_inherit) {
        if (cmd_out_str_ptr) {
            options_line += _T("/no-stderr-inherit ");
        }
    }
    regular_flags.no_stderr_inherit = false; // always reset


    if (child_flags.allow_throw_seh_except) {
        if (cmd_out_str_ptr) {
            options_line += _T("/allow-throw-seh-except ");
        }
    }
    regular_flags.allow_throw_seh_except = false; // always reset

    if (child_flags.allow_expand_unexisted_env) {
        if (cmd_out_str_ptr) {
            options_line += _T("/allow-expand-unexisted-env ");
        }
    }
    regular_flags.allow_expand_unexisted_env = false; // always reset

    //allow_subst_empty_args

    //load_parent_proc_init_env_vars

    if (child_flags.pipe_stdin_to_child_stdin) {
        if (cmd_out_str_ptr) {
            options_line += _T("/pipe-stdin-to-child-stdin ");
        }
    }
    regular_flags.pipe_stdin_to_child_stdin = false; // always reset

    if (child_flags.pipe_child_stdout_to_stdout) {
        if (cmd_out_str_ptr) {
            options_line += _T("/pipe-child-stdout-to-stdout ");
        }
    }
    regular_flags.pipe_child_stdout_to_stdout = false; // always reset

    if (child_flags.pipe_child_stderr_to_stderr) {
        if (cmd_out_str_ptr) {
            options_line += _T("/pipe-child-stderr-to-stderr ");
        }
    }
    regular_flags.pipe_child_stderr_to_stderr = false; // always reset

    if (child_flags.pipe_inout_child) {
        if (cmd_out_str_ptr) {
            options_line += _T("/pipe-inout-child ");
        }
    }
    regular_flags.pipe_inout_child = false; // always reset

    if (child_flags.pipe_out_child) {
        if (cmd_out_str_ptr) {
            options_line += _T("/pipe-out-child ");
        }
    }
    regular_flags.pipe_out_child = false; // always reset

    if (child_flags.pipe_stdin_to_stdout) {
        if (cmd_out_str_ptr) {
            options_line += _T("/pipe-stdin-to-stdout ");
        }
    }
    regular_flags.pipe_stdin_to_stdout = false; // always reset

    if (child_flags.init_com) {
        if (cmd_out_str_ptr) {
            options_line += _T("/init-com ");
        }
    }
    regular_flags.init_com = false; // always reset

    if (child_flags.wait_child_start) {
        if (cmd_out_str_ptr) {
            options_line += _T("/wait-child-start ");
        }
    }
    regular_flags.wait_child_start = false; // always reset

    //child_flags.elevate

    if (child_options.show_as != SW_SHOWNORMAL) {
        if (cmd_out_str_ptr) {
            options_line += std::tstring{ _T("/showas ") } + std::to_tstring(child_options.show_as);
        }
    }
    regular_options.show_as = SW_SHOWNORMAL; // always reset


    if (!child_options.reopen_stdin_as_file.empty()) {
        if (cmd_out_str_ptr) {
            tmp_str = _replace_strings(child_options.reopen_stdin_as_file, _T("\\"), std::tstring{ _T("\\\\") });

            options_line += std::tstring{ _T("/reopen-stdin ") } + std::tstring{ _T("\"") } + _replace_strings(tmp_str, _T("\""), std::tstring{ _T("\\\"") }) + _T("\" ");
        }
    }
    regular_options.reopen_stdin_as_file.clear(); // always reset

    if (!child_options.reopen_stdout_as_file.empty()) {
        if (cmd_out_str_ptr) {
            tmp_str = _replace_strings(child_options.reopen_stdout_as_file, _T("\\"), std::tstring{ _T("\\\\") });

            options_line += std::tstring{ _T("/reopen-stdout ") } + std::tstring{ _T("\"") } + _replace_strings(tmp_str, _T("\""), std::tstring{ _T("\\\"") }) + _T("\" ");
        }
    }
    regular_options.reopen_stdout_as_file.clear(); // always reset

    if (!child_options.reopen_stderr_as_file.empty()) {
        if (cmd_out_str_ptr) {
            tmp_str = _replace_strings(child_options.reopen_stderr_as_file, _T("\\"), std::tstring{ _T("\\\\") });

            options_line += std::tstring{ _T("/reopen-stderr ") } + std::tstring{ _T("\"") } + _replace_strings(tmp_str, _T("\""), std::tstring{ _T("\\\"") }) + _T("\" ");
        }
    }
    regular_options.reopen_stderr_as_file.clear(); // always reset


    if (!child_options.reopen_stdin_as_server_pipe.empty()) {
        if (cmd_out_str_ptr) {
            tmp_str = _replace_strings(child_options.reopen_stdin_as_server_pipe, _T("\\"), std::tstring{ _T("\\\\") });

            options_line += std::tstring{ _T("/reopen-stdin-as-server-pipe ") } + std::tstring{ _T("\"") } + _replace_strings(tmp_str, _T("\""), std::tstring{ _T("\\\"") }) + _T("\" ");
        }
    }
    regular_options.reopen_stdin_as_server_pipe.clear(); // always reset

    if (child_options.reopen_stdin_as_server_pipe_connect_timeout_ms && child_options.reopen_stdin_as_server_pipe_connect_timeout_ms != DEFAULT_SERVER_NAMED_PIPE_CONNECT_TIMEOUT_MS) {
        if (cmd_out_str_ptr) {
            options_line += std::tstring{ _T("/reopen-stdin-as-server-pipe-connect-timeout ") } + std::to_tstring(child_options.reopen_stdin_as_server_pipe_connect_timeout_ms) + _T(" ");
        }
    }
    regular_options.reopen_stdin_as_server_pipe_connect_timeout_ms = 0; // always reset

    if (child_options.reopen_stdin_as_server_pipe_in_buf_size && child_options.reopen_stdin_as_server_pipe_in_buf_size != DEFAULT_NAMED_PIPE_IN_BUF_SIZE) {
        if (cmd_out_str_ptr) {
            options_line += std::tstring{ _T("/reopen-stdin-as-server-pipe-in-buf-size ") } + std::to_tstring(child_options.reopen_stdin_as_server_pipe_in_buf_size) + _T(" ");
        }
    }
    regular_options.reopen_stdin_as_server_pipe_in_buf_size = 0; // always reset

    if (child_options.reopen_stdin_as_server_pipe_out_buf_size && child_options.reopen_stdin_as_server_pipe_out_buf_size != DEFAULT_NAMED_PIPE_OUT_BUF_SIZE) {
        if (cmd_out_str_ptr) {
            options_line += std::tstring{ _T("/reopen-stdin-as-server-pipe-out-buf-size ") } + std::to_tstring(child_options.reopen_stdin_as_server_pipe_out_buf_size) + _T(" ");
        }
    }
    regular_options.reopen_stdin_as_server_pipe_out_buf_size = 0; // always reset

    if (!child_options.reopen_stdin_as_client_pipe.empty()) {
        if (cmd_out_str_ptr) {
            tmp_str = _replace_strings(child_options.reopen_stdin_as_client_pipe, _T("\\"), std::tstring{ _T("\\\\") });

            options_line += std::tstring{ _T("/reopen-stdin-as-client-pipe ") } + std::tstring{ _T("\"") } + _replace_strings(tmp_str, _T("\""), std::tstring{ _T("\\\"") }) + _T("\" ");
        }
    }
    regular_options.reopen_stdin_as_client_pipe.clear(); // always reset

    if (child_options.reopen_stdin_as_client_pipe_connect_timeout_ms && child_options.reopen_stdin_as_client_pipe_connect_timeout_ms != DEFAULT_CLIENT_NAMED_PIPE_CONNECT_TIMEOUT_MS) {
        if (cmd_out_str_ptr) {
            options_line += std::tstring{ _T("/reopen-stdin-as-client-pipe-connect-timeout ") } + std::to_tstring(child_options.reopen_stdin_as_client_pipe_connect_timeout_ms) + _T(" ");
        }
    }
    regular_options.reopen_stdin_as_client_pipe_connect_timeout_ms = 0; // always reset


    if (!child_options.reopen_stdout_as_server_pipe.empty()) {
        if (cmd_out_str_ptr) {
            tmp_str = _replace_strings(child_options.reopen_stdout_as_server_pipe, _T("\\"), std::tstring{ _T("\\\\") });

            options_line += std::tstring{ _T("/reopen-stdout-as-server-pipe ") } + std::tstring{ _T("\"") } + _replace_strings(tmp_str, _T("\""), std::tstring{ _T("\\\"") }) + _T("\" ");
        }
    }
    regular_options.reopen_stdout_as_server_pipe.clear(); // always reset

    if (child_options.reopen_stdout_as_server_pipe_connect_timeout_ms && child_options.reopen_stdout_as_server_pipe_connect_timeout_ms != DEFAULT_SERVER_NAMED_PIPE_CONNECT_TIMEOUT_MS) {
        if (cmd_out_str_ptr) {
            options_line += std::tstring{ _T("/reopen-stdout-as-server-pipe-connect-timeout ") } + std::to_tstring(child_options.reopen_stdout_as_server_pipe_connect_timeout_ms) + _T(" ");
        }
    }
    regular_options.reopen_stdout_as_server_pipe_connect_timeout_ms = 0; // always reset

    if (child_options.reopen_stdout_as_server_pipe_in_buf_size && child_options.reopen_stdout_as_server_pipe_in_buf_size != DEFAULT_NAMED_PIPE_IN_BUF_SIZE) {
        if (cmd_out_str_ptr) {
            options_line += std::tstring{ _T("/reopen-stdout-as-server-pipe-in-buf-size ") } + std::to_tstring(child_options.reopen_stdout_as_server_pipe_in_buf_size) + _T(" ");
        }
    }
    regular_options.reopen_stdout_as_server_pipe_in_buf_size = 0; // always reset

    if (child_options.reopen_stdout_as_server_pipe_out_buf_size && child_options.reopen_stdout_as_server_pipe_out_buf_size != DEFAULT_NAMED_PIPE_OUT_BUF_SIZE) {
        if (cmd_out_str_ptr) {
            options_line += std::tstring{ _T("/reopen-stdout-as-server-pipe-out-buf-size ") } + std::to_tstring(child_options.reopen_stdout_as_server_pipe_out_buf_size) + _T(" ");
        }
    }
    regular_options.reopen_stdout_as_server_pipe_out_buf_size = 0; // always reset

    if (!child_options.reopen_stdout_as_client_pipe.empty()) {
        if (cmd_out_str_ptr) {
            tmp_str = _replace_strings(child_options.reopen_stdout_as_client_pipe, _T("\\"), std::tstring{ _T("\\\\") });

            options_line += std::tstring{ _T("/reopen-stdout-as-client-pipe ") } + std::tstring{ _T("\"") } + _replace_strings(tmp_str, _T("\""), std::tstring{ _T("\\\"") }) + _T("\" ");
        }
    }
    regular_options.reopen_stdout_as_client_pipe.clear(); // always reset

    if (child_options.reopen_stdout_as_client_pipe_connect_timeout_ms && child_options.reopen_stdout_as_client_pipe_connect_timeout_ms != DEFAULT_CLIENT_NAMED_PIPE_CONNECT_TIMEOUT_MS) {
        if (cmd_out_str_ptr) {
            options_line += std::tstring{ _T("/reopen-stdout-as-client-pipe-connect-timeout ") } + std::to_tstring(child_options.reopen_stdout_as_client_pipe_connect_timeout_ms) + _T(" ");
        }
    }
    regular_options.reopen_stdout_as_client_pipe_connect_timeout_ms = 0; // always reset


    if (!child_options.reopen_stderr_as_server_pipe.empty()) {
        if (cmd_out_str_ptr) {
            tmp_str = _replace_strings(child_options.reopen_stderr_as_server_pipe, _T("\\"), std::tstring{ _T("\\\\") });

            options_line += std::tstring{ _T("/reopen-stderr-as-server-pipe ") } + std::tstring{ _T("\"") } + _replace_strings(tmp_str, _T("\""), std::tstring{ _T("\\\"") }) + _T("\" ");
        }
    }
    regular_options.reopen_stderr_as_server_pipe.clear(); // always reset

    if (child_options.reopen_stderr_as_server_pipe_connect_timeout_ms && child_options.reopen_stderr_as_server_pipe_connect_timeout_ms != DEFAULT_SERVER_NAMED_PIPE_CONNECT_TIMEOUT_MS) {
        if (cmd_out_str_ptr) {
            options_line += std::tstring{ _T("/reopen-stderr-as-server-pipe-connect-timeout ") } + std::to_tstring(child_options.reopen_stderr_as_server_pipe_connect_timeout_ms) + _T(" ");
        }
    }
    regular_options.reopen_stderr_as_server_pipe_connect_timeout_ms = 0; // always reset

    if (child_options.reopen_stderr_as_server_pipe_in_buf_size && child_options.reopen_stderr_as_server_pipe_in_buf_size != DEFAULT_NAMED_PIPE_IN_BUF_SIZE) {
        if (cmd_out_str_ptr) {
            options_line += std::tstring{ _T("/reopen-stderr-as-server-pipe-in-buf-size ") } + std::to_tstring(child_options.reopen_stderr_as_server_pipe_in_buf_size) + _T(" ");
        }
    }
    regular_options.reopen_stderr_as_server_pipe_in_buf_size = 0; // always reset

    if (child_options.reopen_stderr_as_server_pipe_out_buf_size && child_options.reopen_stderr_as_server_pipe_out_buf_size != DEFAULT_NAMED_PIPE_OUT_BUF_SIZE) {
        if (cmd_out_str_ptr) {
            options_line += std::tstring{ _T("/reopen-stderr-as-server-pipe-out-buf-size ") } + std::to_tstring(child_options.reopen_stderr_as_server_pipe_out_buf_size) + _T(" ");
        }
    }
    regular_options.reopen_stderr_as_server_pipe_out_buf_size = 0; // always reset

    if (!child_options.reopen_stderr_as_client_pipe.empty()) {
        if (cmd_out_str_ptr) {
            tmp_str = _replace_strings(child_options.reopen_stderr_as_client_pipe, _T("\\"), std::tstring{ _T("\\\\") });

            options_line += std::tstring{ _T("/reopen-stderr-as-client-pipe ") } + std::tstring{ _T("\"") } + _replace_strings(tmp_str, _T("\""), std::tstring{ _T("\\\"") }) + _T("\" ");
        }
    }
    regular_options.reopen_stderr_as_client_pipe.clear(); // always reset

    if (child_options.reopen_stderr_as_client_pipe_connect_timeout_ms && child_options.reopen_stderr_as_client_pipe_connect_timeout_ms != DEFAULT_CLIENT_NAMED_PIPE_CONNECT_TIMEOUT_MS) {
        if (cmd_out_str_ptr) {
            options_line += std::tstring{ _T("/reopen-stderr-as-client-pipe-connect-timeout ") } + std::to_tstring(child_options.reopen_stderr_as_client_pipe_connect_timeout_ms) + _T(" ");
        }
    }
    regular_options.reopen_stderr_as_client_pipe_connect_timeout_ms = 0; // always reset


    if (child_flags.reopen_stdout_file_truncate) {
        if (cmd_out_str_ptr) {
            options_line += _T("/reopen-stdout-file-truncate ");
        }
    }
    regular_flags.reopen_stdout_file_truncate = false; // always reset

    if (child_flags.reopen_stderr_file_truncate) {
        if (cmd_out_str_ptr) {
            options_line += _T("/reopen-stderr-file-truncate ");
        }
    }
    regular_flags.reopen_stderr_file_truncate = false; // always reset


    if (child_options.stdout_dup >= 0) {
        if (cmd_out_str_ptr) {
            options_line += std::tstring{ _T("/stdout-dup ") } + std::to_tstring(child_options.stdout_dup) + _T(" ");
        }
    }
    regular_options.stdout_dup = -1; // always reset

    if (child_options.stderr_dup >= 0) {
        if (cmd_out_str_ptr) {
            options_line += std::tstring{ _T("/stderr-dup ") } + std::to_tstring(child_options.stderr_dup) + _T(" ");
        }
    }
    regular_options.stderr_dup = -1; // always reset


    if (child_flags.stdin_output_flush) {
        if (cmd_out_str_ptr) {
            options_line += _T("/stdin-output-flush ");
        }
    }
    regular_flags.stdin_output_flush = false; // always reset

    if (child_flags.stdout_flush) {
        if (cmd_out_str_ptr) {
            options_line += _T("/stdout-flush ");
        }
    }
    regular_flags.stdout_flush = false; // always reset

    if (child_flags.stderr_flush) {
        if (cmd_out_str_ptr) {
            options_line += _T("/stderr-flush ");
        }
    }
    regular_flags.stderr_flush = false; // always reset

    if (child_flags.output_flush) {
        if (cmd_out_str_ptr) {
            options_line += _T("/output-flush ");
        }
    }
    regular_flags.output_flush = false; // always reset

    if (child_flags.inout_flush) {
        if (cmd_out_str_ptr) {
            options_line += _T("/inout-flush ");
        }
    }
    regular_flags.inout_flush = false; // always reset


    if (child_flags.stdout_vt100) {
        if (cmd_out_str_ptr) {
            options_line += _T("/stdout-vt100 ");
        }
    }
    if (child_flags.stderr_vt100) {
        if (cmd_out_str_ptr) {
            options_line += _T("/stderr-vt100 ");
        }
    }
    if (child_flags.output_vt100) {
        if (cmd_out_str_ptr) {
            options_line += _T("/output-vt100 ");
        }
    }


    if (!child_options.create_outbound_server_pipe_from_stdin.empty()) {
        if (cmd_out_str_ptr) {
            tmp_str = _replace_strings(child_options.create_outbound_server_pipe_from_stdin, _T("\\"), std::tstring{ _T("\\\\") });

            options_line += std::tstring{ _T("/create-outbound-server-pipe-from-stdin ") } + std::tstring{ _T("\"") } + _replace_strings(tmp_str, _T("\""), std::tstring{ _T("\\\"") }) + _T("\" ");
        }
    }
    regular_options.create_outbound_server_pipe_from_stdin.clear(); // always reset

    if (child_options.create_outbound_server_pipe_from_stdin_connect_timeout_ms && child_options.create_outbound_server_pipe_from_stdin_connect_timeout_ms != DEFAULT_CLIENT_NAMED_PIPE_CONNECT_TIMEOUT_MS) {
        if (cmd_out_str_ptr) {
            options_line += std::tstring{ _T("/create-outbound-server-pipe-from-stdin-connect-timeout ") } + std::to_tstring(child_options.create_outbound_server_pipe_from_stdin_connect_timeout_ms) + _T(" ");
        }
    }
    regular_options.create_outbound_server_pipe_from_stdin_connect_timeout_ms = 0; // always reset

    if (child_options.create_outbound_server_pipe_from_stdin_in_buf_size && child_options.create_outbound_server_pipe_from_stdin_in_buf_size != DEFAULT_NAMED_PIPE_IN_BUF_SIZE) {
        if (cmd_out_str_ptr) {
            options_line += std::tstring{ _T("/create-outbound-server-pipe-from-stdin-in-buf-size ") } + std::to_tstring(child_options.create_outbound_server_pipe_from_stdin_in_buf_size) + _T(" ");
        }
    }
    regular_options.create_outbound_server_pipe_from_stdin_in_buf_size = 0; // always reset

    if (child_options.create_outbound_server_pipe_from_stdin_out_buf_size && child_options.create_outbound_server_pipe_from_stdin_out_buf_size != DEFAULT_NAMED_PIPE_OUT_BUF_SIZE) {
        if (cmd_out_str_ptr) {
            options_line += std::tstring{ _T("/create-outbound-server-pipe-from-stdin-out-buf-size ") } + std::to_tstring(child_options.create_outbound_server_pipe_from_stdin_out_buf_size) + _T(" ");
        }
    }
    regular_options.create_outbound_server_pipe_from_stdin_out_buf_size = 0; // always reset


    if (!child_options.create_inbound_server_pipe_to_stdout.empty()) {
        if (cmd_out_str_ptr) {
            tmp_str = _replace_strings(child_options.create_inbound_server_pipe_to_stdout, _T("\\"), std::tstring{ _T("\\\\") });

            options_line += std::tstring{ _T("/create-inbound-server-pipe-to-stdout ") } + std::tstring{ _T("\"") } + _replace_strings(tmp_str, _T("\""), std::tstring{ _T("\\\"") }) + _T("\" ");
        }
    }
    regular_options.create_inbound_server_pipe_to_stdout.clear(); // always reset

    if (child_options.create_inbound_server_pipe_to_stdout_connect_timeout_ms && child_options.create_inbound_server_pipe_to_stdout_connect_timeout_ms != DEFAULT_CLIENT_NAMED_PIPE_CONNECT_TIMEOUT_MS) {
        if (cmd_out_str_ptr) {
            options_line += std::tstring{ _T("/create-inbound-server-pipe-to-stdout-connect-timeout ") } + std::to_tstring(child_options.create_inbound_server_pipe_to_stdout_connect_timeout_ms) + _T(" ");
        }
    }
    regular_options.create_inbound_server_pipe_to_stdout_connect_timeout_ms = 0; // always reset

    if (child_options.create_inbound_server_pipe_to_stdout_in_buf_size && child_options.create_inbound_server_pipe_to_stdout_in_buf_size != DEFAULT_NAMED_PIPE_IN_BUF_SIZE) {
        if (cmd_out_str_ptr) {
            options_line += std::tstring{ _T("/create-inbound-server-pipe-to-stdout-in-buf-size ") } + std::to_tstring(child_options.create_inbound_server_pipe_to_stdout_in_buf_size) + _T(" ");
        }
    }
    regular_options.create_inbound_server_pipe_to_stdout_in_buf_size = 0; // always reset

    if (child_options.create_inbound_server_pipe_to_stdout_out_buf_size && child_options.create_inbound_server_pipe_to_stdout_out_buf_size != DEFAULT_NAMED_PIPE_OUT_BUF_SIZE) {
        if (cmd_out_str_ptr) {
            options_line += std::tstring{ _T("/create-inbound-server-pipe-to-stdout-out-buf-size ") } + std::to_tstring(child_options.create_inbound_server_pipe_to_stdout_out_buf_size) + _T(" ");
        }
    }
    regular_options.create_inbound_server_pipe_to_stdout_out_buf_size = 0; // always reset


    if (!child_options.create_inbound_server_pipe_to_stderr.empty()) {
        if (cmd_out_str_ptr) {
            tmp_str = _replace_strings(child_options.create_inbound_server_pipe_to_stderr, _T("\\"), std::tstring{ _T("\\\\") });

            options_line += std::tstring{ _T("/create-inbound-server-pipe-to-stderr ") } + std::tstring{ _T("\"") } + _replace_strings(tmp_str, _T("\""), std::tstring{ _T("\\\"") }) + _T("\" ");
        }
    }
    regular_options.create_inbound_server_pipe_to_stderr.clear(); // always reset

    if (child_options.create_inbound_server_pipe_to_stderr_connect_timeout_ms && child_options.create_inbound_server_pipe_to_stderr_connect_timeout_ms != DEFAULT_CLIENT_NAMED_PIPE_CONNECT_TIMEOUT_MS) {
        if (cmd_out_str_ptr) {
            options_line += std::tstring{ _T("/create-inbound-server-pipe-to-stderr-connect-timeout ") } + std::to_tstring(child_options.create_inbound_server_pipe_to_stderr_connect_timeout_ms) + _T(" ");
        }
    }
    regular_options.create_inbound_server_pipe_to_stderr_connect_timeout_ms = 0; // always reset

    if (child_options.create_inbound_server_pipe_to_stderr_in_buf_size && child_options.create_inbound_server_pipe_to_stderr_in_buf_size != DEFAULT_NAMED_PIPE_IN_BUF_SIZE) {
        if (cmd_out_str_ptr) {
            options_line += std::tstring{ _T("/create-inbound-server-pipe-to-stderr-in-buf-size ") } + std::to_tstring(child_options.create_inbound_server_pipe_to_stderr_in_buf_size) + _T(" ");
        }
    }
    regular_options.create_inbound_server_pipe_to_stderr_in_buf_size = 0; // always reset

    if (child_options.create_inbound_server_pipe_to_stderr_out_buf_size && child_options.create_inbound_server_pipe_to_stderr_out_buf_size != DEFAULT_NAMED_PIPE_OUT_BUF_SIZE) {
        if (cmd_out_str_ptr) {
            options_line += std::tstring{ _T("/create-inbound-server-pipe-to-stderr-out-buf-size ") } + std::to_tstring(child_options.create_inbound_server_pipe_to_stderr_out_buf_size) + _T(" ");
        }
    }
    regular_options.create_inbound_server_pipe_to_stderr_out_buf_size = 0; // always reset


    if (!child_options.tee_stdin_to_file.empty()) {
        if (cmd_out_str_ptr) {
            tmp_str = _replace_strings(child_options.tee_stdin_to_file, _T("\\"), std::tstring{ _T("\\\\") });

            options_line += std::tstring{ _T("/tee-stdin ") } + std::tstring{ _T("\"") } + _replace_strings(tmp_str, _T("\""), std::tstring{ _T("\\\"") }) + _T("\" ");
        }
    }
    regular_options.tee_stdin_to_file.clear(); // always reset

    if (!child_options.tee_stdout_to_file.empty()) {
        if (cmd_out_str_ptr) {
            tmp_str = _replace_strings(child_options.tee_stdout_to_file, _T("\\"), std::tstring{ _T("\\\\") });

            options_line += std::tstring{ _T("/tee-stdout ") } + std::tstring{ _T("\"") } + _replace_strings(tmp_str, _T("\""), std::tstring{ _T("\\\"") }) + _T("\" ");
        }
    }
    regular_options.tee_stdout_to_file.clear(); // always reset

    if (!child_options.tee_stderr_to_file.empty()) {
        if (cmd_out_str_ptr) {
            tmp_str = _replace_strings(child_options.tee_stderr_to_file, _T("\\"), std::tstring{ _T("\\\\") });

            options_line += std::tstring{ _T("/tee-stderr ") } + std::tstring{ _T("\"") } + _replace_strings(tmp_str, _T("\""), std::tstring{ _T("\\\"") }) + _T("\" ");
        }
    }
    regular_options.tee_stderr_to_file.clear(); // always reset


    if (!child_options.tee_stdin_to_server_pipe.empty()) {
        if (cmd_out_str_ptr) {
            tmp_str = _replace_strings(child_options.tee_stdin_to_server_pipe, _T("\\"), std::tstring{ _T("\\\\") });

            options_line += std::tstring{ _T("/tee-stdin-to-server-pipe ") } + std::tstring{ _T("\"") } + _replace_strings(tmp_str, _T("\""), std::tstring{ _T("\\\"") }) + _T("\" ");
        }
    }
    regular_options.tee_stdin_to_server_pipe.clear(); // always reset

    if (child_options.tee_stdin_to_server_pipe_connect_timeout_ms && child_options.tee_stdin_to_server_pipe_connect_timeout_ms != DEFAULT_SERVER_NAMED_PIPE_CONNECT_TIMEOUT_MS) {
        if (cmd_out_str_ptr) {
            options_line += std::tstring{ _T("/tee-stdin-to-server-pipe-connect-timeout ") } + std::to_tstring(child_options.tee_stdin_to_server_pipe_connect_timeout_ms) + _T(" ");
        }
    }
    regular_options.tee_stdin_to_server_pipe_connect_timeout_ms = 0; // always reset

    if (child_options.tee_stdin_to_server_pipe_in_buf_size && child_options.tee_stdin_to_server_pipe_in_buf_size != DEFAULT_NAMED_PIPE_IN_BUF_SIZE) {
        if (cmd_out_str_ptr) {
            options_line += std::tstring{ _T("/tee-stdin-to-server-pipe-in-buf-size ") } + std::to_tstring(child_options.tee_stdin_to_server_pipe_in_buf_size) + _T(" ");
        }
    }
    regular_options.tee_stdin_to_server_pipe_in_buf_size = 0; // always reset

    if (child_options.tee_stdin_to_server_pipe_out_buf_size && child_options.tee_stdin_to_server_pipe_out_buf_size != DEFAULT_NAMED_PIPE_OUT_BUF_SIZE) {
        if (cmd_out_str_ptr) {
            options_line += std::tstring{ _T("/tee-stdin-to-server-pipe-out-buf-size ") } + std::to_tstring(child_options.tee_stdin_to_server_pipe_out_buf_size) + _T(" ");
        }
    }
    regular_options.tee_stdin_to_server_pipe_out_buf_size = 0; // always reset

    if (!child_options.tee_stdin_to_client_pipe.empty()) {
        if (cmd_out_str_ptr) {
            tmp_str = _replace_strings(child_options.tee_stdin_to_client_pipe, _T("\\"), std::tstring{ _T("\\\\") });

            options_line += std::tstring{ _T("/tee-stdin-to-client-pipe ") } + std::tstring{ _T("\"") } + _replace_strings(tmp_str, _T("\""), std::tstring{ _T("\\\"") }) + _T("\" ");
        }
    }
    regular_options.tee_stdin_to_client_pipe.clear(); // always reset

    if (child_options.tee_stdin_to_client_pipe_connect_timeout_ms && child_options.tee_stdin_to_client_pipe_connect_timeout_ms != DEFAULT_CLIENT_NAMED_PIPE_CONNECT_TIMEOUT_MS) {
        if (cmd_out_str_ptr) {
            options_line += std::tstring{ _T("/tee-stdin-to-client-pipe-connect-timeout ") } + std::to_tstring(child_options.tee_stdin_to_client_pipe_connect_timeout_ms) + _T(" ");
        }
    }
    regular_options.tee_stdin_to_client_pipe_connect_timeout_ms = 0; // always reset


    if (!child_options.tee_stdout_to_server_pipe.empty()) {
        if (cmd_out_str_ptr) {
            tmp_str = _replace_strings(child_options.tee_stdout_to_server_pipe, _T("\\"), std::tstring{ _T("\\\\") });

            options_line += std::tstring{ _T("/tee-stdout-to-server-pipe ") } + std::tstring{ _T("\"") } + _replace_strings(tmp_str, _T("\""), std::tstring{ _T("\\\"") }) + _T("\" ");
        }
    }
    regular_options.tee_stdout_to_server_pipe.clear(); // always reset

    if (child_options.tee_stdout_to_server_pipe_connect_timeout_ms && child_options.tee_stdout_to_server_pipe_connect_timeout_ms != DEFAULT_SERVER_NAMED_PIPE_CONNECT_TIMEOUT_MS) {
        if (cmd_out_str_ptr) {
            options_line += std::tstring{ _T("/tee-stdout-to-server-pipe-connect-timeout ") } + std::to_tstring(child_options.tee_stdout_to_server_pipe_connect_timeout_ms) + _T(" ");
        }
    }
    regular_options.tee_stdout_to_server_pipe_connect_timeout_ms = 0; // always reset

    if (child_options.tee_stdout_to_server_pipe_in_buf_size && child_options.tee_stdout_to_server_pipe_in_buf_size != DEFAULT_NAMED_PIPE_IN_BUF_SIZE) {
        if (cmd_out_str_ptr) {
            options_line += std::tstring{ _T("/tee-stdout-to-server-pipe-in-buf-size ") } + std::to_tstring(child_options.tee_stdout_to_server_pipe_in_buf_size) + _T(" ");
        }
    }
    regular_options.tee_stdout_to_server_pipe_in_buf_size = 0; // always reset

    if (child_options.tee_stdout_to_server_pipe_out_buf_size && child_options.tee_stdout_to_server_pipe_out_buf_size != DEFAULT_NAMED_PIPE_OUT_BUF_SIZE) {
        if (cmd_out_str_ptr) {
            options_line += std::tstring{ _T("/tee-stdout-to-server-pipe-out-buf-size ") } + std::to_tstring(child_options.tee_stdout_to_server_pipe_out_buf_size) + _T(" ");
        }
    }
    regular_options.tee_stdout_to_server_pipe_out_buf_size = 0; // always reset

    if (!child_options.tee_stdout_to_client_pipe.empty()) {
        if (cmd_out_str_ptr) {
            tmp_str = _replace_strings(child_options.tee_stdout_to_client_pipe, _T("\\"), std::tstring{ _T("\\\\") });

            options_line += std::tstring{ _T("/tee-stdout-to-client-pipe ") } + std::tstring{ _T("\"") } + _replace_strings(tmp_str, _T("\""), std::tstring{ _T("\\\"") }) + _T("\" ");
        }
    }
    regular_options.tee_stdout_to_client_pipe.clear(); // always reset

    if (child_options.tee_stdout_to_client_pipe_connect_timeout_ms && child_options.tee_stdout_to_client_pipe_connect_timeout_ms != DEFAULT_CLIENT_NAMED_PIPE_CONNECT_TIMEOUT_MS) {
        if (cmd_out_str_ptr) {
            options_line += std::tstring{ _T("/tee-stdout-to-client-pipe-connect-timeout ") } + std::to_tstring(child_options.tee_stdout_to_client_pipe_connect_timeout_ms) + _T(" ");
        }
    }
    regular_options.tee_stdout_to_client_pipe_connect_timeout_ms = 0; // always reset


    if (!child_options.tee_stderr_to_server_pipe.empty()) {
        if (cmd_out_str_ptr) {
            tmp_str = _replace_strings(child_options.tee_stderr_to_server_pipe, _T("\\"), std::tstring{ _T("\\\\") });

            options_line += std::tstring{ _T("/tee-stderr-to-server-pipe ") } + std::tstring{ _T("\"") } + _replace_strings(tmp_str, _T("\""), std::tstring{ _T("\\\"") }) + _T("\" ");
        }
    }
    regular_options.tee_stderr_to_server_pipe.clear(); // always reset

    if (child_options.tee_stderr_to_server_pipe_connect_timeout_ms && child_options.tee_stderr_to_server_pipe_connect_timeout_ms != DEFAULT_SERVER_NAMED_PIPE_CONNECT_TIMEOUT_MS) {
        if (cmd_out_str_ptr) {
            options_line += std::tstring{ _T("/tee-stderr-to-server-pipe-connect-timeout ") } + std::to_tstring(child_options.tee_stderr_to_server_pipe_connect_timeout_ms) + _T(" ");
        }
    }
    regular_options.tee_stderr_to_server_pipe_connect_timeout_ms = 0; // always reset

    if (child_options.tee_stderr_to_server_pipe_in_buf_size && child_options.tee_stderr_to_server_pipe_in_buf_size != DEFAULT_NAMED_PIPE_IN_BUF_SIZE) {
        if (cmd_out_str_ptr) {
            options_line += std::tstring{ _T("/tee-stderr-to-server-pipe-in-buf-size ") } + std::to_tstring(child_options.tee_stderr_to_server_pipe_in_buf_size) + _T(" ");
        }
    }
    regular_options.tee_stderr_to_server_pipe_in_buf_size = 0; // always reset

    if (child_options.tee_stderr_to_server_pipe_out_buf_size && child_options.tee_stderr_to_server_pipe_out_buf_size != DEFAULT_NAMED_PIPE_OUT_BUF_SIZE) {
        if (cmd_out_str_ptr) {
            options_line += std::tstring{ _T("/tee-stderr-to-server-pipe-out-buf-size ") } + std::to_tstring(child_options.tee_stderr_to_server_pipe_out_buf_size) + _T(" ");
        }
    }
    regular_options.tee_stderr_to_server_pipe_out_buf_size = 0; // always reset

    if (!child_options.tee_stderr_to_client_pipe.empty()) {
        if (cmd_out_str_ptr) {
            tmp_str = _replace_strings(child_options.tee_stderr_to_client_pipe, _T("\\"), std::tstring{ _T("\\\\") });

            options_line += std::tstring{ _T("/tee-stderr-to-client-pipe ") } + std::tstring{ _T("\"") } + _replace_strings(tmp_str, _T("\""), std::tstring{ _T("\\\"") }) + _T("\" ");
        }
    }
    regular_options.tee_stderr_to_client_pipe.clear(); // always reset

    if (child_options.tee_stderr_to_client_pipe_connect_timeout_ms && child_options.tee_stderr_to_client_pipe_connect_timeout_ms != DEFAULT_CLIENT_NAMED_PIPE_CONNECT_TIMEOUT_MS) {
        if (cmd_out_str_ptr) {
            options_line += std::tstring{ _T("/tee-stderr-to-client-pipe-connect-timeout ") } + std::to_tstring(child_options.tee_stderr_to_client_pipe_connect_timeout_ms) + _T(" ");
        }
    }
    regular_options.tee_stderr_to_client_pipe_connect_timeout_ms = 0; // always reset


    if (child_flags.tee_stdout_file_truncate) {
        if (cmd_out_str_ptr) {
            options_line += _T("/tee-stdout-file-truncate ");
        }
    }
    regular_flags.tee_stdout_file_truncate = false; // always reset

    if (child_flags.tee_stderr_file_truncate) {
        if (cmd_out_str_ptr) {
            options_line += _T("/tee-stderr-file-truncate ");
        }
    }
    regular_flags.tee_stderr_file_truncate = false; // always reset


    if (child_options.tee_stdin_dup >= 0) {
        if (cmd_out_str_ptr) {
            options_line += std::tstring{ _T("/tee-stdin-dup ") } + std::to_tstring(child_options.tee_stdin_dup) + _T(" ");
        }
    }
    regular_options.tee_stdin_dup = -1; // always reset

    if (child_options.tee_stdout_dup >= 0) {
        if (cmd_out_str_ptr) {
            options_line += std::tstring{ _T("/tee-stdout-dup ") } + std::to_tstring(child_options.tee_stdout_dup) + _T(" ");
        }
    }
    regular_options.tee_stdout_dup = -1; // always reset

    if (child_options.tee_stderr_dup >= 0) {
        if (cmd_out_str_ptr) {
            options_line += std::tstring{ _T("/tee-stderr-dup ") } + std::to_tstring(child_options.tee_stderr_dup) + _T(" ");
        }
    }
    regular_options.tee_stderr_dup = -1; // always reset

    if (child_flags.tee_conout_dup) {
        if (cmd_out_str_ptr) {
            options_line += _T("/tee-conout-dup ");
        }
    }
    regular_flags.tee_conout_dup = false; // always reset


    if (child_flags.tee_stdin_file_truncate) {
        if (cmd_out_str_ptr) {
            options_line += _T("/tee-stdin-file-truncate ");
        }
    }
    regular_flags.tee_stdin_file_truncate = false; // always reset

    if (child_flags.tee_stdout_file_truncate) {
        if (cmd_out_str_ptr) {
            options_line += _T("/tee-stdout-file-truncate ");
        }
    }
    regular_flags.tee_stdout_file_truncate = false; // always reset

    if (child_flags.tee_stderr_file_truncate) {
        if (cmd_out_str_ptr) {
            options_line += _T("/tee-stderr-file-truncate ");
        }
    }
    regular_flags.tee_stderr_file_truncate = false; // always reset


    if (child_flags.tee_stdin_file_flush) {
        if (cmd_out_str_ptr) {
            options_line += _T("/tee-stdin-file-flush ");
        }
    }
    regular_flags.tee_stdin_file_flush = false; // always reset

    if (child_flags.tee_stdout_file_flush) {
        if (cmd_out_str_ptr) {
            options_line += _T("/tee-stdout-file-flush ");
        }
    }
    regular_flags.tee_stdout_file_flush = false; // always reset

    if (child_flags.tee_stderr_file_flush) {
        if (cmd_out_str_ptr) {
            options_line += _T("/tee-stderr-file-flush ");
        }
    }
    regular_flags.tee_stderr_file_flush = false; // always reset


    if (child_flags.tee_stdin_pipe_flush) {
        if (cmd_out_str_ptr) {
            options_line += _T("/tee-stdin-pipe-flush ");
        }
    }
    regular_flags.tee_stdin_pipe_flush = false; // always reset

    if (child_flags.tee_stdout_pipe_flush) {
        if (cmd_out_str_ptr) {
            options_line += _T("/tee-stdout-pipe-flush ");
        }
    }
    regular_flags.tee_stdout_pipe_flush = false; // always reset

    if (child_flags.tee_stderr_pipe_flush) {
        if (cmd_out_str_ptr) {
            options_line += _T("/tee-stderr-pipe-flush ");
        }
    }
    regular_flags.tee_stderr_pipe_flush = false; // always reset


    if (child_flags.tee_stdin_flush) {
        if (cmd_out_str_ptr) {
            options_line += _T("/tee-stdin-flush ");
        }
    }
    regular_flags.tee_stdin_flush = false; // always reset

    if (child_flags.tee_stdout_flush) {
        if (cmd_out_str_ptr) {
            options_line += _T("/tee-stdout-flush ");
        }
    }
    regular_flags.tee_stdout_flush = false; // always reset

    if (child_flags.tee_stderr_flush) {
        if (cmd_out_str_ptr) {
            options_line += _T("/tee-stderr-flush ");
        }
    }
    regular_flags.tee_stderr_flush = false; // always reset


    if (child_flags.tee_output_flush) {
        if (cmd_out_str_ptr) {
            options_line += _T("/tee-output-flush ");
        }
    }
    regular_flags.tee_output_flush = false; // always reset

    if (child_flags.tee_inout_flush) {
        if (cmd_out_str_ptr) {
            options_line += _T("/tee-inout-flush ");
        }
    }
    regular_flags.tee_inout_flush = false; // always reset


    if (child_options.tee_stdin_pipe_buf_size && child_options.tee_stdin_pipe_buf_size != DEFAULT_ANONYMOUS_PIPE_BUF_SIZE) {
        if (cmd_out_str_ptr) {
            options_line += std::tstring{ _T("/tee-stdin-pipe-buf-size ") } + std::to_tstring(child_options.tee_stdin_pipe_buf_size) + _T(" ");
        }
    }
    regular_options.tee_stdin_pipe_buf_size = 0; // always reset

    if (child_options.tee_stdout_pipe_buf_size && child_options.tee_stdout_pipe_buf_size != DEFAULT_ANONYMOUS_PIPE_BUF_SIZE) {
        if (cmd_out_str_ptr) {
            options_line += std::tstring{ _T("/tee-stdout-pipe-buf-size ") } + std::to_tstring(child_options.tee_stdout_pipe_buf_size) + _T(" ");
        }
    }
    regular_options.tee_stdout_pipe_buf_size = 0; // always reset

    if (child_options.tee_stderr_pipe_buf_size && child_options.tee_stderr_pipe_buf_size != DEFAULT_ANONYMOUS_PIPE_BUF_SIZE) {
        if (cmd_out_str_ptr) {
            options_line += std::tstring{ _T("/tee-stderr-pipe-buf-size ") } + std::to_tstring(child_options.tee_stderr_pipe_buf_size) + _T(" ");
        }
    }
    regular_options.tee_stderr_pipe_buf_size = 0; // always reset


    if (child_options.tee_stdin_read_buf_size && child_options.tee_stdin_read_buf_size != DEFAULT_READ_BUF_SIZE) {
        if (cmd_out_str_ptr) {
            options_line += std::tstring{ _T("/tee-stdin-read-buf-size ") } + std::to_tstring(child_options.tee_stdin_read_buf_size) + _T(" ");
        }
    }
    regular_options.tee_stdin_read_buf_size = 0; // always reset

    if (child_options.tee_stdout_read_buf_size && child_options.tee_stdout_read_buf_size != DEFAULT_READ_BUF_SIZE) {
        if (cmd_out_str_ptr) {
            options_line += std::tstring{ _T("/tee-stdout-read-buf-size ") } + std::to_tstring(child_options.tee_stdout_read_buf_size) + _T(" ");
        }
    }
    regular_options.tee_stdout_read_buf_size = 0; // always reset

    if (child_options.tee_stderr_read_buf_size && child_options.tee_stderr_read_buf_size != DEFAULT_READ_BUF_SIZE) {
        if (cmd_out_str_ptr) {
            options_line += std::tstring{ _T("/tee-stderr-read-buf-size ") } + std::to_tstring(child_options.tee_stderr_read_buf_size) + _T(" ");
        }
    }
    regular_options.tee_stderr_read_buf_size = 0; // always reset


    if (child_flags.mutex_std_writes) {
        if (cmd_out_str_ptr) {
            options_line += _T("/mutex-std-writes ");
        }
    }
    regular_flags.mutex_std_writes = false; // always reset

    if (child_flags.mutex_tee_file_writes) {
        if (cmd_out_str_ptr) {
            options_line += _T("/mutex-tee-file-writes ");
        }
    }
    regular_flags.mutex_tee_file_writes = false; // always reset

    // leave generic console flags and options as is, to manipulate elevated process console you should use the `/elevate{ ... }` option

    if (child_flags.create_child_console) {
        if (cmd_out_str_ptr) {
            options_line += _T("/create-child-console ");
        }
    }
    regular_flags.create_child_console = false; // always reset

    if (child_flags.detach_child_console) {
        if (cmd_out_str_ptr) {
            options_line += _T("/detach-child-console ");
        }
    }
    regular_flags.detach_child_console = false; // always reset

    if (child_flags.create_console) {
        if (cmd_out_str_ptr) {
            options_line += _T("/create-console ");
        }
    }
    regular_flags.create_console = false; // always reset

    if (child_flags.detach_console) {
        if (cmd_out_str_ptr) {
            options_line += _T("/detach-console ");
        }
    }
    regular_flags.detach_console = false; // always reset

    if (child_flags.attach_parent_console) {
        if (cmd_out_str_ptr) {
            options_line += _T("/attach-parent-console ");
        }
    }
    regular_flags.attach_parent_console = false; // always reset

    if (child_options.has.create_console_title) {
        if (cmd_out_str_ptr) {
            options_line += std::tstring{ _T("/create-console-title \"") } + child_options.create_console_title + _T("\" ");
        }
    }
    regular_options.has.create_console_title = false; // always reset
    regular_options.create_console_title.clear();

    if (child_options.has.own_console_title) {
        if (cmd_out_str_ptr) {
            options_line += std::tstring{ _T("/own-console-title \"") } + child_options.own_console_title + _T("\" ");
        }
    }
    regular_options.has.own_console_title = false; // always reset
    regular_options.own_console_title.clear();

    if (child_options.has.console_title) {
        if (cmd_out_str_ptr) {
            options_line += std::tstring{ _T("/console-title \"") } + child_options.console_title + _T("\" ");
        }
    }
    regular_options.has.console_title = false; // always reset
    regular_options.console_title.clear();


    if (child_flags.stdin_echo) {
        if (cmd_out_str_ptr) {
            options_line += _T("/stdin-echo ");
        }
    }
    regular_flags.stdin_echo = false; // always reset

    if (child_flags.no_stdin_echo) {
        if (cmd_out_str_ptr) {
            options_line += _T("/no-stdin-echo ");
        }
    }
    regular_flags.no_stdin_echo = false; // always reset


    if (cmd_out_str_ptr) {
        for (const auto & tuple_ref : child_options.replace_args) {
            const int replace_index = std::get<0>(tuple_ref);

            if (replace_index >= 0) {
                options_line += std::tstring{ _T("/r") } + std::to_tstring(replace_index) + _T(" \"") + std::get<1>(tuple_ref) + _T("\" \"") + std::get<2>(tuple_ref) + _T("\" ");
            }
            else if (replace_index == -1) {
                options_line += std::tstring{ _T("/r \"") } + std::get<1>(tuple_ref) + _T("\" \"") + std::get<2>(tuple_ref) + _T("\" ");
            }
            else if (replace_index == -2) {
                options_line += std::tstring{ _T("/ra \"") } + std::get<1>(tuple_ref) + _T("\" \"") + std::get<2>(tuple_ref) + _T("\" ");
            }
        }
    }
    regular_options.replace_args.clear();

    if (cmd_out_str_ptr) {
        for (const auto & tuple_ref : child_options.env_vars) {
            options_line += std::tstring{ _T("/v \"") } + std::get<0>(tuple_ref) + _T("\" \"") + std::get<1>(tuple_ref) + _T("\" ");
        }
    }
    regular_options.env_vars.clear();


    //child_flags.eval_backslash_esc
    //child_flags.eval_dbl_backslash_esc


    if (child_flags.disable_wow64_fs_redir) {
        if (cmd_out_str_ptr) {
            options_line += _T("/disable-wow64-fs-redir ");
        }
    }
    regular_flags.disable_wow64_fs_redir = false; // always reset

    if (child_flags.disable_ctrl_signals) {
        if (cmd_out_str_ptr) {
            options_line += _T("/disable-ctrl-signals ");
        }
    }
    regular_flags.disable_ctrl_signals = false; // always reset

    if (child_flags.disable_ctrl_c_signal) {
        if (cmd_out_str_ptr) {
            options_line += _T("/disable-ctrl-c-signal ");
        }
    }
    regular_flags.disable_ctrl_c_signal = false; // always reset

#ifndef _CONSOLE
    if (child_flags.allow_gui_autoattach_to_parent_console) {
        if (cmd_out_str_ptr) {
            options_line += _T("/allow-gui-autoattach-to-parent-console ");
        }
    }
    regular_flags.allow_gui_autoattach_to_parent_console = false; // always reset
#endif

    if (child_flags.disable_conout_reattach_to_visible_console) {
        if (cmd_out_str_ptr) {
            options_line += _T("/disable-conout-reattach-to-visible-console ");
        }
    }
    regular_flags.disable_conout_reattach_to_visible_console = false; // always reset

    if (child_flags.allow_conout_attach_to_invisible_parent_console) {
        if (cmd_out_str_ptr) {
            options_line += _T("/allow-conout-attach-to-invisible-parent-console ");
        }
    }
    regular_flags.allow_conout_attach_to_invisible_parent_console = false; // always reset

    if (child_flags.disable_conout_duplicate_to_parent_console_on_error) {
        if (cmd_out_str_ptr) {
            options_line += _T("/disable-conout-duplicate-to-parent-console-on-error ");
        }
    }
    regular_flags.disable_conout_duplicate_to_parent_console_on_error = false; // always reset


    if (child_flags.write_console_stdin_back) {
        if (cmd_out_str_ptr) {
            options_line += _T("/write-console-stdin-back ");
        }
    }
    regular_flags.write_console_stdin_back = false; // always reset


    if (cmd_out_str_ptr) {
        *cmd_out_str_ptr = options_line + cmd_line;
    }
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

template bool CreateInboundPipeToConsoleOutput<1>(int & ret, DWORD & win_error);
template bool CreateInboundPipeToConsoleOutput<2>(int & ret, DWORD & win_error);

template DWORD WINAPI ConnectInboundServerPipeToConsoleOutputThread<1>(LPVOID lpParam);
template DWORD WINAPI ConnectInboundServerPipeToConsoleOutputThread<2>(LPVOID lpParam);
