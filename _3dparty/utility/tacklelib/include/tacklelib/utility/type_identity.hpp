#pragma once

// DO NOT REMOVE, exists to avoid private/public headers mixing!
#ifndef UTILITY_TYPE_IDENTITY_HPP
#define UTILITY_TYPE_IDENTITY_HPP

#include <tacklelib/tacklelib.hpp>

#include <tacklelib/utility/preprocessor.hpp>
#include <tacklelib/utility/platform.hpp>
#include <tacklelib/utility/static_assert.hpp> // required here only for UTILITY_STATIC_PARAM_LOOKUP_BY_ERROR macro

#include <cstdint>
#include <type_traits>
#include <tuple>


// to suppress warnings around compile time expressions or values
#define UTILITY_CONST_EXPR(exp) ::utility::const_expr<(exp) ? true : false>::value

// generates compilation error and shows real type name (and place of declaration in some cases) in an error message, useful for debugging boost::mpl like recurrent types
#define UTILITY_TYPENAME_LOOKUP_BY_ERROR(type_name) \
    using _type_lookup_t = decltype((*(typename ::utility::type_lookup<type_name >::type*)0).operator ,(*(::utility::_not_overloadable_type *)0))

// the macro only for msvc compiler which has more useful error output if a scope class and a type are separated from each other
#if defined(UTILITY_COMPILER_CXX_MSC)

#define UTILITY_TYPENAME_LOOKUP_BY_ERROR_CLASS(class_name, type_name) \
    using _type_lookup_t = decltype((*(typename ::utility::type_lookup<class_name >::type_name*)0).operator ,(*(::utility::_not_overloadable_type *)0))

#else

#define UTILITY_TYPENAME_LOOKUP_BY_ERROR_CLASS(class_name, type_name) \
    UTILITY_TYPENAME_LOOKUP_BY_ERROR(class_name::type_name)

#endif

// lookup compile time template typename value
#define UTILITY_STATIC_PARAM_LOOKUP_BY_ERROR(static_param) \
    UTILITY_TYPENAME_LOOKUP_BY_ERROR(STATIC_ASSERT_PARAM(static_param))

// lookup compile time size value
#define UTILITY_SIZE_LOOKUP_BY_ERROR(size) \
    char * __integral_lookup[size] = 1

// available in GCC from version 4.3, for details see: https://stackoverflow.com/questions/1625105/how-to-write-is-complete-template/1956217#1956217
//
#define UTILITY_IS_TYPE_COMPLETE(type) ::utility::is_type_complete<type, __COUNTER__>::value

// Checks expression on constexpr nature.
// Based on: https://stackoverflow.com/questions/13299394/is-is-constexpr-possible-in-c11/13305072#13305072
//
// CAUTION:
//
//  Where it does work:
//  * This will work at least in GCC 5.4 (C++11) and MSVC 2015 Update 3.
//  * This will work on functions with implementation.
//  * This will work on variables in any scope.
//
//  Where it does not work:
//  * This won't work, for example, in clang 3.8.0!
//  * This won't work on function declarations.
//  * This won't work on functions returning `void` (tip: all `constexpr` functions in C++11 must consist only from single and not a void return statement).
//
#define UTILITY_IS_CONSTEXPR_VALUE(...) noexcept(::utility::makeprval(__VA_ARGS__))

#define UTILITY_DEPENDENT_TYPENAME_COMPILE_ERROR_BY_INCOMPLETE_TYPE(dependent_type_name) \
    using UTILITY_PP_CONCAT(dependent_typename_compiler_error_by_incomplete_type_t, UTILITY_PP_LINE) = typename ::utility::incomplete_dependent_type<dependent_type_name>::type

#define UTILITY_STR_WITH_STATIC_SIZE_TUPLE(str)     str, (::utility::static_size(str))
#define UTILITY_STR_WITH_STATIC_LENGTH_TUPLE(str)   str, (::utility::static_size(str) - 1)

// Checks existence of member function.
// Based on: https://stackoverflow.com/questions/257288/is-it-possible-to-write-a-template-to-check-for-a-functions-existence/264088#264088
//

// detection of static or not static functions depended on FuncSignature template argument
#define DEFINE_UTILITY_MEMBER_FUNCTION_CHECKER_WITH_SIGNATURE(checker_name, func_name) \
    template<typename FuncScopeType, typename FuncSignature> \
    struct checker_name \
    { \
        static_assert(std::is_pointer<FuncSignature>::value || std::is_member_pointer<FuncSignature>::value, \
            "FuncSignature must be a pointer or pointer to member type"); \
        \
        using yes = char[1]; \
        using no  = char[2]; \
        \
        template <typename U_, U_> struct type_check_any; \
        template <typename T_>  static yes & check(type_check_any<FuncSignature, &T_::func_name> *); \
        template <typename>     static no & check(...); \
        \
        static CONSTEXPR const bool value = (sizeof(check<FuncScopeType>(nullptr)) == sizeof(yes)); \
    };

// detection of static only functions depended on FuncSignature template argument
#define DEFINE_UTILITY_STATIC_MEMBER_FUNCTION_CHECKER_WITH_SIGNATURE(checker_name, func_name) \
    template<typename FuncScopeType, typename FuncSignature> \
    struct checker_name \
    { \
        static_assert(!std::is_pointer<FuncSignature>::value && !std::is_member_pointer<FuncSignature>::value, \
            "FuncSignature must not be a pointer or pointer to member, use plain function type"); \
        \
        using yes = char[1]; \
        using no  = char[2]; \
        \
        template <typename U_, U_ *> struct type_check_free_pointer; \
        template <typename T_>  static yes & check(type_check_free_pointer<FuncSignature, &T_::func_name> *); \
        template <typename>     static no & check(...); \
        \
        static CONSTEXPR const bool value = (sizeof(check<FuncScopeType>(nullptr)) == sizeof(yes)); \
    };

// detection of not static only functions depended on FuncSignature template argument
#define DEFINE_UTILITY_NOTSTATIC_MEMBER_FUNCTION_CHECKER_WITH_SIGNATURE(checker_name, func_name) \
    template<typename FuncScopeType, typename FuncSignature> \
    struct checker_name \
    { \
        static_assert(std::is_member_pointer<FuncSignature>::value, "FuncSignature must be a pointer to member"); \
        \
        using yes = char[1]; \
        using no  = char[2]; \
        \
        template <FuncSignature> struct type_check_not_static_pointer {}; \
        template <typename T_>  static yes & check(type_check_not_static_pointer<&T_::func_name> *); \
        template <typename>     static no & check(...); \
        \
        static CONSTEXPR const bool value = (sizeof(check<FuncScopeType>(nullptr)) == sizeof(yes)); \
    };

// Checks existence of data member depended on MemberType template argument
// Based on: https://stackoverflow.com/questions/257288/is-it-possible-to-write-a-template-to-check-for-a-functions-existence/264088#264088
//

// detection of static or not static functions depended on MemberType template argument
#define DEFINE_UTILITY_MEMBER_DATA_CHECKER_WITH_SIGNATURE(checker_name, member_name) \
    template<typename MemberScopeType, typename MemberType> \
    struct checker_name \
    { \
        using unqual_member_type = typename std::remove_reference<MemberType>::type; \
        \
        using yes = char[1]; \
        using no  = char[2]; \
        \
        template <typename U_, U_> struct type_check_any; \
        template <typename T_>  static yes & check(type_check_any<unqual_member_type, &T_::member_name> *); \
        template <typename>     static no & check(...); \
        \
        static CONSTEXPR const bool value = (sizeof(check<MemberScopeType>(nullptr)) == sizeof(yes)); \
    };

// detection of static only functions depended on MemberType template argument
#define DEFINE_UTILITY_STATIC_MEMBER_DATA_CHECKER_WITH_SIGNATURE(checker_name, member_name) \
    template<typename MemberScopeType, typename MemberType> \
    struct checker_name \
    { \
        using unqual_member_type = typename std::remove_reference<MemberType>::type; \
        \
        using yes = char[1]; \
        using no  = char[2]; \
        \
        template <typename U_, U_ *> struct type_check_free_pointer; \
        template <typename T_>  static yes & check(type_check_free_pointer<unqual_member_type, &T_::member_name> *); \
        template <typename>     static no & check(...); \
        \
        static CONSTEXPR const bool value = (sizeof(check<MemberScopeType>(nullptr)) == sizeof(yes)); \
    };

// detection of not static only functions depended on MemberType template argument
#define DEFINE_UTILITY_NOTSTATIC_MEMBER_DATA_CHECKER_WITH_SIGNATURE(checker_name, member_name) \
    template<typename MemberScopeType, typename MemberType> \
    struct checker_name \
    { \
        using unqual_member_type = typename std::remove_reference<MemberType>::type; \
        \
        using yes = char[1]; \
        using no  = char[2]; \
        \
        template <typename U_, typename T_, U_ T_::*> struct type_check_not_static_pointer {}; \
        template <typename T_>  static yes & check(type_check_not_static_pointer<unqual_member_type, T_, &T_::member_name> *); \
        template <typename>     static no & check(...); \
        \
        static CONSTEXPR const bool value = (sizeof(check<MemberScopeType>(nullptr)) == sizeof(yes)); \
    };


// Checks existence of data member.
// Based on: https://stackoverflow.com/questions/15232758/detecting-constexpr-with-sfinae/15236647#15236647 
//

// detects only static data members
#define DEFINE_UTILITY_STATIC_MEMBER_DATA_CHECKER(checker_name, member_name) \
    template<typename MemberScopeType> \
    struct checker_name \
    { \
        using no  = char[1]; \
        using yes = char[2]; \
        \
        template <typename U_, U_ *> struct yes_free_pointer { yes yes_; }; \
        template <typename T_>  static yes_free_pointer<decltype(T_::member_name), &T_::member_name> & check(int); \
        template <typename>     static no & check(...); \
        \
        static CONSTEXPR const bool value = (sizeof(check<MemberScopeType>(0)) == sizeof(yes)); \
    };

// detects only not static data members
#define DEFINE_UTILITY_NOTSTATIC_MEMBER_DATA_CHECKER(checker_name, member_name) \
    template<typename MemberScopeType> \
    struct checker_name \
    { \
        using no  = char[1]; \
        using yes = char[2]; \
        \
        template <typename U_, typename T_, U_ T_::*> struct yes_not_static_pointer { yes yes_;}; \
        template <typename T_>  static yes_not_static_pointer<decltype(T_::member_name), T_, &T_::member_name> & check(int); \
        template <typename>     static no & check(...); \
        \
        static CONSTEXPR const bool value = (sizeof(check<MemberScopeType>(0)) == sizeof(yes)); \
    };


// Checks existence of constexpr member function.
// Based on: https://stackoverflow.com/questions/15232758/detecting-constexpr-with-sfinae/15236647#15236647 
//

// detects only static constexpr functions
#define DEFINE_UTILITY_STATIC_CONSTEXPR_MEMBER_FUNCTION_CHECKER_WITH_ARGS(checker_name, func_name, ...) \
    template<typename FuncScopeType> \
    struct checker_name \
    { \
        using no  = char[1]; \
        using yes = char[2]; \
        \
        template<int> struct yes_static_constexpr { yes yes_; }; \
        template <typename T_>  static yes_static_constexpr<(T_::func_name(__VA_ARGS__), 0)> & check(int); \
        template <typename>     static no & check(...); \
        \
        static CONSTEXPR const bool value = (sizeof(check<FuncScopeType>(0)) == sizeof(yes)); \
    };

// detects only static constexpr functions
#define DEFINE_UTILITY_STATIC_CONSTEXPR_MEMBER_FUNCTION_CHECKER(checker_name, func_call) \
    template<typename FuncScopeType> \
    struct checker_name \
    { \
        using no  = char[1]; \
        using yes = char[2]; \
        \
        template<int> struct yes_static_constexpr { yes yes_; }; \
        template <typename T_>  static yes_static_constexpr<(T_::func_call, 0)> & check(int); \
        template <typename>     static no & check(...); \
        \
        static CONSTEXPR const bool value = (sizeof(check<FuncScopeType>(0)) == sizeof(yes)); \
    };

// detects static constexpr or not static constexpr functions
#define DEFINE_UTILITY_CONSTEXPR_MEMBER_FUNCTION_CHECKER_WITH_ARGS(checker_name, func_name, ...) \
    template<typename FuncScopeType> \
    struct checker_name \
    { \
        using no  = char[1]; \
        using yes = char[2]; \
        \
        template<int> struct yes_any_constexpr { yes yes_; }; \
        template <typename T_>  static yes_any_constexpr<(static_cast<T_ *>(nullptr)->func_name(__VA_ARGS__), 0)> & check(int); \
        template <typename>     static no & check(...); \
        \
        static CONSTEXPR const bool value = (sizeof(check<FuncScopeType>(0)) == sizeof(yes)); \
    };

// detects static constexpr or not static constexpr functions
#define DEFINE_UTILITY_CONSTEXPR_MEMBER_FUNCTION_CHECKER(checker_name, func_call) \
    template<typename FuncScopeType> \
    struct checker_name \
    { \
        using no  = char[1]; \
        using yes = char[2]; \
        \
        template<int> struct yes_any_constexpr { yes yes_; }; \
        template <typename T_>  static yes_any_constexpr<(static_cast<T_ *>(nullptr)->func_call, 0)> & check(int); \
        template <typename>     static no & check(...); \
        \
        static CONSTEXPR const bool value = (sizeof(check<FuncScopeType>(0)) == sizeof(yes)); \
    };

// Checks existence of constexpr data member.
// Based on: https://stackoverflow.com/questions/15232758/detecting-constexpr-with-sfinae/15236647#15236647 
//

// incomplete
/*
// detects only static constexpr data members
#define DEFINE_UTILITY_STATIC_CONSTEXPR_MEMBER_CHECKER(checker_name, member_name) \
    template<typename MemberScopeType> \
    struct checker_name \
    { \
        using no  = char[1]; \
        using yes = char[2]; \
        \
        template<int> struct yes_any_constexpr { yes yes_; }; \
        template <typename U_, U_ *> struct free_pointer {}; \
        template <typename T_>  static yes_any_constexpr<(free_pointer<decltype(T_::member_name), &T_::member_name>{}, 0)> & check(int); \
        template <typename>     static no & check(...); \
        \
        static CONSTEXPR const bool value = (sizeof(check<MemberScopeType>(0)) == sizeof(yes)); \
    };

// detects static constexpr or not static constexpr data members
#define DEFINE_UTILITY_CONSTEXPR_MEMBER_CHECKER(checker_name, member_name, ...) \
    template<typename MemberScopeType> \
    struct checker_name \
    { \
        using no  = char[1]; \
        using yes = char[2]; \
        \
        template<int> struct yes_any_constexpr { yes yes_; }; \
        template <typename U_, typename T_, U_ T_::*> struct not_static_pointer { yes yes_;}; \
        template <typename T_>  static yes_any_constexpr<(not_static_pointer<decltype(T_::member_name), T_, &T_::member_name>{}, 0)> & check(int); \
        template <typename>     static no & check(...); \
        \
        static CONSTEXPR const bool value = (sizeof(check<MemberScopeType>(0)) == sizeof(yes)); \
    };*/

namespace utility
{
    // replacement for mpl::void_, useful to suppress excessive errors output in particular places
    struct void_ { using type = void_; };

    // to suppress `warning C4127: conditional expression is constant`
    template <bool B>
    struct const_expr
    {
        static CONSTEXPR const bool value = B;
    };

    namespace
    {
        struct _not_overloadable_type {};
    }

    template <typename T>
    struct type_lookup
    {
        using type = T;
    };

    template <typename T>
    struct incomplete_dependent_type;

    namespace
    {
        template<class T, int discriminator>
        struct is_type_complete
        {
            static T & getT();
            static char (& pass(T))[2];
            static char pass(...);
            static CONSTEXPR const bool value = (sizeof(pass(getT())) == 2);
        };
    }

    // std::identity is depricated in msvc2017

    template <typename T>
    struct identity
    {
        using type = T;
    };

    template <typename... Type>
    struct tuple_identities
    {
        using tuple_type = std::tuple<Type...>;
    };

    // type-by-value identity

    template <typename T, T v>
    struct value_identity
    {
        using type = T;
        static CONSTEXPR const T value = v;
    };

    template <typename T, T v>
    CONSTEXPR const T value_identity<T, v>::value;

    template <bool b>
    struct bool_identity
    {
        using type = bool;
        static CONSTEXPR const bool value = b;
    };

    template <int v>
    struct int_identity
    {
        using type = int;
        static CONSTEXPR const int value = v;
    };

    template <size_t v>
    struct size_identity
    {
        using type = size_t;
        static CONSTEXPR const size_t value = v;
    };

    // for explicit partial specialization of type_index_identity_base

    template <typename T, int Index>
    struct type_index_identity
    {
        using type = T;
        static constexpr const int index = Index;
    };

    template <typename T, int Index>
    struct type_index_identity_base; // : type_index_identity<T, Index> {};

    // The `dependent_*` classes to provoke compiler to instantiate a template by a dependent template argument to evaluate the value only after template instantiation.
    // This is useful in contexts where a static_assert could be evaluated inside a class template before it's instantiation.
    // For details, see: https://stackoverflow.com/questions/5246049/c11-static-assert-and-template-instantiation/5246686#5246686
    //

    template <typename T, typename U = void>
    struct dependent_type
    {
        using type      = T;
        using user_type = U;
        static CONSTEXPR const bool false_value = !std::is_same<type, type>::value;
    };

    template <typename T, T v>
    struct dependent_value
    {
        using type      = T;
        static CONSTEXPR const bool false_value = !std::is_same<value_identity<type, v>, value_identity<type, v> >::value;
    };

    template <bool B>
    struct dependent_bool
    {
        static CONSTEXPR const bool false_value = !std::is_same<bool_identity<B>, bool_identity<B> >::value;
    };

    template <int N>
    struct dependent_int
    {
        static CONSTEXPR const bool false_value = !std::is_same<int_identity<N>, int_identity<N> >::value;
    };

    // custom more convenient `enable_if` implementation.
    // Based on: https://www.reddit.com/r/cpp_questions/comments/3zn1n9/why_is_this_use_of_enable_if_invalid/
    //

    template <bool B, class Type, typename... Dependencies>
    struct dependent_enable_if
    {
    };

    template<class Type, typename... Dependencies>
    struct dependent_enable_if<true, Type, Dependencies...>
    {
        using type = Type;
    };

    template <bool B, class Type, typename... Dependencies>
    struct dependent_disable_if
    {
    };

    template<class Type, typename... Dependencies>
    struct dependent_disable_if<false, Type, Dependencies...>
    {
        using type = Type;
    };

    template<typename T>
    CONSTEXPR_RETURN typename std::remove_reference<T>::type makeprval(T && t)
    {
        return t;
    }

    // std::size is supported from C++17
    template <typename T, size_t N>
    FORCE_INLINE CONSTEXPR size_t static_size(const T (&)[N]) noexcept
    {
        return N;
    }

    template <typename... T>
    FORCE_INLINE CONSTEXPR size_t static_size(const std::tuple<T...> &)
    {
        return std::tuple_size<std::tuple<T...> >::value;
    }
}

#endif
