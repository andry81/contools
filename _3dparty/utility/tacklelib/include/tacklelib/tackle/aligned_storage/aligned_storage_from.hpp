#pragma once

// DO NOT REMOVE, exists to avoid private/public headers mixing!
#ifndef TACKLE_ALIGNED_STORAGE_FROM_HPP
#define TACKLE_ALIGNED_STORAGE_FROM_HPP

#include <tacklelib/tacklelib.hpp>

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
#include <new>
#include <stdexcept>
#include <typeinfo>
#include <utility>


namespace tackle
{
    template <typename t_storage_type, typename t_tag_pttn_type = tag_pttn_default>
    class aligned_storage_from;

    template <typename t_storage_type>
    class aligned_storage_always_destruct_from;

    // CAUTION: To automatically destruct if constructed (must use tag_pttn_control_lifetime pattern), otherwise stored type would not be destructed in the destructor!
    // Can store construction flag inside and if is, then does destruct if constructed respective to the value of the flag.
    // If flag is not declared (default pattern), then woould not be destructed in the destructor.
    // Special designed class to store type which size and alignment is known.
    // Can be invoked on type with deleted initialization constructor or on type required delayed construction.
    template <typename t_storage_type, typename t_tag_pttn_type>
    class aligned_storage_from : public aligned_storage_base<t_storage_type, t_tag_pttn_type>
    {
    public:
        using base_t            = aligned_storage_base<t_storage_type, t_tag_pttn_type>;
        using storage_type_t    = t_storage_type;

        static const size_t size_value      = sizeof(storage_type_t);
        static const size_t alignment_value = std::alignment_of<storage_type_t>::value;

        using aligned_storage_t = typename std::aligned_storage<size_value, alignment_value>::type;

        FORCE_INLINE aligned_storage_from(bool enable_unconstructed_copy_ = false)
        {
            if (enable_unconstructed_copy_) {
                base_t::enable_unconstructed_copy();
            }
        }

        FORCE_INLINE ~aligned_storage_from()
        {
            // auto destruct ONLY if has lifetime control enabled
            if (base_t::has_construction_flag() && base_t::is_constructed()) {
                destruct();
            }
        }

        FORCE_INLINE aligned_storage_from(const aligned_storage_from & r) :
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

        FORCE_INLINE aligned_storage_from(aligned_storage_from && r) :
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

        FORCE_INLINE aligned_storage_from & operator =(const aligned_storage_from & r)
        {
            this->base_t::operator =(r); // binding with the base

            // just in case
            DEBUG_ASSERT_TRUE(!(base_t::has_construction_flag() ^ r.has_construction_flag())); // both must be or not

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

        FORCE_INLINE aligned_storage_from & operator =(aligned_storage_from && r)
        {
            this->base_t::operator =(r); // binding with the base

            // just in case
            DEBUG_ASSERT_TRUE(!(base_t::has_construction_flag() ^ r.has_construction_flag())); // both must be or not

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

        // direct explicit construction and destruction, implicit construction is not declared here

        FORCE_INLINE void construct_default()
        {
            DEBUG_ASSERT_TRUE(!base_t::has_construction_flag() || !base_t::is_constructed());

            ::new (utility::addressof(m_storage)) storage_type_t();

            // flag construction
            base_t::set_constructed(true);
        }

        template <typename Ref>
        FORCE_INLINE void construct(const Ref & r)
        {
            DEBUG_ASSERT_TRUE(!base_t::has_construction_flag() || !base_t::is_constructed());

            ::new (utility::addressof(m_storage)) storage_type_t(r);

            // flag construction
            base_t::set_constructed(true);
        }

        template <typename Ref>
        FORCE_INLINE void construct(Ref && r)
        {
            DEBUG_ASSERT_TRUE(!base_t::has_construction_flag() || !base_t::is_constructed());

            ::new (utility::addressof(m_storage)) storage_type_t(std::forward<Ref>(r));

            // flag construction
            base_t::set_constructed(true);
        }

        FORCE_INLINE void destruct()
        {
            DEBUG_ASSERT_TRUE(!base_t::has_construction_flag() || base_t::is_constructed());

            base_t::set_constructed(false);

            utility::cast_addressof<storage_type_t *>(m_storage)->storage_type_t::~storage_type_t();
        }

        // implicit assignment is forbidden here, do use explicit assignment instead

        template <typename Ref>
        FORCE_INLINE aligned_storage_from & assign(const Ref & r)
        {
            DEBUG_ASSERT_TRUE(!base_t::has_construction_flag() || base_t::is_constructed());

            return *utility::cast_addressof<storage_type_t *>(m_storage) = r;
        }

        template <typename Ref>
        FORCE_INLINE aligned_storage_from & assign(Ref && r)
        {
            DEBUG_ASSERT_TRUE(!base_t::has_construction_flag() || base_t::is_constructed());

            return *utility::cast_addressof<storage_type_t *>(m_storage) = std::forward<Ref>(r);
        }

        template <typename Ref>
        FORCE_INLINE aligned_storage_from & assign(const Ref & r) volatile
        {
            DEBUG_ASSERT_TRUE(!base_t::has_construction_flag() || base_t::is_constructed());

            return *utility::cast_addressof<storage_type_t *>(m_storage) = r;
        }

        template <typename Ref>
        FORCE_INLINE aligned_storage_from & assign(Ref && r) volatile
        {
            DEBUG_ASSERT_TRUE(!base_t::has_construction_flag() || base_t::is_constructed());

            return *utility::cast_addressof<storage_type_t *>(m_storage) = std::forward<Ref>(r);
        }

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

    // CAUTION: Always destructs even if not constructed!
    // Always does destruct in the destructor even if not constructed (dangerous, use with caution).
    // As a side effect must not has a standalone destruction function, use reconstruct instead!
    // Special designed class to store type which size and alignment is known.
    // Can be invoked on type with deleted initialization constructor or on type required delayed construction.
    template <typename t_storage_type>
    class aligned_storage_always_destruct_from : public aligned_storage_base<t_storage_type, tag_pttn_default>
    {
    public:
        using base_t            = aligned_storage_base<t_storage_type, tag_pttn_default>;
        using storage_type_t    = t_storage_type;

        static const size_t size_value      = sizeof(storage_type_t);
        static const size_t alignment_value = std::alignment_of<storage_type_t>::value;

        using aligned_storage_t = typename std::aligned_storage<size_value, alignment_value>::type;

        FORCE_INLINE aligned_storage_always_destruct_from()
        {
            // do nothing
        }

        FORCE_INLINE ~aligned_storage_always_destruct_from()
        {
            // CAUTION: unconditional destruction!
            unsafe_destruct();
        }

        FORCE_INLINE aligned_storage_always_destruct_from(const aligned_storage_always_destruct_from & r) :
            base_t(r) // binding with the base
        {
            // make unconditional construction
            ::new (utility::addressof(m_storage)) storage_type_t(*utility::cast_addressof<const storage_type_t *>(r.m_storage));
        }

        FORCE_INLINE aligned_storage_always_destruct_from(aligned_storage_always_destruct_from && r) :
            base_t(r) // binding with the base
        {
            // make unconditional construction
            ::new (utility::addressof(m_storage)) storage_type_t(std::move(*utility::cast_addressof<const storage_type_t *>(r.m_storage)));
        }

        FORCE_INLINE aligned_storage_always_destruct_from(const storage_type_t & r)
        {
            unsafe_construct(r);
        }

        FORCE_INLINE aligned_storage_always_destruct_from(storage_type_t && r)
        {
            unsafe_construct(std::move(r));
        }

        FORCE_INLINE aligned_storage_always_destruct_from & operator =(const aligned_storage_always_destruct_from & r)
        {
            this->base_t::operator =(r); // binding with the base

            // make unconditional assignment
            *utility::cast_addressof<storage_type_t *>(m_storage) = *utility::cast_addressof<const storage_type_t *>(r.m_storage);

            return *this;
        }

        FORCE_INLINE aligned_storage_always_destruct_from & operator =(aligned_storage_always_destruct_from && r)
        {
            this->base_t::operator =(r); // binding with the base

            // make unconditional assignment
            *utility::cast_addressof<storage_type_t *>(m_storage) = std::move(*utility::cast_addressof<const storage_type_t *>(r.m_storage));

            return *this;
        }

        // implicit assignment is supported here

        template <typename Ref>
        FORCE_INLINE aligned_storage_always_destruct_from & operator =(const Ref & r)
        {
            // make unconditional assignment
            *utility::cast_addressof<storage_type_t *>(m_storage) = r;

            return *this;
        }

        template <typename Ref>
        FORCE_INLINE aligned_storage_always_destruct_from & operator =(Ref && r)
        {
            // make unconditional assignment
            *utility::cast_addressof<storage_type_t *>(m_storage) = std::forward<Ref>(r);

            return *this;
        }

        template <typename Ref>
        FORCE_INLINE aligned_storage_always_destruct_from & operator =(const Ref & r) volatile
        {
            // make unconditional assignment
            *utility::cast_addressof<storage_type_t *>(m_storage) = r;

            return *this;
        }

        template <typename Ref>
        FORCE_INLINE aligned_storage_always_destruct_from & operator =(Ref && r) volatile
        {
            // make unconditional assignment
            *utility::cast_addressof<storage_type_t *>(m_storage) = std::forward<Ref>(r);

            return *this;
        }

        // direct construction and restruction of the storage

        // unsafe because class declares implicit convertion constructors above
        FORCE_INLINE void unsafe_construct_default()
        {
            ::new (utility::addressof(m_storage)) storage_type_t();
        }

        // unsafe because class declares implicit convertion constructors above
        template <typename Ref>
        FORCE_INLINE void unsafe_construct(const Ref & r)
        {
            ::new (utility::addressof(m_storage)) storage_type_t(r);
        }

        // unsafe because class declares implicit convertion constructors above
        template <typename Ref>
        FORCE_INLINE void unsafe_construct(Ref && r)
        {
            ::new (utility::addressof(m_storage)) storage_type_t(std::forward<Ref>(r));
        }

        FORCE_INLINE void unsafe_destruct()
        {
            utility::cast_addressof<storage_type_t *>(m_storage)->storage_type_t::~storage_type_t();
        }

        // use instead of the destruct function
        template <typename Ref>
        FORCE_INLINE void reconstruct(const Ref & r)
        {
            // destruct at first
            unsafe_destruct();

            return construct(r);
        }

        // use instead of the destruct function
        template <typename Ref>
        FORCE_INLINE void reconstruct(Ref && r)
        {
            // destruct at first
            unsafe_destruct();

            return construct(std::forward<Ref>(r));
        }

        // storage redirection, unsafe because does not check if the instance is constructed
        FORCE_INLINE storage_type_t * unsafe_this()
        {
            return static_cast<storage_type_t *>(address());
        }

        // storage redirection, unsafe because does not check if the instance is constructed
        FORCE_INLINE const storage_type_t * unsafe_this() const
        {
            return reinterpret_cast<const storage_type_t *>(address());
        }

        // storage redirection, unsafe because does not check if the instance is constructed
        FORCE_INLINE volatile storage_type_t * unsafe_this() volatile
        {
            return reinterpret_cast<volatile storage_type_t *>(address());
        }

        // storage redirection, unsafe because does not check if the instance is constructed
        FORCE_INLINE const volatile storage_type_t * unsafe_this() const volatile
        {
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
