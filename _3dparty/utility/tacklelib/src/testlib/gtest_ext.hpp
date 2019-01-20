#pragma once

#if !defined(TACKLE_TESTLIB) && !defined(UNIT_TESTS) && !defined(BENCH_TESTS)
#error This header must be used explicitly in a test declared environment. Use respective definitions to declare a test environment.
#endif

#include <gtest/gtest.h>

#include <functional>


#define EXPECT_TRUE_PRED(v1, fail_pred) \
    EXPECT_PRED1( \
        ::gtest_ext::expect_true_pred{ [&]() -> void { \
            fail_pred; \
        } }, \
        v1)

#define EXPECT_FALSE_PRED(v1, fail_pred) \
    EXPECT_PRED1( \
        ::gtest_ext::expect_false_pred{ [&]() -> void { \
            fail_pred; \
        } }, \
        v1)

#define EXPECT_EQ_PRED(v1, v2, fail_pred) \
    EXPECT_PRED2( \
        ::gtest_ext::expect_eq_pred{ [&]() -> void { \
            fail_pred; \
        } }, \
        v1, v2)

#define EXPECT_NE_PRED(v1, v2, fail_pred) \
    EXPECT_PRED2( \
        ::gtest_ext::expect_ne_pred{ [&]() -> void { \
            fail_pred; \
        } }, \
        v1, v2)

#define EXPECT_LE_PRED(v1, v2, fail_pred) \
    EXPECT_PRED2( \
        ::gtest_ext::expect_le_pred{ [&]() -> void { \
            fail_pred; \
        } }, \
        v1, v2)

#define EXPECT_LT_PRED(v1, v2, fail_pred) \
    EXPECT_PRED2( \
        ::gtest_ext::expect_lt_pred{ [&]() -> void { \
            fail_pred; \
        } }, \
        v1, v2)

#define EXPECT_GE_PRED(v1, v2, fail_pred) \
    EXPECT_PRED2( \
        ::gtest_ext::expect_ge_pred{ [&]() -> void { \
            fail_pred; \
        } }, \
        v1, v2)

#define EXPECT_GT_PRED(v1, v2, fail_pred) \
    EXPECT_PRED2( \
        ::gtest_ext::expect_gt_pred{ [&]() -> void { \
            fail_pred; \
        } }, \
        v1, v2)


namespace gtest_ext
{
    struct expect_true_pred
    {
        template <typename Functor>
        expect_true_pred(Functor && f) :
            pred{ std::forward<Functor>(f) }
        {
        }

        template <typename T>
        bool operator()(T && x) const
        {
            if (x ? true : false) return true;
            pred();
            return false;
        }

        std::function<void()> pred;
    };

    struct expect_false_pred
    {
        template <typename Functor>
        expect_false_pred(Functor && f) :
            pred{ std::forward<Functor>(f) }
        {
        }

        template <typename T>
        bool operator()(T && x) const
        {
            if (x ? false : true) return true;
            pred();
            return false;
        }

        std::function<void()> pred;
    };

    struct expect_eq_pred
    {
        template <typename Functor>
        expect_eq_pred(Functor && f) :
            pred{ std::forward<Functor>(f) }
        {
        }

        template <typename T1, typename T2>
        bool operator()(T1 && v1, T2 && v2) const
        {
            if (v1 == v2) return true;
            pred();
            return false;
        }

        std::function<void()> pred;
    };

    struct expect_ne_pred
    {
        template <typename Functor>
        expect_ne_pred(Functor && f) :
            pred{ std::forward<Functor>(f) }
        {
        }

        template <typename T1, typename T2>
        bool operator()(T1 && v1, T2 && v2) const
        {
            if (v1 != v2) return true;
            pred();
            return false;
        }

        std::function<void()> pred;
    };

    struct expect_le_pred
    {
        template <typename Functor>
        expect_le_pred(Functor && f) :
            pred{ std::forward<Functor>(f) }
        {
        }

        template <typename T1, typename T2>
        bool operator()(T1 && v1, T2 && v2) const
        {
            if (v1 <= v2) return true;
            pred();
            return false;
        }

        std::function<void()> pred;
    };

    struct expect_lt_pred
    {
        template <typename Functor>
        expect_lt_pred(Functor && f) :
            pred{ std::forward<Functor>(f) }
        {
        }

        template <typename T1, typename T2>
        bool operator()(T1 && v1, T2 && v2) const
        {
            if (v1 < v2) return true;
            pred();
            return false;
        }

        std::function<void()> pred;
    };

    struct expect_ge_pred
    {
        template <typename Functor>
        expect_ge_pred(Functor && f) :
            pred{ std::forward<Functor>(f) }
        {
        }

        template <typename T1, typename T2>
        bool operator()(T1 && v1, T2 && v2) const
        {
            if (v1 >= v2) return true;
            pred();
            return false;
        }

        std::function<void()> pred;
    };

    struct expect_gt_pred
    {
        template <typename Functor>
        expect_gt_pred(Functor && f) :
            pred{ std::forward<Functor>(f) }
        {
        }

        template <typename T1, typename T2>
        bool operator()(T1 && v1, T2 && v2) const
        {
            if (v1 > v2) return true;
            pred();
            return false;
        }

        std::function<void()> pred;
    };
}
