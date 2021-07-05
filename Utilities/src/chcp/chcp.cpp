#define _CRT_SECURE_NO_WARNINGS
//#define WIN32_LEAN_AND_MEAN // Exclude rarely-used stuff from Windows headers

#include <windows.h>
#include <stdio.h>
#include <string.h>

#include <algorithm>

#include "common.hpp"

//#ifdef _UNICODE
//#error Unicode is not supported.
//#endif

namespace {
    struct _Flags
    {
        bool            no_print_gen_error_string;
    };

    struct _Options
    {
        unsigned int    chcp_in;
        unsigned int    chcp_out;
    };

    _Flags g_flags                      = {};
    _Options g_options                  = {
        0, 0
    };
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

    size_t arg_len = 0;
    const TCHAR * arg;
    int arg_offset = argv[0][0] != _T('/') ? 1 : 0; // arguments shift detection

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

        if (!tstrcmp(arg, _T("/in"))) {
            arg_offset += 1;
            if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                g_options.chcp_in = _ttoi(arg);
            }
            else {
                if (!g_flags.no_print_gen_error_string) {
                    _ftprintf(stderr, _T("error: flag format is invalid: \"%s\""), arg);
                }
                return err_invalid_format;
            }
        }
        else if (!tstrcmp(arg, _T("/out"))) {
            arg_offset += 1;
            if (argc >= arg_offset + 1 && (arg = argv[arg_offset])) {
                g_options.chcp_out = _ttoi(arg);
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
        else {
            if (!g_flags.no_print_gen_error_string) {
                _ftprintf(stderr, _T("error: flag is not known: \"%s\""), arg);
            }
            return err_invalid_format;
        }

        arg_offset += 1;
    }

    // read positional params

    unsigned int chcp_inout = 0;
    if (argc >= arg_offset + 1 && (arg = argv[arg_offset]) && tstrlen(arg)) {
        chcp_inout = _ttoi(arg);
    }

    arg_offset += 1;

    if (chcp_inout && (g_options.chcp_in || g_options.chcp_out)) {
        if (!g_flags.no_print_gen_error_string) {
            fputs("error: invalid parameters", stderr);
        }
        return err_invalid_params;
    }

    unsigned int chcp_in = 0;
    unsigned int chcp_out = 0;

    if (chcp_inout) {
        chcp_in = chcp_out = chcp_inout;
    }
    else {
        chcp_in = g_options.chcp_in;
        chcp_out = g_options.chcp_out;
    }

    if (chcp_in || chcp_out) {
        if (chcp_out) {
            SetConsoleOutputCP(chcp_out);
        }
        if (chcp_in) {
            SetConsoleCP(chcp_in);
        }
        return err_none;
    }

    std::vector<TCHAR> tchar_buf;

    tchar_buf.resize(34 + 1 + 34 + 1); // max potential size: <OutputCodePage> + ':' + <InputCodePage> + '\0'

    DWORD num_bytes_written = 0;
    std::vector<uint8_t> byte_buf;

    ultot(GetConsoleOutputCP(), tchar_buf.data(), 10);
    const size_t l0 = _tcslen(tchar_buf.data());
    tchar_buf[l0] = _T(':');
    ultot(GetConsoleCP(), &tchar_buf[l0 + 1], 10);

    tchar_buf.resize(_tcslen(tchar_buf.data()));

    // NOTE:
    //  lambda to bypass msvc error: `error C2712: Cannot use __try in functions that require object unwinding`
    //
    [&]() { __try {
        [&]() {
            // explicitly append line return characters
            tchar_buf.resize(tchar_buf.size() + 2);
            tchar_buf[tchar_buf.size() - 2] = _T('\r');
            tchar_buf[tchar_buf.size() - 1] = _T('\n');

#ifdef _UNICODE
            // use current code page
            const UINT cp_out = GetConsoleOutputCP();

            int num_chars = WideCharToMultiByte(cp_out, 0, tchar_buf.data(), tchar_buf.size(), NULL, 0, NULL, NULL);
            if (num_chars) {
                byte_buf.resize(size_t(num_chars));
                num_chars = WideCharToMultiByte(cp_out, 0, tchar_buf.data(), tchar_buf.size(), (char *)byte_buf.data(), (std::min)((size_t)num_chars, byte_buf.size()), NULL, NULL);

                WriteFile(GetStdHandle(STD_OUTPUT_HANDLE), byte_buf.data(), (std::min)((size_t)num_chars, byte_buf.size()), &num_bytes_written, NULL);
            }
            else {
                return -127;
            }
#else
            WriteFile(GetStdHandle(STD_OUTPUT_HANDLE), tchar_buf.data(), tchar_buf.size() * sizeof(tchar_buf[0]), &num_bytes_written, NULL);
#endif
        }();
    }
    __finally {
        ;
    } }();

    return err_none;
}
