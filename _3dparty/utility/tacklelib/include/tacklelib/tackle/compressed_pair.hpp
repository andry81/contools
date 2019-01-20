#pragma once

// Based on `boost` library (https://www.boost.org)
//

// DO NOT REMOVE, exists to avoid private/public headers mixing!
#ifndef TACKLE_COMPRESSED_PAIR_HPP
#define TACKLE_COMPRESSED_PAIR_HPP

#include <tacklelib/tacklelib.hpp>

#include <tacklelib/utility/platform.hpp>
#include <tacklelib/utility/static_assert.hpp>
#include <tacklelib/utility/type_traits.hpp>

#include <algorithm>


namespace tackle
{
    template <class T0, class T1>
    class compressed_pair;

    namespace details
    {
        template <class T0, class T1, bool t_is_same, bool t_is_first_empty, bool t_is_second_empty>
        struct compressed_pair_selector;

        template <class T0, class T1>
        struct compressed_pair_selector<T0, T1, false, false, false>
        {
            static const std::size_t value = 0; // T0 and T1 can not be compressed or should not be compressed
        };

        template <class T0, class T1>
        struct compressed_pair_selector<T0, T1, false, true, true>
        {
            static const std::size_t value = 3; // T0 and T1 can be compressed and may has same addresses: &x.first() == &x.second()
        };

        template <class T0, class T1>
        struct compressed_pair_selector<T0, T1, false, true, false>
        {
            static const std::size_t value = 1; // only T0 can be compressed or T0 and T1 can be compressed but should has different addresses: &x.first() != &x.second()
        };

        template <class T0, class T1>
        struct compressed_pair_selector<T0, T1, false, false, true>
        {
            static const std::size_t value = 2; // only T1 can be compressed or T0 and T1 can be compressed but should has different addresses: &x.first() != &x.second()
        };

        template <class T0, class T1>
        struct compressed_pair_selector<T0, T1, true, true, true>
        {
            static const std::size_t value = 1; // only T0 can be compressed or T0 and T1 can be compressed but should has different addresses: &x.first() != &x.second()
        };

        template <class T0, class T1>
        struct compressed_pair_selector<T0, T1, true, false, false>
        {
            static const std::size_t value = 0; // T0 and T1 can not be compressed or should not be compressed
        };

        template <class T0, class T1, std::size_t instance_index> class compressed_pair_imp;

        // T0 and T1 can not be compressed or should not be compressed

        template <class T0, class T1>
        class compressed_pair_imp<T0, T1, 0>
        {
        public:
            using first_type                = T0;
            using second_type               = T1;
            using first_param_type          = typename utility::call_traits<first_type>::param_type;
            using second_param_type         = typename utility::call_traits<second_type>::param_type;
            using first_reference           = typename utility::call_traits<first_type>::reference;
            using second_reference          = typename utility::call_traits<second_type>::reference;
            using first_const_reference     = typename utility::call_traits<first_type>::const_reference;
            using second_const_reference    = typename utility::call_traits<second_type>::const_reference;

            FORCE_INLINE compressed_pair_imp()
            {
            }

            FORCE_INLINE compressed_pair_imp(first_param_type x, second_param_type y) :
                first_(x), second_(y)
            {
            }

            FORCE_INLINE compressed_pair_imp(first_param_type x) :
                first_(x)
            {
            }

            FORCE_INLINE compressed_pair_imp(second_param_type y) :
                second_(y)
            {
            }

            FORCE_INLINE first_reference first()
            {
                return first_;
            }

            FORCE_INLINE first_const_reference first() const
            {
                return first_;
            }

            FORCE_INLINE second_reference second()
            {
                return second_;
            }

            FORCE_INLINE second_const_reference second() const
            {
                return second_;
            }

            FORCE_INLINE void swap(compressed_pair<T0, T1> & y)
            {
                std::swap(first_, y.first());
                std::swap(second_, y.second());
            }

        private:
            first_type  first_;
            second_type second_;
        };

        // only T0 can be compressed or T0 and T1 can be compressed but should has different addresses: &x.first() != &x.second()

        template <class T0, class T1>
        class compressed_pair_imp<T0, T1, 1> :
            protected std::remove_cv<T0>::type
        {
        public:
            using base_type                 = typename std::remove_cv<T0>::type;

            using first_type                = T0;
            using second_type               = T1;
            using first_param_type          = typename utility::call_traits<first_type>::param_type;
            using second_param_type         = typename utility::call_traits<second_type>::param_type;
            using first_reference           = typename utility::call_traits<first_type>::reference;
            using second_reference          = typename utility::call_traits<second_type>::reference;
            using first_const_reference     = typename utility::call_traits<first_type>::const_reference;
            using second_const_reference    = typename utility::call_traits<second_type>::const_reference;

            FORCE_INLINE compressed_pair_imp()
            {
            }

            FORCE_INLINE compressed_pair_imp(first_param_type x, second_param_type y) :
                base_type(x), second_(y)
            {
            }

            FORCE_INLINE compressed_pair_imp(first_param_type x) :
                base_type(x)
            {
            }

            FORCE_INLINE compressed_pair_imp(second_param_type y) :
                second_(y)
            {
            }

            FORCE_INLINE first_reference first()
            {
                return *this;
            }

            FORCE_INLINE first_const_reference first() const
            {
                return *this;
            }

            FORCE_INLINE second_reference second()
            {
                return second_;
            }

            FORCE_INLINE second_const_reference second() const
            {
                return second_;
            }

            FORCE_INLINE void swap(compressed_pair<T0,T1> & y)
            {
                // first_ is empty here
                std::swap(second_, y.second());
            }

        private:
            second_type second_;
        };

        // only T1 can be compressed or T0 and T1 can be compressed but should has different addresses: &x.first() != &x.second()

        template <class T0, class T1>
        class compressed_pair_imp<T0, T1, 2> :
            protected std::remove_cv<T1>::type
        {
        public:
            using base_type                 = typename std::remove_cv<T1>::type;

            using first_type                = T0;
            using second_type               = T1;
            using first_param_type          = typename utility::call_traits<first_type>::param_type;
            using second_param_type         = typename utility::call_traits<second_type>::param_type;
            using first_reference           = typename utility::call_traits<first_type>::reference;
            using second_reference          = typename utility::call_traits<second_type>::reference;
            using first_const_reference     = typename utility::call_traits<first_type>::const_reference;
            using second_const_reference    = typename utility::call_traits<second_type>::const_reference;

            FORCE_INLINE compressed_pair_imp()
            {
            }

            FORCE_INLINE compressed_pair_imp(first_param_type x, second_param_type y) :
                base_type(y), first_(x)
            {
            }

            FORCE_INLINE compressed_pair_imp(first_param_type x) :
                first_(x)
            {
            }

            FORCE_INLINE compressed_pair_imp(second_param_type y) :
                base_type(y)
            {
            }

            FORCE_INLINE first_reference first()
            {
                return first_;
            }

            FORCE_INLINE first_const_reference first() const
            {
                return first_;
            }

            FORCE_INLINE second_reference second()
            {
                return *this;
            }

            FORCE_INLINE second_const_reference second() const
            {
                return *this;
            }

            FORCE_INLINE void swap(compressed_pair<T0,T1> & y)
            {
                // seconds_ is empty here
                std::swap(first_, y.first());
            }

        private:
            first_type first_;
        };

        // T0 and T1 can be compressed and may has same addresses: &x.first() == &x.second()

        template <class T0, class T1>
        class compressed_pair_imp<T0, T1, 3> :
            protected std::remove_cv<T0>::type,
            protected std::remove_cv<T1>::type
        {
        public:
            using base_type0                = typename std::remove_cv<T0>::type;
            using base_type1                = typename std::remove_cv<T1>::type;

            using first_type                = T0;
            using second_type               = T1;
            using first_param_type          = typename utility::call_traits<first_type>::param_type;
            using second_param_type         = typename utility::call_traits<second_type>::param_type;
            using first_reference           = typename utility::call_traits<first_type>::reference;
            using second_reference          = typename utility::call_traits<second_type>::reference;
            using first_const_reference     = typename utility::call_traits<first_type>::const_reference;
            using second_const_reference    = typename utility::call_traits<second_type>::const_reference;

            FORCE_INLINE compressed_pair_imp()
            {
            }

            FORCE_INLINE compressed_pair_imp(first_param_type x, second_param_type y) :
                base_type0(x), base_type1(y)
            {
            }

            FORCE_INLINE compressed_pair_imp(first_param_type x) :
                base_type0(x)
            {
            }

            FORCE_INLINE compressed_pair_imp(second_param_type y) :
                base_type1(y)
            {
            }

            FORCE_INLINE first_reference first()
            {
                return *this;
            }

            FORCE_INLINE first_const_reference first() const
            {
                return *this;
            }

            FORCE_INLINE second_reference second()
            {
                return *this;
            }

            FORCE_INLINE second_const_reference second() const
            {
                return *this;
            }

            FORCE_INLINE void swap(compressed_pair<T0,T1> &)
            {
                // first_ and seconds_ are empty here
            }
        };
    }

    template <class T0, class T1>
    class compressed_pair :
        private details::compressed_pair_imp<T0, T1, details::compressed_pair_selector<
            T0,
            T1,
            std::is_same<typename std::remove_cv<T0>::type, typename std::remove_cv<T1>::type>::value,
            std::is_empty<T0>::value,
            std::is_empty<T1>::value>::value
        >
    {
    private:
        using base_type = details::compressed_pair_imp<T0, T1, details::compressed_pair_selector<
            T0,
            T1,
            std::is_same<typename std::remove_cv<T0>::type, typename std::remove_cv<T1>::type>::value,
            std::is_empty<T0>::value,
            std::is_empty<T1>::value>::value
        >;

    public:
        using first_type                = T0;
        using second_type               = T1;
        using first_param_type          = typename utility::call_traits<first_type>::param_type;
        using second_param_type         = typename utility::call_traits<second_type>::param_type;
        using first_reference           = typename utility::call_traits<first_type>::reference;
        using second_reference          = typename utility::call_traits<second_type>::reference;
        using first_const_reference     = typename utility::call_traits<first_type>::const_reference;
        using second_const_reference    = typename utility::call_traits<second_type>::const_reference;

        FORCE_INLINE compressed_pair() :
            base_type()
        {
        }

        FORCE_INLINE compressed_pair(first_param_type x, second_param_type y) :
            base_type(x, y)
        {
        }

        FORCE_INLINE explicit compressed_pair(first_param_type x) :
            base_type(x)
        {
        }

        FORCE_INLINE explicit compressed_pair(second_param_type y) :
            base_type(y)
        {
        }

        FORCE_INLINE first_reference first()
        {
            return base_type::first();
        }

        FORCE_INLINE first_const_reference first() const
        {
            return base_type::first();
        }

        FORCE_INLINE second_reference second()
        {
            return base_type::second();
        }

        FORCE_INLINE second_const_reference second() const
        {
            return base_type::second();
        }

        FORCE_INLINE void swap(compressed_pair & p)
        {
            base_type::swap(p);
        }
    };

    template <class T>
    class compressed_pair<T, T> :
        private details::compressed_pair_imp<T, T, details::compressed_pair_selector<
            T,
            T,
            std::is_same<typename std::remove_cv<T>::type, typename std::remove_cv<T>::type>::value,
            std::is_empty<T>::value,
            std::is_empty<T>::value>::value
        >
    {
    private:
       using base_type = details::compressed_pair_imp<T, T, details::compressed_pair_selector<
            T,
            T,
            std::is_same<typename std::remove_cv<T>::type, typename std::remove_cv<T>::type>::value,
            std::is_empty<T>::value,
            std::is_empty<T>::value>::value
        >;

    public:
        using first_type                = T;
        using second_type               = T;
        using first_param_type          = typename utility::call_traits<first_type>::param_type;
        using second_param_type         = typename utility::call_traits<second_type>::param_type;
        using first_reference           = typename utility::call_traits<first_type>::reference;
        using second_reference          = typename utility::call_traits<second_type>::reference;
        using first_const_reference     = typename utility::call_traits<first_type>::const_reference;
        using second_const_reference    = typename utility::call_traits<second_type>::const_reference;

        FORCE_INLINE compressed_pair() :
            base_type()
        {
        }

        FORCE_INLINE compressed_pair(first_param_type x, second_param_type y) :
            base_type(x, y)
        {
        }

        FORCE_INLINE explicit compressed_pair(first_param_type x) :
            base_type(x)
        {
        }

        FORCE_INLINE first_reference first()
        {
            return base_type::first();
        }

        FORCE_INLINE first_const_reference first() const
        {
            return base_type::first();
        }

        FORCE_INLINE second_reference second()
        {
            return base_type::second();
        }

        FORCE_INLINE second_const_reference second() const
        {
            return base_type::second();
        }

        FORCE_INLINE void swap(compressed_pair<T,T> & p)
        {
            base_type::swap(p);
        }
    };

    template <class T0, class T1>
    FORCE_INLINE void swap(compressed_pair<T0, T1> & x, compressed_pair<T0, T1> & y)
    {
       x.swap(y);
    }
}

#endif
