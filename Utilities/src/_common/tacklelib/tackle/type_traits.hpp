#pragma once

// DO NOT REMOVE, exists to avoid private/public headers mixing!
#ifndef UTILITY_TYPE_TRAITS_HPP
#define UTILITY_TYPE_TRAITS_HPP

#include <type_traits>
#include <algorithm>

#include <cstdint>
#include <cstdlib>


namespace utility
{
    // Generalized `for_each` through the `std::tuple` container.
    // Based on: https://stackoverflow.com/questions/1198260/iterate-over-tuple/6894436#6894436
    //

    template <std::size_t I = 0, typename Functor, typename... Args>
    typename std::enable_if<I == sizeof...(Args), void>::type
        for_each(std::tuple<Args...> &, Functor &&)
    {
    }

    template<std::size_t I = 0, typename Functor, typename... Args>
    typename std::enable_if<I < sizeof...(Args), void>::type
        for_each(std::tuple<Args...> & t, Functor && f)
    {
        f(std::get<I>(t));
        for_each<I + 1, Functor, Args...>(t, std::forward<Functor>(f));
    }

    // Unrolled `for_each` for multidimensional arrays

    namespace detail
    {
        template<bool is_array>
        struct _for_each_unroll
        {
            template <typename Functor, typename T, std::size_t N>
            _for_each_unroll(T (& arr)[N], Functor && f)
            {
                invoke(arr, std::forward<Functor>(f));
            }

            template <typename Functor, typename T, std::size_t N>
            _for_each_unroll(T (&& arr)[N], Functor && f)
            {
                invoke(std::forward<T[N]>(arr), std::forward<Functor>(f));
            }

            template <std::size_t I = 0, typename Functor, typename T, std::size_t N>
            typename std::enable_if<I == N, void>::type
                invoke(T (& arr)[N], Functor && f)
            {
            }

            template <std::size_t I = 0, typename Functor, typename T, std::size_t N>
            typename std::enable_if<I == N, void>::type
                invoke(T (&& arr)[N], Functor && f)
            {
            }

            template <std::size_t I = 0, typename Functor, typename T, std::size_t N>
            typename std::enable_if<I < N, void>::type
                invoke(T (& arr)[N], Functor && f)
            {
                _for_each_unroll<std::is_array<T>::value>{ arr[I], std::forward<Functor>(f) };
                invoke<I + 1, Functor, T, N>(arr, std::forward<Functor>(f));
            }

            template <std::size_t I = 0, typename Functor, typename T, std::size_t N>
            typename std::enable_if<I < N, void>::type
                invoke(T (&& arr)[N], Functor && f)
            {
                _for_each_unroll<std::is_array<T>::value>{ std::forward<T>(arr[I]), std::forward<Functor>(f) };
                invoke<I + 1, Functor, T, N>(arr, std::forward<Functor>(f));
            }
        };

        template<>
        struct _for_each_unroll<false>
        {
            template <typename Functor, typename T>
            _for_each_unroll(const T & value, Functor && f)
            {
                f(value);
            }

            template <typename Functor, typename T>
            _for_each_unroll(T && value, Functor && f)
            {
                f(std::forward<T>(value));
            }
        };
    }

    template <std::size_t I = 0, typename Functor, typename T, std::size_t N>
    typename std::enable_if<I == N, void>::type
        for_each_unroll(T (& arr)[N], Functor && f)
    {
    }

    template <std::size_t I = 0, typename Functor, typename T, std::size_t N>
    typename std::enable_if<I == N, void>::type
        for_each_unroll(T (&& arr)[N], Functor && f)
    {
    }

    template <std::size_t I = 0, typename Functor, typename T, std::size_t N>
    typename std::enable_if<I < N, void>::type
        for_each_unroll(T (& arr)[N], Functor && f)
    {
        detail::_for_each_unroll<std::is_array<T>::value>{ arr[I], std::forward<Functor>(f) };
        for_each_unroll<I + 1, Functor, T, N>(arr, std::forward<Functor>(f));
    }

    template <std::size_t I = 0, typename Functor, typename T, std::size_t N>
    typename std::enable_if<I < N, void>::type
        for_each_unroll(T (&& arr)[N], Functor && f)
    {
        detail::_for_each_unroll<std::is_array<T>::value>{ std::forward<T>(arr[I]), std::forward<Functor>(f) };
        for_each_unroll<I + 1, Functor, T, N>(std::forward<T[N]>(arr), std::forward<Functor>(f));
    }
}

#endif
