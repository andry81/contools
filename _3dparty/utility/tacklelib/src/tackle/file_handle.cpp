#include <tacklelib/tackle/file_handle.hpp>


namespace tackle
{
    template class FileHandle<char, std::char_traits<char>, std::allocator<char> >;
    template class FileHandle<wchar_t, std::char_traits<wchar_t>, std::allocator<wchar_t> >;
}
