#!/bin/bash

# Author:   Andrey Dibrov (andry at inbox dot ru)

# Bash file library, supports common file functions.

# Script can be ONLY included by "source" command.
[[ -n "$BASH" && (-z "$BASH_LINENO" || BASH_LINENO[0] -gt 0) && (-z "$SOURCE_CONTOOLS_FILELIB_SH" || SOURCE_CONTOOLS_FILELIB_SH -eq 0) ]] || return 0 || exit 0 # exit to avoid continue if the return can not be called

SOURCE_CONTOOLS_FILELIB_SH=1 # including guard

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
tkl_include_or_abort "$TACKLELIB_BASH_ROOT/tacklelib/baselib.sh"
tkl_include_or_abort "$CONTOOLS_BASH_ROOT/traplib.sh"
tkl_include_or_abort "$CONTOOLS_BASH_ROOT/stringlib.sh"
tkl_include_or_abort "$CONTOOLS_BASH_ROOT/regexplib.sh"

function BufferedRead()
{
  local bufSize="$1"
  local bufVarName="$2"
  local bufStateArrayName="$3"

  # update buffer state
  eval "$bufStateArrayName[0]=0"

  local IFS='' # enables read whole string line into a single variable
  read -n "$bufSize" -r -d '' "$bufVarName"
  eval "(( \${#$bufVarName} == bufSize ))" && return 0
  return 1
}

# Return codes:
#  0 - no EOF, buffer line has characters terminates by the line split string.
#  1 - EOF, buffer line has characters terminated by EOF or by split string
#      which itself early-terminated by EOF.
# Details:
#  The buffer state has format:
#    [0] - buffer position index after last line read.
#    [1] - beginning of a line in the buffer after last line read.
#    [2] - length of a line in the buffer after last line read.
#    [3] - number of the line split string characters read before the next line
#          or before the EOF if the line split string was early-terminated by
#          the EOF.
#  For example, if the last line of a file is not terminate by the line split
#  string characters, then the [3] buffer state would be 0 and the function
#  would return 1. In another case, if the last line of a file is terminated by
#  a beginning of the line split string and the EOF after, then the [3] buffer
#  state would be a length of a beginning of the line split string before the
#  EOF and the function still would return 1. In all other cases where the line
#  split string completely read after the line, the [3] buffer state would be
#  full length of the line split string and the function would return 0.
#  WARNING:
#  1. Because the line split string could be longer than 1 character, then
#     it could be early-terminated by the EOF, so you could gain the line split
#     string characters as a part of the line. To intercept that case you need
#     to check the [3] buffer state after each buffer line read. If it is not
#     equal to 0 or length of the line split string then in the next buffer line
#     read a beginning of the line would contain an ending characters of the
#     line split string!
#  2. The function does not trace the order of a characters in the line split
#     string if the line split string longer than 1 character, so it is only a
#     user responsibility to control it order. For example, if the line split
#     string is a sequence of the "\n\r", then a sequence of the "\r\n" does
#     NOT treat as the line split string and the "\r" character will append
#     to the end of the line, but the "\n" character will append too only if no
#     the "\r" character or the EOF after it.
#
# EXAMPLE OF USAGE: BufferedRead+BufferedReadLine+BufferedEcho+FlushEchoBuffer:
#  BufferedReadError=0
#  BufferedLineReadError=0
#  stdoutBuf=""
#  stdinBuf=""
#  stdinLine=""
#  bufStateArray=(0)
#
#  DoReadBuf=1
#  while (( DoReadBuf )); do
#    BufferedRead 512 stdinBuf bufStateArray
#    BufferedReadError=$?
#
#    DoReadBufLines=1
#    while (( DoReadBufLines )); do
#      BufferedReadLine stdinBuf bufStateArray
#      BufferedLineReadError=$?
#
#      BufferedEcho stdoutBuf 512 "${stdinBuf:${bufStateArray[1]}:${bufStateArray[2]}}"
#      if (( ${bufStateArray[3]} )); then
#        BufferedEcho stdoutBuf 512 $'\n'
#      fi
#
#      (( ! BufferedLineReadError )) || DoReadBufLines=0
#    done
#
#    (( ! BufferedReadError )) || DoReadBuf=0
#  done
#  FlushEchoBuffer stdoutBuf

function BufferedReadLine()
{
  local bufVarName="$1"
  local bufStateArrayName="$2"
  local lineSplitStr="${3-$'\n'}"
  local lineSplitStrLen="${#lineSplitStr}"

  local IFS=$' \t'

  eval declare "bufSize=\"\${#$bufVarName}\""

  # read buffer state from array
  eval declare "bufPos=\"\${$bufStateArrayName[0]:-0}\""

  local i
  local subStr
  for (( i=bufPos; i<bufPos+bufSize; i++ )); do
    eval "subStr=\"\${$bufVarName:\$i:\$lineSplitStrLen}\""
    case "$subStr" in
      "$lineSplitStr")
        # complete line read w/o EOF hit
        eval "$bufStateArrayName=(\"\$((i+lineSplitStrLen))\" \
          \"\$bufPos\" \"\$((i-bufPos))\" \"\$lineSplitStrLen\")"

        return 0
      ;;

      *)
        if (( ${#subStr} < lineSplitStrLen )); then
          case "$lineSplitStr" in
            "$subStr"*)
              # the line split string early-terminated by the EOF
              eval "$bufStateArrayName=(\"\$((i+\${#subStr}))\" \
                \"\$bufPos\" \"\$((i-bufPos))\" \"\${#subStr}\")"
              return 1
            ;;
          esac
        fi
      ;;
    esac
  done

  # EOF
  eval "$bufStateArrayName=(\"\$i\" \"\$bufPos\" \"\$bufSize\" 0)"

  return 1
}

function BufferedEcho()
{
  local bufVarName="$1"
  local bufMaxSize="$2"
  local outputText="$3"
  local outputTextLen="${#outputText}"

  eval declare "bufSize=\"\${#$bufVarName}\""

  if (( bufMaxSize >= bufSize+outputTextLen )); then
    eval "$bufVarName=\"\$$bufVarName\$outputText\""
    return 0
  fi

  eval echo -n "\"\$$bufVarName\""
  local LastError=$?

  if (( bufMaxSize >= outputTextLen )); then
    eval "$bufVarName=\"\$outputText\""
  else
    echo -n "$outputText"
    (( ! bufSize )) || eval "$bufVarName=''"
  fi

  return $LastError
}

function FlushEchoBuffer()
{
  local bufVarName="$1"

  eval declare "bufSize=\"\${#$bufVarName}\""
  if (( bufSize )) ; then
    eval echo -n "\"\$$bufVarName\""
    eval "$bufVarName=''"
    return 0
  fi

  return 1
}

function GetFilePath()
{
  # drop return value
  RETURN_VALUE=""

  local FilePathLink="$1"

  [[ -n "$FilePathLink" ]] || return 1

  case "$OSTYPE" in
    "msys") local WhichUtility='/bin/which' ;;
    *) local WhichUtility='/bin/which.exe' ;;
  esac

  local FilePathLinkFileName="${FilePathLink##*[/\\]}"
  if [[ "$FilePathLinkFileName" == "$FilePathLink" ]]; then
    # file path link is file name. Search file name in search paths
    RETURN_VALUE="`"$WhichUtility" "$FilePathLinkFileName" 2>/dev/null`"
  else
    # convert before call to readlink!
    ConvertNativePathToBackend "$FilePathLink"
  fi

  [[ ! -f "$RETURN_VALUE" ]] || return 0

  # file name is not found in search paths, construct absolute file path from file name
  RETURN_VALUE="`/bin/readlink.exe -m "$FilePathLink"`"
  if [[ ! -f "$RETURN_VALUE" ]]; then
    # still is not found, return input path link
    RETURN_VALUE="$FilePathLink"
    return 1
  fi

  return 0
}

function GetAbsolutePathFromDirPath()
{
  # drop return value
  RETURN_VALUE=""

  local DirPath="$1"
  local RelativePath="$2"

  # drop line returns
  DirPath="${DirPath//[$'\r\n']}" 
  RelativePath="${RelativePath//[$'\r\n']}" 

  # WORKAROUND:
  #   Because some versions of readlink can not handle windows native absolute
  #   paths correctly, then always try to convert directory path to a backend
  #   path before the readlink in case if the path has specific native path
  #   characters.
  if [[ "${DirPath:1:1}" == ":" ]]; then
    ConvertNativePathToBackend "$DirPath"
    DirPath="$RETURN_VALUE"
  fi

  if [[ -n "$DirPath" ]]; then
    if [[ -x "/bin/readlink" ]]; then
      if [[ "${RelativePath:0:1}" != '/' ]]; then
        RETURN_VALUE="$(/bin/readlink -m "$DirPath${RelativePath:+/}$RelativePath")"
      else
        RETURN_VALUE="$(/bin/readlink -m "$RelativePath")"
      fi
    else
      return 1
    fi
  else
    return 2
  fi
}

function ConvertBackendPathToNative()
{
  # cygwin/msys2 uses cygpath command to convert paths
  # msys/mingw uses old style conversion through the "cmd.exe ^/C" call

  # drop return value
  RETURN_VALUE="$1"

  local LastError=0
  local PathToConvert="$1"
  local Flags="$2"

  local ConvertedPath=""

  if [[ "${Flags/i/}" != "$Flags" ]]; then
    # w/ user mount points bypassing
    ExctractPathIgnoringUserMountPoints -w "$PathToConvert"
    LastError=$?
  fi

  if [[ "${Flags/s/}" != "$Flags" ]]; then
    # convert backslashes to slashes
    RETURN_VALUE="${RETURN_VALUE//\\//}"
  fi

  if [[ "${Flags/i/}" != "$Flags" ]]; then
    return $LastError
  fi

  [[ -n "$PathToConvert" ]] || return 1

  GetAbsolutePathFromDirPath "$PathToConvert" || return 2

  case "$OSTYPE" in
    msys* | mingw*)
      while true; do
        # in msys2 and higher we must use /bin/cygpath.exe to convert the path
        if [[ "$OSTYPE" == "msys" && -f "/bin/cygpath.exe" ]]; then
          ConvertedPath="`/bin/cygpath.exe -w "$RETURN_VALUE"`"
          break
        fi
        local ComSpecInternal="${COMSPEC//\\//}" # workaround for a "command not found" in the msys shell
        # msys replaces mount point path properly if it ends by '/' character
        RETURN_VALUE="${RETURN_VALUE%/}/"
        EscapeString "$RETURN_VALUE" '' 2
        # msys automatically converts argument to the native path if it begins from '/' character
        ConvertedPath="`"$ComSpecInternal" '^/C' \(echo $RETURN_VALUE\)`"
        break
      done
    ;;

    cygwin*)
      ConvertedPath="`/bin/cygpath.exe -w "$RETURN_VALUE"`"
    ;;

    *)
      if [[ "${Flags/s/}" != "$Flags" ]]; then
        # convert backslashes to slashes
        RETURN_VALUE="${RETURN_VALUE//\\//}"
      fi

      return 0
    ;;
  esac

  # remove last slash
  ConvertedPath="${ConvertedPath%[/\\]}"

  if [[ "${Flags/s/}" != "$Flags" ]]; then
    # convert backslashes to slashes
    RETURN_VALUE="${ConvertedPath//\\//}"
  else
    # convert all slashes to backward slashes
    RETURN_VALUE="${ConvertedPath//\//\\}"
  fi

  return 0
}

function ConvertNativePathToBackend()
{
  # drop return value
  RETURN_VALUE="$1"

  # Convert all back slashes to slashes.
  local PathToConvert="${1//\\//}"

  [[ -n "$PathToConvert" ]] || return 1

  # workaround for the bash 3.1.0 bug for the expression "${arg:X:Y}",
  # where "Y == 0" or "Y + X >= ${#arg}"
  local PathToConvertLen=${#PathToConvert}
  local PathPrefixes=('' '')
  local PathSuffix=""
  if (( PathToConvertLen > 0 )); then
    PathPrefixes[0]="${PathToConvert:0:1}"
  fi
  if (( PathToConvertLen > 1 )); then
    PathPrefixes[1]="${PathToConvert:1:1}"
  fi
  if (( PathToConvertLen >= 3 )); then
    PathSuffix="${PathToConvert:2}"
    PathSuffix="${PathSuffix%/}"
  fi

  # Convert path drive prefix too.
  if [[ "${PathPrefixes[0]}" != '/' && "${PathPrefixes[0]}" != '.' && "${PathPrefixes[1]}" == ':' ]]; then
    case "$OSTYPE" in
      cygwin*) PathToConvert="/cygdrive/${PathPrefixes[0]}$PathSuffix" ;;
      *)
        PathToConvert="/${PathPrefixes[0]}$PathSuffix"
        # add slash to the end of path in case of drive only path
        (( ! ${#PathSuffix} )) && PathToConvert="$PathToConvert/"
      ;;
    esac
  fi

  RETURN_VALUE="$PathToConvert"

  return 0
}

function ConvertNativePathListToBackend()
{
  # drop return value
  RETURN_VALUE="$1"

  local PathListToConvert="$1"

  [[ -n "$PathListToConvert" ]] || return 1

  # Convert all back slashes to slashes.
  local ConvertedPathList="${PathListToConvert//\\//}"

  # workaround for the bash 3.1.0 bug for the expression "${arg:X:Y}",
  # where "Y == 0" or "Y + X >= ${#arg}"
  local PathToConvertLen
  local PathPrefixes=('' '')
  local PathSuffix=""

  local arg
  local IFS=';'
  for arg in $ConvertedPathList; do
    PathToConvertLen=${#arg}
    if (( PathToConvertLen > 0 )); then
      PathPrefixes[0]="${arg:0:1}"
    fi
    if (( PathToConvertLen > 1 )); then
      PathPrefixes[1]="${arg:1:1}"
    fi
    if (( PathToConvertLen >= 3 )); then
      PathSuffix="${arg:2}"
    fi

    # Convert path drive prefix too.
    if [[ "${PathPrefixes[0]}" != '/' && "${PathPrefixes[0]}" != '.' && "${PathPrefixes[1]}" == ':' ]]; then
      case "$OSTYPE" in
        cygwin*) RETURN_VALUE="$RETURN_VALUE${RETURN_VALUE:+:}/cygdrive/${PathPrefixes[0]}${PathSuffix}" ;;
        *) RETURN_VALUE="$RETURN_VALUE${RETURN_VALUE:+:}/${PathPrefixes[0]}${PathSuffix}" ;;
      esac
    else
      RETURN_VALUE="$RETURN_VALUE${RETURN_VALUE:+${arg:+:}}$arg"
    fi
  done

  return 0
}

function RemoveRelativePathsFromPathListVariable()
{
  local VarName="$1"
  eval local "Var=\"\$$VarName\""

  local NewPaths
  local arg

  # remove relative paths from search paths
  local IFS=':'
  for arg in $Var; do
    if [[ "${arg:0:1}" == '/' ]]; then
      NewPaths="$NewPaths${NewPaths:+${arg:+:}}$arg"
    fi
  done

  eval "$VarName=\"\$NewPaths\""
}

# Extracts real backend path with mount points application.
# Useful before call to "mkdir -p" which could create nesting directories
# by wrong address. For example, if call "mkdir -p /usr/local/install/blabla"
# and "/usr/local/install/blabla" is mounted somewhere, then it creates
# subdirectories not upto mount point but as is from the root - "/".
function ExtractBackendPath()
{
  # Trick it with convertion to native path and back
  ConvertBackendPathToNative "$1" && ConvertNativePathToBackend "$RETURN_VALUE"
}

function CanonicalNativePath()
{
  # Trick it with convertion to backend path and back w/ bypassing user mount
  # points
  ConvertNativePathToBackend "$1" && ConvertBackendPathToNative "$RETURN_VALUE" -i
}

# the same as ExtractBackendPath, but bypassing user mount points table except
# builtin mounts
function ExctractPathIgnoringUserMountPoints()
{
  # Splits the path into 2 paths by exracting builtin paths from the beginning of
  # the path in this order:
  # "/usr/bin" => "/usr/lib" => "/usr" => "/lib" => "/<drive>/" => "/"
  # That is because, the Cygwin backend has the redirection of
  # "/usr/bin" and "/usr/lib" into "/bin" and "/lib" paths respectively, but
  # doesn't has the redirection of the "/usr" itself, when the Msys backend has
  # the redirection of the "/usr" path to the "/" but does not has for the
  # "/usr/bin" path.

  # Examples:
  # 1. path=/usr/bin       => prefix=/usr/bin/    suffix=
  # 2. path=/usr/lib       => prefix=/usr/lib/    suffix=
  # 3. path=/usr           => prefix=/usr/        suffix=
  # 4. path=/lib           => prefix=/lib/        suffix=
  # 5. path=/usr/local/bin => prefix=/usr/        suffix=local/bin
  # 6. path=/tmp           => prefix=/            suffix=tmp
  # Specific to Msys behaviour:
  # 7. path=/c/            => prefix=/c/          suffix=
  # 8. path=/c             => prefix=/            suffix=c
  # Specific to Cygwin behaviour:
  # 9. path=/cygdrive/c    => prefix=/cygdrive/c  suffix=

  local Flags="$1"
  if [[ "${Flags:0:1}" == '-' ]]; then
    shift
  else
    Flags=''
  fi
  local PathToConvert="$1"

  # drop return value
  RETURN_VALUE=""

  (( ${#PathToConvert} )) || return 1

  local DoConvertToBackendTypePath=1
  if [[ "${Flags//w/}" != "$Flags" ]]; then
    DoConvertToBackendTypePath=0 # convert to native path
  elif [[ "${Flags//b/}" != "$Flags" ]]; then # explicit flag
    DoConvertToBackendTypePath=1 # convert to backend path
  fi

  # enable nocase match
  local oldShopt=""
  function LocalReturn()
  {
    if [[ -n "$oldShopt" ]]; then
      # Restore state
      eval $oldShopt
    fi
    unset -f "${FUNCNAME[0]}" # drop function after execution
  }

  # override RETURN with other traps restore
  PushTrapFunctionMove "$DefaultTrapsStackName" LocalReturn RETURN || return 253

  oldShopt="$(shopt -p nocasematch)" # Read state before change
  if [[ "$oldShopt" != "shopt -s nocasematch" ]]; then
    shopt -s nocasematch
  else
    oldShopt=''
  fi

  # The case patterns w/o * ending character.
  # If / character at the end then it is required.
  local PathPrefixes=(/usr/bin /usr/lib /usr /lib '/[a-zA-Z]/' '/cygdrive/[a-zA-Z]' /)

  local PathPrefix
  local PathSuffix

  local IsFound=0

  for PathPrefix in "${PathPrefixes[@]}"; do
    PathSuffix="${PathToConvert#$PathPrefix}"
    if [[ "$PathSuffix" != "$PathToConvert" ]] &&
       [[ -z "$PathSuffix" || "${PathSuffix:0:1}" == '/' || "${PathPrefix%/}" != "$PathPrefix" ]]; then
      IsFound=1
      PathPrefix="${PathToConvert%$PathSuffix}"
      break
    fi
  done

  if (( ! IsFound )); then
    PathPrefix="$PWD" # current path as base if builtin is not found
    PathSuffix="$PathToConvert"
  fi

  PathPrefix="${PathPrefix%/}/" # forward slash at the end
  PathSuffix="${PathSuffix#/}"  # no forward slash at the begin
  PathSuffix="${PathSuffix%/}"  # no forward slash at the end

  local ConvertedPath

  # bypassing mounting points
  case "$OSTYPE" in
    msys* | mingw*)
      while true; do
        # in msys2 and higher we must use /bin/cygpath.exe to convert the path
        if [[ "$OSTYPE" == "msys" && -f "/bin/cygpath.exe" ]]; then
          ConvertedPath="`/bin/cygpath.exe -w "$RETURN_VALUE"`"
          break
        fi
        local ComSpecInternal="${COMSPEC//\\//}" # workaround for a "command not found" in the msys shell
        # msys replaces mount point path properly if it ends by '/' character
        RETURN_VALUE="${PathPrefix%/}/"
        EscapeString "$RETURN_VALUE" '' 2
        # msys automatically converts argument to the native path if it begins from '/' character
        ConvertedPath="$("$ComSpecInternal" '^/C' \(echo $RETURN_VALUE\))"
        break
      done
      ;;

    cygwin*)
      ConvertedPath="`/bin/cygpath.exe -w "$PathPrefix"`"
      ;;

    *)
      RETURN_VALUE="${PathPrefix%/}${PathSuffix:+/}$PathSuffix"
      return 0
      ;;
  esac

  # remove last slash
  ConvertedPath="${ConvertedPath%[/\\]}"
  # convert to declared path type with replacemant of all backward slashes
  if (( DoConvertToBackendTypePath )); then
    ConvertNativePathToBackend "${ConvertedPath//\//\\}" || return 3
    RETURN_VALUE="$RETURN_VALUE${PathSuffix:+/}$PathSuffix"
  else
    RETURN_VALUE="${ConvertedPath//\\//}${PathSuffix:+/}$PathSuffix"
  fi

  return 0
}

function GetRelativePathFromAbsolutePaths()
{
  # drop return value
  RETURN_VALUE=""

  local LastError
  local AbsolutePath="$1"
  local AbsoluteFromPath="$2"
  local AbsolutePathDiff
  local AbsoluteFromDiff
  local arg

  if (( ${#AbsolutePath} )) && [[ "${AbsolutePath:0:1}" != '/' ]]; then
    GetAbsolutePathFromDirPath "$AbsolutePath"
    AbsolutePath="$RETURN_VALUE"
  fi

  if (( ${#AbsoluteFromPath} )) && [[ "${AbsoluteFromPath:0:1}" != '/' ]]; then
    GetAbsolutePathFromDirPath "$AbsoluteFromPath"
    AbsoluteFromPath="$RETURN_VALUE"
  fi

  AbsolutePathDiff="${AbsolutePath#/}"
  AbsoluteFromDiff="${AbsoluteFromPath#/}"

  local ch
  local hasCommonPath=0

  local IFS=$'\r\n' # enables string split only by line return characters and non printable characters may become part of name
  for arg in ${AbsolutePathDiff//\//$'\n'}; do
    [[ -n "$arg" && -n "$AbsoluteFromDiff" ]] || break
    ch="${AbsoluteFromDiff:${#arg}:1}"
    if [[ "${AbsoluteFromDiff:0:${#arg}}" == "$arg" && ( -z "$ch" || "$ch" == '/' ) ]]; then
      AbsolutePathDiff="${AbsolutePathDiff:${#arg}+1}"
      AbsoluteFromDiff="${AbsoluteFromDiff:${#arg}+1}"
      hasCommonPath=1
    else
      break
    fi
  done
  if (( hasCommonPath )); then
    RETURN_VALUE=""
    for arg in ${AbsoluteFromDiff//\//$'\n'}; do
      [[ -n "$arg" ]] || break
      RETURN_VALUE="$RETURN_VALUE${RETURN_VALUE:+/}.."
    done
    RETURN_VALUE="$RETURN_VALUE${RETURN_VALUE:+${AbsolutePathDiff:+/}}$AbsolutePathDiff"
  else
    RETURN_VALUE="/$AbsolutePathDiff"
  fi
  RETURN_VALUE="${RETURN_VALUE%/}"

  return 0
}

function NormalizePath()
{
  # drop return value
  RETURN_VALUE=""

  local InputPath="$1"

  # Convert native path to backend path before call to the readlink.
  ConvertNativePathToBackend "$InputPath" || return 1

  # Normalization through "readlink.exe" utility, path may not exist.
  RETURN_VALUE="`/bin/readlink.exe -m "$RETURN_VALUE"`"

  return 0
}

function GetExitingFilePaths()
{
  # drop return value
  RETURN_VALUE=()

  local FromPath="$1"
  shift
  local FilePath
  for FilePath in "$@"; do
    if [[ "${FilePath:0:1}" != "/" ]]; then
      [[ -f "$FromPath${FromPath:+${FilePath:+/}}$FilePath" ]] && RETURN_VALUE[${#RETURN_VALUE[@]}]="$FilePath"
    else
      [[ -f "$FilePath" ]] && RETURN_VALUE[${#RETURN_VALUE[@]}]="$FilePath"
    fi
  done
}

function GetExitingPaths()
{
  # drop return value
  RETURN_VALUE=()

  local FromPath="$1"
  shift
  local FilePath
  for FilePath in "$@"; do
    if [[ "${FilePath:0:1}" != "/" ]]; then
      [[ -f "$FromPath${FromPath:+${FilePath:+/}}$FilePath" || \
        -d "$FromPath${FromPath:+${FilePath:+/}}$FilePath" ]] && RETURN_VALUE[${#RETURN_VALUE[@]}]="$FilePath"
    else
      [[ -f "$FilePath" || -d "$FilePath" ]] && RETURN_VALUE[${#RETURN_VALUE[@]}]="$FilePath"
    fi
  done
}

function ReadFileToVar()
{
  local FilePath="$1"
  local VarName="$2"

  [[ -n "$VarName" ]] || return 1

  # drop variable value
  eval "$VarName=''"

  GetFilePath "$FilePath"
  FilePath="$RETURN_VALUE"

  [[ -f "$FilePath" ]] || return 2

  eval "$VarName=\"`IFS=''; cat \"\$FilePath\"`\""

  return 0
}

function MakeCommandArgumentsFromFile()
{
  # drop return value
  RETURN_VALUE=""

  local FilePath="$1"
  local DoEval="${2:-0}"

  if [[ "$FilePath" != '-' ]]; then
    FilePath="`/bin/readlink.exe -m "$FilePath"`"
    [[ -f "$FilePath" ]] || return 1
  fi

  local ConfigString=""

  function InternalRead()
  {
    local i
    local ConfigLine=""
    local IgnoreLine=0
    local IsEscapedSequence=0
    local ConfigLineLen

    local IFS='' # enables read whole string line into a single variable

    while read -r ConfigLine; do
      IsEscapedSequence=0
      IgnoreLine=0
      ConfigLineLen="${#ConfigLine}"
      for (( i=0; i<ConfigLineLen; i++ )); do
        case "${ConfigLine:i:1}" in
          $'\n') ;;
          $'\r') ;;

          \\)
            if (( ! IsEscapedSequence )); then
              IsEscapedSequence=1
            else
              IsEscapedSequence=0
            fi
            ;;

          \#)
            if (( ! IsEscapedSequence )); then
              IgnoreLine=1
              ConfigLine="${ConfigLine:0:i}"
              break
            else
              IsEscapedSequence=0
            fi
            ;;

          *)
            (( ! IsEscapedSequence )) || IsEscapedSequence=0
            ;;
        esac
        (( ! IgnoreLine )) || break
      done

      ConfigLine="${ConfigLine#"${ConfigLine%%[^[:space:]]*}"}" # remove beginning whitespaces
      ConfigLine="${ConfigLine%"${ConfigLine##*[^[:space:]]}"}" # remove ending whitespaces
      # remove last backslash
      if (( ${#ConfigLine} )) && [[ "${ConfigLine:${#ConfigLine}-1:1}" == '\' ]]; then #'
        ConfigLine="${ConfigLine:0:${#ConfigLine}-1}"
      fi
      if [[ -n "$ConfigLine" ]]; then
        if (( DoEval )); then
          EscapeString "$ConfigLine" '"' 0
          eval ConfigLine=\"$RETURN_VALUE\"
        fi
        EscapeString "$ConfigLine" '' 1
        ConfigLine="$RETURN_VALUE"
        ConfigString="$ConfigString${ConfigString:+" "}'${ConfigLine}'"
      fi
    done
  }

  if [[ "$FilePath" != '-' ]]; then
    InternalRead < "$FilePath"
  else
    InternalRead
  fi

  RETURN_VALUE="$ConfigString"

  return 0
}

# safe as mkdir but avoids mount points in the path to directory
function MakeDir()
{
  local ArgsArr
  ArgsArr=("$@")
  local DirPath
  local i

  # update all arguments which are not begins by the '-' character
  for (( i=0; i<${#ArgsArr[@]}; i++ )); do
    DirPath="${ArgsArr[i]}"
    if [[ -n "$DirPath" && "${DirPath:0:1}" != '-' ]]; then
      ExtractBackendPath "$DirPath"
      ArgsArr[i]="$RETURN_VALUE"
      #[[ ! -e "$RETURN_VALUE" ]] && echo "MKDIR: $RETURN_VALUE"
    fi
  done

  # call mkdir with updated arguments list
  mkdir "${ArgsArr[@]}"
}

function CopyFiles()
{
  local InputDirPath
  local OutputDirPath
  local NumArgs
  local FromIndex

  local CopyFlags="$1"
  if [[ -n "$CopyFlags" && "${CopyFlags:0:1}" != '-' ]]; then
    CopyFlags=''
  else
    shift
  fi

  InputDirPath="$1"
  OutputDirPath="$2"
  NumArgs="$#"
  FromIndex=2

  GetShiftOffset $(( FromIndex )) "$@" || shift $?

  GetAbsolutePathFromDirPath "$InputDirPath"
  InputDirPath="$RETURN_VALUE"
  GetAbsolutePathFromDirPath "$OutputDirPath"
  OutputDirPath="$RETURN_VALUE"

  local LastError=0
  local i

  if (( FromIndex < NumArgs )); then
    for (( i=FromIndex; i<NumArgs; i++ )); do
      if [[ -n "$1" ]]; then
        if [[ ! -e "$OutputDirPath" ]]; then
          MakeDir -p "$OutputDirPath"
        fi
        cp $CopyFlags "$InputDirPath/$1" "$OutputDirPath/$1"
        (( LastError |= $? ))
      fi
      shift
    done
  else
    CopyDirImpl $CopyFlags "$InputFilePath" "$OutputDirPath"
    (( LastError |= $? ))
  fi

  return $LastError
}

function CopyDirImpl()
{
  local CopyFlags="$1"
  local InputDirPath="$2"
  local OutputDirPath="$3"
  local ExtractedOutputDirPath
  local file

  local isVerbose=1
  [[ "${CopyFlags//v/}" == "$CopyFlags" ]] && isVerbose=0

  local isSilent=0
  [[ "${CopyFlags//s/}" == "$CopyFlags" ]] && isSilent=1

  (
    trap "exit 254" INT # enable interruption while in loop

    shopt -s dotglob # to enable file names beginning by a dot

    pushd "$InputDirPath" >/dev/null 2>&1 && {
      MakeDir -p "$OutputDirPath"
      ExtractedOutputDirPath="$RETURN_VALUE"
      if ! (( isSilent )); then
        echo "\`$InputDirPath/' -> \`$ExtractedOutputDirPath/'"
      fi
      for file in *; do
        cp "-R${CopyFlags#-}" "$InputDirPath/$file" "$ExtractedOutputDirPath" || exit $?
        # if verbose, then do echo only for copied directories to reduce echo abuse
        if (( isVerbose )) && [[ -d "$InputDirPath/$file" ]]; then
          echo "\`$InputDirPath/$file/'"
        fi
      done
    }
  )

  return $?
}

function CopyDir()
{
  local CopyFlags="$1"
  local InputDirPath
  local OutputDirPath
  
  if [[ -n "$CopyFlags" && "${CopyFlags:0:1}" != '-' ]]; then
    CopyFlags=''
    InputDirPath="$1"
    OutputDirPath="$2"
  else
    InputDirPath="$2"
    OutputDirPath="$3"
  fi

  GetAbsolutePathFromDirPath "$InputDirPath"
  InputDirPath="$RETURN_VALUE"
  GetAbsolutePathFromDirPath "$OutputDirPath"
  OutputDirPath="$RETURN_VALUE"

  CopyDirImpl "$CopyFlags" "$InputDirPath" "$OutputDirPath"
}

function MoveDirImpl()
{
  local MoveFlags="$1"
  local InputDirPath="$2"
  local OutputDirPath="$3"
  local ExtractedOutputDirPath
  local file

  local isVerbose=1
  [[ "${MoveFlags//v/}" == "$MoveFlags" ]] && isVerbose=0

  local isSilent=0
  [[ "${MoveFlags//s/}" == "$MoveFlags" ]] && isSilent=1

  (
    trap "exit 254" INT # enable interruption while in loop

    shopt -s dotglob # to enable file names beginning by a dot

    pushd "$InputDirPath" >/dev/null 2>&1 && {
      MakeDir -p "$OutputDirPath"
      ExtractedOutputDirPath="$RETURN_VALUE"
      if ! (( isSilent )); then
        echo "\`$InputDirPath/' -> \`$ExtractedOutputDirPath/'"
      fi
      for file in *; do
        mv "-${MoveFlags#-}" "$InputDirPath/$file" "$ExtractedOutputDirPath" || exit $?
        # if verbose, then do echo only for copied directories to reduce echo abuse
        if (( isVerbose )) && [[ -d "$InputDirPath/$file" ]]; then
          echo "\`$InputDirPath/$file/'"
        fi
      done
    }
  )

  return $?
}

function MoveDir()
{
  local MoveFlags="$1"
  local InputDirPath
  local OutputDirPath
  
  if [[ -n "$MoveFlags" && "${MoveFlags:0:1}" != '-' ]]; then
    MoveFlags=''
    InputDirPath="$1"
    OutputDirPath="$2"
  else
    InputDirPath="$2"
    OutputDirPath="$3"
  fi

  GetAbsolutePathFromDirPath "$InputDirPath"
  InputDirPath="$RETURN_VALUE"
  GetAbsolutePathFromDirPath "$OutputDirPath"
  OutputDirPath="$RETURN_VALUE"

  MoveDirImpl "$MoveFlags" "$InputDirPath" "$OutputDirPath"
}

function CleanupDir()
{
  local CleanupFlags="$1"
  local DirPath
  
  if [[ -n "$CleanupFlags" && "${CleanupFlags:0:1}" != '-' ]]; then
    CleanupFlags=''
    DirPath="$1"
  else
    CleanupFlags="$1"
    DirPath="$2"
    shift
  fi
  shift

  [[ -d "$DirPath" ]] || return 1

  local FilesToRemoveArr
  local DirsToRemoveArr
  FilesToRemoveArr=()
  DirsToRemoveArr=()

  # implementation function which does not run in a child shell process and calls to itself
  function CleanupDirImpl()
  {
    local BaseDirPath="$1"
    shift

    local FilePath
    local arg
    
    for arg in "$@"; do
      if [[ -n "$arg" && "$arg" != '*' ]]; then
        FilePath="$BaseDirPath/$arg"
        #echo "$FilePath"
        if [[ -f "$FilePath" || -h "$FilePath" ]]; then
          FilesToRemoveArr[${#FilesToRemoveArr[@]}]="$FilePath"
          #rm -f "$FilePath" || return 2
        elif [[ -d "$FilePath" ]]; then
          pushd "$arg" >/dev/null && \
          {
            CleanupDirImpl "$FilePath" * || return 1
            DirsToRemoveArr[${#DirsToRemoveArr[@]}]="$FilePath"
            popd >/dev/null
            #rmdir "$FilePath" || return 3
          }
        fi
      fi
    done

    return 0
  }

  # to automatically unroll a child process current directories stack
  (
    trap "exit 254" INT # enable interruption while in loop

    shopt -s dotglob # to enable file names beginning by a dot

    # ignore errors if directory doen't exist, suppress stderr
    pushd "$DirPath" >/dev/null 2>&1 && \
    {
      CleanupDirImpl "$PWD" * || exit 1

      # do remove files at first
      if (( ${#FilesToRemoveArr[@]} )); then
        rm "-f${CleanupFlags#-}" "${FilesToRemoveArr[@]}" || exit 2
      fi

      if (( ${#DirsToRemoveArr[@]} )); then
        rmdir $CleanupFlags "${DirsToRemoveArr[@]}" || exit 3
      fi
    }

    exit 0
  )

  return $?
}

function TouchFiles()
{
  local DirPath="${1:-.}"
  shift

  # implementation function which does not run in a child shell process and calls to itself
  function TouchFilesImpl()
  {
    local BaseDirPath="$1"
    shift

    local FilePath
    local arg
    
    for arg in "$@"; do
      if [[ -n "$arg" ]]; then
        FilePath="$BaseDirPath/$arg"
        if [[ -f "$FilePath" || -h "$FilePath" ]]; then
          touch -a "$FilePath"
        elif [[ -d "$FilePath" ]]; then
          pushd "$arg" >/dev/null && \
          {
            TouchFilesImpl "$BaseDirPath" *
            popd >/dev/null
          }
        fi
      fi
    done

    return 0
  }

  # to automatically unroll the child process current directories stack
  (
    trap "exit 254" INT # enable interruption while in loop

    shopt -s dotglob # to enable file names beginning by a dot

    # ignore errors if directory doen't exist, don't suppress stderr
    pushd "$DirPath" >/dev/null && \
    {
      TouchFilesImpl "$PWD" "$@" || exit 1
    }

    exit 0
  )

  return $?
}

function ReadFileDependents()
{
  # drop return value
  RETURN_VALUE=()

  local FilePath="$1"

  [[ -f "$FilePath" ]] || return 1

  # -1 - for debugging only
  # 1  - use dumpbin.exe
  # 2  - use objdump.exe
  local DumpbType=2

  ConvertBackendPathToNative "$FilePath"
  (( ! $? )) || return 2
  local NativeFilePath="$RETURN_VALUE"

  # drop return value
  RETURN_VALUE=()

  function InternalDumpbinRead()
  {
    local StrLine
    local DoReadDeps=0
    local DoBreak=0
    local HasDeps=0

    local IFS='' # enables read whole string line into a single variable

    while read -r StrLine; do
      case "$StrLine" in
        *'dependencies:')
          DoReadDeps=1
          ;;

        *)
          if (( DoReadDeps )); then
            if (( HasDeps )); then
              if [[ -z "${StrLine//[[:space:]]/}" ]]; then
                local DoBreak=1
                break
              fi
            fi
            if [[ -n "${StrLine//[[:space:]]/}" ]]; then
              HasDeps=1
              echo "${StrLine:4}"
            fi
          fi
          ;;
      esac
      (( DoBreak )) && break
    done
  }

  function InternalObjdumpRead()
  {
    grep "DLL Name:" | \
    {
      local StrLine

      local IFS='' # enables read whole string line into a single variable

      while read -r StrLine; do
        [[ -n "${StrLine//[[:space:]]/}" ]] && echo "${StrLine#*:[[:space:]]}"
      done
    }
  }

  function InternalSimpleRead()
  {
    local StrLine

    local IFS='' # enables read whole string line into a single variable

    while read -r StrLine; do
      [[ -n "${StrLine//[[:space:]]/}" ]] && RETURN_VALUE[${#RETURN_VALUE[@]}]="$StrLine"
    done
  }

  local EvalString=""
  case "$DumpbType" in
    1)
      EvalString="$(
        "$CONTOOLS_UTILITIES_BIN_ROOT/Microsoft/dumpbin.exe" -dependents "$NativeFilePath" | \
        InternalDumpbinRead | tr '[:upper:]' '[:lower:]' | \
        { MakeCommandArgumentsFromFile - && echo -n "$RETURN_VALUE"; }
      )"
      [[ -n "$EvalString" ]] && eval "RETURN_VALUE=($EvalString)"
      ;;

    2)
      EvalString="$(
        "$CONTOOLS_UTILITIES_BIN_ROOT/mingw/bin/objdump.exe" -p "$NativeFilePath" | \
        InternalObjdumpRead | tr '[:upper:]' '[:lower:]' | \
        { MakeCommandArgumentsFromFile - && echo -n "$RETURN_VALUE"; }
      )"
      [[ -n "$EvalString" ]] && eval "RETURN_VALUE=($EvalString)"
      ;;

    -1)
      InternalSimpleRead < "$FilePath"
      ;;
  esac

  return 0
}

function GetFileDependantsByDirPath()
{
  # drop return value
  RETURN_VALUE=()

  local DirPath="$1"
  local Extensions="${2:-"exe dll so"}"

  [[ -d "$DirPath" ]] || return 1

  local FilePath
  local ext

  local IFS=$' \t' # enables string split only by non printable characters back
  for ext in $Extensions; do
    IFS=$'\r\n' # enables string split only by line return characters and non printable characters may become part of name
    for FilePath in `find "$DirPath" -type f -iname "*.$ext" 2>/dev/null`; do
      [[ -n "${FilePath//[[:space:]]/}" ]] && RETURN_VALUE[${#RETURN_VALUE[@]}]="$FilePath"
    done
  done

  return 0
}

function DirectoryLsIterator()
{
  function InternalRead()
  {
    local PredicateFunc="$1"

    GetShiftOffset 1 "$@" || shift $?

    #local DirPathFromRoot="$2"
    #local NestingIndex="$3"

    local LsLine=''
    local IFS='' # enables read whole string line into a single variable
    local LastError=0

    while read -r LsLine; do
      case "$LsLine" in
        ?[r\-][w\-][x\-][r\-][w\-][x\-][r\-][w\-][x\-][[:blank:]\+]*)
          # MatchString function is slow for bash versions less than 3.2 because of external regexp emulation
          if MatchString '' "$LsLine" '([^[:blank:]]+)[[:blank:]]+([^[:blank:]]+)?[[:blank:]]+([^[:blank:]]+)?[[:blank:]]+([^[:blank:]]+)?[[:blank:]]+([^[:blank:]]+)?[[:blank:]]+([^[:blank:]]+)?[[:blank:]]+([^[:blank:]]+)?[[:blank:]]+([^[:blank:]]+)?[[:blank:]]+(.+)'; then
            "$PredicateFunc" "${#BASH_REMATCH[@]}" "${BASH_REMATCH[@]}" "$@"
            LastError=$?
            if (( LastError )); then # stop iterating
              #echo "!!! $LastError" >&2
              return $LastError
            fi
          fi
          ;;
        *)
          # echo "!!!$LsLine!!!"
          ;;
      esac
    done

    return $LastError
  }

  # implementation function which does not run in a child shell process and calls to itself
  function DirectoryLsIteratorImpl()
  {
    local DirPathFromRoot="$1"
    local DirPath="$2"
    local Flags="$3"
    local NestingIndex="${4:-0}"
    local PredicateFunc="$5"

    GetShiftOffset 5 "$@" || shift $?

    #echo "PWD=$PWD"
    #echo "DirPathFromRoot=$DirPathFromRoot"
    #echo "DirPath=$DirPath"
    #echo "NestingIndex=$NestingIndex"
    [[ -d "$DirPath" ]] || return 1
    [[ -n "$PredicateFunc" ]] || return 2

    local DoRecursion=0
    [[ "${Flags//r/}" != "$Flags" ]] && DoRecursion=1

    local LastError=0
    local PipeErrorsArr
    PipeErrorsArr=()

    if (( ! DoRecursion )); then
      # process target directory itself
      #echo "1: DirPath=$DirPath"
      ls -ld "$DirPath" | sort -f --key=1.1d,1 --key=9 | InternalRead "$PredicateFunc" "$DirPathFromRoot" "$NestingIndex"
      LastError=$?
      PipeErrorsArr=("${PIPESTATUS[@]}") # unknown bash bug: workaround for the "elif (( ${PIPESTATUS[0]:-0} ))" construction
      if (( LastError )); then
        LastError=5
      elif (( ${PipeErrorsArr[0]:-0} )); then
        LastError=6
      elif (( ${PipeErrorsArr[1]:-0} )); then
        LastError=7
      elif (( ${PipeErrorsArr[2]:-0} )); then
        LastError=8
      fi
    else
      #echo "2: DirPath=$DirPath"
      # process target directory content
      pushd "$DirPath" 2>&1 >/dev/null && \
      {
        if (( ! $? )); then
          ls -al | sort -f --key=1.1d,1 --key=9 | InternalRead "$PredicateFunc" "$DirPathFromRoot" "$NestingIndex"
          LastError=$?
          PipeErrorsArr=("${PIPESTATUS[@]}") # unknown bash bug: workaround for the "elif (( ${PIPESTATUS[0]:-0} ))" construction
          if (( LastError )); then
            LastError=11
          elif (( ${PipeErrorsArr[0]:-0} )); then
            LastError=12
          elif (( ${PipeErrorsArr[1]:-0} )); then
            LastError=13
          elif (( ${PipeErrorsArr[2]:-0} )); then
            LastError=14
          fi
        else
          LastError=10
        fi
        popd 2>&1 >/dev/null
      }
    fi

    return $LastError
  }

  # run recursion in a child process to later safely terminate it if something goes wrong
  (
    trap "exit 254" INT # enable interruption while in loop
    DirectoryLsIteratorImpl "$@"
  )

  return $?
}

function PrintDirectoryPermissions()
{
  local RootDirPath="${1:-.}"

  function IteratorPredicateFunc1()
  {
    local ChmodPerms=''
    local LsFileField=''
    local RelativeFilePath=''
    local Padding12='            '
    local LastError=0

    local IFS=$' \t\r\n' # workaround for the bug in the "[@]:i" expression under the bash version lower than 4.1

    (( ${#@} >= 3 )) && ChmodPerms="$3"
    (( ${#@} > 3 )) && LsFileField="${@:$1+1:1}"

    local BasePath="${@:$1+2:1}"
    local NestingIndex="${@:$1+3:1}"

    # parse the ls output for the "<filelinkname>" from the file name field in the "<filelinkname> -> <filepath>" format
    if (( ${#LsFileField} )); then
      RelativeFilePath="${LsFileField%[[:blank:]]->[[:blank:]]*}"
    fi

    if (( NestingIndex )); then
      # remove '/' prefix from the path if parent path was not absolute
      if [[ "${RootDirPath:0:1}" != '/' ]]; then
        BasePath="${BasePath#/}"
      fi

      # the "." and ".." subdirectories in the unix is a part of any directory, ignore them to avoid infinite recursion
      if [[ "$RelativeFilePath" == '.' || "$RelativeFilePath" == '..' ]]; then
        return 0
      fi
    fi

    local ChmodPermsAligned=''
    if (( ${#ChmodPerms} < 11 )); then
      ChmodPermsAligned="${Padding12:0:11-${#ChmodPerms}}"
    fi

    if [[ "${ChmodPerms:0:1}" != 'd' ]]; then
      echo "$ChmodPerms$ChmodPermsAligned $BasePath${BasePath:+/}$RelativeFilePath"
    else
      echo "$ChmodPerms$ChmodPermsAligned $BasePath${BasePath:+/}$RelativeFilePath/:"
      # do parse directories recursively
      if [[ "${RelativeFilePath:0:1}" != '/' ]]; then
        DirectoryLsIteratorImpl "$BasePath${BasePath:+/}$RelativeFilePath" "./$RelativeFilePath" -r $((NestingIndex+1)) IteratorPredicateFunc1 "$@"
      else
        DirectoryLsIteratorImpl "$RelativeFilePath" "$RelativeFilePath" -r $((NestingIndex+1)) IteratorPredicateFunc1 "$@"
      fi
      LastError=$?
      #echo "-- LastError=$LastError"
      echo ''
    fi

    return $LastError
  }

  DirectoryLsIterator '' "$RootDirPath" '' 0 IteratorPredicateFunc1
}
