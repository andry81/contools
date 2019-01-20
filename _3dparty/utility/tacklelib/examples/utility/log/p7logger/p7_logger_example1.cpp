// NOTE:
//  this code is not tested for compilation and might be a pseudocode in some points
//

#include <src/utility/assert_private.hpp>
#include <src/utility/log/p7logger/p7_logger.hpp>

#include <tacklelib/tackle/file_handle.hpp>
#include <tacklelib/tackle/string.hpp>
#include <tacklelib/tackle/path_string.hpp>


// workaround for the bug in v4.7 around __FILE__/__LINE__ caching
#define P7_LOG_BASE_ID                          1024

inline void boo(tackle::log_handle & log_handle)
{
    DEBUG_ASSERT_TRUE(log_handle.is_kind_of(tackle::p7_trace_log_handle::static_type_index()));

    auto log_trace_handle = dynamic_cast<tackle::p7_trace_log_handle &>(log_handle);

    // do some logging
    LOG_P7_LOGM_INFO(log_trace_handle, P7_LOG_BASE_ID, "%s", "blabla...\nblabla");
}

inline void foo(tackle::log_handle & log_handle)
{
    DEBUG_ASSERT_TRUE(log_handle.is_kind_of(tackle::p7_client_log_handle::static_type_index()));

    auto log_client_handle = dynamic_cast<tackle::p7_client_log_handle &>(log_handle);
    auto log_trace_handle = tackle::p7_trace_log_handle{ LOG_P7_CREATE_TRACE(log_client_handle, "my_foo_channel") };

    boo(log_trace_handle);
}

int main()
{
    const tackle::path_string out_dir = "C:/my_loooooooooooooooong_log_output_dir"; // pretends to be longer than 256 characters

    // documentation: p7 logger expects `/P7.Dir` only in native format
    const tackle::native_path_string out_dir_unc = utility::fix_long_path(out_dir, true);
    const std::string log_cmd_line = std::move(std::string{ "/P7.Sink=FileBin /P7.Dir=" } + out_dir_unc.str());
    auto client_log_handle = tackle::p7_client_log_handle{ LOG_P7_CREATE_CLIENT(log_cmd_line) };

    // now we can pass logger handle out of bounds a module binary file 
    foo(client_log_handle);

    return 0;
}

