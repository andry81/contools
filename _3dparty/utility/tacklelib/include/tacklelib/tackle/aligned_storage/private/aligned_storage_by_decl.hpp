#pragma once

#ifdef TACKLE_ALIGNED_STORAGE_BY_PUBLIC_DECL_HPP
#error You must not include private header after public!
#endif

// DO NOT REMOVE, exists to avoid private/public headers mixing!
#ifndef TACKLE_ALIGNED_STORAGE_BY_DECL_HPP
#define TACKLE_ALIGNED_STORAGE_BY_DECL_HPP

#include <tacklelib/tacklelib.hpp>

// public headers
#include <tacklelib/utility/platform.hpp>
#include <tacklelib/utility/static_assert.hpp>
#include <tacklelib/utility/type_traits.hpp>
#include <tacklelib/utility/addressof.hpp>
#include <tacklelib/utility/assert.hpp>
#include <tacklelib/utility/memory.hpp>
#include <tacklelib/utility/utility.hpp>

#include <tacklelib/tackle/aligned_storage/aligned_storage_base.hpp>

#include <fmt/format.h>

#include <type_traits>


namespace tackle
{
    // public interface ONLY

    template <typename t_storage_type, size_t t_size_value, size_t t_alignment_value, typename t_tag_pttn_type = tag_pttn_default>
    class aligned_storage_by;

    // special designed class to store type with not yet known size and alignment (for example, forward type with implementation in a .cpp file)
    template <typename t_storage_type, size_t t_size_value, size_t t_alignment_value, typename t_tag_pttn_type>
    class aligned_storage_by : public aligned_storage_base<t_storage_type, t_tag_pttn_type>
    {
    public:
        using base_t            = aligned_storage_base<t_storage_type, t_tag_pttn_type>;
        using storage_type_t    = t_storage_type;

        static const size_t size_value      = t_size_value;
        static const size_t alignment_value = t_alignment_value;

        using aligned_storage_t = typename std::aligned_storage<size_value, alignment_value>::type;

        STATIC_ASSERT_GT(size_value, 1, "size_value must be strictly positive value");
        STATIC_ASSERT_TRUE2(alignment_value > 1 && size_value >= alignment_value,
            alignment_value, size_value,
            "alignment_value must be strictly positive value and not greater than size_value");

        FORCE_INLINE aligned_storage_by(bool enable_unconstructed_copy_ = false);

        FORCE_INLINE ~aligned_storage_by()
        {
            // auto destruct ONLY if has lifetime control enabled
            if (base_t::has_construction_flag() && base_t::is_constructed()) {
                destruct();
            }
        }

        FORCE_INLINE aligned_storage_by(const aligned_storage_by & r);
        FORCE_INLINE aligned_storage_by(aligned_storage_by && r);
        FORCE_INLINE aligned_storage_by & operator =(const aligned_storage_by & r);
        FORCE_INLINE aligned_storage_by & operator =(aligned_storage_by && r);

        // direct explicit construction and destruction, implicit construction is not declared here

        FORCE_INLINE void construct_default();
        template <typename Ref>
        FORCE_INLINE void construct(const Ref & r);
        template <typename Ref>
        FORCE_INLINE void construct(Ref && r);
        FORCE_INLINE void destruct();

        // implicit assignment is forbidden here, do use explicit assignment instead

        template <typename Ref>
        FORCE_INLINE aligned_storage_by & assign(const Ref & r);
        template <typename Ref>
        FORCE_INLINE aligned_storage_by & assign(Ref && r);
        template <typename Ref>
        FORCE_INLINE aligned_storage_by & assign(const Ref & r) volatile;
        template <typename Ref>
        FORCE_INLINE aligned_storage_by & assign(Ref && r) volatile;

        // storage redirection
        FORCE_INLINE storage_type_t * this_()
        {
            if (!base_t::is_constructed()) {
                DEBUG_BREAK_THROW(true) std::runtime_error(fmt::format("{:s}({:d}): this type is not constructed",
                    UTILITY_PP_FUNCSIG, UTILITY_PP_LINE));
            }

            return static_cast<storage_type_t *>(address());
        }

        FORCE_INLINE const storage_type_t * this_() const
        {
            if (!base_t::is_constructed()) {
                DEBUG_BREAK_THROW(true) std::runtime_error(fmt::format("{:s}({:d}): this type is not constructed",
                    UTILITY_PP_FUNCSIG, UTILITY_PP_LINE));
            }

            return reinterpret_cast<const storage_type_t *>(address());
        }

        FORCE_INLINE volatile storage_type_t * this_() volatile
        {
            if (!base_t::is_constructed()) {
                DEBUG_BREAK_THROW(true) std::runtime_error(fmt::format("{:s}({:d}): this type is not constructed",
                    UTILITY_PP_FUNCSIG, UTILITY_PP_LINE));
            }

            return reinterpret_cast<volatile storage_type_t *>(address());
        }

        FORCE_INLINE const volatile storage_type_t * this_() const volatile
        {
            if (!base_t::is_constructed()) {
                DEBUG_BREAK_THROW(true) std::runtime_error(fmt::format("{:s}({:d}): this type is not constructed",
                    UTILITY_PP_FUNCSIG, UTILITY_PP_LINE));
            }

            return reinterpret_cast<const volatile storage_type_t *>(address());
        }

        FORCE_INLINE void * address()
        {
            return utility::addressof(m_storage);
        }

        FORCE_INLINE const void * address() const
        {
            return utility::addressof(m_storage);
        }

        FORCE_INLINE volatile void * address() volatile
        {
            return utility::addressof(m_storage);
        }

        FORCE_INLINE const volatile void * address() const volatile
        {
            return utility::addressof(m_storage);
        }

    private:
        aligned_storage_t m_storage;
    };
}

#endif
