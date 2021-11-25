#!/bin/bash

# Script can be ONLY included by "source" command.
[[ -z "$BASH" || (-n "$BASH_LINENO" && BASH_LINENO[0] -le 0) || (-n "$CONTOOLS_PROJECT_ROOT_INIT0_DIR" && "$CONTOOLS_PROJECT_ROOT_INIT0_DIR" == "$BASH_SOURCE_DIR") ]] && return

if [[ -z "$SOURCE_TACKLELIB_BASH_TACKLELIB_SH" || SOURCE_TACKLELIB_BASH_TACKLELIB_SH -eq 0 ]]; then
  # builtin search
  for BASH_SOURCE_DIR in "/usr/local/bin" "/usr/bin" "/bin"; do
    [[ -f "$BASH_SOURCE_DIR/bash_tacklelib" ]] && {
      source "$BASH_SOURCE_DIR/bash_tacklelib" || exit $?
      break
    }
  done
fi

tkl_export_path CONTOOLS_PROJECT_ROOT_INIT0_DIR "$BASH_SOURCE_DIR" # including guard

[[ -z "$NEST_LVL" ]] && tkl_declare_global NEST_LVL 0

[[ -z "$CONTOOLS_PROJECT_ROOT" ]] &&                tkl_export_path -a -s CONTOOLS_PROJECT_ROOT               "$BASH_SOURCE_DIR/.."
[[ -z "$CONTOOLS_PROJECT_EXTERNALS_ROOT" ]] &&      tkl_export_path -a -s CONTOOLS_PROJECT_EXTERNALS_ROOT     "$CONTOOLS_PROJECT_ROOT/_externals"

[[ -z "$PROJECT_OUTPUT_ROOT" ]] &&                  tkl_export_path -a -s PROJECT_OUTPUT_ROOT                 "$CONTOOLS_PROJECT_ROOT/_out"
[[ -z "$PROJECT_LOG_ROOT" ]] &&                     tkl_export_path -a -s PROJECT_LOG_ROOT                    "$CONTOOLS_PROJECT_ROOT/.log"

[[ -z "$CONTOOLS_PROJECT_INPUT_CONFIG_ROOT" ]] &&   tkl_export_path -a -s CONTOOLS_PROJECT_INPUT_CONFIG_ROOT  "$CONTOOLS_PROJECT_ROOT/_config"
[[ -z "$CONTOOLS_PROJECT_OUTPUT_CONFIG_ROOT" ]] &&  tkl_export_path -a -s CONTOOLS_PROJECT_OUTPUT_CONFIG_ROOT "$PROJECT_OUTPUT_ROOT/config/contools"

[[ -z "$CONTOOLS_ROOT" ]] &&                        tkl_export_path -a -s CONTOOLS_ROOT                       "$CONTOOLS_PROJECT_ROOT/Scripts/Tools"

[[ ! -e "$CONTOOLS_PROJECT_OUTPUT_CONFIG_ROOT" ]] && { mkdir -p "$CONTOOLS_PROJECT_OUTPUT_CONFIG_ROOT" || tkl_abort 10; }

[[ -z "$LOAD_CONFIG_VERBOSE" ]] && (( INIT_VERBOSE )) && tkl_export_path LOAD_CONFIG_VERBOSE 1

tkl_load_config_dir "$CONTOOLS_PROJECT_INPUT_CONFIG_ROOT" "$CONTOOLS_PROJECT_OUTPUT_CONFIG_ROOT"

# init external projects, common dependencies must be always initialized at first

if [[ -f "$CONTOOLS_PROJECT_EXTERNALS_ROOT/tacklelib/__init__/__init__.sh" ]]; then
  tkl_include "$CONTOOLS_PROJECT_EXTERNALS_ROOT/tacklelib/__init__/__init__.sh" || tkl_abort_include
fi

if [[ -f "$CONTOOLS_PROJECT_EXTERNALS_ROOT/svncmd/__init__/__init__.sh" ]]; then
  tkl_include "$CONTOOLS_PROJECT_EXTERNALS_ROOT/svncmd/__init__/__init__.sh" || tkl_abort_include
fi

tkl_include "$TACKLELIB_BASH_ROOT/tacklelib/buildlib.sh" || tkl_abort_include

[[ ! -e "$PROJECT_OUTPUT_ROOT" ]] && { mkdir -p "$PROJECT_OUTPUT_ROOT" || tkl_abort 11; }
[[ ! -e "$PROJECT_LOG_ROOT" ]] && { mkdir -p "$PROJECT_LOG_ROOT" || tkl_abort 12; }

tkl_include "$TACKLELIB_BASH_ROOT/tacklelib/tools/load_config.sh" || tkl_abort_include

: # resets exit code to 0
