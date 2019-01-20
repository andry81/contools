#include "test_common.hpp"

#include <tacklelib/utility/math.hpp>
#include <tacklelib/utility/string.hpp>

#include <src/utility/arc/libarchive/libarchive.hpp>

#include <fmt/format.h>


//// tackle::string_fromat

TEST(FunctionsTest, test_string_format_on_std_string_0_x1M)
{
    for (size_t i = 0; i < 1000000; i++) {
        const std::string v = utility::string_format(0, "%s+%u\n", "test test test", 12345);
        UTILITY_SUPPRESS_OPTIMIZATION_ON_VAR(v);
    }
}

TEST(FunctionsTest, test_string_format_on_std_string_256_x1M)
{
    for (size_t i = 0; i < 1000000; i++) {
        const std::string v = utility::string_format(256, "%s+%u\n", "test test test", 12345);
        UTILITY_SUPPRESS_OPTIMIZATION_ON_VAR(v);
    }
}

//// fmt::format

TEST(FunctionsTest, test_fmt_format_positional_x1M)
{
    for (size_t i = 0; i < 1000000; i++) {
        const std::string v = fmt::format("{0:s}+{1:d}\n", "test test test", 12345);
        UTILITY_SUPPRESS_OPTIMIZATION_ON_VAR(v);
    }
}

TEST(FunctionsTest, test_fmt_format_named_x1M)
{
    for (size_t i = 0; i < 1000000; i++) {
        const std::string v = fmt::format("{first:s}+{second:d}\n", fmt::arg("first", "test test test"), fmt::arg("second", 12345));
        UTILITY_SUPPRESS_OPTIMIZATION_ON_VAR(v);
    }
}

void test_std_fmod(bool in_radians, double range_factor, size_t repeats)
{
    const double min_angle = -DEG_360_IN_RAD_IF(min_angle, in_radians) * range_factor;
    const double max_angle = DEG_360_IN_RAD_IF(max_angle, in_radians) * range_factor;
    const double step_angle = DEG_360_IN_RAD_IF(step_angle, in_radians) / DEG_720_IN_RAD_IF(step_angle, in_radians);

    for (size_t i = 0; i < repeats; i++) {
        for (double angle = min_angle; angle <= max_angle; angle += step_angle) {
            const double angle_norm = std::fmod(angle, DEG_360_IN_RAD_IF(angle, in_radians));
            UTILITY_SUPPRESS_OPTIMIZATION_ON_VAR(angle_norm);
        }
    }
}

void test_c_fmod(bool in_radians, double range_factor, size_t repeats)
{
    const double min_angle = -DEG_360_IN_RAD_IF(min_angle, in_radians) * range_factor;
    const double max_angle = DEG_360_IN_RAD_IF(max_angle, in_radians) * range_factor;
    const double step_angle = DEG_360_IN_RAD_IF(step_angle, in_radians) / DEG_720_IN_RAD_IF(step_angle, in_radians);

    for (size_t i = 0; i < repeats; i++) {
        for (double angle = min_angle; angle <= max_angle; angle += step_angle) {
            const double angle_norm = fmod(angle, DEG_360_IN_RAD_IF(angle, in_radians));
            UTILITY_SUPPRESS_OPTIMIZATION_ON_VAR(angle_norm);
        }
    }
}

void test_normalize_angle(bool in_radians, double range_factor, size_t repeats)
{
    const double min_angle = -DEG_360_IN_RAD_IF(min_angle, in_radians) * range_factor;
    const double max_angle = DEG_360_IN_RAD_IF(max_angle, in_radians) * range_factor;
    const double step_angle = DEG_360_IN_RAD_IF(step_angle, in_radians) / DEG_720_IN_RAD_IF(step_angle, in_radians);

    for (size_t i = 0; i < repeats; i++) {
        for (double angle = min_angle; angle <= max_angle; angle += step_angle) {
            const double angle_norm = math::normalize_angle(angle,
                -DEG_360_IN_RAD_IF(angle, in_radians), DEG_360_IN_RAD_IF(angle, in_radians),
                DEG_360_IN_RAD_IF(angle, in_radians), 0, true);
            UTILITY_SUPPRESS_OPTIMIZATION_ON_VAR(angle_norm);
        }
    }
}

//// std::fmod

TEST(FunctionsTest, test_std_fmod_rads_out_bounds_x10K)
{
    test_std_fmod(true, 10000, 1);
}

TEST(FunctionsTest, test_std_fmod_degrees_out_bounds_x10K)
{
    test_std_fmod(false, 10000, 1);
}

TEST(FunctionsTest, test_std_fmod_rads_180_x10K)
{
    test_std_fmod(true, 0.5, 20000);
}

TEST(FunctionsTest, test_std_fmod_degrees_180_x10K)
{
    test_std_fmod(false, 0.5, 20000);
}

TEST(FunctionsTest, test_std_fmod_rads_360_x10K)
{
    test_std_fmod(true, 1, 10000);
}

TEST(FunctionsTest, test_std_fmod_degrees_360_x10K)
{
    test_std_fmod(false, 1, 10000);
}

TEST(FunctionsTest, test_std_fmod_rads_540_x10K)
{
    test_std_fmod(true, 1.5, 6667);
}

TEST(FunctionsTest, test_std_fmod_degrees_540_x10K)
{
    test_std_fmod(false, 1.5, 6667);
}

TEST(FunctionsTest, test_std_fmod_rads_720_x10K)
{
    test_std_fmod(true, 2, 5000);
}

TEST(FunctionsTest, test_std_fmod_degrees_720_x10K)
{
    test_std_fmod(false, 2, 5000);
}

//// c fmod

TEST(FunctionsTest, test_c_fmod_rads_out_bounds_x10K)
{
    test_c_fmod(true, 10000, 1);
}

TEST(FunctionsTest, test_c_fmod_degrees_out_bounds_x10K)
{
    test_c_fmod(false, 10000, 1);
}

TEST(FunctionsTest, test_c_fmod_rads_180_x10K)
{
    test_c_fmod(true, 0.5, 20000);
}

TEST(FunctionsTest, test_c_fmod_degrees_180_x10K)
{
    test_c_fmod(false, 0.5, 20000);
}

TEST(FunctionsTest, test_c_fmod_rads_360_x10K)
{
    test_c_fmod(true, 1, 10000);
}

TEST(FunctionsTest, test_c_fmod_degrees_360_x10K)
{
    test_c_fmod(false, 1, 10000);
}

TEST(FunctionsTest, test_c_fmod_rads_540_x10K)
{
    test_c_fmod(true, 1.5, 6667);
}

TEST(FunctionsTest, test_c_fmod_degrees_540_x10K)
{
    test_c_fmod(false, 1.5, 6667);
}

TEST(FunctionsTest, test_c_fmod_rads_720_x10K)
{
    test_c_fmod(true, 2, 5000);
}

TEST(FunctionsTest, test_c_fmod_degrees_720_x10K)
{
    test_c_fmod(false, 2, 5000);
}

//// math::normalize_angle

TEST(FunctionsTest, test_normalize_angle_rads_out_bounds_x10K)
{
    test_normalize_angle(true, 10000, 1);
}

TEST(FunctionsTest, test_normalize_angle_degrees_out_bounds_x10K)
{
    test_normalize_angle(false, 10000, 1);
}

TEST(FunctionsTest, test_normalize_angle_rads_180_x10K)
{
    test_normalize_angle(true, 0.5, 20000);
}

TEST(FunctionsTest, test_normalize_angle_degrees_180_x10K)
{
    test_normalize_angle(false, 0.5, 20000);
}

TEST(FunctionsTest, test_normalize_angle_rads_360_x10K)
{
    test_normalize_angle(true, 1, 10000);
}

TEST(FunctionsTest, test_normalize_angle_degrees_360_x10K)
{
    test_normalize_angle(false, 1, 10000);
}

TEST(FunctionsTest, test_normalize_angle_rads_540_x10K)
{
    test_normalize_angle(true, 1.5, 6667);
}

TEST(FunctionsTest, test_normalize_angle_degrees_540_x10K)
{
    test_normalize_angle(false, 1.5, 6667);
}

TEST(FunctionsTest, test_normalize_angle_rads_720_x10K)
{
    test_normalize_angle(true, 2, 5000);
}

TEST(FunctionsTest, test_normalize_angle_degrees_720_x10K)
{
    test_normalize_angle(false, 2, 5000);
}

////// utility::arc::libarchive::write_archive
//
//inline void test_utility_arc_libarchive_write_archive(size_t times)
//{
//    std::vector<tackle::path_string> files = {
//        "test.txt"
//    };
//
//    const tackle::path_string & data_in_dir = TEST_CASE_GET_ROOT(data_in);
//    const tackle::path_string & data_out_dir = TEST_CASE_GET_ROOT(data_out);
//
//    const tackle::path_string in_dir = data_in_dir / "test_arc";
//    const tackle::path_string out_file = data_out_dir / "test_arc.7z";
//
//    if (!utility::is_path_exists(data_out_dir, true)) {
//        utility::create_directory(data_out_dir, true);
//    }
//
//    for (size_t i = 0; i < times; i++) {
//        // compressor:  lzma1
//        // level:       normal (5)
//        utility::arc::libarchive::write_archive({}, ARCHIVE_FORMAT_7ZIP, "compression=lzma1,compression-level=5",
//            out_file, in_dir, files, 32768);
//    }
//}
//
//TEST(FunctionsTest, test_utility_arc_libarchive_write_archive_x10)
//{
//    test_utility_arc_libarchive_write_archive(10);
//}
