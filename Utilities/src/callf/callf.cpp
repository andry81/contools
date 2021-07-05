#include "callf.hpp"
#include "execute.hpp"

//#ifdef _UNICODE
//#error Unicode is not supported.
//#endif


// sets true just after the CreateProcess or ShellExecute success execute
bool g_is_process_executed = false;

// sets true in case if process is not elevated and requested for self elevation
bool g_is_process_elevating = false;


const TCHAR * g_empty_flags_arr[] = {
    _T("")
};

const TCHAR * g_flags_to_preparse_arr[] = {
    _T("/elevate"),
    _T("/create-console"),
    _T("/attach-parent-console"),
    _T("/create-console-title"),
    _T("/own-console-title"),
    _T("/console-title"),
    _T("/disable-conout-reattach-to-visible-console"),
    _T("/disable-conout-duplicate-to-parent-console-on-error")
};

const TCHAR * g_elevate_parent_flags_to_preparse_arr[] = {
    _T("/create-console"),
    _T("/create-console-title"),
    _T("/own-console-title"),
    _T("/console-title"),
};

const TCHAR * g_elevate_child_flags_to_preparse_arr[] = {
    _T("/attach-parent-console"),
};

const TCHAR * g_promote_flags_to_preparse_arr[] = {
    _T("/disable-conout-reattach-to-visible-console"),
    _T("/disable-conout-duplicate-to-parent-console-on-error")
};

const TCHAR * g_promote_parent_flags_to_preparse_arr[] = {
    _T("/disable-conout-reattach-to-visible-console"),
    _T("/disable-conout-duplicate-to-parent-console-on-error")
};

const TCHAR * g_flags_to_parse_arr[] = {
    _T("/chcp-in"),
    _T("/chcp-out"),
    _T("/ret-create-proc"),
    _T("/ret-win-error"),
    _T("/win-error-langid"),
    _T("/ret-child-exit"),
    _T("/print-win-error-string"),
    _T("/print-shell-error-string"),
    _T("/no-print-gen-error-string"),
    _T("/no-sys-dialog-ui"),
    _T("/shell-exec"),
    _T("/shell-exec-expand-env"),
    _T("/D"),
    _T("/no-wait"),
    _T("/no-window"),
    _T("/no-expand-env"),
    _T("/no-subst-vars"),
    _T("/no-std-inherit"),
    _T("/pipe-stdin-to-stdout"),
    _T("/init-com"),
    _T("/wait-child-start"),
    _T("/elevate"),
    _T("/showas"),
    _T("/reopen-stdin"),
    _T("/reopen-stdin-as-server-pipe"),
    _T("/reopen-stdin-as-server-pipe-connect-timeout"),
    _T("/reopen-stdin-as-server-pipe-in-buf-size"),
    _T("/reopen-stdin-as-server-pipe-out-buf-size"),
    _T("/reopen-stdin-as-client-pipe"),
    _T("/reopen-stdin-as-client-pipe-connect-timeout"),
    _T("/reopen-stdout"),
    _T("/reopen-stdout-as-server-pipe"),
    _T("/reopen-stdout-as-server-pipe-connect-timeout"),
    _T("/reopen-stdout-as-server-pipe-in-buf-size"),
    _T("/reopen-stdout-as-server-pipe-out-buf-size"),
    _T("/reopen-stdout-as-client-pipe"),
    _T("/reopen-stdout-as-client-pipe-connect-timeout"),
    _T("/reopen-stderr"),
    _T("/reopen-stderr-as-server-pipe"),
    _T("/reopen-stderr-as-server-pipe-connect-timeout"),
    _T("/reopen-stderr-as-server-pipe-in-buf-size"),
    _T("/reopen-stderr-as-server-pipe-out-buf-size"),
    _T("/reopen-stderr-as-client-pipe"),
    _T("/reopen-stderr-as-client-pipe-connect-timeout"),
    _T("/reopen-stdout-file-truncate"),
    _T("/reopen-stderr-file-truncate"),
    _T("/stdout-dup"),
    _T("/stderr-dup"),
    _T("/stdin-output-flush"),
    _T("/stdout-flush"),
    _T("/stderr-flush"),
    _T("/output-flush"),
    _T("/inout-flush"),
    _T("/create-outbound-server-pipe-from-stdin"),
    _T("/create-outbound-server-pipe-from-stdin-connect-timeout"),
    _T("/create-outbound-server-pipe-from-stdin-in-buf-size"),
    _T("/create-outbound-server-pipe-from-stdin-out-buf-size"),
    _T("/create-inbound-server-pipe-to-stdout"),
    _T("/create-inbound-server-pipe-to-stdout-connect-timeout"),
    _T("/create-inbound-server-pipe-to-stdout-in-buf-size"),
    _T("/create-inbound-server-pipe-to-stdout-out-buf-size"),
    _T("/create-inbound-server-pipe-to-stderr"),
    _T("/create-inbound-server-pipe-to-stderr-connect-timeout"),
    _T("/create-inbound-server-pipe-to-stderr-in-buf-size"),
    _T("/create-inbound-server-pipe-to-stderr-out-buf-size"),
    _T("/tee-stdin"),
    _T("/tee-stdin-to-server-pipe"),
    _T("/tee-stdin-to-server-pipe-connect-timeout"),
    _T("/tee-stdin-to-server-pipe-in-buf-size"),
    _T("/tee-stdin-to-server-pipe-out-buf-size"),
    _T("/tee-stdin-to-client-pipe"),
    _T("/tee-stdin-to-client-pipe-connect-timeout"),
    _T("/tee-stdout"),
    _T("/tee-stdout-to-server-pipe"),
    _T("/tee-stdout-to-server-pipe-connect-timeout"),
    _T("/tee-stdout-to-server-pipe-in-buf-size"),
    _T("/tee-stdout-to-server-pipe-out-buf-size"),
    _T("/tee-stdout-to-client-pipe"),
    _T("/tee-stdout-to-client-pipe-connect-timeout"),
    _T("/tee-stderr"),
    _T("/tee-stderr-to-server-pipe"),
    _T("/tee-stderr-to-server-pipe-connect-timeout"),
    _T("/tee-stderr-to-server-pipe-in-buf-size"),
    _T("/tee-stderr-to-server-pipe-out-buf-size"),
    _T("/tee-stderr-to-client-pipe"),
    _T("/tee-stderr-to-client-pipe-connect-timeout"),
    _T("/tee-stdin-dup"),
    _T("/tee-stdout-dup"),
    _T("/tee-stderr-dup"),
    _T("/tee-stdin-file-truncate"),
    _T("/tee-stdout-file-truncate"),
    _T("/tee-stderr-file-truncate"),
    _T("/tee-stdin-file-flush"),
    _T("/tee-stdout-file-flush"),
    _T("/tee-stderr-file-flush"),
    _T("/tee-stdin-pipe-flush"),
    _T("/tee-stdout-pipe-flush"),
    _T("/tee-stderr-pipe-flush"),
    _T("/tee-stdin-flush"),
    _T("/tee-stdout-flush"),
    _T("/tee-stderr-flush"),
    _T("/tee-output-flush"),
    _T("/tee-inout-flush"),
    _T("/tee-stdin-pipe-buf-size"),
    _T("/tee-stdout-pipe-buf-size"),
    _T("/tee-stderr-pipe-buf-size"),
    _T("/tee-stdin-read-buf-size"),
    _T("/tee-stdout-read-buf-size"),
    _T("/tee-stderr-read-buf-size"),
    _T("/mutex-std-writes"),
    _T("/mutex-tee-file-writes"),
    _T("/create-child-console"),
    _T("/create-console"),
    _T("/attach-parent-console"),
    _T("/create-console-title"),
    _T("/own-console-title"),
    _T("/console-title"),
    _T("/stdin-echo"),
    _T("/eval-backslash-esc"),
    _T("/e"),
    _T("/eval-dbl-backslash-esc"),
    _T("/e\\\\"),
    _T("/disable-conout-reattach-to-visible-console"),
    _T("/disable-conout-duplicate-to-parent-console-on-error")
};

const TCHAR * g_elevate_parent_flags_to_parse_arr[] = {
    _T("/ret-create-proc"),
    _T("/ret-win-error"),
    _T("/no-wait"),
    _T("/no-window"),
    _T("/init-com"),
    _T("/showas"),
    _T("/reopen-stdin"),
    _T("/reopen-stdin-as-server-pipe"),
    _T("/reopen-stdin-as-server-pipe-connect-timeout"),
    _T("/reopen-stdin-as-server-pipe-in-buf-size"),
    _T("/reopen-stdin-as-server-pipe-out-buf-size"),
    _T("/reopen-stdin-as-client-pipe"),
    _T("/reopen-stdin-as-client-pipe-connect-timeout"),
    _T("/reopen-stdout"),
    _T("/reopen-stdout-as-server-pipe"),
    _T("/reopen-stdout-as-server-pipe-connect-timeout"),
    _T("/reopen-stdout-as-server-pipe-in-buf-size"),
    _T("/reopen-stdout-as-server-pipe-out-buf-size"),
    _T("/reopen-stdout-as-client-pipe"),
    _T("/reopen-stdout-as-client-pipe-connect-timeout"),
    _T("/reopen-stderr"),
    _T("/reopen-stderr-as-server-pipe"),
    _T("/reopen-stderr-as-server-pipe-connect-timeout"),
    _T("/reopen-stderr-as-server-pipe-in-buf-size"),
    _T("/reopen-stderr-as-server-pipe-out-buf-size"),
    _T("/reopen-stderr-as-client-pipe"),
    _T("/reopen-stderr-as-client-pipe-connect-timeout"),
    _T("/reopen-stdout-file-truncate"),
    _T("/reopen-stderr-file-truncate"),
    _T("/stdout-dup"),
    _T("/stderr-dup"),
    _T("/stdin-output-flush"),
    _T("/stdout-flush"),
    _T("/stderr-flush"),
    _T("/output-flush"),
    _T("/inout-flush"),
    _T("/create-outbound-server-pipe-from-stdin"),
    _T("/create-outbound-server-pipe-from-stdin-connect-timeout"),
    _T("/create-outbound-server-pipe-from-stdin-in-buf-size"),
    _T("/create-outbound-server-pipe-from-stdin-out-buf-size"),
    _T("/create-inbound-server-pipe-to-stdout"),
    _T("/create-inbound-server-pipe-to-stdout-connect-timeout"),
    _T("/create-inbound-server-pipe-to-stdout-in-buf-size"),
    _T("/create-inbound-server-pipe-to-stdout-out-buf-size"),
    _T("/create-inbound-server-pipe-to-stderr"),
    _T("/create-inbound-server-pipe-to-stderr-connect-timeout"),
    _T("/create-inbound-server-pipe-to-stderr-in-buf-size"),
    _T("/create-inbound-server-pipe-to-stderr-out-buf-size"),
    _T("/mutex-std-writes"),
    _T("/create-child-console"),
    _T("/create-console"),
    _T("/create-console-title"),
    _T("/own-console-title"),
    _T("/console-title"),
    _T("/stdin-echo"),
    _T("/eval-backslash-esc"), //_T("/e"),
    _T("/eval-dbl-backslash-esc"), // _T("/e\\\\"),
    _T("/disable-conout-reattach-to-visible-console"),
    _T("/disable-conout-duplicate-to-parent-console-on-error")
};

const TCHAR * g_elevate_child_flags_to_parse_arr[] = {
    _T("/reopen-stdin"),
    _T("/reopen-stdin-as-server-pipe"),
    _T("/reopen-stdin-as-server-pipe-connect-timeout"),
    _T("/reopen-stdin-as-server-pipe-in-buf-size"),
    _T("/reopen-stdin-as-server-pipe-out-buf-size"),
    _T("/reopen-stdin-as-client-pipe"),
    _T("/reopen-stdin-as-client-pipe-connect-timeout"),
    _T("/reopen-stdout"),
    _T("/reopen-stdout-as-server-pipe"),
    _T("/reopen-stdout-as-server-pipe-connect-timeout"),
    _T("/reopen-stdout-as-server-pipe-in-buf-size"),
    _T("/reopen-stdout-as-server-pipe-out-buf-size"),
    _T("/reopen-stdout-as-client-pipe"),
    _T("/reopen-stdout-as-client-pipe-connect-timeout"),
    _T("/reopen-stderr"),
    _T("/reopen-stderr-as-server-pipe"),
    _T("/reopen-stderr-as-server-pipe-connect-timeout"),
    _T("/reopen-stderr-as-server-pipe-in-buf-size"),
    _T("/reopen-stderr-as-server-pipe-out-buf-size"),
    _T("/reopen-stderr-as-client-pipe"),
    _T("/reopen-stderr-as-client-pipe-connect-timeout"),
    _T("/reopen-stdout-file-truncate"),
    _T("/reopen-stderr-file-truncate"),
    _T("/stdout-dup"),
    _T("/stderr-dup"),
    _T("/stdin-output-flush"),
    _T("/stdout-flush"),
    _T("/stderr-flush"),
    _T("/output-flush"),
    _T("/inout-flush"),
    _T("/mutex-std-writes"),
    _T("/attach-parent-console"),
};

const TCHAR * g_promote_flags_to_parse_arr[] = {
    _T("/chcp-in"),
    _T("/chcp-out"),
    _T("/win-error-langid"),
    _T("/print-win-error-string"),
    _T("/print-shell-error-string"),
    _T("/no-print-gen-error-string"),
    _T("/no-sys-dialog-ui"),
    _T("/attach-parent-console"),
    _T("/disable-conout-reattach-to-visible-console"),
    _T("/disable-conout-duplicate-to-parent-console-on-error")
};

const TCHAR * g_promote_parent_flags_to_parse_arr[] = {
    _T("/chcp-in"),
    _T("/chcp-out"),
    _T("/tee-stdin"),
    _T("/tee-stdin-to-server-pipe"),
    _T("/tee-stdin-to-server-pipe-connect-timeout"),
    _T("/tee-stdin-to-server-pipe-in-buf-size"),
    _T("/tee-stdin-to-server-pipe-out-buf-size"),
    _T("/tee-stdin-to-client-pipe"),
    _T("/tee-stdin-to-client-pipe-connect-timeout"),
    _T("/tee-stdout"),
    _T("/tee-stdout-to-server-pipe"),
    _T("/tee-stdout-to-server-pipe-connect-timeout"),
    _T("/tee-stdout-to-server-pipe-in-buf-size"),
    _T("/tee-stdout-to-server-pipe-out-buf-size"),
    _T("/tee-stdout-to-client-pipe"),
    _T("/tee-stdout-to-client-pipe-connect-timeout"),
    _T("/tee-stderr"),
    _T("/tee-stderr-to-server-pipe"),
    _T("/tee-stderr-to-server-pipe-connect-timeout"),
    _T("/tee-stderr-to-server-pipe-in-buf-size"),
    _T("/tee-stderr-to-server-pipe-out-buf-size"),
    _T("/tee-stderr-to-client-pipe"),
    _T("/tee-stderr-to-client-pipe-connect-timeout"),
    _T("/tee-stdin-dup"),
    _T("/tee-stdout-dup"),
    _T("/tee-stderr-dup"),
    _T("/tee-stdin-file-truncate"),
    _T("/tee-stdout-file-truncate"),
    _T("/tee-stderr-file-truncate"),
    _T("/tee-stdin-file-flush"),
    _T("/tee-stdout-file-flush"),
    _T("/tee-stderr-file-flush"),
    _T("/tee-stdin-pipe-flush"),
    _T("/tee-stdout-pipe-flush"),
    _T("/tee-stderr-pipe-flush"),
    _T("/tee-stdin-flush"),
    _T("/tee-stdout-flush"),
    _T("/tee-stderr-flush"),
    _T("/tee-output-flush"),
    _T("/tee-inout-flush"),
    _T("/tee-stdin-pipe-buf-size"),
    _T("/tee-stdout-pipe-buf-size"),
    _T("/tee-stderr-pipe-buf-size"),
    _T("/tee-stdin-read-buf-size"),
    _T("/tee-stdout-read-buf-size"),
    _T("/tee-stderr-read-buf-size"),
    _T("/mutex-tee-file-writes"),
    _T("/attach-parent-console"),
    _T("/disable-conout-reattach-to-visible-console"),
    _T("/disable-conout-duplicate-to-parent-console-on-error")
};


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
        _print_stderr_message_va(fmt, vl);
        va_end(vl);
    }
    return err_invalid_format;
}

inline void MergeOptions(Flags & out_flags, Options & out_options,
                         const Flags & elevate_parent_flags, const Options & elevate_parent_options,
                         const Flags & promote_flags, const Options & promote_options,
                         const Flags & promote_parent_flags, const Options & promote_parent_options)
{
    // intercept here specific global variables accidental usage instead of local variables
    static struct {} g_options;
    static struct {} g_flags;

    //if (utility::addressof(out_flags) != utility::addressof(flags)) {
    //    out_flags = flags;
    //}
    //if (utility::addressof(out_options) != utility::addressof(options)) {
    //    out_options = options;
    //}

    // merge all except child flags and options

    if (g_is_process_elevating) {
        out_flags.merge(elevate_parent_flags);
        out_options.merge(elevate_parent_options);
    }

    out_flags.merge(promote_flags);
    out_options.merge(promote_options);

    out_flags.merge(promote_parent_flags);
    out_options.merge(promote_parent_options);
}

template <size_t N>
inline bool IsArgInFilter(const TCHAR * arg, const TCHAR * (& filter_arr)[N])
{
    bool is_found = false;

    utility::for_each_unroll(filter_arr, [&](const TCHAR * str) {
        if (!tstrcmp(arg, str)) {
            is_found = true;
            return false;
        }
        return true;
    });

    return is_found;
}

template <size_t N>
inline bool IsArgEqualTo(const TCHAR * arg, const TCHAR (& cmp_arg)[N])
{
    return !tstrncmp(arg, cmp_arg, N);
}

// return:
//  -1 - argument is not detected (not known)
//   0 - argument is detected and is not in inclusion filter
//   1 - argument is detected and is in inclusion filter
//   2 - argument is detected but not checked on inclusion because of invalid format
//   3 - argument is excluded without any checks
//
template <size_t M, size_t N>
int ParseArgToOption(int & error, const TCHAR * arg, int argc, const TCHAR * argv[], int & arg_offset, Flags & flags, Options & options, const TCHAR * (& include_filter_arr)[N], const TCHAR * (& exclude_filter_arr)[M])
{
    // intercept here specific global variables accidental usage instead of local variables
    static struct {} g_options;
    static struct {} g_flags;

    error = err_none;

    const TCHAR * start_arg = arg;

    if (ptrdiff_t(utility::addressof(exclude_filter_arr)) != ptrdiff_t(utility::addressof(g_empty_flags_arr))) {
        if (IsArgInFilter(arg, exclude_filter_arr)) {
            return 3;
        }
    }

    if (IsArgEqualTo(arg, _T("/chcp-in"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                options.chcp_in = _ttoi(arg);
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/chcp-out"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                options.chcp_out = _ttoi(arg);
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/ret-create-proc"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.ret_create_proc = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/ret-win-error"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.ret_win_error = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/win-error-langid"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                options.win_error_langid = _ttoi(arg);
                return 1;
            }
            return 0;
        }
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/ret-child-exit"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.ret_child_exit = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/print-win-error-string"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.print_win_error_string = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/print-shell-error-string"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.print_shell_error_string = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/no-print-gen-error-string"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.no_print_gen_error_string = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/no-sys-dialog-ui"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.no_sys_dialog_ui = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/shell-exec"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                options.shell_exec_verb = arg;
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/shell-exec-expand-env"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.shell_exec_expand_env = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/D"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                options.change_current_dir = arg;
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/no-wait"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.no_wait = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/no-window"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.no_window = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/no-expand-env"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.no_expand_env = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/no-subst-vars"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.no_subst_vars = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/no-std-inherit"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.no_std_inherit = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/pipe-stdin-to-stdout"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.pipe_stdin_to_stdout = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/init-com"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.init_com = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/wait-child-start"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.wait_child_start = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/elevate"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.elevate = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/showas"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                const int showas_value = _ttoi(arg);
                if (showas_value >= 0) {
                    options.show_as = showas_value;
                }
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/reopen-stdin"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                options.reopen_stdin_as_file = arg;
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/reopen-stdin-as-server-pipe"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                options.reopen_stdin_as_server_pipe = arg;
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/reopen-stdin-as-server-pipe-connect-timeout"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                const int timeout_ms = _ttoi(arg);
                if (timeout_ms > 0) {
                    options.reopen_stdin_as_server_pipe_connect_timeout_ms = timeout_ms;
                }
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/reopen-stdin-as-server-pipe-in-buf-size"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                const int buf_size = _ttoi(arg);
                if (buf_size > 0) {
                    options.reopen_stdin_as_server_pipe_in_buf_size = buf_size;
                }
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/reopen-stdin-as-server-pipe-out-buf-size"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                const int buf_size = _ttoi(arg);
                if (buf_size > 0) {
                    options.reopen_stdin_as_server_pipe_out_buf_size = buf_size;
                }
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/reopen-stdin-as-client-pipe"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                options.reopen_stdin_as_client_pipe = arg;
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/reopen-stdin-as-client-pipe-connect-timeout"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                const int timeout_ms = _ttoi(arg);
                if (timeout_ms > 0) {
                    options.reopen_stdin_as_client_pipe_connect_timeout_ms = timeout_ms;
                }
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/reopen-stdout"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                options.reopen_stdout_as_file = arg;
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/reopen-stdout-as-server-pipe"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                options.reopen_stdout_as_server_pipe = arg;
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/reopen-stdout-as-server-pipe-connect-timeout"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                const int timeout_ms = _ttoi(arg);
                if (timeout_ms > 0) {
                    options.reopen_stdout_as_server_pipe_connect_timeout_ms = timeout_ms;
                }
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/reopen-stdout-as-server-pipe-in-buf-size"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                const int buf_size = _ttoi(arg);
                if (buf_size > 0) {
                    options.reopen_stdout_as_server_pipe_in_buf_size = buf_size;
                }
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/reopen-stdout-as-server-pipe-out-buf-size"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                const int buf_size = _ttoi(arg);
                if (buf_size > 0) {
                    options.reopen_stdout_as_server_pipe_out_buf_size = buf_size;
                }
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/reopen-stdout-as-client-pipe"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                options.reopen_stdout_as_client_pipe = arg;
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/reopen-stdout-as-client-pipe-connect-timeout"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                const int timeout_ms = _ttoi(arg);
                if (timeout_ms > 0) {
                    options.reopen_stdout_as_client_pipe_connect_timeout_ms = timeout_ms;
                }
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/reopen-stderr"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                options.reopen_stderr_as_file = arg;
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/reopen-stderr-as-server-pipe"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                options.reopen_stderr_as_server_pipe = arg;
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/reopen-stderr-as-server-pipe-connect-timeout"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                const int timeout_ms = _ttoi(arg);
                if (timeout_ms > 0) {
                    options.reopen_stderr_as_server_pipe_connect_timeout_ms = timeout_ms;
                }
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/reopen-stderr-as-server-pipe-in-buf-size"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                const int buf_size = _ttoi(arg);
                if (buf_size > 0) {
                    options.reopen_stderr_as_server_pipe_in_buf_size = buf_size;
                }
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/reopen-stderr-as-server-pipe-out-buf-size"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                const int buf_size = _ttoi(arg);
                if (buf_size > 0) {
                    options.reopen_stderr_as_server_pipe_out_buf_size = buf_size;
                }
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/reopen-stderr-as-client-pipe"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                options.reopen_stderr_as_client_pipe = arg;
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/reopen-stderr-as-client-pipe-connect-timeout"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                const int timeout_ms = _ttoi(arg);
                if (timeout_ms > 0) {
                    options.reopen_stderr_as_client_pipe_connect_timeout_ms = timeout_ms;
                }
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/reopen-stdout-file-truncate"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.reopen_stdout_file_truncate = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/reopen-stderr-file-truncate"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.reopen_stderr_file_truncate = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/stdout-dup"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                const int fileno_value = _ttoi(arg);
                if (fileno_value >= 0) {
                    options.stdout_dup = fileno_value;
                }
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/stderr-dup"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                const int fileno_value = _ttoi(arg);
                if (fileno_value >= 0) {
                    options.stderr_dup = fileno_value;
                }
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/stdin-output-flush"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.stdin_output_flush = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/stdout-flush"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.stdout_flush = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/stderr-flush"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.stderr_flush = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/output-flush"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.output_flush = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/inout-flush"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.inout_flush = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/create-outbound-server-pipe-from-stdin"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                options.create_outbound_server_pipe_from_stdin = arg;
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/create-outbound-server-pipe-from-stdin-connect-timeout"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                const int timeout_ms = _ttoi(arg);
                if (timeout_ms > 0) {
                    options.create_outbound_server_pipe_from_stdin_connect_timeout_ms = timeout_ms;
                }
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/create-outbound-server-pipe-from-stdin-in-buf-size"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                const int buf_size = _ttoi(arg);
                if (buf_size > 0) {
                    options.create_outbound_server_pipe_from_stdin_in_buf_size = buf_size;
                }
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/create-outbound-server-pipe-from-stdin-out-buf-size"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                const int buf_size = _ttoi(arg);
                if (buf_size > 0) {
                    options.create_outbound_server_pipe_from_stdin_out_buf_size = buf_size;
                }
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/create-inbound-server-pipe-to-stdout"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                options.create_inbound_server_pipe_to_stdout = arg;
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/create-inbound-server-pipe-to-stdout-connect-timeout"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                const int timeout_ms = _ttoi(arg);
                if (timeout_ms > 0) {
                    options.create_inbound_server_pipe_to_stdout_connect_timeout_ms = timeout_ms;
                }
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/create-inbound-server-pipe-to-stdout-in-buf-size"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                const int buf_size = _ttoi(arg);
                if (buf_size > 0) {
                    options.create_inbound_server_pipe_to_stdout_in_buf_size = buf_size;
                }
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/create-inbound-server-pipe-to-stdout-out-buf-size"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                const int buf_size = _ttoi(arg);
                if (buf_size > 0) {
                    options.create_inbound_server_pipe_to_stdout_out_buf_size = buf_size;
                }
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/create-inbound-server-pipe-to-stderr"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                options.create_inbound_server_pipe_to_stderr = arg;
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/create-inbound-server-pipe-to-stderr-connect-timeout"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                const int timeout_ms = _ttoi(arg);
                if (timeout_ms > 0) {
                    options.create_inbound_server_pipe_to_stderr_connect_timeout_ms = timeout_ms;
                }
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/create-inbound-server-pipe-to-stderr-in-buf-size"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                const int buf_size = _ttoi(arg);
                if (buf_size > 0) {
                    options.create_inbound_server_pipe_to_stderr_in_buf_size = buf_size;
                }
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/create-inbound-server-pipe-to-stderr-out-buf-size"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                const int buf_size = _ttoi(arg);
                if (buf_size > 0) {
                    options.create_inbound_server_pipe_to_stderr_out_buf_size = buf_size;
                }
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/tee-stdin"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                options.tee_stdin_to_file = arg;
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/tee-stdin-to-server-pipe"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                options.tee_stdin_to_server_pipe = arg;
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/tee-stdin-to-server-pipe-connect-timeout"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                const int timeout_ms = _ttoi(arg);
                if (timeout_ms > 0) {
                    options.tee_stdin_to_server_pipe_connect_timeout_ms = timeout_ms;
                }
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/tee-stdin-to-server-pipe-in-buf-size"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                const int buf_size = _ttoi(arg);
                if (buf_size > 0) {
                    options.tee_stdin_to_server_pipe_in_buf_size = buf_size;
                }
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/tee-stdin-to-server-pipe-out-buf-size"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                const int buf_size = _ttoi(arg);
                if (buf_size > 0) {
                    options.tee_stdin_to_server_pipe_out_buf_size = buf_size;
                }
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/tee-stdin-to-client-pipe"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                options.tee_stdin_to_client_pipe = arg;
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/tee-stdin-to-client-pipe-connect-timeout"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                const int timeout_ms = _ttoi(arg);
                if (timeout_ms > 0) {
                    options.tee_stdin_to_client_pipe_connect_timeout_ms = timeout_ms;
                }
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/tee-stdout"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                options.tee_stdout_to_file = arg;
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/tee-stdout-to-server-pipe"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                options.tee_stdout_to_server_pipe = arg;
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/tee-stdout-to-server-pipe-connect-timeout"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                const int timeout_ms = _ttoi(arg);
                if (timeout_ms > 0) {
                    options.tee_stdout_to_server_pipe_connect_timeout_ms = timeout_ms;
                }
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/tee-stdout-to-server-pipe-in-buf-size"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                const int buf_size = _ttoi(arg);
                if (buf_size > 0) {
                    options.tee_stdout_to_server_pipe_in_buf_size = buf_size;
                }
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/tee-stdout-to-server-pipe-out-buf-size"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                const int buf_size = _ttoi(arg);
                if (buf_size > 0) {
                    options.tee_stdout_to_server_pipe_out_buf_size = buf_size;
                }
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/tee-stdout-to-client-pipe"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                options.tee_stdout_to_client_pipe = arg;
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/tee-stdout-to-client-pipe-connect-timeout"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                const int timeout_ms = _ttoi(arg);
                if (timeout_ms > 0) {
                    options.tee_stdout_to_client_pipe_connect_timeout_ms = timeout_ms;
                }
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/tee-stderr"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                options.tee_stderr_to_file = arg;
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/tee-stderr-to-server-pipe"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                options.tee_stderr_to_server_pipe = arg;
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/tee-stderr-to-server-pipe-connect-timeout"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                const int timeout_ms = _ttoi(arg);
                if (timeout_ms > 0) {
                    options.tee_stderr_to_server_pipe_connect_timeout_ms = timeout_ms;
                }
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/tee-stderr-to-server-pipe-in-buf-size"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                const int buf_size = _ttoi(arg);
                if (buf_size > 0) {
                    options.tee_stderr_to_server_pipe_in_buf_size = buf_size;
                }
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/tee-stderr-to-server-pipe-out-buf-size"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                const int buf_size = _ttoi(arg);
                if (buf_size > 0) {
                    options.tee_stderr_to_server_pipe_out_buf_size = buf_size;
                }
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/tee-stderr-to-client-pipe"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                options.tee_stderr_to_client_pipe = arg;
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/tee-stderr-to-client-pipe-connect-timeout"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                const int timeout_ms = _ttoi(arg);
                if (timeout_ms > 0) {
                    options.tee_stderr_to_client_pipe_connect_timeout_ms = timeout_ms;
                }
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/tee-stdin-dup"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                const int fileno_value = _ttoi(arg);
                if (fileno_value >= 0) {
                    options.tee_stdin_dup = fileno_value;
                }
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/tee-stdout-dup"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                const int fileno_value = _ttoi(arg);
                if (fileno_value >= 0) {
                    options.tee_stdout_dup = fileno_value;
                }
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/tee-stderr-dup"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                const int fileno_value = _ttoi(arg);
                if (fileno_value >= 0) {
                    options.tee_stderr_dup = fileno_value;
                }
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/tee-stdin-file-truncate"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.tee_stdin_file_truncate = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/tee-stdout-file-truncate"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.tee_stdout_file_truncate = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/tee-stderr-file-truncate"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.tee_stderr_file_truncate = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/tee-stdin-file-flush"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.tee_stdin_file_flush = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/tee-stdout-file-flush"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.tee_stdout_file_flush = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/tee-stderr-file-flush"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.tee_stderr_file_flush = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/tee-stdin-pipe-flush"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.tee_stdin_pipe_flush = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/tee-stdout-pipe-flush"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.tee_stdout_pipe_flush = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/tee-stderr-pipe-flush"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.tee_stderr_pipe_flush = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/tee-stdin-flush"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.tee_stdin_flush = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/tee-stdout-flush"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.tee_stdout_flush = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/tee-stderr-flush"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.tee_stderr_flush = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/tee-output-flush"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.tee_output_flush = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/tee-inout-flush"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.tee_inout_flush = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/tee-stdin-pipe-buf-size"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                const int buf_size = _ttoi(arg);
                if (buf_size > 0) {
                    options.tee_stdin_pipe_buf_size = buf_size;
                }
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/tee-stdout-pipe-buf-size"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                const int buf_size = _ttoi(arg);
                if (buf_size > 0) {
                    options.tee_stdout_pipe_buf_size = buf_size;
                }
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/tee-stderr-pipe-buf-size"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                const int buf_size = _ttoi(arg);
                if (buf_size > 0) {
                    options.tee_stderr_pipe_buf_size = buf_size;
                }
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/tee-stdin-read-buf-size"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                const int buf_size = _ttoi(arg);
                if (buf_size > 0) {
                    options.tee_stdin_read_buf_size = buf_size;
                }
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/tee-stdout-read-buf-size"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                const int buf_size = _ttoi(arg);
                if (buf_size > 0) {
                    options.tee_stdout_read_buf_size = buf_size;
                }
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/tee-stderr-read-buf-size"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                const int buf_size = _ttoi(arg);
                if (buf_size > 0) {
                    options.tee_stderr_read_buf_size = buf_size;
                }
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/mutex-std-writes"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.mutex_std_writes = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/mutex-tee-file-writes"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.mutex_tee_file_writes = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/create-child-console"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.create_child_console = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/create-console"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.create_console = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/attach-parent-console"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.attach_parent_console = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/create-console-title"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                options.create_console_title = arg;
                options.has.create_console_title = true;
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/own-console-title"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                options.own_console_title = arg;
                options.has.own_console_title = true;
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/console-title"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                options.console_title = arg;
                options.has.console_title = true;
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/stdin-echo"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            if (IsArgInFilter(start_arg, include_filter_arr)) {
                const int stdin_echo = _ttoi(arg);
                if (stdin_echo >= 0) {
                    options.stdin_echo = stdin_echo;
                }
                return 1;
            }
            return 0;
        }
        else error = invalid_format_flag(arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/eval-backslash-esc")) || IsArgEqualTo(arg, _T("/e"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.eval_backslash_esc = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/eval-dbl-backslash-esc")) || IsArgEqualTo(arg, _T("/e\\\\"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.eval_dbl_backslash_esc = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/disable-conout-reattach-to-visible-console"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.disable_conout_reattach_to_visible_console = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/disable-conout-duplicate-to-parent-console-on-error"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.disable_conout_duplicate_to_parent_console_on_error = true;
            return 1;
        }
        return 0;
    }

    return -1;
}

int _tmain(int argc, const TCHAR * argv[])
{
#if _DEBUG
    MessageBoxA(NULL, "", "", MB_OK);
#endif

    // CAUTION:
    //  In Windows if you call `CreateProcess` like this: `CreateProcess("a.exe", "/b", ...)`, then the `argv[0]` would be `/b`, not `a.exe`!
    //

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
    int arg_offset = argv[0][0] != _T('/') ? 1 : 0; // arguments shift detection
    int parse_error = err_none;
    int parse_result;

    // silent flags preprocess w/o any errors to search for prioritized flags
    while (argc >= arg_offset + 1)
    {
        arg = argv[arg_offset];

        if (tstrncmp(arg, _T("/"), 1)) {
            break;
        }

        if (!tstrncmp(arg, _T("//"), 2)) {
            arg_offset += 1;
            break;
        }

        if (ParseArgToOption(parse_error, arg, argc, argv, arg_offset, g_regular_flags, g_regular_options, g_flags_to_preparse_arr, g_empty_flags_arr) >= 0) {
            if (parse_error != err_none) {
                return parse_error;
            }
        }
        else if (!tstrcmp(arg, _T("/elevate{"))) {
            arg_offset += 1;

            g_regular_flags.elevate = true;

            bool is_elevate_child_flags = false;

            // read inner flags
            while (argc >= arg_offset + 1)
            {
                arg = argv[arg_offset];

                if ((!is_elevate_child_flags ?
                        ParseArgToOption(parse_error, arg, argc, argv, arg_offset,
                            !is_elevate_child_flags ? g_elevate_parent_flags : g_elevate_child_flags,
                            !is_elevate_child_flags ? g_elevate_parent_options : g_elevate_child_options,
                            g_elevate_parent_flags_to_preparse_arr, g_empty_flags_arr) :
                        ParseArgToOption(parse_error, arg, argc, argv, arg_offset,
                            !is_elevate_child_flags ? g_elevate_parent_flags : g_elevate_child_flags,
                            !is_elevate_child_flags ? g_elevate_parent_options : g_elevate_child_options,
                            g_elevate_child_flags_to_preparse_arr, g_empty_flags_arr)) >= 0) {
                    if (parse_error != err_none) {
                        return parse_error;
                    }
                }
                else if (!is_elevate_child_flags && !tstrcmp(arg, _T("}{"))) {
                    is_elevate_child_flags = true;
                }
                else if (!tstrcmp(arg, _T("}"))) {
                    break;
                }

                arg_offset += 1;
            }
        }
        else if (!tstrcmp(arg, _T("/promote{"))) {
            arg_offset += 1;

            // read inner flags
            while (argc >= arg_offset + 1)
            {
                arg = argv[arg_offset];

                if (ParseArgToOption(parse_error, arg, argc, argv, arg_offset, g_promote_flags, g_promote_options, g_promote_flags_to_preparse_arr, g_empty_flags_arr) >= 0) {
                    if (parse_error != err_none) {
                        return parse_error;
                    }
                }
                else if (!tstrcmp(arg, _T("}"))) {
                    break;
                }

                arg_offset += 1;
            }
        }
        else if (!tstrcmp(arg, _T("/promote-parent{"))) {
            arg_offset += 1;

            // read inner flags
            while (argc >= arg_offset + 1)
            {
                arg = argv[arg_offset];

                if (ParseArgToOption(parse_error, arg, argc, argv, arg_offset, g_promote_parent_flags, g_promote_parent_options, g_promote_parent_flags_to_preparse_arr, g_empty_flags_arr) >= 0) {
                    if (parse_error != err_none) {
                        return parse_error;
                    }
                }
                else if (!tstrcmp(arg, _T("}"))) {
                    break;
                }

                arg_offset += 1;
            }
        }

        arg_offset += 1;
    }

    // update elevation state
    if (g_regular_flags.elevate) {
        const bool is_process_elevated = _is_process_elevated() ? 1 : 0;
        if (!is_process_elevated) {
            g_is_process_elevating = true;
        }

        // we must drop this flag immediately to avoid potential accidental recursion in child process
        g_regular_flags.elevate = false;
    }

    // reset flags and options
    g_flags = g_regular_flags;
    g_options = g_regular_options;

    if (g_is_process_elevating) {
        TranslateCommandLineToElevated(nullptr, nullptr, nullptr,
            g_flags, g_options,
            g_elevate_child_flags, g_elevate_child_options,
            g_promote_flags, g_promote_options);
    }

    // merge options (first time)
    MergeOptions(g_flags, g_options,
        g_elevate_parent_flags, g_elevate_parent_options,
        g_promote_flags, g_promote_options, g_promote_parent_flags, g_promote_parent_options);

    if (!g_flags.disable_conout_duplicate_to_parent_console_on_error) {
        // enable console output buffering by default
        g_enable_conout_prints_buffering = true;
    }

    bool is_conout_reattached_to_visible_console = false;
    bool is_console_window_inited = false;

    std::vector<_ConsoleWindowOwnerProc> console_window_owner_procs;

    // NOTE:
    //  lambda to bypass msvc error: `error C2712: Cannot use __try in functions that require object unwinding`
    //
    return [&]() -> int { __try {
        return [&]() -> int {
            // update process console

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

            if (g_parent_proc_id == -1) {
                g_parent_proc_id = _find_parent_proc_id();
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

                if ((parse_result = ParseArgToOption(parse_error, arg, argc, argv, arg_offset, g_regular_flags, g_regular_options, g_flags_to_parse_arr, g_flags_to_preparse_arr)) >= 0) {
                    if (!parse_result && parse_error != err_none) {
                        parse_error = invalid_format_flag(arg);
                    }
                    if (parse_error != err_none) {
                        return parse_error;
                    }
                }
                else if (!tstrcmp(arg, _T("/elevate{"))) {
                    arg_offset += 1;

                    g_regular_flags.elevate = true;

                    bool is_elevate_child_flags = false;

                    // read inner flags
                    while (argc >= arg_offset + 1)
                    {
                        arg = argv[arg_offset];

                        if ((parse_result = (!is_elevate_child_flags ?
                                ParseArgToOption(parse_error, arg, argc, argv, arg_offset,
                                    !is_elevate_child_flags ? g_elevate_parent_flags : g_elevate_child_flags,
                                    !is_elevate_child_flags ? g_elevate_parent_options : g_elevate_child_options,
                                    g_elevate_parent_flags_to_parse_arr,
                                    g_elevate_parent_flags_to_preparse_arr) :
                                ParseArgToOption(parse_error, arg, argc, argv, arg_offset,
                                    !is_elevate_child_flags ? g_elevate_parent_flags : g_elevate_child_flags,
                                    !is_elevate_child_flags ? g_elevate_parent_options : g_elevate_child_options,
                                    g_elevate_child_flags_to_parse_arr,
                                    g_elevate_child_flags_to_preparse_arr))) >= 0) {
                            if (!parse_result && parse_error != err_none) {
                                parse_error = invalid_format_flag(arg);
                            }
                            if (parse_error != err_none) {
                                return parse_error;
                            }
                        }
                        else if (!is_elevate_child_flags && !tstrcmp(arg, _T("}{"))) {
                            is_elevate_child_flags = true;
                        }
                        else if (!tstrcmp(arg, _T("}"))) {
                            break;
                        }
                        else return invalid_format_flag(arg);

                        arg_offset += 1;
                    }
                }
                else if (!tstrcmp(arg, _T("/promote{"))) {
                    arg_offset += 1;

                    // read inner flags
                    while (argc >= arg_offset + 1)
                    {
                        arg = argv[arg_offset];

                        if ((parse_result = ParseArgToOption(parse_error, arg, argc, argv, arg_offset, g_promote_flags, g_promote_options, g_promote_flags_to_parse_arr, g_promote_flags_to_preparse_arr)) >= 0) {
                            if (!parse_result && parse_error != err_none) {
                                parse_error = invalid_format_flag(arg);
                            }
                            if (parse_error != err_none) {
                                return parse_error;
                            }
                        }
                        else if (!tstrcmp(arg, _T("}"))) {
                            break;
                        }
                        else return invalid_format_flag(arg);

                        arg_offset += 1;
                    }
                }
                else if (!tstrcmp(arg, _T("/promote-parent{"))) {
                    arg_offset += 1;

                    // read inner flags
                    while (argc >= arg_offset + 1)
                    {
                        arg = argv[arg_offset];

                        if ((parse_result = ParseArgToOption(parse_error, arg, argc, argv, arg_offset, g_promote_parent_flags, g_promote_parent_options, g_promote_parent_flags_to_parse_arr, g_promote_parent_flags_to_preparse_arr)) >= 0) {
                            if (!parse_result && parse_error != err_none) {
                                parse_error = invalid_format_flag(arg);
                            }
                            if (parse_error != err_none) {
                                return parse_error;
                            }
                        }
                        else if (!tstrcmp(arg, _T("}"))) {
                            break;
                        }
                        else return invalid_format_flag(arg);

                        arg_offset += 1;
                    }
                }
                else return invalid_format_flag(arg);

                arg_offset += 1;
            }

            // reset flags and options
            g_flags = g_regular_flags;
            g_options = g_regular_options;

            if (g_is_process_elevating) {
                TranslateCommandLineToElevated(nullptr, nullptr, nullptr,
                    g_flags, g_options,
                    g_elevate_child_flags, g_elevate_child_options,
                    g_promote_flags, g_promote_options);
            }

            // merge options (second time)
            MergeOptions(g_flags, g_options,
                g_elevate_parent_flags, g_elevate_parent_options,
                g_promote_flags, g_promote_options, g_promote_parent_flags, g_promote_parent_options);

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

            // promote{ ... } vs promote-parent{ ... }

            if (g_promote_options.chcp_in != 0 && g_promote_parent_options.chcp_in != 0) {
                return invalid_format_flag_message(_T("promote option mixed with promote-parent option: promote.chcp_in=%i promote-parent.chcp_in=%i\n"), g_promote_options.chcp_in, g_promote_parent_options.chcp_in);
            }
            if (g_promote_options.chcp_out != 0 && g_promote_parent_options.chcp_out != 0) {
                return invalid_format_flag_message(_T("promote option mixed with promote-parent option: promote.chcp_out=%i promote-parent.chcp_out=%i\n"), g_promote_options.chcp_out, g_promote_parent_options.chcp_out);
            }
            if (g_promote_flags.attach_parent_console && g_promote_parent_flags.attach_parent_console) {
                return invalid_format_flag_message(_T("promote option mixed with promote-parent option: attach_parent_console\n"));
            }
            if (g_promote_flags.disable_conout_reattach_to_visible_console && g_promote_parent_flags.disable_conout_reattach_to_visible_console) {
                return invalid_format_flag_message(_T("promote option mixed with promote-parent option: disable_conout_reattach_to_visible_console\n"));
            }
            if (g_promote_flags.disable_conout_duplicate_to_parent_console_on_error && g_promote_parent_flags.disable_conout_duplicate_to_parent_console_on_error) {
                return invalid_format_flag_message(_T("promote option mixed with promote-parent option: disable_conout_duplicate_to_parent_console_on_error\n"));
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

            // reset flags and options
            g_flags = g_regular_flags;
            g_options = g_regular_options;

            if (g_is_process_elevating) {
                std::tstring elevated_cmd_out_str;

                TranslateCommandLineToElevated(
                    app_args.fmt_str ? utility::addressof(app_out_args.fmt_str) : nullptr,
                    cmd_args.fmt_str ? utility::addressof(cmd_out_args.fmt_str) : nullptr,
                    utility::addressof(elevated_cmd_out_str),
                    g_flags, g_options,
                    g_elevate_child_flags, g_elevate_child_options,
                    g_promote_flags, g_promote_options);

                // merge options (third time)
                MergeOptions(g_flags, g_options,
                    g_elevate_parent_flags, g_elevate_parent_options,
                    g_promote_flags, g_promote_options, g_promote_parent_flags, g_promote_parent_options);

                SubstOptionsPlaceholders(g_options);

                // update options
                if (g_options.shell_exec_verb != _T("runas")) {
                    g_options.shell_exec_verb = _T("runas");
                }

                return ExecuteProcess(
                    argv[0],
                    tstrlen(argv[0]),
                    !elevated_cmd_out_str.empty() ? elevated_cmd_out_str.c_str() : (LPCTSTR)NULL,
                    !elevated_cmd_out_str.empty() ? elevated_cmd_out_str.length() : 0
                );
            }

            // merge options (third time)
            MergeOptions(g_flags, g_options,
                g_elevate_parent_flags, g_elevate_parent_options,
                g_promote_flags, g_promote_options, g_promote_parent_flags, g_promote_parent_options);

            SubstOptionsPlaceholders(g_options);

            return ExecuteProcess(
                app_args.fmt_str ? app_out_args.fmt_str.c_str() : (LPCTSTR)NULL,
                app_args.fmt_str ? app_out_args.fmt_str.length() : 0,
                cmd_args.fmt_str ? cmd_out_args.fmt_str.c_str() : (LPCTSTR)NULL,
                cmd_args.fmt_str ? cmd_out_args.fmt_str.length() : 0
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
