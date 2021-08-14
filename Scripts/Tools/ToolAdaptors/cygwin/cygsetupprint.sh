#!/bin/bash_entry

# Author:   Andrey Dibrov (andry at inbox dot ru)

# Script prints fields of found packages.

# Command arguments:
# $1 - Path to the setup.ini file.
# $2 - Package section (for example, "prev" or "").
# $3 - Field name (for example, "install" or "requires").
# $4 .. $N - Package names requested for the search.

# Script ONLY for execution.
if [[ -n "$BASH" && (-z "$BASH_LINENO" || ${BASH_LINENO[0]} -eq 0) ]]; then

source '/bin/bash_entry' || exit $?
tkl_include 'cygsetuplib.sh' || tkl_abort_include

PrintPackageFieldFromCygSetupIni "$@"
exit $?

fi
