#pragma once

// DO NOT REMOVE, exists to avoid private/public headers mixing!
#ifndef TACKLE_ALIGNED_STORAGE_BY_DECL_HPP
#define TACKLE_ALIGNED_STORAGE_BY_DECL_HPP
#define TACKLE_ALIGNED_STORAGE_BY_PUBLIC_DECL_HPP

#include <tacklelib/tacklelib.hpp>

#include <tacklelib/utility/platform.hpp>
#include <tacklelib/utility/static_assert.hpp>
#include <tacklelib/utility/type_traits.hpp>
#include <tacklelib/utility/assert.hpp>
#include <tacklelib/utility/memory.hpp>

#include <tacklelib/tackle/aligned_storage/aligned_storage_base.hpp>

#include <type_traits>


namespace tackle
{
    // public interface ONLY

    template <typename t_storage_type, size_t t_size_value, size_t t_alignment_value, typename t_tag_pttn_type = tag_pttn_default>
    class aligned_storage_by : public aligned_storage_base<t_storage_type, t_tag_pttn_type>
    {
    private:
        typename std::aligned_storage<t_size_value, t_alignment_value>::type m_storage;
    };
}

#endif
