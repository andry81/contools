#pragma once

// DO NOT REMOVE, exists to avoid private/public headers mixing!
#ifndef UTILITY_ASSERT_HPP
#define UTILITY_ASSERT_HPP
#define UTILITY_ASSERT_PUBLIC_HPP

#include <tacklelib/tacklelib.hpp>

#include <tacklelib/utility/preprocessor.hpp>
#include <tacklelib/utility/platform.hpp>
#include <tacklelib/utility/debug.hpp>

// enable assertion in the Release
#ifndef NDEBUG
#include <cassert>
#else
#undef NDEBUG
#include <cassert>
#define NDEBUG
#endif


// heap corruption provoke simple check
#if ERROR_IF_EMPTY_PP_DEF(USE_MEMORY_REALLOCATION_IN_VERIFY_ASSERT)
#define UTILITY_DBG_HEAP_CHECK() delete [] (new char [1])
#else
#define UTILITY_DBG_HEAP_CHECK() (void)0
#endif


// FPU precision control check
#if ERROR_IF_EMPTY_PP_DEF(USE_FPU_PRECISION_CHECK_IN_VERIFY_ASSERT)
#define UTILITY_FPU_PRECISION_CHECK() if ((_controlfp(0, 0) & _MCW_PC) != (USE_FPU_PRECISION_CHECK_IN_VERIFY_ASSERT_VALUE)) \
    { \
        ASSERT_FAIL("UTILITY_FPU_PRECISION_CHECK()", L"UTILITY_FPU_PRECISION_CHECK()", UTILITY_PP_FILE, UTILITY_PP_FILE_WIDE, UTILITY_PP_LINE, UTILITY_PP_FUNCSIG); \
    } (void)0
#else
#define UTILITY_FPU_PRECISION_CHECK() (void)0
#endif

// verify/assert post test macro
#define UTILITY_ASSERT_POST_TEST() \
    UTILITY_DBG_HEAP_CHECK(); \
    UTILITY_FPU_PRECISION_CHECK()


#if defined(UTILITY_PLATFORM_WINDOWS)
#define ASSERT_FAIL(msg, msg_w, file, file_w, line, funcsig) _wassert(msg_w, file_w, line)
#define ASSERT_FAIL_WIDE(msg, file, line, funcsig) _wassert(msg, file, line)
#elif defined(UTILITY_PLATFORM_POSIX)
#define ASSERT_FAIL(msg, msg_w, file, file_w, line, funcsig) __assert_fail(msg, file, line, funcsig)
#define ASSERT_FAIL_ANSI(msg, file, line, funcsig) __assert_fail(msg, file, line, funcsig)
#else
#error platform is not implemented
#endif


// always enabled basic asserts

#define BASIC_VERIFY_TRUE(exp)      (( ::utility::UniAssertTrue{ UTILITY_PP_FILE, UTILITY_PP_FILE_WIDE, UTILITY_PP_LINE, UTILITY_PP_FUNCSIG}.verify(exp, UTILITY_PP_STRINGIZE(exp), UTILITY_PP_STRINGIZE_WIDE(exp)) ))
#define BASIC_VERIFY_FALSE(exp)     (( ::utility::UniAssertFalse{ UTILITY_PP_FILE, UTILITY_PP_FILE_WIDE, UTILITY_PP_LINE, UTILITY_PP_FUNCSIG}.verify(exp, UTILITY_PP_STRINGIZE(!(exp)), UTILITY_PP_STRINGIZE_WIDE(!(exp))) ))

#define BASIC_VERIFY_EQ(v1, v2)     (( ::utility::UniAssertEQ{ UTILITY_PP_FILE, UTILITY_PP_FILE_WIDE, UTILITY_PP_LINE, UTILITY_PP_FUNCSIG}.verify(v1, v2, UTILITY_PP_STRINGIZE((v1) == (v2)), UTILITY_PP_STRINGIZE_WIDE((v1) == (v2))) ))
#define BASIC_VERIFY_NE(v1, v2)     (( ::utility::UniAssertNE{ UTILITY_PP_FILE, UTILITY_PP_FILE_WIDE, UTILITY_PP_LINE, UTILITY_PP_FUNCSIG}.verify(v1, v2, UTILITY_PP_STRINGIZE((v1) != (v2)), UTILITY_PP_STRINGIZE_WIDE((v1) != (v2))) ))
#define BASIC_VERIFY_LE(v1, v2)     (( ::utility::UniAssertLE{ UTILITY_PP_FILE, UTILITY_PP_FILE_WIDE, UTILITY_PP_LINE, UTILITY_PP_FUNCSIG}.verify(v1, v2, UTILITY_PP_STRINGIZE((v1) <= (v2)), UTILITY_PP_STRINGIZE_WIDE((v1) <= (v2))) ))
#define BASIC_VERIFY_LT(v1, v2)     (( ::utility::UniAssertLT{ UTILITY_PP_FILE, UTILITY_PP_FILE_WIDE, UTILITY_PP_LINE, UTILITY_PP_FUNCSIG}.verify(v1, v2, UTILITY_PP_STRINGIZE((v1) < (v2)), UTILITY_PP_STRINGIZE_WIDE((v1) < (v2))) ))
#define BASIC_VERIFY_GE(v1, v2)     (( ::utility::UniAssertGE{ UTILITY_PP_FILE, UTILITY_PP_FILE_WIDE, UTILITY_PP_LINE, UTILITY_PP_FUNCSIG}.verify(v1, v2, UTILITY_PP_STRINGIZE((v1) >= (v2)), UTILITY_PP_STRINGIZE_WIDE((v1) >= (v2))) ))
#define BASIC_VERIFY_GT(v1, v2)     (( ::utility::UniAssertGT{ UTILITY_PP_FILE, UTILITY_PP_FILE_WIDE, UTILITY_PP_LINE, UTILITY_PP_FUNCSIG}.verify(v1, v2, UTILITY_PP_STRINGIZE((v1) > (v2)), UTILITY_PP_STRINGIZE_WIDE((v1) > (v2))) ))

// `? true : false` to suppress: `warning C4127: conditional expression is constant`
#define BASIC_ASSERT_TRUE(exp) \
    if ((exp) ? true : false); else do {{ \
        DEBUG_BREAK_IN_DEBUGGER(true); \
        ASSERT_FAIL(UTILITY_PP_STRINGIZE((exp) ? true : false), UTILITY_PP_STRINGIZE_WIDE((exp) ? true : false), UTILITY_PP_FILE, UTILITY_PP_FILE_WIDE, UTILITY_PP_LINE, UTILITY_PP_FUNCSIG); \
    }} while(false); \
    UTILITY_ASSERT_POST_TEST()

#define BASIC_ASSERT_FALSE(exp) \
    if ((exp) ? false : true); else do {{ \
        DEBUG_BREAK_IN_DEBUGGER(true); \
        ASSERT_FAIL(UTILITY_PP_STRINGIZE((exp) ? false : true), UTILITY_PP_STRINGIZE_WIDE((exp) ? false : true), UTILITY_PP_FILE, UTILITY_PP_FILE_WIDE, UTILITY_PP_LINE, UTILITY_PP_FUNCSIG); \
    }} while(false); \
    UTILITY_ASSERT_POST_TEST()

#define BASIC_ASSERT_EQ(v1, v2) \
    if ((v1) == (v2) ? true : false); else do {{ \
        DEBUG_BREAK_IN_DEBUGGER(true); \
        ASSERT_FAIL(UTILITY_PP_STRINGIZE((v1) == (v2)), UTILITY_PP_STRINGIZE_WIDE((v1) == (v2)), UTILITY_PP_FILE, UTILITY_PP_FILE_WIDE, UTILITY_PP_LINE, UTILITY_PP_FUNCSIG); \
    }} while(false); \
    UTILITY_ASSERT_POST_TEST()

#define BASIC_ASSERT_NE(v1, v2) \
    if ((v1) != (v2) ? true : false); else do {{ \
        DEBUG_BREAK_IN_DEBUGGER(true); \
        ASSERT_FAIL(UTILITY_PP_STRINGIZE((v1) != (v2)), UTILITY_PP_STRINGIZE_WIDE((v1) != (v2)), UTILITY_PP_FILE, UTILITY_PP_FILE_WIDE, UTILITY_PP_LINE, UTILITY_PP_FUNCSIG); \
    }} while(false); \
    UTILITY_ASSERT_POST_TEST()

#define BASIC_ASSERT_LE(v1, v2) \
    if ((v1) <= (v2) ? true : false); else do {{ \
        DEBUG_BREAK_IN_DEBUGGER(true); \
        ASSERT_FAIL(UTILITY_PP_STRINGIZE((v1) <= (v2)), UTILITY_PP_STRINGIZE_WIDE((v1) <= (v2)), UTILITY_PP_FILE, UTILITY_PP_FILE_WIDE, UTILITY_PP_LINE, UTILITY_PP_FUNCSIG); \
    }} while(false); \
    UTILITY_ASSERT_POST_TEST()

#define BASIC_ASSERT_LT(v1, v2) \
    if ((v1) < (v2) ? true : false); else do {{ \
        DEBUG_BREAK_IN_DEBUGGER(true); \
        ASSERT_FAIL(UTILITY_PP_STRINGIZE((v1) < (v2)), UTILITY_PP_STRINGIZE_WIDE((v1) < (v2)), UTILITY_PP_FILE, UTILITY_PP_FILE_WIDE, UTILITY_PP_LINE, UTILITY_PP_FUNCSIG); \
    }} while(false); \
    UTILITY_ASSERT_POST_TEST()

#define BASIC_ASSERT_GE(v1, v2) \
    if ((v1) >= (v2) ? true : false); else do {{ \
        DEBUG_BREAK_IN_DEBUGGER(true); \
        ASSERT_FAIL(UTILITY_PP_STRINGIZE((v1) >= (v2)), UTILITY_PP_STRINGIZE_WIDE((v1) >= (v2)), UTILITY_PP_FILE, UTILITY_PP_FILE_WIDE, UTILITY_PP_LINE, UTILITY_PP_FUNCSIG); \
    }} while(false); \
    UTILITY_ASSERT_POST_TEST()

#define BASIC_ASSERT_GT(v1, v2) \
    if ((v1) > (v2) ? true : false); else do {{ \
        DEBUG_BREAK_IN_DEBUGGER(true); \
        ASSERT_FAIL(UTILITY_PP_STRINGIZE((v1) > (v2)), UTILITY_PP_STRINGIZE_WIDE((v1) > (v2)), UTILITY_PP_FILE, UTILITY_PP_FILE_WIDE, UTILITY_PP_LINE, UTILITY_PP_FUNCSIG); \
    }} while(false); \
    UTILITY_ASSERT_POST_TEST()


// always disabled asserts with unused parameters warnings suppression

#define DISABLED_VERIFY_TRUE(exp)   (( ::utility::unused_true(exp) ))
#define DISABLED_VERIFY_FALSE(exp)  (( ::utility::unused_false(exp) ))

#define DISABLED_VERIFY_EQ(v1, v2)  (( ::utility::unused_equal(v1, v2) ))
#define DISABLED_VERIFY_NE(v1, v2)  (( ::utility::unused_not_equal(v1, v2) ))
#define DISABLED_VERIFY_LE(v1, v2)  (( ::utility::unused_less_or_equal(v1, v2) ))
#define DISABLED_VERIFY_LT(v1, v2)  (( ::utility::unused_less(v1, v2) ))
#define DISABLED_VERIFY_GE(v1, v2)  (( ::utility::unused_greater_or_equal(v1, v2) ))
#define DISABLED_VERIFY_GT(v1, v2)  (( ::utility::unused_greater(v1, v2) ))

#define DISABLED_ASSERT_TRUE(exp)   do {{ UTILITY_UNUSED_STATEMENT((exp) ? true : false); UTILITY_ASSERT_POST_TEST(); }} while(false)
#define DISABLED_ASSERT_FALSE(exp)  do {{ UTILITY_UNUSED_STATEMENT((exp) ? false : true); UTILITY_ASSERT_POST_TEST(); }} while(false)

// `? true : false` to suppress: `warning C4127: conditional expression is constant`
#define DISABLED_ASSERT_EQ(v1, v2)  do {{ UTILITY_UNUSED_EXPR((v1) == (v2) ? true : false); UTILITY_ASSERT_POST_TEST(); }} while(false)
#define DISABLED_ASSERT_NE(v1, v2)  do {{ UTILITY_UNUSED_EXPR((v1) != (v2) ? true : false); UTILITY_ASSERT_POST_TEST(); }} while(false)
#define DISABLED_ASSERT_LE(v1, v2)  do {{ UTILITY_UNUSED_EXPR((v1) <= (v2) ? true : false); UTILITY_ASSERT_POST_TEST(); }} while(false)
#define DISABLED_ASSERT_LT(v1, v2)  do {{ UTILITY_UNUSED_EXPR((v1) < (v2) ? true : false); UTILITY_ASSERT_POST_TEST(); }} while(false)
#define DISABLED_ASSERT_GE(v1, v2)  do {{ UTILITY_UNUSED_EXPR((v1) >= (v2) ? true : false); UTILITY_ASSERT_POST_TEST(); }} while(false)
#define DISABLED_ASSERT_GT(v1, v2)  do {{ UTILITY_UNUSED_EXPR((v1) > (v2) ? true : false); UTILITY_ASSERT_POST_TEST(); }} while(false)


// classic debug assert

#if defined(_DEBUG) && !ERROR_IF_EMPTY_PP_DEF(DISABLE_DEBUG_VERIFY_ASSERT)

#define DEBUG_VERIFY_TRUE       BASIC_VERIFY_TRUE
#define DEBUG_VERIFY_FALSE      BASIC_VERIFY_FALSE

#define DEBUG_VERIFY_EQ         BASIC_VERIFY_EQ
#define DEBUG_VERIFY_NE         BASIC_VERIFY_NE
#define DEBUG_VERIFY_LE         BASIC_VERIFY_LE
#define DEBUG_VERIFY_LT         BASIC_VERIFY_LT
#define DEBUG_VERIFY_GE         BASIC_VERIFY_GE
#define DEBUG_VERIFY_GT         BASIC_VERIFY_GT

#define DEBUG_ASSERT_TRUE       BASIC_ASSERT_TRUE
#define DEBUG_ASSERT_FALSE      BASIC_ASSERT_FALSE

#define DEBUG_ASSERT_EQ         BASIC_ASSERT_EQ
#define DEBUG_ASSERT_NE         BASIC_ASSERT_NE
#define DEBUG_ASSERT_LE         BASIC_ASSERT_LE
#define DEBUG_ASSERT_LT         BASIC_ASSERT_LT
#define DEBUG_ASSERT_GE         BASIC_ASSERT_GE
#define DEBUG_ASSERT_GT         BASIC_ASSERT_GT

#define DEBUG_ASSERT_VERIFY_ENABLED 1

#define IF_DEBUG_ASSERT_VERIFY_ENABLED(x) if(x)

#else

#define DEBUG_VERIFY_TRUE       DISABLED_VERIFY_TRUE
#define DEBUG_VERIFY_FALSE      DISABLED_VERIFY_FALSE

#define DEBUG_VERIFY_EQ         DISABLED_VERIFY_EQ
#define DEBUG_VERIFY_NE         DISABLED_VERIFY_NE
#define DEBUG_VERIFY_LE         DISABLED_VERIFY_LE
#define DEBUG_VERIFY_LT         DISABLED_VERIFY_LT
#define DEBUG_VERIFY_GE         DISABLED_VERIFY_GE
#define DEBUG_VERIFY_GT         DISABLED_VERIFY_GT

#define DEBUG_ASSERT_TRUE       DISABLED_ASSERT_TRUE
#define DEBUG_ASSERT_FALSE      DISABLED_ASSERT_FALSE

#define DEBUG_ASSERT_EQ         DISABLED_ASSERT_EQ
#define DEBUG_ASSERT_NE         DISABLED_ASSERT_NE
#define DEBUG_ASSERT_LE         DISABLED_ASSERT_LE
#define DEBUG_ASSERT_LT         DISABLED_ASSERT_LT
#define DEBUG_ASSERT_GE         DISABLED_ASSERT_GE
#define DEBUG_ASSERT_GT         DISABLED_ASSERT_GT

#define DEBUG_ASSERT_VERIFY_ENABLED 0

#define IF_DEBUG_ASSERT_VERIFY_ENABLED(x) if(false)

#endif


// Special local assert, switches between common and basic assert by runtime value.
// If value evaluated to 0, then common version has used, otherwise the basic has used.
// Useful to force assert to stay as basic (for example, to make assertion in the Release)
// if standalone macro definition has used, otherwise use the common one.

#define LOCAL_VERIFY_TRUE(is_local, exp)   (( (is_local) ? BASIC_VERIFY_TRUE(exp) : VERIFY_TRUE(exp) ))
#define LOCAL_VERIFY_FALSE(is_local, exp)  (( (is_local) ? BASIC_VERIFY_FALSE(exp) : VERIFY_FALSE(exp) ))

#define LOCAL_VERIFY_EQ(is_local, v1, v2)  (( (is_local) ? BASIC_VERIFY_EQ(v1, v2) : VERIFY_EQ(v1, v2) ))
#define LOCAL_VERIFY_NE(is_local, v1, v2)  (( (is_local) ? BASIC_VERIFY_NE(v1, v2) : VERIFY_NE(v1, v2) ))
#define LOCAL_VERIFY_LE(is_local, v1, v2)  (( (is_local) ? BASIC_VERIFY_LE(v1, v2) : VERIFY_LE(v1, v2) ))
#define LOCAL_VERIFY_LT(is_local, v1, v2)  (( (is_local) ? BASIC_VERIFY_LT(v1, v2) : VERIFY_LT(v1, v2) ))
#define LOCAL_VERIFY_GE(is_local, v1, v2)  (( (is_local) ? BASIC_VERIFY_GE(v1, v2) : VERIFY_GE(v1, v2) ))
#define LOCAL_VERIFY_GT(is_local, v1, v2)  (( (is_local) ? BASIC_VERIFY_GT(v1, v2) : VERIFY_GT(v1, v2) ))

#define LOCAL_ASSERT_TRUE(is_local, exp)   do {{ if(is_local) BASIC_ASSERT_TRUE(exp); else ASSERT_TRUE(exp); }} while(false)
#define LOCAL_ASSERT_FALSE(is_local, exp)  do {{ if(is_local) BASIC_ASSERT_FALSE(exp); else ASSERT_FALSE(exp); }} while(false)

#define LOCAL_ASSERT_EQ(is_local, v1, v2)  do {{ if(is_local) BASIC_ASSERT_EQ(v1, v2); else ASSERT_EQ(v1, v2); }} while(false)
#define LOCAL_ASSERT_NE(is_local, v1, v2)  do {{ if(is_local) BASIC_ASSERT_NE(v1, v2); else ASSERT_NE(v1, v2); }} while(false)
#define LOCAL_ASSERT_LE(is_local, v1, v2)  do {{ if(is_local) BASIC_ASSERT_LE(v1, v2); else ASSERT_LE(v1, v2); }} while(false)
#define LOCAL_ASSERT_LT(is_local, v1, v2)  do {{ if(is_local) BASIC_ASSERT_LT(v1, v2); else ASSERT_LT(v1, v2); }} while(false)
#define LOCAL_ASSERT_GE(is_local, v1, v2)  do {{ if(is_local) BASIC_ASSERT_GE(v1, v2); else ASSERT_GE(v1, v2); }} while(false)
#define LOCAL_ASSERT_GT(is_local, v1, v2)  do {{ if(is_local) BASIC_ASSERT_GT(v1, v2); else ASSERT_GT(v1, v2); }} while(false)


#if defined(_DEBUG) && !ERROR_IF_EMPTY_PP_DEF(DISABLE_VERIFY_ASSERT)

#define VERIFY_TRUE     DEBUG_VERIFY_TRUE
#define VERIFY_FALSE    DEBUG_VERIFY_FALSE

#define VERIFY_EQ       DEBUG_VERIFY_EQ
#define VERIFY_NE       DEBUG_VERIFY_NE
#define VERIFY_LE       DEBUG_VERIFY_LE
#define VERIFY_LT       DEBUG_VERIFY_LT
#define VERIFY_GE       DEBUG_VERIFY_GE
#define VERIFY_GT       DEBUG_VERIFY_GT

#define ASSERT_TRUE     DEBUG_ASSERT_TRUE
#define ASSERT_FALSE    DEBUG_ASSERT_FALSE

#define ASSERT_EQ       DEBUG_ASSERT_EQ
#define ASSERT_NE       DEBUG_ASSERT_NE
#define ASSERT_LE       DEBUG_ASSERT_LE
#define ASSERT_LT       DEBUG_ASSERT_LT
#define ASSERT_GE       DEBUG_ASSERT_GE
#define ASSERT_GT       DEBUG_ASSERT_GT

#define ASSERT_VERIFY_ENABLED DEBUG_ASSERT_VERIFY_ENABLED

#define IF_ASSERT_VERIFY_ENABLED(x) IF_DEBUG_ASSERT_VERIFY_ENABLED(x)

#else

#define VERIFY_TRUE     DISABLED_VERIFY_TRUE
#define VERIFY_FALSE    DISABLED_VERIFY_FALSE

#define VERIFY_EQ       DISABLED_VERIFY_EQ
#define VERIFY_NE       DISABLED_VERIFY_NE
#define VERIFY_LE       DISABLED_VERIFY_LE
#define VERIFY_LT       DISABLED_VERIFY_LT
#define VERIFY_GE       DISABLED_VERIFY_GE
#define VERIFY_GT       DISABLED_VERIFY_GT

#define ASSERT_TRUE     DISABLED_ASSERT_TRUE
#define ASSERT_FALSE    DISABLED_ASSERT_FALSE

#define ASSERT_EQ       DISABLED_ASSERT_EQ
#define ASSERT_NE       DISABLED_ASSERT_NE
#define ASSERT_LE       DISABLED_ASSERT_LE
#define ASSERT_LT       DISABLED_ASSERT_LT
#define ASSERT_GE       DISABLED_ASSERT_GE
#define ASSERT_GT       DISABLED_ASSERT_GT

#define ASSERT_VERIFY_ENABLED 0

#define IF_ASSERT_VERIFY_ENABLED(x) if(false)

#endif

#ifndef GTEST_FAIL

// redirect expect asserts to common asserts
#define EXPECT_TRUE     ASSERT_TRUE
#define EXPECT_FALSE    ASSERT_FALSE

#define EXPECT_EQ       ASSERT_EQ
#define EXPECT_NE       ASSERT_NE
#define EXPECT_LE       ASSERT_LE
#define EXPECT_LT       ASSERT_LT
#define EXPECT_GE       ASSERT_GE
#define EXPECT_GT       ASSERT_GT

#endif


namespace utility
{
    // TIPS:
    // * to capture parameters by reference in macro definitions for single evaluation
    // * to suppress `unused variable` warnings like: `warning C4101: '...': unreferenced local variable`
    template<typename T>
    FORCE_INLINE const T & unused_true(const T & exp_var)
    {
        const T & r = (exp_var ? exp_var : exp_var); // to avoid warnings of truncation to bool
        UTILITY_ASSERT_POST_TEST();
        return r;
    }

    template<typename T>
    FORCE_INLINE const T & unused_false(const T & exp_var)
    {
        const T & r = (exp_var ? exp_var : exp_var); // to avoid warnings of truncation to bool
        UTILITY_ASSERT_POST_TEST();
        return r;
    }

    template<typename T1, typename T2>
    FORCE_INLINE const T1 & unused_equal(const T1 & v1, const T2 & v2)
    {
        const T1 & r = (v1 == v2 ? v1 : v1);
        UTILITY_ASSERT_POST_TEST();
        return r;
    }

    template<typename T1, typename T2>
    FORCE_INLINE const T1 & unused_not_equal(const T1 & v1, const T2 & v2)
    {
        const T1 & r = (v1 != v2 ? v1 : v1);
        UTILITY_ASSERT_POST_TEST();
        return r;
    }

    template<typename T1, typename T2>
    FORCE_INLINE const T1 & unused_less_or_equal(const T1 & v1, const T2 & v2)
    {
        const T1 & r = (v1 <= v2 ? v1 : v1);
        UTILITY_ASSERT_POST_TEST();
        return r;
    }

    template<typename T1, typename T2>
    FORCE_INLINE const T1 & unused_less(const T1 & v1, const T2 & v2)
    {
        const T1 & r = (v1 < v2 ? v1 : v1);
        UTILITY_ASSERT_POST_TEST();
        return r;
    }

    template<typename T1, typename T2>
    FORCE_INLINE const T1 & unused_greater_or_equal(const T1 & v1, const T2 & v2)
    {
        const T1 & r = (v1 >= v2 ? v1 : v1);
        UTILITY_ASSERT_POST_TEST();
        return r;
    }

    template<typename T1, typename T2>
    FORCE_INLINE const T1 & unused_greater(const T1 & v1, const T2 & v2)
    {
        const T1 & r = (v1 > v2 ? v1 : v1);
        UTILITY_ASSERT_POST_TEST();
        return r;
    }


    struct UniAssertTrue
    {
        // TIPS:
        // * to capture parameters by reference in macro definitions for single evaluation
        // * to suppress `unused variable` warnings like: `warning C4101: '...': unreferenced local variable`
        template<typename T>
        FORCE_INLINE const T & verify(const T & exp_var, const char * exp_str, const wchar_t * exp_str_w)
        {
            if (exp_var ? true : false);
            else {
                DEBUG_BREAK_IN_DEBUGGER(true);
                ASSERT_FAIL(exp_str, exp_str_w, file, file_w, line, funcsig);
            }

            UTILITY_ASSERT_POST_TEST();

            return exp_var;
        }

        const char *    file;
        const wchar_t * file_w;
        unsigned int    line;
        const char *    funcsig;
    };

    struct UniAssertFalse
    {
        // TIPS:
        // * to capture parameters by reference in macro definitions for single evaluation
        // * to suppress `unused variable` warnings like: `warning C4101: '...': unreferenced local variable`
        template<typename T>
        FORCE_INLINE const T & verify(const T & exp_var, const char * exp_str, const wchar_t * exp_str_w)
        {
            if (exp_var ? false : true);
            else {
                DEBUG_BREAK_IN_DEBUGGER(true);
                ASSERT_FAIL(exp_str, exp_str_w, file, file_w, line, funcsig);
            }

            UTILITY_ASSERT_POST_TEST();

            return exp_var;
        }

        const char *    file;
        const wchar_t * file_w;
        unsigned int    line;
        const char *    funcsig;
    };

    struct UniAssertEQ
    {
        // TIPS:
        // * to capture parameters by reference in macro definitions for single evaluation
        // * to suppress `unused variable` warnings like: `warning C4101: '...': unreferenced local variable`
        template<typename T1, typename T2>
        FORCE_INLINE const T1 & verify(const T1 & v1, const T2 & v2, const char * exp_str, const wchar_t * exp_str_w)
        {
            if (v1 == v2);
            else {
                DEBUG_BREAK_IN_DEBUGGER(true);
                ASSERT_FAIL(exp_str, exp_str_w, file, file_w, line, funcsig);
            }

            UTILITY_ASSERT_POST_TEST();

            return v1;
        }

        const char *    file;
        const wchar_t * file_w;
        unsigned int    line;
        const char *    funcsig;
    };

    struct UniAssertNE
    {
        // TIPS:
        // * to capture parameters by reference in macro definitions for single evaluation
        // * to suppress `unused variable` warnings like: `warning C4101: '...': unreferenced local variable`
        template<typename T1, typename T2>
        FORCE_INLINE const T1 & verify(const T1 & v1, const T2 & v2, const char * exp_str, const wchar_t * exp_str_w)
        {
            if (v1 != v2);
            else {
                DEBUG_BREAK_IN_DEBUGGER(true);
                ASSERT_FAIL(exp_str, exp_str_w, file, file_w, line, funcsig);
            }

            UTILITY_ASSERT_POST_TEST();

            return v1;
        }

        const char *    file;
        const wchar_t * file_w;
        unsigned int    line;
        const char *    funcsig;
    };

    struct UniAssertLE
    {
        // TIPS:
        // * to capture parameters by reference in macro definitions for single evaluation
        // * to suppress `unused variable` warnings like: `warning C4101: '...': unreferenced local variable`
        template<typename T1, typename T2>
        FORCE_INLINE const T1 & verify(const T1 & v1, const T2 & v2, const char * exp_str, const wchar_t * exp_str_w)
        {
            if (v1 <= v2);
            else {
                DEBUG_BREAK_IN_DEBUGGER(true);
                ASSERT_FAIL(exp_str, exp_str_w, file, file_w, line, funcsig);
            }

            UTILITY_ASSERT_POST_TEST();

            return v1;
        }

        const char *    file;
        const wchar_t * file_w;
        unsigned int    line;
        const char *    funcsig;
    };

    struct UniAssertLT
    {
        // TIPS:
        // * to capture parameters by reference in macro definitions for single evaluation
        // * to suppress `unused variable` warnings like: `warning C4101: '...': unreferenced local variable`
        template<typename T1, typename T2>
        FORCE_INLINE const T1 & verify(const T1 & v1, const T2 & v2, const char * exp_str, const wchar_t * exp_str_w)
        {
            if (v1 < v2);
            else {
                DEBUG_BREAK_IN_DEBUGGER(true);
                ASSERT_FAIL(exp_str, exp_str_w, file, file_w, line, funcsig);
            }

            UTILITY_ASSERT_POST_TEST();

            return v1;
        }

        const char *    file;
        const wchar_t * file_w;
        unsigned int    line;
        const char *    funcsig;
    };

    struct UniAssertGE
    {
        // TIPS:
        // * to capture parameters by reference in macro definitions for single evaluation
        // * to suppress `unused variable` warnings like: `warning C4101: '...': unreferenced local variable`
        template<typename T1, typename T2>
        FORCE_INLINE const T1 & verify(const T1 & v1, const T2 & v2, const char * exp_str, const wchar_t * exp_str_w)
        {
            if (v1 >= v2);
            else {
                DEBUG_BREAK_IN_DEBUGGER(true);
                ASSERT_FAIL(exp_str, exp_str_w, file, file_w, line, funcsig);
            }

            UTILITY_ASSERT_POST_TEST();

            return v1;
        }

        const char *    file;
        const wchar_t * file_w;
        unsigned int    line;
        const char *    funcsig;
    };

    struct UniAssertGT
    {
        // TIPS:
        // * to capture parameters by reference in macro definitions for single evaluation
        // * to suppress `unused variable` warnings like: `warning C4101: '...': unreferenced local variable`
        template<typename T1, typename T2>
        FORCE_INLINE const T1 & verify(const T1 & v1, const T2 & v2, const char * exp_str, const wchar_t * exp_str_w)
        {
            if (v1 > v2);
            else {
                DEBUG_BREAK_IN_DEBUGGER(true);
                ASSERT_FAIL(exp_str, exp_str_w, file, file_w, line, funcsig);
            }

            UTILITY_ASSERT_POST_TEST();

            return v1;
        }

        const char *    file;
        const wchar_t * file_w;
        unsigned int    line;
        const char *    funcsig;
    };

}

#endif
