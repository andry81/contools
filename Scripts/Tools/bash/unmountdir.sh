#!/bin/bash

# Author:   Andrey Dibrov (andry at inbox dot ru)

# Bash script which unmounts directory in the Cygwin/Msys system.
# Cygwin/Msys system required.

# Examples:
# 1. unmountdir.sh /mingw [<PathTo>]
# 2. source "unmountdir.sh"
#    UnmountDir /mingw [<PathTo>]

if [[ -n "$BASH" ]]; then

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
tkl_include_or_abort "$CONTOOLS_ROOT/bash/baselib.sh"
tkl_include_or_abort "$CONTOOLS_ROOT/bash/traplib.sh"
tkl_include_or_abort "$CONTOOLS_ROOT/bash/stringlib.sh"

function UnmountDir()
{
  local MountPath="$1"
  local WindowsPath="$2"
  local MountSystem="${3:-$OSTYPE}"

  # drop return values
  RETURN_VALUES=()

  # remove trailing slash
  MountPath="${MountPath%/}"

  [[ -n "$MountPath" ]] || return 1
  [[ "${MountPath:0:1}" == '/' ]] || return 2

  local UnmountTool
  local BackendType=0

  if [[ "$MountSystem" == "msys" || "$MountSystem" == "mingw" ]]; then
    BackendType=1
    #UnmountTool="/bin/msysumnt.exe"
  elif [[ "$MountSystem" == "cygwin" ]]; then
    BackendType=2
    UnmountTool="/bin/umount.exe"
  else
    return 5 # unsupported backend type
  fi

  local EscapeChars
  local MountPathEscaped

  local FstabFile
  local LastError

  # enable nocase match for a file paths
  local oldShopt=""
  function LocalReturn()
  {
    if [[ -n "$oldShopt" ]]; then
      # Restore state
      eval $oldShopt
    fi
  }

  # override RETURN with other traps restore
  PushTrapFunctionMove "$DefaultTrapsStackName" LocalReturn RETURN || return 253

  oldShopt="$(shopt -p nocasematch)" # Read state before change
  if [[ "$oldShopt" != "shopt -s nocasematch" ]]; then
    shopt -s nocasematch
  else
    oldShopt=''
  fi

  local ReturnCode=127

  if [[ -f "/etc/fstab" ]]; then
    EscapeChars='.\()[]*+?^$&`|{}'

    EscapeString "$MountPath" "$EscapeChars"
    MountPathEscaped="$RETURN_VALUE"

    FstabFile="$(IFS=""; local PATH='/usr/local/bin:/usr/bin:/bin'; cat '/etc/fstab' | \
      /bin/perl.exe "$CONTOOLS_ROOT/sar.pl" s '(.*?)^[ \t]*[^\r\n]+[ \t]+'"$MountPathEscaped"'(?:[ \t]+[^\r\n]+?|[ \t]*)$\r?\n?(.*?)' '\1\2' ms; \
      LastError=$?; echo -n '.'; exit $LastError)"
    LastError=$?

    (( LastError )) && return 30

    # drop last character
    echo -n "${FstabFile:0:${#FstabFile}-1}" > "/etc/fstab"

    ReturnCode=0
  fi

  if [[ -n "$UnmountTool" && -x "$UnmountTool" ]]; then
    "$UnmountTool" "$MountPath" >/dev/null
    if (( ! $? )); then
      ReturnCode=0
    else
      ReturnCode=32
    fi
  fi

  RETURN_VALUES=("$MountPath" "$WindowsPath")

  return $ReturnCode
}

if [[ -z "$BASH_LINENO" || ${BASH_LINENO[0]} -eq 0 ]]; then
  # Script was not included, then execute it.
  UnmountDir "$@"
  exit $?
fi

fi
