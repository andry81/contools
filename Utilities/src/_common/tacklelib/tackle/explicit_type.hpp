#pragma once

// DO NOT REMOVE, exists to avoid private/public headers mixing!
#ifndef TACKLE_EXPLICIT_TYPE_HPP
#define TACKLE_EXPLICIT_TYPE_HPP

#include <tacklelib/utility/type_traits.hpp>

namespace tackle
{
    template <typename T>
    class explicit_type;

    // safe bool idiom
    template <>
    class explicit_type<bool>
    {
        using bool_type = void (explicit_type::*)() const;

        void true_() const
        {
        }

    public:
        explicit_type(bool value) :
            value_(value)
        {
        }

    public:
        explicit_type(const explicit_type &) = default;
        explicit_type(explicit_type &&) = default;

        explicit_type & operator =(const explicit_type &) = default;
        //explicit_type && operator =(explicit_type &&) = default;

        operator bool_type() const
        {
            if (value_) {
                return &explicit_type::true_;
            }
            
            return nullptr;
        }

    private:
        bool value_;
    };

    // safe int idiom
    template <>
    class explicit_type<int>
    {
    public:
        template <typename T_>
        explicit_type(T_ value) :
            value_(value)
        {
            static_assert(std::is_same<typename utility::remove_cvref<T_>::type, int>::value, "type T_ must be int");
        }

        explicit_type(const explicit_type &) = default;
        explicit_type(explicit_type &&) = default;

        explicit_type & operator =(const explicit_type &) = default;
        //explicit_type && operator =(explicit_type &&) = default;

        operator int() const
        {
            return value_;
        }

    private:
        int value_;
    };

    using explicit_bool = explicit_type<bool>;
    using explicit_int  = explicit_type<int>;
}

#endif
