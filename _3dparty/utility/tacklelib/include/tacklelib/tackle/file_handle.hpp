#pragma once

#include <tacklelib/tacklelib.hpp>

#include <tacklelib/utility/platform.hpp>
#include <tacklelib/utility/assert.hpp>

#include <tacklelib/tackle/smart_handle.hpp>
#include <tacklelib/tackle/string.hpp>

#include <fmt/format.h>

#include <cstdio>
#include <utility>


namespace tackle
{
    template <class t_elem, class t_traits, class t_alloc>
    class FileHandle : public SmartHandle<FILE>
    {
        using base_type = SmartHandle<FILE>;

    public:
        using string_type = std::basic_string<t_elem, t_traits, t_alloc>;

    private:
        FORCE_INLINE static void _deleter(void * p)
        {
            if (p) {
                fclose((FILE *)p);
            }
        }

    public:
        static FORCE_INLINE const FileHandle & null()
        {
            static const FileHandle s_null = FileHandle{ nullptr, UTILITY_LITERAL_STRING("nul", t_elem) };
            return s_null;
        }

        FORCE_INLINE FileHandle()
        {
            *this = null();
        }

        FORCE_INLINE FileHandle(const FileHandle &) = default;
        FORCE_INLINE FileHandle(FileHandle &&) = default;

        FORCE_INLINE FileHandle & operator =(const FileHandle &) = default;
        FORCE_INLINE FileHandle & operator =(FileHandle &&) = default;

        FORCE_INLINE FileHandle(FILE * p, const string_type & file_path) :
            base_type(p, _deleter),
            m_file_path(file_path)
        {
        }

        FORCE_INLINE void reset(FileHandle handle = FileHandle::null())
        {
            auto && handle_rref = std::move(handle);

            auto * deleter = DEBUG_VERIFY_TRUE(std::get_deleter<base_type::DeleterType>(handle_rref.m_pv));
            if (!deleter) {
                // must always have a deleter
                DEBUG_BREAK_THROW(true) std::runtime_error(fmt::format("{:s}({:u}): deleter is not allocated",
                    UTILITY_PP_FUNCSIG, UTILITY_PP_LINE));
            }

            base_type::reset(handle_rref.get(), *deleter);
            m_file_path.clear();
        }

        FORCE_INLINE const string_type & path() const
        {
            return m_file_path;
        }

        FORCE_INLINE int fileno() const
        {
#ifdef UTILITY_PLATFORM_WINDOWS
            return _fileno(get());
#elif defined(UTILITY_PLATFORM_POSIX)
            return ::fileno(get());
#else
#error platform is not implemented
#endif
        }

    private:
        string_type m_file_path;
    };

    using FileHandleA = FileHandle<char, std::char_traits<char>, std::allocator<char> >;
    using FileHandleW = FileHandle<wchar_t, std::char_traits<wchar_t>, std::allocator<wchar_t> >;
}
