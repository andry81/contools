#pragma once

// include public header at first
#include <tacklelib/optimization.hpp>


//// private headers common optimization symbols

//// utility/assert.hpp

// Do NOT use macro inline instead of function/lambda call for the UNIT_ASSERT_* macroses ONLY.
//
// WARNING:
//  1. If not enabled, then compilation or linkage times can has increased slow down (because of more inlining).
//
#define DONT_USE_UNIT_ASSERT_CALL_THROUGH_MACRO_INLINE 0

// WARNING:
//  1. You must define DONT_USE_UNIT_ASSERT_CALL_THROUGH_MACRO_INLINE to fully switch the implementation.
//  2. Compilation or linkage times has noticable slow down around 2x times (msvc2015u3).
#define USE_UNIT_ASSERT_CALL_THROUGH_TEMPLATE_FUNCTION_INSTEAD_LAMBDAS 0

// use basic verify/assert implementation instead unit test implementation (just to measure time spent in unit tests)
#define USE_BASIC_ASSERT_INSTEAD_UNIT_ASSERT 0

//// utility/stream_storage.hpp

// Makes the `stream_storage` `copy_to` and `stride_copy_to` to use internal inlinement for speed up
//
// CAUTION:
//  Can dramatically increase compilation time!
//
#define ENABLE_INTERNAL_FORCE_INLINE_IN_STREAM_STORAGE 0

// Switches from `std::deque` container to the `tackle::deque` (a bit faster, can setup sizes of internal arrays explicitly).
//
#define ENABLE_INTERNAL_TACKLE_DEQUE_IN_STREAM_STORAGE 0
