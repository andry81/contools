#!/bin/bash

# Author:   Andrey Dibrov (andry at inbox dot ru)

# Bash script which mounts directory in the Cygwin/Msys system.
# Cygwin/Msys system required.

# Examples:
# 1. mountdir.sh /mingw 'C:\Mingw'
# 2. source "mountdir.sh"
#    MountDir /mingw 'C:\Mingw'

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
tkl_include_or_abort "$CONTOOLS_BASH_ROOT/baselib.sh"
tkl_include_or_abort "$CONTOOLS_BASH_ROOT/traplib.sh"
tkl_include_or_abort "$CONTOOLS_BASH_ROOT/filelib.sh"
tkl_include_or_abort "$CONTOOLS_BASH_ROOT/stringlib.sh"
tkl_include_or_abort "$CONTOOLS_BASH_ROOT/cygver.sh"

function MountDir()
{
  local WindowsPath="$1"
  local MountPath="$2"
  local MountSystem="${3:-$OSTYPE}"

  # drop return values
  RETURN_VALUES=()

  # remove trailing slash
  WindowsPath="${WindowsPath%[/\\]}"
  MountPath="${MountPath%[/\\]}"

  [[ -n "$WindowsPath" ]] || return 1
  [[ -n "$MountPath" ]] || return 2
  [[ "${MountPath:0:1}" == '/' ]] || return 3
  [[ -n "$MountSystem" ]] || MountSystem="$OSTYPE"

  # make native path canonical
  CanonicalNativePath "$WindowsPath" || return 4
  WindowsPath="$RETURN_VALUE"

  local MountTool
  local SleepTool="/bin/sleep"
  local BackendType=0

  if [[ "$MountSystem" == "msys" || "$MountSystem" == "mingw" ]]; then
    BackendType=1
    #MountTool="/bin/msysmnt.exe"
  elif [[ "$MountSystem" == "cygwin" ]]; then
    BackendType=2
    MountTool="/bin/mount.exe"
  else
    return 5 # unsupported backend type
  fi

  local CygverStr
  local CygverMajor
  local CygverMinor

  local IFS
  local i
  local j

  local CygwinVer_1_7_X=0
  local LastError

  local EscapeChars
  local WindowsPathEscaped
  local MountPathEscaped
  local MountRecordSuffix

  local FstabFile
  local MountRecord

  local WindowsSystemPath
  local ExtractedMountPath

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

  case "$BackendType" in
    1)
      # check white spaces in windows path and replace path by DOS path
      if [[ "${WindowsPath//[ $'\t']/}" != "$WindowsPath" ]]; then
        local ComSpecInternal="$COMSPEC" # workaround for a "command not found" in the msys shell
        # msys automatically converts argument to the native path if it begins from '/' character
        WindowsPath="`"$ComSpecInternal" '^/C' call "$CONTOOLS_ROOT"'\printdospath.bat' "$WindowsPath"`"
        if [[ -n "$WindowsPath" ]]; then
          WindowsPath="${WindowsPath:1:${#WindowsPath}-2}" # remove quotes
          # check DOS path on exists because is important that the DOS path is existing BEFORE the mounting
          if [[ ! -d "$WindowsPath" ]]; then
            echo "mountdir.sh: caution: the DOS mounted path is not existing at the moment, the mount is invalid.
mountdir.sh: info: \"$WindowsPath\"" >&2
          fi
        else
          WindowsPath=':' # just in case
        fi
      fi
    ;;

    2)
      # Check Cygwin version
      CygwinVer cygwin
      CygverStr="$RETURN_VALUE"
      CygverMajor=0
      CygverMinor=0

      IFS=$'.'
      j=0
      for i in $CygverStr; do
        if (( ! j )); then
          [[ -z "$i" ]] || CygverMajor="$i"
        elif (( j == 1 )); then
          [[ -z "$i" ]] || CygverMinor="$i"
        else
          break
        fi
        (( j++ ))
      done

      if (( CygverMajor >= 1 )); then
        if (( CygverMinor >= 7 )); then
          CygwinVer_1_7_X=1
        fi
      fi
    ;;
  esac

  # at first, mount it via native tool if has.

  if [[ -n "$MountTool" && -x "$MountTool" ]]; then
    # because a backend mounting system may be asynchronious, we required to check a mount path after mounting
    NormalizePath "$WindowsPath"
    if (( ! $? )); then
      WindowsSystemPath="$RETURN_VALUE"
      #echo "WindowsSystemPath=$WindowsSystemPath"

      ExtractBackendPath "$MountPath"
      if (( ! $? )); then
        ExtractedMountPath="$RETURN_VALUE"
        #echo "ExtractedMountPath=$ExtractedMountPath"

        # always try to mount before the check
        #echo "$MountTool" -f "$WindowsPath" "$MountPath"
        "$MountTool" -f "$WindowsPath" "$MountPath" >/dev/null
        if (( ! $? )); then
          # now waiting until the path will be resolved
          while (( 1 )); do
            ExtractBackendPath "$MountPath"
            if (( ! $? )); then
              ExtractedMountPath="$RETURN_VALUE"
              if [[ "$WindowsSystemPath" == "$ExtractedMountPath" ]]; then
                break
              else
                echo "!!!! MOUNT ASYNC WAITING !!!!" >&2
                echo "WindowsSystemPath=$WindowsSystemPath" >&2
                echo "ExtractedMountPath=$ExtractedMountPath" >&2
                "$SleepTool" 1 # emulation of an asynchronious wait
              fi
            else
              return 10
            fi
          done
        else
          return 11
        fi
      else
        return 12
      fi
    else
      return 13
    fi
  fi

  local ReturnCode=127

  if (( BackendType )); then
    # cygwin version lower than 1.7 does use the windows registry instead of the fstab file
    if (( BackendType != 2 || CygwinVer_1_7_X )); then
      [[ -f "/etc/fstab" ]] || echo "" > "/etc/fstab"
    fi

    # escapes for the regexp
    EscapeChars='.()[]*+?^$&`"|{}'

    EscapeString "$WindowsPath" '$`"'
    WindowsPathEscaped="${RETURN_VALUE//\\//}"

    EscapeString "$MountPath" "$EscapeChars"
    MountPathEscaped="$RETURN_VALUE"

    # at second, add a mount point to the storage
    if (( CygwinVer_1_7_X )); then
      # extract fstab records and reuse it's fields
      FstabFile="$("$MountTool" -m)"
      if (( ${#FstabFile} )); then
        MountRecord="$("$MountTool" -m | \
          /bin/perl.exe "$CONTOOLS_ROOT/sar.pl" m '^([ \t]*[^\r\n]+[ \t]+)'"$MountPathEscaped"'([ \t]+[^\r\n]+?|[ \t]*)$' '\1'"$MountPathEscaped"'\2' ms;)"
        LastError=$?
      else
        return 20
      fi

      # replace whitespaces in the windows path by "\040" sequence for the cygwin 1.7.X and higher
      WindowsPathEscaped="${WindowsPathEscaped//[ $'\t']/\\\\040}"

      EscapeString "${MountRecord##*$MountPathEscaped[ \t]}" '$\`"'
      MountRecordSuffix="$RETURN_VALUE"
    fi

    if [[ -f "/etc/fstab" ]]; then
      FstabFile="$(IFS=""; PATH='/usr/local/bin:/usr/bin:/bin'; cat '/etc/fstab')"
      if (( ${#FstabFile} )); then
        # Replace mount point in existed mount path.
        FstabFile="$(IFS=""; PATH='/usr/local/bin:/usr/bin:/bin'; cat '/etc/fstab' | \
          /bin/perl.exe "$CONTOOLS_ROOT/sar.pl" s '(.*?^[ \t]*)[^\r\n]+[ \t]+'"$MountPathEscaped"'(?:[ \t]+[^\r\n]+?|[ \t]*)$(.*?)' '\1'"$WindowsPathEscaped $MountPathEscaped${MountRecordSuffix:+ }$MountRecordSuffix"'\2' ms; \
          LastError=$?; echo -n '.'; exit $LastError)"
        LastError=$?

        if (( LastError )); then
          # Mount path is not replaced because not matched (not existed), then try to append to the end of list of printable string lines.
          FstabFile="$(IFS=""; PATH='/usr/local/bin:/usr/bin:/bin'; cat '/etc/fstab' | \
            /bin/perl.exe "$CONTOOLS_ROOT/sar.pl" s '(.*?[ \t]*[^\r\n]+(?:[ \t]+[^\r\n]+)?)\r?\n?([ \t\r\n]*)$' '\1'$'\n'"$WindowsPathEscaped $MountPathEscaped${MountRecordSuffix:+ }$MountRecordSuffix"$'\n''\2' s; \
            LastError=$?; echo -n '.'; exit $LastError)"
          LastError=$?
        fi

        (( LastError )) && return 30

        # drop last character
        FstabFile="${FstabFile:0:${#FstabFile}-1}"

        (( ${#FstabFile} )) || return 31

        echo -n "$FstabFile" > "/etc/fstab"
      else
        echo "$WindowsPathEscaped $MountPathEscaped${MountRecordSuffix:+ }$MountRecordSuffix" > "/etc/fstab"
      fi
    fi

    ReturnCode=0
  fi

  RETURN_VALUES=("$MountPath" "$WindowsPath")

  return $ReturnCode
}

if [[ -z "$BASH_LINENO" || ${BASH_LINENO[0]} -eq 0 ]]; then
  # Script was not included, then execute it.
  MountDir "$@"
  exit $?
fi

fi
