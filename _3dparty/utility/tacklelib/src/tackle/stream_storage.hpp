#pragma once

#include <src/tacklelib_private.hpp>

#include <tacklelib/utility/utility.hpp>
#include <tacklelib/utility/static_assert.hpp>
#include <tacklelib/utility/type_traits.hpp>
#include <tacklelib/utility/assert.hpp>
#include <tacklelib/utility/math.hpp>
#include <tacklelib/utility/algorithm.hpp>

#include <tacklelib/tackle/aligned_storage/max_aligned_storage.hpp>
#include <tacklelib/tackle/deque.hpp>

#include <boost/mpl/vector.hpp>
#include <boost/mpl/list.hpp>
#include <boost/mpl/push_front.hpp>

#include <boost/scope_exit.hpp>

#include <fmt/format.h>

#include <deque>
#include <utility>
#include <algorithm>
#include <type_traits>


namespace tackle
{
    namespace mpl = boost::mpl;

    template <typename T>
    class stream_storage;

    namespace detail
    {
        template <bool ForceInline>
        struct _inline_dispatch
        {
            template <typename T, typename C>
            static size_t _copy_to_impl(const stream_storage<T> & this_, const C & chunks, size_t offset_from, T * to_buf, size_t size) {
                return this_._copy_to_impl(chunks, offset_from, to_buf, size);
            }
        };

        template <>
        struct _inline_dispatch<true>
        {
            template <typename T, typename C>
            static size_t _copy_to_impl(const stream_storage<T> & this_, const C & chunks, size_t offset_from, T * to_buf, size_t size) {
                return this_._copy_to_impl_innerforceinline(chunks, offset_from, to_buf, size);
            }
        };
    }

    template <typename T>
    class stream_storage
    {
#if ERROR_IF_EMPTY_PP_DEF(ENABLE_INTERNAL_FORCE_INLINE_IN_STREAM_STORAGE)
        static const int s_default_inner_inline_level = 1;
#else
        static const int s_default_inner_inline_level = 0;
#endif

    public:
        // up to 256KB chunks (1, 2, 4, 8, 16, ..., 128 * 1024, 256 * 1024)
        using num_chunk_variants_t = mpl::size_t<19>;
        using max_chunk_size_t = mpl::size_t<(0x01U << (num_chunk_variants_t::value - 1))>;

        STATIC_ASSERT_LT(num_chunk_variants_t::value, BOOST_MPL_LIMIT_LIST_SIZE, "must be less than the limit");

    private:
        static CONSTEXPR size_t _get_chunk_size(size_t type_index)
        {
            return (0x01U << type_index);
        }

        // POD type, DO NOT USE constructors, the `buf` ending must be connected w/o gaps with the next element beginning in case of array usage as an underlaying container!
        template <size_t S>
        struct Chunk
        {
            static const size_t size = S;

            T buf[S];
        };

    public:
        using max_sizeof_t = mpl::size_t<(0x01U << (num_chunk_variants_t::value - 1))>;

        // generator of the deque with the power of 2 sized chunks
        template <template <typename, typename, typename> class, size_t, typename> struct tackle_deque_chunks_pof2_generator;
        template <template <typename, typename> class, size_t, typename> struct std_deque_chunks_pof2_generator;

        // generator of the deque const iterators from the power of 2 sized chunks
        template <template <typename, typename, typename> class, size_t, typename> struct tackle_deque_chunk_const_iterators_pof2_generator;
        template <template <typename, typename> class, size_t, typename> struct std_deque_chunk_const_iterators_pof2_generator;

        template <template <typename, typename, typename> class TDequeContainer, typename V>
        struct tackle_deque_chunks_pof2_generator<TDequeContainer, 0, V>
        {
            using type = V;
        };

        template <template <typename, typename> class TDequeContainer, typename V>
        struct std_deque_chunks_pof2_generator<TDequeContainer, 0, V>
        {
            using type = V;
        };

        template <template <typename T_, typename Allocator0, typename Allocator1> class TDequeContainer, size_t N, typename V>
        struct tackle_deque_chunks_pof2_generator
        {
            using chunk_type = Chunk<(size_t(0x01) << (N - 1))>;
            STATIC_ASSERT_EQ(sizeof(chunk_type), sizeof(T) * chunk_type::size, "Chunk should contain pure static array inside with out any gaps or padding");

            using base_type = tackle::deque_base<chunk_type>;

            using next_type_t = TDequeContainer<chunk_type, typename base_type::default_allocator_type0, typename base_type::default_allocator_type1>;
            using type = typename tackle_deque_chunks_pof2_generator<TDequeContainer, N - 1, typename mpl::push_front<V, next_type_t>::type>::type;
        };

        template <template <typename, typename> class TDequeContainer, size_t N, typename V>
        struct std_deque_chunks_pof2_generator
        {
            using chunk_type = Chunk<(size_t(0x01) << (N - 1))>;
            STATIC_ASSERT_EQ(sizeof(chunk_type), sizeof(T) * chunk_type::size, "Chunk should contain pure static array inside with out any gaps or padding");

            using next_type_t = TDequeContainer<chunk_type, typename std::deque<chunk_type>::allocator_type>;
            using type = typename std_deque_chunks_pof2_generator<TDequeContainer, N - 1, typename mpl::push_front<V, next_type_t>::type>::type;
        };


        template <template <typename, typename, typename> class TDequeContainer, typename V>
        struct tackle_deque_chunk_const_iterators_pof2_generator<TDequeContainer, 0, V>
        {
            using type = V;
        };

        template <template <typename, typename> class TDequeContainer, typename V>
        struct std_deque_chunk_const_iterators_pof2_generator<TDequeContainer, 0, V>
        {
            using type = V;
        };

        template <template <typename, typename, typename> class TDequeContainer, size_t N, typename V>
        struct tackle_deque_chunk_const_iterators_pof2_generator
        {
            using chunk_type = Chunk<(size_t(0x01) << (N - 1))>;
            STATIC_ASSERT_EQ(sizeof(chunk_type), sizeof(T) * chunk_type::size, "Chunk should contain pure static array inside with out any gaps or padding");

            using base_type = tackle::deque_base<chunk_type>;

            using next_type_t = typename TDequeContainer<chunk_type, typename base_type::default_allocator_type0, typename base_type::default_allocator_type1>::const_iterator;
            using type = typename tackle_deque_chunk_const_iterators_pof2_generator<TDequeContainer, N - 1, typename mpl::push_front<V, next_type_t>::type>::type;
        };

        template <template <typename, typename> class TDequeContainer, size_t N, typename V>
        struct std_deque_chunk_const_iterators_pof2_generator
        {
            using chunk_type = Chunk<(size_t(0x01) << (N - 1))>;
            STATIC_ASSERT_EQ(sizeof(chunk_type), sizeof(T) * chunk_type::size, "Chunk should contain pure static array inside with out any gaps or padding");

            using next_type_t = typename TDequeContainer<chunk_type, typename std::deque<chunk_type>::allocator_type>::const_iterator;
            using type = typename std_deque_chunk_const_iterators_pof2_generator<TDequeContainer, N - 1, typename mpl::push_front<V, next_type_t>::type>::type;
        };

        using mpl_empty_container_t = mpl::list<>; // begin of mpl container usage

        using tackle_deques_mpl_container_t =
            typename tackle_deque_chunks_pof2_generator<tackle::deque, num_chunk_variants_t::value, mpl_empty_container_t>::type;
        using tackle_deque_const_iterators_mpl_container_t =
            typename tackle_deque_chunk_const_iterators_pof2_generator<tackle::deque, num_chunk_variants_t::value, mpl_empty_container_t>::type;

        using std_deques_mpl_container_t =
            typename std_deque_chunks_pof2_generator<std::deque, num_chunk_variants_t::value, mpl_empty_container_t>::type;
        using std_deque_const_iterators_mpl_container_t =
            typename std_deque_chunk_const_iterators_pof2_generator<std::deque, num_chunk_variants_t::value, mpl_empty_container_t>::type;

#if ERROR_IF_EMPTY_PP_DEF(ENABLE_INTERNAL_TACKLE_DEQUE_IN_STREAM_STORAGE)
        using deque_const_iterators_mpl_container_t = tackle_deque_const_iterators_mpl_container_t;
#else
        using deque_const_iterators_mpl_container_t = std_deque_const_iterators_mpl_container_t;
#endif


    public:
#if ERROR_IF_EMPTY_PP_DEF(ENABLE_INTERNAL_TACKLE_DEQUE_IN_STREAM_STORAGE)
        using storage_types_t = tackle_deques_mpl_container_t;
#else
        using storage_types_t = std_deques_mpl_container_t;
#endif

    private:
        using max_aligned_storage_from_mpl_container_t  = max_aligned_storage_from_mpl_container<storage_types_t>;
        using max_aligned_storage_for_tackle_deques_t   = max_aligned_storage_from_mpl_container<tackle_deques_mpl_container_t>;
        using max_aligned_storage_for_std_deques_t      = max_aligned_storage_from_mpl_container<std_deques_mpl_container_t>;

    public:
        static const size_t max_size_value              = utility::static_if
            <UTILITY_CONST_EXPR(max_aligned_storage_for_tackle_deques_t::max_size_value >= max_aligned_storage_for_std_deques_t::max_size_value)>
            (max_aligned_storage_for_tackle_deques_t::max_size_value, max_aligned_storage_for_std_deques_t::max_size_value);
        static const size_t max_alignment_value         = utility::static_if
            <UTILITY_CONST_EXPR(max_aligned_storage_for_tackle_deques_t::max_alignment_value >= max_aligned_storage_for_std_deques_t::max_alignment_value)>
            (max_aligned_storage_for_tackle_deques_t::max_alignment_value, max_aligned_storage_for_std_deques_t::max_alignment_value);

    private:
        using storage_types_end_it_t                    = typename mpl::end<storage_types_t>::type;
        using num_types_t                               = typename mpl::size<storage_types_t>::type;

        STATIC_ASSERT_GT(num_types_t::value, 0, "template must generate not empty mpl container");

    public:
        class ChunkBufferCRef
        {
            friend class stream_storage;

        private:
            ChunkBufferCRef() :
                m_buf(nullptr), m_size(0)
            {
            }

            ChunkBufferCRef(const T * buf, size_t size) :
                m_buf(buf), m_size(size)
            {
                DEBUG_ASSERT_TRUE(buf && size);
            }

        public:
            const T * get() const
            {
                return m_buf;
            }

            size_t size() const
            {
                return m_size;
            }

        private:
            const T *   m_buf;
            size_t      m_size;
        };

        class basic_const_iterator
        {
            friend class stream_storage;

            using storage_types_t = deque_const_iterators_mpl_container_t;
            using storage_types_end_it_t = typename mpl::end<storage_types_t>::type;
            using num_types_t = typename mpl::size<storage_types_t>::type;

            STATIC_ASSERT_GT(num_types_t::value, 0, "template must generate not empty mpl container");

            using iterator_storage_t = max_aligned_storage_from_mpl_container<storage_types_t>;


        public:
            basic_const_iterator();
            basic_const_iterator(const basic_const_iterator & it);

        private:
            basic_const_iterator(const iterator_storage_t & iterator_storage);

        public:
            basic_const_iterator & operator =(const basic_const_iterator & it);

            ChunkBufferCRef operator *() const;
            ChunkBufferCRef operator ->() const;

            bool operator ==(const basic_const_iterator &) const;
            bool operator !=(const basic_const_iterator &) const;

            basic_const_iterator operator ++(int);
            basic_const_iterator & operator ++();
            basic_const_iterator operator --(int);
            basic_const_iterator & operator --();

        private:
            iterator_storage_t m_iterator_storage;
        };

    public:
        using const_iterator = basic_const_iterator;

        stream_storage(size_t min_chunk_size, size_t min_arr0_capacity, size_t min_arr1_capacity);
        ~stream_storage();

        void reset(size_t min_chunk_size, size_t min_arr0_capacity, size_t min_arr1_capacity);

    protected:
        template <typename T_>
        void _clear(T_ & chunks);

    public:
        void clear();
        const_iterator begin() const;
        const_iterator end() const;
        size_t chunk_size() const;
        size_t size() const;
        size_t remainder() const;
        void push_back(const T * p, size_t size);
        T & operator[](size_t offset);
        const T & operator[](size_t offset) const;
    protected:
        template <typename C>
        size_t _copy_to_impl(const C & chunks, size_t offset_from, T * to_buf, size_t to_size) const;
        template <typename C>
        FORCE_INLINE size_t _copy_to_impl_innerforceinline(const C & chunks, size_t offset_from, T * to_buf, size_t to_size) const; // version with internal force inline

//        template <typename C>
//        size_t _inner_stride_copy_to_impl(const C & chunks, size_t offset_from, size_t from_size,
//            size_t stride_offset, size_t stride_size, T * to_buf, size_t to_size) const;

        template <bool InnerForceInline>
        FORCE_INLINE size_t _stride_copy_to_impl_innerforceinline(size_t offset_from, size_t in_row_offset_from, size_t stream_width,
            size_t slot_begin_in_row_offset, size_t slot_end_in_row_offset, T * to_buf, size_t max_slot_size,
            size_t * in_stream_slot_offset_ptr, size_t * in_slot_byte_offset_ptr, size_t * end_stride_byte_offset_ptr) const;

        // static member call dispatch, useful to expose only one function at a time for inline optimization
        template <bool ForceInline>
        friend struct detail::_inline_dispatch;

    public:
        template <int InnerInlineLevel = s_default_inner_inline_level>
        size_t copy_to(size_t offset_from, T * to_buf, size_t size) const;

        template <int InnerInlineLevel = s_default_inner_inline_level>
        size_t stride_copy_to(size_t offset_from, size_t in_row_offset_from, size_t stream_width,
            size_t slot_begin_in_row_offset, size_t slot_end_in_row_offset, T * to_buf, size_t max_slot_size,
            size_t * in_stream_slot_offset_ptr, size_t * in_slot_byte_offset_ptr, size_t * end_stride_byte_offset_ptr) const;

        template <int InnerInlineLevel = s_default_inner_inline_level>
        FORCE_INLINE size_t stride_copy_to_forceinline(size_t offset_from, size_t in_row_offset_from, size_t stream_width,
            size_t slot_begin_in_row_offset, size_t slot_end_in_row_offset, T * to_buf, size_t max_slot_size,
            size_t * in_stream_slot_offset_ptr, size_t * in_slot_byte_offset_ptr, size_t * end_stride_byte_offset_ptr) const;

        size_t erase_front(size_t size);

    private:
        max_aligned_storage_from_mpl_container_t    m_chunks;
        size_t                                      m_size;
        size_t                                      m_remainder;
    };

    //// stream_storage::basic_const_iterator

    template <typename T>
    inline stream_storage<T>::basic_const_iterator::basic_const_iterator()
    {
    }

    template <typename T>
    inline stream_storage<T>::basic_const_iterator::basic_const_iterator(const basic_const_iterator & it)
    {
        *this = it;
    }

    template <typename T>
    inline stream_storage<T>::basic_const_iterator::basic_const_iterator(const iterator_storage_t & iterator_storage)
    {
        m_iterator_storage.construct(iterator_storage, false);
    }

    template <typename T>
    inline typename stream_storage<T>::basic_const_iterator & stream_storage<T>::basic_const_iterator::operator =(const basic_const_iterator & it)
    {
        m_iterator_storage.assign(it.m_iterator_storage);

        return *this;
    }

    template <typename T>
    inline typename stream_storage<T>::ChunkBufferCRef stream_storage<T>::basic_const_iterator::operator *() const
    {
        return m_iterator_storage.template invoke<ChunkBufferCRef>([&](const auto & chunks_it)
        {
            return ChunkBufferCRef{ chunks_it->buf, utility::static_size(chunks_it->buf) };
        });
    }

    template <typename T>
    inline typename stream_storage<T>::ChunkBufferCRef stream_storage<T>::basic_const_iterator::operator ->() const
    {
        return this->operator *();
    }

    template <typename T>
    inline bool stream_storage<T>::basic_const_iterator::operator ==(const basic_const_iterator & it) const
    {
        const int left_type_index = m_iterator_storage.type_index();
        const int right_type_index = it.m_iterator_storage.type_index();
        if (left_type_index != right_type_index) {
            DEBUG_BREAK_THROW(true) std::runtime_error(
                fmt::format("{:s}({:d}): incompatible iterator storages: left_type_index={:d} right_type_index={:d}",
                    UTILITY_PP_FUNCSIG, UTILITY_PP_LINE, left_type_index, right_type_index));
        }

        return m_iterator_storage.template invoke<bool>([&](const auto & chunks_it)
        {
            using ref_chunk_it_t = decltype(chunks_it);
            using chunk_it_t = typename boost::remove_reference<ref_chunk_it_t>::type;

            const auto & right_chunk_it = *static_cast<const chunk_it_t *>(it.m_iterator_storage.address());

            return chunks_it == right_chunk_it;
        });
    }

    template <typename T>
    inline bool stream_storage<T>::basic_const_iterator::operator !=(const basic_const_iterator & it) const
    {
        return !this->operator ==(it);
    }

    template <typename T>
    inline typename stream_storage<T>::basic_const_iterator stream_storage<T>::basic_const_iterator::operator ++(int)
    {
        const auto it = *this;

        m_iterator_storage.template invoke<void>([](auto & chunks_it)
        {
            chunks_it++;
        });

        return it;
    }

    template <typename T>
    inline typename stream_storage<T>::basic_const_iterator & stream_storage<T>::basic_const_iterator::operator ++()
    {
        m_iterator_storage.template invoke<void>([](auto & chunks_it)
        {
            ++chunks_it;
        });

        return *this;
    }

    template <typename T>
    inline typename stream_storage<T>::basic_const_iterator stream_storage<T>::basic_const_iterator::operator --(int)
    {
        const auto it = *this;

        m_iterator_storage.template invoke<void>([](auto & chunks_it)
        {
            chunks_it--;
        });

        return it;
    }

    template <typename T>
    inline typename stream_storage<T>::basic_const_iterator & stream_storage<T>::basic_const_iterator::operator --()
    {
        m_iterator_storage.template invoke<void>([](auto & chunks_it)
        {
            --chunks_it;
        });

        return *this;
    }

    //// stream_storage

    template <typename T>
    inline stream_storage<T>::stream_storage(size_t min_chunk_size, size_t min_arr0_capacity, size_t min_arr1_capacity) :
        m_size(0), m_remainder(0)
    {
        reset(min_chunk_size, min_arr0_capacity, min_arr1_capacity);
    }

    template <typename T>
    inline stream_storage<T>::~stream_storage()
    {
    }

    template <typename T>
    inline void stream_storage<T>::reset(size_t min_chunk_size, size_t min_arr0_capacity, size_t min_arr1_capacity)
    {
        DEBUG_ASSERT_TRUE(min_chunk_size);

        const int chunk_type_index = math::int_log2_ceil(min_chunk_size);
        if (chunk_type_index >= num_chunk_variants_t::value) {
            DEBUG_BREAK_THROW(true) std::runtime_error(
                fmt::format("{:s}({:d}): minimum chunk size is not supported: min_chunk_size={:d} pof2={:d} max={:d}",
                    UTILITY_PP_FUNCSIG, UTILITY_PP_LINE, min_chunk_size,
                    math::int_pof2_ceil(min_chunk_size), (0x01U << (num_chunk_variants_t::value - 1))));
        }

        if (chunk_type_index != m_chunks.type_index()) {
            m_chunks.construct_default(chunk_type_index, true);

#if ERROR_IF_EMPTY_PP_DEF(ENABLE_INTERNAL_TACKLE_DEQUE_IN_STREAM_STORAGE)
            m_chunks.template invoke<void>([=](auto & chunks)
            {
                using storage_type_t = typename std::remove_reference<decltype(chunks)>::type;

                // available in the tackle implementation
                chunks.reset(typename storage_type_t::optional_params{ min_arr0_capacity, min_arr1_capacity });
            });
#endif
        }
        else {
#if ERROR_IF_EMPTY_PP_DEF(ENABLE_INTERNAL_TACKLE_DEQUE_IN_STREAM_STORAGE)
            m_chunks.template invoke<void>([=](auto & chunks)
            {
                using storage_type_t = typename std::remove_reference<decltype(chunks)>::type;

                this->_clear(chunks);

                // available in the tackle implementation
                chunks.reset(typename storage_type_t::optional_params{ min_arr0_capacity, min_arr1_capacity });
            });
#else
            clear();
#endif
        }
    }

    template <typename T>
    template <typename T_>
    inline void stream_storage<T>::_clear(T_ & chunks)
    {
        m_size = 0;
        m_remainder = 0;
        chunks.clear(); // at last in case if throw an exception
    }

    template <typename T>
    inline void stream_storage<T>::clear()
    {
        m_chunks.template invoke<void>([this](auto & chunks)
        {
            this->_clear(chunks);
        });
    }

    template <typename T>
    inline typename stream_storage<T>::const_iterator stream_storage<T>::begin() const
    {
        return m_chunks.template invoke<const_iterator>([this](const auto & chunks)
        {
            return const_iterator(basic_const_iterator::iterator_storage_t(m_chunks.type_index(), chunks.begin()));
        });
    }

    template <typename T>
    inline typename stream_storage<T>::const_iterator stream_storage<T>::end() const
    {
        return m_chunks.template invoke<const_iterator>([this](const auto & chunks)
        {
            return const_iterator(basic_const_iterator::iterator_storage_t(m_chunks.type_index(), chunks.end()));
        });
    }

    template <typename T>
    inline size_t stream_storage<T>::chunk_size() const
    {
        return m_chunks.template invoke<size_t>([this](const auto & chunks) // to throw exception on invalid type index
        {
            return _get_chunk_size(m_chunks.type_index());
        });
    }

    template <typename T>
    inline size_t stream_storage<T>::size() const
    {
        return m_size;
    }

    template <typename T>
    inline size_t stream_storage<T>::remainder() const
    {
        return m_remainder;
    }

    template <typename T>
    inline void stream_storage<T>::push_back(const T * buf, size_t size)
    {
        DEBUG_ASSERT_TRUE(buf && size);

        m_chunks.template invoke<void>([=](auto & chunks)
        {
            using ref_chunk_t = decltype(chunks[0]);
            using chunk_t = typename boost::remove_reference<ref_chunk_t>::type;

            const size_t chunk_size = this->_get_chunk_size(m_chunks.type_index());
            DEBUG_ASSERT_LT(m_remainder, chunk_size);

            size_t buf_offset = 0;
            size_t left_size = size;

            if_break(1) {
                if (m_remainder) {
                    auto & last_chunk = chunks.back();

                    const size_t copy_to_remainder_size = (std::min)(chunk_size - m_remainder, left_size);
                    UTILITY_COPY(buf, last_chunk.buf + m_remainder, copy_to_remainder_size);
                    left_size -= copy_to_remainder_size;
                    buf_offset += copy_to_remainder_size;
                }

                if (!left_size) break;

                const size_t num_fixed_chunks = left_size / chunk_size;
                const size_t last_fixed_chunk_remainder = left_size % chunk_size;

                for (size_t i = 0; i < num_fixed_chunks; i++) {
                    chunks.push_back(chunk_t());

                    auto & last_chunk = chunks.back();

                    UTILITY_COPY(buf + buf_offset, last_chunk.buf, chunk_size);
                    buf_offset += chunk_size;
                }

                if (last_fixed_chunk_remainder) {
                    chunks.push_back(chunk_t());

                    auto & last_chunk = chunks.back();

                    UTILITY_COPY(buf + buf_offset, last_chunk.buf, last_fixed_chunk_remainder);
                    buf_offset += last_fixed_chunk_remainder;
                }
            }

            m_size += buf_offset;
            m_remainder = (m_remainder + buf_offset) % chunk_size;
        });
    }

    template <typename T>
    inline T & stream_storage<T>::operator[](size_t offset)
    {
        DEBUG_ASSERT_LT(offset, size());

        return m_chunks.template invoke<T &>([=](auto & chunks)
        {
            const size_t chunk_size = this->_get_chunk_size(m_chunks.type_index());

            const auto chunk_devrem = UINT32_DIVREM_POF2_FLOOR_VERIFY(offset, chunk_size);
            auto & chunk = chunks[chunk_devrem.quot];

            return chunk.buf[chunk_devrem.rem];
        });
    }

    template <typename T>
    inline const T & stream_storage<T>::operator[](size_t offset) const
    {
        DEBUG_ASSERT_LT(offset, size());

        return m_chunks.template invoke<const T &>([=](const auto & chunks)
        {
            const size_t chunk_size = this->_get_chunk_size(m_chunks.type_index());

            const auto chunk_devrem = UINT32_DIVREM_POF2_FLOOR_VERIFY(offset, chunk_size);
            const auto & chunk = chunks[chunk_devrem.quot];

            return chunk.buf[chunk_devrem.rem];
        });
    }

    template <typename T> template <typename C>
    inline size_t stream_storage<T>::_copy_to_impl(const C & chunks, size_t offset_from, T * to_buf, size_t to_size) const
    {
        DEBUG_ASSERT_LT(0U, to_size);
        DEBUG_ASSERT_GE(size(), offset_from + to_size);

        const size_t chunk_size = this->_get_chunk_size(m_chunks.type_index());

        const auto chunk_divrem = UINT32_DIVREM_POF2_FLOOR_VERIFY(offset_from, chunk_size);
        const auto & chunk = chunks[chunk_divrem.quot];
        size_t to_buf_offset = 0;
        size_t from_buf_offset = chunk_divrem.rem;
        if (chunk_size >= from_buf_offset + to_size) {
            UTILITY_COPY(chunk.buf + from_buf_offset, to_buf, to_size);
            to_buf_offset += to_size;
        }
        else {
            const auto next_chunk_divrem = UINT32_DIVREM_POF2_FLOOR_VERIFY(chunk_divrem.rem + to_size, chunk_size);

            // cycles overhead optimization
            //if (256 < next_chunk_divrem.quot) {
                size_t chunks_size = chunk_size - chunk_divrem.rem;

                const auto * prev_chunk_ptr = &chunk;
                decltype(prev_chunk_ptr) next_chunk_ptr;

                if (next_chunk_divrem.quot >= 2) {
                    // collect continuous chunks block
                    for (size_t i = 1; i < next_chunk_divrem.quot; i++) {
                        next_chunk_ptr = &chunks[chunk_divrem.quot + i];
                        if (next_chunk_ptr == prev_chunk_ptr + chunks_size) {
                            chunks_size += chunk_size;
                        }
                        else {
                            // next chunk is not continuous, copy collected chunks at once
                            UTILITY_COPY(prev_chunk_ptr->buf + from_buf_offset, to_buf + to_buf_offset, chunks_size);
                            prev_chunk_ptr = next_chunk_ptr;
                            from_buf_offset = 0;
                            to_buf_offset += chunks_size;
                            chunks_size = chunk_size;
                        }
                    }
                }
                if (next_chunk_divrem.rem) {
                    next_chunk_ptr = &chunks[chunk_divrem.quot + next_chunk_divrem.quot];
                    if (next_chunk_ptr == prev_chunk_ptr + chunk_size) {
                        UTILITY_COPY(prev_chunk_ptr->buf + from_buf_offset, to_buf + to_buf_offset, chunks_size + next_chunk_divrem.rem);
                        to_buf_offset += chunks_size + next_chunk_divrem.rem;
                    }
                    else {
                        UTILITY_COPY(prev_chunk_ptr->buf + from_buf_offset, to_buf + to_buf_offset, chunks_size);
                        to_buf_offset += chunks_size;
                        UTILITY_COPY(next_chunk_ptr->buf, to_buf + to_buf_offset, next_chunk_divrem.rem);
                        to_buf_offset += next_chunk_divrem.rem;
                    }
                }
                else {
                    UTILITY_COPY(prev_chunk_ptr->buf + from_buf_offset, to_buf + to_buf_offset, chunks_size);
                    to_buf_offset += chunks_size;
                }
            //}
            //else {
            //    const size_t first_chunk_size = chunk_size - chunk_divrem.rem;
            //
            //    UTILITY_COPY(chunk.buf + from_buf_offset, to_buf + to_buf_offset, first_chunk_size);
            //    to_buf_offset += first_chunk_size;
            //
            //    if (next_chunk_divrem.quot >= 2) {
            //        for (size_t i = 1; i < next_chunk_divrem.quot; i++, to_buf_offset += chunk_size) {
            //            const auto & chunk2 = chunks[chunk_divrem.quot + i];
            //            UTILITY_COPY(chunk2.buf, to_buf + to_buf_offset, chunk_size);
            //        }
            //    }
            //    if (next_chunk_divrem.rem) {
            //        auto & chunk2 = chunks[chunk_divrem.quot + next_chunk_divrem.quot];
            //        const size_t last_chunk_size = next_chunk_divrem.rem;
            //        UTILITY_COPY(chunk2.buf, to_buf + to_buf_offset, last_chunk_size);
            //        to_buf_offset += last_chunk_size;
            //    }
            //}
        }

        return to_buf_offset;
    }

    // version with internal force inline
    template <typename T> template <typename C>
    FORCE_INLINE size_t stream_storage<T>::_copy_to_impl_innerforceinline(const C & chunks, size_t offset_from, T * to_buf, size_t to_size) const
    {
        DEBUG_ASSERT_LT(0U, to_size);
        DEBUG_ASSERT_GE(size(), offset_from + to_size);

        const size_t chunk_size = this->_get_chunk_size(m_chunks.type_index());

        const auto chunk_divrem = UINT32_DIVREM_POF2_FLOOR_VERIFY(offset_from, chunk_size);
        const auto & chunk = chunks[chunk_divrem.quot];
        size_t to_buf_offset = 0;
        size_t from_buf_offset = chunk_divrem.rem;
        if (chunk_size >= from_buf_offset + to_size) {
            UTILITY_COPY_FORCE_INLINE(chunk.buf + from_buf_offset, to_buf, to_size);
            to_buf_offset += to_size;
        }
        else {
            const auto next_chunk_divrem = UINT32_DIVREM_POF2_FLOOR_VERIFY(chunk_divrem.rem + to_size, chunk_size);

            // cycles overhead optimization
            //if (256 < next_chunk_divrem.quot) {
                size_t chunks_size = chunk_size - chunk_divrem.rem;

                const auto * prev_chunk_ptr = &chunk;
                decltype(prev_chunk_ptr) next_chunk_ptr;

                if (next_chunk_divrem.quot >= 2) {
                    // collect continuous chunks block
                    for (size_t i = 1; i < next_chunk_divrem.quot; i++) {
                        next_chunk_ptr = &chunks[chunk_divrem.quot + i];
                        if (next_chunk_ptr == prev_chunk_ptr + chunks_size) {
                            chunks_size += chunk_size;
                        }
                        else {
                            // next chunk is not continuous, copy collected chunks at once
                            UTILITY_COPY_FORCE_INLINE(prev_chunk_ptr->buf + from_buf_offset, to_buf + to_buf_offset, chunks_size);
                            prev_chunk_ptr = next_chunk_ptr;
                            from_buf_offset = 0;
                            to_buf_offset += chunks_size;
                            chunks_size = chunk_size;
                        }
                    }
                }
                if (next_chunk_divrem.rem) {
                    next_chunk_ptr = &chunks[chunk_divrem.quot + next_chunk_divrem.quot];
                    if (next_chunk_ptr == prev_chunk_ptr + chunk_size) {
                        UTILITY_COPY_FORCE_INLINE(prev_chunk_ptr->buf + from_buf_offset, to_buf + to_buf_offset, chunks_size + next_chunk_divrem.rem);
                        to_buf_offset += chunks_size + next_chunk_divrem.rem;
                    }
                    else {
                        UTILITY_COPY_FORCE_INLINE(prev_chunk_ptr->buf + from_buf_offset, to_buf + to_buf_offset, chunks_size);
                        to_buf_offset += chunks_size;
                        UTILITY_COPY_FORCE_INLINE(next_chunk_ptr->buf, to_buf + to_buf_offset, next_chunk_divrem.rem);
                        to_buf_offset += next_chunk_divrem.rem;
                    }
                }
                else {
                    UTILITY_COPY_FORCE_INLINE(prev_chunk_ptr->buf + from_buf_offset, to_buf + to_buf_offset, chunks_size);
                    to_buf_offset += chunks_size;
                }
            //}
            //else {
            //    const size_t first_chunk_size = chunk_size - chunk_divrem.rem;
            //
            //    UTILITY_COPY_FORCE_INLINE(chunk.buf + from_buf_offset, to_buf + to_buf_offset, first_chunk_size);
            //    to_buf_offset += first_chunk_size;
            //
            //    if (next_chunk_divrem.quot >= 2) {
            //        for (size_t i = 1; i < next_chunk_divrem.quot; i++, to_buf_offset += chunk_size) {
            //            const auto & chunk2 = chunks[chunk_divrem.quot + i];
            //            UTILITY_COPY_FORCE_INLINE(chunk2.buf, to_buf + to_buf_offset, chunk_size);
            //        }
            //    }
            //    if (next_chunk_divrem.rem) {
            //        auto & chunk2 = chunks[chunk_divrem.quot + next_chunk_divrem.quot];
            //        const size_t last_chunk_size = next_chunk_divrem.rem;
            //        UTILITY_COPY_FORCE_INLINE(chunk2.buf, to_buf + to_buf_offset, last_chunk_size);
            //        to_buf_offset += last_chunk_size;
            //    }
            //}
        }

        return to_buf_offset;
    }

//    template <typename C>
//    inline size_t _inner_stride_copy_to_impl(const C & chunks, size_t offset_from, size_t from_size, size_t stride_size, size_t stride_step, T * to_buf, size_t to_size) const
//    {
//        DEBUG_ASSERT_TRUE(stride_size && stride_step && from_size && to_size);
//        DEBUG_ASSERT_GE(stride_step, stride_size);
//
//        const size_t chunk_size = this->_get_chunk_size(m_chunks.type_index());
//
//        const auto chunk_divrem = UINT32_DIVREM_POF2_FLOOR_VERIFY(offset_from, chunk_size);
//        const auto & chunk = chunks[chunk_divrem.quot];
//        size_t to_buf_offset = 0;
//        size_t from_buf_offset = chunk_divrem.rem;
//
//        if (chunk_size >= from_buf_offset + from_size) {
//            UTILITY_STRIDE_COPY(to_buf_offset, chunk.buf + from_buf_offset, from_size, stride_size, stride_step, to_buf, to_size);
//        }
//        else {
//            const auto next_chunk_divrem = UINT32_DIVREM_POF2_FLOOR_VERIFY(chunk_divrem.rem + from_size, chunk_size);
//
//            // TODO:
//            //  * UTILITY_STRIDE_COPY from the middle of slot byte instead of only from slot beginning byte
//
//            // cycles overhead optimization
//            //if (256 < next_chunk_divrem.quot) {
//                size_t chunks_size = chunk_size - chunk_divrem.rem;
//
//                const auto * prev_chunk_ptr = &chunk;
//                decltype(prev_chunk_ptr) next_chunk_ptr;
//
//                if (next_chunk_divrem.quot >= 2) {
//                    // collect continuous chunks block
//                    for (size_t i = 1; i < next_chunk_divrem.quot; i++) {
//                        next_chunk_ptr = &chunks[chunk_divrem.quot + i];
//                        if (next_chunk_ptr == prev_chunk_ptr + chunks_size) {
//                            chunks_size += chunk_size;
//                        }
//                        else {
//                            // next chunk is not continuous, copy collected chunks at once
//                            UTILITY_COPY_FORCE_INLINE(prev_chunk_ptr->buf + from_buf_offset, to_buf + to_buf_offset, chunks_size);
//                            prev_chunk_ptr = next_chunk_ptr;
//                            from_buf_offset = 0;
//                            to_buf_offset += chunks_size;
//                            chunks_size = chunk_size;
//                        }
//                    }
//                }
//                if (next_chunk_divrem.rem) {
//                    next_chunk_ptr = &chunks[chunk_divrem.quot + next_chunk_divrem.quot];
//                    if (next_chunk_ptr == prev_chunk_ptr + chunk_size) {
//                        UTILITY_COPY_FORCE_INLINE(prev_chunk_ptr->buf + from_buf_offset, to_buf + to_buf_offset, chunks_size + next_chunk_divrem.rem);
//                        to_buf_offset += chunks_size + next_chunk_divrem.rem;
//                    }
//                    else {
//                        UTILITY_COPY_FORCE_INLINE(prev_chunk_ptr->buf + from_buf_offset, to_buf + to_buf_offset, chunks_size);
//                        to_buf_offset += chunks_size;
//                        UTILITY_COPY_FORCE_INLINE(next_chunk_ptr->buf, to_buf + to_buf_offset, next_chunk_divrem.rem);
//                        to_buf_offset += next_chunk_divrem.rem;
//                    }
//                }
//                else {
//                    UTILITY_COPY_FORCE_INLINE(prev_chunk_ptr->buf + from_buf_offset, to_buf + to_buf_offset, chunks_size);
//                    to_buf_offset += chunks_size;
//                }
//            //}
//            //else {
//            //    const size_t first_chunk_size = chunk_size - chunk_divrem.rem;
//            //
//            //    UTILITY_COPY_FORCE_INLINE(chunk.buf + from_buf_offset, to_buf + to_buf_offset, first_chunk_size);
//            //    to_buf_offset += first_chunk_size;
//            //
//            //    if (next_chunk_divrem.quot >= 2) {
//            //        for (size_t i = 1; i < next_chunk_divrem.quot; i++, to_buf_offset += chunk_size) {
//            //            const auto & chunk2 = chunks[chunk_divrem.quot + i];
//            //            UTILITY_COPY_FORCE_INLINE(chunk2.buf, to_buf + to_buf_offset, chunk_size);
//            //        }
//            //    }
//            //    if (next_chunk_divrem.rem) {
//            //        auto & chunk2 = chunks[chunk_divrem.quot + next_chunk_divrem.quot];
//            //        const size_t last_chunk_size = next_chunk_divrem.rem;
//            //        UTILITY_COPY_FORCE_INLINE(chunk2.buf, to_buf + to_buf_offset, last_chunk_size);
//            //        to_buf_offset += last_chunk_size;
//            //    }
//            //}
//        }
//
//        return to_buf_offset;
//    }

    template <typename T> template <bool InnerForceInline>
    FORCE_INLINE size_t stream_storage<T>::_stride_copy_to_impl_innerforceinline(size_t offset_from, size_t in_row_offset_from, size_t stream_width,
        size_t slot_begin_in_row_offset, size_t slot_end_in_row_offset, T * to_buf, size_t max_slot_size,
        size_t * in_stream_slot_offset_ptr, size_t * in_slot_byte_offset_ptr, size_t * end_stride_byte_offset_ptr) const
    {
        DEBUG_ASSERT_TRUE(to_buf && max_slot_size);
        DEBUG_ASSERT_LT(in_row_offset_from, stream_width);
        DEBUG_ASSERT_GE(stream_width, slot_end_in_row_offset);
        DEBUG_ASSERT_LT(slot_begin_in_row_offset, slot_end_in_row_offset);
        DEBUG_ASSERT_LT(offset_from, size());

        const size_t slot_size = m_chunks.template invoke<size_t>([=](const auto & chunks)
        {
            const size_t slot_width = slot_end_in_row_offset - slot_begin_in_row_offset;

            size_t in_row_offset_last = in_row_offset_from;

            size_t iterated_stream_size = 0;
            size_t slot_size = 0;

            size_t stream_size_left = m_size - offset_from;
            size_t slot_size_left = max_slot_size;

            if (in_stream_slot_offset_ptr) {
                *in_stream_slot_offset_ptr = 0;
            }
            if (in_slot_byte_offset_ptr) {
                *in_slot_byte_offset_ptr = 0;
            }

            BOOST_SCOPE_EXIT(&offset_from, &iterated_stream_size, &end_stride_byte_offset_ptr) {
                if (end_stride_byte_offset_ptr) {
                    *end_stride_byte_offset_ptr = iterated_stream_size;
                }
            } BOOST_SCOPE_EXIT_END

            if (in_row_offset_from < slot_begin_in_row_offset) goto _first_row_left_segment;
            else if (in_row_offset_from < slot_end_in_row_offset) goto _first_row_slot_segment;
            else goto _first_row_right_segment;

            _first_row_left_segment:;
            {
                const size_t iterate_size = (std::min)(slot_begin_in_row_offset - in_row_offset_last, stream_size_left);

                iterated_stream_size += iterate_size;
                DEBUG_ASSERT_GE(stream_size_left, iterate_size);
                stream_size_left -= iterate_size;

                if (!stream_size_left) {
                    if (in_stream_slot_offset_ptr) {
                        *in_stream_slot_offset_ptr = iterated_stream_size;
                    }

                    return slot_size;
                }

                in_row_offset_last = slot_begin_in_row_offset;
            }

            _first_row_slot_segment:;
            {
                if (in_stream_slot_offset_ptr) {
                    *in_stream_slot_offset_ptr = iterated_stream_size;
                }

                const size_t first_slot_row_bytes = slot_end_in_row_offset - in_row_offset_last;

                const size_t slot_size_to_copy = (std::min)((std::min)(first_slot_row_bytes, slot_size_left), stream_size_left);
                DEBUG_ASSERT_LT(0U, slot_size_to_copy);

                const size_t copied_size = detail::_inline_dispatch<InnerForceInline>::
                    _copy_to_impl(*this, chunks, offset_from + iterated_stream_size, to_buf + slot_size, slot_size_to_copy);
                DEBUG_ASSERT_EQ(copied_size, slot_size_to_copy);

                slot_size += copied_size;
                iterated_stream_size += slot_size_to_copy;

                DEBUG_ASSERT_GE(slot_size_left, slot_size_to_copy);
                slot_size_left -= slot_size_to_copy;
                DEBUG_ASSERT_GE(stream_size_left, slot_size_to_copy);
                stream_size_left -= slot_size_to_copy;

                if (in_slot_byte_offset_ptr) {
                    DEBUG_ASSERT_GE(in_row_offset_last, slot_begin_in_row_offset);
                    *in_slot_byte_offset_ptr = in_row_offset_last - slot_begin_in_row_offset;
                }

                if (!slot_size_left || !stream_size_left) return slot_size;

                in_row_offset_last = slot_end_in_row_offset;
            }

            _first_row_right_segment:;
            {
                const size_t iterate_size = (std::min)(stream_width - in_row_offset_last, stream_size_left);

                iterated_stream_size += iterate_size;
                DEBUG_ASSERT_GE(stream_size_left, iterate_size);
                stream_size_left -= iterate_size;

                if (!stream_size_left) {
                    if (!slot_size && in_stream_slot_offset_ptr) {
                        *in_stream_slot_offset_ptr = iterated_stream_size;
                    }

                    return slot_size;
                }

                if (!slot_size && in_stream_slot_offset_ptr) {
                    *in_stream_slot_offset_ptr = iterated_stream_size + (std::min)(slot_begin_in_row_offset, stream_size_left);
                }
            }

            const size_t num_whole_slot_rows = slot_size_left / slot_width;
            const size_t num_whole_stream_rows = stream_size_left / stream_width;

            const size_t num_whole_rows = (std::min)(num_whole_slot_rows, num_whole_stream_rows);
            for (size_t i = 0; i < num_whole_rows; i++) {
                const size_t copied_size = detail::_inline_dispatch<InnerForceInline>::
                    _copy_to_impl(*this, chunks, offset_from + iterated_stream_size + slot_begin_in_row_offset, to_buf + slot_size, slot_width);
                DEBUG_ASSERT_EQ(copied_size, slot_width);

                slot_size += copied_size;
                iterated_stream_size += stream_width;
            }

            const size_t iterate_size = num_whole_rows * stream_width;

            DEBUG_ASSERT_GE(slot_size_left, num_whole_rows * slot_width);
            slot_size_left -= num_whole_rows * slot_width;
            DEBUG_ASSERT_GE(stream_size_left, iterate_size);
            stream_size_left -= iterate_size;

            if (!slot_size_left || !stream_size_left) return slot_size;

            //_last_row_left_segment:;
            {
                const size_t iterate_size = (std::min)(slot_begin_in_row_offset, stream_size_left);

                iterated_stream_size += iterate_size;
                DEBUG_ASSERT_GE(stream_size_left, iterate_size);
                stream_size_left -= iterate_size;

                if (!stream_size_left) return slot_size;
            }

            //_last_row_slot_segment:;
            {
                const size_t slot_size_to_copy = (std::min)((std::min)(slot_width, slot_size_left), stream_size_left);
                DEBUG_ASSERT_LT(0U, slot_size_to_copy);

                const size_t copied_size = detail::_inline_dispatch<InnerForceInline>::
                    _copy_to_impl(*this, chunks, offset_from + iterated_stream_size, to_buf + slot_size, slot_size_to_copy);
                DEBUG_ASSERT_EQ(copied_size, slot_size_to_copy);

                slot_size += copied_size;
                iterated_stream_size += slot_size_to_copy;

                DEBUG_ASSERT_GE(slot_size_left, slot_size_to_copy);
                slot_size_left -= slot_size_to_copy;
                DEBUG_ASSERT_GE(stream_size_left, slot_size_to_copy);
                stream_size_left -= slot_size_to_copy;

                if (!slot_size_left) {
                    // if last slot size to copy was slot width, then iterate offset either to the end of the stream row or to the end of the stream
                    if (slot_size_to_copy == slot_width && stream_size_left && end_stride_byte_offset_ptr) { // has meaning only for `end_stride_byte_offset`
                        const size_t iterate_size = (std::min)(stream_width - slot_end_in_row_offset, stream_size_left);

                        iterated_stream_size += iterate_size;
                        DEBUG_ASSERT_GE(stream_size_left, iterate_size); // just in case
                    }

                    return slot_size;
                }
            }

            //_last_row_right_segment:;
            {
                const size_t iterate_size = (std::min)(stream_width - slot_end_in_row_offset, stream_size_left);

                iterated_stream_size += iterate_size;
                DEBUG_ASSERT_GE(stream_size_left, iterate_size);
                stream_size_left -= iterate_size;

                // end of stream
                DEBUG_ASSERT_FALSE(stream_size_left);
            }

            return slot_size;
        });

#if DEBUG_ASSERT_VERIFY_ENABLED
        if (in_stream_slot_offset_ptr && in_slot_byte_offset_ptr) {
            DEBUG_ASSERT_TRUE(!*in_stream_slot_offset_ptr && !*in_slot_byte_offset_ptr || (*in_stream_slot_offset_ptr ^ *in_slot_byte_offset_ptr)); // only one must be not zero at a time!
        }
#endif

        return slot_size;
    }

    template <typename T> template <int InnerInlineLevel>
    inline size_t stream_storage<T>::copy_to(size_t offset_from, T * to_buf, size_t to_size) const
    {
        return m_chunks.template invoke<size_t>([=](const auto & chunks)
        {
            return detail::_inline_dispatch<InnerInlineLevel ? true : false>::_copy_to_impl(*this, chunks, offset_from, to_buf, to_size);
        });
    }

    template <typename T> template <int InnerInlineLevel>
    inline size_t stream_storage<T>::stride_copy_to(size_t offset_from, size_t in_row_offset_from, size_t stream_width,
        size_t slot_begin_in_row_offset, size_t slot_end_in_row_offset, T * to_buf, size_t max_slot_size,
        size_t * in_stream_slot_offset_ptr, size_t * in_slot_byte_offset_ptr, size_t * end_stride_byte_offset_ptr) const
    {
        if (slot_begin_in_row_offset != 0 || slot_end_in_row_offset != stream_width) {
            return _stride_copy_to_impl_innerforceinline<InnerInlineLevel ? true : false>(
                offset_from, in_row_offset_from, stream_width, slot_begin_in_row_offset, slot_end_in_row_offset,
                to_buf, max_slot_size, in_stream_slot_offset_ptr, in_slot_byte_offset_ptr, end_stride_byte_offset_ptr);
        }

        DEBUG_ASSERT_GE(m_size, offset_from);
        const uint32_t max_size_to_process = (std::min)(max_slot_size, m_size - offset_from);
        return copy_to(offset_from, to_buf, max_size_to_process);
    }

    template <typename T> template <int InnerInlineLevel>
    FORCE_INLINE size_t stream_storage<T>::stride_copy_to_forceinline(size_t offset_from, size_t in_row_offset_from, size_t stream_width,
        size_t slot_begin_in_row_offset, size_t slot_end_in_row_offset, T * to_buf, size_t max_slot_size,
        size_t * in_stream_slot_offset_ptr, size_t * in_slot_byte_offset_ptr, size_t * end_stride_byte_offset_ptr) const
    {
        if (slot_begin_in_row_offset != 0 || slot_end_in_row_offset != stream_width) {
            return _stride_copy_to_impl_innerforceinline<InnerInlineLevel ? true : false>(
                offset_from, in_row_offset_from, stream_width, slot_begin_in_row_offset, slot_end_in_row_offset,
                to_buf, max_slot_size, in_stream_slot_offset_ptr, in_slot_byte_offset_ptr, end_stride_byte_offset_ptr);
        }

        DEBUG_ASSERT_GE(m_size, offset_from);
        const uint32_t max_size_to_process = (std::min)(max_slot_size, m_size - offset_from);
        return copy_to(offset_from, to_buf, max_size_to_process);
    }

    template <typename T>
    inline size_t stream_storage<T>::erase_front(size_t size)
    {
        DEBUG_ASSERT_GE(m_size, size);

        return m_chunks.template invoke<size_t>([=](auto & chunks)
        {
            const size_t chunk_size = this->_get_chunk_size(m_chunks.type_index());

            size_t erased_size;

            if (size < m_size) {
                size_t chunk_index = 0;
                const size_t num_chunks = size / chunk_size;
                for (; chunk_index < num_chunks; chunk_index++) {
                    chunks.pop_front();
                }

                erased_size = chunk_index * chunk_size;

                DEBUG_ASSERT_GE(m_size, erased_size);
                m_size -= erased_size;
            }
            else {
                erased_size = m_size;

                this->clear();
            }

            return erased_size;
        });
    }
}
