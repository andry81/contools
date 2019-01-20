#pragma once

#include <tacklelib/tacklelib.hpp>

#include <tacklelib/utility/platform.hpp>
#include <tacklelib/utility/type_identity.hpp>

#include <utility>


// public interface class holder of private types

namespace tackle {

    class interface_handle
    {
    public:
        virtual ~interface_handle() = 0;
        virtual int type_index() const  = 0;

        FORCE_INLINE bool is_kind_of(int type_index_) const
        {
            return type_index() == type_index_; // must be implemented unique
        }
    };

    inline interface_handle::~interface_handle()
    {
    }

    // iii - interface implementation instantiator

    template <class TInterface, class TBase, int TypeIndex>
    class t_interface_handle : public TInterface, public utility::type_index_identity_base<TBase, TypeIndex>::type
    {
    public:
        using base_type0 = TInterface;
        using base_type1 = TBase;

        FORCE_INLINE static CONSTEXPR const int static_type_index()
        {
            return TypeIndex;
        }

        FORCE_INLINE t_interface_handle() = default;
        FORCE_INLINE t_interface_handle(const t_interface_handle &) = default;
        FORCE_INLINE t_interface_handle(t_interface_handle &&) = default;

        FORCE_INLINE t_interface_handle & operator =(const t_interface_handle &) = default;
        FORCE_INLINE t_interface_handle & operator =(t_interface_handle &&) = default;

        FORCE_INLINE t_interface_handle(TBase handle) :
            base_type1(std::move(handle))
        {
        }

        virtual FORCE_INLINE ~t_interface_handle() override
        {
        }

        virtual FORCE_INLINE int type_index() const override
        {
            return TypeIndex; // must be unique
        }
    };
}
