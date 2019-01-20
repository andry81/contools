#pragma once

#include <src/tacklelib_private.hpp>

#if ERROR_IF_EMPTY_PP_DEF(USE_UTILITY_ARC_LIBARCHIVE)

#include <tacklelib/tackle/path_string.hpp>

#include <libarchive/archive.h> // required for format codes

#include <cstdint>
#include <string>
#include <vector>


namespace utility {
namespace arc {
namespace libarchive {

    void write_archive(const std::vector<int> & input_filter_ids, int format_code,
        const std::string & options, const tackle::path_string & out_file_path,
        const tackle::path_string & in_dir, const std::vector<tackle::path_string> & in_file_paths,
        size_t read_block_size);

    void write_archive(const std::vector<int> & input_filter_ids, int format_code,
        const std::wstring & options, const tackle::path_wstring & out_file_path,
        const tackle::path_wstring & in_dir, const std::vector<tackle::path_wstring> & in_file_paths,
        size_t read_block_size);

}
}
}

#endif
