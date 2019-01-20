#pragma once

// DO NOT REMOVE, exists to avoid private/public headers mixing!
#ifndef TACKLE_DEBUG_HPP
#define TACKLE_DEBUG_HPP

#include <tacklelib/tacklelib.hpp>

#include <tacklelib/utility/preprocessor.hpp>
#include <tacklelib/utility/platform.hpp>
#include <tacklelib/utility/type_identity.hpp>

#include <string>
#include <cwchar>
#include <uchar.h>  // in GCC `cuchar` header might not exist


#define DEBUG_FILE_LINE_A                           ::tackle::DebugFileLineA{ UTILITY_STR_WITH_STATIC_LENGTH_TUPLE(UTILITY_PP_FILE), UTILITY_PP_LINE }
#define DEBUG_FILE_LINE_MAKE_A()                    ::tackle::DebugFileLineInlineStackA::make(::tackle::DebugFileLineA{ UTILITY_STR_WITH_STATIC_LENGTH_TUPLE(UTILITY_PP_FILE), UTILITY_PP_LINE })
#define DEBUG_FILE_LINE_MAKE_PUSH_A(stack)          ::tackle::DebugFileLineInlineStackA::make_push(stack, ::tackle::DebugFileLineA{ UTILITY_STR_WITH_STATIC_LENGTH_TUPLE(UTILITY_PP_FILE), UTILITY_PP_LINE })

#define DEBUG_FILE_LINE_W                           ::tackle::DebugFileLineW{ UTILITY_STR_WITH_STATIC_LENGTH_TUPLE(UTILITY_PP_FILE_WIDE), UTILITY_PP_LINE }
#define DEBUG_FILE_LINE_MAKE_W()                    ::tackle::DebugFileLineInlineStackW::make(::tackle::DebugFileLineW{ UTILITY_STR_WITH_STATIC_LENGTH_TUPLE(UTILITY_PP_FILE_WIDE), UTILITY_PP_LINE })
#define DEBUG_FILE_LINE_MAKE_PUSH_W(stack)          ::tackle::DebugFileLineInlineStackW::make_push(stack, ::tackle::DebugFileLineW{ UTILITY_STR_WITH_STATIC_LENGTH_TUPLE(UTILITY_PP_FILE_WIDE), UTILITY_PP_LINE })


#define DEBUG_FUNC_LINE_A                           ::tackle::DebugFuncLineA{ UTILITY_STR_WITH_STATIC_LENGTH_TUPLE(UTILITY_PP_FUNC), UTILITY_PP_LINE }
#define DEBUG_FUNC_LINE_MAKE_A()                    ::tackle::DebugFuncLineInlineStackA::make(::tackle::DebugFuncLineA{ UTILITY_STR_WITH_STATIC_LENGTH_TUPLE(UTILITY_PP_FUNC), UTILITY_PP_LINE })
#define DEBUG_FUNC_LINE_MAKE_PUSH_A(stack)          ::tackle::DebugFuncLineInlineStackA::make_push(stack, ::tackle::DebugFuncLineA{ UTILITY_STR_WITH_STATIC_LENGTH_TUPLE(UTILITY_PP_FUNC), UTILITY_PP_LINE })


#define DEBUG_FUNCSIG_LINE_A                        ::tackle::DebugFuncLineA{ UTILITY_STR_WITH_STATIC_LENGTH_TUPLE(UTILITY_PP_FUNCSIG), UTILITY_PP_LINE }
#define DEBUG_FUNCSIG_LINE_MAKE_A()                 ::tackle::DebugFuncLineInlineStackA::make(::tackle::DebugFuncLineA{ UTILITY_STR_WITH_STATIC_LENGTH_TUPLE(UTILITY_PP_FUNCSIG), UTILITY_PP_LINE })
#define DEBUG_FUNCSIG_LINE_MAKE_PUSH_A(stack)       ::tackle::DebugFuncLineInlineStackA::make_push(stack, ::tackle::DebugFuncLineA{ UTILITY_STR_WITH_STATIC_LENGTH_TUPLE(UTILITY_PP_FUNCSIG), UTILITY_PP_LINE })


#define DEBUG_FILE_LINE_FUNC_A                      ::tackle::DebugFileLineFuncA{ UTILITY_STR_WITH_STATIC_LENGTH_TUPLE(UTILITY_PP_FILE), UTILITY_PP_LINE, UTILITY_STR_WITH_STATIC_LENGTH_TUPLE(UTILITY_PP_FUNC) }
#define DEBUG_FILE_LINE_FUNC_MAKE_A()               ::tackle::DebugFileLineFuncInlineStackA::make(::tackle::DebugFileLineFuncA{ UTILITY_STR_WITH_STATIC_LENGTH_TUPLE(UTILITY_PP_FILE), UTILITY_PP_LINE, UTILITY_STR_WITH_STATIC_LENGTH_TUPLE(UTILITY_PP_FUNC) })
#define DEBUG_FILE_LINE_FUNC_MAKE_PUSH_A(stack)     ::tackle::DebugFileLineFuncInlineStackA::make_push(stack, ::tackle::DebugFileLineFuncA{ UTILITY_STR_WITH_STATIC_LENGTH_TUPLE(UTILITY_PP_FILE), UTILITY_PP_LINE, UTILITY_STR_WITH_STATIC_LENGTH_TUPLE(UTILITY_PP_FUNC) })

#define DEBUG_FILE_LINE_FUNC_W                      ::tackle::DebugFileLineFuncW{ UTILITY_STR_WITH_STATIC_LENGTH_TUPLE(UTILITY_PP_FILE_WIDE), UTILITY_PP_LINE, UTILITY_STR_WITH_STATIC_LENGTH_TUPLE(UTILITY_PP_FUNC) }
#define DEBUG_FILE_LINE_FUNC_MAKE_W()               ::tackle::DebugFileLineFuncInlineStackW::make(::tackle::DebugFileLineFuncW{ UTILITY_STR_WITH_STATIC_LENGTH_TUPLE(UTILITY_PP_FILE_WIDE), UTILITY_PP_LINE, UTILITY_STR_WITH_STATIC_LENGTH_TUPLE(UTILITY_PP_FUNC) })
#define DEBUG_FILE_LINE_FUNC_MAKE_PUSH_W(stack)     ::tackle::DebugFileLineFuncInlineStackW::make_push(stack, ::tackle::DebugFileLineFuncW{ UTILITY_STR_WITH_STATIC_LENGTH_TUPLE(UTILITY_PP_FILE_WIDE), UTILITY_PP_LINE, UTILITY_STR_WITH_STATIC_LENGTH_TUPLE(UTILITY_PP_FUNC) })


#define DEBUG_FILE_LINE_FUNCSIG_A                   ::tackle::DebugFileLineFuncA{ UTILITY_STR_WITH_STATIC_LENGTH_TUPLE(UTILITY_PP_FILE), UTILITY_PP_LINE, UTILITY_STR_WITH_STATIC_LENGTH_TUPLE(UTILITY_PP_FUNCSIG) }
#define DEBUG_FILE_LINE_FUNCSIG_MAKE_A()            ::tackle::DebugFileLineFuncInlineStackA::make(::tackle::DebugFileLineFuncA{ UTILITY_STR_WITH_STATIC_LENGTH_TUPLE(UTILITY_PP_FILE), UTILITY_PP_LINE, UTILITY_STR_WITH_STATIC_LENGTH_TUPLE(UTILITY_PP_FUNCSIG) })
#define DEBUG_FILE_LINE_FUNCSIG_MAKE_PUSH_A(stack)  ::tackle::DebugFileLineFuncInlineStackA::make_push(stack, ::tackle::DebugFileLineFuncA{ UTILITY_STR_WITH_STATIC_LENGTH_TUPLE(UTILITY_PP_FILE), UTILITY_PP_LINE, UTILITY_STR_WITH_STATIC_LENGTH_TUPLE(UTILITY_PP_FUNCSIG) })

#define DEBUG_FILE_LINE_FUNCSIG_W                   ::tackle::DebugFileLineFuncW{ UTILITY_STR_WITH_STATIC_LENGTH_TUPLE(UTILITY_PP_FILE_WIDE), UTILITY_PP_LINE, UTILITY_STR_WITH_STATIC_LENGTH_TUPLE(UTILITY_PP_FUNCSIG) }
#define DEBUG_FILE_LINE_FUNCSIG_MAKE_W()            ::tackle::DebugFileLineFuncInlineStackW::make(::tackle::DebugFileLineFuncW{ UTILITY_STR_WITH_STATIC_LENGTH_TUPLE(UTILITY_PP_FILE_WIDE), UTILITY_PP_LINE, UTILITY_STR_WITH_STATIC_LENGTH_TUPLE(UTILITY_PP_FUNCSIG) })
#define DEBUG_FILE_LINE_FUNCSIG_MAKE_PUSH_W(stack)  ::tackle::DebugFileLineFuncInlineStackW::make_push(stack, ::tackle::DebugFileLineFuncW{ UTILITY_STR_WITH_STATIC_LENGTH_TUPLE(UTILITY_PP_FILE_WIDE), UTILITY_PP_LINE, UTILITY_STR_WITH_STATIC_LENGTH_TUPLE(UTILITY_PP_FUNCSIG) })


namespace tackle
{
    template <class t_elem>
    struct DebugFileLine
    {
        const t_elem *  file;
        size_t          file_len;
        int             line;
    };

    struct DebugFuncLineA
    {
        const char *    func;
        size_t          func_len;
        int             line;
    };

    using DebugFileLineA = DebugFileLine<char>;
    using DebugFileLineW = DebugFileLine<wchar_t>;

    template <class t_elem>
    struct DebugFileLineFunc
    {
        const t_elem *  file;
        size_t          file_len;
        int             line;
        const char *    func;
        size_t          func_len;
    };

    using DebugFileLineFuncA = DebugFileLineFunc<char>;
    using DebugFileLineFuncW = DebugFileLineFunc<wchar_t>;

    template <typename T>
    class inline_stack
    {
    public:
        inline_stack(const T & top_, const inline_stack * next_ptr_ = nullptr) :
            next_ptr(next_ptr_), top(top_)
        {
        }

        static inline_stack make(const T & top)
        {
            return inline_stack{ top };
        }

        static inline_stack make_push(const inline_stack & next_stack, const T & top)
        {
            return inline_stack{ top, &next_stack };
        }

        const inline_stack *    next_ptr;
        T                       top;
    };

    using DebugFileLineInlineStackA     = inline_stack<DebugFileLineA>;
    using DebugFuncLineInlineStackA     = inline_stack<DebugFuncLineA>;
    using DebugFileLineFuncInlineStackA = inline_stack<DebugFileLineFuncA>;

    using DebugFileLineInlineStackW     = inline_stack<DebugFileLineW>;
    //using DebugFuncLineInlineStackW     = inline_stack<DebugFuncLineW>;
    using DebugFileLineFuncInlineStackW = inline_stack<DebugFileLineFuncW>;
}

#endif
