#pragma once

// DO NOT REMOVE, exists to avoid private/public headers mixing!
#ifndef UTILITY_MATH_HPP
#define UTILITY_MATH_HPP

#include <tacklelib/tacklelib.hpp>

#include <tacklelib/utility/preprocessor.hpp>
#include <tacklelib/utility/platform.hpp>
#include <tacklelib/utility/type_identity.hpp>
#include <tacklelib/utility/static_assert.hpp>
#include <tacklelib/utility/type_traits.hpp>
#include <tacklelib/utility/assert.hpp>

#include <tacklelib/tackle/static_constexpr.hpp>

#include <cstddef>
#include <cstdint>
#include <limits>
#include <utility>
#include <cfloat>
#include <cmath>
#include <algorithm>


#define INT32_LOG2_FLOOR_CONSTEXPR(x)               ::math::int32_log2_floor<x>::value
#define UINT32_LOG2_FLOOR_CONSTEXPR(x)              ::math::uint32_log2_floor<x>::value
#define INT32_LOG2_CEIL_CONSTEXPR(x)                ::math::int32_log2_ceil<x>::value
#define UINT32_LOG2_CEIL_CONSTEXPR(x)               ::math::uint32_log2_ceil<x>::value

#define INT32_POF2_FLOOR_CONSTEXPR(x)               ::math::int32_pof2_floor<x>::value
#define UINT32_POF2_FLOOR_CONSTEXPR(x)              ::math::uint32_pof2_floor<x>::value

#define INT32_POF2_CEIL_CONSTEXPR(x)                ::math::int32_pof2_ceil<x>::value
#define UINT32_POF2_CEIL_CONSTEXPR(x)               ::math::uint32_pof2_ceil<x>::value

#define INT32_LOG2_CONSTEXPR_VERIFY(x)              ::math::int32_log2_verify<x>::value
#define UINT32_LOG2_CONSTEXPR_VERIFY(x)             ::math::uint32_log2_verify<x>::value
#define STDSIZE_LOG2_CONSTEXPR_VERIFY(x)            ::math::stdsize_log2_verify<x>::value

#define INT32_POF2_CONSTEXPR_VERIFY(x)              ::math::int32_pof2_verify<x>::value
#define UINT32_POF2_CONSTEXPR_VERIFY(x)             ::math::uint32_pof2_verify<x>::value


#define INT32_LOG2_FLOOR(x)                         ::math::int_log2_floor<int32_t>(x)
#define UINT32_LOG2_FLOOR(x)                        ::math::int_log2_floor<uint32_t>(x)
#define INT32_LOG2_CEIL(x)                          ::math::int_log2_ceil<int32_t>(x)
#define UINT32_LOG2_CEIL(x)                         ::math::int_log2_ceil<uint32_t>(x)

#define INT32_POF2_FLOOR(x)                         ::math::int_pof2_floor<int32_t>(x)
#define UINT32_POF2_FLOOR(x)                        ::math::int_pof2_floor<uint32_t>(x)
#define INT32_POF2_CEIL(x)                          ::math::int_pof2_ceil<int32_t>(x)
#define UINT32_POF2_CEIL(x)                         ::math::int_pof2_ceil<uint32_t>(x)

#define INT32_LOG2_FLOOR_VERIFY(x)                  ::math::int_log2_floor_verify<int32_t>(x)
#define UINT32_LOG2_FLOOR_VERIFY(x)                 ::math::int_log2_floor_verify<uint32_t>(x)
#define INT32_LOG2_CEIL_VERIFY(x)                   ::math::int_log2_ceil_verify<int32_t>(x)
#define UINT32_LOG2_CEIL_VERIFY(x)                  ::math::int_log2_ceil_verify<uint32_t>(x)

#define INT32_POF2_FLOOR_VERIFY(x)                  ::math::int_pof2_floor_verify<int32_t>(x)
#define UINT32_POF2_FLOOR_VERIFY(x)                 ::math::int_pof2_floor_verify<uint32_t>(x)
#define INT32_POF2_CEIL_VERIFY(x)                   ::math::int_pof2_ceil_verify<int32_t>(x)
#define UINT32_POF2_CEIL_VERIFY(x)                  ::math::int_pof2_ceil_verify<uint32_t>(x)


#define INT32_MULT_POF2_FLOOR_CONSTEXPR(x, y)       int32_t(int32_t(x) << INT32_LOG2_FLOOR_CONSTEXPR(y))
#define UINT32_MULT_POF2_FLOOR_CONSTEXPR(x, y)      uint32_t(uint32_t(x) << UINT32_LOG2_FLOOR_CONSTEXPR(y))
#define INT32_MULT_POF2_CEIL_CONSTEXPR(x, y)        int32_t(int32_t(x) << INT32_LOG2_CEIL_CONSTEXPR(y))
#define UINT32_MULT_POF2_CEIL_CONSTEXPR(x, y)       uint32_t(uint32_t(x) << UINT32_LOG2_CEIL_CONSTEXPR(y))

#define INT32_MULT_POF2_CONSTEXPR_VERIFY(x, y)      int32_t(int32_t(x) << INT32_LOG2_CONSTEXPR_VERIFY(y))
#define UINT32_MULT_POF2_CONSTEXPR_VERIFY(x, y)     uint32_t(uint32_t(x) << UINT32_LOG2_CONSTEXPR_VERIFY(y))

#define INT32_DIV_POF2_FLOOR_CONSTEXPR(x, y)        int32_t(int32_t(x) >> INT32_LOG2_FLOOR_CONSTEXPR(y))
#define UINT32_DIV_POF2_FLOOR_CONSTEXPR(x, y)       uint32_t(uint32_t(x) >> UINT32_LOG2_FLOOR_CONSTEXPR(y))
#define INT32_DIV_POF2_CEIL_CONSTEXPR(x, y)         int32_t(int32_t(x) >> INT32_LOG2_CEIL_CONSTEXPR(y))
#define UINT32_DIV_POF2_CEIL_CONSTEXPR(x, y)        uint32_t(uint32_t(x) >> UINT32_LOG2_CEIL_CONSTEXPR(y))

#define INT32_DIV_POF2_CONSTEXPR_VERIFY(x, y)       int32_t(int32_t(x) >> INT32_LOG2_CONSTEXPR_VERIFY(y))
#define UINT32_DIV_POF2_CONSTEXPR_VERIFY(x, y)      uint32_t(uint32_t(x) >> UINT32_LOG2_CONSTEXPR_VERIFY(y))
#define STDSIZE_DIV_POF2_CONSTEXPR_VERIFY(x, y)     std::size_t(std::size_t(x) >> STDSIZE_LOG2_CONSTEXPR_VERIFY(y))

#define INT32_DIVREM_POF2_FLOOR_CONSTEXPR_Y(x, y)   ::math::divrem<int32_t>{ INT32_DIV_POF2_FLOOR(x, y), int32_t(x) & (INT32_POF2_FLOOR_CONSTEXPR(y) - 1) }
#define UINT32_DIVREM_POF2_FLOOR_CONSTEXPR_Y(x, y)  ::math::divrem<uint32_t>{ UINT32_DIV_POF2_FLOOR(x, y), uint32_t(x) & (UINT32_POF2_FLOOR_CONSTEXPR(y) - 1) }
#define INT32_DIVREM_POF2_CEIL_CONSTEXPR_Y(x, y)    ::math::divrem<int32_t>{ INT32_DIV_POF2_CEIL(x, y), int32_t(x) & (INT32_POF2_CEIL_CONSTEXPR(y) - 1) }
#define UINT32_DIVREM_POF2_CEIL_CONSTEXPR_Y(x, y)   ::math::divrem<uint32_t>{ UINT32_DIV_POF2_CEIL(x, y), uint32_t(x) & (UINT32_POF2_CEIL_CONSTEXPR(y) - 1) }

#define INT32_DIVREM_POF2_FLOOR_CONSTEXPR_XY(x, y)  ::math::divrem<int32_t>{ INT32_DIV_POF2_FLOOR_CONSTEXPR(x, y), int32_t(x) & (INT32_POF2_FLOOR_CONSTEXPR(y) - 1) }
#define UINT32_DIVREM_POF2_FLOOR_CONSTEXPR_XY(x, y) ::math::divrem<uint32_t>{ UINT32_DIV_POF2_FLOOR_CONSTEXPR(x, y), uint32_t(x) & (UINT32_POF2_FLOOR_CONSTEXPR(y) - 1) }
#define INT32_DIVREM_POF2_CEIL_CONSTEXPR_XY(x, y)   ::math::divrem<int32_t>{ INT32_DIV_POF2_CEIL_CONSTEXPR(x, y), int32_t(x) & (INT32_POF2_CEIL_CONSTEXPR(y) - 1) }
#define UINT32_DIVREM_POF2_CEIL_CONSTEXPR_XY(x, y)  ::math::divrem<uint32_t>{ UINT32_DIV_POF2_CEIL_CONSTEXPR(x, y), uint32_t(x) & (UINT32_POF2_CEIL_CONSTEXPR(y) - 1) }

#define INT32_DIVREM_POF2_CONSTEXPR_VERIFY(x, y)   ::math::divrem<int32_t>{ INT32_DIV_POF2_CONSTEXPR_VERIFY(x, y), int32_t(x) & (INT32_POF2_CONSTEXPR_VERIFY(y) - 1) }
#define UINT32_DIVREM_POF2_CONSTEXPR_VERIFY(x, y)  ::math::divrem<uint32_t>{ UINT32_DIV_POF2_CONSTEXPR_VERIFY(x, y), uint32_t(x) & (UINT32_POF2_CONSTEXPR_VERIFY(y) - 1) }


#define INT32_MULT_POF2_FLOOR(x, y)                 int32_t(int32_t(x) << INT32_LOG2_FLOOR(y))
#define UINT32_MULT_POF2_FLOOR(x, y)                uint32_t(uint32_t(x) << UINT32_LOG2_FLOOR(y))
#define INT32_MULT_POF2_CEIL(x, y)                  int32_t(int32_t(x) << INT32_LOG2_CEIL(y))
#define UINT32_MULT_POF2_CEIL(x, y)                 uint32_t(uint32_t(x) << UINT32_LOG2_CEIL(y))

#define INT32_MULT_POF2_FLOOR_VERIFY(x, y)          int32_t(int32_t(x) << INT32_LOG2_FLOOR_VERIFY(y))
#define UINT32_MULT_POF2_FLOOR_VERIFY(x, y)         uint32_t(uint32_t(x) << UINT32_LOG2_FLOOR_VERIFY(y))
#define INT32_MULT_POF2_CEIL_VERIFY(x, y)           int32_t(int32_t(x) << INT32_LOG2_CEIL_VERIFY(y))
#define UINT32_MULT_POF2_CEIL_VERIFY(x, y)          uint32_t(uint32_t(x) << UINT32_LOG2_CEIL_VERIFY(y))

#define INT32_DIV_POF2_FLOOR(x, y)                  int32_t(int32_t(x) >> INT32_LOG2_FLOOR(y))
#define UINT32_DIV_POF2_FLOOR(x, y)                 uint32_t(uint32_t(x) >> UINT32_LOG2_FLOOR(y))
#define INT32_DIV_POF2_CEIL(x, y)                   int32_t(int32_t(x) >> INT32_LOG2_CEIL(y))
#define UINT32_DIV_POF2_CEIL(x, y)                  uint32_t(uint32_t(x) >> UINT32_LOG2_CEIL(y))

#define INT32_DIV_POF2_FLOOR_VERIFY(x, y)           int32_t(int32_t(x) >> INT32_LOG2_FLOOR_VERIFY(y))
#define UINT32_DIV_POF2_FLOOR_VERIFY(x, y)          uint32_t(uint32_t(x) >> UINT32_LOG2_FLOOR_VERIFY(y))
#define INT32_DIV_POF2_CEIL_VERIFY(x, y)            int32_t(int32_t(x) >> INT32_LOG2_CEIL_VERIFY(y))
#define UINT32_DIV_POF2_CEIL_VERIFY(x, y)           uint32_t(uint32_t(x) >> UINT32_LOG2_CEIL_VERIFY(y))

#define INT32_DIVREM_POF2_FLOOR(x, y)               ::math::divrem<int32_t>{ INT32_DIV_POF2_FLOOR(x, y), int32_t(x) & (INT32_POF2_FLOOR(y) - 1) }
#define UINT32_DIVREM_POF2_FLOOR(x, y)              ::math::divrem<uint32_t>{ UINT32_DIV_POF2_FLOOR(x, y), uint32_t(x) & (UINT32_POF2_FLOOR(y) - 1) }
#define INT32_DIVREM_POF2_CEIL(x, y)                ::math::divrem<int32_t>{ INT32_DIV_POF2_CEIL(x, y), int32_t(x) & (INT32_POF2_CEIL(y) - 1) }
#define UINT32_DIVREM_POF2_CEIL(x, y)               ::math::divrem<uint32_t>{ UINT32_DIV_POF2_CEIL(x, y), uint32_t(x) & (UINT32_POF2_CEIL(y) - 1) }

#define INT32_DIVREM_POF2_FLOOR_VERIFY(x, y)        ::math::divrem<int32_t>{ INT32_DIV_POF2_FLOOR_VERIFY(x, y), int32_t(x) & (INT32_POF2_FLOOR_VERIFY(y) - 1) }
#define UINT32_DIVREM_POF2_FLOOR_VERIFY(x, y)       ::math::divrem<uint32_t>{ UINT32_DIV_POF2_FLOOR_VERIFY(x, y), uint32_t(x) & (UINT32_POF2_FLOOR_VERIFY(y) - 1) }
#define INT32_DIVREM_POF2_CEIL_VERIFY(x, y)         ::math::divrem<int32_t>{ INT32_DIV_POF2_CEIL_VERIFY(x, y), int32_t(x) & (INT32_POF2_CEIL_VERIFY(y) - 1) }
#define UINT32_DIVREM_POF2_CEIL_VERIFY(x, y)        ::math::divrem<uint32_t>{ UINT32_DIV_POF2_CEIL_VERIFY(x, y), uint32_t(x) & (UINT32_POF2_CEIL_VERIFY(y) - 1) }


// input angle must not be a class, otherwise you have to use overload version of `pi` in another group of macroses

#define ANGLE_DEG_IN_RAD(angle_deg)                 ::math::angle_degrees_in_radians(angle_deg)
#define ANGLE_DEG_IN_RAD_IF(in_radians, angle_deg)  ((in_radians) ? ANGLE_DEG_IN_RAD(angle_deg) : (angle_deg))

#define ANGLE_RAD_IN_DEG(angle_rad)                 ::math::angle_radians_in_degrees(angle_rad)
#define ANGLE_RAD_IN_DEG_IF(in_degrees, angle_rad)  ((in_degrees) ? ANGLE_RAD_IN_DEG(angle_rad) : (angle_rad))

// value_type is required to intercept implicit cast to class arithmetic type

#define DEG_45_IN_RAD(type_angle)                   ::math::angle_degrees_in_radians(type_angle, ::utility::int_identity<45>())
#define DEG_45_IN_RAD_IF(type_angle, in_radians)    ((in_radians) ? DEG_45_IN_RAD(type_angle) : 45)

#define DEG_90_IN_RAD(type_angle)                   ::math::angle_degrees_in_radians(type_angle, ::utility::int_identity<90>())
#define DEG_90_IN_RAD_IF(type_angle, in_radians)    ((in_radians) ? DEG_90_IN_RAD(type_angle) : 90)

#define DEG_135_IN_RAD(type_angle)                  ::math::angle_degrees_in_radians(type_angle, ::utility::int_identity<135>())
#define DEG_135_IN_RAD_IF(type_angle, in_radians)   ((in_radians) ? DEG_135_IN_RAD(type_angle) : 135)

#define DEG_180_IN_RAD(type_angle)                  ::math::angle_degrees_in_radians(type_angle, ::utility::int_identity<180>())
#define DEG_180_IN_RAD_IF(type_angle, in_radians)   ((in_radians) ? DEG_180_IN_RAD(type_angle) : 180)

#define DEG_225_IN_RAD(type_angle)                  ::math::angle_degrees_in_radians(type_angle, ::utility::int_identity<225>())
#define DEG_225_IN_RAD_IF(type_angle, in_radians)   ((in_radians) ? DEG_225_IN_RAD(type_angle) : 225)

#define DEG_270_IN_RAD(type_angle)                  ::math::angle_degrees_in_radians(type_angle, ::utility::int_identity<270>())
#define DEG_270_IN_RAD_IF(type_angle, in_radians)   ((in_radians) ? DEG_270_IN_RAD(type_angle) : 270)

#define DEG_315_IN_RAD(type_angle)                  ::math::angle_degrees_in_radians(type_angle, ::utility::int_identity<315>())
#define DEG_315_IN_RAD_IF(type_angle, in_radians)   ((in_radians) ? DEG_315_IN_RAD(type_angle) : 315)

#define DEG_360_IN_RAD(type_angle)                  ::math::angle_degrees_in_radians(type_angle, ::utility::int_identity<360>())
#define DEG_360_IN_RAD_IF(type_angle, in_radians)   ((in_radians) ? DEG_360_IN_RAD(type_angle) : 360)

#define DEG_720_IN_RAD(type_angle)                  ::math::angle_degrees_in_radians(type_angle, ::utility::int_identity<720>())
#define DEG_720_IN_RAD_IF(type_angle, in_radians)   ((in_radians) ? DEG_720_IN_RAD(type_angle) : 720)

// in case if pi has storaged in custom arithmetic type

#define ANGLE_DEG_IN_RAD2(angle_deg, pi)            ::math::angle_degrees_in_radians(angle_deg, pi)
#define ANGLE_DEG_IN_RAD2_IF(in_radians, angle_deg, pi) ((in_radians) ? ANGLE_DEG_IN_RAD2(angle_deg, pi) : (angle_deg))

#define ANGLE_RAD_IN_DEG2(angle_rad, pi)            ::math::angle_radians_in_degrees(angle_rad, pi)
#define ANGLE_RAD_IN_DEG2_IF(in_degrees, angle_rad, pi) ((in_degrees) ? ANGLE_RAD_IN_DEG2(angle_rad, pi) : (angle_rad))

#define DEG_45_IN_RAD2(type_angle, pi)              ::math::angle_degrees_in_radians(type_angle, pi, ::utility::int_identity<45>())
#define DEG_45_IN_RAD2_IF(in_radians, type_angle, pi)   ((in_radians) ? DEG_45_IN_RAD2(type_angle, pi) : 45)

#define DEG_90_IN_RAD2(type_angle, pi)              ::math::angle_degrees_in_radians(type_angle, pi, ::utility::int_identity<90>())
#define DEG_90_IN_RAD2_IF(in_radians, type_angle, pi)   ((in_radians) ? DEG_90_IN_RAD2(type_angle, pi) : 90)

#define DEG_135_IN_RAD2(type_angle, pi)             ::math::angle_degrees_in_radians(type_angle, pi, ::utility::int_identity<135>())
#define DEG_135_IN_RAD2_IF(in_radians, type_angle, pi)  ((in_radians) ? DEG_135_IN_RAD2(type_angle, pi) : 135)

#define DEG_180_IN_RAD2(type_angle, pi)             ::math::angle_degrees_in_radians(type_angle, pi, ::utility::int_identity<180>())
#define DEG_180_IN_RAD2_IF(in_radians, type_angle, pi)  ((in_radians) ? DEG_180_IN_RAD2(type_angle, pi) : 180)

#define DEG_225_IN_RAD2(type_angle, pi)             ::math::angle_degrees_in_radians(type_angle, pi, ::utility::int_identity<225>())
#define DEG_225_IN_RAD2_IF(in_radians, type_angle, pi)  ((in_radians) ? DEG_225_IN_RAD2(type_angle, pi) : 225)

#define DEG_270_IN_RAD2(type_angle, pi)             ::math::angle_degrees_in_radians(type_angle, pi, ::utility::int_identity<270>())
#define DEG_270_IN_RAD2_IF(in_radians, type_angle, pi)  ((in_radians) ? DEG_270_IN_RAD2(type_angle, pi) : 270)

#define DEG_315_IN_RAD2(type_angle, pi)             ::math::angle_degrees_in_radians(type_angle, pi, ::utility::int_identity<315>())
#define DEG_315_IN_RAD2_IF(in_radians, type_angle, pi)  ((in_radians) ? DEG_315_IN_RAD2(type_angle, pi) : 315)

#define DEG_360_IN_RAD2(type_angle, pi)             ::math::angle_degrees_in_radians(type_angle, pi, ::utility::int_identity<360>())
#define DEG_360_IN_RAD2_IF(in_radians, type_angle, pi)  ((in_radians) ? DEG_360_IN_RAD2(type_angle, pi) : 360)

#define DEG_720_IN_RAD2(type_angle, pi)             ::math::angle_degrees_in_radians(type_angle, pi, ::utility::int_identity<720>())
#define DEG_720_IN_RAD2_IF(in_radians, type_angle, pi)  ((in_radians) ? DEG_720_IN_RAD2(type_angle, pi) : 720)


// implementation through the define to reuse code in debug and avoid performance slow down in particular usage places
#define INT32_POF2_FLOOR_MACRO_INLINE(return_exp, type_, v) \
{ \
    \
    static_assert(::std::is_integral<type_>::value, "type must be an integer"); \
    \
    STATIC_ASSERT_GE(4, sizeof(v), "general implementation only for integers which sizeof is not greater than 4 bytes"); \
    DEBUG_VERIFY_GT(v, (type_)(0)); \
    \
    using unsigned_type = typename ::std::make_unsigned<type_>::type; \
    unsigned_type unsigned_value = unsigned_type(v); \
    \
    unsigned_value |= (unsigned_value >> 1); \
    unsigned_value |= (unsigned_value >> 2); \
    unsigned_value |= (unsigned_value >> 4); \
    unsigned_value |= (unsigned_value >> 8); \
    unsigned_value |= (unsigned_value >> 16); \
    \
    const type_ shifted_value = (type_)(unsigned_value >> 1); \
    \
    return_exp (type_)(shifted_value + 1); \
} (void)0

#define INT32_POF2_CEIL_MACRO_INLINE(return_exp, type_, v) \
{ \
    \
    static_assert(::std::is_integral<type_>::value, "type must be an integer"); \
    \
    DEBUG_ASSERT_GT(v, (type_)(0)); \
    DEBUG_ASSERT_GE(::std::is_unsigned<type_>::value ? v : ((::std::numeric_limits<type_>::max)() / 2), v); \
    \
    type_ pof2_floor_value; \
    INT32_POF2_FLOOR_MACRO_INLINE(pof2_floor_value =, type_, v); \
    \
    return_exp (pof2_floor_value != v ? (type_)(pof2_floor_value << 1) : pof2_floor_value); \
} (void)0

#define INT32_LOG2_FLOOR_MACRO_INLINE(return_exp, type_, v, pof2_value_ptr) \
if_break(true) \
{ \
    \
    static_assert(::std::is_integral<type_>::value, "type must be an integer"); \
    \
    STATIC_ASSERT_GE(4, sizeof(v), "general implementation only for numbers which sizeof is not greater than 4 bytes"); \
    DEBUG_ASSERT_GT(v, (type_)(0)); \
    \
    type_ * pof2_value_ptr_ = (pof2_value_ptr); \
    \
    if ((type_)(1) >= v) { \
        if (pof2_value_ptr_) { \
            if (v >= (type_)(0)) { \
                *pof2_value_ptr_ = v; \
            } \
            else { \
                *pof2_value_ptr_ = (type_)(0); \
            } \
        } \
        return_exp (type_)(0); \
        break; \
    } \
    \
    type_ pof2_prev_value; \
    INT32_POF2_FLOOR_MACRO_INLINE(pof2_prev_value =, type_, v); \
    \
    if (pof2_value_ptr_) { \
        *pof2_value_ptr_ = pof2_prev_value; \
    } \
    \
    type_ ret = (type_)(0); \
    \
    /* unrolled recursion including unrolled loops */ \
    type_ pof2_next_value = (pof2_prev_value >> 16); \
    \
    if (pof2_next_value) { \
        ret += 16; \
        pof2_prev_value = pof2_next_value; \
        pof2_next_value >>= 8; \
    } \
    else pof2_next_value = (pof2_prev_value >> 8); \
    \
    if (pof2_next_value) { \
        ret += 8; \
        pof2_prev_value = pof2_next_value; \
        pof2_next_value >>= 4; \
    } \
    else { \
        pof2_next_value = (pof2_prev_value >> 4); \
    } \
    \
    if (pof2_next_value) { \
        ret += 4; \
        pof2_prev_value = pof2_next_value; \
        pof2_next_value >>= 2; \
    } \
    else { \
        pof2_next_value = (pof2_prev_value >> 2); \
    } \
    \
    if (pof2_next_value) { \
        ret += 2; \
        pof2_next_value >>= 1; \
    } \
    else { \
        pof2_next_value = (pof2_prev_value >> 1); \
    } \
    \
    if (pof2_next_value) ret++; \
    \
    return_exp ret; \
} (void)0

#define INT32_LOG2_CEIL_MACRO_INLINE(return_exp, type_, v, pof2_value_ptr) \
if_break(true) \
{ \
    \
    static_assert(::std::is_integral<type_>::value, "type must be an integer"); \
    \
    DEBUG_ASSERT_GT(v, (type_)(0)); \
    DEBUG_ASSERT_GE(::std::is_unsigned<type_>::value ? v : ((::std::numeric_limits<type_>::max)() / 2), v); \
    \
    type_ * pof2_value_ptr_ = (pof2_value_ptr); \
    \
    if ((type_)(1) >= v) { \
        if (pof2_value_ptr_) { \
            if (v >= (type_)(0)) { \
                *pof2_value_ptr_ = v; \
            } \
            else { \
                *pof2_value_ptr_ = (type_)(0); \
            } \
        } \
        return_exp (type_)(0); \
        break; \
    } \
    \
    type_ log2_prev_value = (type_)(v - 1); \
    type_ log2_floor_value; \
    \
    if (!pof2_value_ptr_) { \
        INT32_LOG2_FLOOR_MACRO_INLINE(log2_floor_value =, type_, log2_prev_value, nullptr); \
    } \
    else { \
        type_ pof2_floor_value; \
        \
        INT32_LOG2_FLOOR_MACRO_INLINE(log2_floor_value =, type_, log2_prev_value, &pof2_floor_value); \
        \
        *pof2_value_ptr_ = (type_)(pof2_floor_value << 1); \
    } \
    \
    return_exp (type_)(log2_floor_value + 1); \
} (void)0


#ifndef TO_DOUBLE_DEFINED
#define TO_DOUBLE_DEFINED

FORCE_INLINE int to_double(int i)
{
    return i;
}

FORCE_INLINE long to_double(long i)
{
    return i;
}

FORCE_INLINE int64_t to_double(int64_t i)
{
    return i;
}

FORCE_INLINE double to_double(double d)
{
    return d;
}

#endif

namespace math
{
    // shortcuts
    const CONSTEXPR char char_min               = (std::numeric_limits<char>::min)();
    const CONSTEXPR char char_max               = (std::numeric_limits<char>::max)();

    const CONSTEXPR unsigned char uchar_max     = (std::numeric_limits<unsigned char>::max)();

    const CONSTEXPR short short_min             = (std::numeric_limits<short>::min)();
    const CONSTEXPR short short_max             = (std::numeric_limits<short>::max)();

    const CONSTEXPR unsigned short ushort_max   = (std::numeric_limits<unsigned short>::max)();

    const CONSTEXPR int int_min                 = (std::numeric_limits<int>::min)();
    const CONSTEXPR int int_max                 = (std::numeric_limits<int>::max)();

    const CONSTEXPR unsigned int uint_max       = (std::numeric_limits<unsigned int>::max)();

    const CONSTEXPR long long_min               = (std::numeric_limits<long>::min)();
    const CONSTEXPR long long_max               = (std::numeric_limits<long>::max)();

    const CONSTEXPR unsigned long ulong_max     = (std::numeric_limits<unsigned long>::max)();

#ifdef UTILITY_PLATFORM_FEATURE_CXX_STANDARD_LLONG
    const CONSTEXPR long long longlong_min      = (std::numeric_limits<long long>::min)();
    const CONSTEXPR long long longlong_max      = (std::numeric_limits<long long>::max)();
#endif
#ifdef UTILITY_PLATFORM_FEATURE_CXX_STANDARD_ULLONG
    const CONSTEXPR unsigned long long ulonglong_max = (std::numeric_limits<unsigned long long>::max)();
#endif

    const CONSTEXPR int8_t int8_min             = (std::numeric_limits<int8_t>::min)();
    const CONSTEXPR int8_t int8_max             = (std::numeric_limits<int8_t>::max)();

    const CONSTEXPR uint8_t uint8_max           = (std::numeric_limits<uint8_t>::max)();

    const CONSTEXPR int16_t int16_min           = (std::numeric_limits<int16_t>::min)();
    const CONSTEXPR int16_t int16_max           = (std::numeric_limits<int16_t>::max)();

    const CONSTEXPR uint16_t uint16_max         = (std::numeric_limits<uint16_t>::max)();

    const CONSTEXPR int32_t int32_min           = (std::numeric_limits<int32_t>::min)();
    const CONSTEXPR int32_t int32_max           = (std::numeric_limits<int32_t>::max)();

    const CONSTEXPR uint32_t uint32_max         = (std::numeric_limits<uint32_t>::max)();

    const CONSTEXPR int64_t int64_min           = (std::numeric_limits<int64_t>::min)();
    const CONSTEXPR int64_t int64_max           = (std::numeric_limits<int64_t>::max)();

    const CONSTEXPR uint64_t uint64_max         = (std::numeric_limits<uint64_t>::max)();

    const CONSTEXPR size_t size_max             = (std::numeric_limits<size_t>::max)();

    const CONSTEXPR float float_quiet_NaN       = (std::numeric_limits<float>::quiet_NaN)();
    const CONSTEXPR double double_quiet_NaN     = (std::numeric_limits<double>::quiet_NaN)();

    const CONSTEXPR float float_min             = (std::numeric_limits<float>::min)();
    const CONSTEXPR float float_max             = (std::numeric_limits<float>::max)();

    const CONSTEXPR double double_min           = (std::numeric_limits<double>::min)();
    const CONSTEXPR double double_max           = (std::numeric_limits<double>::max)();

    template<typename T>
    struct divrem
    {
        T quot;
        T rem;
    };

    //// constexpr min/max

    template <typename T, T x, T y>
    struct basic_min_of
    {
        static CONSTEXPR const T value = (x < y ? x : y);
    };

    template <typename T, T x, T y>
    struct basic_max_of
    {
        static CONSTEXPR const T value = (x < y ? y : x);
    };

    template <int32_t x, int32_t y>
    struct int32_min_of : basic_min_of<int32_t, x, y>
    {
    };

    template <int32_t x, int32_t y>
    struct int32_max_of : basic_max_of<int32_t, x, y>
    {
    };

    template <size_t x, size_t y>
    struct size_min_of : basic_min_of<size_t, x, y>
    {
    };

    template <size_t x, size_t y>
    struct size_max_of : basic_max_of<size_t, x, y>
    {
    };

    //// constexpr log2 floor

    template<int32_t x>
    struct int32_log2_floor
    {
        STATIC_ASSERT_GT(x, 0, "value must be positive");
        static CONSTEXPR const int32_t value = (int32_log2_floor<x / 2>::value + 1);
    };

    template<int32_t x>
    const int32_t int32_log2_floor<x>::value;

    template<>
    struct int32_log2_floor<0>;
    template<>
    struct int32_log2_floor<1>
    {
        static CONSTEXPR const int32_t value = 0;
    };

    template<uint32_t x>
    struct uint32_log2_floor
    {
        static CONSTEXPR const uint32_t value = (uint32_log2_floor<x / 2>::value + 1);
    };

    template<uint32_t x>
    const uint32_t uint32_log2_floor<x>::value;

    template<>
    struct uint32_log2_floor<0>;
    template<>
    struct uint32_log2_floor<1>
    {
        static CONSTEXPR const uint32_t value = 0;
    };

    template<std::size_t x>
    struct stdsize_log2_floor
    {
        static CONSTEXPR const std::size_t value = (stdsize_log2_floor<x / 2>::value + 1);
    };

    template<std::size_t x>
    const std::size_t stdsize_log2_floor<x>::value;

    template<>
    struct stdsize_log2_floor<0>;
    template<>
    struct stdsize_log2_floor<1>
    {
        static CONSTEXPR const std::size_t value = 0;
    };

    //// constexpr log2 ceil

    template<int32_t x>
    struct int32_log2_ceil
    {
        STATIC_ASSERT_GT(x, 0, "value must be positive");
        STATIC_ASSERT_TRUE2(int32_max / 2 >= x, int32_max, x, "value is too big");
        static CONSTEXPR const int32_t value = (int32_log2_floor<(x + x - 1) / 2>::value + 1);
    };

    template<int32_t x>
    const int32_t int32_log2_ceil<x>::value;

    template<>
    struct int32_log2_ceil<0>;
    template<>
    struct int32_log2_ceil<1>
    {
        static CONSTEXPR const int32_t value = 0;
    };

    template<uint32_t x>
    struct uint32_log2_ceil
    {
        STATIC_ASSERT_TRUE2(uint32_max / 2 >= x, uint32_max, x, "value is too big");
        static CONSTEXPR const uint32_t value = (uint32_log2_floor<(x + x - 1) / 2>::value + 1);
    };

    template<uint32_t x>
    const uint32_t uint32_log2_ceil<x>::value;

    template<>
    struct uint32_log2_ceil<0>;
    template<>
    struct uint32_log2_ceil<1>
    {
        static CONSTEXPR const uint32_t value = 0;
    };

    //// constexpr log2 assert

    template<int32_t x>
    struct int32_log2_verify
    {
        STATIC_ASSERT_TRUE1(x && !(x & (x - 1)), x, "value must be power of 2");
        static CONSTEXPR const int32_t value = int32_log2_floor<x>::value;
    };

    template<int32_t x>
    const int32_t int32_log2_verify<x>::value;

    template<uint32_t x>
    struct uint32_log2_verify
    {
        STATIC_ASSERT_TRUE1(x && !(x & (x - 1)), x, "value must be power of 2");
        static CONSTEXPR const uint32_t value = uint32_log2_floor<x>::value;
    };

    template<uint32_t x>
    const uint32_t uint32_log2_verify<x>::value;

    template<std::size_t x>
    struct stdsize_log2_verify
    {
        STATIC_ASSERT_TRUE1(x && !(x & (x - 1)), x, "value must be power of 2");
        static CONSTEXPR const std::size_t value = stdsize_log2_floor<x>::value;
    };

    template<std::size_t x>
    const std::size_t stdsize_log2_verify<x>::value;

    //// constexpr pof2 floor

    template<uint32_t x>
    struct uint32_pof2_floor;

    template<int32_t x>
    struct int32_pof2_floor
    {
        static CONSTEXPR const int32_t value = int32_t(uint32_pof2_floor<uint32_t(x)>::value);
    };

    template<>
    struct int32_pof2_floor<0>;

    template<int32_t x>
    const int32_t int32_pof2_floor<x>::value;

    template<uint32_t x>
    struct uint32_pof2_floor
    {
        using x1_t = std::integral_constant<uint32_t, x | (x >> 1)>;
        using x2_t = std::integral_constant<uint32_t, x1_t::value | (x1_t::value >> 2)>;
        using x4_t = std::integral_constant<uint32_t, x2_t::value | (x2_t::value >> 4)>;
        using x8_t = std::integral_constant<uint32_t, x4_t::value | (x4_t::value >> 8)>;
        using x16_t = std::integral_constant<uint32_t, x8_t::value | (x8_t::value >> 16)>;

        static CONSTEXPR const uint32_t value = (x16_t::value >> 1) + 1;
    };

    template<>
    struct uint32_pof2_floor<0>;

    template<uint32_t x>
    const uint32_t uint32_pof2_floor<x>::value;

    //// constexpr pof2 ceil

    template<uint32_t x>
    struct uint32_pof2_ceil;

    template<int32_t x>
    struct int32_pof2_ceil
    {
        static CONSTEXPR const int32_t value = int32_t(uint32_pof2_ceil<uint32_t(x)>::value);
    };

    template<int32_t x>
    const int32_t int32_pof2_ceil<x>::value;

    template<uint32_t x>
    struct uint32_pof2_ceil
    {
        using uint32_pof2_floor_t = uint32_pof2_floor<x>;
        static CONSTEXPR const uint32_t value = uint32_pof2_floor_t::value != x ? (uint32_pof2_floor_t::value << 1) : uint32_pof2_floor_t::value;
    };

    template<uint32_t x>
    const uint32_t uint32_pof2_ceil<x>::value;

    //// constexpr pof2 assert

    template<int32_t x>
    struct int32_pof2_verify
    {
        STATIC_ASSERT_TRUE1(x && !(x & (x - 1)), x, "value must be power of 2");
        static CONSTEXPR const int32_t value = x;
    };

    template<int32_t x>
    const int32_t int32_pof2_verify<x>::value;

    template<uint32_t x>
    struct uint32_pof2_verify
    {
        STATIC_ASSERT_TRUE1(x && !(x & (x - 1)), x, "value must be power of 2");
        static CONSTEXPR const uint32_t value = x;
    };

    template<uint32_t x>
    const uint32_t uint32_pof2_verify<x>::value;


    // sign convertion into -1,0,+1 integer
    template <typename T>
    FORCE_INLINE CONSTEXPR_RETURN int sign_to_int(const T & v)
    {
        return (
            v > 0 ?
                +1 :
                v < 0 ?
                    -1 :
                    0
        );
    }

    // sign convertion into sign character: -1 -> `-`, 0 -> ` `, +1 -> `+`
    template <typename T>
    FORCE_INLINE CONSTEXPR_RETURN char sign_to_char(const T & v)
    {
        return (
            v > 0 ?
                '+' :
                v < 0 ?
                    '-' :
                    ' '
        );
    }

    // sign convertion into sign character: -1 -> ` `, 0 -> ` `, +1 -> `+`
    template <typename T>
    FORCE_INLINE CONSTEXPR_RETURN char sign_to_positive_char(const T & v)
    {
        return (
            v > 0 ?
                '+' :
                ' '
        );
    }

    // sign convertion into sign character: -1 -> `-`, 0 -> ` `, +1 -> ` `
    template <typename T>
    FORCE_INLINE CONSTEXPR_RETURN char sign_to_negative_char(const T & v)
    {
        return (
            v < 0 ?
                '-' :
                ' '
        );
    }

    // the bool type is exceptional
    FORCE_INLINE_ALWAYS CONSTEXPR_RETURN bool negate(bool v)
    {
        // The false is the same as zero, which have no effect of negation.
        // The true is the same as not zero, negates to a non zero value, which is still true and have no effect of negation too.
        return v;
    }

#ifndef UTILITY_PLATFORM_FEATURE_CXX_STANDARD_CPP14
    // to suppress compilation warning:
    //  `warning C4146 : unary minus operator applied to unsigned type, result still unsigned`
    FORCE_INLINE_ALWAYS CONSTEXPR_RETURN unsigned int negate(unsigned int i)
    {
        return static_cast<unsigned int>(-static_cast<int>(i));
    }

    FORCE_INLINE_ALWAYS CONSTEXPR_RETURN unsigned long negate(unsigned long i)
    {
        return static_cast<unsigned long>(-static_cast<long>(i));
    }

#ifdef UTILITY_PLATFORM_FEATURE_CXX_STANDARD_ULLONG
    // must be template to make `enable_if` dependent on a type substitution
    template <typename T>
    FORCE_INLINE_ALWAYS CONSTEXPR_RETURN
        typename utility::dependent_enable_if<!std::is_same<unsigned long long, uint64_t>::value, unsigned long long, T>::type
            negate(unsigned long long i, T = utility::int_identity<0>{}) // `utility::int_identity<0>` for `unsigned long long`
    {
        return static_cast<unsigned long long>(-static_cast<long long>(i));
    }
#endif

    FORCE_INLINE_ALWAYS CONSTEXPR_RETURN int negate(int i)
    {
        return -i;
    }

    FORCE_INLINE_ALWAYS CONSTEXPR_RETURN long negate(long i)
    {
        return -i;
    }

#ifdef UTILITY_PLATFORM_FEATURE_CXX_STANDARD_LLONG
    // must be template to make `enable_if` dependent on a type substitution
    template <typename T>
    FORCE_INLINE_ALWAYS CONSTEXPR_RETURN
        typename utility::dependent_enable_if<!std::is_same<long long, int64_t>::value, long long, T>::type
            negate(long long i, T = utility::int_identity<1>{}) // `utility::int_identity<1>` for `long long`
    {
        return -i;
    }
#endif

    FORCE_INLINE_ALWAYS CONSTEXPR_RETURN int64_t negate(int64_t i)
    {
        return -i;
    }

    FORCE_INLINE_ALWAYS CONSTEXPR_RETURN int64_t negate(uint64_t i)
    {
        return static_cast<uint64_t>(-static_cast<int64_t>(i));
    }

    FORCE_INLINE_ALWAYS CONSTEXPR_RETURN float negate(float v)
    {
        return -v;
    }

    FORCE_INLINE_ALWAYS CONSTEXPR_RETURN double negate(double v)
    {
        return -v;
    }

    template <typename T>
    FORCE_INLINE_ALWAYS CONSTEXPR_RETURN T negate(const T & v)
    {
        return -v;
    }

#else

    // negate helper to avoid warnings around negation of unsigned values
    namespace detail
    {
        template <bool is_signed, bool is_make_signed_valid, typename T>
        struct _negate;

        template <bool is_make_signed_valid, typename T>
        struct _negate<true, is_make_signed_valid, T>
        {
            using type = T;

            static CONSTEXPR_RETURN T invoke(const type & v)
            {
                return std::negate<>()(v);
            }
        };

        template <typename T>
        struct _negate<false, true, T>
        {
            using type = T;

            static CONSTEXPR_RETURN T invoke(const type & v)
            {
                // can be unsigned but castable to signed
                return static_cast<typename std::make_unsigned<T>::type>(
                    std::negate<>()(
                        static_cast<typename std::make_signed<T>::type>(v)));
            }
        };

        template <typename T>
        struct _negate<true, true, T>
        {
            using type = T;

            static CONSTEXPR_RETURN T invoke(const type & v)
            {
                return std::negate<>()(v);
            }
        };

        // the bool type is exceptional
        template <bool is_signed, bool is_make_signed_valid>
        struct _negate<is_signed, is_make_signed_valid, bool>
        {
            using type = bool;

            static CONSTEXPR_RETURN bool invoke(bool v)
            {
                // The false is the same as zero, which have no effect of negation.
                // The true is the same as not zero, negates to a non zero value, which is still true and have no effect of negation too.
                return v;
            }
        };

        template <typename T>
        struct _negate<false, false, T>
        {
            using type = T;

            // make static assert function template parameter dependent
            // (still ill-formed, see: https://stackoverflow.com/questions/30078818/static-assert-dependent-on-non-type-template-parameter-different-behavior-on-gc)
            static_assert(sizeof(type) && false, "type T must be signed or at least castable to signed through the std::make_signed");

            static CONSTEXPR_RETURN T invoke(const type & v)
            {
                return std::negate<>()(v); // just in case
            }
        };
    }

    template <typename T>
    FORCE_INLINE_ALWAYS CONSTEXPR_RETURN T negate(const T & v)
    {
        return detail::_negate<std::is_signed<T>::value, utility::is_make_signed_valid<T>::value, T>::invoke(v);
    }
#endif

    template <typename T>
    FORCE_INLINE CONSTEXPR_RETURN auto make_signed_from(T v) -> decltype(static_cast<std::make_signed<T>::type>(v))
    {
        return static_cast<std::make_signed<T>::type>(v);
    }

    template <typename T>
    FORCE_INLINE CONSTEXPR_RETURN T positive_max(const T & v = T())
    {
        return (std::numeric_limits<T>::max)();
    }

    template <typename T>
    FORCE_INLINE CONSTEXPR_RETURN T positive_min(const T & v = T())
    {
        return (
            std::is_floating_point<T>::value ?
                (std::numeric_limits<T>::min)() :
                (std::numeric_limits<T>::min)() + 1
        );
    }

    template <typename T>
    FORCE_INLINE CONSTEXPR_RETURN T negative_max(const T & v = T())
    {
        static_assert(std::is_signed<T>::value, "type T must be signed");

        return (
            std::is_floating_point<T>::value ?
                -(std::numeric_limits<T>::min)() :
                math::negate((std::numeric_limits<typename std::make_unsigned<T>::type>::min)() + 1)
        );
    }

    template <typename T>
    FORCE_INLINE CONSTEXPR_RETURN T negative_min(const T & v = T())
    {
        static_assert(std::is_signed<T>::value, "type T must be signed");

        return (
            std::is_floating_point<T>::value ?
                -(std::numeric_limits<T>::max)() :
                (std::numeric_limits<T>::min)()
        );
    }

    namespace detail
    {
        // use set of guesses to request type scoped pi-function implementation before call to uniform pi calculation logic
        DEFINE_UTILITY_STATIC_MEMBER_FUNCTION_CHECKER_WITH_SIGNATURE(check_type_pi_static_func_variant_0, _pi)  // func variant 000
        DEFINE_UTILITY_STATIC_MEMBER_FUNCTION_CHECKER_WITH_SIGNATURE(check_type_pi_static_func_variant_1, pi)   // func variant 001
        DEFINE_UTILITY_STATIC_MEMBER_FUNCTION_CHECKER_WITH_SIGNATURE(check_type_pi_static_func_variant_2, pi_)  // func variant 002
        DEFINE_UTILITY_STATIC_MEMBER_DATA_CHECKER_WITH_SIGNATURE(check_type_pi_static_data_variant_0, _pi)      // data variant 100
        DEFINE_UTILITY_STATIC_MEMBER_DATA_CHECKER_WITH_SIGNATURE(check_type_pi_static_data_variant_1, pi)       // data variant 101
        DEFINE_UTILITY_STATIC_MEMBER_DATA_CHECKER_WITH_SIGNATURE(check_type_pi_static_data_variant_2, pi_)      // data variant 102

        // uniform pi calculation logic
        template <size_t variant_index>
        struct pi;

        // by value signature
        template <typename FuncScopeType, typename FuncRetType, typename DataType>
        using pi_by_value_t =
            typename std::conditional<check_type_pi_static_func_variant_0<FuncScopeType, FuncRetType()>::value,
                utility::size_identity<0>,
                typename std::conditional<check_type_pi_static_func_variant_1<FuncScopeType, FuncRetType()>::value,
                    utility::size_identity<1>,
                    typename std::conditional<check_type_pi_static_func_variant_2<FuncScopeType, FuncRetType()>::value,
                        utility::size_identity<2>,
                        typename std::conditional<check_type_pi_static_data_variant_0<FuncScopeType, DataType>::value,
                            utility::size_identity<100>,
                            typename std::conditional<check_type_pi_static_data_variant_1<FuncScopeType, DataType>::value,
                                utility::size_identity<101>,
                                typename std::conditional<check_type_pi_static_data_variant_2<FuncScopeType, DataType>::value,
                                    utility::size_identity<102>,
                                    utility::size_identity<size_max>
                                >::type
                            >::type
                        >::type
                    >::type
                >::type
            >::type;

        template <typename FuncScopeType, typename FuncRetType, typename DataType>
        using pi_by_const_reference_t =
            typename std::conditional<check_type_pi_static_func_variant_0<FuncScopeType, const FuncRetType &()>::value,
                utility::size_identity<0>,
                typename std::conditional<check_type_pi_static_func_variant_1<FuncScopeType, const FuncRetType &()>::value,
                    utility::size_identity<1>,
                    typename std::conditional<check_type_pi_static_func_variant_2<FuncScopeType, const FuncRetType &()>::value,
                        utility::size_identity<2>,
                        typename std::conditional<check_type_pi_static_data_variant_0<FuncScopeType, const DataType &>::value,
                            utility::size_identity<100>,
                            typename std::conditional<check_type_pi_static_data_variant_1<FuncScopeType, const DataType &>::value,
                                utility::size_identity<101>,
                                typename std::conditional<check_type_pi_static_data_variant_2<FuncScopeType, const DataType &>::value,
                                    utility::size_identity<102>,
                                    utility::size_identity<size_max>
                                >::type
                            >::type
                        >::type
                    >::type
                >::type
            >::type;

        template <typename FuncScopeType, typename FuncRetType, typename DataType>
        using pi_t =
            typename std::conditional<
                std::is_class<FuncScopeType>::value,
                typename std::conditional<
                    pi_by_value_t<FuncScopeType, FuncRetType, DataType>::value != size_max,
                    utility::size_identity<pi_by_value_t<FuncScopeType, FuncRetType, DataType>::value>,
                    utility::size_identity<pi_by_const_reference_t<FuncScopeType, FuncRetType, DataType>::value>
                >::type,
                utility::size_identity<size_max>
            >::type;

        // Uniform pi calculation logic.
        // Based on: https://stackoverflow.com/questions/1727881/how-to-use-the-pi-constant-in-c/1728959
        //
        template <>
        struct pi<size_max>
        {
            template <typename T>
            static CONSTEXPR_RETURN auto get(const T & = T()) ->
                decltype(std::acos(T{ -1 }))
            {
                return std::acos(T{ -1 });
            }
        };

        template <>
        struct pi<0>
        {
            template <typename T>
            static CONSTEXPR_RETURN auto get(const T & = T()) ->
                decltype(T::_pi())
            {
                return T::_pi();
            }
        };

        template <>
        struct pi<1>
        {
            template <typename T>
            static CONSTEXPR_RETURN auto get(const T & = T()) ->
                decltype(T::pi())
            {
                return T::pi();
            }
        };

        template <>
        struct pi<2>
        {
            template <typename T>
            static CONSTEXPR_RETURN auto get(const T & = T()) ->
                decltype(T::pi_())
            {
                return T::pi_();
            }
        };

        template <>
        struct pi<100>
        {
            template <typename T>
            static CONSTEXPR_RETURN auto get(const T & = T()) ->
                decltype(T::_pi)
            {
                return T::_pi;
            }
        };

        template <>
        struct pi<101>
        {
            template <typename T>
            static CONSTEXPR_RETURN auto get(const T & = T()) ->
                decltype(T::pi)
            {
                return T::pi;
            }
        };

        template <>
        struct pi<102>
        {
            template <typename T>
            static CONSTEXPR_RETURN auto get(const T & = T()) ->
                decltype(T::pi_)
            {
                return T::pi_;
            }
        };
    }

    // uniform pi-constant getter
    template <typename T>
    FORCE_INLINE CONSTEXPR_RETURN auto pi(const T & v = T()) ->
        decltype(detail::pi<detail::pi_t<T, T, T>::value>::get(v))
    {
        return TACKLE_STATIC_CONSTEXPR_VALUE_WITH_INITER(T, detail::pi<detail::pi_t<T, T, T>::value>::get(v));
    }

    FORCE_INLINE CONSTEXPR_RETURN float pi(float v = float())
    {
        return TACKLE_STATIC_CONSTEXPR_VALUE_WITH_INITER(float, detail::pi<detail::pi_t<float, float, float>::value>::get(v));
    }

    FORCE_INLINE CONSTEXPR_RETURN double pi(double v = double())
    {
        return TACKLE_STATIC_CONSTEXPR_VALUE_WITH_INITER(double, detail::pi<detail::pi_t<double, double, double>::value>::get(v));
    }

    template <typename T>
    FORCE_INLINE CONSTEXPR_RETURN T is_signed_min_max(const T & v)
    {
        static_assert(std::is_signed<T>::value, "type T must be signed");

        return (positive_max(v) == v || negative_min(v) == v);
    }

    template <typename T>
    FORCE_INLINE CONSTEXPR_RETURN T is_unsigned_min_max(const T & v)
    {
        static_assert(std::is_unsigned<T>::value, "type T must be unsigned");

        return (!v || positive_max<T>(v) == v);
    }

    template <typename T>
    FORCE_INLINE CONSTEXPR_RETURN bool is_valid_float(const T & v)
    {
        static_assert(std::is_floating_point<T>::value, "type T must be float");

        return (std::isnormal(v) && positive_max(v) != v && negative_min(v) != v || v == 0.0);
    }

    template <typename T>
    FORCE_INLINE CONSTEXPR_RETURN bool is_valid_not_zero_float(const T & v)
    {
        static_assert(std::is_floating_point<T>::value, "type T must be float");

        return (is_valid_float(v) && (v != 0));
    }

    template <typename T>
    FORCE_INLINE CONSTEXPR_RETURN T positive_infinity(const T & v = T())
    {
        static_assert(std::is_floating_point<T>::value, "type T must be float");
        static_assert(std::numeric_limits<T>::has_infinity, "type T must has infinity");

        return (std::numeric_limits<T>::infinity)();
    }

    template <typename T>
    FORCE_INLINE CONSTEXPR_RETURN T negative_infinity(const T & v = T())
    {
        static_assert(std::is_floating_point<T>::value, "type T must be float");
        static_assert(std::numeric_limits<T>::has_infinity, "type T must has infinity");

        return -(std::numeric_limits<T>::infinity)();
    }

    template <typename T>
    FORCE_INLINE CONSTEXPR_RETURN T signed_infinity(const T & v)
    {
        static_assert(std::is_floating_point<T>::value, "type T must be float");
        static_assert(std::numeric_limits<T>::has_infinity, "type T must has infinity");

        return (
            v >= 0 ?
                positive_infinity(v) :
                negative_infinity(v)
        );
    }

    // has difference with the `std::inf`, does test `has_infinity` statically
    template <typename T>
    FORCE_INLINE CONSTEXPR_RETURN bool is_infinite(const T & v)
    {
        static_assert(std::is_floating_point<T>::value, "type T must be float");
        static_assert(std::numeric_limits<T>::has_infinity, "type T must has infinity");

        return std::isinf(v);
    }

    template <typename T>
    FORCE_INLINE CONSTEXPR_RETURN T float_round_to_signed_infinity(const T & v)
    {
        static_assert(std::is_floating_point<T>::value, "type T must be float");
        static_assert(std::numeric_limits<T>::has_infinity, "type T must has infinity");

        // special case, leave as is
        return (0 < v ?
            positive_infinity(v) :
            v < 0 ?
                negative_infinity(v) :
                v
        );
    }

    template<typename R, typename T0, typename T1>
    FORCE_INLINE R t_add_no_overflow(T0 a, T1 b)
    {
        R res = R(a + b);
        res |= -(res < a);
        return res;
    }

    template<typename R, typename T0, typename T1>
    FORCE_INLINE R t_sub_no_overflow(T0 a, T1 b)
    {
        R res = R(a - b);
        res &= -(res <= a);
        return res;
    }

    FORCE_INLINE_ALWAYS uint32_t uint32_add_no_overflow(uint32_t a, uint32_t b)
    {
        return t_add_no_overflow<uint32_t>(a, b);
    }

    FORCE_INLINE_ALWAYS uint64_t uint64_add_no_overflow(uint64_t a, uint64_t b)
    {
        return t_add_no_overflow<uint64_t>(a, b);
    }

    FORCE_INLINE_ALWAYS uint32_t uint32_sub_no_overflow(uint32_t a, uint32_t b)
    {
        return t_sub_no_overflow<uint32_t>(a, b);
    }

    FORCE_INLINE_ALWAYS uint64_t uint64_sub_no_overflow(uint64_t a, uint64_t b)
    {
        return t_sub_no_overflow<uint64_t>(a, b);
    }

    template <typename T>
    FORCE_INLINE T sum_naturals(T v)
    {
        if (v >= 0)
        {
            if (v % 2) {
                return T(((v + 1) >> 1) * v);
            }

            return T((v >> 1) * (v + 1));
        }

        const T n = negate(v);
        if (n % 2) {
            return T(1) - T(((n + 1) >> 1) * n);
        }

        return T(1) - T((n >> 1) * (n + 1));
    }

    FORCE_INLINE_ALWAYS uint64_t sum_naturals(uint64_t from, uint64_t to)
    {
        if (!from)
        {
            return sum_naturals(to);
        }

        return sum_naturals(to) - sum_naturals(from - 1);
    }

    //// runtime pof2 floor

    FORCE_INLINE uint32_t pof2_floor(uint32_t x)
    {
        INT32_POF2_FLOOR_MACRO_INLINE(return, uint32_t, x);
    }

    FORCE_INLINE uint32_t pof2_ceil(uint32_t x)
    {
        INT32_POF2_CEIL_MACRO_INLINE(return, uint32_t, x);
    }

    template <typename T>
    FORCE_INLINE T int_pof2_floor(T v)
    {
        INT32_POF2_FLOOR_MACRO_INLINE(return, T, v);
    }

    template <typename T>
    FORCE_INLINE T int_pof2_ceil(T v)
    {
        INT32_POF2_CEIL_MACRO_INLINE(return, T, v);
    }

    //// runtime pof2 floor assert

    template <typename T>
    FORCE_INLINE T int_pof2_floor_verify(T v)
    {
        T pof2_value;
        INT32_POF2_FLOOR_MACRO_INLINE(pof2_value =, T, v);

        DEBUG_ASSERT_EQ(pof2_value, v);

        return pof2_value;
    }

    //// runtime pof2 ceil assert

    template <typename T>
    FORCE_INLINE T int_pof2_ceil_verify(T v)
    {
        T pof2_value;
        INT32_POF2_CEIL_MACRO_INLINE(pof2_value =, T, v);

        DEBUG_ASSERT_EQ(pof2_value, v);

        return pof2_value;
    }

    //// runtime log2 floor

    template <typename T>
    FORCE_INLINE T int_log2_floor(T v, T * pof2_value_ptr = nullptr)
    {
        INT32_LOG2_FLOOR_MACRO_INLINE(return, T, v, pof2_value_ptr);
    }

    //// runtime log2 ceil

    template <typename T>
    FORCE_INLINE T int_log2_ceil(T v, T * pof2_value_ptr = nullptr)
    {
        INT32_LOG2_CEIL_MACRO_INLINE(return, T, v, pof2_value_ptr);
    }

    //// runtime log2 floor assert

    template <typename T>
    FORCE_INLINE T int_log2_floor_verify(T v)
    {
        T log2_value;

#if ERROR_IF_EMPTY_PP_DEF(DEBUG_ASSERT_VERIFY_ENABLED)
        T pof2_value;
        INT32_LOG2_FLOOR_MACRO_INLINE(log2_value =, T, v, &pof2_value);

        DEBUG_ASSERT_EQ(pof2_value, v);
#else
        INT32_LOG2_FLOOR_MACRO_INLINE(log2_value =, T, v, nullptr);
#endif

        return log2_value;
    }

    //// runtime log2 ceil assert

    template <typename T>
    FORCE_INLINE T int_log2_ceil_verify(T v)
    {
        T log2_value;

#if ERROR_IF_EMPTY_PP_DEF(DEBUG_ASSERT_VERIFY_ENABLED)
        T pof2_value;

        INT32_LOG2_CEIL_MACRO_INLINE(log2_value =, T, v, &pof2_value);

        DEBUG_ASSERT_EQ(pof2_value, v);
#else
        INT32_LOG2_CEIL_MACRO_INLINE(log2_value =, T, v, nullptr);
#endif

        return log2_value;
    }

    template <typename T>
    extern inline T angle_degrees_in_radians(const T & angle_deg)
    {
        using unqual_type = typename std::remove_cv<T>::type;
        static_assert(!std::is_class<unqual_type>::value, "function does not support a class type of an angle, use another set of functions with explicit `pi` parameter");
        return angle_deg * pi<T>() / 180;
    }

    template <typename T>
    extern inline T angle_radians_in_degrees(const T & angle_rad)
    {
        using unqual_type = typename std::remove_cv<T>::type;
        static_assert(!std::is_class<unqual_type>::value, "function does not support a class type of an angle, use another set of functions with explicit `pi` parameter");
        return angle_rad * 180 / pi<T>();
    }

    template <typename T>
    extern inline T angle_degrees_in_radians(const T & angle_deg, utility::int_identity<45>)
    {
        using unqual_type = typename std::remove_cv<T>::type;
        static_assert(!std::is_class<unqual_type>::value, "function does not support a class type of an angle, use another set of functions with explicit `pi` parameter");
        UTILITY_UNUSED_EXPR(angle_deg);
        return pi<T>() / 4;
    }

    template <typename T>
    extern inline T angle_degrees_in_radians(const T & angle_deg, utility::int_identity<90>)
    {
        using unqual_type = typename std::remove_cv<T>::type;
        static_assert(!std::is_class<unqual_type>::value, "function does not support a class type of an angle, use another set of functions with explicit `pi` parameter");
        UTILITY_UNUSED_EXPR(angle_deg);
        return pi<T>() / 2;
    }

    template <typename T>
    extern inline T angle_degrees_in_radians(const T & angle_deg, utility::int_identity<135>)
    {
        using unqual_type = typename std::remove_cv<T>::type;
        static_assert(!std::is_class<unqual_type>::value, "function does not support a class type of an angle, use another set of functions with explicit `pi` parameter");
        UTILITY_UNUSED_EXPR(angle_deg);
        return pi<T>() * 3 / 4;
    }

    template <typename T>
    extern inline T angle_degrees_in_radians(const T & angle_deg, utility::int_identity<180>)
    {
        using unqual_type = typename std::remove_cv<T>::type;
        static_assert(!std::is_class<unqual_type>::value, "function does not support a class type of an angle, use another set of functions with explicit `pi` parameter");
        UTILITY_UNUSED_EXPR(angle_deg);
        return pi<T>();
    }

    template <typename T>
    extern inline T angle_degrees_in_radians(const T & angle_deg, utility::int_identity<225>)
    {
        using unqual_type = typename std::remove_cv<T>::type;
        static_assert(!std::is_class<unqual_type>::value, "function does not support a class type of an angle, use another set of functions with explicit `pi` parameter");
        UTILITY_UNUSED_EXPR(angle_deg);
        return pi<T>() * 5 / 4;
    }

    template <typename T>
    extern inline T angle_degrees_in_radians(const T & angle_deg, utility::int_identity<270>)
    {
        using unqual_type = typename std::remove_cv<T>::type;
        static_assert(!std::is_class<unqual_type>::value, "function does not support a class type of an angle, use another set of functions with explicit `pi` parameter");
        UTILITY_UNUSED_EXPR(angle_deg);
        return pi<T>() * 3 / 2;
    }

    template <typename T>
    extern inline T angle_degrees_in_radians(const T & angle_deg, utility::int_identity<315>)
    {
        using unqual_type = typename std::remove_cv<T>::type;
        static_assert(!std::is_class<unqual_type>::value, "function does not support a class type of an angle, use another set of functions with explicit `pi` parameter");
        UTILITY_UNUSED_EXPR(angle_deg);
        return pi<T>() * 7 / 4;
    }

    template <typename T>
    extern inline T angle_degrees_in_radians(const T & angle_deg, utility::int_identity<360>)
    {
        using unqual_type = typename std::remove_cv<T>::type;
        static_assert(!std::is_class<unqual_type>::value, "function does not support a class type of an angle, use another set of functions with explicit `pi` parameter");
        UTILITY_UNUSED_EXPR(angle_deg);
        return pi<T>() * 2;
    }

    template <typename T>
    extern inline T angle_degrees_in_radians(const T & angle_deg, utility::int_identity<720>)
    {
        using unqual_type = typename std::remove_cv<T>::type;
        static_assert(!std::is_class<unqual_type>::value, "function does not support a class type of an angle, use another set of functions with explicit `pi` parameter");
        UTILITY_UNUSED_EXPR(angle_deg);
        return pi<T>() * 4;
    }

    template <typename T>
    extern inline T angle_degrees_in_radians(const T & angle_deg, const T & pi)
    {
        return angle_deg * pi / 180;
    }

    template <typename T>
    extern inline T angle_radians_in_degrees(const T & angle_rad, const T & pi)
    {
        return angle_rad * 180 / pi;
    }

    template <typename T>
    extern inline T angle_degrees_in_radians(const T & angle_deg, const T & pi, utility::int_identity<45>)
    {
        UTILITY_UNUSED_EXPR(angle_deg);
        return pi / 4;
    }

    template <typename T>
    extern inline T angle_degrees_in_radians(const T & angle_deg, const T & pi, utility::int_identity<90>)
    {
        UTILITY_UNUSED_EXPR(angle_deg);
        return pi / 2;
    }

    template <typename T>
    extern inline T angle_degrees_in_radians(const T & angle_deg, const T & pi, utility::int_identity<135>)
    {
        UTILITY_UNUSED_EXPR(angle_deg);
        return pi * 3 / 4;
    }

    template <typename T>
    extern inline T angle_degrees_in_radians(const T & angle_deg, const T & pi, utility::int_identity<180>)
    {
        UTILITY_UNUSED_EXPR(angle_deg);
        return pi;
    }

    template <typename T>
    extern inline T angle_degrees_in_radians(const T & angle_deg, const T & pi, utility::int_identity<225>)
    {
        UTILITY_UNUSED_EXPR(angle_deg);
        return pi * 5 / 4;
    }

    template <typename T>
    extern inline T angle_degrees_in_radians(const T & angle_deg, const T & pi, utility::int_identity<270>)
    {
        UTILITY_UNUSED_EXPR(angle_deg);
        return pi * 3 / 2;
    }

    template <typename T>
    extern inline T angle_degrees_in_radians(const T & angle_deg, const T & pi, utility::int_identity<315>)
    {
        UTILITY_UNUSED_EXPR(angle_deg);
        return pi * 7 / 4;
    }

    template <typename T>
    extern inline T angle_degrees_in_radians(const T & angle_deg, const T & pi, utility::int_identity<360>)
    {
        UTILITY_UNUSED_EXPR(angle_deg);
        return pi * 2;
    }

    template <typename T>
    extern inline T angle_degrees_in_radians(const T & angle_deg, const T & pi, utility::int_identity<720>)
    {
        UTILITY_UNUSED_EXPR(angle_deg);
        return pi * 4;
    }

    // inclusion_direction if exclude_all=false:
    //  -1 - minimal is included, maximal is excluded (ex: [   0 - +360) )
    //  +1 - minimal is excluded, maximal is included (ex: (-180 - +180] )
    //   0 - minimal and maximal both included (ex: [0 - +180] or [-90 - +90])
    //
    // exclude_all (inclusion_direction must be set to 0):
    //   true - minimal and maximal both excluded (ex: (0 - +180) or (-90 - +90))
    //
    template <typename T>
    extern inline T normalize_angle(const T & ang, const T & min_ang, const T & max_ang, const T & ang_period_mod, int inclusion_direction, bool exclude_all = false)
    {
        static_assert(std::is_floating_point<T>::value, "type T must be float");

        DEBUG_ASSERT_LT(min_ang, max_ang);
        DEBUG_ASSERT_GT(ang_period_mod, 0U); // must be always positive

        DEBUG_ASSERT_GE(min_ang, -ang_period_mod);
        DEBUG_ASSERT_GE(ang_period_mod, max_ang);

        DEBUG_ASSERT_TRUE(!exclude_all || inclusion_direction == 0); // inclusion_direction must be 0, just in case

        if (!BASIC_VERIFY_TRUE(inclusion_direction >= -1 && +1 >= inclusion_direction)) {
            // just in case
            inclusion_direction = 0; // prefer symmetric case
        }

        T ang_norm = ang;

        if_break(!exclude_all) {
            switch (inclusion_direction) {
            case -1:
                if (ang >= min_ang && max_ang > ang) {
                    return ang;
                }

                ang_norm = ang;

                if (ang >= 0) {
                    if (ang < ang_period_mod) {
                        const T ang_neg = ang - ang_period_mod;
                        if (ang_neg >= min_ang && max_ang > ang_neg) {
                            return ang_neg;
                        }
                        break;
                    }
                    else {
                        ang_norm = std::fmod(ang, ang_period_mod);
                        if (ang_norm >= min_ang && max_ang > ang_norm) {
                            return ang_norm;
                        }
                        else {
                            const T ang_neg = ang_norm - ang_period_mod;
                            if (ang_neg >= min_ang && max_ang > ang_neg) {
                                return ang_neg;
                            }
                        }
                    }
                }
                else if (-ang < ang_period_mod) {
                    const T ang_pos = ang + ang_period_mod;
                    if (ang_pos >= min_ang && max_ang > ang_pos) {
                        return ang_pos;
                    }
                    // additional test in direction of inclusion
                    else {
                        const T ang_neg = ang - ang_period_mod;
                        if (ang_neg >= min_ang && max_ang > ang_neg) {
                            return ang_neg;
                        }
                    }
                }
                else {
                    ang_norm = std::fmod(ang, ang_period_mod);
                    if (ang_norm >= min_ang && max_ang > ang_norm) {
                        return ang_norm;
                    }
                    else {
                        const T ang_pos = ang_norm + ang_period_mod;
                        if (ang_pos >= min_ang && max_ang > ang_pos) {
                            return ang_pos;
                        }
                        // additional test in direction of inclusion
                        else {
                            const T ang_neg = ang_norm - ang_period_mod;
                            if (ang_neg >= min_ang && max_ang > ang_neg) {
                                return ang_neg;
                            }
                        }
                    }
                }
                break;

            case 0:
                if (ang >= min_ang && max_ang >= ang) {
                    return ang;
                }

                ang_norm = ang;

                if (ang >= 0) {
                    if (ang < ang_period_mod) {
                        const T ang_neg = ang - ang_period_mod;
                        if (ang_neg >= min_ang && max_ang >= ang_neg) {
                            return ang_neg;
                        }
                        break;
                    }
                    else {
                        ang_norm = std::fmod(ang, ang_period_mod);
                        if (ang_norm >= min_ang && max_ang >= ang_norm) {
                            return ang_norm;
                        }
                        else {
                            const T ang_neg = ang_norm - ang_period_mod;
                            if (ang_neg >= min_ang && max_ang >= ang_neg) {
                                return ang_neg;
                            }
                        }
                    }
                }
                else if (-ang < ang_period_mod) {
                    const T ang_pos = ang + ang_period_mod;
                    if (ang_pos >= min_ang && max_ang >= ang_pos) {
                        return ang_pos;
                    }
                }
                else {
                    ang_norm = std::fmod(ang, ang_period_mod);
                    if (ang_norm >= min_ang && max_ang >= ang_norm) {
                        return ang_norm;
                    }
                    else {
                        const T ang_pos = ang_norm + ang_period_mod;
                        if (ang_pos >= min_ang && max_ang >= ang_pos) {
                            return ang_pos;
                        }
                    }
                }
                break;

            case +1:
                if (ang > min_ang && max_ang >= ang) {
                    return ang;
                }

                ang_norm = ang;

                if (ang >= 0) {
                    if (ang < ang_period_mod) {
                        const T ang_neg = ang - ang_period_mod;
                        if (ang_neg > min_ang && max_ang >= ang_neg) {
                            return ang_neg;
                        }
                        // additional test in direction of inclusion
                        else {
                            const T ang_pos = ang + ang_period_mod;
                            if (ang_pos > min_ang && max_ang >= ang_pos) {
                                return ang_pos;
                            }
                        }
                        break;
                    }
                    else {
                        ang_norm = std::fmod(ang, ang_period_mod);
                        if (ang_norm > min_ang && max_ang >= ang_norm) {
                            return ang_norm;
                        }
                        else {
                            const T ang_neg = ang_norm - ang_period_mod;
                            if (ang_neg > min_ang && max_ang >= ang_neg) {
                                return ang_neg;
                            }
                            // additional test in direction of inclusion
                            else {
                                const T ang_pos = ang_norm + ang_period_mod;
                                if (ang_pos > min_ang && max_ang >= ang_pos) {
                                    return ang_pos;
                                }
                            }
                        }
                    }
                }
                else if (-ang < ang_period_mod) {
                    const T ang_pos = ang + ang_period_mod;
                    if (ang_pos > min_ang && max_ang >= ang_pos) {
                        return ang_pos;
                    }
                }
                else {
                    ang_norm = std::fmod(ang, ang_period_mod);
                    if (ang_norm > min_ang && max_ang >= ang_norm) {
                        return ang_norm;
                    }
                    else {
                        const T ang_pos = ang_norm + ang_period_mod;
                        if (ang_pos > min_ang && max_ang >= ang_pos) {
                            return ang_pos;
                        }
                    }
                }
                break;

            default:
                DEBUG_ASSERT_TRUE(false);
            }
        }
        else {
            if (ang > min_ang && max_ang > ang) {
                return ang;
            }

            ang_norm = ang;

            if (ang >= 0) {
                if (ang < ang_period_mod) {
                    const T ang_neg = ang - ang_period_mod;
                    if (ang_neg > min_ang && max_ang > ang_neg) {
                        return ang_neg;
                    }
                    break;
                }
                else {
                    ang_norm = std::fmod(ang, ang_period_mod);
                    if (ang_norm > min_ang && max_ang > ang_norm) {
                        return ang_norm;
                    }
                    else {
                        const T ang_neg = ang_norm - ang_period_mod;
                        if (ang_neg > min_ang && max_ang > ang_neg) {
                            return ang_neg;
                        }
                    }
                }
            }
            else if (-ang < ang_period_mod) {
                const T ang_pos = ang + ang_period_mod;
                if (ang_pos > min_ang && max_ang > ang_pos) {
                    return ang_pos;
                }
            }
            else {
                ang_norm = std::fmod(ang, ang_period_mod);
                if (ang_norm > min_ang && max_ang > ang_norm) {
                    return ang_norm;
                }
                else {
                    const T ang_pos = ang_norm + ang_period_mod;
                    if (ang_pos > min_ang && max_ang > ang_pos) {
                        return ang_pos;
                    }
                }
            }
        }

        return ang_norm;
    }

    // Calculates closest distance between 2 angles independently to angles change direction.
    //
    // CAUTION:
    //  Because the function does not use direction of angle change, the resulting angles distance will be always less or equal to 180 degrees.
    //  Use `angle_distance` function instead to get angles distance respective to angles change direction.
    //
    // start_angle=[-inf..+inf] end_angle=[-inf..+inf]
    //
    // on_equal_distances_select_closest_to_zero=true:
    //  Calculate angle distance with a sign less or equal by the modulo to the 180 degrees, where
    //  the resulting range middle point would be closest to the zero.
    //  For example, for 2 ranges [0..180] and [0..-180] the function should return +180, but for another 2 ranges
    //  [5..185] and [5..-175] the function should return -180 because an absolute value of middle point |+95| is greater than |-85|.
    //
    // Return: angle_distance=[-pi..+pi]
    //
    template <typename T>
    extern inline T angle_closest_distance(const T & start_angle, const T & end_angle, bool in_radians, bool on_equal_distances_select_closest_to_zero)
    {
        static_assert(std::is_floating_point<T>::value, "type T must be float");

        const T angle_distance_inf = end_angle - start_angle;

        T angle_distance = angle_distance_inf; // retains the sign to transfer the direction of angle

        if (angle_distance_inf < 0) {
            if (-DEG_180_IN_RAD_IF(angle_distance_inf, in_radians) >= angle_distance_inf) {
                // normalize distance from [-inf..0] to (-360..0]
                const T angle_distance_360 = std::fmod(angle_distance_inf, DEG_360_IN_RAD_IF(angle_distance_inf, in_radians));
                if (-DEG_180_IN_RAD_IF(angle_distance_360, in_radians) > angle_distance_360) {
                    angle_distance = DEG_360_IN_RAD_IF(angle_distance_360, in_radians) + angle_distance_360;
                }
                else {
                    if (-DEG_180_IN_RAD_IF(angle_distance_360, in_radians) != angle_distance_360 || !on_equal_distances_select_closest_to_zero) {
                        angle_distance = angle_distance_360;
                    }
                    else {
                        if (start_angle > 0) {
                            angle_distance = -DEG_180_IN_RAD_IF(angle_distance, in_radians);
                        }
                        else {
                            angle_distance = DEG_180_IN_RAD_IF(angle_distance, in_radians);
                        }
                    }
                }
            }
        }
        else {
            if (DEG_180_IN_RAD_IF(angle_distance_inf, in_radians) <= angle_distance_inf) {
                // normalize distance from [0..+inf] to [0..+360)
                const T angle_distance_360 = std::fmod(angle_distance_inf, DEG_360_IN_RAD_IF(angle_distance_inf, in_radians));
                if (DEG_180_IN_RAD_IF(angle_distance_360, in_radians) < angle_distance_360) {
                    angle_distance = angle_distance_360 - DEG_360_IN_RAD_IF(angle_distance_360, in_radians);
                }
                else {
                    if (DEG_180_IN_RAD_IF(angle_distance_360, in_radians) != angle_distance_360 || !on_equal_distances_select_closest_to_zero) {
                        angle_distance = angle_distance_360;
                    }
                    else {
                        if (start_angle > 0) {
                            angle_distance = -DEG_180_IN_RAD_IF(angle_distance, in_radians);
                        }
                        else {
                            angle_distance = DEG_180_IN_RAD_IF(angle_distance, in_radians);
                        }
                    }
                }
            }
        }

        DEBUG_ASSERT_GE(DEG_180_IN_RAD_IF(angle_distance, in_radians), std::fabs(angle_distance));

        return angle_distance;
    }

    // Calculates distance between 2 angles respective to angles change direction if greater than epsilon angle,
    // otherwise calculates angle closest distance.
    //
    // start_angle=[-inf..+inf] end_angle=[-inf..+inf]
    //
    // Return: angle_distance=[-2pi..+2pi]
    //
    template <typename T>
    extern inline T angle_distance(const T & start_angle, const T & end_angle, const T & angle_epsilon, bool positive_angle_change, bool in_radians)
    {
        static_assert(std::is_floating_point<T>::value, "type T must be float");

        // all epsilons must be positive
        DEBUG_ASSERT_GE(angle_epsilon, 0);

        const T angle_distance_inf = end_angle - start_angle;

        // normalize distance from [-inf..0]/[0..+inf] to (-360..0]/[0..+360)
        const T angle_distance_360 = std::fmod(angle_distance_inf, DEG_360_IN_RAD_IF(angle_distance_inf, in_radians));
        const T angle_distance_360_abs = std::fabs(angle_distance_360);

        if (angle_epsilon < angle_distance_360_abs && angle_epsilon < (DEG_360_IN_RAD_IF(angle_distance_360_abs, in_radians) - angle_distance_360_abs)) {
            if (!((angle_distance_360 >= 0) ^ positive_angle_change)) {
                // angle change sign and direction are the same
                return angle_distance_360;
            }

            return positive_angle_change ?
                DEG_360_IN_RAD_IF(angle_distance_360, in_radians) + angle_distance_360 :
                angle_distance_360 - DEG_360_IN_RAD_IF(angle_distance_360, in_radians);
        }

        // closest angle
        if (DEG_180_IN_RAD_IF(angle_distance_360_abs, in_radians) >= angle_distance_360_abs) {
            return angle_distance_360;
        }

        return (angle_distance_360 >= 0) ?
            angle_distance_360 - DEG_360_IN_RAD_IF(angle_distance_360, in_radians) :
            DEG_360_IN_RAD_IF(angle_distance_360, in_radians) + angle_distance_360;
    }

    // Translates (convertes) angle to a min/max range [(min..max)] with 0 in a base angle.
    //
    // inclusion_direction if exclude_all=false:
    //  -1 - minimal is included, maximal is excluded (ex: [-180 - +180) )
    //  +1 - minimal is excluded, maximal is included (ex: (-180 - +180] )
    //   0 - minimal and maximal both included (ex: [-180 - +180])
    //
    // exclude_all (inclusion_direction must be set to 0):
    //   true - minimal and maximal both excluded (ex: (-180 - +180))
    //
    template <typename T>
    extern inline T translate_angle(const T & angle, const T & base_angle, const T & min_angle, const T & max_angle,
        bool in_radians, int inclusion_direction, bool exclude_all = false)
    {
        static_assert(std::is_floating_point<T>::value, "type T must be float");

        return math::normalize_angle(angle - base_angle, min_angle, max_angle, DEG_360_IN_RAD_IF(angle, in_radians), inclusion_direction, exclude_all);
    }

    // Normalizes angle to a range, where the resulting angle would monotonically change (w/o discontinuity on the range) while the angle in the range.
    // Additionally the monotonical change should exists on the greater range with the discontinuity in the angle opposite to the middle angle.
    //
    // start_angle=[-360..+360] mid_angle=[-360..+360] angle_distance=[-inf..+inf] angle=[-inf..+inf]
    //
    template <typename T>
    extern inline T normalize_angle_to_range(const T & start_angle, const T & mid_angle, const T & angle_distance, const T & angle, bool in_radians)
    {
        static_assert(std::is_floating_point<T>::value, "type T must be float");

        // all input must be already normalized and consistent
        DEBUG_ASSERT_TRUE(start_angle >= -DEG_360_IN_RAD_IF(start_angle, in_radians) && DEG_360_IN_RAD_IF(start_angle, in_radians) >= start_angle);
        DEBUG_ASSERT_TRUE(mid_angle - start_angle >= -DEG_360_IN_RAD_IF(mid_angle, in_radians) && DEG_360_IN_RAD_IF(mid_angle, in_radians) >= mid_angle - start_angle);
        DEBUG_ASSERT_GE(DEG_180_IN_RAD_IF(mid_angle, in_radians), std::fabs(mid_angle - start_angle));
#if DEBUG_ASSERT_VERIFY_ENABLED
        if (angle_distance > 0) {
            DEBUG_ASSERT_TRUE(start_angle < mid_angle && mid_angle < start_angle + angle_distance);
        }
        else if (angle_distance < 0) {
            DEBUG_ASSERT_TRUE(start_angle > mid_angle && mid_angle > start_angle + angle_distance);
        }
        else {
            DEBUG_ASSERT_TRUE(start_angle == mid_angle && mid_angle == start_angle + angle_distance);
        }
#endif

        const T angle_norm = math::normalize_angle(angle,
            -DEG_360_IN_RAD_IF(angle, in_radians), DEG_360_IN_RAD_IF(angle, in_radians), DEG_360_IN_RAD_IF(angle, in_radians), 0);
        const T angle_distance_norm = math::normalize_angle(angle_distance,
            -DEG_360_IN_RAD_IF(angle_distance, in_radians), DEG_360_IN_RAD_IF(angle_distance, in_radians), DEG_360_IN_RAD_IF(angle_distance, in_radians), 0);

        const T end_angle_norm = start_angle + angle_distance_norm;
        T prev_angle_tmp;
        T angle_tmp = angle_norm;

        if (angle_distance_norm >= 0) {
            if (end_angle_norm < angle_tmp) {
                do {
                    prev_angle_tmp = angle_tmp;
                    angle_tmp -= DEG_360_IN_RAD_IF(angle_tmp, in_radians);
                } while (end_angle_norm < angle_tmp);

                if (angle_tmp < start_angle) {
                    // choose azimuth with closest distance to the `mid_angle` point
                    if (VERIFY_GE(prev_angle_tmp - mid_angle, 0) <=
                        VERIFY_GE(mid_angle - angle_tmp, 0)) {
                        angle_tmp = prev_angle_tmp;
                    }
                }
            }
            else if (angle_tmp < start_angle) {
                do {
                    prev_angle_tmp = angle_tmp;
                    angle_tmp += DEG_360_IN_RAD_IF(angle_tmp, in_radians);
                } while (angle_tmp < start_angle);

                if (end_angle_norm < angle_tmp) {
                    // choose azimuth with closest distance to the `mid_angle` point
                    if (VERIFY_GE(mid_angle - prev_angle_tmp, 0) <
                        VERIFY_GE(angle_tmp - mid_angle, 0)) {
                        angle_tmp = prev_angle_tmp;
                    }
                }
            }
        }
        else {
            if (start_angle < angle_tmp) {
                do {
                    prev_angle_tmp = angle_tmp;
                    angle_tmp -= DEG_360_IN_RAD_IF(angle_tmp, in_radians);
                } while (start_angle < angle_tmp);

                if (angle_tmp < end_angle_norm) {
                    // choose azimuth with closest distance to the `mid_angle` point
                    if (VERIFY_GE(prev_angle_tmp - mid_angle, 0) <=
                        VERIFY_GE(mid_angle - angle_tmp, 0)) {
                        angle_tmp = prev_angle_tmp;
                    }
                }
            }
            else if (angle_tmp < end_angle_norm) {
                do {
                    prev_angle_tmp = angle_tmp;
                    angle_tmp += DEG_360_IN_RAD_IF(angle_tmp, in_radians);
                } while (angle_tmp < end_angle_norm);

                if (start_angle < angle_tmp) {
                    // choose azimuth with closest distance to the `mid_angle` point
                    if (VERIFY_GE(mid_angle - prev_angle_tmp, 0) <
                        VERIFY_GE(angle_tmp - mid_angle, 0)) {
                        angle_tmp = prev_angle_tmp;
                    }
                }
            }
        }

        return angle_tmp;
    }

    // Calculate periods delta between 2 angles
    template <typename T>
    extern inline T angle_periods_shift(const T & prev_ang, const T & next_ang, const T & ang_period_mod)
    {
        static_assert(std::is_floating_point<T>::value, "type T must be float");

        DEBUG_ASSERT_GT(ang_period_mod, 0U); // must be always positive

        return (next_ang - prev_ang) / ang_period_mod;
    }

    template <typename T>
    extern inline T floor_to_zero(const T & value)
    {
        static_assert(std::is_floating_point<T>::value, "type T must be float");

        if (value >= 0) {
            return std::floor(value);
        }

        return -std::floor(-value);
    }

    // Avoids rounding to the closest value in print functions by truncation to the opposite value.
    // For example, if angle is [0..360], where maximum is 360 degrees, than 259.9997 will be truncated to the 360 in case of num_fraction_chars=3.
    // The function would truncate 259.9997 back to 259.999 to avoid such implicit rounding, except 360 itself, which would not be truncated at all.
    //
    template <typename T>
    extern inline T truncate_float_from_max_power_of_10(const T & value, const T & max_value, const T & no_truncation_epsilon, size_t num_fraction_chars)
    {
        static_assert(std::is_floating_point<T>::value, "type T must be float");

        DEBUG_ASSERT_GE(max_value, value);
        DEBUG_ASSERT_GE(no_truncation_epsilon, 0); // epsilon must be always not negative

        const T rounding_multiplier = std::pow(T(10), int(num_fraction_chars));

        const T delta = max_value - value;
        if (no_truncation_epsilon < delta && 1.0 >= delta * rounding_multiplier) {
            T whole_value;
            std::modf(value * rounding_multiplier, &whole_value);
            return whole_value / rounding_multiplier;
        }

        return value;
    }

    template <typename T>
    extern inline char float_round_to_power_of_10_suffix_sign_char(const T & value, size_t num_fraction_chars)
    {
        static_assert(std::is_floating_point<T>::value, "type T must be float");

        if (num_fraction_chars) {
            const T rounding_multiplier = std::pow(T(10), int(num_fraction_chars));
            const T rounded_value = ((value >= 0) ?
                floor_to_zero(value * rounding_multiplier + 0.5) :
                floor_to_zero(value * rounding_multiplier - 0.5)) / rounding_multiplier;

            if (value < rounded_value) return '-';
            if (rounded_value < value) return '+';
        }
        else {
            const T rounded_value = (value >= 0) ? floor_to_zero(value + 0.5) : floor_to_zero(value - 0.5);

            if (value < rounded_value) return '-';
            if (rounded_value < value) return '+';
        }

        return ' ';
    }

    template <typename T>
    extern inline char float_truncation_sign_char(const T & value, const T & min_value, const T & max_value, const T & epsilon)
    {
        static_assert(std::is_floating_point<T>::value, "type T must be float");

        DEBUG_ASSERT_GE(epsilon, 0);
        DEBUG_ASSERT_GE(max_value, min_value);

        if (value >= min_value && min_value + epsilon >= value) {
            if (value != min_value) return '+';
            else return ' ';
        }
        if (max_value >= value && value >= max_value - epsilon) {
            if (value != max_value) return '-';
            else return ' ';
        }

        return ' ';
    }

    template <typename T>
    extern inline bool is_float_equal(const T & left, const T & right, const T & epsion)
    {
        static_assert(std::is_floating_point<T>::value, "type T must be float");

        if (epsion >= std::fabs(left - right)) {
            return true;
        }

        return false;
    }

    template <typename T>
    extern inline T truncate_float_to_minmax(const T & value, const T & min_value, const T & max_value)
    {
        static_assert(std::is_floating_point<T>::value, "type T must be float");

        DEBUG_ASSERT_GE(max_value, min_value);

        if (max_value < value) {
            return max_value;
        }

        if (value < min_value) {
            return min_value;
        }

        return value;
    }

    template <typename T>
    extern inline T fix_float_trigonometric_range_factor(const T & value)
    {
        static_assert(std::is_floating_point<T>::value, "type T must be float");

        // avoid fix in special case
        if (is_valid_not_zero_float(value)) {
            return truncate_float_to_minmax(value, T(-1.0), T(+1.0));
        }

        return value;
    }

    template <typename T>
    extern inline T fix_float_trigonometric_range_asin(const T & value, bool in_radians)
    {
        static_assert(std::is_floating_point<T>::value, "type T must be float");

        // avoid fix in special case
        if (is_valid_not_zero_float(value)) {
            const T pi_{ pi<T>() };
            const T min_value_included = -DEG_90_IN_RAD2_IF(in_radians, pi_, pi_);
            const T max_value_included = DEG_90_IN_RAD2_IF(in_radians, pi_, pi_);
            return truncate_float_to_minmax(value, min_value_included, max_value_included);
        }

        return value;
    }

    template <typename T>
    extern inline T fix_float_trigonometric_range_acos(const T & value, bool in_radians)
    {
        static_assert(std::is_floating_point<T>::value, "type T must be float");

        // avoid fix in special case
        if (is_valid_not_zero_float(value)) {
            const T pi_{ pi<T>() };
            const T min_value_included = 0;
            const T max_value_included = DEG_180_IN_RAD2_IF(in_radians, pi_, pi_);
            return truncate_float_to_minmax(value, min_value_included, max_value_included);
        }

        return value;
    }

    template <typename T>
    extern inline T fix_float_trigonometric_range_atan(const T & value, bool in_radians)
    {
        static_assert(std::is_floating_point<T>::value, "type T must be float");

        return fix_float_trigonometric_range_asin(value, in_radians);
    }

    template <typename T>
    extern inline T fix_float_trigonometric_range_atan2(const T & value, bool in_radians)
    {
        static_assert(std::is_floating_point<T>::value, "type T must be float");

        // avoid fix in special case
        if (is_valid_not_zero_float(value)) {
            const T pi_{ pi<T>() };
            const T min_value_exluded = std::nextafter(-DEG_180_IN_RAD2_IF(in_radians, pi_, pi_), positive_infinity(pi_));
            const T max_value_included = DEG_180_IN_RAD2_IF(in_radians, pi_, pi_);
            return truncate_float_to_minmax(value, min_value_exluded, max_value_included);
        }

        return value;
    }

    // changes exponent of one of the floats to compensate unsensible addition/subtraction
    template <typename T>
    extern inline int reduce_float_exp_delta(const T & from, T & to_fix, int min_sensible_exp_delta = 1)
    {
        static_assert(std::is_floating_point<T>::value, "type T must be float");

        DEBUG_ASSERT_GT(std::abs(from), std::abs(to_fix)); // fix value must be always lower by absolute value!

        // should not be zero
        if (from == 0 || to_fix == 0) {
            return 0;
        }

        int from_exp;
        int to_exp;

        std::frexp(from, &from_exp);
        const double to_frac = std::frexp(to_fix, &to_exp);

        const int float_digits = std::numeric_limits<T>::digits;
        const int exp_delta = std::abs(from_exp - to_exp);

        if (exp_delta > float_digits) {
            const int compensate_exp_delta = (std::max)(exp_delta - float_digits, min_sensible_exp_delta); // compensate by exponent distance reduction
            to_fix = std::ldexp(to_frac, to_exp + compensate_exp_delta);
            return compensate_exp_delta;
        }

        return 0;
    }
}

#endif
