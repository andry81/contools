#pragma once

#include <tacklelib/tacklelib.hpp>

#include <tacklelib/utility/preprocessor.hpp>
#include <tacklelib/utility/platform.hpp>
#include <tacklelib/utility/type_traits.hpp>

#include <fmt/format.h>

#include <memory>
#include <stdexcept>
#include <functional>
#include <utility>


namespace tackle
{
    template <typename T>
    class SmartHandle;

    template <typename T, typename R = bool, typename Base = std::default_delete<T> >
    class ReleaseDeleter;

    // deleting `void*` is undefined
    template <>
    class SmartHandle<void>;

    template <typename R, typename Base>
    class ReleaseDeleter<void, R, Base>;

    using ReleaseDeleterFunc = std::function<void(void *)>; // to pass everything behaving like a function

    // * not thread safe deleter with release support
    // * the deleter by user type together with the deleter by user value, the deleter by user value has priority
    template <typename T, typename R, typename Base>
    class ReleaseDeleter : private Base {
    public:
        // external release state:
        //  1. should be initialized before the deleter holder
        //  2. must be shared pointer to avoid delete of deleted memory
        //  3. must be constructed through the std::make_shared to reduce memory allocation calls
        //  4. if needs to avoid the deleter then must be true
        //  5. if needs to be thread safe with the holder, then must be either atomic or it's assignment should be
        //     strictly ordered before a call to the holder release function!
        using ReleaseStateSharedPtr = std::shared_ptr<R>;

        FORCE_INLINE ReleaseDeleter(ReleaseStateSharedPtr release_state_ptr, ReleaseDeleterFunc deleter = nullptr) :
            m_release_state_ptr(std::move(release_state_ptr)),
            m_deleter(std::move(deleter))
        {}

        FORCE_INLINE ReleaseDeleter(const ReleaseDeleter &) = default;
        FORCE_INLINE ReleaseDeleter(ReleaseDeleter &&) = default;

        FORCE_INLINE ReleaseDeleter & operator =(const ReleaseDeleter &) = default;
        FORCE_INLINE ReleaseDeleter & operator =(ReleaseDeleter &&) = default;

        FORCE_INLINE void operator()(T * ptr)
        {
            if (*m_release_state_ptr.get()) return; // pointer has been released
            if (m_deleter) {
                m_deleter(ptr);
            }
            else {
                return Base::operator()(ptr);
            }
        }

        FORCE_INLINE const ReleaseStateSharedPtr & get_state() const
        {
            return m_release_state_ptr;
        }

        FORCE_INLINE const ReleaseDeleterFunc & get_deleter() const
        {
            return m_deleter;
        }

        FORCE_INLINE void set_state(bool state)
        {
            auto * p = m_release_state_ptr.get();
            if (!p) {
                DEBUG_BREAK_THROW(true) std::runtime_error(fmt::format("{:s}({:u}): deleter state is not allocated",
                    UTILITY_PP_FUNCSIG, UTILITY_PP_LINE));
            }

            *p = state;
        }

        // deleter can reset ONLY together with the state
        FORCE_INLINE void reset(ReleaseStateSharedPtr release_state_ptr, ReleaseDeleterFunc deleter)
        {
            m_release_state_ptr = std::move(release_state_ptr);
            m_deleter = std::move(deleter);
        }

    private:
        ReleaseStateSharedPtr   m_release_state_ptr;
        ReleaseDeleterFunc      m_deleter;
    };

    template <typename T>
    class SmartHandle
    {
    private:
        using SharedPtr     = std::shared_ptr<void>;

    public:
        using DeleterType   = ReleaseDeleter<T>;

    protected:
        FORCE_INLINE SmartHandle(T * p = 0, ReleaseDeleterFunc deleter_func = nullptr);
        FORCE_INLINE SmartHandle(T * p, DeleterType deleter); // to call from derived implementation

    public:
        FORCE_INLINE SmartHandle(const SmartHandle &) = default;
        FORCE_INLINE SmartHandle(SmartHandle &&) = default;

        FORCE_INLINE SmartHandle & operator =(const SmartHandle &) = default;
        FORCE_INLINE SmartHandle & operator =(SmartHandle &&) = default;

        FORCE_INLINE ~SmartHandle();

    protected:
        FORCE_INLINE void reset(T * p = 0, ReleaseDeleterFunc deleter = nullptr);
        FORCE_INLINE void reset(T * p, DeleterType deleter); // to call from derived implementation

    public:
        FORCE_INLINE operator bool() const;

        FORCE_INLINE T * detach();
        FORCE_INLINE T * get() const;

    protected:
        SharedPtr   m_pv;
    };

    template <typename T>
    FORCE_INLINE SmartHandle<T>::SmartHandle(T * p, ReleaseDeleterFunc deleter_func) :
        // does not release (false) by default
        m_pv(p, DeleterType(std::make_shared<bool>(bool(false)), std::move(deleter_func)))
    {
    }

    template <typename T>
    FORCE_INLINE SmartHandle<T>::SmartHandle(T * p, DeleterType deleter) :
        m_pv(p, std::move(deleter))
    {
    }

    template <typename T>
    FORCE_INLINE SmartHandle<T>::~SmartHandle()
    {
    }

    template <typename T>
    FORCE_INLINE void SmartHandle<T>::reset(T * p, ReleaseDeleterFunc deleter_func)
    {
        // does not release (false) by default
        m_pv.reset(p, DeleterType(std::make_shared<bool>(bool(false)), std::move(deleter_func)));
    }

    template <typename T>
    FORCE_INLINE void SmartHandle<T>::reset(T * p, DeleterType deleter)
    {
        m_pv.reset(p, std::move(deleter));
    }

    template <typename T>
    FORCE_INLINE SmartHandle<T>::operator bool() const
    {
        return m_pv.get() ? true : false;
    }

    template <typename T>
    FORCE_INLINE T * SmartHandle<T>::detach()
    {
        auto * deleter = std::get_deleter<DeleterType>(m_pv);
        if (deleter) {
            // if needs to be thread safe, then this line must be either atomic or strictly ordered before the release call!
            deleter->set_state(true);
        }

        T * p_detached = get();

        m_pv.reset(); // call with release

        return p_detached;
    }

    template <typename T>
    FORCE_INLINE T * SmartHandle<T>::get() const
    {
        return static_cast<T *>(m_pv.get());
    }
}
