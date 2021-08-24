#!/bin/bash

# Author:   Andrey Dibrov (andry at inbox dot ru)

# Bash script for reading stdin/file to the variable CAT_BUFFER. This is useful
# if you want to add to stream additional characters, like terminating
# character to avoid trailing line return characters trucation by bash
# operators `` and $(). Cygwin/Mingw/Msys system required.

# Examples:
# 1. myvar="`source cat2.sh; ReadStream "myfile.txt"; echo -n "*$CAT_BUFFER*";`"
#    myvar="${myvar:1:${#myvar}-2}"
# 2. myvar="`source cat2.sh; ReadStream < "myfile.txt"; echo -n "*$CAT_BUFFER*";`"
#    myvar="${myvar:1:${#myvar}-2}"

if [[ -n "$BASH" ]]; then

function ReadStream()
{
  if [[ -n "$1" ]]; then
    local fileName="$1"
    local readStdin=0
  else
    local readStdin=1
  fi

  # Create or clear buffer variable.
  CAT_BUFFER=""

  # IFS="" - enables read whole string line into a single variable. 
  local IFS=""

  local stdinLine=""
  local doRead=1
  local minReadBlockSize=65536
  if [[ $readStdin -ne 0 ]]; then
    while [[ $doRead -ne 0 ]]; do
      read -r -n $minReadBlockSize stdinLine
      local LastError=$?

      if [[ $LastError -eq 0 ]]; then
        CAT_BUFFER="${CAT_BUFFER}$stdinLine"$'\n'
      else
        CAT_BUFFER="${CAT_BUFFER}$stdinLine"
        doRead=0
      fi
    done
  else
    {
      while [[ $doRead -ne 0 ]]; do
        read -r -n $minReadBlockSize stdinLine
        local LastError=$?

        if [[ $LastError -eq 0 ]]; then
          CAT_BUFFER="${CAT_BUFFER}$stdinLine"$'\n'
        else
          CAT_BUFFER="${CAT_BUFFER}$stdinLine"
          doRead=0
        fi
      done
    } < "$fileName"
  fi

  return 0
}

if [[ -z "$BASH_LINENO" || ${BASH_LINENO[0]} -eq 0 ]]; then
  # Script was not included, then execute it.
  ReadStream "$@"
  exit $?
fi

fi
