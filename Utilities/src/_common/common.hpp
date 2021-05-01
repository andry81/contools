#ifndef __COMMON_HPP__
#define __COMMON_HPP__

#include <version.hpp>

#include <string>
#include <vector>

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
    using tstring_vector_t         = std::vector<std::tstring>;

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
            if (!env_buf_size) {
                env_buf[0] = _T('\0');
            }

            parsed_str.append(env_buf);
        }

        return return_offset_ptr;
    }

    inline bool _is_winnt()
    {
        OSVERSIONINFO osv;
        osv.dwOSVersionInfoSize = sizeof(osv);
        GetVersionEx(&osv);
        return (osv.dwPlatformId == VER_PLATFORM_WIN32_NT);
    }

    inline void _print_error_message(DWORD win_error)
    {
        LPTSTR win_error_msg_buf = nullptr;
        UINT prev_cp = GetConsoleOutputCP();
        FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
            NULL, win_error, MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), (LPTSTR)&win_error_msg_buf, 0, NULL);
        _ftprintf(stderr, _T("error: win32: \"%s\"\n"), win_error_msg_buf);
        LocalFree(win_error_msg_buf);
    }
}

#endif
