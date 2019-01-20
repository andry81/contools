#pragma once

// DO NOT REMOVE, exists to avoid private/public headers mixing!
#ifndef TACKLE_ALIGNED_STORAGE_BASE_HPP
#define TACKLE_ALIGNED_STORAGE_BASE_HPP

#include <tacklelib/tacklelib.hpp>

#include <tacklelib/utility/platform.hpp>
#include <tacklelib/utility/utility.hpp>

#include <fmt/format.h>

#include <cstdio>
#include <stdexcept>


#define TACKLE_ALIGNED_STORAGE_BY_INSTANCE_TOKEN(size_of, align_of, tag_pttn_type) \
    UTILITY_PP_CONCAT6(size_, size_of, _align_, align_of, _pttn_, tag_pttn_type)


namespace tackle
{
    // CAUTION:
    //  Special tag pattern type to use the aligned storage with enabled (not deleted) copy constructor and assignment operator
    //  with explicit flag of constructed state (it is dangerous w/o the flag because being copied or assigned type can be not yet constructed!).
    //
    struct tag_pttn_control_lifetime {};
    struct tag_pttn_default {};

    //// aligned_storage_base

    template <typename t_storage_type, typename t_tag_pttn_type>
    class aligned_storage_base
    {
    public:
        FORCE_INLINE aligned_storage_base()
        {
        }

        // sometimes the msvc compiler shows the wrong usage place of a deleted function, old style with a `private` section works better
    private:
        aligned_storage_base(const aligned_storage_base &) = delete; // use explicit `construct` instead
        aligned_storage_base & operator =(const aligned_storage_base &) = delete; // use explicit `assign` instead

    public:
        FORCE_INLINE bool is_constructed() const
        {
            return true;    // external control, always treats as constructed
        }

        FORCE_INLINE bool is_constructed() const volatile
        {
            return true;    // external control, always treats as constructed
        }

        FORCE_INLINE bool is_unconstructed_copy_allowed() const
        {
            return false;   // must be always constructed
        }

        FORCE_INLINE bool has_construction_flag() const
        {
            return false;
        }

    protected:
        FORCE_INLINE void set_constructed(bool is_constructed)
        {
            // DO NOTHING
            UTILITY_UNUSED_STATEMENT(is_constructed);
        }

        // unsafe
        FORCE_INLINE void enable_unconstructed_copy()
        {
            DEBUG_BREAK_THROW(true) std::runtime_error(fmt::format("{:s}({:d}): not implemented",
                UTILITY_PP_FUNCSIG, UTILITY_PP_LINE));
        }
    };

    template <typename t_storage_type>
    class aligned_storage_base<t_storage_type, tag_pttn_control_lifetime>
    {
        enum Flags
        {
            Flag_None                       = 0,
            Flag_IsConstructed              = 0x01,
            Flag_IsUnconstractedCopyAllowed = 0x02  // unsafe
        };

    public:
        FORCE_INLINE aligned_storage_base() :
            m_flags(Flag_None)
        {
        }

        FORCE_INLINE aligned_storage_base(const aligned_storage_base &)
        {
            // DO NOT COPY FLAG HERE!
        }

        FORCE_INLINE aligned_storage_base & operator =(const aligned_storage_base &)
        {
            // DO NOT COPY FLAG HERE!
            return *this;
        }

        FORCE_INLINE bool is_constructed() const
        {
            return (m_flags & Flag_IsConstructed) ? true : false;
        }

        FORCE_INLINE bool is_constructed() const volatile
        {
            return (m_flags & Flag_IsConstructed) ? true : false;
        }

        FORCE_INLINE bool is_unconstructed_copy_allowed() const
        {
            return (m_flags & Flag_IsUnconstractedCopyAllowed) ? true : false;
        }

        FORCE_INLINE bool has_construction_flag() const
        {
            return true;
        }

    protected:
        FORCE_INLINE void set_constructed(bool is_constructed_)
        {
            m_flags = Flags(m_flags | (is_constructed_ ? Flag_IsConstructed : Flag_None));
        }

        // unsafe
        FORCE_INLINE void enable_unconstructed_copy()
        {
            m_flags = Flags(m_flags | Flag_IsUnconstractedCopyAllowed);
        }

    protected:
        Flags m_flags;
    };
}

#endif
