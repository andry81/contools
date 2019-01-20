#pragma once

// DO NOT REMOVE, exists to avoid private/public headers mixing!
#ifndef TACKLE_GEOMETRY_VECTOR_HPP
#define TACKLE_GEOMETRY_VECTOR_HPP

#include <tacklelib/utility/platform.hpp>
#include <tacklelib/utility/static_assert.hpp>
#include <tacklelib/utility/assert.hpp>
#include <tacklelib/utility/math.hpp>
#include <tacklelib/utility/memory.hpp>

#include <tacklelib/tackle/static_constexpr.hpp>

#include <cstddef>
#include <cstdlib>
#include <string>
#include <functional>
#include <atomic>
#include <type_traits>
#include <utility>


namespace tackle {
namespace geometry {

template <typename T>
struct BasicVector3
{
    using elem_type = T;
    using arr_type  = elem_type[3];

    elem_type & operator [](size_t index)
    {
        static elem_type dummy_param{};

        switch (index) {
            case 0: return x;
            case 1: return y;
            case 2: return z;
            default: DEBUG_ASSERT_TRUE(false);
        }

        dummy_param = elem_type{};  // to reset if was changed

        return dummy_param; // to protect change of not related parameters
    }

    elem_type operator [](size_t index) const
    {
        switch (index) {
            case 0: return x;
            case 1: return y;
            case 2: return z;
            default: DEBUG_ASSERT_TRUE(false);
        }

        return elem_type{};
    }

    static const BasicVector3 & null()
    {
        return TACKLE_STATIC_CONSTEXPR_VALUE_WITH_ARGS(BasicVector3);
    }

    elem_type x, y, z;
};

using BasicVector3f = BasicVector3<float>;
using BasicVector3d = BasicVector3<double>;

template <typename T>
struct Vector3 : BasicVector3<T>
{
    using base_type = BasicVector3<T>;
    using elem_type = typename base_type::elem_type;

    Vector3(const Vector3 &) = default;
    Vector3(Vector3 &&) = default;

    Vector3 & operator =(const Vector3 &) = default;
    Vector3 & operator =(Vector3 &&) = default;

    Vector3() :
        base_type{}
    {
    }

    Vector3(elem_type x, elem_type y, elem_type z) :
        base_type{ std::move(x), std::move(y), std::move(z) }
    {
    }

    static const Vector3 & null()
    {
        return TACKLE_STATIC_CONSTEXPR_VALUE_WITH_ARGS(Vector3);
    }

    template <typename V0_>
    Vector3 & operator +=(V0_ && k)
    {
        this->x += k;
        this->y += k;
        this->z += k;
        return *this;
    }

    template <typename V0_>
    Vector3 & operator -=(V0_ && k)
    {
        this->x -= k;
        this->y -= k;
        this->z -= k;
        return *this;
    }

    template <typename V0_>
    Vector3 & operator *=(V0_ && k)
    {
        this->x *= k;
        this->y *= k;
        this->z *= k;
        return *this;
    }

    template <typename V0_>
    Vector3 & operator /=(V0_ && k)
    {
        this->x /= k;
        this->y /= k;
        this->z /= k;
        return *this;
    }

    Vector3 & operator +=(Vector3 r)
    {
        this->x += std::move(r.x);
        this->y += std::move(r.y);
        this->z += std::move(r.z);
        return *this;
    }

    Vector3 & operator -=(Vector3 r)
    {
        this->x -= std::move(r.x);
        this->y -= std::move(r.y);
        this->z -= std::move(r.z);
        return *this;
    }
};

using Vector3f = Vector3<float>;
using Vector3d = Vector3<double>;

template <typename T>
inline bool operator ==(const Vector3<T> & l, const Vector3<T> & r)
{
    return l.x == r.x && l.y == r.y && l.z == r.z;
}

template <typename T>
inline bool operator !=(const Vector3<T> & l, const Vector3<T> & r)
{
    return l.x != r.x || l.y != r.y || l.z != r.z;
}

template <typename T, typename V0>
inline Vector3<T> operator +(Vector3<T> vec, V0 && k)
{
    vec += k;
    return vec;
}

template <typename T, typename V0>
inline Vector3<T> operator +(V0 && k, Vector3<T> vec)
{
    vec += k;
    return vec;
}

template <typename T>
inline Vector3<T> operator +(Vector3<T> l, Vector3<T> r)
{
    l += r;
    return l;
}

template <typename T, typename V0>
inline Vector3<T> operator -(Vector3<T> vec, V0 && k)
{
    vec -= k;
    return vec;
}

template <typename T>
inline Vector3<T> operator -(Vector3<T> l, Vector3<T> r)
{
    l -= r;
    return l;
}

template <typename T>
inline Vector3<T> operator -(Vector3<T> vec)
{
    vec.x = -vec.x;
    vec.y = -vec.y;
    vec.z = -vec.z;
    return vec;
}

template <typename T, typename V0>
inline Vector3<T> operator *(Vector3<T> vec, V0 && k)
{
    vec *= k;
    return vec;
}

template <typename T, typename V0>
inline Vector3<T> operator *(V0 && k, Vector3<T> vec)
{
    vec *= k;
    return vec;
}

template <typename T, typename V0>
inline Vector3<T> operator /(Vector3<T> vec, V0 && k)
{
    vec /= k;
    return vec;
}

// normalized vector
template <typename T>
struct Normal3 : public Vector3<T>
{
    using base_type = Vector3<T>;
    using elem_type = typename base_type::elem_type;

    Normal3(const Normal3 &) = default;
    Normal3(Normal3 &&) = default;

    Normal3 & operator =(const Normal3 &) = default;
    Normal3 & operator =(Normal3 &&) = default;

    Normal3() :
        base_type{}
    {
    }

    explicit Normal3(Vector3<T> vec) :
        base_type{ std::move(vec) }
    {
    }

    Normal3(elem_type x, elem_type y, elem_type z) :
        base_type{ std::move(x), std::move(y), std::move(z) }
    {
    }

    static const Normal3 & null()
    {
        return TACKLE_STATIC_CONSTEXPR_VALUE_WITH_ARGS(Normal3);
    }

    void fix_float_trigonometric_range_factor()
    {
        this->x = math::fix_float_trigonometric_range_factor(this->x);
        this->y = math::fix_float_trigonometric_range_factor(this->y);
        this->z = math::fix_float_trigonometric_range_factor(this->z);
    }

    template <typename V0_>
    Normal3 & operator *=(V0_ && k)
    {
        this->x *= k;
        this->y *= k;
        this->z *= k;
        return *this;
    }

    template <typename V0_>
    Normal3 & operator /=(V0_ && k)
    {
        this->x /= k;
        this->y /= k;
        this->z /= k;
        return *this;
    }
};

using Normal3f = Normal3<float>;
using Normal3d = Normal3<double>;

template <typename T>
inline bool operator ==(const Normal3<T> & l, const Normal3<T> & r)
{
    return l.x == r.x && l.y == r.y && l.z == r.z;
}

template <typename T>
inline bool operator !=(const Normal3<T> & l, const Normal3<T> & r)
{
    return l.x != r.x || l.y != r.y || l.z != r.z;
}

template <typename T>
inline Normal3<T> operator -(Normal3<T> vec)
{
    vec.x = -vec.x;
    vec.y = -vec.y;
    vec.z = -vec.z;
    return vec;
}

template <typename T, typename V0>
inline Vector3<T> operator *(Normal3<T> vec, V0 && k)
{
    vec *= k;
    return vec;
}

template <typename T, typename V0>
inline Vector3<T> operator *(V0 && k, Normal3<T> vec)
{
    vec *= k;
    return vec;
}

template <typename T>
struct BasicVector4
{
    using elem_type = T;
    using arr_type  = elem_type[4];

    elem_type & operator [](size_t index)
    {
        static elem_type dummy_param{};

        switch (index) {
            case 0: return x;
            case 1: return y;
            case 2: return z;
            case 3: return w;
            default: DEBUG_ASSERT_TRUE(false);
        }

        dummy_param = elem_type{};  // to reset if was changed

        return dummy_param; // to protect change of not related parameters
    }

    elem_type operator [](size_t index) const
    {
        switch (index) {
            case 0: return x;
            case 1: return y;
            case 2: return z;
            case 3: return w;
            default: DEBUG_ASSERT_TRUE(false);
        }
        return elem_type{};
    }

    static const BasicVector4 & null()
    {
        return TACKLE_STATIC_CONSTEXPR_VALUE_WITH_ARGS(BasicVector4);
    }

    elem_type x, y, z, w;
};

using BasicVector4f = BasicVector4<float>;
using BasicVector4d = BasicVector4<double>;

template <typename T>
struct Vector4 : public BasicVector4<T>
{
    using base_type = BasicVector4<T>;
    using elem_type = typename base_type::elem_type;

    Vector4(const Vector4 &) = default;
    Vector4(Vector4 &&) = default;

    Vector4 & operator =(const Vector4 &) = default;
    Vector4 & operator =(Vector4 &&) = default;

    Vector4() :
        base_type{}
    {
    }

    Vector4(Vector3<T> v, elem_type w) :
        base_type{ std::move(v.x), std::move(v.y), std::move(v.z), std::move(w) }
    {
    }

    Vector4(elem_type x, elem_type y, elem_type z, elem_type w) :
        base_type{ std::move(x), std::move(y), std::move(z), std::move(w) }
    {
    }

    Vector3<T> basis() const
    {
        return Vector3<T>{ this->x, this->y, this->z };
    }
};

using Vector4f = Vector4<float>;
using Vector4d = Vector4<double>;

template <typename T>
inline bool operator ==(const Vector4<T> & l, const Vector4<T> & r)
{
    return l.x == r.x && l.y == r.y && l.z == r.z && l.w == r.w;
}

template <typename T>
inline bool operator !=(const Vector4<T> & l, const Vector4<T> & r)
{
    return l.x != r.x || l.y != r.y || l.z != r.z || l.w != r.w;
}

template <typename T>
inline Vector3<T> operator -(Vector4<T> l, Vector4<T> r)
{
    return Vector3<T>{ l.x - r.x, l.y - r.y, l.z - r.z };
}

template <typename T>
inline Vector3<T> operator +(Vector4<T> l, Vector4<T> r)
{
    return Vector3<T>{ l.x + r.x, l.y + r.y, l.z + r.z };
}

template <typename T>
struct NormalMatrix3x3
{
    using elem_type = Normal3<T>;

    NormalMatrix3x3(const NormalMatrix3x3 &) = default;
    NormalMatrix3x3(NormalMatrix3x3 &&) = default;

    NormalMatrix3x3 & operator =(const NormalMatrix3x3 &) = default;
    NormalMatrix3x3 & operator =(NormalMatrix3x3 &&) = default;

    NormalMatrix3x3()
    {
    }

    NormalMatrix3x3(const elem_type (& vec_mat)[3]) :
        m{ vec_mat[0], vec_mat[1], vec_mat[2] }
    {
    }

    NormalMatrix3x3(elem_type vec0, elem_type vec1, elem_type vec2) :
        m{ std::move(vec0), std::move(vec1), std::move(vec2) }
    {
    }

    elem_type & operator [](size_t index)
    {
        static elem_type dummy_param{};

        if (index < 3) {
            return m[index];
        }

        DEBUG_ASSERT_TRUE(false);

        dummy_param = elem_type{};  // to reset if was changed

        return dummy_param; // to protect change of not related parameters
    }

    const elem_type & operator [](size_t index) const
    {
        if (index < 3) {
            return m[index];
        }

        DEBUG_ASSERT_TRUE(false);

        return elem_type::null();
    }

    void fix_float_trigonometric_range_factor()
    {
        m[0].fix_float_trigonometric_range_factor();
        m[1].fix_float_trigonometric_range_factor();
        m[2].fix_float_trigonometric_range_factor();
    }

    static const NormalMatrix3x3 & null()
    {
        return TACKLE_STATIC_CONSTEXPR_VALUE_WITH_ARGS(NormalMatrix3x3);
    }

    template <typename V0_>
    void validate(V0_ && unit_square_epsilon) const;

    elem_type m[3];
};

using NormalMatrix3x3f = NormalMatrix3x3<float>;
using NormalMatrix3x3d = NormalMatrix3x3<double>;

template <typename T>
inline bool operator ==(const NormalMatrix3x3<T> & l, const NormalMatrix3x3<T> & r)
{
    return l.m[0] == r.m[0] && l.m[1] == r.m[1] && l.m[2] == r.m[2];
}

template <typename T>
inline bool operator !=(const NormalMatrix3x3<T> & l, const NormalMatrix3x3<T> & r)
{
    return l.m[0] != r.m[0] || l.m[1] != r.m[1] || l.m[2] != r.m[2];
}

template <typename T>
void vector_cross_product(Vector3<T> & vec_out, Vector3<T> vec_first, Vector3<T> vec_second);

template <typename T, typename V0>
bool vector_is_equal(Vector3<T> l, Vector3<T> r, V0 && vec_square_epsilon);

template <typename T> template <typename V0_>
inline void NormalMatrix3x3<T>::validate(V0_ && unit_square_epsilon) const
{
    // self test matrix on consistency
#if DEBUG_ASSERT_VERIFY_ENABLED
    NormalMatrix3x3 vec_mat_test;
    vector_cross_product(vec_mat_test.m[2], m[0], m[1]);
    vector_cross_product(vec_mat_test.m[0], m[1], m[2]);
    vector_cross_product(vec_mat_test.m[1], m[2], m[0]);

    DEBUG_ASSERT_TRUE(vector_is_equal(vec_mat_test.m[0], m[0], unit_square_epsilon));
    DEBUG_ASSERT_TRUE(vector_is_equal(vec_mat_test.m[1], m[1], unit_square_epsilon));
    DEBUG_ASSERT_TRUE(vector_is_equal(vec_mat_test.m[2], m[2], unit_square_epsilon));
#else
    UTILITY_UNUSED_EXPR(unit_square_epsilon);
#endif
}

}
}

#endif
