#pragma once

// DO NOT REMOVE, exists to avoid private/public headers mixing!
#ifndef UTILITY_UTILITY_HPP
#define UTILITY_UTILITY_HPP

#include <tacklelib/tacklelib.hpp>

#include <tacklelib/utility/platform.hpp>
#include <tacklelib/utility/type_identity.hpp>
#include <tacklelib/utility/static_assert.hpp>
#include <tacklelib/utility/type_traits.hpp>
#include <tacklelib/utility/assert.hpp>
#include <tacklelib/utility/debug.hpp>
#include <tacklelib/utility/math.hpp>
#include <tacklelib/utility/string.hpp>

#include <tacklelib/tackle/path_string.hpp>
#include <tacklelib/tackle/file_handle.hpp>

#ifdef UTILITY_COMPILER_CXX_MSC
#include <intrin.h>
#else
#include <x86intrin.h>  // Not just <immintrin.h> for compilers other than icc
#endif

#include <type_traits>
#include <limits>
#include <sstream>
#include <iomanip>
#include <algorithm>
#include <memory>
#include <cfloat>
#include <cmath>
#include <string>
#include <stdexcept>
#include <utility>
#include <cstdint>

#if defined(UTILITY_PLATFORM_POSIX)
#include <termios.h>
#include <unistd.h>
#endif

#include <cstdio>
#include <memory.h>

#if defined(UTILITY_PLATFORM_WINDOWS)
#include <conio.h>
#elif defined(UTILITY_PLATFORM_POSIX)
#else
#error platform is not implemented
#endif

// forwards
namespace tackle
{
    template <class t_elem, class t_traits, class t_alloc>
    class FileHandle;

    using FileHandleA = FileHandle<char, std::char_traits<char>, std::allocator<char> >;
    using FileHandleW = FileHandle<wchar_t, std::char_traits<wchar_t>, std::allocator<wchar_t> >;
}

namespace tackle
{
    template <class t_elem, class t_traits, class t_alloc>
    using unc_basic_path_string = path_basic_string<t_elem, t_traits, t_alloc, literal_separators<t_elem>::filesystem_unc_dir_separator_char>;

    using unc_path_string       = unc_basic_path_string<char, std::char_traits<char>, std::allocator<char> >;
    using unc_path_wstring      = unc_basic_path_string<wchar_t, std::char_traits<wchar_t>, std::allocator<wchar_t> >;
    using unc_path_u16string    = unc_basic_path_string<char16_t, std::char_traits<char16_t>, std::allocator<char16_t> >;
    using unc_path_u32string    = unc_basic_path_string<char32_t, std::char_traits<char32_t>, std::allocator<char32_t> >;

    template <typename t_elem>
    struct tag_unc_path_basic_string    : tag_path_basic_string<t_elem, literal_separators<t_elem>::filesystem_unc_dir_separator_char> {};

    template <class t_elem>
    struct tag_unc_basic_path_string    : tag_unc_path_basic_string<t_elem> {};

    struct tag_unc_path_string          : tag_unc_basic_path_string<char> {};
    struct tag_unc_path_wstring         : tag_unc_basic_path_string<wchar_t> {};
    struct tag_unc_path_u16string       : tag_unc_basic_path_string<char16_t> {};
    struct tag_unc_path_u32string       : tag_unc_basic_path_string<char32_t> {};

    template <typename t_elem>
    struct tag_unc_path_string_by_elem :
        std::conditional<std::is_same<char, t_elem>::value,
            tag_unc_path_string,
            typename std::conditional<std::is_same<wchar_t, t_elem>::value,
                tag_unc_path_wstring,
                typename std::conditional<std::is_same<char16_t, t_elem>::value,
                    tag_unc_path_u16string,
                    typename std::conditional<std::is_same<char32_t, t_elem>::value,
                        tag_unc_path_u32string,
                        utility::void_
                    >::type
                >::type
            >::type
        >::type
    {
    };

}

namespace utility
{

    enum SharedAccess
    {
#if defined(UTILITY_PLATFORM_WINDOWS)
        SharedAccess_DenyRW     = _SH_DENYRW,   // deny read/write mode
        SharedAccess_DenyWrite  = _SH_DENYWR,   // deny write mode
        SharedAccess_DenyRead   = _SH_DENYRD,   // deny read mode
        SharedAccess_DenyNone   = _SH_DENYNO,   // deny none mode
        SharedAccess_Secure     = _SH_SECURE    // secure mode
#elif defined(UTILITY_PLATFORM_POSIX)
        SharedAccess_DenyRW     = 0x10,         // deny read/write mode
        SharedAccess_DenyWrite  = 0x20,         // deny write mode
        SharedAccess_DenyRead   = 0x30,         // deny read mode
        SharedAccess_DenyNone   = 0x40,         // deny none mode
        SharedAccess_Secure     = 0x80          // secure mode
#endif
    };

    uint64_t get_file_size(tackle::FileHandleA file_handle);
    uint64_t get_file_size(tackle::FileHandleW file_handle);

    bool is_files_equal(tackle::FileHandleA left_file_handle, tackle::FileHandleA right_file_handle, size_t read_bloc);
    bool is_files_equal(tackle::FileHandleW left_file_handle, tackle::FileHandleW right_file_handle, size_t read_block_size);

#if ERROR_IF_EMPTY_PP_DEF(USE_UTILITY_NETWORK_UNC)

#if defined(UTILITY_PLATFORM_WINDOWS)
    bool convert_local_to_network_unc_path(tackle::generic_path_string from_path, tackle::unc_path_string & to_path, bool throw_on_error);
    bool convert_local_to_network_unc_path(tackle::generic_path_wstring from_path, tackle::unc_path_wstring & to_path, bool throw_on_error);

    bool convert_local_to_network_unc_path(tackle::native_path_string from_path, tackle::unc_path_string & to_path, bool throw_on_error);
    bool convert_local_to_network_unc_path(tackle::native_path_wstring from_path, tackle::unc_path_wstring & to_path, bool throw_on_error);

    tackle::unc_path_string convert_local_to_network_unc_path(tackle::generic_path_string from_path, tackle::tag_unc_path_string, bool throw_on_error);
    tackle::unc_path_wstring convert_local_to_network_unc_path(tackle::generic_path_wstring from_path, tackle::tag_unc_path_wstring, bool throw_on_error);

    tackle::unc_path_string convert_local_to_network_unc_path(tackle::native_path_string from_path, tackle::tag_unc_path_string, bool throw_on_error);
    tackle::unc_path_wstring convert_local_to_network_unc_path(tackle::native_path_wstring from_path, tackle::tag_unc_path_wstring, bool throw_on_error);

    bool convert_network_unc_to_local_path(tackle::unc_path_string from_path, tackle::generic_path_string & to_path, bool throw_on_error);
    bool convert_network_unc_to_local_path(tackle::unc_path_wstring from_path, tackle::generic_path_wstring & to_path, bool throw_on_error);

    bool convert_network_unc_to_local_path(tackle::unc_path_string from_path, tackle::native_path_string & to_path, bool throw_on_error);
    bool convert_network_unc_to_local_path(tackle::unc_path_wstring from_path, tackle::native_path_wstring & to_path, bool throw_on_error);

    tackle::generic_path_string convert_network_unc_to_local_path(tackle::unc_path_string from_path, tackle::tag_generic_path_string, bool throw_on_error);
    tackle::generic_path_wstring convert_network_unc_to_local_path(tackle::unc_path_wstring from_path, tackle::tag_generic_path_wstring, bool throw_on_error);

    tackle::native_path_string convert_network_unc_to_local_path(tackle::unc_path_string from_path, tackle::tag_native_path_string, bool throw_on_error);
    tackle::native_path_wstring convert_network_unc_to_local_path(tackle::unc_path_wstring from_path, tackle::tag_native_path_wstring, bool throw_on_error);
#endif

#endif

    bool convert_local_to_local_unc_path(tackle::generic_path_string from_path, tackle::unc_path_string & to_path, bool throw_on_error);
    bool convert_local_to_local_unc_path(tackle::generic_path_wstring from_path, tackle::unc_path_wstring & to_path, bool throw_on_error);

#if defined(UTILITY_PLATFORM_WINDOWS)
    bool convert_local_to_local_unc_path(tackle::native_path_string from_path, tackle::unc_path_string & to_path, bool throw_on_error);
    bool convert_local_to_local_unc_path(tackle::native_path_wstring from_path, tackle::unc_path_wstring & to_path, bool throw_on_error);
#endif

    tackle::unc_path_string convert_local_to_local_unc_path(tackle::generic_path_string from_path, tackle::tag_unc_path_string, bool throw_on_error);
    tackle::unc_path_wstring convert_local_to_local_unc_path(tackle::generic_path_wstring from_path, tackle::tag_unc_path_wstring, bool throw_on_error);

#if defined(UTILITY_PLATFORM_WINDOWS)
    tackle::unc_path_string convert_local_to_local_unc_path(tackle::native_path_string from_path, tackle::tag_unc_path_string, bool throw_on_error);
    tackle::unc_path_wstring convert_local_to_local_unc_path(tackle::native_path_wstring from_path, tackle::tag_unc_path_wstring, bool throw_on_error);
#endif

    bool convert_local_unc_to_local_path(tackle::unc_path_string from_path, tackle::generic_path_string & to_path);
    bool convert_local_unc_to_local_path(tackle::unc_path_wstring from_path, tackle::generic_path_wstring & to_path);

#if defined(UTILITY_PLATFORM_WINDOWS)
    bool convert_local_unc_to_local_path(tackle::unc_path_string from_path, tackle::native_path_string & to_path);
    bool convert_local_unc_to_local_path(tackle::unc_path_wstring from_path, tackle::native_path_wstring & to_path);
#endif

    tackle::generic_path_string convert_local_unc_to_local_path(tackle::unc_path_string from_path, tackle::tag_generic_path_string);
    tackle::generic_path_wstring convert_local_unc_to_local_path(tackle::unc_path_wstring from_path, tackle::tag_generic_path_wstring);

#if defined(UTILITY_PLATFORM_WINDOWS)
    tackle::native_path_string convert_local_unc_to_local_path(tackle::unc_path_string from_path, tackle::tag_native_path_string);
    tackle::native_path_wstring convert_local_unc_to_local_path(tackle::unc_path_wstring from_path, tackle::tag_native_path_wstring);
#endif

    tackle::native_path_string fix_long_path(tackle::generic_path_string file_path, bool throw_on_error);
    tackle::native_path_wstring fix_long_path(tackle::generic_path_wstring file_path, bool throw_on_error);

#if defined(UTILITY_PLATFORM_WINDOWS)
    tackle::native_path_string fix_long_path(tackle::native_path_string file_path, bool throw_on_error);
    tackle::native_path_wstring fix_long_path(tackle::native_path_wstring file_path, bool throw_on_error);
#endif

    tackle::FileHandleA recreate_file(tackle::generic_path_string file_path, const char * mode, SharedAccess share_flags,
        size_t size = 0, uint32_t fill_by = 0, bool throw_on_error = true);
    tackle::FileHandleW recreate_file(tackle::generic_path_wstring file_path, const wchar_t * mode, SharedAccess share_flags,
        size_t size = 0, uint32_t fill_by = 0, bool throw_on_error = true);

#if defined(UTILITY_PLATFORM_WINDOWS)
    tackle::FileHandleA recreate_file(tackle::native_path_string file_path, const char * mode, SharedAccess share_flags,
        size_t size = 0, uint32_t fill_by = 0, bool throw_on_error = true);
    tackle::FileHandleW recreate_file(tackle::native_path_wstring file_path, const wchar_t * mode, SharedAccess share_flags,
        size_t size = 0, uint32_t fill_by = 0, bool throw_on_error = true);
#endif

    tackle::FileHandleA create_file(tackle::generic_path_string file_path, const char * mode, SharedAccess share_flags,
        size_t size = 0, uint32_t fill_by = 0, bool throw_on_error = true);
    tackle::FileHandleW create_file(tackle::generic_path_wstring file_path, const wchar_t * mode, SharedAccess share_flags,
        size_t size = 0, uint32_t fill_by = 0, bool throw_on_error = true);

#if defined(UTILITY_PLATFORM_WINDOWS)
    tackle::FileHandleA create_file(tackle::native_path_string file_path, const char * mode, SharedAccess share_flags,
        size_t size = 0, uint32_t fill_by = 0, bool throw_on_error = true);
    tackle::FileHandleW create_file(tackle::native_path_wstring file_path, const wchar_t * mode, SharedAccess share_flags,
        size_t size = 0, uint32_t fill_by = 0, bool throw_on_error = true);
#endif

    tackle::FileHandleA open_file(tackle::generic_path_string file_path, const char * mode, SharedAccess share_flags,
        size_t creation_size = 0, size_t resize_if_existed = -1, uint32_t fill_by_on_creation = 0,
        bool throw_on_error = true);
    tackle::FileHandleW open_file(tackle::generic_path_wstring file_path, const wchar_t * mode, SharedAccess share_flags,
        size_t creation_size = 0, size_t resize_if_existed = -1, uint32_t fill_by_on_creation = 0,
        bool throw_on_error = true);

#if defined(UTILITY_PLATFORM_WINDOWS)
    tackle::FileHandleA open_file(tackle::native_path_string file_path, const char * mode, SharedAccess share_flags,
        size_t creation_size = 0, size_t resize_if_existed = -1, uint32_t fill_by_on_creation = 0,
        bool throw_on_error = true);
    tackle::FileHandleW open_file(tackle::native_path_wstring file_path, const wchar_t * mode, SharedAccess share_flags,
        size_t creation_size = 0, size_t resize_if_existed = -1, uint32_t fill_by_on_creation = 0,
        bool throw_on_error = true);
#endif

    bool is_directory_path(tackle::generic_path_string path, bool throw_on_error);
    bool is_directory_path(tackle::generic_path_wstring path, bool throw_on_error);

#if defined(UTILITY_PLATFORM_WINDOWS)
    bool is_directory_path(tackle::native_path_string path, bool throw_on_error);
    bool is_directory_path(tackle::native_path_wstring path, bool throw_on_error);
#endif

    bool is_regular_file(tackle::generic_path_string path, bool throw_on_error);
    bool is_regular_file(tackle::generic_path_wstring path, bool throw_on_error);

#if defined(UTILITY_PLATFORM_WINDOWS)
    bool is_regular_file(tackle::native_path_string path, bool throw_on_error);
    bool is_regular_file(tackle::native_path_wstring path, bool throw_on_error);
#endif

    bool is_symlink_path(tackle::generic_path_string path, bool throw_on_error);
    bool is_symlink_path(tackle::generic_path_wstring path, bool throw_on_error);

#if defined(UTILITY_PLATFORM_WINDOWS)
    bool is_symlink_path(tackle::native_path_string path, bool throw_on_error);
    bool is_symlink_path(tackle::native_path_wstring path, bool throw_on_error);
#endif

    bool is_path_exists(tackle::generic_path_string path, bool throw_on_error);
    bool is_path_exists(tackle::generic_path_wstring path, bool throw_on_error);

#if defined(UTILITY_PLATFORM_WINDOWS)
    bool is_path_exists(tackle::native_path_string path, bool throw_on_error);
    bool is_path_exists(tackle::native_path_wstring path, bool throw_on_error);
#endif

    bool create_directory(tackle::generic_path_string path, bool throw_on_error);
    bool create_directory(tackle::generic_path_wstring path, bool throw_on_error);

#if defined(UTILITY_PLATFORM_WINDOWS)
    bool create_directory(tackle::native_path_string path, bool throw_on_error);
    bool create_directory(tackle::native_path_wstring path, bool throw_on_error);
#endif

    bool create_directory_if_not_exist(tackle::generic_path_string path, bool throw_on_error); // no exception if directory already exists
    bool create_directory_if_not_exist(tackle::generic_path_wstring path, bool throw_on_error); // no exception if directory already exists

#if defined(UTILITY_PLATFORM_WINDOWS)
    bool create_directory_if_not_exist(tackle::native_path_string path, bool throw_on_error); // no exception if directory already exists
    bool create_directory_if_not_exist(tackle::native_path_wstring path, bool throw_on_error); // no exception if directory already exists
#endif

    void create_directory_symlink(tackle::generic_path_string to, tackle::generic_path_string from, bool throw_on_error);
    void create_directory_symlink(tackle::generic_path_wstring to, tackle::generic_path_wstring from, bool throw_on_error);

#if defined(UTILITY_PLATFORM_WINDOWS)
    void create_directory_symlink(tackle::native_path_string to, tackle::native_path_string from, bool throw_on_error);
    void create_directory_symlink(tackle::native_path_wstring to, tackle::native_path_wstring from, bool throw_on_error);
#endif

    bool create_directories(tackle::generic_path_string path, bool throw_on_error);
    bool create_directories(tackle::generic_path_wstring path, bool throw_on_error);

#if defined(UTILITY_PLATFORM_WINDOWS)
    bool create_directories(tackle::native_path_string path, bool throw_on_error);
    bool create_directories(tackle::native_path_wstring path, bool throw_on_error);
#endif

    bool remove_directory(tackle::generic_path_string path, bool recursively, bool throw_on_error);
    bool remove_directory(tackle::generic_path_wstring path, bool recursively, bool throw_on_error);

#if defined(UTILITY_PLATFORM_WINDOWS)
    bool remove_directory(tackle::native_path_string path, bool recursively, bool throw_on_error);
    bool remove_directory(tackle::native_path_wstring path, bool recursively, bool throw_on_error);
#endif

    bool remove_file(tackle::generic_path_string path, bool throw_on_error);
    bool remove_file(tackle::generic_path_wstring path, bool throw_on_error);

#if defined(UTILITY_PLATFORM_WINDOWS)
    bool remove_file(tackle::native_path_string path, bool throw_on_error);
    bool remove_file(tackle::native_path_wstring path, bool throw_on_error);
#endif

    bool remove_symlink(tackle::generic_path_string path, bool throw_on_error);
    bool remove_symlink(tackle::generic_path_wstring path, bool throw_on_error);

#if defined(UTILITY_PLATFORM_WINDOWS)
    bool remove_symlink(tackle::native_path_string path, bool throw_on_error);
    bool remove_symlink(tackle::native_path_wstring path, bool throw_on_error);
#endif

    bool is_relative_path(tackle::generic_path_string path);
    bool is_relative_path(tackle::generic_path_wstring path);

#if defined(UTILITY_PLATFORM_WINDOWS)
    bool is_relative_path(tackle::native_path_string path);
    bool is_relative_path(tackle::native_path_wstring path);
#endif

    bool is_absolute_path(tackle::generic_path_string path);
    bool is_absolute_path(tackle::generic_path_wstring path);

#if defined(UTILITY_PLATFORM_WINDOWS)
    bool is_absolute_path(tackle::native_path_string path);
    bool is_absolute_path(tackle::native_path_wstring path);
#endif

    tackle::generic_path_string get_relative_path(tackle::generic_path_string from_path, tackle::generic_path_string to_path, bool throw_on_error);
    tackle::generic_path_wstring get_relative_path(tackle::generic_path_wstring from_path, tackle::generic_path_wstring to_path, bool throw_on_error);

#if defined(UTILITY_PLATFORM_WINDOWS)
    tackle::native_path_string get_relative_path(tackle::native_path_string from_path, tackle::native_path_string to_path, bool throw_on_error);
    tackle::native_path_wstring get_relative_path(tackle::native_path_wstring from_path, tackle::native_path_wstring to_path, bool throw_on_error);
#endif

    tackle::generic_path_string get_absolute_path(tackle::generic_path_string from_path, tackle::generic_path_string to_path);
    tackle::generic_path_wstring get_absolute_path(tackle::generic_path_wstring from_path, tackle::generic_path_wstring to_path);

#if defined(UTILITY_PLATFORM_WINDOWS)
    tackle::native_path_string get_absolute_path(tackle::native_path_string from_path, tackle::native_path_string to_path);
    tackle::native_path_wstring get_absolute_path(tackle::native_path_wstring from_path, tackle::native_path_wstring to_path);
#endif

    tackle::generic_path_string get_absolute_path(tackle::generic_path_string path, bool throw_on_error);
    tackle::generic_path_wstring get_absolute_path(tackle::generic_path_wstring path, bool throw_on_error);

#if defined(UTILITY_PLATFORM_WINDOWS)
    tackle::native_path_string get_absolute_path(tackle::native_path_string path, bool throw_on_error);
    tackle::native_path_wstring get_absolute_path(tackle::native_path_wstring path, bool throw_on_error);
#endif

    tackle::generic_path_string get_current_path(bool throw_on_error, tackle::tag_generic_path_string);
    tackle::generic_path_wstring get_current_path(bool throw_on_error, tackle::tag_generic_path_wstring);

#if defined(UTILITY_PLATFORM_WINDOWS)
    tackle::native_path_string get_current_path(bool throw_on_error, tackle::tag_native_path_string);
    tackle::native_path_wstring get_current_path(bool throw_on_error, tackle::tag_native_path_wstring);
#endif

    std::string get_file_name(tackle::generic_path_string path);
    std::wstring get_file_name(tackle::generic_path_wstring path);

#if defined(UTILITY_PLATFORM_WINDOWS)
    std::string get_file_name(tackle::native_path_string path);
    std::wstring get_file_name(tackle::native_path_wstring path);
#endif

    std::string get_file_name_stem(tackle::generic_path_string path);
    std::wstring get_file_name_stem(tackle::generic_path_wstring path);

#if defined(UTILITY_PLATFORM_WINDOWS)
    std::string get_file_name_stem(tackle::native_path_string path);
    std::wstring get_file_name_stem(tackle::native_path_wstring path);
#endif

    tackle::generic_path_string get_parent_path(tackle::generic_path_string path);
    tackle::generic_path_wstring get_parent_path(tackle::generic_path_wstring path);

#if defined(UTILITY_PLATFORM_WINDOWS)
    tackle::native_path_string get_parent_path(tackle::native_path_string path);
    tackle::native_path_wstring get_parent_path(tackle::native_path_wstring path);
#endif

    tackle::generic_path_string get_module_file_path(tackle::tag_generic_path_string, bool cached);
    tackle::generic_path_wstring get_module_file_path(tackle::tag_generic_path_wstring, bool cached);

#if defined(UTILITY_PLATFORM_WINDOWS)
    tackle::native_path_string get_module_file_path(tackle::tag_native_path_string, bool cached);
    tackle::native_path_wstring get_module_file_path(tackle::tag_native_path_wstring, bool cached);
#endif

    tackle::generic_path_string get_module_dir_path(tackle::tag_generic_path_string, bool cached);
    tackle::generic_path_wstring get_module_dir_path(tackle::tag_generic_path_wstring, bool cached);

#if defined(UTILITY_PLATFORM_WINDOWS)
    tackle::native_path_string get_module_dir_path(tackle::tag_native_path_string, bool cached);
    tackle::native_path_wstring get_module_dir_path(tackle::tag_native_path_wstring, bool cached);
#endif

    tackle::generic_path_string get_lexically_normal_path(tackle::generic_path_string path);
    tackle::generic_path_wstring get_lexically_normal_path(tackle::generic_path_wstring path);

#if defined(UTILITY_PLATFORM_WINDOWS)
    tackle::native_path_string get_lexically_normal_path(tackle::native_path_string path);
    tackle::native_path_wstring get_lexically_normal_path(tackle::native_path_wstring path);
#endif

    tackle::generic_path_string get_lexically_relative_path(tackle::generic_path_string from_path, tackle::generic_path_string to_path);
    tackle::generic_path_wstring get_lexically_relative_path(tackle::generic_path_wstring from_path, tackle::generic_path_wstring to_path);

#if defined(UTILITY_PLATFORM_WINDOWS)
    tackle::native_path_string get_lexically_relative_path(tackle::native_path_string from_path, tackle::native_path_string to_path);
    tackle::native_path_wstring get_lexically_relative_path(tackle::native_path_wstring from_path, tackle::native_path_wstring to_path);
#endif

    tackle::generic_path_string convert_to_generic_path(const char * path, size_t len);
    tackle::generic_path_wstring convert_to_generic_path(const wchar_t * path, size_t len);

    tackle::generic_path_string convert_to_generic_path(std::string path);
    tackle::generic_path_wstring convert_to_generic_path(std::wstring path);

    tackle::generic_path_string convert_to_generic_path(tackle::generic_path_string path);
    tackle::generic_path_wstring convert_to_generic_path(tackle::generic_path_wstring path);

#if defined(UTILITY_PLATFORM_WINDOWS)
    tackle::generic_path_string convert_to_generic_path(tackle::native_path_string path);
    tackle::generic_path_wstring convert_to_generic_path(tackle::native_path_wstring path);
#endif

    tackle::native_path_string convert_to_native_path(const char * path, size_t len);
    tackle::native_path_wstring convert_to_native_path(const wchar_t * path, size_t len);

    tackle::native_path_string convert_to_native_path(std::string path);
    tackle::native_path_wstring convert_to_native_path(std::wstring path);

    tackle::native_path_string convert_to_native_path(tackle::generic_path_string path);
    tackle::native_path_wstring convert_to_native_path(tackle::generic_path_wstring path);

#if defined(UTILITY_PLATFORM_WINDOWS)
    tackle::native_path_string convert_to_native_path(tackle::native_path_string path);
    tackle::native_path_wstring convert_to_native_path(tackle::native_path_wstring path);
#endif

    tackle::generic_path_string truncate_path_relative_prefix(tackle::generic_path_string path);
    tackle::generic_path_wstring truncate_path_relative_prefix(tackle::generic_path_wstring path);

#if defined(UTILITY_PLATFORM_WINDOWS)
    tackle::native_path_string truncate_path_relative_prefix(tackle::native_path_string path);
    tackle::native_path_wstring truncate_path_relative_prefix(tackle::native_path_wstring path);
#endif

    template<typename T>
    FORCE_INLINE T str_to_int(const std::string & str, std::size_t * pos = nullptr, int base = 10, bool throw_on_error = false)
    {
        T i{}; // value initialization default construction is required in case if an error has happend and throw_on_error = false

        try {
            i = static_cast<T>(std::stoi(str, pos, base));
        }
        // by default suppress exceptions
        catch (const std::invalid_argument & ex) {
            UTILITY_UNUSED_STATEMENT(ex);
            DEBUG_BREAK_IN_DEBUGGER(true);
            if (throw_on_error) {
                throw;
            }
        }
        catch (const std::out_of_range & ex) {
            UTILITY_UNUSED_STATEMENT(ex);
            DEBUG_BREAK_IN_DEBUGGER(true);
            if (throw_on_error) {
                throw;
            }
        }
        catch (const std::exception & ex) {
            UTILITY_UNUSED_STATEMENT(ex);
            DEBUG_BREAK_IN_DEBUGGER(true);
            if (throw_on_error) {
                throw;
            }
        }
        catch (...) {
            DEBUG_BREAK_IN_DEBUGGER(true);
            if (throw_on_error) {
                throw;
            }
        }

        return i;
    }

    template<typename T>
    FORCE_INLINE std::string int_to_hex(T i, size_t padding = sizeof(T) * 2)
    {
#if ERROR_IF_EMPTY_PP_DEF(USE_FMT_LIBRARY_INSTEAD_STD_STRINGSTREAMS)
        const std::string fmt_format = utility::string_format(256, "{:%s%ux}", padding ? "0" : "", padding ? padding : 0); // faster than fmt format
        return fmt::format(fmt_format, int64_t(i));
#else
        std::stringstream stream;
        stream << std::setfill('0') << std::setw(padding) << std::hex << i;
        return stream.str();
#endif
    }

    template<typename T>
    FORCE_INLINE std::string int_to_dec(T i, size_t padding = sizeof(T) * 2)
    {
#if ERROR_IF_EMPTY_PP_DEF(USE_FMT_LIBRARY_INSTEAD_STD_STRINGSTREAMS)
        const std::string fmt_format = utility::string_format(256, "{:%s%ud}", padding ? "0" : "", padding ? padding : 0); // faster than fmt format
        return fmt::format(fmt_format, int64_t(i));
#else
        std::stringstream stream;
        stream << std::setfill('0') << std::setw(padding) << std::dec << i;
        return stream.str();
#endif
    }

    template<typename T>
    FORCE_INLINE void int_to_bin_forceinline(std::string & ret, T i, bool first_bit_is_lowest_bit = false)
    {
        STATIC_ASSERT_TRUE(std::is_trivially_copyable<T>::value, "T must be a trivial copy type");

        CONSTEXPR const size_t num_bytes = sizeof(T);

        ret.resize(num_bytes * CHAR_BIT);

        char * data_ptr = &ret[0]; // faster than for-ed operator[] in the Debug

        size_t char_offset;
        const uint32_t * chunks_ptr = (const uint32_t *)&i;

        const size_t num_whole_chunks = num_bytes / 4;
        const size_t chunks_remainder = num_bytes % 4;

        if (first_bit_is_lowest_bit) {
            char_offset = 0;

            for (size_t i = 0; i < num_whole_chunks; i++, chunks_ptr++) {
                for (size_t j = 0; j < 32; j++, char_offset++) {
                    data_ptr[char_offset] = (chunks_ptr[i] & (0x01U << j)) ? '1' : '0';
                }
            }
            if (chunks_remainder) {
                for (size_t j = 0; j < chunks_remainder * CHAR_BIT; j++, char_offset++) {
                    data_ptr[char_offset] = (chunks_ptr[i] & (0x01U << j)) ? '1' : '0';
                }
            }

            data_ptr[char_offset] = '\0';
        }
        else {
            char_offset = num_bytes * CHAR_BIT;

            data_ptr[char_offset] = '\0';

            for (size_t i = 0; i < num_whole_chunks; i++, chunks_ptr++) {
                for (size_t j = 0; j < 32; j++, char_offset--) {
                    data_ptr[char_offset] = (chunks_ptr[i] & (0x01U << j)) ? '1' : '0';
                }
            }
            if (chunks_remainder) {
                for (size_t j = 0; j < chunks_remainder * CHAR_BIT; j++, char_offset--) {
                    data_ptr[char_offset] = (chunks_ptr[i] & (0x01U << j)) ? '1' : '0';
                }
            }
        }
    }

    template<typename T>
    inline std::string int_to_bin(T i, bool first_bit_is_lowest_bit = false)
    {
        std::string res;
        int_to_bin_forceinline(res, i, first_bit_is_lowest_bit);
        return res;
    }

    FORCE_INLINE_ALWAYS uint8_t reverse(uint8_t byte)
    {
        byte = (byte & 0xF0) >> 4 | (byte & 0x0F) << 4;
        byte = (byte & 0xCC) >> 2 | (byte & 0x33) << 2;
        byte = (byte & 0xAA) >> 1 | (byte & 0x55) << 1;
        return byte;
    }

    template <typename T>
    FORCE_INLINE T reverse(T value)
    {
        T res = 0;
        for (size_t i = 0; i < sizeof(value) * CHAR_BIT; i++) {
            if (value & (0x01U << i)) {
                res |= (0x01U << (sizeof(value) * CHAR_BIT - i - 1));
            }
        }
        return res;
    }

    template<typename T>
    FORCE_INLINE uint32_t t_rotl32(uint32_t n, unsigned int c)
    {
        STATIC_ASSERT_GE(sizeof(uint32_t), sizeof(T), "sizeof(T) must be less or equal to the sizeof(uint32_t)");
        const uint32_t byte_mask = uint32_t(-1) >> (CHAR_BIT * (sizeof(uint32_t) - sizeof(T)));
        const uint32_t mask = (CHAR_BIT * sizeof(T) - 1);
        c &= mask;
        return byte_mask & ((n << c) | ((byte_mask & n) >> (mask & math::negate(c))));
    }

    template<typename T>
    FORCE_INLINE uint32_t t_rotr32(uint32_t n, unsigned int c)
    {
        STATIC_ASSERT_GE(sizeof(uint32_t), sizeof(T), "sizeof(T) must be less or equal to the sizeof(uint32_t)");
        const uint32_t byte_mask = uint32_t(-1) >> (CHAR_BIT * (sizeof(uint32_t) - sizeof(T)));
        const uint32_t mask = (CHAR_BIT * sizeof(T) - 1);
        c &= mask;
        return byte_mask & (((byte_mask & n) >> c) | (n << (mask & math::negate(c))));
    }

    template<typename T>
    FORCE_INLINE uint64_t t_rotl64(uint64_t n, unsigned int c)
    {
        STATIC_ASSERT_GE(sizeof(uint64_t), sizeof(T), "sizeof(T) must be less or equal to the sizeof(uint64_t)");
        const uint64_t byte_mask = uint64_t(-1) >> (CHAR_BIT * (sizeof(uint64_t) - sizeof(T)));
        const uint64_t mask = (CHAR_BIT * sizeof(T) - 1);
        c &= mask;
        return byte_mask & ((n << c) | ((byte_mask & n) >> (mask & math::negate(c))));
    }

    template<typename T>
    FORCE_INLINE uint64_t t_rotr64(uint64_t n, unsigned int c)
    {
        STATIC_ASSERT_GE(sizeof(uint64_t), sizeof(T), "sizeof(T) must be less or equal to the sizeof(uint64_t)");
        const uint64_t byte_mask = uint64_t(-1) >> (CHAR_BIT * (sizeof(uint64_t) - sizeof(T)));
        const uint64_t mask = (CHAR_BIT * sizeof(T) - 1);
        c &= mask;
        return byte_mask & (((byte_mask & n) >> c) | (n << (mask & math::negate(c))));
    }

    FORCE_INLINE_ALWAYS uint32_t rotl8(uint32_t n, unsigned int c)
    {
#if defined(UTILITY_COMPILER_CXX_MSC) && ERROR_IF_EMPTY_PP_DEF(ENABLE_INTRINSIC)
        return _rotl8(unsigned char(n), unsigned char(c));
#else
        return t_rotl32<uint8_t>(n, c);
#endif
    }

    FORCE_INLINE_ALWAYS uint32_t rotr8(uint32_t n, unsigned int c)
    {
#if defined(UTILITY_COMPILER_CXX_MSC) && ERROR_IF_EMPTY_PP_DEF(ENABLE_INTRINSIC)
        return _rotr8(unsigned char(n), unsigned char(c));
#else
        return t_rotr32<uint8_t>(n, c);
#endif
    }

    FORCE_INLINE_ALWAYS uint32_t rotl16(uint32_t n, unsigned int c)
    {
#if defined(UTILITY_COMPILER_CXX_MSC) && ERROR_IF_EMPTY_PP_DEF(ENABLE_INTRINSIC)
        return _rotl16(unsigned short(n), unsigned char(c));
#else
        return t_rotl32<uint16_t>(n, c);
#endif
    }

    FORCE_INLINE_ALWAYS uint32_t rotr16(uint32_t n, unsigned int c)
    {
#if defined(UTILITY_COMPILER_CXX_MSC) && ERROR_IF_EMPTY_PP_DEF(ENABLE_INTRINSIC)
        return _rotr16(unsigned short(n), unsigned char(c));
#else
        return t_rotr32<uint16_t>(n, c);
#endif
    }

    FORCE_INLINE_ALWAYS uint32_t rotl32(uint32_t n, unsigned int c)
    {
#if defined(UTILITY_COMPILER_CXX_MSC) && ERROR_IF_EMPTY_PP_DEF(ENABLE_INTRINSIC)
        return _rotl(unsigned int(n), int(c));
#else
        return t_rotl32<uint32_t>(n, c);
#endif
    }

    FORCE_INLINE_ALWAYS uint32_t rotr32(uint32_t n, unsigned int c)
    {
#if defined(UTILITY_COMPILER_CXX_MSC) && ERROR_IF_EMPTY_PP_DEF(ENABLE_INTRINSIC)
        return _rotr(unsigned int(n), int(c));
#else
        return t_rotr32<uint32_t>(n, c);
#endif
    }

    FORCE_INLINE_ALWAYS uint64_t rotl64(uint64_t n, unsigned int c)
    {
#if defined(UTILITY_COMPILER_CXX_MSC) && ERROR_IF_EMPTY_PP_DEF(ENABLE_INTRINSIC)
        return _rotl64(unsigned long long(n), int(c));
#else
        return t_rotl64<uint64_t>(n, c);
#endif
    }

    FORCE_INLINE_ALWAYS uint64_t rotr64(uint64_t n, unsigned int c)
    {
#if defined(UTILITY_COMPILER_CXX_MSC) && ERROR_IF_EMPTY_PP_DEF(ENABLE_INTRINSIC)
        return _rotr64(unsigned long long(n), int(c));
#else
        return t_rotr64<uint64_t>(n, c);
#endif
    }

    // reads from keypress, doesn't echo
    inline int getch()
    {
#if defined(UTILITY_PLATFORM_WINDOWS)
        return ::_getch();
#elif defined(UTILITY_PLATFORM_POSIX)
        struct termios oldattr, newattr;
        int ch;
        tcgetattr(STDIN_FILENO, &oldattr);
        newattr = oldattr;
        newattr.c_lflag &= ~(ICANON | ECHO);
        tcsetattr(STDIN_FILENO, TCSANOW, &newattr);
        ch = getchar();
        tcsetattr(STDIN_FILENO, TCSANOW, &oldattr);
        return ch;
#endif
    }

    // reads from keypress, echoes
    inline int getche()
    {
#if defined(UTILITY_PLATFORM_WINDOWS)
        return ::_getche();
#elif defined(UTILITY_PLATFORM_POSIX)
        struct termios oldattr, newattr;
        int ch;
        tcgetattr(STDIN_FILENO, &oldattr);
        newattr = oldattr;
        newattr.c_lflag &= ~(ICANON);
        tcsetattr(STDIN_FILENO, TCSANOW, &newattr);
        ch = getchar();
        tcsetattr(STDIN_FILENO, TCSANOW, &oldattr);
        return ch;
#endif
    }

    // reset std::stringstream object
    // Based on: https://stackoverflow.com/questions/7623650/resetting-a-stringstream
    //
    FORCE_INLINE void reset_stringstream(std::stringstream & ss)
    {
        const static std::stringstream initial;

        ss.str(std::string{});
        ss.clear();
        ss.copyfmt(initial);
    }

    FORCE_INLINE double modf(double d)
    {
        double whole;
        return std::modf(d, &whole);
    }

    // Calculates tick step between min/max range closest to power-of-10 and if not enough, then
    // splits in twice down to a value multiple to `5` and if not enough, then
    // splits in twice down to a value multiple to `2`.
    // The idea all of this is to end a floating point value by a finite set of digits on an axis multiple either to power-of-10 or to `5` or to `2`.
    //
    template <typename U, typename T>
    FORCE_INLINE U calibrate_ruler_tick_step_to_closest_power_of_10(T min, T max, size_t ticks, const U & float_point_identity = U{})
    {
        static_assert(std::is_floating_point<U>::value, "U must be a floating point type");

        DEBUG_ASSERT_LT(min, max);
        DEBUG_ASSERT_LT(0U, ticks);

        const T distance = max - min;

        U tick_step = U(distance) / ticks;

        int tick_step_exp;
        std::frexp(tick_step, &tick_step_exp);

        if (tick_step < 1.0) {
            size_t rounded_integer_part_numerator;
            size_t rounded_integer_part_denominator;

            const U tick_step_power_of_10 = U(tick_step_exp) * std::log(U(2)) / std::log(U(10)); // must cast to float point arithmetic
            DEBUG_ASSERT_GE(0, tick_step_power_of_10);

            const size_t num_digits_in_power_of_10 = size_t(std::floor(tick_step_power_of_10 >= 0 ?
                tick_step_power_of_10 : -tick_step_power_of_10 + 1));
            const auto signed_num_digits_in_power_of_10 = tick_step_power_of_10 >= 0 ?
                math::make_signed_from(num_digits_in_power_of_10) : -math::make_signed_from(num_digits_in_power_of_10);

            U closest_value_with_integer_part = tick_step * std::pow(U(10.0), num_digits_in_power_of_10);

            if (closest_value_with_integer_part >= 5) {
                rounded_integer_part_numerator = 5;
                rounded_integer_part_denominator = 1;
            }
            else {
                rounded_integer_part_numerator = 25;
                rounded_integer_part_denominator = 10;
            }

            tick_step = rounded_integer_part_numerator *
                std::pow(U(10.0), tick_step_power_of_10 >= 0 ?
                    math::make_signed_from(num_digits_in_power_of_10) : -math::make_signed_from(num_digits_in_power_of_10)) / rounded_integer_part_denominator; // drop the rest fraction

            // calibration through overflow/underflow

            U prev_tick_step;
            U next_tick_step = tick_step;
            size_t rounded_integer_part_next_numerator = rounded_integer_part_numerator;

            if (next_tick_step * ticks < 2 * distance) {
                do {
                    // step still not big enough, increase step in twice
                    rounded_integer_part_numerator = rounded_integer_part_next_numerator;
                    prev_tick_step = next_tick_step;

                    rounded_integer_part_next_numerator *= 2;
                    next_tick_step = rounded_integer_part_next_numerator *
                        std::pow(U(10.0), signed_num_digits_in_power_of_10) / rounded_integer_part_denominator;
                } while (next_tick_step * ticks < 2 * distance);

                tick_step = prev_tick_step;

                next_tick_step = prev_tick_step;
            }

            size_t rounded_integer_part_next_denominator = rounded_integer_part_denominator;

            if (next_tick_step * ticks >= distance) {
                do {
                    // step still not small enough, decrease step in twice
                    rounded_integer_part_denominator = rounded_integer_part_next_denominator;
                    prev_tick_step = next_tick_step;

                    rounded_integer_part_next_denominator *= 2;
                    next_tick_step = rounded_integer_part_numerator *
                        std::pow(U(10.0), signed_num_digits_in_power_of_10) / rounded_integer_part_next_denominator;
                } while (next_tick_step * ticks >= distance);

                tick_step = prev_tick_step;
            }
        }
        else {
            U closest_value_with_integer_part = std::floor(tick_step / 5) * 5;
            if (!closest_value_with_integer_part) {
                closest_value_with_integer_part = std::floor(tick_step);
            }

            U rounded_integer_part_numerator = size_t(closest_value_with_integer_part + 0.5);
            U rounded_integer_part_denominator = 1;

            // calibration through overflow/underflow

            U prev_tick_step;
            U next_tick_step = tick_step;
            U rounded_integer_part_next_numerator = rounded_integer_part_numerator;

            if (next_tick_step * ticks < 2 * distance) {
                do {
                    // step still not big enough, increase step in twice
                    rounded_integer_part_numerator = rounded_integer_part_next_numerator;
                    prev_tick_step = next_tick_step;

                    rounded_integer_part_next_numerator *= 2;
                    next_tick_step = rounded_integer_part_next_numerator / rounded_integer_part_denominator;
                } while (next_tick_step * ticks < 2 * distance);

                tick_step = prev_tick_step;

                next_tick_step = prev_tick_step;
            }

            U rounded_integer_part_next_denominator = rounded_integer_part_denominator;

            if (next_tick_step * ticks >= distance) {
                do {
                    // step still not small enough, decrease step in twice
                    rounded_integer_part_denominator = rounded_integer_part_next_denominator;
                    prev_tick_step = next_tick_step;

                    rounded_integer_part_next_denominator *= 2;
                    next_tick_step = rounded_integer_part_numerator / rounded_integer_part_next_denominator;
                } while (next_tick_step * ticks >= distance);

                tick_step = prev_tick_step;
            }
        }

        return tick_step;
    }
}

#endif
