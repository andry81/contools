#pragma once

// DO NOT REMOVE, exists to avoid private/public headers mixing!
#ifndef TACKLE_PATH_STRING_HPP
#define TACKLE_PATH_STRING_HPP

#include <tacklelib/tacklelib.hpp>

#include <tacklelib/utility/platform.hpp>
#include <tacklelib/utility/type_identity.hpp>
#include <tacklelib/utility/assert.hpp>

#include <tacklelib/tackle/string.hpp>

#include <string>
#include <type_traits>
#include <utility>


// See details around problems related to this class implementation:
//  https://stackoverflow.com/questions/53155089/stdstring-class-inheritance-and-tedious-c-overload-resolution
//  https://godbolt.org/z/jhcWoh
//

namespace tackle
{
    template <class t_elem, class t_traits, class t_alloc, t_elem separator_char>
    class path_basic_string : public std::basic_string<t_elem, t_traits, t_alloc>
    {
    public:
        using base_type = std::basic_string<t_elem, t_traits, t_alloc>;

        FORCE_INLINE path_basic_string() = default;
        FORCE_INLINE path_basic_string(const path_basic_string &) = default;
        FORCE_INLINE path_basic_string(path_basic_string &&) = default;

        FORCE_INLINE path_basic_string & operator =(const path_basic_string &) = default;
        FORCE_INLINE path_basic_string & operator =(path_basic_string &&) = default;

        // implicit or explicit conversion from path with different separator is forbidden

        // sometimes the msvc compiler shows the wrong usage place of a deleted function, old style with a `private` section works better
    private:
        template <t_elem separator_char_>
        path_basic_string(const path_basic_string<t_elem, t_traits, t_alloc, separator_char_> &) = delete;

        template <t_elem separator_char_>
        path_basic_string & operator =(const path_basic_string<t_elem, t_traits, t_alloc, separator_char_> &) = delete;

    public:
        FORCE_INLINE path_basic_string(base_type r) :
            base_type(std::move(r))
        {
        }

        FORCE_INLINE path_basic_string(const t_elem * p) :
            base_type(DEBUG_VERIFY_TRUE(p))
        {
        }

        FORCE_INLINE base_type & str()
        {
            return *this;
        }

        FORCE_INLINE const base_type & str() const
        {
            return *this;
        }

        using base_type::base_type;
        using base_type::operator=;

        // sometimes the msvc compiler shows the wrong usage place of a deleted function, old style with a `private` section works better
    private:
        path_basic_string & operator+= (base_type r) = delete;
        path_basic_string & operator+= (const t_elem * p) = delete;

        // NOTE:
        //  W/o `= delete` to avoid compilation error under msvc2015 update 3: `error C2995: function template has already been defined`
        //

        // WORKAROUND: error C2556: overloaded function differs only by return type from
        template <class t_elem_, class t_traits_, class t_alloc_, t_elem_ separator_char_>
        friend path_basic_string<t_elem_, t_traits_, t_alloc_, separator_char_> operator+ (
            path_basic_string<t_elem_, t_traits_, t_alloc_, separator_char_> l,
            std::basic_string<t_elem_, t_traits_, t_alloc_> r);

        // WORKAROUND: error C2556: overloaded function differs only by return type from
        template <class t_elem_, class t_traits_, class t_alloc_, t_elem_ separator_char_>
        friend path_basic_string<t_elem_, t_traits_, t_alloc_, separator_char_> operator+ (
            std::basic_string<t_elem_, t_traits_, t_alloc_> l,
            path_basic_string<t_elem_, t_traits_, t_alloc_, separator_char_> r);

        template <class t_elem_, class t_traits_, class t_alloc_, t_elem_ separator_char_>
        friend path_basic_string<t_elem_, t_traits_, t_alloc_, separator_char_> operator+ (
            path_basic_string<t_elem_, t_traits_, t_alloc_, separator_char_> l,
            path_basic_string<t_elem_, t_traits_, t_alloc_, separator_char_> r);

        template <class t_elem_, class t_traits_, class t_alloc_, t_elem_ separator_char_>
        friend path_basic_string<t_elem_, t_traits_, t_alloc_, separator_char_> operator+ (
            path_basic_string<t_elem_, t_traits_, t_alloc_, separator_char_> l,
            const t_elem_ * p);

        template <class t_elem_, class t_traits_, class t_alloc_, t_elem_ separator_char_>
        friend path_basic_string<t_elem_, t_traits_, t_alloc_, separator_char_> operator+ (
            const t_elem_ * p,
            path_basic_string<t_elem_, t_traits_, t_alloc_, separator_char_> r);

    public:
        FORCE_INLINE path_basic_string & operator/= (base_type r)
        {
            base_type && r_path = std::move(r);

            base_type & base_this = *this;
            if (!r.empty()) {
                if (!this->empty()) {
                    base_this += UTILITY_LITERAL_STRING_BY_CHAR_ARRAY(t_elem, separator_char).data();
                }
                base_this += r_path;
            }

            return *this;
        }

        FORCE_INLINE path_basic_string & operator/= (const t_elem * p)
        {
            DEBUG_ASSERT_TRUE(p);

            base_type & base_this = *this;
            if (*p) {
                if (!this->empty()) {
                    base_this += UTILITY_LITERAL_STRING_BY_CHAR_ARRAY(t_elem, separator_char).data();
                }
                base_this += p;
            }

            return *this;
        }

        // WORKAROUND: error C2556: overloaded function differs only by return type from
        friend FORCE_INLINE path_basic_string operator/ (path_basic_string l, base_type r)
        {
            path_basic_string && l_path = std::move(l);
            path_basic_string && r_path = std::move(std::forward<base_type>(r));
            l_path /= r_path;
            return l_path;
        }

        // WORKAROUND: error C2556: overloaded function differs only by return type from
        friend FORCE_INLINE path_basic_string operator/ (base_type l, path_basic_string r)
        {
            path_basic_string && l_path = std::move(std::forward<base_type>(l));
            path_basic_string && r_path = std::move(r);
            l_path /= r_path;
            return l_path;
        }

        friend FORCE_INLINE path_basic_string operator/ (path_basic_string l, path_basic_string r)
        {
            path_basic_string && l_path = std::move(l);
            path_basic_string && r_path = std::move(r);
            l_path /= r_path;
            return l_path;
        }

        friend FORCE_INLINE path_basic_string operator/ (path_basic_string l, const t_elem * p)
        {
            DEBUG_ASSERT_TRUE(p);

            path_basic_string && l_path = std::move(l);
            if (*p) {
                l_path /= p;
            }
            return l_path;
        }

        friend FORCE_INLINE path_basic_string operator/ (const t_elem * p, path_basic_string r)
        {
            DEBUG_ASSERT_TRUE(p);

            base_type && r_path = std::move(std::forward<base_type>(r));
            if (!r_path.empty()) {
                if (*p) {
                    // call base operator instead in case if it is specialized for this
                    return p + (UTILITY_LITERAL_STRING_BY_CHAR_ARRAY(t_elem, separator_char).data() + r_path);
                }

                return r_path;
            }

            return p;
        }
    };

    // forward slash path strings
    using path_string       = path_basic_string<char, std::char_traits<char>, std::allocator<char>, literal_separators<char>::forward_slash_char>;
    using path_wstring      = path_basic_string<wchar_t, std::char_traits<wchar_t>, std::allocator<wchar_t>, literal_separators<wchar_t>::forward_slash_char>;

    using path_u16string    = path_basic_string<char16_t, std::char_traits<char16_t>, std::allocator<char16_t>, literal_separators<char16_t>::forward_slash_char>;
    using path_u32string    = path_basic_string<char32_t, std::char_traits<char32_t>, std::allocator<char32_t>, literal_separators<char32_t>::forward_slash_char>;

    // back slash path strings
    using path_string_bs    = path_basic_string<char, std::char_traits<char>, std::allocator<char>, literal_separators<char>::backward_slash_char>;
    using path_wstring_bs   = path_basic_string<wchar_t, std::char_traits<wchar_t>, std::allocator<wchar_t>, literal_separators<wchar_t>::backward_slash_char>;

    using path_u16string_bs = path_basic_string<char16_t, std::char_traits<char16_t>, std::allocator<char16_t>, literal_separators<char16_t>::backward_slash_char>;
    using path_u32string_bs = path_basic_string<char32_t, std::char_traits<char32_t>, std::allocator<char32_t>, literal_separators<char32_t>::backward_slash_char>;

    template <char separator_char>
    using basic_path_string             = path_basic_string<char, std::char_traits<char>, std::allocator<char>, separator_char>;
    template <wchar_t separator_char>
    using basic_path_wstring            = path_basic_string<wchar_t, std::char_traits<wchar_t>, std::allocator<wchar_t>, separator_char>;
    template <char16_t separator_char>
    using basic_path_u16string          = path_basic_string<char16_t, std::char_traits<char16_t>, std::allocator<char16_t>, separator_char>;
    template <char32_t separator_char>
    using basic_path_u32string          = path_basic_string<char32_t, std::char_traits<char32_t>, std::allocator<char32_t>, separator_char>;

    template <class t_elem, class t_traits, class t_alloc>
    using generic_basic_path_string     = path_basic_string<t_elem, t_traits, t_alloc, literal_separators<t_elem>::forward_slash_char>;

#if defined(UTILITY_PLATFORM_WINDOWS)
    template <class t_elem, class t_traits, class t_alloc>
    using native_basic_path_string      = path_basic_string<t_elem, t_traits, t_alloc, literal_separators<t_elem>::backward_slash_char>;
#else
    // native and generic uses the same type here
    template <class t_elem, class t_traits, class t_alloc>
    using native_basic_path_string      = path_basic_string<t_elem, t_traits, t_alloc, literal_separators<t_elem>::forward_slash_char>;
#endif

    using generic_path_string           = generic_basic_path_string<char, std::char_traits<char>, std::allocator<char> >;
    using generic_path_wstring          = generic_basic_path_string<wchar_t, std::char_traits<wchar_t>, std::allocator<wchar_t> >;
    using generic_path_u16string        = generic_basic_path_string<char16_t, std::char_traits<char16_t>, std::allocator<char16_t> >;
    using generic_path_u32string        = generic_basic_path_string<char32_t, std::char_traits<char32_t>, std::allocator<char32_t> >;

    using native_path_string            = native_basic_path_string<char, std::char_traits<char>, std::allocator<char> >;
    using native_path_wstring           = native_basic_path_string<wchar_t, std::char_traits<wchar_t>, std::allocator<wchar_t> >;
    using native_path_u16string         = native_basic_path_string<char16_t, std::char_traits<char16_t>, std::allocator<char16_t> >;
    using native_path_u32string         = native_basic_path_string<char32_t, std::char_traits<char32_t>, std::allocator<char32_t> >;

    // tagging types

    template <typename t_elem, t_elem separator_char>
    struct tag_path_basic_string {};

    template <char separator_char>
    struct tag_basic_path_string        : tag_path_basic_string<char, separator_char> {};
    template <wchar_t separator_char>
    struct tag_basic_path_wstring       : tag_path_basic_string<wchar_t, separator_char> {};
    template <char16_t separator_char>
    struct tag_basic_path_u16string     : tag_path_basic_string<char16_t, separator_char> {};
    template <char32_t separator_char>
    struct tag_basic_path_u32string     : tag_path_basic_string<char32_t, separator_char> {};

    template <typename t_elem>
    struct tag_generic_path_basic_string : tag_path_basic_string<t_elem, literal_separators<t_elem>::forward_slash_char> {};
    template <typename t_elem>
    struct tag_native_path_basic_string : tag_path_basic_string<t_elem, literal_separators<t_elem>::backward_slash_char> {};

    struct tag_path_string              : tag_basic_path_string<literal_separators<char>::forward_slash_char> {};
    struct tag_path_wstring             : tag_basic_path_wstring<literal_separators<wchar_t>::forward_slash_char> {};
    struct tag_path_u16string           : tag_basic_path_u16string<literal_separators<char16_t>::forward_slash_char> {};
    struct tag_path_u32string           : tag_basic_path_u32string<literal_separators<char32_t>::forward_slash_char> {};

    struct tag_path_string_bs           : tag_basic_path_string<literal_separators<char>::backward_slash_char> {};
    struct tag_path_wstring_bs          : tag_basic_path_wstring<literal_separators<wchar_t>::backward_slash_char> {};
    struct tag_path_u16string_bs        : tag_basic_path_u16string<literal_separators<char16_t>::backward_slash_char> {};
    struct tag_path_u32string_bs        : tag_basic_path_u32string<literal_separators<char32_t>::backward_slash_char> {};

    template <class t_elem>
    struct tag_generic_basic_path_string : tag_generic_path_basic_string<t_elem> {};

    struct tag_generic_path_string      : tag_generic_path_basic_string<char>, tag_basic_path_string<literal_separators<char>::forward_slash_char> {};
    struct tag_generic_path_wstring     : tag_generic_path_basic_string<wchar_t>, tag_basic_path_wstring<literal_separators<wchar_t>::forward_slash_char> {};
    struct tag_generic_path_u16string   : tag_generic_path_basic_string<char16_t>, tag_basic_path_u16string<literal_separators<char16_t>::forward_slash_char> {};
    struct tag_generic_path_u32string   : tag_generic_path_basic_string<char32_t>, tag_basic_path_u32string<literal_separators<char32_t>::forward_slash_char> {};

    template <class t_elem>
    struct tag_native_basic_path_string : tag_native_path_basic_string<t_elem> {};

    struct tag_native_path_string       : tag_native_path_basic_string<char>, tag_basic_path_string<literal_separators<char>::backward_slash_char> {};
    struct tag_native_path_wstring      : tag_native_path_basic_string<wchar_t>, tag_basic_path_wstring<literal_separators<wchar_t>::backward_slash_char> {};
    struct tag_native_path_u16string    : tag_native_path_basic_string<char16_t>, tag_basic_path_u16string<literal_separators<char16_t>::backward_slash_char> {};
    struct tag_native_path_u32string    : tag_native_path_basic_string<char32_t>, tag_basic_path_u32string<literal_separators<char32_t>::backward_slash_char> {};

    template <typename t_elem, t_elem separator_char>
    struct tag_basic_path_string_by_separator_char :
        std::conditional<UTILITY_CONST_EXPR(separator_char == literal_separators<t_elem>::forward_slash_char),
            tag_generic_basic_path_string<t_elem>,
            typename std::conditional<UTILITY_CONST_EXPR(separator_char == literal_separators<t_elem>::backward_slash_char),
                tag_native_basic_path_string<t_elem>,
                utility::void_
            >::type
        >::type
    {
    };

    template <typename t_elem, t_elem separator_char>
    struct tag_basic_path_string_by_elem :
        std::conditional<std::is_same<char, t_elem>::value,
            tag_basic_path_string<separator_char>,
            typename std::conditional<std::is_same<wchar_t, t_elem>::value,
                tag_basic_path_wstring<separator_char>,
                typename std::conditional<std::is_same<char16_t, t_elem>::value,
                    tag_basic_path_u16string<separator_char>,
                    typename std::conditional<std::is_same<char32_t, t_elem>::value,
                        tag_basic_path_u32string<separator_char>,
                        utility::void_
                    >::type
                >::type
            >::type
        >::type
    {
    };

}

#endif
