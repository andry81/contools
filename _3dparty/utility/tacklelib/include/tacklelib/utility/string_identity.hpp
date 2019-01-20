#pragma once

// DO NOT REMOVE, exists to avoid private/public headers mixing!
#ifndef UTILITY_STRING_IDENTITY_HPP
#define UTILITY_STRING_IDENTITY_HPP

#include <tacklelib/tacklelib.hpp>

#include <tacklelib/utility/platform.hpp>
#include <tacklelib/utility/type_identity.hpp>

#include <cwchar>
#include <uchar.h> // in GCC `cuchar` header might not exist
#include <string>
#include <memory>
#include <type_traits>


namespace utility {

    template <typename T>
    struct basic_char_identity {};

    template <>
    struct basic_char_identity<char>
    {
        static CONSTEXPR const size_t type_index = 0;
    };

    template <>
    struct basic_char_identity<wchar_t>
    {
        static CONSTEXPR const size_t type_index = 1;
    };

    template <>
    struct basic_char_identity<char16_t>
    {
        static CONSTEXPR const size_t type_index = 2;
    };

    template <>
    struct basic_char_identity<char32_t>
    {
        static CONSTEXPR const size_t type_index = 3;
    };

    using char_identity         = basic_char_identity<char>;
    using wchar_identity        = basic_char_identity<wchar_t>;
    using char16_identity       = basic_char_identity<char16_t>;
    using char32_identity       = basic_char_identity<char32_t>;

    struct tag_char             : char_identity {};
    struct tag_wchar            : wchar_identity {};
    struct tag_char16           : char16_identity {};
    struct tag_char32           : char32_identity {};

    template <typename t_elem>
    struct tag_char_by_elem :
        std::conditional<std::is_same<char, t_elem>::value,
            tag_char,
            typename std::conditional<std::is_same<wchar_t, t_elem>::value,
                tag_wchar,
                typename std::conditional<std::is_same<char16_t, t_elem>::value,
                    tag_char16,
                    typename std::conditional<std::is_same<char32_t, t_elem>::value,
                        tag_char32,
                        utility::void_
                    >::type
                >::type
            >::type
        >::type
    {
    };

    template <class t_elem, class t_traits, class t_alloc>
    struct basic_string_identity {};

    using string_identity       = basic_string_identity<char, std::char_traits<char>, std::allocator<char> >;
    using wstring_identity      = basic_string_identity<wchar_t, std::char_traits<wchar_t>, std::allocator<wchar_t> >;
    using u16string_identity    = basic_string_identity<char16_t, std::char_traits<char16_t>, std::allocator<char16_t> >;
    using u32string_identity    = basic_string_identity<char32_t, std::char_traits<char32_t>, std::allocator<char32_t> >;

    struct tag_string           : string_identity {};
    struct tag_wstring          : wstring_identity {};
    struct tag_u16string        : u16string_identity {};
    struct tag_u32string        : u32string_identity {};

    template <typename t_elem>
    struct tag_string_by_elem :
        std::conditional<std::is_same<char, t_elem>::value,
            tag_string,
            typename std::conditional<std::is_same<wchar_t, t_elem>::value,
                tag_wstring,
                typename std::conditional<std::is_same<char16_t, t_elem>::value,
                    tag_u16string,
                    typename std::conditional<std::is_same<char32_t, t_elem>::value,
                        tag_u32string,
                        utility::void_
                    >::type
                >::type
            >::type
        >::type
    {
    };

}


#endif
