#pragma once

#ifndef __EXECUTE_HPP__
#define __EXECUTE_HPP__

#include "callf.hpp"

#include <deque>
#include <tuple>
#include <type_traits>
#include <atomic>


// std and tee files has different mutex name prefixes because should not be mixed for write
#define STD_FILE_WRITE_MUTEX_NAME_PREFIX    "{12FBACAA-9C0D-460F-9B69-5FB8EB747B5C}"
#define TEE_FILE_WRITE_MUTEX_NAME_PREFIX    "{C50E64BC-9A9F-4507-9B77-4446319A556E}"

#define DEFAULT_READ_BUF_SIZE               65536
#define DEFAULT_ANONYMOUS_PIPE_BUF_SIZE     65536
#define DEFAULT_NAMED_PIPE_IN_BUF_SIZE      65536
#define DEFAULT_NAMED_PIPE_OUT_BUF_SIZE     65536

#define DEFAULT_SERVER_NAMED_PIPE_CONNECT_TIMEOUT_MS 30000
#define DEFAULT_CLIENT_NAMED_PIPE_CONNECT_TIMEOUT_MS 30000


struct Flags
{
    // NOTE: the `tee` applies only to the child process here!
    //
    bool            show_help;
    bool            disable_conout_reattach_to_visible_console;
    bool            disable_conout_duplicate_to_parent_console_on_error;
    bool            elevate;
    bool            stdin_output_flush;             // flush handle connected with stdin input
    bool            stdout_flush;
    bool            stderr_flush;
    bool            output_flush;                   // flush stdout and stderr
    bool            inout_flush;                    // flush handle connected with stdin input and flush stdout and stderr
    bool            reopen_stdout_file_truncate;
    bool            reopen_stderr_file_truncate;
    bool            tee_stdin_file_truncate;
    bool            tee_stdout_file_truncate;
    bool            tee_stderr_file_truncate;
    bool            tee_stdin_file_flush;
    bool            tee_stdin_pipe_flush;
    bool            tee_stdin_flush;                // flush stdin tee files and pipes
    bool            tee_stdout_file_flush;
    bool            tee_stdout_pipe_flush;
    bool            tee_stdout_flush;               // flush stdout tee files and pipes
    bool            tee_stderr_file_flush;
    bool            tee_stderr_pipe_flush;
    bool            tee_stderr_flush;               // flush stderr tee files and pipes
    bool            tee_output_flush;               // flush stdout and stderr for tee files and pipes
    bool            tee_inout_flush;                // flush stdin and stdout and stderr for tee files and pipes
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
    bool            no_std_inherit;
    bool            pipe_stdin_to_stdout;
    bool            shell_exec_expand_env;
    bool            create_child_console;
    bool            create_console;                 // has priority over attach_parent_console
    bool            attach_parent_console;
    bool            eval_backslash_esc;             // evaluate backslash escape characters
    bool            eval_dbl_backslash_esc;         // evaluate double backslash escape characters (`\\`)
    bool            init_com;
    bool            wait_child_start;
    bool            mutex_std_writes;
    bool            mutex_tee_file_writes;

    void merge(const Flags & flags);
    void clear();
};

struct HasOptions
{
    bool            create_console_title;
    bool            own_console_title;
    bool            console_title;
};

struct Options
{
    uint_t          win_ver_major;
    uint_t          win_ver_minor;
    uint_t          win_ver_build;

    std::tstring    shell_exec_verb;
    std::tstring    change_current_dir;

    std::tstring    reopen_stdin_as_file;
    std::tstring    reopen_stdin_as_server_pipe;
    std::tstring    reopen_stdin_as_client_pipe;
    std::tstring    reopen_stdout_as_file;
    std::tstring    reopen_stdout_as_server_pipe;
    std::tstring    reopen_stdout_as_client_pipe;
    std::tstring    reopen_stderr_as_file;
    std::tstring    reopen_stderr_as_server_pipe;
    std::tstring    reopen_stderr_as_client_pipe;

    // has meaning for stdin as disk or pipe handle, has no use for console input
    std::tstring    tee_stdin_to_file;
    std::tstring    tee_stdin_to_server_pipe;
    std::tstring    tee_stdin_to_client_pipe;
    std::tstring    tee_stdout_to_file;
    std::tstring    tee_stdout_to_server_pipe;
    std::tstring    tee_stdout_to_client_pipe;
    std::tstring    tee_stderr_to_file;
    std::tstring    tee_stderr_to_server_pipe;
    std::tstring    tee_stderr_to_client_pipe;

    std::tstring    create_console_title;
    std::tstring    own_console_title;
    std::tstring    console_title;

    std::tstring    create_outbound_server_pipe_from_stdin;
    std::tstring    create_inbound_server_pipe_to_stdout;
    std::tstring    create_inbound_server_pipe_to_stderr;

    uint_t          chcp_in;
    uint_t          chcp_out;
    uint_t          win_error_langid;

    int             stdout_dup;
    int             stderr_dup;

    int             tee_stdin_dup;
    int             tee_stdout_dup;
    int             tee_stderr_dup;

    uint_t          reopen_stdin_as_server_pipe_connect_timeout_ms;
    uint_t          reopen_stdin_as_client_pipe_connect_timeout_ms;
    uint_t          reopen_stdout_as_server_pipe_connect_timeout_ms;
    uint_t          reopen_stdout_as_client_pipe_connect_timeout_ms;
    uint_t          reopen_stderr_as_server_pipe_connect_timeout_ms;
    uint_t          reopen_stderr_as_client_pipe_connect_timeout_ms;

    // a named pipe in/out buffer sizes, used if a named pipe is used to reopen stdout/stderr
    int             reopen_stdin_as_server_pipe_in_buf_size;
    int             reopen_stdin_as_server_pipe_out_buf_size;
    int             reopen_stdout_as_server_pipe_in_buf_size;
    int             reopen_stdout_as_server_pipe_out_buf_size;
    int             reopen_stderr_as_server_pipe_in_buf_size;
    int             reopen_stderr_as_server_pipe_out_buf_size;

    uint_t          create_outbound_server_pipe_from_stdin_connect_timeout_ms;
    uint_t          create_inbound_server_pipe_to_stdout_connect_timeout_ms;
    uint_t          create_inbound_server_pipe_to_stderr_connect_timeout_ms;

    // a named pipe in/out buffer sizes, used instead of anonymous pipe to write into from stdin and read from into stdout/stderr
    uint_t          create_outbound_server_pipe_from_stdin_in_buf_size;
    uint_t          create_outbound_server_pipe_from_stdin_out_buf_size;
    uint_t          create_inbound_server_pipe_to_stdout_in_buf_size;
    uint_t          create_inbound_server_pipe_to_stdout_out_buf_size;
    uint_t          create_inbound_server_pipe_to_stderr_in_buf_size;
    uint_t          create_inbound_server_pipe_to_stderr_out_buf_size;

    uint_t          tee_stdin_to_server_pipe_connect_timeout_ms;
    uint_t          tee_stdin_to_client_pipe_connect_timeout_ms;
    uint_t          tee_stdout_to_server_pipe_connect_timeout_ms;
    uint_t          tee_stdout_to_client_pipe_connect_timeout_ms;
    uint_t          tee_stderr_to_server_pipe_connect_timeout_ms;
    uint_t          tee_stderr_to_client_pipe_connect_timeout_ms;

    // a named pipe in/out buffer sizes, used if a named pipe is used to duplicate stdin/stdout/stderr into a named pipe
    uint_t          tee_stdin_to_server_pipe_in_buf_size;
    uint_t          tee_stdin_to_server_pipe_out_buf_size;
    uint_t          tee_stdout_to_server_pipe_in_buf_size;
    uint_t          tee_stdout_to_server_pipe_out_buf_size;
    uint_t          tee_stderr_to_server_pipe_in_buf_size;
    uint_t          tee_stderr_to_server_pipe_out_buf_size;

    // internal anonymous pipe buffer sizes (a named pipe buffer sizes overrides these)
    uint_t          tee_stdin_pipe_buf_size;
    uint_t          tee_stdout_pipe_buf_size;
    uint_t          tee_stderr_pipe_buf_size;
    uint_t          tee_stdin_read_buf_size;
    uint_t          tee_stdout_read_buf_size;
    uint_t          tee_stderr_read_buf_size;

    int             stdin_echo;
    uint_t          show_as;

    std::deque<std::tuple<int, std::tstring, std::tstring> > replace_args; // -1 - all, -2 - greater or equal to 1
    std::deque<std::tuple<std::tstring, std::tstring> > env_vars;
    std::deque<std::tuple<int> > eval_backslash_esc;

    HasOptions      has;

    Options();
    Options(const Options &) = default;
    Options(Options &&) = default;

    void merge(const Options & options);
    void clear();

    Options & operator =(const Options &) = default;
    //Options && operator =(Options &&) = default;
};

struct ThreadReturnData
{
    int             ret;
    DWORD           win_error;
    std::tstring    msg;
    bool            is_error;
    bool            is_copied;

    ThreadReturnData() :
        ret(), win_error(), is_error(false), is_copied(false)
    {
    }

    ThreadReturnData(const ThreadReturnData &) = default;
    ThreadReturnData(ThreadReturnData &&) = default;
};

struct WorkerThreadsReturnData
{
    WorkerThreadsReturnData()
    {
        mutex = CreateMutex(NULL, FALSE, NULL);
    }

    ~WorkerThreadsReturnData()
    {
        _close_handle(mutex);
    }

    void add(ThreadReturnData data)
    {
        WaitForSingleObject(mutex, INFINITE);

        datas.push_back(data);

        ReleaseMutex(mutex);
    }

    HANDLE                       mutex;
    std::deque<ThreadReturnData> datas;
};

struct WorkerThreadsSyncData
{
    std::atomic_bool    cancel_io;

    WorkerThreadsSyncData() :
        cancel_io(false)
    {
    }
};

struct StreamPipeThreadData : ThreadReturnData, WorkerThreadsSyncData
{
};

struct ConnectNamedPipeThreadData : ThreadReturnData, WorkerThreadsSyncData
{
};

template <typename TData>
struct BasicThreadLocals
{
    HANDLE      thread_handle;
    DWORD       thread_id;
    TData       thread_data;

    BasicThreadLocals() :
        thread_handle(INVALID_HANDLE_VALUE), thread_id((DWORD)-1)
    {
    }
};

struct BasicNamedPipeLocals
{
    HANDLE *    server_named_pipe_handle_ptr;
    HANDLE *    client_named_pipe_handle_ptr;

    BasicNamedPipeLocals() :
        server_named_pipe_handle_ptr(nullptr), client_named_pipe_handle_ptr(nullptr)
    {
    }
};

struct StreamPipeThreadLocals : BasicThreadLocals<StreamPipeThreadData>
{
};

struct StdinToStdoutThreadLocals : BasicThreadLocals<StreamPipeThreadData>
{
};

struct ConnectNamedPipeThreadLocals : BasicThreadLocals<ConnectNamedPipeThreadData>, BasicNamedPipeLocals
{
};


extern Flags g_flags;
extern Flags g_regular_flags;
extern Flags g_elevate_parent_flags;
extern Flags g_elevate_child_flags;
extern Flags g_promote_flags;
extern Flags g_promote_parent_flags;

extern Options g_options;
extern Options g_regular_options;
extern Options g_elevate_parent_options;
extern Options g_elevate_child_options;
extern Options g_promote_options;
extern Options g_promote_parent_options;

extern DWORD g_parent_proc_id;
extern HWND  g_current_proc_console_window;

BOOL WINAPI CtrlHandler(DWORD ctrl_type);

template <int stream_type>
DWORD WINAPI StreamPipeThread(LPVOID lpParam);

DWORD WINAPI StdinToStdoutThread(LPVOID lpParam);

template <int handle_type, int co_stream_type>
DWORD WINAPI ConnectServerNamedPipeThread(LPVOID lpParam);

template <int handle_type, int co_stream_type>
DWORD WINAPI ConnectClientNamedPipeThread(LPVOID lpParam);

bool ReopenStdin(int & ret, DWORD & win_error, UINT cp_in);
bool ReopenStdout(int & ret, DWORD & win_error, UINT cp_in);
bool ReopenStderr(int & ret, DWORD & win_error, UINT cp_in);

bool CreateOutboundPipeFromConsoleInput(int & ret, DWORD & win_error);
template <int stream_type>
bool CreateInboundPipeToConsoleOutput(int & ret, DWORD & win_error);

DWORD WINAPI ConnectOutboundServerPipeFromConsoleInputThread(LPVOID lpParam);

template <int stream_type>
DWORD WINAPI ConnectInboundServerPipeToConsoleOutputThread(LPVOID lpParam);

bool CreateStdinToStdoutLoop(int & ret, DWORD & win_error);

bool CreateTeeOutputFromStdin(int & ret, DWORD & win_error, UINT cp_in);
bool CreateTeeOutputFromStdout(int & ret, DWORD & win_error, UINT cp_in);
bool CreateTeeOutputFromStderr(int & ret, DWORD & win_error, UINT cp_in);

int ExecuteProcess(LPCTSTR app, size_t app_len, LPCTSTR cmd, size_t cmd_len);

std::tstring SubstNamePlaceholders(std::tstring str);
void SubstOptionsPlaceholders(Options & options);

void TranslateCommandLineToElevated(const std::tstring * app_str_ptr, const std::tstring * cmd_str_ptr, std::tstring * cmd_out_str_ptr,
                                    Flags & regular_flags, Options & regular_options,
                                    const Flags & elevate_child_flags, const Options & elevate_child_options,
                                    const Flags & promote_child_flags, const Options & promote_child_options);


template <typename T>
inline void DisconnectNamedPipeThreadLocal(BasicThreadLocals<T> & local)
{
}

inline void DisconnectNamedPipeThreadLocal(BasicNamedPipeLocals & local)
{
    if (local.server_named_pipe_handle_ptr) {
        CancelIo(*local.server_named_pipe_handle_ptr);
        DisconnectNamedPipe(*local.server_named_pipe_handle_ptr);
        local.server_named_pipe_handle_ptr = nullptr;
    }
    else if (local.client_named_pipe_handle_ptr) {
        CancelIo(*local.client_named_pipe_handle_ptr);
        _close_handle(*local.client_named_pipe_handle_ptr);
        local.client_named_pipe_handle_ptr = nullptr;
    }
}

template <typename T, size_t N>
inline void WaitForWorkerThreads(T (& locals)[N], bool cancel_io, bool wait_all = true)
{
    size_t num_valid_handles = 0;

    // CAUTION:
    //  The `WaitForMultipleObjects` can not wait an array with `INVALID_HANDLE_VALUE` values.
    //

    HANDLE valid_handles[sizeof(locals) / sizeof(locals[0])];

    utility::for_each_unroll(locals, [&](auto & local) {
        if (_is_valid_handle(local.thread_handle)) {
            if (cancel_io) {
                // cancel I/O before wait on a thread
                local.thread_data.cancel_io = true;
                CancelSynchronousIo(local.thread_handle);
                DisconnectNamedPipeThreadLocal(local);
            }

            valid_handles[num_valid_handles] = local.thread_handle;
            num_valid_handles++;
        }
    });

    if (!num_valid_handles) return;

    WaitForMultipleObjects(num_valid_handles, valid_handles, wait_all ? TRUE : FALSE, INFINITE);

    // reset handles
    utility::for_each_unroll(locals, [&](auto & local) {
        local.thread_handle = INVALID_HANDLE_VALUE;
    });

    //return num_valid_handles;
}

template <typename T>
inline void WaitForWorkerThreads(T & local, bool cancel_io, bool wait_all = true)
{
    return WaitForWorkerThreads(make_singular_array(local), cancel_io, wait_all);
}

template <typename T>
inline void WaitForStreamPipeThreads(T && locals, bool cancel_io, bool wait_all = true)
{
    static_assert(!std::is_same<typename std::remove_extent<T>::type, StreamPipeThreadLocals>::value, "T must be StreamPipeThreadLocals class");
    return WaitForWorkerThreads(std::forward<T>(locals), cancel_io, wait_all);
}

template <typename T>
inline void WaitForConnectNamedPipeThreads(T && locals, bool cancel_io, bool wait_all = true)
{
    static_assert(!std::is_same<typename std::remove_extent<T>::type, ConnectNamedPipeThreadLocals>::value, "T must be ConnectNamedPipeThreadLocals class");
    return WaitForWorkerThreads(std::forward<T>(locals), cancel_io, wait_all);
}

#endif
