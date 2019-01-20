#pragma once

// DO NOT REMOVE, exists to avoid private/public headers mixing!
#ifndef TACKLE_DATE_TIME_HPP
#define TACKLE_DATE_TIME_HPP

#include <tacklelib/tacklelib.hpp>

#include <tacklelib/utility/platform.hpp>
#include <tacklelib/utility/type_identity.hpp>
#include <tacklelib/utility/type_traits.hpp>
#include <tacklelib/utility/addressof.hpp>
#include <tacklelib/utility/debug.hpp>
#include <tacklelib/utility/memory.hpp>
#include <tacklelib/utility/time.hpp>
#include <tacklelib/utility/utility.hpp>

//#include <tacklelib/tackle/string.hpp>

#include <fmt/format.h>
#include <fmt/time.h>

#include <cstdint>
#include <string>
#include <iomanip>
//#include <regex>
#include <locale>
//#include <cctype>
#include <utility>


// Template date and time container with these features:
//  * arbitrary storage type with respective copy constructor
//  * constructable from the date/time in a string
//
namespace tackle
{
    template <typename T, class t_elem, class t_traits, class t_alloc>
    class basic_date_time
    {
        using uncval_type = typename utility::remove_cvref<T>::type;

    public:
        enum StorageType
        {
            StorageType_Unknown = -1,
            StorageType_Custom  = 1,     // T
            StorageType_String  = 2      // string_type
        };

        struct tag_storage_custom_type : utility::int_identity<StorageType_Custom> {};
        struct tag_storage_string_type : utility::int_identity<StorageType_String> {};

    protected:
        using string_type = std::basic_string<t_elem, t_traits, t_alloc>;
//        using regex_type = std::basic_regex<t_elem>;
//
//        struct RegexAssoc
//        {
//            t_elem      placeholder;
//            string_type regex_replace_str;
//        };

//        static const RegexAssoc s_regex_assocs[] =
//        {
//            { UTILITY_LITERAL_CHAR('C', t_elem), UTILITY_LITERAL_STRING("[0-9][0-9]", t_elem) },                    // 00-99
//            { UTILITY_LITERAL_CHAR('d', t_elem), UTILITY_LITERAL_STRING("0[1-9]|[1-2][0-9]|3[0-1]", t_elem) },      // 01-31
//            { UTILITY_LITERAL_CHAR('H', t_elem), UTILITY_LITERAL_STRING("[0-1][0-9]|2[0-3]", t_elem) },             // 00-23
//            { UTILITY_LITERAL_CHAR('I', t_elem), UTILITY_LITERAL_STRING("0[1-9]|1[0-2]", t_elem) },                 // 01-12
//            { UTILITY_LITERAL_CHAR('j', t_elem), UTILITY_LITERAL_STRING("00[1-9]|0[1-9][0-9]|[1-2][0-9][0-9]|3[0-5][0-9]|36[0-6]", t_elem) },   // 001-366
//            { UTILITY_LITERAL_CHAR('m', t_elem), UTILITY_LITERAL_STRING("0[1-9]|1[0-2]", t_elem) },                 // 01-12
//            { UTILITY_LITERAL_CHAR('M', t_elem), UTILITY_LITERAL_STRING("[0-5][0-9]", t_elem) },                    // 00-59
//            { UTILITY_LITERAL_CHAR('S', t_elem), UTILITY_LITERAL_STRING("[0-5][0-9]|6[0-1]", t_elem) },             // 00-61
//            { UTILITY_LITERAL_CHAR('u', t_elem), UTILITY_LITERAL_STRING("[1-7]", t_elem) },                         // 1-7
//            { UTILITY_LITERAL_CHAR('U', t_elem), UTILITY_LITERAL_STRING("[0-4][0-9]|5[0-3]", t_elem) },             // 00-53
//            { UTILITY_LITERAL_CHAR('V', t_elem), UTILITY_LITERAL_STRING("0[1-9]|[1-4][0-9]|5[0-3]", t_elem) },      // 01-53
//            { UTILITY_LITERAL_CHAR('w', t_elem), UTILITY_LITERAL_STRING("[0-6]", t_elem) },                         // 0-6
//            { UTILITY_LITERAL_CHAR('W', t_elem), UTILITY_LITERAL_STRING("[0-4][0-9]|5[0-3]", t_elem) },             // 00-53
//            { UTILITY_LITERAL_CHAR('y', t_elem), UTILITY_LITERAL_STRING("[0-9][0-9]", t_elem) },                    // 00-99
//            { UTILITY_LITERAL_CHAR('Y', t_elem), UTILITY_LITERAL_STRING("[0-9][0-9][0-9][0-9]", t_elem) },          // 0000-9999
//        };

    public:
        FORCE_INLINE basic_date_time(StorageType storage_type__ = StorageType_Custom) :
            storage_type_{ storage_type__ }
        {
            switch (storage_type__) {
            case StorageType_Unknown: // internal delayed construction
                break;
            case StorageType_Custom:
                ::new (utility::addressof(custom)) T{};
                break;
            case StorageType_String:
                ::new (utility::addressof(string_)) string_type{};
                break;
            default:
                DEBUG_ASSERT_TRUE(false);
            }
        }

        FORCE_INLINE basic_date_time(T r) :
            storage_type_{ StorageType_Custom },
            custom(std::move(r))
        {
        }

        FORCE_INLINE basic_date_time(string_type r) :
            storage_type_{ StorageType_String },
            string_(std::move(r))
        {
        }

        FORCE_INLINE basic_date_time(const t_elem * p) :
            storage_type_{ StorageType_String },
            string_(p)
        {
        }

        // store with convertion into custom type, format string is partially compatible with the std::strftime
        FORCE_INLINE basic_date_time(const string_type & fmt, string_type time_str, const std::string & locale = "C", bool throw_on_error = true) :
            storage_type_{ StorageType_Unknown }
        {
            reset(fmt, std::move(time_str), locale, throw_on_error);

//            const size_t time_fmt_len = time_fmt.length();
//
//            string_type regex_time_fmt_str;
//
//            bool is_control_char = false;
//            size_t prev_char_index = 0;
//            t_elem prev_char;
//
//            for (size_t char_index = 0; char_index < time_fmt_len; char_index++) {
//                const t_elem ch = time_fmt;
//                if (!is_escaped_char) {
//                    if (ch != UTILITY_LITERAL_CHAR("%", t_elem)) {
//                        // escape only if not usual character symbol!
//                        if (!std::isdigit(ch, loc) && !std::isalpha(ch, loc) && ch != UTILITY_LITERAL_CHAR('_', t_elem)) {
//                            regex_time_fmt_str += UTILITY_LITERAL_STRING("\\", t_elem);
//                        }
//                        regex_time_fmt_str += ch;
//                    }
//                    else {
//                        is_escaped_char = true;
//                    }
//                }
//                else {
//                    if (ch != UTILITY_LITERAL_CHAR("%", t_elem)) {
//                        bool is_known_placeholder = false;
//                        for (const auto & regex_assocs : s_regex_assocs) {
//                            if (ch == regex_assocs.placeholder) {
//                                is_known_placeholder = true;
//                                regex_time_fmt_str += regex_assocs.regex_replace_str;
//                                break;
//                            }
//                        }
//                        if (!is_known_placeholder) {
//                            // output as plain text
//                            regex_time_fmt_str += UTILITY_LITERAL_STRING("\\%\\", t_elem);
//                            regex_time_fmt_str += ch;
//                        }
//                    }
//                    else {
//                        regex_time_fmt_str += UTILITY_LITERAL_STRING("\\%", t_elem);
//                    }
//
//                    is_escaped_char = false;
//                }
//            }
//
//            if (is_control_char) {
//                // unclosed escape sequence
//                regex_time_fmt_str += UTILITY_LITERAL_STRING("\\%", t_elem);
//            }
//
//            std::smatch time_str_match;
//            if (std::regex_search(time_str, time_str_match,
//                regex_type{ regex_time_fmt_str, std::regex_constants::ECMAScript | std::regex_constants::icase })) {
//
//                std::tm time;
//                std::get_time(&time, time_str);
//            }
        }

        FORCE_INLINE basic_date_time(const basic_date_time & r) :
            storage_type_(r.storage_type_)
        {
            switch (r.storage_type_) {
            case StorageType_Custom:
                ::new (utility::addressof(custom)) T{ r.custom };
                break;
            case StorageType_String:
                ::new (utility::addressof(string_)) string_type{ r.string_ };
                break;
            default:
                DEBUG_ASSERT_TRUE(false);
            }
        }

        FORCE_INLINE basic_date_time(basic_date_time && r) :
            storage_type_(r.storage_type_)
        {
            basic_date_time && r_time = std::move(r);

            switch (r.storage_type_) {
            case StorageType_Custom:
                ::new (utility::addressof(custom)) T{ r_time.custom };
                break;
            case StorageType_String:
                ::new (utility::addressof(string_)) string_type{ r_time.string_ };
                break;
            default:
                DEBUG_ASSERT_TRUE(false);
            }
        }

        FORCE_INLINE basic_date_time & operator =(T r)
        {
            reset(std::move(r));
            return *this;
        }

        FORCE_INLINE basic_date_time & operator =(string_type r)
        {
            reset(std::move(r));
            return *this;
        }

        FORCE_INLINE basic_date_time & operator =(const t_elem * p)
        {
            reset(p);
            return *this;
        }

        FORCE_INLINE basic_date_time & operator =(basic_date_time r)
        {
            reset(std::move(r));
            return *this;
        }

        FORCE_INLINE void reset(StorageType storage_type__ = StorageType_Custom)
        {
            _destruct();

            storage_type_ = storage_type__;

            switch (storage_type__) {
            case StorageType_Custom:
                ::new (utility::addressof(custom)) T{};
                break;
            case StorageType_String:
                ::new (utility::addressof(string_)) string_type{};
                break;
            default:
                DEBUG_ASSERT_TRUE(false);
            }
        }

        FORCE_INLINE void reset(T r)
        {
            T && r_time = std::move(r);

            const StorageType prev_storage_type = storage_type_;

            if (prev_storage_type != StorageType_Custom) {
                _destruct();
                ::new (utility::addressof(custom)) T{ r_time };
            }
            else {
                custom = r_time;
            }
        }

        FORCE_INLINE void reset(string_type r)
        {
            string_type && r_rref = std::move(r);

            const StorageType prev_storage_type = storage_type_;

            if (prev_storage_type != StorageType_String) {
                _destruct();
                ::new (utility::addressof(string_)) string_type{ r_rref };
            }
            else {
                string_ = r_rref;
            }
        }

        FORCE_INLINE void reset(const t_elem * p)
        {
            const StorageType prev_storage_type = storage_type_;

            if (prev_storage_type != StorageType_String) {
                _destruct();
                ::new (utility::addressof(string_)) string_type{ p };
            }
            else {
                string_ = p;
            }
        }

        // store with convertion into custom type, format string is partially compatible with the std::strftime
        FORCE_INLINE void reset(const string_type & fmt, string_type time_str, const std::string & locale = "C", bool throw_on_error = true)
        {
            string_type && time_str_rref = std::move(time_str);

            std::tm time{};

            if (!utility::time::get_time(time, locale, fmt, time_str_rref)) {
                if (throw_on_error) {
                    DEBUG_BREAK_THROW(true) std::runtime_error(fmt::format("{:s}({:d}): time format string is invalid",
                        UTILITY_PP_FUNCSIG, UTILITY_PP_LINE));
                }
                else {
                    return;
                }
            }

            storage_type_ = StorageType_Custom;
            custom = static_cast<T>(utility::time::timegm(time));
        }

        FORCE_INLINE void reset(basic_date_time r)
        {
            basic_date_time && r_time = std::move(r);

            const StorageType prev_storage_type = storage_type_;

            const bool do_reconstruct = (prev_storage_type != r.storage_type_);
            if (do_reconstruct) {
                _destruct();
            }

            storage_type_ = r.storage_type_;

            switch (r.storage_type_) {
            case StorageType_Custom:
                if (do_reconstruct) {
                    ::new (utility::addressof(custom)) T{ r_time.custom };
                }
                else {
                    custom = r_time.custom;
                }
                break;
            case StorageType_String:
                if (do_reconstruct) {
                    ::new (utility::addressof(string_)) string_type{ r_time.string_ };
                }
                else {
                    string_ = r_time.string_;
                }
                break;
            default:
                DEBUG_ASSERT_TRUE(false);
            }
        }

    protected:
        FORCE_INLINE void _destruct()
        {
            switch (storage_type_) {
            case StorageType_Unknown:
                break;
            case StorageType_Custom:
                this->custom.~T();
                break;
            case StorageType_String:
                this->string_.~string_type();
                break;
            default:
                DEBUG_ASSERT_TRUE(false);
            }

            // just in case
            storage_type_ = StorageType_Unknown;
        }

    public:
        FORCE_INLINE ~basic_date_time()
        {
            _destruct();
        }

        FORCE_INLINE StorageType storage_type() const
        {
            return storage_type_;
        }

        FORCE_INLINE const T & get(utility::int_identity<StorageType_Custom>) const
        {
            if (storage_type_ != StorageType_Custom) {
                DEBUG_BREAK_THROW(true) std::runtime_error(fmt::format("{:s}({:d}): storage type is not custom type",
                    UTILITY_PP_FUNCSIG, UTILITY_PP_LINE));
            }

            return custom;
        }

        FORCE_INLINE const string_type & get(utility::int_identity<StorageType_String>) const
        {
            if (storage_type_ != StorageType_String) {
                DEBUG_BREAK_THROW(true) std::runtime_error(fmt::format("{:s}({:d}): storage type is not string type",
                    UTILITY_PP_FUNCSIG, UTILITY_PP_LINE));
            }

            return string_;
        }

    protected:
        StorageType     storage_type_;
        union {
            T           custom;
            string_type string_;
        };
    };

    template <typename T>
    using date_time_a = basic_date_time<T, char, std::char_traits<char>, std::allocator<char> >;
    template <typename T>
    using date_time_w = basic_date_time<T, wchar_t, std::char_traits<wchar_t>, std::allocator<wchar_t> >;

    template <typename T>
    using date_time_u16 = basic_date_time<T, char16_t, std::char_traits<char16_t>, std::allocator<char16_t> >;
    template <typename T>
    using date_time_u32 = basic_date_time<T, char32_t, std::char_traits<char32_t>, std::allocator<char32_t> >;

    using date_time_double_a = date_time_a<double>;
    using date_time_double_w = date_time_w<double>;

    using date_time_double_u16 = date_time_u16<double>;
    using date_time_double_u32 = date_time_u32<double>;

    using date_time_t_a = date_time_a<time_t>;
    using date_time_t_w = date_time_w<time_t>;

    using date_time_t_u16 = date_time_u16<time_t>;
    using date_time_t_u32 = date_time_u32<time_t>;

    using date_time_uint64_a = date_time_a<uint64_t>;
    using date_time_uint64_w = date_time_w<uint64_t>;

    using date_time_uint64_u16 = date_time_u16<uint64_t>;
    using date_time_uint64_u32 = date_time_u32<uint64_t>;
}

#endif
