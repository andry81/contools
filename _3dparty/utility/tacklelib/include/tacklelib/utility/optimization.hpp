#pragma once

// DO NOT REMOVE, exists to avoid private/public headers mixing!
#ifndef UTILITY_OPTIMIZATION_HPP
#define UTILITY_OPTIMIZATION_HPP

#include <tacklelib/tacklelib.hpp>

#include <tacklelib/utility/preprocessor.hpp>
#include <tacklelib/utility/platform.hpp>
#include <tacklelib/utility/addressof.hpp>


#define UTILITY_UNUSED(suffix, exp)                 UTILITY_UNUSED_ ## suffix(exp)

#define UTILITY_UNUSED_EXPR(exp)                    (( (void)((exp), nullptr) ))
#define UTILITY_UNUSED_STATEMENT(exp)               do {{ (void)((exp), 0); }} while(false)

#define UTILITY_UNUSED_EXPR2(e0, e1)                (( UTILITY_UNUSED_EXPR(e0), UTILITY_UNUSED_EXPR(e1) ))
#define UTILITY_UNUSED_STATEMENT2(e0, e1)           do {{ UTILITY_UNUSED_STATEMENT(e0); UTILITY_UNUSED_STATEMENT(e1); }} while(false)

#define UTILITY_UNUSED_EXPR3(e0, e1, e2)            (( UTILITY_UNUSED_EXPR2(e0, e1), UTILITY_UNUSED_EXPR(e2) ))
#define UTILITY_UNUSED_STATEMENT3(e0, e1, e2)       do {{ UTILITY_UNUSED_STATEMENT2(e0, e1); UTILITY_UNUSED_STATEMENT(e2); }} while(false)

#define UTILITY_UNUSED_EXPR4(e0, e1, e2, e3)        (( UTILITY_UNUSED_EXPR3(e0, e1, e2), UTILITY_UNUSED_EXPR(e3) ))
#define UTILITY_UNUSED_STATEMENT4(e0, e1, e2, e3)   do {{ UTILITY_UNUSED_STATEMENT3(e0, e1, e2); UTILITY_UNUSED_STATEMENT(e3); }} while(false)

#define UTILITY_UNUSED_EXPR5(e0, e1, e2, e3, e4)    (( UTILITY_UNUSED_EXPR4(e0, e1, e2, e3), UTILITY_UNUSED_EXPR(e4) ))
#define UTILITY_UNUSED_STATEMENT5(e0, e1, e2, e3, e4) do {{ UTILITY_UNUSED_STATEMENT4(e0, e1, e2, e3); UTILITY_UNUSED_STATEMENT(e4); }} while(false)

#define UTILITY_UNUSED_EXPR6(e0, e1, e2, e3, e4, e5) (( UTILITY_UNUSED_EXPR5(e0, e1, e2, e3, e4), UTILITY_UNUSED_EXPR(e5) ))
#define UTILITY_UNUSED_STATEMENT6(e0, e1, e2, e3, e4, e5) do {{ UTILITY_UNUSED_STATEMENT5(e0, e1, e2, e3, e4); UTILITY_UNUSED_STATEMENT(e5); }} while(false)

#define UTILITY_UNUSED_EXPR7(e0, e1, e2, e3, e4, e5, e6) (( UTILITY_UNUSED_EXPR6(e0, e1, e2, e3, e4, e5), UTILITY_UNUSED_EXPR(e6) ))
#define UTILITY_UNUSED_STATEMENT7(e0, e1, e2, e3, e4, e5, e6) do {{ UTILITY_UNUSED_STATEMENT6(e0, e1, e2, e3, e4, e5); UTILITY_UNUSED_STATEMENT(e6); }} while(false)

#define UTILITY_UNUSED_EXPR8(e0, e1, e2, e3, e4, e5, e6, e7) (( UTILITY_UNUSED_EXPR7(e0, e1, e2, e3, e4, e5, e6), UTILITY_UNUSED_EXPR(e7) ))
#define UTILITY_UNUSED_STATEMENT8(e0, e1, e2, e3, e4, e5, e6, e7) do {{ UTILITY_UNUSED_STATEMENT7(e0, e1, e2, e3, e4, e5, e6); UTILITY_UNUSED_STATEMENT(e7); }} while(false)

#define UTILITY_SUPPRESS_OPTIMIZATION_ON_VAR(var)   ::utility::unused_param(::utility::addressof(var)) // must be l-value reference

#if defined(UTILITY_PLATFORM_WINDOWS)
#   define UTILITY_PLATFORM_ATTRIBUTE_DISABLE_OPTIMIZATION
#elif defined(UTILITY_COMPILER_CXX_GCC)
#   define UTILITY_PLATFORM_ATTRIBUTE_DISABLE_OPTIMIZATION __attribute__((optimize("O0")))
#else
#   define UTILITY_PLATFORM_ATTRIBUTE_DISABLE_OPTIMIZATION
#endif


namespace utility
{
    extern const volatile void * volatile g_unused_param_storage_ptr;

    // empty instruction for breakpoint placeholder
    FORCE_INLINE_ALWAYS void unused()
    {
    }

    // external function to suppress optimization over unused variables and return values in the Release through use them in an external function
    extern FORCE_NO_INLINE void UTILITY_PLATFORM_ATTRIBUTE_DISABLE_OPTIMIZATION unused_param(const volatile void * p);

    template <typename T>
    class unused_param_by_lref
    {
    public:
        FORCE_INLINE unused_param_by_lref(T & var)
        {
            UTILITY_SUPPRESS_OPTIMIZATION_ON_VAR(var);
        }
    };

    // to turn off/on optimization suppression in the compile time
    template <bool Enable, typename T>
    class unused_param_by_lref_if
    {
    public:
        FORCE_INLINE unused_param_by_lref_if(T & var)
        {
            UTILITY_SUPPRESS_OPTIMIZATION_ON_VAR(var);
        }
    };

    template <typename T>
    class unused_param_by_lref_if<false, T>
    {
    public:
        FORCE_INLINE unused_param_by_lref_if(T & var)
        {
            UTILITY_UNUSED_STATEMENT(var);
        }
    };
}

#endif
