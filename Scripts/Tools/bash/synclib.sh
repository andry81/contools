#!/bin/bash

# Script library to support synchronization operations.

# Script can be ONLY included by "source" command.
[[ -n "$BASH" && (-z "$BASH_LINENO" || BASH_LINENO[0] -gt 0) && (-z "$SOURCE_CONTOOLS_SYNCLIB_SH" || SOURCE_CONTOOLS_SYNCLIB_SH -eq 0) ]] || return 0 || exit 0 # exit to avoid continue if the return can not be called

SOURCE_CONTOOLS_SYNCLIB_SH=1 # including guard

if [[ -z "$SOURCE_TACKLELIB_BASH_TACKLELIB_SH" || SOURCE_TACKLELIB_BASH_TACKLELIB_SH -eq 0 ]]; then
  # builtin search
  for BASH_SOURCE_DIR in "/usr/local/bin" "/usr/bin" "/bin"; do
    [[ -f "$BASH_SOURCE_DIR/bash_tacklelib" ]] && {
      source "$BASH_SOURCE_DIR/bash_tacklelib" || exit $?
      break
    }
  done
fi

tkl_include_or_abort '__init__.sh'
tkl_include_or_abort "$CONTOOLS_ROOT/bash/traplib.sh"

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
