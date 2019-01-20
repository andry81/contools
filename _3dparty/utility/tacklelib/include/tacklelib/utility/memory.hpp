#pragma once

// DO NOT REMOVE, exists to avoid private/public headers mixing!
#ifndef UTILITY_MEMORY_HPP
#define UTILITY_MEMORY_HPP

#include <tacklelib/tacklelib.hpp>

#include <tacklelib/utility/platform.hpp>
#include <tacklelib/utility/type_traits.hpp>
#include <tacklelib/utility/addressof.hpp>
#include <tacklelib/utility/assert.hpp>
#include <tacklelib/utility/debug.hpp>

#include <fmt/format.h>

#include <type_traits>
#include <cstdint>
#include <cstdio>
#include <memory>
#include <stdexcept>


#ifndef UTILITY_PLATFORM_FEATURE_CXX_STANDARD_MAKE_UNIQUE

// std::make_unique is supported from C++14.
// implementation taken from C++ ISO papers: https://isocpp.org/files/papers/N3656.txt
//
namespace std
{
    template <typename T, typename D>
    class unique_ptr;

    namespace detail
    {
        template<class T>
        struct _unique_if
        {
            typedef unique_ptr<T> _single_object;
        };

        template<class T>
        struct _unique_if<T[]>
        {
            typedef unique_ptr<T[]> _unknown_bound;
        };

        template<class T, size_t N>
        struct _unique_if<T[N]>
        {
            typedef void _known_bound;
        };
    }

    template<class T, class... Args>
    inline typename detail::_unique_if<T>::_single_object make_unique(Args &&... args)
    {
        return unique_ptr<T>(new T(std::forward<Args>(args)...));
    }

    template<class T>
    inline typename detail::_unique_if<T>::_unknown_bound make_unique(size_t n)
    {
        typedef typename remove_extent<T>::type U;
        return unique_ptr<T>(new U[n]());
    }

    template<class T, class... Args>
    typename detail::_unique_if<T>::_known_bound make_unique(Args &&...) = delete;
}

#endif

namespace utility
{
    enum MemoryType
    {
        MemType_VirtualMemory   = 1,
        MemType_PhysicalMemory  = 2
    };

    // proc_id:
    //  0               - current process
    //  *               - target process
    size_t get_process_memory_size(MemoryType mem_type, size_t proc_id);

    // simple buffer to reallocate memory on demand
    //
    //  CAUTION:
    //      Because the buffer class does not reallocate memory if requested buffer size less than already existed, then out of size read/write access WOULD NOT BE CATCHED!
    //      To workaround that we must AT LEAST do guard the end of the buffer in the DEBUG.
    //
    class Buffer
    {
    public:
        // memory power-of-2 sizes
        enum : uint64_t {
            _1KB    = 1 * 1024,                     _2KB    = 2 * 1024,                     _4KB    = 4 * 1024,
            _8KB    = 8 * 1024,                     _16KB   = 16 * 1024,                    _32KB   = 32 * 1024,
            _64KB   = 64 * 1024,                    _128KB  = 128 * 1024,                   _256KB  = 256 * 1024,
            _512KB  = 512 * 1024,                   _1MB    = 1 * 1024 * 1024,              _2MB    = 2 * 1024 * 1024,
            _4MB    = 4 * 1024 * 1024,              _8MB    = 8 * 1024 * 1024,              _16MB   = 16 * 1024 * 1024,
            _32MB   = 32 * 1024 * 1024,             _64MB   = 64 * 1024 * 1024,             _128MB  = 128 * 1024 * 1024,
            _256MB  = 256 * 1024 * 1024,            _512MB  = 512 * 1024 * 1024,            _1GB    = 1 * 1024 * 1024 * 1024,
            _2GB    = 2ULL * 1024 * 1024 * 1024,    _4GB    = 4ULL * 1024 * 1024 * 1024,    _8GB    = 8ULL * 1024 * 1024 * 1024,
        };

    protected:
        using BufPtr = std::unique_ptr<uint8_t[]>;
        using GuardSequenceStr_t = char [49];

        FORCE_INLINE static CONSTEXPR_RETURN const GuardSequenceStr_t & _guard_sequence_str()
        {
            return "XYZXYZXYZXYZXYZXYZXYZXYZXYZXYZXYZXYZXYZXYZXYZXYZ";
        }

        FORCE_INLINE static CONSTEXPR_RETURN const size_t _guard_max_len()
        {
            return 256; // to avoid comparison slow down on big arrays
        }

    public:
        FORCE_INLINE Buffer(size_t size = 0) :
            m_offset(0), m_size(0), m_reserve(0), m_is_reallocating(false)
        {
            if (size) { // optimization to avoid an empty call in constructor
                reset(size);
            }
        }

        FORCE_INLINE ~Buffer()
        {
#if !ERROR_IF_EMPTY_PP_DEF(DISABLE_BUFFER_GUARD_CHECK) && (ERROR_IF_EMPTY_PP_DEF(ENABLE_PERSISTENT_BUFFER_GUARD_CHECK) || defined(_DEBUG))
            check_buffer_guards();
#endif
        }

        void check_buffer_guards();

    private:
        void _fill_buffer_guards();

    public:
        FORCE_INLINE void reset(size_t size)
        {
#if !ERROR_IF_EMPTY_PP_DEF(DISABLE_BUFFER_GUARD_CHECK) && (ERROR_IF_EMPTY_PP_DEF(ENABLE_PERSISTENT_BUFFER_GUARD_CHECK) || defined(_DEBUG))
            check_buffer_guards();

            // minimum 16 bytes or 1% of allocation size for guard sections on the left and right, but not greater than `s_guard_max_len`
            const size_t offset = (std::min)((std::max)(size / 100, 16U), _guard_max_len());
            const size_t size_extra = size ? (size + offset * 2) : 0;
#else
            const size_t offset = 0;
            const size_t size_extra = size;
#endif

            // reallocate only if greater, deallocate only if 0
            if (size_extra) {
                if (m_reserve < size_extra) {
                    m_buf_ptr = BufPtr(new uint8_t[size_t(size_extra)], std::default_delete<uint8_t[]>());
                    m_reserve = size_extra;
                }

                m_offset = offset;
                m_size = size;

#if !ERROR_IF_EMPTY_PP_DEF(DISABLE_BUFFER_GUARD_CHECK) && (ERROR_IF_EMPTY_PP_DEF(ENABLE_PERSISTENT_BUFFER_GUARD_CHECK) || defined(_DEBUG))
                _fill_buffer_guards();
#endif
            }
            else {
                m_buf_ptr.reset();
                m_offset = m_reserve = m_size = 0;
            }
        }

        FORCE_INLINE size_t size() const
        {
            return m_size;
        }

        FORCE_INLINE uint8_t * get()
        {
            DEBUG_ASSERT_TRUE(m_size);
            return m_buf_ptr.get() + m_offset;
        }

        FORCE_INLINE const uint8_t * get() const
        {
            DEBUG_ASSERT_TRUE(m_size);
            return m_buf_ptr.get() + m_offset;
        }

        FORCE_INLINE uint8_t * realloc_get(size_t size)
        {
            reset(size);

#if ERROR_IF_EMPTY_PP_DEF(ENABLE_BUFFER_REALLOC_AFTER_ALLOC)
            if (!m_is_reallocating)
            {
                Buffer local_buf;

                local_buf.set_reallocating(true);

                realloc_debug(local_buf);
            }
#endif

            return m_buf_ptr.get() + m_offset;
        }

        FORCE_INLINE void set_reallocating(bool is_reallocating)
        {
            m_is_reallocating = is_reallocating;
        }

        FORCE_INLINE uint8_t * release()
        {
            m_offset = m_size = m_reserve = 0;
            return m_buf_ptr.release();
        }

        // for memory debugging on a moment of deallocation
        FORCE_INLINE void realloc_debug(Buffer & to_buf)
        {
            uint8_t * to_buf_ptr = to_buf.realloc_get(m_size);
            memcpy(to_buf_ptr - to_buf.m_offset, m_buf_ptr.get(), size_t(m_reserve));

            m_buf_ptr.reset(to_buf.release());
        }

    private:
        size_t  m_offset;
        size_t  m_size;
        size_t  m_reserve;
        BufPtr  m_buf_ptr;
        bool    m_is_reallocating;
    };

}

#endif
