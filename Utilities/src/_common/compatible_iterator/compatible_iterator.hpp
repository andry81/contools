#pragma once

// DO NOT REMOVE, exists to avoid private/public headers mixing!
#ifndef TACKLE_COMPATIBLE_ITEREATOR_HPP
#define TACKLE_COMPATIBLE_ITEREATOR_HPP

#include <tacklelib/tackle/addressof.hpp>

#include <assert.h>
#include <cstring>
#include <type_traits>
#include <memory>

#include <vector>
#include <list>
#include <utility>

//#define DISABLE_ITERATOR_SINGULARITY_CHECK

namespace tackle
{
    typedef char byte;

    template <bool b, int i1, int i2>
    class int_if
    {
    public:
        enum { value = i1 };
    };

    template <int i1, int i2>
    class int_if<false, i1, i2>
    {
    public:
        enum { value = i2 };
    };

    template <int i1, int i2, int i3, int i4>
    class int_max
    {
    protected:
        enum
        {
            is_i1_less = (i1 < i2 ? 1 : 0),
            is_i3_less = (i3 < i4 ? 1 : 0),
            max_i12 = int_if<is_i1_less, i2, i1>::value,
            max_i34 = int_if<is_i3_less, i4, i3>::value,
            is_max_i12_less = (int(max_i12) < int(max_i34) ? 1 : 0)
        };

    public:
        enum { value = int_if<is_max_i12_less, max_i34, max_i12>::value };
    };

    template <int i1, int i2>
    class int_max<i1, i2, -1, -1>
    {
    protected:
        enum
        {
            is_i1_less = (i1 < i2 ? 1 : 0)
        };

    public:
        enum { value = int_if<is_i1_less, i2, i1>::value };
    };

    template <int i1, int i2, int i3>
    class int_max<i1, i2, i3, -1>
    {
    protected:
        enum
        {
            is_i1_less = (i1 < i2 ? 1 : 0),
            max_i12 = int_if<is_i1_less, i2, i1>::value,
            is_max_i12_less = (int(max_i12) < i3 ? 1 : 0)
        };

    public:
        enum { value = int_if<is_max_i12_less, i3, max_i12>::value };
    };

    // Wrapper around aligned storage to disable all unspecified behaviour and implement `this_` function instead of `address` function.
    //
    template <std::size_t S, std::size_t A>
    class aligned_storage
    {
    public:
        typename std::aligned_storage<S, A>::type storage;

        aligned_storage()
        {
        }

    private:
        aligned_storage(const aligned_storage & storage_);
        const aligned_storage & operator =(const aligned_storage & storage_);

    public:
        void * this_()
        {
            return utility::addressof(storage);
        }

        const void * this_() const
        {
            return utility::addressof(storage);
        }
    };

    // avoiding gcc warning: `... may be used uninitialized in this function`
    template <typename T>
    T & make_static_default()
    {
        static T value;
        return value;
    };

    // avoiding implicit usage of explicit copy-ctor of type T by return type in make functions
    template <typename T>
    class make_holder : public T
    {
    protected:
        // direct call forbidden constructors
        make_holder()
        {
        }

    public:
        make_holder(const T & obj) : T(obj)
        {
        }
    };

    // global_construct_storage
    template <typename AS, typename T>
    inline void global_construct_storage(T & storage)
    {
        return global_construct_storage<AS>(std::addressof(storage));
    }

    template <typename AS, typename T>
    inline void global_construct_storage(T * storage)
    {
        ::new (reinterpret_cast<AS*>(storage)) AS;
    }

    template <typename AS, typename T, typename P1>
    inline void global_construct_storage(T & storage, const P1 & p1)
    {
        return global_construct_storage<AS>(std::addressof(storage), p1);
    }

    template <typename AS, typename T, typename P1>
    inline void global_construct_storage(T * storage, const P1 & p1)
    {
        ::new (reinterpret_cast<AS*>(storage)) AS(p1);
    }

    // destruct_storage
    template <typename AS, typename T>
    inline void destruct_storage(T & storage)
    {
        return destruct_storage<AS *>(std::addressof(storage));
    }

    template <typename AS, typename T>
    inline void destruct_storage(T * storage)
    {
        reinterpret_cast<AS *>(storage)->AS::~AS();
    }

    //CAUTION.
    //  It enables the user to check whether an iterator is singular or not.
    //  This is available ONLY if an iterator has a default constructor with member initialization with the same values each call time,
    //  otherwise this function will involve undefined behaviour.
    //  To avoid that problem you should check what constructor before function call for each respective iterator type!
    //
    template <typename container_t>
    int is_singular_iterator(const typename container_t::iterator & it, bool check_self_consistency = true)
    {
        // check self consistency
        tackle::aligned_storage<sizeof(it), std::alignment_of<typename container_t::iterator>::value> aligned_buf1;
        tackle::aligned_storage<sizeof(it), std::alignment_of<typename container_t::iterator>::value> aligned_buf2;

        tackle::byte * aligned_buf_ptr1 = 0;
        tackle::byte * aligned_buf_ptr2 = 0;

        if (check_self_consistency)
        {
            aligned_buf_ptr1 = reinterpret_cast<tackle::byte *>(aligned_buf1.this_());
            aligned_buf_ptr2 = reinterpret_cast<tackle::byte *>(aligned_buf2.this_());

            for (int i = 0; i < sizeof(aligned_buf1); i++)
            {
                *(aligned_buf_ptr1 + i) = tackle::byte(i + 1);
            }
            for (int i = 0; i < sizeof(aligned_buf2); i++)
            {
                *(aligned_buf_ptr2 + i) = tackle::byte(sizeof(aligned_buf1) + i + 1);
            }

            tackle::global_construct_storage<typename container_t::iterator>(aligned_buf_ptr1);
            tackle::global_construct_storage<typename container_t::iterator>(aligned_buf_ptr2);
        }

        int result = -1;
        if (!check_self_consistency || !memcmp((void *)aligned_buf_ptr1, (void *)aligned_buf_ptr2, sizeof(aligned_buf_ptr1)))
        {
            typename container_t::iterator & default_it = make_static_default<typename container_t::iterator>();
            result = !memcmp(&it, &default_it, sizeof(it)) ? 1 : 0;
        }

        if (check_self_consistency)
        {
            tackle::destruct_storage<typename container_t::iterator>(aligned_buf_ptr1);
            tackle::destruct_storage<typename container_t::iterator>(aligned_buf_ptr2);
        }

        assert(result >= 0);

        return result;
    }

    template <typename container_t>
    int is_singular_iterator(const typename container_t::const_iterator & it, bool check_self_consistency = true)
    {
        // check self consistency
        tackle::aligned_storage<sizeof(it), std::alignment_of<typename container_t::const_iterator>::value> aligned_buf1;
        tackle::aligned_storage<sizeof(it), std::alignment_of<typename container_t::const_iterator>::value> aligned_buf2;

        tackle::byte * aligned_buf_ptr1 = 0;
        tackle::byte * aligned_buf_ptr2 = 0;

        if (check_self_consistency)
        {
            aligned_buf_ptr1 = reinterpret_cast<tackle::byte *>(aligned_buf1.this_());
            aligned_buf_ptr2 = reinterpret_cast<tackle::byte *>(aligned_buf2.this_());

            for (size_t i = 0; i < sizeof(aligned_buf1); i++)
            {
                *(aligned_buf_ptr1 + i) = tackle::byte(i + 1);
            }
            for (size_t i = 0; i < sizeof(aligned_buf2); i++)
            {
                *(aligned_buf_ptr2 + i) = tackle::byte(sizeof(aligned_buf1) + i + 1);
            }

            tackle::global_construct_storage<typename container_t::const_iterator>(aligned_buf_ptr1);
            tackle::global_construct_storage<typename container_t::const_iterator>(aligned_buf_ptr2);
        }

        int result = -1;
        if (!check_self_consistency || !memcmp((void *)aligned_buf_ptr1, (void *)aligned_buf_ptr2, sizeof(aligned_buf_ptr1)))
        {
            typename container_t::const_iterator & default_it = make_static_default<typename container_t::const_iterator>();
            result = !memcmp(&it, &default_it, sizeof(it)) ? 1 : 0;
        }

        if (check_self_consistency)
        {
            tackle::destruct_storage<typename container_t::const_iterator>(aligned_buf_ptr1);
            tackle::destruct_storage<typename container_t::const_iterator>(aligned_buf_ptr2);
        }

        assert(result >= 0);

        return result;
    }

    template <typename container_t>
    int is_singular_iterator(const typename container_t::reverse_iterator & it, bool check_self_consistency = true)
    {
        // check self consistency
        tackle::aligned_storage<sizeof(it), std::alignment_of<typename container_t::reverse_iterator>::value> aligned_buf1;
        tackle::aligned_storage<sizeof(it), std::alignment_of<typename container_t::reverse_iterator>::value> aligned_buf2;

        tackle::byte * aligned_buf_ptr1 = 0;
        tackle::byte * aligned_buf_ptr2 = 0;

        if (check_self_consistency)
        {
            aligned_buf_ptr1 = reinterpret_cast<tackle::byte *>(aligned_buf1.this_());
            aligned_buf_ptr2 = reinterpret_cast<tackle::byte *>(aligned_buf2.this_());

            for (int i = 0; i < sizeof(aligned_buf1); i++)
            {
                *(aligned_buf_ptr1 + i) = tackle::byte(i + 1);
        }
            for (int i = 0; i < sizeof(aligned_buf2); i++)
            {
                *(aligned_buf_ptr2 + i) = tackle::byte(sizeof(aligned_buf1) + i + 1);
            }

            tackle::global_construct_storage<typename container_t::reverse_iterator>(aligned_buf_ptr1);
            tackle::global_construct_storage<typename container_t::reverse_iterator>(aligned_buf_ptr2);
        }

        int result = -1;
        if (!check_self_consistency || !memcmp((void *)aligned_buf_ptr1, (void *)aligned_buf_ptr2, sizeof(aligned_buf_ptr1)))
        {
            typename container_t::reverse_iterator & default_it = make_static_default<typename container_t::reverse_iterator>();
            result = !memcmp(&it, &default_it, sizeof(it)) ? 1 : 0;
        }

        if (check_self_consistency)
        {
            tackle::destruct_storage<typename container_t::reverse_iterator>(aligned_buf_ptr1);
            tackle::destruct_storage<typename container_t::reverse_iterator>(aligned_buf_ptr2);
        }

        assert(result >= 0);

        return result;
    }

    template <typename container_t>
    int is_singular_iterator(const typename container_t::const_reverse_iterator & it, bool check_self_consistency = true)
    {
        // check self consistency
        tackle::aligned_storage<sizeof(it), std::alignment_of<typename container_t::const_reverse_iterator>::value> aligned_buf1;
        tackle::aligned_storage<sizeof(it), std::alignment_of<typename container_t::const_reverse_iterator>::value> aligned_buf2;

        tackle::byte * aligned_buf_ptr1 = 0;
        tackle::byte * aligned_buf_ptr2 = 0;

        if (check_self_consistency)
        {
            aligned_buf_ptr1 = reinterpret_cast<tackle::byte *>(aligned_buf1.this_());
            aligned_buf_ptr2 = reinterpret_cast<tackle::byte *>(aligned_buf2.this_());

            for (int i = 0; i < sizeof(aligned_buf1); i++)
            {
                *(aligned_buf_ptr1 + i) = tackle::byte(i + 1);
            }
            for (int i = 0; i < sizeof(aligned_buf2); i++)
            {
                *(aligned_buf_ptr2 + i) = tackle::byte(sizeof(aligned_buf1) + i + 1);
            }

            tackle::global_construct_storage<typename container_t::const_reverse_iterator>(aligned_buf_ptr1);
            tackle::global_construct_storage<typename container_t::const_reverse_iterator>(aligned_buf_ptr2);
        }

        int result = -1;
        if (!check_self_consistency || !memcmp((void *)aligned_buf_ptr1, (void *)aligned_buf_ptr2, sizeof(aligned_buf_ptr1)))
        {
            typename container_t::const_reverse_iterator & default_it = make_static_default<typename container_t::const_reverse_iterator>();
            result = !memcmp(&it, &default_it, sizeof(it)) ? 1 : 0;
        }

        if (check_self_consistency)
        {
            tackle::destruct_storage<typename container_t::const_reverse_iterator>(aligned_buf_ptr1);
            tackle::destruct_storage<typename container_t::const_reverse_iterator>(aligned_buf_ptr2);
        }

        assert(result >= 0);

        return result;
    }

    //INFO:
    // - GNU GCC doesn't have conversion constructor for reverse_iterator.
    //

    //Reverse iterator for standard containers which implementation doesn't have implementation of reverse_iterator.
    //T - type of bidirectional iterator.
    template <typename T>
    class reverse_iterator_adaptor
    {
    public:
        typedef typename T::iterator iterator;

    protected:
        iterator it;

    public:
        reverse_iterator_adaptor()
        {
        }

        reverse_iterator_adaptor(const reverse_iterator_adaptor & it_)
        {
            it = it_.it;
        }

        explicit reverse_iterator_adaptor(const iterator & it_)
        {
            it = it_;
        }

        const reverse_iterator_adaptor & operator= (const iterator & it_)
        {
            it = it_;

            return *this;
        }

        const reverse_iterator_adaptor & operator= (const reverse_iterator_adaptor & it_)
        {
            it = it_.it;

            return *this;
        }

        iterator base() const
        {
            return it;
        }

        //prefix form
        iterator operator++ ()
        {
            return --it;
        }

        iterator operator-- ()
        {
            return ++it;
        }

        //postfix form
        iterator operator++ (int)
        {
            return it--;
        }

        iterator operator-- (int)
        {
            return it++;
        }

        bool operator== (const reverse_iterator_adaptor & it_) const
        {
            return it == it_;
        }

        bool operator!= (const reverse_iterator_adaptor & it_) const
        {
            return it != it;
        }
    };

    template <typename T>
    class const_reverse_iterator_adaptor
    {
    public:
        typedef typename T::iterator iterator;
        typedef typename T::const_iterator const_iterator;

    protected:
        const_iterator it;

    public:
        const_reverse_iterator_adaptor()
        {
        }

        explicit const_reverse_iterator_adaptor(const iterator & it_)
        {
            it = it_;
        }

        explicit const_reverse_iterator_adaptor(const const_iterator & it_)
        {
            it = it_;
        }

        explicit const_reverse_iterator_adaptor(const reverse_iterator_adaptor<T> & it_)
        {
            it = it_.it;
        }

        explicit const_reverse_iterator_adaptor(const const_reverse_iterator_adaptor & it_)
        {
            it = it_.it;
        }

        const const_reverse_iterator_adaptor & operator= (const iterator & it_)
        {
            it = it_;

            return *this;
        }

        const const_reverse_iterator_adaptor & operator= (const const_iterator & it_)
        {
            it = it_;

            return *this;
        }

        const const_reverse_iterator_adaptor & operator= (const reverse_iterator_adaptor<T> & it_)
        {
            it = it_.it;

            return *this;
        }

        const const_reverse_iterator_adaptor & operator= (const const_reverse_iterator_adaptor & it_)
        {
            it = it_.it;

            return *this;
        }

        const_iterator base() const
        {
            return it;
        }

        // prefix form
        const_iterator operator++ ()
        {
            return --it;
        }

        const_iterator operator-- ()
        {
            return ++it;
        }

        // postfix form
        const_iterator operator++ (int)
        {
            return it--;
        }

        const_iterator operator-- (int)
        {
            return it++;
        }

        bool operator== (const const_reverse_iterator_adaptor & it_) const
        {
            return it == it_;
        }

        bool operator!= (const const_reverse_iterator_adaptor & it_) const
        {
            return it != it;
        }
    };

    template <typename T>
    inline make_holder<reverse_iterator_adaptor<T> > make_reverse_iterator(const typename T::iterator & it)
    {
#if defined(unix) || defined(__unix) || defined(_XOPEN_SOURCE) || defined(_POSIX_SOURCE)
        reverse_iterator_adaptor<T> dummy(it);
        return dummy;
#else
        return reverse_iterator_adaptor<T>(it);
#endif
    }

    template <typename T>
    inline make_holder<const_reverse_iterator_adaptor<T> > make_reverse_iterator(const typename T::const_iterator & it)
    {
#if defined(unix) || defined(__unix) || defined(_XOPEN_SOURCE) || defined(_POSIX_SOURCE)
        const_reverse_iterator_adaptor<T> dummy(it);
        return dummy;
#else
        return const_reverse_iterator_adaptor<T>(it);
#endif
    }
}

namespace tackle
{
    template <int I>
    class void_type
    {
    public:
        class iterator
        {
        public:
            bool operator ==(const iterator &) const { return true; }
            bool operator !=(const iterator &) const { return true; }
            iterator operator ++() { return iterator(); }
            iterator operator --() { return iterator(); }
            iterator operator ++(int) { return iterator(); }
            iterator operator --(int) { return iterator(); }
        };

        class const_iterator
        {
        public:
            bool operator ==(const const_iterator &) const { return true; }
            bool operator !=(const const_iterator &) const { return true; }
            const_iterator operator ++() { return const_iterator(); }
            const_iterator operator --() { return const_iterator(); }
            const_iterator operator ++(int) { return const_iterator(); }
            const_iterator operator --(int) { return const_iterator(); }
        };

        class reverse_iterator
        {
        public:
            bool operator ==(const reverse_iterator &) const { return true; }
            bool operator !=(const reverse_iterator &) const { return true; }
            reverse_iterator operator ++() { return reverse_iterator(); }
            reverse_iterator operator --() { return reverse_iterator(); }
            reverse_iterator operator ++(int) { return reverse_iterator(); }
            reverse_iterator operator --(int) { return reverse_iterator(); }
            iterator base() const { return iterator(); }
        };

        class const_reverse_iterator
        {
        public:
            bool operator ==(const const_reverse_iterator &) const { return true; }
            bool operator !=(const const_reverse_iterator &) const { return true; }
            const_reverse_iterator operator ++() { return const_reverse_iterator(); }
            const_reverse_iterator operator --() { return const_reverse_iterator(); }
            const_reverse_iterator operator ++(int) { return const_reverse_iterator(); }
            const_reverse_iterator operator --(int) { return const_reverse_iterator(); }
            const_iterator base() const { return const_iterator(); }
        };

        class value_type {};

        iterator begin() { return iterator(); };
        const_iterator begin() const { return const_iterator(); };
        reverse_iterator rbegin() { return reverse_iterator(); };
        const_reverse_iterator rbegin() const { return const_reverse_iterator(); };

        iterator end() { return iterator(); };
        const_iterator end() const { return const_iterator(); };
        reverse_iterator rend() { return reverse_iterator(); };
        const_reverse_iterator rend() const { return const_reverse_iterator(); };

        iterator erase(const iterator &) { return iterator(); }
    };

    template <typename C1, typename C2 = void_type<1>, typename C3 = void_type<2>, typename C4 = void_type<3> >
    class compatible_iterator_path_node;

    template <typename C1, typename C2 = void_type<1>, typename C3 = void_type<2>, typename C4 = void_type<3> >
    class compatible_const_iterator_path_node;

    // Iterator which have method "done", instead of comparison on end iterator for
    // cases where a target iterator and the end iterator could point to different objects of
    // different standard compatible containers. Designed for up to 4 different container types.
    //
    template <typename C1, typename C2 = void_type<1>, typename C3 = void_type<2>, typename C4 = void_type<3> >
    class compatible_iterator
    {
    public:
        typedef C1 container_type1;
        typedef C2 container_type2;
        typedef C3 container_type3;
        typedef C4 container_type4;

        typedef typename C1::iterator C1_iterator;
        typedef typename C2::iterator C2_iterator;
        typedef typename C3::iterator C3_iterator;
        typedef typename C4::iterator C4_iterator;

        typedef typename C1::iterator C1_forward_iterator;
        typedef typename C2::iterator C2_forward_iterator;
        typedef typename C3::iterator C3_forward_iterator;
        typedef typename C4::iterator C4_forward_iterator;

        typedef typename C1::reverse_iterator C1_backward_iterator;
        typedef typename C2::reverse_iterator C2_backward_iterator;
        typedef typename C3::reverse_iterator C3_backward_iterator;
        typedef typename C4::reverse_iterator C4_backward_iterator;

    protected:
        enum
        {
            it_sizeof_C1 = sizeof(C1_iterator),
            it_sizeof_C2 = sizeof(C2_iterator),
            it_sizeof_C3 = sizeof(C3_iterator),
            it_sizeof_C4 = sizeof(C4_iterator),
            it_sizeof_max = tackle::int_max<it_sizeof_C1, it_sizeof_C2, it_sizeof_C3, it_sizeof_C4>::value
        };

        enum
        {
            it_alignof_C1 = std::alignment_of<C1_iterator>::value,
            it_alignof_C2 = std::alignment_of<C2_iterator>::value,
            it_alignof_C3 = std::alignment_of<C3_iterator>::value,
            it_alignof_C4 = std::alignment_of<C4_iterator>::value,
            it_alignof_max = tackle::int_max<it_alignof_C1, it_alignof_C2, it_alignof_C3, it_alignof_C4>::value
        };

        typedef aligned_storage<it_sizeof_max, it_alignof_max> aligned_storage_iterator_type;

    protected:
        aligned_storage_iterator_type   m_it_storage;   // deferred iterator
        int                             m_it_type;      // deferred iterator target type
        void *                          m_it_cont;      // deferred iterator container
        bool                            m_forward;

    protected:
        void construct_storage(const compatible_iterator & it);
        void construct_storage(const C1_iterator & it, bool as_default);
        void construct_storage(const C2_iterator & it, bool as_default);
        void construct_storage(const C3_iterator & it, bool as_default);
        void construct_storage(const C4_iterator & it, bool as_default);
        void destruct_storage();

        C1_iterator & cast_storage_to_ref0();
        C2_iterator & cast_storage_to_ref1();
        C3_iterator & cast_storage_to_ref2();
        C4_iterator & cast_storage_to_ref3();

        const C1_iterator & cast_storage_to_ref0() const;
        const C2_iterator & cast_storage_to_ref1() const;
        const C3_iterator & cast_storage_to_ref2() const;
        const C4_iterator & cast_storage_to_ref3() const;

    public:
        compatible_iterator();
        compatible_iterator(const compatible_iterator & it);
        compatible_iterator(const C1_iterator & it, C1 * it_cont);
        compatible_iterator(const C2_iterator & it, C2 * it_cont);
        compatible_iterator(const C3_iterator & it, C3 * it_cont);
        compatible_iterator(const C4_iterator & it, C4 * it_cont);
        ~compatible_iterator();

        const compatible_iterator & operator =(const compatible_iterator & it);

        bool operator ==(const compatible_iterator & it) const;
        bool operator !=(const compatible_iterator & it) const;

        int typeIndex() const;
        compatible_iterator_path_node<C1, C2, C3, C4> path_node() const;

        C1_iterator get0() const;
        C2_iterator get1() const;
        C3_iterator get2() const;
        C4_iterator get3() const;

        C1 * get_container0() const;
        C2 * get_container1() const;
        C3 * get_container2() const;
        C4 * get_container3() const;

        void start(bool forward);
        void start(bool forward, C1 * it_cont);
        void start(bool forward, C2 * it_cont);
        void start(bool forward, C3 * it_cont);
        void start(bool forward, C4 * it_cont);
        bool done(bool forward) const;
        void step(bool forward);

        compatible_iterator erase();

        bool is_forward() const;

        void set(const compatible_iterator & it);
        void set(const C1_iterator & it, C1 * it_cont);
        void set(const C2_iterator & it, C2 * it_cont);
        void set(const C3_iterator & it, C3 * it_cont);
        void set(const C4_iterator & it, C4 * it_cont);
        void set(bool forward, const compatible_iterator_path_node<C1, C2, C3, C4> & it_path_node);

        void clear();
    };

    template <typename C1, typename C2 = void_type<1>, typename C3 = void_type<2>, typename C4 = void_type<3> >
    class compatible_const_iterator
    {
        friend class compatible_iterator<C1, C2, C3, C4>;

    public:
        typedef C1 container_type1;
        typedef C2 container_type2;
        typedef C3 container_type3;
        typedef C4 container_type4;

        typedef typename C1::const_iterator C1_const_iterator;
        typedef typename C2::const_iterator C2_const_iterator;
        typedef typename C3::const_iterator C3_const_iterator;
        typedef typename C4::const_iterator C4_const_iterator;

        typedef typename C1::const_iterator C1_const_forward_iterator;
        typedef typename C2::const_iterator C2_const_forward_iterator;
        typedef typename C3::const_iterator C3_const_forward_iterator;
        typedef typename C4::const_iterator C4_const_forward_iterator;

        typedef typename C1::const_reverse_iterator C1_const_backward_iterator;
        typedef typename C2::const_reverse_iterator C2_const_backward_iterator;
        typedef typename C3::const_reverse_iterator C3_const_backward_iterator;
        typedef typename C4::const_reverse_iterator C4_const_backward_iterator;

    protected:
        enum
        {
            it_sizeof_C1 = sizeof(C1_const_iterator),
            it_sizeof_C2 = sizeof(C2_const_iterator),
            it_sizeof_C3 = sizeof(C3_const_iterator),
            it_sizeof_C4 = sizeof(C4_const_iterator),
            it_sizeof_max = tackle::int_max<it_sizeof_C1, it_sizeof_C2, it_sizeof_C3, it_sizeof_C4>::value
        };

        enum
        {
            it_alignof_C1 = std::alignment_of<C1_const_iterator>::value,
            it_alignof_C2 = std::alignment_of<C2_const_iterator>::value,
            it_alignof_C3 = std::alignment_of<C3_const_iterator>::value,
            it_alignof_C4 = std::alignment_of<C4_const_iterator>::value,
            it_alignof_max = tackle::int_max<it_alignof_C1, it_alignof_C2, it_alignof_C3, it_alignof_C4>::value
        };

        typedef aligned_storage<it_sizeof_max, it_alignof_max> aligned_storage_iterator_type;

    protected:
        aligned_storage_iterator_type   m_it_storage;  // deferred iterator
        int                             m_it_type;     // deferred iterator target type
        const void *                    m_it_cont;     // deferred iterator container
        bool                            m_forward;

    protected:
        void construct_storage(const compatible_const_iterator & it);
        void construct_storage(const compatible_iterator<C1, C2, C3, C4> & it);
        void construct_storage(const C1_const_iterator & it, bool as_default);
        void construct_storage(const C2_const_iterator & it, bool as_default);
        void construct_storage(const C3_const_iterator & it, bool as_default);
        void construct_storage(const C4_const_iterator & it, bool as_default);
        void destruct_storage();

        C1_const_iterator & cast_storage_to_ref0();
        C2_const_iterator & cast_storage_to_ref1();
        C3_const_iterator & cast_storage_to_ref2();
        C4_const_iterator & cast_storage_to_ref3();

        const C1_const_iterator & cast_storage_to_ref0() const;
        const C2_const_iterator & cast_storage_to_ref1() const;
        const C3_const_iterator & cast_storage_to_ref2() const;
        const C4_const_iterator & cast_storage_to_ref3() const;

    public:
        compatible_const_iterator();
        compatible_const_iterator(const compatible_const_iterator & it);
        compatible_const_iterator(const compatible_iterator<C1, C2, C3, C4> & it);
        compatible_const_iterator(const C1_const_iterator & it, const C1 * it_cont);
        compatible_const_iterator(const C2_const_iterator & it, const C2 * it_cont);
        compatible_const_iterator(const C3_const_iterator & it, const C3 * it_cont);
        compatible_const_iterator(const C4_const_iterator & it, const C4 * it_cont);
        ~compatible_const_iterator();

        const compatible_const_iterator & operator =(const compatible_const_iterator & it);
        const compatible_const_iterator & operator =(const compatible_iterator<C1, C2, C3, C4> & it);

        bool operator ==(const compatible_const_iterator & it) const;
        bool operator !=(const compatible_const_iterator & it) const;

        int typeIndex() const;
        compatible_const_iterator_path_node<C1, C2, C3, C4> path_node() const;

        C1_const_iterator get0() const;
        C2_const_iterator get1() const;
        C3_const_iterator get2() const;
        C4_const_iterator get3() const;

        const C1 * get_container0() const;
        const C2 * get_container1() const;
        const C3 * get_container2() const;
        const C4 * get_container3() const;

        void start(bool forward);
        void start(bool forward, const C1 * it_cont);
        void start(bool forward, const C2 * it_cont);
        void start(bool forward, const C3 * it_cont);
        void start(bool forward, const C4 * it_cont);
        bool done(bool forward) const;
        void step(bool forward);

        bool is_forward() const;

        void set(const compatible_const_iterator & it);
        void set(const compatible_iterator<C1, C2, C3, C4> & it);
        void set(const C1_const_iterator & it, const C1 * it_cont);
        void set(const C2_const_iterator & it, const C2 * it_cont);
        void set(const C3_const_iterator & it, const C3 * it_cont);
        void set(const C4_const_iterator & it, const C4 * it_cont);
        void set(bool forward, const compatible_const_iterator_path_node<C1, C2, C3, C4> & it_path_node);
        void set(bool forward, const compatible_iterator_path_node<C1, C2, C3, C4> & it_path_node);

        void clear();
    };

    template <typename C1, typename C2, typename C3, typename C4>
    class compatible_iterator_path_node
    {
    protected:
        int     m_it_type;
        void *  m_it_cont;

    public:
        compatible_iterator_path_node();
        compatible_iterator_path_node(C1 * cont_ptr);
        compatible_iterator_path_node(C2 * cont_ptr);
        compatible_iterator_path_node(C3 * cont_ptr);
        compatible_iterator_path_node(C4 * cont_ptr);

        const compatible_iterator_path_node & operator =(C1 * cont_ptr);
        const compatible_iterator_path_node & operator =(C2 * cont_ptr);
        const compatible_iterator_path_node & operator =(C3 * cont_ptr);
        const compatible_iterator_path_node & operator =(C4 * cont_ptr);

        int typeIndex() const;
        void * get() const;
        C1 * get0() const;
        C2 * get1() const;
        C3 * get2() const;
        C4 * get3() const;
    };

    template <typename C1, typename C2, typename C3, typename C4>
    class compatible_const_iterator_path_node
    {
    protected:
        int             m_it_type;
        const void *    m_it_cont;

    public:
        compatible_const_iterator_path_node();
        compatible_const_iterator_path_node(const C1 * cont_ptr);
        compatible_const_iterator_path_node(const C2 * cont_ptr);
        compatible_const_iterator_path_node(const C3 * cont_ptr);
        compatible_const_iterator_path_node(const C4 * cont_ptr);

        const compatible_const_iterator_path_node & operator =(const C1 * cont_ptr);
        const compatible_const_iterator_path_node & operator =(const C2 * cont_ptr);
        const compatible_const_iterator_path_node & operator =(const C3 * cont_ptr);
        const compatible_const_iterator_path_node & operator =(const C4 * cont_ptr);

        int typeIndex() const;
        const void * get() const;
        const C1 * get0() const;
        const C2 * get1() const;
        const C3 * get2() const;
        const C4 * get3() const;
    };

    template <typename C1, typename C2 = void_type<1>, typename C3 = void_type<2>, typename C4 = void_type<3> >
    class compatible_iterator_path
    {
    public:
        typedef compatible_iterator_path_node<C1, C2, C3, C4> path_node;

    protected:
        typedef typename std::vector<path_node> iterator_path;

    public:
        typedef typename std::vector<path_node>::size_type size_type;

    protected:
        iterator_path m_it_path;

    public:
        path_node & operator [](typename iterator_path::size_type index);
        const path_node & operator [](typename iterator_path::size_type index) const;

        void append_container(C1 * it_cont);
        void append_container(C2 * it_cont);
        void append_container(C3 * it_cont);
        void append_container(C4 * it_cont);

        typename iterator_path::size_type size() const;
        typename iterator_path::size_type capacity() const;
        void resize(typename iterator_path::size_type size);
        void reserve(typename iterator_path::size_type size);
        void clear();

        path_node & front();
        const path_node & front() const;
        path_node & back();
        const path_node & back() const;
    };

    template <typename C1, typename C2 = void_type<1>, typename C3 = void_type<2>, typename C4 = void_type<3> >
    class compatible_const_iterator_path
    {
    public:
        typedef compatible_const_iterator_path_node<C1, C2, C3, C4> path_node;

    protected:
        typedef typename std::vector<path_node> iterator_path;

    public:
        typedef typename std::vector<path_node>::size_type size_type;

    protected:
        iterator_path m_it_path;

    public:
        path_node & operator [](typename iterator_path::size_type index);
        const path_node & operator [](typename iterator_path::size_type index) const;

        void append_container(const C1 * it_cont);
        void append_container(const C2 * it_cont);
        void append_container(const C3 * it_cont);
        void append_container(const C4 * it_cont);

        typename iterator_path::size_type size() const;
        typename iterator_path::size_type capacity() const;
        void resize(typename iterator_path::size_type size);
        void reserve(typename iterator_path::size_type size);
        void clear();

        path_node & front();
        const path_node & front() const;
        path_node & back();
        const path_node & back() const;
    };

    template <typename C1, typename C2 = void_type<1>, typename C3 = void_type<2>, typename C4 = void_type<3> >
    class compatible_path_iterator
    {
    protected:
        typedef compatible_iterator<C1, C2, C3, C4> iterator;
        typedef compatible_iterator_path<C1, C2, C3, C4> iterator_path;
        typedef compatible_iterator_path_node<C1, C2, C3, C4> iterator_path_node;

    public:
        typedef typename iterator_path::size_type size_type;

    protected:
        iterator                m_it;
        const iterator_path *   m_it_path_ptr;
        size_type               m_it_path_node_index;
        bool                    m_forward;

    public:
        compatible_path_iterator();

        const iterator & get() const;

        void start(bool forward);
        bool done(bool forward) const;
        void step(bool forward);
        void step();
        bool is_forward() const;

        void seek_begin_path_node(bool forward);
        void seek_end_path_node(bool forward);

        void set(bool forward, const iterator_path & it_path);
        void clear();
    };

    template <typename C1, typename C2 = void_type<1>, typename C3 = void_type<2>, typename C4 = void_type<3> >
    class compatible_path_const_iterator
    {
    protected:
        typedef compatible_const_iterator<C1, C2, C3, C4> iterator;
        typedef compatible_const_iterator_path<C1, C2, C3, C4> iterator_path;
        typedef compatible_const_iterator_path_node<C1, C2, C3, C4> iterator_path_node;

    public:
        typedef typename iterator_path::size_type size_type;

    protected:
        iterator                m_it;
        const iterator_path *   m_it_path_ptr;
        size_type               m_it_path_node_index;
        bool                    m_forward;

    public:
        compatible_path_const_iterator();

        const iterator & get() const;

        void start(bool forward);
        bool done(bool forward) const;
        void step(bool forward);
        bool is_forward() const;

        void seek_begin_path_node(bool forward);
        void seek_end_path_node(bool forward);

        void set(bool forward, const iterator_path & it_path);
        void clear();
    };

    //-------------------------------------------------------------------------

    // compatible_iterator
    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_iterator<C1, C2, C3, C4>::construct_storage(const compatible_iterator & it)
    {
        switch (it.m_it_type)
        {
        case 0:
        {
            return construct_storage(it.cast_storage_to_ref0(), false);
        }
        break;

        case 1:
        {
            return construct_storage(it.cast_storage_to_ref1(), false);
        }
        break;

        case 2:
        {
            return construct_storage(it.cast_storage_to_ref2(), false);
        }
        break;

        case 3:
        {
            return construct_storage(it.cast_storage_to_ref3(), false);
        }
        break;

        default:
            assert(0);
        }
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_iterator<C1, C2, C3, C4>::construct_storage(const typename C1::iterator & it, bool as_default)
    {
        if (as_default)
        {
            tackle::global_construct_storage<typename C1::iterator>(m_it_storage.this_());
        }
        else
        {
            tackle::global_construct_storage<typename C1::iterator>(m_it_storage.this_(), it);
        }
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_iterator<C1, C2, C3, C4>::construct_storage(const typename C2::iterator & it, bool as_default)
    {
        if (as_default)
        {
            tackle::global_construct_storage<typename C2::iterator>(m_it_storage.this_());
        }
        else
        {
            tackle::global_construct_storage<typename C2::iterator>(m_it_storage.this_(), it);
        }
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_iterator<C1, C2, C3, C4>::construct_storage(const typename C3::iterator & it, bool as_default)
    {
        if (as_default)
        {
            tackle::global_construct_storage<typename C3::iterator>(m_it_storage.this_());
        }
        else
        {
            tackle::global_construct_storage<typename C3::iterator>(m_it_storage.this_(), it);
        }
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_iterator<C1, C2, C3, C4>::construct_storage(const typename C4::iterator & it, bool as_default)
    {
        if (as_default)
        {
            tackle::global_construct_storage<typename C4::iterator>(m_it_storage.this_());
        }
        else
        {
            tackle::global_construct_storage<typename C4::iterator>(m_it_storage.this_(), it);
        }
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_iterator<C1, C2, C3, C4>::destruct_storage()
    {
        switch (m_it_type)
        {
        case 0:
        {
            tackle::destruct_storage<typename C1::iterator>(m_it_storage.this_());
        }
        break;

        case 1:
        {
            tackle::destruct_storage<typename C2::iterator>(m_it_storage.this_());
        }
        break;

        case 2:
        {
            tackle::destruct_storage<typename C3::iterator>(m_it_storage.this_());
        }
        break;

        case 3:
        {
            tackle::destruct_storage<typename C4::iterator>(m_it_storage.this_());
        }
        break;

        default:
            assert(0);
        }
    }

    template <typename C1, typename C2, typename C3, typename C4>
    typename C1::iterator & compatible_iterator<C1, C2, C3, C4>::cast_storage_to_ref0()
    {
        return *reinterpret_cast<typename C1::iterator *>(m_it_storage.this_());
    }

    template <typename C1, typename C2, typename C3, typename C4>
    typename C2::iterator & compatible_iterator<C1, C2, C3, C4>::cast_storage_to_ref1()
    {
        return *reinterpret_cast<typename C2::iterator *>(m_it_storage.this_());
    }

    template <typename C1, typename C2, typename C3, typename C4>
    typename C3::iterator & compatible_iterator<C1, C2, C3, C4>::cast_storage_to_ref2()
    {
        return *reinterpret_cast<typename C3::iterator *>(m_it_storage.this_());
    }

    template <typename C1, typename C2, typename C3, typename C4>
    typename C4::iterator & compatible_iterator<C1, C2, C3, C4>::cast_storage_to_ref3()
    {
        return *reinterpret_cast<typename C4::iterator *>(m_it_storage.this_());
    }

    template <typename C1, typename C2, typename C3, typename C4>
    const typename C1::iterator & compatible_iterator<C1, C2, C3, C4>::cast_storage_to_ref0() const
    {
        return *reinterpret_cast<const typename C1::iterator *>(m_it_storage.this_());
    }

    template <typename C1, typename C2, typename C3, typename C4>
    const typename C2::iterator & compatible_iterator<C1, C2, C3, C4>::cast_storage_to_ref1() const
    {
        return *reinterpret_cast<const typename C2::iterator *>(m_it_storage.this_());
    }

    template <typename C1, typename C2, typename C3, typename C4>
    const typename C3::iterator & compatible_iterator<C1, C2, C3, C4>::cast_storage_to_ref2() const
    {
        return *reinterpret_cast<const typename C3::iterator *>(m_it_storage.this_());
    }

    template <typename C1, typename C2, typename C3, typename C4>
    const typename C4::iterator & compatible_iterator<C1, C2, C3, C4>::cast_storage_to_ref3() const
    {
        return *reinterpret_cast<const typename C4::iterator *>(m_it_storage.this_());
    }

    template <typename C1, typename C2, typename C3, typename C4>
    compatible_iterator<C1, C2, C3, C4>::compatible_iterator() :
        m_it_type(-1),
        m_it_cont(0),
        m_forward(true)
    {
    }

    template <typename C1, typename C2, typename C3, typename C4>
    compatible_iterator<C1, C2, C3, C4>::compatible_iterator(const compatible_iterator & it) :
        m_it_type(-1),
        m_it_cont(0),
        m_forward(true)
    {
        set(it);
    }

    template <typename C1, typename C2, typename C3, typename C4>
    compatible_iterator<C1, C2, C3, C4>::compatible_iterator(const typename C1::iterator & it, C1 * it_cont) :
        m_it_type(-1),
        m_it_cont(0),
        m_forward(true)
    {
        set(it, it_cont);
    }

    template <typename C1, typename C2, typename C3, typename C4>
    compatible_iterator<C1, C2, C3, C4>::compatible_iterator(const typename C2::iterator & it, C2 * it_cont) :
        m_it_type(-1),
        m_it_cont(0),
        m_forward(true)
    {
        set(it, it_cont);
    }

    template <typename C1, typename C2, typename C3, typename C4>
    compatible_iterator<C1, C2, C3, C4>::compatible_iterator(const typename C3::iterator & it, C3 * it_cont) :
        m_it_type(-1),
        m_it_cont(0),
        m_forward(true)
    {
        set(it, it_cont);
    }

    template <typename C1, typename C2, typename C3, typename C4>
    compatible_iterator<C1, C2, C3, C4>::compatible_iterator(const typename C4::iterator & it, C4 * it_cont) :
        m_it_type(-1),
        m_it_cont(0),
        m_forward(true)
    {
        set(it, it_cont);
    }

    template <typename C1, typename C2, typename C3, typename C4>
    compatible_iterator<C1, C2, C3, C4>::~compatible_iterator()
    {
        if (m_it_type != -1)
        {
            destruct_storage();
            m_it_type = -1;
            m_it_cont = 0;
        }
    }

    template <typename C1, typename C2, typename C3, typename C4>
    const compatible_iterator<C1, C2, C3, C4> & compatible_iterator<C1, C2, C3, C4>::operator =(const compatible_iterator & it)
    {
        set(it);

        return *this;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    bool compatible_iterator<C1, C2, C3, C4>::operator ==(const compatible_iterator & it) const
    {
        assert(m_it_cont && it.m_it_cont); //Should be initialized before!

        if (m_it_type != it.m_it_type)
        {
            return false;
        }

        switch (m_it_type)
        {
        case 0:
        {
            return get0() == it.get0();
        }
        break;

        case 1:
        {
            return get1() == it.get1();
        }
        break;

        case 2:
        {
            return get2() == it.get2();
        }
        break;

        case 3:
        {
            return get3() == it.get3();
        }
        break;
        }

        assert(0);

        return false;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    bool compatible_iterator<C1, C2, C3, C4>::operator !=(const compatible_iterator & it) const
    {
        assert(m_it_cont && it.m_it_cont); //Should be initialized before!

        if (m_it_type != it.m_it_type)
        {
            return true;
        }

        switch (m_it_type)
        {
        case 0:
        {
            return get0() != it.get0();
        }
        break;

        case 1:
        {
            return get1() != it.get1();
        }
        break;

        case 2:
        {
            return get2() != it.get2();
        }
        break;

        case 3:
        {
            return get3() != it.get3();
        }
        break;
        }

        assert(0);

        return false;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    int compatible_iterator<C1, C2, C3, C4>::typeIndex() const
    {
        return m_it_type;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    compatible_iterator_path_node<C1, C2, C3, C4> compatible_iterator<C1, C2, C3, C4>::path_node() const
    {
        switch (m_it_type)
        {
        case 0:
        {
            return compatible_iterator_path_node<C1, C2, C3, C4>(get_container0());
        }
        break;

        case 1:
        {
            return compatible_iterator_path_node<C1, C2, C3, C4>(get_container1());
        }
        break;

        case 2:
        {
            return compatible_iterator_path_node<C1, C2, C3, C4>(get_container2());
        }
        break;

        case 3:
        {
            return compatible_iterator_path_node<C1, C2, C3, C4>(get_container3());
        }
        break;
        }

        assert(0);

        return compatible_iterator_path_node<C1, C2, C3, C4>();
    }

    template <typename C1, typename C2, typename C3, typename C4>
    typename C1::iterator compatible_iterator<C1, C2, C3, C4>::get0() const
    {
        assert(m_it_type == 0);

        if (m_forward)
        {
            return cast_storage_to_ref0();
        }

        tackle::reverse_iterator_adaptor<C1> rit((tackle::make_reverse_iterator<C1>(cast_storage_to_ref0())));
        rit++;

        return rit.base();
    }

    template <typename C1, typename C2, typename C3, typename C4>
    typename C2::iterator compatible_iterator<C1, C2, C3, C4>::get1() const
    {
        assert(m_it_type == 1);

        if (m_forward)
        {
            return cast_storage_to_ref1();
        }

        tackle::reverse_iterator_adaptor<C2> rit((tackle::make_reverse_iterator<C2>(cast_storage_to_ref1())));
        rit++;

        return rit.base();
    }

    template <typename C1, typename C2, typename C3, typename C4>
    typename C3::iterator compatible_iterator<C1, C2, C3, C4>::get2() const
    {
        assert(m_it_type == 2);

        if (m_forward)
        {
            return cast_storage_to_ref2();
        }

        tackle::reverse_iterator_adaptor<C3> rit((tackle::make_reverse_iterator<C3>(cast_storage_to_ref2())));
        rit++;

        return rit.base();
    }

    template <typename C1, typename C2, typename C3, typename C4>
    typename C4::iterator compatible_iterator<C1, C2, C3, C4>::get3() const
    {
        assert(m_it_type == 3);

        if (m_forward)
        {
            return cast_storage_to_ref3();
        }

        tackle::reverse_iterator_adaptor<C4> rit((tackle::make_reverse_iterator<C4>(cast_storage_to_ref3())));
        rit++;

        return rit.base();
    }

    template <typename C1, typename C2, typename C3, typename C4>
    C1 * compatible_iterator<C1, C2, C3, C4>::get_container0() const
    {
        return reinterpret_cast<C1 *>(m_it_cont);
    }

    template <typename C1, typename C2, typename C3, typename C4>
    C2 * compatible_iterator<C1, C2, C3, C4>::get_container1() const
    {
        return reinterpret_cast<C2 *>(m_it_cont);
    }

    template <typename C1, typename C2, typename C3, typename C4>
    C3 * compatible_iterator<C1, C2, C3, C4>::get_container2() const
    {
        return reinterpret_cast<C3 *>(m_it_cont);
    }

    template <typename C1, typename C2, typename C3, typename C4>
    C4 * compatible_iterator<C1, C2, C3, C4>::get_container3() const
    {
        return reinterpret_cast<C4 *>(m_it_cont);
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_iterator<C1, C2, C3, C4>::start(bool forward)
    {
        switch (m_it_type)
        {
        case 0:
        {
            if (forward)
            {
                C1 * cont_ptr = get_container0();
                set(cont_ptr->begin(), cont_ptr);
            }
            else
            {
                C1 * cont_ptr = get_container0();
                set(cont_ptr->rbegin().base(), cont_ptr);
            }
            m_forward = forward;
        }
        break;

        case 1:
        {
            if (forward)
            {
                C2 * cont_ptr = get_container1();
                set(cont_ptr->begin(), cont_ptr);
            }
            else
            {
                C2 * cont_ptr = get_container1();
                set(cont_ptr->rbegin().base(), cont_ptr);
            }
            m_forward = forward;
        }
        break;

        case 2:
        {
            if (forward)
            {
                C3 * cont_ptr = get_container2();
                set(cont_ptr->begin(), cont_ptr);
            }
            else
            {
                C3 * cont_ptr = get_container2();
                set(cont_ptr->rbegin().base(), cont_ptr);
            }
            m_forward = forward;
        }
        break;

        case 3:
        {
            if (forward)
            {
                C4 * cont_ptr = get_container3();
                set(cont_ptr->begin(), cont_ptr);
            }
            else
            {
                C4 * cont_ptr = get_container3();
                set(cont_ptr->rbegin().base(), cont_ptr);
            }
            m_forward = forward;
        }
        break;

        default:
            assert(0);
        }
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_iterator<C1, C2, C3, C4>::start(bool forward, C1 * cont_ptr)
    {
        if (!cont_ptr)
        {
            return start(forward);
        }

        if (forward)
        {
            set(cont_ptr->begin(), cont_ptr);
        }
        else
        {
            set(cont_ptr->rbegin().base(), cont_ptr);
        }
        m_forward = forward;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_iterator<C1, C2, C3, C4>::start(bool forward, C2 * cont_ptr)
    {
        if (!cont_ptr)
        {
            return start(forward);
        }

        if (forward)
        {
            set(cont_ptr->begin(), cont_ptr);
        }
        else
        {
            set(cont_ptr->rbegin().base(), cont_ptr);
        }
        m_forward = forward;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_iterator<C1, C2, C3, C4>::start(bool forward, C3 * cont_ptr)
    {
        if (!cont_ptr)
        {
            return start(forward);
        }

        if (forward)
        {
            set(cont_ptr->begin(), cont_ptr);
        }
        else
        {
            set(cont_ptr->rbegin().base(), cont_ptr);
        }
        m_forward = forward;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_iterator<C1, C2, C3, C4>::start(bool forward, C4 * cont_ptr)
    {
        if (!cont_ptr)
        {
            return start(forward);
        }

        if (forward)
        {
            set(cont_ptr->begin(), cont_ptr);
        }
        else
        {
            set(cont_ptr->rbegin().base(), cont_ptr);
        }
        m_forward = forward;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    bool compatible_iterator<C1, C2, C3, C4>::done(bool forward) const
    {
        switch (m_it_type)
        {
        case 0:
        {
            assert(m_it_cont);
#ifndef DISABLE_ITERATOR_SINGULARITY_CHECK
            assert(!tackle::is_singular_iterator<C1>(cast_storage_to_ref0()));
#endif

            if (forward)
            {
                return cast_storage_to_ref0() == get_container0()->end();
            }
            else
            {
                return cast_storage_to_ref0() == get_container0()->rend().base();
            }
        }
        break;

        case 1:
        {
            assert(m_it_cont);
#ifndef DISABLE_ITERATOR_SINGULARITY_CHECK
            assert(!tackle::is_singular_iterator<C2>(cast_storage_to_ref1()));
#endif

            if (forward)
            {
                return cast_storage_to_ref1() == get_container1()->end();
            }
            else
            {
                return cast_storage_to_ref1() == get_container1()->rend().base();
            }
        }
        break;

        case 2:
        {
            assert(m_it_cont);
#ifndef DISABLE_ITERATOR_SINGULARITY_CHECK
            assert(!tackle::is_singular_iterator<C3>(cast_storage_to_ref2()));
#endif

            if (forward)
            {
                return cast_storage_to_ref2() == get_container2()->end();
            }
            else
            {
                return cast_storage_to_ref2() == get_container2()->rend().base();
            }
        }
        break;

        case 3:
        {
            assert(m_it_cont);
#ifndef DISABLE_ITERATOR_SINGULARITY_CHECK
            assert(!tackle::is_singular_iterator<C4>(cast_storage_to_ref3()));
#endif

            if (forward)
            {
                return cast_storage_to_ref3() == get_container3()->end();
            }
            else
            {
                return cast_storage_to_ref3() == get_container3()->rend().base();
            }
        }
        break;

        default:
            assert(0);
        }

        return true;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_iterator<C1, C2, C3, C4>::step(bool forward)
    {
        switch (m_it_type)
        {
        case 0:
        {
            assert(m_it_cont);
#ifndef DISABLE_ITERATOR_SINGULARITY_CHECK
            assert(!tackle::is_singular_iterator<C1>(cast_storage_to_ref0()));
#endif

            if (forward)
            {
                ++cast_storage_to_ref0();
            }
            else
            {
                --cast_storage_to_ref0();
            }
        }
        break;

        case 1:
        {
            assert(m_it_cont);
#ifndef DISABLE_ITERATOR_SINGULARITY_CHECK
            assert(!tackle::is_singular_iterator<C2>(cast_storage_to_ref1()));
#endif

            if (forward)
            {
                ++cast_storage_to_ref1();
            }
            else
            {
                --cast_storage_to_ref1();
            }
        }
        break;

        case 2:
        {
            assert(m_it_cont);
#ifndef DISABLE_ITERATOR_SINGULARITY_CHECK
            assert(!tackle::is_singular_iterator<C3>(cast_storage_to_ref2()));
#endif

            if (forward)
            {
                ++cast_storage_to_ref2();
            }
            else
            {
                --cast_storage_to_ref2();
            }
        }
        break;

        case 3:
        {
            assert(m_it_cont);
#ifndef DISABLE_ITERATOR_SINGULARITY_CHECK
            assert(!tackle::is_singular_iterator<C4>(cast_storage_to_ref3()));
#endif

            if (forward)
            {
                ++cast_storage_to_ref3();
            }
            else
            {
                --cast_storage_to_ref3();
            }
        }
        break;

        default:
            assert(0);
        }
    }

    template <typename C1, typename C2, typename C3, typename C4>
    compatible_iterator<C1, C2, C3, C4> compatible_iterator<C1, C2, C3, C4>::erase()
    {
        compatible_iterator next_it;

        switch (m_it_type)
        {
        case 0:
        {
            assert(m_it_cont);
#ifndef DISABLE_ITERATOR_SINGULARITY_CHECK
            assert(!tackle::is_singular_iterator<C1>(cast_storage_to_ref0()));
#endif

            C1 * cont_ptr = get_container0();
            next_it.set(cont_ptr->erase(get0()), cont_ptr);
        }
        break;

        case 1:
        {
            assert(m_it_cont);
#ifndef DISABLE_ITERATOR_SINGULARITY_CHECK
            assert(!tackle::is_singular_iterator<C2>(cast_storage_to_ref1()));
#endif

            C2 * cont_ptr = get_container1();
            next_it.set(cont_ptr->erase(get1()), cont_ptr);
        }
        break;

        case 2:
        {
            assert(m_it_cont);
#ifndef DISABLE_ITERATOR_SINGULARITY_CHECK
            assert(!tackle::is_singular_iterator<C3>(cast_storage_to_ref2()));
#endif

            C3 * cont_ptr = get_container2();
            next_it.set(cont_ptr->erase(get2()), cont_ptr);
        }
        break;

        case 3:
        {
            assert(m_it_cont);
#ifndef DISABLE_ITERATOR_SINGULARITY_CHECK
            assert(!tackle::is_singular_iterator<C4>(cast_storage_to_ref3()));
#endif

            C4 * cont_ptr = get_container3();
            next_it.set(cont_ptr->erase(get3()), cont_ptr);
        }
        break;

        default:
            assert(0);
        }

        return next_it;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    bool compatible_iterator<C1, C2, C3, C4>::is_forward() const
    {
        return m_forward;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_iterator<C1, C2, C3, C4>::set(const compatible_iterator & it)
    {
        switch (it.m_it_type)
        {
        case 0:
        {
            set(it.cast_storage_to_ref0(), reinterpret_cast<C1 *>(it.m_it_cont));
            m_forward = it.m_forward;
        }
        break;

        case 1:
        {
            set(it.cast_storage_to_ref1(), reinterpret_cast<C2 *>(it.m_it_cont));
            m_forward = it.m_forward;
        }
        break;

        case 2:
        {
            set(it.cast_storage_to_ref2(), reinterpret_cast<C3 *>(it.m_it_cont));
            m_forward = it.m_forward;
        }
        break;

        case 3:
        {
            set(it.cast_storage_to_ref3(), reinterpret_cast<C4 *>(it.m_it_cont));
            m_forward = it.m_forward;
        }
        break;

        default:
            assert(0);
        }
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_iterator<C1, C2, C3, C4>::set(const typename C1::iterator & it, C1 * it_cont)
    {
        assert(it_cont);
#ifndef DISABLE_ITERATOR_SINGULARITY_CHECK
        if (!tackle::is_singular_iterator<C1>(it))
        {
            (void)(it == it_cont->end()); // force check iterators compatibility
        }
#endif

        if (m_it_type == 0)
        {
            cast_storage_to_ref0() = it;
        }
        else
        {
            if (m_it_type != -1)
            {
                destruct_storage();
            }
            construct_storage(it, false);
            m_it_type = 0;
        }

        m_it_cont = it_cont;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_iterator<C1, C2, C3, C4>::set(const typename C2::iterator & it, C2 * it_cont)
    {
        assert(it_cont);
#ifndef DISABLE_ITERATOR_SINGULARITY_CHECK
        if (!tackle::is_singular_iterator<C2>(it))
        {
            (void)(it == it_cont->end()); // force check iterators compatibility
        }
#endif

        if (m_it_type == 1)
        {
            cast_storage_to_ref1() = it;
        }
        else
        {
            if (m_it_type != -1)
            {
                destruct_storage();
            }
            construct_storage(it, false);
            m_it_type = 1;
        }

        m_it_cont = it_cont;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_iterator<C1, C2, C3, C4>::set(const typename C3::iterator & it, C3 * it_cont)
    {
        assert(it_cont);
#ifndef DISABLE_ITERATOR_SINGULARITY_CHECK
        if (!tackle::is_singular_iterator<C3>(it))
        {
            (void)(it == it_cont->end()); // force check iterators compatibility
        }
#endif

        if (m_it_type == 2)
        {
            cast_storage_to_ref2() = it;
        }
        else
        {
            if (m_it_type != -1)
            {
                destruct_storage();
            }
            construct_storage(it, false);
            m_it_type = 2;
        }

        m_it_cont = it_cont;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_iterator<C1, C2, C3, C4>::set(const typename C4::iterator & it, C4 * it_cont)
    {
        assert(it_cont);
#ifndef DISABLE_ITERATOR_SINGULARITY_CHECK
        if (!tackle::is_singular_iterator<C4>(it))
        {
            (void)(it == it_cont->end()); // force check iterators compatibility
        }
#endif

        if (m_it_type == 3)
        {
            cast_storage_to_ref3() = it;
        }
        else
        {
            if (m_it_type != -1)
            {
                destruct_storage();
            }
            construct_storage(it, false);
            m_it_type = 3;
        }

        m_it_cont = it_cont;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_iterator<C1, C2, C3, C4>::set(bool forward, const compatible_iterator_path_node<C1, C2, C3, C4> & it_path_node)
    {
        if (it_path_node.typeIndex() == -1 || !it_path_node.get())
        {
            assert(0);
            clear();
            return;
        }

        switch (it_path_node.typeIndex())
        {
        case 0:
        {
            C1 * cont_ptr = reinterpret_cast<C1 *>(it_path_node.get());
            start(forward, cont_ptr);
        }
        break;

        case 1:
        {
            C2 * cont_ptr = reinterpret_cast<C2 *>(it_path_node.get());
            start(forward, cont_ptr);
        }
        break;

        case 2:
        {
            C3 * cont_ptr = reinterpret_cast<C3 *>(it_path_node.get());
            start(forward, cont_ptr);
        }
        break;

        case 3:
        {
            C4 * cont_ptr = reinterpret_cast<C4 *>(it_path_node.get());
            start(forward, cont_ptr);
        }
        break;

        default:
            assert(0);
            clear();
        }
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_iterator<C1, C2, C3, C4>::clear()
    {
        if (m_it_type != -1)
        {
            destruct_storage();
            m_it_type = -1;
        }
        m_it_cont = 0;
        m_forward = true;
    }

    // compatible_const_iterator
    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_const_iterator<C1, C2, C3, C4>::construct_storage(const compatible_const_iterator & it)
    {
        switch (it.m_it_type)
        {
        case 0:
        {
            return construct_storage(it.cast_storage_to_ref0(), false);
        }
        break;

        case 1:
        {
            return construct_storage(it.cast_storage_to_ref1(), false);
        }
        break;

        case 2:
        {
            return construct_storage(it.cast_storage_to_ref2(), false);
        }
        break;

        case 3:
        {
            return construct_storage(it.cast_storage_to_ref3(), false);
        }
        break;

        default:
            assert(0);
        }
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_const_iterator<C1, C2, C3, C4>::construct_storage(const compatible_iterator<C1, C2, C3, C4> & it)
    {
        switch (it.m_it_type)
        {
        case 0:
        {
            return construct_storage(it.cast_storage_to_ref0(), false);
        }
        break;

        case 1:
        {
            return construct_storage(it.cast_storage_to_ref1(), false);
        }
        break;

        case 2:
        {
            return construct_storage(it.cast_storage_to_ref2(), false);
        }
        break;

        case 3:
        {
            return construct_storage(it.cast_storage_to_ref3(), false);
        }
        break;

        default:
            assert(0);
        }
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_const_iterator<C1, C2, C3, C4>::construct_storage(const typename C1::const_iterator & it, bool as_default)
    {
        if (as_default)
        {
            tackle::global_construct_storage<typename C1::const_iterator>(m_it_storage.this_());
        }
        else
        {
            tackle::global_construct_storage<typename C1::const_iterator>(m_it_storage.this_(), it);
        }
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_const_iterator<C1, C2, C3, C4>::construct_storage(const typename C2::const_iterator & it, bool as_default)
    {
        if (as_default)
        {
            tackle::global_construct_storage<typename C2::const_iterator>(m_it_storage.this_());
        }
        else
        {
            tackle::global_construct_storage<typename C2::const_iterator>(m_it_storage.this_(), it);
        }
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_const_iterator<C1, C2, C3, C4>::construct_storage(const typename C3::const_iterator & it, bool as_default)
    {
        if (as_default)
        {
            tackle::global_construct_storage<typename C3::const_iterator>(m_it_storage.this_());
        }
        else
        {
            tackle::global_construct_storage<typename C3::const_iterator>(m_it_storage.this_(), it);
        }
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_const_iterator<C1, C2, C3, C4>::construct_storage(const typename C4::const_iterator & it, bool as_default)
    {
        if (as_default)
        {
            tackle::global_construct_storage<typename C4::const_iterator>(m_it_storage.this_());
        }
        else
        {
            tackle::global_construct_storage<typename C4::const_iterator>(m_it_storage.this_(), it);
        }
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_const_iterator<C1, C2, C3, C4>::destruct_storage()
    {
        switch (m_it_type)
        {
        case 0:
        {
            tackle::destruct_storage<typename C1::const_iterator>(m_it_storage.this_());
        }
        break;

        case 1:
        {
            tackle::destruct_storage<typename C2::const_iterator>(m_it_storage.this_());
        }
        break;

        case 2:
        {
            tackle::destruct_storage<typename C3::const_iterator>(m_it_storage.this_());
        }
        break;

        case 3:
        {
            tackle::destruct_storage<typename C4::const_iterator>(m_it_storage.this_());
        }
        break;

        default:
            assert(0);
        }
    }

    template <typename C1, typename C2, typename C3, typename C4>
    typename C1::const_iterator & compatible_const_iterator<C1, C2, C3, C4>::cast_storage_to_ref0()
    {
        return *reinterpret_cast<typename C1::const_iterator *>(m_it_storage.this_());
    }

    template <typename C1, typename C2, typename C3, typename C4>
    typename C2::const_iterator & compatible_const_iterator<C1, C2, C3, C4>::cast_storage_to_ref1()
    {
        return *reinterpret_cast<typename C2::const_iterator *>(m_it_storage.this_());
    }

    template <typename C1, typename C2, typename C3, typename C4>
    typename C3::const_iterator & compatible_const_iterator<C1, C2, C3, C4>::cast_storage_to_ref2()
    {
        return *reinterpret_cast<typename C3::const_iterator *>(m_it_storage.this_());
    }

    template <typename C1, typename C2, typename C3, typename C4>
    typename C4::const_iterator & compatible_const_iterator<C1, C2, C3, C4>::cast_storage_to_ref3()
    {
        return *reinterpret_cast<typename C4::const_iterator *>(m_it_storage.this_());
    }

    template <typename C1, typename C2, typename C3, typename C4>
    const typename C1::const_iterator & compatible_const_iterator<C1, C2, C3, C4>::cast_storage_to_ref0() const
    {
        return *reinterpret_cast<const typename C1::const_iterator *>(m_it_storage.this_());
    }

    template <typename C1, typename C2, typename C3, typename C4>
    const typename C2::const_iterator & compatible_const_iterator<C1, C2, C3, C4>::cast_storage_to_ref1() const
    {
        return *reinterpret_cast<const typename C2::const_iterator *>(m_it_storage.this_());
    }

    template <typename C1, typename C2, typename C3, typename C4>
    const typename C3::const_iterator & compatible_const_iterator<C1, C2, C3, C4>::cast_storage_to_ref2() const
    {
        return *reinterpret_cast<const typename C3::const_iterator *>(m_it_storage.this_());
    }

    template <typename C1, typename C2, typename C3, typename C4>
    const typename C4::const_iterator & compatible_const_iterator<C1, C2, C3, C4>::cast_storage_to_ref3() const
    {
        return *reinterpret_cast<const typename C4::const_iterator *>(m_it_storage.this_());
    }

    template <typename C1, typename C2, typename C3, typename C4>
    compatible_const_iterator<C1, C2, C3, C4>::compatible_const_iterator() :
        m_it_type(-1),
        m_it_cont(0),
        m_forward(true)
    {
    }

    template <typename C1, typename C2, typename C3, typename C4>
    compatible_const_iterator<C1, C2, C3, C4>::compatible_const_iterator(const compatible_const_iterator & it) :
        m_it_type(-1),
        m_it_cont(0),
        m_forward(true)
    {
        set(it);
    }

    template <typename C1, typename C2, typename C3, typename C4>
    compatible_const_iterator<C1, C2, C3, C4>::compatible_const_iterator(const compatible_iterator<C1, C2, C3, C4> & it) :
        m_it_type(-1),
        m_it_cont(0),
        m_forward(true)
    {
        set(it);
    }

    template <typename C1, typename C2, typename C3, typename C4>
    compatible_const_iterator<C1, C2, C3, C4>::compatible_const_iterator(const typename C1::const_iterator & it, const C1 * it_cont) :
        m_it_type(-1),
        m_it_cont(0),
        m_forward(true)
    {
        set(it, it_cont);
    }

    template <typename C1, typename C2, typename C3, typename C4>
    compatible_const_iterator<C1, C2, C3, C4>::compatible_const_iterator(const typename C2::const_iterator & it, const C2 * it_cont) :
        m_it_type(-1),
        m_it_cont(0),
        m_forward(true)
    {
        set(it, it_cont);
    }

    template <typename C1, typename C2, typename C3, typename C4>
    compatible_const_iterator<C1, C2, C3, C4>::compatible_const_iterator(const typename C3::const_iterator & it, const C3 * it_cont) :
        m_it_type(-1),
        m_it_cont(0),
        m_forward(true)
    {
        set(it, it_cont);
    }

    template <typename C1, typename C2, typename C3, typename C4>
    compatible_const_iterator<C1, C2, C3, C4>::compatible_const_iterator(const typename C4::const_iterator & it, const C4 * it_cont) :
        m_it_type(-1),
        m_it_cont(0),
        m_forward(true)
    {
        set(it, it_cont);
    }

    template <typename C1, typename C2, typename C3, typename C4>
    compatible_const_iterator<C1, C2, C3, C4>::~compatible_const_iterator()
    {
        if (m_it_type != -1)
        {
            destruct_storage();
            m_it_type = -1;
            m_it_cont = 0;
        }
    }

    template <typename C1, typename C2, typename C3, typename C4>
    const compatible_const_iterator<C1, C2, C3, C4> & compatible_const_iterator<C1, C2, C3, C4>::operator =(const compatible_const_iterator & it)
    {
        set(it);

        return *this;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    const compatible_const_iterator<C1, C2, C3, C4> & compatible_const_iterator<C1, C2, C3, C4>::operator =(const compatible_iterator<C1, C2, C3, C4> & it)
    {
        set(it);

        return *this;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    bool compatible_const_iterator<C1, C2, C3, C4>::operator ==(const compatible_const_iterator & it) const
    {
        assert(m_it_cont && it.m_it_cont); // should be initialized before!

        if (m_it_type != it.m_it_type)
        {
            return false;
        }

        switch (m_it_type)
        {
        case 0:
        {
            return get0() == it.get0();
        }
        break;

        case 1:
        {
            return get1() == it.get1();
        }
        break;

        case 2:
        {
            return get2() == it.get2();
        }
        break;

        case 3:
        {
            return get3() == it.get3();
        }
        break;
        }

        assert(0);

        return false;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    bool compatible_const_iterator<C1, C2, C3, C4>::operator !=(const compatible_const_iterator & it) const
    {
        assert(m_it_cont && it.m_it_cont); // should be initialized before!

        if (m_it_type != it.m_it_type)
        {
            return true;
        }

        switch (m_it_type)
        {
        case 0:
        {
            return get0() != it.get0();
        }
        break;

        case 1:
        {
            return get1() != it.get1();
        }
        break;

        case 2:
        {
            return get2() != it.get2();
        }
        break;

        case 3:
        {
            return get3() != it.get3();
        }
        break;
        }

        assert(0);

        return false;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    int compatible_const_iterator<C1, C2, C3, C4>::typeIndex() const
    {
        return m_it_type;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    compatible_const_iterator_path_node<C1, C2, C3, C4> compatible_const_iterator<C1, C2, C3, C4>::path_node() const
    {
        switch (m_it_type)
        {
        case 0:
        {
            return compatible_const_iterator_path_node<C1, C2, C3, C4>(get_container0());
        }
        break;

        case 1:
        {
            return compatible_const_iterator_path_node<C1, C2, C3, C4>(get_container1());
        }
        break;

        case 2:
        {
            return compatible_const_iterator_path_node<C1, C2, C3, C4>(get_container2());
        }
        break;

        case 3:
        {
            return compatible_const_iterator_path_node<C1, C2, C3, C4>(get_container3());
        }
        break;
        }

        assert(0);

        return compatible_const_iterator_path_node<C1, C2, C3, C4>();
    }

    template <typename C1, typename C2, typename C3, typename C4>
    typename C1::const_iterator compatible_const_iterator<C1, C2, C3, C4>::get0() const
    {
        assert(m_it_type == 0);

        if (m_forward)
        {
            return cast_storage_to_ref0();
        }

        tackle::const_reverse_iterator_adaptor<C1> rit((tackle::make_reverse_iterator<C1>(cast_storage_to_ref0())));
        rit++;

        return rit.base();
    }

    template <typename C1, typename C2, typename C3, typename C4>
    typename C2::const_iterator compatible_const_iterator<C1, C2, C3, C4>::get1() const
    {
        assert(m_it_type == 1);

        if (m_forward)
        {
            return cast_storage_to_ref1();
        }

        tackle::const_reverse_iterator_adaptor<C2> rit((tackle::make_reverse_iterator<C2>(cast_storage_to_ref1())));
        rit++;

        return rit.base();
    }

    template <typename C1, typename C2, typename C3, typename C4>
    typename C3::const_iterator compatible_const_iterator<C1, C2, C3, C4>::get2() const
    {
        assert(m_it_type == 2);

        if (m_forward)
        {
            return cast_storage_to_ref2();
        }

        tackle::const_reverse_iterator_adaptor<C3> rit((tackle::make_reverse_iterator<C3>(cast_storage_to_ref2())));
        rit++;

        return rit.base();
    }

    template <typename C1, typename C2, typename C3, typename C4>
    typename C4::const_iterator compatible_const_iterator<C1, C2, C3, C4>::get3() const
    {
        assert(m_it_type == 3);

        if (m_forward)
        {
            return cast_storage_to_ref3();
        }

        tackle::const_reverse_iterator_adaptor<C4> rit((tackle::make_reverse_iterator<C4>(cast_storage_to_ref3())));
        rit++;

        return rit.base();
    }

    template <typename C1, typename C2, typename C3, typename C4>
    const C1 * compatible_const_iterator<C1, C2, C3, C4>::get_container0() const
    {
        return reinterpret_cast<const C1 *>(m_it_cont);
    }

    template <typename C1, typename C2, typename C3, typename C4>
    const C2 * compatible_const_iterator<C1, C2, C3, C4>::get_container1() const
    {
        return reinterpret_cast<const C2 *>(m_it_cont);
    }

    template <typename C1, typename C2, typename C3, typename C4>
    const C3 * compatible_const_iterator<C1, C2, C3, C4>::get_container2() const
    {
        return reinterpret_cast<const C3 *>(m_it_cont);
    }

    template <typename C1, typename C2, typename C3, typename C4>
    const C4 * compatible_const_iterator<C1, C2, C3, C4>::get_container3() const
    {
        return reinterpret_cast<const C4 *>(m_it_cont);
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_const_iterator<C1, C2, C3, C4>::start(bool forward)
    {
        switch (m_it_type)
        {
        case 0:
        {
            if (forward)
            {
                const C1 * cont_ptr = get_container0();
                set(cont_ptr->begin(), cont_ptr);
            }
            else
            {
                const C1 * cont_ptr = get_container0();
                set(cont_ptr->rbegin().base(), cont_ptr);
            }
            m_forward = forward;
        }
        break;

        case 1:
        {
            if (forward)
            {
                const C2 * cont_ptr = get_container1();
                set(cont_ptr->begin(), cont_ptr);
            }
            else
            {
                const C2 * cont_ptr = get_container1();
                set(cont_ptr->rbegin().base(), cont_ptr);
            }
            m_forward = forward;
        }
        break;

        case 2:
        {
            if (forward)
            {
                const C3 * cont_ptr = get_container2();
                set(cont_ptr->begin(), cont_ptr);
            }
            else
            {
                const C3 * cont_ptr = get_container2();
                set(cont_ptr->rbegin().base(), cont_ptr);
            }
            m_forward = forward;
        }
        break;

        case 3:
        {
            if (forward)
            {
                const C4 * cont_ptr = get_container3();
                set(cont_ptr->begin(), cont_ptr);
            }
            else
            {
                const C4 * cont_ptr = get_container3();
                set(cont_ptr->rbegin().base(), cont_ptr);
            }
            m_forward = forward;
        }
        break;

        default:
            assert(0);
        }
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_const_iterator<C1, C2, C3, C4>::start(bool forward, const C1 * cont_ptr)
    {
        if (!cont_ptr)
        {
            return start(forward);
        }

        if (forward)
        {
            set(cont_ptr->begin(), cont_ptr);
        }
        else
        {
            set(cont_ptr->rbegin().base(), cont_ptr);
        }
        m_forward = forward;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_const_iterator<C1, C2, C3, C4>::start(bool forward, const C2 * cont_ptr)
    {
        if (!cont_ptr)
        {
            return start(forward);
        }

        if (forward)
        {
            set(cont_ptr->begin(), cont_ptr);
        }
        else
        {
            set(cont_ptr->rbegin().base(), cont_ptr);
        }
        m_forward = forward;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_const_iterator<C1, C2, C3, C4>::start(bool forward, const C3 * cont_ptr)
    {
        if (!cont_ptr)
        {
            return start(forward);
        }

        if (forward)
        {
            set(cont_ptr->begin(), cont_ptr);
        }
        else
        {
            set(cont_ptr->rbegin().base(), cont_ptr);
        }
        m_forward = forward;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_const_iterator<C1, C2, C3, C4>::start(bool forward, const C4 * cont_ptr)
    {
        if (!cont_ptr)
        {
            return start(forward);
        }

        if (forward)
        {
            set(cont_ptr->begin(), cont_ptr);
        }
        else
        {
            set(cont_ptr->rbegin().base(), cont_ptr);
        }
        m_forward = forward;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    bool compatible_const_iterator<C1, C2, C3, C4>::done(bool forward) const
    {
        switch (m_it_type)
        {
        case 0:
        {
            assert(m_it_cont);
#ifndef DISABLE_ITERATOR_SINGULARITY_CHECK
            assert(!tackle::is_singular_iterator<C1>(cast_storage_to_ref0()));
#endif

            if (forward)
            {
                return cast_storage_to_ref0() == get_container0()->end();
            }
            else
            {
                return cast_storage_to_ref0() == get_container0()->rend().base();
            }
        }
        break;

        case 1:
        {
            assert(m_it_cont);
#ifndef DISABLE_ITERATOR_SINGULARITY_CHECK
            assert(!tackle::is_singular_iterator<C2>(cast_storage_to_ref1()));
#endif

            if (forward)
            {
                return cast_storage_to_ref1() == get_container1()->end();
            }
            else
            {
                return cast_storage_to_ref1() == get_container1()->rend().base();
            }
        }
        break;

        case 2:
        {
            assert(m_it_cont);
#ifndef DISABLE_ITERATOR_SINGULARITY_CHECK
            assert(!tackle::is_singular_iterator<C3>(cast_storage_to_ref2()));
#endif

            if (forward)
            {
                return cast_storage_to_ref2() == get_container2()->end();
            }
            else
            {
                return cast_storage_to_ref2() == get_container2()->rend().base();
            }
        }
        break;

        case 3:
        {
            assert(m_it_cont);
#ifndef DISABLE_ITERATOR_SINGULARITY_CHECK
            assert(!tackle::is_singular_iterator<C4>(cast_storage_to_ref3()));
#endif

            if (forward)
            {
                return cast_storage_to_ref3() == get_container3()->end();
            }
            else
            {
                return cast_storage_to_ref3() == get_container3()->rend().base();
            }
        }
        break;

        default:
            assert(0);
        }

        return true;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_const_iterator<C1, C2, C3, C4>::step(bool forward)
    {
        switch (m_it_type)
        {
        case 0:
        {
            assert(m_it_cont);
#ifndef DISABLE_ITERATOR_SINGULARITY_CHECK
            assert(!tackle::is_singular_iterator<C1>(cast_storage_to_ref0()));
#endif

            if (forward)
            {
                ++cast_storage_to_ref0();
            }
            else
            {
                --cast_storage_to_ref0();
            }
        }
        break;

        case 1:
        {
            assert(m_it_cont);
#ifndef DISABLE_ITERATOR_SINGULARITY_CHECK
            assert(!tackle::is_singular_iterator<C2>(cast_storage_to_ref1()));
#endif

            if (forward)
            {
                ++cast_storage_to_ref1();
            }
            else
            {
                --cast_storage_to_ref1();
            }
        }
        break;

        case 2:
        {
            assert(m_it_cont);
#ifndef DISABLE_ITERATOR_SINGULARITY_CHECK
            assert(!tackle::is_singular_iterator<C3>(cast_storage_to_ref2()));
#endif

            if (forward)
            {
                ++cast_storage_to_ref2();
            }
            else
            {
                --cast_storage_to_ref2();
            }
        }
        break;

        case 3:
        {
            assert(m_it_cont);
#ifndef DISABLE_ITERATOR_SINGULARITY_CHECK
            assert(!tackle::is_singular_iterator<C4>(cast_storage_to_ref3()));
#endif

            if (forward)
            {
                ++cast_storage_to_ref3();
            }
            else
            {
                --cast_storage_to_ref3();
            }
        }
        break;

        default:
            assert(0);
        }
    }

    template <typename C1, typename C2, typename C3, typename C4>
    bool compatible_const_iterator<C1, C2, C3, C4>::is_forward() const
    {
        return m_forward;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_const_iterator<C1, C2, C3, C4>::set(const compatible_const_iterator & it)
    {
        switch (it.m_it_type)
        {
        case 0:
        {
            set(it.cast_storage_to_ref0(), reinterpret_cast<const C1 *>(it.m_it_cont));
            m_forward = it.m_forward;
        }
        break;

        case 1:
        {
            set(it.cast_storage_to_ref1(), reinterpret_cast<const C2 *>(it.m_it_cont));
            m_forward = it.m_forward;
        }
        break;

        case 2:
        {
            set(it.cast_storage_to_ref2(), reinterpret_cast<const C3 *>(it.m_it_cont));
            m_forward = it.m_forward;
        }
        break;

        case 3:
        {
            set(it.cast_storage_to_ref3(), reinterpret_cast<const C4 *>(it.m_it_cont));
            m_forward = it.m_forward;
        }
        break;

        default:
            assert(0);
        }
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_const_iterator<C1, C2, C3, C4>::set(const compatible_iterator<C1, C2, C3, C4> & it)
    {
        switch (it.m_it_type)
        {
        case 0:
        {
            set(it.cast_storage_to_ref0(), reinterpret_cast<const C1 *>(it.m_it_cont));
            m_forward = it.m_forward;
        }
        break;

        case 1:
        {
            set(it.cast_storage_to_ref1(), reinterpret_cast<const C2 *>(it.m_it_cont));
            m_forward = it.m_forward;
        }
        break;

        case 2:
        {
            set(it.cast_storage_to_ref2(), reinterpret_cast<const C3 *>(it.m_it_cont));
            m_forward = it.m_forward;
        }
        break;

        case 3:
        {
            set(it.cast_storage_to_ref3(), reinterpret_cast<const C4 *>(it.m_it_cont));
            m_forward = it.m_forward;
        }
        break;

        default:
            assert(0);
        }
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_const_iterator<C1, C2, C3, C4>::set(const typename C1::const_iterator & it, const C1 * it_cont)
    {
        assert(it_cont);
#ifndef DISABLE_ITERATOR_SINGULARITY_CHECK
        if (!tackle::is_singular_iterator<C1>(it))
        {
            (void)(it == it_cont->end()); // force check iterators compatibility
        }
#endif

        if (m_it_type == 0)
        {
            cast_storage_to_ref0() = it;
        }
        else
        {
            if (m_it_type != -1)
            {
                destruct_storage();
            }
            construct_storage(it, false);
            m_it_type = 0;
        }

        m_it_cont = it_cont;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_const_iterator<C1, C2, C3, C4>::set(const typename C2::const_iterator & it, const C2 * it_cont)
    {
        assert(it_cont);
#ifndef DISABLE_ITERATOR_SINGULARITY_CHECK
        if (!tackle::is_singular_iterator<C2>(it))
        {
            (void)(it == it_cont->end()); // force check iterators compatibility
        }
#endif

        if (m_it_type == 1)
        {
            cast_storage_to_ref1() = it;
        }
        else
        {
            if (m_it_type != -1)
            {
                destruct_storage();
            }
            construct_storage(it, false);
            m_it_type = 1;
        }

        m_it_cont = it_cont;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_const_iterator<C1, C2, C3, C4>::set(const typename C3::const_iterator & it, const C3 * it_cont)
    {
        assert(it_cont);
#ifndef DISABLE_ITERATOR_SINGULARITY_CHECK
        if (!tackle::is_singular_iterator<C3>(it))
        {
            (void)(it == it_cont->end()); // force check iterators compatibility
        }
#endif

        if (m_it_type == 2)
        {
            cast_storage_to_ref2() = it;
        }
        else
        {
            if (m_it_type != -1)
            {
                destruct_storage();
            }
            construct_storage(it, false);
            m_it_type = 2;
        }

        m_it_cont = it_cont;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_const_iterator<C1, C2, C3, C4>::set(const typename C4::const_iterator & it, const C4 * it_cont)
    {
        assert(it_cont);
#ifndef DISABLE_ITERATOR_SINGULARITY_CHECK
        if (!tackle::is_singular_iterator<C4>(it))
        {
            (void)(it == it_cont->end()); // force check iterators compatibility
        }
#endif

        if (m_it_type == 3)
        {
            cast_storage_to_ref3() = it;
        }
        else
        {
            if (m_it_type != -1)
            {
                destruct_storage();
            }
            construct_storage(it, false);
            m_it_type = 3;
        }

        m_it_cont = it_cont;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_const_iterator<C1, C2, C3, C4>::set(bool forward, const compatible_const_iterator_path_node<C1, C2, C3, C4> & it_path_node)
    {
        if (it_path_node.typeIndex() == -1 || !it_path_node.get())
        {
            assert(0);
            clear();
            return;
        }

        switch (it_path_node.typeIndex())
        {
        case 0:
        {
            const C1 * cont_ptr = reinterpret_cast<const C1 *>(it_path_node.get());
            start(forward, cont_ptr);
        }
        break;

        case 1:
        {
            const C2 * cont_ptr = reinterpret_cast<const C2 *>(it_path_node.get());
            start(forward, cont_ptr);
        }
        break;

        case 2:
        {
            const C3 * cont_ptr = reinterpret_cast<const C3 *>(it_path_node.get());
            start(forward, cont_ptr);
        }
        break;

        case 3:
        {
            const C4 * cont_ptr = reinterpret_cast<const C4 *>(it_path_node.get());
            start(forward, cont_ptr);
        }
        break;

        default:
            assert(0);
            clear();
        }
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_const_iterator<C1, C2, C3, C4>::set(bool forward, const compatible_iterator_path_node<C1, C2, C3, C4> & it_path_node)
    {
        if (it_path_node.typeIndex() == -1 || !it_path_node.get())
        {
            assert(0);
            clear();
            return;
        }

        switch (it_path_node.typeIndex())
        {
        case 0:
        {
            const C1 * cont_ptr = reinterpret_cast<const C1 *>(it_path_node.get());
            start(forward, cont_ptr);
        }
        break;

        case 1:
        {
            const C2 * cont_ptr = reinterpret_cast<const C2 *>(it_path_node.get());
            start(forward, cont_ptr);
        }
        break;

        case 2:
        {
            const C3 * cont_ptr = reinterpret_cast<const C3 *>(it_path_node.get());
            start(forward, cont_ptr);
        }
        break;

        case 3:
        {
            const C4 * cont_ptr = reinterpret_cast<const C4 *>(it_path_node.get());
            start(forward, cont_ptr);
        }
        break;

        default:
            assert(0);
            clear();
        }
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_const_iterator<C1, C2, C3, C4>::clear()
    {
        if (m_it_type != -1)
        {
            destruct_storage();
            m_it_type = -1;
        }
        m_it_cont = 0;
        m_forward = true;
    }

    // compatible_iterator_path_node
    template <typename C1, typename C2, typename C3, typename C4>
    compatible_iterator_path_node<C1, C2, C3, C4>::compatible_iterator_path_node() :
        m_it_type(-1),
        m_it_cont(0)
    {
    }

    template <typename C1, typename C2, typename C3, typename C4>
    compatible_iterator_path_node<C1, C2, C3, C4>::compatible_iterator_path_node(C1 * cont_ptr)
    {
        *this = cont_ptr;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    compatible_iterator_path_node<C1, C2, C3, C4>::compatible_iterator_path_node(C2 * cont_ptr)
    {
        *this = cont_ptr;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    compatible_iterator_path_node<C1, C2, C3, C4>::compatible_iterator_path_node(C3 * cont_ptr)
    {
        *this = cont_ptr;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    compatible_iterator_path_node<C1, C2, C3, C4>::compatible_iterator_path_node(C4 * cont_ptr)
    {
        *this = cont_ptr;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    const compatible_iterator_path_node<C1, C2, C3, C4> & compatible_iterator_path_node<C1, C2, C3, C4>::operator =(C1 * cont_ptr)
    {
        assert(cont_ptr);
        m_it_type = 0;
        m_it_cont = cont_ptr;

        return *this;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    const compatible_iterator_path_node<C1, C2, C3, C4> & compatible_iterator_path_node<C1, C2, C3, C4>::operator =(C2 * cont_ptr)
    {
        assert(cont_ptr);
        m_it_type = 1;
        m_it_cont = cont_ptr;

        return *this;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    const compatible_iterator_path_node<C1, C2, C3, C4> & compatible_iterator_path_node<C1, C2, C3, C4>::operator =(C3 * cont_ptr)
    {
        assert(cont_ptr);
        m_it_type = 2;
        m_it_cont = cont_ptr;

        return *this;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    const compatible_iterator_path_node<C1, C2, C3, C4> & compatible_iterator_path_node<C1, C2, C3, C4>::operator =(C4 * cont_ptr)
    {
        assert(cont_ptr);
        m_it_type = 3;
        m_it_cont = cont_ptr;

        return *this;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    int compatible_iterator_path_node<C1, C2, C3, C4>::typeIndex() const
    {
        return m_it_type;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void* compatible_iterator_path_node<C1, C2, C3, C4>::get() const
    {
        return m_it_cont;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    C1 * compatible_iterator_path_node<C1, C2, C3, C4>::get0() const
    {
        if (m_it_type == 0)
        {
            return reinterpret_cast<C1 *>(m_it_cont);
        }

        return 0;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    C2 * compatible_iterator_path_node<C1, C2, C3, C4>::get1() const
    {
        if (m_it_type == 1)
        {
            return reinterpret_cast<C2 *>(m_it_cont);
        }

        return 0;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    C3 * compatible_iterator_path_node<C1, C2, C3, C4>::get2() const
    {
        if (m_it_type == 2)
        {
            return reinterpret_cast<C3 *>(m_it_cont);
        }

        return 0;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    C4 * compatible_iterator_path_node<C1, C2, C3, C4>::get3() const
    {
        if (m_it_type == 3)
        {
            return reinterpret_cast<C4 *>(m_it_cont);
        }

        return 0;
    }

    // compatible_iterator_path_node
    template <typename C1, typename C2, typename C3, typename C4>
    compatible_const_iterator_path_node<C1, C2, C3, C4>::compatible_const_iterator_path_node() :
        m_it_type(-1),
        m_it_cont(0)
    {
    }

    template <typename C1, typename C2, typename C3, typename C4>
    compatible_const_iterator_path_node<C1, C2, C3, C4>::compatible_const_iterator_path_node(const C1 * cont_ptr)
    {
        *this = cont_ptr;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    compatible_const_iterator_path_node<C1, C2, C3, C4>::compatible_const_iterator_path_node(const C2 * cont_ptr)
    {
        *this = cont_ptr;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    compatible_const_iterator_path_node<C1, C2, C3, C4>::compatible_const_iterator_path_node(const C3 * cont_ptr)
    {
        *this = cont_ptr;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    compatible_const_iterator_path_node<C1, C2, C3, C4>::compatible_const_iterator_path_node(const C4 * cont_ptr)
    {
        *this = cont_ptr;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    const compatible_const_iterator_path_node<C1, C2, C3, C4> & compatible_const_iterator_path_node<C1, C2, C3, C4>::operator =(const C1 * cont_ptr)
    {
        assert(cont_ptr);
        m_it_type = 0;
        m_it_cont = cont_ptr;

        return *this;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    const compatible_const_iterator_path_node<C1, C2, C3, C4> & compatible_const_iterator_path_node<C1, C2, C3, C4>::operator =(const C2 * cont_ptr)
    {
        assert(cont_ptr);
        m_it_type = 1;
        m_it_cont = cont_ptr;

        return *this;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    const compatible_const_iterator_path_node<C1, C2, C3, C4> & compatible_const_iterator_path_node<C1, C2, C3, C4>::operator =(const C3 * cont_ptr)
    {
        assert(cont_ptr);
        m_it_type = 2;
        m_it_cont = cont_ptr;

        return *this;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    const compatible_const_iterator_path_node<C1, C2, C3, C4> & compatible_const_iterator_path_node<C1, C2, C3, C4>::operator =(const C4 * cont_ptr)
    {
        assert(cont_ptr);
        m_it_type = 3;
        m_it_cont = cont_ptr;

        return *this;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    int compatible_const_iterator_path_node<C1, C2, C3, C4>::typeIndex() const
    {
        return m_it_type;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    const void* compatible_const_iterator_path_node<C1, C2, C3, C4>::get() const
    {
        return m_it_cont;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    const C1 * compatible_const_iterator_path_node<C1, C2, C3, C4>::get0() const
    {
        if (m_it_type == 0)
        {
            return reinterpret_cast<const C1 *>(m_it_cont);
        }

        return 0;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    const C2 * compatible_const_iterator_path_node<C1, C2, C3, C4>::get1() const
    {
        if (m_it_type == 1)
        {
            return reinterpret_cast<const C2 *>(m_it_cont);
        }

        return 0;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    const C3 * compatible_const_iterator_path_node<C1, C2, C3, C4>::get2() const
    {
        if (m_it_type == 2)
        {
            return reinterpret_cast<const C3 *>(m_it_cont);
        }

        return 0;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    const C4 * compatible_const_iterator_path_node<C1, C2, C3, C4>::get3() const
    {
        if (m_it_type == 3)
        {
            return reinterpret_cast<const C4 *>(m_it_cont);
        }

        return 0;
    }

    // compatible_iterator_path
    template <typename C1, typename C2, typename C3, typename C4>
    compatible_iterator_path_node<C1, C2, C3, C4> & compatible_iterator_path<C1, C2, C3, C4>::operator [](typename compatible_iterator_path<C1, C2, C3, C4>::iterator_path::size_type index)
    {
        return m_it_path[index];
    }

    template <typename C1, typename C2, typename C3, typename C4>
    const compatible_iterator_path_node<C1, C2, C3, C4> & compatible_iterator_path<C1, C2, C3, C4>::operator [](typename compatible_iterator_path<C1, C2, C3, C4>::iterator_path::size_type index) const
    {
        return m_it_path[index];
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_iterator_path<C1, C2, C3, C4>::append_container(C1 * it_cont)
    {
        m_it_path.append(std::make_pair(0, it_cont));
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_iterator_path<C1, C2, C3, C4>::append_container(C2 * it_cont)
    {
        m_it_path.append(std::make_pair(1, it_cont));
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_iterator_path<C1, C2, C3, C4>::append_container(C3 * it_cont)
    {
        m_it_path.append(std::make_pair(2, it_cont));
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_iterator_path<C1, C2, C3, C4>::append_container(C4 * it_cont)
    {
        m_it_path.append(std::make_pair(3, it_cont));
    }

    template <typename C1, typename C2, typename C3, typename C4>
    typename compatible_iterator_path<C1, C2, C3, C4>::iterator_path::size_type compatible_iterator_path<C1, C2, C3, C4>::size() const
    {
        return m_it_path.size();
    }

    template <typename C1, typename C2, typename C3, typename C4>
    typename compatible_iterator_path<C1, C2, C3, C4>::iterator_path::size_type compatible_iterator_path<C1, C2, C3, C4>::capacity() const
    {
        return m_it_path.capacity();
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_iterator_path<C1, C2, C3, C4>::resize(typename compatible_iterator_path<C1, C2, C3, C4>::iterator_path::size_type size)
    {
        m_it_path.resize(size);
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_iterator_path<C1, C2, C3, C4>::reserve(typename compatible_iterator_path<C1, C2, C3, C4>::iterator_path::size_type size)
    {
        m_it_path.reserve(size);
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_iterator_path<C1, C2, C3, C4>::clear()
    {
        m_it_path.clear();
    }

    template <typename C1, typename C2, typename C3, typename C4>
    compatible_iterator_path_node<C1, C2, C3, C4> & compatible_iterator_path<C1, C2, C3, C4>::front()
    {
        return m_it_path.front();
    }

    template <typename C1, typename C2, typename C3, typename C4>
    const compatible_iterator_path_node<C1, C2, C3, C4> & compatible_iterator_path<C1, C2, C3, C4>::front() const
    {
        return m_it_path.front();
    }

    template <typename C1, typename C2, typename C3, typename C4>
    compatible_iterator_path_node<C1, C2, C3, C4> & compatible_iterator_path<C1, C2, C3, C4>::back()
    {
        return m_it_path.back();
    }

    template <typename C1, typename C2, typename C3, typename C4>
    const compatible_iterator_path_node<C1, C2, C3, C4> & compatible_iterator_path<C1, C2, C3, C4>::back() const
    {
        return m_it_path.back();
    }

    // compatible_iterator_path
    template <typename C1, typename C2, typename C3, typename C4>
    compatible_const_iterator_path_node<C1, C2, C3, C4> & compatible_const_iterator_path<C1, C2, C3, C4>::operator [](typename compatible_const_iterator_path<C1, C2, C3, C4>::iterator_path::size_type index)
    {
        return m_it_path[index];
    }

    template <typename C1, typename C2, typename C3, typename C4>
    const compatible_const_iterator_path_node<C1, C2, C3, C4> & compatible_const_iterator_path<C1, C2, C3, C4>::operator [](typename compatible_const_iterator_path<C1, C2, C3, C4>::iterator_path::size_type index) const
    {
        return m_it_path[index];
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_const_iterator_path<C1, C2, C3, C4>::append_container(const C1 * it_cont)
    {
        m_it_path.append(std::make_pair(0, it_cont));
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_const_iterator_path<C1, C2, C3, C4>::append_container(const C2 * it_cont)
    {
        m_it_path.append(std::make_pair(1, it_cont));
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_const_iterator_path<C1, C2, C3, C4>::append_container(const C3 * it_cont)
    {
        m_it_path.append(std::make_pair(2, it_cont));
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_const_iterator_path<C1, C2, C3, C4>::append_container(const C4 * it_cont)
    {
        m_it_path.append(std::make_pair(3, it_cont));
    }

    template <typename C1, typename C2, typename C3, typename C4>
    typename compatible_const_iterator_path<C1, C2, C3, C4>::iterator_path::size_type compatible_const_iterator_path<C1, C2, C3, C4>::size() const
    {
        return m_it_path.size();
    }

    template <typename C1, typename C2, typename C3, typename C4>
    typename compatible_const_iterator_path<C1, C2, C3, C4>::iterator_path::size_type compatible_const_iterator_path<C1, C2, C3, C4>::capacity() const
    {
        return m_it_path.capacity();
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_const_iterator_path<C1, C2, C3, C4>::resize(typename compatible_const_iterator_path<C1, C2, C3, C4>::iterator_path::size_type size)
    {
        m_it_path.resize(size);
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_const_iterator_path<C1, C2, C3, C4>::reserve(typename compatible_const_iterator_path<C1, C2, C3, C4>::iterator_path::size_type size)
    {
        m_it_path.reserve(size);
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_const_iterator_path<C1, C2, C3, C4>::clear()
    {
        m_it_path.clear();
    }

    template <typename C1, typename C2, typename C3, typename C4>
    compatible_const_iterator_path_node<C1, C2, C3, C4> & compatible_const_iterator_path<C1, C2, C3, C4>::front()
    {
        return m_it_path.front();
    }

    template <typename C1, typename C2, typename C3, typename C4>
    const compatible_const_iterator_path_node<C1, C2, C3, C4> & compatible_const_iterator_path<C1, C2, C3, C4>::front() const
    {
        return m_it_path.front();
    }

    template <typename C1, typename C2, typename C3, typename C4>
    compatible_const_iterator_path_node<C1, C2, C3, C4> & compatible_const_iterator_path<C1, C2, C3, C4>::back()
    {
        return m_it_path.back();
    }

    template <typename C1, typename C2, typename C3, typename C4>
    const compatible_const_iterator_path_node<C1, C2, C3, C4> & compatible_const_iterator_path<C1, C2, C3, C4>::back() const
    {
        return m_it_path.back();
    }

    // compatible_path_iterator
    template <typename C1, typename C2, typename C3, typename C4>
    compatible_path_iterator<C1, C2, C3, C4>::compatible_path_iterator() :
        m_it_path_ptr(0),
        m_it_path_node_index(-1),
        m_forward(true)
    {
    }

    template <typename C1, typename C2, typename C3, typename C4>
    const compatible_iterator<C1, C2, C3, C4> & compatible_path_iterator<C1, C2, C3, C4>::get() const
    {
        return m_it;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_path_iterator<C1, C2, C3, C4>::start(bool forward)
    {
        if (!m_it_path_ptr)
        {
            assert(0);
            return;
        }

        const size_type num_it_conts = m_it_path_ptr->size();
        if (!num_it_conts)
        {
            assert(0);
            return;
        }

        const iterator_path_node & it_path_node = forward ? *m_it_path_ptr->begin() : *m_it_path_ptr->back();
        switch (it_path_node.typeIndex())
        {
        case 0:
        {
            C1 * cont_ptr = reinterpret_cast<C1 *>(it_path_node.get());
            m_it.start(forward, cont_ptr);
        }
        break;

        case 1:
        {
            C2 * cont_ptr = reinterpret_cast<C2 *>(it_path_node.get());
            m_it.start(forward, cont_ptr);
        }
        break;

        case 2:
        {
            C3 * cont_ptr = reinterpret_cast<C3 *>(it_path_node.get());
            m_it.start(forward, cont_ptr);
        }
        break;

        case 3:
        {
            C4 * cont_ptr = reinterpret_cast<C4 *>(it_path_node.get());
            m_it.start(forward, cont_ptr);
        }
        break;

        default:
            assert(0);
        }
        m_forward = forward;

        // iterate to valid node
        if (m_it.done())
        {
            step(forward);
        }
    }

    template <typename C1, typename C2, typename C3, typename C4>
    bool compatible_path_iterator<C1, C2, C3, C4>::done(bool forward) const
    {
        if (!m_it_path_ptr || m_it_path_node_index == size_type(-1))
        {
            assert(0);
            return true;
        }

        const size_type num_it_conts = m_it_path_ptr->size();
        if (!num_it_conts || num_it_conts <= m_it_path_node_index)
        {
            assert(0);
            return true;
        }

        iterator it = m_it;
        size_type it_path_node_index = m_it_path_node_index;

        while (it.done(forward))
        {
            if ((forward && it_path_node_index < num_it_conts - 1) || (!forward && it_path_node_index > 0))
            {
                const iterator_path_node & next_it_path_node = (*m_it_path_ptr)[it_path_node_index + (forward ? +1 : -1)];
                switch (next_it_path_node.typeIndex())
                {
                case 0:
                {
                    C1 * next_cont_ptr = reinterpret_cast<C1 *>(next_it_path_node.get());
                    it.start(forward, next_cont_ptr);
                    forward ? it_path_node_index++ : it_path_node_index--;
                }
                break;

                case 1:
                {
                    C2 * next_cont_ptr = reinterpret_cast<C2 *>(next_it_path_node.get());
                    it.start(forward, next_cont_ptr);
                    forward ? it_path_node_index++ : it_path_node_index--;
                }
                break;

                case 2:
                {
                    C3 * next_cont_ptr = reinterpret_cast<C3 *>(next_it_path_node.get());
                    it.start(forward, next_cont_ptr);
                    forward ? it_path_node_index++ : it_path_node_index--;
                }
                break;

                case 3:
                {
                    C4 * next_cont_ptr = reinterpret_cast<C4 *>(next_it_path_node.get());
                    it.start(forward, next_cont_ptr);
                    forward ? it_path_node_index++ : it_path_node_index--;
                }
                break;

                default:
                    assert(0);
                    return true;
                }

                continue;
            }

            return true;
        }

        return false;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_path_iterator<C1, C2, C3, C4>::step(bool forward)
    {
        if (!m_it_path_ptr || m_it_path_node_index == size_type(-1))
        {
            assert(0);
            return;
        }

        const size_type num_it_conts = m_it_path_ptr->size();
        if (!num_it_conts || num_it_conts <= m_it_path_node_index)
        {
            assert(0);
            return;
        }

        if (!m_it.done(forward))
        {
            m_it.step(forward);
        }

        while (m_it.done(forward))
        {
            if ((forward && m_it_path_node_index < num_it_conts - 1) || (!forward && m_it_path_node_index > 0))
            {
                const iterator_path_node & next_it_path_node = (*m_it_path_ptr)[m_it_path_node_index + (forward ? +1 : -1)];
                switch (next_it_path_node.typeIndex())
                {
                case 0:
                {
                    C1 * next_cont_ptr = reinterpret_cast<C1 *>(next_it_path_node.get());
                    m_it.start(forward, next_cont_ptr);
                    forward ? m_it_path_node_index++ : m_it_path_node_index--;
                }
                break;

                case 1:
                {
                    C2 * next_cont_ptr = reinterpret_cast<C2 *>(next_it_path_node.get());
                    m_it.start(forward, next_cont_ptr);
                    forward ? m_it_path_node_index++ : m_it_path_node_index--;
                }
                break;

                case 2:
                {
                    C3 * next_cont_ptr = reinterpret_cast<C3 *>(next_it_path_node.get());
                    m_it.start(forward, next_cont_ptr);
                    forward ? m_it_path_node_index++ : m_it_path_node_index--;
                }
                break;

                case 3:
                {
                    C4 * next_cont_ptr = reinterpret_cast<C4 *>(next_it_path_node.get());
                    m_it.start(forward, next_cont_ptr);
                    forward ? m_it_path_node_index++ : m_it_path_node_index--;
                }
                break;

                default:
                    assert(0);
                    return;
                }

                continue;
            }

            return;
        }
    }

    template <typename C1, typename C2, typename C3, typename C4>
    bool compatible_path_iterator<C1, C2, C3, C4>::is_forward() const
    {
        return m_it.is_forward();
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_path_iterator<C1, C2, C3, C4>::seek_begin_path_node(bool forward)
    {
        if (!m_it_path_ptr || m_it_path_node_index == size_type(-1))
        {
            assert(0);
            return;
        }

        const size_type num_it_conts = m_it_path_ptr->size();
        if (!num_it_conts || num_it_conts <= m_it_path_node_index)
        {
            assert(0);
            return;
        }

        switch (m_it.typeIndex())
        {
        case 0:
        {
            const iterator_path_node & path_node = m_it.path_node();
            m_it.set(forward ? path_node.get0()->begin() : path_node.get0()->rbegin().base(), path_node.get0());
        }
        break;

        case 1:
        {
            const iterator_path_node & path_node = m_it.path_node();
            m_it.set(forward ? path_node.get1()->begin() : path_node.get1()->rbegin().base(), path_node.get1());
        }
        break;

        case 2:
        {
            const iterator_path_node & path_node = m_it.path_node();
            m_it.set(forward ? path_node.get2()->begin() : path_node.get2()->rbegin().base(), path_node.get2());
        }
        break;

        case 3:
        {
            const iterator_path_node & path_node = m_it.path_node();
            m_it.set(forward ? path_node.get3()->begin() : path_node.get3()->rbegin().base(), path_node.get3());
        }
        break;

        default:
            assert(0);
        }
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_path_iterator<C1, C2, C3, C4>::seek_end_path_node(bool forward)
    {
        if (!m_it_path_ptr || m_it_path_node_index == size_type(-1))
        {
            assert(0);
            return;
        }

        const size_type num_it_conts = m_it_path_ptr->size();
        if (!num_it_conts || num_it_conts <= m_it_path_node_index)
        {
            assert(0);
            return;
        }

        switch (m_it.typeIndex())
        {
        case 0:
        {
            const iterator_path_node & path_node = m_it.path_node();
            m_it.set(forward ? path_node.get0()->end() : path_node.get0()->rend().base(), path_node.get0());
        }
        break;

        case 1:
        {
            const iterator_path_node & path_node = m_it.path_node();
            m_it.set(forward ? path_node.get1()->end() : path_node.get1()->rend().base(), path_node.get1());
        }
        break;

        case 2:
        {
            const iterator_path_node & path_node = m_it.path_node();
            m_it.set(forward ? path_node.get2()->end() : path_node.get2()->rend().base(), path_node.get2());
        }
        break;

        case 3:
        {
            const iterator_path_node & path_node = m_it.path_node();
            m_it.set(forward ? path_node.get3()->end() : path_node.get3()->rend().base(), path_node.get3());
        }
        break;

        default:
            assert(0);
        }
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_path_iterator<C1, C2, C3, C4>::set(bool forward, const compatible_iterator_path<C1, C2, C3, C4> & it_path)
    {
        assert(it_path.size());
        m_it.set(forward, forward ? it_path.front() : it_path.back());
        m_it_path_ptr = &it_path;
        m_it_path_node_index = forward ? 0 : it_path.size() - 1;
        m_forward = forward;

        // iterate to valid node
        if (m_it.done(forward))
        {
            step(forward);
        }
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_path_iterator<C1, C2, C3, C4>::clear()
    {
        m_it.clear();
        m_it_path_ptr = 0;
        m_it_path_node_index = -1;
        m_forward = true;
    }

    // compatible_path_const_iterator
    template <typename C1, typename C2, typename C3, typename C4>
    compatible_path_const_iterator<C1, C2, C3, C4>::compatible_path_const_iterator() :
        m_it_path_ptr(0),
        m_it_path_node_index(-1),
        m_forward(true)
    {
    }

    template <typename C1, typename C2, typename C3, typename C4>
    const compatible_const_iterator<C1, C2, C3, C4> & compatible_path_const_iterator<C1, C2, C3, C4>::get() const
    {
        return m_it;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_path_const_iterator<C1, C2, C3, C4>::start(bool forward)
    {
        if (!m_it_path_ptr || m_it_path_node_index == size_type(-1))
        {
            assert(0);
            return;
        }

        const size_type num_it_conts = m_it_path_ptr->size();
        if (!num_it_conts || num_it_conts <= m_it_path_node_index)
        {
            assert(0);
            return;
        }

        const iterator_path_node & it_path_node = forward ? *m_it_path_ptr->begin() : *m_it_path_ptr->back();
        switch (it_path_node.typeIndex())
        {
        case 0:
        {
            const C1 * cont_ptr = reinterpret_cast<const C1 *>(it_path_node.get());
            m_it.start(forward, cont_ptr);
        }
        break;

        case 1:
        {
            const C2 * cont_ptr = reinterpret_cast<const C2 *>(it_path_node.get());
            m_it.start(forward, cont_ptr);
        }
        break;

        case 2:
        {
            const C3 * cont_ptr = reinterpret_cast<const C3 *>(it_path_node.get());
            m_it.start(forward, cont_ptr);
        }
        break;

        case 3:
        {
            const C4 * cont_ptr = reinterpret_cast<const C4 *>(it_path_node.get());
            m_it.start(forward, cont_ptr);
        }
        break;

        default:
            assert(0);
        }
        m_forward = forward;

        // iterate to valid node
        if (m_it.done(forward))
        {
            step(forward);
        }
    }

    template <typename C1, typename C2, typename C3, typename C4>
    bool compatible_path_const_iterator<C1, C2, C3, C4>::done(bool forward) const
    {
        if (!m_it_path_ptr || m_it_path_node_index == size_type(-1))
        {
            assert(0);
            return true;
        }

        const size_type num_it_conts = m_it_path_ptr->size();
        if (!num_it_conts || num_it_conts <= m_it_path_node_index)
        {
            assert(0);
            return true;
        }

        iterator it = m_it;
        size_type it_path_node_index = m_it_path_node_index;

        while (it.done(forward))
        {
            if ((forward && it_path_node_index < num_it_conts - 1) || (!forward && it_path_node_index > 0))
            {
                const iterator_path_node & next_it_path_node = (*m_it_path_ptr)[it_path_node_index + (forward ? +1 : -1)];
                switch (next_it_path_node.typeIndex())
                {
                case 0:
                {
                    const C1 * next_cont_ptr = reinterpret_cast<const C1 *>(next_it_path_node.get());
                    it.start(forward, next_cont_ptr);
                    forward ? it_path_node_index++ : it_path_node_index--;
                }
                break;

                case 1:
                {
                    const C2 * next_cont_ptr = reinterpret_cast<const C2 *>(next_it_path_node.get());
                    it.start(forward, next_cont_ptr);
                    forward ? it_path_node_index++ : it_path_node_index--;
                }
                break;

                case 2:
                {
                    const C3 * next_cont_ptr = reinterpret_cast<const C3 *>(next_it_path_node.get());
                    it.start(forward, next_cont_ptr);
                    forward ? it_path_node_index++ : it_path_node_index--;
                }
                break;

                case 3:
                {
                    const C4 * next_cont_ptr = reinterpret_cast<const C4 *>(next_it_path_node.get());
                    it.start(forward, next_cont_ptr);
                    forward ? it_path_node_index++ : it_path_node_index--;
                }
                break;

                default:
                    assert(0);
                    return true;
                }

                continue;
            }

            return true;
        }

        return false;
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_path_const_iterator<C1, C2, C3, C4>::step(bool forward)
    {
        if (!m_it_path_ptr || m_it_path_node_index == size_type(-1))
        {
            assert(0);
            return;
        }

        const size_type num_it_conts = m_it_path_ptr->size();
        if (!num_it_conts || num_it_conts <= m_it_path_node_index)
        {
            assert(0);
            return;
        }

        if (!m_it.done(forward))
        {
            m_it.step(forward);
        }

        while (m_it.done(forward))
        {
            if ((forward && m_it_path_node_index < num_it_conts - 1) || (!forward && m_it_path_node_index > 0))
            {
                const iterator_path_node & next_it_path_node = (*m_it_path_ptr)[m_it_path_node_index + (forward ? +1 : -1)];
                switch (next_it_path_node.typeIndex())
                {
                case 0:
                {
                    const C1 * next_cont_ptr = reinterpret_cast<const C1 *>(next_it_path_node.get());
                    m_it.start(forward, next_cont_ptr);
                    forward ? m_it_path_node_index++ : m_it_path_node_index--;
                }
                break;

                case 1:
                {
                    const C2 * next_cont_ptr = reinterpret_cast<const C2 *>(next_it_path_node.get());
                    m_it.start(forward, next_cont_ptr);
                    forward ? m_it_path_node_index++ : m_it_path_node_index--;
                }
                break;

                case 2:
                {
                    const C3 * next_cont_ptr = reinterpret_cast<const C3 *>(next_it_path_node.get());
                    m_it.start(forward, next_cont_ptr);
                    forward ? m_it_path_node_index++ : m_it_path_node_index--;
                }
                break;

                case 3:
                {
                    const C4 * next_cont_ptr = reinterpret_cast<const C4 *>(next_it_path_node.get());
                    m_it.start(forward, next_cont_ptr);
                    forward ? m_it_path_node_index++ : m_it_path_node_index--;
                }
                break;

                default:
                    assert(0);
                    return;
                }

                continue;
            }

            return;
        }
    }

    template <typename C1, typename C2, typename C3, typename C4>
    bool compatible_path_const_iterator<C1, C2, C3, C4>::is_forward() const
    {
        return m_it.is_forward();
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_path_const_iterator<C1, C2, C3, C4>::seek_begin_path_node(bool forward)
    {
        if (!m_it_path_ptr || m_it_path_node_index == size_type(-1))
        {
            assert(0);
            return;
        }

        const size_type num_it_conts = m_it_path_ptr->size();
        if (!num_it_conts || num_it_conts <= m_it_path_node_index)
        {
            assert(0);
            return;
        }

        switch (m_it.typeIndex())
        {
        case 0:
        {
            const iterator_path_node & path_node = m_it.path_node();
            m_it.set(forward ? path_node.get0()->begin() : path_node.get0()->rbegin().base(), path_node.get0());
        }
        break;

        case 1:
        {
            const iterator_path_node & path_node = m_it.path_node();
            m_it.set(forward ? path_node.get1()->begin() : path_node.get1()->rbegin().base(), path_node.get1());
        }
        break;

        case 2:
        {
            const iterator_path_node & path_node = m_it.path_node();
            m_it.set(forward ? path_node.get2()->begin() : path_node.get2()->rbegin().base(), path_node.get2());
        }
        break;

        case 3:
        {
            const iterator_path_node & path_node = m_it.path_node();
            m_it.set(forward ? path_node.get3()->begin() : path_node.get3()->rbegin().base(), path_node.get3());
        }
        break;

        default:
            assert(0);
        }
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_path_const_iterator<C1, C2, C3, C4>::seek_end_path_node(bool forward)
    {
        if (!m_it_path_ptr || m_it_path_node_index == size_type(-1))
        {
            assert(0);
            return;
        }

        const size_type num_it_conts = m_it_path_ptr->size();
        if (!num_it_conts || num_it_conts <= m_it_path_node_index)
        {
            assert(0);
            return;
        }

        switch (m_it.typeIndex())
        {
        case 0:
        {
            const iterator_path_node & path_node = m_it.path_node();
            m_it.set(forward ? path_node.get0()->end() : path_node.get0()->rend().base(), path_node.get0());
        }
        break;

        case 1:
        {
            const iterator_path_node & path_node = m_it.path_node();
            m_it.set(forward ? path_node.get1()->end() : path_node.get1()->rend().base(), path_node.get1());
        }
        break;

        case 2:
        {
            const iterator_path_node & path_node = m_it.path_node();
            m_it.set(forward ? path_node.get2()->end() : path_node.get2()->rend().base(), path_node.get2());
        }
        break;

        case 3:
        {
            const iterator_path_node & path_node = m_it.path_node();
            m_it.set(forward ? path_node.get3()->end() : path_node.get3()->rend().base(), path_node.get3());
        }
        break;

        default:
            assert(0);
        }
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_path_const_iterator<C1, C2, C3, C4>::set(bool forward, const compatible_const_iterator_path<C1, C2, C3, C4> & it_path)
    {
        assert(it_path.size());
        m_it.set(forward, forward ? it_path.front() : it_path.back());
        m_it_path_ptr = &it_path;
        m_it_path_node_index = forward ? 0 : it_path.size() - 1;
        m_forward = forward;

        // iterate to valid node
        if (m_it.done(forward))
        {
            step(forward);
        }
    }

    template <typename C1, typename C2, typename C3, typename C4>
    void compatible_path_const_iterator<C1, C2, C3, C4>::clear()
    {
        m_it.clear();
        m_it_path_ptr = 0;
        m_it_path_node_index = -1;
        m_forward = true;
    }
}

#endif
