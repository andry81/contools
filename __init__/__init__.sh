#!/bin/bash

# Script can be ONLY included by "source" command.
if [[ -n "$BASH" && (-z "$BASH_LINENO" || BASH_LINENO[0] -gt 0) && "$CONTOOLS_ROOT_INIT0_DIR" != "$BASH_SOURCE_DIR" ]]; then

CONTOOLS_ROOT_INIT0_DIR="$BASH_SOURCE_DIR" # including guard

source "/bin/bash_entry" || exit $?

[[ -z "$NEST_LVL" ]] && NEST_LVL=0

tkl_normalize_path "$BASH_SOURCE_DIR/.." -a && \
PROJECT_ROOT="$RETURN_VALUE"

[[ -z "$LOCAL_CONFIG_DIR_NAME" ]] && LOCAL_CONFIG_DIR_NAME=config

[[ -z "$CONTOOLS_ROOT" ]] && CONTOOLS_ROOT="$PROJECT_ROOT/Scripts/Tools"
[[ -z "$UTILITIES_ROOT" ]] && UTILITIES_ROOT="$PROJECT_ROOT/Utilities"
[[ -z "$UTILITY_ROOT" ]] && UTILITY_ROOT="$UTILITIES_ROOT/bin"
[[ -z "$BUILD_TOOLS_ROOT" ]] && BUILD_TOOLS_ROOT="$CONTOOLS_ROOT/build"
[[ -z "$GNUWIN32_ROOT" ]] && GNUWIN32_ROOT="$CONTOOLS_ROOT/gnuwin32"
[[ -z "$SVNCMD_TOOLS_ROOT" ]] && SVNCMD_TOOLS_ROOT="$CONTOOLS_ROOT/scm/svn"
[[ -z "$SQLITE_TOOLS_ROOT" ]] && SQLITE_TOOLS_ROOT="$CONTOOLS_ROOT/sqlite"
[[ -z "$TESTLIB_ROOT" ]] && TESTLIB_ROOT="$CONTOOLS_ROOT/testlib"
[[ -z "$XML_TOOLS_ROOT" ]] && XML_TOOLS_ROOT="$CONTOOLS_ROOT/xml"
[[ -z "$HASHDEEP_ROOT" ]] && HASHDEEP_ROOT="$CONTOOLS_ROOT/hash/hashdeep"
[[ -z "$VARS_ROOT" ]] && VARS_ROOT="$CONTOOLS_ROOT/vars"

return 0

fi
