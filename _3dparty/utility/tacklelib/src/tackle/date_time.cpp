#include <tacklelib/tackle/date_time.hpp>


namespace tackle
{
    template class basic_date_time<double, char, std::char_traits<char>, std::allocator<char> >;
    template class basic_date_time<double, wchar_t, std::char_traits<wchar_t>, std::allocator<wchar_t> >;

    template class basic_date_time<uint64_t, char, std::char_traits<char>, std::allocator<char> >;
    template class basic_date_time<uint64_t, wchar_t, std::char_traits<wchar_t>, std::allocator<wchar_t> >;
}
