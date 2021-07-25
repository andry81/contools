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

    template <typename Flags, typename Options>
    void _parse_string(int arg_index, const TCHAR * parse_str, std::tstring & parsed_str, TCHAR * env_buf,
                       bool no_expand_env, bool no_subst_vars, bool use_in_args,
                       const Flags & flags, const Options & options,
                       const InBaseArgs & in_args = InBaseArgs(), const OutBaseArgs & out_args = OutBaseArgs()) {

        // intercept here specific global variables accidental usage instead of local variables
        static struct {} g_options;
        static struct {} g_flags;

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
                    bool allow_expand_env_in_arg = options.expand_env_args.empty();
                    bool allow_expand_unexisted_env = flags.allow_expand_unexisted_env;

                    if_break (!allow_expand_env_in_arg) {
                        const int pos_arg_index = arg_index + 2;    // positional argument index
                        if (pos_arg_index < 0) {                    // `/v <name> <value>` option argument, always allow
                            allow_expand_env_in_arg = true; 
                            break;
                        }

                        for (const auto & tuple_ref : options.expand_env_args) {
                            const int expand_env_arg_index = std::get<0>(tuple_ref);
                            const bool allow_expand_unexisted_env2 = std::get<1>(tuple_ref);

                            if (expand_env_arg_index == pos_arg_index) {
                                allow_expand_env_in_arg = true;
                                if (!allow_expand_unexisted_env) {
                                    allow_expand_unexisted_env = allow_expand_unexisted_env2;
                                }
                                break;
                            }
                        }
                    }

                    if (allow_expand_env_in_arg) {
                        const TCHAR * last_offset_var_ptr = _extract_variable(last_offset_ptr, p - 1, parsed_str, env_buf, allow_expand_unexisted_env);
                        if (last_offset_var_ptr) {
                            found = true;
                            last_offset_ptr = last_offset_var_ptr;
                            break;
                        }
                    }
                }

                if (!no_subst_vars) {
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
                            if (!var_vn && (!no_expand_env || p == parse_str || p > parse_str && *(p - 1) != _T('$'))) {
                                bool allow_subst_var_in_arg = options.subst_vars_args.empty();
                                bool allow_subst_empty_arg = flags.allow_subst_empty_args;

                                if_break(!allow_subst_var_in_arg) {
                                    const int pos_arg_index = arg_index + 2;    // positional argument index
                                    if (pos_arg_index < 0) {                    // `/v <name> <value>` option argument, always allow
                                        allow_subst_var_in_arg = true;
                                        break;
                                    }

                                    for (const auto & tuple_ref : options.subst_vars_args) {
                                        const int subst_var_arg_index = std::get<0>(tuple_ref);
                                        const bool allow_subst_empty_arg2 = std::get<1>(tuple_ref);

                                        if (subst_var_arg_index == pos_arg_index) {
                                            allow_subst_var_in_arg = true;
                                            if (!allow_subst_empty_arg) {
                                                allow_subst_empty_arg = allow_subst_empty_arg2;
                                            }
                                            break;
                                        }
                                    }
                                }

                                parsed_str.append(last_offset_ptr, p);
                                last_offset_ptr = p + var_vn_len;

                                if (i != arg_index) {
                                    if (it.typeIndex() == 0) {
                                        const std::tstring::size_type vn_value_len = tstrlen(*it.get0());
                                        if (allow_subst_var_in_arg && (allow_subst_empty_arg || vn_value_len)) {
                                            parsed_str.append(*it.get0());
                                        }
                                        else {
                                            parsed_str.append(var_buf);
                                        }
                                    }
                                    else if (it.typeIndex() == 1) {
                                        const std::tstring::size_type vn_value_len = it.get1()->length();
                                        if (allow_subst_var_in_arg && (allow_subst_empty_arg || vn_value_len)) {
                                            parsed_str.append(*it.get1());
                                        }
                                        else {
                                            parsed_str.append(var_buf);
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

                        // {Nhs}
                        {
                            tstrcpy(var_buf, _T("{"));
                            tstrcat(var_buf, int_to_str_buffer);
                            tstrcat(var_buf, _T("hs}"));

                            const size_t var_vn_len = tstrlen(var_buf);
                            const int var_vn = tstrncmp(p, var_buf, var_vn_len);
                            if (!var_vn && (!no_expand_env || p == parse_str || p > parse_str && *(p - 1) != _T('$'))) {
                                bool allow_subst_var_in_arg = options.subst_vars_args.empty();
                                bool allow_subst_empty_arg = flags.allow_subst_empty_args;

                                if_break(!allow_subst_var_in_arg) {
                                    const int pos_arg_index = arg_index + 2;    // positional argument index
                                    if (pos_arg_index < 0) {                    // `/v <name> <value>` option argument, always allow
                                        allow_subst_var_in_arg = true;
                                        break;
                                    }

                                    for (const auto & tuple_ref : options.subst_vars_args) {
                                        const int subst_var_arg_index = std::get<0>(tuple_ref);
                                        const bool allow_subst_empty_arg2 = std::get<1>(tuple_ref);

                                        if (subst_var_arg_index == pos_arg_index) {
                                            allow_subst_var_in_arg = true;
                                            if (!allow_subst_empty_arg) {
                                                allow_subst_empty_arg = allow_subst_empty_arg2;
                                            }
                                            break;
                                        }
                                    }
                                }

                                parsed_str.append(last_offset_ptr, p);
                                last_offset_ptr = p + var_vn_len;
                                if (i != arg_index) {
                                    if (it.typeIndex() == 0) {
                                        const std::tstring::size_type vn_value_len = tstrlen(*it.get0());
                                        if (allow_subst_var_in_arg && (allow_subst_empty_arg || vn_value_len)) {
                                            for (std::tstring::size_type j = 0; j < vn_value_len; j++) {
                                                parsed_str.append(g_hextbl[(*it.get0())[j]]);
                                            }
                                        }
                                        else {
                                            parsed_str.append(var_buf);
                                        }
                                    }
                                    else if (it.typeIndex() == 1) {
                                        const std::tstring::size_type vn_value_len = it.get1()->length();
                                        if (allow_subst_var_in_arg && (allow_subst_empty_arg || vn_value_len)) {
                                            for (std::tstring::size_type j = 0; j < vn_value_len; j++) {
                                                parsed_str.append(g_hextbl[(*it.get1())[j]]);
                                            }
                                        }
                                        else {
                                            parsed_str.append(var_buf);
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
