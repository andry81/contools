#pragma once

// DO NOT REMOVE, exists to avoid private/public headers mixing!
#ifndef UTILITY_PREPROCESSOR_HPP
#define UTILITY_PREPROCESSOR_HPP

// Not empty definitions filter with ability to raise a preprocessor error on not defined definitions or empty definitions:
//  MSVC (2017) utilized errors:
//  * not defined:   `C2124: divide or mod by zero`
//  * defined empty: `C1017: invalid integer constant expression`
//  GCC (5.4) utilized errors:
//  * not defined:   `division by zero in #if`
//  * defined empty: `operator '||' has no left operand`
//
#if defined(__GNUC__) && __GNUC__ >= 3
#define ERROR_IF_EMPTY_PP_DEF(x, args...) (x || (!defined(x ## args) && 0/x))
#else
#define ERROR_IF_EMPTY_PP_DEF(x) (x || (!defined (## x ##) && 0/x))
#endif

#define UTILITY_PP_MACRO_ARG0_(v0, ...) v0
#define UTILITY_PP_MACRO_ARG0(...)      UTILITY_PP_MACRO_ARG0_(__VA_ARGS__)

#define UTILITY_PP_MACRO_ARG1_(v0, ...) UTILITY_PP_MACRO_ARG0_(__VA_ARGS__)
#define UTILITY_PP_MACRO_ARG1(...)      UTILITY_PP_MACRO_ARG1_(__VA_ARGS__)

#define UTILITY_PP_MACRO_ARG2_(v0, ...) UTILITY_PP_MACRO_ARG1_(__VA_ARGS__)
#define UTILITY_PP_MACRO_ARG2(...)      UTILITY_PP_MACRO_ARG2_(__VA_ARGS__)

#define UTILITY_PP_MACRO_ARG3_(v0, ...) UTILITY_PP_MACRO_ARG2_(__VA_ARGS__)
#define UTILITY_PP_MACRO_ARG3(...)      UTILITY_PP_MACRO_ARG3_(__VA_ARGS__)

#define UTILITY_PP_STRINGIZE_(x)        #x
#define UTILITY_PP_STRINGIZE(x) UTILITY_PP_STRINGIZE_(x)

#define UTILITY_PP_STRINGIZE_IF_0()
#define UTILITY_PP_STRINGIZE_IF_1(x)    UTILITY_PP_STRINGIZE(x)
#define UTILITY_PP_STRINGIZE_IF(f, ...) UTILITY_PP_CONCAT(UTILITY_PP_STRINGIZE_IF_, f)(__VA_ARGS__)

#define UTILITY_PP_STRINGIZE_WIDE(x) UTILITY_PP_CONCAT(L, UTILITY_PP_STRINGIZE(x))

#define UTILITY_PP_STRINGIZE_WIDE_IF_0(x)
#define UTILITY_PP_STRINGIZE_WIDE_IF_1(x) UTILITY_PP_STRINGIZE_WIDE(x)
#define UTILITY_PP_STRINGIZE_WIDE_IF(f, ...) UTILITY_PP_CONCAT(UTILITY_PP_STRINGIZE_WIDE_IF_, f)(__VA_ARGS__)

#define UTILITY_PP_CONCAT_(v1, v2) v1 ## v2
#define UTILITY_PP_CONCAT(v1, v2) UTILITY_PP_CONCAT_(v1, v2)

#define UTILITY_PP_CONCAT3_(v1, v2, v3) v1 ## v2 ## v3
#define UTILITY_PP_CONCAT3(v1, v2, v3) UTILITY_PP_CONCAT3_(v1, v2, v3)

#define UTILITY_PP_CONCAT4_(v1, v2, v3, v4) v1 ## v2 ## v3 ## v4
#define UTILITY_PP_CONCAT4(v1, v2, v3, v4) UTILITY_PP_CONCAT4_(v1, v2, v3, v4)

#define UTILITY_PP_CONCAT5_(v1, v2, v3, v4, v5) v1 ## v2 ## v3 ## v4 ## v5
#define UTILITY_PP_CONCAT5(v1, v2, v3, v4, v5) UTILITY_PP_CONCAT5_(v1, v2, v3, v4, v5)

#define UTILITY_PP_CONCAT6_(v1, v2, v3, v4, v5, v6) v1 ## v2 ## v3 ## v4 ## v5 ## v6
#define UTILITY_PP_CONCAT6(v1, v2, v3, v4, v5, v6) UTILITY_PP_CONCAT6_(v1, v2, v3, v4, v5, v6)

#define UTILITY_PP_CONCAT7_(v1, v2, v3, v4, v5, v6, v7) v1 ## v2 ## v3 ## v4 ## v5 ## v6 ## v7
#define UTILITY_PP_CONCAT7(v1, v2, v3, v4, v5, v6, v7) UTILITY_PP_CONCAT7_(v1, v2, v3, v4, v5, v6, v7)

#define UTILITY_PP_CONCAT8_(v1, v2, v3, v4, v5, v6, v7, v8) v1 ## v2 ## v3 ## v4 ## v5 ## v6 ## v7 ## v8
#define UTILITY_PP_CONCAT8(v1, v2, v3, v4, v5, v6, v7, v8) UTILITY_PP_CONCAT8_(v1, v2, v3, v4, v5, v6, v7, v8)

#define UTILITY_PP_FILE_ __FILE__
#define UTILITY_PP_FILE UTILITY_PP_FILE_

#define UTILITY_PP_FILE_WIDE UTILITY_PP_CONCAT(L, UTILITY_PP_FILE)

#define UTILITY_PP_LINE_ __LINE__
#define UTILITY_PP_LINE UTILITY_PP_LINE_

#define UTILITY_PP_LINE_STR UTILITY_PP_STRINGIZE(UTILITY_PP_LINE)
#define UTILITY_PP_LINE_STR_WIDE UTILITY_PP_STRINGIZE_WIDE(UTILITY_PP_LINE)

#define UTILITY_PP_EMPTY_
#define UTILITY_PP_EMPTY UTILITY_PP_EMPTY_

#define UTILITY_PP_IDENTITY_(x) x
#define UTILITY_PP_IDENTITY(x) UTILITY_PP_IDENTITY_(x)
#define UTILITY_PP_IDENTITY2_(v1, v2) v1, v2
#define UTILITY_PP_IDENTITY2(v1, v2) UTILITY_PP_IDENTITY2_(v1, v2)
#define UTILITY_PP_IDENTITY3_(v1, v2, v3) v1, v2, v3
#define UTILITY_PP_IDENTITY3(v1, v2, v3, v4) UTILITY_PP_IDENTITY3_(v1, v2, v3)
#define UTILITY_PP_IDENTITY4_(v1, v2, v3, v4) v1, v2, v3, v4
#define UTILITY_PP_IDENTITY4(v1, v2, v3, v4) UTILITY_PP_IDENTITY4_(v1, v2, v3, v4)
#define UTILITY_PP_IDENTITY5_(v1, v2, v3, v4, v5) v1, v2, v3, v4, v5
#define UTILITY_PP_IDENTITY5(v1, v2, v3, v4, v5) UTILITY_PP_IDENTITY5_(v1, v2, v3, v4, v5)
#define UTILITY_PP_IDENTITY6_(v1, v2, v3, v4, v5, v6) v1, v2, v3, v4, v5, v6
#define UTILITY_PP_IDENTITY6(v1, v2, v3, v4, v5, v6) UTILITY_PP_IDENTITY6_(v1, v2, v3, v4, v5, v6)
#define UTILITY_PP_IDENTITY7_(v1, v2, v3, v4, v5, v6, v7) v1, v2, v3, v4, v5, v6, v7
#define UTILITY_PP_IDENTITY7(v1, v2, v3, v4, v5, v6, v7) UTILITY_PP_IDENTITY7_(v1, v2, v3, v4, v5, v6, v7)
#define UTILITY_PP_IDENTITY8_(v1, v2, v3, v4, v5, v6, v7, v8) v1, v2, v3, v4, v5, v6, v7, v8
#define UTILITY_PP_IDENTITY8(v1, v2, v3, v4, v5, v6, v7, v8) UTILITY_PP_IDENTITY8_(v1, v2, v3, v4, v5, v6, v7, v8)

#define UTILITY_PP_VA_ARGS_(...)    __VA_ARGS__
#define UTILITY_PP_VA_ARGS(...)     UTILITY_PP_VA_ARGS_(__VA_ARGS__)

#define UTILITY_PP_IDENTITY_VA_ARGS_(x, ...)    x, ## __VA_ARGS__
#define UTILITY_PP_IDENTITY_VA_ARGS(x, ...)     UTILITY_PP_IDENTITY_VA_ARGS_(x, ## __VA_ARGS__)

#define UTILITY_PP_IIF_0(x, ...) __VA_ARGS__
#define UTILITY_PP_IIF_1(x, ...) x
#define UTILITY_PP_IIF(c) UTILITY_PP_CONCAT_(UTILITY_PP_IIF_, c)

#define UTILITY_PP_IIF_NOT_0(x, ...) x
#define UTILITY_PP_IIF_NOT_1(x, ...) __VA_ARGS__
#define UTILITY_PP_IIF_NOT_(c) UTILITY_PP_CONCAT_(UTILITY_PP_IIF_NOT_, c)

#define UTILITY_PP_HAS_COMMA(...) UTILITY_PP_IDENTITY(UTILITY_PP_VA_ARGS_TAIL(__VA_ARGS__, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0))
#define UTILITY_PP_IS_EMPTY_TRIGGER_PARENTHESIS_(...) ,

#define UTILITY_PP_IS_EMPTY(...) UTILITY_PP_IS_EMPTY_(                                      \
    /* test if there is just one argument, eventually an empty one */                       \
    UTILITY_PP_HAS_COMMA(__VA_ARGS__),                                                      \
    /* test if _TRIGGER_PARENTHESIS_ together with the argument adds a comma */             \
    UTILITY_PP_HAS_COMMA(UTILITY_PP_IS_EMPTY_TRIGGER_PARENTHESIS_ __VA_ARGS__),             \
    /* test if the argument together with a parenthesis adds a comma */                     \
    UTILITY_PP_HAS_COMMA(__VA_ARGS__ ()),                                                   \
    /* test if placing it between _TRIGGER_PARENTHESIS_ and the parenthesis adds a comma */ \
    UTILITY_PP_HAS_COMMA(UTILITY_PP_IS_EMPTY_TRIGGER_PARENTHESIS_ __VA_ARGS__ ()))

#define UTILITY_PP_IS_EMPTY_(_0, _1, _2, _3) UTILITY_PP_HAS_COMMA(UTILITY_PP_CONCAT5_(UTILITY_PP_IS_EMPTY_IS_EMPTY_CASE_, _0, _1, _2, _3))
#define UTILITY_PP_IS_EMPTY_IS_EMPTY_CASE_0001 ,

#define UTILITY_PP_VA_ARGS_SIZE(...) UTILITY_PP_IIF(UTILITY_PP_IS_EMPTY(__VA_ARGS__))(0, UTILITY_PP_VA_ARGS_SIZE_(__VA_ARGS__, UTILITY_PP_VA_ARGS_SEQ64()))
#define UTILITY_PP_VA_ARGS_SIZE_(...) UTILITY_PP_IDENTITY(UTILITY_PP_VA_ARGS_TAIL(__VA_ARGS__))

#define UTILITY_PP_VA_ARGS_TAIL(_0,_1,_2,_3,_4,_5,_6,_7,_8,_9,_10,_11,_12,_13,_14, x, ...) x
#define UTILITY_PP_VA_ARGS_SEQ64() 15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0

#define UTILITY_PP_LINE_TERMINATOR

#define SCOPED_TYPEDEF(type_, typedef_) using typedef_ = struct { using type = type_; }

#endif
