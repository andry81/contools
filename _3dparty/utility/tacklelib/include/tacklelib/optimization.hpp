#pragma once


//// public headers common optimization symbols

// CAUTION:
//  Imprudent usage of the FORCE_INLINE on each function can dramatically increase compilation times!
//
#define ENABLE_FORCE_INLINE 1       // defines FORCE_INLINE in to builtin instruction to force entity to inline

#define ENABLE_FORCE_NO_INLINE 1    // defines FORCE_NO_INLINE in to builtin instruction to force entity to not inline

#define ENABLE_INTRINSIC 1          // use builtin implementation (intrinsic) instead externally linked
