#define _CRT_SECURE_NO_WARNINGS
//#define WIN32_LEAN_AND_MEAN // Exclude rarely-used stuff from Windows headers

#include <windows.h>
#include <stdio.h>
#include <string.h>

#include <algorithm>

#include "common.hpp"
#include "printf.hpp"

//#ifdef _UNICODE
//#error Unicode is not supported.
//#endif

namespace {
    struct _Flags
    {
        bool            no_print_gen_error_string;
        bool            no_expand_env;                  // don't expand `${...}` environment variables
        bool            no_subst_vars;                  // don't substitute `{...}` variables (command line parameters)
        bool            eval_backslash_esc;             // evaluate backslash escape characters
    };

    struct _Options
    {
        unsigned int    chcp;
    };

    _Flags g_flags                      = {};
    _Options g_options                  = {
        0
    };
}

int _tmain(int argc, const TCHAR * argv[])
{
    if (!argc || !argv[0]) {
        return err_unspecified;
    }

    const TCHAR * arg;
    int arg_offset = 1;

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
        else if (!tstrcmp(arg, _T("/eval-backslash-esc")) || !tstrcmp(arg, _T("/e"))) {
            g_flags.eval_backslash_esc = true;
        }
        else if (!tstrcmp(arg, _T("//"))) {
            arg_offset += 1;
            break;
        }
        else {
            if (!g_flags.no_print_gen_error_string) {
                _ftprintf(stderr, _T("error: flag is not known: \"%s\""), arg);
            }
            return err_invalid_format;
        }

        arg_offset += 1;
    }

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
        for (int i = 0; i < num_args; i++) {
            if (tstrcmp(in_args.args[i], _T(""))) {
                _parse_string(i, in_args.args[i], out_args.args[i], env_buf,
                    g_flags.no_expand_env, g_flags.no_subst_vars, true, in_args, out_args);
            }
            else {
                in_args.args[i] = nullptr;
            }
        }
    }

    _parse_string(-1, in_args.fmt_str, out_args.fmt_str, env_buf,
        g_flags.no_expand_env, g_flags.no_subst_vars, false, in_args, out_args);

    if (g_flags.eval_backslash_esc) {
        _tprintf(_T("%s"), _eval_backslash_escape_chars(out_args.fmt_str).c_str());
    }
    else {
        tputs(out_args.fmt_str.c_str());
    }

    return err_none;
}
