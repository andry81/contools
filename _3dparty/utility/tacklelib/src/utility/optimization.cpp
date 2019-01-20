#include <tacklelib/utility/optimization.hpp>


namespace utility {

const volatile void * volatile g_unused_param_storage_ptr = nullptr;

void UTILITY_PLATFORM_ATTRIBUTE_DISABLE_OPTIMIZATION unused_param(const volatile void * p)
{
    g_unused_param_storage_ptr = p;
}

}
