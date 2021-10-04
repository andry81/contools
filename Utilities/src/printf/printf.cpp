#define _CRT_SECURE_NO_WARNINGS
//#define WIN32_LEAN_AND_MEAN // Exclude rarely-used stuff from Windows headers

#include <windows.h>
#include <stdio.h>

#include "common.hpp"
#include "printf.hpp"

//#ifdef _UNICODE
//#error Unicode is not supported.
//#endif

namespace {
    struct InArgs : InBaseArgs
    {
        const TCHAR *   fmt_str;
    };

    struct OutArgs : OutBaseArgs
    {
        std::tstring    fmt_str;
    };

    struct _Flags
    {
        _Flags()
        {
            // raw initialization
            memset(this, 0, sizeof(*this));
        }

        _Flags(const _Flags &) = default;
        _Flags(_Flags &&) = default;

        _Flags & operator =(const _Flags &) = default;
        //_Flags && operator =(_Flags &&) = default;

        bool            no_print_gen_error_string;
        bool            no_expand_env;                  // don't expand `${...}` environment variables
        bool            no_subst_vars;                  // don't substitute `{...}` variables (command line parameters)
        bool            no_subst_empty_tail_vars;       // don't substitute empty `{*}` and `{@}` variables

        bool            allow_expand_unexisted_env;
        bool            allow_subst_empty_args;

        bool            eval_backslash_esc;             // evaluate backslash escape characters
        bool            eval_dbl_backslash_esc;         // evaluate double backslash escape characters (`\\`)
    };

    struct _Options
    {
        _Options()
        {
            chcp = 0;
        }

        _Options(const _Options &) = default;
        _Options(_Options &&) = default;

        _Options & operator =(const _Options &) = default;
        //_Options && operator =(_Options &&) = default;

        unsigned int    chcp;

        // std::tuple<argument_offset_index, allow_expand_unexisted_env_var>:
        //  argument_offset_index: -1 - all, -2 - greater or equal to 1
        std::deque<std::tuple<int, bool> > expand_env_args;

        // std::tuple<argument_offset_index, allow_subst_empty_arg>:
        //  argument_offset_index: -1 - all, -2 - greater or equal to 1
        std::deque<std::tuple<int, bool> > subst_vars_args;
    };

    _Flags g_flags                      = {};
    _Options g_options                  = {};
}

int _tmain(int argc, const TCHAR * argv[])
{
    PWSTR cmdline_str = GetCommandLine();

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

    if (!argc || !argv[0]) {
        return err_unspecified;
    }

    const TCHAR * arg;
    int arg_offset = arg_offset_begin;

    if (argc >= arg_offset + 1 && argv[arg_offset] && !tstrcmp(argv[arg_offset], _T("/?"))) {
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
                fputs("error: flag is invalid", stderr);
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

        if (!tstrcmp(arg, _T("/chcp"))) {
            arg_offset += 1;
            if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                g_options.chcp = _ttoi(arg);
            }
            else {
                if (!g_flags.no_print_gen_error_string) {
                    _ftprintf(stderr, _T("error: flag format is invalid: \"%s\""), arg);
                }
                return err_invalid_format;
            }
        }
        else if (!tstrcmp(arg, _T("/no-print-gen-error-string"))) {
            g_flags.no_print_gen_error_string = true;
        }
        else if (!tstrcmp(arg, _T("/no-expand-env"))) {
            g_flags.no_expand_env = true;
        }
        else if (!tstrcmp(arg, _T("/no-subst-vars"))) {
            g_flags.no_subst_vars = true;
        }
        else if (!tstrcmp(arg, _T("/no-subst-empty-tail-vars"))) {
            g_flags.no_subst_empty_tail_vars = true;
        }
        else if (!tstrcmp(arg, _T("/allow-expand-unexisted-env"))) {
            g_flags.allow_expand_unexisted_env = true;
        }
        else if (!tstrcmp(arg, _T("/allow-subst-empty-args"))) {
            g_flags.allow_subst_empty_args = true;
        }
        else if (!tstrcmp(arg, _T("/eval-backslash-esc")) || !tstrcmp(arg, _T("/e"))) {
            g_flags.eval_backslash_esc = true;
        }
        else if (!tstrcmp(arg, _T("/eval-dbl-backslash-esc")) || !tstrcmp(arg, _T("/e\\\\"))) {
            g_flags.eval_dbl_backslash_esc = true;
        }
        else {
            if (!g_flags.no_print_gen_error_string) {
                _ftprintf(stderr, _T("error: flag is not known: \"%s\""), arg);
            }
            return err_invalid_format;
        }

        arg_offset += 1;
    }

    // `/no-expand-env` vs `/allow-expand-unexisted-env`
    if (g_flags.no_expand_env && g_flags.allow_expand_unexisted_env) {
        fputs("error: `/no-expand-env` flag mixed with `/allow-expand-unexisted-env`\n", stderr);
        return err_invalid_format;
    }

    // `/no-subst-vars` vs `/allow-subst-empty-args`
    if (g_flags.no_subst_vars && g_flags.allow_subst_empty_args) {
        fputs("error: `/no-subst-vars` flag mixed with `/allow-subst-empty-args`\n", stderr);
        return err_invalid_format;
    }

    // [0] = `{*}`
    // [1] = `{@}`
    //
    size_t special_cmdline_arg_index_arr[2] = { size_t(arg_offset) + 1, size_t(arg_offset) + 2 };
    ptrdiff_t special_cmdline_arg_offset_arr[2];

    _get_cmdline_arg_offsets(cmdline_str, special_cmdline_arg_index_arr, special_cmdline_arg_offset_arr);

    // environment variable buffer
    TCHAR env_buf[MAX_ENV_BUF_SIZE];

    InArgs in_args = InArgs();
    OutArgs out_args = OutArgs();

    if (argc >= arg_offset + 1 && (arg = argv[arg_offset]) && tstrlen(arg)) {
        in_args.fmt_str = arg;
        if (!tstrcmp(in_args.fmt_str, _T(""))) {
            in_args.fmt_str = nullptr;
        }
    }

    arg_offset += 1;

    if (!in_args.fmt_str) {
        if (!g_flags.no_print_gen_error_string) {
            fputs("error: format string is empty", stderr);
        }
        return err_format_empty;
    }

    // read and parse tail arguments
    if (argc >= arg_offset + 1 && in_args.fmt_str) {
        const int num_args = argc - arg_offset;

        in_args.args.resize(num_args);
        out_args.args.resize(num_args);

        for (int i = 0; i < num_args; i++) {
            in_args.args[i] = argv[arg_offset + i];
        }
        // double pass to expand ${...} variables before {...} variables
        if (!g_flags.no_expand_env && !g_flags.no_subst_vars) {
            std::tstring tmp;

            for (int i = 0; i < num_args; i++) {
                if (tstrcmp(in_args.args[i], _T(""))) {
                    _parse_string(i, in_args.args[i], out_args.args[i], env_buf,
                        false, true, true,
                        g_flags, g_options,
                        cmdline_str, special_cmdline_arg_offset_arr,
                        in_args, out_args);
                }
                else {
                    in_args.args[i] = nullptr;
                }
            }
            for (int i = 0; i < num_args; i++) {
                tmp.clear();
                _parse_string(i, out_args.args[i].c_str(), tmp, env_buf,
                    true, false, false,
                    g_flags, g_options,
                    cmdline_str, special_cmdline_arg_offset_arr,
                    InArgs{}, out_args);
                out_args.args[i] = std::move(tmp);
            }
        }
        else {
            for (int i = 0; i < num_args; i++) {
                if (tstrcmp(in_args.args[i], _T(""))) {
                    _parse_string(i, in_args.args[i], out_args.args[i], env_buf,
                        g_flags.no_expand_env, g_flags.no_subst_vars, true,
                        g_flags, g_options,
                        cmdline_str, special_cmdline_arg_offset_arr,
                        in_args, out_args);
                }
                else {
                    in_args.args[i] = nullptr;
                }
            }
        }
    }

    _parse_string(-1, in_args.fmt_str, out_args.fmt_str, env_buf,
        g_flags.no_expand_env, g_flags.no_subst_vars, false,
        g_flags, g_options,
        cmdline_str, special_cmdline_arg_offset_arr,
        in_args, out_args);

    UINT prev_cp = 0;

    DWORD num_bytes_written = 0;
    std::vector<uint8_t> byte_buf;

    // NOTE:
    //  lambda to bypass msvc error: `error C2712: Cannot use __try in functions that require object unwinding`
    //
    [&]() { __try {
        if (g_options.chcp) {
            prev_cp = GetConsoleOutputCP();
            if (g_options.chcp != prev_cp) {
                SetConsoleOutputCP(g_options.chcp);
            }
        }

        if (g_flags.eval_backslash_esc || g_flags.eval_dbl_backslash_esc) {
            [&]() {
                const auto & fmt_str = _eval_escape_chars(out_args.fmt_str, g_flags.eval_backslash_esc, g_flags.eval_dbl_backslash_esc);
#ifdef _UNICODE
                // use current code page
                const UINT cp_out = GetConsoleOutputCP();

                int num_chars = WideCharToMultiByte(cp_out, 0, fmt_str.c_str(), fmt_str.length(), NULL, 0, NULL, NULL);
                if (num_chars) {
                    byte_buf.resize(size_t(num_chars));
                    num_chars = WideCharToMultiByte(cp_out, 0, fmt_str.c_str(), fmt_str.length(), (char *)&byte_buf[0], byte_buf.size(), NULL, NULL);
                }

                WriteFile(GetStdHandle(STD_OUTPUT_HANDLE), (char *)&byte_buf[0], (std::min)((size_t)num_chars, byte_buf.size()), &num_bytes_written, NULL);
#else
                WriteFile(GetStdHandle(STD_OUTPUT_HANDLE), fmt_str.c_str(), fmt_str.length() * sizeof(fmt_str[0]), &num_bytes_written, NULL);
#endif
            }();
        }
        else {
            // explicitly append line return characters
            out_args.fmt_str.resize(out_args.fmt_str.size() + 2);
            out_args.fmt_str[out_args.fmt_str.size() - 2] = _T('\r');
            out_args.fmt_str[out_args.fmt_str.size() - 1] = _T('\n');

#ifdef _UNICODE
            // use current code page
            const UINT cp_out = GetConsoleOutputCP();

            int num_chars = WideCharToMultiByte(cp_out, 0, out_args.fmt_str.c_str(), out_args.fmt_str.length(), NULL, 0, NULL, NULL);
            if (num_chars) {
                byte_buf.resize(size_t(num_chars));
                num_chars = WideCharToMultiByte(cp_out, 0, out_args.fmt_str.c_str(), out_args.fmt_str.length(), (char *)&byte_buf[0], byte_buf.size(), NULL, NULL);
            }

            WriteFile(GetStdHandle(STD_OUTPUT_HANDLE), (char *)&byte_buf[0], (std::min)((size_t)num_chars, byte_buf.size()), &num_bytes_written, NULL);
#else
            WriteFile(GetStdHandle(STD_OUTPUT_HANDLE), out_args.fmt_str.c_str(), out_args.fmt_str.length() * sizeof(out_args.fmt_str[0]), &num_bytes_written, NULL);
#endif
        }
    }
    __finally {
        // close shared resources at first
        if (g_options.chcp && g_options.chcp != prev_cp) {
            SetConsoleCP(prev_cp);
        }
    } }();

    return err_none;
}
