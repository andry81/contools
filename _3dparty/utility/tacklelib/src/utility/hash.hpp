#pragma once

#include <src/tacklelib_private.hpp>

#include <tacklelib/utility/platform.hpp>

#include <boost/functional/hash.hpp>


namespace utility
{
    template <class T>
    FORCE_INLINE void hash_combine(std::size_t & seed, const T & v)
    {
        boost::hash<T> hasher;
        seed ^= hasher(v) + 0x9e3779b9 + (seed << 6) + (seed >> 2);
    }
}
