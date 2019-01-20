#pragma once

// DO NOT REMOVE, exists to avoid private/public headers mixing!
#ifndef UTILITY_ADDRESSOF_HPP
#define UTILITY_ADDRESSOF_HPP

#include <tacklelib/tacklelib.hpp>

#include <tacklelib/utility/platform.hpp>


namespace utility
{
    template <typename T>
    FORCE_INLINE CONSTEXPR T * addressof(T & arg)
    {
        return
            reinterpret_cast<T *>(
                &const_cast<char &>(
                    reinterpret_cast<const volatile char &>(arg)));
    }

    template <typename T>
    FORCE_INLINE CONSTEXPR const T * addressof(const T & arg)
    {
        return
            reinterpret_cast<const T *>(
                &const_cast<const char &>(
                    reinterpret_cast<const volatile char &>(arg)));
    }

    template <typename To, typename From>
    FORCE_INLINE To cast_addressof(From & v)
    {
        return static_cast<To>(static_cast<void *>(utility::addressof(v)));
    }

    template <typename To, typename From>
    FORCE_INLINE To cast_addressof(const From & v)
    {
        return static_cast<To>(static_cast<const void *>(utility::addressof(v)));
    }

    template <typename To, typename From>
    FORCE_INLINE To cast_addressof(volatile From & v)
    {
        return static_cast<To>(static_cast<volatile void *>(utility::addressof(v)));
    }

    template <typename To, typename From>
    FORCE_INLINE To cast_addressof(const volatile From & v)
    {
        return static_cast<To>(static_cast<const volatile void *>(utility::addressof(v)));
    }

    // rvalue address does not exist
    template <typename To, typename From>
    To cast_addressof(From && v);
}

#endif
