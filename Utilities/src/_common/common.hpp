#ifndef __COMMON_HPP__
#define __COMMON_HPP__

#include <version.hpp>

#include <string>
#include <vector>
#include <deque>
#include <locale>
#include <algorithm>
#include <cstdio>
#include <cstdarg>
#include <ctime>
#include <atomic>

#include <assert.h>
#include <stdint.h>
#include <ShellAPI.h>

#include <stdio.h>
#include <string.h>
#include <memory.h>
#include <io.h>
#include <fcntl.h>
#include <tlhelp32.h>

#include "std/tctype.hpp"
#include "std/tstdlib.hpp"
#include "std/tstring.hpp"
#include "std/tstdio.hpp"
#include "std/ttime.hpp"

#include "tacklelib/tackle/platform.hpp"
#include "tacklelib/tackle/type_identity.hpp"
#include "tacklelib/tackle/string_identity.hpp"
#include "tacklelib/tackle/type_traits.hpp"
#include "tacklelib/tackle/addressof.hpp"


#define if_break switch(0) case 0: default: if
#define MAX_ENV_BUF_SIZE 32767

#define STDIN_FILENO    0
#define STDOUT_FILENO   1
#define STDERR_FILENO   2


namespace {
    enum _error
    {
        err_none            = 0,

        err_unspecified     = -255,

        err_help_output     = -128,

        err_named_pipe_connect_timeout = -7,
        err_named_pipe_connect_error = -6,
        err_io_error        = -5,
        err_win32_error     = -4,
        err_invalid_params  = -3,
        err_invalid_format  = -2,
        err_format_empty    = -1
    };

    using uint_t = unsigned int;

    using const_tchar_ptr_vector_t = std::vector<const TCHAR *>;
    using tstring_vector_t = std::vector<std::tstring>;


    template <typename T>
    inline T (& make_singular_array(T & ref))[1]
    {
        return reinterpret_cast<T(&)[1]>(ref);
    }

    template <typename T, typename... Args>
    inline void _construct(T & ref, Args &&... args)
    {
        ::new (utility::addressof(ref)) T(std::forward<Args>(args)...);
    }

    template <typename T>
    inline void _destruct(T * ptr)
    {
        ptr->~T();
    }

    struct _AnyString
    {
        _AnyString(const std::string & astr_) :
            astr(astr_), is_wstr(false)
        {
        }

        _AnyString(std::string && astr_) :
            astr(std::move(astr_)), is_wstr(false)
        {
        }

        _AnyString(const std::wstring & wstr_) :
            wstr(wstr_), is_wstr(true)
        {
        }

        _AnyString(std::wstring && wstr_) :
            wstr(std::move(wstr_)), is_wstr(true)
        {
        }

        _AnyString(const _AnyString & anystr) :
            is_wstr(anystr.is_wstr)
        {
            if (is_wstr) {
                _construct(wstr, anystr.wstr);
            }
            else {
                _construct(astr, anystr.astr);
            }
        }

        _AnyString(_AnyString && anystr) :
            is_wstr(anystr.is_wstr)
        {
            if (is_wstr) {
                _construct(wstr, std::move(anystr.wstr));
            }
            else {
                _construct(astr, std::move(anystr.astr));
            }
        }

        ~_AnyString()
        {
            if (is_wstr) {
                _destruct(&wstr);
            }
            else {
                _destruct(&astr);
            }
        }

        union {
            std::string     astr;
            std::wstring    wstr;
        };
        bool                is_wstr;
    };

    struct _ConsoleOutput
    {
        int         stream_type;
        _AnyString  any_str;
    };


    const TCHAR * g_hextbl[] = {
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

    std::deque<_ConsoleOutput>  g_conout_prints_buf;
    bool                        g_enable_conout_prints_buffering;


    inline void _get_win_ver(uint_t & major, uint_t & minor, uint_t & build)
    {
        // CAUTION:
        //  Has effect only for Windows version up to 8.1 (read MSDN documentation)
        //
        const DWORD dwVersion = GetVersion();

        major = (DWORD)(LOBYTE(LOWORD(dwVersion)));
        minor = (DWORD)(HIBYTE(LOWORD(dwVersion)));

        if (dwVersion < 0x80000000) {
            build = (DWORD)(HIWORD(dwVersion));
        }
    }

    std::tstring::value_type _to_lower(std::tstring::value_type ch, unsigned int code_page)
    {
        if (code_page) {
            // NOTE: increases executable on + ~200KB
            return std::use_facet<std::ctype<std::tstring::value_type> >(std::locale(std::string(".") + std::to_string(code_page))).tolower(ch);
        }

        // NOTE: w/o above code increases executable on + ~60KB
        return std::use_facet<std::ctype<std::tstring::value_type> >(std::locale()).tolower(ch);
    }

    struct _to_lower_with_codepage
    {
        _to_lower_with_codepage(unsigned int code_page_) :
            code_page(code_page_)
        {
        }

        std::tstring::value_type operator()(std::tstring::value_type ch_)
        {
            return _to_lower(ch_, code_page);
        }

        unsigned int code_page;
    };

    // code_page=0 for default std::locale
    std::tstring _to_lower(std::tstring str, unsigned int code_page)
    {
        std::tstring res;
        res.resize(str.size());
        std::transform(str.begin(), str.end(), res.begin(), _to_lower_with_codepage(code_page));
        return res;
    }

    uint64_t _hash_string_to_u64(std::tstring str, unsigned int code_page)
    {
        uint64_t res = 10000019;
        for (size_t i = 0; i < str.length(); i += 2)
        {
            uint64_t merge = _to_lower(str[i], code_page) * 65536 + _to_lower(str[i + 1], code_page);
            res = res * 8191 + merge; // unchecked arithmetic
        }
        return res;
    }

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

    inline bool _set_crt_std_handle(HANDLE file_handle, int id, bool duplicate_input_handle, bool inherit_handle_on_duplicate = true)
    {
        int flags = 0;

#ifdef _UNICODE
        flags |= _O_WTEXT;
#else
        flags |= _O_TEXT;
#endif

        // CAUTION:
        //  Based on: `_open_osfhandle` : https://docs.microsoft.com/en-us/cpp/c-runtime-library/reference/open-osfhandle
        //    The _open_osfhandle call transfers ownership of the Win32 file handle to the file descriptor.
        //    To close a file opened by using _open_osfhandle, call _close. The underlying OS file handle is also closed by a call to _close.
        //    Don't call the Win32 function CloseHandle on the original handle.
        //    If the file descriptor is owned by a FILE * stream, then a call to fclose closes both the file descriptor and the underlying handle.
        //    In this case, don't call _close on the file descriptor or CloseHandle on the original handle.
        //

        // So, we must duplicate handle from here and return the duplicated one back out from the function.

        // CAUTION:
        //  We must not change the input handle, otherwise functions like `ConnectNamedPipe` will fail on a duplicated handle!
        //

        // CAUTION:
        //  MSDN:
        //    If stdout or stderr is not associated with an output stream (for example, in a Windows application without a console window),
        //    the file descriptor returned is -2. In previous versions, the file descriptor returned was -1.
        //    This change allows applications to distinguish this condition from an error.
        //
        //  The `_fileno` can return negative number and it does if a standard handle is already closed (parent process has called `CreateProcess` w/o standard handles inheritance).
        //  In that case you must use a direct number, for example, `STDOUT_FILENO` instead of `_fileno(stdout)`, otherwise all sequenced calls will fail, which means `_close(fd)` will close
        //  the handle w/o a duplication!
        //

        // CAUTION:
        //  The `_open_osfhandle` would ignore `SetStdHandle` if all 3 ids already has been allocated.
        //  The `_dup2` can fail with -1 return code in case if can not duplicate a handle and it happens
        //  when the handle has been opened from the `CONOUT$` file!
        //

        HANDLE file_handle_crt = file_handle;

        switch (id)
        {
        case 0: {
            if (duplicate_input_handle) {
                if (!DuplicateHandle(GetCurrentProcess(), file_handle, GetCurrentProcess(), &file_handle_crt, 0,
                    inherit_handle_on_duplicate ? TRUE : FALSE, DUPLICATE_SAME_ACCESS)) {
                    return false;
                }
            }

            const int fd = _open_osfhandle((intptr_t)file_handle_crt, flags | _O_RDONLY);
            const int stdin_fileno = _fileno(stdin);
            _dup2(fd, stdin_fileno >= 0 ? stdin_fileno : STDIN_FILENO);
            _close(fd);
        } break;

        case 1: {
            if (duplicate_input_handle) {
                if (!DuplicateHandle(GetCurrentProcess(), file_handle, GetCurrentProcess(), &file_handle_crt, 0,
                    inherit_handle_on_duplicate ? TRUE : FALSE, DUPLICATE_SAME_ACCESS)) {
                    return false;
                }
            }

            const int fd = _open_osfhandle((intptr_t)file_handle_crt, flags | _O_WRONLY);
            const int stdout_fileno = _fileno(stdout);
            _dup2(fd, stdout_fileno >= 0 ? stdout_fileno : STDOUT_FILENO);
            _close(fd);
        } break;

        case 2: {
            if (duplicate_input_handle) {
                if (!DuplicateHandle(GetCurrentProcess(), file_handle, GetCurrentProcess(), &file_handle_crt, 0,
                    inherit_handle_on_duplicate ? TRUE : FALSE, DUPLICATE_SAME_ACCESS)) {
                    return false;
                }
            }

            const int fd = _open_osfhandle((intptr_t)file_handle_crt, flags | _O_WRONLY);
            const int stderr_fileno = _fileno(stderr);
            _dup2(fd, stderr_fileno >= 0 ? stderr_fileno : STDERR_FILENO);
            _close(fd);
        } break;

        default:
            return false;
        }

        return true;
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

    inline void _reattach_stdin_to_console(bool inherit_handle)
    {
        SECURITY_ATTRIBUTES sa{};

        sa.nLength = sizeof(sa);
        sa.bInheritHandle = inherit_handle ? TRUE : FALSE;

        HANDLE conin_handle = CreateFile(_T("CONIN$"),
            GENERIC_READ, FILE_SHARE_READ, &sa,
            OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);

        if (_is_valid_handle(conin_handle)) {
            _set_crt_std_handle(conin_handle, 0, false);
        }
    }

    inline void _reattach_stdout_to_console(bool inherit_handle)
    {
        SECURITY_ATTRIBUTES sa{};

        sa.nLength = sizeof(sa);
        sa.bInheritHandle = inherit_handle ? TRUE : FALSE;

        HANDLE conout_handle = CreateFile(_T("CONOUT$"),
            GENERIC_WRITE, FILE_SHARE_WRITE, &sa,
            OPEN_ALWAYS,
            FILE_ATTRIBUTE_NORMAL, NULL);

        if (_is_valid_handle(conout_handle)) {
            _set_crt_std_handle(conout_handle, 1, false);
        }
    }

    inline void _reattach_stderr_to_console(bool inherit_handle)
    {
        SECURITY_ATTRIBUTES sa{};

        sa.nLength = sizeof(sa);
        sa.bInheritHandle = inherit_handle ? TRUE : FALSE;

        HANDLE conout_handle = CreateFile(_T("CONOUT$"),
            GENERIC_WRITE, FILE_SHARE_WRITE, &sa,
            OPEN_ALWAYS,
            FILE_ATTRIBUTE_NORMAL, NULL);

        if (_is_valid_handle(conout_handle)) {
            _set_crt_std_handle(conout_handle, 2, false);
        }
    }

    inline void _reattach_std_console_handles(bool inherit_handles)
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
            _reattach_stdin_to_console(inherit_handles);
        }

        switch (stdout_handle_type) {
        case FILE_TYPE_UNKNOWN:
        case FILE_TYPE_CHAR:
            _reattach_stdout_to_console(inherit_handles);
        }

        switch (stderr_handle_type) {
        case FILE_TYPE_UNKNOWN:
        case FILE_TYPE_CHAR:
            _reattach_stderr_to_console(inherit_handles);
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

    struct _EnumConsoleWindowsProcData
    {
        TCHAR tchar_buf[256];
        std::vector<HWND> console_window_handles_arr;
    };

    BOOL CALLBACK EnumConsoleWindowsProc(HWND hwnd, LPARAM lParam)
    {
        _EnumConsoleWindowsProcData & enum_proc_data = *(_EnumConsoleWindowsProcData *)lParam;

        enum_proc_data.tchar_buf[0] = _T('\0');

        GetClassName(hwnd, enum_proc_data.tchar_buf, sizeof(enum_proc_data.tchar_buf));

        if (!tstrcmp(enum_proc_data.tchar_buf, _T("ConsoleWindowClass"))) {
            enum_proc_data.console_window_handles_arr.push_back(hwnd);
        }

        return TRUE;
    }

    struct _ConsoleWindowOwnerProc
    {
        DWORD proc_id;
        HWND  console_window;   // NULL if not owned

        _ConsoleWindowOwnerProc() :
            proc_id(-1), console_window()
        {
        }

        _ConsoleWindowOwnerProc(DWORD proc_id_, HWND console_window_) :
            proc_id(proc_id_), console_window(console_window_)
        {
        }

        _ConsoleWindowOwnerProc(const _ConsoleWindowOwnerProc &) = default;
        _ConsoleWindowOwnerProc(_ConsoleWindowOwnerProc &&) = default;

        _ConsoleWindowOwnerProc & operator =(const _ConsoleWindowOwnerProc &) = default;
        _ConsoleWindowOwnerProc & operator =(_ConsoleWindowOwnerProc &&) = default;
    };

    inline DWORD _find_parent_proc_id()
    {
        DWORD parent_proc_id = -1;

        HANDLE proc_list_handle = INVALID_HANDLE_VALUE;
        const DWORD current_proc_id = GetCurrentProcessId();

        [&]() { __try {
            [&]() {
                proc_list_handle = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
                PROCESSENTRY32 pe = { 0 };
                pe.dwSize = sizeof(PROCESSENTRY32);

                if (Process32First(proc_list_handle, &pe)) {
                    do {
                        if (current_proc_id == pe.th32ProcessID) {
                            parent_proc_id = pe.th32ParentProcessID;
                            break;
                        }
                    } while (Process32Next(proc_list_handle, &pe));
                }
            }();
        }
        __finally {
            _close_handle(proc_list_handle);
        } }();

        return parent_proc_id;
    }

    // CAUTION:
    //  Function GetConsoleWindow() returns already inherited console window handle!
    //  We have to find console window relation through the console windows enumeration.
    //  If returns NULL, then it means the current process DOES NOT OWN the console window, but nevertheless can have it.
    //
    inline HWND _find_console_window_owner_procs(std::vector<_ConsoleWindowOwnerProc> * ancestors_ptr, DWORD & parent_proc_id)
    {
        parent_proc_id = (DWORD)-1;

        if (ancestors_ptr) {
            ancestors_ptr->reserve(64);
        }

        _EnumConsoleWindowsProcData enum_proc_data;

        enum_proc_data.console_window_handles_arr.reserve(256);

        if (!EnumWindows(&EnumConsoleWindowsProc, (LPARAM)&enum_proc_data)) {
            return NULL;
        }

        if (!enum_proc_data.console_window_handles_arr.size()) {
            return NULL;
        }

        HWND current_proc_console_window = NULL;

        DWORD console_window_proc_id;
        HANDLE proc_list_handle = INVALID_HANDLE_VALUE;
        const DWORD current_proc_id = GetCurrentProcessId();

        for (auto console_window_handle : enum_proc_data.console_window_handles_arr) {
            console_window_proc_id = (DWORD)-1;
            GetWindowThreadProcessId(console_window_handle, &console_window_proc_id);
            if (console_window_proc_id == current_proc_id) {
                current_proc_console_window = console_window_handle;
                break;
            }
        }

        [&]() { __try {
            [&]() {
                proc_list_handle = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
                PROCESSENTRY32 pe = { 0 };
                pe.dwSize = sizeof(PROCESSENTRY32);

                if (Process32First(proc_list_handle, &pe)) {
                    bool continue_search_ancestors = false;
                    DWORD ancestor_proc_id = (DWORD)-1;

                    do {
                        if (current_proc_id == pe.th32ProcessID) {
                            ancestor_proc_id = parent_proc_id = pe.th32ParentProcessID;
                            if (ancestors_ptr) {
                                ancestors_ptr->push_back({ parent_proc_id, NULL });
                            }
                            continue_search_ancestors = true;
                            break;
                        }
                    } while (Process32Next(proc_list_handle, &pe));

                    if (!ancestors_ptr) return;

                    while (continue_search_ancestors) {
                        continue_search_ancestors = false;

                        Process32First(proc_list_handle, &pe);

                        do {
                            if (ancestor_proc_id == pe.th32ProcessID) {
                                ancestor_proc_id = pe.th32ParentProcessID;
                                ancestors_ptr->push_back({ ancestor_proc_id, NULL });
                                continue_search_ancestors = true;
                                break;
                            }
                        } while (Process32Next(proc_list_handle, &pe));
                    }
                }
            }();
        }
        __finally {
            _close_handle(proc_list_handle);
        } }();

        if (ancestors_ptr && parent_proc_id != -1) {
            for (auto console_window_handle : enum_proc_data.console_window_handles_arr) {
                console_window_proc_id = (DWORD)-1;
                GetWindowThreadProcessId(console_window_handle, &console_window_proc_id);

                for (auto & ancestor_console_window_owner_proc : *ancestors_ptr) {
                    if (console_window_proc_id == ancestor_console_window_owner_proc.proc_id) {
                        ancestor_console_window_owner_proc.console_window = console_window_handle;
                        break;
                    }
                }
            }
        }

        return current_proc_console_window;
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

    inline void _print_raw_message(int stream_type, const char * fmt, ...)
    {
        char fixed_message_char_buf[256];

        // just in case
        fixed_message_char_buf[0] = '\0';

        va_list args1;
        va_start(args1, fmt);

        // CAUTION:
        //
        //  MSDN:
        //    The vsnprintf function returns the number of characters that are written, not counting the terminating null character.
        //    If the buffer size specified by count isn't sufficiently large to contain the output specified by format and argptr,
        //    the return value of vsnprintf is the number of characters that would be written, not counting the null character, if count were sufficiently large.
        //    If the return value is greater than count - 1, the output has been truncated. A return value of -1 indicates that an encoding error has occurred.
        //
        //  The `vsnprintf` returns -1 on encoding error and value greater than count if output string is truncated.
        //

        constexpr const size_t fixed_message_char_buf_size = sizeof(fixed_message_char_buf) / sizeof(fixed_message_char_buf[0]);
        const int num_written_chars = vsnprintf(fixed_message_char_buf, fixed_message_char_buf_size, fmt, args1);

        va_end(args1);

        if (num_written_chars > 0 && num_written_chars < fixed_message_char_buf_size) {
            if (g_enable_conout_prints_buffering) {
                g_conout_prints_buf.push_back(_ConsoleOutput{ 1, std::string{ fixed_message_char_buf, size_t(num_written_chars) } });
            }

            switch (stream_type) {
            case 1:
                fputs(fixed_message_char_buf, stdout);
                break;
            case 2:
                fputs(fixed_message_char_buf, stderr);
                break;
            }
        }
        else if (num_written_chars >= -1) {
            std::vector<char> char_buf;

            char_buf.resize(num_written_chars + 1);

            va_start(args1, fmt);

            vsnprintf(char_buf.data(), char_buf.size(), fmt, args1);

            va_end(args1);

            if (g_enable_conout_prints_buffering) {
                g_conout_prints_buf.push_back(_ConsoleOutput{ 1, std::string{ char_buf.data(), char_buf.size() > 0 ? char_buf.size() - 1 : 0 } });
            }

            switch (stream_type) {
            case 1:
                fputs(char_buf.data(), stdout);
                break;
            case 2:
                fputs(char_buf.data(), stderr);
                break;
            }
        }
        else {
            // CAUTION:
            //
            //  MSDN:
            //   Let len be the length of the formatted data string, not including the terminating null. Both len and count are the number of characters for snprintf and _snprintf,
            //   and the number of wide characters for _snwprintf.
            //
            //   For all functions, if len < count, len characters are stored in buffer, a null - terminator is appended, and len is returned.
            //
            //   The snprintf function truncates the output when len is greater than or equal to count, by placing a null-terminator at buffer[count-1].
            //   The value returned is len, the number of characters that would have been output if count was large enough.
            //   The snprintf function returns a negative value if an encoding error occurs.
            //

            const int num_written_chars2 = snprintf(fixed_message_char_buf, fixed_message_char_buf_size, "%s\n", (char *)NULL); // encoding error

            if (g_enable_conout_prints_buffering) {
                g_conout_prints_buf.push_back(_ConsoleOutput{ 1, std::string{ fixed_message_char_buf, size_t(num_written_chars2) } });
            }

            switch (stream_type) {
            case 1:
                fputs(fixed_message_char_buf, stdout);
                break;
            case 2:
                fputs(fixed_message_char_buf, stderr);
                break;
            }
        }
    }

    inline void _print_raw_message(int stream_type, const wchar_t * fmt, ...)
    {
        wchar_t fixed_message_char_buf[256];

        // just in case
        fixed_message_char_buf[0] = L'\0';

        va_list args1;
        va_start(args1, fmt);

        // CAUTION:
        //
        //  MSDN:
        //    Both _vsnprintf and _vsnwprintf functions return the number of characters written if the number of characters to write is less than or equal to count.
        //    If the number of characters to write is greater than count, these functions return -1 indicating that output has been truncated
        //
        //  The `_vsnwprintf` has a different behaviour versus the `vsnprintf` function and returns -1 on output string truncation (no an encoding error!),
        //  so we must call `_vsnwprintf` first time with an empty buffer and zero count to request the buffer size!
        //

        std::vector<wchar_t> char_buf;

        const int num_written_chars = _vsnwprintf(NULL, 0, fmt, args1);

        char_buf.resize(num_written_chars + 1);

        _vsnwprintf(char_buf.data(), char_buf.size(), fmt, args1);

        va_end(args1);

        if (g_enable_conout_prints_buffering) {
            g_conout_prints_buf.push_back(_ConsoleOutput{ 1, std::wstring{ char_buf.data(), char_buf.data() > 0 ? char_buf.data() - 1 : 0 } });
        }

        switch (stream_type) {
        case 1:
            fputws(char_buf.data(), stdout);
            break;
        case 2:
            fputws(char_buf.data(), stderr);
            break;
        }
    }

    inline double _get_utc_to_local_time_offset_sec()
    {
        time_t currtime;

        time(&currtime);
        struct tm * timeinfo = gmtime(&currtime);

        time_t utc = mktime(timeinfo);
        timeinfo = localtime(&currtime);
        time_t local = mktime(timeinfo);

        // Get offset in hours from UTC
        double utc_to_local_offset_sec = difftime(local, utc);

        // adjust for DST
        if (timeinfo->tm_isdst > 0) {
            utc_to_local_offset_sec -= 60;
        }

        return utc_to_local_offset_sec;
    }

    // `time_utc = false` for local time
    inline void _unix_time(struct timespec *spec, bool time_utc = true)
    {
#ifdef UTILITY_PLATFORM_WINDOWS
        static constexpr const uint64_t from_1_jan1601_to_1_jan1970_100nsecs = 116444736000000000ULL;   //1.jan1601 to 1.jan1970
        int64_t wintime;
        GetSystemTimeAsFileTime((FILETIME *)&wintime);
        wintime -= from_1_jan1601_to_1_jan1970_100nsecs;
        spec->tv_sec = wintime / 10000000;
        spec->tv_nsec = wintime % 10000000 * 100;
        if (!time_utc) {
            TIME_ZONE_INFORMATION tz{};
            GetTimeZoneInformation(&tz);
            spec->tv_sec -= tz.Bias * 60;
        }
#elif defined(UTILITY_PLATFORM_POSIX) || defined(UTILITY_PLATFORM_MINGW)
        struct timeval tv;
        gettimeofday(&tv, NULL);
        spec->tv_sec = tv.tv_sec;
        spec->tv_nsec = tv.tv_usec * 1000;
        if (!time_utc) {
            const double utc_to_local_offset_sec = _get_utc_to_local_time_offset_sec();
            spec->tv_sec += decltype(spec->tv_sec){ utc_to_local_offset_sec }
        }
#else
        ::timespec_get(spec, TIME_UTC);
        if (!time_utc) {
            const double utc_to_local_offset_sec = _get_utc_to_local_time_offset_sec();
            spec->tv_sec += static_cast<decltype(spec->tv_sec)>(utc_to_local_offset_sec);
        }
#endif
    }

    inline std::string _get_time_str(utility::tag_string, bool time_utc)
    {
        struct timespec tmspec{};
        _unix_time(&tmspec, time_utc);

        char buffer[32];

        time_t tm_{ tmspec.tv_sec };
        struct tm * tm_info = time_utc ? gmtime(&tm_) : localtime(&tm_);
        strftime(buffer, sizeof(buffer) / sizeof(buffer[0]), "%Y:%m:%d %H:%M:%S", tm_info);

        int millisec = lrint(tmspec.tv_nsec / 1000000.0); // Round to nearest millisec
        if (millisec >= 1000) { // Allow for rounding up to nearest second
            millisec -= 1000;
            tmspec.tv_sec++;
        }

        sprintf(buffer + strlen(buffer), ".%03d", millisec);

        return buffer;
    }

    inline std::wstring _get_time_str(utility::tag_wstring, bool time_utc)
    {
        struct timespec tmspec {};
        _unix_time(&tmspec, time_utc);

        wchar_t buffer[32];

        time_t tm_{ tmspec.tv_sec };
        struct tm * tm_info = gmtime(&tm_);
        wcsftime(buffer, sizeof(buffer) / sizeof(buffer[0]), L"%Y:%m:%d %H:%M:%S", tm_info);

        int millisec = lrint(tmspec.tv_nsec / 1000000.0); // Round to nearest millisec
        if (millisec >= 1000) { // Allow for rounding up to nearest second
            millisec -= 1000;
            tmspec.tv_sec++;
        }

        _swprintf(buffer + wcslen(buffer), L".%03d", millisec);

        return buffer;
    }

    inline std::string _format_stderr_message(const char * fmt, va_list vl)
    {
        char module_char_buf[256];
        char fixed_message_char_buf[256];

        // just in case
        module_char_buf[0] = '\0';
        fixed_message_char_buf[0] = '\0';

        const std::string local_time_str = _get_time_str(utility::tag_string{}, false);

        module_char_buf[0] = '\0';
        GetModuleFileNameA(NULL, module_char_buf, sizeof(module_char_buf) / sizeof(module_char_buf[0]));
        module_char_buf[sizeof(module_char_buf) / sizeof(module_char_buf[0]) - 1] = '\0'; // for Windows XP

        // CAUTION:
        //
        //  MSDN:
        //    The vsnprintf function returns the number of characters that are written, not counting the terminating null character.
        //    If the buffer size specified by count isn't sufficiently large to contain the output specified by format and argptr,
        //    the return value of vsnprintf is the number of characters that would be written, not counting the null character, if count were sufficiently large.
        //    If the return value is greater than count - 1, the output has been truncated. A return value of -1 indicates that an encoding error has occurred.
        //
        //  The `vsnprintf` returns -1 on encoding error and value greater than count if output string is truncated.
        //
        //  MSDN:
        //
        //    For all functions other than snprintf, if len = count, len characters are stored in buffer, no null-terminator is appended, and len is returned.
        //    If len > count, count characters are stored in buffer, no null-terminator is appended, and a negative value is returned.
        //
        //    If buffer is a null pointer and count is zero, len is returned as the count of characters required to format the output, not including the terminating null.
        //    To make a successful call with the same argument and locale parameters, allocate a buffer holding at least len + 1 characters.
        //
        //  The `_snprintf` has a different behaviour versus the `vsnprintf` function and returns a negative value on output string truncation (no an encoding error!),
        //  so we must call `_snprintf` first time with an empty buffer and zero count to request the buffer size!
        //

        constexpr const size_t fixed_message_char_buf_size = sizeof(fixed_message_char_buf) / sizeof(fixed_message_char_buf[0]);
        const int num_written_chars = vsnprintf(fixed_message_char_buf, fixed_message_char_buf_size, fmt, vl);

        if (num_written_chars > 0 && num_written_chars < fixed_message_char_buf_size) {
            std::vector<char> char_buf;

            const int num_written_chars2 =
                _snprintf(NULL, 0,
                    "[%s] [%u] [%s] error: %s",
                    local_time_str.c_str(), GetCurrentProcessId(), module_char_buf, fixed_message_char_buf);

            char_buf.resize(num_written_chars2 + 1);

            _snprintf(char_buf.data(), char_buf.size(),
                "[%s] [%u] [%s] error: %s",
                local_time_str.c_str(), GetCurrentProcessId(), module_char_buf, fixed_message_char_buf);

            return std::string{ char_buf.data(), char_buf.size() > 0 ? char_buf.size() - 1 : 0 };
        }
        else if (num_written_chars >= -1) {
            std::vector<char> char_buf;
            std::vector<char> char_buf2;

            char_buf.resize(num_written_chars + 1);

            vsnprintf(char_buf.data(), char_buf.size(), fmt, vl);

            const int num_written_chars2 =
                _snprintf(NULL, 0,
                    "[%s] [%u] [%s] error: %s",
                    local_time_str.c_str(), GetCurrentProcessId(), module_char_buf, char_buf.data());

            char_buf2.resize(num_written_chars2 + 1);

            _snprintf(char_buf2.data(), char_buf2.size(),
                "[%s] [%u] [%s] error: %s",
                local_time_str.c_str(), GetCurrentProcessId(), module_char_buf, char_buf.data());

            return std::string{ char_buf2.data(), char_buf2.size() > 0 ? char_buf2.size() - 1 : 0 };
        }
        else {
            std::vector<char> char_buf;

            const int num_written_chars2 =
                _snprintf(NULL, 0,
                    "[%s] [%u] [%s] error: %s",
                    local_time_str.c_str(), GetCurrentProcessId(), module_char_buf, (char *)NULL);

            char_buf.resize(num_written_chars2 + 1);

            _snprintf(char_buf.data(), char_buf.size(),
                "[%s] [%u] [%s] error: %s",
                local_time_str.c_str(), GetCurrentProcessId(), module_char_buf, (char *)NULL);

            return std::string{ char_buf.data(), char_buf.size() > 0 ? char_buf.size() - 1 : 0 };
        }
    }

    inline std::wstring _format_stderr_message(const wchar_t * fmt, va_list vl)
    {
        wchar_t module_char_buf[256];
        wchar_t fixed_message_char_buf[256];

        // just in case
        module_char_buf[0] = L'\0';
        fixed_message_char_buf[0] = L'\0';

        const std::wstring local_time_str = _get_time_str(utility::tag_wstring{}, false);

        module_char_buf[0] = L'\0';
        GetModuleFileNameW(NULL, module_char_buf, sizeof(module_char_buf) / sizeof(module_char_buf[0]));
        module_char_buf[sizeof(module_char_buf) / sizeof(module_char_buf[0]) - 1] = L'\0'; // for Windows XP

        // CAUTION:
        //
        //  MSDN:
        //    Both _vsnprintf and _vsnwprintf functions return the number of characters written if the number of characters to write is less than or equal to count.
        //    If the number of characters to write is greater than count, these functions return -1 indicating that output has been truncated
        //
        //  The `_vsnwprintf` has a different behaviour versus the `vsnprintf` function and returns -1 on output string truncation (no an encoding error!),
        //  so we must call `_vsnwprintf` first time with an empty buffer and zero count to request the buffer size!
        //

        constexpr const size_t fixed_message_char_buf_size = sizeof(fixed_message_char_buf) / sizeof(fixed_message_char_buf[0]);
        const int num_written_chars = _vsnwprintf(fixed_message_char_buf, fixed_message_char_buf_size, fmt, vl);

        if (num_written_chars > 0 && num_written_chars < fixed_message_char_buf_size) {
            std::vector<wchar_t> char_buf;

            const int num_written_chars2 =
                _snwprintf(NULL, 0,
                    L"[%s] [%u] [%s] error: %s",
                    local_time_str.c_str(), GetCurrentProcessId(), module_char_buf, fixed_message_char_buf);

            char_buf.resize(num_written_chars2 + 1);

            _snwprintf(char_buf.data(), char_buf.size(),
                L"[%s] [%u] [%s] error: %s",
                local_time_str.c_str(), GetCurrentProcessId(), module_char_buf, fixed_message_char_buf);

            return std::wstring{ char_buf.data(), char_buf.size() > 0 ? char_buf.size() - 1 : 0 };
        }
        else if (num_written_chars >= -1) {
            std::vector<wchar_t> char_buf;
            std::vector<wchar_t> char_buf2;

            char_buf.resize(num_written_chars + 1);

            _vsnwprintf(char_buf.data(), char_buf.size(), fmt, vl);

            const int num_written_chars2 =
                _snwprintf(NULL, 0,
                    L"[%s] [%u] [%s] error: %s",
                    local_time_str.c_str(), GetCurrentProcessId(), module_char_buf, char_buf.data());

            char_buf2.resize(num_written_chars2 + 1);

            _snwprintf(char_buf2.data(), char_buf2.size(),
                L"[%s] [%u] [%s] error: %s",
                local_time_str.c_str(), GetCurrentProcessId(), module_char_buf, char_buf.data());

            return std::wstring{ char_buf2.data(), char_buf2.size() > 0 ? char_buf2.size() - 1 : 0 };
        }
        else {
            std::vector<wchar_t> char_buf;

            const int num_written_chars2 =
                _snwprintf(NULL, 0,
                    L"[%s] [%u] [%s] error: %s",
                    local_time_str.c_str(), GetCurrentProcessId(), module_char_buf, (wchar_t *)NULL);

            char_buf.resize(num_written_chars2 + 1);

            _snwprintf(char_buf.data(), char_buf.size(),
                L"[%s] [%u] [%s] error: %s",
                local_time_str.c_str(), GetCurrentProcessId(), module_char_buf, (wchar_t *)NULL);

            return std::wstring{ char_buf.data(), char_buf.size() > 0 ? char_buf.size() - 1 : 0 };
        }
    }

    inline std::string _format_stderr_message(const char * fmt, ...)
    {
        va_list vl;
        va_start(vl, fmt);
        const auto ret = _format_stderr_message(fmt, vl);
        va_end(vl);
        return ret;
    }

    inline std::wstring _format_stderr_message(const wchar_t * fmt, ...)
    {
        va_list vl;
        va_start(vl, fmt);
        const auto ret = _format_stderr_message(fmt, vl);
        va_end(vl);
        return ret;
    }

    inline void _print_stderr_message_va(const char * fmt, va_list vl)
    {
        char module_char_buf[256];
        char fixed_message_char_buf[256];

        // just in case
        module_char_buf[0] = '\0';
        fixed_message_char_buf[0] = '\0';

        const std::string local_time_str = _get_time_str(utility::tag_string{}, false);

        module_char_buf[0] = '\0';
        GetModuleFileNameA(NULL, module_char_buf, sizeof(module_char_buf) / sizeof(module_char_buf[0]));
        module_char_buf[sizeof(module_char_buf) / sizeof(module_char_buf[0]) - 1] = '\0'; // for Windows XP

        constexpr const size_t fixed_message_char_buf_size = sizeof(fixed_message_char_buf) / sizeof(fixed_message_char_buf[0]);
        const int num_written_chars = vsnprintf(fixed_message_char_buf, fixed_message_char_buf_size, fmt, vl);

        // CAUTION:
        //
        //  MSDN:
        //    The vsnprintf function returns the number of characters that are written, not counting the terminating null character.
        //    If the buffer size specified by count isn't sufficiently large to contain the output specified by format and argptr,
        //    the return value of vsnprintf is the number of characters that would be written, not counting the null character, if count were sufficiently large.
        //    If the return value is greater than count - 1, the output has been truncated. A return value of -1 indicates that an encoding error has occurred.
        //
        //  The `vsnprintf` returns -1 on encoding error and value greater than count if output string is truncated.
        //

        if (num_written_chars > 0 && num_written_chars < fixed_message_char_buf_size) {
            if (g_enable_conout_prints_buffering) {
                g_conout_prints_buf.push_back(_ConsoleOutput{ 2, std::string{ fixed_message_char_buf, size_t(num_written_chars) } });
            }

            fprintf(stderr, "[%s] [%u] [%s] error: %s",
                local_time_str.c_str(), GetCurrentProcessId(), module_char_buf, fixed_message_char_buf);
        }
        else if (num_written_chars >= -1) {
            std::vector<char> char_buf;

            char_buf.resize(num_written_chars + 1);

            vsnprintf(char_buf.data(), char_buf.size(), fmt, vl);

            if (g_enable_conout_prints_buffering) {
                g_conout_prints_buf.push_back(_ConsoleOutput{ 1, std::string{ char_buf.data(), char_buf.size() > 0 ? char_buf.size() - 1 : 0 } });
            }

            fprintf(stderr, "[%s] [%u] [%s] error: %s",
                local_time_str.c_str(), GetCurrentProcessId(), module_char_buf, char_buf.data());
        }
        else {
            fprintf(stderr, "[%s] [%u] [%s] error: %s",
                local_time_str.c_str(), GetCurrentProcessId(), module_char_buf, (char *)NULL); // encoding error
        }
    }

    inline void _print_stderr_message_va(const wchar_t * fmt, va_list vl)
    {
        wchar_t module_char_buf[256];
        wchar_t fixed_message_char_buf[256];

        // just in case
        module_char_buf[0] = L'\0';
        fixed_message_char_buf[0] = L'\0';

        const std::wstring local_time_str = _get_time_str(utility::tag_wstring{}, false);

        module_char_buf[0] = L'\0';
        GetModuleFileNameW(NULL, module_char_buf, sizeof(module_char_buf) / sizeof(module_char_buf[0]));
        module_char_buf[sizeof(module_char_buf) / sizeof(module_char_buf[0]) - 1] = L'\0'; // for Windows XP

        // CAUTION:
        //
        //  MSDN:
        //    Both _vsnprintf and _vsnwprintf functions return the number of characters written if the number of characters to write is less than or equal to count.
        //    If the number of characters to write is greater than count, these functions return -1 indicating that output has been truncated
        //
        //  The `_vsnwprintf` has a different behaviour versus the `vsnprintf` function and returns -1 on output string truncation (no an encoding error!),
        //  so we must call `_vsnwprintf` first time with an empty buffer and zero count to request the buffer size!
        //

        std::vector<wchar_t> char_buf;

        const int num_written_chars = _vsnwprintf(NULL, 0, fmt, vl);

        char_buf.resize(num_written_chars + 1);

        _vsnwprintf(char_buf.data(), char_buf.size(), fmt, vl);

        if (g_enable_conout_prints_buffering) {
            g_conout_prints_buf.push_back(_ConsoleOutput{ 1, std::wstring{ char_buf.data(), char_buf.size() > 0 ? char_buf.size() - 1 : 0 } });
        }
        
        fwprintf(stderr, L"[%s] [%u] [%s] error: %s",
            local_time_str.c_str(), GetCurrentProcessId(), module_char_buf, char_buf.data());
    }

    inline void _print_stderr_message(const char * fmt, ...)
    {
        va_list vl;
        va_start(vl, fmt);
        _print_stderr_message_va(fmt, vl);
        va_end(vl);
    }

    inline void _print_stderr_message(const wchar_t * fmt, ...)
    {
        va_list vl;
        va_start(vl, fmt);
        _print_stderr_message_va(fmt, vl);
        va_end(vl);
    }

    inline std::tstring _format_win_error_message(DWORD win_error, UINT langid = LANG_NEUTRAL)
    {
        std::tstring ret;

        LPSTR win_error_msg_buf_a = nullptr;
        LPWSTR win_error_msg_buf_w = nullptr;

        [&]() { __try {
            [&]() {
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
#ifdef _UNICODE
                    ret = _format_stderr_message(L"win32: \"%s\"\n", win_error_msg_buf_w);
#else
                    std::vector<char> char_buf;

                    int num_chars = WideCharToMultiByte(cp_out, 0, win_error_msg_buf_w, -1, NULL, 0, NULL, NULL);
                    if (num_chars) {
                        char_buf.resize(size_t(num_chars) + sizeof(char_buf[0]));
                        num_chars = WideCharToMultiByte(cp_out, 0, win_error_msg_buf_w, -1, char_buf.data(), (std::min)((size_t)num_chars, char_buf.size()), NULL, NULL);
                    }

                    if (num_chars) {
                        ret = _format_stderr_message("win32: \"%s\"\n", char_buf.data());
                    }
#endif
                }
                else {
                    FormatMessageA(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
                        NULL, win_error, MAKELANGID(langid, SUBLANG_DEFAULT), (LPSTR)&win_error_msg_buf_a, 0, NULL);
#ifdef _UNICODE
                    std::vector<wchar_t> char_buf;

                    int num_chars = MultiByteToWideChar(cp_out, 0, win_error_msg_buf_a, -1, NULL, 0);
                    if (num_chars) {
                        char_buf.resize(size_t(num_chars) + sizeof(char_buf[0]));
                        num_chars = MultiByteToWideChar(cp_out, 0, win_error_msg_buf_a, -1, char_buf.data(), (std::min)((size_t)num_chars, char_buf.size()));
                    }

                    if (num_chars) {
                        ret = _format_stderr_message(L"win32: \"%s\"\n", char_buf.data());
                    }
#else
                    ret = _format_stderr_message("win32: \"%s\"\n", win_error_msg_buf_a);
#endif
                }
            }();
        }
        __finally {
            if (win_error_msg_buf_a) {
                LocalFree(win_error_msg_buf_a);
            }
            if (win_error_msg_buf_w) {
                LocalFree(win_error_msg_buf_w);
            }
        } }();

        return ret;
    }

    inline void _print_win_error_message(DWORD win_error, UINT langid = LANG_NEUTRAL)
    {
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
                _print_stderr_message(L"win32: \"%s\"\n", win_error_msg_buf_w);
            }
            else {
                FormatMessageA(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
                    NULL, win_error, MAKELANGID(langid, SUBLANG_DEFAULT), (LPSTR)&win_error_msg_buf_a, 0, NULL);
                _print_stderr_message("win32: \"%s\"\n", win_error_msg_buf_a);
            }
        }
        __finally {
            if (win_error_msg_buf_a) {
                LocalFree(win_error_msg_buf_a);
            }
            if (win_error_msg_buf_w) {
                LocalFree(win_error_msg_buf_w);
            }
        } }();
    }

    inline void _print_shell_exec_error_message(DWORD shell_error, const SHELLEXECUTEINFO & sei)
    {
        switch (shell_error) {
        case 0:
            _print_stderr_message(_T("ShellExecute: operating system is out of memory or resources: error=0x%08X (%d) file=\"%s\" params=\"%s\"\n"),
                shell_error, shell_error, sei.lpFile, sei.lpParameters);
            break;
        case SE_ERR_FNF:
            _print_stderr_message(_T("ShellExecute: file is not found: error=0x%08X (%d) file=\"%s\" params=\"%s\"\n"),
                shell_error, shell_error, sei.lpFile, sei.lpParameters);
            break;
        case SE_ERR_PNF:
            _print_stderr_message(_T("ShellExecute: path is not found: error=0x%08X (%d) file=\"%s\" params=\"%s\"\n"),
                shell_error, shell_error, sei.lpFile, sei.lpParameters);
            break;
        case SE_ERR_ACCESSDENIED:
            _print_stderr_message(_T("ShellExecute: access denied: error=0x%08X (%d) file=\"%s\" params=\"%s\"\n"),
                shell_error, shell_error, sei.lpFile, sei.lpParameters);
            break;
        case SE_ERR_OOM:
            _print_stderr_message(_T("ShellExecute: out of memory: error=0x%08X (%d) file=\"%s\" params=\"%s\"\n"),
                shell_error, shell_error, sei.lpFile, sei.lpParameters);
            break;
        case SE_ERR_DLLNOTFOUND:
            _print_stderr_message(_T("ShellExecute: dynamic-link library is not found: error=0x%08X (%d) file=\"%s\" params=\"%s\"\n"),
                shell_error, shell_error, sei.lpFile, sei.lpParameters);
            break;
        case SE_ERR_SHARE:
            _print_stderr_message(_T("ShellExecute: cannot share an open file: error=0x%08X (%d) file=\"%s\" params=\"%s\"\n"),
                shell_error, shell_error, sei.lpFile, sei.lpParameters);
            break;
        case SE_ERR_ASSOCINCOMPLETE:
            _print_stderr_message(_T("ShellExecute: file association information is not complete: error=0x%08X (%d) file=\"%s\" params=\"%s\"\n"),
                shell_error, shell_error, sei.lpFile, sei.lpParameters);
            break;
        case SE_ERR_DDETIMEOUT:
            _print_stderr_message(_T("ShellExecute: DDE operation is timed out: error=0x%08X (%d) file=\"%s\" params=\"%s\"\n"),
                shell_error, shell_error, sei.lpFile, sei.lpParameters);
            break;
        case SE_ERR_DDEFAIL:
            _print_stderr_message(_T("ShellExecute: DDE operation is failed: error=0x%08X (%d) file=\"%s\" params=\"%s\"\n"),
                shell_error, shell_error, sei.lpFile, sei.lpParameters);
            break;
        case SE_ERR_DDEBUSY:
            _print_stderr_message(_T("ShellExecute: DDE operation is busy: error=0x%08X (%d) file=\"%s\" params=\"%s\"\n"),
                shell_error, shell_error, sei.lpFile, sei.lpParameters);
            break;
        case SE_ERR_NOASSOC:
            _print_stderr_message(_T("ShellExecute: file association is not available: error=0x%08X (%d) file=\"%s\" params=\"%s\"\n"),
                shell_error, shell_error, sei.lpFile, sei.lpParameters);
            break;
        default:
            _print_stderr_message(_T("ShellExecute: unknown error: error=0x%08X (%d) file=\"%s\" params=\"%s\"\n"),
                shell_error, shell_error, sei.lpFile, sei.lpParameters);
        }
    }

    inline std::tstring _replace_strings(std::tstring str, const std::tstring & from, std::tstring to)
    {
        size_t start_pos = 0;

        while ((start_pos = str.find(from, start_pos)) != std::tstring::npos) {
            str.replace(start_pos, from.length(), to);
            start_pos += to.length();
        }

        return str;
    }

    template <typename Functor>
    inline std::tstring _replace_strings(std::tstring str, const std::tstring & from, Functor && to_functor)
    {
        size_t index = 0;
        size_t start_pos = 0;

        while ((start_pos = str.find(from, start_pos)) != std::tstring::npos) {
            auto to = std::forward<Functor>(to_functor)(index, start_pos);
            str.replace(start_pos, from.length(), to);
            start_pos += to.length();
            index++;
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

        str_eval_buf.reserve(str.length() + (str.length() + 1) / 2 + 1); // compensate string expansion for heximal-to-decimal number conversion

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
                                const auto decimal_value = tstrtoul(digits_buf.data(), &stop_scan_char_ptr, 16);
                                if (errno != ERANGE) {
                                    digits_eval_buf.resize(10 + 1); // max decimal digits
                                    digits_eval_buf[0] = _T('\0');
                                    ultot(decimal_value, digits_eval_buf.data(), 10);
                                    const size_t digits_num = tstrlen(digits_eval_buf.data());
                                    str_eval_buf.resize(str_size + digits_num);
                                    tstrcat(&str_eval_buf[str_size], digits_eval_buf.data());
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
                                const auto decimal_value = tstrtoul(digits_buf.data(), &stop_scan_char_ptr, 8);
                                if (errno != ERANGE) {
                                    digits_eval_buf.resize(10 + 1); // max decimal digits
                                    digits_eval_buf[0] = _T('\0');
                                    ultot(decimal_value, digits_eval_buf.data(), 10);
                                    const size_t digits_num = tstrlen(digits_eval_buf.data());
                                    str_eval_buf.resize(str_size + digits_num);
                                    tstrcat(&str_eval_buf[str_size], digits_eval_buf.data());
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
            const auto decimal_value = tstrtoul(digits_buf.data(), &stop_scan_char_ptr, 16);
            if (errno != ERANGE) {
                digits_eval_buf.resize(10 + 1); // max decimal digits
                digits_eval_buf[0] = _T('\0');
                ultot(decimal_value, digits_eval_buf.data(), 10);
                const size_t digits_num = tstrlen(digits_eval_buf.data());
                str_eval_buf.resize(str_size + digits_num);
                tstrcat(&str_eval_buf[str_size], digits_eval_buf.data());
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
            const auto decimal_value = tstrtoul(digits_buf.data(), &stop_scan_char_ptr, 8);
            if (errno != ERANGE) {
                digits_eval_buf.resize(10 + 1); // max decimal digits
                digits_eval_buf[0] = _T('\0');
                ultot(decimal_value, digits_eval_buf.data(), 10);
                const size_t digits_num = tstrlen(digits_eval_buf.data());
                str_eval_buf.resize(str_size + digits_num);
                tstrcat(&str_eval_buf[str_size], digits_eval_buf.data());
                str_size += digits_num;
            }
        }

        // resize on overflow
        if (str_size + 1 > str_eval_buf.size()) {
            str_eval_buf.resize(str_size + 1);
        }

        str_eval_buf[str_size] = _T('\0');

        return std::tstring(str_eval_buf.data(), &str_eval_buf[str_size]);
    }
}

#endif
