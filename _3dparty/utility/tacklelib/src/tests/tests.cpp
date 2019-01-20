#include "test_common.hpp"

// include all tests headers from here
//...
//

// must define appropriate tests here to skip them in case of absence respective conditions
DECLARE_TEST_CASES
{
#ifdef UNIT_TESTS
    DECLARE_TEST_CASE_FUNC(FunctionsTest, *, nullptr, nullptr, "", "", "", 0),

    DECLARE_TEST_CASE_FUNC(TackleDequeTest, *, nullptr, nullptr, "", "", "", 0),
#endif

#ifdef BENCH_TESTS
    DECLARE_TEST_CASE_FUNC(FunctionsTest, *, nullptr, nullptr, "test_funcs_duration", "test_funcs_duration", "", 0),
#endif
};
