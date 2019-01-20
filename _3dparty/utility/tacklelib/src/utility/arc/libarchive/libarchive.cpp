#include <src/utility/arc/libarchive/libarchive.hpp>

#if ERROR_IF_EMPTY_PP_DEF(USE_UTILITY_ARC_LIBARCHIVE)

#include <tacklelib/utility/platform.hpp>
#include <tacklelib/utility/debug.hpp>
#include <tacklelib/utility/assert.hpp>
#include <tacklelib/utility/memory.hpp>
#include <tacklelib/utility/locale.hpp>
#include <tacklelib/utility/utility.hpp>

#include <tacklelib/tackle/file_handle.hpp>
#include <tacklelib/tackle/path_string.hpp>

#include <fmt/format.h>

#include <libarchive/archive_entry.h>

#include <cstdio>
#include <cstdlib>
#include <stdexcept>

#include <fcntl.h>
#include <sys/stat.h>
#ifdef UTILITY_COMPILER_CXX_MSC
#include <io.h>
#else
#include <unistd.h>
#endif


namespace utility {
namespace arc {
namespace libarchive {

namespace {

    FORCE_INLINE int _archive_write_set_options(archive * a, const std::string & options)
    {
        return archive_write_set_options(a, options.c_str());
    }

    FORCE_INLINE int _archive_write_set_options(archive * a, const std::wstring & options)
    {
        return archive_write_set_options(a, utility::convert_utf16_to_utf8_string(options).c_str());
    }

    FORCE_INLINE int _archive_write_open_filename(archive * a, const std::string & filename)
    {
        return archive_write_open_filename(a, filename.c_str());
    }

    FORCE_INLINE int _archive_write_open_filename(archive * a, const std::wstring & filename)
    {
        return archive_write_open_filename_w(a, filename.c_str());
    }

    void _archive_entry_set_pathname(archive_entry * entry, const std::string & name, utility::tag_string)
    {
        return archive_entry_set_pathname(entry, name.c_str());
    }

    void _archive_entry_set_pathname(archive_entry * entry, const std::string & name_utf8, utility::tag_wstring)
    {
        return archive_entry_set_pathname_utf8(entry, name_utf8.c_str());
    }

    template <class t_elem, class t_traits, class t_alloc, t_elem separator_char>
    FORCE_INLINE void _write_archive(const std::vector<int> & input_filter_ids, int format_code,
        const std::basic_string<t_elem, t_traits, t_alloc> & options,
        const tackle::path_basic_string<t_elem, t_traits, t_alloc, separator_char> & out_file_path,
        const tackle::path_basic_string<t_elem, t_traits, t_alloc, separator_char> & in_dir,
        const std::vector<tackle::path_basic_string<t_elem, t_traits, t_alloc, separator_char> > & in_file_paths,
        size_t read_block_size)
    {
        using native_basic_path_string_t = tackle::native_basic_path_string<t_elem, t_traits, t_alloc>;
        using basic_string_identity_t = utility::basic_string_identity<t_elem, t_traits, t_alloc>;
        using FileHandleT = tackle::FileHandle<t_elem, t_traits, t_alloc>;

        struct archive *a;
        struct archive_entry *entry;
        struct stat st;
        utility::Buffer buf{ read_block_size };
        int len;

        a = archive_write_new();

        for (auto filter_id : input_filter_ids) {
            switch (filter_id) {
            case ARCHIVE_FILTER_NONE:
                break;
            case ARCHIVE_FILTER_GZIP:
                archive_write_add_filter_gzip(a);
                break;
            case ARCHIVE_FILTER_BZIP2:
                archive_write_add_filter_bzip2(a);
                break;
            case ARCHIVE_FILTER_COMPRESS:
                archive_write_add_filter_compress(a);
                break;
            case ARCHIVE_FILTER_LZMA:
                archive_write_add_filter_lzma(a);
                break;
            case ARCHIVE_FILTER_XZ:
                archive_write_add_filter_xz(a);
                break;
            case ARCHIVE_FILTER_UU:
                archive_write_add_filter_uuencode(a);
                break;
            case ARCHIVE_FILTER_LZIP:
                archive_write_add_filter_lzip(a);
                break;
            case ARCHIVE_FILTER_LRZIP:
                archive_write_add_filter_lrzip(a);
                break;
            case ARCHIVE_FILTER_LZOP:
                archive_write_add_filter_lzop(a);
                break;
            case ARCHIVE_FILTER_GRZIP:
                archive_write_add_filter_grzip(a);
                break;
            case ARCHIVE_FILTER_LZ4:
                archive_write_add_filter_lz4(a);
                break;
            case ARCHIVE_FILTER_ZSTD:
                archive_write_add_filter_zstd(a);
                break;

                // not supported
            default:
                DEBUG_BREAK_THROW(true) std::runtime_error(
                    fmt::format("{:s}({:d}): archive filter does not supported: filter_id={:d}",
                        UTILITY_PP_FUNCSIG, UTILITY_PP_LINE, filter_id));
            }
        }

        if (format_code) {
            archive_write_set_format(a, format_code);
        }

        if (!options.empty()) {
            _archive_write_set_options(a, options);
        }

        _archive_write_open_filename(a, out_file_path);

        native_basic_path_string_t fixed_in_file;
        tackle::native_path_string fixed_in_file_ansi_or_utf8;
        tackle::path_string in_file_path_ansi_or_utf8;

        for (auto in_file_path : in_file_paths) {
            if (in_dir.empty() || utility::is_absolute_path(in_file_path)) {
                fixed_in_file = utility::fix_long_path(in_file_path, true); // must be fixed in case of the windows
                in_file_path_ansi_or_utf8 = fixed_in_file_ansi_or_utf8 = utility::convert_utf16_to_utf8_string(fixed_in_file);
            }
            else {
                fixed_in_file = utility::fix_long_path(in_dir / in_file_path, true); // must be fixed in case of the windows
                in_file_path_ansi_or_utf8 = utility::convert_utf16_to_utf8_string(in_file_path);
                fixed_in_file_ansi_or_utf8 = utility::convert_utf16_to_utf8_string(fixed_in_file);
            }

            stat(fixed_in_file_ansi_or_utf8.c_str(), &st);

            entry = archive_entry_new();

            _archive_entry_set_pathname(entry, in_file_path_ansi_or_utf8, utility::tag_string_by_elem<t_elem>{});
            archive_entry_set_size(entry, st.st_size);
            archive_entry_set_filetype(entry, AE_IFREG);
            archive_entry_set_ctime(entry, st.st_ctime, 0);
            archive_entry_set_atime(entry, st.st_atime, 0);
            archive_entry_set_mtime(entry, st.st_mtime, 0);
            archive_entry_set_uid(entry, st.st_uid);
            archive_entry_set_dev(entry, st.st_dev);
            archive_entry_set_gid(entry, st.st_gid);
            archive_entry_set_ino(entry, st.st_ino);
            archive_entry_set_nlink(entry, st.st_nlink);
            archive_entry_set_rdev(entry, st.st_rdev);
            archive_entry_set_perm(entry, 0644);
            archive_entry_set_mode(entry, st.st_mode);
            archive_write_header(a, entry);

            const FileHandleT in_file_handle =
                utility::open_file(fixed_in_file, UTILITY_LITERAL_STRING("rb", t_elem), utility::SharedAccess_DenyWrite); // should not be opened for writing

            const int in_file_desc = in_file_handle.fileno();
            len = read(in_file_desc, buf.get(), size_t(buf.size())); // buffer size can not be greater than max of size_t type here
            while (len > 0) {
                archive_write_data(a, buf.get(), len);
                len = read(in_file_desc, buf.get(), size_t(buf.size())); // buffer size can not be greater than max of size_t type here
            }

            archive_entry_free(entry);
        }

        archive_write_close(a);
        archive_write_free(a);
    }

}

    void write_archive(const std::vector<int> & input_filter_ids, int format_code,
        const std::string & options, const tackle::path_string & out_file_path,
        const tackle::path_string & in_dir, const std::vector<tackle::path_string> & in_file_paths,
        size_t read_block_size)
    {
        return _write_archive(input_filter_ids, format_code, options, out_file_path, in_dir, in_file_paths, read_block_size);
    }

    void write_archive(const std::vector<int> & input_filter_ids, int format_code,
        const std::wstring & options, const tackle::path_wstring & out_file_path,
        const tackle::path_wstring & in_dir, const std::vector<tackle::path_wstring> & in_file_paths,
        size_t read_block_size)
    {
        return _write_archive(input_filter_ids, format_code, options, out_file_path, in_dir, in_file_paths, read_block_size);
    }

}
}
}

#endif
