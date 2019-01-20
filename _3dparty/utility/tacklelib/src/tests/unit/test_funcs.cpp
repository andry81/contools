#include "test_common.hpp"

#include <tacklelib/utility/math.hpp>
#include <tacklelib/utility/time.hpp>
#include <tacklelib/utility/utility.hpp>

#include <tacklelib/tackle/path_string.hpp>

namespace {
    namespace ti = utility::time;

    struct TestStats_angle_closest_distance
    {
        TestStats_angle_closest_distance() :
            peak_angle_distance_fluctuation(0)
        {
        }

        double peak_angle_distance_fluctuation;
    };

    struct TestStats_angle_distance
    {
        TestStats_angle_distance() :
            peak_angle_distance_fluctuation(0)
        {
        }

        double peak_angle_distance_fluctuation;
    };
}

namespace common
{
    const double angle_closest_distance_epsilon = 0;
    const double angle_distance_epsilon = 0;
}


TEST(FunctionsTest, ROTL)
{
    ASSERT_EQ(::utility::rotl8(0b11000000, 1), 0b10000001);
    ASSERT_EQ(::utility::rotl8(0b11000001, 2), 0b00000111);
    ASSERT_EQ(::utility::rotl8(0b01111110, 1), 0b11111100);
    ASSERT_EQ(::utility::rotl8(0b00111111, 1), 0b01111110);
    ASSERT_EQ(::utility::rotl16(0b1100000000000000, 1), 0b1000000000000001);
    ASSERT_EQ(::utility::rotl16(0b1100000000000001, 2), 0b0000000000000111);
    ASSERT_EQ(::utility::rotl32(0b11000000000000000000000000000000, 1), 0b10000000000000000000000000000001);
    ASSERT_EQ(::utility::rotl32(0b11000000000000000000000000000001, 2), 0b00000000000000000000000000000111);
    ASSERT_EQ(::utility::rotl64(0b1100000000000000000000000000000000000000000000000000000000000000, 1), 0b1000000000000000000000000000000000000000000000000000000000000001);
    ASSERT_EQ(::utility::rotl64(0b1100000000000000000000000000000000000000000000000000000000000001, 2), 0b0000000000000000000000000000000000000000000000000000000000000111);
}

TEST(FunctionsTest, ROTR)
{
    ASSERT_EQ(::utility::rotr8(0b00000011, 1), 0b10000001);
    ASSERT_EQ(::utility::rotr8(0b10000011, 2), 0b11100000);
    ASSERT_EQ(::utility::rotr8(0b01111110, 1), 0b00111111);
    ASSERT_EQ(::utility::rotr8(0b11111100, 1), 0b01111110);
    ASSERT_EQ(::utility::rotr16(0b0000000000000011, 1), 0b1000000000000001);
    ASSERT_EQ(::utility::rotr16(0b1000000000000011, 2), 0b1110000000000000);
    ASSERT_EQ(::utility::rotr32(0b00000000000000000000000000000011, 1), 0b10000000000000000000000000000001);
    ASSERT_EQ(::utility::rotr32(0b10000000000000000000000000000011, 2), 0b11100000000000000000000000000000);
    ASSERT_EQ(::utility::rotr64(0b0000000000000000000000000000000000000000000000000000000000000011, 1), 0b1000000000000000000000000000000000000000000000000000000000000001);
    ASSERT_EQ(::utility::rotr64(0b1000000000000000000000000000000000000000000000000000000000000011, 2), 0b1110000000000000000000000000000000000000000000000000000000000000);
}

TEST(FunctionsTest, int_log2_floor)
{
    for (int i = 1; i < 1000000; i++) {
        ASSERT_EQ(::math::int_log2_floor(i), int(log2(i)));
    }
    for (unsigned int i = 1; i < 1000000; i++) {
        ASSERT_EQ(::math::int_log2_floor(i), (unsigned int)(log2(i)));
    }
}

TEST(FunctionsTest, int_log2_ceil)
{
    for (int i = 1; i < 1000000; i++) {
        ASSERT_EQ(::math::int_log2_ceil(i), int(log2(i + i - 1)));
    }
    for (unsigned int i = 1; i < 1000000; i++) {
        ASSERT_EQ(::math::int_log2_ceil(i), (unsigned int)(log2(i + i - 1)));
    }
}

TEST(FunctionsTest, int_pof2_floor)
{
    for (int i = 1; i < 1000000; i++) {
        ASSERT_EQ(::math::int_pof2_floor(i), pow(2, int(log2(i))));
    }
    for (unsigned int i = 1; i < 1000000; i++) {
        ASSERT_EQ(::math::int_pof2_floor(i), pow(2, (unsigned int)(log2(i))));
    }
}

TEST(FunctionsTest, int_pof2_ceil)
{
    for (int i = 1; i < 1000000; i++) {
        ASSERT_EQ(::math::int_pof2_ceil(i), pow(2, int(log2(i + i - 1))));
    }
    for (unsigned int i = 1; i < 1000000; i++) {
        ASSERT_EQ(::math::int_pof2_ceil(i), pow(2, (unsigned int)(log2(i + i - 1))));
    }
}

TEST(FunctionsTest, int_log2_pof2_floor)
{
    for (int i = 1; i < 1000000; i++) {
        int pof2_floor_value = -1;
        const int log2_floor_value_eta = int(log2(i));
        ASSERT_EQ(::math::int_log2_floor(i, &pof2_floor_value), log2_floor_value_eta);
        ASSERT_EQ(pof2_floor_value, pow(2, log2_floor_value_eta));
    }
    for (unsigned int i = 1; i < 1000000; i++) {
        unsigned int pof2_floor_value = -1;
        const unsigned int log2_floor_value_eta = (unsigned int)(log2(i));
        ASSERT_EQ(::math::int_log2_floor(i, &pof2_floor_value), log2_floor_value_eta);
        ASSERT_EQ(pof2_floor_value, pow(2, log2_floor_value_eta));
    }
}

TEST(FunctionsTest, int_log2_pof2_ceil)
{
    for (int i = 1; i < 1000000; i++) {
        int pof2_ceil_value = -1;
        const int log2_ceil_value_eta = int(log2(i + i - 1));
        ASSERT_EQ(::math::int_log2_ceil(i, &pof2_ceil_value), log2_ceil_value_eta);
        ASSERT_EQ(pof2_ceil_value, pow(2, log2_ceil_value_eta));
    }
    for (unsigned int i = 1; i < 1000000; i++) {
        unsigned int pof2_ceil_value = -1;
        const unsigned int log2_ceil_value_eta = (unsigned int)(log2(i + i - 1));
        ASSERT_EQ(::math::int_log2_ceil(i, &pof2_ceil_value), log2_ceil_value_eta);
        ASSERT_EQ(pof2_ceil_value, pow(2, log2_ceil_value_eta));
    }
}

TEST(FunctionsTest, int_log2_pof2_floor_time)
{
    for (int i = 1; i < 1000000; i++) {
        int pof2_floor_value = -1;
        const int log2_floor_value_eta = int(log2(i));
        ASSERT_EQ(::math::int_log2_floor(i, &pof2_floor_value), log2_floor_value_eta);
        UTILITY_SUPPRESS_OPTIMIZATION_ON_VAR(pof2_floor_value);
    }
    for (unsigned int i = 1; i < 1000000; i++) {
        unsigned int pof2_floor_value = -1;
        const unsigned int log2_floor_value_eta = (unsigned int)(log2(i));
        ASSERT_EQ(::math::int_log2_floor(i, &pof2_floor_value), log2_floor_value_eta);
        UTILITY_SUPPRESS_OPTIMIZATION_ON_VAR(pof2_floor_value);
    }
}

TEST(FunctionsTest, int_log2_pof2_ceil_time)
{
    for (int i = 1; i < 1000000; i++) {
        int pof2_ceil_value = -1;
        const int log2_ceil_value_eta = int(log2(i + i - 1));
        ASSERT_EQ(::math::int_log2_ceil(i, &pof2_ceil_value), log2_ceil_value_eta);
        UTILITY_SUPPRESS_OPTIMIZATION_ON_VAR(pof2_ceil_value);
    }
    for (unsigned int i = 1; i < 1000000; i++) {
        unsigned int pof2_ceil_value = -1;
        const unsigned int log2_ceil_value_eta = (unsigned int)(log2(i + i - 1));
        ASSERT_EQ(::math::int_log2_ceil(i, &pof2_ceil_value), log2_ceil_value_eta);
        UTILITY_SUPPRESS_OPTIMIZATION_ON_VAR(pof2_ceil_value);
    }
}

TEST(FunctionsTest, int_stdlib_log2_floor_time)
{
    for (int i = 1; i < 1000000; i++) {
        const int log2_floor_value = int(log2(i));
        UTILITY_SUPPRESS_OPTIMIZATION_ON_VAR(log2_floor_value);
    }
    for (unsigned int i = 1; i < 1000000; i++) {
        const unsigned int log2_floor_value = (unsigned int)(log2(i));
        UTILITY_SUPPRESS_OPTIMIZATION_ON_VAR(log2_floor_value);
    }
}

TEST(FunctionsTest, int_thislib_log2_floor_time)
{
    for (int i = 1; i < 1000000; i++) {
        const int log2_floor_value = ::math::int_log2_floor(i);
        UTILITY_SUPPRESS_OPTIMIZATION_ON_VAR(log2_floor_value);
    }
    for (unsigned int i = 1; i < 1000000; i++) {
        const unsigned int log2_floor_value = ::math::int_log2_floor(i);
        UTILITY_SUPPRESS_OPTIMIZATION_ON_VAR(log2_floor_value);
    }
}

TEST(FunctionsTest, int_stdlib_log2_ceil_time)
{
    for (int i = 1; i < 1000000; i++) {
        const int log2_ceil_value = int(log2(i + i - 1));
        UTILITY_SUPPRESS_OPTIMIZATION_ON_VAR(log2_ceil_value);
    }
    for (unsigned int i = 1; i < 1000000; i++) {
        const unsigned int log2_ceil_value = (unsigned int)(log2(i + i - 1));
        UTILITY_SUPPRESS_OPTIMIZATION_ON_VAR(log2_ceil_value);
    }
}

TEST(FunctionsTest, int_thislib_log2_ceil_time)
{
    for (int i = 1; i < 1000000; i++) {
        const int log2_ceil_value = ::math::int_log2_ceil(i);
        UTILITY_SUPPRESS_OPTIMIZATION_ON_VAR(log2_ceil_value);
    }
    for (unsigned int i = 1; i < 1000000; i++) {
        const unsigned int log2_ceil_value = ::math::int_log2_ceil(i);
        UTILITY_SUPPRESS_OPTIMIZATION_ON_VAR(log2_ceil_value);
    }
}

TEST(FunctionsTest, unroll_copy)
{
    const int ref[16] = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 };
    int out[16];

    memset(out, 0, utility::static_size(out) * sizeof(out[0]));
    UTILITY_COPY(ref, out, 5, 5);
    ASSERT_TRUE(!memcmp(ref, out, 5) && !out[5]);

    memset(out, 0, utility::static_size(out) * sizeof(out[0]));
    UTILITY_COPY(ref, out, 3, 7);
    ASSERT_TRUE(!memcmp(ref, out, 3) && !out[3]);

    memset(out, 0, utility::static_size(out) * sizeof(out[0]));
    UTILITY_COPY(ref, out, 7, 3);
    ASSERT_TRUE(!memcmp(ref, out, 7) && !out[7]);
}

template <size_t t_out_ref_size, size_t t_ref_size>
void test_stride_copy(size_t stride_size, size_t stride_step,
    size_t ref_size, size_t from_buf_offset_, const int (& ref)[t_ref_size],
    size_t out_size, const int (& out_ref)[t_out_ref_size])
{
    ASSERT_GE(ref_size, out_size);
    ASSERT_GE(out_size, t_out_ref_size);
    int out[math::size_max_of<t_ref_size, t_out_ref_size>::value + 1];
    size_t to_buf_offset;

    memset(out, 0, utility::static_size(out) * sizeof(out[0]));
    const size_t from_buf_offset = UTILITY_STRIDE_COPY(to_buf_offset, ref, ref_size, stride_size, stride_step, out, out_size);
    ASSERT_TRUE(!memcmp(out_ref, out, utility::static_size(out_ref) * sizeof(out_ref[0])));
    if (out_size != t_out_ref_size) {
        ASSERT_FALSE(out[out_size]);
    }
    ASSERT_EQ(from_buf_offset, from_buf_offset_);
    ASSERT_EQ(to_buf_offset, utility::static_size(out_ref));
}

TEST(FunctionsTest, stride_copy)
{
    const int ref[16] = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 };

    test_stride_copy(1, 1, 16, 16, ref, 16, { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 });
    test_stride_copy(1, 3, 16, 16, ref, 16, { 1, 4, 7, 10, 13, 16 });
    test_stride_copy(1, 4, 16, 16, ref, 16, { 1, 5, 9, 13 });
    test_stride_copy(1, 5, 16, 16, ref, 16, { 1, 6, 11, 16 });
    test_stride_copy(2, 2, 16, 16, ref, 16, { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 });
    test_stride_copy(2, 3, 16, 16, ref, 16, { 1, 2, 4, 5, 7, 8, 10, 11, 13, 14, 16 });
    test_stride_copy(2, 4, 16, 16, ref, 16, { 1, 2, 5, 6, 9, 10, 13, 14 });
    test_stride_copy(2, 5, 16, 16, ref, 16, { 1, 2, 6, 7, 11, 12, 16 });
    test_stride_copy(3, 3, 16, 16, ref, 16, { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 });
    test_stride_copy(3, 4, 16, 16, ref, 16, { 1, 2, 3, 5, 6, 7, 9, 10, 11, 13, 14, 15 });
    test_stride_copy(3, 5, 16, 16, ref, 16, { 1, 2, 3, 6, 7, 8, 11, 12, 13, 16 });
    test_stride_copy(3, 6, 16, 16, ref, 16, { 1, 2, 3, 7, 8, 9, 13, 14, 15 });
    test_stride_copy(4, 4, 16, 16, ref, 16, { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 });
    test_stride_copy(4, 5, 16, 16, ref, 16, { 1, 2, 3, 4, 6, 7, 8, 9, 11, 12, 13, 14, 16 });
    test_stride_copy(4, 6, 16, 16, ref, 16, { 1, 2, 3, 4, 7, 8, 9, 10, 13, 14, 15, 16 });
    test_stride_copy(5, 5, 16, 16, ref, 16, { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 });
    test_stride_copy(5, 6, 16, 16, ref, 16, { 1, 2, 3, 4, 5, 7, 8, 9, 10, 11, 13, 14, 15, 16 });
    test_stride_copy(5, 7, 16, 16, ref, 16, { 1, 2, 3, 4, 5, 8, 9, 10, 11, 12, 15, 16 });
    test_stride_copy(6, 6, 16, 16, ref, 16, { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 });
    test_stride_copy(6, 7, 16, 16, ref, 16, { 1, 2, 3, 4, 5, 6, 8, 9, 10, 11, 12, 13, 15, 16 });

    test_stride_copy(1, 1, 16, 10, ref, 10, { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 });
    test_stride_copy(1, 3, 16, 16, ref, 10, { 1, 4, 7, 10, 13, 16 });
    test_stride_copy(1, 4, 16, 16, ref, 10, { 1, 5, 9, 13 });
    test_stride_copy(1, 5, 16, 16, ref, 10, { 1, 6, 11, 16 });
    test_stride_copy(2, 2, 16, 10, ref, 10, { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 });
    test_stride_copy(2, 3, 16, 15, ref, 10, { 1, 2, 4, 5, 7, 8, 10, 11, 13, 14 });
    test_stride_copy(2, 4, 16, 16, ref, 10, { 1, 2, 5, 6, 9, 10, 13, 14 });
    test_stride_copy(2, 5, 16, 16, ref, 10, { 1, 2, 6, 7, 11, 12, 16 });
    //test_stride_copy(3, 3, 16, 10, ref, 10, { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 });
    //test_stride_copy(3, 4, 16, 16, ref, 10, { 1, 2, 3, 5, 6, 7, 9, 10, 11, 13 });
    //test_stride_copy(3, 5, 16, 16, ref, 10, { 1, 2, 3, 6, 7, 8, 11, 12, 13, 16 });
    //test_stride_copy(3, 6, 16, 16, ref, 10, { 1, 2, 3, 7, 8, 9, 13, 14, 15 });
    //test_stride_copy(4, 4, 16, 10, ref, 10, { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 });
    //test_stride_copy(4, 5, 16, 16, ref, 10, { 1, 2, 3, 4, 6, 7, 8, 9, 11, 12 });
    //test_stride_copy(4, 6, 16, 16, ref, 10, { 1, 2, 3, 4, 7, 8, 9, 10, 13, 14 });
    //test_stride_copy(5, 5, 16, 10, ref, 10, { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 });
    //test_stride_copy(5, 6, 16, 16, ref, 10, { 1, 2, 3, 4, 5, 7, 8, 9, 10, 11 });
    //test_stride_copy(5, 7, 16, 16, ref, 10, { 1, 2, 3, 4, 5, 8, 9, 10, 11, 12 });
    //test_stride_copy(6, 6, 16, 10, ref, 10, { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 });
    //test_stride_copy(6, 7, 16, 16, ref, 10, { 1, 2, 3, 4, 5, 6, 8, 9, 10, 11 });
}

//// path_string

template <typename T>
void test_path_string_operator_plus_left(T left_path_str)
{
    // with raw string
    {
        const std::string test1 = left_path_str / "bbb";
        ASSERT_EQ(test1, "aaa/bbb");

        const char * r2 = "bbb";
        const std::string test2 = left_path_str / r2;
        ASSERT_EQ(test2, "aaa/bbb");

        const char * const & r3 = "bbb";
        const std::string test3 = left_path_str / r3;
        ASSERT_EQ(test3, "aaa/bbb");

        const char r4[] = "bbb";
        const std::string test4 = left_path_str / r4;
        ASSERT_EQ(test4, "aaa/bbb");

        const char (& r5)[4] = "bbb";
        const std::string test5 = left_path_str / r5;
        ASSERT_EQ(test5, "aaa/bbb");
    }

    // with std::string
    {
        const std::string r1 = "bbb";
        const std::string test1 = left_path_str / r1;
        ASSERT_EQ(test1, "aaa/bbb");

        const std::string test2 = left_path_str / std::string{ "bbb" };
        ASSERT_EQ(test2, "aaa/bbb");

        const std::string & r3 = "bbb";
        const std::string test3 = left_path_str / r3;
        ASSERT_EQ(test3, "aaa/bbb");

        std::string r4_ = "bbb";
        std::string & r4 = r4_;
        const std::string test4 = left_path_str / r4;
        ASSERT_EQ(test4, "aaa/bbb");
    }

    // with path_string
    {
        const tackle::path_string r1 = "bbb";
        const std::string test1 = left_path_str / r1;
        ASSERT_EQ(test1, "aaa/bbb");

        const std::string test2 = left_path_str / tackle::path_string{ "bbb" };
        ASSERT_EQ(test2, "aaa/bbb");

        const tackle::path_string & r3 = "bbb";
        const std::string test3 = left_path_str / r3;
        ASSERT_EQ(test3, "aaa/bbb");

        tackle::path_string r4_ = "bbb";
        tackle::path_string & r4 = r4_;
        const std::string test4 = left_path_str / r4;
        ASSERT_EQ(test4, "aaa/bbb");
    }
}

void test_path_string_operator_plus_left_by_value()
{
    test_path_string_operator_plus_left<tackle::path_string>("aaa");
}

void test_path_string_operator_plus_left_by_ref()
{
    tackle::path_string path_str = "aaa";
    test_path_string_operator_plus_left<tackle::path_string &>(path_str);
}

void test_path_string_operator_plus_left_by_cref()
{
    test_path_string_operator_plus_left<const tackle::path_string &>("aaa");
}

void test_path_string_operator_plus_left_by_rref()
{
    test_path_string_operator_plus_left<tackle::path_string &&>(std::move(tackle::path_string{ "aaa" }));
}

template <typename T>
void test_path_string_operator_plus_right(T right_path_str)
{
    // with raw string
    {
        const std::string test1 = "aaa" / right_path_str;
        ASSERT_EQ(test1, "aaa/bbb");

        const char * l2 = "aaa";
        const std::string test2 = l2 / right_path_str;
        ASSERT_EQ(test2, "aaa/bbb");

        const char * const & l3 = "aaa";
        const std::string test3 = l3 / right_path_str;
        ASSERT_EQ(test3, "aaa/bbb");

        const char l4[] = "aaa";
        const std::string test4 = l4 / right_path_str;
        ASSERT_EQ(test4, "aaa/bbb");

        const char (& l5)[4] = "aaa";
        const std::string test5 = l5 / right_path_str;
        ASSERT_EQ(test5, "aaa/bbb");
    }

    // with std::string
    {
        const std::string l1 = "aaa";
        const std::string test1 = l1 / right_path_str;
        ASSERT_EQ(test1, "aaa/bbb");

        const std::string test2 = std::string{ "aaa" } / right_path_str;
        ASSERT_EQ(test2, "aaa/bbb");

        const std::string & l3 = "aaa";
        const std::string test3 = l3 / right_path_str;
        ASSERT_EQ(test3, "aaa/bbb");

        std::string l4_ = "aaa";
        std::string & l4 = l4_;
        const std::string test4 = l4 / right_path_str;
        ASSERT_EQ(test4, "aaa/bbb");
    }

    // with path_string
    {
        const tackle::path_string l1 = "aaa";
        const std::string test1 = l1 / right_path_str;
        ASSERT_EQ(test1, "aaa/bbb");

        const std::string test2 = tackle::path_string{ "aaa" } / right_path_str;
        ASSERT_EQ(test2, "aaa/bbb");

        const tackle::path_string & l3 = "aaa";
        const std::string test3 = l3 / right_path_str;
        ASSERT_EQ(test3, "aaa/bbb");

        tackle::path_string l4_ = "aaa";
        tackle::path_string & l4 = l4_;
        const std::string test4 = l4 / right_path_str;
        ASSERT_EQ(test4, "aaa/bbb");
    }
}

void test_path_string_operator_plus_right_by_value()
{
    test_path_string_operator_plus_right<tackle::path_string>("bbb");
}

void test_path_string_operator_plus_right_by_ref()
{
    tackle::path_string path_str = "bbb";
    test_path_string_operator_plus_right<tackle::path_string &>(path_str);
}

void test_path_string_operator_plus_right_by_cref()
{
    test_path_string_operator_plus_right<const tackle::path_string &>("bbb");
}

void test_path_string_operator_plus_right_by_rref()
{
    test_path_string_operator_plus_right<tackle::path_string &&>(std::move(tackle::path_string{ "bbb" }));
}

TEST(FunctionsTest, path_string_operator_plus)
{
    test_path_string_operator_plus_left_by_value();
    test_path_string_operator_plus_left_by_ref();
    test_path_string_operator_plus_left_by_cref();
    test_path_string_operator_plus_left_by_rref();
    test_path_string_operator_plus_right_by_value();
    test_path_string_operator_plus_right_by_ref();
    test_path_string_operator_plus_right_by_cref();
    test_path_string_operator_plus_right_by_rref();
}

//// QD

template <typename T>
void float_compare_normal_with_infinity(double numerator, double denominator)
{
    ASSERT_TRUE(!std::isnan(numerator) && !std::isnan(denominator));
    ASSERT_NE(denominator, 0);

    const double value = numerator / denominator;

    ASSERT_TRUE(!std::isnan(value) && !math::is_infinite(value));
    ASSERT_LT(value, math::positive_infinity(value));
    ASSERT_LT(math::negative_infinity(value), value);

#if ERROR_IF_EMPTY_PP_DEF(ENABLE_QD_INTEGRATION)
    const T qd_value = T(numerator) / denominator;

    ASSERT_TRUE(!std::isnan(qd_value) && !math::is_infinite(qd_value));
    ASSERT_LT(qd_value, math::positive_infinity(qd_value));
    ASSERT_LT(math::negative_infinity(qd_value), qd_value);
#endif
}

TEST(FunctionsTest, float_compare_normal_with_infinity)
{
#if ERROR_IF_EMPTY_PP_DEF(ENABLE_QD_INTEGRATION)
    // dd_real
    float_compare_normal_with_infinity<dd_real>(1.0, 1.0);
    float_compare_normal_with_infinity<dd_real>(0, 1.0);
    float_compare_normal_with_infinity<dd_real>(-1.0, 1.0);

    float_compare_normal_with_infinity<dd_real>(1.0, 3.0);
    float_compare_normal_with_infinity<dd_real>(-1.0, 3.0);

    float_compare_normal_with_infinity<dd_real>(math::positive_max(0.0), 1.0);
    float_compare_normal_with_infinity<dd_real>(math::negative_min(0.0), 1.0);

    // qd_real
    float_compare_normal_with_infinity<qd_real>(1.0, 1.0);
    float_compare_normal_with_infinity<qd_real>(0, 1.0);
    float_compare_normal_with_infinity<qd_real>(-1.0, 1.0);

    float_compare_normal_with_infinity<qd_real>(1.0, 3.0);
    float_compare_normal_with_infinity<qd_real>(-1.0, 3.0);

    float_compare_normal_with_infinity<qd_real>(math::positive_max(0.0), 1.0);
    float_compare_normal_with_infinity<qd_real>(math::negative_min(0.0), 1.0);
#endif

    // double
    float_compare_normal_with_infinity<double>(1.0, 1.0);
    float_compare_normal_with_infinity<double>(0, 1.0);
    float_compare_normal_with_infinity<double>(-1.0, 1.0);

    float_compare_normal_with_infinity<double>(1.0, 3.0);
    float_compare_normal_with_infinity<double>(-1.0, 3.0);

    float_compare_normal_with_infinity<double>(math::positive_max(0.0), 1.0);
    float_compare_normal_with_infinity<double>(math::negative_min(0.0), 1.0);

    // float
    float_compare_normal_with_infinity<float>(1.0, 1.0);
    float_compare_normal_with_infinity<float>(0, 1.0);
    float_compare_normal_with_infinity<float>(-1.0, 1.0);

    float_compare_normal_with_infinity<float>(1.0, 3.0);
    float_compare_normal_with_infinity<float>(-1.0, 3.0);

    float_compare_normal_with_infinity<float>(math::positive_max(0.0f), 1.0);
    float_compare_normal_with_infinity<float>(math::negative_min(0.0f), 1.0);
}

#if ERROR_IF_EMPTY_PP_DEF(ENABLE_QD_INTEGRATION)

template <typename T>
void qdlib_nextafter(double from_numerator, double from_denominator, double to_numerator, double to_denominator)
{
    ASSERT_TRUE(!std::isnan(from_numerator) && !std::isnan(from_denominator));
    ASSERT_TRUE(!std::isnan(to_numerator) && !std::isnan(from_denominator));

    ASSERT_NE(from_denominator, 0);
    ASSERT_NE(to_denominator, 0);

    const T from_value = !math::is_infinite(from_numerator) ? T(from_numerator) / from_denominator : math::signed_infinity(from_numerator);
    const T to_value = !math::is_infinite(to_numerator) ? T(to_numerator) / to_denominator : math::signed_infinity(to_numerator);

    const T qd_value = std::nextafter(from_value, to_value);
    ASSERT_TRUE(!std::isnan(qd_value) && !math::is_infinite(qd_value));

    if (from_value != to_value) {
        ASSERT_NE(qd_value, from_value);
        if (from_value < to_value) {
            ASSERT_LT(from_value, qd_value);
            if (qd_value != to_value) {
                ASSERT_LT(qd_value, to_value);
            }
        }
        else {
            ASSERT_GT(from_value, to_value);
            ASSERT_GT(from_value, qd_value);
            if (qd_value != to_value) {
                ASSERT_GT(qd_value, to_value);
            }
        }
    }
    else {
        ASSERT_EQ(qd_value, from_value);
        ASSERT_EQ(qd_value, to_value);
    }
}

TEST(FunctionsTest, qdlib_real_nextafter)
{
    // dd_real
    qdlib_nextafter<dd_real>(1.0, 1.0, 10.0, 1.0);
    qdlib_nextafter<dd_real>(0.0, 1.0, 10.0, 1.0);
    qdlib_nextafter<dd_real>(-1.0, 1.0, 10.0, 1.0);

    qdlib_nextafter<dd_real>(1.0, 3.0, 10.0, 1.0);
    qdlib_nextafter<dd_real>(-1.0, 3.0, 10.0, 1.0);

    qdlib_nextafter<dd_real>(1.0, 1.0, math::positive_max(0.0), 1.0);
    qdlib_nextafter<dd_real>(0.0, 1.0, math::positive_max(0.0), 1.0);
    qdlib_nextafter<dd_real>(-1.0, 1.0, math::positive_max(0.0), 1.0);

    qdlib_nextafter<dd_real>(1.0, 1.0, math::positive_infinity(0.0), 1.0);
    qdlib_nextafter<dd_real>(0.0, 1.0, math::positive_infinity(0.0), 1.0);
    qdlib_nextafter<dd_real>(-1.0, 1.0, math::positive_infinity(0.0), 1.0);

    qdlib_nextafter<dd_real>(1.0, 1.0, -10.0, 1.0);
    qdlib_nextafter<dd_real>(0.0, 1.0, -10.0, 1.0);
    qdlib_nextafter<dd_real>(-1.0, 1.0, -10.0, 1.0);

    qdlib_nextafter<dd_real>(1.0, 3.0, -10.0, 1.0);
    qdlib_nextafter<dd_real>(-1.0, 3.0, -10.0, 1.0);

    qdlib_nextafter<dd_real>(1.0, 1.0, math::negative_infinity(0.0), 1.0);
    qdlib_nextafter<dd_real>(0.0, 1.0, math::negative_infinity(0.0), 1.0);
    qdlib_nextafter<dd_real>(-1.0, 1.0, math::negative_infinity(0.0), 1.0);

    // qd_real
    qdlib_nextafter<qd_real>(1.0, 1.0, 10.0, 1.0);
    qdlib_nextafter<qd_real>(0.0, 1.0, 10.0, 1.0);
    qdlib_nextafter<qd_real>(-1.0, 1.0, 10.0, 1.0);

    qdlib_nextafter<qd_real>(1.0, 3.0, 10.0, 1.0);
    qdlib_nextafter<qd_real>(-1.0, 3.0, 10.0, 1.0);

    qdlib_nextafter<qd_real>(1.0, 1.0, math::positive_max(0.0), 1.0);
    qdlib_nextafter<qd_real>(0.0, 1.0, math::positive_max(0.0), 1.0);
    qdlib_nextafter<qd_real>(-1.0, 1.0, math::positive_max(0.0), 1.0);

    qdlib_nextafter<qd_real>(1.0, 1.0, math::positive_infinity(0.0), 1.0);
    qdlib_nextafter<qd_real>(0.0, 1.0, math::positive_infinity(0.0), 1.0);
    qdlib_nextafter<qd_real>(-1.0, 1.0, math::positive_infinity(0.0), 1.0);

    qdlib_nextafter<qd_real>(1.0, 1.0, -10.0, 1.0);
    qdlib_nextafter<qd_real>(0.0, 1.0, -10.0, 1.0);
    qdlib_nextafter<qd_real>(-1.0, 1.0, -10.0, 1.0);

    qdlib_nextafter<qd_real>(1.0, 3.0, -10.0, 1.0);
    qdlib_nextafter<qd_real>(-1.0, 3.0, -10.0, 1.0);

    qdlib_nextafter<qd_real>(1.0, 1.0, math::negative_infinity(0.0), 1.0);
    qdlib_nextafter<qd_real>(0.0, 1.0, math::negative_infinity(0.0), 1.0);
    qdlib_nextafter<qd_real>(-1.0, 1.0, math::negative_infinity(0.0), 1.0);
}

#endif

//// test_normalize_angle

void test_normalize_angle(double ang, double min_ang, double max_ang, double ang_period_mod, int inclusion_direction, double eta_angle)
{
    ASSERT_EQ(math::normalize_angle(ang, min_ang, max_ang, ang_period_mod, inclusion_direction), eta_angle);
}

TEST(FunctionsTest, normalize_angle)
{
    //// 0..+360

    // 0..720 -> [0..+360)
    test_normalize_angle(   0,    0, +360, 360, -1,    0);
    test_normalize_angle(  90,    0, +360, 360, -1,   90);
    test_normalize_angle( 179,    0, +360, 360, -1,  179);
    test_normalize_angle( 180,    0, +360, 360, -1,  180);
    test_normalize_angle( 181,    0, +360, 360, -1,  181);
    test_normalize_angle( 270,    0, +360, 360, -1,  270);
    test_normalize_angle( 359,    0, +360, 360, -1,  359);
    test_normalize_angle( 360,    0, +360, 360, -1,    0);
    test_normalize_angle( 361,    0, +360, 360, -1,    1);
    test_normalize_angle( 450,    0, +360, 360, -1,   90);
    test_normalize_angle( 539,    0, +360, 360, -1,  179);
    test_normalize_angle( 540,    0, +360, 360, -1,  180);
    test_normalize_angle( 541,    0, +360, 360, -1,  181);
    test_normalize_angle( 630,    0, +360, 360, -1,  270);
    test_normalize_angle( 719,    0, +360, 360, -1,  359);
    test_normalize_angle( 720,    0, +360, 360, -1,    0);

    // 0..-720 -> [0..+360)
    test_normalize_angle(   0,    0, +360, 360, -1,    0);
    test_normalize_angle(- 90,    0, +360, 360, -1,  270);
    test_normalize_angle(-179,    0, +360, 360, -1,  181);
    test_normalize_angle(-180,    0, +360, 360, -1,  180);
    test_normalize_angle(-181,    0, +360, 360, -1,  179);
    test_normalize_angle(-270,    0, +360, 360, -1,   90);
    test_normalize_angle(-359,    0, +360, 360, -1,    1);
    test_normalize_angle(-360,    0, +360, 360, -1,    0);
    test_normalize_angle(-361,    0, +360, 360, -1,  359);
    test_normalize_angle(-450,    0, +360, 360, -1,  270);
    test_normalize_angle(-539,    0, +360, 360, -1,  181);
    test_normalize_angle(-540,    0, +360, 360, -1,  180);
    test_normalize_angle(-541,    0, +360, 360, -1,  179);
    test_normalize_angle(-630,    0, +360, 360, -1,   90);
    test_normalize_angle(-719,    0, +360, 360, -1,    1);
    test_normalize_angle(-720,    0, +360, 360, -1,    0);

    // 0..720 -> [0..+360]
    test_normalize_angle(   0,    0, +360, 360,  0,    0);
    test_normalize_angle(  90,    0, +360, 360,  0,   90);
    test_normalize_angle( 179,    0, +360, 360,  0,  179);
    test_normalize_angle( 180,    0, +360, 360,  0,  180);
    test_normalize_angle( 181,    0, +360, 360,  0,  181);
    test_normalize_angle( 270,    0, +360, 360,  0,  270);
    test_normalize_angle( 359,    0, +360, 360,  0,  359);
    test_normalize_angle( 360,    0, +360, 360,  0,  360);
    test_normalize_angle( 361,    0, +360, 360,  0,    1);
    test_normalize_angle( 450,    0, +360, 360,  0,   90);
    test_normalize_angle( 539,    0, +360, 360,  0,  179);
    test_normalize_angle( 540,    0, +360, 360,  0,  180);
    test_normalize_angle( 541,    0, +360, 360,  0,  181);
    test_normalize_angle( 630,    0, +360, 360,  0,  270);
    test_normalize_angle( 719,    0, +360, 360,  0,  359);
    test_normalize_angle( 720,    0, +360, 360,  0,    0);

    // 0..-720 -> [0..+360]
    test_normalize_angle(   0,    0, +360, 360,  0,    0);
    test_normalize_angle(- 90,    0, +360, 360,  0,  270);
    test_normalize_angle(-179,    0, +360, 360,  0,  181);
    test_normalize_angle(-180,    0, +360, 360,  0,  180);
    test_normalize_angle(-181,    0, +360, 360,  0,  179);
    test_normalize_angle(-270,    0, +360, 360,  0,   90);
    test_normalize_angle(-359,    0, +360, 360,  0,    1);
    test_normalize_angle(-360,    0, +360, 360,  0,    0);
    test_normalize_angle(-361,    0, +360, 360,  0,  359);
    test_normalize_angle(-450,    0, +360, 360,  0,  270);
    test_normalize_angle(-539,    0, +360, 360,  0,  181);
    test_normalize_angle(-540,    0, +360, 360,  0,  180);
    test_normalize_angle(-541,    0, +360, 360,  0,  179);
    test_normalize_angle(-630,    0, +360, 360,  0,   90);
    test_normalize_angle(-719,    0, +360, 360,  0,    1);
    test_normalize_angle(-720,    0, +360, 360,  0,    0);

    // 0..720 -> (0..+360]
    test_normalize_angle(   0,    0, +360, 360, +1,  360);
    test_normalize_angle(  90,    0, +360, 360, +1,   90);
    test_normalize_angle( 179,    0, +360, 360, +1,  179);
    test_normalize_angle( 180,    0, +360, 360, +1,  180);
    test_normalize_angle( 181,    0, +360, 360, +1,  181);
    test_normalize_angle( 270,    0, +360, 360, +1,  270);
    test_normalize_angle( 359,    0, +360, 360, +1,  359);
    test_normalize_angle( 360,    0, +360, 360, +1,  360);
    test_normalize_angle( 361,    0, +360, 360, +1,    1);
    test_normalize_angle( 450,    0, +360, 360, +1,   90);
    test_normalize_angle( 539,    0, +360, 360, +1,  179);
    test_normalize_angle( 540,    0, +360, 360, +1,  180);
    test_normalize_angle( 541,    0, +360, 360, +1,  181);
    test_normalize_angle( 630,    0, +360, 360, +1,  270);
    test_normalize_angle( 719,    0, +360, 360, +1,  359);
    test_normalize_angle( 720,    0, +360, 360, +1,  360);

    // 0..-720 -> (0..+360]
    test_normalize_angle(   0,    0, +360, 360, +1,  360);
    test_normalize_angle(- 90,    0, +360, 360, +1,  270);
    test_normalize_angle(-179,    0, +360, 360, +1,  181);
    test_normalize_angle(-180,    0, +360, 360, +1,  180);
    test_normalize_angle(-181,    0, +360, 360, +1,  179);
    test_normalize_angle(-270,    0, +360, 360, +1,   90);
    test_normalize_angle(-359,    0, +360, 360, +1,    1);
    test_normalize_angle(-360,    0, +360, 360, +1,  360);
    test_normalize_angle(-361,    0, +360, 360, +1,  359);
    test_normalize_angle(-450,    0, +360, 360, +1,  270);
    test_normalize_angle(-539,    0, +360, 360, +1,  181);
    test_normalize_angle(-540,    0, +360, 360, +1,  180);
    test_normalize_angle(-541,    0, +360, 360, +1,  179);
    test_normalize_angle(-630,    0, +360, 360, +1,   90);
    test_normalize_angle(-719,    0, +360, 360, +1,    1);
    test_normalize_angle(-720,    0, +360, 360, +1,  360);

    //// -90..+90

    // 0..720 -> (-90..+90]
    test_normalize_angle(   0, - 90, + 90, 360, +1,    0);
    test_normalize_angle(  90, - 90, + 90, 360, +1,   90);
    test_normalize_angle( 179, - 90, + 90, 360, +1,  179);
    test_normalize_angle( 180, - 90, + 90, 360, +1,  180);
    test_normalize_angle( 181, - 90, + 90, 360, +1,  181);
    test_normalize_angle( 270, - 90, + 90, 360, +1,  270);
    test_normalize_angle( 359, - 90, + 90, 360, +1, -  1);
    test_normalize_angle( 360, - 90, + 90, 360, +1,    0);
    test_normalize_angle( 361, - 90, + 90, 360, +1,    1);
    test_normalize_angle( 450, - 90, + 90, 360, +1,   90);
    test_normalize_angle( 539, - 90, + 90, 360, +1,  179);
    test_normalize_angle( 540, - 90, + 90, 360, +1,  180);
    test_normalize_angle( 541, - 90, + 90, 360, +1,  181);
    test_normalize_angle( 630, - 90, + 90, 360, +1,  270);
    test_normalize_angle( 719, - 90, + 90, 360, +1, -  1);
    test_normalize_angle( 720, - 90, + 90, 360, +1,    0);

    // 0..-720 -> (-90..+90]
    test_normalize_angle(   0, - 90, + 90, 360, +1,    0);
    test_normalize_angle(- 90, - 90, + 90, 360, +1, - 90);
    test_normalize_angle(-179, - 90, + 90, 360, +1, -179);
    test_normalize_angle(-180, - 90, + 90, 360, +1, -180);
    test_normalize_angle(-181, - 90, + 90, 360, +1, -181);
    test_normalize_angle(-270, - 90, + 90, 360, +1,   90);
    test_normalize_angle(-359, - 90, + 90, 360, +1,    1);
    test_normalize_angle(-360, - 90, + 90, 360, +1,    0);
    test_normalize_angle(-361, - 90, + 90, 360, +1, -  1);
    test_normalize_angle(-450, - 90, + 90, 360, +1, - 90);
    test_normalize_angle(-539, - 90, + 90, 360, +1, -179);
    test_normalize_angle(-540, - 90, + 90, 360, +1, -180);
    test_normalize_angle(-541, - 90, + 90, 360, +1, -181);
    test_normalize_angle(-630, - 90, + 90, 360, +1,   90);
    test_normalize_angle(-719, - 90, + 90, 360, +1,    1);
    test_normalize_angle(-720, - 90, + 90, 360, +1,    0);

    // 0..720 -> [-90..+90]
    test_normalize_angle(   0, - 90, + 90, 360,  0,    0);
    test_normalize_angle(  90, - 90, + 90, 360,  0,   90);
    test_normalize_angle( 179, - 90, + 90, 360,  0,  179);
    test_normalize_angle( 180, - 90, + 90, 360,  0,  180);
    test_normalize_angle( 181, - 90, + 90, 360,  0,  181);
    test_normalize_angle( 270, - 90, + 90, 360,  0, - 90);
    test_normalize_angle( 359, - 90, + 90, 360,  0, -  1);
    test_normalize_angle( 360, - 90, + 90, 360,  0,    0);
    test_normalize_angle( 361, - 90, + 90, 360,  0,    1);
    test_normalize_angle( 450, - 90, + 90, 360,  0,   90);
    test_normalize_angle( 539, - 90, + 90, 360,  0,  179);
    test_normalize_angle( 540, - 90, + 90, 360,  0,  180);
    test_normalize_angle( 541, - 90, + 90, 360,  0,  181);
    test_normalize_angle( 630, - 90, + 90, 360,  0, - 90);
    test_normalize_angle( 719, - 90, + 90, 360,  0, -  1);
    test_normalize_angle( 720, - 90, + 90, 360,  0,    0);

    // 0..-720 -> [-90..+90]
    test_normalize_angle(   0, - 90, + 90, 360,  0,    0);
    test_normalize_angle(- 90, - 90, + 90, 360,  0, - 90);
    test_normalize_angle(-179, - 90, + 90, 360,  0, -179);
    test_normalize_angle(-180, - 90, + 90, 360,  0, -180);
    test_normalize_angle(-181, - 90, + 90, 360,  0, -181);
    test_normalize_angle(-270, - 90, + 90, 360,  0,   90);
    test_normalize_angle(-359, - 90, + 90, 360,  0,    1);
    test_normalize_angle(-360, - 90, + 90, 360,  0,    0);
    test_normalize_angle(-361, - 90, + 90, 360,  0, -  1);
    test_normalize_angle(-450, - 90, + 90, 360,  0, - 90);
    test_normalize_angle(-539, - 90, + 90, 360,  0, -179);
    test_normalize_angle(-540, - 90, + 90, 360,  0, -180);
    test_normalize_angle(-541, - 90, + 90, 360,  0, -181);
    test_normalize_angle(-630, - 90, + 90, 360,  0,   90);
    test_normalize_angle(-719, - 90, + 90, 360,  0,    1);
    test_normalize_angle(-720, - 90, + 90, 360,  0,    0);

    // 0..720 -> [-90..+90)
    test_normalize_angle(   0, - 90, + 90, 360, -1,    0);
    test_normalize_angle(  90, - 90, + 90, 360, -1,   90);
    test_normalize_angle( 179, - 90, + 90, 360, -1,  179);
    test_normalize_angle( 180, - 90, + 90, 360, -1,  180);
    test_normalize_angle( 181, - 90, + 90, 360, -1,  181);
    test_normalize_angle( 270, - 90, + 90, 360, -1, - 90);
    test_normalize_angle( 359, - 90, + 90, 360, -1, -  1);
    test_normalize_angle( 360, - 90, + 90, 360, -1,    0);
    test_normalize_angle( 361, - 90, + 90, 360, -1,    1);
    test_normalize_angle( 450, - 90, + 90, 360, -1,   90);
    test_normalize_angle( 539, - 90, + 90, 360, -1,  179);
    test_normalize_angle( 540, - 90, + 90, 360, -1,  180);
    test_normalize_angle( 541, - 90, + 90, 360, -1,  181);
    test_normalize_angle( 630, - 90, + 90, 360, -1, - 90);
    test_normalize_angle( 719, - 90, + 90, 360, -1, -  1);
    test_normalize_angle( 720, - 90, + 90, 360, -1,    0);

    // 0..-720 -> [-90..+90)
    test_normalize_angle(   0, - 90, + 90, 360, -1,    0);
    test_normalize_angle(- 90, - 90, + 90, 360, -1, - 90);
    test_normalize_angle(-179, - 90, + 90, 360, -1, -179);
    test_normalize_angle(-180, - 90, + 90, 360, -1, -180);
    test_normalize_angle(-181, - 90, + 90, 360, -1, -181);
    test_normalize_angle(-270, - 90, + 90, 360, -1, -270);
    test_normalize_angle(-359, - 90, + 90, 360, -1,    1);
    test_normalize_angle(-360, - 90, + 90, 360, -1,    0);
    test_normalize_angle(-361, - 90, + 90, 360, -1, -  1);
    test_normalize_angle(-450, - 90, + 90, 360, -1, - 90);
    test_normalize_angle(-539, - 90, + 90, 360, -1, -179);
    test_normalize_angle(-540, - 90, + 90, 360, -1, -180);
    test_normalize_angle(-541, - 90, + 90, 360, -1, -181);
    test_normalize_angle(-630, - 90, + 90, 360, -1, -270);
    test_normalize_angle(-719, - 90, + 90, 360, -1,    1);
    test_normalize_angle(-720, - 90, + 90, 360, -1,    0);

    //// -180..+180

    // 0..720 -> (-180..+180]
    test_normalize_angle(   0, -180, +180, 360, +1,    0);
    test_normalize_angle(  90, -180, +180, 360, +1,   90);
    test_normalize_angle( 179, -180, +180, 360, +1,  179);
    test_normalize_angle( 180, -180, +180, 360, +1,  180);
    test_normalize_angle( 181, -180, +180, 360, +1, -179);
    test_normalize_angle( 270, -180, +180, 360, +1, - 90);
    test_normalize_angle( 359, -180, +180, 360, +1, -  1);
    test_normalize_angle( 360, -180, +180, 360, +1,    0);
    test_normalize_angle( 361, -180, +180, 360, +1,    1);
    test_normalize_angle( 450, -180, +180, 360, +1,   90);
    test_normalize_angle( 539, -180, +180, 360, +1,  179);
    test_normalize_angle( 540, -180, +180, 360, +1,  180);
    test_normalize_angle( 541, -180, +180, 360, +1, -179);
    test_normalize_angle( 630, -180, +180, 360, +1, - 90);
    test_normalize_angle( 719, -180, +180, 360, +1, -  1);
    test_normalize_angle( 720, -180, +180, 360, +1,    0);

    // 0..-720 -> (-180..+180]
    test_normalize_angle(   0, -180, +180, 360, +1,    0);
    test_normalize_angle(- 90, -180, +180, 360, +1, - 90);
    test_normalize_angle(-179, -180, +180, 360, +1, -179);
    test_normalize_angle(-180, -180, +180, 360, +1,  180);
    test_normalize_angle(-181, -180, +180, 360, +1,  179);
    test_normalize_angle(-270, -180, +180, 360, +1,   90);
    test_normalize_angle(-359, -180, +180, 360, +1,    1);
    test_normalize_angle(-360, -180, +180, 360, +1,    0);
    test_normalize_angle(-361, -180, +180, 360, +1, -  1);
    test_normalize_angle(-450, -180, +180, 360, +1, - 90);
    test_normalize_angle(-539, -180, +180, 360, +1, -179);
    test_normalize_angle(-540, -180, +180, 360, +1,  180);
    test_normalize_angle(-541, -180, +180, 360, +1,  179);
    test_normalize_angle(-630, -180, +180, 360, +1,   90);
    test_normalize_angle(-719, -180, +180, 360, +1,    1);
    test_normalize_angle(-720, -180, +180, 360, +1,    0);

    // 0..720 -> [-180..+180]
    test_normalize_angle(   0, -180, +180, 360,  0,    0);
    test_normalize_angle(  90, -180, +180, 360,  0,   90);
    test_normalize_angle( 179, -180, +180, 360,  0,  179);
    test_normalize_angle( 180, -180, +180, 360,  0,  180);
    test_normalize_angle( 181, -180, +180, 360,  0, -179);
    test_normalize_angle( 270, -180, +180, 360,  0, - 90);
    test_normalize_angle( 359, -180, +180, 360,  0, -  1);
    test_normalize_angle( 360, -180, +180, 360,  0,    0);
    test_normalize_angle( 361, -180, +180, 360,  0,    1);
    test_normalize_angle( 450, -180, +180, 360,  0,   90);
    test_normalize_angle( 539, -180, +180, 360,  0,  179);
    test_normalize_angle( 540, -180, +180, 360,  0,  180);
    test_normalize_angle( 541, -180, +180, 360,  0, -179);
    test_normalize_angle( 630, -180, +180, 360,  0, - 90);
    test_normalize_angle( 719, -180, +180, 360,  0, -  1);
    test_normalize_angle( 720, -180, +180, 360,  0,    0);

    // 0..-720 -> [-180..+180]
    test_normalize_angle(   0, -180, +180, 360,  0,    0);
    test_normalize_angle(- 90, -180, +180, 360,  0, - 90);
    test_normalize_angle(-179, -180, +180, 360,  0, -179);
    test_normalize_angle(-180, -180, +180, 360,  0, -180);
    test_normalize_angle(-181, -180, +180, 360,  0,  179);
    test_normalize_angle(-270, -180, +180, 360,  0,   90);
    test_normalize_angle(-359, -180, +180, 360,  0,    1);
    test_normalize_angle(-360, -180, +180, 360,  0,    0);
    test_normalize_angle(-361, -180, +180, 360,  0, -  1);
    test_normalize_angle(-450, -180, +180, 360,  0, - 90);
    test_normalize_angle(-539, -180, +180, 360,  0, -179);
    test_normalize_angle(-540, -180, +180, 360,  0, -180);
    test_normalize_angle(-541, -180, +180, 360,  0,  179);
    test_normalize_angle(-630, -180, +180, 360,  0,   90);
    test_normalize_angle(-719, -180, +180, 360,  0,    1);
    test_normalize_angle(-720, -180, +180, 360,  0,    0);

    // 0..720 -> [-180..+180)
    test_normalize_angle(   0, -180, +180, 360, -1,    0);
    test_normalize_angle(  90, -180, +180, 360, -1,   90);
    test_normalize_angle( 179, -180, +180, 360, -1,  179);
    test_normalize_angle( 180, -180, +180, 360, -1, -180);
    test_normalize_angle( 181, -180, +180, 360, -1, -179);
    test_normalize_angle( 270, -180, +180, 360, -1, - 90);
    test_normalize_angle( 359, -180, +180, 360, -1, -  1);
    test_normalize_angle( 360, -180, +180, 360, -1,    0);
    test_normalize_angle( 361, -180, +180, 360, -1,    1);
    test_normalize_angle( 450, -180, +180, 360, -1,   90);
    test_normalize_angle( 539, -180, +180, 360, -1,  179);
    test_normalize_angle( 540, -180, +180, 360, -1, -180);
    test_normalize_angle( 541, -180, +180, 360, -1, -179);
    test_normalize_angle( 630, -180, +180, 360, -1, - 90);
    test_normalize_angle( 719, -180, +180, 360, -1, -  1);
    test_normalize_angle( 720, -180, +180, 360, -1,    0);

    // 0..-720 -> [-180..+180)
    test_normalize_angle(   0, -180, +180, 360, -1,    0);
    test_normalize_angle(- 90, -180, +180, 360, -1, - 90);
    test_normalize_angle(-179, -180, +180, 360, -1, -179);
    test_normalize_angle(-180, -180, +180, 360, -1, -180);
    test_normalize_angle(-181, -180, +180, 360, -1,  179);
    test_normalize_angle(-270, -180, +180, 360, -1,   90);
    test_normalize_angle(-359, -180, +180, 360, -1,    1);
    test_normalize_angle(-360, -180, +180, 360, -1,    0);
    test_normalize_angle(-361, -180, +180, 360, -1, -  1);
    test_normalize_angle(-450, -180, +180, 360, -1, - 90);
    test_normalize_angle(-539, -180, +180, 360, -1, -179);
    test_normalize_angle(-540, -180, +180, 360, -1, -180);
    test_normalize_angle(-541, -180, +180, 360, -1,  179);
    test_normalize_angle(-630, -180, +180, 360, -1,   90);
    test_normalize_angle(-719, -180, +180, 360, -1,    1);
    test_normalize_angle(-720, -180, +180, 360, -1,    0);

    //// -270..+270

    // 0..720 -> (-270..+270]
    test_normalize_angle(   0, -270, +270, 360, +1,    0);
    test_normalize_angle(  90, -270, +270, 360, +1,   90);
    test_normalize_angle( 179, -270, +270, 360, +1,  179);
    test_normalize_angle( 180, -270, +270, 360, +1,  180);
    test_normalize_angle( 181, -270, +270, 360, +1,  181);
    test_normalize_angle( 269, -270, +270, 360, +1,  269);
    test_normalize_angle( 270, -270, +270, 360, +1,  270);
    test_normalize_angle( 271, -270, +270, 360, +1, - 89);
    test_normalize_angle( 359, -270, +270, 360, +1, -  1);
    test_normalize_angle( 360, -270, +270, 360, +1,    0);
    test_normalize_angle( 361, -270, +270, 360, +1,    1);
    test_normalize_angle( 450, -270, +270, 360, +1,   90);
    test_normalize_angle( 539, -270, +270, 360, +1,  179);
    test_normalize_angle( 540, -270, +270, 360, +1,  180);
    test_normalize_angle( 541, -270, +270, 360, +1,  181);
    test_normalize_angle( 629, -270, +270, 360, +1,  269);
    test_normalize_angle( 630, -270, +270, 360, +1,  270);
    test_normalize_angle( 631, -270, +270, 360, +1, - 89);
    test_normalize_angle( 719, -270, +270, 360, +1, -  1);
    test_normalize_angle( 720, -270, +270, 360, +1,    0);

    // 0..-720 -> (-270..+270]
    test_normalize_angle(   0, -270, +270, 360, +1,    0);
    test_normalize_angle(- 90, -270, +270, 360, +1, - 90);
    test_normalize_angle(-179, -270, +270, 360, +1, -179);
    test_normalize_angle(-180, -270, +270, 360, +1, -180);
    test_normalize_angle(-181, -270, +270, 360, +1, -181);
    test_normalize_angle(-269, -270, +270, 360, +1, -269);
    test_normalize_angle(-270, -270, +270, 360, +1,   90);
    test_normalize_angle(-271, -270, +270, 360, +1,   89);
    test_normalize_angle(-359, -270, +270, 360, +1,    1);
    test_normalize_angle(-360, -270, +270, 360, +1,    0);
    test_normalize_angle(-361, -270, +270, 360, +1, -  1);
    test_normalize_angle(-450, -270, +270, 360, +1, - 90);
    test_normalize_angle(-539, -270, +270, 360, +1, -179);
    test_normalize_angle(-540, -270, +270, 360, +1, -180);
    test_normalize_angle(-541, -270, +270, 360, +1, -181);
    test_normalize_angle(-629, -270, +270, 360, +1, -269);
    test_normalize_angle(-630, -270, +270, 360, +1,   90);
    test_normalize_angle(-631, -270, +270, 360, +1,   89);
    test_normalize_angle(-719, -270, +270, 360, +1,    1);
    test_normalize_angle(-720, -270, +270, 360, +1,    0);

    // 0..720 -> [-270..+270]
    test_normalize_angle(   0, -270, +270, 360,  0,    0);
    test_normalize_angle(  90, -270, +270, 360,  0,   90);
    test_normalize_angle( 179, -270, +270, 360,  0,  179);
    test_normalize_angle( 180, -270, +270, 360,  0,  180);
    test_normalize_angle( 181, -270, +270, 360,  0,  181);
    test_normalize_angle( 269, -270, +270, 360,  0,  269);
    test_normalize_angle( 270, -270, +270, 360,  0,  270);
    test_normalize_angle( 271, -270, +270, 360,  0, - 89);
    test_normalize_angle( 359, -270, +270, 360,  0, -  1);
    test_normalize_angle( 360, -270, +270, 360,  0,    0);
    test_normalize_angle( 361, -270, +270, 360,  0,    1);
    test_normalize_angle( 450, -270, +270, 360,  0,   90);
    test_normalize_angle( 539, -270, +270, 360,  0,  179);
    test_normalize_angle( 540, -270, +270, 360,  0,  180);
    test_normalize_angle( 541, -270, +270, 360,  0,  181);
    test_normalize_angle( 629, -270, +270, 360,  0,  269);
    test_normalize_angle( 630, -270, +270, 360,  0,  270);
    test_normalize_angle( 631, -270, +270, 360,  0, - 89);
    test_normalize_angle( 719, -270, +270, 360,  0, -  1);
    test_normalize_angle( 720, -270, +270, 360,  0,    0);

    // 0..-720 -> [-270..+270]
    test_normalize_angle(   0, -270, +270, 360,  0,    0);
    test_normalize_angle(- 90, -270, +270, 360,  0, - 90);
    test_normalize_angle(-179, -270, +270, 360,  0, -179);
    test_normalize_angle(-180, -270, +270, 360,  0, -180);
    test_normalize_angle(-181, -270, +270, 360,  0, -181);
    test_normalize_angle(-269, -270, +270, 360,  0, -269);
    test_normalize_angle(-270, -270, +270, 360,  0, -270);
    test_normalize_angle(-271, -270, +270, 360,  0,   89);
    test_normalize_angle(-359, -270, +270, 360,  0,    1);
    test_normalize_angle(-360, -270, +270, 360,  0,    0);
    test_normalize_angle(-361, -270, +270, 360,  0, -  1);
    test_normalize_angle(-450, -270, +270, 360,  0, - 90);
    test_normalize_angle(-539, -270, +270, 360,  0, -179);
    test_normalize_angle(-540, -270, +270, 360,  0, -180);
    test_normalize_angle(-541, -270, +270, 360,  0, -181);
    test_normalize_angle(-629, -270, +270, 360,  0, -269);
    test_normalize_angle(-630, -270, +270, 360,  0, -270);
    test_normalize_angle(-631, -270, +270, 360,  0,   89);
    test_normalize_angle(-719, -270, +270, 360,  0,    1);
    test_normalize_angle(-720, -270, +270, 360,  0,    0);

    // 0..720 -> [-270..+270)
    test_normalize_angle(   0, -270, +270, 360, -1,    0);
    test_normalize_angle(  90, -270, +270, 360, -1,   90);
    test_normalize_angle( 179, -270, +270, 360, -1,  179);
    test_normalize_angle( 180, -270, +270, 360, -1,  180);
    test_normalize_angle( 181, -270, +270, 360, -1,  181);
    test_normalize_angle( 269, -270, +270, 360, -1,  269);
    test_normalize_angle( 270, -270, +270, 360, -1, - 90);
    test_normalize_angle( 271, -270, +270, 360, -1, - 89);
    test_normalize_angle( 359, -270, +270, 360, -1, -  1);
    test_normalize_angle( 360, -270, +270, 360, -1,    0);
    test_normalize_angle( 361, -270, +270, 360, -1,    1);
    test_normalize_angle( 450, -270, +270, 360, -1,   90);
    test_normalize_angle( 539, -270, +270, 360, -1,  179);
    test_normalize_angle( 540, -270, +270, 360, -1,  180);
    test_normalize_angle( 541, -270, +270, 360, -1,  181);
    test_normalize_angle( 629, -270, +270, 360, -1,  269);
    test_normalize_angle( 630, -270, +270, 360, -1, - 90);
    test_normalize_angle( 631, -270, +270, 360, -1, - 89);
    test_normalize_angle( 719, -270, +270, 360, -1, -  1);
    test_normalize_angle( 720, -270, +270, 360, -1,    0);

    // 0..-720 -> [-270..+270)
    test_normalize_angle(   0, -270, +270, 360, -1,    0);
    test_normalize_angle(- 90, -270, +270, 360, -1, - 90);
    test_normalize_angle(-179, -270, +270, 360, -1, -179);
    test_normalize_angle(-180, -270, +270, 360, -1, -180);
    test_normalize_angle(-181, -270, +270, 360, -1, -181);
    test_normalize_angle(-269, -270, +270, 360, -1, -269);
    test_normalize_angle(-270, -270, +270, 360, -1, -270);
    test_normalize_angle(-271, -270, +270, 360, -1,   89);
    test_normalize_angle(-359, -270, +270, 360, -1,    1);
    test_normalize_angle(-360, -270, +270, 360, -1,    0);
    test_normalize_angle(-361, -270, +270, 360, -1, -  1);
    test_normalize_angle(-450, -270, +270, 360, -1, - 90);
    test_normalize_angle(-539, -270, +270, 360, -1, -179);
    test_normalize_angle(-540, -270, +270, 360, -1, -180);
    test_normalize_angle(-541, -270, +270, 360, -1, -181);
    test_normalize_angle(-629, -270, +270, 360, -1, -269);
    test_normalize_angle(-630, -270, +270, 360, -1, -270);
    test_normalize_angle(-631, -270, +270, 360, -1,   89);
    test_normalize_angle(-719, -270, +270, 360, -1,    1);
    test_normalize_angle(-720, -270, +270, 360, -1,    0);
}

//// math::angle_closest_distance

void test_angle_closest_distance(double start_angle_deg, double end_angle_deg, bool on_equal_distances_select_closest_to_zero, double eta_angle_distance, TestStats_angle_closest_distance & stats)
{
    const double angle_distance = math::angle_closest_distance(start_angle_deg, end_angle_deg, false, on_equal_distances_select_closest_to_zero);

    const double angle_distance_fluctuation = std::fabs(angle_distance - eta_angle_distance);

    stats.peak_angle_distance_fluctuation = (std::max)(stats.peak_angle_distance_fluctuation, angle_distance_fluctuation);

    ASSERT_GE(common::angle_closest_distance_epsilon, angle_distance_fluctuation);

    if (angle_distance >= 0) {
        ASSERT_GE(start_angle_deg + angle_distance, start_angle_deg);
        ASSERT_EQ(
            math::normalize_angle<double>(end_angle_deg, 0, 360, 360, -1),
            math::normalize_angle<double>(start_angle_deg + angle_distance, 0, 360, 360, -1));
    }
    else {
        ASSERT_LE(start_angle_deg + angle_distance, start_angle_deg);
        ASSERT_EQ(
            math::normalize_angle<double>(end_angle_deg, 0, 360, 360, -1),
            math::normalize_angle<double>(start_angle_deg + angle_distance, 0, 360, 360, -1));
    }

    const double angle_distance_normalized = std::fabs(
        math::normalize_angle<double>(end_angle_deg, 0, 360, 360, -1) -
        math::normalize_angle<double>(start_angle_deg + angle_distance, 0, 360, 360, -1));

    ASSERT_GE(common::angle_closest_distance_epsilon, angle_distance_normalized);
}

TEST(FunctionsTest, angle_closest_distance)
{
    TestStats_angle_closest_distance stats;

    //// any angle tests

    // special cases
    test_angle_closest_distance( 0.0,  0.0,  true,    0, stats);
    test_angle_closest_distance( 0.0, -0.0,  true,    0, stats);
    test_angle_closest_distance(-0.0,  0.0,  true,    0, stats);
    test_angle_closest_distance(-0.0, -0.0,  true,    0, stats);

    // start: [0..90], positive end, positive distance
    test_angle_closest_distance(   5,   10,  true,    5, stats);
    test_angle_closest_distance(   0,   90,  true,   90, stats);
    test_angle_closest_distance(   5,  175,  true,  170, stats);

    test_angle_closest_distance(   0,  360,  true,    0, stats);
    test_angle_closest_distance(   5,  370,  true,    5, stats);
    test_angle_closest_distance(   0,  450,  true,   90, stats);
    test_angle_closest_distance(   5,  535,  true,  170, stats);
    test_angle_closest_distance(   0,  540,  true,  180, stats);

    // start: [0..90], positive end, negative distance
    test_angle_closest_distance(   5,  185,  true, -180, stats);
    test_angle_closest_distance(   5,  355,  true, - 10, stats);
    test_angle_closest_distance(   0,  270,  true, - 90, stats);
    test_angle_closest_distance(   5,  186,  true, -179, stats);
    test_angle_closest_distance(   5,  545,  true, -180, stats);

    // start: [90..180], positive end, positive distance
    test_angle_closest_distance(  90,   90,  true,    0, stats);
    test_angle_closest_distance(  95,  100,  true,    5, stats);
    test_angle_closest_distance(  90,  180,  true,   90, stats);
    test_angle_closest_distance(  95,  265,  true,  170, stats);

    test_angle_closest_distance(  90,  450,  true,    0, stats);
    test_angle_closest_distance(  95,  460,  true,    5, stats);
    test_angle_closest_distance(  90,  540,  true,   90, stats);
    test_angle_closest_distance(  95,  625,  true,  170, stats);

    // start: [90..180], positive end, negative distance
    test_angle_closest_distance(  95,   85,  true, - 10, stats);
    test_angle_closest_distance(  90,  360,  true, - 90, stats);
    test_angle_closest_distance(  95,  276,  true, -179, stats);
    test_angle_closest_distance(  95,  275,  true, -180, stats);
    test_angle_closest_distance(  90,  630,  true, -180, stats);
    test_angle_closest_distance(  95,  635,  true, -180, stats);

    // start: [180..270], positive end, positive distance
    test_angle_closest_distance( 180,  180,  true,    0, stats);
    test_angle_closest_distance( 185,  190,  true,    5, stats);
    test_angle_closest_distance( 180,  270,  true,   90, stats);
    test_angle_closest_distance( 185,  355,  true,  170, stats);

    test_angle_closest_distance( 180,  540,  true,    0, stats);
    test_angle_closest_distance( 185,  550,  true,    5, stats);
    test_angle_closest_distance( 180,  630,  true,   90, stats);
    test_angle_closest_distance( 185,  715,  true,  170, stats);

    // start: [180..270], positive end, negative distance
    test_angle_closest_distance( 185,  175,  true, - 10, stats);
    test_angle_closest_distance( 180,   90,  true, - 90, stats);
    test_angle_closest_distance( 185,    6,  true, -179, stats);
    test_angle_closest_distance( 185,    5,  true, -180, stats);
    test_angle_closest_distance( 185,  365,  true, -180, stats);
    test_angle_closest_distance( 180,  720,  true, -180, stats);
    test_angle_closest_distance( 185,  725,  true, -180, stats);

    // start: [270..360], positive end, positive distance
    test_angle_closest_distance( 270,  270,  true,    0, stats);
    test_angle_closest_distance( 275,  280,  true,    5, stats);
    test_angle_closest_distance( 270,    0,  true,   90, stats);
    test_angle_closest_distance( 270,  360,  true,   90, stats);
    test_angle_closest_distance( 275,  445,  true,  170, stats);

    test_angle_closest_distance( 270,  630,  true,    0, stats);
    test_angle_closest_distance( 275,  640,  true,    5, stats);
    test_angle_closest_distance( 270,  720,  true,   90, stats);
    test_angle_closest_distance( 275,   85,  true,  170, stats);

    // start: [270..360], positive end, negative distance
    test_angle_closest_distance( 275,  265,  true, - 10, stats);
    test_angle_closest_distance( 270,  180,  true, - 90, stats);
    test_angle_closest_distance( 275,   96,  true, -179, stats);
    test_angle_closest_distance( 275,   95,  true, -180, stats);
    test_angle_closest_distance( 270,  450,  true, -180, stats);
    test_angle_closest_distance( 275,  455,  true, -180, stats);

    ////

    // start: [0..90], negative end, positive distance
    test_angle_closest_distance(   0, -360,  true,    0, stats);
    test_angle_closest_distance(   5, -350,  true,    5, stats);
    test_angle_closest_distance(   0, -270,  true,   90, stats);
    test_angle_closest_distance(   5, -185,  true,  170, stats);

    test_angle_closest_distance(   0, -720,  true,    0, stats);
    test_angle_closest_distance(   5, -710,  true,    5, stats);
    test_angle_closest_distance(   0, -270,  true,   90, stats);
    test_angle_closest_distance(   5, -185,  true,  170, stats);

    // start: [0..90], negative end, negative distance
    test_angle_closest_distance(   5, -  5,  true, - 10, stats);
    test_angle_closest_distance(   0, - 90,  true, - 90, stats);
    test_angle_closest_distance(   5, -174,  true, -179, stats);
    test_angle_closest_distance(   5, -175,  true, -180, stats);

    // start: [90..180], negative end, positive distance
    test_angle_closest_distance(  90, -270,  true,    0, stats);
    test_angle_closest_distance(  95, -260,  true,    5, stats);
    test_angle_closest_distance(  90, -180,  true,   90, stats);
    test_angle_closest_distance(  95, - 95,  true,  170, stats);
    test_angle_closest_distance(  95, - 86,  true,  179, stats);

    // start: [90..180], negative end, negative distance
    test_angle_closest_distance(  90, -360,  true, - 90, stats);
    test_angle_closest_distance(  95, -275,  true, - 10, stats);
    test_angle_closest_distance(  90, - 90,  true, -180, stats);
    test_angle_closest_distance(  95, - 85,  true, -180, stats);
    test_angle_closest_distance(  95, - 84,  true, -179, stats);
    test_angle_closest_distance(  90,    0,  true, - 90, stats);

    // start: [180..270], negative end, positive distance
    test_angle_closest_distance( 180, -180,  true,    0, stats);
    test_angle_closest_distance( 185, -170,  true,    5, stats);
    test_angle_closest_distance( 180, - 90,  true,   90, stats);
    test_angle_closest_distance( 185, -  5,  true,  170, stats);

    // start: [180..270], negative end, negative distance
    test_angle_closest_distance( 180, -360,  true, -180, stats);
    test_angle_closest_distance( 185, -185,  true, - 10, stats);
    test_angle_closest_distance( 180, -270,  true, - 90, stats);
    test_angle_closest_distance( 185, -354,  true, -179, stats);
    test_angle_closest_distance( 185, -355,  true, -180, stats);

    // start: [270..360], negative end, positive distance
    test_angle_closest_distance( 275, - 80,  true,    5, stats);
    test_angle_closest_distance( 270, -360,  true,   90, stats);
    test_angle_closest_distance( 275, -275,  true,  170, stats);

    test_angle_closest_distance( 270, - 90,  true,    0, stats);

    // start: [270..360], negative end, negative distance
    test_angle_closest_distance( 270, -270,  true, -180, stats);
    test_angle_closest_distance( 275, -265,  true, -180, stats);
    test_angle_closest_distance( 275, - 95,  true, - 10, stats);
    test_angle_closest_distance( 270, -180,  true, - 90, stats);
    test_angle_closest_distance( 275, -264,  true, -179, stats);
    test_angle_closest_distance( 275, -265,  true, -180, stats);

    ////

    // start: (0..-90], positive end, positive distance
    test_angle_closest_distance(-  5,    0,  true,    5, stats);
    test_angle_closest_distance(-  5,  165,  true,  170, stats);
    test_angle_closest_distance(-  5,  175,  true,  180, stats);

    test_angle_closest_distance(-  5,  360,  true,    5, stats);
    test_angle_closest_distance(-  5,  525,  true,  170, stats);
    test_angle_closest_distance(-  5,  535,  true,  180, stats);

    // start: (0..-90], positive end, negative distance
    test_angle_closest_distance(-  5,  345,  true, - 10, stats);
    test_angle_closest_distance(-  5,  176,  true, -179, stats);

    // start: [-90..-180], positive end, positive distance
    test_angle_closest_distance(- 90,    0,  true,   90, stats);
    test_angle_closest_distance(- 95,    5,  true,  100, stats);
    test_angle_closest_distance(- 90,   90,  true,  180, stats);
    test_angle_closest_distance(- 95,   85,  true,  180, stats);
    test_angle_closest_distance(- 90,  270,  true,    0, stats);
    test_angle_closest_distance(- 95,  275,  true,   10, stats);

    test_angle_closest_distance(- 90,  360,  true,   90, stats);
    test_angle_closest_distance(- 95,  365,  true,  100, stats);
    test_angle_closest_distance(- 95,  435,  true,  170, stats);
    test_angle_closest_distance(- 90,  450,  true,  180, stats);

    // start: [-90..-180], positive end, negative distance
    test_angle_closest_distance(- 90,   91,  true, -179, stats);
    test_angle_closest_distance(- 95,   86,  true, -179, stats);

    // start: [-180..-270], positive end, positive distance
    test_angle_closest_distance(-180,    0,  true,  180, stats);
    test_angle_closest_distance(-180,  180,  true,    0, stats);
    test_angle_closest_distance(-185,  180,  true,    5, stats);
    test_angle_closest_distance(-180,  270,  true,   90, stats);
    test_angle_closest_distance(-185,  345,  true,  170, stats);
    test_angle_closest_distance(-180,  360,  true,  180, stats);
    test_angle_closest_distance(-185,  355,  true,  180, stats);

    // start: [-180..-270], positive end, negative distance
    test_angle_closest_distance(-185,  165,  true, - 10, stats);
    test_angle_closest_distance(-180,   90,  true, - 90, stats);
    test_angle_closest_distance(-185,    0,  true, -175, stats);

    // start: [-270..-360], positive end, positive distance
    test_angle_closest_distance(-270,  270,  true,  180, stats);
    test_angle_closest_distance(-270,  260,  true,  170, stats);
    test_angle_closest_distance(-275,   85,  true,    0, stats);
    test_angle_closest_distance(-270,   90,  true,    0, stats);
    test_angle_closest_distance(-270,  180,  true,   90, stats);

    // start: [-270..-360], positive end, negative distance
    test_angle_closest_distance(-270,    0,  true, - 90, stats);
    test_angle_closest_distance(-275,    5,  true, - 80, stats);
    test_angle_closest_distance(-270,  365,  true, - 85, stats);
    test_angle_closest_distance(-270,  360,  true, - 90, stats);
    test_angle_closest_distance(-275,  355,  true, - 90, stats);

    ////

    // start: (0..-90], negative end, positive distance
    test_angle_closest_distance(-  5, -365,  true,    0, stats);
    test_angle_closest_distance(-  5, -360,  true,    5, stats);
    test_angle_closest_distance(-  5, -185,  true,  180, stats);

    // start: (0..-90], negative end, negative distance
    test_angle_closest_distance(-  5, - 10,  true, -  5, stats);
    test_angle_closest_distance(-  5, -184,  true, -179, stats);
    test_angle_closest_distance(-  5, -370,  true, -  5, stats);

    // start: [-90..-180], negative end, positive distance
    test_angle_closest_distance(- 90, -  5,  true,   85, stats);
    test_angle_closest_distance(- 90, - 90,  true,    0, stats);
    test_angle_closest_distance(- 95, -275,  true,  180, stats);
    test_angle_closest_distance(- 90, -360,  true,   90, stats);

    // start: [-90..-180], negative end, negative distance
    test_angle_closest_distance(- 90, -180,  true, - 90, stats);

    test_angle_closest_distance(- 90, -540,  true, - 90, stats);

    // start: [-180..-270], negative end, positive distance
    test_angle_closest_distance(-180, -180,  true,    0, stats);
    test_angle_closest_distance(-180, - 90,  true,   90, stats);
    test_angle_closest_distance(-185, -  5,  true,  180, stats);

    // start: [-180..-270], negative end, negative distance
    test_angle_closest_distance(-180, -270,  true, - 90, stats);
    test_angle_closest_distance(-185, -275,  true, - 90, stats);
    test_angle_closest_distance(-180, -355,  true, -175, stats);
    test_angle_closest_distance(-185, -355,  true, -170, stats);
    test_angle_closest_distance(-185, -715,  true, -170, stats);

    // start: [-270..-360], negative end, positive distance
    test_angle_closest_distance(-270, -270,  true,    0, stats);
    test_angle_closest_distance(-270, -180,  true,   90, stats);
    test_angle_closest_distance(-275, - 95,  true,  180, stats);

    // start: [-270..-360], negative end, negative distance
    test_angle_closest_distance(-270, - 85,  true, -175, stats);
    test_angle_closest_distance(-270, -360,  true, - 90, stats);
    test_angle_closest_distance(-275, -365,  true, - 90, stats);

    //// 179, 180, 181 ONLY angle tests

    // [0..179], [0..180], [0..181], 45 degrees shift to positive

    test_angle_closest_distance(   0,  179,  true,  179, stats);  test_angle_closest_distance(   0,  179, false,  179, stats);
    test_angle_closest_distance(   0,  180,  true,  180, stats);  test_angle_closest_distance(   0,  180, false,  180, stats);
    test_angle_closest_distance(   0,  181,  true, -179, stats);  test_angle_closest_distance(   0,  181, false, -179, stats);

    test_angle_closest_distance(  45,  224,  true,  179, stats);  test_angle_closest_distance(  45,  224, false,  179, stats);
    test_angle_closest_distance(  45,  225,  true, -180, stats);  test_angle_closest_distance(  45,  225, false,  180, stats);
    test_angle_closest_distance(  45,  226,  true, -179, stats);  test_angle_closest_distance(  45,  226, false, -179, stats);

    test_angle_closest_distance(  90,  269,  true,  179, stats);  test_angle_closest_distance(  90,  269, false,  179, stats);
    test_angle_closest_distance(  90,  270,  true, -180, stats);  test_angle_closest_distance(  90,  270, false,  180, stats);
    test_angle_closest_distance(  90,  271,  true, -179, stats);  test_angle_closest_distance(  90,  271, false, -179, stats);

    test_angle_closest_distance( 135,  314,  true,  179, stats);  test_angle_closest_distance( 135,  314, false,  179, stats);
    test_angle_closest_distance( 135,  315,  true, -180, stats);  test_angle_closest_distance( 135,  315, false,  180, stats);
    test_angle_closest_distance( 135,  316,  true, -179, stats);  test_angle_closest_distance( 135,  316, false, -179, stats);

    test_angle_closest_distance( 180,  359,  true,  179, stats);  test_angle_closest_distance( 180,  359, false,  179, stats);
    test_angle_closest_distance( 180,  360,  true, -180, stats);  test_angle_closest_distance( 180,  360, false,  180, stats);
    test_angle_closest_distance( 180,  361,  true, -179, stats);  test_angle_closest_distance( 180,  361, false, -179, stats);

    test_angle_closest_distance( 225,  404,  true,  179, stats);  test_angle_closest_distance( 225,  404, false,  179, stats);
    test_angle_closest_distance( 225,  405,  true, -180, stats);  test_angle_closest_distance( 225,  405, false,  180, stats);
    test_angle_closest_distance( 225,  406,  true, -179, stats);  test_angle_closest_distance( 225,  406, false, -179, stats);

    test_angle_closest_distance( 270,  449,  true,  179, stats);  test_angle_closest_distance( 270,  449, false,  179, stats);
    test_angle_closest_distance( 270,  450,  true, -180, stats);  test_angle_closest_distance( 270,  450, false,  180, stats);
    test_angle_closest_distance( 270,  451,  true, -179, stats);  test_angle_closest_distance( 270,  451, false, -179, stats);

    test_angle_closest_distance( 315,  494,  true,  179, stats);  test_angle_closest_distance( 315,  494, false,  179, stats);
    test_angle_closest_distance( 315,  495,  true, -180, stats);  test_angle_closest_distance( 315,  495, false,  180, stats);
    test_angle_closest_distance( 315,  496,  true, -179, stats);  test_angle_closest_distance( 315,  496, false, -179, stats);

    test_angle_closest_distance( 360,  539,  true,  179, stats);  test_angle_closest_distance( 360,  539, false,  179, stats);
    test_angle_closest_distance( 360,  540,  true, -180, stats);  test_angle_closest_distance( 360,  540, false,  180, stats);
    test_angle_closest_distance( 360,  541,  true, -179, stats);  test_angle_closest_distance( 360,  541, false, -179, stats);

    // [0..179], [0..180], [0..181], 45 degrees shift to negative

    test_angle_closest_distance(- 45,  134,  true,  179, stats);  test_angle_closest_distance(- 45,  134, false,  179, stats);
    test_angle_closest_distance(- 45,  135,  true,  180, stats);  test_angle_closest_distance(- 45,  135, false,  180, stats);
    test_angle_closest_distance(- 45,  136,  true, -179, stats);  test_angle_closest_distance(- 45,  136, false, -179, stats);

    test_angle_closest_distance(- 90,   89,  true,  179, stats);  test_angle_closest_distance(- 90,   89, false,  179, stats);
    test_angle_closest_distance(- 90,   90,  true,  180, stats);  test_angle_closest_distance(- 90,   90, false,  180, stats);
    test_angle_closest_distance(- 90,   91,  true, -179, stats);  test_angle_closest_distance(- 90,   91, false, -179, stats);

    test_angle_closest_distance(-135,   44,  true,  179, stats);  test_angle_closest_distance(-135,   44, false,  179, stats);
    test_angle_closest_distance(-135,   45,  true,  180, stats);  test_angle_closest_distance(-135,   45, false,  180, stats);
    test_angle_closest_distance(-135,   46,  true, -179, stats);  test_angle_closest_distance(-135,   46, false, -179, stats);

    test_angle_closest_distance(-180,   -1,  true,  179, stats);  test_angle_closest_distance(-180,   -1, false,  179, stats);
    test_angle_closest_distance(-180,    0,  true,  180, stats);  test_angle_closest_distance(-180,    0, false,  180, stats);
    test_angle_closest_distance(-180,    1,  true, -179, stats);  test_angle_closest_distance(-180,    1, false, -179, stats);

    test_angle_closest_distance(-225,  -46,  true,  179, stats);  test_angle_closest_distance(-225,  -46, false,  179, stats);
    test_angle_closest_distance(-225,  -45,  true,  180, stats);  test_angle_closest_distance(-225,  -45, false,  180, stats);
    test_angle_closest_distance(-225,  -44,  true, -179, stats);  test_angle_closest_distance(-225,  -44, false, -179, stats);

    test_angle_closest_distance(-270,  -91,  true,  179, stats);  test_angle_closest_distance(-270,  -91, false,  179, stats);
    test_angle_closest_distance(-270,  -90,  true,  180, stats);  test_angle_closest_distance(-270,  -90, false,  180, stats);
    test_angle_closest_distance(-270,  -89,  true, -179, stats);  test_angle_closest_distance(-270,  -89, false, -179, stats);

    test_angle_closest_distance(-315, -136,  true,  179, stats);  test_angle_closest_distance(-315, -136, false,  179, stats);
    test_angle_closest_distance(-315, -135,  true,  180, stats);  test_angle_closest_distance(-315, -135, false,  180, stats);
    test_angle_closest_distance(-315, -134,  true, -179, stats);  test_angle_closest_distance(-315, -134, false, -179, stats);

    test_angle_closest_distance(-360, -181,  true,  179, stats);  test_angle_closest_distance(-360, -181, false,  179, stats);
    test_angle_closest_distance(-360, -180,  true,  180, stats);  test_angle_closest_distance(-360, -180, false,  180, stats);
    test_angle_closest_distance(-360, -179,  true, -179, stats);  test_angle_closest_distance(-360, -179, false, -179, stats);

    // [0..-179], [0..-180], [0..-181], 45 degrees shift to negative

    test_angle_closest_distance(   0, -179,  true, -179, stats);  test_angle_closest_distance(   0, -179, false, -179, stats);
    test_angle_closest_distance(   0, -180,  true,  180, stats);  test_angle_closest_distance(   0, -180, false, -180, stats);
    test_angle_closest_distance(   0, -181,  true,  179, stats);  test_angle_closest_distance(   0, -181, false,  179, stats);

    test_angle_closest_distance(- 45, -224,  true, -179, stats);  test_angle_closest_distance(- 45, -224, false, -179, stats);
    test_angle_closest_distance(- 45, -225,  true,  180, stats);  test_angle_closest_distance(- 45, -225, false, -180, stats);
    test_angle_closest_distance(- 45, -226,  true,  179, stats);  test_angle_closest_distance(- 45, -226, false,  179, stats);

    test_angle_closest_distance(- 90, -269,  true, -179, stats);  test_angle_closest_distance(- 90, -269, false, -179, stats);
    test_angle_closest_distance(- 90, -270,  true,  180, stats);  test_angle_closest_distance(- 90, -270, false, -180, stats);
    test_angle_closest_distance(- 90, -271,  true,  179, stats);  test_angle_closest_distance(- 90, -271, false,  179, stats);

    test_angle_closest_distance(-135, -314,  true, -179, stats);  test_angle_closest_distance(-135, -314, false, -179, stats);
    test_angle_closest_distance(-135, -315,  true,  180, stats);  test_angle_closest_distance(-135, -315, false, -180, stats);
    test_angle_closest_distance(-135, -316,  true,  179, stats);  test_angle_closest_distance(-135, -316, false,  179, stats);

    test_angle_closest_distance(-180, -359,  true, -179, stats);  test_angle_closest_distance(-180, -359, false, -179, stats);
    test_angle_closest_distance(-180, -360,  true,  180, stats);  test_angle_closest_distance(-180, -360, false, -180, stats);
    test_angle_closest_distance(-180, -361,  true,  179, stats);  test_angle_closest_distance(-180, -361, false,  179, stats);

    test_angle_closest_distance(-225, -404,  true, -179, stats);  test_angle_closest_distance(-225, -404, false, -179, stats);
    test_angle_closest_distance(-225, -405,  true,  180, stats);  test_angle_closest_distance(-225, -405, false, -180, stats);
    test_angle_closest_distance(-225, -406,  true,  179, stats);  test_angle_closest_distance(-225, -406, false,  179, stats);

    test_angle_closest_distance(-270, -449,  true, -179, stats);  test_angle_closest_distance(-270, -449, false, -179, stats);
    test_angle_closest_distance(-270, -450,  true,  180, stats);  test_angle_closest_distance(-270, -450, false, -180, stats);
    test_angle_closest_distance(-270, -451,  true,  179, stats);  test_angle_closest_distance(-270, -451, false,  179, stats);

    test_angle_closest_distance(-315, -494,  true, -179, stats);  test_angle_closest_distance(-315, -494, false, -179, stats);
    test_angle_closest_distance(-315, -495,  true,  180, stats);  test_angle_closest_distance(-315, -495, false, -180, stats);
    test_angle_closest_distance(-315, -496,  true,  179, stats);  test_angle_closest_distance(-315, -496, false,  179, stats);

    test_angle_closest_distance(-360, -539,  true, -179, stats);  test_angle_closest_distance(-360, -539, false, -179, stats);
    test_angle_closest_distance(-360, -540,  true,  180, stats);  test_angle_closest_distance(-360, -540, false, -180, stats);
    test_angle_closest_distance(-360, -541,  true,  179, stats);  test_angle_closest_distance(-360, -541, false,  179, stats);

    // [0..-179], [0..-180], [0..-181], 45 degrees shift to positive

    test_angle_closest_distance(  45, -134,  true, -179, stats);  test_angle_closest_distance(  45, -134, false, -179, stats);
    test_angle_closest_distance(  45, -135,  true, -180, stats);  test_angle_closest_distance(  45, -135, false, -180, stats);
    test_angle_closest_distance(  45, -136,  true,  179, stats);  test_angle_closest_distance(  45, -136, false,  179, stats);

    test_angle_closest_distance(  90,  -89,  true, -179, stats);  test_angle_closest_distance(  90,  -89, false, -179, stats);
    test_angle_closest_distance(  90,  -90,  true, -180, stats);  test_angle_closest_distance(  90,  -90, false, -180, stats);
    test_angle_closest_distance(  90,  -91,  true,  179, stats);  test_angle_closest_distance(  90,  -91, false,  179, stats);

    test_angle_closest_distance( 135,  -44,  true, -179, stats);  test_angle_closest_distance( 135,  -44, false, -179, stats);
    test_angle_closest_distance( 135,  -45,  true, -180, stats);  test_angle_closest_distance( 135,  -45, false, -180, stats);
    test_angle_closest_distance( 135,  -46,  true,  179, stats);  test_angle_closest_distance( 135,  -46, false,  179, stats);

    test_angle_closest_distance( 180,    1,  true, -179, stats);  test_angle_closest_distance( 180,    1, false, -179, stats);
    test_angle_closest_distance( 180,    0,  true, -180, stats);  test_angle_closest_distance( 180,    0, false, -180, stats);
    test_angle_closest_distance( 180,   -1,  true,  179, stats);  test_angle_closest_distance( 180,   -1, false,  179, stats);

    test_angle_closest_distance( 225,   46,  true, -179, stats);  test_angle_closest_distance( 225,   46, false, -179, stats);
    test_angle_closest_distance( 225,   45,  true, -180, stats);  test_angle_closest_distance( 225,   45, false, -180, stats);
    test_angle_closest_distance( 225,   44,  true,  179, stats);  test_angle_closest_distance( 225,   44, false,  179, stats);

    test_angle_closest_distance( 270,   91,  true, -179, stats);  test_angle_closest_distance( 270,   91, false, -179, stats);
    test_angle_closest_distance( 270,   90,  true, -180, stats);  test_angle_closest_distance( 270,   90, false, -180, stats);
    test_angle_closest_distance( 270,   89,  true,  179, stats);  test_angle_closest_distance( 270,   89, false,  179, stats);

    test_angle_closest_distance( 315,  136,  true, -179, stats);  test_angle_closest_distance( 315,  136, false, -179, stats);
    test_angle_closest_distance( 315,  135,  true, -180, stats);  test_angle_closest_distance( 315,  135, false, -180, stats);
    test_angle_closest_distance( 315,  134,  true,  179, stats);  test_angle_closest_distance( 315,  134, false,  179, stats);

    test_angle_closest_distance( 360,  181,  true, -179, stats);  test_angle_closest_distance( 360,  181, false, -179, stats);
    test_angle_closest_distance( 360,  180,  true, -180, stats);  test_angle_closest_distance( 360,  180, false, -180, stats);
    test_angle_closest_distance( 360,  179,  true,  179, stats);  test_angle_closest_distance( 360,  179, false,  179, stats);

    // [180..-1], [180..0], [180..1], 45 degrees shift to positive

// duplication
//    test_angle_closest_distance( 180, -  1,  true,  179, stats);  test_angle_closest_distance( 180, -  1, false,  179, stats);
//    test_angle_closest_distance( 180,    0,  true, -180, stats);  test_angle_closest_distance( 180,    0, false, -180, stats);
//    test_angle_closest_distance( 180,    1,  true, -179, stats);  test_angle_closest_distance( 180,    1, false, -179, stats);
//
//    test_angle_closest_distance( 225,   44,  true,  179, stats);  test_angle_closest_distance( 225,   44, false,  179, stats);
//    test_angle_closest_distance( 225,   45,  true, -180, stats);  test_angle_closest_distance( 225,   45, false, -180, stats);
//    test_angle_closest_distance( 225,   46,  true, -179, stats);  test_angle_closest_distance( 225,   46, false, -179, stats);
//
//    test_angle_closest_distance( 270,   89,  true,  179, stats);  test_angle_closest_distance( 270,   89, false,  179, stats);
//    test_angle_closest_distance( 270,   90,  true, -180, stats);  test_angle_closest_distance( 270,   90, false, -180, stats);
//    test_angle_closest_distance( 270,   91,  true, -179, stats);  test_angle_closest_distance( 270,   91, false, -179, stats);
//
//    test_angle_closest_distance( 315,  134,  true,  179, stats);  test_angle_closest_distance( 315,  134, false,  179, stats);
//    test_angle_closest_distance( 315,  135,  true, -180, stats);  test_angle_closest_distance( 315,  135, false, -180, stats);
//    test_angle_closest_distance( 315,  136,  true, -179, stats);  test_angle_closest_distance( 315,  136, false, -179, stats);
//
//    test_angle_closest_distance( 360,  179,  true,  179, stats);  test_angle_closest_distance( 360,  179, false,  179, stats);
//    test_angle_closest_distance( 360,  180,  true, -180, stats);  test_angle_closest_distance( 360,  180, false, -180, stats);
//    test_angle_closest_distance( 360,  181,  true, -179, stats);  test_angle_closest_distance( 360,  181, false, -179, stats);

    test_angle_closest_distance( 405,  224,  true,  179, stats);  test_angle_closest_distance( 405,  224, false,  179, stats);
    test_angle_closest_distance( 405,  225,  true, -180, stats);  test_angle_closest_distance( 405,  225, false, -180, stats);
    test_angle_closest_distance( 405,  226,  true, -179, stats);  test_angle_closest_distance( 405,  226, false, -179, stats);

    test_angle_closest_distance( 450,  269,  true,  179, stats);  test_angle_closest_distance( 450,  269, false,  179, stats);
    test_angle_closest_distance( 450,  270,  true, -180, stats);  test_angle_closest_distance( 450,  270, false, -180, stats);
    test_angle_closest_distance( 450,  271,  true, -179, stats);  test_angle_closest_distance( 450,  271, false, -179, stats);

    test_angle_closest_distance( 495,  314,  true,  179, stats);  test_angle_closest_distance( 495,  314, false,  179, stats);
    test_angle_closest_distance( 495,  315,  true, -180, stats);  test_angle_closest_distance( 495,  315, false, -180, stats);
    test_angle_closest_distance( 495,  316,  true, -179, stats);  test_angle_closest_distance( 495,  316, false, -179, stats);

    test_angle_closest_distance( 540,  359,  true,  179, stats);  test_angle_closest_distance( 540,  359, false,  179, stats);
    test_angle_closest_distance( 540,  360,  true, -180, stats);  test_angle_closest_distance( 540,  360, false, -180, stats);
    test_angle_closest_distance( 540,  361,  true, -179, stats);  test_angle_closest_distance( 540,  361, false, -179, stats);

    // [180..-1], [180..0], [180..1], 45 degrees shift to negative

// duplication
//    test_angle_closest_distance( 135, - 46,  true,  179, stats);  test_angle_closest_distance( 135, - 46, false,  179, stats);
//    test_angle_closest_distance( 135, - 45,  true, -180, stats);  test_angle_closest_distance( 135, - 45, false, -180, stats);
//    test_angle_closest_distance( 135, - 44,  true, -179, stats);  test_angle_closest_distance( 135, - 44, false, -179, stats);
//
//    test_angle_closest_distance(  90, - 91,  true,  179, stats);  test_angle_closest_distance(  90, - 91, false,  179, stats);
//    test_angle_closest_distance(  90, - 90,  true, -180, stats);  test_angle_closest_distance(  90, - 90, false, -180, stats);
//    test_angle_closest_distance(  90, - 89,  true, -179, stats);  test_angle_closest_distance(  90, - 89, false, -179, stats);
//
//    test_angle_closest_distance(  45, -136,  true,  179, stats);  test_angle_closest_distance(  45, -136, false,  179, stats);
//    test_angle_closest_distance(  45, -135,  true, -180, stats);  test_angle_closest_distance(  45, -135, false, -180, stats);
//    test_angle_closest_distance(  45, -134,  true, -179, stats);  test_angle_closest_distance(  45, -134, false, -179, stats);
//
//    test_angle_closest_distance(   0, -181,  true,  179, stats);  test_angle_closest_distance(   0, -181, false,  179, stats);
//    test_angle_closest_distance(   0, -180,  true,  180, stats);  test_angle_closest_distance(   0, -180, false, -180, stats);
//    test_angle_closest_distance(   0, -179,  true, -179, stats);  test_angle_closest_distance(   0, -179, false, -179, stats);
//
//    test_angle_closest_distance(- 45, -226,  true,  179, stats);  test_angle_closest_distance(- 45, -226, false,  179, stats);
//    test_angle_closest_distance(- 45, -225,  true,  180, stats);  test_angle_closest_distance(- 45, -225, false, -180, stats);
//    test_angle_closest_distance(- 45, -224,  true, -179, stats);  test_angle_closest_distance(- 45, -224, false, -179, stats);
//
//    test_angle_closest_distance(- 90, -271,  true,  179, stats);  test_angle_closest_distance(- 90, -271, false,  179, stats);
//    test_angle_closest_distance(- 90, -270,  true,  180, stats);  test_angle_closest_distance(- 90, -270, false, -180, stats);
//    test_angle_closest_distance(- 90, -269,  true, -179, stats);  test_angle_closest_distance(- 90, -269, false, -179, stats);
//
//    test_angle_closest_distance(-135, -316,  true,  179, stats);  test_angle_closest_distance(-135, -316, false,  179, stats);
//    test_angle_closest_distance(-135, -315,  true,  180, stats);  test_angle_closest_distance(-135, -315, false, -180, stats);
//    test_angle_closest_distance(-135, -314,  true, -179, stats);  test_angle_closest_distance(-135, -314, false, -179, stats);
//
//    test_angle_closest_distance(-180, -361,  true,  179, stats);  test_angle_closest_distance(-180, -361, false,  179, stats);
//    test_angle_closest_distance(-180, -360,  true,  180, stats);  test_angle_closest_distance(-180, -360, false, -180, stats);
//    test_angle_closest_distance(-180, -359,  true, -179, stats);  test_angle_closest_distance(-180, -359, false, -179, stats);

    // [-180..-1], [-180..0], [-180..1], 45 degrees shift to negative

// duplication
//    test_angle_closest_distance(-180,    1,  true, -179, stats);  test_angle_closest_distance(-180,    1, false, -179, stats);
//    test_angle_closest_distance(-180,    0,  true,  180, stats);  test_angle_closest_distance(-180,    0, false,  180, stats);
//    test_angle_closest_distance(-180, -  1,  true,  179, stats);  test_angle_closest_distance(-180, -  1, false,  179, stats);

    test_angle_closest_distance(-225, - 44,  true, -179, stats);  test_angle_closest_distance(-225, - 44, false, -179, stats);
    test_angle_closest_distance(-225, - 45,  true,  180, stats);  test_angle_closest_distance(-225, - 45, false,  180, stats);
    test_angle_closest_distance(-225, - 46,  true,  179, stats);  test_angle_closest_distance(-225, - 46, false,  179, stats);

    test_angle_closest_distance(-270, - 89,  true, -179, stats);  test_angle_closest_distance(-270, - 89, false, -179, stats);
    test_angle_closest_distance(-270, - 90,  true,  180, stats);  test_angle_closest_distance(-270, - 90, false,  180, stats);
    test_angle_closest_distance(-270, - 91,  true,  179, stats);  test_angle_closest_distance(-270, - 91, false,  179, stats);

//    test_angle_closest_distance(-315, -134,  true, -179, stats);  test_angle_closest_distance(-315, -134, false, -179, stats);
//    test_angle_closest_distance(-315, -135,  true,  180, stats);  test_angle_closest_distance(-315, -135, false,  180, stats);
//    test_angle_closest_distance(-315, -136,  true,  179, stats);  test_angle_closest_distance(-315, -136, false,  179, stats);
//
//    test_angle_closest_distance(-360, -179,  true, -179, stats);  test_angle_closest_distance(-360, -179, false, -179, stats);
//    test_angle_closest_distance(-360, -180,  true,  180, stats);  test_angle_closest_distance(-360, -180, false,  180, stats);
//    test_angle_closest_distance(-360, -181,  true,  179, stats);  test_angle_closest_distance(-360, -181, false,  179, stats);

    test_angle_closest_distance(-405, -224,  true, -179, stats);  test_angle_closest_distance(-405, -224, false, -179, stats);
    test_angle_closest_distance(-405, -225,  true,  180, stats);  test_angle_closest_distance(-405, -225, false,  180, stats);
    test_angle_closest_distance(-405, -226,  true,  179, stats);  test_angle_closest_distance(-405, -226, false,  179, stats);

    test_angle_closest_distance(-450, -269,  true, -179, stats);  test_angle_closest_distance(-450, -269, false, -179, stats);
    test_angle_closest_distance(-450, -270,  true,  180, stats);  test_angle_closest_distance(-450, -270, false,  180, stats);
    test_angle_closest_distance(-450, -271,  true,  179, stats);  test_angle_closest_distance(-450, -271, false,  179, stats);

    test_angle_closest_distance(-495, -314,  true, -179, stats);  test_angle_closest_distance(-495, -314, false, -179, stats);
    test_angle_closest_distance(-495, -315,  true,  180, stats);  test_angle_closest_distance(-495, -315, false,  180, stats);
    test_angle_closest_distance(-495, -316,  true,  179, stats);  test_angle_closest_distance(-495, -316, false,  179, stats);

    test_angle_closest_distance(-540, -359,  true, -179, stats);  test_angle_closest_distance(-540, -359, false, -179, stats);
    test_angle_closest_distance(-540, -360,  true,  180, stats);  test_angle_closest_distance(-540, -360, false,  180, stats);
    test_angle_closest_distance(-540, -361,  true,  179, stats);  test_angle_closest_distance(-540, -361, false,  179, stats);

    // [-180..-1], [-180..0], [-180..1], 45 degrees shift to positive

// duplication
//    test_angle_closest_distance(-135,   44,  true,  179, stats);  test_angle_closest_distance(-135,   44, false,  179, stats);
//    test_angle_closest_distance(-135,   45,  true,  180, stats);  test_angle_closest_distance(-135,   45, false,  180, stats);
//    test_angle_closest_distance(-135,   46,  true, -179, stats);  test_angle_closest_distance(-135,   46, false, -179, stats);
//
//    test_angle_closest_distance(- 90,   89,  true,  179, stats);  test_angle_closest_distance(- 90,   89, false,  179, stats);
//    test_angle_closest_distance(- 90,   90,  true,  180, stats);  test_angle_closest_distance(- 90,   90, false,  180, stats);
//    test_angle_closest_distance(- 90,   91,  true, -179, stats);  test_angle_closest_distance(- 90,   91, false, -179, stats);
//
//    test_angle_closest_distance(- 45,  134,  true,  179, stats);  test_angle_closest_distance(- 45,  134, false,  179, stats);
//    test_angle_closest_distance(- 45,  135,  true,  180, stats);  test_angle_closest_distance(- 45,  135, false,  180, stats);
//    test_angle_closest_distance(- 45,  136,  true, -179, stats);  test_angle_closest_distance(- 45,  136, false, -179, stats);
//
//    test_angle_closest_distance(   0,  179,  true,  179, stats);  test_angle_closest_distance(   0,  179, false,  179, stats);
//    test_angle_closest_distance(   0,  180,  true,  180, stats);  test_angle_closest_distance(   0,  180, false,  180, stats);
//    test_angle_closest_distance(   0,  181,  true, -179, stats);  test_angle_closest_distance(   0,  181, false, -179, stats);
//
//    test_angle_closest_distance(  45,  224,  true,  179, stats);  test_angle_closest_distance(  45,  224, false,  179, stats);
//    test_angle_closest_distance(  45,  225,  true, -180, stats);  test_angle_closest_distance(  45,  225, false,  180, stats);
//    test_angle_closest_distance(  45,  226,  true, -179, stats);  test_angle_closest_distance(  45,  226, false, -179, stats);
//
//    test_angle_closest_distance(  90,  269,  true,  179, stats);  test_angle_closest_distance(  90,  269, false,  179, stats);
//    test_angle_closest_distance(  90,  270,  true, -180, stats);  test_angle_closest_distance(  90,  270, false,  180, stats);
//    test_angle_closest_distance(  90,  271,  true, -179, stats);  test_angle_closest_distance(  90,  271, false, -179, stats);
//
//    test_angle_closest_distance( 135,  314,  true,  179, stats);  test_angle_closest_distance( 135,  314, false,  179, stats);
//    test_angle_closest_distance( 135,  315,  true, -180, stats);  test_angle_closest_distance( 135,  315, false,  180, stats);
//    test_angle_closest_distance( 135,  316,  true, -179, stats);  test_angle_closest_distance( 135,  316, false, -179, stats);
//
//    test_angle_closest_distance( 180,  359,  true,  179, stats);  test_angle_closest_distance( 180,  359, false,  179, stats);
//    test_angle_closest_distance( 180,  360,  true, -180, stats);  test_angle_closest_distance( 180,  360, false,  180, stats);
//    test_angle_closest_distance( 180,  361,  true, -179, stats);  test_angle_closest_distance( 180,  361, false, -179, stats);

}

//// math::angle_distance

void test_angle_distance(double start_angle_deg, double end_angle_deg, bool positive_angle_change, double eta_angle_distance, TestStats_angle_distance & stats)
{
    const double angle_distance = math::angle_distance<double>(start_angle_deg, end_angle_deg, 0, positive_angle_change, false);

    const double angle_distance_fluctuation = std::fabs(angle_distance - eta_angle_distance);

    stats.peak_angle_distance_fluctuation = (std::max)(stats.peak_angle_distance_fluctuation, angle_distance_fluctuation);

    ASSERT_GE(common::angle_distance_epsilon, angle_distance_fluctuation);

    if (angle_distance >= 0) {
        ASSERT_GE(start_angle_deg + angle_distance, start_angle_deg);
        ASSERT_EQ(
            math::normalize_angle<double>(end_angle_deg, 0, 360, 360, -1),
            math::normalize_angle<double>(start_angle_deg + angle_distance, 0, 360, 360, -1));
    }
    else {
        ASSERT_LE(start_angle_deg + angle_distance, start_angle_deg);
        ASSERT_EQ(
            math::normalize_angle<double>(end_angle_deg, 0, 360, 360, -1),
            math::normalize_angle<double>(start_angle_deg + angle_distance, 0, 360, 360, -1));
    }

    const double angle_distance_normalized = std::fabs(
        math::normalize_angle<double>(end_angle_deg, 0, 360, 360, -1) -
        math::normalize_angle<double>(start_angle_deg + angle_distance, 0, 360, 360, -1));

    ASSERT_GE(common::angle_closest_distance_epsilon, angle_distance_normalized);
}

TEST(FunctionsTest, angle_distance)
{
    TestStats_angle_distance stats;

    //// any angle tests

    // special cases
    test_angle_distance( 0.0,  0.0,  true,    0, stats);
    test_angle_distance( 0.0, -0.0,  true,    0, stats);
    test_angle_distance(-0.0,  0.0,  true,    0, stats);
    test_angle_distance(-0.0, -0.0,  true,    0, stats);

    // start: [0..90], positive end, positive distance
    test_angle_distance(   5,   10,  true,    5, stats);
    test_angle_distance(   0,   90,  true,   90, stats);
    test_angle_distance(   5,  175,  true,  170, stats);

    test_angle_distance(   0,  360,  true,    0, stats);
    test_angle_distance(   5,  370,  true,    5, stats);
    test_angle_distance(   0,  450,  true,   90, stats);
    test_angle_distance(   5,  535,  true,  170, stats);
    test_angle_distance(   0,  540,  true,  180, stats);

    // start: [0..90], positive end, negative distance
    test_angle_distance(   5,  185, false, -180, stats);
    test_angle_distance(   5,  355, false, - 10, stats);
    test_angle_distance(   0,  270, false, - 90, stats);
    test_angle_distance(   5,  186, false, -179, stats);
    test_angle_distance(   5,  545, false, -180, stats);

    // start: [90..180], positive end, positive distance
    test_angle_distance(  90,   90,  true,    0, stats);
    test_angle_distance(  95,  100,  true,    5, stats);
    test_angle_distance(  90,  180,  true,   90, stats);
    test_angle_distance(  95,  265,  true,  170, stats);

    test_angle_distance(  90,  450,  true,    0, stats);
    test_angle_distance(  95,  460,  true,    5, stats);
    test_angle_distance(  90,  540,  true,   90, stats);
    test_angle_distance(  95,  625,  true,  170, stats);

    // start: [90..180], positive end, negative distance
    test_angle_distance(  95,   85, false, - 10, stats);
    test_angle_distance(  90,  360, false, - 90, stats);
    test_angle_distance(  95,  276, false, -179, stats);
    test_angle_distance(  95,  275, false, -180, stats);
    test_angle_distance(  90,  630, false, -180, stats);
    test_angle_distance(  95,  635, false, -180, stats);

    // start: [180..270], positive end, positive distance
    test_angle_distance( 180,  180,  true,    0, stats);
    test_angle_distance( 185,  190,  true,    5, stats);
    test_angle_distance( 180,  270,  true,   90, stats);
    test_angle_distance( 185,  355,  true,  170, stats);

    test_angle_distance( 180,  540,  true,    0, stats);
    test_angle_distance( 185,  550,  true,    5, stats);
    test_angle_distance( 180,  630,  true,   90, stats);
    test_angle_distance( 185,  715,  true,  170, stats);

    // start: [180..270], positive end, negative distance
    test_angle_distance( 185,  175, false, - 10, stats);
    test_angle_distance( 180,   90, false, - 90, stats);
    test_angle_distance( 185,    6, false, -179, stats);
    test_angle_distance( 185,    5, false, -180, stats);
    test_angle_distance( 185,  365, false, -180, stats);
    test_angle_distance( 180,  720, false, -180, stats);
    test_angle_distance( 185,  725, false, -180, stats);

    // start: [270..360], positive end, positive distance
    test_angle_distance( 270,  270,  true,    0, stats);
    test_angle_distance( 275,  280,  true,    5, stats);
    test_angle_distance( 270,    0,  true,   90, stats);
    test_angle_distance( 270,  360,  true,   90, stats);
    test_angle_distance( 275,  445,  true,  170, stats);

    test_angle_distance( 270,  630,  true,    0, stats);
    test_angle_distance( 275,  640,  true,    5, stats);
    test_angle_distance( 270,  720,  true,   90, stats);
    test_angle_distance( 275,   85,  true,  170, stats);

    // start: [270..360], positive end, negative distance
    test_angle_distance( 275,  265, false, - 10, stats);
    test_angle_distance( 270,  180, false, - 90, stats);
    test_angle_distance( 275,   96, false, -179, stats);
    test_angle_distance( 275,   95, false, -180, stats);
    test_angle_distance( 270,  450, false, -180, stats);
    test_angle_distance( 275,  455, false, -180, stats);

    ////

    // start: [0..90], negative end, positive distance
    test_angle_distance(   0, -360,  true,    0, stats);
    test_angle_distance(   5, -350,  true,    5, stats);
    test_angle_distance(   0, -270,  true,   90, stats);
    test_angle_distance(   5, -185,  true,  170, stats);

    test_angle_distance(   0, -720,  true,    0, stats);
    test_angle_distance(   5, -710,  true,    5, stats);
    test_angle_distance(   0, -270,  true,   90, stats);
    test_angle_distance(   5, -185,  true,  170, stats);

    // start: [0..90], negative end, negative distance
    test_angle_distance(   5, -  5, false, - 10, stats);
    test_angle_distance(   0, - 90, false, - 90, stats);
    test_angle_distance(   5, -174, false, -179, stats);
    test_angle_distance(   5, -175, false, -180, stats);

    // start: [90..180], negative end, positive distance
    test_angle_distance(  90, -270,  true,    0, stats);
    test_angle_distance(  95, -260,  true,    5, stats);
    test_angle_distance(  90, -180,  true,   90, stats);
    test_angle_distance(  95, - 95,  true,  170, stats);
    test_angle_distance(  95, - 86,  true,  179, stats);

    // start: [90..180], negative end, negative distance
    test_angle_distance(  90, -360, false, - 90, stats);
    test_angle_distance(  95, -275, false, - 10, stats);
    test_angle_distance(  90, - 90, false, -180, stats);
    test_angle_distance(  95, - 85, false, -180, stats);
    test_angle_distance(  95, - 84, false, -179, stats);
    test_angle_distance(  90,    0, false, - 90, stats);

    // start: [180..270], negative end, positive distance
    test_angle_distance( 180, -180,  true,    0, stats);
    test_angle_distance( 185, -170,  true,    5, stats);
    test_angle_distance( 180, - 90,  true,   90, stats);
    test_angle_distance( 185, -  5,  true,  170, stats);

    // start: [180..270], negative end, negative distance
    test_angle_distance( 180, -360, false, -180, stats);
    test_angle_distance( 185, -185, false, - 10, stats);
    test_angle_distance( 180, -270, false, - 90, stats);
    test_angle_distance( 185, -354, false, -179, stats);
    test_angle_distance( 185, -355, false, -180, stats);

    // start: [270..360], negative end, positive distance
    test_angle_distance( 275, - 80,  true,    5, stats);
    test_angle_distance( 270, -360,  true,   90, stats);
    test_angle_distance( 275, -275,  true,  170, stats);

    test_angle_distance( 270, - 90,  true,    0, stats);

    // start: [270..360], negative end, negative distance
    test_angle_distance( 270, -270, false, -180, stats);
    test_angle_distance( 275, -265, false, -180, stats);
    test_angle_distance( 275, - 95, false, - 10, stats);
    test_angle_distance( 270, -180, false, - 90, stats);
    test_angle_distance( 275, -264, false, -179, stats);
    test_angle_distance( 275, -265, false, -180, stats);

    ////

    // start: (0..-90], positive end, positive distance
    test_angle_distance(-  5,    0,  true,    5, stats);
    test_angle_distance(-  5,  165,  true,  170, stats);
    test_angle_distance(-  5,  175,  true,  180, stats);

    test_angle_distance(-  5,  360,  true,    5, stats);
    test_angle_distance(-  5,  525,  true,  170, stats);
    test_angle_distance(-  5,  535,  true,  180, stats);

    // start: (0..-90], positive end, negative distance
    test_angle_distance(-  5,  345, false, - 10, stats);
    test_angle_distance(-  5,  176, false, -179, stats);

    // start: [-90..-180], positive end, positive distance
    test_angle_distance(- 90,    0,  true,   90, stats);
    test_angle_distance(- 95,    5,  true,  100, stats);
    test_angle_distance(- 90,   90,  true,  180, stats);
    test_angle_distance(- 95,   85,  true,  180, stats);
    test_angle_distance(- 90,  270,  true,    0, stats);
    test_angle_distance(- 95,  275,  true,   10, stats);

    test_angle_distance(- 90,  360,  true,   90, stats);
    test_angle_distance(- 95,  365,  true,  100, stats);
    test_angle_distance(- 95,  435,  true,  170, stats);
    test_angle_distance(- 90,  450,  true,  180, stats);

    // start: [-90..-180], positive end, negative distance
    test_angle_distance(- 90,   91, false, -179, stats);
    test_angle_distance(- 95,   86, false, -179, stats);

    // start: [-180..-270], positive end, positive distance
    test_angle_distance(-180,    0,  true,  180, stats);
    test_angle_distance(-180,  180,  true,    0, stats);
    test_angle_distance(-185,  180,  true,    5, stats);
    test_angle_distance(-180,  270,  true,   90, stats);
    test_angle_distance(-185,  345,  true,  170, stats);
    test_angle_distance(-180,  360,  true,  180, stats);
    test_angle_distance(-185,  355,  true,  180, stats);

    // start: [-180..-270], positive end, negative distance
    test_angle_distance(-185,  165, false, - 10, stats);
    test_angle_distance(-180,   90, false, - 90, stats);
    test_angle_distance(-185,    0, false, -175, stats);

    // start: [-270..-360], positive end, positive distance
    test_angle_distance(-270,  270,  true,  180, stats);
    test_angle_distance(-270,  260,  true,  170, stats);
    test_angle_distance(-275,   85,  true,    0, stats);
    test_angle_distance(-270,   90,  true,    0, stats);
    test_angle_distance(-270,  180,  true,   90, stats);

    // start: [-270..-360], positive end, negative distance
    test_angle_distance(-270,    0, false, - 90, stats);
    test_angle_distance(-275,    5, false, - 80, stats);
    test_angle_distance(-270,  365, false, - 85, stats);
    test_angle_distance(-270,  360, false, - 90, stats);
    test_angle_distance(-275,  355, false, - 90, stats);

    ////

    // start: (0..-90], negative end, positive distance
    test_angle_distance(-  5, -365,  true,    0, stats);
    test_angle_distance(-  5, -360,  true,    5, stats);
    test_angle_distance(-  5, -185,  true,  180, stats);

    // start: (0..-90], negative end, negative distance
    test_angle_distance(-  5, - 10, false, -  5, stats);
    test_angle_distance(-  5, -184, false, -179, stats);
    test_angle_distance(-  5, -370, false, -  5, stats);

    // start: [-90..-180], negative end, positive distance
    test_angle_distance(- 90, -  5,  true,   85, stats);
    test_angle_distance(- 90, - 90,  true,    0, stats);
    test_angle_distance(- 95, -275,  true,  180, stats);
    test_angle_distance(- 90, -360,  true,   90, stats);

    // start: [-90..-180], negative end, negative distance
    test_angle_distance(- 90, -180, false, - 90, stats);

    test_angle_distance(- 90, -540, false, - 90, stats);

    // start: [-180..-270], negative end, positive distance
    test_angle_distance(-180, -180,  true,    0, stats);
    test_angle_distance(-180, - 90,  true,   90, stats);
    test_angle_distance(-185, -  5,  true,  180, stats);

    // start: [-180..-270], negative end, negative distance
    test_angle_distance(-180, -270, false, - 90, stats);
    test_angle_distance(-185, -275, false, - 90, stats);
    test_angle_distance(-180, -355, false, -175, stats);
    test_angle_distance(-185, -355, false, -170, stats);
    test_angle_distance(-185, -715, false, -170, stats);

    // start: [-270..-360], negative end, positive distance
    test_angle_distance(-270, -270,  true,    0, stats);
    test_angle_distance(-270, -180,  true,   90, stats);
    test_angle_distance(-275, - 95,  true,  180, stats);

    // start: [-270..-360], negative end, negative distance
    test_angle_distance(-270, - 85, false, -175, stats);
    test_angle_distance(-270, -360, false, - 90, stats);
    test_angle_distance(-275, -365, false, - 90, stats);

    //// 179, 180, 181 ONLY angle tests

    // [0..179], [0..180], [0..181], 45 degrees shift to positive

    test_angle_distance(   0,  179,  true,  179, stats);  test_angle_distance(   0,  179, false, -181, stats);
    test_angle_distance(   0,  180,  true,  180, stats);  test_angle_distance(   0,  180, false, -180, stats);
    test_angle_distance(   0,  181,  true,  181, stats);  test_angle_distance(   0,  181, false, -179, stats);

    test_angle_distance(  45,  224,  true,  179, stats);  test_angle_distance(  45,  224, false, -181, stats);
    test_angle_distance(  45,  225,  true,  180, stats);  test_angle_distance(  45,  225, false, -180, stats);
    test_angle_distance(  45,  226,  true,  181, stats);  test_angle_distance(  45,  226, false, -179, stats);

    test_angle_distance(  90,  269,  true,  179, stats);  test_angle_distance(  90,  269, false, -181, stats);
    test_angle_distance(  90,  270,  true,  180, stats);  test_angle_distance(  90,  270, false, -180, stats);
    test_angle_distance(  90,  271,  true,  181, stats);  test_angle_distance(  90,  271, false, -179, stats);

    test_angle_distance( 135,  314,  true,  179, stats);  test_angle_distance( 135,  314, false, -181, stats);
    test_angle_distance( 135,  315,  true,  180, stats);  test_angle_distance( 135,  315, false, -180, stats);
    test_angle_distance( 135,  316,  true,  181, stats);  test_angle_distance( 135,  316, false, -179, stats);

    test_angle_distance( 180,  359,  true,  179, stats);  test_angle_distance( 180,  359, false, -181, stats);
    test_angle_distance( 180,  360,  true,  180, stats);  test_angle_distance( 180,  360, false, -180, stats);
    test_angle_distance( 180,  361,  true,  181, stats);  test_angle_distance( 180,  361, false, -179, stats);

    test_angle_distance( 225,  404,  true,  179, stats);  test_angle_distance( 225,  404, false, -181, stats);
    test_angle_distance( 225,  405,  true,  180, stats);  test_angle_distance( 225,  405, false, -180, stats);
    test_angle_distance( 225,  406,  true,  181, stats);  test_angle_distance( 225,  406, false, -179, stats);

    test_angle_distance( 270,  449,  true,  179, stats);  test_angle_distance( 270,  449, false, -181, stats);
    test_angle_distance( 270,  450,  true,  180, stats);  test_angle_distance( 270,  450, false, -180, stats);
    test_angle_distance( 270,  451,  true,  181, stats);  test_angle_distance( 270,  451, false, -179, stats);

    test_angle_distance( 315,  494,  true,  179, stats);  test_angle_distance( 315,  494, false, -181, stats);
    test_angle_distance( 315,  495,  true,  180, stats);  test_angle_distance( 315,  495, false, -180, stats);
    test_angle_distance( 315,  496,  true,  181, stats);  test_angle_distance( 315,  496, false, -179, stats);

    test_angle_distance( 360,  539,  true,  179, stats);  test_angle_distance( 360,  539, false, -181, stats);
    test_angle_distance( 360,  540,  true,  180, stats);  test_angle_distance( 360,  540, false, -180, stats);
    test_angle_distance( 360,  541,  true,  181, stats);  test_angle_distance( 360,  541, false, -179, stats);

    // [0..179], [0..180], [0..181], 45 degrees shift to negative

    test_angle_distance(- 45,  134,  true,  179, stats);  test_angle_distance(- 45,  134, false, -181, stats);
    test_angle_distance(- 45,  135,  true,  180, stats);  test_angle_distance(- 45,  135, false, -180, stats);
    test_angle_distance(- 45,  136,  true,  181, stats);  test_angle_distance(- 45,  136, false, -179, stats);

    test_angle_distance(- 90,   89,  true,  179, stats);  test_angle_distance(- 90,   89, false, -181, stats);
    test_angle_distance(- 90,   90,  true,  180, stats);  test_angle_distance(- 90,   90, false, -180, stats);
    test_angle_distance(- 90,   91,  true,  181, stats);  test_angle_distance(- 90,   91, false, -179, stats);

    test_angle_distance(-135,   44,  true,  179, stats);  test_angle_distance(-135,   44, false, -181, stats);
    test_angle_distance(-135,   45,  true,  180, stats);  test_angle_distance(-135,   45, false, -180, stats);
    test_angle_distance(-135,   46,  true,  181, stats);  test_angle_distance(-135,   46, false, -179, stats);

    test_angle_distance(-180,   -1,  true,  179, stats);  test_angle_distance(-180,   -1, false, -181, stats);
    test_angle_distance(-180,    0,  true,  180, stats);  test_angle_distance(-180,    0, false, -180, stats);
    test_angle_distance(-180,    1,  true,  181, stats);  test_angle_distance(-180,    1, false, -179, stats);

    test_angle_distance(-225,  -46,  true,  179, stats);  test_angle_distance(-225,  -46, false, -181, stats);
    test_angle_distance(-225,  -45,  true,  180, stats);  test_angle_distance(-225,  -45, false, -180, stats);
    test_angle_distance(-225,  -44,  true,  181, stats);  test_angle_distance(-225,  -44, false, -179, stats);

    test_angle_distance(-270,  -91,  true,  179, stats);  test_angle_distance(-270,  -91, false, -181, stats);
    test_angle_distance(-270,  -90,  true,  180, stats);  test_angle_distance(-270,  -90, false, -180, stats);
    test_angle_distance(-270,  -89,  true,  181, stats);  test_angle_distance(-270,  -89, false, -179, stats);

    test_angle_distance(-315, -136,  true,  179, stats);  test_angle_distance(-315, -136, false, -181, stats);
    test_angle_distance(-315, -135,  true,  180, stats);  test_angle_distance(-315, -135, false, -180, stats);
    test_angle_distance(-315, -134,  true,  181, stats);  test_angle_distance(-315, -134, false, -179, stats);

    test_angle_distance(-360, -181,  true,  179, stats);  test_angle_distance(-360, -181, false, -181, stats);
    test_angle_distance(-360, -180,  true,  180, stats);  test_angle_distance(-360, -180, false, -180, stats);
    test_angle_distance(-360, -179,  true,  181, stats);  test_angle_distance(-360, -179, false, -179, stats);

    // [0..-179], [0..-180], [0..-181], 45 degrees shift to negative

    test_angle_distance(   0, -179,  true,  181, stats);  test_angle_distance(   0, -179, false, -179, stats);
    test_angle_distance(   0, -180,  true,  180, stats);  test_angle_distance(   0, -180, false, -180, stats);
    test_angle_distance(   0, -181,  true,  179, stats);  test_angle_distance(   0, -181, false, -181, stats);

    test_angle_distance(- 45, -224,  true,  181, stats);  test_angle_distance(- 45, -224, false, -179, stats);
    test_angle_distance(- 45, -225,  true,  180, stats);  test_angle_distance(- 45, -225, false, -180, stats);
    test_angle_distance(- 45, -226,  true,  179, stats);  test_angle_distance(- 45, -226, false, -181, stats);

    test_angle_distance(- 90, -269,  true,  181, stats);  test_angle_distance(- 90, -269, false, -179, stats);
    test_angle_distance(- 90, -270,  true,  180, stats);  test_angle_distance(- 90, -270, false, -180, stats);
    test_angle_distance(- 90, -271,  true,  179, stats);  test_angle_distance(- 90, -271, false, -181, stats);

    test_angle_distance(-135, -314,  true,  181, stats);  test_angle_distance(-135, -314, false, -179, stats);
    test_angle_distance(-135, -315,  true,  180, stats);  test_angle_distance(-135, -315, false, -180, stats);
    test_angle_distance(-135, -316,  true,  179, stats);  test_angle_distance(-135, -316, false, -181, stats);

    test_angle_distance(-180, -359,  true,  181, stats);  test_angle_distance(-180, -359, false, -179, stats);
    test_angle_distance(-180, -360,  true,  180, stats);  test_angle_distance(-180, -360, false, -180, stats);
    test_angle_distance(-180, -361,  true,  179, stats);  test_angle_distance(-180, -361, false, -181, stats);

    test_angle_distance(-225, -404,  true,  181, stats);  test_angle_distance(-225, -404, false, -179, stats);
    test_angle_distance(-225, -405,  true,  180, stats);  test_angle_distance(-225, -405, false, -180, stats);
    test_angle_distance(-225, -406,  true,  179, stats);  test_angle_distance(-225, -406, false, -181, stats);

    test_angle_distance(-270, -449,  true,  181, stats);  test_angle_distance(-270, -449, false, -179, stats);
    test_angle_distance(-270, -450,  true,  180, stats);  test_angle_distance(-270, -450, false, -180, stats);
    test_angle_distance(-270, -451,  true,  179, stats);  test_angle_distance(-270, -451, false, -181, stats);

    test_angle_distance(-315, -494,  true,  181, stats);  test_angle_distance(-315, -494, false, -179, stats);
    test_angle_distance(-315, -495,  true,  180, stats);  test_angle_distance(-315, -495, false, -180, stats);
    test_angle_distance(-315, -496,  true,  179, stats);  test_angle_distance(-315, -496, false, -181, stats);

    test_angle_distance(-360, -539,  true,  181, stats);  test_angle_distance(-360, -539, false, -179, stats);
    test_angle_distance(-360, -540,  true,  180, stats);  test_angle_distance(-360, -540, false, -180, stats);
    test_angle_distance(-360, -541,  true,  179, stats);  test_angle_distance(-360, -541, false, -181, stats);

    // [0..-179], [0..-180], [0..-181], 45 degrees shift to positive

    test_angle_distance(  45, -134,  true,  181, stats);  test_angle_distance(  45, -134, false, -179, stats);
    test_angle_distance(  45, -135,  true,  180, stats);  test_angle_distance(  45, -135, false, -180, stats);
    test_angle_distance(  45, -136,  true,  179, stats);  test_angle_distance(  45, -136, false, -181, stats);

    test_angle_distance(  90,  -89,  true,  181, stats);  test_angle_distance(  90,  -89, false, -179, stats);
    test_angle_distance(  90,  -90,  true,  180, stats);  test_angle_distance(  90,  -90, false, -180, stats);
    test_angle_distance(  90,  -91,  true,  179, stats);  test_angle_distance(  90,  -91, false, -181, stats);

    test_angle_distance( 135,  -44,  true,  181, stats);  test_angle_distance( 135,  -44, false, -179, stats);
    test_angle_distance( 135,  -45,  true,  180, stats);  test_angle_distance( 135,  -45, false, -180, stats);
    test_angle_distance( 135,  -46,  true,  179, stats);  test_angle_distance( 135,  -46, false, -181, stats);

    test_angle_distance( 180,    1,  true,  181, stats);  test_angle_distance( 180,    1, false, -179, stats);
    test_angle_distance( 180,    0,  true,  180, stats);  test_angle_distance( 180,    0, false, -180, stats);
    test_angle_distance( 180,   -1,  true,  179, stats);  test_angle_distance( 180,   -1, false, -181, stats);

    test_angle_distance( 225,   46,  true,  181, stats);  test_angle_distance( 225,   46, false, -179, stats);
    test_angle_distance( 225,   45,  true,  180, stats);  test_angle_distance( 225,   45, false, -180, stats);
    test_angle_distance( 225,   44,  true,  179, stats);  test_angle_distance( 225,   44, false, -181, stats);

    test_angle_distance( 270,   91,  true,  181, stats);  test_angle_distance( 270,   91, false, -179, stats);
    test_angle_distance( 270,   90,  true,  180, stats);  test_angle_distance( 270,   90, false, -180, stats);
    test_angle_distance( 270,   89,  true,  179, stats);  test_angle_distance( 270,   89, false, -181, stats);

    test_angle_distance( 315,  136,  true,  181, stats);  test_angle_distance( 315,  136, false, -179, stats);
    test_angle_distance( 315,  135,  true,  180, stats);  test_angle_distance( 315,  135, false, -180, stats);
    test_angle_distance( 315,  134,  true,  179, stats);  test_angle_distance( 315,  134, false, -181, stats);

    test_angle_distance( 360,  181,  true,  181, stats);  test_angle_distance( 360,  181, false, -179, stats);
    test_angle_distance( 360,  180,  true,  180, stats);  test_angle_distance( 360,  180, false, -180, stats);
    test_angle_distance( 360,  179,  true,  179, stats);  test_angle_distance( 360,  179, false, -181, stats);

    // [180..-1], [180..0], [180..1], 45 degrees shift to positive

// duplication
//    test_angle_distance( 180, -  1,  true,  179, stats);  test_angle_distance( 180, -  1, false, -181, stats);
//    test_angle_distance( 180,    0,  true,  180, stats);  test_angle_distance( 180,    0, false, -180, stats);
//    test_angle_distance( 180,    1,  true,  181, stats);  test_angle_distance( 180,    1, false, -179, stats);
//
//    test_angle_distance( 225,   44,  true,  179, stats);  test_angle_distance( 225,   44, false, -181, stats);
//    test_angle_distance( 225,   45,  true,  180, stats);  test_angle_distance( 225,   45, false, -180, stats);
//    test_angle_distance( 225,   46,  true,  181, stats);  test_angle_distance( 225,   46, false, -179, stats);
//
//    test_angle_distance( 270,   89,  true,  179, stats);  test_angle_distance( 270,   89, false, -181, stats);
//    test_angle_distance( 270,   90,  true,  180, stats);  test_angle_distance( 270,   90, false, -180, stats);
//    test_angle_distance( 270,   91,  true,  181, stats);  test_angle_distance( 270,   91, false, -179, stats);
//
//    test_angle_distance( 315,  134,  true,  179, stats);  test_angle_distance( 315,  134, false, -181, stats);
//    test_angle_distance( 315,  135,  true,  180, stats);  test_angle_distance( 315,  135, false, -180, stats);
//    test_angle_distance( 315,  136,  true,  181, stats);  test_angle_distance( 315,  136, false, -179, stats);
//
//    test_angle_distance( 360,  179,  true,  179, stats);  test_angle_distance( 360,  179, false, -181, stats);
//    test_angle_distance( 360,  180,  true,  180, stats);  test_angle_distance( 360,  180, false, -180, stats);
//    test_angle_distance( 360,  181,  true,  181, stats);  test_angle_distance( 360,  181, false, -179, stats);

    test_angle_distance( 405,  224,  true,  179, stats);  test_angle_distance( 405,  224, false, -181, stats);
    test_angle_distance( 405,  225,  true,  180, stats);  test_angle_distance( 405,  225, false, -180, stats);
    test_angle_distance( 405,  226,  true,  181, stats);  test_angle_distance( 405,  226, false, -179, stats);

    test_angle_distance( 450,  269,  true,  179, stats);  test_angle_distance( 450,  269, false, -181, stats);
    test_angle_distance( 450,  270,  true,  180, stats);  test_angle_distance( 450,  270, false, -180, stats);
    test_angle_distance( 450,  271,  true,  181, stats);  test_angle_distance( 450,  271, false, -179, stats);

    test_angle_distance( 495,  314,  true,  179, stats);  test_angle_distance( 495,  314, false, -181, stats);
    test_angle_distance( 495,  315,  true,  180, stats);  test_angle_distance( 495,  315, false, -180, stats);
    test_angle_distance( 495,  316,  true,  181, stats);  test_angle_distance( 495,  316, false, -179, stats);

    test_angle_distance( 540,  359,  true,  179, stats);  test_angle_distance( 540,  359, false, -181, stats);
    test_angle_distance( 540,  360,  true,  180, stats);  test_angle_distance( 540,  360, false, -180, stats);
    test_angle_distance( 540,  361,  true,  181, stats);  test_angle_distance( 540,  361, false, -179, stats);

    // [180..-1], [180..0], [180..1], 45 degrees shift to negative

// duplication
//    test_angle_distance( 135, - 46,  true,  179, stats);  test_angle_distance( 135, - 46, false, -181, stats);
//    test_angle_distance( 135, - 45,  true,  180, stats);  test_angle_distance( 135, - 45, false, -180, stats);
//    test_angle_distance( 135, - 44,  true,  181, stats);  test_angle_distance( 135, - 44, false, -179, stats);
//
//    test_angle_distance(  90, - 91,  true,  179, stats);  test_angle_distance(  90, - 91, false, -181, stats);
//    test_angle_distance(  90, - 90,  true,  180, stats);  test_angle_distance(  90, - 90, false, -180, stats);
//    test_angle_distance(  90, - 89,  true,  181, stats);  test_angle_distance(  90, - 89, false, -179, stats);
//
//    test_angle_distance(  45, -136,  true,  179, stats);  test_angle_distance(  45, -136, false, -181, stats);
//    test_angle_distance(  45, -135,  true,  180, stats);  test_angle_distance(  45, -135, false, -180, stats);
//    test_angle_distance(  45, -134,  true,  181, stats);  test_angle_distance(  45, -134, false, -179, stats);
//
//    test_angle_distance(   0, -181,  true,  179, stats);  test_angle_distance(   0, -181, false, -181, stats);
//    test_angle_distance(   0, -180,  true,  180, stats);  test_angle_distance(   0, -180, false, -180, stats);
//    test_angle_distance(   0, -179,  true,  181, stats);  test_angle_distance(   0, -179, false, -179, stats);
//
//    test_angle_distance(- 45, -226,  true,  179, stats);  test_angle_distance(- 45, -226, false, -181, stats);
//    test_angle_distance(- 45, -225,  true,  180, stats);  test_angle_distance(- 45, -225, false, -180, stats);
//    test_angle_distance(- 45, -224,  true,  181, stats);  test_angle_distance(- 45, -224, false, -179, stats);
//
//    test_angle_distance(- 90, -271,  true,  179, stats);  test_angle_distance(- 90, -271, false, -181, stats);
//    test_angle_distance(- 90, -270,  true,  180, stats);  test_angle_distance(- 90, -270, false, -180, stats);
//    test_angle_distance(- 90, -269,  true,  181, stats);  test_angle_distance(- 90, -269, false, -179, stats);
//
//    test_angle_distance(-135, -316,  true,  179, stats);  test_angle_distance(-135, -316, false, -181, stats);
//    test_angle_distance(-135, -315,  true,  180, stats);  test_angle_distance(-135, -315, false, -180, stats);
//    test_angle_distance(-135, -314,  true,  181, stats);  test_angle_distance(-135, -314, false, -179, stats);
//
//    test_angle_distance(-180, -361,  true,  179, stats);  test_angle_distance(-180, -361, false, -181, stats);
//    test_angle_distance(-180, -360,  true,  180, stats);  test_angle_distance(-180, -360, false, -180, stats);
//    test_angle_distance(-180, -359,  true,  181, stats);  test_angle_distance(-180, -359, false, -179, stats);

    // [-180..-1], [-180..0], [-180..1], 45 degrees shift to negative

// duplication
//    test_angle_distance(-180,    1,  true,  181, stats);  test_angle_distance(-180,    1, false, -179, stats);
//    test_angle_distance(-180,    0,  true,  180, stats);  test_angle_distance(-180,    0, false, -180, stats);
//    test_angle_distance(-180, -  1,  true,  179, stats);  test_angle_distance(-180, -  1, false, -181, stats);

    test_angle_distance(-225, - 44,  true,  181, stats);  test_angle_distance(-225, - 44, false, -179, stats);
    test_angle_distance(-225, - 45,  true,  180, stats);  test_angle_distance(-225, - 45, false, -180, stats);
    test_angle_distance(-225, - 46,  true,  179, stats);  test_angle_distance(-225, - 46, false, -181, stats);

    test_angle_distance(-270, - 89,  true,  181, stats);  test_angle_distance(-270, - 89, false, -179, stats);
    test_angle_distance(-270, - 90,  true,  180, stats);  test_angle_distance(-270, - 90, false, -180, stats);
    test_angle_distance(-270, - 91,  true,  179, stats);  test_angle_distance(-270, - 91, false, -181, stats);

//    test_angle_distance(-315, -134,  true,  181, stats);  test_angle_distance(-315, -134, false, -179, stats);
//    test_angle_distance(-315, -135,  true,  180, stats);  test_angle_distance(-315, -135, false, -180, stats);
//    test_angle_distance(-315, -136,  true,  179, stats);  test_angle_distance(-315, -136, false, -181, stats);
//
//    test_angle_distance(-360, -179,  true,  181, stats);  test_angle_distance(-360, -179, false, -179, stats);
//    test_angle_distance(-360, -180,  true,  180, stats);  test_angle_distance(-360, -180, false, -180, stats);
//    test_angle_distance(-360, -181,  true,  179, stats);  test_angle_distance(-360, -181, false, -181, stats);

    test_angle_distance(-405, -224,  true, 181, stats);  test_angle_distance(-405, -224, false, -179, stats);
    test_angle_distance(-405, -225,  true, 180, stats);  test_angle_distance(-405, -225, false, -180, stats);
    test_angle_distance(-405, -226,  true, 179, stats);  test_angle_distance(-405, -226, false, -181, stats);

    test_angle_distance(-450, -269,  true, 181, stats);  test_angle_distance(-450, -269, false, -179, stats);
    test_angle_distance(-450, -270,  true, 180, stats);  test_angle_distance(-450, -270, false, -180, stats);
    test_angle_distance(-450, -271,  true, 179, stats);  test_angle_distance(-450, -271, false, -181, stats);

    test_angle_distance(-495, -314,  true, 181, stats);  test_angle_distance(-495, -314, false, -179, stats);
    test_angle_distance(-495, -315,  true, 180, stats);  test_angle_distance(-495, -315, false, -180, stats);
    test_angle_distance(-495, -316,  true, 179, stats);  test_angle_distance(-495, -316, false, -181, stats);

    test_angle_distance(-540, -359,  true, 181, stats);  test_angle_distance(-540, -359, false, -179, stats);
    test_angle_distance(-540, -360,  true, 180, stats);  test_angle_distance(-540, -360, false, -180, stats);
    test_angle_distance(-540, -361,  true, 179, stats);  test_angle_distance(-540, -361, false, -181, stats);

    // [-180..-1], [-180..0], [-180..1], 45 degrees shift to positive

// duplication
//    test_angle_distance(-135,   44,  true,  179, stats);  test_angle_distance(-135,   44, false, -181, stats);
//    test_angle_distance(-135,   45,  true,  180, stats);  test_angle_distance(-135,   45, false, -180, stats);
//    test_angle_distance(-135,   46,  true,  181, stats);  test_angle_distance(-135,   46, false, -179, stats);
//
//    test_angle_distance(- 90,   89,  true,  179, stats);  test_angle_distance(- 90,   89, false, -181, stats);
//    test_angle_distance(- 90,   90,  true,  180, stats);  test_angle_distance(- 90,   90, false, -180, stats);
//    test_angle_distance(- 90,   91,  true,  181, stats);  test_angle_distance(- 90,   91, false, -179, stats);
//
//    test_angle_distance(- 45,  134,  true,  179, stats);  test_angle_distance(- 45,  134, false, -181, stats);
//    test_angle_distance(- 45,  135,  true,  180, stats);  test_angle_distance(- 45,  135, false, -180, stats);
//    test_angle_distance(- 45,  136,  true,  181, stats);  test_angle_distance(- 45,  136, false, -179, stats);
//
//    test_angle_distance(   0,  179,  true,  179, stats);  test_angle_distance(   0,  179, false, -181, stats);
//    test_angle_distance(   0,  180,  true,  180, stats);  test_angle_distance(   0,  180, false, -180, stats);
//    test_angle_distance(   0,  181,  true,  181, stats);  test_angle_distance(   0,  181, false, -179, stats);
//
//    test_angle_distance(  45,  224,  true,  179, stats);  test_angle_distance(  45,  224, false, -181, stats);
//    test_angle_distance(  45,  225,  true,  180, stats);  test_angle_distance(  45,  225, false, -180, stats);
//    test_angle_distance(  45,  226,  true,  181, stats);  test_angle_distance(  45,  226, false, -179, stats);
//
//    test_angle_distance(  90,  269,  true,  179, stats);  test_angle_distance(  90,  269, false, -181, stats);
//    test_angle_distance(  90,  270,  true,  180, stats);  test_angle_distance(  90,  270, false, -180, stats);
//    test_angle_distance(  90,  271,  true,  181, stats);  test_angle_distance(  90,  271, false, -179, stats);
//
//    test_angle_distance( 135,  314,  true,  179, stats);  test_angle_distance( 135,  314, false, -181, stats);
//    test_angle_distance( 135,  315,  true,  180, stats);  test_angle_distance( 135,  315, false, -180, stats);
//    test_angle_distance( 135,  316,  true,  181, stats);  test_angle_distance( 135,  316, false, -179, stats);
//
//    test_angle_distance( 180,  359,  true,  179, stats);  test_angle_distance( 180,  359, false, -181, stats);
//    test_angle_distance( 180,  360,  true,  180, stats);  test_angle_distance( 180,  360, false, -180, stats);
//    test_angle_distance( 180,  361,  true,  181, stats);  test_angle_distance( 180,  361, false, -179, stats);
}

//// math::translate_angle

void test_translate_angle(double angle_deg, double base_angle_deg, double etha_angle_deg)
{
    const double translated_angle_deg = math::translate_angle<double>(angle_deg, base_angle_deg, -180, +180, false, 0);
    ASSERT_EQ(translated_angle_deg, etha_angle_deg);
}

TEST(FunctionsTest, translate_angle)
{
    // special cases
    test_translate_angle( 0.0,  0.0, 0);
    test_translate_angle( 0.0, -0.0, 0);
    test_translate_angle(-0.0,  0.0, 0);
    test_translate_angle(-0.0, -0.0, 0);

    // [-630]
    test_translate_angle(-1035, -630, - 45);
    test_translate_angle(- 990, -630,    0);
    test_translate_angle(- 945, -630,   45);
    test_translate_angle(- 900, -630,   90);
    test_translate_angle(- 855, -630,  135);
    test_translate_angle(- 811, -630,  179);
    test_translate_angle(- 810, -630, -180);
    test_translate_angle(- 765, -630, -135);
    test_translate_angle(- 720, -630, - 90);
    test_translate_angle(- 675, -630, - 45);
    test_translate_angle(- 630, -630,    0);
    test_translate_angle(- 585, -630,   45);
    test_translate_angle(- 540, -630,   90);
    test_translate_angle(- 495, -630,  135);
    test_translate_angle(- 450, -630,  180);
    test_translate_angle(- 449, -630, -179);
    test_translate_angle(- 405, -630, -135);
    test_translate_angle(- 360, -630, - 90);
    test_translate_angle(- 315, -630, - 45);
    test_translate_angle(- 270, -630,    0);
    test_translate_angle(- 225, -630,   45);

    // [-585]
    test_translate_angle(- 990, -585, - 45);
    test_translate_angle(- 945, -585,    0);
    test_translate_angle(- 900, -585,   45);
    test_translate_angle(- 855, -585,   90);
    test_translate_angle(- 810, -585,  135);
    test_translate_angle(- 766, -585,  179);
    test_translate_angle(- 765, -585, -180);
    test_translate_angle(- 720, -585, -135);
    test_translate_angle(- 675, -585, - 90);
    test_translate_angle(- 630, -585, - 45);
    test_translate_angle(- 585, -585,    0);
    test_translate_angle(- 540, -585,   45);
    test_translate_angle(- 495, -585,   90);
    test_translate_angle(- 450, -585,  135);
    test_translate_angle(- 405, -585,  180);
    test_translate_angle(- 404, -585, -179);
    test_translate_angle(- 360, -585, -135);
    test_translate_angle(- 315, -585, - 90);
    test_translate_angle(- 270, -585, - 45);
    test_translate_angle(- 225, -585,    0);
    test_translate_angle(- 180, -585,   45);

    // [-540]
    test_translate_angle(- 945, -540, - 45);
    test_translate_angle(- 900, -540,    0);
    test_translate_angle(- 855, -540,   45);
    test_translate_angle(- 810, -540,   90);
    test_translate_angle(- 765, -540,  135);
    test_translate_angle(- 721, -540,  179);
    test_translate_angle(- 720, -540, -180);
    test_translate_angle(- 675, -540, -135);
    test_translate_angle(- 630, -540, - 90);
    test_translate_angle(- 585, -540, - 45);
    test_translate_angle(- 540, -540,    0);
    test_translate_angle(- 495, -540,   45);
    test_translate_angle(- 450, -540,   90);
    test_translate_angle(- 405, -540,  135);
    test_translate_angle(- 360, -540,  180);
    test_translate_angle(- 359, -540, -179);
    test_translate_angle(- 315, -540, -135);
    test_translate_angle(- 270, -540, - 90);
    test_translate_angle(- 225, -540, - 45);
    test_translate_angle(- 180, -540,    0);
    test_translate_angle(- 135, -540,   45);

    // [-495]
    test_translate_angle(- 900, -495, - 45);
    test_translate_angle(- 855, -495,    0);
    test_translate_angle(- 810, -495,   45);
    test_translate_angle(- 765, -495,   90);
    test_translate_angle(- 720, -495,  135);
    test_translate_angle(- 676, -495,  179);
    test_translate_angle(- 675, -495, -180);
    test_translate_angle(- 630, -495, -135);
    test_translate_angle(- 585, -495, - 90);
    test_translate_angle(- 540, -495, - 45);
    test_translate_angle(- 495, -495,    0);
    test_translate_angle(- 450, -495,   45);
    test_translate_angle(- 405, -495,   90);
    test_translate_angle(- 360, -495,  135);
    test_translate_angle(- 315, -495,  180);
    test_translate_angle(- 314, -495, -179);
    test_translate_angle(- 270, -495, -135);
    test_translate_angle(- 225, -495, - 90);
    test_translate_angle(- 180, -495, - 45);
    test_translate_angle(- 135, -495,    0);
    test_translate_angle(-  90, -495,   45);

    // [-450]
    test_translate_angle(- 855, -450, - 45);
    test_translate_angle(- 810, -450,    0);
    test_translate_angle(- 765, -450,   45);
    test_translate_angle(- 720, -450,   90);
    test_translate_angle(- 675, -450,  135);
    test_translate_angle(- 631, -450,  179);
    test_translate_angle(- 630, -450, -180);
    test_translate_angle(- 585, -450, -135);
    test_translate_angle(- 540, -450, - 90);
    test_translate_angle(- 495, -450, - 45);
    test_translate_angle(- 450, -450,    0);
    test_translate_angle(- 405, -450,   45);
    test_translate_angle(- 360, -450,   90);
    test_translate_angle(- 315, -450,  135);
    test_translate_angle(- 270, -450,  180);
    test_translate_angle(- 269, -450, -179);
    test_translate_angle(- 225, -450, -135);
    test_translate_angle(- 180, -450, - 90);
    test_translate_angle(- 135, -450, - 45);
    test_translate_angle(-  90, -450,    0);
    test_translate_angle(-  45, -450,   45);

    // [-405]
    test_translate_angle(- 810, -405, - 45);
    test_translate_angle(- 765, -405,    0);
    test_translate_angle(- 720, -405,   45);
    test_translate_angle(- 675, -405,   90);
    test_translate_angle(- 630, -405,  135);
    test_translate_angle(- 586, -405,  179);
    test_translate_angle(- 585, -405, -180);
    test_translate_angle(- 540, -405, -135);
    test_translate_angle(- 495, -405, - 90);
    test_translate_angle(- 450, -405, - 45);
    test_translate_angle(- 405, -405,    0);
    test_translate_angle(- 360, -405,   45);
    test_translate_angle(- 315, -405,   90);
    test_translate_angle(- 270, -405,  135);
    test_translate_angle(- 225, -405,  180);
    test_translate_angle(- 224, -405, -179);
    test_translate_angle(- 180, -405, -135);
    test_translate_angle(- 135, -405, - 90);
    test_translate_angle(-  90, -405, - 45);
    test_translate_angle(-  45, -405,    0);
    test_translate_angle(    0, -405,   45);

    // [-360]
    test_translate_angle(- 765, -360, - 45);
    test_translate_angle(- 720, -360,    0);
    test_translate_angle(- 675, -360,   45);
    test_translate_angle(- 630, -360,   90);
    test_translate_angle(- 585, -360,  135);
    test_translate_angle(- 541, -360,  179);
    test_translate_angle(- 540, -360, -180);
    test_translate_angle(- 495, -360, -135);
    test_translate_angle(- 450, -360, - 90);
    test_translate_angle(- 405, -360, - 45);
    test_translate_angle(- 360, -360,    0);
    test_translate_angle(- 315, -360,   45);
    test_translate_angle(- 270, -360,   90);
    test_translate_angle(- 225, -360,  135);
    test_translate_angle(- 180, -360,  180);
    test_translate_angle(- 179, -360, -179);
    test_translate_angle(- 135, -360, -135);
    test_translate_angle(-  90, -360, - 90);
    test_translate_angle(-  45, -360, - 45);
    test_translate_angle(    0, -360,    0);
    test_translate_angle(   45, -360,   45);

    // [-315]
    test_translate_angle(- 720, -315, - 45);
    test_translate_angle(- 675, -315,    0);
    test_translate_angle(- 630, -315,   45);
    test_translate_angle(- 585, -315,   90);
    test_translate_angle(- 540, -315,  135);
    test_translate_angle(- 496, -315,  179);
    test_translate_angle(- 495, -315, -180);
    test_translate_angle(- 450, -315, -135);
    test_translate_angle(- 405, -315, - 90);
    test_translate_angle(- 360, -315, - 45);
    test_translate_angle(- 315, -315,    0);
    test_translate_angle(- 270, -315,   45);
    test_translate_angle(- 225, -315,   90);
    test_translate_angle(- 180, -315,  135);
    test_translate_angle(- 135, -315,  180);
    test_translate_angle(- 134, -315, -179);
    test_translate_angle(-  90, -315, -135);
    test_translate_angle(-  45, -315, - 90);
    test_translate_angle(    0, -315, - 45);
    test_translate_angle(   45, -315,    0);
    test_translate_angle(   90, -315,   45);

    // [-270]
    test_translate_angle(- 675, -270, - 45);
    test_translate_angle(- 630, -270,    0);
    test_translate_angle(- 585, -270,   45);
    test_translate_angle(- 540, -270,   90);
    test_translate_angle(- 495, -270,  135);
    test_translate_angle(- 451, -270,  179);
    test_translate_angle(- 450, -270, -180);
    test_translate_angle(- 405, -270, -135);
    test_translate_angle(- 360, -270, - 90);
    test_translate_angle(- 315, -270, - 45);
    test_translate_angle(- 270, -270,    0);
    test_translate_angle(- 225, -270,   45);
    test_translate_angle(- 180, -270,   90);
    test_translate_angle(- 135, -270,  135);
    test_translate_angle(-  90, -270,  180);
    test_translate_angle(-  89, -270, -179);
    test_translate_angle(-  45, -270, -135);
    test_translate_angle(    0, -270, - 90);
    test_translate_angle(   45, -270, - 45);
    test_translate_angle(   90, -270,    0);
    test_translate_angle(  135, -270,   45);

    // [-225]
    test_translate_angle(- 630, -225, - 45);
    test_translate_angle(- 585, -225,    0);
    test_translate_angle(- 540, -225,   45);
    test_translate_angle(- 495, -225,   90);
    test_translate_angle(- 450, -225,  135);
    test_translate_angle(- 406, -225,  179);
    test_translate_angle(- 405, -225, -180);
    test_translate_angle(- 360, -225, -135);
    test_translate_angle(- 315, -225, - 90);
    test_translate_angle(- 270, -225, - 45);
    test_translate_angle(- 225, -225,    0);
    test_translate_angle(- 180, -225,   45);
    test_translate_angle(- 135, -225,   90);
    test_translate_angle(-  90, -225,  135);
    test_translate_angle(-  45, -225,  180);
    test_translate_angle(-  44, -225, -179);
    test_translate_angle(    0, -225, -135);
    test_translate_angle(   45, -225, - 90);
    test_translate_angle(   90, -225, - 45);
    test_translate_angle(  135, -225,    0);
    test_translate_angle(  180, -225,   45);

    // [-180]
    test_translate_angle(- 585, -180, - 45);
    test_translate_angle(- 540, -180,    0);
    test_translate_angle(- 495, -180,   45);
    test_translate_angle(- 450, -180,   90);
    test_translate_angle(- 405, -180,  135);
    test_translate_angle(- 361, -180,  179);
    test_translate_angle(- 360, -180, -180);
    test_translate_angle(- 315, -180, -135);
    test_translate_angle(- 270, -180, - 90);
    test_translate_angle(- 225, -180, - 45);
    test_translate_angle(- 180, -180,    0);
    test_translate_angle(- 135, -180,   45);
    test_translate_angle(-  90, -180,   90);
    test_translate_angle(-  45, -180,  135);
    test_translate_angle(    0, -180,  180);
    test_translate_angle(    1, -180, -179);
    test_translate_angle(   45, -180, -135);
    test_translate_angle(   90, -180, - 90);
    test_translate_angle(  135, -180, - 45);
    test_translate_angle(  180, -180,    0);
    test_translate_angle(  225, -180,   45);

    // [-135]
    test_translate_angle(- 540, -135, - 45);
    test_translate_angle(- 495, -135,    0);
    test_translate_angle(- 450, -135,   45);
    test_translate_angle(- 405, -135,   90);
    test_translate_angle(- 360, -135,  135);
    test_translate_angle(- 316, -135,  179);
    test_translate_angle(- 315, -135, -180);
    test_translate_angle(- 270, -135, -135);
    test_translate_angle(- 225, -135, - 90);
    test_translate_angle(- 180, -135, - 45);
    test_translate_angle(- 135, -135,    0);
    test_translate_angle(-  90, -135,   45);
    test_translate_angle(-  45, -135,   90);
    test_translate_angle(    0, -135,  135);
    test_translate_angle(   45, -135,  180);
    test_translate_angle(   46, -135, -179);
    test_translate_angle(   90, -135, -135);
    test_translate_angle(  135, -135, - 90);
    test_translate_angle(  180, -135, - 45);
    test_translate_angle(  225, -135,    0);
    test_translate_angle(  270, -135,   45);

    // [-90]
    test_translate_angle(- 495, - 90, - 45);
    test_translate_angle(- 450, - 90,    0);
    test_translate_angle(- 405, - 90,   45);
    test_translate_angle(- 360, - 90,   90);
    test_translate_angle(- 315, - 90,  135);
    test_translate_angle(- 271, - 90,  179);
    test_translate_angle(- 270, - 90, -180);
    test_translate_angle(- 225, - 90, -135);
    test_translate_angle(- 180, - 90, - 90);
    test_translate_angle(- 135, - 90, - 45);
    test_translate_angle(-  90, - 90,    0);
    test_translate_angle(-  45, - 90,   45);
    test_translate_angle(    0, - 90,   90);
    test_translate_angle(   45, - 90,  135);
    test_translate_angle(   90, - 90,  180);
    test_translate_angle(   91, - 90, -179);
    test_translate_angle(  135, - 90, -135);
    test_translate_angle(  180, - 90, - 90);
    test_translate_angle(  225, - 90, - 45);
    test_translate_angle(  270, - 90,    0);
    test_translate_angle(  315, - 90,   45);

    // [-45]
    test_translate_angle(- 450, - 45, - 45);
    test_translate_angle(- 405, - 45,    0);
    test_translate_angle(- 360, - 45,   45);
    test_translate_angle(- 315, - 45,   90);
    test_translate_angle(- 270, - 45,  135);
    test_translate_angle(- 226, - 45,  179);
    test_translate_angle(- 225, - 45, -180);
    test_translate_angle(- 180, - 45, -135);
    test_translate_angle(- 135, - 45, - 90);
    test_translate_angle(-  90, - 45, - 45);
    test_translate_angle(-  45, - 45,    0);
    test_translate_angle(    0, - 45,   45);
    test_translate_angle(   45, - 45,   90);
    test_translate_angle(   90, - 45,  135);
    test_translate_angle(  135, - 45,  180);
    test_translate_angle(  136, - 45, -179);
    test_translate_angle(  180, - 45, -135);
    test_translate_angle(  225, - 45, - 90);
    test_translate_angle(  270, - 45, - 45);
    test_translate_angle(  315, - 45,    0);
    test_translate_angle(  360, - 45,   45);

    // [0]
    test_translate_angle(- 405,    0, - 45);
    test_translate_angle(- 360,    0,    0);
    test_translate_angle(- 315,    0,   45);
    test_translate_angle(- 270,    0,   90);
    test_translate_angle(- 225,    0,  135);
    test_translate_angle(- 181,    0,  179);
    test_translate_angle(- 180,    0, -180);
    test_translate_angle(- 135,    0, -135);
    test_translate_angle(-  90,    0, - 90);
    test_translate_angle(-  45,    0, - 45);
    test_translate_angle(    0,    0,    0);
    test_translate_angle(   45,    0,   45);
    test_translate_angle(   90,    0,   90);
    test_translate_angle(  135,    0,  135);
    test_translate_angle(  180,    0,  180);
    test_translate_angle(  181,    0, -179);
    test_translate_angle(  225,    0, -135);
    test_translate_angle(  270,    0, - 90);
    test_translate_angle(  315,    0, - 45);
    test_translate_angle(  360,    0,    0);
    test_translate_angle(  405,    0,   45);

    // [45]
    test_translate_angle(- 360,   45, - 45);
    test_translate_angle(- 315,   45,    0);
    test_translate_angle(- 270,   45,   45);
    test_translate_angle(- 225,   45,   90);
    test_translate_angle(- 180,   45,  135);
    test_translate_angle(- 136,   45,  179);
    test_translate_angle(- 135,   45, -180);
    test_translate_angle(-  90,   45, -135);
    test_translate_angle(-  45,   45, - 90);
    test_translate_angle(    0,   45, - 45);
    test_translate_angle(   45,   45,    0);
    test_translate_angle(   90,   45,   45);
    test_translate_angle(  135,   45,   90);
    test_translate_angle(  180,   45,  135);
    test_translate_angle(  225,   45,  180);
    test_translate_angle(  226,   45, -179);
    test_translate_angle(  270,   45, -135);
    test_translate_angle(  315,   45, - 90);
    test_translate_angle(  360,   45, - 45);
    test_translate_angle(  405,   45,    0);
    test_translate_angle(  450,   45,   45);

    // [90]
    test_translate_angle(- 315,   90, - 45);
    test_translate_angle(- 270,   90,    0);
    test_translate_angle(- 225,   90,   45);
    test_translate_angle(- 180,   90,   90);
    test_translate_angle(- 135,   90,  135);
    test_translate_angle(-  91,   90,  179);
    test_translate_angle(-  90,   90, -180);
    test_translate_angle(-  45,   90, -135);
    test_translate_angle(    0,   90, - 90);
    test_translate_angle(   45,   90, - 45);
    test_translate_angle(   90,   90,    0);
    test_translate_angle(  135,   90,   45);
    test_translate_angle(  180,   90,   90);
    test_translate_angle(  225,   90,  135);
    test_translate_angle(  270,   90,  180);
    test_translate_angle(  271,   90, -179);
    test_translate_angle(  315,   90, -135);
    test_translate_angle(  360,   90, - 90);
    test_translate_angle(  405,   90, - 45);
    test_translate_angle(  450,   90,    0);
    test_translate_angle(  495,   90,   45);

    // [135]
    test_translate_angle(- 270,  135, - 45);
    test_translate_angle(- 225,  135,    0);
    test_translate_angle(- 180,  135,   45);
    test_translate_angle(- 135,  135,   90);
    test_translate_angle(-  90,  135,  135);
    test_translate_angle(-  46,  135,  179);
    test_translate_angle(-  45,  135, -180);
    test_translate_angle(    0,  135, -135);
    test_translate_angle(   45,  135, - 90);
    test_translate_angle(   90,  135, - 45);
    test_translate_angle(  135,  135,    0);
    test_translate_angle(  180,  135,   45);
    test_translate_angle(  225,  135,   90);
    test_translate_angle(  270,  135,  135);
    test_translate_angle(  315,  135,  180);
    test_translate_angle(  316,  135, -179);
    test_translate_angle(  360,  135, -135);
    test_translate_angle(  405,  135, - 90);
    test_translate_angle(  450,  135, - 45);
    test_translate_angle(  495,  135,    0);
    test_translate_angle(  540,  135,   45);

    // [180]
    test_translate_angle(- 225,  180, - 45);
    test_translate_angle(- 180,  180,    0);
    test_translate_angle(- 135,  180,   45);
    test_translate_angle(-  90,  180,   90);
    test_translate_angle(-  45,  180,  135);
    test_translate_angle(-   1,  180,  179);
    test_translate_angle(    0,  180, -180);
    test_translate_angle(   45,  180, -135);
    test_translate_angle(   90,  180, - 90);
    test_translate_angle(  135,  180, - 45);
    test_translate_angle(  180,  180,    0);
    test_translate_angle(  225,  180,   45);
    test_translate_angle(  270,  180,   90);
    test_translate_angle(  315,  180,  135);
    test_translate_angle(  360,  180,  180);
    test_translate_angle(  361,  180, -179);
    test_translate_angle(  405,  180, -135);
    test_translate_angle(  450,  180, - 90);
    test_translate_angle(  495,  180, - 45);
    test_translate_angle(  540,  180,    0);
    test_translate_angle(  585,  180,   45);

    // [225]
    test_translate_angle(- 180,  225, - 45);
    test_translate_angle(- 135,  225,    0);
    test_translate_angle(-  90,  225,   45);
    test_translate_angle(-  45,  225,   90);
    test_translate_angle(    0,  225,  135);
    test_translate_angle(   44,  225,  179);
    test_translate_angle(   45,  225, -180);
    test_translate_angle(   90,  225, -135);
    test_translate_angle(  135,  225, - 90);
    test_translate_angle(  180,  225, - 45);
    test_translate_angle(  225,  225,    0);
    test_translate_angle(  270,  225,   45);
    test_translate_angle(  315,  225,   90);
    test_translate_angle(  360,  225,  135);
    test_translate_angle(  405,  225,  180);
    test_translate_angle(  406,  225, -179);
    test_translate_angle(  450,  225, -135);
    test_translate_angle(  495,  225, - 90);
    test_translate_angle(  540,  225, - 45);
    test_translate_angle(  585,  225,    0);
    test_translate_angle(  630,  225,   45);

    // [270]
    test_translate_angle(- 135,  270, - 45);
    test_translate_angle(-  90,  270,    0);
    test_translate_angle(-  45,  270,   45);
    test_translate_angle(    0,  270,   90);
    test_translate_angle(   45,  270,  135);
    test_translate_angle(   89,  270,  179);
    test_translate_angle(   90,  270, -180);
    test_translate_angle(  135,  270, -135);
    test_translate_angle(  180,  270, - 90);
    test_translate_angle(  225,  270, - 45);
    test_translate_angle(  270,  270,    0);
    test_translate_angle(  315,  270,   45);
    test_translate_angle(  360,  270,   90);
    test_translate_angle(  405,  270,  135);
    test_translate_angle(  450,  270,  180);
    test_translate_angle(  451,  270, -179);
    test_translate_angle(  495,  270, -135);
    test_translate_angle(  540,  270, - 90);
    test_translate_angle(  585,  270, - 45);
    test_translate_angle(  630,  270,    0);
    test_translate_angle(  675,  270,   45);

    // [315]
    test_translate_angle(-  90,  315, - 45);
    test_translate_angle(-  45,  315,    0);
    test_translate_angle(    0,  315,   45);
    test_translate_angle(   45,  315,   90);
    test_translate_angle(   90,  315,  135);
    test_translate_angle(  134,  315,  179);
    test_translate_angle(  135,  315, -180);
    test_translate_angle(  180,  315, -135);
    test_translate_angle(  225,  315, - 90);
    test_translate_angle(  270,  315, - 45);
    test_translate_angle(  315,  315,    0);
    test_translate_angle(  360,  315,   45);
    test_translate_angle(  405,  315,   90);
    test_translate_angle(  450,  315,  135);
    test_translate_angle(  495,  315,  180);
    test_translate_angle(  496,  315, -179);
    test_translate_angle(  540,  315, -135);
    test_translate_angle(  585,  315, - 90);
    test_translate_angle(  630,  315, - 45);
    test_translate_angle(  675,  315,    0);
    test_translate_angle(  720,  315,   45);

    // [360]
    test_translate_angle(-  45,  360, - 45);
    test_translate_angle(    0,  360,    0);
    test_translate_angle(   45,  360,   45);
    test_translate_angle(   90,  360,   90);
    test_translate_angle(  135,  360,  135);
    test_translate_angle(  179,  360,  179);
    test_translate_angle(  180,  360, -180);
    test_translate_angle(  225,  360, -135);
    test_translate_angle(  270,  360, - 90);
    test_translate_angle(  315,  360, - 45);
    test_translate_angle(  360,  360,    0);
    test_translate_angle(  405,  360,   45);
    test_translate_angle(  450,  360,   90);
    test_translate_angle(  495,  360,  135);
    test_translate_angle(  540,  360,  180);
    test_translate_angle(  541,  360, -179);
    test_translate_angle(  585,  360, -135);
    test_translate_angle(  630,  360, - 90);
    test_translate_angle(  675,  360, - 45);
    test_translate_angle(  720,  360,    0);
    test_translate_angle(  765,  360,   45);

    // [405]
    test_translate_angle(    0,  405, - 45);
    test_translate_angle(   45,  405,    0);
    test_translate_angle(   90,  405,   45);
    test_translate_angle(  135,  405,   90);
    test_translate_angle(  180,  405,  135);
    test_translate_angle(  224,  405,  179);
    test_translate_angle(  225,  405, -180);
    test_translate_angle(  270,  405, -135);
    test_translate_angle(  315,  405, - 90);
    test_translate_angle(  360,  405, - 45);
    test_translate_angle(  405,  405,    0);
    test_translate_angle(  450,  405,   45);
    test_translate_angle(  495,  405,   90);
    test_translate_angle(  540,  405,  135);
    test_translate_angle(  585,  405,  180);
    test_translate_angle(  586,  405, -179);
    test_translate_angle(  630,  405, -135);
    test_translate_angle(  675,  405, - 90);
    test_translate_angle(  720,  405, - 45);
    test_translate_angle(  765,  405,    0);
    test_translate_angle(  810,  405,   45);

    // [450]
    test_translate_angle(   45,  450, - 45);
    test_translate_angle(   90,  450,    0);
    test_translate_angle(  135,  450,   45);
    test_translate_angle(  180,  450,   90);
    test_translate_angle(  225,  450,  135);
    test_translate_angle(  269,  450,  179);
    test_translate_angle(  270,  450, -180);
    test_translate_angle(  315,  450, -135);
    test_translate_angle(  360,  450, - 90);
    test_translate_angle(  405,  450, - 45);
    test_translate_angle(  450,  450,    0);
    test_translate_angle(  495,  450,   45);
    test_translate_angle(  540,  450,   90);
    test_translate_angle(  585,  450,  135);
    test_translate_angle(  630,  450,  180);
    test_translate_angle(  631,  450, -179);
    test_translate_angle(  675,  450, -135);
    test_translate_angle(  720,  450, - 90);
    test_translate_angle(  765,  450, - 45);
    test_translate_angle(  810,  450,    0);
    test_translate_angle(  855,  450,   45);

    // [495]
    test_translate_angle(   90,  495, - 45);
    test_translate_angle(  135,  495,    0);
    test_translate_angle(  180,  495,   45);
    test_translate_angle(  225,  495,   90);
    test_translate_angle(  270,  495,  135);
    test_translate_angle(  314,  495,  179);
    test_translate_angle(  315,  495, -180);
    test_translate_angle(  360,  495, -135);
    test_translate_angle(  405,  495, - 90);
    test_translate_angle(  450,  495, - 45);
    test_translate_angle(  495,  495,    0);
    test_translate_angle(  540,  495,   45);
    test_translate_angle(  585,  495,   90);
    test_translate_angle(  630,  495,  135);
    test_translate_angle(  675,  495,  180);
    test_translate_angle(  676,  495, -179);
    test_translate_angle(  720,  495, -135);
    test_translate_angle(  765,  495, - 90);
    test_translate_angle(  810,  495, - 45);
    test_translate_angle(  855,  495,    0);
    test_translate_angle(  900,  495,   45);

    // [540]
    test_translate_angle(  135,  540, - 45);
    test_translate_angle(  180,  540,    0);
    test_translate_angle(  225,  540,   45);
    test_translate_angle(  270,  540,   90);
    test_translate_angle(  315,  540,  135);
    test_translate_angle(  359,  540,  179);
    test_translate_angle(  360,  540, -180);
    test_translate_angle(  405,  540, -135);
    test_translate_angle(  450,  540, - 90);
    test_translate_angle(  495,  540, - 45);
    test_translate_angle(  540,  540,    0);
    test_translate_angle(  585,  540,   45);
    test_translate_angle(  630,  540,   90);
    test_translate_angle(  675,  540,  135);
    test_translate_angle(  720,  540,  180);
    test_translate_angle(  721,  540, -179);
    test_translate_angle(  765,  540, -135);
    test_translate_angle(  810,  540, - 90);
    test_translate_angle(  855,  540, - 45);
    test_translate_angle(  900,  540,    0);
    test_translate_angle(  945,  540,   45);

    // [585]
    test_translate_angle(  180,  585, - 45);
    test_translate_angle(  225,  585,    0);
    test_translate_angle(  270,  585,   45);
    test_translate_angle(  315,  585,   90);
    test_translate_angle(  360,  585,  135);
    test_translate_angle(  404,  585,  179);
    test_translate_angle(  405,  585, -180);
    test_translate_angle(  450,  585, -135);
    test_translate_angle(  495,  585, - 90);
    test_translate_angle(  540,  585, - 45);
    test_translate_angle(  585,  585,    0);
    test_translate_angle(  630,  585,   45);
    test_translate_angle(  675,  585,   90);
    test_translate_angle(  720,  585,  135);
    test_translate_angle(  765,  585,  180);
    test_translate_angle(  766,  585, -179);
    test_translate_angle(  810,  585, -135);
    test_translate_angle(  855,  585, - 90);
    test_translate_angle(  900,  585, - 45);
    test_translate_angle(  945,  585,    0);
    test_translate_angle(  990,  585,   45);

    // [630]
    test_translate_angle(  225,  630, - 45);
    test_translate_angle(  270,  630,    0);
    test_translate_angle(  315,  630,   45);
    test_translate_angle(  360,  630,   90);
    test_translate_angle(  405,  630,  135);
    test_translate_angle(  449,  630,  179);
    test_translate_angle(  450,  630, -180);
    test_translate_angle(  495,  630, -135);
    test_translate_angle(  540,  630, - 90);
    test_translate_angle(  585,  630, - 45);
    test_translate_angle(  630,  630,    0);
    test_translate_angle(  675,  630,   45);
    test_translate_angle(  720,  630,   90);
    test_translate_angle(  765,  630,  135);
    test_translate_angle(  810,  630,  180);
    test_translate_angle(  811,  630, -179);
    test_translate_angle(  855,  630, -135);
    test_translate_angle(  900,  630, - 90);
    test_translate_angle(  945,  630, - 45);
    test_translate_angle(  990,  630,    0);
    test_translate_angle( 1035,  630,   45);
}

//// math::normalize_angle_to_range

void test_normalize_angle_to_range(double start_angle_deg, double end_angle_deg, double angle_deg, double eta_angle_deg)
{
    const double angle_distance = math::angle_closest_distance(start_angle_deg, end_angle_deg, false, true);

    const double mid_angle_deg = start_angle_deg + angle_distance / 2;

    const double angle_norm = math::normalize_angle_to_range(start_angle_deg, mid_angle_deg, angle_distance, angle_deg, false);

    ASSERT_EQ(angle_norm, eta_angle_deg);
}

TEST(FunctionsTest, normalize_angle_to_range)
{
    // special cases
    test_normalize_angle_to_range( 0.0,  0.0,    0,    0);
    test_normalize_angle_to_range( 0.0, -0.0,    0,    0);
    test_normalize_angle_to_range(-0.0,  0.0,    0,    0);
    test_normalize_angle_to_range(-0.0, -0.0,    0,    0);

    // [0..90] -> distance=+90
    test_normalize_angle_to_range(   0,   90, -495,  225);

    test_normalize_angle_to_range(   0,   90, -494, -134);
    test_normalize_angle_to_range(   0,   90, -450, - 90);
    test_normalize_angle_to_range(   0,   90, -360,    0);
    test_normalize_angle_to_range(   0,   90, -315,   45);
    test_normalize_angle_to_range(   0,   90, -270,   90);
    test_normalize_angle_to_range(   0,   90, -180,  180);
    test_normalize_angle_to_range(   0,   90, -135,  225);

    test_normalize_angle_to_range(   0,   90, -134, -134);
    test_normalize_angle_to_range(   0,   90, - 90, - 90);
    test_normalize_angle_to_range(   0,   90,    0,    0);
    test_normalize_angle_to_range(   0,   90,   45,   45);
    test_normalize_angle_to_range(   0,   90,   90,   90);
    test_normalize_angle_to_range(   0,   90,  180,  180);
    test_normalize_angle_to_range(   0,   90,  225,  225);

    test_normalize_angle_to_range(   0,   90,  226, -134);
    test_normalize_angle_to_range(   0,   90,  270, - 90);
    test_normalize_angle_to_range(   0,   90,  360,    0);
    test_normalize_angle_to_range(   0,   90,  405,   45);
    test_normalize_angle_to_range(   0,   90,  450,   90);
    test_normalize_angle_to_range(   0,   90,  540,  180);
    test_normalize_angle_to_range(   0,   90,  585,  225);

    test_normalize_angle_to_range(   0,   90,  586, -134);

    // [0..180] -> distance=+180
    test_normalize_angle_to_range(   0,  180, -450,  270);

    test_normalize_angle_to_range(   0,  180, -449, - 89);
    test_normalize_angle_to_range(   0,  180, -360,    0);
    test_normalize_angle_to_range(   0,  180, -270,   90);
    test_normalize_angle_to_range(   0,  180, -180,  180);
    test_normalize_angle_to_range(   0,  180, - 90,  270);

    test_normalize_angle_to_range(   0,  180, - 89, - 89);
    test_normalize_angle_to_range(   0,  180,    0,    0);
    test_normalize_angle_to_range(   0,  180,   90,   90);
    test_normalize_angle_to_range(   0,  180,  180,  180);
    test_normalize_angle_to_range(   0,  180,  270,  270);

    test_normalize_angle_to_range(   0,  180,  271, - 89);
    test_normalize_angle_to_range(   0,  180,  360,    0);
    test_normalize_angle_to_range(   0,  180,  450,   90);
    test_normalize_angle_to_range(   0,  180,  540,  180);
    test_normalize_angle_to_range(   0,  180,  630,  270);

    test_normalize_angle_to_range(   0,  180,  631, - 89);

    // [90..180] -> distance=+90
    test_normalize_angle_to_range(  90,  180, -405,  315);

    test_normalize_angle_to_range(  90,  180, -404, - 44);
    test_normalize_angle_to_range(  90,  180, -360,    0);
    test_normalize_angle_to_range(  90,  180, -270,   90);
    test_normalize_angle_to_range(  90,  180, -180,  180);
    test_normalize_angle_to_range(  90,  180, - 90,  270);
    test_normalize_angle_to_range(  90,  180, - 45,  315);

    test_normalize_angle_to_range(  90,  180, - 44, - 44);
    test_normalize_angle_to_range(  90,  180,    0,    0);
    test_normalize_angle_to_range(  90,  180,   90,   90);
    test_normalize_angle_to_range(  90,  180,  180,  180);
    test_normalize_angle_to_range(  90,  180,  270,  270);
    test_normalize_angle_to_range(  90,  180,  315,  315);

    test_normalize_angle_to_range(  90,  180,  316, - 44);
    test_normalize_angle_to_range(  90,  180,  360,    0);
    test_normalize_angle_to_range(  90,  180,  450,   90);
    test_normalize_angle_to_range(  90,  180,  540,  180);
    test_normalize_angle_to_range(  90,  180,  630,  270);
    test_normalize_angle_to_range(  90,  180,  675,  315);

    test_normalize_angle_to_range(  90,  180,  676, - 44);

    // [90..270] -> distance=-180 -> [90..-90]
    test_normalize_angle_to_range(  90,  270,  541, -179);

    test_normalize_angle_to_range(  90,  270,  540,  180);
    test_normalize_angle_to_range(  90,  270,  450,   90);
    test_normalize_angle_to_range(  90,  270,  360,    0);
    test_normalize_angle_to_range(  90,  270,  270, - 90);
    test_normalize_angle_to_range(  90,  270,  181, -179);

    test_normalize_angle_to_range(  90,  270,  180,  180);
    test_normalize_angle_to_range(  90,  270,   90,   90);
    test_normalize_angle_to_range(  90,  270,    0,    0);
    test_normalize_angle_to_range(  90,  270, - 90, - 90);
    test_normalize_angle_to_range(  90,  270, -179, -179);

    test_normalize_angle_to_range(  90,  270, -180,  180);
    test_normalize_angle_to_range(  90,  270, -270,   90);
    test_normalize_angle_to_range(  90,  270, -360,    0);
    test_normalize_angle_to_range(  90,  270, -450,  -90);
    test_normalize_angle_to_range(  90,  270, -539, -179);

    test_normalize_angle_to_range(  90,  270, -540,  180);

    // [180..270] -> distance=+90
    test_normalize_angle_to_range( 180,  270, -315,  405);

    test_normalize_angle_to_range( 180,  270, -314,   46);
    test_normalize_angle_to_range( 180,  270, -270,   90);
    test_normalize_angle_to_range( 180,  270, -180,  180);
    test_normalize_angle_to_range( 180,  270, -135,  225);
    test_normalize_angle_to_range( 180,  270, - 90,  270);
    test_normalize_angle_to_range( 180,  270,    0,  360);
    test_normalize_angle_to_range( 180,  270,   45,  405);

    test_normalize_angle_to_range( 180,  270,   46,   46);
    test_normalize_angle_to_range( 180,  270,   90,   90);
    test_normalize_angle_to_range( 180,  270,  180,  180);
    test_normalize_angle_to_range( 180,  270,  225,  225);
    test_normalize_angle_to_range( 180,  270,  270,  270);
    test_normalize_angle_to_range( 180,  270,  360,  360);
    test_normalize_angle_to_range( 180,  270,  405,  405);

    test_normalize_angle_to_range( 180,  270,  406,   46);
    test_normalize_angle_to_range( 180,  270,  450,   90);
    test_normalize_angle_to_range( 180,  270,  540,  180);
    test_normalize_angle_to_range( 180,  270,  585,  225);
    test_normalize_angle_to_range( 180,  270,  630,  270);
    test_normalize_angle_to_range( 180,  270,  720,  360);
    test_normalize_angle_to_range( 180,  270,  765,  405);

    test_normalize_angle_to_range( 180,  270,  766,   46);

    // [180..360] -> distance=-180 -> [180..0]
    test_normalize_angle_to_range( 180,  360,  631, - 89);

    test_normalize_angle_to_range( 180,  360,  630,  270);
    test_normalize_angle_to_range( 180,  360,  540,  180);
    test_normalize_angle_to_range( 180,  360,  450,   90);
    test_normalize_angle_to_range( 180,  360,  360,    0);
    test_normalize_angle_to_range( 180,  360,  271, - 89);

    test_normalize_angle_to_range( 180,  360,  270,  270);
    test_normalize_angle_to_range( 180,  360,  180,  180);
    test_normalize_angle_to_range( 180,  360,   90,   90);
    test_normalize_angle_to_range( 180,  360,    0,    0);
    test_normalize_angle_to_range( 180,  360, - 89, - 89);

    test_normalize_angle_to_range( 180,  360, - 90,  270);
    test_normalize_angle_to_range( 180,  360, -180,  180);
    test_normalize_angle_to_range( 180,  360, -270,   90);
    test_normalize_angle_to_range( 180,  360, -360,    0);
    test_normalize_angle_to_range( 180,  360, -449, - 89);

    test_normalize_angle_to_range( 180,  360, -450,  270);

    // [270..360] -> distance=+90
    test_normalize_angle_to_range( 270,  360, -225,  495);

    test_normalize_angle_to_range( 270,  360, -224,  136);
    test_normalize_angle_to_range( 270,  360, -180,  180);
    test_normalize_angle_to_range( 270,  360, - 90,  270);
    test_normalize_angle_to_range( 270,  360, - 45,  315);
    test_normalize_angle_to_range( 270,  360,    0,  360);
    test_normalize_angle_to_range( 270,  360,   90,  450);
    test_normalize_angle_to_range( 270,  360,  135,  495);

    test_normalize_angle_to_range( 270,  360,  136,  136);
    test_normalize_angle_to_range( 270,  360,  180,  180);
    test_normalize_angle_to_range( 270,  360,  270,  270);
    test_normalize_angle_to_range( 270,  360,  315,  315);
    test_normalize_angle_to_range( 270,  360,  360,  360);
    test_normalize_angle_to_range( 270,  360,  450,  450);
    test_normalize_angle_to_range( 270,  360,  495,  495);

    test_normalize_angle_to_range( 270,  360,  496,  136);
    test_normalize_angle_to_range( 270,  360,  540,  180);
    test_normalize_angle_to_range( 270,  360,  630,  270);
    test_normalize_angle_to_range( 270,  360,  675,  315);
    test_normalize_angle_to_range( 270,  360,  720,  360);
    test_normalize_angle_to_range( 270,  360,  810,  450);
    test_normalize_angle_to_range( 270,  360,  855,  495);

    test_normalize_angle_to_range( 270,  360,  856,  136);

    // [270..450] -> distance=-180 -> [270..90]
    test_normalize_angle_to_range( 270,  450,  721,    1);

    test_normalize_angle_to_range( 270,  450,  720,  360);
    test_normalize_angle_to_range( 270,  450,  630,  270);
    test_normalize_angle_to_range( 270,  450,  540,  180);
    test_normalize_angle_to_range( 270,  450,  450,   90);
    test_normalize_angle_to_range( 270,  450,  361,    1);

    test_normalize_angle_to_range( 270,  450,  360,  360);
    test_normalize_angle_to_range( 270,  450,  270,  270);
    test_normalize_angle_to_range( 270,  450,  180,  180);
    test_normalize_angle_to_range( 270,  450,   90,   90);
    test_normalize_angle_to_range( 270,  450,    1,    1);

    test_normalize_angle_to_range( 270,  450,    0,  360);
    test_normalize_angle_to_range( 270,  450, - 90,  270);
    test_normalize_angle_to_range( 270,  450, -180,  180);
    test_normalize_angle_to_range( 270,  450, -270,   90);
    test_normalize_angle_to_range( 270,  450, -359,    1);

    test_normalize_angle_to_range( 270,  450, -360,  360);

    ////

    // [0..-90] -> distance=-90
    test_normalize_angle_to_range(   0, - 90,  496, -224);

    test_normalize_angle_to_range(   0, - 90,  495,  135);
    test_normalize_angle_to_range(   0, - 90,  450,   90);
    test_normalize_angle_to_range(   0, - 90,  360,    0);
    test_normalize_angle_to_range(   0, - 90,  315, - 45);
    test_normalize_angle_to_range(   0, - 90,  270, - 90);
    test_normalize_angle_to_range(   0, - 90,  180, -180);
    test_normalize_angle_to_range(   0, - 90,  136, -224);

    test_normalize_angle_to_range(   0, - 90,  135,  135);
    test_normalize_angle_to_range(   0, - 90,   90,   90);
    test_normalize_angle_to_range(   0, - 90,    0,    0);
    test_normalize_angle_to_range(   0, - 90, - 45, - 45);
    test_normalize_angle_to_range(   0, - 90, - 90, - 90);
    test_normalize_angle_to_range(   0, - 90, -180, -180);
    test_normalize_angle_to_range(   0, - 90, -224, -224);

    test_normalize_angle_to_range(   0, - 90, -225,  135);
    test_normalize_angle_to_range(   0, - 90, -270,   90);
    test_normalize_angle_to_range(   0, - 90, -360,    0);
    test_normalize_angle_to_range(   0, - 90, -405, - 45);
    test_normalize_angle_to_range(   0, - 90, -450, - 90);
    test_normalize_angle_to_range(   0, - 90, -540, -180);
    test_normalize_angle_to_range(   0, - 90, -584, -224);

    test_normalize_angle_to_range(   0, - 90, -585,  135);

    // [0..-180] -> distance=+180 -> [0..180]
    test_normalize_angle_to_range(   0, -180, -450, 270);

    test_normalize_angle_to_range(   0, -180, -449, -89);
    test_normalize_angle_to_range(   0, -180, -360,   0);
    test_normalize_angle_to_range(   0, -180, -270,  90);
    test_normalize_angle_to_range(   0, -180, -180, 180);
    test_normalize_angle_to_range(   0, -180, - 90, 270);

    test_normalize_angle_to_range(   0, -180, - 89,- 89);
    test_normalize_angle_to_range(   0, -180,    0,   0);
    test_normalize_angle_to_range(   0, -180,   90,  90);
    test_normalize_angle_to_range(   0, -180,  180, 180);
    test_normalize_angle_to_range(   0, -180,  270, 270);

    test_normalize_angle_to_range(   0, -180,  271, - 89);
    test_normalize_angle_to_range(   0, -180,  360,    0);
    test_normalize_angle_to_range(   0, -180,  450,   90);
    test_normalize_angle_to_range(   0, -180,  540,  180);
    test_normalize_angle_to_range(   0, -180,  630,  270);

    test_normalize_angle_to_range(   0, -180,  631, - 89);

    // [-90..-180] -> distance=-90
    test_normalize_angle_to_range(- 90, -180,  406, -314);

    test_normalize_angle_to_range(- 90, -180,  405,   45);
    test_normalize_angle_to_range(- 90, -180,  360,    0);
    test_normalize_angle_to_range(- 90, -180,  270, - 90);
    test_normalize_angle_to_range(- 90, -180,  225, -135);
    test_normalize_angle_to_range(- 90, -180,  180, -180);
    test_normalize_angle_to_range(- 90, -180,   90, -270);
    test_normalize_angle_to_range(- 90, -180,   46, -314);

    test_normalize_angle_to_range(- 90, -180,   45,   45);
    test_normalize_angle_to_range(- 90, -180,    0,    0);
    test_normalize_angle_to_range(- 90, -180, - 90, - 90);
    test_normalize_angle_to_range(- 90, -180, -135, -135);
    test_normalize_angle_to_range(- 90, -180, -180, -180);
    test_normalize_angle_to_range(- 90, -180, -270, -270);
    test_normalize_angle_to_range(- 90, -180, -314, -314);

    test_normalize_angle_to_range(- 90, -180, -315,   45);
    test_normalize_angle_to_range(- 90, -180, -360,    0);
    test_normalize_angle_to_range(- 90, -180, -450, - 90);
    test_normalize_angle_to_range(- 90, -180, -495, -135);
    test_normalize_angle_to_range(- 90, -180, -540, -180);
    test_normalize_angle_to_range(- 90, -180, -630, -270);
    test_normalize_angle_to_range(- 90, -180, -674, -314);

    test_normalize_angle_to_range(- 90, -180, -675,   45);

    // [-90..-270] -> distance=180 -> [-90..90]
    test_normalize_angle_to_range(- 90, -270, -540,  180);

    test_normalize_angle_to_range(- 90, -270, -539, -179);
    test_normalize_angle_to_range(- 90, -270, -450, - 90);
    test_normalize_angle_to_range(- 90, -270, -360,    0);
    test_normalize_angle_to_range(- 90, -270, -270,   90);
    test_normalize_angle_to_range(- 90, -270, -180,  180);

    test_normalize_angle_to_range(- 90, -270, -179, -179);
    test_normalize_angle_to_range(- 90, -270, - 90, - 90);
    test_normalize_angle_to_range(- 90, -270,    0,    0);
    test_normalize_angle_to_range(- 90, -270,   90,   90);
    test_normalize_angle_to_range(- 90, -270,  180,  180);

    test_normalize_angle_to_range(- 90, -270,  181, -179);
    test_normalize_angle_to_range(- 90, -270,  270, - 90);
    test_normalize_angle_to_range(- 90, -270,  360,    0);
    test_normalize_angle_to_range(- 90, -270,  450,   90);
    test_normalize_angle_to_range(- 90, -270,  540,  180);

    test_normalize_angle_to_range(- 90, -270,  541, -179);

    // [-180..-270] -> distance=-90
    test_normalize_angle_to_range(-180, -270,  316, -404);

    test_normalize_angle_to_range(-180, -270,  315, - 45);
    test_normalize_angle_to_range(-180, -270,  270, - 90);
    test_normalize_angle_to_range(-180, -270,  180, -180);
    test_normalize_angle_to_range(-180, -270,  135, -225);
    test_normalize_angle_to_range(-180, -270,   90, -270);
    test_normalize_angle_to_range(-180, -270,    0, -360);
    test_normalize_angle_to_range(-180, -270, - 44, -404);

    test_normalize_angle_to_range(-180, -270, - 45, - 45);
    test_normalize_angle_to_range(-180, -270, - 90, - 90);
    test_normalize_angle_to_range(-180, -270, -180, -180);
    test_normalize_angle_to_range(-180, -270, -225, -225);
    test_normalize_angle_to_range(-180, -270, -270, -270);
    test_normalize_angle_to_range(-180, -270, -360, -360);
    test_normalize_angle_to_range(-180, -270, -404, -404);

    test_normalize_angle_to_range(-180, -270, -405, - 45);
    test_normalize_angle_to_range(-180, -270, -450, - 90);
    test_normalize_angle_to_range(-180, -270, -540, -180);
    test_normalize_angle_to_range(-180, -270, -585, -225);
    test_normalize_angle_to_range(-180, -270, -630, -270);
    test_normalize_angle_to_range(-180, -270, -720, -360);
    test_normalize_angle_to_range(-180, -270, -764, -404);

    test_normalize_angle_to_range(-180, -270, -765, - 45);

    // [-180..-360] -> distance=180 -> [-180..0]
    test_normalize_angle_to_range(-180,    0, -630,   90);

    test_normalize_angle_to_range(-180,    0, -629, -269);
    test_normalize_angle_to_range(-180,    0, -540, -180);
    test_normalize_angle_to_range(-180,    0, -450, - 90);
    test_normalize_angle_to_range(-180,    0, -360,    0);
    test_normalize_angle_to_range(-180,    0, -270,   90);

    test_normalize_angle_to_range(-180,    0, -269, -269);
    test_normalize_angle_to_range(-180,    0, -180, -180);
    test_normalize_angle_to_range(-180,    0, - 90, - 90);
    test_normalize_angle_to_range(-180,    0,    0,    0);
    test_normalize_angle_to_range(-180,    0,   90,   90);

    test_normalize_angle_to_range(-180,    0,   91, -269);
    test_normalize_angle_to_range(-180,    0,  180, -180);
    test_normalize_angle_to_range(-180,    0,  270, - 90);
    test_normalize_angle_to_range(-180,    0,  360,    0);
    test_normalize_angle_to_range(-180,    0,  450,   90);

    test_normalize_angle_to_range(-180,    0,  451, -269);

    // [-270..-360] -> distance=-90
    test_normalize_angle_to_range(-270, -360,  226, -494);

    test_normalize_angle_to_range(-270, -360,  225, -135);
    test_normalize_angle_to_range(-270, -360,  180, -180);
    test_normalize_angle_to_range(-270, -360,   90, -270);
    test_normalize_angle_to_range(-270, -360,   45, -315);
    test_normalize_angle_to_range(-270, -360,    0, -360);
    test_normalize_angle_to_range(-270, -360,  -90, -450);
    test_normalize_angle_to_range(-270, -360, -134, -494);

    test_normalize_angle_to_range(-270, -360, -135, -135);
    test_normalize_angle_to_range(-270, -360, -180, -180);
    test_normalize_angle_to_range(-270, -360, -270, -270);
    test_normalize_angle_to_range(-270, -360, -315, -315);
    test_normalize_angle_to_range(-270, -360, -360, -360);
    test_normalize_angle_to_range(-270, -360, -450, -450);
    test_normalize_angle_to_range(-270, -360, -494, -494);

    test_normalize_angle_to_range(-270, -360, -495, -135);
    test_normalize_angle_to_range(-270, -360, -540, -180);
    test_normalize_angle_to_range(-270, -360, -630, -270);
    test_normalize_angle_to_range(-270, -360, -675, -315);
    test_normalize_angle_to_range(-270, -360, -720, -360);
    test_normalize_angle_to_range(-270, -360, -810, -450);
    test_normalize_angle_to_range(-270, -360, -854, -494);

    test_normalize_angle_to_range(-270, -360, -855, -135);

    // [-270..-450] -> distance=180 -> [-270..-90]
    test_normalize_angle_to_range(-270, -450, -720,    0);

    test_normalize_angle_to_range(-270, -450, -719, -359);
    test_normalize_angle_to_range(-270, -450, -630, -270);
    test_normalize_angle_to_range(-270, -450, -540, -180);
    test_normalize_angle_to_range(-270, -450, -450, - 90);
    test_normalize_angle_to_range(-270, -450, -360,    0);

    test_normalize_angle_to_range(-270, -450, -359, -359);
    test_normalize_angle_to_range(-270, -450, -270, -270);
    test_normalize_angle_to_range(-270, -450, -180, -180);
    test_normalize_angle_to_range(-270, -450, - 90, - 90);
    test_normalize_angle_to_range(-270, -450,    0,    0);

    test_normalize_angle_to_range(-270, -450,    1, -359);
    test_normalize_angle_to_range(-270, -450,   90, -270);
    test_normalize_angle_to_range(-270, -450,  180, -180);
    test_normalize_angle_to_range(-270, -450,  270, - 90);
    test_normalize_angle_to_range(-270, -450,  360,    0);

    test_normalize_angle_to_range(-270, -450,  361, -359);
}

//// std::fmod vs math::normalize_angle

void test_std_fmod_vs_normalize_angle(bool in_radians, size_t num)
{
    const double min_angle = -DEG_360_IN_RAD_IF(min_angle, in_radians) * num;
    const double max_angle = DEG_360_IN_RAD_IF(max_angle, in_radians) * num;
    const double inc_angle = DEG_360_IN_RAD_IF(inc_angle, in_radians) / DEG_720_IN_RAD_IF(inc_angle, in_radians);

    for (double angle = min_angle; angle <= max_angle; angle += inc_angle) {
        const double fmod_angle = std::fmod(angle, DEG_360_IN_RAD_IF(angle, in_radians));
        const double norm_angle = math::normalize_angle(angle,
            -DEG_360_IN_RAD_IF(angle, in_radians), DEG_360_IN_RAD_IF(angle, in_radians), DEG_360_IN_RAD_IF(angle, in_radians), 0, true);
        ASSERT_EQ(fmod_angle, norm_angle);
    }
}

TEST(FunctionsTest, std_fmod_vs_normalize_angle_rads)
{
    test_std_fmod_vs_normalize_angle(true, 1000);
}

TEST(FunctionsTest, std_fmod_vs_normalize_angle_degrees)
{
    test_std_fmod_vs_normalize_angle(false, 1000);
}

//// get_leap_days

inline void test_get_leap_days(size_t begin_year, size_t end_year, size_t eta_leap_days)
{
    const double leap_days = begin_year < end_year ? ti::get_leap_days(end_year) - ti::get_leap_days(begin_year + 1) : 0;
    ASSERT_EQ(leap_days, eta_leap_days);
}

TEST(FunctionsTest, get_leap_days)
{
    // test values based on this: https://stackoverflow.com/questions/14878356/efficiently-calculate-leap-days
    //

    test_get_leap_days(1996, 1996, 0);
    test_get_leap_days(1996, 1997, 0);
    test_get_leap_days(1996, 1998, 0);
    test_get_leap_days(1996, 1999, 0);
    test_get_leap_days(1996, 2000, 0);
    test_get_leap_days(1996, 2001, 1);
    test_get_leap_days(1996, 2002, 1);
    test_get_leap_days(1996, 2003, 1);
    test_get_leap_days(1996, 2004, 1);
    test_get_leap_days(1996, 2005, 2);
    test_get_leap_days(1996, 2006, 2);
    test_get_leap_days(1996, 2007, 2);
    test_get_leap_days(1996, 2008, 2);
    test_get_leap_days(1996, 2009, 3);
    test_get_leap_days(1997, 1997, 0);
    test_get_leap_days(1997, 1998, 0);
    test_get_leap_days(1997, 1999, 0);
    test_get_leap_days(1997, 2000, 0);
    test_get_leap_days(1997, 2001, 1);
    test_get_leap_days(1997, 2002, 1);
    test_get_leap_days(1997, 2003, 1);
    test_get_leap_days(1997, 2004, 1);
    test_get_leap_days(1997, 2005, 2);
    test_get_leap_days(1997, 2006, 2);
    test_get_leap_days(1997, 2007, 2);
    test_get_leap_days(1997, 2008, 2);
    test_get_leap_days(1997, 2009, 3);
    test_get_leap_days(1998, 1998, 0);
    test_get_leap_days(1998, 1999, 0);
    test_get_leap_days(1998, 2000, 0);
    test_get_leap_days(1998, 2001, 1);
    test_get_leap_days(1998, 2002, 1);
    test_get_leap_days(1998, 2003, 1);
    test_get_leap_days(1998, 2004, 1);
    test_get_leap_days(1998, 2005, 2);
    test_get_leap_days(1998, 2006, 2);
    test_get_leap_days(1998, 2007, 2);
    test_get_leap_days(1998, 2008, 2);
    test_get_leap_days(1998, 2009, 3);
    test_get_leap_days(1999, 1999, 0);
    test_get_leap_days(1999, 2000, 0);
    test_get_leap_days(1999, 2001, 1);
    test_get_leap_days(1999, 2002, 1);
    test_get_leap_days(1999, 2003, 1);
    test_get_leap_days(1999, 2004, 1);
    test_get_leap_days(1999, 2005, 2);
    test_get_leap_days(1999, 2006, 2);
    test_get_leap_days(1999, 2007, 2);
    test_get_leap_days(1999, 2008, 2);
    test_get_leap_days(1999, 2009, 3);
    test_get_leap_days(2000, 2000, 0);
    test_get_leap_days(2000, 2001, 0);
    test_get_leap_days(2000, 2002, 0);
    test_get_leap_days(2000, 2003, 0);
    test_get_leap_days(2000, 2004, 0);
    test_get_leap_days(2000, 2005, 1);
    test_get_leap_days(2000, 2006, 1);
    test_get_leap_days(2000, 2007, 1);
    test_get_leap_days(2000, 2008, 1);
    test_get_leap_days(2000, 2009, 2);
    test_get_leap_days(2001, 2001, 0);
    test_get_leap_days(2001, 2002, 0);
    test_get_leap_days(2001, 2003, 0);
    test_get_leap_days(2001, 2004, 0);
    test_get_leap_days(2001, 2005, 1);
    test_get_leap_days(2001, 2006, 1);
    test_get_leap_days(2001, 2007, 1);
    test_get_leap_days(2001, 2008, 1);
    test_get_leap_days(2001, 2009, 2);
    test_get_leap_days(2002, 2002, 0);
    test_get_leap_days(2002, 2003, 0);
    test_get_leap_days(2002, 2004, 0);
    test_get_leap_days(2002, 2005, 1);
    test_get_leap_days(2002, 2006, 1);
    test_get_leap_days(2002, 2007, 1);
    test_get_leap_days(2002, 2008, 1);
    test_get_leap_days(2002, 2009, 2);
    test_get_leap_days(2003, 2003, 0);
    test_get_leap_days(2003, 2004, 0);
    test_get_leap_days(2003, 2005, 1);
    test_get_leap_days(2003, 2006, 1);
    test_get_leap_days(2003, 2007, 1);
    test_get_leap_days(2003, 2008, 1);
    test_get_leap_days(2003, 2009, 2);
    test_get_leap_days(2004, 2004, 0);
    test_get_leap_days(2004, 2005, 0);
    test_get_leap_days(2004, 2006, 0);
    test_get_leap_days(2004, 2007, 0);
    test_get_leap_days(2004, 2008, 0);
    test_get_leap_days(2004, 2009, 1);
    test_get_leap_days(2005, 2005, 0);
    test_get_leap_days(2005, 2006, 0);
    test_get_leap_days(2005, 2007, 0);
    test_get_leap_days(2005, 2008, 0);
    test_get_leap_days(2005, 2009, 1);
    test_get_leap_days(2006, 2006, 0);
    test_get_leap_days(2006, 2007, 0);
    test_get_leap_days(2006, 2008, 0);
    test_get_leap_days(2006, 2009, 1);
    test_get_leap_days(2007, 2007, 0);
    test_get_leap_days(2007, 2008, 0);
    test_get_leap_days(2007, 2009, 1);
    test_get_leap_days(2008, 2008, 0);
    test_get_leap_days(2008, 2009, 0);
    test_get_leap_days(1896, 1896, 0);
    test_get_leap_days(1896, 1897, 0);
    test_get_leap_days(1896, 1898, 0);
    test_get_leap_days(1896, 1899, 0);
    test_get_leap_days(1896, 1900, 0);
    test_get_leap_days(1896, 1901, 0);
    test_get_leap_days(1896, 1902, 0);
    test_get_leap_days(1896, 1903, 0);
    test_get_leap_days(1896, 1904, 0);
    test_get_leap_days(1896, 1905, 1);
    test_get_leap_days(1896, 1906, 1);
    test_get_leap_days(1896, 1907, 1);
    test_get_leap_days(1896, 1908, 1);
    test_get_leap_days(1896, 1909, 2);
    test_get_leap_days(1897, 1897, 0);
    test_get_leap_days(1897, 1898, 0);
    test_get_leap_days(1897, 1899, 0);
    test_get_leap_days(1897, 1900, 0);
    test_get_leap_days(1897, 1901, 0);
    test_get_leap_days(1897, 1902, 0);
    test_get_leap_days(1897, 1903, 0);
    test_get_leap_days(1897, 1904, 0);
    test_get_leap_days(1897, 1905, 1);
    test_get_leap_days(1897, 1906, 1);
    test_get_leap_days(1897, 1907, 1);
    test_get_leap_days(1897, 1908, 1);
    test_get_leap_days(1897, 1909, 2);
    test_get_leap_days(1898, 1898, 0);
    test_get_leap_days(1898, 1899, 0);
    test_get_leap_days(1898, 1900, 0);
    test_get_leap_days(1898, 1901, 0);
    test_get_leap_days(1898, 1902, 0);
    test_get_leap_days(1898, 1903, 0);
    test_get_leap_days(1898, 1904, 0);
    test_get_leap_days(1898, 1905, 1);
    test_get_leap_days(1898, 1906, 1);
    test_get_leap_days(1898, 1907, 1);
    test_get_leap_days(1898, 1908, 1);
    test_get_leap_days(1898, 1909, 2);
    test_get_leap_days(1899, 1899, 0);
    test_get_leap_days(1899, 1900, 0);
    test_get_leap_days(1899, 1901, 0);
    test_get_leap_days(1899, 1902, 0);
    test_get_leap_days(1899, 1903, 0);
    test_get_leap_days(1899, 1904, 0);
    test_get_leap_days(1899, 1905, 1);
    test_get_leap_days(1899, 1906, 1);
    test_get_leap_days(1899, 1907, 1);
    test_get_leap_days(1899, 1908, 1);
    test_get_leap_days(1899, 1909, 2);
    test_get_leap_days(1900, 1900, 0);
    test_get_leap_days(1900, 1901, 0);
    test_get_leap_days(1900, 1902, 0);
    test_get_leap_days(1900, 1903, 0);
    test_get_leap_days(1900, 1904, 0);
    test_get_leap_days(1900, 1905, 1);
    test_get_leap_days(1900, 1906, 1);
    test_get_leap_days(1900, 1907, 1);
    test_get_leap_days(1900, 1908, 1);
    test_get_leap_days(1900, 1909, 2);
    test_get_leap_days(1901, 1901, 0);
    test_get_leap_days(1901, 1902, 0);
    test_get_leap_days(1901, 1903, 0);
    test_get_leap_days(1901, 1904, 0);
    test_get_leap_days(1901, 1905, 1);
    test_get_leap_days(1901, 1906, 1);
    test_get_leap_days(1901, 1907, 1);
    test_get_leap_days(1901, 1908, 1);
    test_get_leap_days(1901, 1909, 2);
    test_get_leap_days(1902, 1902, 0);
    test_get_leap_days(1902, 1903, 0);
    test_get_leap_days(1902, 1904, 0);
    test_get_leap_days(1902, 1905, 1);
    test_get_leap_days(1902, 1906, 1);
    test_get_leap_days(1902, 1907, 1);
    test_get_leap_days(1902, 1908, 1);
    test_get_leap_days(1902, 1909, 2);
    test_get_leap_days(1903, 1903, 0);
    test_get_leap_days(1903, 1904, 0);
    test_get_leap_days(1903, 1905, 1);
    test_get_leap_days(1903, 1906, 1);
    test_get_leap_days(1903, 1907, 1);
    test_get_leap_days(1903, 1908, 1);
    test_get_leap_days(1903, 1909, 2);
    test_get_leap_days(1904, 1904, 0);
    test_get_leap_days(1904, 1905, 0);
    test_get_leap_days(1904, 1906, 0);
    test_get_leap_days(1904, 1907, 0);
    test_get_leap_days(1904, 1908, 0);
    test_get_leap_days(1904, 1909, 1);
    test_get_leap_days(1905, 1905, 0);
    test_get_leap_days(1905, 1906, 0);
    test_get_leap_days(1905, 1907, 0);
    test_get_leap_days(1905, 1908, 0);
    test_get_leap_days(1905, 1909, 1);
    test_get_leap_days(1906, 1906, 0);
    test_get_leap_days(1906, 1907, 0);
    test_get_leap_days(1906, 1908, 0);
    test_get_leap_days(1906, 1909, 1);
    test_get_leap_days(1907, 1907, 0);
    test_get_leap_days(1907, 1908, 0);
    test_get_leap_days(1907, 1909, 1);
    test_get_leap_days(1908, 1908, 0);
    test_get_leap_days(1908, 1909, 0);
}
