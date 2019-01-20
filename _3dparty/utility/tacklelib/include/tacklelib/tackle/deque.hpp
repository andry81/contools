#pragma once

// DO NOT REMOVE, exists to avoid private/public headers mixing!
#ifndef TACKLE_DEQUE_HPP
#define TACKLE_DEQUE_HPP

#include <tacklelib/utility/platform.hpp>
#include <tacklelib/utility/static_assert.hpp>
#include <tacklelib/utility/assert.hpp>
#include <tacklelib/utility/math.hpp>

#include <tacklelib/tackle/compressed_pair.hpp>

#include <memory>
#include <cstdio>
#include <cstdint>
#include <cstring>
#include <stdexcept>
#include <type_traits>
#include <limits>
#include <functional>
#include <algorithm>


namespace tackle
{
    struct deque_params
    {
        using size_type0                                            = std::size_t;
        using size_type1                                            = uint32_t;     // nested size is limited

        static const size_type0 size0_max                           = (std::numeric_limits<size_type0>::max)();
        static const size_type1 size1_max                           = (std::numeric_limits<size_type1>::max)();

        static const size_type0 default_min_arr0_capacity           = 16;
        static const size_type1 default_min_arr1_capacity_bytes     = 256 * 1024;
        static const size_type0 default_grow_by_numerator           = 384;  // 1.5 grow factor
        static const size_type0 default_grow_by_denominator         = 256;
        static const size_type0 default_relocate_if_arr0_size_greater_numerator     = 256; // relocate if a size is greater than 66.6% of a capacity, otherwise grow
        static const size_type0 default_relocate_if_arr0_size_greater_denominator   = 384;

        STATIC_ASSERT_GT(default_grow_by_numerator, default_grow_by_denominator,
            "numerator must be greater than the denominator");
        STATIC_ASSERT_LT(default_relocate_if_arr0_size_greater_numerator, default_relocate_if_arr0_size_greater_denominator,
            "numerator must be less than the denominator");

        FORCE_INLINE deque_params()
        {
            reset(default_min_arr0_capacity, default_min_arr1_capacity_bytes);
        }

        FORCE_INLINE deque_params(const deque_params & params)
        {
            reset(params);
        }

        FORCE_INLINE deque_params(size_type0 min_arr0_capacity_, size_type1 min_arr1_capacity_bytes_)
        {
            reset(min_arr0_capacity_, min_arr1_capacity_bytes_);
        }

        FORCE_INLINE void reset(const deque_params & params)
        {
            return reset(params.min_arr0_capacity, params.min_arr1_capacity_bytes);
        }

        FORCE_INLINE void reset(size_type0 min_arr0_capacity_, size_type1 min_arr1_capacity_bytes_)
        {
            DEBUG_ASSERT_TRUE(min_arr0_capacity_);
            DEBUG_ASSERT_TRUE(min_arr1_capacity_bytes_);
            min_arr0_capacity = (std::max)(min_arr0_capacity_, size_type0(1)); // just in case
            // TODO:
            //  Find the reason why `std:::max` slow downs the `TackleDequeTest.thislib_deque_push_back_time` and
            //  `TackleDequeTest.thislib_deque_push_front_time` tests in the `unit_tests` in the Release around this line under the Linux
            //
            min_arr1_capacity_bytes = (std::max)(min_arr1_capacity_bytes_, size_type1(1)); // just in case
        }

        // sometimes the msvc compiler shows the wrong usage place of a deleted function, old style with a `private` section works better
    private:
        deque_params & operator=(const deque_params &) = delete;

    public:
        size_type0 min_arr0_capacity;       // minimal capacity for level0 array
        size_type1 min_arr1_capacity_bytes; // minimal capacity for level1 arrays in bytes (will be rounded up)
    };

    template <typename T>
    class deque_base;

    template <typename T,
        typename Allocator0 = typename deque_base<T>::default_allocator_type0,
        typename Allocator1 = typename deque_base<T>::default_allocator_type1>
    class deque;

    template <typename T>
    class deque_base
    {
    public:
        using value_type                = T;

        using size_type0                = deque_params::size_type0;
        using size_type1                = deque_params::size_type1;

        using difference_type           = std::ptrdiff_t;

        using reference                 = value_type &;
        using const_reference           = const value_type &;

        using arr1_item                 = value_type;

        // CAUTION: must be a POD type for the sake of the memmove!
        //
        struct arr0_item
        {
            FORCE_INLINE void reset(arr1_item * arr1_ptr_, uint32_t begin_index_, uint32_t end_index_)
            {
                arr1_ptr    = arr1_ptr_;
                begin_index = begin_index_;
                end_index   = end_index_;
            }

            arr1_item * arr1_ptr;
            uint32_t    begin_index;
            uint32_t    end_index;      // excluding the last
        };

        using default_allocator_type0   = std::allocator<arr0_item>;
        using default_allocator_type1   = std::allocator<arr1_item>;

        using arr0_unique_ptr           = std::unique_ptr<arr0_item[], std::function<void(arr0_item *)> >;
        using arr1_unique_ptr           = std::unique_ptr<arr1_item[], std::function<void(arr1_item *)> >;

     protected:
        template <typename container_type, typename T0, typename T1>
        class t_iterator_base
        {
        public:
            using uncval_container_type = typename std::remove_cv<container_type>::type;
            using uncval_type0          = typename std::remove_cv<T0>::type;
            using uncval_type1          = typename std::remove_cv<T1>::type;

            FORCE_INLINE t_iterator_base() :
                container_ptr(nullptr),
                arr0_item_ptr(nullptr),
                arr0_item_index(deque_params::size0_max),
                arr1_item_ptr(nullptr),
                arr1_item_index(deque_params::size1_max)
            {
            }

            FORCE_INLINE t_iterator_base(uncval_container_type * container_ptr_,
                uncval_type0 * arr0_item_ptr_, size_type0 arr0_item_index_, uncval_type1 * arr1_item_ptr_, size_type1 arr1_item_index_) :
                container_ptr(container_ptr_),
                arr0_item_ptr(arr0_item_ptr_),
                arr0_item_index(arr0_item_index_),
                arr1_item_ptr(arr1_item_ptr_),
                arr1_item_index(arr1_item_index_)
            {
            }

            FORCE_INLINE t_iterator_base(const uncval_container_type * container_ptr_,
                const uncval_type0 * arr0_item_ptr_, size_type0 arr0_item_index_, const uncval_type1 * arr1_item_ptr_, size_type1 arr1_item_index_) :
                container_ptr(container_ptr_),
                arr0_item_ptr(arr0_item_ptr_),
                arr0_item_index(arr0_item_index_),
                arr1_item_ptr(arr1_item_ptr_),
                arr1_item_index(arr1_item_index_)
            {
            }

            FORCE_INLINE t_iterator_base(const t_iterator_base<uncval_container_type, uncval_type0, uncval_type1> & it_base) :
                container_ptr(it_base.container_ptr),
                arr0_item_ptr(it_base.arr0_item_ptr),
                arr0_item_index(it_base.arr0_item_index),
                arr1_item_ptr(it_base.arr1_item_ptr),
                arr1_item_index(it_base.arr1_item_index)
            {
            }

            FORCE_INLINE t_iterator_base(const t_iterator_base<const uncval_container_type, const uncval_type0, const uncval_type1> & it_base) :
                container_ptr(const_cast<uncval_container_type *>(it_base.container_ptr)),
                arr0_item_ptr(const_cast<uncval_type0 *>(it_base.arr0_item_ptr)),
                arr0_item_index(it_base.arr0_item_index),
                arr1_item_ptr(const_cast<uncval_type1 *>(it_base.arr1_item_ptr)),
                arr1_item_index(it_base.arr1_item_index)
            {
            }

            FORCE_INLINE T1 & operator *() const;
            FORCE_INLINE T1 * operator ->() const;

            FORCE_INLINE bool operator ==(const t_iterator_base & r) const;
            FORCE_INLINE bool operator !=(const t_iterator_base & r) const;

            FORCE_INLINE t_iterator_base & operator ++();
            FORCE_INLINE t_iterator_base & operator --();

            FORCE_INLINE t_iterator_base operator ++(int);
            FORCE_INLINE t_iterator_base operator --(int);

            T1 *                arr1_item_ptr;
            size_type1          arr1_item_index;
            T0 *                arr0_item_ptr;
            size_type0          arr0_item_index;
            container_type *    container_ptr;
        };

        template<typename T_, typename Allocator, typename... Args>
        FORCE_INLINE static void construct_items(Allocator alloc, T_ * ptr, size_type0 head_index, size_type0 count, Args... args)
        {
            DEBUG_ASSERT_TRUE(ptr);
            DEBUG_ASSERT_TRUE(count);
            if (!UTILITY_CONST_EXPR(std::is_trivially_copyable<T_>::value)) {
                for (std::size_t i = 0; i < count; ++i) {
                    alloc.construct(&ptr[head_index + i], std::forward<Args>(args)...);
                }
            }
        }

        template<typename T_, typename Allocator, typename... Args>
        FORCE_INLINE static T_ * allocate_construct_items(Allocator alloc, size_type0 capacity, size_type0 head_index, size_type0 count, Args... args)
        {
            T_ * ptr = alloc.allocate(capacity);

            construct_items(alloc, ptr, head_index, count, std::forward<Args>(args)...);

            return ptr;
        }

        template<typename T_, typename Allocator>
        FORCE_INLINE static void deallocate_items(Allocator alloc, T_ * allocated_ptr, size_type0 capacity)
        {
            alloc.deallocate(allocated_ptr, capacity);
        }

        template<typename T_, typename Allocator, typename... Args>
        FORCE_INLINE static void destruct_items(Allocator alloc, T_ * ptr, size_type0 count)
        {
            if (!UTILITY_CONST_EXPR(std::is_trivially_copyable<T_>::value)) {
                std::size_t i = DEBUG_VERIFY_TRUE(count);
                do {
                    --i;
                    alloc.destroy(&ptr[i]);
                } while(i > 0);
            }
        }

        template<typename T_, typename Allocator, typename... Args>
        FORCE_INLINE static std::unique_ptr<T_[], std::function<void(T_ *)> >
            make_items_uptr(Allocator alloc, T_ * allocated_ptr, size_type0 capacity, size_type0 head_index, size_type0 count)
        {
            static const auto & deleter = [](T_ * ptr, Allocator alloc, size_type0 capacity, size_type0 head_index, size_type0 count)
            {
                DEBUG_ASSERT_TRUE(ptr);
                DEBUG_ASSERT_TRUE(capacity);
                DEBUG_ASSERT_TRUE(count);

                const size_type0 end_index = head_index + DEBUG_VERIFY_GT(count, 0U);

                auto * item_ptr = ptr + end_index;
                size_type0 item_index = end_index;

                do {
                    --item_index;
                    --item_ptr;

                    destruct_items(alloc, item_ptr, 1);
                } while (item_index > head_index);

                deallocate_items(alloc, ptr, capacity);
            };

            return{
                DEBUG_VERIFY_TRUE(allocated_ptr),
                std::bind(deleter, std::placeholders::_1, alloc, DEBUG_VERIFY_TRUE(capacity), head_index, DEBUG_VERIFY_TRUE(count))
            };
        }

        FORCE_INLINE size_type1 get_arr1_capacity(size_type1 min_arr1_capacity_bytes)
        {
            // round up to the closest greater or equal power of 2 value
            return math::int_pof2_ceil((min_arr1_capacity_bytes + sizeof(arr1_item) - 1) / sizeof(arr1_item));
        }
    };

    template <typename T, typename Allocator0, typename Allocator1>
    class deque : public deque_base<T>
    {
        template <typename C_, typename T0_, typename T1_>
        friend class deque_base<T>::t_iterator_base;

    public:
        using base_type                 = deque_base<T>;

        using value_type                = typename base_type::value_type;

        using size_type0                = typename base_type::size_type0;
        using size_type1                = typename base_type::size_type1;

        using difference_type           = typename base_type::difference_type;

        using reference                 = value_type &;
        using const_reference           = const value_type &;

        class iterator;
        class const_iterator;

        using reverse_iterator          = std::reverse_iterator<iterator>;
        using const_reverse_iterator    = std::reverse_iterator<const_iterator>;

        using arr0_item                 = typename base_type::arr0_item;
        using arr1_item                 = typename base_type::arr1_item;

        using allocator_type0           = Allocator0;
        using allocator_type1           = Allocator1;

        using allocator_tuple           = std::tuple<allocator_type0, allocator_type1>;

        using pointer                   = typename std::allocator_traits<allocator_type1>::pointer;
        using const_pointer             = typename std::allocator_traits<allocator_type1>::const_pointer;

        using arr0_unique_ptr           = typename base_type::arr0_unique_ptr;
        using arr1_unique_ptr           = typename base_type::arr1_unique_ptr;

        using optional_params           = deque_params;

    protected:
        struct This
        {
            FORCE_INLINE This() :
                arr0_ptr(nullptr), arr0_capacity(0), size(0), begin_index(0), end_index(0),
                arr1_head_ptr(nullptr), arr1_tail_ptr(nullptr), arr1_capacity(0), head_arr1_size(0)
            {
            }

            FORCE_INLINE This(const deque_params & params_) :
                arr0_ptr(nullptr), arr0_capacity(0), size(0), begin_index(0), end_index(0),
                arr1_head_ptr(nullptr), arr1_tail_ptr(nullptr), arr1_capacity(0), head_arr1_size(0),
                params(params_)
            {
            }

            FORCE_INLINE void _validate_not_empty() const
            {
                IF_DEBUG_ASSERT_VERIFY_ENABLED(1) {
                    DEBUG_ASSERT_TRUE(arr0_ptr);
                    DEBUG_ASSERT_TRUE(arr0_capacity);
                    DEBUG_ASSERT_TRUE(size);
                    DEBUG_ASSERT_TRUE(end_index);
                    DEBUG_ASSERT_LT(begin_index, end_index);
                    DEBUG_ASSERT_TRUE(arr1_head_ptr);
                    DEBUG_ASSERT_TRUE(arr1_tail_ptr);
                    DEBUG_ASSERT_TRUE(arr1_capacity);
                    DEBUG_ASSERT_TRUE(head_arr1_size);
                    DEBUG_ASSERT_GE(arr1_capacity, head_arr1_size);
                    DEBUG_ASSERT_GE(arr0_capacity, end_index - begin_index);

                    auto & arr0_head_item = arr0_ptr[begin_index];

                    DEBUG_ASSERT_EQ(arr1_head_ptr, arr0_head_item.arr1_ptr);

                    DEBUG_ASSERT_TRUE(arr0_head_item.arr1_ptr);
                    DEBUG_ASSERT_LT(arr0_head_item.begin_index, arr0_head_item.end_index);
                    DEBUG_ASSERT_GE(arr1_capacity, arr0_head_item.end_index - arr0_head_item.begin_index);

                    if (begin_index != end_index - 1) {
                        auto & arr0_tail_item = arr0_ptr[end_index - 1];

                        DEBUG_ASSERT_EQ(arr1_tail_ptr, arr0_tail_item.arr1_ptr);

                        DEBUG_ASSERT_TRUE(arr0_tail_item.arr1_ptr);
                        DEBUG_ASSERT_LT(arr0_tail_item.begin_index, arr0_tail_item.end_index);
                        DEBUG_ASSERT_GE(arr1_capacity, arr0_tail_item.end_index - arr0_tail_item.begin_index);

                        DEBUG_ASSERT_NE(arr1_head_ptr, arr1_tail_ptr);
                    }
                    else {
                        DEBUG_ASSERT_EQ(arr1_head_ptr, arr1_tail_ptr);
                    }
                }
            }

            FORCE_INLINE void _validate_empty() const
            {
                IF_DEBUG_ASSERT_VERIFY_ENABLED(1) {
                    DEBUG_ASSERT_FALSE(size);
                    DEBUG_ASSERT_EQ(begin_index, end_index);
                    DEBUG_ASSERT_FALSE(arr1_head_ptr);
                    DEBUG_ASSERT_FALSE(arr1_tail_ptr);
                    DEBUG_ASSERT_LE(end_index, arr0_capacity);
                    DEBUG_ASSERT_FALSE(head_arr1_size);
                }
            }

            arr0_item *     arr0_ptr;
            size_type0      arr0_capacity;
            size_type0      size;           // overall size
            size_type0      begin_index;
            size_type0      end_index;      // excluding the last
            arr1_item *     arr1_head_ptr;
            arr1_item *     arr1_tail_ptr;
            size_type1      arr1_capacity;  // power-of-2 capacity
            size_type1      head_arr1_size; // duplication for fast access
            deque_params    params;
        };

    public:
        using iterator_base         = typename base_type::TEMPLATE_SCOPE t_iterator_base<deque, arr0_item, arr1_item>;
        using const_iterator_base   = typename base_type::TEMPLATE_SCOPE t_iterator_base<const deque, const arr0_item, const arr1_item>;

        class iterator : public iterator_base
        {
            friend class deque;

            FORCE_INLINE iterator(const iterator_base & it);
            FORCE_INLINE iterator(const const_iterator & it);

        public:
            FORCE_INLINE iterator();
            FORCE_INLINE iterator(const iterator & r) = default;
        };

        class const_iterator : public const_iterator_base
        {
            friend class deque;

            FORCE_INLINE const_iterator(const const_iterator_base & it);

        public:
            FORCE_INLINE const_iterator();
            FORCE_INLINE const_iterator(const const_iterator & r) = default;
        };

    public:
        FORCE_INLINE explicit deque(const deque_params & params = deque_params());
        FORCE_INLINE explicit deque(const deque_params & params, const allocator_tuple & alloc_tuple);
        //FORCE_INLINE explicit deque(size_type0 count, const T & value = T(), const deque_params & params = deque_params(), const Allocator & alloc = Allocator());
        //FORCE_INLINE explicit deque(size_type0 count, const deque_params & params = deque_params(), const Allocator & alloc = Allocator());
        //template <typename InputIt>
        //FORCE_INLINE deque(InputIt first, InputIt last, const deque_params & params = deque_params(), const Allocator & alloc = Allocator());

        FORCE_INLINE ~deque();

   protected:
       FORCE_INLINE arr0_item * _reallocate_arr0_increase(size_type0 capacity, bool relocate_to_greater_address);
       FORCE_INLINE bool _relocate_arr0_items_to_center(size_type0 relocate_size, bool relocate_to_greater_address);

   public:
       FORCE_INLINE void reset(const deque_params & params = deque_params(), bool relocate_to_greater_address = false) noexcept;
        //FORCE_INLINE void reset(const deque_params & params, bool relocate_to_greater_address, const Allocator & alloc);
        //FORCE_INLINE void reset(size_type0 count, const T & value = T(), const deque_params & params = deque_params(), bool relocate_to_greater_address = false, const Allocator & alloc = Allocator());
        //FORCE_INLINE void reset(size_type0 count, const deque_params & params = deque_params(), bool relocate_to_greater_address = false, const Allocator & alloc = Allocator());
        //template <typename InputIt>
        //FORCE_INLINE void reset(InputIt first, InputIt last, const deque_params & params = deque_params(), bool relocate_to_greater_address = false, const Allocator & alloc = Allocator());

        //FORCE_INLINE void assign(size_type0 count, const T & value);
        //template <typename InputIt>
        //FORCE_INLINE void assign(InputIt first, InputIt last);

       FORCE_INLINE const allocator_tuple & get_allocator_tuple() const;

        //FORCE_INLINE reference at(size_type0 pos);
        //FORCE_INLINE const_reference at(size_type0 pos) const;

        FORCE_INLINE reference operator [](size_type0 pos);
        FORCE_INLINE const_reference operator [](size_type0 pos) const;

        FORCE_INLINE reference front();
        FORCE_INLINE const_reference front() const;

        FORCE_INLINE reference back();
        FORCE_INLINE const_reference back() const;

        FORCE_INLINE iterator begin() noexcept;
        FORCE_INLINE const_iterator begin() const noexcept;
        FORCE_INLINE const_iterator cbegin() const noexcept;

        FORCE_INLINE iterator end() noexcept;
        FORCE_INLINE const_iterator end() const noexcept;
        FORCE_INLINE const_iterator cend() const noexcept;

        //FORCE_INLINE reverse_iterator rbegin() noexcept;
        //FORCE_INLINE const_reverse_iterator rbegin() const noexcept;
        //FORCE_INLINE const_reverse_iterator crbegin() const noexcept;

        //FORCE_INLINE reverse_iterator rend() noexcept;
        //FORCE_INLINE const_reverse_iterator rend() const noexcept;
        //FORCE_INLINE const_reverse_iterator crend() const noexcept;

        FORCE_INLINE bool empty() const noexcept;

        FORCE_INLINE size_type0 size() const noexcept;

        FORCE_INLINE size_type0 max_size() const noexcept;

        //FORCE_INLINE void shrink_to_fit();

        FORCE_INLINE void clear() noexcept;

        //FORCE_INLINE iterator insert(const_iterator pos, const T & value);
        //FORCE_INLINE iterator insert(const_iterator pos, size_type0 count, const T & value);
        //template <typename InputIt>
        //FORCE_INLINE iterator insert(const_iterator pos, InputIt first, InputIt last);

        FORCE_INLINE iterator erase(const_iterator pos);
        FORCE_INLINE iterator erase(const_iterator first, const_iterator last);

        FORCE_INLINE void push_back(const T & value);
        FORCE_INLINE void pop_back();

        FORCE_INLINE void push_front(const T & value);
        FORCE_INLINE void pop_front();

        //FORCE_INLINE void resize(size_type0 count);
        //FORCE_INLINE void resize(size_type0 count, const value_type & value);

    protected:
        using compressed_allocator_pair_type = compressed_pair<allocator_type0, allocator_type1>;

        compressed_pair<compressed_allocator_pair_type, This> m_compressed_pair;
    };

    //// deque_base::t_iterator_base

    template <typename T>
    template <typename container_type, typename T0, typename T1>
    FORCE_INLINE T1 & deque_base<T>::t_iterator_base<container_type, T0, T1>::operator *() const
    {
        return *DEBUG_VERIFY_TRUE(arr1_item_ptr);
    }

    template <typename T>
    template <typename container_type, typename T0, typename T1>
    FORCE_INLINE T1 * deque_base<T>::t_iterator_base<container_type, T0, T1>::operator ->() const
    {
        return DEBUG_VERIFY_TRUE(arr1_item_ptr);
    }

    template <typename T>
    template <typename container_type, typename T0, typename T1>
    FORCE_INLINE bool deque_base<T>::t_iterator_base<container_type, T0, T1>::operator ==(const t_iterator_base & r) const
    {
        IF_DEBUG_ASSERT_VERIFY_ENABLED(1) {
            return arr0_item_index == r.arr0_item_index && arr1_item_ptr == r.arr1_item_ptr;
        }

        return arr0_item_index == r.arr0_item_index && arr1_item_index == r.arr1_item_index;
    }

    template <typename T>
    template <typename container_type, typename T0, typename T1>
    FORCE_INLINE bool deque_base<T>::t_iterator_base<container_type, T0, T1>::operator !=(const t_iterator_base & r) const
    {
        return !this->operator ==(r);
    }

    template <typename T>
    template <typename container_type, typename T0, typename T1>
    FORCE_INLINE typename deque_base<T>::TEMPLATE_SCOPE t_iterator_base<container_type, T0, T1> & deque_base<T>::t_iterator_base<container_type, T0, T1>::operator ++()
    {
        auto & cont = *DEBUG_VERIFY_TRUE(container_ptr);
        auto & cont_this = cont.m_compressed_pair.second();

        IF_DEBUG_ASSERT_VERIFY_ENABLED(1) {
            auto & arr0_item = *DEBUG_VERIFY_TRUE(arr0_item_ptr);
            DEBUG_ASSERT_TRUE(arr0_item.arr1_ptr);

            DEBUG_ASSERT_TRUE(arr0_item_index >= cont_this.begin_index && arr0_item_index < cont_this.end_index);
            DEBUG_ASSERT_TRUE(arr0_item_index >= 0 && arr0_item_index < cont_this.arr0_capacity);
            DEBUG_ASSERT_TRUE(arr1_item_index >= arr0_item.begin_index && arr1_item_index < arr0_item.end_index);
            DEBUG_ASSERT_TRUE(arr1_item_index >= 0 && arr1_item_index < cont_this.arr1_capacity);
        }

        ++arr1_item_index;
        ++arr1_item_ptr;

        if (arr1_item_index == arr0_item_ptr->end_index) {
            ++arr0_item_index;
            ++arr0_item_ptr;

            if (arr0_item_index != cont_this.end_index) {
                arr1_item_index = arr0_item_ptr->begin_index;
                arr1_item_ptr = arr0_item_ptr->arr1_ptr;
            }
        }

        return *this;
    }

    template <typename T>
    template <typename container_type, typename T0, typename T1>
    FORCE_INLINE typename deque_base<T>::TEMPLATE_SCOPE t_iterator_base<container_type, T0, T1> & deque_base<T>::t_iterator_base<container_type, T0, T1>::operator --()
    {
        auto & cont = *DEBUG_VERIFY_TRUE(container_ptr);
        auto & cont_this = cont.m_compressed_pair.second();

        IF_DEBUG_ASSERT_VERIFY_ENABLED(1) {
            if (arr0_item_index != cont_this.end_index) {
                auto & arr0_item = *DEBUG_VERIFY_TRUE(arr0_item_ptr);
                DEBUG_ASSERT_TRUE(arr0_item.arr1_ptr);

                DEBUG_ASSERT_TRUE(arr0_item_index >= cont_this.begin_index && arr0_item_index < cont_this.end_index);
                DEBUG_ASSERT_TRUE(arr0_item_index >= 0 && arr0_item_index < cont_this.arr0_capacity);
                DEBUG_ASSERT_TRUE(arr1_item_index >= arr0_item.begin_index && arr1_item_index < arr0_item.end_index);
                DEBUG_ASSERT_TRUE(arr1_item_index >= 0 && arr1_item_index < cont_this.arr1_capacity);
            }
            else {
                auto & arr0_item = *(DEBUG_VERIFY_TRUE(arr0_item_ptr) - 1);
                DEBUG_ASSERT_TRUE(arr0_item.arr1_ptr);

                DEBUG_ASSERT_EQ(arr1_item_index, arr0_item.end_index);
                DEBUG_ASSERT_TRUE(arr0_item_index > 0 && arr0_item_index <= cont_this.arr0_capacity);
                DEBUG_ASSERT_TRUE(arr1_item_index > 0 && arr1_item_index <= cont_this.arr1_capacity);
            }
        }

        if (arr0_item_index != cont_this.end_index) {
            if (arr1_item_index != arr0_item_ptr->begin_index) {
                --arr1_item_index;
                --arr1_item_ptr;
            }
            else {
                --arr0_item_index;
                --arr0_item_ptr;
                arr1_item_index = arr0_item_ptr->end_index - 1;
                arr1_item_ptr = arr0_item_ptr->arr1_ptr + arr1_item_index;
            }
        }
        else {
            --arr1_item_index;
            --arr1_item_ptr;
            --arr0_item_index;
            --arr0_item_ptr;
        }

        return *this;
    }

    template <typename T>
    template <typename container_type, typename T0, typename T1>
    FORCE_INLINE typename deque_base<T>::TEMPLATE_SCOPE t_iterator_base<container_type, T0, T1> deque_base<T>::t_iterator_base<container_type, T0, T1>::operator ++(int)
    {
        const t_iterator_base it = { *this };
        ++*this;
        return it;
    }

    template <typename T>
    template <typename container_type, typename T0, typename T1>
    FORCE_INLINE typename deque_base<T>::TEMPLATE_SCOPE t_iterator_base<container_type, T0, T1> deque_base<T>::t_iterator_base<container_type, T0, T1>::operator --(int)
    {
        const t_iterator_base it = { *this };
        --*this;
        return it;
    }

    //// deque::iterator

    template <typename T, typename Allocator0, typename Allocator1>
    FORCE_INLINE deque<T, Allocator0, Allocator1>::iterator::iterator(const iterator_base & it) :
        iterator_base(it)
    {
    }

    template <typename T, typename Allocator0, typename Allocator1>
    FORCE_INLINE deque<T, Allocator0, Allocator1>::iterator::iterator(const const_iterator & it) :
        iterator_base(it)
    {
    }

    template <typename T, typename Allocator0, typename Allocator1>
    FORCE_INLINE deque<T, Allocator0, Allocator1>::iterator::iterator()
    {
    }

    //// deque::const_iterator

    template <typename T, typename Allocator0, typename Allocator1>
    FORCE_INLINE deque<T, Allocator0, Allocator1>::const_iterator::const_iterator(const const_iterator_base & it) :
        const_iterator_base(it)
    {
    }

    template <typename T, typename Allocator0, typename Allocator1>
    FORCE_INLINE deque<T, Allocator0, Allocator1>::const_iterator::const_iterator()
    {
    }

    //// deque

    template <typename T, typename Allocator0, typename Allocator1>
    FORCE_INLINE deque<T, Allocator0, Allocator1>::deque(const deque_params & params) :
        m_compressed_pair{ compressed_allocator_pair_type{ allocator_type0{}, allocator_type1{} }, This{ params } }
    {
    }

    template <typename T, typename Allocator0, typename Allocator1>
    FORCE_INLINE deque<T, Allocator0, Allocator1>::deque(const deque_params & params, const allocator_tuple & alloc_tuple) :
        m_compressed_pair{ compressed_allocator_pair_type{ std::get<0>(alloc_tuple), std::get<1>(alloc_tuple) }, This{ params } }
    {
    }

    template <typename T, typename Allocator0, typename Allocator1>
    FORCE_INLINE deque<T, Allocator0, Allocator1>::~deque()
    {
        auto & this_ = m_compressed_pair.second();

        clear();

        if (this_.arr0_ptr) {
            auto & compressed_pair_first = m_compressed_pair.first();

            auto & alloc0 = compressed_pair_first.first();

            base_type::deallocate_items(alloc0, this_.arr0_ptr, this_.arr0_capacity);

            this_.arr0_ptr = nullptr; // just in case
        }
    }

    template <typename T, typename Allocator0, typename Allocator1>
    FORCE_INLINE typename deque<T, Allocator0, Allocator1>::arr0_item * deque<T, Allocator0, Allocator1>::_reallocate_arr0_increase(size_type0 capacity, bool relocate_to_greater_address)
    {
        auto & this_ = m_compressed_pair.second();

        DEBUG_ASSERT_GT(capacity, this_.arr0_capacity);

        auto & compressed_pair_first = m_compressed_pair.first();

        auto & alloc0 = compressed_pair_first.first();

        const size_type0 size = this_.end_index - this_.begin_index;

        DEBUG_ASSERT_GT(capacity, size);

        size_type0 new_begin_index;
        size_type0 new_end_index;

        if (!relocate_to_greater_address) {
            new_begin_index = 0;
            new_end_index = size;
        }
        else {
            new_begin_index = capacity - size;
            new_end_index = capacity;
        }

        arr0_item * old_arr0_ptr = DEBUG_VERIFY_TRUE(this_.arr0_ptr);
        arr0_item * new_arr0_ptr = base_type::TEMPLATE_SCOPE allocate_construct_items<typename base_type::arr0_item>(alloc0, capacity, new_begin_index, size);
        arr0_unique_ptr new_arr0_uptr = base_type::make_items_uptr(alloc0, new_arr0_ptr, capacity, new_begin_index, size);

        // copy
        memcpy(new_arr0_ptr + new_begin_index, old_arr0_ptr + this_.begin_index, sizeof(arr0_item) * size);

        // relocate pointer
        this_.arr0_ptr = new_arr0_uptr.release();

        // to deallocate on exit
        arr0_unique_ptr old_arr0_uptr = base_type::make_items_uptr(alloc0, old_arr0_ptr, this_.arr0_capacity, this_.begin_index, this_.end_index);

        this_.arr0_capacity = capacity;
        this_.begin_index = new_begin_index;
        this_.end_index = new_end_index;

        return new_arr0_ptr;
    }

    template <typename T, typename Allocator0, typename Allocator1>
    FORCE_INLINE bool deque<T, Allocator0, Allocator1>::_relocate_arr0_items_to_center(size_type0 relocate_size, bool relocate_to_greater_address)
    {
        auto & this_ = m_compressed_pair.second();

        const size_type0 size = this_.end_index - this_.begin_index;

        DEBUG_ASSERT_TRUE(!relocate_to_greater_address && (this_.end_index == this_.arr0_capacity) || relocate_to_greater_address && !this_.begin_index);
        DEBUG_ASSERT_LT(relocate_size, this_.arr0_capacity);
        DEBUG_ASSERT_GE(relocate_size, size);

        auto & compressed_pair_first = m_compressed_pair.first();

        auto & alloc0 = compressed_pair_first.first();

        arr0_item * arr0_ptr = DEBUG_VERIFY_TRUE(this_.arr0_ptr);

        const size_type0 relocated_begin_index = STDSIZE_DIV_POF2_CONSTEXPR_VERIFY(this_.arr0_capacity - size, 2); // truncation to the lowest
        const size_type0 relocated_end_index = relocated_begin_index + size;

        size_type0 relocate_distance;

        if (!relocate_to_greater_address) {
            DEBUG_ASSERT_LE(relocated_begin_index, this_.begin_index);
            DEBUG_ASSERT_LE(relocated_end_index, this_.end_index);
            DEBUG_ASSERT_LE(relocated_end_index, this_.arr0_capacity);

            relocate_distance = this_.begin_index - relocated_begin_index;
            if (relocate_distance) {
                // default-construct before relocation
                base_type::construct_items(alloc0, arr0_ptr, relocated_begin_index, relocate_distance);

                // relocate
                memmove(arr0_ptr + relocated_begin_index, arr0_ptr + this_.begin_index, sizeof(arr0_item) * size);

                this_.begin_index = relocated_begin_index;

                // destruct moved items from right-to-left
                auto * item_ptr = arr0_ptr + this_.end_index;
                size_type0 item_count = 0;

                do {
                    ++item_count;
                    --item_ptr;

                    base_type::destruct_items(alloc0, item_ptr, 1);

                    --this_.end_index; // in case of exception in destructor
                } while (item_count < relocate_distance);

                DEBUG_ASSERT_EQ(this_.end_index, relocated_end_index);
            }
        }
        else {
            DEBUG_ASSERT_GE(relocated_begin_index, this_.begin_index);
            DEBUG_ASSERT_GE(relocated_end_index, this_.end_index);
            DEBUG_ASSERT_LE(relocated_end_index, this_.arr0_capacity);

            relocate_distance = relocated_begin_index - this_.begin_index;
            if (relocate_distance) {
                // default-construct before relocation
                base_type::construct_items(alloc0, arr0_ptr, relocated_end_index, relocate_distance);

                // relocate
                memmove(arr0_ptr + relocated_begin_index, arr0_ptr + this_.begin_index, sizeof(arr0_item) * size);

                this_.end_index = relocated_end_index;

                // destruct moved items from left-to-right
                auto * item_ptr = arr0_ptr + this_.begin_index;
                size_type0 item_count = 0;

                do {
                    base_type::destruct_items(alloc0, item_ptr, 1);

                    ++item_count;
                    ++item_ptr;
                    ++this_.begin_index; // in case of exception in destructor
                } while (item_count < relocate_distance);

                DEBUG_ASSERT_EQ(this_.begin_index, relocated_begin_index);
            }
        }

        return relocate_distance ? true : false;
    }

    template <typename T, typename Allocator0, typename Allocator1>
    FORCE_INLINE void deque<T, Allocator0, Allocator1>::reset(const deque_params & params, bool relocate_to_greater_address) noexcept
    {
        auto & this_ = m_compressed_pair.second();

        auto * arr0_ptr = this_.arr0_ptr;

        const size_type1 arr1_capacity = base_type::get_arr1_capacity(params.min_arr1_capacity_bytes);

        if (this_.arr1_capacity != arr1_capacity) {
            clear();
        }

        if (arr0_ptr && this_.arr0_capacity < params.min_arr0_capacity) {
            _reallocate_arr0_increase(params.min_arr0_capacity, relocate_to_greater_address);
        }

        this_.params.reset(params);
    }

    template <typename T, typename Allocator0, typename Allocator1>
    FORCE_INLINE const typename deque<T, Allocator0, Allocator1>::allocator_tuple & deque<T, Allocator0, Allocator1>::get_allocator_tuple() const
    {
        const auto & compressed_pair_first = m_compressed_pair.first();

        return std::make_tuple(compressed_pair_first.first(), compressed_pair_first.second());
    }

    template <typename T, typename Allocator0, typename Allocator1>
    FORCE_INLINE typename deque<T, Allocator0, Allocator1>::reference deque<T, Allocator0, Allocator1>::operator [](size_type0 pos)
    {
        return const_cast<reference>(const_cast<const deque *>(this)->operator [](pos));
    }

    template <typename T, typename Allocator0, typename Allocator1>
    FORCE_INLINE typename deque<T, Allocator0, Allocator1>::const_reference deque<T, Allocator0, Allocator1>::operator [](size_type0 pos) const
    {
        auto & this_ = m_compressed_pair.second();

        this_._validate_not_empty();

        if (DEBUG_VERIFY_LE(this_.head_arr1_size, this_.arr1_capacity) != this_.arr1_capacity) {
            if (pos >= this_.head_arr1_size) {
                const auto divrem = UINT32_DIVREM_POF2_CEIL_VERIFY(pos - this_.head_arr1_size, this_.arr1_capacity);

                // level 0
                DEBUG_ASSERT_LT(this_.begin_index + divrem.quot + 1, this_.end_index);
                const auto & arr0_item = DEBUG_VERIFY_TRUE(this_.arr0_ptr)[this_.begin_index + divrem.quot + 1];
                // level 1
                DEBUG_ASSERT_LT(arr0_item.begin_index + divrem.rem, arr0_item.end_index);

                return DEBUG_VERIFY_TRUE(arr0_item.arr1_ptr)[arr0_item.begin_index + divrem.rem];
            }
            else {
                // level 0
                const auto & arr0_item = DEBUG_VERIFY_TRUE(this_.arr0_ptr)[this_.begin_index];
                // level 1
                DEBUG_ASSERT_LT(arr0_item.begin_index + pos, arr0_item.end_index);

                return DEBUG_VERIFY_TRUE(arr0_item.arr1_ptr)[arr0_item.begin_index + pos];
            }
        }
        else {
            const auto divrem = UINT32_DIVREM_POF2_CEIL_VERIFY(pos, this_.arr1_capacity);

            // level 0
            DEBUG_ASSERT_LT(this_.begin_index + divrem.quot, this_.end_index);
            const auto & arr0_item = DEBUG_VERIFY_TRUE(this_.arr0_ptr)[this_.begin_index + divrem.quot];
            // level 1
            DEBUG_ASSERT_LT(arr0_item.begin_index + divrem.rem, arr0_item.end_index);

            return DEBUG_VERIFY_TRUE(arr0_item.arr1_ptr)[arr0_item.begin_index + divrem.rem];
        }
    }

    template <typename T, typename Allocator0, typename Allocator1>
    FORCE_INLINE typename deque<T, Allocator0, Allocator1>::reference deque<T, Allocator0, Allocator1>::front()
    {
        return this->operator [](0);
    }

    template <typename T, typename Allocator0, typename Allocator1>
    FORCE_INLINE typename deque<T, Allocator0, Allocator1>::const_reference deque<T, Allocator0, Allocator1>::front() const
    {
        return this->operator [](0);
    }

    template <typename T, typename Allocator0, typename Allocator1>
    FORCE_INLINE typename deque<T, Allocator0, Allocator1>::reference deque<T, Allocator0, Allocator1>::back()
    {
        return this->operator [](DEBUG_VERIFY_GT(size(), 0U) - 1);
    }

    template <typename T, typename Allocator0, typename Allocator1>
    FORCE_INLINE typename deque<T, Allocator0, Allocator1>::const_reference deque<T, Allocator0, Allocator1>::back() const
    {
        return this->operator [](DEBUG_VERIFY_GT(size(), 0U) - 1);
    }

    template <typename T, typename Allocator0, typename Allocator1>
    FORCE_INLINE typename deque<T, Allocator0, Allocator1>::iterator deque<T, Allocator0, Allocator1>::begin() noexcept
    {
        return const_cast<const deque *>(this)->begin();
    }

    template <typename T, typename Allocator0, typename Allocator1>
    FORCE_INLINE typename deque<T, Allocator0, Allocator1>::const_iterator deque<T, Allocator0, Allocator1>::begin() const noexcept
    {
        auto & this_ = m_compressed_pair.second();

        if (!empty()) {
            this_._validate_not_empty();

            auto * arr0_ptr = this_.arr0_ptr;

            auto & arr0_head_item = arr0_ptr[this_.begin_index];

            return const_iterator{
                const_iterator_base{
                    this,
                    arr0_ptr + this_.begin_index, this_.begin_index,
                    arr0_head_item.arr1_ptr + arr0_head_item.begin_index, arr0_head_item.begin_index
                }
            };
        }

        this_._validate_empty();

        return const_iterator{
            const_iterator_base{
                this,
                nullptr, deque_params::size0_max,
                nullptr, deque_params::size1_max
            }
        };
    }

    template <typename T, typename Allocator0, typename Allocator1>
    FORCE_INLINE typename deque<T, Allocator0, Allocator1>::const_iterator deque<T, Allocator0, Allocator1>::cbegin() const noexcept
    {
        return begin();
    }

    template <typename T, typename Allocator0, typename Allocator1>
    FORCE_INLINE typename deque<T, Allocator0, Allocator1>::iterator deque<T, Allocator0, Allocator1>::end() noexcept
    {
        return const_cast<const deque *>(this)->end();
    }

    template <typename T, typename Allocator0, typename Allocator1>
    FORCE_INLINE typename deque<T, Allocator0, Allocator1>::const_iterator deque<T, Allocator0, Allocator1>::end() const noexcept
    {
        auto & this_ = m_compressed_pair.second();

        if (!empty()) {
            this_._validate_not_empty();

            auto * arr0_ptr = this_.arr0_ptr;

            auto & arr0_tail_item = arr0_ptr[this_.end_index - 1];

            return const_iterator{
                const_iterator_base{
                    this,
                    arr0_ptr + this_.end_index, this_.end_index,
                    arr0_tail_item.arr1_ptr + arr0_tail_item.end_index, arr0_tail_item.end_index
                }
            };
        }

        this_._validate_empty();

        return const_iterator{
            const_iterator_base{
                this,
                nullptr, deque_params::size0_max,
                nullptr, deque_params::size1_max
            }
        };
    }

    template <typename T, typename Allocator0, typename Allocator1>
    FORCE_INLINE typename deque<T, Allocator0, Allocator1>::const_iterator deque<T, Allocator0, Allocator1>::cend() const noexcept
    {
        return end();
    }

    template <typename T, typename Allocator0, typename Allocator1>
    FORCE_INLINE bool deque<T, Allocator0, Allocator1>::empty() const noexcept
    {
        return !size();
    }

    template <typename T, typename Allocator0, typename Allocator1>
    FORCE_INLINE typename deque<T, Allocator0, Allocator1>::size_type0 deque<T, Allocator0, Allocator1>::size() const noexcept
    {
        auto & this_ = m_compressed_pair.second();

        return this_.size;
    }

    template <typename T, typename Allocator0, typename Allocator1>
    FORCE_INLINE typename deque<T, Allocator0, Allocator1>::size_type0 deque<T, Allocator0, Allocator1>::max_size() const noexcept
    {
        return size_type0((deque_params::size0_max - sizeof(deque) - sizeof(arr0_item)) / sizeof(T));
    }

    template <typename T, typename Allocator0, typename Allocator1>
    FORCE_INLINE void deque<T, Allocator0, Allocator1>::clear() noexcept
    {
        auto & this_ = m_compressed_pair.second();

        if (!empty()) {
            this_._validate_not_empty();

            auto & compressed_pair_first = m_compressed_pair.first();

            auto & alloc0 = compressed_pair_first.first();
            auto & alloc1 = compressed_pair_first.second();

            auto & this_ = m_compressed_pair.second();

            size_type0 arr0_item_index = this_.end_index;
            auto * arr0_item_ptr = this_.arr0_ptr + this_.end_index;

            do {
                --arr0_item_index;
                --arr0_item_ptr;

                auto & arr0_item = *arr0_item_ptr;
                DEBUG_ASSERT_LT(arr0_item.begin_index, arr0_item.end_index);

                auto * arr1_item_ptr = DEBUG_VERIFY_TRUE(arr0_item.arr1_ptr) + arr0_item.end_index;
                size_type0 arr1_item_index = arr0_item.end_index;
                do {
                    --arr1_item_index;
                    --arr1_item_ptr;

                    base_type::destruct_items(alloc1, DEBUG_VERIFY_TRUE(arr1_item_ptr), 1);

                    // just in case of exception
                    DEBUG_ASSERT_TRUE(this_.size);
                    --this_.size;
                    --arr0_item.end_index;

                    if (arr0_item_index == this_.begin_index) {
                        DEBUG_ASSERT_TRUE(this_.head_arr1_size);
                        --this_.head_arr1_size;
                    }
                }
                while (arr1_item_index > arr0_item.begin_index);

                base_type::deallocate_items(alloc1, DEBUG_VERIFY_TRUE(arr0_item.arr1_ptr), this_.arr1_capacity);

                // just in case of exception
                arr0_item.reset(nullptr, 0, 0);
                --this_.end_index;

                if (arr0_item_index != this_.begin_index) {
                  this_.arr1_tail_ptr = this_.arr0_ptr[arr0_item_index - 1].arr1_ptr;
                }
                else {
                    this_.arr1_head_ptr = this_.arr1_tail_ptr = nullptr;
                }

                base_type::destruct_items(alloc0, DEBUG_VERIFY_TRUE(arr0_item_ptr), 1);
            }
            while (arr0_item_index > this_.begin_index);

            // no level 0 deallocation here, only call destructors

            this_.size              = 0;
            this_.begin_index       = 0;
            this_.end_index         = 0;
            DEBUG_VERIFY_FALSE(this_.arr1_head_ptr);    // must be already cleared up
            DEBUG_VERIFY_FALSE(this_.arr1_tail_ptr);
            this_.arr1_head_ptr = this_.arr1_tail_ptr = nullptr; // just in case
            DEBUG_VERIFY_FALSE(this_.head_arr1_size);   // must be already cleared up
            this_.head_arr1_size    = 0;                // just in case
        }

        this_._validate_empty();
    }

    template <typename T, typename Allocator0, typename Allocator1>
    FORCE_INLINE void deque<T, Allocator0, Allocator1>::push_back(const T & value)
    {
        auto & compressed_pair_first = m_compressed_pair.first();

        auto & alloc0 = compressed_pair_first.first();
        auto & alloc1 = compressed_pair_first.second();

        auto & this_ = m_compressed_pair.second();

        arr0_item * arr0_ptr;
        arr1_item * arr1_ptr;

        // destructs and deallocates ONLY level 0 constructions and allocations
        arr0_unique_ptr arr0_uptr;

        // destructs and deallocates ONLY level 1 constructions and allocations
        arr1_unique_ptr arr1_uptr;

        if (!empty()) {
            this_._validate_not_empty();

            arr0_ptr = this_.arr0_ptr;
            arr1_ptr = DEBUG_VERIFY_TRUE(this_.arr1_tail_ptr);

            auto & arr0_tail_item = arr0_ptr[this_.end_index - 1];

            if (arr0_tail_item.end_index < this_.arr1_capacity) {
                base_type::construct_items(alloc1, arr1_ptr, arr0_tail_item.end_index, 1);

                arr1_ptr[arr0_tail_item.end_index] = value;

                ++arr0_tail_item.end_index;

                if (this_.arr1_head_ptr == this_.arr1_tail_ptr) {
                    ++this_.head_arr1_size;
                }
            }
            else {
                DEBUG_ASSERT_LE(this_.end_index, this_.arr0_capacity);

                if (this_.end_index == this_.arr0_capacity) {
                    const size_type0 size = this_.end_index - this_.begin_index;
                    const size_type0 arr0_relocate_size =
                        size_type0((uint64_t(size + 1) * deque_params::default_relocate_if_arr0_size_greater_denominator + deque_params::default_relocate_if_arr0_size_greater_numerator - 1) /
                            deque_params::default_relocate_if_arr0_size_greater_numerator);

                    bool is_relocated = false;
                    if (arr0_relocate_size >= size && arr0_relocate_size < this_.arr0_capacity) {
                        is_relocated = _relocate_arr0_items_to_center(arr0_relocate_size, false);
                    }

                    if (!is_relocated) {
                        arr0_ptr = _reallocate_arr0_increase(
                            size_type0((uint64_t(this_.arr0_capacity) * deque_params::default_grow_by_numerator + deque_params::default_grow_by_denominator - 1) /
                                deque_params::default_grow_by_denominator), false);
                    }
                }

                arr1_ptr = base_type::TEMPLATE_SCOPE allocate_construct_items<typename base_type::arr1_item>(
                    alloc1, DEBUG_VERIFY_TRUE(this_.arr1_capacity), 0, 1);
                arr1_uptr = base_type::make_items_uptr(alloc1, arr1_ptr, this_.arr1_capacity, 0, 1);

                arr1_ptr[0] = value;

                DEBUG_ASSERT_LT(this_.end_index, this_.arr0_capacity);
                base_type::construct_items(alloc0, arr0_ptr, this_.end_index, 1);

                arr0_ptr[this_.end_index].reset(arr1_ptr, 0, 1);

                arr1_uptr.release();

                this_.arr1_tail_ptr = arr1_ptr;

                ++this_.end_index;
            }
        }
        else {
            this_._validate_empty();

            size_type0 arr0_capacity;

            if (this_.arr0_ptr) {
                arr0_ptr = this_.arr0_ptr;
                arr0_capacity = this_.arr0_capacity;
            }
            else {
                arr0_capacity = this_.params.min_arr0_capacity;
                arr0_ptr = base_type::TEMPLATE_SCOPE allocate_construct_items<typename base_type::arr0_item>(
                    alloc0, DEBUG_VERIFY_TRUE(arr0_capacity), 0, 1);
                arr0_uptr.reset(base_type::make_items_uptr(alloc0, arr0_ptr, arr0_capacity, 0, 1).release());
            }

            const size_type1 arr1_capacity = base_type::get_arr1_capacity(this_.params.min_arr1_capacity_bytes);

            arr1_ptr = base_type::TEMPLATE_SCOPE allocate_construct_items<typename base_type::arr1_item>(
                alloc1, DEBUG_VERIFY_TRUE(arr1_capacity), 0, 1);
            arr1_uptr.reset(base_type::make_items_uptr(alloc1, arr1_ptr, arr1_capacity, 0, 1).release());

            arr1_ptr[0] = value;

            DEBUG_ASSERT_LE(this_.end_index, arr0_capacity);
            base_type::construct_items(alloc0, arr0_ptr, 0, 1);

            arr0_ptr[0].reset(arr1_ptr, 0, 1);

            arr1_uptr.release();

            if (!this_.arr0_ptr) {
                this_.arr0_ptr = arr0_uptr.release();
                this_.arr0_capacity = arr0_capacity;
            }

            this_.arr1_head_ptr = this_.arr1_tail_ptr = arr1_ptr;
            this_.arr1_capacity = arr1_capacity;

            this_.begin_index = 0;
            this_.end_index = 1;

            DEBUG_ASSERT_FALSE(this_.head_arr1_size);
            ++this_.head_arr1_size;
        }

        ++this_.size;
    }

    template <typename T, typename Allocator0, typename Allocator1>
    FORCE_INLINE void deque<T, Allocator0, Allocator1>::pop_back()
    {
        auto & compressed_pair_first = m_compressed_pair.first();

        auto & alloc1 = compressed_pair_first.second();

        auto & this_ = m_compressed_pair.second();

        this_._validate_not_empty();

        arr0_item * arr0_ptr = this_.arr0_ptr;
        arr1_item * arr1_ptr = DEBUG_VERIFY_TRUE(this_.arr1_tail_ptr);

        auto & arr0_tail_item = arr0_ptr[this_.end_index - 1];

        DEBUG_ASSERT_LT(arr0_tail_item.begin_index, arr0_tail_item.end_index);
        DEBUG_ASSERT_TRUE(this_.arr1_head_ptr != this_.arr1_tail_ptr || this_.head_arr1_size);

        --arr0_tail_item.end_index;

        if (arr0_tail_item.begin_index != arr0_tail_item.end_index) {
            base_type::destruct_items(alloc1, arr1_ptr + arr0_tail_item.end_index, 1);

            if (this_.arr1_head_ptr == this_.arr1_tail_ptr) {
                DEBUG_ASSERT_TRUE(this_.head_arr1_size);
                --this_.head_arr1_size;
            }
        }
        else {
            // destructs and deallocates ONLY level 1 constructions and allocations
            arr1_unique_ptr arr1_uptr = base_type::make_items_uptr(alloc1, arr1_ptr, this_.arr1_capacity, arr0_tail_item.begin_index, 1); // must destruct on scope exit
            UTILITY_UNUSED_STATEMENT(arr1_uptr); // unused variable warning suppression

            DEBUG_ASSERT_LT(this_.begin_index, this_.end_index);

            --this_.end_index;

            if (this_.begin_index != this_.end_index) {
                auto & arr0_prev_tail_item = arr0_ptr[this_.end_index - 1];
                this_.arr1_tail_ptr = arr0_prev_tail_item.arr1_ptr;
            }
            else {
                this_.arr1_head_ptr = this_.arr1_tail_ptr = nullptr;
                DEBUG_ASSERT_EQ(this_.head_arr1_size, 1U);
                this_.head_arr1_size = 0;
            }
        }

        --this_.size;
    }

    template <typename T, typename Allocator0, typename Allocator1>
    FORCE_INLINE void deque<T, Allocator0, Allocator1>::push_front(const T & value)
    {
        auto & compressed_pair_first = m_compressed_pair.first();

        auto & alloc0 = compressed_pair_first.first();
        auto & alloc1 = compressed_pair_first.second();

        auto & this_ = m_compressed_pair.second();

        arr0_item * arr0_ptr;
        arr1_item * arr1_ptr;

        // destructs and deallocates ONLY level 0 constructions and allocations
        arr0_unique_ptr arr0_uptr;

        // destructs and deallocates ONLY level 1 constructions and allocations
        arr1_unique_ptr arr1_uptr;

        if (!empty()) {
            this_._validate_not_empty();

            arr0_ptr = this_.arr0_ptr;
            arr1_ptr = DEBUG_VERIFY_TRUE(this_.arr1_head_ptr);

            auto & arr0_head_item = arr0_ptr[this_.begin_index];

            if (arr0_head_item.begin_index > 0) {
                base_type::construct_items(alloc1, arr1_ptr, arr0_head_item.begin_index - 1, 1);

                arr1_ptr[arr0_head_item.begin_index - 1] = value;

                --arr0_head_item.begin_index;

                ++this_.head_arr1_size;
            }
            else {
                DEBUG_ASSERT_LT(this_.begin_index, this_.arr0_capacity);

                if (!this_.begin_index) {
                    const size_type0 size = this_.end_index - this_.begin_index;
                    const size_type0 arr0_relocate_size =
                        size_type0((uint64_t(size + 1) * deque_params::default_relocate_if_arr0_size_greater_denominator + deque_params::default_relocate_if_arr0_size_greater_numerator - 1) /
                            deque_params::default_relocate_if_arr0_size_greater_numerator);

                    bool is_relocated = false;
                    if (arr0_relocate_size >= size && arr0_relocate_size < this_.arr0_capacity) {
                        is_relocated = _relocate_arr0_items_to_center(arr0_relocate_size, true);
                    }

                    if (!is_relocated) {
                        arr0_ptr = _reallocate_arr0_increase(
                            size_type0((uint64_t(this_.arr0_capacity) * deque_params::default_grow_by_numerator + deque_params::default_grow_by_denominator - 1) /
                                deque_params::default_grow_by_denominator), true);
                    }
                }

                arr1_ptr = base_type::TEMPLATE_SCOPE allocate_construct_items<typename base_type::arr1_item>(
                    alloc1, DEBUG_VERIFY_TRUE(this_.arr1_capacity), this_.arr1_capacity - 1, 1);
                arr1_uptr = base_type::make_items_uptr(alloc1, arr1_ptr, this_.arr1_capacity, this_.arr1_capacity - 1, 1);

                arr1_ptr[this_.arr1_capacity - 1] = value;

                DEBUG_ASSERT_GT(this_.begin_index, 0U);
                base_type::construct_items(alloc0, arr0_ptr, this_.begin_index - 1, 1);

                arr0_ptr[this_.begin_index - 1].reset(arr1_ptr, this_.arr1_capacity - 1, this_.arr1_capacity);

                arr1_uptr.release();

                this_.arr1_head_ptr = arr1_ptr;

                --this_.begin_index;

                this_.head_arr1_size = 1;
            }
        }
        else {
            this_._validate_empty();

            size_type0 arr0_capacity;

            if (this_.arr0_ptr) {
                arr0_ptr = this_.arr0_ptr;
                arr0_capacity = this_.arr0_capacity;
            }
            else {
                arr0_capacity = this_.params.min_arr0_capacity;
                arr0_ptr = base_type::TEMPLATE_SCOPE allocate_construct_items<typename base_type::arr0_item>(
                    alloc0, DEBUG_VERIFY_TRUE(arr0_capacity), arr0_capacity - 1, 1);
                arr0_uptr.reset(base_type::make_items_uptr(alloc0, arr0_ptr, arr0_capacity, arr0_capacity - 1, 1).release());
            }

            const size_type1 arr1_capacity = base_type::get_arr1_capacity(this_.params.min_arr1_capacity_bytes);

            arr1_ptr = base_type::TEMPLATE_SCOPE allocate_construct_items<typename base_type::arr1_item>(
                alloc1, DEBUG_VERIFY_TRUE(arr1_capacity), arr1_capacity - 1, 1);
            arr1_uptr.reset(base_type::make_items_uptr(alloc1, arr1_ptr, arr1_capacity, arr1_capacity - 1, 1).release());

            arr1_ptr[arr1_capacity - 1] = value;

            DEBUG_ASSERT_GT(arr0_capacity, 0U);
            base_type::construct_items(alloc0, arr0_ptr, arr0_capacity - 1, 1);

            arr0_ptr[arr0_capacity - 1].reset(arr1_ptr, arr1_capacity - 1, arr1_capacity);

            arr1_uptr.release();

            if (!this_.arr0_ptr) {
                this_.arr0_ptr = arr0_uptr.release();
                this_.arr0_capacity = arr0_capacity;
            }

            this_.arr1_head_ptr = this_.arr1_tail_ptr = arr1_ptr;
            this_.arr1_capacity = arr1_capacity;

            this_.begin_index = arr0_capacity - 1;
            this_.end_index = arr0_capacity;

            DEBUG_ASSERT_FALSE(this_.head_arr1_size);
            ++this_.head_arr1_size;
        }

        ++this_.size;
    }

    template <typename T, typename Allocator0, typename Allocator1>
    FORCE_INLINE void deque<T, Allocator0, Allocator1>::pop_front()
    {
        auto & compressed_pair_first = m_compressed_pair.first();

        auto & alloc1 = compressed_pair_first.second();

        auto & this_ = m_compressed_pair.second();

        this_._validate_not_empty();

        arr0_item * arr0_ptr = this_.arr0_ptr;
        arr1_item * arr1_ptr = DEBUG_VERIFY_TRUE(this_.arr1_head_ptr);

        auto & arr0_head_item = arr0_ptr[this_.begin_index];

        DEBUG_ASSERT_LT(arr0_head_item.begin_index, arr0_head_item.end_index);
        DEBUG_ASSERT_TRUE(this_.arr1_head_ptr != this_.arr1_tail_ptr || this_.head_arr1_size);

        ++arr0_head_item.begin_index;

        if (arr0_head_item.begin_index != arr0_head_item.end_index) {
            base_type::destruct_items(alloc1, arr1_ptr + arr0_head_item.begin_index - 1, 1);

            DEBUG_ASSERT_TRUE(this_.head_arr1_size);
            --this_.head_arr1_size;
        }
        else {
            // destructs and deallocates ONLY level 1 constructions and allocations
            arr1_unique_ptr arr1_uptr = base_type::make_items_uptr(alloc1, arr1_ptr, this_.arr1_capacity, arr0_head_item.begin_index - 1, 1); // must destruct on scope exit
            UTILITY_UNUSED_STATEMENT(arr1_uptr); // unused variable warning suppression

            DEBUG_ASSERT_LT(this_.begin_index, this_.end_index);

            ++this_.begin_index;

            if (this_.begin_index != this_.end_index) {
                auto & arr0_next_head_item = arr0_ptr[this_.begin_index];
                this_.arr1_head_ptr = arr0_next_head_item.arr1_ptr;
                this_.head_arr1_size = arr0_next_head_item.end_index - arr0_next_head_item.begin_index;
                DEBUG_ASSERT_TRUE(this_.head_arr1_size);
            }
            else {
                this_.arr1_head_ptr = this_.arr1_tail_ptr = nullptr;
                DEBUG_ASSERT_EQ(this_.head_arr1_size, 1U);
                this_.head_arr1_size = 0;
            }
        }

        --this_.size;
    }
}

#endif
