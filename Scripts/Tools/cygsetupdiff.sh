#!/bin/bash_entry

# Author:   Andrey Dibrov (andry at inbox dot ru)

# Script reads the first cygwin setup.ini file and extracts all requested
# packages including it's dependencies. Then reads the second cygwin setup.ini
# file and findout which found depencies is not found in that file. Then after
# that it prints all packages not found in the second file but found in the
# first.

# Command arguments:
# $1 - Path to the first setup.ini file.
# $2 - Path to the second setup.ini file.
# $3 - Path to the resulting setup.ini file generating by the first file:
# $4 .. $N - Package names requested for the extraction from the first file to
#      the second.

# Script ONLY for execution.
if [[ -n "$BASH" && (-z "$BASH_LINENO" || ${BASH_LINENO[0]} -eq 0) ]]; then

source "${CONTOOLS_ROOT:-.}/cygsetuplib.sh"

OverallBeginTime="$(date "+%s")"
CalculateCygSetupIniPackagesDiff "$@"
LastError=$?
OverallEndTime="$(date "+%s")"

(( OverallSpentTime=OverallEndTime-OverallBeginTime ))

echo "* Overall time spent: ${OverallSpentTime} sec"

exit $LastError

fi
