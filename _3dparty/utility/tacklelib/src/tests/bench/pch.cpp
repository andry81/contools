// to avoid problems in cmake with different file properties on the same cpp file for different targets

#include "test_common.hpp" // to avoid error: `fatal error C1010: unexpected end of file while looking for precompiled header. Did you forget to add '#include "test_common.hpp"' to your source?`
#include "test_common.cpp"
