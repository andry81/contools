#ifndef __COMMON_PRINTF_HPP__
#define __COMMON_PRINTF_HPP__

#include <version.hpp>
#include <common.hpp>

#include <compatible_iterator/compatible_iterator.hpp>

namespace {
    struct InBaseArgs
    {
        const_tchar_ptr_vector_t    args;
    };

    struct OutBaseArgs
    {
        tstring_vector_t    args;
    };

    using compatible_const_it       = tackle::compatible_const_iterator<const_tchar_ptr_vector_t, tstring_vector_t>;
    using compatible_const_it_path  = tackle::compatible_const_iterator_path<const_tchar_ptr_vector_t, tstring_vector_t>;
    using compatible_path_const_it  = tackle::compatible_path_const_iterator<const_tchar_ptr_vector_t, tstring_vector_t>;

    void _parse_string(int arg_index, const TCHAR * parse_str, std::tstring & parsed_str, TCHAR * env_buf,
                       bool no_expand_env, bool no_subst_vars, bool use_in_args,
                       const InBaseArgs & in_args = InBaseArgs(), const OutBaseArgs & out_args = OutBaseArgs()) {

        if (no_expand_env && no_subst_vars) {
            parsed_str.append(parse_str);
            return;
        }

        bool done = false;
        bool found;
        const TCHAR * last_offset_ptr = parse_str;
        TCHAR var_buf[256];
        TCHAR int_to_str_buffer[sizeof(int) * 8 + 1]; // maximum length for minimum radix + null terminator

        do {
            found = false;

            const TCHAR * p = tstrstr(last_offset_ptr, _T("{"));
            if_break(p) {
                // process unprocessed trailing characters
                if (p > last_offset_ptr && !no_expand_env) {
                    const TCHAR * last_offset_var_ptr = _extract_variable(last_offset_ptr, p - 1, parsed_str, env_buf);
                    if (last_offset_var_ptr) {
                        found = true;
                        last_offset_ptr = last_offset_var_ptr;
                        break;
                    }
                }

                // process escapes
                if (p > last_offset_ptr && *(p - 1) == _T('\\')) {
                    if (p > last_offset_ptr + 1) {
                        parsed_str.append(last_offset_ptr, p - 1);
                    }
                    parsed_str.append(p, p + 1);
                    last_offset_ptr = p + 1;
                    if (*last_offset_ptr) found = true;
                    break;
                }

                if (!no_subst_vars) {
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

                        _itot(i, int_to_str_buffer, 10);

                        // {N}
                        {
                            tstrcpy(var_buf, _T("{"));
                            tstrcat(var_buf, int_to_str_buffer);
                            tstrcat(var_buf, _T("}"));

                            const size_t var_vn_len = tstrlen(var_buf);
                            const int var_vn = tstrncmp(p, var_buf, var_vn_len);
                            if (!var_vn && (!no_expand_env || p > parse_str && *(p - 1) != _T('$'))) {
                                parsed_str.append(last_offset_ptr, p);
                                last_offset_ptr = p + var_vn_len;

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
                            tstrcpy(var_buf, _T("{"));
                            tstrcat(var_buf, int_to_str_buffer);
                            tstrcat(var_buf, _T("hs}"));

                            const size_t var_vn_len = tstrlen(var_buf);
                            const int var_vn = tstrncmp(p, var_buf, var_vn_len);
                            if (!var_vn && (!no_expand_env || p > parse_str && *(p - 1) != _T('$'))) {
                                parsed_str.append(last_offset_ptr, p);
                                last_offset_ptr = p + var_vn_len;
                                if (i != arg_index) {
                                    if (it.typeIndex() == 0) {
                                        const std::tstring::size_type vn_value_len = tstrlen(*it.get0());
                                        for (std::tstring::size_type j = 0; j < vn_value_len; j++) {
                                            parsed_str.append(g_hextbl[(*it.get0())[j]]);
                                        }
                                    }
                                    else if (it.typeIndex() == 1) {
                                        const std::tstring::size_type vn_value_len = it.get1()->length();
                                        for (std::tstring::size_type j = 0; j < vn_value_len; j++) {
                                            parsed_str.append(g_hextbl[(*it.get1())[j]]);
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
                }
                else {
                    if (p > last_offset_ptr) {
                        parsed_str.append(last_offset_ptr, p);
                    }

                    parsed_str.append(_T("{"));

                    last_offset_ptr = p + 1;

                    found = true;
                }

                if (found) break;

                if (*(p + 1)) {
                    const TCHAR * p_end = tstrstr(p + 1, _T("}"));
                    if (p_end) {
                        parsed_str.append(last_offset_ptr, p_end + 1);
                        last_offset_ptr = p_end + 1;
                        if (*last_offset_ptr) found = true;
                        break;
                    }
                }
            }

            if (!found) done = true;

            if (done && last_offset_ptr) {
                parsed_str.append(last_offset_ptr);
                last_offset_ptr = 0; // just in case
            }
        } while (!done);
    }
}

#endif
