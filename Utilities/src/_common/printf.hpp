#ifndef __COMMON_PRINTF_HPP__
#define __COMMON_PRINTF_HPP__

#include <version.hpp>
#include <common.hpp>

#include <compatible_iterator/compatible_iterator.hpp>

namespace {
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

    using compatible_const_it       = tackle::compatible_const_iterator<const_char_ptr_vector_t, string_vector_t>;
    using compatible_const_it_path  = tackle::compatible_const_iterator_path<const_char_ptr_vector_t, string_vector_t>;
    using compatible_path_const_it  = tackle::compatible_path_const_iterator<const_char_ptr_vector_t, string_vector_t>;

    void _parse_string(int arg_index, const char * parse_str, std::string & parsed_str, char * in_str_value, bool use_in_args,
                       const InArgs & in_args = InArgs(), const OutArgs & out_args = OutArgs()) {
        bool done = false;
        bool found;
        const char * last_offset = parse_str;
        char var_buf[256];
        char int_to_str_buffer[sizeof(int) * 8 + 1]; // maximum length for minimum radix + null terminator

        do {
            found = false;

            const char * p = strstr(last_offset, "{");
            if_break(p) {
                // process unprocessed trailing characters
                if (p > last_offset) {
                    const char * last_offset_var = _extract_variable(last_offset, p - 1, parsed_str, in_str_value);
                    if (last_offset_var) {
                        found = true;
                        last_offset = last_offset_var;
                        break;
                    }
                }

                // process escapes
                if (p > last_offset && *(p - 1) == '\\') {
                    if (p > last_offset + 1) {
                        parsed_str.append(last_offset, p - 1);
                    }
                    parsed_str.append(p, p + 1);
                    last_offset = p + 1;
                    if (*last_offset) found = true;
                    break;
                }

                int i = 0;

                compatible_const_it_path it_path;
                it_path.resize(1);

                if (use_in_args) {
                    it_path[0] = &in_args.args;
                }
                else {
                    it_path[0] = &out_args.args;
                }

                compatible_path_const_it path_it;
                for (path_it.set(true, it_path); !path_it.done(true); path_it.step(true), ++i) {
                    const compatible_const_it & it = path_it.get();

                    itoa(i, int_to_str_buffer, 10);

                    // {N}
                    {
                        strcpy(var_buf, "{");
                        strcat(var_buf, int_to_str_buffer);
                        strcat(var_buf, "}");

                        const size_t var_vn_len = strlen(var_buf);
                        const int var_vn = strncmp(p, var_buf, var_vn_len);
                        if (!var_vn) {
                            parsed_str.append(last_offset, p);
                            last_offset = p + var_vn_len;

                            if (i != arg_index) {
                                if (it.typeIndex() == 0) {
                                    parsed_str.append(*it.get0());
                                }
                                else if (it.typeIndex() == 1) {
                                    parsed_str.append(*it.get1());
                                }
                                else {
                                    assert(0);
                                }
                            }
                            else {
                                parsed_str.append(var_buf);
                            }

                            found = true;
                        }

                        if (found) break;
                    }

                    // {Nhs}
                    {
                        strcpy(var_buf, "{");
                        strcat(var_buf, int_to_str_buffer);
                        strcat(var_buf, "hs}");

                        const size_t var_vn_len = strlen(var_buf);
                        const int var_vn = strncmp(p, var_buf, var_vn_len);
                        if (!var_vn) {
                            parsed_str.append(last_offset, p);
                            last_offset = p + var_vn_len;
                            if (i != arg_index) {
                                if (it.typeIndex() == 0) {
                                    const std::string::size_type vn_value_len = strlen(*it.get0());
                                    for (std::string::size_type j = 0; j < vn_value_len; j++) {
                                        parsed_str.append(hextbl[(*it.get0())[j]]);
                                    }
                                }
                                else if (it.typeIndex() == 1) {
                                    const std::string::size_type vn_value_len = it.get1()->length();
                                    for (std::string::size_type j = 0; j < vn_value_len; j++) {
                                        parsed_str.append(hextbl[(*it.get1())[j]]);
                                    }
                                }
                                else {
                                    assert(0);
                                }
                            }
                            else {
                                parsed_str.append(var_buf);
                            }

                            found = true;
                        }

                        if (found) break;
                    }
                }

                if (found) break;

                if (*(p + 1)) {
                    const char * p_end = strstr(p + 1, "}");
                    if (p_end) {
                        parsed_str.append(last_offset, p_end + 1);
                        last_offset = p_end + 1;
                        if (*last_offset) found = true;
                        break;
                    }
                }
            }

            if (!found) done = true;

            if (done && last_offset) {
                parsed_str.append(last_offset);
                last_offset = 0; // just in case
            }
        } while (!done);
    }
}

#endif
