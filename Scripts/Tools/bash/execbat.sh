#!/bin/bash

# Author:   Andrey Dibrov (andry at inbox dot ru)

# Bash script for invoking Windows batch scripts. Cygwin/Mingw/Msys system
# required.

# Examples:
# 1. execbat.sh "echo 10"
# 2. source "execbat.sh"
#    ExecWindowsBatch "echo 10"

if [[ -n "$BASH" ]]; then

function ExecWindowsBatch()
{
  local ComSpecInternal="${COMSPEC//\\//}" # workaround for a "command not found" in the msys shell

  if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "mingw" ]]; then
    "$ComSpecInternal" '^/C' "($@)"

    return 0
  elif [[ "$OSTYPE" == "cygwin" ]]; then
    # Convert all back slashes to slashes (cygwin style).
    "$ComSpecInternal" '^/C' "($@)"

    return 0
  fi

  return 1
}

if [[ ${BASH_LINENO[0]} -eq 0 ]]; then
  # Script was not included, then execute it.
  ExecWindowsBatch "$@"
  exit $?
fi
 
fi
