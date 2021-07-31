#pragma once

// DO NOT REMOVE, exists to avoid private/public headers mixing!
#ifndef TACKLE_EXPLICIT_TYPE_HPP
#define TACKLE_EXPLICIT_TYPE_HPP

#include <tacklelib/utility/type_traits.hpp>

namespace tackle
{
    template <typename T>
    class excplicit_type;

    // safe bool idiom
    template <>
    class excplicit_type<bool>
    {
        using bool_type = void (excplicit_type::*)() const;

        void _true() const
        {
        }

    public:
        excplicit_type(bool value) :
            value_(value)
        {
        }

    public:
        excplicit_type(const excplicit_type &) = default;
        excplicit_type(excplicit_type &&) = default;

        excplicit_type & operator =(const excplicit_type &) = default;
        //excplicit_type && operator =(excplicit_type &&) = default;

        operator bool_type() const
        {
            if (value_) {
                return &excplicit_type::_true;
            }
            
            return nullptr;
        }

    private:
        bool value_;
    };

    // safe int idiom
    template <>
    class excplicit_type<int>
    {
    public:
        template <typename T_>
        excplicit_type(T_ value) :
            value_(value)
        {
            static_assert(std::is_same<typename utility::remove_cvref<T_>::type, int>::value, "type T_ must be int");
        }

        excplicit_type(const excplicit_type &) = default;
        excplicit_type(excplicit_type &&) = default;

        excplicit_type & operator =(const excplicit_type &) = default;
        //excplicit_type && operator =(excplicit_type &&) = default;

        operator int() const
        {
            return value_;
        }

    private:
        int value_;
    };

    using explicit_bool = excplicit_type<bool>;
    using explicit_int  = excplicit_type<int>;
}

#endif
