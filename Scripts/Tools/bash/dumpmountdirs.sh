#!/bin/bash

# Author:   Andrey Dibrov (andry at inbox dot ru)

# Bash script which dumps mounted directories in system.
# Cygwin/Msys system required.

# Examples:
# 1. dumpmountdirs.sh
# 2. source "dumpmountdirs.sh"
#    DumpMountDirs

if [[ -n "$BASH" ]]; then

function DumpMountDirs()
{
  # Drop return value
  RETURN_VALUE=""

  if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "mingw" ]]; then
    if [[ ! -f "/etc/fstab" ]]; then
      return 254
    fi

    {
      IFS=""

      local stdinLine=""
      local doRead=1
      while [[ $doRead -ne 0 ]]; do
        read -r stdinLine
        local LastError=$?

        # Clear comments.
        stdinLine="`echo -n "$stdinLine" | grep -E '^[^#][^#]*' | sed -e 's/\(^[^#][^#]*\).*/\1/g'`"

        if [[ $LastError -ne 0 ]]; then
          if [[ ! -z "$stdinLine" ]]; then
            RETURN_VALUE="$RETURN_VALUE$stdinLine"
          fi
          doRead=0
        else
          if [[ ! -z "$stdinLine" ]]; then
            RETURN_VALUE="$RETURN_VALUE$stdinLine"$'\n'
          fi
        fi
      done
    } < '/etc/fstab'
  elif [[ "$OSTYPE" == "cygwin" ]]; then
    RETURN_VALUE="`/bin/mount.exe -m 2>/dev/null`"
    return $?
  fi

  return 0
}

if [[ -z "$BASH_LINENO" || ${BASH_LINENO[0]} -eq 0 ]]; then
  # Script was not included, then execute it.
  DumpMountDirs "$@"
  LastError=$?
  [[ -z "$RETURN_VALUE" ]] || echo -n "$RETURN_VALUE"
  exit $LastError
fi

fi
