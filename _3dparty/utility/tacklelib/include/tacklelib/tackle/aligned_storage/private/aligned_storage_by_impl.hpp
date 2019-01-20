#pragma once

// "aligned_storage_by_decl.hpp" must be already included here!
#ifndef TACKLE_ALIGNED_STORAGE_BY_DECL_HPP
#error You must include declaration header "aligned_storage_by_decl.hpp" at first!
#endif

#include <fmt/format.h>

#include <type_traits>
#include <new>
#include <stdexcept>
#include <typeinfo>
#include <utility>


namespace tackle
{
    //// aligned_storage_by

    template <typename t_storage_type, size_t t_size_value, size_t t_alignment_value, typename t_tag_pttn_type>
    FORCE_INLINE aligned_storage_by<t_storage_type, t_size_value, t_alignment_value, t_tag_pttn_type>::aligned_storage_by(bool enable_unconstructed_copy_)
    {
        // prevent the linkage of invalid constructed type with inappropriate size or alignment
        STATIC_ASSERT_EQ(size_value, sizeof(storage_type_t), "the storage type size is different");
        STATIC_ASSERT_EQ(alignment_value, std::alignment_of<storage_type_t>::value, "the storage type alignment is different");

        if (enable_unconstructed_copy_) {
            base_t::enable_unconstructed_copy();
        }
    }

    template <typename t_storage_type, size_t t_size_value, size_t t_alignment_value, typename t_tag_pttn_type>
    FORCE_INLINE aligned_storage_by<t_storage_type, t_size_value, t_alignment_value, t_tag_pttn_type>::aligned_storage_by(const aligned_storage_by & r) :
        base_t(r) // binding with the base
    {
        // just in case
        DEBUG_ASSERT_TRUE(!(base_t::has_construction_flag() ^ r.has_construction_flag())); // both must be or not
        DEBUG_ASSERT_TRUE(!base_t::is_constructed());

        // at first, check if storage is constructed
        if (!r.is_constructed()) {
            if (!base_t::is_unconstructed_copy_allowed()) {
                DEBUG_BREAK_THROW(true) std::runtime_error(fmt::format("{:s}({:d}): reference type is not constructed",
                    UTILITY_PP_FUNCSIG, UTILITY_PP_LINE));
            }
        }
        else {
            // make construction
            ::new (utility::addressof(m_storage)) storage_type_t(*utility::cast_addressof<const storage_type_t *>(r.m_storage));

            // flag construction
            base_t::set_constructed(true);
        }
    }

    template <typename t_storage_type, size_t t_size_value, size_t t_alignment_value, typename t_tag_pttn_type>
    FORCE_INLINE aligned_storage_by<t_storage_type, t_size_value, t_alignment_value, t_tag_pttn_type>::aligned_storage_by(aligned_storage_by && r) :
        base_t(r) // binding with the base
    {
        // just in case
        DEBUG_ASSERT_TRUE(!(base_t::has_construction_flag() ^ r.has_construction_flag())); // both must be or not
        DEBUG_ASSERT_TRUE(!base_t::is_constructed());

        // at first, check if storage is constructed
        if (!r.is_constructed()) {
            if (!base_t::is_unconstructed_copy_allowed()) {
                DEBUG_BREAK_THROW(true) std::runtime_error(fmt::format("{:s}({:d}): reference type is not constructed",
                    UTILITY_PP_FUNCSIG, UTILITY_PP_LINE));
            }
        }
        else {
            // make construction
            ::new (utility::addressof(m_storage)) storage_type_t(std::move(*utility::cast_addressof<const storage_type_t *>(r.m_storage)));

            // flag construction
            base_t::set_constructed(true);
        }
    }

    template <typename t_storage_type, size_t t_size_value, size_t t_alignment_value, typename t_tag_pttn_type>
    FORCE_INLINE aligned_storage_by<t_storage_type, t_size_value, t_alignment_value, t_tag_pttn_type> &
        aligned_storage_by<t_storage_type, t_size_value, t_alignment_value, t_tag_pttn_type>::operator =(const aligned_storage_by & r)
    {
        this->base_t::operator =(r); // binding with the base

        // just in case
        DEBUG_ASSERT_TRUE(base_t::has_construction_flag() && r.has_construction_flag());

        // at first, check if both storages are constructed
        if (!base_t::is_constructed()) {
            DEBUG_BREAK_THROW(true) std::runtime_error(fmt::format("{:s}({:d}): this type is not constructed",
                UTILITY_PP_FUNCSIG, UTILITY_PP_LINE));
        }

        if (!r.is_constructed()) {
            DEBUG_BREAK_THROW(true) std::runtime_error(fmt::format("{:s}({:d}): reference type is not constructed",
                UTILITY_PP_FUNCSIG, UTILITY_PP_LINE));
        }

        // make assignment
        *utility::cast_addressof<storage_type_t *>(m_storage) = *utility::cast_addressof<const storage_type_t *>(r.m_storage);

        return *this;
    }

    template <typename t_storage_type, size_t t_size_value, size_t t_alignment_value, typename t_tag_pttn_type>
    FORCE_INLINE aligned_storage_by<t_storage_type, t_size_value, t_alignment_value, t_tag_pttn_type> &
        aligned_storage_by<t_storage_type, t_size_value, t_alignment_value, t_tag_pttn_type>::operator =(aligned_storage_by && r)
    {
        this->base_t::operator =(r); // binding with the base

        // just in case
        DEBUG_ASSERT_TRUE(base_t::has_construction_flag() && r.has_construction_flag());

        // at first, check if both storages are constructed
        if (!base_t::is_constructed()) {
            DEBUG_BREAK_THROW(true) std::runtime_error(fmt::format("{:s}({:d}): this type is not constructed",
                UTILITY_PP_FUNCSIG, UTILITY_PP_LINE));
        }

        if (!r.is_constructed()) {
            DEBUG_BREAK_THROW(true) std::runtime_error(fmt::format("{:s}({:d}): reference type is not constructed",
                UTILITY_PP_FUNCSIG, UTILITY_PP_LINE));
        }

        // make assignment
        *utility::cast_addressof<storage_type_t *>(m_storage) = std::move(*utility::cast_addressof<const storage_type_t *>(r.m_storage));

        return *this;
    }

    template <typename t_storage_type, size_t t_size_value, size_t t_alignment_value, typename t_tag_pttn_type>
    FORCE_INLINE void aligned_storage_by<t_storage_type, t_size_value, t_alignment_value, t_tag_pttn_type>::construct_default()
    {
        DEBUG_ASSERT_TRUE(!base_t::has_construction_flag() || !base_t::is_constructed());

        ::new (utility::addressof(m_storage)) storage_type_t();

        // flag construction
        base_t::set_constructed(true);
    }

    template <typename t_storage_type, size_t t_size_value, size_t t_alignment_value, typename t_tag_pttn_type>
    template <typename Ref>
    FORCE_INLINE void aligned_storage_by<t_storage_type, t_size_value, t_alignment_value, t_tag_pttn_type>::construct(const Ref & r)
    {
        DEBUG_ASSERT_TRUE(!base_t::has_construction_flag() || !base_t::is_constructed());

        ::new (utility::addressof(m_storage)) storage_type_t(r);

        // flag construction
        base_t::set_constructed(true);
    }

    template <typename t_storage_type, size_t t_size_value, size_t t_alignment_value, typename t_tag_pttn_type>
    template <typename Ref>
    FORCE_INLINE void aligned_storage_by<t_storage_type, t_size_value, t_alignment_value, t_tag_pttn_type>::construct(Ref && r)
    {
        DEBUG_ASSERT_TRUE(!base_t::has_construction_flag() || !base_t::is_constructed());

        ::new (utility::addressof(m_storage)) storage_type_t(std::forward<Ref>(r));

        // flag construction
        base_t::set_constructed(true);
    }

    template <typename t_storage_type, size_t t_size_value, size_t t_alignment_value, typename t_tag_pttn_type>
    FORCE_INLINE void aligned_storage_by<t_storage_type, t_size_value, t_alignment_value, t_tag_pttn_type>::destruct()
    {
        DEBUG_ASSERT_TRUE(!base_t::has_construction_flag() || base_t::is_constructed());

        base_t::set_constructed(false);

        utility::cast_addressof<storage_type_t *>(m_storage)->storage_type_t::~storage_type_t();
    }

    template <typename t_storage_type, size_t t_size_value, size_t t_alignment_value, typename t_tag_pttn_type>
    template <typename Ref>
    FORCE_INLINE aligned_storage_by<t_storage_type, t_size_value, t_alignment_value, t_tag_pttn_type> &
        aligned_storage_by<t_storage_type, t_size_value, t_alignment_value, t_tag_pttn_type>::assign(const Ref & r)
    {
        DEBUG_ASSERT_TRUE(!base_t::has_construction_flag() || base_t::is_constructed());

        *utility::cast_addressof<storage_type_t *>(m_storage) = r;

        return *this;
    }

    template <typename t_storage_type, size_t t_size_value, size_t t_alignment_value, typename t_tag_pttn_type>
    template <typename Ref>
    FORCE_INLINE aligned_storage_by<t_storage_type, t_size_value, t_alignment_value, t_tag_pttn_type> &
        aligned_storage_by<t_storage_type, t_size_value, t_alignment_value, t_tag_pttn_type>::assign(Ref && r)
    {
        DEBUG_ASSERT_TRUE(!base_t::has_construction_flag() || base_t::is_constructed());

        *utility::cast_addressof<storage_type_t *>(m_storage) = std::forward<Ref>(r);

        return *this;
    }

    template <typename t_storage_type, size_t t_size_value, size_t t_alignment_value, typename t_tag_pttn_type>
    template <typename Ref>
    FORCE_INLINE aligned_storage_by<t_storage_type, t_size_value, t_alignment_value, t_tag_pttn_type> &
        aligned_storage_by<t_storage_type, t_size_value, t_alignment_value, t_tag_pttn_type>::assign(const Ref & r) volatile
    {
        DEBUG_ASSERT_TRUE(!base_t::has_construction_flag() || base_t::is_constructed());

        *utility::cast_addressof<storage_type_t *>(m_storage) = r;

        return *this;
    }

    template <typename t_storage_type, size_t t_size_value, size_t t_alignment_value, typename t_tag_pttn_type>
    template <typename Ref>
    FORCE_INLINE aligned_storage_by<t_storage_type, t_size_value, t_alignment_value, t_tag_pttn_type> &
        aligned_storage_by<t_storage_type, t_size_value, t_alignment_value, t_tag_pttn_type>::assign(Ref && r) volatile
    {
        DEBUG_ASSERT_TRUE(!base_t::has_construction_flag() || base_t::is_constructed());

        *utility::cast_addressof<storage_type_t *>(m_storage) = std::forward<Ref>(r);

        return *this;
    }
}
