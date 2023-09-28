#define _CRT_SECURE_NO_WARNINGS
//#define WIN32_LEAN_AND_MEAN // Exclude rarely-used stuff from Windows headers

#include <windows.h>
#include <tchar.h>
#include <stdio.h>
#include <string.h>

#include "common.hpp"

//#ifdef _UNICODE
//#error Unicode is not supported.
//#endif


namespace
{
    enum _error
    {
        err_help_output     = -1,
        err_none            = 0,
        err_invalid_format  = 1,
        err_invalid_params  = 2,
        err_io_error        = 16,
        err_unspecified     = 255
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

        bool allow_expand_unexisted_env;
    };

    struct _Options
    {
    };

    struct InArgs
    {
        const TCHAR * print_prefix_str;
        const TCHAR * equal_str;
        const TCHAR * not_equal_str;
        const TCHAR * less_str;
        const TCHAR * greater_or_equal_str;
    };

    template <typename Flags, typename Options>
    void _parse_string(const TCHAR * parse_str, std::tstring & parsed_str, const TCHAR * v0_value, const TCHAR * v1_value,
                       const Flags & flags, const Options & options,
                       TCHAR * in_str_value, const InArgs & in_args = InArgs()) {
        bool done = false;
        bool found;
        const TCHAR * last_offset = parse_str;

        std::tstring equal_str;
        std::tstring not_equal_str;
        std::tstring less_str;
        std::tstring greater_or_equal_str;

        bool is_equal_str_parsed = false;
        bool is_not_equal_str_parsed = false;
        bool is_less_str_parsed = false;
        bool is_greater_or_equal_str_parsed = false;

        do {
            found = false;

            const TCHAR * p = tstrstr(last_offset, _T("{"));
            if_break (p) {
                if(p > last_offset) {
                    const TCHAR * last_offset_var = _extract_variable(last_offset, p - 1, parsed_str, in_str_value, flags.allow_expand_unexisted_env);
                    if (last_offset_var) {
                        found = true;
                        last_offset = last_offset_var;
                        break;
                    }
                }

                if(p > last_offset && *(p - 1) == _T('\\')) {
                    if (p > last_offset + 1) {
                        parsed_str.append(last_offset, p - 1);
                    }
                    parsed_str.append(p, p + 1);
                    last_offset = p + 1;
                    if (*last_offset) found = true;
                    break;
                }

                // {0}
                const int var_v0 = tstrncmp(p, _T("{0}"), 3);
                if (!var_v0) {
                    parsed_str.append(last_offset, p);
                    last_offset = p + 3;
                    parsed_str.append(v0_value);
                    found = true;
                }

                // {1}
                if (!found) {
                    const int var_v1 = tstrncmp(p, _T("{1}"), 3);
                    if (!var_v1) {
                        parsed_str.append(last_offset, p);
                        last_offset = p + 3;
                        parsed_str.append(v1_value);
                        found = true;
                    }
                }

                // {0hs}
                if (!found) {
                    const int var_v0 = tstrncmp(p, _T("{0hs}"), 5);
                    if (!var_v0) {
                        parsed_str.append(last_offset, p);
                        last_offset = p + 5;
                        const size_t v0_value_len = tstrlen(v0_value);
                        for(size_t i = 0; i < v0_value_len; i++) {
                            parsed_str.append(g_hextbl[v0_value[i]]);
                        }
                        found = true;
                    }
                }

                // {1hs}
                if (!found) {
                    const int var_v1 = tstrncmp(p, _T("{1hs}"), 5);
                    if (!var_v1) {
                        parsed_str.append(last_offset, p);
                        last_offset = p + 5;
                        const size_t v1_value_len = tstrlen(v1_value);
                        for(size_t i = 0; i < v1_value_len; i++) {
                            parsed_str.append(g_hextbl[v1_value[i]]);
                        }
                        found = true;
                    }
                }

                // {EQL}
                if (!found && in_args.equal_str) {
                    const int var_eql = tstrncmp(p, _T("{EQL}"), 5);
                    if (!var_eql) {
                        if (!is_equal_str_parsed) {
                            _parse_string(in_args.equal_str, equal_str, v0_value, v1_value, flags, options, in_str_value);
                            is_equal_str_parsed = true;
                        }
                        parsed_str.append(last_offset, p);
                        last_offset = p + 5;
                        parsed_str.append(equal_str);
                        found = true;
                    }
                }

                // {NEQ}
                if (!found && in_args.not_equal_str) {
                    const int var_neq = tstrncmp(p, _T("{NEQ}"), 5);
                    if (!var_neq) {
                        if (!is_not_equal_str_parsed) {
                            _parse_string(in_args.not_equal_str, not_equal_str, v0_value, v1_value, flags, options, in_str_value);
                            is_not_equal_str_parsed = true;
                        }
                        parsed_str.append(last_offset, p);
                        last_offset = p + 5;
                        parsed_str.append(not_equal_str);
                        found = true;
                    }
                }

                // {LSS}
                if (!found && in_args.less_str) {
                    const int var_less = tstrncmp(p, _T("{LSS}"), 5);
                    if (!var_less) {
                        if (!is_less_str_parsed) {
                            _parse_string(in_args.less_str, less_str, v0_value, v1_value, flags, options, in_str_value);
                            is_less_str_parsed = true;
                        }
                        parsed_str.append(last_offset, p);
                        last_offset = p + 5;
                        parsed_str.append(less_str);
                        found = true;
                    }
                }

                // {GEQ}
                if (!found && in_args.greater_or_equal_str) {
                    const int var_gtr = tstrncmp(p, _T("{GEQ}"), 5);
                    if (!var_gtr) {
                        if (!is_greater_or_equal_str_parsed) {
                            _parse_string(in_args.greater_or_equal_str, greater_or_equal_str, v0_value, v1_value, flags, options, in_str_value);
                            is_greater_or_equal_str_parsed = true;
                        }
                        parsed_str.append(last_offset, p);
                        last_offset = p + 5;
                        parsed_str.append(greater_or_equal_str);
                        found = true;
                    }
                }

                if (!found) {
                    if(*(p + 1)) {
                        const TCHAR * p_end = tstrstr(p + 1, _T("}"));
                        if (p_end) {
                            parsed_str.append(last_offset, p);
                            last_offset = p_end + 1;
                            if (*last_offset) found = true;
                            break;
                        }
                    }
                }
            }

            if (!found) done = true;

            if (done && last_offset) {
                parsed_str.append(last_offset);
                last_offset = 0; // just in case
            }
        } while(!done);
    }
}

int _tmain(int argc, const TCHAR * argv[])
{
    // CAUTION:
    //  In Windows if you call `CreateProcess` like this: `CreateProcess("a.exe", "/b", ...)`, then the `argv[0]` would be `/b`, not `a.exe`!
    //

    if(!argc || !argv[0])
        return 255;

    if (!argc || !argv[0]) {
        return err_unspecified;
    }

    const TCHAR * arg;
    int arg_offset = argv[0][0] != _T('/') ? 1 : 0; // arguments shift detection

    if (argc >= arg_offset + 1 && argv[arg_offset] && !tstrcmp(argv[arg_offset], _T("/?"))) {
        if (argc >= arg_offset + 2) return err_invalid_format;

#define INCLUDE_HELP_INL_EPILOG(N) ::puts(
#define INCLUDE_HELP_INL_PROLOG(N) );    
#include "gen/help_inl.hpp"

        return err_help_output;
    }

    // environment variable buffers
    TCHAR value1[MAX_ENV_BUF_SIZE];
    TCHAR value2[MAX_ENV_BUF_SIZE];
    TCHAR env_buf[MAX_ENV_BUF_SIZE];

    if (argc >= arg_offset + 1 && (arg = argv[arg_offset]) && tstrlen(arg)) {
        const DWORD value1Size = ::GetEnvironmentVariable(arg, value1, sizeof(value1) / sizeof(value1[0]));
        if (!value1Size) {
            value1[0] = _T('\0');
        }
        if (value1Size > sizeof(value1) / sizeof(value1[0])) {
            return 2;
        }
    } else {
        return 2;
    }

    arg_offset += 1;

    if (argc >= arg_offset + 1 && (arg = argv[arg_offset]) && tstrlen(arg)) {
        const DWORD value2Size = ::GetEnvironmentVariable(arg, value2, sizeof(value2) / sizeof(value2[0]));
        if (!value2Size) {
            value2[0] = _T('\0');
        }
        if (value2Size > sizeof(value2) / sizeof(value2[0])) {
            return 3;
        }
    } else {
        return 3;
    }

    arg_offset += 1;

    // prepare print string
    std::tstring print_prefix_str;
    std::tstring equal_str;
    std::tstring not_equal_str;
    std::tstring less_str;
    std::tstring greater_or_equal_str;

    InArgs in_args = InArgs();

    if (argc >= arg_offset + 1 && (arg = argv[arg_offset]) && tstrlen(arg)) {
        in_args.print_prefix_str = arg;
        if (!tstrcmp(in_args.print_prefix_str, _T(""))) {
            in_args.print_prefix_str = nullptr;
        }
    }

    arg_offset += 1;

    // {EQL} string
    if (argc >= arg_offset + 1 && (arg = argv[arg_offset]) && tstrlen(arg)) {
        in_args.equal_str = arg;
        if (!tstrcmp(in_args.equal_str, _T(""))) {
            in_args.equal_str = nullptr;
        }
    }

    arg_offset += 1;

    // {NEQ} string
    if (argc >= arg_offset + 1 && (arg = argv[arg_offset]) && tstrlen(arg)) {
        in_args.not_equal_str = arg;
        if (!tstrcmp(in_args.not_equal_str, _T(""))) {
            in_args.not_equal_str = nullptr;
        }
    }

    arg_offset += 1;

    // {LSS} string
    if (argc >= arg_offset + 1 && (arg = argv[arg_offset]) && tstrlen(arg)) {
        in_args.less_str = arg;
        if (!tstrcmp(in_args.less_str, _T(""))) {
            in_args.less_str = nullptr;
        }
    }

    arg_offset += 1;

    // {GEQ}/{GTR} string
    if (argc >= arg_offset + 1 && (arg = argv[arg_offset]) && tstrlen(arg)) {
        in_args.greater_or_equal_str = arg;
        if (!tstrcmp(in_args.greater_or_equal_str, _T(""))) {
            in_args.greater_or_equal_str = nullptr;
        }
    }

    arg_offset += 1;

    const int res = tstrcmp(value1, value2);

    if (in_args.print_prefix_str) {
        _parse_string(in_args.print_prefix_str, print_prefix_str, value1, value2, _Flags{}, _Options{}, env_buf, in_args);
        if (!print_prefix_str.empty()) tputs(print_prefix_str.c_str());
    }

    if (!res && in_args.equal_str) {
        _parse_string(in_args.equal_str, equal_str, value1, value2, _Flags{}, _Options{}, env_buf);
        if (!equal_str.empty()) tputs(equal_str.c_str());
        return 0;
    }

    if (res && in_args.not_equal_str) {
        _parse_string(in_args.not_equal_str, not_equal_str, value1, value2, _Flags{}, _Options{}, env_buf);
        if (!not_equal_str.empty()) tputs(not_equal_str.c_str());
        return res < 0 ? -1 : 1;
    }

    if (res < 0 && in_args.less_str) {
        _parse_string(in_args.less_str, less_str, value1, value2, _Flags{}, _Options{}, env_buf);
        if (!less_str.empty()) tputs(less_str.c_str());
        return -1;
    }

    if (in_args.greater_or_equal_str) {
        _parse_string(in_args.greater_or_equal_str, greater_or_equal_str, value1, value2, _Flags{}, _Options{}, env_buf);
        if (!greater_or_equal_str.empty()) tputs(greater_or_equal_str.c_str());
    }

    return !res ? 0 : res < 0 ? -1 : 1;
}
