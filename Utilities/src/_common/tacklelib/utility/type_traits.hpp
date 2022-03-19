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
    inline typename std::enable_if<I == sizeof...(Args), void>::type
        for_each(std::tuple<Args...> &, Functor &&)
    {
    }

    template<std::size_t I = 0, typename Functor, typename... Args>
    inline typename std::enable_if<I < sizeof...(Args), void>::type
        for_each(std::tuple<Args...> & t, Functor && f)
    {
        f(std::get<I>(t));
        for_each<I + 1, Functor, Args...>(t, std::forward<Functor>(f));
    }

    // Unrolled breakable `for_each` for multidimensional arrays

    namespace detail
    {
        template<bool is_array>
        struct _for_each_unroll
        {
            template <typename Functor, typename T, std::size_t N>
            _for_each_unroll(_for_each_unroll * parent_, T (& arr)[N], Functor && f) :
                parent(parent_), break_(false)
            {
                invoke(arr, std::forward<Functor>(f));
            }

            template <typename Functor, typename T, std::size_t N>
            _for_each_unroll(_for_each_unroll * parent_, T (&& arr)[N], Functor && f) :
                parent(parent_), break_(false)
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
                if (!break_) {
                    _for_each_unroll<std::is_array<T>::value> nested_for_each{ this, arr[I], std::forward<Functor>(f) };
                    if (!nested_for_each.break_) {
                        invoke<I + 1, Functor, T, N>(arr, std::forward<Functor>(f));
                    }
                    else if (parent) parent->break_ = true;
                }
            }

            template <std::size_t I = 0, typename Functor, typename T, std::size_t N>
            typename std::enable_if<I < N, void>::type
                invoke(T (&& arr)[N], Functor && f)
            {
                if (!break_) {
                    _for_each_unroll<std::is_array<T>::value> nested_for_each{ this, std::forward<T>(arr[I]), std::forward<Functor>(f) };
                    if (!nested_for_each.break_) {
                        invoke<I + 1, Functor, T, N>(arr, std::forward<Functor>(f));
                    }
                    else if (parent) parent->break_ = true;
                }
            }

            _for_each_unroll * parent;
            bool break_;
        };

        template <typename Functor, typename T, bool is_array>
        inline void _invoke_breakable(_for_each_unroll<is_array> & this_, const T & value, Functor && f, bool_identity<false> is_breakable)
        {
            f(value);
        };

        template <typename Functor, typename T, bool is_array>
        inline void _invoke_breakable(_for_each_unroll<is_array> & this_, const T & value, Functor && f, bool_identity<true> is_breakable)
        {
            if (!f(value)) {
                this_.break_ = true;
            }
        };

        template <typename Functor, typename T, bool is_array>
        inline void _invoke_breakable(_for_each_unroll<is_array> & this_, T && value, Functor && f, bool_identity<false> is_breakable)
        {
            f(std::forward<T>(value));
        };

        template <typename Functor, typename T, bool is_array>
        inline void _invoke_breakable(_for_each_unroll<is_array> & this_, T && value, Functor && f, bool_identity<true> is_breakable)
        {
            if (!f(std::forward<T>(value))) {
                this_.break_ = true;
            }
        };

        template<>
        struct _for_each_unroll<false>
        {
            template <typename Functor, typename T>
            _for_each_unroll(void * parent, const T & value, Functor && f) :
                break_(false)
            {
                _invoke_breakable(*this, value, std::forward<Functor>(f), bool_identity<!std::is_void<decltype(f(value))>::value>{});
            }

            template <typename Functor, typename T>
            _for_each_unroll(void * parent, T && value, Functor && f) :
                break_(false)
            {
                _invoke_breakable(*this, value, std::forward<Functor>(f), bool_identity<!std::is_void<decltype(f(std::forward<T>(value)))>::value>{});
            }

            bool break_;
        };
    }

    template <std::size_t I = 0, typename Functor, typename T, std::size_t N>
    inline typename std::enable_if<I == N, void>::type
        for_each_unroll(T (& arr)[N], Functor && f)
    {
    }

    template <std::size_t I = 0, typename Functor, typename T, std::size_t N>
    inline typename std::enable_if<I == N, void>::type
        for_each_unroll(T (&& arr)[N], Functor && f)
    {
    }

    template <std::size_t I = 0, typename Functor, typename T, std::size_t N>
    inline typename std::enable_if<I < N, void>::type
        for_each_unroll(T (& arr)[N], Functor && f)
    {
        detail::_for_each_unroll<std::is_array<T>::value> nested_for_each{ nullptr, arr[I], std::forward<Functor>(f) };
        if (!nested_for_each.break_) {
            for_each_unroll<I + 1, Functor, T, N>(arr, std::forward<Functor>(f));
        }
    }

    template <std::size_t I = 0, typename Functor, typename T, std::size_t N>
    inline typename std::enable_if<I < N, void>::type
        for_each_unroll(T (&& arr)[N], Functor && f)
    {
        detail::_for_each_unroll<std::is_array<T>::value> nested_for_each{ nullptr, std::forward<T>(arr[I]), std::forward<Functor>(f) };
        if (!nested_for_each.break_) {
            for_each_unroll<I + 1, Functor, T, N>(std::forward<T[N]>(arr), std::forward<Functor>(f));
        }
    }
}

#endif
