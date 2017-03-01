#define _CRT_SECURE_NO_WARNINGS
//#define WIN32_LEAN_AND_MEAN // Exclude rarely-used stuff from Windows headers

#include <windows.h>
#include <stdio.h>
#include <string.h>
#include <string>
#include <vector>

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

  typedef std::vector<const char *> const_char_ptr_vector_t;
  typedef std::vector<std::string> string_vector_t;

  struct InArgs
  {
    const char * fmt_str;
    const_char_ptr_vector_t args;
  };

  struct OutArgs
  {
    std::string fmt_str;
    string_vector_t args;
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

  void _parse_string(const char * parse_str, std::string & parsed_str, char * in_str_value, const InArgs & in_args = InArgs(), const OutArgs & out_args = OutArgs()) {
    bool done = false;
    bool found;
    const char * last_offset = parse_str;
    char var_buffer[256];
    char int_to_str_buffer[sizeof(int) * 8 + 1]; // maximum length for minimum radix + null terminator

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

        if (in_args.fmt_str) {
          int i = 0;
          for (string_vector_t::const_iterator it = out_args.args.begin(); it != out_args.args.end(); ++it, ++i) {
            itoa(i, int_to_str_buffer, 10);

            strcpy(var_buffer, "{$");
            strcat(var_buffer, int_to_str_buffer);
            strcat(var_buffer, "}");

            // {$N}
            const int var_vn_len = strlen(var_buffer);
            const int var_vn = strncmp(p, var_buffer, var_vn_len);
            if (!var_vn) {
              parsed_str.append(last_offset, p);
              last_offset = p + var_vn_len;
              parsed_str.append(out_args.args[i]);
              found = true;
            }

            // {$Nhs}
            if (!found) {
              strcpy(var_buffer, "{$");
              strcat(var_buffer, int_to_str_buffer);
              strcat(var_buffer, "hs}");

              const int var_vn_len = strlen(var_buffer);
              const int var_vn = strncmp(p, var_buffer, var_vn_len);
              if (!var_vn) {
                parsed_str.append(last_offset, p);
                last_offset = p + var_vn_len;
                const std::string::size_type vn_value_len = out_args.args[i].length();
                for(std::string::size_type j = 0; j < vn_value_len; j++) {
                  parsed_str.append(hextbl[out_args.args[i][j]]);
                }
                found = true;
              }
            }

            if (found) break;
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
    if (argc >= 3) return 2;
    do_show_help = true; // /?
  }

  if(do_show_help) {
    ::puts(
#include "help_inl.hpp"
      );

    return 1;
  }

  // environment variable buffer
  char value_in_str[MAX_ENV_VALUE_SIZE];

  InArgs in_args = InArgs();
  OutArgs out_args = OutArgs();

  if (argc >= 2 && argv[1] && strlen(argv[1])) {
    in_args.fmt_str = argv[1];
    if (!strcmp(in_args.fmt_str , "")) {
      in_args.fmt_str  = 0;
    }
  }

  if (!in_args.fmt_str) return -1;

  // read and parse input arguments
  if (argc >= 3) {
    in_args.args.resize(argc - 2);
    out_args.args.resize(argc - 2);
    for (int i = 0; i < argc - 2; i++) {
      in_args.args[i] = argv[i + 2];
      if (strcmp(in_args.args[i] , "")) {
        _parse_string(in_args.args[i], out_args.args[i], value_in_str);
      } else {
        in_args.args[i] = 0;
      }
    }
  }

  _parse_string(in_args.fmt_str, out_args.fmt_str, value_in_str, in_args, out_args);
  if (!out_args.fmt_str.empty()) {
    puts(out_args.fmt_str.c_str());
    return 0;
  }

  return -1;
}
