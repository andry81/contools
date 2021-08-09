#pragma once

// DO NOT REMOVE, exists to avoid private/public headers mixing!
#ifndef UTILITY_STRING_IDENTITY_HPP
#define UTILITY_STRING_IDENTITY_HPP

#include <string>
#include <array>
#include <cstring>
#include <cstddef>
#include <cstdarg>
#include <cstdio>
#include <cstdlib>
#include <cstdint>
#include <cwchar>
#if !defined(UTILITY_PLATFORM_MINGW) && !defined(UTILITY_COMPILER_CXX_GCC)
#   include <uchar.h> // in GCC `cuchar` header might not exist
#endif
#include <memory>
#include <algorithm>
#include <type_traits>


#define UTILITY_LITERAL_STRING_WITH_PREFIX_(ansi_str, prefix) prefix ## ansi_str
#define UTILITY_LITERAL_STRING_WITH_PREFIX(ansi_str, prefix) UTILITY_LITERAL_STRING_WITH_PREFIX_(ansi_str, prefix)


namespace utility {

    template <class t_elem, class t_traits, class t_alloc>
    struct basic_string_identity {};

    template <class t_traits, class t_alloc>
    struct basic_string_identity<char, t_traits, t_alloc>
    {
        static constexpr const size_t type_index = 0;
    };

    template <class t_traits, class t_alloc>
    struct basic_string_identity<wchar_t, t_traits, t_alloc>
    {
        static constexpr const size_t type_index = 1;
    };

    template <class t_traits, class t_alloc>
    struct basic_string_identity<char16_t, t_traits, t_alloc>
    {
        static constexpr const size_t type_index = 2;
    };

    template <class t_traits, class t_alloc>
    struct basic_string_identity<char32_t, t_traits, t_alloc>
    {
        static constexpr const size_t type_index = 3;
    };

    using string_identity       = basic_string_identity<char, std::char_traits<char>, std::allocator<char> >;
    using wstring_identity      = basic_string_identity<wchar_t, std::char_traits<wchar_t>, std::allocator<wchar_t> >;
    using u16string_identity    = basic_string_identity<char16_t, std::char_traits<char16_t>, std::allocator<char16_t> >;
    using u32string_identity    = basic_string_identity<char32_t, std::char_traits<char32_t>, std::allocator<char32_t> >;

    // all tags must be derived as a new type
    template <class t_elem, class t_traits, class t_alloc>
    struct tag_basic_string     : basic_string_identity<t_elem, t_traits, t_alloc> {};

    struct tag_string           : string_identity {};
    struct tag_wstring          : wstring_identity {};
    struct tag_u16string        : u16string_identity {};
    struct tag_u32string        : u32string_identity {};

}

#endif
