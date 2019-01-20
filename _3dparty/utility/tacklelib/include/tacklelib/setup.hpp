#pragma once


//// public headers common setup symbols

#define USE_FMT_LIBRARY_INSTEAD_STD_STRINGSTREAMS 1         // Uses `fmt` 3dparty library to format string instead of `std::stringstream` (much faster and more convenient)

//// utility/utility.hpp

#define USE_UTILITY_NETWORK_UNC 0                           // Enables network UNC utility functions, `pystring` library is required

// QD integration disabled by default

#ifndef ENABLE_QD_INTEGRATION
#define ENABLE_QD_INTEGRATION 0
#endif
#ifndef ENABLE_QD_DD_INTEGRATION
#define ENABLE_QD_DD_INTEGRATION 0
#endif
#ifndef ENABLE_QD_QD_INTEGRATION
#define ENABLE_QD_QD_INTEGRATION 0
#endif
