#pragma once

// DO NOT REMOVE, exists to avoid private/public headers mixing!
#ifndef TACKLE_MAX_ALIGNED_STORAGE_DECL_HPP
#define TACKLE_MAX_ALIGNED_STORAGE_DECL_HPP

#include <src/tacklelib_private.hpp>

// private headers
#include <src/utility/assert_private.hpp>

// public headers
#include <tacklelib/utility/platform.hpp>
#include <tacklelib/utility/type_traits.hpp>
#include <tacklelib/utility/addressof.hpp>
#include <tacklelib/utility/assert.hpp>
#include <tacklelib/utility/memory.hpp>
#include <tacklelib/utility/utility.hpp>

#include <tacklelib/tackle/aligned_storage/aligned_storage_base.hpp>

#include <boost/preprocessor/repeat.hpp>
#include <boost/preprocessor/cat.hpp>

#include <boost/mpl/if.hpp>
#include <boost/mpl/less.hpp>
#include <boost/mpl/at.hpp>
#include <boost/mpl/size.hpp>
#include <boost/mpl/void.hpp>
#include <boost/mpl/find.hpp>
#include <boost/mpl/end.hpp>
#include <boost/mpl/sizeof.hpp>
#include <boost/mpl/max_element.hpp>
#include <boost/mpl/transform_view.hpp>
#include <boost/mpl/identity.hpp>

#include <boost/mpl/vector.hpp>

#include <fmt/format.h>

// alignof_ headers
#include <boost/mpl/size_t.hpp>
#include <boost/mpl/aux_/na_spec.hpp>
#include <boost/mpl/aux_/lambda_support.hpp>

#include <type_traits>
#include <new>
#include <stdexcept>
#include <typeinfo>
#include <utility>


#define TACKLE_PP_MAX_NUM_ALIGNED_STORAGE_TYPES 32 // for the builtin switch-case generator


// alignof mpl style implementation (namespace injection) the same way as the `mpl::sizeof_` did
namespace boost {
namespace mpl {
    template<
        typename BOOST_MPL_AUX_NA_PARAM(T)
    >
    struct alignof_
        : mpl::size_t< std::alignment_of<T>::value >
    {
        BOOST_MPL_AUX_LAMBDA_SUPPORT(1, alignof_, (T))
    };

    BOOST_MPL_AUX_NA_SPEC_NO_ETI(1, alignof_)
}
}

namespace tackle
{
    namespace mpl = boost::mpl;

    template <typename t_mpl_container_types, typename t_tag_pttn_type = tag_pttn_default>
    class max_aligned_storage_from_mpl_container;

    // The `max_aligned_storage_from_mpl_container` already stores construction state through the `type_index` variable.
    // We only need to enable copy constructor and assign operator if appropriate tag has declared.
    template <typename tag_pttn>
    class max_aligned_storage_from_mpl_container_base
    {
    public:
        FORCE_INLINE max_aligned_storage_from_mpl_container_base()
        {
        }

        max_aligned_storage_from_mpl_container_base(const max_aligned_storage_from_mpl_container_base &) = delete; // use explicit `construct` instead
        max_aligned_storage_from_mpl_container_base & operator =(const max_aligned_storage_from_mpl_container_base &) = delete; // use explicit `assign` instead
    };

    template <>
    class max_aligned_storage_from_mpl_container_base<tag_pttn_control_lifetime>
    {
        // MUST BE EMPTY
    };

    // special designed class to make maximal size and alignment for a storage to construct/destruct it explicitly by the type index
    template <typename t_mpl_container_types, typename t_tag_pttn_type>
    class max_aligned_storage_from_mpl_container : public max_aligned_storage_from_mpl_container_base<t_tag_pttn_type>
    {
    public:
        using base_t = max_aligned_storage_from_mpl_container_base<t_tag_pttn_type>;
        using storage_types_t = t_mpl_container_types;

    private:
        using storage_types_end_it_t = typename mpl::end<storage_types_t>::type;
        using num_types_t = typename mpl::size<storage_types_t>::type;

        STATIC_ASSERT_GT(num_types_t::value, 0, "template must be specialized with not empty mpl container");
        STATIC_ASSERT_GE(TACKLE_PP_MAX_NUM_ALIGNED_STORAGE_TYPES, num_types_t::value,
            "TACKLE_PP_MAX_NUM_ALIGNED_STORAGE_TYPES has not enough value or storage_types_t is too big");

        using max_size_t = typename mpl::deref<
            typename mpl::max_element<
                mpl::transform_view<storage_types_t, mpl::sizeof_<mpl::_1> >
            >::type
        >::type;

        using max_alignment_t = typename mpl::deref<
            typename mpl::max_element<
                mpl::transform_view<storage_types_t, mpl::alignof_<mpl::_1> >
            >::type
        >::type;

    public:
        // use maximals
        static const size_t max_size_value = max_size_t::value;
        static const size_t max_alignment_value = max_alignment_t::value;

        STATIC_ASSERT_GE(max_size_value, 1, "size_value must be strictly positive value");
        STATIC_ASSERT_TRUE2(max_alignment_value >= 1 && max_size_value >= max_alignment_value,
            max_alignment_value, max_size_value,
            "max_alignment_value must be strictly positive value and not greater than max_size_value");

        using max_aligned_storage_t = typename std::aligned_storage<max_size_value, max_alignment_value>::type;

        FORCE_INLINE max_aligned_storage_from_mpl_container(int type_index = -1);
        template <typename Ref>
        FORCE_INLINE max_aligned_storage_from_mpl_container(int type_index, const Ref & r);
        template <typename Ref>
        FORCE_INLINE max_aligned_storage_from_mpl_container(int type_index, Ref && r);
        FORCE_INLINE ~max_aligned_storage_from_mpl_container();

        FORCE_INLINE max_aligned_storage_from_mpl_container(const max_aligned_storage_from_mpl_container & r) :
            base_t(r) // binding with the base
        {
            // just in case
            DEBUG_ASSERT_LT(type_index(), 0);

            // at first, check if storage is constructed
            if (!r.is_constructed()) {
                DEBUG_BREAK_THROW(true) std::runtime_error(fmt::format("{:s}({:d}): reference type is not constructed",
                    UTILITY_PP_FUNCSIG, UTILITY_PP_LINE));
            }

            // make construction
            _construct(r, false);
        }

        FORCE_INLINE max_aligned_storage_from_mpl_container(max_aligned_storage_from_mpl_container && r) :
            base_t(r) // binding with the base
        {
            // just in case
            DEBUG_ASSERT_LT(type_index(), 0);

            // at first, check if storage is constructed
            if (!r.is_constructed()) {
                DEBUG_BREAK_THROW(true) std::runtime_error(fmt::format("{:s}({:d}): reference type is not constructed",
                    UTILITY_PP_FUNCSIG, UTILITY_PP_LINE));
            }

            // make construction
            _construct(std::move(r), false);
        }

        FORCE_INLINE max_aligned_storage_from_mpl_container & operator =(const max_aligned_storage_from_mpl_container & r)
        {
            this->base_t::operator =(r); // binding with the base

            // at first, check if both storages are constructed
            if (!is_constructed()) {
                DEBUG_BREAK_THROW(true) std::runtime_error(fmt::format("{:s}({:d}): this type is not constructed",
                    UTILITY_PP_FUNCSIG, UTILITY_PP_LINE));
            }

            if (!r.is_constructed()) {
                DEBUG_BREAK_THROW(true) std::runtime_error(fmt::format("{:s}({:d}): reference type is not constructed",
                    UTILITY_PP_FUNCSIG, UTILITY_PP_LINE));
            }

            // make assignment
            return _assign(r);
        }

        FORCE_INLINE max_aligned_storage_from_mpl_container & operator =(max_aligned_storage_from_mpl_container && r)
        {
            this->base_t::operator =(r); // binding with the base

            // at first, check if both storages are constructed
            if (!is_constructed()) {
                DEBUG_BREAK_THROW(true) std::runtime_error(fmt::format("{:s}({:d}): this type is not constructed",
                    UTILITY_PP_FUNCSIG, UTILITY_PP_LINE));
            }

            if (!r.is_constructed()) {
                DEBUG_BREAK_THROW(true) std::runtime_error(fmt::format("{:s}({:d}): reference type is not constructed",
                    UTILITY_PP_FUNCSIG, UTILITY_PP_LINE));
            }

            // make assignment
            return _assign(std::move(r));
        }

        // direct explicit construction and destruction, implicit construction is not declared here

        void construct_default(int type_index, bool reconstruct);
        template <typename Ref>
        void construct(int type_index, const Ref & r, bool reconstruct);
        template <typename Ref>
        void construct(int type_index, Ref && r, bool reconstruct);

        FORCE_INLINE bool is_constructed() const
        {
            const int type_index_ = type_index();
            DEBUG_ASSERT_LT(type_index_, mpl::size<storage_types_t>::value);
            return type_index_ >= 0 && type_index_ < mpl::size<storage_types_t>::value; // redundant check, just in case
        }

        FORCE_INLINE bool is_constructed() const volatile
        {
            const int type_index_ = type_index();
            DEBUG_ASSERT_LT(type_index_, mpl::size<storage_types_t>::value);
            return type_index_ >= 0 && type_index_ < mpl::size<storage_types_t>::value; // redundant check, just in case
        }

    private:
        FORCE_INLINE void _construct(const max_aligned_storage_from_mpl_container & s, bool reconstruct);
        FORCE_INLINE void _construct(max_aligned_storage_from_mpl_container && s, bool reconstruct);

    public:
        FORCE_INLINE void destruct();

        FORCE_INLINE int type_index() const;

    private:
        max_aligned_storage_from_mpl_container & _assign(const max_aligned_storage_from_mpl_container & s, bool throw_exceptions_on_type_error = true);
        max_aligned_storage_from_mpl_container & _assign(max_aligned_storage_from_mpl_container && s, bool throw_exceptions_on_type_error = true);

    public:
        // implicit assignment is forbidden here, do use explicit assignment instead

        template <typename Ref>
        max_aligned_storage_from_mpl_container & assign(const Ref & r, bool throw_exceptions_on_type_error = true);
        template <typename Ref>
        max_aligned_storage_from_mpl_container & assign(Ref && r, bool throw_exceptions_on_type_error = true);

        template <typename R, typename F>
        FORCE_INLINE R invoke(F && functor, bool throw_exceptions_on_type_error = true);
        template <typename R, typename F>
        FORCE_INLINE R invoke(F && functor, bool throw_exceptions_on_type_error = true) const;

        // CAUTION:
        //  Invokes functor if it's return type is convertible to the declared return type, otherwise does return unconstructed value!
        //
        template <typename R, typename F>
        FORCE_INLINE R invoke_if_returnable(F && functor, bool throw_exceptions_on_type_error = true);
        template <typename R, typename F>
        FORCE_INLINE R invoke_if_returnable(F && functor, bool throw_exceptions_on_type_error = true) const;

        FORCE_INLINE void * address();
        FORCE_INLINE const void * address() const;
        FORCE_INLINE volatile void * address() volatile;
        FORCE_INLINE const volatile void * address() const volatile;

    private:
        int m_type_index;
        max_aligned_storage_t m_storage;
    };

    //// max_aligned_storage_from_mpl_container

    template <typename t_mpl_container_types, typename t_tag_pttn_type>
    FORCE_INLINE max_aligned_storage_from_mpl_container<t_mpl_container_types, t_tag_pttn_type>::max_aligned_storage_from_mpl_container(int type_index) :
        m_type_index(-1) // as not constructed
    {
        DEBUG_ASSERT_LT(type_index, mpl::size<storage_types_t>::value);
        if (type_index >= 0) {
            construct_default(type_index, false);
        }
    }

    template <typename t_mpl_container_types, typename t_tag_pttn_type> template <typename Ref>
    FORCE_INLINE max_aligned_storage_from_mpl_container<t_mpl_container_types, t_tag_pttn_type>::max_aligned_storage_from_mpl_container(int type_index, const Ref & r) :
        m_type_index(-1) // as not constructed
    {
        DEBUG_ASSERT_LT(type_index, mpl::size<storage_types_t>::value);
        if (DEBUG_VERIFY_TRUE(type_index >= 0)) {
            construct(type_index, r, false);
        }
    }

    template <typename t_mpl_container_types, typename t_tag_pttn_type> template <typename Ref>
    FORCE_INLINE max_aligned_storage_from_mpl_container<t_mpl_container_types, t_tag_pttn_type>::max_aligned_storage_from_mpl_container(int type_index, Ref && r) :
        m_type_index(-1) // as not constructed
    {
        DEBUG_ASSERT_LT(type_index, mpl::size<storage_types_t>::value);
        if (DEBUG_VERIFY_TRUE(type_index >= 0)) {
            construct(type_index, std::forward<Ref>(r), false);
        }
    }

    template <typename t_mpl_container_types, typename t_tag_pttn_type>
    FORCE_INLINE max_aligned_storage_from_mpl_container<t_mpl_container_types, t_tag_pttn_type>::~max_aligned_storage_from_mpl_container()
    {
        DEBUG_ASSERT_LT(m_type_index, mpl::size<storage_types_t>::value);
        if (m_type_index >= 0) {
            destruct();
        }
    }

    template <typename t_mpl_container_types, typename t_tag_pttn_type>
    FORCE_INLINE int max_aligned_storage_from_mpl_container<t_mpl_container_types, t_tag_pttn_type>::type_index() const
    {
        return m_type_index;
    }

    template <typename t_mpl_container_types, typename t_tag_pttn_type>
    FORCE_INLINE void * max_aligned_storage_from_mpl_container<t_mpl_container_types, t_tag_pttn_type>::address()
    {
        return utility::addressof(m_storage);
    }

    template <typename t_mpl_container_types, typename t_tag_pttn_type>
    FORCE_INLINE const void * max_aligned_storage_from_mpl_container<t_mpl_container_types, t_tag_pttn_type>::address() const
    {
        return utility::addressof(m_storage);
    }

    template <typename t_mpl_container_types, typename t_tag_pttn_type>
    FORCE_INLINE volatile void * max_aligned_storage_from_mpl_container<t_mpl_container_types, t_tag_pttn_type>::address() volatile
    {
        return utility::addressof(m_storage);
    }

    template <typename t_mpl_container_types, typename t_tag_pttn_type>
    FORCE_INLINE const volatile void * max_aligned_storage_from_mpl_container<t_mpl_container_types, t_tag_pttn_type>::address() const volatile
    {
        return utility::addressof(m_storage);
    }
}

#endif
