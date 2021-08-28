#!/bin/bash

# Script can be ONLY included by "source" command.
[[ -z "$BASH" || (-n "$BASH_LINENO" && BASH_LINENO[0] -le 0) || "$CONTOOLS_PROJECT_ROOT_INIT0_DIR" == "$BASH_SOURCE_DIR" ]] && return

source '/bin/bash_tacklelib' || exit $?

[[ BASH_SOURCE_NEST_LVL -eq 0 ]] && tkl_make_source_file_components

[[ -z "$NEST_LVL" ]] && tkl_declare_global NEST_LVL=0

[[ -z "$CONTOOLS_PROJECT_ROOT" ]] && {
  tkl_normalize_path "$BASH_SOURCE_DIR/.." -a || tkl_abort 9
  tkl_export CONTOOLS_PROJECT_ROOT                  "${RETURN_VALUE:-*:\$\{CONTOOLS_PROJECT_ROOT\}}" # safety: replace by not applicable or unexisted directory if empty
}
[[ -z "$CONTOOLS_PROJECT_EXTERNALS_ROOT" ]] &&      tkl_export CONTOOLS_PROJECT_EXTERNALS_ROOT    "$CONTOOLS_PROJECT_ROOT/_externals"

[[ -z "$CONTOOLS_ROOT" ]] &&                        tkl_export CONTOOLS_ROOT                      "$CONTOOLS_PROJECT_ROOT/Scripts/Tools"
[[ -z "$CONTOOLS_BASH_ROOT" ]] &&                   tkl_export CONTOOLS_BASH_ROOT                 "$CONTOOLS_ROOT/bash"
[[ -z "$CONTOOLS_BUILD_TOOLS_ROOT" ]] &&            tkl_export CONTOOLS_BUILD_TOOLS_ROOT          "$CONTOOLS_ROOT/build"
[[ -z "$CONTOOLS_SQLITE_TOOLS_ROOT" ]] &&           tkl_export CONTOOLS_SQLITE_TOOLS_ROOT         "$CONTOOLS_ROOT/sqlite"
[[ -z "$CONTOOLS_TESTLIB_ROOT" ]] &&                tkl_export CONTOOLS_TESTLIB_ROOT              "$CONTOOLS_ROOT/testlib"
[[ -z "$CONTOOLS_XML_TOOLS_ROOT" ]] &&              tkl_export CONTOOLS_XML_TOOLS_ROOT            "$CONTOOLS_ROOT/xml"
[[ -z "$CONTOOLS_VARS_ROOT" ]] &&                   tkl_export CONTOOLS_VARS_ROOT                 "$CONTOOLS_ROOT/vars"

[[ -z "$CONTOOLS_UTILITIES_ROOT" ]] &&              tkl_export CONTOOLS_UTILITIES_ROOT            "$CONTOOLS_PROJECT_ROOT/Utilities"
[[ -z "$CONTOOLS_UTILITIES_BIN_ROOT" ]] &&          tkl_export CONTOOLS_UTILITIES_BIN_ROOT        "$CONTOOLS_UTILITIES_ROOT/bin"
[[ -z "$CONTOOLS_GNUWIN32_ROOT" ]] &&               tkl_export CONTOOLS_GNUWIN32_ROOT             "$CONTOOLS_UTILITIES_BIN_ROOT/gnuwin32"
[[ -z "$CONTOOLS_UTILITIES_HASHDEEP_ROOT" ]] &&     tkl_export CONTOOLS_UTILITIES_HASHDEEP_ROOT   "$CONTOOLS_UTILITIES_BIN_ROOT/hashdeep"
[[ -z "$CONTOOLS_UTILITIES_SQLITE_ROOT" ]] &&       tkl_export CONTOOLS_UTILITIES_SQLITE_ROOT     "$CONTOOLS_UTILITIES_BIN_ROOT/sqlite"

# init external projects

if [[ -f "$CONTOOLS_PROJECT_EXTERNALS_ROOT/tacklelib/__init__/__init__.sh" ]]; then
  tkl_include "$CONTOOLS_PROJECT_EXTERNALS_ROOT/tacklelib/__init__/__init__.sh" || tkl_abort_include
fi

if [[ -f "$CONTOOLS_PROJECT_EXTERNALS_ROOT/svncmd/__init__/__init__.sh" ]]; then
  tkl_include "$CONTOOLS_PROJECT_EXTERNALS_ROOT/svncmd/__init__/__init__.sh" || tkl_abort_include
fi

CONTOOLS_PROJECT_ROOT_INIT0_DIR="$BASH_SOURCE_DIR" # including guard

: # resets exit code to 0
