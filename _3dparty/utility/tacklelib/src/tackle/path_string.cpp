#include <tacklelib/tackle/path_string.hpp>


namespace tackle
{
    // forward slash path strings
    template class path_basic_string<char, std::char_traits<char>, std::allocator<char>, literal_separators<char>::forward_slash_char>;
    template class path_basic_string<wchar_t, std::char_traits<wchar_t>, std::allocator<wchar_t>, literal_separators<wchar_t>::forward_slash_char>;

    template class path_basic_string<char16_t, std::char_traits<char16_t>, std::allocator<char16_t>, literal_separators<char16_t>::forward_slash_char>;
    template class path_basic_string<char32_t, std::char_traits<char32_t>, std::allocator<char32_t>, literal_separators<char32_t>::forward_slash_char>;

    // back slash path strings
    template class path_basic_string<char, std::char_traits<char>, std::allocator<char>, literal_separators<char>::backward_slash_char>;
    template class path_basic_string<wchar_t, std::char_traits<wchar_t>, std::allocator<wchar_t>, literal_separators<wchar_t>::backward_slash_char>;

    template class path_basic_string<char16_t, std::char_traits<char16_t>, std::allocator<char16_t>, literal_separators<char16_t>::backward_slash_char>;
    template class path_basic_string<char32_t, std::char_traits<char32_t>, std::allocator<char32_t>, literal_separators<char32_t>::backward_slash_char>;
}
