#ifndef __COMMON_PRINTF_HPP__
#define __COMMON_PRINTF_HPP__

#include <version.hpp>
#include <common.hpp>

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

	void _parse_string(const char * parse_str, std::string & parsed_str, char * in_str_value, const InArgs & in_args = InArgs(), const OutArgs & out_args = OutArgs()) {
		bool done = false;
		bool found;
		const char * last_offset = parse_str;
		char var_buffer[256];
		char int_to_str_buffer[sizeof(int) * 8 + 1]; // maximum length for minimum radix + null terminator

		do {
			found = false;

			const char * p = strstr(last_offset, "{");
			if_break(p) {
				if (p > last_offset) {
					const char * last_offset_var = _extract_variable(last_offset, p - 1, parsed_str, in_str_value);
					if (last_offset_var) {
						found = true;
						last_offset = last_offset_var;
						break;
					}
				}

				if (p > last_offset && *(p - 1) == '\\') {
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

						strcpy(var_buffer, "{");
						strcat(var_buffer, int_to_str_buffer);
						strcat(var_buffer, "}");

						// {N}
						const size_t var_vn_len = strlen(var_buffer);
						const int var_vn = strncmp(p, var_buffer, var_vn_len);
						if (!var_vn) {
							parsed_str.append(last_offset, p);
							last_offset = p + var_vn_len;
							parsed_str.append(out_args.args[i]);
							found = true;
						}

						// {Nhs}
						if (!found) {
							strcpy(var_buffer, "{");
							strcat(var_buffer, int_to_str_buffer);
							strcat(var_buffer, "hs}");

							const size_t var_vn_len = strlen(var_buffer);
							const int var_vn = strncmp(p, var_buffer, var_vn_len);
							if (!var_vn) {
								parsed_str.append(last_offset, p);
								last_offset = p + var_vn_len;
								const std::string::size_type vn_value_len = out_args.args[i].length();
								for (std::string::size_type j = 0; j < vn_value_len; j++) {
									parsed_str.append(hextbl[out_args.args[i][j]]);
								}
								found = true;
							}
						}

						if (found) break;
					}
				}

				if (!found) {
					if (*(p + 1)) {
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
		} while (!done);
	}
}

#endif
