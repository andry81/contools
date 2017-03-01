//----------------------------------------
// Description: Console utility to compare environement variable's values.
// Author:      Andrey Dibrov (andry at inbox dot ru)
//----------------------------------------

#define _CRT_SECURE_NO_WARNINGS
//#define WIN32_LEAN_AND_MEAN // Exclude rarely-used stuff from Windows headers

#include <windows.h>
#include <stdio.h>
#include <string.h>
#include <string>

#include "common.hpp"

#ifdef _UNICODE
#error Unicode is not supported.
#endif

#define if_break switch(0) case 0: default: if
#define MAX_ENV_VALUE_SIZE 32767

namespace {
  const char * hextbl[] = {
    "00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "0A", "0B", "0C", "0D", "0E", "0F",
    "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "1A", "1B", "1C", "1D", "1E", "1F",
    "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "2A", "2B", "2C", "2D", "2E", "2F",
    "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "3A", "3B", "3C", "3D", "3E", "3F",
    "40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "4A", "4B", "4C", "4D", "4E", "4F",
    "50", "51", "52", "53", "54", "55", "56", "57", "58", "59", "5A", "5B", "5C", "5D", "5E", "5F",
    "60", "61", "62", "63", "64", "65", "66", "67", "68", "69", "6A", "6B", "6C", "6D", "6E", "6F",
    "70", "71", "72", "73", "74", "75", "76", "77", "78", "79", "7A", "7B", "7C", "7D", "7E", "7F",
    "80", "81", "82", "83", "84", "85", "86", "87", "88", "89", "8A", "8B", "8C", "8D", "8E", "8F",
    "90", "91", "92", "93", "94", "95", "96", "97", "98", "99", "9A", "9B", "9C", "9D", "9E", "9F",
    "A0", "A1", "A2", "A3", "A4", "A5", "A6", "A7", "A8", "A9", "AA", "AB", "AC", "AD", "AE", "AF",
    "B0", "B1", "B2", "B3", "B4", "B5", "B6", "B7", "B8", "B9", "BA", "BB", "BC", "BD", "BE", "BF",
    "C0", "C1", "C2", "C3", "C4", "C5", "C6", "C7", "C8", "C9", "CA", "CB", "CC", "CD", "CE", "CF",
    "D0", "D1", "D2", "D3", "D4", "D5", "D6", "D7", "D8", "D9", "DA", "DB", "DC", "DD", "DE", "DF",
    "E0", "E1", "E2", "E3", "E4", "E5", "E6", "E7", "E8", "E9", "EA", "EB", "EC", "ED", "EE", "EF",
    "F0", "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "FA", "FB", "FC", "FD", "FE", "FF",
  };

  struct InArgs
  {
    const char * print_prefix_str;
    const char * equal_str;
    const char * not_equal_str;
    const char * less_str;
    const char * greater_or_equal_str;
  };

  const char * _extract_variable(const char * last_offset, const char * parse_str, std::string & parsed_str, char * in_str_value) {
    const char * return_offset = 0;

    const char * p_in_str_var = 0;
    if (!strncmp(parse_str, "${", 2)) p_in_str_var = parse_str;
    if_break (p_in_str_var) {
      const char * p_in_str_var_end = strstr(p_in_str_var + 2, "}");
      if (!p_in_str_var_end) break;

      parsed_str.append(last_offset, p_in_str_var);
      return_offset = p_in_str_var_end + 1;

      const std::string in_str_var_name(p_in_str_var + 2, p_in_str_var_end);
      const DWORD in_str_value_size = !in_str_var_name.empty() ? ::GetEnvironmentVariableA(in_str_var_name.c_str(), in_str_value, MAX_ENV_VALUE_SIZE) : (MAX_ENV_VALUE_SIZE + 1);
      if (in_str_value_size > MAX_ENV_VALUE_SIZE) {
        // append as is
        parsed_str.append(p_in_str_var, p_in_str_var_end + 1);
        break;
      }
      if (!in_str_value_size) {
        in_str_value[0] = '\0';
      }

      parsed_str.append(in_str_value);
    }

    return return_offset;
  }

  void _parse_string(const char * parse_str, std::string & parsed_str, const char * v0_value, const char * v1_value,
                     char * in_str_value, const InArgs & in_args = InArgs()) {
    bool done = false;
    bool found;
    const char * last_offset = parse_str;

    std::string equal_str;
    std::string not_equal_str;
    std::string less_str;
    std::string greater_or_equal_str;

    bool is_equal_str_parsed = false;
    bool is_not_equal_str_parsed = false;
    bool is_less_str_parsed = false;
    bool is_greater_or_equal_str_parsed = false;

    do {
      found = false;

      const char * p = strstr(last_offset, "{");
      if_break (p) {
        if(p > last_offset) {
          const char * last_offset_var = _extract_variable(last_offset, p-1, parsed_str, in_str_value);
          if (last_offset_var) {
            found = true;
            last_offset = last_offset_var;
            break;
          }
        }

        if(p > last_offset && *(p-1) == '\\') {
          if (p > last_offset + 1) {
            parsed_str.append(last_offset, p - 1);
          }
          parsed_str.append(p, p + 1);
          last_offset = p + 1;
          if (*last_offset) found = true;
          break;
        }

        // {$0}
        const int var_v0 = strncmp(p, "{$0}", 4);
        if (!var_v0) {
          parsed_str.append(last_offset, p);
          last_offset = p + 4;
          parsed_str.append(v0_value);
          found = true;
        }

        // {$1}
        if (!found) {
          const int var_v1 = strncmp(p, "{$1}", 4);
          if (!var_v1) {
            parsed_str.append(last_offset, p);
            last_offset = p + 4;
            parsed_str.append(v1_value);
            found = true;
          }
        }

        // {$0hs}
        if (!found) {
          const int var_v0 = strncmp(p, "{$0hs}", 6);
          if (!var_v0) {
            parsed_str.append(last_offset, p);
            last_offset = p + 6;
            const size_t v0_value_len = strlen(v0_value);
            for(size_t i = 0; i < v0_value_len; i++) {
              parsed_str.append(hextbl[v0_value[i]]);
            }
            found = true;
          }
        }

        // {$1hs}
        if (!found) {
          const int var_v1 = strncmp(p, "{$1hs}", 6);
          if (!var_v1) {
            parsed_str.append(last_offset, p);
            last_offset = p + 6;
            const size_t v1_value_len = strlen(v1_value);
            for(size_t i = 0; i < v1_value_len; i++) {
              parsed_str.append(hextbl[v1_value[i] - '0']);
            }
            found = true;
          }
        }

        // {EQL}
        if (!found && in_args.equal_str) {
          const int var_eql = strncmp(p, "{EQL}", 5);
          if (!var_eql) {
            if (!is_equal_str_parsed) {
              _parse_string(in_args.equal_str, equal_str, v0_value, v1_value, in_str_value);
              is_equal_str_parsed = true;
            }
            parsed_str.append(last_offset, p);
            last_offset = p + 5;
            parsed_str.append(equal_str);
            found = true;
          }
        }

        // {NEQ}
        if (!found && in_args.not_equal_str) {
          const int var_neq = strncmp(p, "{NEQ}", 5);
          if (!var_neq) {
            if (!is_not_equal_str_parsed) {
              _parse_string(in_args.not_equal_str, not_equal_str, v0_value, v1_value, in_str_value);
              is_not_equal_str_parsed = true;
            }
            parsed_str.append(last_offset, p);
            last_offset = p + 5;
            parsed_str.append(not_equal_str);
            found = true;
          }
        }

        // {LSS}
        if (!found && in_args.less_str) {
          const int var_less = strncmp(p, "{LSS}", 5);
          if (!var_less) {
            if (!is_less_str_parsed) {
              _parse_string(in_args.less_str, less_str, v0_value, v1_value, in_str_value);
              is_less_str_parsed = true;
            }
            parsed_str.append(last_offset, p);
            last_offset = p + 5;
            parsed_str.append(less_str);
            found = true;
          }
        }

        // {GEQ}
        if (!found && in_args.greater_or_equal_str) {
          const int var_gtr = strncmp(p, "{GEQ}", 5);
          if (!var_gtr) {
            if (!is_greater_or_equal_str_parsed) {
              _parse_string(in_args.greater_or_equal_str, greater_or_equal_str, v0_value, v1_value, in_str_value);
              is_greater_or_equal_str_parsed = true;
            }
            parsed_str.append(last_offset, p);
            last_offset = p + 5;
            parsed_str.append(greater_or_equal_str);
            found = true;
          }
        }

        if (!found) {
          if(*(p + 1)) {
            const char * p_end = strstr(p + 1, "}");
            if (p_end) {
              parsed_str.append(last_offset, p);
              last_offset = p_end + 1;
              if (*last_offset) found = true;
              break;
            }
          }
        }
      }

      if (!found) done = true;

      if (done && last_offset) {
        parsed_str.append(last_offset);
        last_offset = 0; // just in case
      }
    } while(!done);
  }
}

int main(int argc,const char* argv[])
{
  if(!argc || !argv[0])
    return 255;

  bool do_show_help = false;

  if(argc >= 2 && argv[1] && !strcmp(argv[1], "/?")) {
    if (argc >= 3) return 4;
    do_show_help = true; // /?
  }

  if(do_show_help) {
    ::puts(
#include "help_inl.hpp"
      );

    return 5;
  }

  // environment variable buffers
  char value1[MAX_ENV_VALUE_SIZE];
  char value2[MAX_ENV_VALUE_SIZE];
  char value_in_str[MAX_ENV_VALUE_SIZE];

  if (argc >= 2 && argv[1] && strlen(argv[1])) {
    const DWORD value1Size = ::GetEnvironmentVariableA(argv[1], value1, sizeof(value1)/sizeof(value1[0]));
    if (!value1Size) {
      value1[0] = '\0';
    }
    if (value1Size > sizeof(value1)/sizeof(value1[0])) {
      return 2;
    }
  } else {
    return 2;
  }

  if (argc >= 3 && argv[2] && strlen(argv[2])) {
    const DWORD value2Size = ::GetEnvironmentVariableA(argv[2], value2, sizeof(value2)/sizeof(value2[0]));
    if (!value2Size) {
      value2[0] = '\0';
    }
    if (value2Size > sizeof(value2)/sizeof(value2[0])) {
      return 3;
    }
  } else {
    return 3;
  }

  // prepare print string
  std::string print_prefix_str;
  std::string equal_str;
  std::string not_equal_str;
  std::string less_str;
  std::string greater_or_equal_str;

  InArgs in_args = InArgs();

  if (argc >= 4 && argv[3] && strlen(argv[3])) {
    in_args.print_prefix_str = argv[3];
    if (!strcmp(in_args.print_prefix_str, "")) {
      in_args.print_prefix_str = 0;
    }
  }

  // {EQL} string
  if (argc >= 5 && argv[4]) {
    in_args.equal_str = argv[4];
    if (!strcmp(in_args.equal_str, "")) {
      in_args.equal_str = 0;
    }
  }

  // {NEQ} string
  if (argc >= 6 && argv[5]) {
    in_args.not_equal_str = argv[5];
    if (!strcmp(in_args.not_equal_str, "")) {
      in_args.not_equal_str = 0;
    }
  }

  // {LSS} string
  if (argc >= 7 && argv[6]) {
    in_args.less_str = argv[6];
    if (!strcmp(in_args.less_str, "")) {
      in_args.less_str = 0;
    }
  }

  // {GEQ}/{GTR} string
  if (argc >= 8 && argv[7]) {
    in_args.greater_or_equal_str = argv[7];
    if (!strcmp(in_args.greater_or_equal_str, "")) {
      in_args.greater_or_equal_str = 0;
    }
  }

  const int res = strcmp(value1, value2);

  if (in_args.print_prefix_str) {
    _parse_string(in_args.print_prefix_str, print_prefix_str, value1, value2, value_in_str, in_args);
    if (!print_prefix_str.empty()) puts(print_prefix_str.c_str());
  }

  if (!res && in_args.equal_str) {
    _parse_string(in_args.equal_str, equal_str, value1, value2, value_in_str);
    if (!equal_str.empty()) puts(equal_str.c_str());
    return 0;
  }

  if (res && in_args.not_equal_str) {
    _parse_string(in_args.not_equal_str, not_equal_str, value1, value2, value_in_str);
    if (!not_equal_str.empty()) puts(not_equal_str.c_str());
    return res < 0 ? -1 : 1;
  }

  if (res < 0 && in_args.less_str) {
    _parse_string(in_args.less_str, less_str, value1, value2, value_in_str);
    if (!less_str.empty()) puts(less_str.c_str());
    return -1;
  }

  if (in_args.greater_or_equal_str) {
    _parse_string(in_args.greater_or_equal_str, greater_or_equal_str, value1, value2, value_in_str);
    if (!greater_or_equal_str.empty()) puts(greater_or_equal_str.c_str());
  }

  return res < 0 ? -1 : 1;
}
