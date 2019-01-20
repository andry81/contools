#pragma once


//// public headers common debug symbols

// Converts all FORCE_INLINE into `force no inline` both in debug and release (useful when want to profile each function).
#define DEFINE_FORCE_INLINE_TO_FORCE_NO_INLINE 0

// Disables VERIFY_*/ASSERT_* macroses ONLY.
#define DISABLE_VERIFY_ASSERT 0

// Disables DEBUG_VERIFY_*/DEBUG_ASSERT_* macroses ONLY.
#define DISABLE_DEBUG_VERIFY_ASSERT 0

// increases chances to catch a memory corruption place.
#define USE_MEMORY_REALLOCATION_IN_VERIFY_ASSERT 0

// check FPU precision control in each assert (x86 only, x64 is not supported following the MSDN documentation)
#define USE_FPU_PRECISION_CHECK_IN_VERIFY_ASSERT 0
#define USE_FPU_PRECISION_CHECK_IN_VERIFY_ASSERT_VALUE _PC_53 // available values: _PC_24, _PC_53, _PC_64

// Call `utility::Buffer::realloc` immediately after `utility::Buffer::realloc_get`.
// This will trigger builtin memory corruption checker.
#define ENABLE_BUFFER_REALLOC_AFTER_ALLOC 0

// Enables builtin `utility::Buffer` guards even in release (by default it is enabled ONLY in the Debug)
#define ENABLE_PERSISTENT_BUFFER_GUARD_CHECK 0

// Disables builtin `utility::Buffer` guards everythere (by default it is enabled ONLY in the Debug)
#define DISABLE_BUFFER_GUARD_CHECK 0
