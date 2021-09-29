#ifndef __COMMON_HPP__
#define __COMMON_HPP__

#include <version.hpp>

#include <WinBase.h>
#include <WinNT.h>

#include <string>
#include <vector>
#include <deque>
#include <locale>
#include <algorithm>
#include <cstdio>
#include <cstdarg>
#include <ctime>
#include <atomic>
#include <iostream>
#include <limits>

#include <assert.h>
#include <stdint.h>
#include <ShellAPI.h>

#include <stdio.h>
#include <conio.h>
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

#include "tacklelib/utility/platform.hpp"
#include "tacklelib/utility/type_identity.hpp"
#include "tacklelib/utility/string_identity.hpp"
#include "tacklelib/utility/type_traits.hpp"
#include "tacklelib/utility/addressof.hpp"

#include "tacklelib/tackle/explicit_type.hpp"

#define MAX_ENV_BUF_SIZE 32767

#define SYNC_STD_STREAMS_WITH_STDIO 0

#define USE_WIN32_CONSOLE_DEVICE_PATH 1

#define if_break switch(0) case 0: default: if

#define STDIN_FILENO    0
#define STDOUT_FILENO   1
#define STDERR_FILENO   2

#define STATUS_SUCCESS  0x00000000

// Details:
//
//  https://docs.microsoft.com/en-us/windows/win32/fileio/naming-a-file#win32-device-namespaces
//
#if USE_WIN32_CONSOLE_DEVICE_PATH
#   define CONIN_FILE       "\\\\.\\CON"
#   define CONOUT_FILE      "\\\\.\\CON"
#else
#   define CONIN_FILE       "CONIN$"
#   define CONOUT_FILE      "CONOUT$"
#endif

#ifdef _CONSOLE
#   define IF_CONSOLE_APP(t, f) t
#else
#   define IF_CONSOLE_APP(t, f) f
#endif

#ifndef _WIN32_WINNT_WIN8
#   define _WIN32_WINNT_WIN8                   0x0602
#endif

#if _WIN32_WINNT < _WIN32_WINNT_WIN8

typedef struct _FILE_ID_128 {
    BYTE  Identifier[16];
} FILE_ID_128, *PFILE_ID_128;

typedef struct _FILE_ID_INFO {
    ULONGLONG VolumeSerialNumber;
    FILE_ID_128 FileId;
} FILE_ID_INFO, *PFILE_ID_INFO;


static constexpr FILE_INFO_BY_HANDLE_CLASS FileIdInfo = FILE_INFO_BY_HANDLE_CLASS(18);

#endif

#ifndef ENABLE_VIRTUAL_TERMINAL_PROCESSING
#define ENABLE_VIRTUAL_TERMINAL_PROCESSING 0x0004
#endif


namespace {
    enum _error
    {
        err_none            = 0,

        err_unspecified     = -255,

        err_seh_exception   = -254,

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

    struct _WinVer
    {
        uint_t major;
        uint_t minor;
        uint_t build;
    };

    struct _FileId
    {
        enum {
            fileid_unknown,
            fileid_index64,
            fileid_index128
        } fileid_type;

        union {
            struct {
                DWORD dwVolumeSerialNumber;
                DWORD nFileIndexHigh;
                DWORD nFileIndexLow;
            } index64;

            struct {
                ULONGLONG   VolumeSerialNumber;
                FILE_ID_128 FileId;
            } index128;
        };

        _FileId() :
            fileid_type(fileid_unknown)
        {
        }

        _FileId(DWORD dwVolumeSerialNumber, DWORD nFileIndexHigh, DWORD nFileIndexLow) :
            fileid_type(fileid_index64)
        {
            index64.dwVolumeSerialNumber = dwVolumeSerialNumber;
            index64.nFileIndexHigh = nFileIndexHigh;
            index64.nFileIndexLow = nFileIndexLow;
        }

        _FileId(ULONGLONG VolumeSerialNumber, const FILE_ID_128 & FileId) :
            fileid_type(fileid_index128)
        {
            index128.VolumeSerialNumber = VolumeSerialNumber;
            index128.FileId = FileId;
        }

        ~_FileId()
        {
        }

        std::tstring to_tstring(TCHAR separator = _T('-')) const;
    };

    struct _StdHandlesState
    {
        _StdHandlesState() :
            is_stdin_inheritable(-1), is_stdout_inheritable(-1), is_stderr_inheritable(-1),
            stdin_handle_flags(0), stdout_handle_flags(0), stderr_handle_flags(0),
            has_stdin_console_mode(false), has_stdout_console_mode(false), has_stderr_console_mode(false),
            stdin_handle_mode(0), stdout_handle_mode(0), stderr_handle_mode(0),
            stdin_last_error(0), stdout_last_error(0), stderr_last_error(0)
        {
        }

        void save_stdin_state(HANDLE stdin_handle);
        void save_stdout_state(HANDLE stdout_handle);
        void save_stderr_state(HANDLE stderr_handle);

        void restore_stdin_state(HANDLE stdin_handle, bool restore_console_mode_defaults) const;
        void restore_stdout_state(HANDLE stdout_handle, bool restore_console_mode_defaults) const;
        void restore_stderr_state(HANDLE stderr_handle, bool restore_console_mode_defaults) const;

        int is_stdin_inheritable;
        int is_stdout_inheritable;
        int is_stderr_inheritable;

        DWORD stdin_handle_flags;
        DWORD stdout_handle_flags;
        DWORD stderr_handle_flags;

        bool has_stdin_console_mode;
        bool has_stdout_console_mode;
        bool has_stderr_console_mode;

        DWORD stdin_handle_mode;
        DWORD stdout_handle_mode;
        DWORD stderr_handle_mode;

        mutable DWORD stdin_last_error;
        mutable DWORD stdout_last_error;
        mutable DWORD stderr_last_error;
    };

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

        _AnyString(const _AnyString & anystr);
        _AnyString(_AnyString && anystr);

        ~_AnyString();

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

    struct _EnumConsoleWindowsProcData
    {
        TCHAR tchar_buf[256];
        std::vector<HWND> console_window_handles_arr;
    };

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

    //struct _to_lower_with_codepage
    //{
    //    _to_lower_with_codepage(unsigned int code_page_) :
    //        code_page(code_page_)
    //    {
    //    }

    //    std::tstring::value_type operator()(std::tstring::value_type ch_)
    //    {
    //        return _to_lower(ch_, code_page);
    //    }

    //    unsigned int code_page;
    //};


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


    inline std::tstring _FileId::to_tstring(TCHAR separator) const
    {
        std::tstring ret;

        switch (fileid_type)
        {
        case fileid_index128:
            for (int i = 0; i < sizeof(index128.VolumeSerialNumber); i++) {
                ret += g_hextbl[((uint8_t*)&index128.VolumeSerialNumber)[i]];
            }
            ret += separator;
            for (int i = 0; i < sizeof(index128.FileId); i++) {
                ret += g_hextbl[((uint8_t*)&index128.FileId)[i]];
            }
            break;
        case fileid_index64:
            for (int i = 0; i < sizeof(index64.dwVolumeSerialNumber); i++) {
                ret += g_hextbl[((uint8_t*)&index64.dwVolumeSerialNumber)[i]];
            }
            ret += separator;
            for (int i = 0; i < sizeof(index64.nFileIndexHigh); i++) {
                ret += g_hextbl[((uint8_t*)&index64.nFileIndexHigh)[i]];
            }
            ret += separator;
            for (int i = 0; i < sizeof(index64.nFileIndexLow); i++) {
                ret += g_hextbl[((uint8_t*)&index64.nFileIndexLow)[i]];
            }
            break;
        }

        return ret;
    }

    template <typename T>
    inline T(&make_singular_array(T & ref))[1]
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

    inline bool _is_valid_handle(HANDLE handle)
    {
        return handle > 0 && handle != INVALID_HANDLE_VALUE;
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


    inline void _StdHandlesState::save_stdin_state(HANDLE stdin_handle)
    {
        stdin_last_error = 0;
        stdin_handle_flags = 0;
        has_stdin_console_mode = false;

        if (GetHandleInformation(stdin_handle, &stdin_handle_flags)) {
            is_stdin_inheritable = (stdin_handle_flags & HANDLE_FLAG_INHERIT) ? 1 : 0;
        }

        SetLastError(0);
        if (GetConsoleMode(stdin_handle, &stdin_handle_mode)) {
            has_stdin_console_mode = true;
        }
        else stdin_last_error = GetLastError();
    }

    inline void _StdHandlesState::save_stdout_state(HANDLE stdout_handle)
    {
        stdout_last_error = 0;
        stdout_handle_flags = 0;
        has_stdout_console_mode = false;

        if (GetHandleInformation(stdout_handle, &stdout_handle_flags)) {
            is_stdout_inheritable = (stdout_handle_flags & HANDLE_FLAG_INHERIT) ? 1 : 0;
        }

        SetLastError(0);
        if (GetConsoleMode(stdout_handle, &stdout_handle_mode)) {
            has_stdout_console_mode = true;
        }
        else stdout_last_error = GetLastError();
    }

    inline void _StdHandlesState::save_stderr_state(HANDLE stderr_handle)
    {
        stderr_last_error = 0;
        stderr_handle_flags = 0;
        has_stderr_console_mode = false;

        if (GetHandleInformation(stderr_handle, &stderr_handle_flags)) {
            is_stderr_inheritable = (stderr_handle_flags & HANDLE_FLAG_INHERIT) ? 1 : 0;
        }

        SetLastError(0);
        if (GetConsoleMode(stderr_handle, &stderr_handle_mode)) {
            has_stderr_console_mode = true;
        }
        else stderr_last_error = GetLastError();
    }

    inline void _StdHandlesState::restore_stdin_state(HANDLE stdin_handle, bool restore_console_mode_defaults) const
    {
        stdin_last_error = 0;

        if (GetFileType(stdin_handle) == FILE_TYPE_CHAR) {
            if (has_stdin_console_mode) {
                SetLastError(0);
                SetConsoleMode(stdin_handle, stdin_handle_mode);
                stdin_last_error = GetLastError();
            }
            else if (restore_console_mode_defaults) {
                SetLastError(0);
                SetConsoleMode(stdin_handle, ENABLE_PROCESSED_INPUT | ENABLE_LINE_INPUT | ENABLE_ECHO_INPUT | ENABLE_INSERT_MODE | ENABLE_EXTENDED_FLAGS | ENABLE_AUTO_POSITION); // 423
                stdin_last_error = GetLastError();
            }
        }
    }

    inline void _StdHandlesState::restore_stdout_state(HANDLE stdout_handle, bool restore_console_mode_defaults) const
    {
        stdout_last_error = 0;

        if (GetFileType(stdout_handle) == FILE_TYPE_CHAR) {
            if (has_stdout_console_mode) {
                SetLastError(0);
                SetConsoleMode(stdout_handle, stdout_handle_mode);
                stdout_last_error = GetLastError();
            }
            else if (restore_console_mode_defaults) {
                SetLastError(0);
                SetConsoleMode(stdout_handle, ENABLE_PROCESSED_OUTPUT | ENABLE_WRAP_AT_EOL_OUTPUT); // 3
                stdout_last_error = GetLastError();
            }
        }
    }

    inline void _StdHandlesState::restore_stderr_state(HANDLE stderr_handle, bool restore_console_mode_defaults) const
    {
        stderr_last_error = 0;

        if (GetFileType(stderr_handle) == FILE_TYPE_CHAR) {
            if (has_stderr_console_mode) {
                SetLastError(0);
                SetConsoleMode(stderr_handle, stderr_handle_mode);
                stderr_last_error = GetLastError();
            }
            else if (restore_console_mode_defaults) {
                SetLastError(0);
                SetConsoleMode(stderr_handle, ENABLE_PROCESSED_OUTPUT | ENABLE_WRAP_AT_EOL_OUTPUT); // 3
                stderr_last_error = GetLastError();
            }
        }
    }


    inline _AnyString::_AnyString(const _AnyString & anystr) :
        is_wstr(anystr.is_wstr)
    {
        if (is_wstr) {
            _construct(wstr, anystr.wstr);
        }
        else {
            _construct(astr, anystr.astr);
        }
    }

    inline _AnyString::_AnyString(_AnyString && anystr) :
        is_wstr(anystr.is_wstr)
    {
        if (is_wstr) {
            _construct(wstr, std::move(anystr.wstr));
        }
        else {
            _construct(astr, std::move(anystr.astr));
        }
    }

    inline _AnyString::~_AnyString()
    {
        if (is_wstr) {
            _destruct(&wstr);
        }
        else {
            _destruct(&astr);
        }
    }


    inline bool _is_equal_fileid(const _FileId & fileid0, const _FileId & fileid1)
    {
        switch (fileid0.fileid_type)
        {
        case _FileId::fileid_index128:
            if (fileid1.fileid_type == _FileId::fileid_index128) {
                return fileid0.index128.VolumeSerialNumber == fileid1.index128.VolumeSerialNumber &&
                    !memcmp(fileid0.index128.FileId.Identifier, fileid1.index128.FileId.Identifier, sizeof(fileid0.index128.FileId.Identifier));
            }
            break;
        case _FileId::fileid_index64:
            if (fileid1.fileid_type == _FileId::fileid_index64) {
                return fileid0.index64.dwVolumeSerialNumber == fileid1.index64.dwVolumeSerialNumber &&
                    fileid0.index64.nFileIndexHigh == fileid1.index64.nFileIndexHigh &&
                    fileid0.index64.nFileIndexLow == fileid1.index64.nFileIndexLow;
            }
            break;
        }

        return false;
    }

    inline void _get_win_ver(_WinVer & win_ver)
    {
        // CAUTION:
        //  Has effect only for Windows version up to 8.1 (read MSDN documentation)
        //
        const DWORD dwVersion = GetVersion();

        win_ver.major = (DWORD)(LOBYTE(LOWORD(dwVersion)));
        win_ver.minor = (DWORD)(HIBYTE(LOWORD(dwVersion)));

        if (dwVersion < 0x80000000) {
            win_ver.build = (DWORD)(HIWORD(dwVersion));
        }
        else {
            win_ver.build = 0;
        }

        const bool is_os_windows_xp_or_lower = win_ver.major < 6;

        if (!is_os_windows_xp_or_lower) {
            // Based on: https://stackoverflow.com/questions/36543301/detecting-windows-10-version/36545162#36545162
            //

            typedef LONG NTSTATUS, *PNTSTATUS;

            typedef NTSTATUS (WINAPI* RtlGetVersionPtr)(PRTL_OSVERSIONINFOW);

            HMODULE ntdll_hmodule = ::GetModuleHandleW(L"ntdll.dll");
            if (ntdll_hmodule) {
                RtlGetVersionPtr RtlGetVersion = (RtlGetVersionPtr)::GetProcAddress(ntdll_hmodule, "RtlGetVersion");
                if (RtlGetVersion != nullptr) {
                    RTL_OSVERSIONINFOW rovi{};
                    rovi.dwOSVersionInfoSize = sizeof(rovi);
                    if (STATUS_SUCCESS == RtlGetVersion(&rovi)) {
                        win_ver.major = rovi.dwMajorVersion;
                        win_ver.minor = rovi.dwMinorVersion;
                        win_ver.build = rovi.dwBuildNumber;
                    }
                }
            }
        }
    }

    // NOTE:
    //  Deprecated because C++11 standard does not support unicode code page in locales together with
    //  lowercase/uppercase functionality which is not available without a knowledge of language per character.
    //

    //std::tstring::value_type _to_lower(std::tstring::value_type ch, unsigned int code_page)
    //{
    //    if (code_page) {
    //        // NOTE: increases executable on + ~200KB
    //        return std::use_facet<std::ctype<std::tstring::value_type> >(std::locale(std::string(".") + std::to_string(code_page))).tolower(ch);
    //    }

    //    // NOTE: w/o above code increases executable on + ~60KB
    //    return std::use_facet<std::ctype<std::tstring::value_type> >(std::locale()).tolower(ch);
    //}

    // code_page=0 for default std::locale
    //std::tstring _to_lower(std::tstring str, unsigned int code_page)
    //{
    //    std::tstring res;
    //    res.resize(str.size());
    //    std::transform(str.begin(), str.end(), res.begin(), _to_lower_with_codepage(code_page));
    //    return res;
    //}

    //uint64_t _hash_string_to_u64(std::tstring str, unsigned int code_page)
    //{
    //    uint64_t res = 10000019;
    //    const size_t str_len = str.length();
    //    for (size_t i = 0; i < str_len; i += 2)
    //    {
    //        uint64_t merge = _to_lower(str[i], code_page) * 65536 + (i + 1 < str_len ? _to_lower(str[i + 1], code_page) : 0);
    //        res = res * 8191 + merge; // unchecked arithmetic
    //    }
    //    return res;
    //}

    uint64_t _hash_string_to_u64(std::tstring str)
    {
        uint64_t res = 10000019;
        const size_t str_len = str.length();
        for (size_t i = 0; i < str_len; i += 2)
        {
            uint64_t merge = str[i] * 65536 + (i + 1 < str_len ? str[i + 1] : 0);
            res = res * 8191 + merge; // unchecked arithmetic
        }
        return res;
    }

    _FileId _get_fileid_by_file_handle(HANDLE file_handle, const _WinVer & win_ver)
    {
        if (win_ver.major > 6 || win_ver.major == 6 && win_ver.minor >= 2) {
            FILE_ID_INFO fileid_info{};
            if (GetFileInformationByHandleEx(file_handle, FileIdInfo, &fileid_info, sizeof(fileid_info))) {
                return _FileId{ fileid_info.VolumeSerialNumber, fileid_info.FileId };
            }
        }
        else {
            BY_HANDLE_FILE_INFORMATION fileid_info{};
            if (GetFileInformationByHandle(file_handle, &fileid_info)) {
                return _FileId{ fileid_info.dwVolumeSerialNumber, fileid_info.nFileIndexHigh, fileid_info.nFileIndexLow };
            }
        }

        return _FileId{ 0, 0, 0 };
    }

    inline bool _is_winnt()
    {
        OSVERSIONINFO osv;
        osv.dwOSVersionInfoSize = sizeof(osv);
        GetVersionEx(&osv);
        return (osv.dwPlatformId == VER_PLATFORM_WIN32_NT);
    }

    inline bool _set_crt_std_handle(HANDLE file_handle, tackle::explicit_int from_fileno, tackle::explicit_int to_fileno, tackle::explicit_int mode_flags,
                                    tackle::explicit_bool duplicate_input_handle, tackle::explicit_bool inherit_handle_on_duplicate = true)
    {
        if (!_is_valid_handle(file_handle)) {
            if (from_fileno >= 0) {
                file_handle = (HANDLE)_get_osfhandle(from_fileno);
                if (!_is_valid_handle(file_handle)) {
                    return false;
                }
            }
            else {
                return false;
            }
        }

        const int mode_flags_ = mode_flags >= 0 ? mode_flags : _O_BINARY;

        // CAUTION:
        //  Based on: `_open_osfhandle` : https://docs.microsoft.com/en-us/cpp/c-runtime-library/reference/open-osfhandle
        //    The _open_osfhandle call transfers ownership of the Win32 file handle to the file descriptor.
        //    To close a file opened by using _open_osfhandle, call _close. The underlying OS file handle is also closed by a call to _close.
        //    Don't call the Win32 function CloseHandle on the original handle.
        //    If the file descriptor is owned by a FILE * stream, then a call to fclose closes both the file descriptor and the underlying handle.
        //    In this case, don't call _close on the file descriptor or CloseHandle on the original handle.
        //
        // So, we must duplicate handle from here and return the duplicated one if want to own the handle.
        //

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
        //  In that case you must use a direct number, for example, `STDOUT_FILENO` instead of `_fileno(stdout)`, otherwise all sequenced calls will fail, which means
        //  the `_close(fd)` after failed `_dup(fd, ...)` will close the handle w/o duplication!
        //

        // CAUTION:
        //  The `_open_osfhandle` would ignore `SetStdHandle` if all 3 descriptors has already been allocated.
        //

        // CAUTION:
        //  The `_dup2` may fail with -1 return code in case if can not duplicate a handle and it happens
        //  when the handle has been opened from the `CONIN$` or `CONOUT$` of `\\.\CON` file.
        //

        // CAUTION:
        //  The input handle can be already registered in the CRT, otherwise the `_dup2` function will close it before the duplication.
        //  
        //

        // CAUTION:
        //  The CRT `_dup2` and `freopen` functions does ignore call to `SetStdHandle` in case of not console (GUI) application!
        //


        HANDLE file_handle_crt = file_handle;
        HANDLE registered_stdin_handle = INVALID_HANDLE_VALUE;
        HANDLE registered_stdout_handle = INVALID_HANDLE_VALUE;
        HANDLE registered_stderr_handle = INVALID_HANDLE_VALUE;

        switch (to_fileno)
        {
        case STDIN_FILENO:
        case STDOUT_FILENO:
        case STDERR_FILENO:
        {
            __try {
                if (duplicate_input_handle) {
                    if (!DuplicateHandle(GetCurrentProcess(), file_handle, GetCurrentProcess(), &file_handle_crt, 0,
                        inherit_handle_on_duplicate ? TRUE : FALSE, DUPLICATE_SAME_ACCESS)) {
                        return false;
                    }
                }

                const int fd = _open_osfhandle((intptr_t)file_handle_crt, mode_flags_ | (to_fileno == STDIN_FILENO ? _O_RDONLY : _O_WRONLY));
                if (fd != to_fileno) {
                    if (_dup2(fd, to_fileno) >= 0) {
                        _close(fd);
                    }

#ifndef _CONSOLE
                    registered_stdin_handle = (HANDLE)_get_osfhandle(to_fileno);
#endif
                }

            }
            __finally {
                _setmode(to_fileno, mode_flags_);

#ifndef _CONSOLE
                // we must to register it, because CRT does ignore that
                switch (to_fileno)
                {
                case STDIN_FILENO:
                    if (_is_valid_handle(registered_stdin_handle)) {
                        SetStdHandle(STD_INPUT_HANDLE, registered_stdin_handle);
                    }
                    break;
                case STDOUT_FILENO:
                    if (_is_valid_handle(registered_stdout_handle)) {
                        SetStdHandle(STD_OUTPUT_HANDLE, registered_stdout_handle);
                    }
                    break;
                case STDERR_FILENO:
                    if (_is_valid_handle(registered_stderr_handle)) {
                        SetStdHandle(STD_ERROR_HANDLE, registered_stderr_handle);
                    }
                    break;
                }
#endif
            }
        } break;

        default:
            return false;
        }

        return true;
    }

    inline void _detach_stdin()
    {
        // WORKAROUND:
        //  If `_fileno` return negative value, then `fclose` won't call `_close` on associated descriptor, so
        //  we have to do it directly.
        //

        const int stdin_fileno = _fileno(stdin);
        fclose(stdin);
        if (stdin_fileno < 0) {
            _close(STDIN_FILENO);
        }
    }

    inline void _detach_stdout()
    {
        // WORKAROUND:
        //  If `_fileno` return negative value, then `fclose` won't call `_close` on associated descriptor, so
        //  we have to do it directly.
        //

        const int stdout_fileno = _fileno(stdout);
        fclose(stdout);
        if (stdout_fileno < 0) {
            _close(STDOUT_FILENO);
        }
    }

    inline void _detach_stderr()
    {
        // WORKAROUND:
        //  If `_fileno` return negative value, then `fclose` won't call `_close` on associated descriptor, so
        //  we have to do it directly.
        //

        const int stderr_fileno = _fileno(stderr);
        fclose(stderr);
        if (stderr_fileno < 0) {
            _close(STDERR_FILENO);
        }
    }

    inline bool _attach_stdin_from_console(bool set_std_handle, bool inherit_handle)
    {
        // CAUTION
        //  We can not use `_fileno` function in case of duplication into a target CRT standard handle because of instable results.
        //  The `STDIN_FILENO`/`STDOUT_FILENO`/`STDERR_FILENO` is used instead.
        //

        // CAUTION:
        //  The CRT `_dup2` and `freopen` function avoids call to `SetStdHandle` in case of GUI (not console) application!
        //

        // CAUTION:
        //  We should not close a character device handle, otherwise another process in process inheritance tree may lose the handle buffer to continue interact with it.
        //

        tfreopen(_T(CONIN_FILE), _T("rb"), stdin);

        if (set_std_handle) {
            const int stdin_fileno = _fileno(stdin);
            if (stdin_fileno >= 0) {
                const HANDLE registered_stdin_handle = (HANDLE)_get_osfhandle(stdin_fileno);
                if (_is_valid_handle(registered_stdin_handle)) {
                    SetStdHandle(STD_INPUT_HANDLE, registered_stdin_handle);
                }
            }
        }

        return true;
    }

    inline bool _attach_stdout_from_console(bool set_std_handle, bool inherit_handle)
    {
        // CAUTION
        //  We must call `freopen` to reinitialize FILE* object, otherwise `_fileno` function will continue return negative values on standard handles and
        //  would be partially synchronized with the reopened Win32 API standard handle.
        //

        // CAUTION:
        //  The CRT `_dup2` and `freopen` function avoids call to `SetStdHandle` in case of GUI (not console) application!
        //

        // CAUTION:
        //  We should not close a character device handle, otherwise another process in process inheritance tree may lose the handle buffer to continue interact with it.
        //

        tfreopen(_T(CONOUT_FILE), _T("wb"), stdout);

        if (set_std_handle) {
            const int stdout_fileno = _fileno(stdout);
            if (stdout_fileno >= 0) {
                const HANDLE registered_stdout_handle = (HANDLE)_get_osfhandle(stdout_fileno);
                if (_is_valid_handle(registered_stdout_handle)) {
                    SetStdHandle(STD_OUTPUT_HANDLE, registered_stdout_handle);
                }
            }
        }

        return true;
    }

    inline bool _attach_stderr_from_console(bool set_std_handle, bool inherit_handle)
    {
        // CAUTION
        //  We must call `freopen` to reinitialize FILE* object, otherwise `_fileno` function will continue return negative values on standard handles and
        //  would be partially synchronized with the reopened Win32 API standard handle.
        //

        // CAUTION:
        //  The CRT `_dup2` and `freopen` function avoids call to `SetStdHandle` in case of GUI (not console) application!
        //

        // CAUTION:
        //  We should not close a character device handle, otherwise another process in process inheritance tree may lose the handle buffer to continue interact with it.
        //

        tfreopen(_T(CONOUT_FILE), _T("wb"), stderr);

        if (set_std_handle) {
            const int stderr_fileno = _fileno(stderr);
            if (stderr_fileno >= 0) {
                const HANDLE registered_stderr_handle = (HANDLE)_get_osfhandle(stderr_fileno);
                if (_is_valid_handle(registered_stderr_handle)) {
                    SetStdHandle(STD_ERROR_HANDLE, registered_stderr_handle);
                }
            }
        }

        return true;
    }

    inline bool _duplicate_stdout_to_stderr(bool set_std_handle, bool inherit_handle)
    {
        if (!_attach_stderr_from_console(set_std_handle, inherit_handle)) {
            return false;
        }

        // duplicate to duplicate console mode
        const int stdout_fileno = _fileno(stdout);
        const int stderr_fileno = _fileno(stderr);

        return _dup2(stdout_fileno, stderr_fileno) >= 0;
    }

    inline bool _duplicate_stderr_to_stdout(bool set_std_handle, bool inherit_handle)
    {
        if (!_attach_stdout_from_console(set_std_handle, inherit_handle)) {
            return false;
        }

        // duplicate to duplicate console mode
        const int stdout_fileno = _fileno(stdout);
        const int stderr_fileno = _fileno(stderr);

        return _dup2(stderr_fileno, stdout_fileno) >= 0;
    }

    inline HANDLE _create_conin_handle(bool inherit_handle)
    {
        SECURITY_ATTRIBUTES sa{};

        sa.nLength = sizeof(sa);
        sa.bInheritHandle = inherit_handle ? TRUE : FALSE;

        HANDLE conin_handle_dup = CreateFileW(UTILITY_LITERAL_STRING_WITH_PREFIX(CONIN_FILE, L),
            GENERIC_READ, FILE_SHARE_READ, inherit_handle ? &sa : NULL, // must use `sa` to setup inheritance
            OPEN_EXISTING,
            FILE_ATTRIBUTE_NORMAL, NULL);

        return conin_handle_dup;
    }

    inline HANDLE _create_conout_handle(bool inherit_handle)
    {
        SECURITY_ATTRIBUTES sa{};

        sa.nLength = sizeof(sa);
        sa.bInheritHandle = inherit_handle ? TRUE : FALSE;

        HANDLE conout_handle_dup = CreateFileW(UTILITY_LITERAL_STRING_WITH_PREFIX(CONOUT_FILE, L),
            GENERIC_WRITE, FILE_SHARE_WRITE, inherit_handle ? &sa : NULL, // must use `sa` to setup inheritance
            OPEN_EXISTING,
            FILE_ATTRIBUTE_NORMAL, NULL);

        return conout_handle_dup;
    }

    inline void _reinit_crt_std_handles(int stdin_open_flags = _O_RDONLY | _O_BINARY,
                                        int stdout_open_flags = _O_WRONLY | _O_BINARY,
                                        int stderr_open_flags = _O_WRONLY | _O_BINARY)
    {
        // TODO:
        //  Get injected from here into parent process being used for console window attachment and
        //  directly call `GetStdHandle` functions to read standard handle addresses layout to update the standard handles (call `StdStdHandle`) instead of below code.
        //

        const HANDLE stdin_handle = GetStdHandle(STD_INPUT_HANDLE);
        const HANDLE stdout_handle = GetStdHandle(STD_OUTPUT_HANDLE);
        const HANDLE stderr_handle = GetStdHandle(STD_ERROR_HANDLE);

        const DWORD stdin_handle_type = _is_valid_handle(stdin_handle) ? GetFileType(stdin_handle) : FILE_TYPE_UNKNOWN;
        const DWORD stdout_handle_type = _is_valid_handle(stdout_handle) ? GetFileType(stdout_handle) : FILE_TYPE_UNKNOWN;
        const DWORD stderr_handle_type = _is_valid_handle(stderr_handle) ? GetFileType(stderr_handle) : FILE_TYPE_UNKNOWN;

        _attach_stdin_from_console(false, false);

        _attach_stdout_from_console(false, false);
        if (!_duplicate_stdout_to_stderr(false, false)) {
            _attach_stderr_from_console(false, false);
        }

        int stdin_filno = _fileno(stdin);
        int stdout_filno = _fileno(stdout);
        int stderr_filno = _fileno(stderr);

        bool is_stdin_closed = false;
        bool is_stdout_closed = false;
        bool is_stderr_closed = false;

        // NOTE:
        //  In backward order from stderr to stdin.
        //
        if (stderr_filno >= 0) {
            _close(stderr_filno);
            is_stderr_closed = true;
        }
        if (stdout_filno >= 0) {
            _close(stdout_filno);
            is_stdout_closed = true;
        }
        if (stdin_filno >= 0) {
            _close(stdin_filno);
            is_stdin_closed = true;
        }

        HANDLE stdin_handle_dup = INVALID_HANDLE_VALUE;
        HANDLE stdout_handle_dup = INVALID_HANDLE_VALUE;
        HANDLE stderr_handle_dup = INVALID_HANDLE_VALUE;

        // NOTE:
        //  In forward order from stdin to stderr.
        //
        if (is_stdin_closed) {
            if (stdin_handle_type != FILE_TYPE_UNKNOWN) {
                stdin_filno = _open_osfhandle((intptr_t)stdin_handle, stdin_open_flags);
            }
            else {
                stdin_handle_dup = _create_conin_handle(false);
                if (_is_valid_handle(stdin_handle_dup)) {
                    stdin_filno = _open_osfhandle((intptr_t)stdin_handle_dup, stdin_open_flags);
                }
            }
        }

        if (is_stdout_closed) {
            if (stdout_handle_type != FILE_TYPE_UNKNOWN) {
                stdout_filno = _open_osfhandle((intptr_t)stdout_handle, stdout_open_flags);
            }
            else {
                stdout_handle_dup = _create_conout_handle(false);
                if (_is_valid_handle(stdout_handle_dup)) {
                    stdout_filno = _open_osfhandle((intptr_t)stdout_handle_dup, stdout_open_flags);
                }
            }
        }

        if (is_stderr_closed) {
            if (stderr_handle_type != FILE_TYPE_UNKNOWN) {
                stderr_filno = _open_osfhandle((intptr_t)stderr_handle, stderr_open_flags);
            }
            else {
                stderr_handle_dup = _create_conout_handle(false);
                if (_is_valid_handle(stderr_handle_dup)) {
                    stderr_filno = _open_osfhandle((intptr_t)stderr_handle_dup, stderr_open_flags);
                }
            }
        }

        // invalidate duplicated handles to leave them to the `_sanitize_std_handles` call

        // NOTE:
        //  In backward order from stderr to stdin.
        //
        _close_handle(stderr_handle_dup);
        _close_handle(stdout_handle_dup);
        _close_handle(stdin_handle_dup);
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

    inline const TCHAR * _extract_variable(const TCHAR * last_offset_ptr, const TCHAR * parse_str, std::tstring & parsed_str, TCHAR * env_buf, bool allow_expand_unexisted_env)
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

                if (!allow_expand_unexisted_env) {
                    parsed_str.append(_T("${"));
                    parsed_str.append(in_str_var_name);
                    parsed_str.append(_T("}"));
                }
            }
        }

        return return_offset_ptr;
    }

    inline int _wide_char_to_multi_byte(UINT code_page, LPCWSTR in_str, int num_in_chars, std::vector<char> & out_buf)
    {
        int num_translated_bytes = WideCharToMultiByte(code_page, 0, in_str, num_in_chars, NULL, 0, NULL, NULL);
        if (num_translated_bytes) {
            out_buf.resize(size_t(num_translated_bytes) + (num_in_chars > 0 ? 1U : 0U));
            num_translated_bytes = WideCharToMultiByte(code_page, 0, in_str, num_in_chars, out_buf.data(), num_translated_bytes, NULL, NULL);
            if (num_in_chars > 0) {
                out_buf[size_t(num_translated_bytes)] = '\0';
            }

            return num_translated_bytes;
        }

        out_buf.clear();

        return 0;
    }

    inline int _multi_byte_to_wide_char(UINT code_page, LPCSTR in_str, int num_in_chars, std::vector<wchar_t> & out_buf)
    {
        int num_translated_chars = MultiByteToWideChar(code_page, 0, in_str, num_in_chars, NULL, 0);
        if (num_translated_chars) {
            out_buf.resize(size_t(num_translated_chars) + (num_in_chars > 0 ? 1U : 0U));
            num_translated_chars = MultiByteToWideChar(code_page, 0, in_str, num_in_chars, out_buf.data(), num_translated_chars);
            if (num_in_chars > 0) {
                out_buf[size_t(num_translated_chars)] = L'\0';
            }

            return num_translated_chars;
        }

        out_buf.clear();

        return 0;
    }

    // flags:
    //  0x01 - enable_conout_prints_buffering
    //
    inline void _print_raw_message_va_impl(int flags, int stream_type, const char * fmt, va_list vl)
    {
        const bool enable_conout_prints_buffering = flags & 0x01;

        char fixed_message_char_buf[256];

        // just in case
        fixed_message_char_buf[0] = '\0';

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
        const int num_written_chars = vsnprintf(fixed_message_char_buf, fixed_message_char_buf_size, fmt, vl);

        const UINT cp_out = GetConsoleOutputCP();

        CPINFO cp_info{};
        if (!GetCPInfo(cp_out, &cp_info)) {
            // fallback to module character set
#ifdef _UNICODE
            cp_info.MaxCharSize = sizeof(wchar_t);
#else
            cp_info.MaxCharSize = sizeof(char);
#endif
        }

        if (num_written_chars > 0 && num_written_chars < fixed_message_char_buf_size) {
            if (enable_conout_prints_buffering) {
                g_conout_prints_buf.push_back(_ConsoleOutput{ stream_type, std::string{ fixed_message_char_buf, size_t(num_written_chars) } });
            }

            if (cp_info.MaxCharSize == sizeof(char)) {
                switch (stream_type) {
                case STDOUT_FILENO:
                    fputs(fixed_message_char_buf, stdout);
                    break;
                case STDERR_FILENO:
                    fputs(fixed_message_char_buf, stderr);
                    break;
                }
            }
            else {
                std::vector<wchar_t> translated_char_buf;

                if (_multi_byte_to_wide_char(cp_out, fixed_message_char_buf, num_written_chars, translated_char_buf)) {
                    switch (stream_type) {
                    case STDOUT_FILENO:
                        fputws(translated_char_buf.data(), stdout);
                        break;
                    case STDERR_FILENO:
                        fputws(translated_char_buf.data(), stderr);
                        break;
                    }
                }
            }
        }
        else if (num_written_chars >= -1) {
            std::vector<char> char_buf;

            char_buf.resize(num_written_chars + 1);

            vsnprintf(char_buf.data(), char_buf.size(), fmt, vl);

            if (enable_conout_prints_buffering) {
                g_conout_prints_buf.push_back(_ConsoleOutput{ stream_type, std::string{ char_buf.data(), char_buf.size() > 0 ? char_buf.size() - 1 : 0 } });
            }

            if (cp_info.MaxCharSize == sizeof(char)) {
                switch (stream_type) {
                case STDOUT_FILENO:
                    fputs(char_buf.data(), stdout);
                    break;
                case STDERR_FILENO:
                    fputs(char_buf.data(), stderr);
                    break;
                }
            }
            else {
                std::vector<wchar_t> translated_char_buf;

                if (_multi_byte_to_wide_char(cp_out, char_buf.data(), num_written_chars, translated_char_buf)) {
                    switch (stream_type) {
                    case STDOUT_FILENO:
                        fputws(translated_char_buf.data(), stdout);
                        break;
                    case STDERR_FILENO:
                        fputws(translated_char_buf.data(), stderr);
                        break;
                    }
                }
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

            if (enable_conout_prints_buffering) {
                g_conout_prints_buf.push_back(_ConsoleOutput{ stream_type, std::string{ fixed_message_char_buf, size_t(num_written_chars2) } });
            }

            if (cp_info.MaxCharSize == sizeof(char)) {
                switch (stream_type) {
                case STDOUT_FILENO:
                    fputs(fixed_message_char_buf, stdout);
                    break;
                case STDERR_FILENO:
                    fputs(fixed_message_char_buf, stderr);
                    break;
                }
            }
            else {
                std::vector<wchar_t> translated_char_buf;

                if (_multi_byte_to_wide_char(cp_out, fixed_message_char_buf, num_written_chars, translated_char_buf)) {
                    switch (stream_type) {
                    case STDOUT_FILENO:
                        fputws(translated_char_buf.data(), stdout);
                        break;
                    case STDERR_FILENO:
                        fputws(translated_char_buf.data(), stderr);
                        break;
                    }
                }
            }
        }
    }

    // flags:
    //  0x01 - enable_conout_prints_buffering
    //
    inline void _print_raw_message_va_impl(int flags, int stream_type, const wchar_t * fmt, va_list vl)
    {
        const bool enable_conout_prints_buffering = flags & 0x01;

        wchar_t fixed_message_char_buf[256];

        // just in case
        fixed_message_char_buf[0] = L'\0';

        // CAUTION:
        //
        //  MSDN:
        //    Both _vsnprintf and _vsnwprintf functions return the number of characters written if the number of characters to write is less than or equal to count.
        //    If the number of characters to write is greater than count, these functions return -1 indicating that output has been truncated
        //
        //  The `_vsnwprintf` has a different behaviour versus the `vsnprintf` function and returns -1 on output string truncation (not an encoding error!),
        //  so we must call `_vsnwprintf` first time with an empty buffer and zero count to request the buffer size!
        //

        std::vector<wchar_t> char_buf;

        const int num_written_chars = _vsnwprintf(NULL, 0, fmt, vl);

        char_buf.resize(num_written_chars + 1);

        _vsnwprintf(char_buf.data(), char_buf.size(), fmt, vl);

        const UINT cp_out = GetConsoleOutputCP();

        CPINFO cp_info{};
        if (!GetCPInfo(cp_out, &cp_info)) {
            // fallback to module character set
#ifdef _UNICODE
            cp_info.MaxCharSize = sizeof(wchar_t);
#else
            cp_info.MaxCharSize = sizeof(char);
#endif
        }

        if (enable_conout_prints_buffering) {
            g_conout_prints_buf.push_back(_ConsoleOutput{ stream_type, std::wstring{ char_buf.data(), char_buf.size() > 0 ? char_buf.size() - 1 : 0 } });
        }

        if (cp_info.MaxCharSize != sizeof(char)) {
            switch (stream_type) {
            case STDOUT_FILENO:
                fputws(char_buf.data(), stdout);
                break;
            case STDERR_FILENO:
                fputws(char_buf.data(), stderr);
                break;
            }
        }
        else {
            std::vector<char> translated_char_buf;

            if (_wide_char_to_multi_byte(cp_out, char_buf.data(), char_buf.size(), translated_char_buf)) {
                switch (stream_type) {
                case STDOUT_FILENO:
                    fputs(translated_char_buf.data(), stdout);
                    break;
                case STDERR_FILENO:
                    fputs(translated_char_buf.data(), stderr);
                    break;
                }
            }
        }
    }

    inline void _print_raw_message_impl(int flags, int stream_type, const char * fmt, ...)
    {
        va_list vl;
        va_start(vl, fmt);
        _print_raw_message_va_impl(flags, stream_type, fmt, vl);
        va_end(vl);
    }

    inline void _print_raw_message_impl(int flags, int stream_type, const wchar_t * fmt, ...)
    {
        va_list vl;
        va_start(vl, fmt);
        _print_raw_message_va_impl(flags, stream_type, fmt, vl);
        va_end(vl);
    }

    inline void _print_raw_message(int stream_type, const char * fmt, ...)
    {
        va_list vl;
        va_start(vl, fmt);
        _print_raw_message_va_impl(g_enable_conout_prints_buffering ? 0x01 : 0, stream_type, fmt, vl);
        va_end(vl);
    }

    inline void _print_raw_message(int stream_type, const wchar_t * fmt, ...)
    {
        va_list vl;
        va_start(vl, fmt);
        _print_raw_message_va_impl(g_enable_conout_prints_buffering ? 0x01 : 0, stream_type, fmt, vl);
        va_end(vl);
    }

    // flags:
    //  0x01 - enable_conout_prints_buffering
    //
    inline void _put_raw_message_impl(int flags, int stream_type, std::string str)
    {
        const bool enable_conout_prints_buffering = flags & 0x01;

        const UINT cp_out = GetConsoleOutputCP();

        CPINFO cp_info{};
        if (!GetCPInfo(cp_out, &cp_info)) {
            // fallback to module character set
#ifdef _UNICODE
            cp_info.MaxCharSize = sizeof(wchar_t);
#else
            cp_info.MaxCharSize = sizeof(char);
#endif
        }

        if (enable_conout_prints_buffering) {
            g_conout_prints_buf.push_back(_ConsoleOutput{ stream_type, str });
        }

        if (cp_info.MaxCharSize == sizeof(char)) {
            switch (stream_type) {
            case STDOUT_FILENO:
                fputs(str.c_str(), stdout);
                break;
            case STDERR_FILENO:
                fputs(str.c_str(), stderr);
                break;
            }
        }
        else {
            std::vector<wchar_t> translated_char_buf;

            if (_multi_byte_to_wide_char(cp_out, str.c_str(), str.length(), translated_char_buf)) {
                switch (stream_type) {
                case STDOUT_FILENO:
                    fputws(translated_char_buf.data(), stdout);
                    break;
                case STDERR_FILENO:
                    fputws(translated_char_buf.data(), stderr);
                    break;
                }
            }
        }
    }

    // flags:
    //  0x01 - enable_conout_prints_buffering
    //
    inline void _put_raw_message_impl(int flags, int stream_type, std::wstring str)
    {
        const bool enable_conout_prints_buffering = flags & 0x01;

        const UINT cp_out = GetConsoleOutputCP();

        CPINFO cp_info{};
        if (!GetCPInfo(cp_out, &cp_info)) {
            // fallback to module character set
#ifdef _UNICODE
            cp_info.MaxCharSize = sizeof(wchar_t);
#else
            cp_info.MaxCharSize = sizeof(char);
#endif
        }

        if (enable_conout_prints_buffering) {
            g_conout_prints_buf.push_back(_ConsoleOutput{ stream_type, str });
        }

        if (cp_info.MaxCharSize != sizeof(char)) {
            switch (stream_type) {
            case STDOUT_FILENO:
                fputws(str.c_str(), stdout);
                break;
            case STDERR_FILENO:
                fputws(str.c_str(), stderr);
                break;
            }
        }
        else {
            std::vector<char> translated_char_buf;

            if (_wide_char_to_multi_byte(cp_out, str.c_str(), str.length(), translated_char_buf)) {
                switch (stream_type) {
                case STDOUT_FILENO:
                    fputs(translated_char_buf.data(), stdout);
                    break;
                case STDERR_FILENO:
                    fputs(translated_char_buf.data(), stderr);
                    break;
                }
            }
        }
    }

    inline void _put_raw_message(int stream_type, std::string str)
    {
        _put_raw_message_impl(g_enable_conout_prints_buffering ? 0x01 : 0, stream_type, std::move(str));
    }

    inline void _put_raw_message(int stream_type, std::wstring str)
    {
        _put_raw_message_impl(g_enable_conout_prints_buffering ? 0x01 : 0, stream_type, std::move(str));
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

    inline std::string _format_stderr_message_va(const char * fmt, va_list vl)
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
        //  The `_snprintf` has a different behaviour versus the `vsnprintf` function and returns a negative value on output string truncation (not an encoding error!),
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

    inline std::wstring _format_stderr_message_va(const wchar_t * fmt, va_list vl)
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
        //  The `_vsnwprintf` has a different behaviour versus the `vsnprintf` function and returns -1 on output string truncation (not an encoding error!),
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
        const auto ret = _format_stderr_message_va(fmt, vl);
        va_end(vl);
        return ret;
    }

    inline std::wstring _format_stderr_message(const wchar_t * fmt, ...)
    {
        va_list vl;
        va_start(vl, fmt);
        const auto ret = _format_stderr_message_va(fmt, vl);
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
            _print_raw_message(STDERR_FILENO, "[%s] [%u] [%s] error: %s",
                local_time_str.c_str(), GetCurrentProcessId(), module_char_buf, fixed_message_char_buf);
        }
        else if (num_written_chars >= -1) {
            std::vector<char> char_buf;

            char_buf.resize(num_written_chars + 1);

            vsnprintf(char_buf.data(), char_buf.size(), fmt, vl);

            _print_raw_message(STDERR_FILENO, "[%s] [%u] [%s] error: %s",
                local_time_str.c_str(), GetCurrentProcessId(), module_char_buf, char_buf.data());
        }
        else {
            _print_raw_message(STDERR_FILENO, "[%s] [%u] [%s] error: %s",
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
        //  The `_vsnwprintf` has a different behaviour versus the `vsnprintf` function and returns -1 on output string truncation (not an encoding error!),
        //  so we must call `_vsnwprintf` first time with an empty buffer and zero count to request the buffer size!
        //

        std::vector<wchar_t> char_buf;

        const int num_written_chars = _vsnwprintf(NULL, 0, fmt, vl);

        char_buf.resize(num_written_chars + 1);

        _vsnwprintf(char_buf.data(), char_buf.size(), fmt, vl);

        _print_raw_message(STDERR_FILENO, L"[%s] [%u] [%s] error: %s",
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
                    cp_info.MaxCharSize = sizeof(wchar_t);
#else
                    cp_info.MaxCharSize = sizeof(char);
#endif
                }

                if (cp_info.MaxCharSize != sizeof(char)) {
                    FormatMessageW(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
                        NULL, win_error, MAKELANGID(langid, SUBLANG_DEFAULT), (LPWSTR)&win_error_msg_buf_w, 0, NULL);
#ifdef _UNICODE
                    ret = _format_stderr_message(L"win32: \"%s\"\n", win_error_msg_buf_w);
#else
                    std::vector<char> char_buf;

                    if (_wide_char_to_multi_byte(cp_out, win_error_msg_buf_w, -1, char_buf)) {
                        ret = _format_stderr_message("win32: \"%s\"\n", char_buf.data());
                    }
#endif
                }
                else {
                    FormatMessageA(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
                        NULL, win_error, MAKELANGID(langid, SUBLANG_DEFAULT), (LPSTR)&win_error_msg_buf_a, 0, NULL);
#ifdef _UNICODE
                    std::vector<wchar_t> char_buf;

                    if (_multi_byte_to_wide_char(cp_out, win_error_msg_buf_a, -1, char_buf)) {
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
                cp_info.MaxCharSize = sizeof(wchar_t);
#else
                cp_info.MaxCharSize = sizeof(char);
#endif
            }

            if (cp_info.MaxCharSize != sizeof(char)) {
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

        // post process

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

    template <typename Flags, typename Options>
    inline bool _sanitize_std_handles(int & ret, DWORD & win_error, _StdHandlesState & std_handles_state, const Flags & flags, const Options & options)
    {
        // intercept here specific global variables accidental usage instead of local variables
        static struct {} g_options;
        static struct {} g_flags;


        HANDLE stdin_handle = INVALID_HANDLE_VALUE;
        HANDLE stdout_handle = INVALID_HANDLE_VALUE;
        HANDLE stderr_handle = INVALID_HANDLE_VALUE;

        DWORD stdin_handle_type = FILE_TYPE_UNKNOWN;
        DWORD stdout_handle_type = FILE_TYPE_UNKNOWN;
        DWORD stderr_handle_type = FILE_TYPE_UNKNOWN;

        for (int read_std_handles_iter = 0; read_std_handles_iter < 2; read_std_handles_iter++) {
            SetLastError(0); // just in case
            stdin_handle = GetStdHandle(STD_INPUT_HANDLE);
            if (!read_std_handles_iter) {
                if (!std_handles_state.has_stdin_console_mode && _is_valid_handle(stdin_handle)) {
                    // save console mode if not done yet
                    std_handles_state.save_stdin_state(stdin_handle);
                }
            }
            else {
                if (!_is_valid_handle(stdin_handle)) {
                    if (flags.ret_win_error || flags.print_win_error_string || !flags.no_print_gen_error_string) {
                        win_error = GetLastError();
                    }
                    if (!flags.ret_win_error) {
                        ret = err_win32_error;
                    }
                    else {
                        ret = win_error;
                    }
                    if (!flags.no_print_gen_error_string) {
                        _print_stderr_message(_T("stdin handle is invalid: win_error=0x%08X (%d)\n"),
                            win_error, win_error);
                    }
                    if (flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, options.win_error_langid);
                    }

                    return false;
                }
            }

            SetLastError(0); // just in case
            stdout_handle = GetStdHandle(STD_OUTPUT_HANDLE);
            if (!read_std_handles_iter) {
                if (!std_handles_state.has_stdout_console_mode && _is_valid_handle(stdout_handle)) {
                    // save console mode if not done yet
                    std_handles_state.save_stdout_state(stdout_handle);
                }
            }
            else {
                if (!_is_valid_handle(stdout_handle)) {
                    if (flags.ret_win_error || flags.print_win_error_string || !flags.no_print_gen_error_string) {
                        win_error = GetLastError();
                    }
                    if (!flags.ret_win_error) {
                        ret = err_win32_error;
                    }
                    else {
                        ret = win_error;
                    }
                    if (!flags.no_print_gen_error_string) {
                        _print_stderr_message(_T("stdout handle is invalid: win_error=0x%08X (%d)\n"),
                            win_error, win_error);
                    }
                    if (flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, options.win_error_langid);
                    }

                    return false;
                }
            }

            SetLastError(0); // just in case
            stderr_handle = GetStdHandle(STD_ERROR_HANDLE);
            if (!read_std_handles_iter) {
                if (!std_handles_state.has_stderr_console_mode && _is_valid_handle(stderr_handle)) {
                    // save console mode if not done yet
                    std_handles_state.save_stderr_state(stderr_handle);
                }
            }
            else {
                if (!_is_valid_handle(stderr_handle)) {
                    if (flags.ret_win_error || flags.print_win_error_string || !flags.no_print_gen_error_string) {
                        win_error = GetLastError();
                    }
                    if (!flags.ret_win_error) {
                        ret = err_win32_error;
                    }
                    else {
                        ret = win_error;
                    }

                    // CAUTION:
                    //  Below code has no effect and is left just in case.
                    //

                    if (!flags.no_print_gen_error_string) {
                        _print_stderr_message(_T("stderr handle is invalid: win_error=0x%08X (%d)\n"),
                            win_error, win_error);
                    }
                    if (flags.print_win_error_string && win_error) {
                        _print_win_error_message(win_error, options.win_error_langid);
                    }

                    return false;
                }
            }

            // reopen closed std handles from `CONIN$` and `CONOUT$` or `\\.\CON` files

            //#define FILE_TYPE_UNKNOWN   0x0000
            //#define FILE_TYPE_DISK      0x0001 // ReadFile
            //#define FILE_TYPE_CHAR      0x0002 // ReadConsoleInput, PeekConsoleInput
            //#define FILE_TYPE_PIPE      0x0003 // ReadFile, PeekNamedPipe
            //#define FILE_TYPE_REMOTE    0x8000
            //

            stdin_handle_type = _is_valid_handle(stdin_handle) ? GetFileType(stdin_handle) : FILE_TYPE_UNKNOWN;
            stdout_handle_type = _is_valid_handle(stdout_handle) ? GetFileType(stdout_handle) : FILE_TYPE_UNKNOWN;
            stderr_handle_type = _is_valid_handle(stderr_handle) ? GetFileType(stderr_handle) : FILE_TYPE_UNKNOWN;

            if (read_std_handles_iter) {
                // WORKAROUND:
                //  Sometimes either the stdout or stderr is invalid after process elevation.
                //  If try to reopen the stdout or stderr handle from the `CONOUT$` pseudo file before close a second one, then it leads to handle duplication of already invalidated handle
                //  (the `DuplicateHandle` fails inside `_dup` call).
                //  To avoid that we have to close BOTH stdout AND stderr, and only after try to reopen them from `CONOUT$` pseudo file.
                //

                if (stdin_handle_type == FILE_TYPE_UNKNOWN) {
                    if (flags.ret_win_error || flags.print_win_error_string || !flags.no_print_gen_error_string) {
                        win_error = GetLastError();
                    }
                    if (!flags.ret_win_error) {
                        ret = err_win32_error;
                    }
                    else {
                        ret = win_error;
                    }

                    if (stderr_handle_type != FILE_TYPE_UNKNOWN) {
                        if (!flags.no_print_gen_error_string) {
                            _print_stderr_message(_T("stdin handle type is unknown: win_error=0x%08X (%d)\n"),
                                win_error, win_error);
                        }
                        if (flags.print_win_error_string && win_error) {
                            _print_win_error_message(win_error, options.win_error_langid);
                        }
                    }

                    return false;
                }

                std_handles_state.restore_stdin_state(stdin_handle, true);

                if (stdout_handle_type == FILE_TYPE_UNKNOWN) {
                    if (flags.ret_win_error || flags.print_win_error_string || !flags.no_print_gen_error_string) {
                        win_error = GetLastError();
                    }
                    if (!flags.ret_win_error) {
                        ret = err_win32_error;
                    }
                    else {
                        ret = win_error;
                    }

                    if (stderr_handle_type != FILE_TYPE_UNKNOWN) {
                        if (!flags.no_print_gen_error_string) {
                            _print_stderr_message(_T("stdout handle type is unknown: win_error=0x%08X (%d)\n"),
                                win_error, win_error);
                        }
                        if (flags.print_win_error_string && win_error) {
                            _print_win_error_message(win_error, options.win_error_langid);
                        }
                    }

                    return false;
                }

                std_handles_state.restore_stdout_state(stdout_handle, true);

                if (stderr_handle_type == FILE_TYPE_UNKNOWN) {
                    if (flags.ret_win_error || flags.print_win_error_string || !flags.no_print_gen_error_string) {
                        win_error = GetLastError();
                    }
                    if (!flags.ret_win_error) {
                        ret = err_win32_error;
                    }
                    else {
                        ret = win_error;
                    }

                    if (stderr_handle_type != FILE_TYPE_UNKNOWN) {
                        if (!flags.no_print_gen_error_string) {
                            _print_stderr_message(_T("stderr handle type is unknown: win_error=0x%08X (%d)\n"),
                                win_error, win_error);
                        }
                        if (flags.print_win_error_string && win_error) {
                            _print_win_error_message(win_error, options.win_error_langid);
                        }
                    }

                    return false;
                }

                std_handles_state.restore_stderr_state(stderr_handle, true);

                break;
            }
            else if (stdin_handle_type != FILE_TYPE_UNKNOWN && stdout_handle_type != FILE_TYPE_UNKNOWN && stderr_handle_type != FILE_TYPE_UNKNOWN) {
                break;
            }

            // CAUTION:
            //  The Administrator privileges process isolation logic has an issue:
            //
            //  When the process A creates the process B, the process B can contain invalid handles in Win32 handle table.
            //
            //  This happens because:
            //
            //  1. Process B has different or higher privileges than process A.
            //
            //  2. Process B attaches to the console window of process A.
            //      NOTE:
            //        Additional issues with console attachment:
            //          `AllocConsole, AttachConsole (traditional)` : https://github.com/rprichard/win32-console-docs#allocconsole-attachconsole-traditional
            //
            //  3. Process A has different standard handle address layout opposed to the process B (may be because the process B can not inherit the standard handles addresses layout under the Administrator privileges isolation).
            //
            //  When the console window of the process A attaches to the process B with the same privileges, then the process B gets the standard handle addresses layout of the process A.
            //  When the console window of the process A with a user privileges attaches to the process B with the Administrator privileges, then the process B gets default standard handle addresses layout,
            //  which means all the standard handles inside the CRT of the process B must be invalidated and reinitialized, but unfortunately the CRT has no functionality for that.
            //
            //  Example:
            //      Process A handles    ->     Process B handles
            //          stdin  = 0x03               stdin  = 0x03
            //          stdout = 0x13               stdout = 0x07
            //          stderr = 0x0b               stderr = 0x0b
            //
            //      The process B would contain invalid stdout handle and function `GetFileType((HANDLE)0x07)` would return 0 (FILE_TYPE_UNKNOWN).
            //
            //  There is a workaround for that:
            //
            //  1. Reopen all such handles from `CONIN$` and `CONOUT$` or `\\.\CON` files.
            //     This method has a problem, the `GetConsoleMode` function returns 0 for such an opened handle which means the `ENABLE_PROCESSED_OUTPUT` flag in stdout/stderr has dropped and
            //     the output will contain printable form of carriage return and line feed characters. In the same time the `SetConsoleMode` fails on such handles opened through the `CreateFile`.
            //     So this method only fixes the standard handles validity without it's console mode flags.
            //

            // NOTE:
            //  In backward order from stderr to stdin.
            //
            if (stderr_handle_type == FILE_TYPE_UNKNOWN) {
                _detach_stderr();
            }

            if (stdout_handle_type == FILE_TYPE_UNKNOWN) {
                _detach_stdout();
            }

            if (stdin_handle_type == FILE_TYPE_UNKNOWN) {
                _detach_stdin();
            }

            const bool set_std_handle = IF_CONSOLE_APP(false, true);

            // NOTE:
            //  In forward order from stdin to stderr.
            //
            if (stdin_handle_type == FILE_TYPE_UNKNOWN) {
                _attach_stdin_from_console(set_std_handle, !!std_handles_state.is_stdin_inheritable); // by default - inheritable
            }

            if (stdout_handle_type == FILE_TYPE_UNKNOWN) {
                // attempt to duplicate stdout/stderr from stderr/stdout handle at first
                if (stderr_handle_type != FILE_TYPE_UNKNOWN) {
                    if (!_duplicate_stderr_to_stdout(set_std_handle, !!std_handles_state.is_stdout_inheritable)) {
                        _attach_stdout_from_console(set_std_handle, !!std_handles_state.is_stdout_inheritable); // by default - inheritable
                    }
                }
                else {
                    if (!_attach_stdout_from_console(set_std_handle, !!std_handles_state.is_stdout_inheritable) || // by default - inheritable
                        !_duplicate_stdout_to_stderr(set_std_handle, !!std_handles_state.is_stderr_inheritable)) {
                        _attach_stderr_from_console(set_std_handle, !!std_handles_state.is_stderr_inheritable); // by default - inheritable
                    }
                }
            }
            else if (stderr_handle_type == FILE_TYPE_UNKNOWN) {
                if (!_duplicate_stdout_to_stderr(set_std_handle, !!std_handles_state.is_stderr_inheritable)) {
                    _attach_stderr_from_console(set_std_handle, !!std_handles_state.is_stderr_inheritable); // by default - inheritable
                }
            }


#if SYNC_STD_STREAMS_WITH_STDIO
            std::ios::sync_with_stdio(); // sync with C++ streams
#endif
        }

        return true;
    }

    template <typename Flags, typename Options>
    inline bool _get_stdin_handle(int & ret, DWORD & win_error, HANDLE & stdin_handle, const Flags & flags, const Options & options)
    {
        // intercept here specific global variables accidental usage instead of local variables
        static struct {} g_options;
        static struct {} g_flags;

        SetLastError(0); // just in case
        stdin_handle = GetStdHandle(STD_INPUT_HANDLE);
        if (!_is_valid_handle(stdin_handle)) {
            if (flags.ret_win_error || flags.print_win_error_string || !flags.no_print_gen_error_string) {
                win_error = GetLastError();
            }
            if (!flags.ret_win_error) {
                ret = err_win32_error;
            }
            else {
                ret = win_error;
            }
            if (!flags.no_print_gen_error_string) {
                _print_stderr_message(_T("stdin handle is invalid: win_error=0x%08X (%d)\n"),
                    win_error, win_error);
            }
            if (flags.print_win_error_string && win_error) {
                _print_win_error_message(win_error, options.win_error_langid);
            }
            return false;
        }

        return true;
    }

    template <typename Flags, typename Options>
    inline bool _get_stdout_handle(int & ret, DWORD & win_error, HANDLE & stdout_handle, const Flags & flags, const Options & options)
    {
        // intercept here specific global variables accidental usage instead of local variables
        static struct {} g_options;
        static struct {} g_flags;

        SetLastError(0); // just in case
        stdout_handle = GetStdHandle(STD_OUTPUT_HANDLE);
        if (!_is_valid_handle(stdout_handle)) {
            if (flags.ret_win_error || flags.print_win_error_string || !flags.no_print_gen_error_string) {
                win_error = GetLastError();
            }
            if (!flags.ret_win_error) {
                ret = err_win32_error;
            }
            else {
                ret = win_error;
            }
            if (!flags.no_print_gen_error_string) {
                _print_stderr_message(_T("stdout handle is invalid: win_error=0x%08X (%d)\n"),
                    win_error, win_error);
            }
            if (flags.print_win_error_string && win_error) {
                _print_win_error_message(win_error, options.win_error_langid);
            }
            return false;
        }

        return true;
    }

    template <typename Flags, typename Options>
    inline bool _get_stderr_handle(int & ret, DWORD & win_error, HANDLE & stderr_handle, const Flags & flags, const Options & options)
    {
        // intercept here specific global variables accidental usage instead of local variables
        static struct {} g_options;
        static struct {} g_flags;

        SetLastError(0); // just in case
        stderr_handle = GetStdHandle(STD_ERROR_HANDLE);
        if (!_is_valid_handle(stderr_handle)) {
            if (flags.ret_win_error || flags.print_win_error_string || !flags.no_print_gen_error_string) {
                win_error = GetLastError();
            }
            if (!flags.ret_win_error) {
                ret = err_win32_error;
            }
            else {
                ret = win_error;
            }

            // CAUTION:
            //  Below code has no effect and is left just in case.
            //

            if (!flags.no_print_gen_error_string) {
                _print_stderr_message(_T("stderr handle is invalid: win_error=0x%08X (%d)\n"),
                    win_error, win_error);
            }
            if (flags.print_win_error_string && win_error) {
                _print_win_error_message(win_error, options.win_error_langid);
            }
            return false;
        }

        return true;
    }

    template <typename Flags, typename Options>
    inline bool _get_std_handles(int & ret, DWORD & win_error, HANDLE & stdin_handle, HANDLE & stdout_handle, HANDLE & stderr_handle, const Flags & flags, const Options & options)
    {
        // intercept here specific global variables accidental usage instead of local variables
        static struct {} g_options;
        static struct {} g_flags;

        if (!_get_stdin_handle(ret, win_error, stdin_handle, flags, options)) {
            return false;
        }
        if (!_get_stdout_handle(ret, win_error, stdout_handle, flags, options)) {
            return false;
        }
        if (!_get_stderr_handle(ret, win_error, stderr_handle, flags, options)) {
            return false;
        }

        return true;
    }

    inline void _free_console(_StdHandlesState & std_handles_state)
    {
        HANDLE stdin_handle = GetStdHandle(STD_INPUT_HANDLE);
        HANDLE stdout_handle = GetStdHandle(STD_OUTPUT_HANDLE);
        HANDLE stderr_handle = GetStdHandle(STD_ERROR_HANDLE);

        std_handles_state.save_stderr_state(stderr_handle);
        std_handles_state.save_stdout_state(stdout_handle);
        std_handles_state.save_stdin_state(stdin_handle);

        FreeConsole();
    }

    inline HWND _alloc_console(const _StdHandlesState & std_handles_state)
    {
        if (!AllocConsole()) {
            return NULL;
        }

        HWND inherited_console_window = GetConsoleWindow();

        return inherited_console_window;
    }

    inline HWND _attach_console(const _StdHandlesState & std_handles_state, DWORD process_id, bool inherit_handle)
    {
        if (!AttachConsole(process_id)) {
            return NULL;
        }

        HWND inherited_console_window = GetConsoleWindow();

        return inherited_console_window;
    }

    // Based on ReactOS implementation:
    //  https://github.com/reactos/reactos/blob/2636cff09fdb70bfe63c52ea9d2d24dbfc1e337f/dll/win32/shell32/wine/shell32_main.c#L80
    //

    /*************************************************************************
    * CommandLineToArgvW            [SHELL32.@]
    *
    * We must interpret the quotes in the command line to rebuild the argv
    * array correctly:
    * - arguments are separated by spaces or tabs
    * - quotes serve as optional argument delimiters
    *   '"a b"'   -> 'a b'
    * - escaped quotes must be converted back to '"'
    *   '\"'      -> '"'
    * - consecutive backslashes preceding a quote see their number halved with
    *   the remainder escaping the quote:
    *   2n   backslashes + quote -> n backslashes + quote as an argument delimiter
    *   2n+1 backslashes + quote -> n backslashes + literal quote
    * - backslashes that are not followed by a quote are copied literally:
    *   'a\b'     -> 'a\b'
    *   'a\\b'    -> 'a\\b'
    * - in quoted strings, consecutive quotes see their number divided by three
    *   with the remainder modulo 3 deciding whether to close the string or not.
    *   Note that the opening quote must be counted in the consecutive quotes,
    *   that's the (1+) below:
    *   (1+) 3n   quotes -> n quotes
    *   (1+) 3n+1 quotes -> n quotes plus closes the quoted string
    *   (1+) 3n+2 quotes -> n+1 quotes plus closes the quoted string
    * - in unquoted strings, the first quote opens the quoted string and the
    *   remaining consecutive quotes follow the above rule.
    */

    template <size_t N>
    inline bool _get_cmdline_arg_offsets(LPCWSTR lpCmdLine, const size_t (& from_arg_index_arr)[N], ptrdiff_t (& arg_offset_arr)[N])
    {
        const auto max_index = (std::numeric_limits<size_t>::max)();

        for(auto & value : arg_offset_arr) { value = max_index; };

        if (!lpCmdLine) {
            return false;
        }

        DWORD argc;
        LPCWSTR s;
        int quote_count, backslash_count;
        bool quote_open = false;

        size_t from_arg_index = 0;
        size_t arg_index;

        // --- First count the arguments
        argc = 1;
        s = lpCmdLine;
        // The first argument, the executable path, follows special rules
        if (*s == L'"')
        {
            // The executable path ends at the next quote, no matter what
            s++;
            while (*s)
                if (*s++ == L'"')
                    break;
        }
        else
        {
            // The executable path ends at the next space, no matter what
            while (*s && *s != L' ' && *s != L'\t')
                s++;
        }

        // skip to the first argument, if any
        while (*s == L' ' || *s == L'\t')
            s++;

        if (*s)
        {
            argc++;

            arg_index = 0;
            utility::for_each_unroll(from_arg_index_arr,
                [&](size_t value) -> bool {
                    if (arg_index < from_arg_index) {
                        arg_index++;
                        return true;
                    }
                    if (argc >= value + 1) {
                        arg_offset_arr[arg_index] = (ptrdiff_t)(s - lpCmdLine);
                        from_arg_index = arg_index + 1;
                    }
                    arg_index++;
                    return true;
                }
            );
        }

        if (from_arg_index >= N) {
            return true;
        }

        // analyze the remaining arguments
        backslash_count = 0;
        while (*s)
        {
            if ((*s == L' ' || *s == L'\t') && !quote_open)
            {
                while (*s == L' ' || *s == L'\t')
                    s++;
                if (*s)
                {
                    argc++;

                    arg_index = 0;
                    utility::for_each_unroll(from_arg_index_arr,
                        [&](size_t value) -> bool {
                            if (arg_index < from_arg_index) {
                                arg_index++;
                                return true;
                            }
                            if (argc >= value + 1) {
                                arg_offset_arr[arg_index] = (ptrdiff_t)(s - lpCmdLine);
                                from_arg_index = arg_index + 1;
                            }
                            arg_index++;
                            return true;
                        }
                    );

                    if (from_arg_index >= N) {
                        return true;
                    }
                }

                backslash_count = 0;
            }
            else if (*s == L'\\')
            {
                backslash_count++;
                s++;
            }
            else if (*s == L'"')
            {
                quote_count = 0;

                if (!(backslash_count & 1))
                    quote_count++; // unescaped

                s++;
                backslash_count = 0;

                while (*s == L'"')
                {
                    quote_count++;
                    s++;
                }

                if (quote_count & 1) {
                    quote_open = !quote_open;
                }
            }
            else
            {
                // a regular character
                backslash_count = 0;
                s++;
            }
        }

        return 0 < from_arg_index;
    }

#ifdef _DEBUG
    inline void _debug_print_win32_std_handles(uint32_t index)
    {
        const HANDLE stdin_handle = GetStdHandle(STD_INPUT_HANDLE);
        const HANDLE stdout_handle = GetStdHandle(STD_OUTPUT_HANDLE);
        const HANDLE stderr_handle = GetStdHandle(STD_ERROR_HANDLE);

        const DWORD stdin_handle_type = stdin_handle ? GetFileType(stdin_handle) : FILE_TYPE_UNKNOWN;
        const DWORD stdout_handle_type = stdout_handle ? GetFileType(stdout_handle) : FILE_TYPE_UNKNOWN;
        const DWORD stderr_handle_type = stderr_handle ? GetFileType(stderr_handle) : FILE_TYPE_UNKNOWN;

        const DWORD current_proc_id = GetCurrentProcessId();

        _StdHandlesState std_handles_state;

        std_handles_state.save_stdin_state(stdin_handle);
        std_handles_state.save_stdout_state(stdout_handle);
        std_handles_state.save_stderr_state(stderr_handle);

        _print_raw_message_impl(0, STDOUT_FILENO, "%02uA %06u [WIN32] stdin : %04X t=%u i=%u m=%04X; stdout: %04X t=%u i=%u m=%04X; stderr: %04X t=%u i=%u m=%04X\n", index, current_proc_id,
            (uint16_t)(uintptr_t)stdin_handle, stdin_handle_type, stdin_handle_type ? std_handles_state.is_stdin_inheritable : 0, (DWORD)(uint16_t)(std_handles_state.has_stdin_console_mode ? std_handles_state.stdin_handle_mode : (DWORD)-1),
            (uint16_t)(uintptr_t)stdout_handle, stdout_handle_type, stdout_handle_type ? std_handles_state.is_stdout_inheritable : 0, (DWORD)(uint16_t)(std_handles_state.has_stdout_console_mode ? std_handles_state.stdout_handle_mode : (DWORD)-1),
            (uint16_t)(uintptr_t)stderr_handle, stderr_handle_type, stderr_handle_type ? std_handles_state.is_stderr_inheritable : 0, (DWORD)(uint16_t)(std_handles_state.has_stderr_console_mode ? std_handles_state.stderr_handle_mode : (DWORD)-1));

        _print_raw_message_impl(0, STDERR_FILENO, "%02uB %06u [WIN32] stdin : %04X t=%u i=%u m=%04X; stdout: %04X t=%u i=%u m=%04X; stderr: %04X t=%u i=%u m=%04X\n", index, current_proc_id,
            (uint16_t)(uintptr_t)stdin_handle, stdin_handle_type, stdin_handle_type ? std_handles_state.is_stdin_inheritable : 0, (DWORD)(uint16_t)(std_handles_state.has_stdin_console_mode ? std_handles_state.stdin_handle_mode : (DWORD)-1),
            (uint16_t)(uintptr_t)stdout_handle, stdout_handle_type, stdout_handle_type ? std_handles_state.is_stdout_inheritable : 0, (DWORD)(uint16_t)(std_handles_state.has_stdout_console_mode ? std_handles_state.stdout_handle_mode : (DWORD)-1),
            (uint16_t)(uintptr_t)stderr_handle, stderr_handle_type, stderr_handle_type ? std_handles_state.is_stderr_inheritable : 0, (DWORD)(uint16_t)(std_handles_state.has_stderr_console_mode ? std_handles_state.stderr_handle_mode : (DWORD)-1));
    }

    inline void _debug_print_crt_std_handles(uint32_t index)
    {
        const int stdin_fileno = _fileno(stdin);
        const HANDLE stdin_handle = (HANDLE)_get_osfhandle(stdin_fileno);

        const int stdout_fileno = _fileno(stdout);
        const HANDLE stdout_handle = (HANDLE)_get_osfhandle(stdout_fileno);

        const int stderr_fileno = _fileno(stderr);
        const HANDLE stderr_handle = (HANDLE)_get_osfhandle(stderr_fileno);

        const DWORD stdin_handle_type = stdin_handle ? GetFileType(stdin_handle) : FILE_TYPE_UNKNOWN;
        const DWORD stdout_handle_type = stdout_handle ? GetFileType(stdout_handle) : FILE_TYPE_UNKNOWN;
        const DWORD stderr_handle_type = stderr_handle ? GetFileType(stderr_handle) : FILE_TYPE_UNKNOWN;

        const DWORD current_proc_id = GetCurrentProcessId();

        _StdHandlesState std_handles_state;

        std_handles_state.save_stdin_state(stdin_handle);
        std_handles_state.save_stdout_state(stdout_handle);
        std_handles_state.save_stderr_state(stderr_handle);

        _print_raw_message_impl(0, STDOUT_FILENO, "%02uA %06u [CRT]   stdin : %04X t=%u i=%u m=%04X; stdout: %04X t=%u i=%u m=%04X; stderr: %04X t=%u i=%u m=%04X\n", index, current_proc_id,
            (uint16_t)(uintptr_t)stdin_handle, stdin_handle_type, stdin_handle_type ? std_handles_state.is_stdin_inheritable : 0, (DWORD)(uint16_t)(std_handles_state.has_stdin_console_mode ? std_handles_state.stdin_handle_mode : (DWORD)-1),
            (uint16_t)(uintptr_t)stdout_handle, stdout_handle_type, stdout_handle_type ? std_handles_state.is_stdout_inheritable : 0, (DWORD)(uint16_t)(std_handles_state.has_stdout_console_mode ? std_handles_state.stdout_handle_mode : (DWORD)-1),
            (uint16_t)(uintptr_t)stderr_handle, stderr_handle_type, stderr_handle_type ? std_handles_state.is_stderr_inheritable : 0, (DWORD)(uint16_t)(std_handles_state.has_stderr_console_mode ? std_handles_state.stderr_handle_mode : (DWORD)-1));

        _print_raw_message_impl(0, STDERR_FILENO, "%02uB %06u [CRT]   stdin : %04X t=%u i=%u m=%04X; stdout: %04X t=%u i=%u m=%04X; stderr: %04X t=%u i=%u m=%04X\n", index, current_proc_id,
            (uint16_t)(uintptr_t)stdin_handle, stdin_handle_type, stdin_handle_type ? std_handles_state.is_stdin_inheritable : 0, (DWORD)(uint16_t)(std_handles_state.has_stdin_console_mode ? std_handles_state.stdin_handle_mode : (DWORD)-1),
            (uint16_t)(uintptr_t)stdout_handle, stdout_handle_type, stdout_handle_type ? std_handles_state.is_stdout_inheritable : 0, (DWORD)(uint16_t)(std_handles_state.has_stdout_console_mode ? std_handles_state.stdout_handle_mode : (DWORD)-1),
            (uint16_t)(uintptr_t)stderr_handle, stderr_handle_type, stderr_handle_type ? std_handles_state.is_stderr_inheritable : 0, (DWORD)(uint16_t)(std_handles_state.has_stderr_console_mode ? std_handles_state.stderr_handle_mode : (DWORD)-1));
    }
#endif
}

#endif
