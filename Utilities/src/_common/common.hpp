#ifndef __COMMON_HPP__
#define __COMMON_HPP__

#include <version.hpp>

#include <string>
#include <vector>

#include <assert.h>
#include <ShellAPI.h>

#include "std/tctype.hpp"
#include "std/tstdlib.hpp"
#include "std/tstring.hpp"
#include "std/tstdio.hpp"


#define if_break switch(0) case 0: default: if
#define MAX_ENV_BUF_SIZE 32767


namespace {
    enum _error
    {
        err_none            = 0,

        err_unspecified     = -256,

        err_help_output     = -128,

        err_win32_error     = -4,
        err_invalid_params  = -3,
        err_invalid_format  = -2,
        err_format_empty    = -1
    };

    const TCHAR * hextbl[] = {
        _T("00"), _T("01"), _T("02"), _T("03"), _T("04"), _T("05"), _T("06"), _T("07"), _T("08"), _T("09"), _T("0A"), _T("0B"), _T("0C"), _T("0D"), _T("0E"), _T("0F"),
        _T("10"), _T("11"), _T("12"), _T("13"), _T("14"), _T("15"), _T("16"), _T("17"), _T("18"), _T("19"), _T("1A"), _T("1B"), _T("1C"), _T("1D"), _T("1E"), _T("1F"),
        _T("20"), _T("21"), _T("22"), _T("23"), _T("24"), _T("25"), _T("26"), _T("27"), _T("28"), _T("29"), _T("2A"), _T("2B"), _T("2C"), _T("2D"), _T("2E"), _T("2F"),
        _T("30"), _T("31"), _T("32"), _T("33"), _T("34"), _T("35"), _T("36"), _T("37"), _T("38"), _T("39"), _T("3A"), _T("3B"), _T("3C"), _T("3D"), _T("3E"), _T("3F"),
        _T("40"), _T("41"), _T("42"), _T("43"), _T("44"), _T("45"), _T("46"), _T("47"), _T("48"), _T("49"), _T("4A"), _T("4B"), _T("4C"), _T("4D"), _T("4E"), _T("4F"),
        _T("50"), _T("51"), _T("52"), _T("53"), _T("54"), _T("55"), _T("56"), _T("57"), _T("58"), _T("59"), _T("5A"), _T("5B"), _T("5C"), _T("5D"), _T("5E"), _T("5F"),
        _T("60"), _T("61"), _T("62"), _T("63"), _T("64"), _T("65"), _T("66"), _T("67"), _T("68"), _T("69"), _T("6A"), _T("6B"), _T("6C"), _T("6D"), _T("6E"), _T("6F"),
        _T("70"), _T("71"), _T("72"), _T("73"), _T("74"), _T("75"), _T("76"), _T("77"), _T("78"), _T("79"), _T("7A"), _T("7B"), _T("7C"), _T("7D"), _T("7E"), _T("7F"),
        _T("80"), _T("81"), _T("82"), _T("83"), _T("84"), _T("85"), _T("86"), _T("87"), _T("88"), _T("89"), _T("8A"), _T("8B"), _T("8C"), _T("8D"), _T("8E"), _T("8F"),
        _T("90"), _T("91"), _T("92"), _T("93"), _T("94"), _T("95"), _T("96"), _T("97"), _T("98"), _T("99"), _T("9A"), _T("9B"), _T("9C"), _T("9D"), _T("9E"), _T("9F"),
        _T("A0"), _T("A1"), _T("A2"), _T("A3"), _T("A4"), _T("A5"), _T("A6"), _T("A7"), _T("A8"), _T("A9"), _T("AA"), _T("AB"), _T("AC"), _T("AD"), _T("AE"), _T("AF"),
        _T("B0"), _T("B1"), _T("B2"), _T("B3"), _T("B4"), _T("B5"), _T("B6"), _T("B7"), _T("B8"), _T("B9"), _T("BA"), _T("BB"), _T("BC"), _T("BD"), _T("BE"), _T("BF"),
        _T("C0"), _T("C1"), _T("C2"), _T("C3"), _T("C4"), _T("C5"), _T("C6"), _T("C7"), _T("C8"), _T("C9"), _T("CA"), _T("CB"), _T("CC"), _T("CD"), _T("CE"), _T("CF"),
        _T("D0"), _T("D1"), _T("D2"), _T("D3"), _T("D4"), _T("D5"), _T("D6"), _T("D7"), _T("D8"), _T("D9"), _T("DA"), _T("DB"), _T("DC"), _T("DD"), _T("DE"), _T("DF"),
        _T("E0"), _T("E1"), _T("E2"), _T("E3"), _T("E4"), _T("E5"), _T("E6"), _T("E7"), _T("E8"), _T("E9"), _T("EA"), _T("EB"), _T("EC"), _T("ED"), _T("EE"), _T("EF"),
        _T("F0"), _T("F1"), _T("F2"), _T("F3"), _T("F4"), _T("F5"), _T("F6"), _T("F7"), _T("F8"), _T("F9"), _T("FA"), _T("FB"), _T("FC"), _T("FD"), _T("FE"), _T("FF"),
    };

    using const_tchar_ptr_vector_t = std::vector<const TCHAR *>;
    using tstring_vector_t = std::vector<std::tstring>;

    inline bool _is_valid_handle(HANDLE handle)
    {
        return handle && handle != INVALID_HANDLE_VALUE;
    }

    inline void _close_handle(HANDLE & handle)
    {
        if (_is_valid_handle(handle)) {
            CloseHandle(handle);
        }
        handle = INVALID_HANDLE_VALUE;
    }

    inline void _close_handle(HANDLE & handle0, HANDLE & handle1)
    {
        _close_handle(handle0);
        handle1 = INVALID_HANDLE_VALUE;
    }

    inline bool _is_winnt()
    {
        OSVERSIONINFO osv;
        osv.dwOSVersionInfoSize = sizeof(osv);
        GetVersionEx(&osv);
        return (osv.dwPlatformId == VER_PLATFORM_WIN32_NT);
    }

    inline void _set_crt_std_handle(HANDLE file_handle, int id)
    {
        int fd;
        int flags = 0;

#ifdef _UNICODE
        flags |= _O_WTEXT;
#else
        flags |= _O_TEXT;
#endif

        switch (id)
        {
        case 0:
            fd = _open_osfhandle((intptr_t)file_handle, flags | _O_RDONLY);
            _dup2(fd, _fileno(stdin));
            _close(fd);
            break;
        case 1:
            fd = _open_osfhandle((intptr_t)file_handle, flags | _O_WRONLY);
            _dup2(fd, _fileno(stdout));
            _close(fd);
            break;
        case 2:
            fd = _open_osfhandle((intptr_t)file_handle, flags | _O_WRONLY);
            _dup2(fd, _fileno(stderr));
            _close(fd);
            break;
        }
    }

    inline void _duplicate_std_console_handles(HANDLE & stdin_dup_handle, HANDLE & stdout_dup_handle, HANDLE & stderr_dup_handle)
    {
        stdin_dup_handle = stdout_dup_handle = stderr_dup_handle = INVALID_HANDLE_VALUE;

        HANDLE stdin_handle = GetStdHandle(STD_INPUT_HANDLE);
        HANDLE stdout_handle = GetStdHandle(STD_OUTPUT_HANDLE);
        HANDLE stderr_handle = GetStdHandle(STD_ERROR_HANDLE);

        const DWORD stdin_handle_type = GetFileType(stdin_handle);
        const DWORD stdout_handle_type = GetFileType(stdout_handle);
        const DWORD stderr_handle_type = GetFileType(stderr_handle);

        if (stdin_handle_type == FILE_TYPE_CHAR) {
            DuplicateHandle(GetCurrentProcess(), stdin_handle, GetCurrentProcess(), &stdin_dup_handle, 0, TRUE, DUPLICATE_SAME_ACCESS);
        }
        if (stdout_handle_type == FILE_TYPE_CHAR) {
            DuplicateHandle(GetCurrentProcess(), stdout_handle, GetCurrentProcess(), &stdout_dup_handle, 0, TRUE, DUPLICATE_SAME_ACCESS);
        }
        if (stderr_handle_type == FILE_TYPE_CHAR) {
            DuplicateHandle(GetCurrentProcess(), stderr_handle, GetCurrentProcess(), &stderr_dup_handle, 0, TRUE, DUPLICATE_SAME_ACCESS);
        }
    }

    inline void _reattach_std_console_handles()
    {
        // reattach detached or not redirected stdin/stdout/stderr to new console

        // check redirection
        HANDLE stdin_handle = GetStdHandle(STD_INPUT_HANDLE);
        HANDLE stdout_handle = GetStdHandle(STD_OUTPUT_HANDLE);
        HANDLE stderr_handle = GetStdHandle(STD_ERROR_HANDLE);

        const DWORD stdin_handle_type = GetFileType(stdin_handle);
        const DWORD stdout_handle_type = GetFileType(stdout_handle);
        const DWORD stderr_handle_type = GetFileType(stderr_handle);

        SECURITY_ATTRIBUTES sa{};

        sa.nLength = sizeof(sa);
        sa.bInheritHandle = TRUE;

        switch (stdin_handle_type) {
        case FILE_TYPE_UNKNOWN:
        case FILE_TYPE_CHAR:
            HANDLE conin_handle = CreateFile(_T("CONIN$"),
                GENERIC_READ, FILE_SHARE_READ, &sa, // `sa` just in case
                OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
            if (_is_valid_handle(conin_handle)) {
                _set_crt_std_handle(conin_handle, 0);
            }
        }

        switch (stdout_handle_type) {
        case FILE_TYPE_UNKNOWN:
        case FILE_TYPE_CHAR: {
            HANDLE conerr_handle = INVALID_HANDLE_VALUE;
            HANDLE conout_handle = CreateFile(_T("CONOUT$"),
                GENERIC_WRITE, FILE_SHARE_READ | FILE_SHARE_WRITE, &sa,
                OPEN_ALWAYS,
                FILE_ATTRIBUTE_NORMAL, NULL);
            if (_is_valid_handle(conout_handle)) {
                if (stderr_handle_type == FILE_TYPE_CHAR) {
                    // CAUTION:
                    //  We must duplicate handle before call to `_set_crt_std_handle`, because it closes the handle.
                    //
                    if (DuplicateHandle(GetCurrentProcess(), conout_handle, GetCurrentProcess(), &conerr_handle, 0, TRUE, DUPLICATE_SAME_ACCESS)) {
                        _set_crt_std_handle(conerr_handle, 2);
                    }
                }

                _set_crt_std_handle(conout_handle, 1);
            }
        } break;

        default: {
            switch (stderr_handle_type) {
            case FILE_TYPE_UNKNOWN:
            case FILE_TYPE_CHAR:
                HANDLE conerr_handle = CreateFile(_T("CONOUT$"),
                    GENERIC_WRITE, FILE_SHARE_READ | FILE_SHARE_WRITE, &sa,
                    OPEN_ALWAYS,
                    FILE_ATTRIBUTE_NORMAL, NULL);
                if (_is_valid_handle(conerr_handle)) {
                    _set_crt_std_handle(conerr_handle, 2);
                }
            }
        }
        }
    }

    inline DWORD _find_parent_process_id()
    {
        
        HANDLE proc_list_handle = INVALID_HANDLE_VALUE;
        const DWORD current_proc_id = GetCurrentProcessId();

        __try {
            proc_list_handle = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
            PROCESSENTRY32 pe = { 0 };
            pe.dwSize = sizeof(PROCESSENTRY32);

            if (Process32First(proc_list_handle, &pe)) {
                do {
                    if (pe.th32ProcessID == current_proc_id) {
                        return pe.th32ParentProcessID;
                    }
                } while (Process32Next(proc_list_handle, &pe));
            }
        }
        __finally {
            _close_handle(proc_list_handle);
        }

        return (DWORD)-1;
    }

    struct EnumConsoleWindowsProcData
    {
        TCHAR tchar_buf[256];
        std::vector<HWND> console_window_handles_arr;
    };

    BOOL CALLBACK EnumConsoleWindowsProc(HWND hwnd, LPARAM lParam)
    {
        EnumConsoleWindowsProcData & enum_proc_data = *(EnumConsoleWindowsProcData *)lParam;

        enum_proc_data.tchar_buf[0] = _T('\0');

        GetClassName(hwnd, enum_proc_data.tchar_buf, sizeof(enum_proc_data.tchar_buf));

        if (!tstrcmp(enum_proc_data.tchar_buf, _T("ConsoleWindowClass"))) {
            enum_proc_data.console_window_handles_arr.push_back(hwnd);
        }

        return TRUE;
    }

    inline HWND _find_parent_process_console_window(DWORD & parent_proc_id)
    {
        EnumConsoleWindowsProcData enum_proc_data;

        enum_proc_data.console_window_handles_arr.reserve(256);

        parent_proc_id = (DWORD)-1;

        if (!EnumWindows(&EnumConsoleWindowsProc, (LPARAM)&enum_proc_data)) {
            return NULL;
        }

        if (!enum_proc_data.console_window_handles_arr.size()) {
            return NULL;
        }

        HWND ret = NULL;

        DWORD console_window_proc_id;
        HANDLE proc_list_handle = INVALID_HANDLE_VALUE;
        const DWORD current_proc_id = GetCurrentProcessId();

        [&]() { __try {
            [&]() {
                proc_list_handle = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
                PROCESSENTRY32 pe = { 0 };
                pe.dwSize = sizeof(PROCESSENTRY32);

                if (Process32First(proc_list_handle, &pe)) {
                    do {
                        for (auto console_window_handle : enum_proc_data.console_window_handles_arr) {
                            console_window_proc_id = (DWORD)-1;
                            GetWindowThreadProcessId(console_window_handle, &console_window_proc_id);
                            if (console_window_proc_id == pe.th32ParentProcessID) {
                                parent_proc_id = pe.th32ParentProcessID;
                                ret = console_window_handle;
                                return;
                            }
                        }
                    } while (Process32Next(proc_list_handle, &pe));
                }
            }();
        }
        __finally {
            _close_handle(proc_list_handle);
        } }();

        return ret;
    }

    inline bool _is_process_elevated()
    {
        bool ret = FALSE;
        HANDLE token_handle = NULL;

        __try {
            if (OpenProcessToken(GetCurrentProcess(), TOKEN_QUERY, &token_handle)) {
                TOKEN_ELEVATION elevation;
                DWORD cbSize = sizeof(TOKEN_ELEVATION);
                if (GetTokenInformation(token_handle, TokenElevation, &elevation, sizeof(elevation), &cbSize)) {
                    ret = !!elevation.TokenIsElevated;
                }
            }
        }
        __finally {
            if (token_handle && token_handle != INVALID_HANDLE_VALUE) {
                CloseHandle(token_handle);
            }
        }

        return ret;
    }

    inline const TCHAR * _extract_variable(const TCHAR * last_offset_ptr, const TCHAR * parse_str, std::tstring & parsed_str, TCHAR * env_buf)
    {
        const TCHAR * return_offset_ptr = 0;

        const TCHAR * in_str_var_ptr = 0;
        if (!tstrncmp(parse_str, _T("${"), 2)) in_str_var_ptr = parse_str; // must point to `${`

        if_break(in_str_var_ptr) {
            const TCHAR * in_str_var_end_ptr = tstrstr(in_str_var_ptr + 2, _T("}")); // must not be `${}`
            if (!in_str_var_end_ptr) break;

            parsed_str.append(last_offset_ptr, in_str_var_ptr);
            return_offset_ptr = in_str_var_end_ptr + 1;

            const std::tstring in_str_var_name(in_str_var_ptr + 2, in_str_var_end_ptr);
            const DWORD env_buf_size = !in_str_var_name.empty() ? ::GetEnvironmentVariable(in_str_var_name.c_str(), env_buf, MAX_ENV_BUF_SIZE) : (MAX_ENV_BUF_SIZE + 1);
            if (env_buf_size > MAX_ENV_BUF_SIZE) {
                // append as is
                parsed_str.append(in_str_var_ptr, in_str_var_end_ptr + 1);
                break;
            }
            if (env_buf_size) {
                parsed_str.append(env_buf);
            }
            else {
                env_buf[0] = _T('\0');

                parsed_str.append(_T("${"));
                parsed_str.append(in_str_var_name);
                parsed_str.append(_T("}"));
            }
        }

        return return_offset_ptr;
    }

    inline void _print_win_error_message(DWORD win_error, UINT langid = LANG_NEUTRAL)
    {
        LPTSTR win_error_msg_buf = nullptr;
        LPSTR win_error_msg_buf_a = nullptr;
        LPWSTR win_error_msg_buf_w = nullptr;

        [&]() { __try {
            const UINT cp_out = GetConsoleOutputCP();

            CPINFO cp_info{};
            if (!GetCPInfo(cp_out, &cp_info)) {
                // fallback to module character set
#ifdef _UNICODE
                cp_info.MaxCharSize = 2;
#else
                cp_info.MaxCharSize = 1;
#endif
            }

            if (cp_info.MaxCharSize != 1) {
                FormatMessageW(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
                    NULL, win_error, MAKELANGID(langid, SUBLANG_DEFAULT), (LPWSTR)&win_error_msg_buf_w, 0, NULL);
                fwprintf(stderr, L"error: win32: \"%s\"\n", win_error_msg_buf_w);
            }
            else {
                FormatMessageA(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
                    NULL, win_error, MAKELANGID(langid, SUBLANG_DEFAULT), (LPSTR)&win_error_msg_buf_a, 0, NULL);
                fprintf(stderr, "error: win32: \"%s\"\n", win_error_msg_buf_a);
            }
        }
        __finally {
            if (win_error_msg_buf) {
                LocalFree(win_error_msg_buf);
            }
            if (win_error_msg_buf_a) {
                LocalFree(win_error_msg_buf_a);
            }
            if (win_error_msg_buf_w) {
                LocalFree(win_error_msg_buf_w);
            }
        } }();
    }

    inline void _print_shell_exec_error_message(DWORD shell_error, const SHELLEXECUTEINFO & sei) {
        switch (shell_error) {
        case 0:
            _ftprintf(stderr, _T("error: ShellExecute: operating system is out of memory or resources: error=0x%08X (%d) file=\"%s\" params=\"%s\"\n"),
                shell_error, shell_error, sei.lpFile, sei.lpParameters);
            break;
        case SE_ERR_FNF:
            _ftprintf(stderr, _T("error: ShellExecute: file is not found: error=0x%08X (%d) file=\"%s\" params=\"%s\"\n"),
                shell_error, shell_error, sei.lpFile, sei.lpParameters);
            break;
        case SE_ERR_PNF:
            _ftprintf(stderr, _T("error: ShellExecute: path is not found: error=0x%08X (%d) file=\"%s\" params=\"%s\"\n"),
                shell_error, shell_error, sei.lpFile, sei.lpParameters);
            break;
        case SE_ERR_ACCESSDENIED:
            _ftprintf(stderr, _T("error: ShellExecute: access denied: error=0x%08X (%d) file=\"%s\" params=\"%s\"\n"),
                shell_error, shell_error, sei.lpFile, sei.lpParameters);
            break;
        case SE_ERR_OOM:
            _ftprintf(stderr, _T("error: ShellExecute: out of memory: error=0x%08X (%d) file=\"%s\" params=\"%s\"\n"),
                shell_error, shell_error, sei.lpFile, sei.lpParameters);
            break;
        case SE_ERR_DLLNOTFOUND:
            _ftprintf(stderr, _T("error: ShellExecute: dynamic-link library is not found: error=0x%08X (%d) file=\"%s\" params=\"%s\"\n"),
                shell_error, shell_error, sei.lpFile, sei.lpParameters);
            break;
        case SE_ERR_SHARE:
            _ftprintf(stderr, _T("error: ShellExecute: cannot share an open file: error=0x%08X (%d) file=\"%s\" params=\"%s\"\n"),
                shell_error, shell_error, sei.lpFile, sei.lpParameters);
            break;
        case SE_ERR_ASSOCINCOMPLETE:
            _ftprintf(stderr, _T("error: ShellExecute: file association information is not complete: error=0x%08X (%d) file=\"%s\" params=\"%s\"\n"),
                shell_error, shell_error, sei.lpFile, sei.lpParameters);
            break;
        case SE_ERR_DDETIMEOUT:
            _ftprintf(stderr, _T("error: ShellExecute: DDE operation is timed out: error=0x%08X (%d) file=\"%s\" params=\"%s\"\n"),
                shell_error, shell_error, sei.lpFile, sei.lpParameters);
            break;
        case SE_ERR_DDEFAIL:
            _ftprintf(stderr, _T("error: ShellExecute: DDE operation is failed: error=0x%08X (%d) file=\"%s\" params=\"%s\"\n"),
                shell_error, shell_error, sei.lpFile, sei.lpParameters);
            break;
        case SE_ERR_DDEBUSY:
            _ftprintf(stderr, _T("error: ShellExecute: DDE operation is busy: error=0x%08X (%d) file=\"%s\" params=\"%s\"\n"),
                shell_error, shell_error, sei.lpFile, sei.lpParameters);
            break;
        case SE_ERR_NOASSOC:
            _ftprintf(stderr, _T("error: ShellExecute: file association is not available: error=0x%08X (%d) file=\"%s\" params=\"%s\"\n"),
                shell_error, shell_error, sei.lpFile, sei.lpParameters);
            break;
        default:
            _ftprintf(stderr, _T("error: ShellExecute: unknown error: error=0x%08X (%d) file=\"%s\" params=\"%s\"\n"),
                shell_error, shell_error, sei.lpFile, sei.lpParameters);
        }
    }

    inline std::tstring _replace_strings(std::tstring str, const std::tstring & from, const std::tstring & to)
    {
        size_t start_pos = 0;
        while ((start_pos = str.find(from, start_pos)) != std::tstring::npos) {
            str.replace(start_pos, from.length(), to);
            start_pos += to.length();
        }
        return str;
    }

    inline std::tstring _eval_escape_chars(const std::tstring & str, bool eval_backslash_esc, bool eval_dbl_backslash_esc)
    {
        assert(eval_backslash_esc || eval_dbl_backslash_esc);

        std::vector<TCHAR> str_eval_buf;
        std::vector<TCHAR> digits_buf;
        std::vector<TCHAR> digits_eval_buf;
        TCHAR * stop_scan_char_ptr;
        size_t str_size = 0;
        size_t digit_index = 0;
        bool is_escape_char = false;
        bool is_digits = false;
        bool is_hex_digits = false;     // if not, then octal

        str_eval_buf.reserve(str.length() + (str.length() + 1) / 2 + 1); // compensate string expansion for heximal-to-decimal number convertion

        for (auto it = str.begin(); it != str.end(); ++it) {
            do { // empty do-loop to reuse iterator
                if (!is_escape_char) {
                    switch (*it) {
                    case _T('\\'):
                        is_escape_char = true;
                        digit_index = 0;
                        break;
                    default:
                        str_size++;

                        // resize on overflow
                        if (str_size > str_eval_buf.size()) {
                            str_eval_buf.resize(str_size);
                        }

                        str_eval_buf[str_size - 1] = *it;
                    }
                }
                else {
                    if (!eval_backslash_esc) {
                        if (*it == _T('\\')) goto dbl_backslash_esc;

                        str_size += 2;

                        // resize on overflow
                        if (str_size > str_eval_buf.size()) {
                            str_eval_buf.resize(str_size);
                        }

                        str_eval_buf[str_size - 2] = _T('\\');
                        str_eval_buf[str_size - 1] = *it;
                        is_escape_char = false;
                        break;
                    }

                    if (is_digits) goto default_;

                    switch (*it) {
                    case _T('\\'):
                    dbl_backslash_esc:

                        str_size++;

                        // resize on overflow
                        if (str_size > str_eval_buf.size()) {
                            str_eval_buf.resize(str_size);
                        }

                        str_eval_buf[str_size - 1] = _T('\\');
                        is_escape_char = false;
                        break;
                    case _T('a'):
                        str_size++;

                        // resize on overflow
                        if (str_size > str_eval_buf.size()) {
                            str_eval_buf.resize(str_size);
                        }

                        str_eval_buf[str_size - 1] = _T('\a');
                        is_escape_char = false;
                        break;
                    case _T('b'):
                        str_size++;

                        // resize on overflow
                        if (str_size > str_eval_buf.size()) {
                            str_eval_buf.resize(str_size);
                        }

                        str_eval_buf[str_size - 1] = _T('\b');
                        is_escape_char = false;
                        break;
                    case _T('t'):
                        str_size++;

                        // resize on overflow
                        if (str_size > str_eval_buf.size()) {
                            str_eval_buf.resize(str_size);
                        }

                        str_eval_buf[str_size - 1] = _T('\t');
                        is_escape_char = false;
                        break;
                    case _T('n'):
                        str_size++;

                        // resize on overflow
                        if (str_size > str_eval_buf.size()) {
                            str_eval_buf.resize(str_size);
                        }

                        str_eval_buf[str_size - 1] = _T('\n');
                        is_escape_char = false;
                        break;
                    case _T('v'):
                        str_size++;

                        // resize on overflow
                        if (str_size > str_eval_buf.size()) {
                            str_eval_buf.resize(str_size);
                        }

                        str_eval_buf[str_size - 1] = _T('\v');
                        is_escape_char = false;
                        break;
                    case _T('f'):
                        str_size++;

                        // resize on overflow
                        if (str_size > str_eval_buf.size()) {
                            str_eval_buf.resize(str_size);
                        }

                        str_eval_buf[str_size - 1] = _T('\f');
                        is_escape_char = false;
                        break;
                    case _T('r'):
                        str_size++;

                        // resize on overflow
                        if (str_size > str_eval_buf.size()) {
                            str_eval_buf.resize(str_size);
                        }

                        str_eval_buf[str_size - 1] = _T('\r');
                        is_escape_char = false;
                        break;
                    case _T('e'):
                        str_size++;

                        // resize on overflow
                        if (str_size > str_eval_buf.size()) {
                            str_eval_buf.resize(str_size);
                        }

                        str_eval_buf[str_size - 1] = _T('\x1B');
                        is_escape_char = false;
                        break;
                    case _T('"'):
                        str_size++;

                        // resize on overflow
                        if (str_size > str_eval_buf.size()) {
                            str_eval_buf.resize(str_size);
                        }

                        str_eval_buf[str_size - 1] = _T('"');
                        is_escape_char = false;
                        break;
                    case _T('\''):
                        str_size++;

                        // resize on overflow
                        if (str_size > str_eval_buf.size()) {
                            str_eval_buf.resize(str_size);
                        }

                        str_eval_buf[str_size - 1] = _T('\'');
                        is_escape_char = false;
                        break;
                    case _T('\?'):
                        str_size++;

                        // resize on overflow
                        if (str_size > str_eval_buf.size()) {
                            str_eval_buf.resize(str_size);
                        }

                        str_eval_buf[str_size - 1] = _T('\?');
                        is_escape_char = false;
                        break;
                    case _T('x'):
                        is_digits = true;
                        is_hex_digits = true;
                        if (digits_buf.capacity() < 16) {
                            digits_buf.reserve(16);
                        }
                        digits_buf.resize(0);
                        break;
                    default: default_:
                        if (is_hex_digits) {
                            const int is_hex_digit = tisxdigit(*it);
                            if (is_hex_digit) {
                                // resize on overflow
                                if (digits_buf.size() < digit_index + 2) { // including terminal character
                                    digits_buf.resize(digit_index + 2);
                                }

                                digits_buf[digit_index] = *it;

                                digit_index++;
                            }

                            if (!is_hex_digit || digit_index >= 8) {
                                // resize on overflow
                                if (digits_buf.size() < digit_index + 2) { // including terminal character
                                    digits_buf.resize(digit_index + 2);
                                }

                                digits_buf[digit_index] = _T('\0');

                                _set_errno(0); // just in case
                                const auto decimal_value = tstrtoul(&digits_buf[0], &stop_scan_char_ptr, 16);
                                if (errno != ERANGE) {
                                    digits_eval_buf.resize(10 + 1); // max decimal digits
                                    digits_eval_buf[0] = _T('\0');
                                    ultot(decimal_value, &digits_eval_buf[0], 10);
                                    const size_t digits_num = tstrlen(&digits_eval_buf[0]);
                                    str_eval_buf.resize(str_size + digits_num);
                                    tstrcat(&str_eval_buf[str_size], &digits_eval_buf[0]);
                                    str_size += digits_num;
                                }

                                is_escape_char = false;
                                is_digits = false;
                                is_hex_digits = false;

                                continue; // reuse iterator
                            }
                        }
                        else {
                            const int is_octal_digit = tisdigit(*it) && *it != _T('8') && *it != _T('9');
                            if (is_octal_digit) {
                                if (!digit_index) {
                                    is_digits = true;
                                    if (digits_buf.capacity() < 16) {
                                        digits_buf.reserve(16);
                                    }
                                }

                                // resize on overflow
                                if (digits_buf.size() < digit_index + 2) { // including terminal character
                                    digits_buf.resize(digit_index + 2);
                                }

                                digits_buf[digit_index] = *it;

                                digit_index++;
                            }

                            if (!is_octal_digit || digit_index >= 10) {
                                // resize on overflow
                                if (digits_buf.size() < digit_index + 2) { // including terminal character
                                    digits_buf.resize(digit_index + 2);
                                }

                                digits_buf[digit_index] = _T('\0');

                                _set_errno(0); // just in case
                                const auto decimal_value = tstrtoul(&digits_buf[0], &stop_scan_char_ptr, 8);
                                if (errno != ERANGE) {
                                    digits_eval_buf.resize(10 + 1); // max decimal digits
                                    digits_eval_buf[0] = _T('\0');
                                    ultot(decimal_value, &digits_eval_buf[0], 10);
                                    const size_t digits_num = tstrlen(&digits_eval_buf[0]);
                                    str_eval_buf.resize(str_size + digits_num);
                                    tstrcat(&str_eval_buf[str_size], &digits_eval_buf[0]);
                                    str_size += digits_num;
                                }

                                is_escape_char = false;
                                is_digits = false;

                                continue; // reuse iterator
                            }
                        }
                    }
                }
                break;
            } while (true);
        }

        // postprocess

        if (is_hex_digits) {
            // resize on overflow
            if (digits_buf.size() < digit_index + 2) { // including terminal character
                digits_buf.resize(digit_index + 2);
            }

            digits_buf[digit_index] = _T('\0');

            _set_errno(0); // just in case
            const auto decimal_value = tstrtoul(&digits_buf[0], &stop_scan_char_ptr, 16);
            if (errno != ERANGE) {
                digits_eval_buf.resize(10 + 1); // max decimal digits
                digits_eval_buf[0] = _T('\0');
                ultot(decimal_value, &digits_eval_buf[0], 10);
                const size_t digits_num = tstrlen(&digits_eval_buf[0]);
                str_eval_buf.resize(str_size + digits_num);
                tstrcat(&str_eval_buf[str_size], &digits_eval_buf[0]);
                str_size += digits_num;
            }
        }
        else if (is_digits) {
            // resize on overflow
            if (digits_buf.size() < digit_index + 2) { // including terminal character
                digits_buf.resize(digit_index + 2);
            }

            digits_buf[digit_index] = _T('\0');

            _set_errno(0); // just in case
            const auto decimal_value = tstrtoul(&digits_buf[0], &stop_scan_char_ptr, 8);
            if (errno != ERANGE) {
                digits_eval_buf.resize(10 + 1); // max decimal digits
                digits_eval_buf[0] = _T('\0');
                ultot(decimal_value, &digits_eval_buf[0], 10);
                const size_t digits_num = tstrlen(&digits_eval_buf[0]);
                str_eval_buf.resize(str_size + digits_num);
                tstrcat(&str_eval_buf[str_size], &digits_eval_buf[0]);
                str_size += digits_num;
            }
        }

        // resize on overflow
        if (str_size + 1 > str_eval_buf.size()) {
            str_eval_buf.resize(str_size + 1);
        }

        str_eval_buf[str_size] = _T('\0');

        return std::tstring(&str_eval_buf[0], &str_eval_buf[str_size]);
    }
}

#endif
