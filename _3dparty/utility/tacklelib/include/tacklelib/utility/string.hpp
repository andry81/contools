#pragma once

// DO NOT REMOVE, exists to avoid private/public headers mixing!
#ifndef UTILITY_STRING_HPP
#define UTILITY_STRING_HPP

#include <tacklelib/tacklelib.hpp>

#include <tacklelib/utility/preprocessor.hpp>
#include <tacklelib/utility/platform.hpp>
#include <tacklelib/utility/string_identity.hpp>

#include <string>
#include <cstring>
#include <cstddef>
#include <cstdarg>
#include <cstdio>
#include <cstdlib>
#include <cstdint>
#include <cwchar>
#include <uchar.h> // in GCC `cuchar` header might not exist
#include <memory>
#include <algorithm>
#include <type_traits>


namespace utility {

    template <typename CharT>
    FORCE_INLINE size_t string_length(const CharT * str)
    {
        DEBUG_ASSERT_TRUE(str);
        return std::char_traits<CharT>::length(str);
    }

    // implementation based on answers from here: stackoverflow.com/questions/2342162/stdstring-formatting-like-sprintf/2342176
    //

    FORCE_INLINE std::string string_format(size_t string_reserve, std::string fmt_str, va_list vl)
    {
        size_t str_len = (std::max)(fmt_str.size(), string_reserve);
        std::string str;

        while (true) {
            str.resize(str_len);

            const int final_n = std::vsnprintf(const_cast<char *>(str.data()), str_len, fmt_str.c_str(), vl);

            if (final_n < 0 || final_n >= int(str_len))
                str_len += (std::abs)(final_n - int(str_len) + 1);
            else {
                str.resize(final_n); // do not forget to shrink the size!
                break;
            }
        }

        return str;
    }

    FORCE_INLINE std::wstring string_format(size_t string_reserve, std::wstring fmt_str, va_list vl)
    {
        size_t str_len = (std::max)(fmt_str.size(), string_reserve);
        std::wstring str;

        while (true) {
            str.resize(str_len);

            const int final_n = std::vswprintf(const_cast<wchar_t *>(str.data()), str_len, fmt_str.c_str(), vl);

            if (final_n < 0 || final_n >= int(str_len))
                str_len += (std::abs)(final_n - int(str_len) + 1);
            else {
                str.resize(final_n); // do not forget to shrink the size!
                break;
            }
        }

        return str;
    }

    inline std::string string_format(size_t string_reserve, std::string fmt_str, ...)
    {
        va_list vl;
        va_start(vl, fmt_str);
        std::string str{ std::move(string_format(string_reserve, fmt_str, vl)) };
        va_end(vl);

        return str;
    }

    inline std::wstring string_format(size_t string_reserve, std::wstring fmt_str, ...)
    {
        va_list vl;
        va_start(vl, fmt_str);
        std::wstring str{ std::move(string_format(string_reserve, fmt_str, vl)) };
        va_end(vl);

        return str;
    }

}

#endif
