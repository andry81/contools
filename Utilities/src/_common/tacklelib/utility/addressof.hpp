#pragma once

// DO NOT REMOVE, exists to avoid private/public headers mixing!
#ifndef UTILITY_ADDRESSOF_HPP
#define UTILITY_ADDRESSOF_HPP

#include <functional>
#include <utility>


// CAUTION:
//  * addressof function must be declared in a namespace, otherwise CAN FAIL SILENTLY!
//

namespace utility
{
    template <typename T>
    inline constexpr T * addressof(T & arg)
    {
        return
            reinterpret_cast<T *>(
                &const_cast<char &>(
                    reinterpret_cast<const volatile char &>(arg)));
    }

    template <typename T>
    inline constexpr const T * addressof(const T & arg)
    {
        return
            reinterpret_cast<const T *>(
                &const_cast<const char &>(
                    reinterpret_cast<const volatile char &>(arg)));
    }

    // Specific std::function address retrieve.
    // Based on: https://stackoverflow.com/questions/18039723/c-trying-to-get-function-address-from-a-stdfunction/18039824#18039824
    //

    template <typename T, typename... U>
    inline auto addressof(T(func)(U...))->T(*)(U...)
    {
        return func;
    }

    template <typename T, typename... U>
    inline auto addressof(const std::function<T(U...)> & func)->T(*)(U...)
    {
        auto func_ptr = func.template target<T(*)(U...)>(); // would return nullptr on a lambda
        if (func_ptr) {
            return *func_ptr;
        }

        return nullptr;
    }

    template <typename To, typename From>
    inline To cast_addressof(From & v)
    {
        return static_cast<To>(static_cast<void *>(utility::addressof(v)));
    }

    template <typename To, typename From>
    inline To cast_addressof(const From & v)
    {
        return static_cast<To>(static_cast<const void *>(utility::addressof(v)));
    }

    template <typename To, typename From>
    inline To cast_addressof(volatile From & v)
    {
        return static_cast<To>(static_cast<volatile void *>(utility::addressof(v)));
    }

    template <typename To, typename From>
    inline To cast_addressof(const volatile From & v)
    {
        return static_cast<To>(static_cast<const volatile void *>(utility::addressof(v)));
    }

    // rvalue address does not exist
    template <typename To, typename From>
    To cast_addressof(From && v);

    template <typename T, typename... Args>
    inline T & construct_static_as(Args &&... args)
    {
        static T value{ std::forward<decltype(args)>(args)... };
        return value;
    }
}

#endif
