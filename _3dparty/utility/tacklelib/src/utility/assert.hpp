#pragma once

#ifdef UTILITY_ASSERT_PUBLIC_HPP
#error You must not include private header after public!
#endif

// DO NOT REMOVE, exists to avoid private/public headers mixing!
#ifndef UTILITY_ASSERT_HPP
#define UTILITY_ASSERT_HPP

#include <src/tacklelib_private.hpp>

#include <tacklelib/utility/preprocessor.hpp>
#include <tacklelib/utility/platform.hpp>
#include <tacklelib/utility/debug.hpp>

#if !defined(GTEST_INCLUDE_FROM_EXTERNAL)

#if defined(GTEST_FAIL)
#error <utility/assert.hpp> header must be included instead of the <gtest.h> header
#endif

#if defined(TACKLE_TESTLIB) || defined(UNIT_TESTS) || defined(BENCH_TESTS)
#define GTEST_DONT_DEFINE_ASSERT_TRUE 1
#define GTEST_DONT_DEFINE_ASSERT_FALSE 1
#define GTEST_DONT_DEFINE_ASSERT_EQ 1
#define GTEST_DONT_DEFINE_ASSERT_NE 1
#define GTEST_DONT_DEFINE_ASSERT_LE 1
#define GTEST_DONT_DEFINE_ASSERT_LT 1
#define GTEST_DONT_DEFINE_ASSERT_GE 1
#define GTEST_DONT_DEFINE_ASSERT_GT 1

#include <gtest/gtest.h>

// back compatability
#undef ASSERT_TRUE
#undef ASSERT_FALSE
#undef ASSERT_EQ
#undef ASSERT_NE
#undef ASSERT_LE
#undef ASSERT_LT
#undef ASSERT_GE
#undef ASSERT_GT
#endif

#endif

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


// CAUTION:
//  Below `gtest_fail_*` functions avoides dramatic slow down of compilation or linkage (in case of /LTCG) times in the Full Optimization Release in the MSVC2015 Update 3.
//  Direct inclusion of respective gtest macroses (`GTEST_TEST_BOOLEAN_` and `GTEST_ASSERT_`) through the macro call or through the `__forceinline`-ed function call in the Full Optimization Release is EXTREMELY NOT RECOMMENDED!

// TIPS:
//  * if debugger is attached but `::testing::GTEST_FLAG(break_on_failure)` has not been setted, then an assertion does explicit break.

#if defined(UNIT_TESTS) || defined(BENCH_TESTS)

#define UTILITY_ASSERT_GTEST_MESSAGE_(message, result_type) \
    GTEST_MESSAGE_AT_(file, line, message, result_type) // `file` and `line` must be external respective variables

#define UTILITY_ASSERT_GTEST_FATAL_FAILURE_(message) \
    UTILITY_ASSERT_GTEST_MESSAGE_(message, ::testing::TestPartResult::kFatalFailure)

#define UTILITY_ASSERT_GTEST_NONFATAL_FAILURE_(message) \
    UTILITY_ASSERT_GTEST_MESSAGE_(message, ::testing::TestPartResult::kNonFatalFailure)


// uses inside a function inlinement, has significant differences, DO NOT MERGE!
#define UTILITY_GTEST_FAIL_TRUE_FUNC_INLINE(exp_str, file, line) \
    ::utility::gtest_fail_true(exp_str, file, line);

#define UTILITY_GTEST_FAIL_FALSE_FUNC_INLINE(exp_str, file, line) \
    ::utility::gtest_fail_false(exp_str, file, line);

#define UTILITY_GTEST_FAIL_EXP_FUNC_INLINE(exp_value, file, line) \
    ::utility::gtest_fail_exp(exp_value, file, line);


// uses inside a macro inlinement, has significant differences, DO NOT MERGE!
#define UTILITY_GTEST_FAIL_TRUE_MACRO_INLINE(exp_str, file, line) \
    ::utility::gtest_fail_true(exp_str, file, line);

#define UTILITY_GTEST_FAIL_FALSE_MACRO_INLINE(exp_str, file, line) \
    ::utility::gtest_fail_false(exp_str, file, line);

#define UTILITY_GTEST_FAIL_EXP_MACRO_INLINE(exp_value, file, line) \
    ::utility::gtest_fail_exp(exp_value, file, line);


#if !ERROR_IF_EMPTY_PP_DEF(DONT_USE_UNIT_ASSERT_CALL_THROUGH_MACRO_INLINE)

#define UNIT_VERIFY_TRUE(exp) (( ::utility::UniAssertTrue{ UTILITY_PP_FILE, UTILITY_PP_FILE_WIDE, UTILITY_PP_LINE, UTILITY_PP_FUNCSIG}.gtest_verify(exp, UTILITY_PP_STRINGIZE(exp)) ))
#define UNIT_ASSERT_TRUE(exp) \
    if ((exp) ? true : false); else do {{ \
        UTILITY_GTEST_FAIL_TRUE_MACRO_INLINE(UTILITY_PP_STRINGIZE(exp), UTILITY_PP_FILE, UTILITY_PP_LINE); \
    }} while(false); \
    UTILITY_ASSERT_POST_TEST()

#define UNIT_VERIFY_FALSE(exp) (( ::utility::UniAssertFalse{ UTILITY_PP_FILE, UTILITY_PP_FILE_WIDE, UTILITY_PP_LINE, UTILITY_PP_FUNCSIG}.gtest_verify(exp, UTILITY_PP_STRINGIZE(!(exp))) ))
#define UNIT_ASSERT_FALSE(exp) \
    if ((exp) ? false : true); else do {{ \
        UTILITY_GTEST_FAIL_FALSE_MACRO_INLINE(UTILITY_PP_STRINGIZE(exp), UTILITY_PP_FILE, UTILITY_PP_LINE); \
    }} while(false); \
    UTILITY_ASSERT_POST_TEST()

#define UNIT_VERIFY_EQ(v1, v2) (( ::utility::UniAssertEQ{ UTILITY_PP_FILE, UTILITY_PP_FILE_WIDE, UTILITY_PP_LINE, UTILITY_PP_FUNCSIG}.gtest_verify(v1, v2, UTILITY_PP_STRINGIZE(v1), UTILITY_PP_STRINGIZE(v2)) ))
#define UNIT_ASSERT_EQ(v1, v2) \
    do {{ \
        const auto & exp_var_1 = (v1); \
        if (const ::testing::AssertionResult exp_value = ::testing::internal::EqHelper<GTEST_IS_NULL_LITERAL_(exp_var_1)>::Compare(UTILITY_PP_STRINGIZE(v1), UTILITY_PP_STRINGIZE(v2), exp_var_1, v2)); \
        else UTILITY_GTEST_FAIL_EXP_MACRO_INLINE(exp_value, UTILITY_PP_FILE, UTILITY_PP_LINE); \
        UTILITY_ASSERT_POST_TEST(); \
    }} while(false)

#define UNIT_VERIFY_NE(v1, v2) (( ::utility::UniAssertNE{ UTILITY_PP_FILE, UTILITY_PP_FILE_WIDE, UTILITY_PP_LINE, UTILITY_PP_FUNCSIG}.gtest_verify(v1, v2, UTILITY_PP_STRINGIZE(v1), UTILITY_PP_STRINGIZE(v2)) ))
#define UNIT_ASSERT_NE(v1, v2) \
    do {{ \
        const auto & exp_var_1 = (v1); \
        if (const ::testing::AssertionResult exp_value = ::testing::internal::CmpHelperNE(UTILITY_PP_STRINGIZE(v1), UTILITY_PP_STRINGIZE(v2), exp_var_1, v2)); \
        else UTILITY_GTEST_FAIL_EXP_MACRO_INLINE(exp_value, UTILITY_PP_FILE, UTILITY_PP_LINE); \
        UTILITY_ASSERT_POST_TEST(); \
    }} while(false)

#define UNIT_VERIFY_LE(v1, v2) (( ::utility::UniAssertLE{ UTILITY_PP_FILE, UTILITY_PP_FILE_WIDE, UTILITY_PP_LINE, UTILITY_PP_FUNCSIG}.gtest_verify(v1, v2, UTILITY_PP_STRINGIZE(v1), UTILITY_PP_STRINGIZE(v2)) ))
#define UNIT_ASSERT_LE(v1, v2) \
    do {{ \
        const auto & exp_var_1 = (v1); \
        if (const ::testing::AssertionResult exp_value = ::testing::internal::CmpHelperLE(UTILITY_PP_STRINGIZE(v1), UTILITY_PP_STRINGIZE(v2), exp_var_1, v2)); \
        else UTILITY_GTEST_FAIL_EXP_MACRO_INLINE(exp_value, UTILITY_PP_FILE, UTILITY_PP_LINE); \
        UTILITY_ASSERT_POST_TEST(); \
    }} while(false)

#define UNIT_VERIFY_LT(v1, v2) (( ::utility::UniAssertLT{ UTILITY_PP_FILE, UTILITY_PP_FILE_WIDE, UTILITY_PP_LINE, UTILITY_PP_FUNCSIG}.gtest_verify(v1, v2, UTILITY_PP_STRINGIZE(v1), UTILITY_PP_STRINGIZE(v2)) ))
#define UNIT_ASSERT_LT(v1, v2) \
    do {{ \
        const auto & exp_var_1 = (v1); \
        if (const ::testing::AssertionResult exp_value = ::testing::internal::CmpHelperLT(UTILITY_PP_STRINGIZE(v1), UTILITY_PP_STRINGIZE(v2), exp_var_1, v2)); \
        else UTILITY_GTEST_FAIL_EXP_MACRO_INLINE(exp_value, UTILITY_PP_FILE, UTILITY_PP_LINE); \
        UTILITY_ASSERT_POST_TEST(); \
    }} while(false)

#define UNIT_VERIFY_GE(v1, v2) (( ::utility::UniAssertGE{ UTILITY_PP_FILE, UTILITY_PP_FILE_WIDE, UTILITY_PP_LINE, UTILITY_PP_FUNCSIG}.gtest_verify(v1, v2, UTILITY_PP_STRINGIZE(v1), UTILITY_PP_STRINGIZE(v2)) ))
#define UNIT_ASSERT_GE(v1, v2) \
    do {{ \
        const auto & exp_var_1 = (v1); \
        if (const ::testing::AssertionResult exp_value = ::testing::internal::CmpHelperGE(UTILITY_PP_STRINGIZE(v1), UTILITY_PP_STRINGIZE(v2), exp_var_1, v2)); \
        else UTILITY_GTEST_FAIL_EXP_MACRO_INLINE(exp_value, UTILITY_PP_FILE, UTILITY_PP_LINE); \
        UTILITY_ASSERT_POST_TEST(); \
    }} while(false)

#define UNIT_VERIFY_GT(v1, v2) (( ::utility::UniAssertGT{ UTILITY_PP_FILE, UTILITY_PP_FILE_WIDE, UTILITY_PP_LINE, UTILITY_PP_FUNCSIG}.gtest_verify(v1, v2, UTILITY_PP_STRINGIZE(v1), UTILITY_PP_STRINGIZE(v2)) ))
#define UNIT_ASSERT_GT(v1, v2) \
    do {{ \
        const auto & exp_var_1 = (v1); \
        if (const ::testing::AssertionResult exp_value = ::testing::internal::CmpHelperGT(UTILITY_PP_STRINGIZE(v1), UTILITY_PP_STRINGIZE(v2), exp_var_1, v2)); \
        else UTILITY_GTEST_FAIL_EXP_MACRO_INLINE(exp_value, UTILITY_PP_FILE, UTILITY_PP_LINE); \
        UTILITY_ASSERT_POST_TEST(); \
    }} while(false)

#else

#if ERROR_IF_EMPTY_PP_DEF(USE_UNIT_ASSERT_CALL_THROUGH_TEMPLATE_FUNCTION_INSTEAD_LAMBDAS)

#define UNIT_VERIFY_TRUE(exp) (( ::utility::UniAssertTrue{ UTILITY_PP_FILE, UTILITY_PP_FILE_WIDE, UTILITY_PP_LINE, UTILITY_PP_FUNCSIG}.gtest_verify(exp, UTILITY_PP_STRINGIZE(exp)) ))
#if ERROR_IF_EMPTY_PP_DEF(DONT_USE_UNIT_ASSERT_CALL_THROUGH_MACRO_INLINE)
    #define UNIT_ASSERT_TRUE(exp) do {{ ::utility::UniAssertTrue{ UTILITY_PP_FILE, UTILITY_PP_FILE_WIDE, UTILITY_PP_LINE, UTILITY_PP_FUNCSIG}.gtest_verify(exp, UTILITY_PP_STRINGIZE(exp)); UTILITY_ASSERT_POST_TEST(); }} while(false)
#endif

////

#define UNIT_VERIFY_FALSE(exp) (( ::utility::UniAssertFalse{ UTILITY_PP_FILE, UTILITY_PP_FILE_WIDE, UTILITY_PP_LINE, UTILITY_PP_FUNCSIG}.gtest_verify(exp, UTILITY_PP_STRINGIZE(!(exp))) ))
#if ERROR_IF_EMPTY_PP_DEF(DONT_USE_UNIT_ASSERT_CALL_THROUGH_MACRO_INLINE)
    #define UNIT_ASSERT_FALSE(exp) do {{ ::utility::UniAssertFalse{ UTILITY_PP_FILE, UTILITY_PP_FILE_WIDE, UTILITY_PP_LINE, UTILITY_PP_FUNCSIG}.gtest_verify(exp, UTILITY_PP_STRINGIZE(!(exp))); UTILITY_ASSERT_POST_TEST(); }} while(false)
#endif

////

#define UNIT_VERIFY_EQ(v1, v2) (( ::utility::UniAssertEQ{ UTILITY_PP_FILE, UTILITY_PP_FILE_WIDE, UTILITY_PP_LINE, UTILITY_PP_FUNCSIG}.gtest_verify(v1, v2, UTILITY_PP_STRINGIZE(v1), UTILITY_PP_STRINGIZE(v2)) ))
#if ERROR_IF_EMPTY_PP_DEF(DONT_USE_UNIT_ASSERT_CALL_THROUGH_MACRO_INLINE)
    #define UNIT_ASSERT_EQ(v1, v2) /*do {{*/ ::utility::UniAssertEQ{ UTILITY_PP_FILE, UTILITY_PP_FILE_WIDE, UTILITY_PP_LINE, UTILITY_PP_FUNCSIG}.gtest_verify(v1, v2, UTILITY_PP_STRINGIZE(v1), UTILITY_PP_STRINGIZE(v2)); UTILITY_ASSERT_POST_TEST()//; }} while(false)
#endif

////

#define UNIT_VERIFY_NE(v1, v2) (( ::utility::UniAssertNE{ UTILITY_PP_FILE, UTILITY_PP_FILE_WIDE, UTILITY_PP_LINE, UTILITY_PP_FUNCSIG}.gtest_verify(v1, v2, UTILITY_PP_STRINGIZE(v1), UTILITY_PP_STRINGIZE(v2)) ))
#if ERROR_IF_EMPTY_PP_DEF(DONT_USE_UNIT_ASSERT_CALL_THROUGH_MACRO_INLINE)
    #define UNIT_ASSERT_NE(v1, v2) do {{ ::utility::UniAssertNE{ UTILITY_PP_FILE, UTILITY_PP_FILE_WIDE, UTILITY_PP_LINE, UTILITY_PP_FUNCSIG}.gtest_verify(v1, v2, UTILITY_PP_STRINGIZE(v1), UTILITY_PP_STRINGIZE(v2)); UTILITY_ASSERT_POST_TEST(); }} while(false)
#endif

////

#define UNIT_VERIFY_LE(v1, v2) (( ::utility::UniAssertLE{ UTILITY_PP_FILE, UTILITY_PP_FILE_WIDE, UTILITY_PP_LINE, UTILITY_PP_FUNCSIG}.gtest_verify(v1, v2, UTILITY_PP_STRINGIZE(v1), UTILITY_PP_STRINGIZE(v2)) ))
#if ERROR_IF_EMPTY_PP_DEF(DONT_USE_UNIT_ASSERT_CALL_THROUGH_MACRO_INLINE)
    #define UNIT_ASSERT_LE(v1, v2) do {{ ::utility::UniAssertLE{ UTILITY_PP_FILE, UTILITY_PP_FILE_WIDE, UTILITY_PP_LINE, UTILITY_PP_FUNCSIG}.gtest_verify(v1, v2, UTILITY_PP_STRINGIZE(v1), UTILITY_PP_STRINGIZE(v2)); UTILITY_ASSERT_POST_TEST(); }} while(false)
#endif

////

#define UNIT_VERIFY_LT(v1, v2) (( ::utility::UniAssertLT{ UTILITY_PP_FILE, UTILITY_PP_FILE_WIDE, UTILITY_PP_LINE, UTILITY_PP_FUNCSIG}.gtest_verify(v1, v2, UTILITY_PP_STRINGIZE(v1), UTILITY_PP_STRINGIZE(v2)) ))
#if ERROR_IF_EMPTY_PP_DEF(DONT_USE_UNIT_ASSERT_CALL_THROUGH_MACRO_INLINE)
    #define UNIT_ASSERT_LT(v1, v2) do {{ ::utility::UniAssertLT{ UTILITY_PP_FILE, UTILITY_PP_FILE_WIDE, UTILITY_PP_LINE, UTILITY_PP_FUNCSIG}.gtest_verify(v1, v2, UTILITY_PP_STRINGIZE(v1), UTILITY_PP_STRINGIZE(v2)); UTILITY_ASSERT_POST_TEST(); }} while(false)
#endif

////

#define UNIT_VERIFY_GE(v1, v2) (( ::utility::UniAssertGE{ UTILITY_PP_FILE, UTILITY_PP_FILE_WIDE, UTILITY_PP_LINE, UTILITY_PP_FUNCSIG}.gtest_verify(v1, v2, UTILITY_PP_STRINGIZE(v1), UTILITY_PP_STRINGIZE(v2)) ))
#if ERROR_IF_EMPTY_PP_DEF(DONT_USE_UNIT_ASSERT_CALL_THROUGH_MACRO_INLINE)
    #define UNIT_ASSERT_GE(v1, v2) do {{ ::utility::UniAssertGE{ UTILITY_PP_FILE, UTILITY_PP_FILE_WIDE, UTILITY_PP_LINE, UTILITY_PP_FUNCSIG}.gtest_verify(v1, v2, UTILITY_PP_STRINGIZE(v1), UTILITY_PP_STRINGIZE(v2)); UTILITY_ASSERT_POST_TEST(); }} while(false)
#endif

////

#define UNIT_VERIFY_GT(v1, v2) (( ::utility::UniAssertGT{ UTILITY_PP_FILE, UTILITY_PP_FILE_WIDE, UTILITY_PP_LINE, UTILITY_PP_FUNCSIG}.gtest_verify(v1, v2, UTILITY_PP_STRINGIZE(v1), UTILITY_PP_STRINGIZE(v2)) ))
#if ERROR_IF_EMPTY_PP_DEF(DONT_USE_UNIT_ASSERT_CALL_THROUGH_MACRO_INLINE)
    #define UNIT_ASSERT_GT(v1, v2) do {{ ::utility::UniAssertGT{ UTILITY_PP_FILE, UTILITY_PP_FILE_WIDE, UTILITY_PP_LINE, UTILITY_PP_FUNCSIG}.gtest_verify(v1, v2, UTILITY_PP_STRINGIZE(v1), UTILITY_PP_STRINGIZE(v2)); UTILITY_ASSERT_POST_TEST(); }} while(false)
#endif

#else

#ifdef _MSC_VER
    #if _MSC_VER < 1600 // < MSVC++ 10 (Visual Studio 2010)
        #error lambda is not supported
    #endif
#else
    #if __cplusplus < 201103L
        #error lambda is not supported
    #endif
#endif

#define UNIT_VERIFY_TRUE_IMPL(exp) [&](const auto & exp_var, const char * exp_str, const char * file, unsigned int line) -> const auto & { \
        if (exp_var ? true : false); \
        else UTILITY_GTEST_FAIL_TRUE_FUNC_INLINE(exp_str, file, line); \
        UTILITY_ASSERT_POST_TEST(); \
        return exp_var; \
    }

#define UNIT_VERIFY_TRUE(exp) (( UNIT_VERIFY_TRUE_IMPL(exp)(exp, UTILITY_PP_STRINGIZE(exp), UTILITY_PP_FILE, UTILITY_PP_LINE) ))
#if ERROR_IF_EMPTY_PP_DEF(DONT_USE_UNIT_ASSERT_CALL_THROUGH_MACRO_INLINE)
    #define UNIT_ASSERT_TRUE(exp) do {{ UNIT_VERIFY_TRUE_IMPL(exp)(exp, UTILITY_PP_STRINGIZE(exp), UTILITY_PP_FILE, UTILITY_PP_LINE); }} while(false)
#endif

#define UNIT_VERIFY_FALSE_IMPL(exp) [&](const auto & exp_var, const char * exp_str, const char * file, unsigned int line) -> const auto & { \
        if (exp_var ? false : true); \
        else UTILITY_GTEST_FAIL_FALSE_FUNC_INLINE(exp_str, file, line); \
        UTILITY_ASSERT_POST_TEST(); \
        return exp_var; \
    }

#define UNIT_VERIFY_FALSE(exp) (( UNIT_VERIFY_FALSE_IMPL(exp)(exp, UTILITY_PP_STRINGIZE(exp), UTILITY_PP_FILE, UTILITY_PP_LINE) ))
#if ERROR_IF_EMPTY_PP_DEF(DONT_USE_UNIT_ASSERT_CALL_THROUGH_MACRO_INLINE)
    #define UNIT_ASSERT_FALSE(exp) do {{ UNIT_VERIFY_FALSE_IMPL(exp)(exp, UTILITY_PP_STRINGIZE(exp), UTILITY_PP_FILE, UTILITY_PP_LINE); }} while(false)
#endif

#define UNIT_VERIFY_EQ_IMPL(v1, v2) [&](const auto & v_1, const auto & v_2, const char * v1_str, const char * v2_str, const char * file, unsigned int line) -> const auto & { \
        if (const ::testing::AssertionResult exp_value = ::testing::internal::EqHelper<GTEST_IS_NULL_LITERAL_(v_1)>::Compare(v1_str, v2_str, v_1, v_2)); \
        else UTILITY_GTEST_FAIL_EXP_FUNC_INLINE(exp_value, file, line); \
        UTILITY_ASSERT_POST_TEST(); \
        return v_1; \
    }

#define UNIT_VERIFY_EQ(v1, v2) (( UNIT_VERIFY_EQ_IMPL(v1, v2)(v1, v2, UTILITY_PP_STRINGIZE(v1), UTILITY_PP_STRINGIZE(v2), UTILITY_PP_FILE, UTILITY_PP_LINE) ))
#if ERROR_IF_EMPTY_PP_DEF(DONT_USE_UNIT_ASSERT_CALL_THROUGH_MACRO_INLINE)
    #define UNIT_ASSERT_EQ(v1, v2) do {{ UNIT_VERIFY_EQ_IMPL(v1, v2)(v1, v2, UTILITY_PP_STRINGIZE(v1), UTILITY_PP_STRINGIZE(v2), UTILITY_PP_FILE, UTILITY_PP_LINE); }} while(false)
#endif

////

#define UNIT_VERIFY_NE_IMPL(v1, v2) [&](const auto & v_1, const auto & v_2, const char * v1_str, const char * v2_str, const char * file, unsigned int line) -> const auto & { \
        if (const ::testing::AssertionResult exp_value = ::testing::internal::CmpHelperNE(v1_str, v2_str, v_1, v_2)); \
        else UTILITY_GTEST_FAIL_EXP_FUNC_INLINE(exp_value, file, line); \
        UTILITY_ASSERT_POST_TEST(); \
        return v_1; \
    }

#define UNIT_VERIFY_NE(v1, v2) (( UNIT_VERIFY_NE_IMPL(v1, v2)(v1, v2, UTILITY_PP_STRINGIZE(v1), UTILITY_PP_STRINGIZE(v2), UTILITY_PP_FILE, UTILITY_PP_LINE) ))
#if ERROR_IF_EMPTY_PP_DEF(DONT_USE_UNIT_ASSERT_CALL_THROUGH_MACRO_INLINE)
    #define UNIT_ASSERT_NE(v1, v2) do {{ UNIT_VERIFY_NE_IMPL(v1, v2)(v1, v2, UTILITY_PP_STRINGIZE(v1), UTILITY_PP_STRINGIZE(v2), UTILITY_PP_FILE, UTILITY_PP_LINE); }} while(false)
#endif

////

#define UNIT_VERIFY_LE_IMPL(v1, v2) [&](const auto & v_1, const auto & v_2, const char * v1_str, const char * v2_str, const char * file, unsigned int line) -> const auto & { \
        if (const ::testing::AssertionResult exp_value = ::testing::internal::CmpHelperLE(v1_str, v2_str, v_1, v_2)); \
        else UTILITY_GTEST_FAIL_EXP_FUNC_INLINE(exp_value, file, line); \
        UTILITY_ASSERT_POST_TEST(); \
        return v_1; \
    }

#define UNIT_VERIFY_LE(v1, v2) (( UNIT_VERIFY_LE_IMPL(v1, v2)(v1, v2, UTILITY_PP_STRINGIZE(v1), UTILITY_PP_STRINGIZE(v2), UTILITY_PP_FILE, UTILITY_PP_LINE) ))
#if ERROR_IF_EMPTY_PP_DEF(DONT_USE_UNIT_ASSERT_CALL_THROUGH_MACRO_INLINE)
    #define UNIT_ASSERT_LE(v1, v2) do {{ UNIT_VERIFY_LE_IMPL(v1, v2)(v1, v2, UTILITY_PP_STRINGIZE(v1), UTILITY_PP_STRINGIZE(v2), UTILITY_PP_FILE, UTILITY_PP_LINE); }} while(false)
#endif

////

#define UNIT_VERIFY_LT_IMPL(v1, v2) [&](const auto & v_1, const auto & v_2, const char * v1_str, const char * v2_str, const char * file, unsigned int line) -> const auto & { \
        if (const ::testing::AssertionResult exp_value = ::testing::internal::CmpHelperLT(v1_str, v2_str, v_1, v_2)); \
        else UTILITY_GTEST_FAIL_EXP_FUNC_INLINE(exp_value, file, line); \
        UTILITY_ASSERT_POST_TEST(); \
        return v_1; \
    }

#define UNIT_VERIFY_LT(v1, v2) (( UNIT_VERIFY_LT_IMPL(v1, v2)(v1, v2, UTILITY_PP_STRINGIZE(v1), UTILITY_PP_STRINGIZE(v2), UTILITY_PP_FILE, UTILITY_PP_LINE) ))
#if ERROR_IF_EMPTY_PP_DEF(DONT_USE_UNIT_ASSERT_CALL_THROUGH_MACRO_INLINE)
    #define UNIT_ASSERT_LT(v1, v2) do {{ UNIT_VERIFY_LT_IMPL(v1, v2)(v1, v2, UTILITY_PP_STRINGIZE(v1), UTILITY_PP_STRINGIZE(v2), UTILITY_PP_FILE, UTILITY_PP_LINE); }} while(false)
#endif

////

#define UNIT_VERIFY_GE_IMPL(v1, v2) [&](const auto & v_1, const auto & v_2, const char * v1_str, const char * v2_str, const char * file, unsigned int line) -> const auto & { \
        if (const ::testing::AssertionResult exp_value = ::testing::internal::CmpHelperGE(v1_str, v2_str, v_1, v_2)); \
        else UTILITY_GTEST_FAIL_EXP_FUNC_INLINE(exp_value, file, line); \
        UTILITY_ASSERT_POST_TEST(); \
        return v_1; \
    }

#define UNIT_VERIFY_GE(v1, v2) (( UNIT_VERIFY_GE_IMPL(v1, v2)(v1, v2, UTILITY_PP_STRINGIZE(v1), UTILITY_PP_STRINGIZE(v2), UTILITY_PP_FILE, UTILITY_PP_LINE) ))
#if ERROR_IF_EMPTY_PP_DEF(DONT_USE_UNIT_ASSERT_CALL_THROUGH_MACRO_INLINE)
    #define UNIT_ASSERT_GE(v1, v2) do {{ UNIT_VERIFY_GE_IMPL(v1, v2)(v1, v2, UTILITY_PP_STRINGIZE(v1), UTILITY_PP_STRINGIZE(v2), UTILITY_PP_FILE, UTILITY_PP_LINE); }} while(false)
#endif

////

#define UNIT_VERIFY_GT_IMPL(v1, v2) [&](const auto & v_1, const auto & v_2, const char * v1_str, const char * v2_str, const char * file, unsigned int line) -> const auto & { \
        if (const ::testing::AssertionResult exp_value = ::testing::internal::CmpHelperGT(v1_str, v2_str, v_1, v_2)); \
        else UTILITY_GTEST_FAIL_EXP_FUNC_INLINE(exp_value, file, line); \
        UTILITY_ASSERT_POST_TEST(); \
        return v_1; \
    }

#define UNIT_VERIFY_GT(v1, v2) (( UNIT_VERIFY_GT_IMPL(v1, v2)(v1, v2, UTILITY_PP_STRINGIZE(v1), UTILITY_PP_STRINGIZE(v2), UTILITY_PP_FILE, UTILITY_PP_LINE) ))
#if ERROR_IF_EMPTY_PP_DEF(DONT_USE_UNIT_ASSERT_CALL_THROUGH_MACRO_INLINE)
    #define UNIT_ASSERT_GT(v1, v2) do {{ UNIT_VERIFY_GT_IMPL(v1, v2)(v1, v2, UTILITY_PP_STRINGIZE(v1), UTILITY_PP_STRINGIZE(v2), UTILITY_PP_FILE, UTILITY_PP_LINE); }} while(false)
#endif

#endif

#endif

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


#if ERROR_IF_EMPTY_PP_DEF(DISABLE_VERIFY_ASSERT) || defined(BENCH_TESTS)

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

#else

// TIPS:
//  * avoid usage the unit test asserts in debug because of greater runtime slow down in respect to basic assert implementation
//

#if defined(_DEBUG)

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

#elif defined(UNIT_TESTS)

#if ERROR_IF_EMPTY_PP_DEF(USE_BASIC_ASSERT_INSTEAD_UNIT_ASSERT)

#define VERIFY_TRUE     BASIC_VERIFY_TRUE
#define VERIFY_FALSE    BASIC_VERIFY_FALSE

#define VERIFY_EQ       BASIC_VERIFY_EQ
#define VERIFY_NE       BASIC_VERIFY_NE
#define VERIFY_LE       BASIC_VERIFY_LE
#define VERIFY_LT       BASIC_VERIFY_LT
#define VERIFY_GE       BASIC_VERIFY_GE
#define VERIFY_GT       BASIC_VERIFY_GT

#define ASSERT_TRUE     BASIC_ASSERT_TRUE
#define ASSERT_FALSE    BASIC_ASSERT_FALSE

#define ASSERT_EQ       BASIC_ASSERT_EQ
#define ASSERT_NE       BASIC_ASSERT_NE
#define ASSERT_LE       BASIC_ASSERT_LE
#define ASSERT_LT       BASIC_ASSERT_LT
#define ASSERT_GE       BASIC_ASSERT_GE
#define ASSERT_GT       BASIC_ASSERT_GT

#define ASSERT_VERIFY_ENABLED 1

#define IF_ASSERT_VERIFY_ENABLED(x) if(x)

#else

#define VERIFY_TRUE     UNIT_VERIFY_TRUE
#define VERIFY_FALSE    UNIT_VERIFY_FALSE

#define VERIFY_EQ       UNIT_VERIFY_EQ
#define VERIFY_NE       UNIT_VERIFY_NE
#define VERIFY_LE       UNIT_VERIFY_LE
#define VERIFY_LT       UNIT_VERIFY_LT
#define VERIFY_GE       UNIT_VERIFY_GE
#define VERIFY_GT       UNIT_VERIFY_GT

#define ASSERT_TRUE     UNIT_ASSERT_TRUE
#define ASSERT_FALSE    UNIT_ASSERT_FALSE

#define ASSERT_EQ       UNIT_ASSERT_EQ
#define ASSERT_NE       UNIT_ASSERT_NE
#define ASSERT_LE       UNIT_ASSERT_LE
#define ASSERT_LT       UNIT_ASSERT_LT
#define ASSERT_GE       UNIT_ASSERT_GE
#define ASSERT_GT       UNIT_ASSERT_GT

#define ASSERT_VERIFY_ENABLED 1

#define IF_ASSERT_VERIFY_ENABLED(x) if(x)

#endif

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

#if defined(UNIT_TESTS) || defined(BENCH_TESTS)
    inline void gtest_fail_true(const char * exp_str, const char * file, unsigned int line) // must be not `__forceinline`-ed!
    {
        DEBUG_BREAK_IN_DEBUGGER(true);
        GTEST_TEST_BOOLEAN_(false, exp_str, false, true, UTILITY_ASSERT_GTEST_FATAL_FAILURE_);
    }

    inline void gtest_fail_false(const char * exp_str, const char * file, unsigned int line) // must be not `__forceinline`-ed!
    {
        DEBUG_BREAK_IN_DEBUGGER(true);
        GTEST_TEST_BOOLEAN_(false, exp_str, true, false, UTILITY_ASSERT_GTEST_FATAL_FAILURE_);
    }

    inline void gtest_fail_exp(const ::testing::AssertionResult & exp_value, const char * file, unsigned int line) // must be not `__forceinline`-ed!
    {
        DEBUG_BREAK_IN_DEBUGGER(true);
        GTEST_ASSERT_(exp_value, UTILITY_ASSERT_GTEST_FATAL_FAILURE_);
    }
#endif

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

#if defined(UNIT_TESTS) || defined(BENCH_TESTS)
        template <typename T>
        FORCE_INLINE const T & gtest_verify(const T & exp_var, const char * exp_str) const {
            if (exp_var ? true : false); // to avoid `warning C4800: forcing value to bool 'true' or 'false' (performance warning)`
            else UTILITY_GTEST_FAIL_TRUE_FUNC_INLINE(exp_str, file, line);

            UTILITY_ASSERT_POST_TEST();

            return exp_var;
        }
#endif

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

#if defined(UNIT_TESTS) || defined(BENCH_TESTS)
        template <typename T>
        FORCE_INLINE const T & gtest_verify(const T & exp_var, const char * exp_str) const {
            if (exp_var ? false : true); // to avoid `warning C4800: forcing value to bool 'true' or 'false' (performance warning)`
            else UTILITY_GTEST_FAIL_FALSE_FUNC_INLINE(exp_str, file, line);

            UTILITY_ASSERT_POST_TEST();

            return exp_var;
        }
#endif

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

#if defined(UNIT_TESTS) || defined(BENCH_TESTS)
        template <typename T1, typename T2>
        FORCE_INLINE const T1 & gtest_verify(const T1 & v1, const T2 & v2, const char * v1_str, const char * v2_str) const {
            if (const ::testing::AssertionResult exp_value = ::testing::internal::EqHelper<GTEST_IS_NULL_LITERAL_(v1)>::Compare(v1_str, v2_str, v1, v2));
            else UTILITY_GTEST_FAIL_EXP_FUNC_INLINE(exp_value, file, line);

            UTILITY_ASSERT_POST_TEST();

            return v1;
        }
#endif

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

#if defined(UNIT_TESTS) || defined(BENCH_TESTS)
        template <typename T1, typename T2>
        FORCE_INLINE const T1 & gtest_verify(const T1 & v1, const T2 & v2, const char * v1_str, const char * v2_str) const {
            if (const ::testing::AssertionResult exp_value = ::testing::internal::CmpHelperNE(v1_str, v2_str, v1, v2));
            else UTILITY_GTEST_FAIL_EXP_FUNC_INLINE(exp_value, file, line);

            UTILITY_ASSERT_POST_TEST();

            return v1;
        }
#endif

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

#if defined(UNIT_TESTS) || defined(BENCH_TESTS)
        template <typename T1, typename T2>
        FORCE_INLINE const T1 & gtest_verify(const T1 & v1, const T2 & v2, const char * v1_str, const char * v2_str) const {
            if (const ::testing::AssertionResult exp_value = ::testing::internal::CmpHelperLE(v1_str, v2_str, v1, v2));
            else UTILITY_GTEST_FAIL_EXP_FUNC_INLINE(exp_value, file, line);

            UTILITY_ASSERT_POST_TEST();

            return v1;
        }
#endif

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

#if defined(UNIT_TESTS) || defined(BENCH_TESTS)
        template <typename T1, typename T2>
        FORCE_INLINE const T1 & gtest_verify(const T1 & v1, const T2 & v2, const char * v1_str, const char * v2_str) const {
            if (const ::testing::AssertionResult exp_value = ::testing::internal::CmpHelperLT(v1_str, v2_str, v1, v2));
            else UTILITY_GTEST_FAIL_EXP_FUNC_INLINE(exp_value, file, line);

            UTILITY_ASSERT_POST_TEST();

            return v1;
        }
#endif

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

#if defined(UNIT_TESTS) || defined(BENCH_TESTS)
        template <typename T1, typename T2>
        FORCE_INLINE const T1 & gtest_verify(const T1 & v1, const T2 & v2, const char * v1_str, const char * v2_str) const {
            if (const ::testing::AssertionResult exp_value = ::testing::internal::CmpHelperGE(v1_str, v2_str, v1, v2));
            else UTILITY_GTEST_FAIL_EXP_FUNC_INLINE(exp_value, file, line);

            UTILITY_ASSERT_POST_TEST();

            return v1;
        }
#endif

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

#if defined(UNIT_TESTS) || defined(BENCH_TESTS)
        template <typename T1, typename T2>
        FORCE_INLINE const T1 & gtest_verify(const T1 & v1, const T2 & v2, const char * v1_str, const char * v2_str) const {
            if (const ::testing::AssertionResult exp_value = ::testing::internal::CmpHelperGT(v1_str, v2_str, v1, v2));
            else UTILITY_GTEST_FAIL_EXP_FUNC_INLINE(exp_value, file, line);

            UTILITY_ASSERT_POST_TEST();

            return v1;
        }
#endif

        const char *    file;
        const wchar_t * file_w;
        unsigned int    line;
        const char *    funcsig;
    };

}

#endif
