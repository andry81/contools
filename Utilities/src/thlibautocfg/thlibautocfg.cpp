//----------------------------------------
// Description: Console utility to generate files from configuration/text files.
// Author:      Andrey Dibrov (andry at inbox dot ru)
//----------------------------------------

#define _CRT_SECURE_NO_WARNINGS
#define WIN32_LEAN_AND_MEAN // Exclude rarely-used stuff from Windows headers

#include <windows.h>
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "common.hpp"

#define MAX_QUOTES_IN_STRING_LINE       256

namespace
{
  //variable_type
  enum variable_type
  {
    eVarType_Unknown    = -1,
    eVarType_Ansi       = 0,
    aVerType_Unicode16  = 1,
  };

  struct _ConfigFileAutoHandle
  {
    FILE* handle;

    _ConfigFileAutoHandle(const char* file_path_str)
    {
      handle = ::fopen(file_path_str, "rt");
    }

    ~_ConfigFileAutoHandle()
    {
      if(handle)
      {
        ::fclose(handle);
        handle = NULL; // just in case
      }
    }
  };

  struct _OutputFileAutoHandle
  {
    FILE* handle;

    _OutputFileAutoHandle(const char* file_path_str)
    {
      handle = ::fopen(file_path_str,"wt");
    }

    ~_OutputFileAutoHandle()
    {
      if(handle)
      {
        ::fclose(handle);
        handle = NULL; // just in case
      }
    }
  };

  //----------------------------------------
  // Return value:
  //  Pointer to first non space character in str_buf.
  // Input values:
  //  str_buf               - pointer to buffer with scanning string.
  //  str_buf_size          - size of buffer with scanning string.
  //  var_fmt_type1_pptr    - pointer to variable which store format of read variable.
  //  last_non_space_char_pptr - pointer to variable which store pointer to last non
  //                          space character in str_buf.
  //  eq_char_pptr          - pointer to variable which store pointer to first equal ('=')
  //                          character in str_buf.
  //  stop_proc_char_pptr   - pointer to variable which store pointer to first
  //                          not commented stopping parse ('$') character in str_buf.
  //  comment_char_pptr     - pointer to variable which store pointer to first
  //                          not stop parsed comment ('#') character in str_buf.
  char* _scan_cfg_str_line(char*   str_buf,
                           size_t  str_buf_size,
                           char**  var_fmt_type1_pptr,
                           char**  last_non_space_char_pptr,
                           char**  eq_char_pptr,
                           char**  stop_proc_char_pptr,
                           char**  comment_char_pptr)
  {
    assert(str_buf && str_buf_size > 1);
    char* cur_char_ptr = str_buf;
    char* first_non_space_char_ptr = NULL;
    char* var_fmt_type1_ptr = NULL;
    char* last_non_space_char_ptr = NULL;
    char* eq_char_ptr = NULL;
    char* stop_proc_char_ptr = NULL;
    char* comment_char_ptr = NULL;
    for(size_t i = 0; i < str_buf_size-1 && *cur_char_ptr != '\0'; ++i, ++cur_char_ptr)
    {
      // ignore control ansi chars
      if(*cur_char_ptr < 16 || *cur_char_ptr == 32)
        continue;

      if(!first_non_space_char_ptr)
        first_non_space_char_ptr = cur_char_ptr;

      switch(*cur_char_ptr)
      {
        case '$':
        {
          if(!stop_proc_char_ptr && !comment_char_ptr) {
            stop_proc_char_ptr = cur_char_ptr;
          }
        } break;

        case '#':
        {
          if(!comment_char_ptr && !stop_proc_char_ptr) {
            comment_char_ptr = cur_char_ptr;
          }
        } break;

        case ':':
        {
          if(!var_fmt_type1_ptr)
          {
            if(first_non_space_char_ptr && !stop_proc_char_ptr && !comment_char_ptr && !eq_char_ptr)
            {
              if(first_non_space_char_ptr < cur_char_ptr)
              {
                var_fmt_type1_ptr = cur_char_ptr;
              }
            }
          }
        } break;

        default:;
      }

      if(!comment_char_ptr || stop_proc_char_ptr && stop_proc_char_ptr < comment_char_ptr)
      {
        if(!stop_proc_char_ptr)
        {
          if(!eq_char_ptr)
          {
            if(*cur_char_ptr == '=')
              eq_char_ptr = cur_char_ptr;
          }
        }
        last_non_space_char_ptr = cur_char_ptr;
      }
    }

    if(var_fmt_type1_pptr)
      *var_fmt_type1_pptr = var_fmt_type1_ptr;

    if(last_non_space_char_pptr)
      *last_non_space_char_pptr = last_non_space_char_ptr;

    if(eq_char_pptr)
      *eq_char_pptr = eq_char_ptr;

    if(stop_proc_char_pptr)
      *stop_proc_char_pptr = stop_proc_char_ptr;

    if(comment_char_pptr)
      *comment_char_pptr = comment_char_ptr;

    return first_non_space_char_ptr;
  }

  //----------------------------------------
  // Return values:
  //  - 0   //Success
  //  - 1   //Out of buffer comment_char_buf
  // Input values:
  //  str_buf                 - pointer to buffer with scanning string.
  //  str_buf_size            - size of buffer with scanning string.
  //  comment_char_buf        - pointer to externally allocated buffer which would
  //                            store pointers to characters in str_buf which must be commented.
  //  comment_char_buf_size   - size of comment_char_buf buffer.
  //  do_quote_procent_chars  - do quote procent characters.
  int _scan_txt_str_line(const char*   str_buf,
                         size_t        str_buf_size,
                         size_t*       str_len_ptr,
                         const char**  comment_char_buf,
                         size_t        comment_char_buf_size,
                         size_t*       num_comment_chars_ptr,
                         bool          do_quote_procent_chars = false)
  {
    assert(str_buf && str_buf_size > 1);
    assert(comment_char_buf && comment_char_buf_size > 0);

    const char*   cur_char_ptr = str_buf;
    const char**  cur_bak_slash_char_pptr = comment_char_buf;
    size_t        cur_bak_slash_char_index = 0;
    size_t i;
    for(i = 0; i < str_buf_size-1 && *cur_char_ptr != '\0'; ++i, ++cur_char_ptr)
    {
      if(*cur_char_ptr == '\n' || *cur_char_ptr == '\r')
        break;
      // ignore control ansi chars
      else if(*cur_char_ptr < 16 || *cur_char_ptr == 32)
        continue;

      switch(*cur_char_ptr)
      {
        case '\"':
        {
          if(cur_bak_slash_char_index >= comment_char_buf_size-1)
            return 1;

          cur_bak_slash_char_pptr[cur_bak_slash_char_index] = cur_char_ptr;
          cur_bak_slash_char_index++;
        } break;

        case '\\':
        {
          if(cur_bak_slash_char_index >= comment_char_buf_size-1)
            return 1;

          cur_bak_slash_char_pptr[cur_bak_slash_char_index] = cur_char_ptr;
          cur_bak_slash_char_index++;
        } break;

        case '%':
        {
          if(!do_quote_procent_chars)
            break;
          if(cur_bak_slash_char_index >= comment_char_buf_size-1)
            return 1;

          cur_bak_slash_char_pptr[cur_bak_slash_char_index] = cur_char_ptr;
          cur_bak_slash_char_index++;
        } break;

        default:;
      }
    }

    if(str_len_ptr)
      *str_len_ptr = i;

    if(num_comment_chars_ptr)
      *num_comment_chars_ptr = cur_bak_slash_char_index;

    return 0;
  }
  //----------------------------------------
  // Return values:
  //  - 0   //Success
  //  - 1   //Out of buffer
  int _parse_result_to_buf(char*          buf,
                           size_t         buf_size,
                           size_t*        result_len_ptr,
                           variable_type  var_type,
                           const char*    str_buf,
                           const char*    first_non_space_char_ptr,
                           const char*    non_space_char_before_eq_ptr,
                           const char*    eq_char_ptr,
                           const char*    non_space_char_after_eq_ptr,
                           const char*    last_non_space_char_ptr,
                           const char*    comment_char_ptr,
                           const char*    stop_proc_str_ptr = NULL,
                           size_t         stop_proc_str_len = 0)
  {
    assert(buf);
    assert(buf_size >= 256);         //Must be at least 256 bytes
    assert(str_buf && str_buf <= first_non_space_char_ptr);
    assert(first_non_space_char_ptr);
    assert(!stop_proc_str_ptr || stop_proc_str_len > 0);

    size_t cur_copy_len;

    struct OnReturn
    {
      char*   buf;
      size_t  old_result_len;
      size_t* result_len_ptr;

      OnReturn(char* buf_,size_t* result_len_)
      {
        buf = buf_;
        old_result_len = 0;
        result_len_ptr = result_len_;
      }

      ~OnReturn()
      {
        buf[old_result_len] = '\0';
        if(result_len_ptr)
          *result_len_ptr = old_result_len;
      }
    }
    on_return_local(buf, result_len_ptr);

    size_t new_result_len = 0;

    cur_copy_len = first_non_space_char_ptr-str_buf;
    new_result_len += cur_copy_len;

    if(new_result_len >= buf_size)
      return 1; // out of buffer

    ::strncpy(buf+on_return_local.old_result_len, str_buf,cur_copy_len);
    on_return_local.old_result_len = new_result_len;

    if(first_non_space_char_ptr != stop_proc_str_ptr)
    {
      assert(var_type != eVarType_Unknown); // must be already known
      char var_name_prefix_str[32] = "";

      switch(var_type)
      {
        case eVarType_Ansi:
        {
          ::strcpy(var_name_prefix_str,"const char g_sz");
        } break;

        case aVerType_Unicode16:
        {
          ::strcpy(var_name_prefix_str,"const wchar_t g_sz");
        } break;
      }

      cur_copy_len = ::strlen(var_name_prefix_str);
      new_result_len += cur_copy_len;
      if(new_result_len >= buf_size)
        return 1; // out of buffer

      ::strncpy(buf+on_return_local.old_result_len, var_name_prefix_str, cur_copy_len);
      on_return_local.old_result_len = new_result_len;

      cur_copy_len = non_space_char_before_eq_ptr-first_non_space_char_ptr+1;
      new_result_len += cur_copy_len;

      if(new_result_len >= buf_size)
        return 1; // out of buffer

      ::strncpy(buf+on_return_local.old_result_len, first_non_space_char_ptr, cur_copy_len);
      on_return_local.old_result_len = new_result_len;

      const char var_name_suffix_str[] = "[]";
      cur_copy_len = sizeof(var_name_suffix_str)/sizeof(var_name_suffix_str[0])-1;
      new_result_len += cur_copy_len;
      if(new_result_len >= buf_size)
        return 1; // out of buffer

      ::strncpy(buf+on_return_local.old_result_len, var_name_suffix_str, cur_copy_len);
      on_return_local.old_result_len = new_result_len;
    }

    if(eq_char_ptr)
    {
      const char equality_str[] = " = ";
      cur_copy_len = sizeof(equality_str)/sizeof(equality_str[0])-1;
      new_result_len += cur_copy_len;

      if(new_result_len >= buf_size)
        return 1; // out of buffer

      ::strncpy(buf+on_return_local.old_result_len, equality_str, cur_copy_len);
      on_return_local.old_result_len = new_result_len;
    }

    if(non_space_char_after_eq_ptr)
    {
      if(!stop_proc_str_ptr || non_space_char_after_eq_ptr != stop_proc_str_ptr)
      {
        char quote_first_buf[4];

        if(var_type != aVerType_Unicode16)
          strcpy(quote_first_buf,"\"");
        else
          strcpy(quote_first_buf,"L\"");

        cur_copy_len = ::strlen(quote_first_buf);
        new_result_len += cur_copy_len;

        if(new_result_len >= buf_size)
          return 1; // out of buffer

        ::strncpy(buf+on_return_local.old_result_len, quote_first_buf, cur_copy_len);
        on_return_local.old_result_len = new_result_len;

        cur_copy_len = last_non_space_char_ptr-non_space_char_after_eq_ptr+1;
        new_result_len += cur_copy_len;
        ::strncpy(buf+on_return_local.old_result_len, non_space_char_after_eq_ptr, cur_copy_len);
        on_return_local.old_result_len = new_result_len;

        const char quote_last_buf[] = "\"";
        cur_copy_len = sizeof(quote_last_buf)/sizeof(quote_last_buf[0])-1;
        new_result_len += cur_copy_len;

        if(new_result_len >= buf_size)
          return 1; // out of buffer

        ::strncpy(buf+on_return_local.old_result_len,quote_last_buf,cur_copy_len);
        on_return_local.old_result_len = new_result_len;
      }
    }

    if(stop_proc_str_ptr)
    {
      // add string before stop processing character as is
      if(first_non_space_char_ptr != stop_proc_str_ptr)
      {
        if(last_non_space_char_ptr)
        {
          cur_copy_len = last_non_space_char_ptr-stop_proc_str_ptr;
          if(cur_copy_len)
          {
            new_result_len += cur_copy_len;
            if(new_result_len >= buf_size)
              return 1; // out of buffer

            ::strncpy(buf+on_return_local.old_result_len, last_non_space_char_ptr, cur_copy_len);
            on_return_local.old_result_len = new_result_len;
          }
        }
        else
        {
          assert(eq_char_ptr);
          cur_copy_len = eq_char_ptr+1-stop_proc_str_ptr;
          if(cur_copy_len)
          {
            new_result_len += cur_copy_len;
            if(new_result_len >= buf_size)
              return 1; // out of buffer

            ::strncpy(buf+on_return_local.old_result_len, eq_char_ptr+1, cur_copy_len);
            on_return_local.old_result_len = new_result_len;
          }
        }
      }

      // add stop processed string
      if(stop_proc_str_len > 1)
      {
        cur_copy_len = stop_proc_str_len-1;
        new_result_len += cur_copy_len;
        if(new_result_len >= buf_size)
          return 1; // out of buffer

        ::strncpy(buf+on_return_local.old_result_len, stop_proc_str_ptr+1, cur_copy_len);
        on_return_local.old_result_len = new_result_len;
      }
    }
    else if(!non_space_char_after_eq_ptr)
    {
      assert(first_non_space_char_ptr == stop_proc_str_ptr || !stop_proc_str_ptr);
      char quote_empty_buf[4];

      if(var_type != aVerType_Unicode16)
        strcpy(quote_empty_buf,"\"\"");
      else
        strcpy(quote_empty_buf,"L\"\"");

      cur_copy_len = ::strlen(quote_empty_buf);
      new_result_len += cur_copy_len;
      if(new_result_len >= buf_size)
        return 1; // out of buffer

      ::strncpy(buf+on_return_local.old_result_len, quote_empty_buf, cur_copy_len);
      on_return_local.old_result_len = new_result_len;
    }

    if(first_non_space_char_ptr && eq_char_ptr && (!stop_proc_str_ptr || !comment_char_ptr))
    {
      const char szStringLineSuffix[] = ";";
      cur_copy_len = sizeof(szStringLineSuffix)/sizeof(szStringLineSuffix[0])-1;
      new_result_len += cur_copy_len;
      if(new_result_len >= buf_size)
        return 1; // out of buffer

      ::strncpy(buf+on_return_local.old_result_len, szStringLineSuffix, cur_copy_len);
      on_return_local.old_result_len = new_result_len;
    }

    return 0;
  }
}

int main(int argc, char* argv[])
{
  if(!argc || !argv[0])
    return 255;

  bool do_show_help = false;

  //<Mode>
  int mode = 0;

  //<Flags>
  int flags = 0;
  bool hasFlags = false;
  bool unicode = false;

  if(argc >= 2 && argv[1]) {
    if(!::strcmp(argv[1], "/?")) {
      if (argc >= 3) return 1;
      do_show_help = true; // /?
    } else if(!::strcmp(argv[1], "-cfg2c")) {
      mode = 1; // -cfg2c
    } else if(!::strcmp(argv[1], "-txt2c")) {
      mode = 2; // -txt2c
    }
  }

  if(argc >= 3 && argv[2]) {
    if(argv[2][0] == '-') {
      hasFlags = true;
      if(::strchr(argv[2], 'u')) {
        unicode = true;
      }
      if(::strchr(argv[2], 'p')) {
        flags |= 1;
      } else if(::strchr(argv[2], 'a')) {
        flags |= 2;
      }
    }
  }

  if(do_show_help) {
    ::puts(
#include "help_inl.hpp"
      );

    return 2;
  }

  //<config_file_auto_handle>
  const char* config_file_str;
  size_t config_file_str_len = -1;
  if(!hasFlags && argc >= 3)
  {
    config_file_str = argv[2];
    config_file_str_len = ::strlen(config_file_str);
  }
  else if(hasFlags && argc >= 4)
  {
    config_file_str = argv[3];
    config_file_str_len = ::strlen(config_file_str);
  }

  //<output_file_auto_handle>
  const char* output_file_str;
  size_t output_file_str_len = -1;
  if(!hasFlags && argc >= 4)
  {
    output_file_str = argv[3];
    output_file_str_len = ::strlen(output_file_str);
  }
  else if(hasFlags && argc >= 5)
  {
    output_file_str = argv[4];
    output_file_str_len = ::strlen(output_file_str);
  }

  if(argc < 4 || !mode || argc > 5)
    return 3;

  if(!config_file_str_len || !output_file_str_len)
    return 4;

  _ConfigFileAutoHandle config_file_auto_handle(config_file_str);

  if(!config_file_auto_handle.handle)
    return 5;

  _OutputFileAutoHandle output_file_auto_handle(output_file_str);
  if(!output_file_auto_handle.handle)
    return 6;

  char in_line_buf[4096];
  char out_line_buf[4096+MAX_QUOTES_IN_STRING_LINE];

  const char* comment_char_buf[MAX_QUOTES_IN_STRING_LINE];
  switch(mode)
  {
    case 1:
    {
      char* var_fmt_type1_ptr = NULL;       //':'
      char* last_non_space_char_ptr = NULL; //Any
      char* eq_char_ptr = NULL;             //'='
      char* stop_proc_char_ptr = NULL;      //'$'
      char* comment_char_ptr = NULL;        //'#'
      while(!::feof(config_file_auto_handle.handle))
      {
        char* str_line = ::fgets(in_line_buf, sizeof(in_line_buf)/sizeof(in_line_buf[0]),
          config_file_auto_handle.handle);
        if(!str_line)
          continue;

        char* first_non_space_char_ptr =
          _scan_cfg_str_line(str_line, sizeof(in_line_buf)/sizeof(in_line_buf[0]),
              &var_fmt_type1_ptr, &last_non_space_char_ptr,
              &eq_char_ptr, &stop_proc_char_ptr,
              &comment_char_ptr);

        if(!first_non_space_char_ptr)
        {
          ::fprintf(output_file_auto_handle.handle, "\n");
          continue;
        }
        else
        {
          // ignore line if line is comment itself
          if(comment_char_ptr && first_non_space_char_ptr == comment_char_ptr)
            continue;

          // ignore line if variable name ends with ':'
          if(!stop_proc_char_ptr || first_non_space_char_ptr != stop_proc_char_ptr)
          {
            assert(last_non_space_char_ptr);
            if(var_fmt_type1_ptr && var_fmt_type1_ptr+1 > last_non_space_char_ptr)
              continue;
          }
        }

        // read variable format
        variable_type var_type = eVarType_Ansi;
        if(var_fmt_type1_ptr)
        {
          if(var_fmt_type1_ptr[1] == 'A')
            ;//var_type = eVarType_Ansi;
          else if(var_fmt_type1_ptr[1] == 'W')
            var_type = aVerType_Unicode16;
          else
          {
            // ignore line cause unknown variable format
            var_type = eVarType_Unknown;
            continue;
          }
        }

        if(!stop_proc_char_ptr)
        {
          if(!eq_char_ptr || first_non_space_char_ptr == eq_char_ptr)
          {
            ::fprintf(output_file_auto_handle.handle, "//%s", str_line);
            continue;
          }

          assert(first_non_space_char_ptr < last_non_space_char_ptr);
          assert(first_non_space_char_ptr < eq_char_ptr);
          assert(eq_char_ptr <= last_non_space_char_ptr);

          // find last non space character before equal and
          // first non space character after equal (comment character excluded)
          char* non_space_char_before_eq_ptr = NULL;
          char* non_space_char_after_eq_ptr = NULL;
          char* end_non_space_char_before_eq_ptr =
            var_fmt_type1_ptr ? var_fmt_type1_ptr : eq_char_ptr;

          _scan_cfg_str_line(first_non_space_char_ptr,
            end_non_space_char_before_eq_ptr-first_non_space_char_ptr+1,
            NULL, &non_space_char_before_eq_ptr, NULL, NULL, NULL);

          assert(first_non_space_char_ptr <= non_space_char_before_eq_ptr);
          if(eq_char_ptr < last_non_space_char_ptr)
          {
            non_space_char_after_eq_ptr = _scan_cfg_str_line(eq_char_ptr+1,
              last_non_space_char_ptr-eq_char_ptr+1, NULL, NULL, NULL, NULL, NULL);
            assert(non_space_char_after_eq_ptr <= last_non_space_char_ptr);
          }

          const int parse_res = _parse_result_to_buf(out_line_buf,
            sizeof(out_line_buf)/sizeof(out_line_buf[0]), NULL, var_type, str_line,
            first_non_space_char_ptr, non_space_char_before_eq_ptr,
            eq_char_ptr, non_space_char_after_eq_ptr, last_non_space_char_ptr, comment_char_ptr);
        }
        else
        {
          size_t parsed_str_len = 0;

          // find last non space character before equal and
          // first non space character after equal (stop processing and comment characters are excluded)
          char* non_space_char_before_eq_ptr = NULL;
          char* non_space_char_after_eq_ptr = NULL;
          char* end_non_space_char_before_eq_ptr = var_fmt_type1_ptr ? var_fmt_type1_ptr : eq_char_ptr;
          char* non_space_char_before_stop_proc_ptr = NULL;

          if(first_non_space_char_ptr != stop_proc_char_ptr)
          {
            if(!eq_char_ptr || first_non_space_char_ptr == eq_char_ptr)
            {
              ::fprintf(output_file_auto_handle.handle, "//%s", str_line);
              continue;
            }

            assert(first_non_space_char_ptr < last_non_space_char_ptr);
            assert(first_non_space_char_ptr < eq_char_ptr);
            assert(eq_char_ptr < last_non_space_char_ptr);
            assert(eq_char_ptr < stop_proc_char_ptr);

            _scan_cfg_str_line(first_non_space_char_ptr,
              end_non_space_char_before_eq_ptr-first_non_space_char_ptr+1,
              NULL, &non_space_char_before_eq_ptr, NULL, NULL, NULL);

            assert(first_non_space_char_ptr <= non_space_char_before_eq_ptr);
            non_space_char_after_eq_ptr =
              _scan_cfg_str_line(eq_char_ptr+1, stop_proc_char_ptr-eq_char_ptr+1,
                NULL, &non_space_char_before_stop_proc_ptr, NULL, NULL, NULL);

            const bool bIsVarValueAsIs = (non_space_char_after_eq_ptr == stop_proc_char_ptr &&
              non_space_char_after_eq_ptr == non_space_char_before_stop_proc_ptr);

            assert(bIsVarValueAsIs ||
              !((non_space_char_after_eq_ptr != NULL) ^ (non_space_char_before_stop_proc_ptr != NULL)));
            assert(bIsVarValueAsIs ||
              !non_space_char_after_eq_ptr || non_space_char_after_eq_ptr < stop_proc_char_ptr);
            assert(bIsVarValueAsIs ||
              !non_space_char_before_stop_proc_ptr ||
              non_space_char_before_stop_proc_ptr < stop_proc_char_ptr);
          }

          const int parse_res =
            _parse_result_to_buf(out_line_buf, sizeof(out_line_buf)/sizeof(out_line_buf[0]),
              &parsed_str_len, var_type, str_line, first_non_space_char_ptr,
              non_space_char_before_eq_ptr, eq_char_ptr, non_space_char_after_eq_ptr,
              non_space_char_before_stop_proc_ptr, comment_char_ptr, stop_proc_char_ptr,
              last_non_space_char_ptr+1-stop_proc_char_ptr);
          if(parse_res)
          {
            // ignore on error
            ::fprintf(output_file_auto_handle.handle, "\n");
            continue;
          }
        }

        ::fprintf(output_file_auto_handle.handle, "%s\n", out_line_buf);
      }
    } break;

    case 2:
    {
      while(!::feof(config_file_auto_handle.handle))
      {
        char* str_line = ::fgets(in_line_buf, sizeof(in_line_buf)/sizeof(in_line_buf[0]),
          config_file_auto_handle.handle);
        if(!str_line)
          continue;

        size_t string_len = 0;
        size_t num_comment_chars = 0;
        const int nScanRes = _scan_txt_str_line(
          str_line, sizeof(in_line_buf)/sizeof(in_line_buf[0]), &string_len,
          comment_char_buf, sizeof(comment_char_buf)/sizeof(comment_char_buf[0]), &num_comment_chars,
          (flags & 0x2) ? true : false);

        if(num_comment_chars)
        {
          const char* cur_str_line = str_line;
          char* cur_str_line_out = out_line_buf;
          size_t i;

          for(i = 0; i < num_comment_chars; ++i)
          {
            const size_t sub_str_len = comment_char_buf[i]-cur_str_line;
            ::strncpy(cur_str_line_out, cur_str_line, sub_str_len);

            switch(*comment_char_buf[i])
            {
              case '%': cur_str_line_out[sub_str_len] = '%'; break;
              default:  cur_str_line_out[sub_str_len] = '\\';
            }

            cur_str_line += sub_str_len;
            cur_str_line_out += sub_str_len+1;
          }

          assert(cur_str_line < str_line+string_len);
          ::strncpy(cur_str_line_out, cur_str_line, str_line+string_len-cur_str_line);
          out_line_buf[string_len+i] = '\0';
        }
        else
        {
          ::strncpy(out_line_buf, str_line, string_len);
          out_line_buf[string_len] = '\0';
        }

        if (!unicode) {
          ::fprintf(output_file_auto_handle.handle, "\"%s\\n\"\n", out_line_buf);
        } else {
          ::fprintf(output_file_auto_handle.handle, "L\"%s\\n\"\n", out_line_buf);
        }
      }
    } break;

    default:
      return 255;
  }

  return 0;
}
