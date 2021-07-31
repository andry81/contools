#pragma once

// DO NOT REMOVE, exists to avoid private/public headers mixing!
#ifndef UTILITY_TYPE_IDENTITY_HPP
#define UTILITY_TYPE_IDENTITY_HPP

#include <cstdint>
#include <type_traits>


// CAUTION:
//  Redundant parentheses are required here to bypass a tricky error in the GCC 5.4.x around expressions with `>` and `<` characters in case of usage inside another expressions with the same characters:
//      `error: wrong number of template arguments (1, should be at least 2)`
//      `error: macro "..." passed 2 arguments, but takes just 1`
//

// * to suppress warnings around compile time expressions or values
// * to guarantee compile-timeness of an expression
#define UTILITY_CONSTEXPR(exp)                          (::utility::constexpr_bool<(exp) ? true : false>::value)


namespace utility
{
    //// containers

    // to suppress `warning C4127: conditional expression is constant`
    template <bool B, typename...>
    struct constexpr_bool
    {
        static constexpr const bool value = B;
    };

    template <bool B, typename... types>
    const bool constexpr_bool<B, types...>::value;

    // bool identity / identities

    template <bool b>
    struct bool_identity
    {
        using type = bool;
        static constexpr const bool value = b;
    };

    template <bool b>
    constexpr const bool bool_identity<b>::value;

    template <bool... b>
    struct bool_identities
    {
        using type = bool;
        static constexpr const bool values[] = { b... };
    };

    // remove_reference + remove_cv
    template <typename T>
    struct remove_cvref
    {
        using type = typename std::remove_cv<typename std::remove_reference<T>::type>::type;
    };

    // remove_pointer + remove_cv
    template <typename T>
    struct remove_cvptr
    {
        using type = typename std::remove_cv<typename std::remove_pointer<T>::type>::type;
    };

    // remove_reference + remove_cv + remove_pointer + remove_cv
    template <typename T>
    struct remove_cvref_cvptr
    {
        using type = typename remove_cvptr<typename remove_cvref<T>::type>::type;
    };

    // remove_reference + remove_cv + remove_pointer + remove_cv + remove_extent
    template <typename T>
    struct remove_cvref_cvptr_extent
    {
        using type = typename std::remove_extent<typename remove_cvref_cvptr<T>::type>::type;
    };
}

#endif
