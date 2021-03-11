//----------------------------------------
// Description: Console utility to compare environement variable's values.
// Author:      Andrey Dibrov (andry at inbox dot ru)
//----------------------------------------

#define _CRT_SECURE_NO_WARNINGS
//#define WIN32_LEAN_AND_MEAN // Exclude rarely-used stuff from Windows headers

#include <windows.h>
#include <stdio.h>
#include <string.h>

#include "common.hpp"

#ifdef _UNICODE
#error Unicode is not supported.
#endif

namespace {
  struct InArgs
  {
    const char * print_prefix_str;
    const char * equal_str;
    const char * not_equal_str;
    const char * less_str;
    const char * greater_or_equal_str;
  };

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

        // {0}
        const int var_v0 = strncmp(p, "{0}", 3);
        if (!var_v0) {
          parsed_str.append(last_offset, p);
          last_offset = p + 3;
          parsed_str.append(v0_value);
          found = true;
        }

        // {1}
        if (!found) {
          const int var_v1 = strncmp(p, "{1}", 3);
          if (!var_v1) {
            parsed_str.append(last_offset, p);
            last_offset = p + 3;
            parsed_str.append(v1_value);
            found = true;
          }
        }

        // {0hs}
        if (!found) {
          const int var_v0 = strncmp(p, "{0hs}", 5);
          if (!var_v0) {
            parsed_str.append(last_offset, p);
            last_offset = p + 5;
            const size_t v0_value_len = strlen(v0_value);
            for(size_t i = 0; i < v0_value_len; i++) {
              parsed_str.append(hextbl[v0_value[i]]);
            }
            found = true;
          }
        }

        // {1hs}
        if (!found) {
          const int var_v1 = strncmp(p, "{1hs}", 5);
          if (!var_v1) {
            parsed_str.append(last_offset, p);
            last_offset = p + 5;
            const size_t v1_value_len = strlen(v1_value);
            for(size_t i = 0; i < v1_value_len; i++) {
              parsed_str.append(hextbl[v1_value[i]]);
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
  char value1[MAX_ENV_BUF_SIZE];
  char value2[MAX_ENV_BUF_SIZE];
  char env_buf[MAX_ENV_BUF_SIZE];

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
    _parse_string(in_args.print_prefix_str, print_prefix_str, value1, value2, env_buf, in_args);
    if (!print_prefix_str.empty()) puts(print_prefix_str.c_str());
  }

  if (!res && in_args.equal_str) {
    _parse_string(in_args.equal_str, equal_str, value1, value2, env_buf);
    if (!equal_str.empty()) puts(equal_str.c_str());
    return 0;
  }

  if (res && in_args.not_equal_str) {
    _parse_string(in_args.not_equal_str, not_equal_str, value1, value2, env_buf);
    if (!not_equal_str.empty()) puts(not_equal_str.c_str());
    return res < 0 ? -1 : 1;
  }

  if (res < 0 && in_args.less_str) {
    _parse_string(in_args.less_str, less_str, value1, value2, env_buf);
    if (!less_str.empty()) puts(less_str.c_str());
    return -1;
  }

  if (in_args.greater_or_equal_str) {
    _parse_string(in_args.greater_or_equal_str, greater_or_equal_str, value1, value2, env_buf);
    if (!greater_or_equal_str.empty()) puts(greater_or_equal_str.c_str());
  }

  return !res ? 0 : res < 0 ? -1 : 1;
}
