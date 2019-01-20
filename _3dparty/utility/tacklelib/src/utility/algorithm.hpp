#pragma once

#include <src/tacklelib_private.hpp>

#include <tacklelib/utility/utility.hpp>
#include <tacklelib/utility/static_assert.hpp>
#include <tacklelib/utility/type_traits.hpp>
#include <tacklelib/utility/math.hpp>

#include <boost/chrono.hpp>

#include <type_traits>
#include <limits>
#include <memory>
#include <algorithm>


#define TACKLE_PP_DEFAULT_UNROLLED_COPY_SIZE    256 // should not be greater than TACKLE_PP_MAX_UNROLLED_COPY_SIZE from `utility/algorithm/generated/unroll_copy_switch.hpp`
#define TACKLE_PP_MAX_UNROLLED_COPY_SIZE        256

// copy with builtin unroll
#define UTILITY_COPY(from, to, size, ...) \
    ::utility::copy(from, to, size, ## __VA_ARGS__)

#define UTILITY_COPY_FORCE_INLINE(from, to, size, ...) \
    ::utility::copy_forceinline(from, to, size, ## __VA_ARGS__)

// stride copy w/o unroll (already force inlined)
#define UTILITY_STRIDE_COPY(to_buf_offset, from, from_size, copy_size, stride_step, to, to_size) \
    ::utility::stride_copy(to_buf_offset, from, from_size, copy_size, stride_step, to, to_size)

STATIC_ASSERT_GE(TACKLE_PP_MAX_UNROLLED_COPY_SIZE, TACKLE_PP_DEFAULT_UNROLLED_COPY_SIZE, "TACKLE_PP_DEFAULT_UNROLLED_COPY_SIZE must be not greater than TACKLE_PP_MAX_UNROLLED_COPY_SIZE");


namespace utility
{
    namespace chrono = boost::chrono;

    // POD type, DO NOT USE constructors
    template<typename T, size_t S>
    struct StaticArray
    {
        static const size_t size = S;

        T buf[S];
    };

    // for iterators debugging
    template<typename T>
    FORCE_INLINE bool is_singular_iterator(const T & it)
    {
        T tmp = {};
        return !std::memcmp(&tmp, &it, sizeof(it));
    }

    // Unrolls even in debug, useful to speedup not optimized code, where a call to function has unnecessary overhead
    // (for example, call to `memcpy` in a `for` with relatively small copy distance).
    template<typename T>
    inline void copy(const T * from, T * to, size_t size, size_t unroll_size = TACKLE_PP_DEFAULT_UNROLLED_COPY_SIZE)
    {
        const size_t unrolled_size = (std::min)(unroll_size, size_t(TACKLE_PP_MAX_UNROLLED_COPY_SIZE));
        if (unrolled_size >= size) {
            switch(size) {
                case 0: break;
                #include <src/utility/algorithm/generated/unroll_copy_switch.hpp>
                default: DEBUG_ASSERT_TRUE(false);
            }
        }
        else if (UTILITY_CONST_EXPR(std::is_trivially_copyable<T>::value)) {
            memcpy(to, from, sizeof(T) * size);
        }
        else {
            for (size_t i = 0; i < size; i++) {
                to[i] = from[i];
            }
        }
    }

    // force inline version of unrolled copy
    template<typename T>
    FORCE_INLINE void copy_forceinline(const T * from, T * to, size_t size, size_t unroll_size = TACKLE_PP_DEFAULT_UNROLLED_COPY_SIZE)
    {
        const size_t unrolled_size = (std::min)(unroll_size, size_t(TACKLE_PP_MAX_UNROLLED_COPY_SIZE));
        if (unrolled_size >= size) {
            switch(size) {
                case 0: break;
                #include <src/utility/algorithm/generated/unroll_copy_switch.hpp>
                default: DEBUG_ASSERT_TRUE(false);
            }
        }
        else if (UTILITY_CONST_EXPR(std::is_trivially_copyable<T>::value)) {
            memcpy(to, from, sizeof(T) * size);
        }
        else {
            for (size_t i = 0; i < size; i++) {
                to[i] = from[i];
            }
        }
    }

    template<typename T>
    FORCE_INLINE size_t stride_copy(size_t & to_buf_offset_ref, const T * from, size_t from_size, size_t copy_size, size_t stride_step, T * to, size_t to_size)
    {
        // TODO:
        //  * UTILITY_STRIDE_COPY from the middle of slot byte instead of only from slot beginning byte

        DEBUG_ASSERT_TRUE(from_size && to_size);
        DEBUG_ASSERT_GE(stride_step, copy_size); // step begins from copy begin byte!

        using chunk_type = StaticArray<T, 4>;

        STATIC_ASSERT_EQ(sizeof(chunk_type), sizeof(T) * chunk_type::size, "StaticArray should contain pure static array inside with out any gaps or padding");

        CONSTEXPR const size_t copy_chunk_size = sizeof(chunk_type);

        STATIC_ASSERT_GE(copy_chunk_size, 4U, "must be at least 4 bytes");
        STATIC_ASSERT_EQ(math::uint32_pof2_floor<copy_chunk_size / sizeof(T)>::value, copy_chunk_size / sizeof(T), "must be power of 2");

        size_t from_buf_offset = 0;
        size_t to_buf_offset = 0;

        size_t left_buf_from_size = from_size;
        size_t left_buf_to_size = to_size;

        if (from_size >= copy_chunk_size) {
            // reduced buffer size where we can copy the last byte by the chunk block size w/o access violation out of the buffer end bound
            const size_t from_chunked_size = from_size + 1 - copy_chunk_size;

            size_t num_whole_steps = from_chunked_size / stride_step;
            size_t step_remainder = from_chunked_size % stride_step;

            // prognose output buffer size, and recalculate steps and remainder
            const size_t buf_size_to_copy = copy_size * num_whole_steps + (std::min)(step_remainder, copy_size);
            if (to_size < buf_size_to_copy) {
                num_whole_steps = to_size / copy_size;
                step_remainder = to_size % copy_size;
            }

            const size_t num_whole_chunks_in_copy_size = copy_size / copy_chunk_size;
            const size_t chunks_remainder_in_copy_size = copy_size % copy_chunk_size;

            // remainder condition moved out of most inner loop
            if (!chunks_remainder_in_copy_size) {
                // simplified copy by chunk blocks w/o remainder
                for (size_t i = 0; i < num_whole_steps; i++) {
                    for (size_t j = 0; j < num_whole_chunks_in_copy_size; j++) {
                        *reinterpret_cast<chunk_type *>(to + to_buf_offset) = *reinterpret_cast<const chunk_type *>(from + from_buf_offset + copy_chunk_size * j);
                        to_buf_offset += copy_chunk_size;

                        DEBUG_ASSERT_GE(left_buf_to_size, copy_chunk_size);
                        left_buf_to_size -= copy_chunk_size;
                    }

                    from_buf_offset += stride_step;

                    DEBUG_ASSERT_GE(left_buf_from_size, stride_step);
                    left_buf_from_size -= stride_step;
                }
            }
            else {
                // copy by chunk blocks with remainder
                for (size_t i = 0; i < num_whole_steps; i++) {
                    for (size_t j = 0; j < num_whole_chunks_in_copy_size; j++) {
                        *reinterpret_cast<chunk_type *>(to + to_buf_offset) = *reinterpret_cast<const chunk_type *>(from + from_buf_offset + copy_chunk_size * j);
                        to_buf_offset += copy_chunk_size;

                        DEBUG_ASSERT_GE(left_buf_to_size, copy_chunk_size);
                        left_buf_to_size -= copy_chunk_size;
                    }
                    // remainder copy
                    *reinterpret_cast<chunk_type *>(to + to_buf_offset) = *reinterpret_cast<const chunk_type *>(from + from_buf_offset + copy_chunk_size * num_whole_chunks_in_copy_size);
                    to_buf_offset += chunks_remainder_in_copy_size;

                    DEBUG_ASSERT_GE(left_buf_to_size, chunks_remainder_in_copy_size);
                    left_buf_to_size -= chunks_remainder_in_copy_size;

                    from_buf_offset += stride_step;

                    DEBUG_ASSERT_GE(left_buf_from_size, stride_step);
                    left_buf_from_size -= stride_step;
                }
            }

            // rest of the buffer cannot be optimized, copy as is
            const size_t left_buf_to_copy_remainder = step_remainder + copy_chunk_size - 1;

            size_t num_left_whole_steps = left_buf_to_copy_remainder / stride_step;
            size_t left_step_remainder = left_buf_to_copy_remainder % stride_step;

            // prognose left output buffer size, and recalculate steps and remainder
            const size_t left_buf_size_to_copy = copy_size * num_left_whole_steps + (std::min)(left_step_remainder, copy_size);
            if (left_buf_to_size < left_buf_size_to_copy) {
                num_left_whole_steps = left_buf_to_size / copy_size;
                left_step_remainder = left_buf_to_size % copy_size;
            }

            for (size_t i = 0; i < num_left_whole_steps; i++) {
                for (size_t j = 0; j < copy_size; j++) {
                    to[to_buf_offset++] = from[from_buf_offset + j];
                }

                from_buf_offset += stride_step;

                DEBUG_ASSERT_GE(left_buf_from_size, stride_step);
                left_buf_from_size -= stride_step;

                DEBUG_ASSERT_GE(left_buf_to_size, copy_size);
                left_buf_to_size -= copy_size;
            }

            const size_t left_step_remain_size_to_copy = (std::min)(left_step_remainder, copy_size);
            if (left_step_remain_size_to_copy) {
                for (size_t i = 0; i < left_step_remain_size_to_copy; i++) {
                    to[to_buf_offset++] = from[from_buf_offset + i];
                }

                const size_t buf_from_remain_size = (std::min)(left_buf_from_size, stride_step);

                from_buf_offset += buf_from_remain_size;

                DEBUG_ASSERT_GE(left_buf_from_size, buf_from_remain_size);
                left_buf_from_size -= buf_from_remain_size;

                DEBUG_ASSERT_GE(left_buf_to_size, left_step_remain_size_to_copy);
                left_buf_to_size -= left_step_remain_size_to_copy;
            }
        }
        else {
            size_t num_whole_steps = from_size / stride_step;
            size_t step_remainder = from_size % stride_step;

            // prognose output buffer size, and recalculate steps and remainder
            const size_t buf_size_to_copy = copy_size * num_whole_steps + (std::min)(step_remainder, copy_size);
            if (to_size < buf_size_to_copy) {
                num_whole_steps = to_size / copy_size;
                step_remainder = to_size % copy_size;
            }

            for (size_t i = 0; i < num_whole_steps; i++) {
                for (size_t j = 0; j < copy_size; j++) {
                    to[to_buf_offset++] = from[from_buf_offset + j];
                }

                from_buf_offset += stride_step;

                DEBUG_ASSERT_GE(left_buf_from_size, stride_step);
                left_buf_from_size -= stride_step;

                DEBUG_ASSERT_GE(left_buf_to_size, copy_size);
                left_buf_to_size -= copy_size;
            }

            const size_t left_step_remain_size_to_copy = (std::min)(step_remainder, copy_size);
            if (left_step_remain_size_to_copy) {
                for (size_t i = 0; i < left_step_remain_size_to_copy; i++) {
                    to[to_buf_offset++] = from[from_buf_offset + i];
                }

                const size_t buf_from_remain_size = (std::min)(left_buf_from_size, stride_step);

                from_buf_offset += buf_from_remain_size;

                DEBUG_ASSERT_GE(left_buf_from_size, buf_from_remain_size);
                left_buf_from_size -= buf_from_remain_size;

                DEBUG_ASSERT_GE(left_buf_to_size, left_step_remain_size_to_copy);
                left_buf_to_size -= left_step_remain_size_to_copy;
            }
        }

        DEBUG_ASSERT_TRUE(!left_buf_from_size || !left_buf_to_size); // at least one buffer must hit the end bound

        // if out buffer has space after the copy, then put `\0` at the end of copied sequence to cut off trash bytes in the buffer which might be copied in previous iterations
        if (left_buf_to_size) {
            to[to_buf_offset] = '\0';
        }

        to_buf_offset_ref = to_buf_offset;

        return from_buf_offset;
    }

    FORCE_INLINE_ALWAYS void spin_sleep(uint64_t wait_nsec)
    {
        const auto begin_wait_time = chrono::high_resolution_clock::now();

        while (true)
        {
            const auto next_wait_time = chrono::high_resolution_clock::now();

            const auto spent_time_dur = next_wait_time - begin_wait_time;

            const uint64_t spent_time_dur_nsec = spent_time_dur.count() >= 0 ? // workaround for negative values
                chrono::duration_cast<chrono::nanoseconds>(spent_time_dur).count() : 0;

            if (spent_time_dur_nsec >= wait_nsec) {
                return;
            }
        }
    }

    template <typename Functor>
    FORCE_INLINE void spin_sleep(uint64_t wait_nsec, Functor && spin_function)
    {
        const auto begin_wait_time = chrono::high_resolution_clock::now();

        while (true)
        {
            const auto next_wait_time = chrono::high_resolution_clock::now();

            const auto spent_time_dur = next_wait_time - begin_wait_time;

            const uint64_t spent_time_dur_nsec = spent_time_dur.count() >= 0 ? // workaround for negative values
                chrono::duration_cast<chrono::nanoseconds>(spent_time_dur).count() : 0;

            if (spent_time_dur_nsec >= wait_nsec) {
                return;
            }

            if (!spin_function()) {
                return;
            }
        }
    }

    template <typename Functor>
    FORCE_INLINE void spin_sleep(uint64_t wait_nsec, Functor && spin_function, uint64_t schedule_call_time_nsec)
    {
        const auto begin_wait_time = chrono::high_resolution_clock::now();

        uint64_t schedule_time_next_index;
        uint64_t schedule_time_prev_index = math::uint64_max;

        while (true)
        {
            const auto next_wait_time = chrono::high_resolution_clock::now();

            const auto spent_time_dur = next_wait_time - begin_wait_time;

            const uint64_t spent_time_dur_nsec = spent_time_dur.count() >= 0 ? // workaround for negative values
                chrono::duration_cast<chrono::nanoseconds>(spent_time_dur).count() : 0;

            if (spent_time_dur_nsec >= wait_nsec) {
                return;
            }

            schedule_time_next_index = spent_time_dur_nsec / schedule_call_time_nsec;

            if (schedule_time_next_index != schedule_time_prev_index) {
                if (!spin_function()) {
                    return;
                }
                schedule_time_prev_index = schedule_time_next_index;
            }
        }
    }
}
