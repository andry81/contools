#!/bin/bash

# Author:   Andrey Dibrov (andry at inbox dot ru)

# Script prints fields of found packages.

# Command arguments:
# $1 - Path to the setup.ini file.
# $2 - Package section (for example, "prev" or "").
# $3 - Field name (for example, "install" or "requires").
# $4 .. $N - Package names requested for the search.

# Script ONLY for execution.
if [[ -n "$BASH" && (-z "$BASH_LINENO" || ${BASH_LINENO[0]} -eq 0) ]]; then

if [[ -z "$SOURCE_TACKLELIB_BASH_TACKLELIB_SH" || SOURCE_TACKLELIB_BASH_TACKLELIB_SH -eq 0 ]]; then
  # builtin search
  for BASH_SOURCE_DIR in "/usr/local/bin" "/usr/bin" "/bin"; do
    [[ -f "$BASH_SOURCE_DIR/bash_tacklelib" ]] && {
      source "$BASH_SOURCE_DIR/bash_tacklelib" || exit $?
      break
    }
  done
fi

tkl_include_or_abort 'cygsetuplib.sh'

PrintPackageFieldFromCygSetupIni "$@"
exit $?

fi
