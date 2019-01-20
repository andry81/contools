#pragma once

// DO NOT REMOVE, exists to avoid private/public headers mixing!
#ifndef UTILITY_STATIC_ASSERT_HPP
#define UTILITY_STATIC_ASSERT_HPP

#include <tacklelib/tacklelib.hpp>

#include <tacklelib/utility/preprocessor.hpp>
#include <tacklelib/utility/type_identity.hpp>


#define STATIC_ASSERT_PARAM(v1) ::utility::StaticAssertParam<decltype(v1), (v1)>
#define STATIC_ASSERT_VALUE(v1) STATIC_ASSERT_PARAM(v1)::value

#define STATIC_ASSERT_TRUE(exp, msg)    static_assert(::utility::StaticAssertTrue<decltype(exp), (exp)>::value, "expression: \"" UTILITY_PP_STRINGIZE(exp) "\": " msg)
#define STATIC_ASSERT_TRUE1(exp, v1, msg) \
    static_assert(::utility::StaticAssertTrue<decltype(exp), (exp), \
                  STATIC_ASSERT_PARAM(v1) >::value, "expression: \"" UTILITY_PP_STRINGIZE(exp) "\": " msg)
#define STATIC_ASSERT_TRUE2(exp, v1, v2, msg) \
    static_assert(::utility::StaticAssertTrue<decltype(exp), (exp), \
                  STATIC_ASSERT_PARAM(v1), \
                  STATIC_ASSERT_PARAM(v2) >::value, "expression: \"" UTILITY_PP_STRINGIZE(exp) "\": " msg)
#define STATIC_ASSERT_TRUE3(exp, v1, v2, v3, msg) \
    static_assert(::utility::StaticAssertTrue<decltype(exp), (exp), \
                  STATIC_ASSERT_PARAM(v1), \
                  STATIC_ASSERT_PARAM(v2), \
                  STATIC_ASSERT_PARAM(v3) >::value, "expression: \"" UTILITY_PP_STRINGIZE(exp) "\": " msg)
#define STATIC_ASSERT_TRUE4(exp, v1, v2, v3, v4, msg) \
    static_assert(::utility::StaticAssertTrue<decltype(exp), (exp), \
                  STATIC_ASSERT_PARAM(v1), \
                  STATIC_ASSERT_PARAM(v2), \
                  STATIC_ASSERT_PARAM(v3), \
                  STATIC_ASSERT_PARAM(v4) >::value, "expression: \"" UTILITY_PP_STRINGIZE(exp) "\": " msg)

#define STATIC_ASSERT_FALSE(exp, msg)   static_assert(::utility::StaticAssertFalse<decltype(exp), (exp)>::value, "expression: \"" UTILITY_PP_STRINGIZE(exp) "\": " msg)
#define STATIC_ASSERT_FALSE1(exp, v1, msg) \
    static_assert(::utility::StaticAssertFalse<decltype(exp), (exp), \
                  STATIC_ASSERT_PARAM(v1) >::value, "expression: \"" UTILITY_PP_STRINGIZE(exp) "\": " msg)
#define STATIC_ASSERT_FALSE2(exp, v1, v2, msg) \
    static_assert(::utility::StaticAssertFalse<decltype(exp), (exp), \
                  STATIC_ASSERT_PARAM(v1), \
                  STATIC_ASSERT_PARAM(v2) >::value, "expression: \"" UTILITY_PP_STRINGIZE(exp) "\": " msg)
#define STATIC_ASSERT_FALSE3(exp, v1, v2, v3, msg) \
    static_assert(::utility::StaticAssertFalse<decltype(exp), (exp), \
                  STATIC_ASSERT_PARAM(v1), \
                  STATIC_ASSERT_PARAM(v2), \
                  STATIC_ASSERT_PARAM(v3) >::value, "expression: \"" UTILITY_PP_STRINGIZE(exp) "\": " msg)
#define STATIC_ASSERT_FALSE4(exp, v1, v2, v3, v4, msg) \
    static_assert(::utility::StaticAssertFalse<decltype(exp), (exp), \
                  STATIC_ASSERT_PARAM(v1), \
                  STATIC_ASSERT_PARAM(v2), \
                  STATIC_ASSERT_PARAM(v3), \
                  STATIC_ASSERT_PARAM(v4) >::value, "expression: \"" UTILITY_PP_STRINGIZE(exp) "\": " msg)

#define STATIC_ASSERT_EQ(v1, v2, msg)   static_assert(::utility::StaticAssertEQ<decltype(v1), decltype(v2), (v1), (v2)>::value, "expression: \"" UTILITY_PP_STRINGIZE(v1) " == " UTILITY_PP_STRINGIZE(v2) "\": " msg)
#define STATIC_ASSERT_NE(v1, v2, msg)   static_assert(::utility::StaticAssertNE<decltype(v1), decltype(v2), (v1), (v2)>::value, "expression: \"" UTILITY_PP_STRINGIZE(v1) " != " UTILITY_PP_STRINGIZE(v2) "\": " msg)
#define STATIC_ASSERT_LE(v1, v2, msg)   static_assert(::utility::StaticAssertLE<decltype(v1), decltype(v2), (v1), (v2)>::value, "expression: \"" UTILITY_PP_STRINGIZE(v1) " <= " UTILITY_PP_STRINGIZE(v2) "\": " msg)
#define STATIC_ASSERT_LT(v1, v2, msg)   static_assert(::utility::StaticAssertLT<decltype(v1), decltype(v2), (v1), (v2)>::value, "expression: \"" UTILITY_PP_STRINGIZE(v1) " < "  UTILITY_PP_STRINGIZE(v2) "\": " msg)
#define STATIC_ASSERT_GE(v1, v2, msg)   static_assert(::utility::StaticAssertGE<decltype(v1), decltype(v2), (v1), (v2)>::value, "expression: \"" UTILITY_PP_STRINGIZE(v1) " >= " UTILITY_PP_STRINGIZE(v2) "\": " msg)
#define STATIC_ASSERT_GT(v1, v2, msg)   static_assert(::utility::StaticAssertGT<decltype(v1), decltype(v2), (v1), (v2)>::value, "expression: \"" UTILITY_PP_STRINGIZE(v1) " > "  UTILITY_PP_STRINGIZE(v2) "\": " msg)


namespace utility
{
    template <typename T, T v>
    struct StaticAssertParam
    {
    };

    template <typename T, T v, typename... Params>
    struct StaticAssertTrue;

    template <typename T, T v>
    struct StaticAssertTrue<T, v>
    {
        static const bool value = (v ? true : false);
    };

    template <typename T, T v>
    const bool StaticAssertTrue<T, v>::value;

    template <typename T, T v, typename... Params>
    struct StaticAssertTrue
    {
        static const bool value = (v ? true : false);
        // duplicate the error, to provoke compiler include complete error stack from here
        static_assert(v ? true : false, "StaticAssertTrue with parameters failed.");
    };

    template <typename T, T v, typename... Params>
    const bool StaticAssertTrue<T, v, Params...>::value;

    template <typename T, T v, typename... Params>
    struct StaticAssertFalse;

    template <typename T, T v>
    struct StaticAssertFalse<T, v>
    {
        static const bool value = (v ? false : true);
    };

    template <typename T, T v>
    const bool StaticAssertFalse<T, v>::value;

    template <typename T, T v, typename... Params>
    struct StaticAssertFalse
    {
        static const bool value = (v ? false : true);
        // duplicate the error, to provoke compiler include complete error stack from here
        static_assert(v ? false : true, "StaticAssertFalse with parameters failed.");
    };

    template <typename T, T v, typename... Params>
    const bool StaticAssertFalse<T, v, Params...>::value;

    template <typename U, typename V, U u, V v>
    struct StaticAssertEQ
    {
        static const bool value = (u == v);
        // duplicate the error, to provoke compiler include complete error stack from here
        static_assert(u == v, "StaticAssertEQ failed.");
    };

    template <typename U, typename V, U u, V v>
    const bool StaticAssertEQ<U, V, u, v>::value;

    template <typename U, typename V, U u, V v>
    struct StaticAssertNE
    {
        static const bool value = (u != v);
        // duplicate the error, to provoke compiler include complete error stack from here
        static_assert(u != v, "StaticAssertNE failed.");
    };

    template <typename U, typename V, U u, V v>
    const bool StaticAssertNE<U, V, u, v>::value;

    template <typename U, typename V, U u, V v>
    struct StaticAssertLE
    {
        static const bool value = (u <= v);
        // duplicate the error, to provoke compiler include complete error stack from here
        static_assert(u <= v, "StaticAssertLE failed.");
    };

    template <typename U, typename V, U u, V v>
    const bool StaticAssertLE<U, V, u, v>::value;

    template <typename U, typename V, U u, V v>
    struct StaticAssertLT
    {
        static const bool value = (u < v);
        // duplicate the error, to provoke compiler include complete error stack from here
        static_assert(u < v, "StaticAssertLT failed.");
    };

    template <typename U, typename V, U u, V v>
    const bool StaticAssertLT<U, V, u, v>::value;

    template <typename U, typename V, U u, V v>
    struct StaticAssertGE
    {
        static const bool value = (u >= v);
        // duplicate the error, to provoke compiler include complete error stack from here
        static_assert(u >= v, "StaticAssertGE failed.");
    };

    template <typename U, typename V, U u, V v>
    const bool StaticAssertGE<U, V, u, v>::value;

    template <typename U, typename V, U u, V v>
    struct StaticAssertGT
    {
        static const bool value = (u > v);
        // duplicate the error, to provoke compiler include complete error stack from here
        static_assert(u > v, "StaticAssertGT failed.");
    };

    template <typename U, typename V, U u, V v>
    const bool StaticAssertGT<U, V, u, v>::value;

    // To compare strings in a static assert.
    // See for details: https://stackoverflow.com/questions/27490858/how-can-you-compare-two-character-strings-statically-at-compile-time
    //
    CONSTEXPR bool static_strings_equal(const char * a, const char * b)
    {
        return *a == *b && (*a == '\0' || static_strings_equal(a + 1, b + 1));
    }

    CONSTEXPR bool static_strings_equal(const wchar_t * a, const wchar_t * b)
    {
        return *a == *b && (*a == L'\0' || static_strings_equal(a + 1, b + 1));
    }
}

#endif
