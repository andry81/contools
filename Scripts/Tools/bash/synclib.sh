#!/bin/bash

# Script library to support synchronization operations.

# Script can be ONLY included by "source" command.
[[ -z "$BASH" || (-n "$BASH_LINENO" && BASH_LINENO[0] -le 0) || (-n "$SOURCE_CONTOOLS_SYNCLIB_SH" && SOURCE_CONTOOLS_SYNCLIB_SH -ne 0) ]] && return

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

tkl_include '__init__.sh' || tkl_abort_include
tkl_include "$CONTOOLS_ROOT/bash/traplib.sh" || tkl_abort_include

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
