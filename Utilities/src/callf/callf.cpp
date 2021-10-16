#include "callf.hpp"
#include "execute.hpp"

//#ifdef _UNICODE
//#error Unicode is not supported.
//#endif


namespace {
    struct InArgs : InBaseArgs
    {
        const TCHAR *       app_fmt_str;
        const TCHAR *       cmd_fmt_str;
    };

    struct OutArgs : OutBaseArgs
    {
        std::tstring        app_fmt_str;
        std::tstring        cmd_fmt_str;
    };
}


// WOW64 FileSystem redirection data
PVOID g_disable_wow64_fs_redir_ptr = NULL;

// sets true just after the CreateProcess or ShellExecute success execute
bool g_is_process_executed = false;

// sets true in case if process is not elevated and requested for self elevation
bool g_is_process_elevating = false;


const TCHAR * g_empty_flags_arr[] = {
    _T("")
};

const TCHAR * g_flags_to_preparse_arr[] = {
    _T("/ret-create-proc"),
    _T("/ret-win-error"),
    _T("/win-error-langid"),
    _T("/ret-child-exit"),
    _T("/print-win-error-string"),
    _T("/print-shell-error-string"),
    _T("/no-print-gen-error-string"),
    _T("/no-windows-console"),
    _T("/pause-on-exit-if-error-before-exec"),
    _T("/pause-on-exit-if-error"),
    _T("/pause-on-exit"),
    _T("/allow-throw-seh-except"),
    _T("/elevate"),
    _T("/create-console"),
    _T("/detach-console"),
    _T("/attach-parent-console"),
    _T("/create-console-title"),
    _T("/own-console-title"),
    _T("/console-title"),
    _T("/disable-wow64-fs-redir"),
#ifndef _CONSOLE
    _T("/allow-gui-autoattach-to-parent-console"),
#endif
    _T("/disable-conout-reattach-to-visible-console"),
    _T("/allow-conout-attach-to-invisible-parent-console"),
    _T("/disable-conout-duplicate-to-parent-console-on-error")
};

const TCHAR * g_elevate_parent_flags_to_preparse_arr[] = {
    _T("/no-windows-console"),
    _T("/create-console-title"),
    _T("/own-console-title"),
    _T("/console-title"),
};

const TCHAR * g_elevate_child_flags_to_preparse_arr[] = {
    _T("/no-expand-env"),
    _T("/attach-parent-console"),
    _T("/create-console-title"),
    _T("/own-console-title"),
    _T("/console-title"),
};

const TCHAR * g_promote_flags_to_preparse_arr[] = {
    _T("/ret-create-proc"),
    _T("/ret-win-error"),
    _T("/win-error-langid"),
    _T("/ret-child-exit"),
    _T("/print-win-error-string"),
    _T("/no-print-gen-error-string"),
    _T("/pause-on-exit-if-error-before-exec"),
    _T("/pause-on-exit-if-error"),
    _T("/pause-on-exit"),
    _T("/allow-throw-seh-except"),
    _T("/create-console"),
    _T("/detach-console"),
    _T("/attach-parent-console"),
    _T("/disable-wow64-fs-redir"),
#ifndef _CONSOLE
    _T("/allow-gui-autoattach-to-parent-console"),
#endif
    _T("/disable-conout-reattach-to-visible-console"),
    _T("/allow-conout-attach-to-invisible-parent-console"),
    _T("/disable-conout-duplicate-to-parent-console-on-error")
};

const TCHAR * g_promote_parent_flags_to_preparse_arr[] = {
    _T("/ret-create-proc"),
    _T("/ret-win-error"),
    _T("/win-error-langid"),
    _T("/ret-child-exit"),
    _T("/pause-on-exit-if-error-before-exec"),
    _T("/pause-on-exit-if-error"),
    _T("/pause-on-exit"),
    _T("/allow-throw-seh-except"),
    _T("/create-console"),
    _T("/detach-console"),
    _T("/attach-parent-console"),
    _T("/disable-wow64-fs-redir"),
#ifndef _CONSOLE
    _T("/allow-gui-autoattach-to-parent-console"),
#endif
    _T("/disable-conout-reattach-to-visible-console"),
    _T("/allow-conout-attach-to-invisible-parent-console"),
    _T("/disable-conout-duplicate-to-parent-console-on-error")
};

const TCHAR * g_flags_w_index_to_parse_arr[] = {
    _T("/EE"),
    _T("/expand-env-arg"), _T("/E"),
    _T("/SE"),
    _T("/subst-vars-arg"), _T("/S"),
    _T("/replace-arg"), _T("/r"),
    _T("/eval-backslash-esc"), _T("/e"),
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
    _T("/pause-on-exit-if-error-before-exec"),
    _T("/pause-on-exit-if-error"),
    _T("/pause-on-exit"),
    _T("/shell-exec"),
    _T("/shell-exec-expand-env"),
    _T("/D"),
    _T("/no-wait"),
    _T("/no-window"),
    _T("/no-window-console"),
    _T("/no-expand-env"),
    _T("/no-subst-vars"),
    _T("/no-subst-empty-tail-vars"),
    _T("/no-std-inherit"),
    _T("/no-stdin-inherit"),
    _T("/no-stdout-inherit"),
    _T("/no-stderr-inherit"),
    _T("/allow-throw-seh-except"),
    _T("/allow-expand-unexisted-env"),
    _T("/allow-subst-empty-args"),
    _T("/pipe-stdin-to-child-stdin"),
    _T("/pipe-child-stdout-to-stdout"),
    _T("/pipe-child-stderr-to-stderr"),
    _T("/pipe-inout-child"),
    _T("/pipe-out-child"),
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
    _T("/stdout-vt100"),
    _T("/stderr-vt100"),
    _T("/output-vt100"),
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
    _T("/tee-conout-dup"),
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
    _T("/detach-child-console"),
    _T("/create-console"),
    _T("/detach-console"),
    _T("/attach-parent-console"),
    _T("/create-console-title"),
    _T("/own-console-title"),
    _T("/console-title"),
    _T("/stdin-echo"),
    _T("/no-stdin-echo"),
    _T("/replace-args"), _T("/r"),
    _T("/replace-args-in-tail"), _T("/ra"),
    _T("/eval-backslash-esc"), _T("/e"),
    _T("/eval-dbl-backslash-esc"), _T("/e\\\\"),
    _T("/set-env-var"), _T("/v"),
    _T("/disable-wow64-fs-redir"),
#ifndef _CONSOLE
    _T("/allow-gui-autoattach-to-parent-console"),
#endif
    _T("/disable-conout-reattach-to-visible-console"),
    _T("/allow-conout-attach-to-invisible-parent-console"),
    _T("/disable-conout-duplicate-to-parent-console-on-error"),
    _T("/write-console-stdin-back")
};

const TCHAR * g_elevate_parent_flags_to_parse_arr[] = {
    _T("/no-sys-dialog-ui"),
    _T("/no-wait"),
    _T("/no-window"),
    _T("/no-window-console"),
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
    _T("/create-console-title"),
    _T("/own-console-title"),
    _T("/console-title"),
    _T("/stdin-echo"),
    _T("/no-stdin-echo"),
    _T("/eval-backslash-esc"), _T("/e"),
    _T("/eval-dbl-backslash-esc"), _T("/e\\\\"),
    _T("/disable-wow64-fs-redir"),
#ifndef _CONSOLE
    _T("/allow-gui-autoattach-to-parent-console"),
#endif
    _T("/disable-conout-reattach-to-visible-console"),
    _T("/allow-conout-attach-to-invisible-parent-console"),
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
    _T("/create-console"),
    _T("/detach-console"),
    _T("/attach-parent-console"),
};

const TCHAR * g_promote_flags_to_parse_arr[] = {
    _T("/chcp-in"),
    _T("/chcp-out"),
    _T("/ret-create-proc"),
    _T("/ret-win-error"),
    _T("/win-error-langid"),
    _T("/ret-child-exit"),
    _T("/print-win-error-string"),
    _T("/print-shell-error-string"),
    _T("/no-print-gen-error-string"),
    _T("/pause-on-exit-if-error-before-exec"),
    _T("/pause-on-exit-if-error"),
    _T("/pause-on-exit"),
    _T("/allow-throw-seh-except"),
    _T("/attach-parent-console"),
    _T("/disable-wow64-fs-redir"),
#ifndef _CONSOLE
    _T("/allow-gui-autoattach-to-parent-console"),
#endif
    _T("/disable-conout-reattach-to-visible-console"),
    _T("/allow-conout-attach-to-invisible-parent-console"),
    _T("/disable-conout-duplicate-to-parent-console-on-error")
};

const TCHAR * g_promote_parent_flags_to_parse_arr[] = {
    _T("/chcp-in"),
    _T("/chcp-out"),
    _T("/ret-create-proc"),
    _T("/ret-win-error"),
    _T("/win-error-langid"),
    _T("/ret-child-exit"),
    _T("/pause-on-exit-if-error-before-exec"),
    _T("/pause-on-exit-if-error"),
    _T("/pause-on-exit"),
    _T("/no-std-inherit"),
    _T("/no-stdin-inherit"),
    _T("/no-stdout-inherit"),
    _T("/no-stderr-inherit"),
    _T("/allow-throw-seh-except"),
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
    _T("/stdout-vt100"),
    _T("/stderr-vt100"),
    _T("/output-vt100"),
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
    _T("/tee-conout-dup"),
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
    _T("/create-console"),
    _T("/detach-console"),
    _T("/attach-parent-console"),
    _T("/disable-wow64-fs-redir"),
#ifndef _CONSOLE
    _T("/allow-gui-autoattach-to-parent-console"),
#endif
    _T("/disable-conout-reattach-to-visible-console"),
    _T("/allow-conout-attach-to-invisible-parent-console"),
    _T("/disable-conout-duplicate-to-parent-console-on-error"),
    _T("/write-console-stdin-back")
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
inline bool IsArgWithSuffixInFilter(const TCHAR * arg, size_t arg_len, const TCHAR * (& filter_arr)[N])
{
    bool is_found = false;

    utility::for_each_unroll(filter_arr, [&](const TCHAR * str) {
        const size_t str_len = tstrlen(str);
        if (str_len != arg_len) {
            return true;
        }
        if (!tstrncmp(arg, str, str_len)) {
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
    static_assert(N > 1, "cmp_arg[N] must contain at least one character");
    return !tstrncmp(arg, cmp_arg, N);
}

template <size_t N>
inline bool IsArgWithSuffixEqualTo(const TCHAR * arg, const TCHAR (& cmp_arg)[N], const TCHAR * & arg_suffix)
{
    static_assert(N > 1, "cmp_arg[N] must contain at least one character");
    if (!tstrncmp(arg, cmp_arg, N - 1)) {
        arg_suffix = arg + N - 1;
        return true;
    }
    return false;
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
    const TCHAR * arg_suffix = nullptr;

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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
    if (IsArgEqualTo(arg, _T("/no-window-console"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.no_window_console = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/pause-on-exit-if-error-before-exec"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.pause_on_exit_if_error_before_exec = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/pause-on-exit-if-error"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.pause_on_exit_if_error = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/pause-on-exit"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.pause_on_exit = true;
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
    if (IsArgEqualTo(arg, _T("/no-subst-empty-tail-vars"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.no_subst_empty_tail_vars = true;
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
    if (IsArgEqualTo(arg, _T("/no-stdin-inherit"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.no_stdin_inherit = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/no-stdout-inherit"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.no_stdout_inherit = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/no-stderr-inherit"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.no_stderr_inherit = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/allow-throw-seh-except"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.allow_throw_seh_except = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/allow-expand-unexisted-env"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.allow_expand_unexisted_env = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/allow-subst-empty-args"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.allow_subst_empty_args = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/pipe-stdin-to-child-stdin"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.pipe_stdin_to_child_stdin = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/pipe-child-stdout-to-stdout"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.pipe_child_stdout_to_stdout = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/pipe-child-stderr-to-stderr"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.pipe_child_stderr_to_stderr = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/pipe-inout-child"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.pipe_inout_child = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/pipe-out-child"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.pipe_out_child = true;
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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

    if (IsArgEqualTo(arg, _T("/stdout-vt100"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.stdout_vt100 = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/stderr-vt100"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.stderr_vt100 = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/output-vt100"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.output_vt100 = true;
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/tee-conout-dup"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.tee_conout_dup = true;
            return 1;
        }
        return 0;
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
    if (IsArgEqualTo(arg, _T("/detach-child-console"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.detach_child_console = true;
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
    if (IsArgEqualTo(arg, _T("/detach-console"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.detach_console = true;
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
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
        else error = invalid_format_flag(start_arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/stdin-echo"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.stdin_echo = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/no-stdin-echo"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.no_stdin_echo = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/replace-args")) || IsArgEqualTo(arg, _T("/r"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            const TCHAR * from = arg;

            arg_offset += 1;
            if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                const TCHAR * to = arg;

                if (IsArgInFilter(start_arg, include_filter_arr)) {
                    options.replace_args.push_back(std::make_tuple(-1, std::tstring{ from }, std::tstring{ to }));
                    return 1;
                }
                return 0;
            }
            else error = invalid_format_flag(start_arg);
            return 2;
        }
        else error = invalid_format_flag(start_arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/replace-args-in-tail")) || IsArgEqualTo(arg, _T("/ra"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            const TCHAR * from = arg;

            arg_offset += 1;
            if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                const TCHAR * to = arg;

                if (IsArgInFilter(start_arg, include_filter_arr)) {
                    options.replace_args.push_back(std::make_tuple(-2, std::tstring{ from }, std::tstring{ to }));
                    return 1;
                }
                return 0;
            }
            else error = invalid_format_flag(start_arg);
            return 2;
        }
        else error = invalid_format_flag(start_arg);
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
    if (IsArgEqualTo(arg, _T("/set-env-var")) || IsArgEqualTo(arg, _T("/v"))) {
        arg_offset += 1;
        if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
            const TCHAR * name = arg;

            arg_offset += 1;
            if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                const TCHAR * value = arg;

                if (IsArgInFilter(start_arg, include_filter_arr)) {
                    options.env_vars.push_back(std::make_tuple(std::tstring{ name }, std::tstring{ value }));
                    return 1;
                }
                return 0;
            }
            else error = invalid_format_flag(start_arg);
            return 2;
        }
        else error = invalid_format_flag(start_arg);
        return 2;
    }
    if (IsArgEqualTo(arg, _T("/disable-wow64-fs-redir"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.disable_wow64_fs_redir = true;
            return 1;
        }
        return 0;
    }
#ifndef _CONSOLE
    if (IsArgEqualTo(arg, _T("/allow-gui-autoattach-to-parent-console"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.allow_gui_autoattach_to_parent_console = true;
            return 1;
        }
        return 0;
    }
#endif
    if (IsArgEqualTo(arg, _T("/disable-conout-reattach-to-visible-console"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.disable_conout_reattach_to_visible_console = true;
            return 1;
        }
        return 0;
    }
    if (IsArgEqualTo(arg, _T("/allow-conout-attach-to-invisible-parent-console"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.allow_conout_attach_to_invisible_parent_console = true;
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
    if (IsArgEqualTo(arg, _T("/write-console-stdin-back"))) {
        if (IsArgInFilter(start_arg, include_filter_arr)) {
            flags.write_console_stdin_back = true;
            return 1;
        }
        return 0;
    }

    return -1;
}

template <size_t N>
int ParseArgWithSuffixToOption(int & error, const TCHAR * arg, int argc, const TCHAR * argv[], int & arg_offset, Flags & flags, Options & options, const TCHAR * (& include_filter_arr)[N])
{
    // intercept here specific global variables accidental usage instead of local variables
    static struct {} g_options;
    static struct {} g_flags;

    error = err_none;

    const TCHAR * start_arg = arg;
    const TCHAR * arg_suffix = nullptr;

    if (IsArgWithSuffixEqualTo(arg, _T("/EE"), arg_suffix)) {
        const size_t arg_suffix_len = tstrlen(arg_suffix);
        if (arg_suffix_len && tisdigit(*arg_suffix)) {
            const int arg_index = _ttoi(arg_suffix);
            if (arg_index >= 0) {
                if (IsArgWithSuffixInFilter(start_arg, arg_suffix - start_arg, include_filter_arr)) {
                    options.expand_env_args.push_back(std::make_tuple(arg_index, true));
                    return 1;
                }
                return 0;
            }
            else error = invalid_format_flag(start_arg);
        }
        return -1;
    }
    if (IsArgWithSuffixEqualTo(arg, _T("/expand-env-arg"), arg_suffix) || IsArgWithSuffixEqualTo(arg, _T("/E"), arg_suffix)) {
        const size_t arg_suffix_len = tstrlen(arg_suffix);
        if (arg_suffix_len && tisdigit(*arg_suffix)) {
            const int arg_index = _ttoi(arg_suffix);
            if (arg_index >= 0) {
                if (IsArgWithSuffixInFilter(start_arg, arg_suffix - start_arg, include_filter_arr)) {
                    options.expand_env_args.push_back(std::make_tuple(arg_index, false));
                    return 1;
                }
                return 0;
            }
            else error = invalid_format_flag(start_arg);
        }
        return -1;
    }
    if (IsArgWithSuffixEqualTo(arg, _T("/SE"), arg_suffix)) {
        const size_t arg_suffix_len = tstrlen(arg_suffix);
        if (arg_suffix_len && tisdigit(*arg_suffix)) {
            const int arg_index = _ttoi(arg_suffix);
            if (arg_index >= 0) {
                if (IsArgWithSuffixInFilter(start_arg, arg_suffix - start_arg, include_filter_arr)) {
                    options.subst_vars_args.push_back(std::make_tuple(arg_index, true));
                    return 1;
                }
                return 0;
            }
            else error = invalid_format_flag(start_arg);
        }
        return -1;
    }
    if (IsArgWithSuffixEqualTo(arg, _T("/subst-vars-arg"), arg_suffix) || IsArgWithSuffixEqualTo(arg, _T("/S"), arg_suffix)) {
        const size_t arg_suffix_len = tstrlen(arg_suffix);
        if (arg_suffix_len && tisdigit(*arg_suffix)) {
            const int arg_index = _ttoi(arg_suffix);
            if (arg_index >= 0) {
                if (IsArgWithSuffixInFilter(start_arg, arg_suffix - start_arg, include_filter_arr)) {
                    options.subst_vars_args.push_back(std::make_tuple(arg_index, false));
                    return 1;
                }
                return 0;
            }
            else error = invalid_format_flag(start_arg);
        }
        return -1;
    }
    if (IsArgWithSuffixEqualTo(arg, _T("/replace-arg"), arg_suffix) || IsArgWithSuffixEqualTo(arg, _T("/r"), arg_suffix)) {
        const size_t arg_suffix_len = tstrlen(arg_suffix);
        if (arg_suffix_len && tisdigit(*arg_suffix)) {
            const int arg_index = _ttoi(arg_suffix);
            if (arg_index >= 0) {
                arg_offset += 1;
                if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                    const TCHAR * from = arg;

                    arg_offset += 1;
                    if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                        if (IsArgWithSuffixInFilter(start_arg, arg_suffix - start_arg, include_filter_arr)) {
                            const TCHAR * to = arg;

                            options.replace_args.push_back(std::make_tuple(arg_index, std::tstring{ from }, std::tstring{ to }));
                            return 1;
                        }
                        return 0;
                    }
                    else error = invalid_format_flag(start_arg);
                    return 2;
                }
                else error = invalid_format_flag(start_arg);
            }
            else error = invalid_format_flag(start_arg);
        }
        return -1;
    }
    if (IsArgWithSuffixEqualTo(arg, _T("/eval-backslash-esc"), arg_suffix) || IsArgWithSuffixEqualTo(arg, _T("/e"), arg_suffix)) {
        const size_t arg_suffix_len = tstrlen(arg_suffix);
        if (arg_suffix_len && tisdigit(*arg_suffix)) {
            const int arg_index = _ttoi(arg_suffix);
            if (arg_index >= 0) {
                if (IsArgWithSuffixInFilter(start_arg, arg_suffix - start_arg, include_filter_arr)) {
                    options.eval_backslash_esc.push_back(arg_index);
                    return 1;
                }
                return 0;
            }
            else error = invalid_format_flag(start_arg);
        }
        return -1;
    }

    return -1;
}

int main_seh_except_filter(unsigned int code, struct _EXCEPTION_POINTERS *ep)
{
    if (g_flags.allow_throw_seh_except) {
        return EXCEPTION_CONTINUE_SEARCH;
    }
    else {
        return EXCEPTION_EXECUTE_HANDLER;
    }
}

// different main for `callf.exe` and `callfg.exe`
#ifdef _CONSOLE
int _tmain(int argc, const TCHAR * argv[])
#else
int WINAPI wWinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, PWSTR pCmdLine, int nCmdShow)
#endif
{
#ifndef _CONSOLE
    int argc = 0;
    LPCWSTR * argv = NULL;

    PWSTR cmdline_str = GetCommandLine();
    argv = const_cast<LPCWSTR *>(CommandLineToArgvW(cmdline_str, &argc));
#else
    PWSTR cmdline_str = GetCommandLine();
#endif

    TCHAR module_file_name_buf[MAX_PATH];
    const TCHAR * program_file_name = nullptr;
    size_t arg_offset_begin = 0;

    if (argv[0][0] != _T('/')) { // arguments shift detection
        program_file_name = argv[0];
        arg_offset_begin = 1;
    }
    else if (GetModuleFileName(NULL, module_file_name_buf, sizeof(module_file_name_buf) / sizeof(module_file_name_buf[0]))) {
        program_file_name = module_file_name_buf;
    }

#if _DEBUG
    MessageBox(NULL, cmdline_str, program_file_name ? program_file_name : _T(""), MB_OK);
#endif

    // CAUTION:
    //  In Windows if you call `CreateProcess` like this: `CreateProcess("a.exe", "/b", ...)`, then the `argv[0]` would be `/b`, not `a.exe`!
    //

    int ret = err_none;
    DWORD win_error = 0;

    std::vector<_ConsoleWindowOwnerProc> console_window_owner_procs;

    bool is_conout_processed_for_detach_alloc_attach_to_console = false;
    bool is_console_window_inited = false;

#ifdef _DEBUG
    _debug_print_win32_std_handles(1);
    _debug_print_crt_std_handles(1);
#endif

    // NOTE:
    //  lambda to bypass msvc error: `error C2712: Cannot use __try in functions that require object unwinding`
    //
    return ret = [&]() -> int { __try { __try {
        return ret = [&]() -> int {

            // NOTE:
            //  While the current process being started it's console can be hidden by the CreateProcess/ShellExecute from the parent process.
            //  So we have to check the current process console window on visibility and if it is not exist or not visible and
            //  the parent process console is visible, then make temporary reattachment to a parent process console.
            //  Otherwise the output into the stdout/stderr from here won't be visible by the user until the `/attach-parent-console` flag is
            //  applied.
            //  If you don't want such behaviour, then you have to use the `/disable-conout-reattach-to-visible-console` flag.
            //

            if (!argc || !argv[0]) {
                return err_unspecified;
            }

            int arg_offset = arg_offset_begin;

            const TCHAR * arg;
            int parse_error = err_none;
            int parse_result;

            bool print_help = false;

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

                if (!tstrncmp(arg, _T("/?"), 2)) {
                    arg_offset += 1;

                    print_help = true;

#ifndef _CONSOLE
                    // auto attach to parent console to be able to print help
                    g_flags.allow_gui_autoattach_to_parent_console = true;
#endif

                    break;
                }

                if ((parse_result = ParseArgToOption(parse_error, arg, argc, argv, arg_offset, g_regular_flags, g_regular_options, g_flags_to_preparse_arr, g_empty_flags_arr)) >= 0) {
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
                                g_elevate_parent_flags_to_preparse_arr, g_empty_flags_arr) :
                            ParseArgToOption(parse_error, arg, argc, argv, arg_offset,
                                !is_elevate_child_flags ? g_elevate_parent_flags : g_elevate_child_flags,
                                !is_elevate_child_flags ? g_elevate_parent_options : g_elevate_child_options,
                                g_elevate_child_flags_to_preparse_arr, g_empty_flags_arr))) >= 0) {
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

                        if ((parse_result = ParseArgToOption(parse_error, arg, argc, argv, arg_offset, g_promote_flags, g_promote_options, g_promote_flags_to_preparse_arr, g_empty_flags_arr)) >= 0) {
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

                        if ((parse_result = ParseArgToOption(parse_error, arg, argc, argv, arg_offset, g_promote_parent_flags, g_promote_parent_options, g_promote_parent_flags_to_preparse_arr, g_empty_flags_arr)) >= 0) {
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

            // console detach, attach, alloc

            if (g_flags.detach_console && (g_flags.create_console || g_flags.attach_parent_console)) {
                return invalid_format_flag_message(_T("`/detach-console` flag mixed with `/create-console` or `/attach-parent-console`\n"));
            }
            if (g_flags.create_child_console && (g_flags.create_child_console || g_flags.no_window_console)) {
                return invalid_format_flag_message(_T("`/detach-child-console` flag mixed with `/create-child-console` or `/no-window-console`\n"));
            }

            if (!g_flags.disable_conout_duplicate_to_parent_console_on_error) {
                // enable console output buffering by default
                g_enable_conout_prints_buffering = true;
            }

            // disable WOW64 FileSystem redirection

            if (g_flags.disable_wow64_fs_redir) {
                Wow64DisableWow64FsRedirection(&g_disable_wow64_fs_redir_ptr);
            }

            // update process console

            g_inherited_console_window = GetConsoleWindow();

            _StdHandlesState std_handles_state;

            if (g_flags.detach_console) {
                // check if console can be detached

                is_conout_processed_for_detach_alloc_attach_to_console = true;

                if (g_inherited_console_window) {
                    _free_console(std_handles_state);

                    g_inherited_console_window = GetConsoleWindow();
                }
            }

#ifndef _CONSOLE
            if (!is_conout_processed_for_detach_alloc_attach_to_console && g_flags.allow_gui_autoattach_to_parent_console) {
                // check if console is not yet exist
                if (!g_inherited_console_window) {
                    // check if parent process console can be attached
                    g_owned_console_window = _find_console_window_owner_procs(&console_window_owner_procs, g_parent_proc_id);
                    is_console_window_inited = true;

                    _ConsoleWindowOwnerProc ancestor_console_window_owner_proc;

                    // search ancestor console window owner process
                    for (const auto & console_window_owner_proc : console_window_owner_procs) {
                        if (console_window_owner_proc.console_window) {
                            if (g_flags.allow_conout_attach_to_invisible_parent_console || IsWindowVisible(console_window_owner_proc.console_window)) {
                                ancestor_console_window_owner_proc = console_window_owner_proc;
                                break;
                            }
                        }
                    }

                    if (ancestor_console_window_owner_proc.console_window &&
                        g_inherited_console_window != ancestor_console_window_owner_proc.console_window &&
                        ancestor_console_window_owner_proc.proc_id != (DWORD)-1) {
                        // reattach to parent process console window

                        is_conout_processed_for_detach_alloc_attach_to_console = true;

                        _detach_stderr();
                        _detach_stdout();
                        _detach_stdin();

                        g_inherited_console_window = _attach_console(std_handles_state, ancestor_console_window_owner_proc.proc_id, true);

                        if (g_inherited_console_window) {
                            _reinit_crt_std_handles();
                        }

                        if (g_options.has.console_title) {
                            SetConsoleTitle(g_options.console_title.c_str());
                        }
                    }
                }
            }
#endif

            if (!is_conout_processed_for_detach_alloc_attach_to_console && !g_flags.disable_conout_reattach_to_visible_console) {
                // check if console is not visible
                if (g_inherited_console_window && !IsWindowVisible(g_inherited_console_window)) {
                    if (g_flags.create_console) {
                        // check if console can be created
                        g_owned_console_window = _find_console_window_owner_procs(NULL, g_parent_proc_id);
                        is_console_window_inited = true;

                        is_conout_processed_for_detach_alloc_attach_to_console = true;

                        if (!g_owned_console_window) {
                            _detach_stderr();
                            _detach_stdout();
                            _detach_stdin();

                            if (g_inherited_console_window) {
                                _free_console(std_handles_state);
                            }
                            g_inherited_console_window = _alloc_console(std_handles_state);

                            if (g_inherited_console_window) {
                                _reinit_crt_std_handles();
                            }
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
                    }
                    else {
                        // check if parent process console can be attached
                        g_owned_console_window = _find_console_window_owner_procs(&console_window_owner_procs, g_parent_proc_id);
                        is_console_window_inited = true;

                        _ConsoleWindowOwnerProc ancestor_console_window_owner_proc;

                        // search ancestor console window owner process
                        for (const auto & console_window_owner_proc : console_window_owner_procs) {
                            if (console_window_owner_proc.console_window) {
                                if (IsWindowVisible(console_window_owner_proc.console_window)) {
                                    ancestor_console_window_owner_proc = console_window_owner_proc;
                                    break;
                                }
                            }
                        }

                        if (ancestor_console_window_owner_proc.console_window &&
                            g_inherited_console_window != ancestor_console_window_owner_proc.console_window &&
                            ancestor_console_window_owner_proc.proc_id != (DWORD)-1) {
                            // reattach to parent process console window

                            is_conout_processed_for_detach_alloc_attach_to_console = true;

                            _detach_stderr();
                            _detach_stdout();
                            _detach_stdin();

                            if (g_inherited_console_window) {
                                _free_console(std_handles_state);
                            }
                            g_inherited_console_window = _attach_console(std_handles_state, ancestor_console_window_owner_proc.proc_id, true);

                            if (g_inherited_console_window) {
                                _reinit_crt_std_handles();
                            }

                            if (g_options.has.console_title) {
                                SetConsoleTitle(g_options.console_title.c_str());
                            }
                        }
                    }
                }
            }

            if (!is_conout_processed_for_detach_alloc_attach_to_console) {
                if (g_flags.create_console) {
                    // check if console can be created
                    if (!is_console_window_inited) {
                        g_owned_console_window = _find_console_window_owner_procs(NULL, g_parent_proc_id);
                        is_console_window_inited = true;
                    }

                    if (!g_owned_console_window) {
                        _detach_stderr();
                        _detach_stdout();
                        _detach_stdin();

                        if (g_inherited_console_window) {
                            _free_console(std_handles_state);
                        }
                        g_inherited_console_window = _alloc_console(std_handles_state);

                        if (g_inherited_console_window) {
                            _reinit_crt_std_handles();
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
                    }
                }
                else if (g_flags.attach_parent_console) {
                    // check if parent process console can be attached
                    g_owned_console_window = _find_console_window_owner_procs(&console_window_owner_procs, g_parent_proc_id);
                    is_console_window_inited = true;

                    _ConsoleWindowOwnerProc ancestor_console_window_owner_proc;

                    // search ancestor console window owner process
                    for (const auto & console_window_owner_proc : console_window_owner_procs) {
                        if (console_window_owner_proc.console_window) {
                            if (g_flags.allow_conout_attach_to_invisible_parent_console || IsWindowVisible(console_window_owner_proc.console_window)) {
                                ancestor_console_window_owner_proc = console_window_owner_proc;
                                break;
                            }
                        }
                    }

                    if (ancestor_console_window_owner_proc.console_window &&
                        g_inherited_console_window != ancestor_console_window_owner_proc.console_window &&
                        ancestor_console_window_owner_proc.proc_id != (DWORD)-1) {
                        // reattach to parent process console window

                        is_conout_processed_for_detach_alloc_attach_to_console = true;

                        _detach_stderr();
                        _detach_stdout();
                        _detach_stdin();

                        if (g_inherited_console_window) {
                            _free_console(std_handles_state);
                        }
                        g_inherited_console_window = _attach_console(std_handles_state, ancestor_console_window_owner_proc.proc_id, true);

                        if (g_inherited_console_window) {
                            _reinit_crt_std_handles();
                        }

                        if (g_options.has.console_title) {
                            SetConsoleTitle(g_options.console_title.c_str());
                        }
                    }
                }
                else {
                    if (!is_console_window_inited) {
                        g_owned_console_window = _find_console_window_owner_procs(NULL, g_parent_proc_id);
                        is_console_window_inited = true;
                    }

                    if (g_owned_console_window && g_options.has.own_console_title) {
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

#ifdef _DEBUG
            _debug_print_win32_std_handles(2);
            _debug_print_crt_std_handles(2);
#endif

            if (g_inherited_console_window) {
#ifndef _CONSOLE
                // only owned console available for change the show state
                if (g_owned_console_window) {
                    ShowWindow(g_inherited_console_window, nCmdShow);
                }
#endif

                if (!_sanitize_std_handles(ret, win_error, std_handles_state, g_flags, g_options)) {
                    if (g_flags.ret_win_error) {
                        return win_error;
                    }
                    else {
                        return ret;
                    }
                }
            }

#ifdef _DEBUG
            _debug_print_win32_std_handles(3);
            _debug_print_crt_std_handles(3);
#endif

            arg_offset = arg_offset_begin;

            if (print_help) {
                _put_raw_message_impl(0, STDOUT_FILENO,
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
                    if (!parse_result && parse_error == err_none) {
                        parse_error = invalid_format_flag(arg);
                    }
                    if (parse_error != err_none) {
                        return parse_error;
                    }
                }
                else if ((parse_result = ParseArgWithSuffixToOption(parse_error, arg, argc, argv, arg_offset, g_regular_flags, g_regular_options, g_flags_w_index_to_parse_arr)) >= 0) {
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
                            if (!parse_result && parse_error == err_none) {
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
                            if (!parse_result && parse_error == err_none) {
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
                            if (!parse_result && parse_error == err_none) {
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

            // no-std*-inherit

            if (g_flags.no_std_inherit && (g_flags.no_stdin_inherit || g_flags.no_stdout_inherit || g_flags.no_stderr_inherit)) {
                return invalid_format_flag_message(_T("standard handles inheritance prevention flags are mixed: /no-std*-inherit\n"));
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

            if (g_flags.tee_conout_dup && (tee_stdout_as_count >= 1 || tee_stderr_as_count >= 1 || g_options.tee_stdout_dup != -1 || g_options.tee_stderr_dup != -1)) {
                return invalid_format_flag_message(_T("tee conout is mixed\n"));
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

            if (g_flags.tee_conout_dup && !tee_stdin_as_count) {
                return invalid_format_flag_message(_T("tee stdin duplication of not opened handle into conout\n"));
            }

            // stdout-vt100, stderr-vt100 vs output-vt100
            if (g_flags.output_vt100) {
                if (g_flags.stdout_vt100 || g_flags.stderr_vt100) {
                    return invalid_format_flag_message(_T("vt100 flags are mixed: /output-vt100 <-> /std*-vt100\n"));
                }
            }


            // /pipe-*

            if (g_flags.pipe_stdin_to_stdout) {
                if (g_flags.pipe_stdin_to_child_stdin) {
                    return invalid_format_flag_message(_T("pipe flags are mixed: /pipe-stdin-to-child-stdin <-> /pipe-stdin-to-stdout\n"));
                }
                if (g_flags.pipe_child_stdout_to_stdout) {
                    return invalid_format_flag_message(_T("pipe flags are mixed: /pipe-child-stdout-to-stdout <-> /pipe-stdin-to-stdout\n"));
                }
                if (g_flags.pipe_child_stderr_to_stderr) {
                    return invalid_format_flag_message(_T("pipe flags are mixed: /pipe-child-stderr-to-stderr <-> /pipe-stdin-to-stdout\n"));
                }
                if (g_flags.pipe_inout_child) {
                    return invalid_format_flag_message(_T("pipe flags are mixed: /pipe-inout-child <-> /pipe-stdin-to-stdout\n"));
                }
                if (g_flags.pipe_out_child) {
                    return invalid_format_flag_message(_T("pipe flags are mixed: /pipe-out-child <-> /pipe-stdin-to-stdout\n"));
                }
            }

            if (g_flags.pipe_inout_child && g_flags.pipe_out_child) {
                return invalid_format_flag_message(_T("pipe flags are mixed: /pipe-inout-child <-> /pipe-out-child\n"));
            }

            // /stdin-echo

            if (g_flags.stdin_echo && g_flags.no_stdin_echo) {
                return invalid_format_flag_message(_T("stdin echo flags are mixed: /stdin-echo <-> /no-stdin-echo\n"));
            }

            // promote{ ... } vs promote-parent{ ... }

            if (g_promote_options.chcp_in != 0 && g_promote_parent_options.chcp_in != 0) {
                return invalid_format_flag_message(_T("promote option mixed with promote-parent option: promote.chcp_in=%i promote-parent.chcp_in=%i\n"), g_promote_options.chcp_in, g_promote_parent_options.chcp_in);
            }
            if (g_promote_options.chcp_out != 0 && g_promote_parent_options.chcp_out != 0) {
                return invalid_format_flag_message(_T("promote option mixed with promote-parent option: promote.chcp_out=%i promote-parent.chcp_out=%i\n"), g_promote_options.chcp_out, g_promote_parent_options.chcp_out);
            }
            if (g_promote_flags.attach_parent_console && g_promote_parent_flags.attach_parent_console) {
                return invalid_format_flag_message(_T("promote option mixed with promote-parent option: /attach-parent-console\n"));
            }

            if (g_promote_flags.pause_on_exit_if_error_before_exec && g_promote_parent_flags.pause_on_exit_if_error_before_exec) {
                return invalid_format_flag_message(_T("promote option mixed with promote-parent option: /pause-on-exit-if-error-before-exec\n"));
            }
            if (g_promote_flags.pause_on_exit_if_error && g_promote_parent_flags.pause_on_exit_if_error) {
                return invalid_format_flag_message(_T("promote option mixed with promote-parent option: /pause-on-exit-if-error\n"));
            }
            if (g_promote_flags.pause_on_exit && g_promote_parent_flags.pause_on_exit) {
                return invalid_format_flag_message(_T("promote option mixed with promote-parent option: /pause-on-exit\n"));
            }

            if (g_promote_flags.disable_wow64_fs_redir && g_promote_parent_flags.disable_wow64_fs_redir) {
                return invalid_format_flag_message(_T("promote option mixed with promote-parent option: /disable-wow64-fs-redir\n"));
            }

            if (g_promote_flags.allow_gui_autoattach_to_parent_console && g_promote_parent_flags.allow_gui_autoattach_to_parent_console) {
                return invalid_format_flag_message(_T("promote option mixed with promote-parent option: /allow-gui-autoattach-to-parent-console\n"));
            }
            if (g_promote_flags.disable_conout_reattach_to_visible_console && g_promote_parent_flags.disable_conout_reattach_to_visible_console) {
                return invalid_format_flag_message(_T("promote option mixed with promote-parent option: /disable-conout-reattach-to-visible-console\n"));
            }
            if (g_promote_flags.allow_conout_attach_to_invisible_parent_console && g_promote_parent_flags.allow_conout_attach_to_invisible_parent_console) {
                return invalid_format_flag_message(_T("promote option mixed with promote-parent option: /allow-conout-attach-to-invisible-parent-console\n"));
            }
            if (g_promote_flags.disable_conout_duplicate_to_parent_console_on_error && g_promote_parent_flags.disable_conout_duplicate_to_parent_console_on_error) {
                return invalid_format_flag_message(_T("promote option mixed with promote-parent option: /disable-conout-duplicate-to-parent-console-on-error\n"));
            }

            // /write-console-stdin-back vs /pipe-*

            if (g_flags.write_console_stdin_back) {
                if (g_flags.pipe_stdin_to_child_stdin || g_flags.pipe_child_stdout_to_stdout || g_flags.pipe_child_stderr_to_stderr || g_flags.pipe_inout_child || g_flags.pipe_out_child || g_flags.pipe_stdin_to_stdout) {
                    return invalid_format_flag_message(_T("write console stdin back flag mixed with pipe flags: /write_console_stdin_back <-> /pipe-*\n"));
                }
            }

            // `/no-expand-env` vs `/allow-expand-unexisted-env`
            if (g_flags.no_expand_env && g_flags.allow_expand_unexisted_env) {
                return invalid_format_flag_message(_T("environment variables expansion flags are mixed: /no-expand-env <-> /allow-expand-unexisted-env\n"));
            }

            // `/expand-env-arg<N>`, `/E<N>`, `/EE<N>` vs `/no-expand-env`
            if (g_flags.no_expand_env && !g_options.expand_env_args.empty()) {
                return invalid_format_flag_message(_T("environment variables expansion flags are mixed: /no-expand-env <-> /expand-env-arg<N>, /E<N>, /EE<N>\n"));
            }

            // `/EE<N>` vs `/allow-expand-unexisted-env`
            if (g_flags.allow_expand_unexisted_env && !g_options.expand_env_args.empty()) {
                for (auto it = g_options.expand_env_args.begin(); it != g_options.expand_env_args.end(); ++it) {
                    const int expand_env_arg_index = std::get<0>(*it);
                    const bool allow_expand_unexisted_env = std::get<1>(*it);
                    if (allow_expand_unexisted_env) {
                        return invalid_format_flag_message(_T("environment variables expansion flags are mixed: /allow-expand-unexisted-env <-> /EE<N>\n"));
                    }
                }
            }

            // `/expand-env-arg<N>`, `/E<N>`, `/EE<N>` vs `/expand-env-arg<N>`, `/E<N>`, `/EE<N>`
            if (g_options.expand_env_args.size() > 1) {
                for (auto it = g_options.expand_env_args.begin(), next_it = it; it != g_options.expand_env_args.end(); it = next_it) {
                    ++next_it;
                    const int expand_env_arg_index = std::get<0>(*it);
                    for (auto it2 = next_it; it2 != g_options.expand_env_args.end(); ++it2) {
                        const int expand_env_arg_index2 = std::get<0>(*it2);
                        if (expand_env_arg_index == expand_env_arg_index2) {
                            return invalid_format_flag_message(_T("environment variables expansion flags are mixed: /expand-env-arg<N>, /E<N> <-> /EE<N>: N=%i\n"), expand_env_arg_index);
                        }
                    }
                }
            }

            // `/no-subst-vars` vs `/allow-subst-empty-args`
            if (g_flags.no_subst_vars && g_flags.allow_subst_empty_args) {
                return invalid_format_flag_message(_T("variables substitution flags are mixed: /no-subst-vars <-> /allow-subst-empty-args\n"));
            }

            // `/subst-vars-arg<N>`, `/S<N>`, `/SE<N>` vs `/no-expand-env`
            if (!g_options.subst_vars_args.empty() && g_flags.no_subst_vars) {
                return invalid_format_flag_message(_T("variables substitution flags are mixed: /no-subst-vars <-> /subst-vars-arg<N>, /S<N>, /SE<N>\n"));
            }

            // `/SE<N>` vs `/allow-subst-empty-args`
            if (!g_options.subst_vars_args.empty() && g_flags.allow_subst_empty_args) {
                for (auto it = g_options.subst_vars_args.begin(); it != g_options.subst_vars_args.end(); ++it) {
                    const int subst_vars_arg_index = std::get<0>(*it);
                    const bool allow_subst_empty_arg = std::get<1>(*it);
                    if (allow_subst_empty_arg) {
                        return invalid_format_flag_message(_T("variables substitution flags are mixed: /allow-subst-empty-args <-> /SE<N>\n"));
                    }
                }
            }

            // `/subst-vars-arg<N>`, `/S<N>`, `/SE<N>` vs `/subst-vars-arg<N>`, `/S<N>`, `/SE<N>`
            if (g_options.subst_vars_args.size() > 1) {
                for (auto it = g_options.subst_vars_args.begin(), next_it = it; it != g_options.subst_vars_args.end(); it = next_it) {
                    ++next_it;
                    const int subst_arg_index = std::get<0>(*it);
                    for (auto it2 = next_it; it2 != g_options.subst_vars_args.end(); ++it2) {
                        const int subst_arg_index2 = std::get<0>(*it2);
                        if (subst_arg_index == subst_arg_index2) {
                            return invalid_format_flag_message(_T("variables substitution flags are mixed: /subst-vars-arg<N>, /S<N> <-> /SE<N>: N=%i\n"), subst_arg_index);
                        }
                    }
                }
            }

            // [0] = `{*}`
            // [1] = `{@}`
            //
            size_t special_cmdline_arg_index_arr[2] = { size_t(arg_offset) + 2, size_t(arg_offset) + 3 };
            ptrdiff_t special_cmdline_arg_offset_arr[2];

            _get_cmdline_arg_offsets(cmdline_str, special_cmdline_arg_index_arr, special_cmdline_arg_offset_arr);

            // environment variable buffer
            TCHAR env_buf[MAX_ENV_BUF_SIZE];

            // <ApplicationNameFormatString> or <FilePathFormatString>
            // <CommandLineFormatString> or <ParametersFormatString>
            //
            // CAUTION:
            //  In case of ShellExecute the <ParametersFormatString> must contain only a command line arguments,
            //  but not the path to the executable itself which is part of <CommandLineFormatString>!
            //
            InArgs in_args = InArgs();
            OutArgs out_args = OutArgs();

            if (argc >= arg_offset + 1 && (arg = argv[arg_offset]) && tstrlen(arg)) {
                in_args.app_fmt_str = arg;
                if (!tstrcmp(in_args.app_fmt_str, _T(""))) {
                    in_args.app_fmt_str = nullptr;
                }
            }

            arg_offset += 1;

            if (argc >= arg_offset + 1 && (arg = argv[arg_offset]) && tstrlen(arg)) {
                in_args.cmd_fmt_str = arg;
                if (!tstrcmp(in_args.cmd_fmt_str, _T(""))) {
                    in_args.cmd_fmt_str = nullptr;
                }
            }

            arg_offset += 1;

            if (g_options.shell_exec_verb.empty()) {
                if (!in_args.app_fmt_str && !in_args.cmd_fmt_str) {
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
                if (!in_args.app_fmt_str) {
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

            // update environment variables before ${...} environment variables expansion in command line
            for (const auto & env_vars_ref : g_options.env_vars) {
                // expand ${...} variables for `<value>` in `/v <name> <value>` options
                if (!g_flags.no_expand_env) {
                    std::tstring tmp;

                    _parse_string(-3, std::get<1>(env_vars_ref).c_str(), tmp, env_buf, false, true, false, g_flags, g_options, cmdline_str, special_cmdline_arg_offset_arr);

                    SetEnvironmentVariable(std::get<0>(env_vars_ref).c_str(), tmp.c_str());
                }
                else {
                    SetEnvironmentVariable(std::get<0>(env_vars_ref).c_str(), std::get<1>(env_vars_ref).c_str());
                }
            }

            if (in_args.app_fmt_str) {
                out_args.app_fmt_str = in_args.app_fmt_str;
            }

            if (in_args.cmd_fmt_str) {
                out_args.cmd_fmt_str = in_args.cmd_fmt_str;
            }

            // read and parse tail arguments
            if (argc >= arg_offset + 1) {
                const int num_args = argc - arg_offset;

                in_args.args.resize(num_args);
                out_args.args.resize(num_args);

                for (int i = 0; i < num_args; i++) {
                    in_args.args[i] = argv[arg_offset + i];
                }

                // expand ${...} variables before {...} variables
                if (!g_flags.no_expand_env) {
                    for (int i = 0; i < num_args; i++) {
                        if (tstrcmp(in_args.args[i], _T(""))) {
                            _parse_string(i, in_args.args[i], out_args.args[i], env_buf,
                                false, true, true, g_flags, g_options,
                                cmdline_str, special_cmdline_arg_offset_arr,
                                in_args, out_args);
                        }
                        else {
                            in_args.args[i] = nullptr;
                        }
                    }
                }
                else {
                    // copy input arguments to output arguments
                    for (int i = 0; i < num_args; i++) {
                        if (in_args.args[i] && tstrcmp(in_args.args[i], _T(""))) {
                            out_args.args[i] = in_args.args[i];
                        }
                        else {
                            in_args.args[i] = nullptr;
                        }
                    }
                }

                // replace strings per argument
                for (const auto & replace_args_ref : g_options.replace_args) {
                    int replace_offset = std::get<0>(replace_args_ref);

                    if (replace_offset >= 2) {
                        // variadic arguments
                        replace_offset -= 2;

                        if (size_t(replace_offset) < out_args.args.size()) {
                            if (in_args.args[replace_offset]) {
                                out_args.args[replace_offset] = _replace_strings(out_args.args[replace_offset], std::get<1>(replace_args_ref), std::get<2>(replace_args_ref));
                            }
                        }
                    }
                }

                // replace strings per range
                for (const auto & replace_args_ref : g_options.replace_args) {
                    const int replace_offset = std::get<0>(replace_args_ref);

                    if (replace_offset < 0) {
                        for (int i = 0; i < num_args; i++) {
                            if (in_args.args[i]) {
                                out_args.args[i] = _replace_strings(out_args.args[i], std::get<1>(replace_args_ref), std::get<2>(replace_args_ref));
                            }
                        }
                    }
                }

                // expand {...} variables
                if (!g_flags.no_subst_vars) {
                    std::tstring tmp;

                    for (int i = 0; i < num_args; i++) {
                        tmp.clear();
                        _parse_string(i, out_args.args[i].c_str(), tmp, env_buf,
                            true, false, false, g_flags, g_options,
                            cmdline_str, special_cmdline_arg_offset_arr,
                            InArgs{}, out_args);
                        out_args.args[i] = std::move(tmp);
                    }
                }

                // backslash escaping per argument
                for (const auto & eval_backslash_esc_ref : g_options.eval_backslash_esc) {
                    int escape_offset = std::get<0>(eval_backslash_esc_ref);

                    if (escape_offset >= 2) {
                        // variadic arguments
                        escape_offset -= 2;

                        if (size_t(escape_offset) < out_args.args.size()) {
                            if (in_args.args[escape_offset]) {
                                out_args.args[escape_offset] = _eval_escape_chars(out_args.args[escape_offset], true, false);
                            }
                        }
                    }
                }

                // backslash escaping per range
                for (const auto & eval_backslash_esc_ref : g_options.eval_backslash_esc) {
                    const int escape_offset = std::get<0>(eval_backslash_esc_ref);

                    if (escape_offset < 0) {
                        for (int i = 0; i < num_args; i++) {
                            if (in_args.args[i]) {
                                out_args.args[i] = _eval_escape_chars(out_args.args[i], true, false);
                            }
                        }
                    }
                }
            }

            // expand ${...} variables before {...} variables
            if (!g_flags.no_expand_env) {
                if (in_args.app_fmt_str) {
                    std::tstring tmp;
                    _parse_string(-2, out_args.app_fmt_str.c_str(), tmp, env_buf,
                        false, true, false, g_flags, g_options,
                        cmdline_str, special_cmdline_arg_offset_arr,
                        in_args, out_args);
                    out_args.app_fmt_str = std::move(tmp);
                }
                if (in_args.cmd_fmt_str) {
                    std::tstring tmp;
                    _parse_string(-1, out_args.cmd_fmt_str.c_str(), tmp, env_buf,
                        false, true, false, g_flags, g_options,
                        cmdline_str, special_cmdline_arg_offset_arr,
                        in_args, out_args);
                    out_args.cmd_fmt_str = std::move(tmp);
                }
            }

            // replace strings per argument
            for (const auto & replace_args_ref : g_options.replace_args) {
                const int replace_offset = std::get<0>(replace_args_ref);

                if (replace_offset == 0) {
                    if (in_args.app_fmt_str) {
                        out_args.app_fmt_str = _replace_strings(out_args.app_fmt_str, std::get<1>(replace_args_ref), std::get<2>(replace_args_ref));
                    }
                }
                else if (replace_offset == 1) {
                    if (in_args.cmd_fmt_str) {
                        out_args.cmd_fmt_str = _replace_strings(out_args.cmd_fmt_str, std::get<1>(replace_args_ref), std::get<2>(replace_args_ref));
                    }
                }
            }

            // replace strings per range
            for (const auto & replace_args_ref : g_options.replace_args) {
                const int replace_offset = std::get<0>(replace_args_ref);

                if (replace_offset == -1) {
                    if (in_args.app_fmt_str) {
                        out_args.app_fmt_str = _replace_strings(out_args.app_fmt_str, std::get<1>(replace_args_ref), std::get<2>(replace_args_ref));
                    }
                }
                if (replace_offset == -1 || replace_offset == -2) {
                    if (in_args.cmd_fmt_str) {
                        out_args.cmd_fmt_str = _replace_strings(out_args.cmd_fmt_str, std::get<1>(replace_args_ref), std::get<2>(replace_args_ref));
                    }
                }
            }

            // expand {...} variables
            if (!g_flags.no_subst_vars) {
                if (in_args.app_fmt_str) {
                    std::tstring tmp;
                    _parse_string(-2, out_args.app_fmt_str.c_str(), tmp, env_buf,
                        true, false, false, g_flags, g_options,
                        cmdline_str, special_cmdline_arg_offset_arr,
                        in_args, out_args);
                    out_args.app_fmt_str = std::move(tmp);
                }
                if (in_args.cmd_fmt_str) {
                    std::tstring tmp;
                    _parse_string(-1, out_args.cmd_fmt_str.c_str(), tmp, env_buf,
                        true, false, false, g_flags, g_options,
                        cmdline_str, special_cmdline_arg_offset_arr,
                        in_args, out_args);
                    out_args.cmd_fmt_str = std::move(tmp);
                }
            }

            // backslash escaping per argument
            for (const auto & eval_backslash_esc_ref : g_options.eval_backslash_esc) {
                const int escape_offset = std::get<0>(eval_backslash_esc_ref);

                if (escape_offset == 0) {
                    if (in_args.app_fmt_str) {
                        out_args.app_fmt_str = _eval_escape_chars(out_args.app_fmt_str, g_flags.eval_backslash_esc, g_flags.eval_dbl_backslash_esc);
                    }
                }
                else if (escape_offset == 1) {
                    if (in_args.cmd_fmt_str) {
                        out_args.cmd_fmt_str = _eval_escape_chars(out_args.cmd_fmt_str, g_flags.eval_backslash_esc, g_flags.eval_dbl_backslash_esc);
                    }
                }

            }

            // backslash escaping per range
            if (g_flags.eval_backslash_esc || g_flags.eval_dbl_backslash_esc) {
                if (in_args.app_fmt_str) {
                    out_args.app_fmt_str = _eval_escape_chars(out_args.app_fmt_str, g_flags.eval_backslash_esc, g_flags.eval_dbl_backslash_esc);
                }
                if (in_args.cmd_fmt_str) {
                    out_args.cmd_fmt_str = _eval_escape_chars(out_args.cmd_fmt_str, g_flags.eval_backslash_esc, g_flags.eval_dbl_backslash_esc);
                }
            }

            // reset flags and options
            g_flags = g_regular_flags;
            g_options = g_regular_options;

            if (g_is_process_elevating) {
                std::tstring elevated_cmd_out_str;

                TranslateCommandLineToElevated(
                    in_args.app_fmt_str ? utility::addressof(out_args.app_fmt_str) : nullptr,
                    in_args.cmd_fmt_str ? utility::addressof(out_args.cmd_fmt_str) : nullptr,
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

                const LPCTSTR app = program_file_name ? program_file_name : (LPCTSTR)NULL;
                const size_t app_len = program_file_name ? tstrlen(program_file_name) : 0;

                return ExecuteProcess(
                    app,
                    app_len,
                    !elevated_cmd_out_str.empty() ? elevated_cmd_out_str.c_str() : (LPCTSTR)NULL,
                    !elevated_cmd_out_str.empty() ? elevated_cmd_out_str.length() : 0
                );
            }

            // merge options (third time)
            MergeOptions(g_flags, g_options,
                g_elevate_parent_flags, g_elevate_parent_options,
                g_promote_flags, g_promote_options, g_promote_parent_flags, g_promote_parent_options);

            SubstOptionsPlaceholders(g_options);

            const LPCTSTR app = in_args.app_fmt_str ? out_args.app_fmt_str.c_str() : (LPCTSTR)NULL;
            const size_t app_len = in_args.app_fmt_str ? out_args.app_fmt_str.length() : 0;

            return ExecuteProcess(
                app,
                app_len,
                in_args.cmd_fmt_str ? out_args.cmd_fmt_str.c_str() : (LPCTSTR)NULL,
                in_args.cmd_fmt_str ? out_args.cmd_fmt_str.length() : 0
            );
        }();
    }
    __except (main_seh_except_filter(GetExceptionCode(), GetExceptionInformation())) {
        return ret = err_seh_exception;
    }
    }
    __finally {
        [&]() {
            const bool pause_on_exit = g_flags.pause_on_exit || g_flags.pause_on_exit_if_error && ret != err_none || g_flags.pause_on_exit_if_error_before_exec && !g_is_process_executed && ret != err_none;

#ifdef _DEBUG
            if (pause_on_exit || g_conout_prints_buf.size()) {
                _debug_print_win32_std_handles(8);
                _debug_print_crt_std_handles(8);
            }
#endif

            if (pause_on_exit) {
                _put_raw_message_impl(0, STDOUT_FILENO, "Press any key to continue . . . \n");
                getch();
            }

            if (g_enable_conout_prints_buffering && !g_is_process_executed) {
                if (!is_console_window_inited || g_owned_console_window && !console_window_owner_procs.size()) {
                    g_owned_console_window = _find_console_window_owner_procs(&console_window_owner_procs, g_parent_proc_id);
                    is_console_window_inited = true;
                }

                if (g_owned_console_window) {
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

                    _StdHandlesState std_handles_state;

                    if (!g_inherited_console_window) {
                        g_inherited_console_window = GetConsoleWindow();
                    }

                    _detach_stderr();
                    _detach_stdout();
                    _detach_stdin();

                    if (g_inherited_console_window) {
                        _free_console(std_handles_state);
                    }
                    if (ancestor_console_window_owner_proc.proc_id != (DWORD)-1) {
                        g_inherited_console_window = _attach_console(std_handles_state, ancestor_console_window_owner_proc.proc_id, true);
                    }

                    if (g_inherited_console_window) {
                        _reinit_crt_std_handles();

#ifdef _DEBUG
                        if (g_conout_prints_buf.size()) {
                            _debug_print_win32_std_handles(9);
                            _debug_print_crt_std_handles(9);
                        }
#endif

                        for (const auto & conout : g_conout_prints_buf) {
                            if (conout.any_str.is_wstr) {
                                _put_raw_message_impl(0, conout.stream_type, conout.any_str.wstr);
                            }
                            else {
                                _put_raw_message_impl(0, conout.stream_type, conout.any_str.astr);
                            }
                        }
                    }
                }
            }

            if (g_flags.disable_wow64_fs_redir) {
                Wow64RevertWow64FsRedirection(g_disable_wow64_fs_redir_ptr);
                g_disable_wow64_fs_redir_ptr = NULL; // just in case
            }

#ifndef _CONSOLE
            if (argv) {
                LocalFree(argv);
            }
#endif
        }();
    }
    }();
}
