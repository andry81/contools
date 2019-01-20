#include "test_common.hpp"

#include <tacklelib/tackle/deque.hpp>

#include <vector>
#include <deque>


template <typename Deque>
inline void test_deque_empty(const Deque & deq)
{
    ASSERT_EQ(deq.size(), 0U);
}

template <typename Deque, typename T>
inline void test_deque(const Deque & deq, const std::deque<T> & values)
{
    const size_t deq_size = deq.size();

    ASSERT_EQ(deq_size, values.size());

    size_t value_index = 0;

    auto begin_it = deq.begin();
    auto end_it = deq.end();

    if (!deq.empty()) {
        ASSERT_FALSE(values.empty());
        ASSERT_EQ(*begin_it, values.front());
        ASSERT_EQ(deq.front(), values.front());
        ASSERT_EQ(deq.back(), values.back());

        auto it = begin_it;
        ++it;

        if (deq_size == 1) {
            ASSERT_EQ(it, end_it);
        }
        else {
            ASSERT_NE(it, end_it);
        }

        it = begin_it;
        it++;

        if (deq_size == 1) {
            ASSERT_EQ(it, end_it);
        }
        else {
            ASSERT_NE(it, end_it);
        }

        it = end_it;
        --it;

        if (deq_size == 1) {
            ASSERT_EQ(it, begin_it);
        }
        else {
            ASSERT_NE(it, begin_it);
        }

        it = end_it;
        it--;

        if (deq_size == 1) {
            ASSERT_EQ(it, begin_it);
        }
        else {
            ASSERT_NE(it, begin_it);
        }
    }
    else ASSERT_TRUE(values.empty());

    for(auto it = begin_it; it != end_it; ++it, value_index++)
    {
        ASSERT_EQ(*it, values[value_index]);
        ASSERT_EQ(deq[value_index], values[value_index]);
    }

    if (begin_it != end_it) {
        value_index = deq.size();
        auto it = end_it;

        do {
            --value_index;
            --it;

            ASSERT_EQ(*it, values[value_index]);
            ASSERT_EQ(deq[value_index], values[value_index]);
        } while(it != begin_it);
    }
}

template <typename T>
inline void test_deque_push_back(size_t min_arr0_capacity, size_t min_arr1_capacity_bytes, size_t max_size_from_limit, size_t max_size_to_limit)
{
    for (size_t j = 1; j <= max_size_to_limit; j++) {
        tackle::deque<T> deq{ tackle::deque_params{ min_arr0_capacity, min_arr1_capacity_bytes } };
        std::deque<T> etha;

        for (size_t i = 1; i <= max_size_from_limit * j; i++) {
            deq.push_back(i);
            etha.push_back(i);
            test_deque(deq, etha);
        }

        deq.clear();
        etha.clear();

        test_deque_empty(deq);

        for (size_t i = 1; i <= max_size_from_limit * j; i++) {
            deq.push_back(i);
            etha.push_back(i);
            test_deque(deq, etha);
        }
    }
}

template <typename T>
inline void test_deque_push_front(size_t min_arr0_capacity, size_t min_arr1_capacity_bytes, size_t max_size_from_limit, size_t max_size_to_limit)
{
    for (size_t j = 1; j <= max_size_to_limit; j++) {
        tackle::deque<T> deq{ tackle::deque_params{ min_arr0_capacity, min_arr1_capacity_bytes } };
        std::deque<T> etha;

        for (size_t i = 1; i <= max_size_from_limit * j; i++) {
            deq.push_front(i);
            etha.push_front(i);
            test_deque(deq, etha);
        }

        deq.clear();
        etha.clear();

        test_deque_empty(deq);

        for (size_t i = 1; i <= max_size_from_limit * j; i++) {
            deq.push_front(i);
            etha.push_front(i);
            test_deque(deq, etha);
        }
    }
}

TEST(TackleDequeTest, deque_push_back)
{
    test_deque_push_back<int>(1, 2, 5, 10);
    test_deque_push_back<int>(2, 3, 5, 10);
    test_deque_push_back<int>(2, 1, 5, 10);
    test_deque_push_back<int>(3, 2, 5, 10);
    test_deque_push_back<int>(3, 3, 5, 10);
    test_deque_push_back<int>(4, 3, 5, 10);
    test_deque_push_back<int>(4, 8, 5, 10);
    test_deque_push_back<int>(16, 8, 5, 10);
    test_deque_push_back<int>(16, 32, 5, 10);
}

TEST(TackleDequeTest, deque_push_front)
{
    test_deque_push_front<int>(1, 2, 5, 10);
    test_deque_push_front<int>(2, 3, 5, 10);
    test_deque_push_front<int>(2, 1, 5, 10);
    test_deque_push_front<int>(3, 2, 5, 10);
    test_deque_push_front<int>(3, 3, 5, 10);
    test_deque_push_front<int>(4, 3, 5, 10);
    test_deque_push_front<int>(4, 8, 5, 10);
    test_deque_push_front<int>(16, 8, 5, 10);
    test_deque_push_front<int>(16, 32, 5, 10);
}

template <typename T>
inline void test_deque_push_back_front(bool from_back, size_t min_arr0_capacity, size_t min_arr1_capacity_bytes, size_t max_size_from_limit, size_t max_size_to_limit)
{
    for (size_t j = 1; j <= max_size_to_limit; j++) {
        tackle::deque<T> deq{ tackle::deque_params{ min_arr0_capacity, min_arr1_capacity_bytes } };
        std::deque<T> etha;

        size_t push_count = 0;

        for (size_t i = 1; i <= max_size_from_limit * j; i++, push_count++) {
            if (!(push_count & 0x01) ^ from_back) {
                deq.push_back(i);
                etha.push_back(i);
            }
            else {
                deq.push_front(i);
                etha.push_front(i);
            }
            test_deque(deq, etha);
        }

        deq.clear();
        etha.clear();

        test_deque_empty(deq);

        push_count = 0;

        for (size_t i = 1; i <= max_size_from_limit * j; i++, push_count++) {
            if (!(push_count & 0x01) ^ from_back) {
                deq.push_back(i);
                etha.push_back(i);
            }
            else {
                deq.push_front(i);
                etha.push_front(i);
            }
            test_deque(deq, etha);
        }
    }
}

TEST(TackleDequeTest, deque_push_back_front)
{
    test_deque_push_back_front<int>(true, 1, 2, 5, 10);
    test_deque_push_back_front<int>(true, 2, 3, 5, 10);
    test_deque_push_back_front<int>(true, 2, 1, 5, 10);
    test_deque_push_back_front<int>(true, 3, 2, 5, 10);
    test_deque_push_back_front<int>(true, 3, 3, 5, 10);
    test_deque_push_back_front<int>(true, 4, 3, 5, 10);
    test_deque_push_back_front<int>(true, 4, 8, 5, 10);
    test_deque_push_back_front<int>(true, 16, 8, 5, 10);
    test_deque_push_back_front<int>(true, 16, 32, 5, 10);

    test_deque_push_back_front<int>(false, 1, 2, 5, 10);
    test_deque_push_back_front<int>(false, 2, 3, 5, 10);
    test_deque_push_back_front<int>(false, 2, 1, 5, 10);
    test_deque_push_back_front<int>(false, 3, 2, 5, 10);
    test_deque_push_back_front<int>(false, 3, 3, 5, 10);
    test_deque_push_back_front<int>(false, 4, 3, 5, 10);
    test_deque_push_back_front<int>(false, 4, 8, 5, 10);
    test_deque_push_back_front<int>(false, 16, 8, 5, 10);
    test_deque_push_back_front<int>(false, 16, 32, 5, 10);
}

template <typename T>
inline void test_stdlib_deque_push_back_time(size_t max_size_from_limit, size_t max_size_to_limit)
{
    for (size_t j = 1; j <= max_size_to_limit; j++) {
        std::deque<T> deq;

        {
            for (size_t i = 1; i <= max_size_from_limit * j; i++) {
                deq.push_back(i);
            }

            const bool is_empty = deq.empty();
            UTILITY_SUPPRESS_OPTIMIZATION_ON_VAR(is_empty);
        }

        deq.clear();

        {
            for (size_t i = 1; i <= max_size_from_limit * j; i++) {
                deq.push_back(i);
            }

            const bool is_empty = deq.empty();
            UTILITY_SUPPRESS_OPTIMIZATION_ON_VAR(is_empty);
        }
    }
}

template <typename T>
inline void test_thislib_deque_push_back_time(size_t min_arr0_capacity, size_t min_arr1_capacity_bytes, size_t max_size_from_limit, size_t max_size_to_limit)
{
    for (size_t j = 1; j <= max_size_to_limit; j++) {
        tackle::deque<T> deq{ tackle::deque_params{ min_arr0_capacity, min_arr1_capacity_bytes } };

        {
            for (size_t i = 1; i <= max_size_from_limit * j; i++) {
                deq.push_back(i);
            }

            const bool is_empty = deq.empty();
            UTILITY_SUPPRESS_OPTIMIZATION_ON_VAR(is_empty);
        }

        deq.clear();

        {
            for (size_t i = 1; i <= max_size_from_limit * j; i++) {
                deq.push_back(i);
            }

            const bool is_empty = deq.empty();
            UTILITY_SUPPRESS_OPTIMIZATION_ON_VAR(is_empty);
        }
    }
}

template <typename T>
inline void test_stdlib_deque_push_front_time(size_t max_size_from_limit, size_t max_size_to_limit)
{
    for (size_t j = 1; j <= max_size_to_limit; j++) {
        std::deque<T> deq;

        {
            for (size_t i = 1; i <= max_size_from_limit * j; i++) {
                deq.push_front(i);
            }

            const bool is_empty = deq.empty();
            UTILITY_SUPPRESS_OPTIMIZATION_ON_VAR(is_empty);
        }

        deq.clear();

        {
            for (size_t i = 1; i <= max_size_from_limit * j; i++) {
                deq.push_front(i);
            }

            const bool is_empty = deq.empty();
            UTILITY_SUPPRESS_OPTIMIZATION_ON_VAR(is_empty);
        }
    }
}

template <typename T>
inline void test_thislib_deque_push_front_time(size_t min_arr0_capacity, size_t min_arr1_capacity_bytes, size_t max_size_from_limit, size_t max_size_to_limit)
{
    for (size_t j = 1; j <= max_size_to_limit; j++) {
        tackle::deque<T> deq{ tackle::deque_params{ min_arr0_capacity, min_arr1_capacity_bytes } };

        {
            for (size_t i = 1; i <= max_size_from_limit * j; i++) {
                deq.push_front(i);
            }

            const bool is_empty = deq.empty();
            UTILITY_SUPPRESS_OPTIMIZATION_ON_VAR(is_empty);
        }

        deq.clear();

        {
            for (size_t i = 1; i <= max_size_from_limit * j; i++) {
                deq.push_front(i);
            }

            const bool is_empty = deq.empty();
            UTILITY_SUPPRESS_OPTIMIZATION_ON_VAR(is_empty);
        }
    }
}

TEST(TackleDequeTest, stdlib_deque_push_back_time)
{
    test_stdlib_deque_push_back_time<int>(50, DEBUG_RELEASE_EXPR(100, 1000));
}

TEST(TackleDequeTest, stdlib_deque_push_front_time)
{
    test_stdlib_deque_push_front_time<int>(50, DEBUG_RELEASE_EXPR(100, 1000));
}

TEST(TackleDequeTest, thislib_deque_push_back_time)
{
    test_thislib_deque_push_back_time<int>(256, 256 * 1024, 50, DEBUG_RELEASE_EXPR(100, 1000));
}

TEST(TackleDequeTest, thislib_deque_push_front_time)
{
    test_thislib_deque_push_front_time<int>(256, 256 * 1024, 50, DEBUG_RELEASE_EXPR(100, 1000));
}

template <typename T>
inline void test_stdlib_deque_opindex_time(size_t size)
{
    std::deque<T> deq;

    for (size_t i = 1; i <= size; i++) {
        deq.push_back(i);
    }

    for (size_t i = 1; i <= size; i++) {
        const T v = deq[i - 1];
        UTILITY_SUPPRESS_OPTIMIZATION_ON_VAR(v);
    }
}

template <typename T>
inline void test_thislib_deque_opindex_time(size_t min_arr0_capacity, size_t min_arr1_capacity_bytes, size_t size)
{
    tackle::deque<T> deq{ tackle::deque_params{ min_arr0_capacity, min_arr1_capacity_bytes } };

    for (size_t i = 1; i <= size; i++) {
        deq.push_back(i);
    }

    for (size_t i = 1; i <= size; i++) {
        const T v = deq[i - 1];
        UTILITY_SUPPRESS_OPTIMIZATION_ON_VAR(v);
    }
}

TEST(TackleDequeTest, stdlib_deque_opindex_time)
{
    test_stdlib_deque_opindex_time<int>(DEBUG_RELEASE_EXPR(100000, 1000000));
}

TEST(TackleDequeTest, thislib_deque_opindex_time)
{
    test_thislib_deque_opindex_time<int>(256, 256 * 1024, DEBUG_RELEASE_EXPR(100000, 1000000));
}

template <typename T>
inline void test_deque_pop_back(size_t min_arr0_capacity, size_t min_arr1_capacity_bytes, size_t max_size_from_limit, size_t max_size_to_limit)
{
    for (size_t j = 1; j <= max_size_to_limit; j++) {
        tackle::deque<T> deq{ tackle::deque_params{ min_arr0_capacity, min_arr1_capacity_bytes } };
        std::deque<T> etha;

        for (size_t i = 1; i <= max_size_from_limit * j; i++) {
            deq.push_back(i);
            etha.push_back(i);
        }

        for (size_t i = 1; i <= max_size_from_limit * j; i++) {
            deq.pop_back();
            etha.pop_back();
            test_deque(deq, etha);
        }

        test_deque_empty(deq);

        for (size_t i = 1; i <= max_size_from_limit * j; i++) {
            deq.push_back(i);
            etha.push_back(i);
        }

        for (size_t i = 1; i <= max_size_from_limit * j; i++) {
            deq.pop_back();
            etha.pop_back();
            test_deque(deq, etha);
        }

        test_deque_empty(deq);
    }
}

template <typename T>
inline void test_deque_pop_front(size_t min_arr0_capacity, size_t min_arr1_capacity_bytes, size_t max_size_from_limit, size_t max_size_to_limit)
{
    for (size_t j = 1; j <= max_size_to_limit; j++) {
        tackle::deque<T> deq{ tackle::deque_params{ min_arr0_capacity, min_arr1_capacity_bytes } };
        std::deque<T> etha;

        for (size_t i = 1; i <= max_size_from_limit * j; i++) {
            deq.push_front(i);
            etha.push_front(i);
        }

        for (size_t i = 1; i <= max_size_from_limit * j; i++) {
            deq.pop_front();
            etha.pop_front();
            test_deque(deq, etha);
        }

        test_deque_empty(deq);

        for (size_t i = 1; i <= max_size_from_limit * j; i++) {
            deq.push_front(i);
            etha.push_front(i);
        }

        for (size_t i = 1; i <= max_size_from_limit * j; i++) {
            deq.pop_front();
            etha.pop_front();
            test_deque(deq, etha);
        }

        test_deque_empty(deq);
    }
}

TEST(TackleDequeTest, deque_pop_back)
{
    test_deque_pop_back<int>(1, 2, 5, 10);
    test_deque_pop_back<int>(2, 3, 5, 10);
    test_deque_pop_back<int>(2, 1, 5, 10);
    test_deque_pop_back<int>(3, 2, 5, 10);
    test_deque_pop_back<int>(3, 3, 5, 10);
    test_deque_pop_back<int>(4, 3, 5, 10);
    test_deque_pop_back<int>(4, 8, 5, 10);
    test_deque_pop_back<int>(16, 8, 5, 10);
    test_deque_pop_back<int>(16, 32, 5, 10);
}

TEST(TackleDequeTest, deque_pop_front)
{
    test_deque_pop_front<int>(1, 2, 5, 10);
    test_deque_pop_front<int>(2, 3, 5, 10);
    test_deque_pop_front<int>(2, 1, 5, 10);
    test_deque_pop_front<int>(3, 2, 5, 10);
    test_deque_pop_front<int>(3, 3, 5, 10);
    test_deque_pop_front<int>(4, 3, 5, 10);
    test_deque_pop_front<int>(4, 8, 5, 10);
    test_deque_pop_front<int>(16, 8, 5, 10);
    test_deque_pop_front<int>(16, 32, 5, 10);
}

template <typename T>
inline void test_deque_pop_push_back(size_t min_arr0_capacity, size_t min_arr1_capacity_bytes, size_t max_size_from_limit, size_t max_size_to_limit)
{
    for (size_t j = 1; j <= max_size_to_limit; j++) {
        tackle::deque<T> deq{ tackle::deque_params{ min_arr0_capacity, min_arr1_capacity_bytes } };
        std::deque<T> etha;

        for (size_t i = 1; i <= max_size_from_limit * j; i++) {
            deq.push_back(i);
            etha.push_back(i);
        }

        for (size_t i = 1; i <= max_size_from_limit * j; i++) {
            deq.pop_back();
            etha.pop_back();
        }

        for (size_t i = 1; i <= max_size_from_limit * j; i++) {
            deq.push_back(i);
            etha.push_back(i);
            test_deque(deq, etha);
        }

        deq.clear();
        etha.clear();

        test_deque_empty(deq);

        for (size_t i = 1; i <= max_size_from_limit * j; i++) {
            deq.push_back(i);
            etha.push_back(i);
        }

        for (size_t i = 1; i <= max_size_from_limit * j; i++) {
            deq.pop_back();
            etha.pop_back();
        }

        for (size_t i = 1; i <= max_size_from_limit * j; i++) {
            deq.push_back(i);
            etha.push_back(i);
            test_deque(deq, etha);
        }
    }
}

template <typename T>
inline void test_deque_pop_push_front(size_t min_arr0_capacity, size_t min_arr1_capacity_bytes, size_t max_size_from_limit, size_t max_size_to_limit)
{
    for (size_t j = 1; j <= max_size_to_limit; j++) {
        tackle::deque<T> deq{ tackle::deque_params{ min_arr0_capacity, min_arr1_capacity_bytes } };
        std::deque<T> etha;

        for (size_t i = 1; i <= max_size_from_limit * j; i++) {
            deq.push_front(i);
            etha.push_front(i);
        }

        for (size_t i = 1; i <= max_size_from_limit * j; i++) {
            deq.pop_front();
            etha.pop_front();
        }

        for (size_t i = 1; i <= max_size_from_limit * j; i++) {
            deq.push_front(i);
            etha.push_front(i);
            test_deque(deq, etha);
        }

        deq.clear();
        etha.clear();

        test_deque_empty(deq);

        for (size_t i = 1; i <= max_size_from_limit * j; i++) {
            deq.push_front(i);
            etha.push_front(i);
        }

        for (size_t i = 1; i <= max_size_from_limit * j; i++) {
            deq.pop_front();
            etha.pop_front();
        }

        for (size_t i = 1; i <= max_size_from_limit * j; i++) {
            deq.push_front(i);
            etha.push_front(i);
            test_deque(deq, etha);
        }
    }
}

TEST(TackleDequeTest, deque_pop_push_back)
{
    test_deque_pop_push_back<int>(1, 2, 5, 10);
    test_deque_pop_push_back<int>(2, 3, 5, 10);
    test_deque_pop_push_back<int>(2, 1, 5, 10);
    test_deque_pop_push_back<int>(3, 2, 5, 10);
    test_deque_pop_push_back<int>(3, 3, 5, 10);
    test_deque_pop_push_back<int>(4, 3, 5, 10);
    test_deque_pop_push_back<int>(4, 8, 5, 10);
    test_deque_pop_push_back<int>(16, 8, 5, 10);
    test_deque_pop_push_back<int>(16, 32, 5, 10);
}

TEST(TackleDequeTest, deque_pop_push_front)
{
    test_deque_pop_push_front<int>(1, 2, 5, 10);
    test_deque_pop_push_front<int>(2, 3, 5, 10);
    test_deque_pop_push_front<int>(2, 1, 5, 10);
    test_deque_pop_push_front<int>(3, 2, 5, 10);
    test_deque_pop_push_front<int>(3, 3, 5, 10);
    test_deque_pop_push_front<int>(4, 3, 5, 10);
    test_deque_pop_push_front<int>(4, 8, 5, 10);
    test_deque_pop_push_front<int>(16, 8, 5, 10);
    test_deque_pop_push_front<int>(16, 32, 5, 10);
}

template <typename T>
inline void test_deque_pop_back_front(bool push_from_back, bool pop_from_back, size_t min_arr0_capacity, size_t min_arr1_capacity_bytes, size_t max_size_from_limit, size_t max_size_to_limit)
{
    for (size_t j = 1; j <= max_size_to_limit; j++) {
        tackle::deque<T> deq{ tackle::deque_params{ min_arr0_capacity, min_arr1_capacity_bytes } };
        std::deque<T> etha;

        size_t push_count = 0;
        size_t pop_count = 0;

        for (size_t i = 1; i <= max_size_from_limit * j; i++, push_count++) {
            if (!(push_count & 0x01) ^ push_from_back) {
                deq.push_back(i);
                etha.push_back(i);
            }
            else {
                deq.push_front(i);
                etha.push_front(i);
            }
        }

        for (size_t i = 1; i <= max_size_from_limit * j; i++, pop_count++) {
            if (!(pop_count & 0x01) ^ pop_from_back) {
                deq.pop_back();
                etha.pop_back();
            }
            else {
                deq.pop_front();
                etha.pop_front();
            }
            test_deque(deq, etha);
        }

        test_deque_empty(deq);

        push_count = 0;
        pop_count = 0;

        for (size_t i = 1; i <= max_size_from_limit * j; i++, push_count++) {
            if (!(push_count & 0x01) ^ push_from_back) {
                deq.push_back(i);
                etha.push_back(i);
            }
            else {
                deq.push_front(i);
                etha.push_front(i);
            }
        }

        for (size_t i = 1; i <= max_size_from_limit * j; i++, pop_count++) {
            if (!(pop_count & 0x01) ^ pop_from_back) {
                deq.pop_back();
                etha.pop_back();
            }
            else {
                deq.pop_front();
                etha.pop_front();
            }
            test_deque(deq, etha);
        }

        test_deque_empty(deq);
    }
}

TEST(TackleDequeTest, deque_pop_back_front)
{
    test_deque_pop_back_front<int>(true, true, 1, 2, 5, 10);
    test_deque_pop_back_front<int>(true, true, 2, 3, 5, 10);
    test_deque_pop_back_front<int>(true, true, 2, 1, 5, 10);
    test_deque_pop_back_front<int>(true, true, 3, 2, 5, 10);
    test_deque_pop_back_front<int>(true, true, 3, 3, 5, 10);
    test_deque_pop_back_front<int>(true, true, 4, 3, 5, 10);
    test_deque_pop_back_front<int>(true, true, 4, 8, 5, 10);
    test_deque_pop_back_front<int>(true, true, 16, 8, 5, 10);
    test_deque_pop_back_front<int>(true, true, 16, 32, 5, 10);

    test_deque_pop_back_front<int>(false, false, 1, 2, 5, 10);
    test_deque_pop_back_front<int>(false, false, 2, 3, 5, 10);
    test_deque_pop_back_front<int>(false, false, 2, 1, 5, 10);
    test_deque_pop_back_front<int>(false, false, 3, 2, 5, 10);
    test_deque_pop_back_front<int>(false, false, 3, 3, 5, 10);
    test_deque_pop_back_front<int>(false, false, 4, 3, 5, 10);
    test_deque_pop_back_front<int>(false, false, 4, 8, 5, 10);
    test_deque_pop_back_front<int>(false, false, 16, 8, 5, 10);
    test_deque_pop_back_front<int>(false, false, 16, 32, 5, 10);

    test_deque_pop_back_front<int>(true, false, 1, 2, 5, 10);
    test_deque_pop_back_front<int>(true, false, 2, 3, 5, 10);
    test_deque_pop_back_front<int>(true, false, 2, 1, 5, 10);
    test_deque_pop_back_front<int>(true, false, 3, 2, 5, 10);
    test_deque_pop_back_front<int>(true, false, 3, 3, 5, 10);
    test_deque_pop_back_front<int>(true, false, 4, 3, 5, 10);
    test_deque_pop_back_front<int>(true, false, 4, 8, 5, 10);
    test_deque_pop_back_front<int>(true, false, 16, 8, 5, 10);
    test_deque_pop_back_front<int>(true, false, 16, 32, 5, 10);

    test_deque_pop_back_front<int>(false, true, 1, 2, 5, 10);
    test_deque_pop_back_front<int>(false, true, 2, 3, 5, 10);
    test_deque_pop_back_front<int>(false, true, 2, 1, 5, 10);
    test_deque_pop_back_front<int>(false, true, 3, 2, 5, 10);
    test_deque_pop_back_front<int>(false, true, 3, 3, 5, 10);
    test_deque_pop_back_front<int>(false, true, 4, 3, 5, 10);
    test_deque_pop_back_front<int>(false, true, 4, 8, 5, 10);
    test_deque_pop_back_front<int>(false, true, 16, 8, 5, 10);
    test_deque_pop_back_front<int>(false, true, 16, 32, 5, 10);
}

template <typename T>
inline void test_deque_pop_push_back_front(bool push_from_back, bool pop_from_back, size_t min_arr0_capacity, size_t min_arr1_capacity_bytes, size_t max_size_from_limit, size_t max_size_to_limit)
{
    for (size_t j = 1; j <= max_size_to_limit; j++) {
        tackle::deque<T> deq{ tackle::deque_params{ min_arr0_capacity, min_arr1_capacity_bytes } };
        std::deque<T> etha;

        size_t push_count = 0;
        size_t pop_count = 0;

        for (size_t i = 1; i <= max_size_from_limit * j; i++, push_count++) {
            if (!(push_count & 0x01) ^ push_from_back) {
                deq.push_back(i);
                etha.push_back(i);
            }
            else {
                deq.push_front(i);
                etha.push_front(i);
            }
        }

        for (size_t i = 1; i <= max_size_from_limit * j; i++, pop_count++) {
            if (!(pop_count & 0x01) ^ pop_from_back) {
                deq.pop_back();
                etha.pop_back();
            }
            else {
                deq.pop_front();
                etha.pop_front();
            }
        }

        push_count = 0;

        for (size_t i = 1; i <= max_size_from_limit * j; i++, push_count++) {
            if (!(push_count & 0x01) ^ push_from_back) {
                deq.push_back(i);
                etha.push_back(i);
            }
            else {
                deq.push_front(i);
                etha.push_front(i);
            }
            test_deque(deq, etha);
        }

        deq.clear();
        etha.clear();

        test_deque_empty(deq);

        push_count = 0;
        pop_count = 0;

        for (size_t i = 1; i <= max_size_from_limit * j; i++, push_count++) {
            if (!(push_count & 0x01) ^ push_from_back) {
                deq.push_back(i);
                etha.push_back(i);
            }
            else {
                deq.push_front(i);
                etha.push_front(i);
            }
        }

        for (size_t i = 1; i <= max_size_from_limit * j; i++, pop_count++) {
            if (!(pop_count & 0x01) ^ pop_from_back) {
                deq.pop_back();
                etha.pop_back();
            }
            else {
                deq.pop_front();
                etha.pop_front();
            }
        }

        push_count = 0;

        for (size_t i = 1; i <= max_size_from_limit * j; i++, push_count++) {
            if (!(push_count & 0x01) ^ push_from_back) {
                deq.push_back(i);
                etha.push_back(i);
            }
            else {
                deq.push_front(i);
                etha.push_front(i);
            }
            test_deque(deq, etha);
        }
    }
}

TEST(TackleDequeTest, deque_pop_push_back_front)
{
    test_deque_pop_push_back_front<int>(true, true, 1, 2, 5, 10);
    test_deque_pop_push_back_front<int>(true, true, 2, 3, 5, 10);
    test_deque_pop_push_back_front<int>(true, true, 2, 1, 5, 10);
    test_deque_pop_push_back_front<int>(true, true, 3, 2, 5, 10);
    test_deque_pop_push_back_front<int>(true, true, 3, 3, 5, 10);
    test_deque_pop_push_back_front<int>(true, true, 4, 3, 5, 10);
    test_deque_pop_push_back_front<int>(true, true, 4, 8, 5, 10);
    test_deque_pop_push_back_front<int>(true, true, 16, 8, 5, 10);
    test_deque_pop_push_back_front<int>(true, true, 16, 32, 5, 10);

    test_deque_pop_push_back_front<int>(false, false, 1, 2, 5, 10);
    test_deque_pop_push_back_front<int>(false, false, 2, 3, 5, 10);
    test_deque_pop_push_back_front<int>(false, false, 2, 1, 5, 10);
    test_deque_pop_push_back_front<int>(false, false, 3, 2, 5, 10);
    test_deque_pop_push_back_front<int>(false, false, 3, 3, 5, 10);
    test_deque_pop_push_back_front<int>(false, false, 4, 3, 5, 10);
    test_deque_pop_push_back_front<int>(false, false, 4, 8, 5, 10);
    test_deque_pop_push_back_front<int>(false, false, 16, 8, 5, 10);
    test_deque_pop_push_back_front<int>(false, false, 16, 32, 5, 10);

    test_deque_pop_push_back_front<int>(true, false, 1, 2, 5, 10);
    test_deque_pop_push_back_front<int>(true, false, 2, 3, 5, 10);
    test_deque_pop_push_back_front<int>(true, false, 2, 1, 5, 10);
    test_deque_pop_push_back_front<int>(true, false, 3, 2, 5, 10);
    test_deque_pop_push_back_front<int>(true, false, 3, 3, 5, 10);
    test_deque_pop_push_back_front<int>(true, false, 4, 3, 5, 10);
    test_deque_pop_push_back_front<int>(true, false, 4, 8, 5, 10);
    test_deque_pop_push_back_front<int>(true, false, 16, 8, 5, 10);
    test_deque_pop_push_back_front<int>(true, false, 16, 32, 5, 10);

    test_deque_pop_push_back_front<int>(false, true, 1, 2, 5, 10);
    test_deque_pop_push_back_front<int>(false, true, 2, 3, 5, 10);
    test_deque_pop_push_back_front<int>(false, true, 2, 1, 5, 10);
    test_deque_pop_push_back_front<int>(false, true, 3, 2, 5, 10);
    test_deque_pop_push_back_front<int>(false, true, 3, 3, 5, 10);
    test_deque_pop_push_back_front<int>(false, true, 4, 3, 5, 10);
    test_deque_pop_push_back_front<int>(false, true, 4, 8, 5, 10);
    test_deque_pop_push_back_front<int>(false, true, 16, 8, 5, 10);
    test_deque_pop_push_back_front<int>(false, true, 16, 32, 5, 10);
}

template <typename T>
inline void test_stdlib_deque_pop_back_time(size_t max_size_from_limit, size_t max_size_to_limit)
{
    for (size_t j = 1; j <= max_size_to_limit; j++) {
        std::deque<T> deq;

        {
            for (size_t i = 1; i <= max_size_from_limit * j; i++) {
                deq.push_back(i);
            }

            for (size_t i = 1; i <= max_size_from_limit * j; i++) {
                deq.pop_back();
            }

            const bool is_empty = deq.empty();
            UTILITY_SUPPRESS_OPTIMIZATION_ON_VAR(is_empty);
        }

        {
            for (size_t i = 1; i <= max_size_from_limit * j; i++) {
                deq.push_back(i);
            }

            for (size_t i = 1; i <= max_size_from_limit * j; i++) {
                deq.pop_back();
            }

            const bool is_empty = deq.empty();
            UTILITY_SUPPRESS_OPTIMIZATION_ON_VAR(is_empty);
        }
    }
}

template <typename T>
inline void test_thislib_deque_pop_back_time(size_t min_arr0_capacity, size_t min_arr1_capacity_bytes, size_t max_size_from_limit, size_t max_size_to_limit)
{
    for (size_t j = 1; j <= max_size_to_limit; j++) {
        tackle::deque<T> deq{ tackle::deque_params{ min_arr0_capacity, min_arr1_capacity_bytes } };

        {
            for (size_t i = 1; i <= max_size_from_limit * j; i++) {
                deq.push_back(i);
            }

            for (size_t i = 1; i <= max_size_from_limit * j; i++) {
                deq.pop_back();
            }

            const bool is_empty = deq.empty();
            UTILITY_SUPPRESS_OPTIMIZATION_ON_VAR(is_empty);
        }

        {
            for (size_t i = 1; i <= max_size_from_limit * j; i++) {
                deq.push_back(i);
            }

            for (size_t i = 1; i <= max_size_from_limit * j; i++) {
                deq.pop_back();
            }

            const bool is_empty = deq.empty();
            UTILITY_SUPPRESS_OPTIMIZATION_ON_VAR(is_empty);
        }
    }
}

template <typename T>
inline void test_stdlib_deque_pop_front_time(size_t max_size_from_limit, size_t max_size_to_limit)
{
    for (size_t j = 1; j <= max_size_to_limit; j++) {
        std::deque<T> deq;

        {
            for (size_t i = 1; i <= max_size_from_limit * j; i++) {
                deq.push_front(i);
            }

            for (size_t i = 1; i <= max_size_from_limit * j; i++) {
                deq.pop_front();
            }

            const bool is_empty = deq.empty();
            UTILITY_SUPPRESS_OPTIMIZATION_ON_VAR(is_empty);
        }

        {
            for (size_t i = 1; i <= max_size_from_limit * j; i++) {
                deq.push_front(i);
            }

            for (size_t i = 1; i <= max_size_from_limit * j; i++) {
                deq.pop_front();
            }

            const bool is_empty = deq.empty();
            UTILITY_SUPPRESS_OPTIMIZATION_ON_VAR(is_empty);
        }
    }
}

template <typename T>
inline void test_thislib_deque_pop_front_time(size_t min_arr0_capacity, size_t min_arr1_capacity_bytes, size_t max_size_from_limit, size_t max_size_to_limit)
{
    for (size_t j = 1; j <= max_size_to_limit; j++) {
        tackle::deque<T> deq{ tackle::deque_params{ min_arr0_capacity, min_arr1_capacity_bytes } };

        {
            for (size_t i = 1; i <= max_size_from_limit * j; i++) {
                deq.push_front(i);
            }

            for (size_t i = 1; i <= max_size_from_limit * j; i++) {
                deq.pop_front();
            }

            const bool is_empty = deq.empty();
            UTILITY_SUPPRESS_OPTIMIZATION_ON_VAR(is_empty);
        }

        {
            for (size_t i = 1; i <= max_size_from_limit * j; i++) {
                deq.push_front(i);
            }

            for (size_t i = 1; i <= max_size_from_limit * j; i++) {
                deq.pop_front();
            }

            const bool is_empty = deq.empty();
            UTILITY_SUPPRESS_OPTIMIZATION_ON_VAR(is_empty);
        }
    }
}

TEST(TackleDequeTest, stdlib_deque_pop_back_time)
{
    test_stdlib_deque_pop_back_time<int>(50, DEBUG_RELEASE_EXPR(100, 1000));
}

TEST(TackleDequeTest, stdlib_deque_pop_front_time)
{
    test_stdlib_deque_pop_front_time<int>(50, DEBUG_RELEASE_EXPR(100, 1000));
}

TEST(TackleDequeTest, thislib_deque_pop_back_time)
{
    test_thislib_deque_pop_back_time<int>(256, 256 * 1024, 50, DEBUG_RELEASE_EXPR(100, 1000));
}

TEST(TackleDequeTest, thislib_deque_pop_front_time)
{
    test_thislib_deque_pop_front_time<int>(256, 256 * 1024, 50, DEBUG_RELEASE_EXPR(100, 1000));
}
