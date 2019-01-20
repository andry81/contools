#pragma once

// "max_aligned_storage_decl.hpp" must be already included here!
#ifndef TACKLE_MAX_ALIGNED_STORAGE_DECL_HPP
#error You must include declaration header "max_aligned_storage_decl.hpp" at first!
#endif


namespace tackle
{
    //// max_aligned_storage_from_mpl_container

    //#undef UTILITY_PP_LINE_TERMINATOR
    #define TACKLE_PP_REPEAT_INVOKE_MACRO_BY_TYPE_INDEX(z, n, macro_text) \
        case n: { UTILITY_PP_LINE_TERMINATOR\
            using storage_type_t = typename mpl::if_<mpl::less<mpl::size_t<n>, mpl::size_t<num_types_t::value> >, mpl::at<storage_types_t, mpl::int_<n> >, mpl::void_>::type::type; UTILITY_PP_LINE_TERMINATOR\
            macro_text(z, n); UTILITY_PP_LINE_TERMINATOR\
        } break; UTILITY_PP_LINE_TERMINATOR

    // for binary operators
    #define TACKLE_PP_REPEAT_INVOKE_RIGHT_MACRO_BY_TYPE_INDEX(z, n, macro_text) \
        case n: { UTILITY_PP_LINE_TERMINATOR\
            using right_storage_type_t = typename mpl::if_<mpl::less<mpl::size_t<n>, mpl::size_t<num_types_t::value> >, mpl::at<storage_types_t, mpl::int_<n> >, mpl::void_>::type::type; UTILITY_PP_LINE_TERMINATOR\
            macro_text(z, n); UTILITY_PP_LINE_TERMINATOR\
        } break; UTILITY_PP_LINE_TERMINATOR

    #define TACKLE_PP_CONSTRUCT_MACRO(z, n) \
        if (UTILITY_CONST_EXPR(n < num_types_t::value)) { \
            if (utility::construct_dispatcher<n, storage_type_t, (n < num_types_t::value)>:: \
                construct_default(utility::addressof(m_storage), UTILITY_PP_FUNCSIG, \
                    "%s: storage type is not default constructable: Type=\"%s\"")) { \
                m_type_index = type_index; \
            } \
        } else goto default_

    // direct construction and destruction of the storage
    template <typename t_mpl_container_types, typename t_tag_pttn_type>
    inline void max_aligned_storage_from_mpl_container<t_mpl_container_types, t_tag_pttn_type>::construct_default(int type_index, bool reconstruct)
    {
        DEBUG_ASSERT_TRUE(reconstruct || !is_constructed()); // must be not constructed!
        if (reconstruct && is_constructed()) { // if already been constructed
            destruct();
        }

        switch (type_index)
        {
            BOOST_PP_REPEAT(TACKLE_PP_MAX_NUM_ALIGNED_STORAGE_TYPES, TACKLE_PP_REPEAT_INVOKE_MACRO_BY_TYPE_INDEX, TACKLE_PP_CONSTRUCT_MACRO)

        default_:;
            default: {
                DEBUG_BREAK_THROW(true) std::runtime_error(
                    fmt::format("{:s}({:d}): invalid type index: type_index={:d}",
                        UTILITY_PP_FUNCSIG, UTILITY_PP_LINE, type_index));
            }
        }
    }

    #undef TACKLE_PP_CONSTRUCT_MACRO

    #define TACKLE_PP_CONSTRUCT_MACRO(z, n) \
        if (UTILITY_CONST_EXPR(n < num_types_t::value)) { \
            if (utility::construct_dispatcher<n, storage_type_t, (n < num_types_t::value)>:: \
                construct(utility::addressof(m_storage), r, UTILITY_PP_FUNCSIG, \
                    "%s: storage type is not constructable by reference value: Type=\"%s\" Ref=\"%s\"")) { \
                m_type_index = type_index; \
            } \
        } else goto default_

    template <typename t_mpl_container_types, typename t_tag_pttn_type> template <typename Ref>
    inline void max_aligned_storage_from_mpl_container<t_mpl_container_types, t_tag_pttn_type>::construct(int type_index, const Ref & r, bool reconstruct)
    {
        DEBUG_ASSERT_TRUE(reconstruct || !is_constructed()); // must be not constructed!
        if (reconstruct && is_constructed()) { // if already been constructed
            destruct();
        }

        switch (type_index)
        {
            BOOST_PP_REPEAT(TACKLE_PP_MAX_NUM_ALIGNED_STORAGE_TYPES, TACKLE_PP_REPEAT_INVOKE_MACRO_BY_TYPE_INDEX, TACKLE_PP_CONSTRUCT_MACRO)

        default_:;
            default: {
                DEBUG_BREAK_THROW(true) std::runtime_error(
                    fmt::format("{:s}({:d}): invalid type index: type_index={:d}",
                        UTILITY_PP_FUNCSIG, UTILITY_PP_LINE, type_index));
            }
        }
    }

    #undef TACKLE_PP_CONSTRUCT_MACRO

    #define TACKLE_PP_CONSTRUCT_XREF_MACRO(z, n) \
        if (UTILITY_CONST_EXPR(n < num_types_t::value)) { \
            if (utility::construct_dispatcher<n, storage_type_t, (n < num_types_t::value)>:: \
                construct(utility::addressof(m_storage), std::forward<Ref>(r), UTILITY_PP_FUNCSIG, \
                    "%s: storage type is not constructable by reference value: Type=\"%s\" Ref=\"%s\"")) { \
                m_type_index = type_index; \
            } \
        } else goto default_

    template <typename t_mpl_container_types, typename t_tag_pttn_type> template <typename Ref>
    inline void max_aligned_storage_from_mpl_container<t_mpl_container_types, t_tag_pttn_type>::construct(int type_index, Ref && r, bool reconstruct)
    {
        DEBUG_ASSERT_TRUE(reconstruct || !is_constructed()); // must be not constructed!
        if (reconstruct && is_constructed()) { // if already been constructed
            destruct();
        }

        switch (type_index)
        {
            BOOST_PP_REPEAT(TACKLE_PP_MAX_NUM_ALIGNED_STORAGE_TYPES, TACKLE_PP_REPEAT_INVOKE_MACRO_BY_TYPE_INDEX, TACKLE_PP_CONSTRUCT_XREF_MACRO)

        default_:;
            default: {
                DEBUG_BREAK_THROW(true) std::runtime_error(
                    fmt::format("{:s}({:d}): invalid type index: type_index={:d}",
                        UTILITY_PP_FUNCSIG, UTILITY_PP_LINE, type_index));
            }
        }
    }

    #undef TACKLE_PP_CONSTRUCT_XREF_MACRO

    #define TACKLE_PP_CONSTRUCT_MACRO(z, n) \
        if (UTILITY_CONST_EXPR(n < num_types_t::value)) { \
            ::new (utility::addressof(m_storage)) storage_type_t(*utility::cast_addressof<const storage_type_t *>(s)); \
            m_type_index = s.m_type_index; \
        } else goto default_

    template <typename t_mpl_container_types, typename t_tag_pttn_type>
    FORCE_INLINE void max_aligned_storage_from_mpl_container<t_mpl_container_types, t_tag_pttn_type>::_construct(const max_aligned_storage_from_mpl_container & s, bool reconstruct)
    {
        if (!s.is_constructed()) goto default_;

        DEBUG_ASSERT_TRUE(reconstruct || !is_constructed()); // must be not constructed!
        if (reconstruct && is_constructed()) { // if already been constructed
            destruct();
        }

        switch (s.m_type_index)
        {
            BOOST_PP_REPEAT(TACKLE_PP_MAX_NUM_ALIGNED_STORAGE_TYPES, TACKLE_PP_REPEAT_INVOKE_MACRO_BY_TYPE_INDEX, TACKLE_PP_CONSTRUCT_MACRO)

        default_:;
            default: {
                DEBUG_BREAK_THROW(true) std::runtime_error(
                    fmt::format("{:s}({:d}): invalid storage construction: to_type_index={:d} from_type_index={:d}",
                        UTILITY_PP_FUNCSIG, UTILITY_PP_LINE, m_type_index, s.m_type_index));
            }
        }
    }

    #undef TACKLE_PP_CONSTRUCT_MACRO

    #define TACKLE_PP_CONSTRUCT_XREF_MACRO(z, n) \
        if (UTILITY_CONST_EXPR(n < num_types_t::value)) { \
            ::new (utility::addressof(m_storage)) storage_type_t(std::move(*utility::cast_addressof<const storage_type_t *>(s))); \
            m_type_index = s.m_type_index; \
        } else goto default_

    template <typename t_mpl_container_types, typename t_tag_pttn_type>
    FORCE_INLINE void max_aligned_storage_from_mpl_container<t_mpl_container_types, t_tag_pttn_type>::_construct(max_aligned_storage_from_mpl_container && s, bool reconstruct)
    {
        if (!s.is_constructed()) goto default_;

        DEBUG_ASSERT_TRUE(reconstruct || !is_constructed()); // must be not constructed!
        if (reconstruct && is_constructed()) { // if already been constructed
            destruct();
        }

        switch (s.m_type_index)
        {
            BOOST_PP_REPEAT(TACKLE_PP_MAX_NUM_ALIGNED_STORAGE_TYPES, TACKLE_PP_REPEAT_INVOKE_MACRO_BY_TYPE_INDEX, TACKLE_PP_CONSTRUCT_XREF_MACRO)

        default_:;
            default: {
                DEBUG_BREAK_THROW(true) std::runtime_error(
                    fmt::format("{:s}({:d}): invalid storage construction: to_type_index={:d} from_type_index={:d}",
                        UTILITY_PP_FUNCSIG, UTILITY_PP_LINE, m_type_index, s.m_type_index));
            }
        }
    }

    #undef TACKLE_PP_CONSTRUCT_XREF_MACRO

    #define TACKLE_PP_DESTRUCT_MACRO(z, n) \
        if (UTILITY_CONST_EXPR(n < num_types_t::value)) { \
            m_type_index = -1; \
            utility::cast_addressof<storage_type_t *>(m_storage)->storage_type_t::~storage_type_t(); \
        } else goto default_

    template <typename t_mpl_container_types, typename t_tag_pttn_type>
    FORCE_INLINE void max_aligned_storage_from_mpl_container<t_mpl_container_types, t_tag_pttn_type>::destruct()
    {
        switch (m_type_index)
        {
            BOOST_PP_REPEAT(TACKLE_PP_MAX_NUM_ALIGNED_STORAGE_TYPES, TACKLE_PP_REPEAT_INVOKE_MACRO_BY_TYPE_INDEX, TACKLE_PP_DESTRUCT_MACRO)

        default_:;
            default: {
                DEBUG_BREAK_THROW(true) std::runtime_error(
                    fmt::format("{:s}({:d}): invalid type index: type_index={:d}",
                        UTILITY_PP_FUNCSIG, UTILITY_PP_LINE, m_type_index));
            }
        }
    }

    #undef TACKLE_PP_DESTRUCT_MACRO

    #define TACKLE_PP_ASSIGN_MACRO_LEFT(z, n) \
        if (UTILITY_CONST_EXPR(n < num_types_t::value)) { \
            auto & left_value = *utility::cast_addressof<storage_type_t *>(m_storage); \
            switch (s.type_index()) \
            { \
                BOOST_PP_CAT(BOOST_PP_REPEAT_, z)(TACKLE_PP_MAX_NUM_ALIGNED_STORAGE_TYPES, TACKLE_PP_REPEAT_INVOKE_RIGHT_MACRO_BY_TYPE_INDEX, TACKLE_PP_ASSIGN_MACRO_RIGHT) \
                \
                default: goto default_; \
            } \
        } else goto default_

    #define TACKLE_PP_ASSIGN_MACRO_RIGHT(z, n) \
        if (UTILITY_CONST_EXPR(n < num_types_t::value)) { \
            const auto & right_value = *utility::cast_addressof<const right_storage_type_t *>(s); \
            utility::assign_dispatcher<right_storage_type_t, storage_type_t, true>:: \
                call(left_value, right_value, UTILITY_PP_FUNCSIG, \
                    "%s: From type is not convertible to the To type: From=\"%s\" To=\"%s\"", throw_exceptions_on_type_error); \
        } \
        else goto default_

    template <typename t_mpl_container_types, typename t_tag_pttn_type>
    inline max_aligned_storage_from_mpl_container<t_mpl_container_types, t_tag_pttn_type> &
        max_aligned_storage_from_mpl_container<t_mpl_container_types, t_tag_pttn_type>::_assign(const max_aligned_storage_from_mpl_container & s, bool throw_exceptions_on_type_error)
    {
        // containers must be already constructed before the assign
        if (!is_constructed() || !s.is_constructed()) goto default_;

        switch (m_type_index)
        {
            BOOST_PP_REPEAT(TACKLE_PP_MAX_NUM_ALIGNED_STORAGE_TYPES, TACKLE_PP_REPEAT_INVOKE_MACRO_BY_TYPE_INDEX, TACKLE_PP_ASSIGN_MACRO_LEFT)

        default_:;
            default: if(throw_exceptions_on_type_error) {
                DEBUG_BREAK_THROW(true) std::runtime_error(
                    fmt::format("{:s}({:d}): invalid storage assign: to_type_index={:d} from_type_index={:d}",
                        UTILITY_PP_FUNCSIG, UTILITY_PP_LINE, m_type_index, s.m_type_index));
            }
        }

        return *this;
    }

    #undef TACKLE_PP_ASSIGN_MACRO_RIGHT
    #undef TACKLE_PP_ASSIGN_MACRO_LEFT

    #define TACKLE_PP_ASSIGN_XREF_MACRO_LEFT(z, n) \
        if (UTILITY_CONST_EXPR(n < num_types_t::value)) { \
            auto & left_value = *utility::cast_addressof<storage_type_t *>(m_storage); \
            switch (s.type_index()) \
            { \
                BOOST_PP_CAT(BOOST_PP_REPEAT_, z)(TACKLE_PP_MAX_NUM_ALIGNED_STORAGE_TYPES, TACKLE_PP_REPEAT_INVOKE_RIGHT_MACRO_BY_TYPE_INDEX, TACKLE_PP_ASSIGN_XREF_MACRO_RIGHT) \
                \
                default: goto default_; \
            } \
        } else goto default_

    #define TACKLE_PP_ASSIGN_XREF_MACRO_RIGHT(z, n) \
        if (UTILITY_CONST_EXPR(n < num_types_t::value)) { \
            auto && right_value = std::move(*utility::cast_addressof<const right_storage_type_t *>(s)); \
            utility::assign_dispatcher<right_storage_type_t, storage_type_t, true>:: \
                call(left_value, right_value, UTILITY_PP_FUNCSIG, \
                    "%s: From type is not convertible to the To type: From=\"%s\" To=\"%s\"", throw_exceptions_on_type_error); \
        } \
        else goto default_

    template <typename t_mpl_container_types, typename t_tag_pttn_type>
    inline max_aligned_storage_from_mpl_container<t_mpl_container_types, t_tag_pttn_type> &
        max_aligned_storage_from_mpl_container<t_mpl_container_types, t_tag_pttn_type>::_assign(max_aligned_storage_from_mpl_container && s, bool throw_exceptions_on_type_error)
    {
        // containers must be already constructed before the assign
        if (!is_constructed() || !s.is_constructed()) goto default_;

        switch (m_type_index)
        {
            BOOST_PP_REPEAT(TACKLE_PP_MAX_NUM_ALIGNED_STORAGE_TYPES, TACKLE_PP_REPEAT_INVOKE_MACRO_BY_TYPE_INDEX, TACKLE_PP_ASSIGN_XREF_MACRO_LEFT)

        default_:;
            default: if(throw_exceptions_on_type_error) {
                DEBUG_BREAK_THROW(true) std::runtime_error(
                    fmt::format("{:s}({:d}): invalid storage assign: to_type_index={:d} from_type_index={:d}",
                        UTILITY_PP_FUNCSIG, UTILITY_PP_LINE, m_type_index, s.m_type_index));
            }
        }

        return *this;
    }

    #undef TACKLE_PP_ASSIGN_XREF_MACRO_RIGHT
    #undef TACKLE_PP_ASSIGN_XREF_MACRO_LEFT

    #define TACKLE_PP_ASSIGN_MACRO_LEFT(z, n) \
        if (UTILITY_CONST_EXPR(n < num_types_t::value)) { \
            auto & left_value = *utility::cast_addressof<storage_type_t *>(m_storage); \
            utility::assign_dispatcher<Ref, storage_type_t, true>:: \
                call(left_value, r, UTILITY_PP_FUNCSIG, \
                    "%s: From type is not convertible to the To type: From=\"%s\" To=\"%s\"", throw_exceptions_on_type_error); \
        } else goto default_

    template <typename t_mpl_container_types, typename t_tag_pttn_type> template <typename Ref>
    inline max_aligned_storage_from_mpl_container<t_mpl_container_types, t_tag_pttn_type> &
        max_aligned_storage_from_mpl_container<t_mpl_container_types, t_tag_pttn_type>::assign(const Ref & r, bool throw_exceptions_on_type_error)
    {
        // container must be already constructed before the assign
        if (!is_constructed()) goto default_;

        switch (m_type_index)
        {
            BOOST_PP_REPEAT(TACKLE_PP_MAX_NUM_ALIGNED_STORAGE_TYPES, TACKLE_PP_REPEAT_INVOKE_MACRO_BY_TYPE_INDEX, TACKLE_PP_ASSIGN_MACRO_LEFT)

        default_:;
            default: if(throw_exceptions_on_type_error) {
                DEBUG_BREAK_THROW(true) std::runtime_error(
                    fmt::format("{:s}({:d}): invalid storage assign: type_index={:d}",
                        UTILITY_PP_FUNCSIG, UTILITY_PP_LINE, m_type_index));
            }
        }

        return *this;
    }

    #undef TACKLE_PP_ASSIGN_MACRO_LEFT

    #define TACKLE_PP_ASSIGN_XREF_MACRO_LEFT(z, n) \
        if (UTILITY_CONST_EXPR(n < num_types_t::value)) { \
            auto & left_value = *utility::cast_addressof<storage_type_t *>(m_storage); \
            utility::assign_dispatcher<Ref, storage_type_t, true>:: \
                call(left_value, std::forward<Ref>(r), UTILITY_PP_FUNCSIG, \
                    "%s: From type is not convertible to the To type: From=\"%s\" To=\"%s\"", throw_exceptions_on_type_error); \
        } else goto default_

    template <typename t_mpl_container_types, typename t_tag_pttn_type> template <typename Ref>
    inline max_aligned_storage_from_mpl_container<t_mpl_container_types, t_tag_pttn_type> &
        max_aligned_storage_from_mpl_container<t_mpl_container_types, t_tag_pttn_type>::assign(Ref && r, bool throw_exceptions_on_type_error)
    {
        // container must be already constructed before the assign
        if (!is_constructed()) goto default_;

        switch (m_type_index)
        {
            BOOST_PP_REPEAT(TACKLE_PP_MAX_NUM_ALIGNED_STORAGE_TYPES, TACKLE_PP_REPEAT_INVOKE_MACRO_BY_TYPE_INDEX, TACKLE_PP_ASSIGN_XREF_MACRO_LEFT)

        default_:;
            default: if(throw_exceptions_on_type_error) {
                DEBUG_BREAK_THROW(true) std::runtime_error(
                    fmt::format("{:s}({:d}): invalid storage assign: type_index={:d}",
                        UTILITY_PP_FUNCSIG, UTILITY_PP_LINE, m_type_index));
            }
        }

        return *this;
    }

    #undef TACKLE_PP_ASSIGN_XREF_MACRO_LEFT

    #define TACKLE_PP_INVOKE_MACRO(z, n) \
        if (UTILITY_CONST_EXPR(n < num_types_t::value)) { \
            return utility::invoke_dispatcher<n, R, storage_types_t, mpl::find, storage_types_end_it_t, \
                n < num_types_t::value, utility::is_function_traits_extractable<decltype(functor)>::value>:: \
                call(functor, *utility::cast_addressof<storage_type_t *>(m_storage), UTILITY_PP_FUNCSIG, \
                    "%s: functor has not convertible first parameter type: From=\"%s\" To=\"%s\" Ret=\"%s\"", throw_exceptions_on_type_error); \
        } else goto default_

    template <typename t_mpl_container_types, typename t_tag_pttn_type> template <typename R, typename F>
    FORCE_INLINE R max_aligned_storage_from_mpl_container<t_mpl_container_types, t_tag_pttn_type>::invoke(F && functor, bool throw_exceptions_on_type_error)
    {
        switch (m_type_index)
        {
            BOOST_PP_REPEAT(TACKLE_PP_MAX_NUM_ALIGNED_STORAGE_TYPES, TACKLE_PP_REPEAT_INVOKE_MACRO_BY_TYPE_INDEX, TACKLE_PP_INVOKE_MACRO)

        default_:;
            default: if(throw_exceptions_on_type_error) {
                DEBUG_BREAK_THROW(true) std::runtime_error(
                    fmt::format("{:s}({:d}): invalid type index: type_index={:d}",
                        UTILITY_PP_FUNCSIG, UTILITY_PP_LINE, m_type_index));
            }
        }

        // CAUTION:
        //  After this point any usage of the return value is UB!
        //  The return value exists ONLY to remove requirement of the type default constructor existance, because underlaying
        //  storage of the type can be a late construction container.
        //

        return utility::unconstructed_value(utility::identity<R>());
    }

    #undef TACKLE_PP_INVOKE_MACRO

    #define TACKLE_PP_INVOKE_MACRO(z, n) \
        if (UTILITY_CONST_EXPR(n < num_types_t::value)) { \
            return utility::invoke_dispatcher<n, R, storage_types_t, mpl::find, storage_types_end_it_t, \
                n < num_types_t::value, utility::is_function_traits_extractable<decltype(functor)>::value>:: \
                call(functor, *utility::cast_addressof<const storage_type_t *>(m_storage), UTILITY_PP_FUNCSIG, \
                    "%s: functor has not convertible first parameter type: From=\"%s\" To=\"%s\" Ret=\"%s\"", throw_exceptions_on_type_error); \
        } else goto default_

    template <typename t_mpl_container_types, typename t_tag_pttn_type> template <typename R, typename F>
    FORCE_INLINE R max_aligned_storage_from_mpl_container<t_mpl_container_types, t_tag_pttn_type>::invoke(F && functor, bool throw_exceptions_on_type_error) const
    {
        switch (m_type_index)
        {
            BOOST_PP_REPEAT(TACKLE_PP_MAX_NUM_ALIGNED_STORAGE_TYPES, TACKLE_PP_REPEAT_INVOKE_MACRO_BY_TYPE_INDEX, TACKLE_PP_INVOKE_MACRO)

        default_:;
            default: if(throw_exceptions_on_type_error) {
                DEBUG_BREAK_THROW(true) std::runtime_error(
                    fmt::format("{:s}({:d}): invalid type index: type_index={:d}",
                        UTILITY_PP_FUNCSIG, UTILITY_PP_LINE, m_type_index));
            }
        }

        // CAUTION:
        //  After this point any usage of the return value is UB!
        //  The return value exists ONLY to remove requirement of the type default constructor existance, because underlaying
        //  storage of the type can be a late construction container.
        //

        return utility::unconstructed_value(utility::identity<R>());
    }

    #undef TACKLE_PP_INVOKE_MACRO

    #define TACKLE_PP_INVOKE_MACRO(z, n) \
        if (UTILITY_CONST_EXPR(n < num_types_t::value)) { \
            return utility::invoke_if_returnable_dispatcher<n, R, storage_types_t, mpl::find, storage_types_end_it_t, \
                (n < num_types_t::value), std::is_convertible<storage_type_t, unqual_return_type_t>::value>:: \
                call(functor, *utility::cast_addressof<storage_type_t *>(m_storage), UTILITY_PP_FUNCSIG, \
                    "%s: functor has not convertible first parameter type: From=\"%s\" To=\"%s\" Ret=\"%s\"", throw_exceptions_on_type_error); \
        } else goto default_

    template <typename t_mpl_container_types, typename t_tag_pttn_type> template <typename R, typename F>
    FORCE_INLINE R max_aligned_storage_from_mpl_container<t_mpl_container_types, t_tag_pttn_type>::invoke_if_returnable(F && functor, bool throw_exceptions_on_type_error)
    {
        // remove reference and qualificators to avoid cast issues like r-value cast to not constant reference
        using unqual_return_type_t = typename std::remove_cv<typename std::remove_reference<R>::type>::type;

        switch (m_type_index)
        {
            BOOST_PP_REPEAT(TACKLE_PP_MAX_NUM_ALIGNED_STORAGE_TYPES, TACKLE_PP_REPEAT_INVOKE_MACRO_BY_TYPE_INDEX, TACKLE_PP_INVOKE_MACRO)

        default_:;
            default: if(throw_exceptions_on_type_error) {
                DEBUG_BREAK_THROW(true) std::runtime_error(
                    fmt::format("{:s}({:d}): invalid type index: type_index={:d}",
                        UTILITY_PP_FUNCSIG, UTILITY_PP_LINE, m_type_index));
            }
        }

        // CAUTION:
        //  After this point any usage of the return value is UB!
        //  The return value exists ONLY to remove requirement of the type default constructor existance, because underlaying
        //  storage of the type can be a late construction container.
        //

        return utility::unconstructed_value(utility::identity<R>());
    }

    #undef TACKLE_PP_INVOKE_MACRO

    #define TACKLE_PP_INVOKE_MACRO(z, n) \
        if (UTILITY_CONST_EXPR(n < num_types_t::value)) { \
            return utility::invoke_if_returnable_dispatcher<n, R, storage_types_t, mpl::find, storage_types_end_it_t, \
                (n < num_types_t::value), std::is_convertible<storage_type_t, unqual_return_type_t>::value>:: \
                call(functor, *utility::cast_addressof<const storage_type_t *>(m_storage), UTILITY_PP_FUNCSIG, \
                    "%s: functor has not convertible first parameter type: From=\"%s\" To=\"%s\" Ret=\"%s\"", throw_exceptions_on_type_error); \
        } else goto default_

    template <typename t_mpl_container_types, typename t_tag_pttn_type> template <typename R, typename F>
    FORCE_INLINE R max_aligned_storage_from_mpl_container<t_mpl_container_types, t_tag_pttn_type>::invoke_if_returnable(F && functor, bool throw_exceptions_on_type_error) const
    {
        // remove reference and qualificators to avoid cast issues like r-value cast to not constant reference
        using unqual_return_type_t = typename std::remove_cv<typename std::remove_reference<R>::type>::type;

        switch (m_type_index)
        {
            BOOST_PP_REPEAT(TACKLE_PP_MAX_NUM_ALIGNED_STORAGE_TYPES, TACKLE_PP_REPEAT_INVOKE_MACRO_BY_TYPE_INDEX, TACKLE_PP_INVOKE_MACRO)

        default_:;
            default: if(throw_exceptions_on_type_error) {
                DEBUG_BREAK_THROW(true) std::runtime_error(
                    fmt::format("{:s}({:d}): invalid type index: type_index={:d}",
                        UTILITY_PP_FUNCSIG, UTILITY_PP_LINE, m_type_index));
            }
        }

        // CAUTION:
        //  After this point any usage of the return value is UB!
        //  The return value exists ONLY to remove requirement of the type default constructor existance, because underlaying
        //  storage of the type can be a late construction container.
        //

        return utility::unconstructed_value(utility::identity<R>());
    }

    #undef TACKLE_PP_INVOKE_MACRO

    #undef TACKLE_PP_REPEAT_INVOKE_MACRO_BY_TYPE_INDEX
    #undef TACKLE_PP_REPEAT_INVOKE_RIGHT_MACRO_BY_TYPE_INDEX
}
