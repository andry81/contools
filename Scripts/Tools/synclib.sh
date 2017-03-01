#!/bin/bash_entry

# Script library to support synchronization operations.

# Script can be ONLY included by "source" command.
if [[ -n "$BASH" && (-z "$BASH_LINENO" || ${BASH_LINENO[0]} -gt 0) ]] && (( ! ${#SOURCE_CONTOOLS_SYNCLIB_SH} )); then

SOURCE_CONTOOLS_SYNCLIB_SH=1 # including guard

source "${TOOLS_PATH:-.}/traplib.sh"

function TryLockFn1()
{
  local PathToLockDir="$1"

  [[ -d "$PathToLockDir" ]] && return 2

  PushTrap "$DefaultTrapsStackName" UnlockFn1 EXIT || return 253

  # make the lock directory to emulate a mutex logic
  if mkdir "$PathToLockDir" 2>/dev/null; then
    # exclusively created and locked
    return 0
  fi

  PopTrap "$DefaultTrapsStackName" EXIT

  return 1
}

function UnlockFn1()
{
  local PathToLockDir="$1"

  # remove the lock directory
  rmdir "$PathToLockDir" 2>/dev/null
  local LastError=$?

  # restore trap
  PopTrap "$DefaultTrapsStackName" EXIT

  (( LastError )) || return 1

  return 0
}

function TryLockFn2()
{
  local PathToLockFile="$1"

  [[ -f "$PathToLockFile" ]] && return 2

  PushTrap "$DefaultTrapsStackName" UnlockFn2 EXIT || return 253

  # make the lock file to emulate a mutex logic
  if (set -C; >"$PathToLockFile") 2>/dev/null; then
    # exclusively created and locked
    return 0
  fi

  PopTrap "$DefaultTrapsStackName" EXIT

  return 1
}

function UnlockFn2()
{
  local PathToLockFile="$1"

  # remove the lock file
  rm -f "$PathToLockFile" 2>/dev/null
  local LastError=$?

  # restore trap
  PopTrap "$DefaultTrapsStackName" EXIT

  (( LastError )) || return 1

  return 0
}

unset SOURCE_CONTOOLS_SYNCLIB_SH # including guard unset

fi
