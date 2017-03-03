#define _CRT_SECURE_NO_WARNINGS
//#define WIN32_LEAN_AND_MEAN // Exclude rarely-used stuff from Windows headers

#include <windows.h>
#include <stdio.h>
#include <string.h>

#include "common.hpp"
#include "printf.hpp"

#ifdef _UNICODE
#error Unicode is not supported.
#endif

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
