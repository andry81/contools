#pragma once

// DO NOT REMOVE, exists to avoid private/public headers mixing!
#ifndef UTILITY_TIME_HPP
#define UTILITY_TIME_HPP

#include <tacklelib/tacklelib.hpp>

#include <tacklelib/utility/platform.hpp>
#include <tacklelib/utility/type_traits.hpp>
#include <tacklelib/utility/assert.hpp>
#include <tacklelib/utility/string.hpp>

#if ERROR_IF_EMPTY_PP_DEF(USE_FMT_LIBRARY_INSTEAD_STD_STRINGSTREAMS)
#include <fmt/format.h>
#include <fmt/time.h>
#endif

#include <string>
#include <ctime>
#include <cmath>
#include <cstdint>
#include <atomic>
#include <chrono>
#include <limits>
#include <sstream>
#include <iomanip>
#include <utility>

#ifdef UTILITY_PLATFORM_WINDOWS
// windows includes must be ordered here!
#include <windef.h>
#include <winbase.h>
#include <winnt.h>
#elif defined(UTILITY_PLATFORM_POSIX)
//#include <time.h>
#else
#error platform is not implemented
#endif


namespace utility {
namespace time {

    static CONSTEXPR const uint64_t unix_epoch_mcsecs                       =  62135596800000000ULL;
    static CONSTEXPR const uint64_t from_1_jan1601_to_1_jan1970_100nsecs    = 116444736000000000ULL;   //1.jan1601 to 1.jan1970

#ifdef UTILITY_PLATFORM_WINDOWS
    using clockid_t = int;

    const clockid_t CLOCK_REALTIME              = 0;    // Identifier for system-wide realtime clock.
    const clockid_t CLOCK_MONOTONIC             = 1;    // Monotonic system-wide clock.
    const clockid_t CLOCK_PROCESS_CPUTIME_ID    = 2;    // High-resolution timer from the CPU.
    const clockid_t CLOCK_THREAD_CPUTIME_ID     = 3;    // Thread-specific CPU-time clock.
    const clockid_t CLOCK_MONOTONIC_RAW         = 4;    // Monotonic system-wide clock, not adjusted for frequency scaling.
    const clockid_t CLOCK_REALTIME_COARSE       = 5;    // Identifier for system-wide realtime clock, updated only on ticks.
    const clockid_t CLOCK_MONOTONIC_COARSE      = 6;    // Monotonic system-wide clock, updated only on ticks.
    const clockid_t CLOCK_BOOTTIME              = 7;    // Monotonic system-wide clock that includes time spent in suspension.
    const clockid_t CLOCK_REALTIME_ALARM        = 8;    // Like CLOCK_REALTIME but also wakes suspended system.
    const clockid_t CLOCK_BOOTTIME_ALARM        = 9;    // Like CLOCK_BOOTTIME but also wakes suspended system.
    const clockid_t CLOCK_TAI                   = 11;   // Like CLOCK_REALTIME but in International Atomic Time.
#endif

    FORCE_INLINE void unix_time(struct timespec *spec)
    {
#ifdef UTILITY_PLATFORM_WINDOWS
        int64_t wintime;
        GetSystemTimeAsFileTime((FILETIME *)&wintime);
        wintime -= from_1_jan1601_to_1_jan1970_100nsecs;
        spec->tv_sec = wintime / 10000000i64;
        spec->tv_nsec = wintime % 10000000i64 * 100;
#else
        ::timespec_get(spec, TIME_UTC);
#endif
    }

    FORCE_INLINE int clock_gettime(clockid_t clk_id, struct timespec * ct)
    {
#ifdef UTILITY_PLATFORM_WINDOWS
        UTILITY_UNUSED_STATEMENT(clk_id);

        // context call saved per thread basis instead of per entire application
        thread_local std::atomic<bool> s_has_queried_frequency = false;
        thread_local LARGE_INTEGER s_counts_per_sec;
        timespec unix_startspec;
        LARGE_INTEGER count;

        if (!s_has_queried_frequency.exchange(true)) {
            if (QueryPerformanceFrequency(&s_counts_per_sec)) {
                unix_time(&unix_startspec);
            }
            else {
                s_counts_per_sec.QuadPart = 0;
            }
        }

        if (!ct || s_counts_per_sec.QuadPart <= 0 || !QueryPerformanceCounter(&count)) {
            return -1;
        }

        ct->tv_sec = unix_startspec.tv_sec + count.QuadPart / s_counts_per_sec.QuadPart;
        int64_t tv_nsec = unix_startspec.tv_nsec + ((count.QuadPart % s_counts_per_sec.QuadPart) * 1000000000i64) / s_counts_per_sec.QuadPart;

        if (!(tv_nsec < 1000000000)) {
            ct->tv_sec++;
            tv_nsec -= 1000000000;
        }

        DEBUG_ASSERT_GE(int64_t((std::numeric_limits<long>::max)()), tv_nsec);
        ct->tv_nsec = long(tv_nsec);

        return 0;
#else
        return ::clock_gettime(clk_id, ct);
#endif
    }

    FORCE_INLINE bool is_leap_year(size_t year)
    {
        return !(year % 4) && (year % 100) || !(year % 400);
    }

    FORCE_INLINE size_t get_leap_days(size_t year)
    {
        DEBUG_ASSERT_GE(year, 1800U);
        const size_t prev_year = year - 1;
        return prev_year / 4 - prev_year / 100 + prev_year / 400;
    }


    FORCE_INLINE std::tm gmtime(const std::time_t & time)
    {
        std::tm t = {};

#ifdef UTILITY_PLATFORM_WINDOWS
        gmtime_s(&t, &time);
#else
        gmtime_r(&time, &t);
#endif

        return t;
    }

    FORCE_INLINE std::string strftime(const std::string & fmt, const std::tm & time)
    {
#if ERROR_IF_EMPTY_PP_DEF(USE_FMT_LIBRARY_INSTEAD_STD_STRINGSTREAMS)
        const std::string fmt_format = utility::string_format(256, "{:%s}", fmt.c_str()); // faster than fmt format
        return fmt::format(fmt_format, time);
#else
        std::stringstream buffer;
        buffer << std::put_time(&time, fmt.c_str());
        return buffer.str();
#endif
    }

    // Uses `std::get_time` to read the formatted time string into calendar time (not including milliseconds and days since 1 January).
    template <class t_elem, class t_traits, class t_alloc>
    FORCE_INLINE bool get_time(std::tm & time, const std::string & locale,
        const std::basic_string<t_elem, t_traits, t_alloc> & fmt, const std::basic_string<t_elem, t_traits, t_alloc> & date_time_str)
    {
// not implemented
//#if ERROR_IF_EMPTY_PP_DEF(USE_FMT_LIBRARY_INSTEAD_STD_STRINGSTREAMS)
//        const std::string fmt_format = utility::string_format(256, "{:%s}", fmt.c_str()); // faster than fmt format
//        return fmt::get_time(fmt_format, date_time_str);
//#else
        time = std::tm{};

        std::basic_istringstream<t_elem, t_traits, t_alloc> ss{ date_time_str };
        if (!locale.empty()) {
            ss.imbue(std::locale(locale));
        }

        // CAUTION:
        //  t.tm_yday is not initialized here!
        //
        ss >> std::get_time(&time, fmt.c_str());

        return !ss.fail();
//#endif
    }

    // Uses `std::get_time` to read the formatted time string into calendar time (not including milliseconds and days since 1 January).
    template <class t_elem, class t_traits, class t_alloc>
    FORCE_INLINE bool get_time(std::tm & time, const std::string & locale,
        const std::basic_string<t_elem, t_traits, t_alloc> & fmt, std::basic_string<t_elem, t_traits, t_alloc> && date_time_str)
    {
// not implemented
//#if ERROR_IF_EMPTY_PP_DEF(USE_FMT_LIBRARY_INSTEAD_STD_STRINGSTREAMS)
//        const std::string fmt_format = utility::string_format(256, "{:%s}", fmt.c_str()); // faster than fmt format
//        return fmt::get_time(fmt_format, date_time_str);
//#else
        time = std::tm{};

        std::basic_istringstream<t_elem, t_traits, t_alloc> ss{ std::move(date_time_str) };
        if (!locale.empty()) {
            ss.imbue(std::locale(locale));
        }

        // CAUTION:
        //  t.tm_yday is not initialized here!
        //
        ss >> std::get_time(&time, fmt.c_str());

        return !ss.fail();
//#endif
    }

    FORCE_INLINE time_t timegm(const std::tm & time)
    {
        tm c_tm = time; // must be not constant

#if defined(UTILITY_COMPILER_CXX_GCC)
        return timegm(&c_tm);
#elif defined(UTILITY_COMPILER_CXX_MSC)
        return _mkgmtime(&c_tm);
#endif
    }

    FORCE_INLINE std::tm get_calendar_time_from_utc_time_sec(double utc_time_sec, double * utc_time_sec_fract = nullptr)
    {
        // convert UTC time to time_t structure
        const time_t track_time = time_t(uint64_t(utc_time_sec)); // seconds since 00:00 hours 1 Jan 1970 (unix epoch)

        if (utc_time_sec_fract) {
            double whole;
            *utc_time_sec_fract = std::modf(utc_time_sec, &whole);
        }

        return utility::time::gmtime(track_time);
    }

}
}

#endif
