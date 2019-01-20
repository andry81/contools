#pragma once

// DO NOT REMOVE, exists to avoid private/public headers mixing!
#ifndef TACKLE_STRING_HPP
#define TACKLE_STRING_HPP

#include <tacklelib/tacklelib.hpp>

#include <tacklelib/utility/preprocessor.hpp>
#include <tacklelib/utility/platform.hpp>
#include <tacklelib/utility/string.hpp>

#include <string>
#include <array>
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


// hint: operator* applies to character literals, but not to double-quoted literals
#define UTILITY_LITERAL_CHAR_(c_str, char_type)         ((void)(c_str * 0), ::tackle::literal_char_caster<char_type>::cast_from(c_str, L ## c_str, u ## c_str, U ## c_str))

// hint: operator[] applies to double-quoted literals, but is not to character literals
#define UTILITY_LITERAL_STRING_(c_str, char_type)       ((void)(c_str[0]), ::tackle::literal_string_caster<char_type>::cast_from(c_str, L ## c_str, u ## c_str, U ## c_str))

#define UTILITY_LITERAL_CHAR(c_str, char_type)          UTILITY_LITERAL_CHAR_(c_str, char_type)
#define UTILITY_LITERAL_STRING(c_str, char_type)        UTILITY_LITERAL_STRING_(c_str, char_type)

#define UTILITY_LITERAL_STRING_LEN_(c_str, char_type)   ((void)(c_str[0]), sizeof(c_str))
#define UTILITY_LITERAL_STRING_LEN(c_str, char_type)    UTILITY_LITERAL_STRING_LEN_(c_str, char_type)

#define UTILITY_LITERAL_STRING_BY_CHAR_ARRAY(char_type, ...) \
    ((void)(UTILITY_PP_MACRO_ARG0(__VA_ARGS__) * 0), ::tackle::literal_string_from_chars<char_type>(__VA_ARGS__, UTILITY_LITERAL_CHAR('\0', char_type)))


namespace tackle {

    template <typename CharT, size_t S>
    using literal_basic_string_const_arr                            = const CharT[S];

    template <typename CharT, size_t S>
    using literal_basic_string_arr                                  = CharT[S];

    template <typename CharT, size_t S>
    using literal_basic_string_const_reference_arr                  = const CharT (&)[S];

    template <typename CharT, size_t S>
    using literal_basic_string_reference_arr                        = CharT (&)[S];

    template <typename CharT, size_t S>
    using literal_char_array                                        = std::array<CharT, S>;

    template <size_t S> using literal_string_const_reference_arr    = literal_basic_string_const_reference_arr<char, S>;
    template <size_t S> using literal_string_reference_arr          = literal_basic_string_reference_arr<char, S>;

    template <size_t S> using literal_wstring_const_reference_arr   = literal_basic_string_const_reference_arr<wchar_t, S>;
    template <size_t S> using literal_wstring_reference_arr         = literal_basic_string_reference_arr<wchar_t, S>;

    template <size_t S> using literal_u16string_const_reference_arr = literal_basic_string_const_reference_arr<char16_t, S>;
    template <size_t S> using literal_u16string_reference_arr       = literal_basic_string_reference_arr<char16_t, S>;

    template <size_t S> using literal_u32string_const_reference_arr = literal_basic_string_const_reference_arr<char32_t, S>;
    template <size_t S> using literal_u32string_reference_arr       = literal_basic_string_reference_arr<char32_t, S>;

    //// literal_char_caster, literal_string_caster

    // template class to replace partial function specialization and avoid overload over different return types
    template <typename CharT>
    struct literal_char_caster;
    template <typename CharT>
    struct literal_string_caster;

    template <>
    struct literal_char_caster<char>
    {
        FORCE_INLINE static CONSTEXPR char
            cast_from(
                char ach,
                wchar_t wch,
                char16_t char16ch,
                char32_t char32ch)
        {
            return ach;
        }
    };

    template <>
    struct literal_char_caster<wchar_t>
    {
        FORCE_INLINE static CONSTEXPR wchar_t
            cast_from(
                char ach,
                wchar_t wch,
                char16_t char16ch,
                char32_t char32ch)
        {
            return wch;
        }
    };

    template <>
    struct literal_char_caster<char16_t>
    {
        FORCE_INLINE static CONSTEXPR char16_t
            cast_from(
                char ach,
                wchar_t wch,
                char16_t char16ch,
                char32_t char32ch)
        {
            return char16ch;
        }
    };

    template <>
    struct literal_char_caster<char32_t>
    {
        FORCE_INLINE static CONSTEXPR char32_t
            cast_from(
                char ach,
                wchar_t wch,
                char16_t char16ch,
                char32_t char32ch)
        {
            return char32ch;
        }
    };

    // Based on: https://stackoverflow.com/questions/3703658/specifying-one-type-for-all-arguments-passed-to-variadic-function-or-variadic-te
    //

    namespace details {

        template <typename R, typename...>
        struct fst
        {
            using type = R;
        };

    }

    template <typename CharT, typename... Args>
    FORCE_INLINE static CONSTEXPR
        typename details::fst<literal_char_array<CharT, sizeof...(Args)>,
            typename std::enable_if<
                std::is_convertible<Args, CharT>::value
            >::type...
        >::type
        literal_string_from_chars(Args... args)
    {
        return{{ args... }};
    }

    //template <typename CharT>
    //FORCE_INLINE static CONSTEXPR auto
    //    literal_string_from_chars(CharT... args) -> literal_string_const_reference_arr<sizeof...(args)>
    //{
    //    return { args... };
    //}

    template <>
    struct literal_string_caster<char>
    {
        template <size_t S>
        FORCE_INLINE static CONSTEXPR literal_string_const_reference_arr<S>
            cast_from(
                literal_string_const_reference_arr<S> astr,
                literal_wstring_const_reference_arr<S> wstr,
                literal_u16string_const_reference_arr<S> char16str,
                literal_u32string_const_reference_arr<S> char32str)
        {
            return astr;
        }
    };

    template <>
    struct literal_string_caster<wchar_t>
    {
        template <size_t S>
        FORCE_INLINE static CONSTEXPR literal_wstring_const_reference_arr<S>
            cast_from(
                literal_string_const_reference_arr<S> astr,
                literal_wstring_const_reference_arr<S> wstr,
                literal_u16string_const_reference_arr<S> char16str,
                literal_u32string_const_reference_arr<S> char32str)
        {
            return wstr;
        }
    };

    template <>
    struct literal_string_caster<char16_t>
    {
        template <size_t S>
        FORCE_INLINE static CONSTEXPR literal_u16string_const_reference_arr<S>
            cast_from(
                literal_string_const_reference_arr<S> astr,
                literal_wstring_const_reference_arr<S> wstr,
                literal_u16string_const_reference_arr<S> char16str,
                literal_u32string_const_reference_arr<S> char32str)
        {
            return char16str;
        }
    };

    template <>
    struct literal_string_caster<char32_t>
    {
        template <size_t S>
        FORCE_INLINE static CONSTEXPR literal_u32string_const_reference_arr<S>
            cast_from(
                literal_string_const_reference_arr<S> astr,
                literal_wstring_const_reference_arr<S> wstr,
                literal_u16string_const_reference_arr<S> char16str,
                literal_u32string_const_reference_arr<S> char32str)
        {
            return char32str;
        }
    };

    //// literal_separators

    template <typename CharT>
    struct literal_separators
    {
        using forward_slash_str_t                                   = literal_basic_string_const_arr<CharT, UTILITY_LITERAL_STRING_LEN("/", CharT)>;
        using backward_slash_str_t                                  = literal_basic_string_const_arr<CharT, UTILITY_LITERAL_STRING_LEN("\\", CharT)>;
        using space_str_t                                           = literal_basic_string_const_arr<CharT, UTILITY_LITERAL_STRING_LEN(" ", CharT)>;

        static CONSTEXPR forward_slash_str_t forward_slash_str      = UTILITY_LITERAL_STRING("/", CharT);
        static CONSTEXPR backward_slash_str_t backward_slash_str    = UTILITY_LITERAL_STRING("\\", CharT);
        static CONSTEXPR space_str_t space_str                      = UTILITY_LITERAL_STRING(" ", CharT);

        static CONSTEXPR const CharT forward_slash_char             = UTILITY_LITERAL_CHAR('/', CharT);
        static CONSTEXPR const CharT backward_slash_char            = UTILITY_LITERAL_CHAR('\\', CharT);
        static CONSTEXPR const CharT space_char                     = UTILITY_LITERAL_CHAR(' ', CharT);

        // back slash separator has meaning only on the Windows systems in the UNC paths
        static CONSTEXPR const CharT filesystem_unc_dir_separator_char = backward_slash_char;
    };

}

#endif
