#include "callf.hpp"
#include "execute.hpp"

//#ifdef _UNICODE
//#error Unicode is not supported.
//#endif


// sets true just after the CreateProcess or ShellExecute success execute
bool g_is_process_executed = false;


inline int invalid_format_flag(const TCHAR * arg)
{
    if (!g_flags.no_print_gen_error_string) {
        _print_stderr_message(_T("flag format is invalid: \"%s\"\n"), arg);
    }
    return err_invalid_format;
}

inline int invalid_format_flag_message(const TCHAR * fmt, ...)
{
    if (!g_flags.no_print_gen_error_string) {
        va_list vl;
        va_start(vl, fmt);
        _print_stderr_message_va(_T("flag format is invalid: %s\n"), vl);
        va_end(vl);
    }
    return err_invalid_format;
}

int _tmain(int argc, const TCHAR * argv[])
{
#if _DEBUG
    MessageBoxA(NULL, "", "", MB_OK);
#endif

    if (!argc || !argv[0]) {
        return err_unspecified;
    }

    // NOTE:
    //  While the current process being started it's console can be hidden by the CreateProcess/ShellExecute from the parent process.
    //  So we have to check the current process console window on visibility and if it is not exist or not visible and
    //  the parent process console is visible, then make temporary reattachment to a parent process console.
    //  Otherwise the output into the stdout/stderr from here won't be visible by the user until the `/attach-parent-console` flag is
    //  applied.
    //  If you don't want such behaviour, then you have to use the `/disable-conout-reattach-to-visible-console` flag.
    //

    const TCHAR * arg;
    int arg_offset = 1;

    bool detach_console = false;

    // silent flags preprocess w/o any errors to search for prioritized flags
    while (argc >= arg_offset + 1)
    {
        arg = argv[arg_offset];

        if (!tstrcmp(arg, _T("/disable-conout-reattach-to-visible-console"))) {
            g_flags.disable_conout_reattach_to_visible_console = true;
        }
        else if (!tstrcmp(arg, _T("/disable-conout-duplicate-to-parent-console-on-error"))) {
            g_flags.disable_conout_duplicate_to_parent_console_on_error = true;
        }
        else if (!tstrcmp(arg, _T("/create-console"))) {
            g_flags.create_console = true;
        }
        else if (!tstrcmp(arg, _T("/create-console-title"))) {
            arg_offset += 1;
            if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                g_options.create_console_title = arg;
                g_options.has.create_console_title = true;
            }
        }
        else if (!tstrcmp(arg, _T("/own-console-title"))) {
            arg_offset += 1;
            if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                g_options.own_console_title = arg;
                g_options.has.own_console_title = true;
            }
        }
        else if (!tstrcmp(arg, _T("/console-title"))) {
            arg_offset += 1;
            if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                g_options.console_title = arg;
                g_options.has.console_title = true;
            }
        }
        else if (!tstrcmp(arg, _T("/attach-parent-console"))) {
            g_flags.attach_parent_console = true;
        }

        arg_offset += 1;
    }

    if (!g_flags.disable_conout_duplicate_to_parent_console_on_error) {
        // enable console output buffering by default
        g_enable_conout_prints_buffering = true;
    }

    bool is_conout_reattached_to_visible_console = false;
    bool is_console_window_inited = false;

    std::vector<_ConsoleWindowOwnerProc> console_window_owner_procs;

    // NOTE:
    //  labda to bypass msvc error: `error C2712: Cannot use __try in functions that require object unwinding`
    //
    return [&]() -> int { __try {
        return [&]() -> int {
            if (!g_flags.disable_conout_reattach_to_visible_console) {
                // check if console is not visible
                HWND inherited_console_window = GetConsoleWindow();
                if (inherited_console_window && !IsWindowVisible(inherited_console_window)) {
                    if (g_flags.create_console) {
                        // check if console can be just unhided
                        g_current_proc_console_window = _find_console_window_owner_procs(NULL, g_parent_proc_id);
                        is_console_window_inited = true;

                        is_conout_reattached_to_visible_console = true;

                        if (!g_current_proc_console_window) {
                            FreeConsole();
                            AllocConsole();
                        }

                        if (g_options.has.create_console_title) {
                            SetConsoleTitle(g_options.create_console_title.c_str());
                        }
                        else if (g_options.has.own_console_title) {
                            SetConsoleTitle(g_options.own_console_title.c_str());
                        }
                        else if (g_options.has.console_title) {
                            SetConsoleTitle(g_options.console_title.c_str());
                        }

                        // update visibility state
                        inherited_console_window = GetConsoleWindow();
                        ShowWindow(inherited_console_window, SW_SHOW);
                        ShowWindow(inherited_console_window, SW_SHOW); // WTF: second ShowWindow (not UpdateWindow) is required, otherwise does not show in Release
                    }
                    else {
                        // check if parent process console can be attached and visible
                        g_current_proc_console_window = _find_console_window_owner_procs(&console_window_owner_procs, g_parent_proc_id);
                        is_console_window_inited = true;

                        _ConsoleWindowOwnerProc ancestor_console_window_owner_proc;

                        // search ancestor console window owner process
                        for (const auto & console_window_owner_proc : console_window_owner_procs) {
                            if (console_window_owner_proc.console_window) {
                                ancestor_console_window_owner_proc = console_window_owner_proc;
                                break;
                            }
                        }

                        if (ancestor_console_window_owner_proc.console_window &&
                            inherited_console_window != ancestor_console_window_owner_proc.console_window &&
                            IsWindowVisible(ancestor_console_window_owner_proc.console_window) &&
                            ancestor_console_window_owner_proc.proc_id != (DWORD)-1) {
                            // reattach to parent process console window
                            is_conout_reattached_to_visible_console = true;

                            FreeConsole();
                            AttachConsole(ancestor_console_window_owner_proc.proc_id);

                            if (g_options.has.console_title) {
                                SetConsoleTitle(g_options.console_title.c_str());
                            }
                        }
                    }
                }
            }

            if (!is_conout_reattached_to_visible_console) {
                if (g_flags.create_console) {
                    // check if the current process console existence
                    if (!is_console_window_inited) {
                        g_current_proc_console_window = _find_console_window_owner_procs(NULL, g_parent_proc_id);
                    }

                    if (!g_current_proc_console_window) {
                        HWND inherited_console_window = GetConsoleWindow();
                        if (inherited_console_window) {
                            FreeConsole();
                        }
                        AllocConsole();

                        if (g_options.has.create_console_title) {
                            SetConsoleTitle(g_options.create_console_title.c_str());
                        }
                        else if (g_options.has.own_console_title) {
                            SetConsoleTitle(g_options.own_console_title.c_str());
                        }
                        else if (g_options.has.console_title) {
                            SetConsoleTitle(g_options.console_title.c_str());
                        }
                    }
                }
                else if (g_flags.attach_parent_console) {
                    // check if the current process console can be attached
                    HWND inherited_console_window = GetConsoleWindow();
                    g_current_proc_console_window = _find_console_window_owner_procs(&console_window_owner_procs, g_parent_proc_id);

                    _ConsoleWindowOwnerProc ancestor_console_window_owner_proc;

                    // search ancestor console window owner process
                    for (const auto & console_window_owner_proc : console_window_owner_procs) {
                        if (console_window_owner_proc.console_window) {
                            ancestor_console_window_owner_proc = console_window_owner_proc;
                            break;
                        }
                    }

                    if (ancestor_console_window_owner_proc.console_window &&
                        inherited_console_window != ancestor_console_window_owner_proc.console_window &&
                        ancestor_console_window_owner_proc.proc_id != (DWORD)-1) {
                        // reattach to parent process console window
                        is_conout_reattached_to_visible_console = true;

                        FreeConsole();
                        AttachConsole(ancestor_console_window_owner_proc.proc_id);

                        if (g_options.has.console_title) {
                            SetConsoleTitle(g_options.console_title.c_str());
                        }
                    }
                }
                else {
                    if (!is_console_window_inited) {
                        g_current_proc_console_window = _find_console_window_owner_procs(NULL, g_parent_proc_id);
                        is_console_window_inited = true;
                    }

                    if (g_current_proc_console_window && g_options.has.own_console_title) {
                        SetConsoleTitle(g_options.own_console_title.c_str());
                    }
                    else if (g_options.has.console_title) {
                        SetConsoleTitle(g_options.console_title.c_str());
                    }
                }
            }

            arg_offset = 1;

            if(argc >= arg_offset + 1 && argv[arg_offset] && !tstrcmp(argv[arg_offset], _T("/?"))) {
                _print_raw_message(
                    1, "%s",
#include "help_inl.hpp"
                );

                return err_help_output;
            }

            // read flags
            while (argc >= arg_offset + 1)
            {
                arg = argv[arg_offset];
                if (!arg) return invalid_format_flag(arg);

                if (tstrncmp(arg, _T("/"), 1)) {
                    break;
                }

                if (!tstrncmp(arg, _T("//"), 2)) {
                    arg_offset += 1;
                    break;
                }

                // CAUTION:
                //  Use `if_break` instead of chained if-else sequence to avoid the MSVC compiler error:
                //  `fatal error C1061: compiler limit : blocks nested too deeply`
                //

                if_break(true) {
                    if (!tstrcmp(arg, _T("/chcp-in"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            g_options.chcp_in = _ttoi(arg);
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/chcp-out"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            g_options.chcp_out = _ttoi(arg);
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/ret-create-proc"))) {
                        g_flags.ret_create_proc = true;
                        break;
                    }
                    if (!tstrcmp(arg, _T("/ret-win-error"))) {
                        g_flags.ret_win_error = true;
                        break;
                    }
                    if (!tstrcmp(arg, _T("/win-error-langid"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            g_options.win_error_langid = _ttoi(arg);
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/ret-child-exit"))) {
                        g_flags.ret_child_exit = true;
                        break;
                    }
                    if (!tstrcmp(arg, _T("/print-win-error-string"))) {
                        g_flags.print_win_error_string = true;
                        break;
                    }
                    if (!tstrcmp(arg, _T("/print-shell-error-string"))) {
                        g_flags.print_shell_error_string = true;
                        break;
                    }
                    if (!tstrcmp(arg, _T("/no-print-gen-error-string"))) {
                        g_flags.no_print_gen_error_string = true;
                        break;
                    }
                    if (!tstrcmp(arg, _T("/no-sys-dialog-ui"))) {
                        g_flags.no_sys_dialog_ui = true;
                        break;
                    }
                    if (!tstrcmp(arg, _T("/shell-exec"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            g_options.shell_exec_verb = arg;
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/D"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            g_options.change_current_dir = arg;
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/no-wait"))) {
                        g_flags.no_wait = true;
                        break;
                    }
                    if (!tstrcmp(arg, _T("/no-window"))) {
                        g_flags.no_window = true;
                        break;
                    }
                    if (!tstrcmp(arg, _T("/no-expand-env"))) {
                        g_flags.no_expand_env = true;
                        break;
                    }
                    if (!tstrcmp(arg, _T("/no-subst-vars"))) {
                        g_flags.no_subst_vars = true;
                        break;
                    }
                    if (!tstrcmp(arg, _T("/no-std-inherit"))) {
                        g_flags.no_std_inherit = true;
                        break;
                    }
                    if (!tstrcmp(arg, _T("/pipe-stdin-to-stdout"))) {
                        g_flags.pipe_stdin_to_stdout = true;
                        break;
                    }
                    if (!tstrcmp(arg, _T("/shell-exec-expand-env"))) {
                        g_flags.shell_exec_expand_env = true;
                        break;
                    }
                    if (!tstrcmp(arg, _T("/init-com"))) {
                        g_flags.init_com = true;
                        break;
                    }
                    if (!tstrcmp(arg, _T("/wait-child-start"))) {
                        g_flags.wait_child_start = true;
                        break;
                    }
                    if (!tstrcmp(arg, _T("/showas"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            const int showas_value = _ttoi(arg);
                            if (showas_value >= 0) {
                                g_options.show_as = showas_value;
                            }
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/create-child-console"))) {
                        g_flags.create_child_console = true;
                        break;
                    }
                    if (!tstrcmp(arg, _T("/create-console"))) {
                        // ignore
                        break;
                    }
                    if (!tstrcmp(arg, _T("/create-console-title"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            // ignore
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/own-console-title"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            // ignore
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/console-title"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            // ignore
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/attach-parent-console"))) {
                        // ignore
                        break;
                    }
                    if (!tstrcmp(arg, _T("/reopen-stdin"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            g_options.reopen_stdin_as_file = arg;
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/reopen-stdin-as-server-pipe"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            g_options.reopen_stdin_as_server_pipe = arg;
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/reopen-stdin-as-server-pipe-connect-timeout"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            const int timeout_ms = _ttoi(arg);
                            if (timeout_ms > 0) {
                                g_options.reopen_stdin_as_server_pipe_connect_timeout_ms = timeout_ms;
                            }
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/reopen-stdin-as-server-pipe-in-buf-size"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            const int buf_size = _ttoi(arg);
                            if (buf_size > 0) {
                                g_options.reopen_stdin_as_server_pipe_in_buf_size = buf_size;
                            }
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/reopen-stdin-as-server-pipe-out-buf-size"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            const int buf_size = _ttoi(arg);
                            if (buf_size > 0) {
                                g_options.reopen_stdin_as_server_pipe_out_buf_size = buf_size;
                            }
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/reopen-stdin-as-client-pipe"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            g_options.reopen_stdin_as_client_pipe = arg;
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/reopen-stdin-as-client-pipe-connect-timeout"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            const int timeout_ms = _ttoi(arg);
                            if (timeout_ms > 0) {
                                g_options.reopen_stdin_as_client_pipe_connect_timeout_ms = timeout_ms;
                            }
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/reopen-stdout"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            g_options.reopen_stdout_as_file = arg;
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/reopen-stdout-as-server-pipe"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            g_options.reopen_stdout_as_server_pipe = arg;
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/reopen-stdout-as-server-pipe-connect-timeout"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            const int timeout_ms = _ttoi(arg);
                            if (timeout_ms > 0) {
                                g_options.reopen_stdout_as_server_pipe_connect_timeout_ms = timeout_ms;
                            }
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/reopen-stdout-as-server-pipe-in-buf-size"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            const int buf_size = _ttoi(arg);
                            if (buf_size > 0) {
                                g_options.reopen_stdout_as_server_pipe_in_buf_size = buf_size;
                            }
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/reopen-stdout-as-server-pipe-out-buf-size"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            const int buf_size = _ttoi(arg);
                            if (buf_size > 0) {
                                g_options.reopen_stdout_as_server_pipe_out_buf_size = buf_size;
                            }
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/reopen-stdout-as-client-pipe"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            g_options.reopen_stdout_as_client_pipe = arg;
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/reopen-stdout-as-client-pipe-connect-timeout"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            const int timeout_ms = _ttoi(arg);
                            if (timeout_ms > 0) {
                                g_options.reopen_stdout_as_client_pipe_connect_timeout_ms = timeout_ms;
                            }
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/reopen-stderr"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            g_options.reopen_stderr_as_file = arg;
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/reopen-stderr-as-server-pipe"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            g_options.reopen_stderr_as_server_pipe = arg;
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/reopen-stderr-as-server-pipe-connect-timeout"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            const int timeout_ms = _ttoi(arg);
                            if (timeout_ms > 0) {
                                g_options.reopen_stderr_as_server_pipe_connect_timeout_ms = timeout_ms;
                            }
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/reopen-stderr-as-server-pipe-in-buf-size"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            const int buf_size = _ttoi(arg);
                            if (buf_size > 0) {
                                g_options.reopen_stderr_as_server_pipe_in_buf_size = buf_size;
                            }
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/reopen-stderr-as-server-pipe-out-buf-size"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            const int buf_size = _ttoi(arg);
                            if (buf_size > 0) {
                                g_options.reopen_stderr_as_server_pipe_out_buf_size = buf_size;
                            }
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/reopen-stderr-as-client-pipe"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            g_options.reopen_stderr_as_client_pipe = arg;
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/reopen-stderr-as-client-pipe-connect-timeout"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            const int timeout_ms = _ttoi(arg);
                            if (timeout_ms > 0) {
                                g_options.reopen_stderr_as_client_pipe_connect_timeout_ms = timeout_ms;
                            }
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/reopen-stdout-truncate"))) {
                        g_flags.reopen_stdout_file_truncate = true;
                        break;
                    }
                    if (!tstrcmp(arg, _T("/reopen-stderr-truncate"))) {
                        g_flags.reopen_stderr_file_truncate = true;
                        break;
                    }
                    if (!tstrcmp(arg, _T("/stdout-dup"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            const int fileno_value = _ttoi(arg);
                            if (fileno_value >= 0) {
                                g_options.stdout_dup = fileno_value;
                            }
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/stderr-dup"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            const int fileno_value = _ttoi(arg);
                            if (fileno_value >= 0) {
                                g_options.stderr_dup = fileno_value;
                            }
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/stdin-output-flush"))) {
                        g_flags.stdin_output_flush = true;
                        break;
                    }
                    if (!tstrcmp(arg, _T("/stdout-flush"))) {
                        g_flags.stdout_flush = true;
                        break;
                    }
                    if (!tstrcmp(arg, _T("/stderr-flush"))) {
                        g_flags.stderr_flush = true;
                        break;
                    }
                    if (!tstrcmp(arg, _T("/output-flush"))) {
                        g_flags.output_flush = true;
                        break;
                    }
                    if (!tstrcmp(arg, _T("/inout-flush"))) {
                        g_flags.inout_flush = true;
                        break;
                    }
                    if (!tstrcmp(arg, _T("/create-outbound-pipe-from-stdin"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            g_options.create_outbound_pipe_from_stdin = arg;
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/create-outbound-pipe-from-stdin-connect-timeout"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            const int timeout_ms = _ttoi(arg);
                            if (timeout_ms > 0) {
                                g_options.create_outbound_pipe_from_stdin_connect_timeout_ms = timeout_ms;
                            }
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/create-outbound-pipe-from-stdin-in-buf-size"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            const int buf_size = _ttoi(arg);
                            if (buf_size > 0) {
                                g_options.create_outbound_pipe_from_stdin_in_buf_size = buf_size;
                            }
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/create-outbound-pipe-from-stdin-out-buf-size"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            const int buf_size = _ttoi(arg);
                            if (buf_size > 0) {
                                g_options.create_outbound_pipe_from_stdin_out_buf_size = buf_size;
                            }
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/create-inbound-pipe-to-stdout"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            g_options.create_inbound_pipe_to_stdout = arg;
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/create-inbound-pipe-to-stdout-connect-timeout"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            const int timeout_ms = _ttoi(arg);
                            if (timeout_ms > 0) {
                                g_options.create_inbound_pipe_to_stdout_connect_timeout_ms = timeout_ms;
                            }
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/create-inbound-pipe-to-stdout-in-buf-size"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            const int buf_size = _ttoi(arg);
                            if (buf_size > 0) {
                                g_options.create_inbound_pipe_to_stdout_in_buf_size = buf_size;
                            }
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/create-inbound-pipe-to-stdout-out-buf-size"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            const int buf_size = _ttoi(arg);
                            if (buf_size > 0) {
                                g_options.create_inbound_pipe_to_stdout_out_buf_size = buf_size;
                            }
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/create-inbound-pipe-to-stderr"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            g_options.create_inbound_pipe_to_stderr = arg;
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/create-inbound-pipe-to-stderr-connect-timeout"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            const int timeout_ms = _ttoi(arg);
                            if (timeout_ms > 0) {
                                g_options.create_inbound_pipe_to_stderr_connect_timeout_ms = timeout_ms;
                            }
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/create-inbound-pipe-to-stderr-in-buf-size"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            const int buf_size = _ttoi(arg);
                            if (buf_size > 0) {
                                g_options.create_inbound_pipe_to_stderr_in_buf_size = buf_size;
                            }
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/create-inbound-pipe-to-stderr-out-buf-size"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            const int buf_size = _ttoi(arg);
                            if (buf_size > 0) {
                                g_options.create_inbound_pipe_to_stderr_out_buf_size = buf_size;
                            }
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/tee-stdin"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            g_options.tee_stdin_to_file = arg;
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/tee-stdin-to-server-pipe"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            g_options.tee_stdin_to_server_pipe = arg;
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/tee-stdin-to-server-pipe-connect-timeout"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            const int timeout_ms = _ttoi(arg);
                            if (timeout_ms > 0) {
                                g_options.tee_stdin_to_server_pipe_connect_timeout_ms = timeout_ms;
                            }
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/tee-stdin-to-server-pipe-in-buf-size"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            const int buf_size = _ttoi(arg);
                            if (buf_size > 0) {
                                g_options.tee_stdin_to_server_pipe_in_buf_size = buf_size;
                            }
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/tee-stdin-to-server-pipe-out-buf-size"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            const int buf_size = _ttoi(arg);
                            if (buf_size > 0) {
                                g_options.tee_stdin_to_server_pipe_out_buf_size = buf_size;
                            }
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/tee-stdin-to-client-pipe"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            g_options.tee_stdin_to_client_pipe = arg;
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/tee-stdin-to-client-pipe-connect-timeout"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            const int timeout_ms = _ttoi(arg);
                            if (timeout_ms > 0) {
                                g_options.tee_stdin_to_client_pipe_connect_timeout_ms = timeout_ms;
                            }
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/tee-stdout"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            g_options.tee_stdout_to_file = arg;
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/tee-stdout-to-server-pipe"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            g_options.tee_stdout_to_server_pipe = arg;
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/tee-stdout-to-server-pipe-connect-timeout"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            const int timeout_ms = _ttoi(arg);
                            if (timeout_ms > 0) {
                                g_options.tee_stdout_to_server_pipe_connect_timeout_ms = timeout_ms;
                            }
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/tee-stdout-to-server-pipe-in-buf-size"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            const int buf_size = _ttoi(arg);
                            if (buf_size > 0) {
                                g_options.tee_stdout_to_server_pipe_in_buf_size = buf_size;
                            }
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/tee-stdout-to-server-pipe-out-buf-size"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            const int buf_size = _ttoi(arg);
                            if (buf_size > 0) {
                                g_options.tee_stdout_to_server_pipe_out_buf_size = buf_size;
                            }
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/tee-stdout-to-client-pipe"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            g_options.tee_stdout_to_client_pipe = arg;
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/tee-stdout-to-client-pipe-connect-timeout"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            const int timeout_ms = _ttoi(arg);
                            if (timeout_ms > 0) {
                                g_options.tee_stdout_to_client_pipe_connect_timeout_ms = timeout_ms;
                            }
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/tee-stderr"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            g_options.tee_stderr_to_file = arg;
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/tee-stderr-to-server-pipe"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            g_options.tee_stderr_to_server_pipe = arg;
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/tee-stderr-to-server-pipe-connect-timeout"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            const int timeout_ms = _ttoi(arg);
                            if (timeout_ms > 0) {
                                g_options.tee_stderr_to_server_pipe_connect_timeout_ms = timeout_ms;
                            }
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/tee-stderr-to-server-pipe-in-buf-size"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            const int buf_size = _ttoi(arg);
                            if (buf_size > 0) {
                                g_options.tee_stderr_to_server_pipe_in_buf_size = buf_size;
                            }
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/tee-stderr-to-server-pipe-out-buf-size"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            const int buf_size = _ttoi(arg);
                            if (buf_size > 0) {
                                g_options.tee_stderr_to_server_pipe_out_buf_size = buf_size;
                            }
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/tee-stderr-to-client-pipe"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            g_options.tee_stderr_to_client_pipe = arg;
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/tee-stderr-to-client-pipe-connect-timeout"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            const int timeout_ms = _ttoi(arg);
                            if (timeout_ms > 0) {
                                g_options.tee_stderr_to_client_pipe_connect_timeout_ms = timeout_ms;
                            }
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/tee-stdin-truncate"))) {
                        g_flags.tee_stdin_file_truncate = true;
                        break;
                    }
                    if (!tstrcmp(arg, _T("/tee-stdout-truncate"))) {
                        g_flags.tee_stdout_file_truncate = true;
                        break;
                    }
                    if (!tstrcmp(arg, _T("/tee-stderr-truncate"))) {
                        g_flags.tee_stderr_file_truncate = true;
                        break;
                    }
                    if (!tstrcmp(arg, _T("/tee-stdin-file-flush"))) {
                        g_flags.tee_stdin_file_flush = true;
                        break;
                    }
                    if (!tstrcmp(arg, _T("/tee-stdout-file-flush"))) {
                        g_flags.tee_stdout_file_flush = true;
                        break;
                    }
                    if (!tstrcmp(arg, _T("/tee-stderr-file-flush"))) {
                        g_flags.tee_stderr_file_flush = true;
                        break;
                    }
                    if (!tstrcmp(arg, _T("/tee-stdin-pipe-flush"))) {
                        g_flags.tee_stdin_pipe_flush = true;
                        break;
                    }
                    if (!tstrcmp(arg, _T("/tee-stdout-pipe-flush"))) {
                        g_flags.tee_stdout_pipe_flush = true;
                        break;
                    }
                    if (!tstrcmp(arg, _T("/tee-stderr-pipe-flush"))) {
                        g_flags.tee_stderr_pipe_flush = true;
                        break;
                    }
                    if (!tstrcmp(arg, _T("/tee-stdin-flush"))) {
                        g_flags.tee_stdin_flush = true;
                        break;
                    }
                    if (!tstrcmp(arg, _T("/tee-stdout-flush"))) {
                        g_flags.tee_stdout_flush = true;
                        break;
                    }
                    if (!tstrcmp(arg, _T("/tee-stderr-flush"))) {
                        g_flags.tee_stderr_flush = true;
                        break;
                    }
                    if (!tstrcmp(arg, _T("/tee-output-flush"))) {
                        g_flags.tee_output_flush = true;
                        break;
                    }
                    if (!tstrcmp(arg, _T("/tee-inout-flush"))) {
                        g_flags.tee_inout_flush = true;
                        break;
                    }
                    if (!tstrcmp(arg, _T("/tee-stdin-pipe-buf-size"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            const int buf_size = _ttoi(arg);
                            if (buf_size > 0) {
                                g_options.tee_stdin_pipe_buf_size = buf_size;
                            }
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/tee-stdout-pipe-buf-size"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            const int buf_size = _ttoi(arg);
                            if (buf_size > 0) {
                                g_options.tee_stdout_pipe_buf_size = buf_size;
                            }
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/tee-stderr-pipe-buf-size"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            const int buf_size = _ttoi(arg);
                            if (buf_size > 0) {
                                g_options.tee_stderr_pipe_buf_size = buf_size;
                            }
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/tee-stdin-read-buf-size"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            const int buf_size = _ttoi(arg);
                            if (buf_size > 0) {
                                g_options.tee_stdin_read_buf_size = buf_size;
                            }
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/tee-stdout-read-buf-size"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            const int buf_size = _ttoi(arg);
                            if (buf_size > 0) {
                                g_options.tee_stdout_read_buf_size = buf_size;
                            }
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/tee-stderr-read-buf-size"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            const int buf_size = _ttoi(arg);
                            if (buf_size > 0) {
                                g_options.tee_stderr_read_buf_size = buf_size;
                            }
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/tee-stdin-dup"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            const int fileno_value = _ttoi(arg);
                            if (fileno_value >= 0) {
                                g_options.tee_stdin_dup = fileno_value;
                            }
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/tee-stdout-dup"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            const int fileno_value = _ttoi(arg);
                            if (fileno_value >= 0) {
                                g_options.tee_stdout_dup = fileno_value;
                            }
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/tee-stderr-dup"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            const int fileno_value = _ttoi(arg);
                            if (fileno_value >= 0) {
                                g_options.tee_stderr_dup = fileno_value;
                            }
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/mutex-std-writes"))) {
                        g_flags.mutex_std_writes = true;
                        break;
                    }
                    if (!tstrcmp(arg, _T("/mutex-tee-file-writes"))) {
                        g_flags.mutex_tee_file_writes = true;
                        break;
                    }
                    if (!tstrcmp(arg, _T("/stdin-echo"))) {
                        arg_offset += 1;
                        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                            const int stdin_echo = _ttoi(arg);
                            if (stdin_echo >= 0) {
                                g_options.stdin_echo = stdin_echo;
                            }
                        }
                        else return invalid_format_flag(arg);
                        break;
                    }
                    if (!tstrcmp(arg, _T("/eval-backslash-esc")) || !tstrcmp(arg, _T("/e"))) {
                        g_flags.eval_backslash_esc = true;
                        break;
                    }
                    if (!tstrcmp(arg, _T("/eval-dbl-backslash-esc")) || !tstrcmp(arg, _T("/e\\\\"))) {
                        g_flags.eval_dbl_backslash_esc = true;
                        break;
                    }
                    if (!tstrcmp(arg, _T("/disable-conout-reattach-to-visible-console"))) {
                        // ignore
                        break;
                    }
                    if (!tstrcmp(arg, _T("/disable-conout-duplicate-to-parent-console-on-error"))) {
                        // ignore
                        break;
                    }

                    return invalid_format_flag(arg);
                }

                arg_offset += 1;
            }

            // reopen std

            int reopen_stdin_as_count = 0;
            int reopen_stdout_as_count = 0;
            int reopen_stderr_as_count = 0;

            if (!g_options.reopen_stdin_as_file.empty()) {
                reopen_stdin_as_count++;
            }
            if (!g_options.reopen_stdin_as_server_pipe.empty()) {
                reopen_stdin_as_count++;
            }
            if (!g_options.reopen_stdin_as_client_pipe.empty()) {
                reopen_stdin_as_count++;
            }

            if (!g_options.reopen_stdout_as_file.empty()) {
                reopen_stdout_as_count++;
            }
            if (!g_options.reopen_stdout_as_server_pipe.empty()) {
                reopen_stdout_as_count++;
            }
            if (!g_options.reopen_stdout_as_client_pipe.empty()) {
                reopen_stdout_as_count++;
            }

            if (!g_options.reopen_stderr_as_file.empty()) {
                reopen_stderr_as_count++;
            }
            if (!g_options.reopen_stderr_as_server_pipe.empty()) {
                reopen_stderr_as_count++;
            }
            if (!g_options.reopen_stderr_as_client_pipe.empty()) {
                reopen_stderr_as_count++;
            }

            if (reopen_stdin_as_count > 1) {
                return invalid_format_flag_message(_T("stdin reopen is mixed\n"));
            }

            if (reopen_stdout_as_count > 1 || reopen_stdout_as_count == 1 && g_options.stdout_dup != -1) {
                return invalid_format_flag_message(_T("stdout reopen is mixed\n"));
            }
            if (reopen_stderr_as_count > 1 || reopen_stderr_as_count == 1 && g_options.stderr_dup != -1) {
                return invalid_format_flag_message(_T("stderr reopen is mixed\n"));
            }

            // std dup

            if (g_options.stdout_dup != -1 && g_options.stdout_dup != 2) {
                return invalid_format_flag_message(_T("stdout duplication has invalid fileno: fileno=%i\n"), g_options.stdout_dup);
            }
            if (g_options.stderr_dup != -1 && g_options.stderr_dup != 1) {
                return invalid_format_flag_message(_T("stderr duplication has invalid fileno: fileno=%i\n"), g_options.stderr_dup);
            }

            // tee std

            int tee_stdin_as_count = 0;
            int tee_stdout_as_count = 0;
            int tee_stderr_as_count = 0;

            int tee_stdin_as_named_pipe_count = 0;
            int tee_stdout_as_named_pipe_count = 0;
            int tee_stderr_as_named_pipe_count = 0;

            if (!g_options.tee_stdin_to_file.empty()) {
                tee_stdin_as_count++;
            }
            if (!g_options.tee_stdin_to_server_pipe.empty()) {
                tee_stdin_as_count++;
                tee_stdin_as_named_pipe_count++;
            }
            if (!g_options.tee_stdin_to_client_pipe.empty()) {
                tee_stdin_as_count++;
                tee_stdin_as_named_pipe_count++;
            }

            if (!g_options.tee_stdout_to_file.empty()) {
                tee_stdout_as_count++;
            }
            if (!g_options.tee_stdout_to_server_pipe.empty()) {
                tee_stdout_as_count++;
                tee_stdout_as_named_pipe_count++;
            }
            if (!g_options.tee_stdout_to_client_pipe.empty()) {
                tee_stdout_as_count++;
                tee_stdout_as_named_pipe_count++;
            }

            if (!g_options.tee_stderr_to_file.empty()) {
                tee_stderr_as_count++;
            }
            if (!g_options.tee_stderr_to_server_pipe.empty()) {
                tee_stderr_as_count++;
                tee_stderr_as_named_pipe_count++;
            }
            if (!g_options.tee_stderr_to_client_pipe.empty()) {
                tee_stderr_as_count++;
                tee_stderr_as_named_pipe_count++;
            }

            if (tee_stdin_as_count >= 1 && g_options.tee_stdin_dup != -1 || tee_stdin_as_named_pipe_count > 1) {
                return invalid_format_flag_message(_T("tee stdin is mixed\n"));
            }
            if (tee_stdout_as_count >= 1 && g_options.tee_stdout_dup != -1 || tee_stdout_as_named_pipe_count > 1) {
                return invalid_format_flag_message(_T("tee stdout is mixed\n"));
            }
            if (tee_stderr_as_count >= 1 && g_options.tee_stderr_dup != -1 || tee_stderr_as_named_pipe_count > 1) {
                return invalid_format_flag_message(_T("tee stderr is mixed\n"));
            }

            // tee std dup

            if (g_options.tee_stdin_dup != -1) {
                if (g_options.tee_stdin_dup != 1 && g_options.tee_stdin_dup != 2) {
                    return invalid_format_flag_message(_T("tee stdin duplication has invalid fileno: fileno=%i\n"), g_options.tee_stdin_dup);
                }
                else if (g_options.tee_stdin_dup == 1 && !tee_stdout_as_count ||
                         g_options.tee_stdin_dup == 2 && !tee_stderr_as_count) {
                    return invalid_format_flag_message(_T("tee stdin duplication of not opened handle: fileno=%i\n"), g_options.tee_stdin_dup);
                }
            }

            if (g_options.tee_stdout_dup != -1) {
                if (g_options.tee_stdout_dup != 0 && g_options.tee_stdout_dup != 2) {
                    return invalid_format_flag_message(_T("tee stdout duplication has invalid fileno: fileno=%i\n"), g_options.tee_stdout_dup);
                }
                else if (g_options.tee_stdout_dup == 0 && !tee_stdin_as_count ||
                         g_options.tee_stdout_dup == 2 && !tee_stderr_as_count) {
                    return invalid_format_flag_message(_T("tee stdout duplication of not opened handle: fileno=%i\n"), g_options.tee_stdout_dup);
                }
            }

            if (g_options.tee_stderr_dup != -1) {
                if (g_options.tee_stderr_dup != 0 && g_options.tee_stderr_dup != 1) {
                    return invalid_format_flag_message(_T("tee stderr duplication has invalid fileno: fileno=%i\n"), g_options.tee_stderr_dup);
                }
                else if (g_options.tee_stderr_dup == 0 && !tee_stdin_as_count ||
                         g_options.tee_stderr_dup == 1 && !tee_stdout_as_count) {
                    return invalid_format_flag_message(_T("tee stderr duplication of not opened handle: fileno=%i\n"), g_options.tee_stderr_dup);
                }
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
                        _print_stderr_message(_T("format arguments are empty\n"));
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
                        _print_stderr_message(_T("file path format argument is empty\n"));
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

            return ExecuteProcess(
                app_args.fmt_str ? app_out_args.fmt_str.c_str() : (LPCTSTR)NULL,
                app_args.fmt_str ? app_out_args.fmt_str.length() : 0,
                cmd_args.fmt_str ? cmd_out_args.fmt_str.c_str() : (LPCTSTR)NULL,
                cmd_args.fmt_str ? cmd_out_args.fmt_str.length() : 0,
                g_flags, g_options
            );
        }();
    }
    __finally {
        [&]() {
            if (g_enable_conout_prints_buffering && !g_is_process_executed) {
                if (!is_console_window_inited || g_current_proc_console_window && !console_window_owner_procs.size()) {
                    g_current_proc_console_window = _find_console_window_owner_procs(&console_window_owner_procs, g_parent_proc_id);
                    is_console_window_inited = true;
                }

                if (g_current_proc_console_window) {
                    _ConsoleWindowOwnerProc ancestor_console_window_owner_proc;

                    // search ancestor console window owner process
                    for (const auto & console_window_owner_proc : console_window_owner_procs) {
                        if (console_window_owner_proc.console_window) {
                            ancestor_console_window_owner_proc = console_window_owner_proc;
                            break;
                        }
                    }

                    // The process is owning the console window and is going to close it.
                    // Detach console before the exit, attach to parent console and does print the saved console prints into a parent console.

                    FreeConsole();
                    if (ancestor_console_window_owner_proc.proc_id != (DWORD)-1) {
                        AttachConsole(ancestor_console_window_owner_proc.proc_id);
                    }

                    for (const auto & conout : g_conout_prints_buf) {
                        if (conout.any_str.is_wstr) {
                            switch (conout.stream_type) {
                            case 1:
                                fputws(conout.any_str.wstr.c_str(), stdout);
                                break;
                            case 2:
                                fputws(conout.any_str.wstr.c_str(), stderr);
                                break;
                            }
                        }
                        else {
                            switch (conout.stream_type) {
                            case 1:
                                fputs(conout.any_str.astr.c_str(), stdout);
                                break;
                            case 2:
                                fputs(conout.any_str.astr.c_str(), stderr);
                                break;
                            }
                        }
                    }
                }
            }
        }();
    }
    }();
}
