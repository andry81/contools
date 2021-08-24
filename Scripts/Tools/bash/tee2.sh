#!/bin/bash

# Author:   Andrey Dibrov (andry at inbox dot ru)

# Bash script for redirecting stdin to both stdout and stderr or one of
# the auxiliary streams (if first parameter has been set) at a time.
# Cygwin/Mingw/Msys system required.

# Examples:
# 1. echo 10 | tee2.sh
# 2. echo 10 | tee2.sh -6 6>&2
# 3. source "tee2.sh"
#    echo 10 | SplitPipeToStream
#    echo 20 | SplitPipeToStream -6 6>&2
#    echo 30 | SplitPipeToStream -6 s 6>&2

if [[ -n "$BASH" ]]; then

function SplitPipeToStream()
{
  if [[ -n "$1" ]]; then
    local auxnum="${1:1}"
  else
    local auxnum=2
  fi
  if [[ "$2" == "s" ]]; then
    local doSwap=1
  else
    local doSwap=0
  fi

  if [[ -z "$auxnum" || $auxnum -lt 2 || $auxnum -gt 255 ]]; then
    auxnum=2
  fi

  # IFS="" - enables read whole string line into a single variable. 
  local IFS=""

  local stdinLine
  local doRead=1
  if [[ $doSwap -eq 0 ]]; then
    # Use "read" instead "cat" to do not block piping.
    while [[ $doRead -ne 0 ]]; do
      read -r stdinLine
      local LastError=$?

      if [[ $LastError -eq 0 ]]; then
        echo "$stdinLine"
        eval 'echo "$stdinLine" >&'$auxnum
      else
        echo -n "$stdinLine"
        eval 'echo -n "$stdinLine" >&'$auxnum
        doRead=0
      fi
    done
  else
    # Use "read" instead "cat" to do not block piping.
    while [[ $doRead -ne 0 ]]; do
      read -r stdinLine
      local LastError=$?

      if [[ $LastError -eq 0 ]]; then
        eval 'echo "$stdinLine" >&'$auxnum
        echo "$stdinLine"
      else
        eval 'echo -n "$stdinLine" >&'$auxnum
        echo -n "$stdinLine"
        doRead=0
      fi
    done
  fi

  return 0
}

if [[ -z "$BASH_LINENO" || ${BASH_LINENO[0]} -eq 0 ]]; then
  # Script was not included, then execute it.
  SplitPipeToStream "$@"
  exit $?
fi

fi
