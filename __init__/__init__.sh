#!/bin/bash

# Script can be ONLY included by "source" command.
if [[ -n "$BASH" && (-z "$BASH_LINENO" || BASH_LINENO[0] -gt 0) && "$CONTOOLS_ROOT_INIT0_DIR" != "$BASH_SOURCE_DIR" ]]; then

CONTOOLS_ROOT_INIT0_DIR="$BASH_SOURCE_DIR" # including guard

source "/bin/bash_entry" || exit $?

[[ -z "$NEST_LVL" ]] && NEST_LVL=0

tkl_normalize_path "$BASH_SOURCE_DIR/.." -a && \
CONTOOLS_PROJECT_ROOT="$RETURN_VALUE"

[[ -z "$CONTOOLS_ROOT" ]] &&                tkl_export CONTOOLS_ROOT                "$CONTOOLS_PROJECT_ROOT/Scripts/Tools"
[[ -z "$CONTOOLS_UTILITIES_ROOT" ]] &&      tkl_export CONTOOLS_UTILITIES_ROOT      "$CONTOOLS_PROJECT_ROOT/Utilities"
[[ -z "$CONTOOLS_UTILITIES_BIN_ROOT" ]] &&  tkl_export CONTOOLS_UTILITIES_BIN_ROOT  "$CONTOOLS_UTILITIES_ROOT/bin"
[[ -z "$CONTOOLS_BUILD_TOOLS_ROOT" ]] &&    tkl_export CONTOOLS_BUILD_TOOLS_ROOT    "$CONTOOLS_ROOT/build"
[[ -z "$CONTOOLS_GNUWIN32_ROOT" ]] &&       tkl_export CONTOOLS_GNUWIN32_ROOT       "$CONTOOLS_ROOT/gnuwin32"
[[ -z "$SVNCMD_TOOLS_ROOT" ]] &&            tkl_export SVNCMD_TOOLS_ROOT            "$CONTOOLS_ROOT/scm/svn"
[[ -z "$CONTOOLS_SQLITE_TOOLS_ROOT" ]] &&   tkl_export CONTOOLS_SQLITE_TOOLS_ROOT   "$CONTOOLS_ROOT/sqlite"
[[ -z "$CONTOOLS_TESTLIB_ROOT" ]] &&        tkl_export CONTOOLS_TESTLIB_ROOT        "$CONTOOLS_ROOT/testlib"
[[ -z "$CONTOOLS_XML_TOOLS_ROOT" ]] &&      tkl_export CONTOOLS_XML_TOOLS_ROOT      "$CONTOOLS_ROOT/xml"
[[ -z "$CONTOOLS_HASHDEEP_ROOT" ]] &&       tkl_export CONTOOLS_HASHDEEP_ROOT       "$CONTOOLS_ROOT/hash/hashdeep"
[[ -z "$CONTOOLS_VARS_ROOT" ]] &&           tkl_export CONTOOLS_VARS_ROOT           "$CONTOOLS_ROOT/vars"

return 0

fi
