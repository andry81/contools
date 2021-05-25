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

int _tmain(int argc, const TCHAR * argv[])
{
#if _DEBUG
    MessageBoxA(NULL, "", "", MB_OK);
#endif

    if (!argc || !argv[0]) {
        return err_unspecified;
    }

    size_t arg_len = 0;
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
            return err_invalid_format;
        }

        if (tstrncmp(arg, _T("/"), 1)) {
            break;
        }

        return err_invalid_format;

        //arg_offset += 1;
    }

    std::vector<TCHAR> tchar_buf;

    tchar_buf.resize(34); // max potential unsigned long size

    DWORD num_bytes_written = 0;
    std::vector<uint8_t> byte_buf;

    if (argc >= arg_offset + 1 && (arg = argv[arg_offset]) && (arg_len = tstrlen(arg))) {
        TCHAR * endptr;
        const auto cp = _tcstoul(arg, &endptr, 10);
        SetConsoleOutputCP(cp);
        return 0;
    }

    ultot(GetConsoleOutputCP(), &tchar_buf[0], 10);

    tchar_buf.resize(_tcslen(&tchar_buf[0]));

    // NOTE:
    //  labda to bypass msvc error: `error C2712: Cannot use __try in functions that require object unwinding`
    //
    [&]() { __try {
        [&]() {
            // explicitly append line return characters
            tchar_buf.resize(tchar_buf.size() + 2);
            tchar_buf[tchar_buf.size() - 2] = _T('\r');
            tchar_buf[tchar_buf.size() - 1] = _T('\n');

#ifdef _UNICODE
            // use current code page
            const UINT cp = GetConsoleOutputCP();

            int num_chars = WideCharToMultiByte(cp, 0, &tchar_buf[0], tchar_buf.size(), NULL, 0, NULL, NULL);
            if (num_chars) {
                byte_buf.resize(size_t(num_chars));
                num_chars = WideCharToMultiByte(cp, 0, &tchar_buf[0], tchar_buf.size(), (char *)&byte_buf[0], (std::min)((size_t)num_chars, byte_buf.size()), NULL, NULL);

                WriteFile(GetStdHandle(STD_OUTPUT_HANDLE), &byte_buf[0], (std::min)((size_t)num_chars, byte_buf.size()), &num_bytes_written, NULL);
            }
            else {
                return -127;
            }
#else
            WriteFile(GetStdHandle(STD_OUTPUT_HANDLE), tchar_buf[0], tchar_buf.size() * sizeof(tchar_buf[0]), &num_bytes_written, NULL);
#endif
        }();
    }
    __finally {
        ;
    } }();

    return 0;
}
