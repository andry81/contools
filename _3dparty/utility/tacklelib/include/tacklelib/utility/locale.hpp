#pragma once

#include <tacklelib/tacklelib.hpp>

#include <tacklelib/utility/platform.hpp>
#include <tacklelib/utility/type_identity.hpp>

#include <tacklelib/tackle/string.hpp>

#include <locale>
#include <codecvt>
#include <utility>


namespace utility {

    enum StringConvertionType
    {
        StringConv_utf8_to_utf16        = 1,
        StringConv_utf16_to_utf8        = 2,
        StringConv_utf8_tofrom_utf16    = 3,
    };

    struct tag_string_conv_utf8_to_utf16 : utility::int_identity<StringConv_utf8_to_utf16> {};
    struct tag_string_conv_utf16_to_utf8 : utility::int_identity<StringConv_utf16_to_utf8> {};
    struct tag_string_conv_utf8_tofrom_utf16 : utility::int_identity<StringConv_utf8_tofrom_utf16> {};

    FORCE_INLINE const std::string & convert_utf16_to_utf8_string(const std::string & astr)
    {
        return astr;
    }

    template <class Codecvt, class Elem, class Walloc = std::allocator<Elem>, class Balloc = std::allocator<char> >
    FORCE_INLINE std::string convert_utf16_to_utf8_string(const std::wstring & wstr, std::wstring_convert<Codecvt, Elem, Walloc, Balloc> && wstr_converter)
    {
        return wstr_converter.to_bytes(wstr);
    }

    FORCE_INLINE std::string convert_utf16_to_utf8_string(const std::wstring & wstr)
    {
        using wstring_convert_t = std::wstring_convert<std::codecvt_utf8_utf16<wchar_t>, wchar_t>;

        return convert_utf16_to_utf8_string(wstr, wstring_convert_t{});
    }

    template <class Codecvt, class Elem, class Walloc = std::allocator<Elem>, class Balloc = std::allocator<char> >
    FORCE_INLINE std::string convert_utf16_to_utf8_string(const std::u16string & u16str, std::wstring_convert<Codecvt, Elem, Walloc, Balloc> && u16str_converter)
    {
        return u16str_converter.to_bytes(u16str);
    }

    FORCE_INLINE std::string convert_utf16_to_utf8_string(const std::u16string & u16str)
    {
        using wstring_convert_t = std::wstring_convert<std::codecvt_utf8_utf16<char16_t>, char16_t>;

        return convert_utf16_to_utf8_string(u16str, wstring_convert_t{});
    }

    template <class Codecvt, class Elem, class Walloc = std::allocator<Elem>, class Balloc = std::allocator<char> >
    FORCE_INLINE std::string convert_utf16_to_utf8_string(const std::u32string & u32str, std::wstring_convert<Codecvt, Elem, Walloc, Balloc> && u32str_converter)
    {
        return u32str_converter.to_bytes(u32str);
    }

    FORCE_INLINE std::string convert_utf16_to_utf8_string(const std::u32string & u32str)
    {
        using wstring_convert_t = std::wstring_convert<std::codecvt_utf8_utf16<char32_t>, char32_t>;

        return convert_utf16_to_utf8_string(u32str, wstring_convert_t{});
    }


    template <class Codecvt, class Walloc = std::allocator<wchar_t>, class Balloc = std::allocator<char> >
    FORCE_INLINE std::wstring convert_utf8_to_utf16_string(const std::string & astr, std::wstring_convert<Codecvt, wchar_t, Walloc, Balloc> && wstr_converter)
    {
        return wstr_converter.from_bytes(astr);
    }

    FORCE_INLINE std::wstring convert_utf8_to_utf16_string(const std::string & astr, utility::wstring_identity)
    {
        using wstring_convert_t = std::wstring_convert<std::codecvt_utf8_utf16<wchar_t>, wchar_t>;

        return convert_utf8_to_utf16_string(astr, wstring_convert_t{});
    }

    template <class Codecvt, class Walloc = std::allocator<char16_t>, class Balloc = std::allocator<char> >
    FORCE_INLINE std::u16string convert_utf8_to_utf16_string(const std::string & astr, std::wstring_convert<Codecvt, char16_t, Walloc, Balloc> && wstr_converter)
    {
        return wstr_converter.from_bytes(astr);
    }

    FORCE_INLINE std::u16string convert_utf8_to_utf16_string(const std::string & astr, utility::tag_u16string)
    {
        using wstring_convert_t = std::wstring_convert<std::codecvt_utf8_utf16<char16_t>, char16_t>;

        return convert_utf8_to_utf16_string(astr, wstring_convert_t{});
    }

    template <class Codecvt, class Walloc = std::allocator<char32_t>, class Balloc = std::allocator<char> >
    FORCE_INLINE std::u32string convert_utf8_to_utf16_string(const std::string & astr, std::wstring_convert<Codecvt, char32_t, Walloc, Balloc> && wstr_converter)
    {
        return wstr_converter.from_bytes(astr);
    }

    FORCE_INLINE std::u32string convert_utf8_to_utf16_string(const std::string & astr, utility::tag_u32string)
    {
        using wstring_convert_t = std::wstring_convert<std::codecvt_utf8_utf16<char32_t>, char32_t>;

        return convert_utf8_to_utf16_string(astr, wstring_convert_t{});
    }

    // tagged functions

    FORCE_INLINE void convert_string_to_string(std::string from_str, std::string & to_path, ...)
    {
        to_path = std::move(from_str);
    }

    FORCE_INLINE void convert_string_to_string(std::string from_str, std::wstring & to_path, utility::int_identity<StringConv_utf8_to_utf16>)
    {
        to_path = convert_utf8_to_utf16_string(std::move(from_str), utility::tag_wstring{});
    }

    FORCE_INLINE void convert_string_to_string(std::string from_str, std::wstring & to_path, utility::int_identity<StringConv_utf8_tofrom_utf16>)
    {
        to_path = convert_utf8_to_utf16_string(std::move(from_str), utility::tag_wstring{});
    }

    FORCE_INLINE void convert_string_to_string(std::wstring from_str, std::wstring & to_path, ...)
    {
        to_path = std::move(from_str);
    }

    FORCE_INLINE void convert_string_to_string(std::wstring from_str, std::string & to_path, utility::int_identity<StringConv_utf16_to_utf8>)
    {
        to_path = convert_utf16_to_utf8_string(std::move(from_str));
    }

    FORCE_INLINE void convert_string_to_string(std::wstring from_str, std::string & to_path, utility::int_identity<StringConv_utf8_tofrom_utf16>)
    {
        to_path = convert_utf16_to_utf8_string(std::move(from_str));
    }

    FORCE_INLINE std::string convert_string_to_string(std::string from_str, utility::string_identity, ...)
    {
        return std::move(from_str);
    }

    FORCE_INLINE std::wstring convert_string_to_string(std::string from_str, utility::wstring_identity, utility::int_identity<StringConv_utf8_to_utf16>)
    {
        return convert_utf8_to_utf16_string(std::move(from_str), utility::tag_wstring{});
    }

    FORCE_INLINE std::wstring convert_string_to_string(std::string from_str, utility::wstring_identity, utility::int_identity<StringConv_utf8_tofrom_utf16>)
    {
        return convert_utf8_to_utf16_string(std::move(from_str), utility::tag_wstring{});
    }

    FORCE_INLINE std::wstring convert_string_to_string(std::wstring from_str, utility::wstring_identity, ...)
    {
        return std::move(from_str);
    }

    FORCE_INLINE std::string convert_string_to_string(std::wstring from_str, utility::string_identity, utility::int_identity<StringConv_utf16_to_utf8>)
    {
        return convert_utf16_to_utf8_string(std::move(from_str));
    }

    FORCE_INLINE std::string convert_string_to_string(std::wstring from_str, utility::string_identity, utility::int_identity<StringConv_utf8_tofrom_utf16>)
    {
        return convert_utf16_to_utf8_string(std::move(from_str));
    }

}
