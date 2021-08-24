#!/bin/bash

# Author:   Andrey Dibrov (andry at inbox dot ru)
 
# Bash script which copies the Cygwin/Mingw/Msys system "libmsvcr??[d].a" files
# to "libmsvcr[d].a" files which uses as runtime libraries by default by GCC
# linker. Cygwin/Mingw/Msys system required.

# Command arguments:
# $1 - Version of libraries:
#   60 - Link with "msvcrt[d].dll" (Microsoft Visual C++ \'98 aka v6.0).
#   70 - Link with "msvcrt70[d].dll" (Microsoft Visual C++ 2002 aka v7.0).
#   71 - Link with "msvcrt71[d].dll" (Microsoft Visual C++ 2003 aka v7.1).
#   80 - Link with "msvcrt80[d].dll" (Microsoft Visual C++ 2005 aka v8.0).
#   90 - Link with "msvcrt90[d].dll" (Microsoft Visual C++ 2008 aka v9.0).
# $2 - Flag:
#   -icheck - Don't check dynamic libraries "msvcr??[d].dll" for existence in
#             search paths.

# Script ONLY for execution.
if [[ -n "$BASH" && (-z "$BASH_LINENO" || ${BASH_LINENO[0]} -eq 0) ]]; then

if [[ -n "$BASH_LINENO" ]] && (( ${BASH_LINENO[0]} > 0 )); then
  ScriptFilePath="${BASH_SOURCE[0]//\\//}"
else
  ScriptFilePath="${0//\\//}"
fi
if [[ "${ScriptFilePath:1:1}" == ":" ]]; then
  ScriptFilePath="`/bin/readlink.exe -f "/${ScriptFilePath/:/}"`"
else
  ScriptFilePath="`/bin/readlink.exe -f "$ScriptFilePath"`"
fi

ScriptDirPath="${ScriptFilePath%[/]*}"
ScriptFileName="${ScriptFilePath##*[/]}"

LinkMsvcrtVer="$1"

if [[ -z "$LinkMsvcrtVer" || \
  "$LinkMsvcrtVer" != "60" && \
  "$LinkMsvcrtVer" != "70" && \
  "$LinkMsvcrtVer" != "71" && \
  "$LinkMsvcrtVer" != "80" && \
  "$LinkMsvcrtVer" != "90" ]]; then
  echo \
"$ScriptFileName"$': Script copies libmsvcr??[d].a to libmsvcr[d].a libraries
           which used by GCC linker by default.

Usage: '"$ScriptFileName"$' <60|70|71|80|90> [-icheck]

Command arguments:
  $1 - Version of libraries:
    60 - Link with "msvcrt[d].dll" (Microsoft Visual C++ \'98 aka v6.0).
    70 - Link with "msvcrt70[d].dll" (Microsoft Visual C++ 2002 aka v7.0).
    71 - Link with "msvcrt71[d].dll" (Microsoft Visual C++ 2003 aka v7.1).
    80 - Link with "msvcrt80[d].dll" (Microsoft Visual C++ 2005 aka v8.1).
    90 - Link with "msvcrt90[d].dll" (Microsoft Visual C++ 2008 aka v9.0).
  $2 - Flag:
    -icheck - Don\'t check dynamic libraries "msvcr??[d].dll" for existence in
              search paths.
'
  exit 1
fi

function GetAbsolutePathFromDirPath()
{
  # drop return value
  RETURN_VALUE="$1"

  local DirPath="$1"
  local RelativePath="$2"

  # WORKAROUND:
  #   Because some versions of readlink can not handle windows native absolute
  #   paths correctly, then always try to convert directory path to a backend
  #   path before the readlink in case if the path has specific native path
  #   characters.
  if [[ "${DirPath:1:1}" == ":" ]]; then
    ConvertNativePathToBackend "$DirPath"
    DirPath="$RETURN_VALUE"
  fi

  if [[ -n "$DirPath" && -x "/bin/readlink.exe" ]]; then
    if [[ "${RelativePath:0:1}" != '/' ]]; then
      RETURN_VALUE="`/bin/readlink.exe -m "$DirPath${RelativePath:+/}$RelativePath"`"
    else
      RETURN_VALUE="`/bin/readlink.exe -m "$RelativePath"`"
    fi
  fi

  return 0
}

function ConvertBackendPathToNative()
{
  # cygwin/msys2 uses cygpath command to convert paths
  # msys/mingw uses old style conversion through the "cmd.exe ^/C" call

  # drop return value
  RETURN_VALUE="$1"

  local PathToConvert="$1"
    local Flags="$2"

    local ConvertedPath=""

    if [[ "${Flags/i/}" != "$Flags" ]]; then
      # w/ user mount points bypassing
      ExctractPathIgnoringUserMountPoints -w "$PathToConvert"
      return $?
    fi

  [[ -n "$PathToConvert" ]] || return 1

  GetAbsolutePathFromDirPath "$PathToConvert"

  case "$OSTYPE" in
    "msys" | "mingw")
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

    "cygwin")
      ConvertedPath="`/bin/cygpath.exe -w "$RETURN_VALUE"`"
    ;;

    *)
      return 2
    ;;
  esac

  # remove last slash
  ConvertedPath="${ConvertedPath%[/\\]}"
  # convert all slashes to backward slashes
  RETURN_VALUE="${ConvertedPath//\//\\}"

  return 0
}

function FindChar()
{
  # drop return value
  RETURN_VALUE=""

  # (Required) String which would be searched.
  local String="$1"
  # (Required) Chars for search.
  local Chars="$2"

  if [[ -z "$String" ]]; then
    RETURN_VALUE="-1"
    return 1
  fi
  if [[ -z "$Chars" ]]; then
    RETURN_VALUE="-1"
    return 2
  fi

  local StringLen="${#String}"
  local CharsLen="${#Chars}"
  local i
  local j
  for (( i=0; i < StringLen; i++ )); do
    for (( j=0; j < CharsLen; j++ )); do
      if [[ "${String:$i:1}" == "${Chars:$j:1}" ]]; then
        RETURN_VALUE="$i"
        return 0
        break
      fi
    done
  done

  RETURN_VALUE="-1"

  return 3
}

function EscapeString()
{
  # drop return value
  RETURN_VALUE=""

  # (Required) String which would be escaped.
  local String="$1"
  # (Optional) Set of characters in string which are gonna be escaped.
  local EscapeChars="$2"
  # (Optional) Type of escaping:
  #   0 - String will be quoted by the " character, so escape any character from
  #       "EscapeChars" by the \ character.
  #   1 - String will be quoted by the ' character, so the ' character should be
  #       escaped by the \' sequance. The "EscapeChars" variable doesn't used in this case.
  #   2 - String will be used in the cmd.exe shell, so quote any character from
  #       the "EscapeChars" variable by the ^ character.
  local EscapeType="${3:-0}"

  if [[ -z "$String" ]]; then
    RETURN_VALUE="$String"
    return 1
  fi

  if [[ -z "$EscapeChars" ]]; then
    case $EscapeType in
      0) EscapeChars='$!&|\`"' ;;
      2) EscapeChars='^?*&|<>()"' ;;
    esac
  fi

  local EscapedString=""
  local StringCharEscapeOffset=-1
  local i
  for (( i=0; i<${#String}; i++ )); do
    local StringChar="${String:$i:1}"
    case $EscapeType in
      0)
        FindChar "$EscapeChars" "$StringChar"
        StringCharEscapeOffset="$RETURN_VALUE"
        if (( StringCharEscapeOffset < 0 )); then
          EscapedString="$EscapedString$StringChar"
        else
          EscapedString="$EscapedString\\$StringChar"
        fi
      ;;
      1)
        if [[ "$StringChar" != "'" ]]; then
          EscapedString="$EscapedString$StringChar"
        else
          EscapedString="$EscapedString'\\''"
        fi
      ;;
      *)
        FindChar "$EscapeChars" "$StringChar"
        StringCharEscapeOffset="$RETURN_VALUE"
        if (( StringCharEscapeOffset >= 0 )); then
          EscapedString="$EscapedString^"
        fi
        EscapedString="$EscapedString$StringChar"
      ;;
    esac
  done

  [[ -n "$EscapedString" ]] || return 2

  RETURN_VALUE="$EscapedString"

  return 0
}

echo "$ScriptFileName: set GCC to link executables by default with \"libmsvcr"\
"`if [[ "$LinkMsvcrtVer" == "60" ]]; then exit 0; else echo -n "$LinkMsvcrtVer"; fi`"\
"[d].dll\" dynamic libraries."

ConvertBackendPathToNative '/'
SystemRuntimePath="$RETURN_VALUE"

if [[ "$OSTYPE" = "msys" ]]; then
  # Test "/mingw" mount point, it should exist.
  ConvertBackendPathToNative '/mingw'
  MingwMountPath="$RETURN_VALUE"

  (echo "$MingwMountPath/" | tr '\134' '\057' | grep -i "`echo -n "$SystemRuntimePath/" | tr '\134' '\057'`") >/dev/null 2>&1
  LastError=$?

  if [[ $LastError -eq 0 ]]; then
    echo "$ScriptFileName: info: \"/mingw\": \"$MingwMountPath\"
$ScriptFileName: error: \"/mingw\" directory not mounted properly or mounted in to system root path." >&2
    exit 2
  fi
  SystemLibPath="/mingw/lib"
elif [[ "$OSTYPE" = "cygwin" ]]; then
  SystemLibPath="/lib/mingw"
  if [[ ! -d "$SystemLibPath" ]]; then
    SystemLibPath="/usr/i686-pc-mingw32/sys-root/mingw/lib"
  fi
else
  SystemLibPath="/lib"
fi

if [[ "$2" = "-icheck" ]]; then
  IgnoreDllCheck=1
  IgnoreStatusMsg="warning"
else
  IgnoreDllCheck=0
  IgnoreStatusMsg="error"
fi

LinkMsvcrtLib60Path="$SystemLibPath/libmsvcr60.a"
LinkMsvcrtLib60dPath="$SystemLibPath/libmsvcr60d.a"

LinkMsvcrtLibDefaultPath="$SystemLibPath/libmsvcrt.a"
LinkMsvcrtLibDefaultdPath="$SystemLibPath/libmsvcrtd.a"

LinkMsvcrtLibPath="$SystemLibPath/libmsvcr${LinkMsvcrtVer}.a"
LinkMsvcrtLibdPath="$SystemLibPath/libmsvcr${LinkMsvcrtVer}d.a"

LinkMoldnameLib60Path="$SystemLibPath/libmoldname60.a"
LinkMoldnameLib60dPath="$SystemLibPath/libmoldname60d.a"

LinkMoldnameLibDefaultPath="$SystemLibPath/libmoldname.a"
LinkMoldnameLibDefaultdPath="$SystemLibPath/libmoldnamed.a"

LinkMoldnameLibPath="$SystemLibPath/libmoldname${LinkMsvcrtVer}.a"
LinkMoldnameLibdPath="$SystemLibPath/libmoldname${LinkMsvcrtVer}d.a"

MsvcrtDefaultLibsSaved=0
MoldnameDefaultLibsSaved=0

# Save libraries (if not done yet) which would be rewrited.
if [[ ! -f "$LinkMsvcrtLib60Path" && ! -f "$LinkMsvcrtLib60dPath" ]]; then
  if [[ ! -f "$LinkMsvcrtLibDefaultPath" && ! -f "$LinkMsvcrtLibDefaultdPath" ]]; then
    echo "$ScriptFileName: error: libraries \"libmsvcrt[d].a\" not found." >&2
    exit 2
  fi

  cp -f "$LinkMsvcrtLibDefaultPath" "$LinkMsvcrtLib60Path" >/dev/null 2>&1
  cp -f "$LinkMsvcrtLibDefaultdPath" "$LinkMsvcrtLib60dPath" >/dev/null 2>&1
  MsvcrtDefaultLibsSaved=1
  echo "$ScriptFileName: info: libraries \"libmsvcr60[d].a\" not found, created from \"libmsvcrt[d].a\"." >&2
fi

if [[ ! -f "$LinkMoldnameLib60Path" && ! -f "$LinkMoldnameLib60dPath" ]]; then
  if [[ -f "$LinkMoldnameLibDefaultPath" && -f "$LinkMoldnameLibDefaultdPath" ]]; then
    cp -f "$LinkMoldnameLibDefaultPath" "$LinkMoldnameLib60Path" >/dev/null 2>&1
    cp -f "$LinkMoldnameLibDefaultdPath" "$LinkMoldnameLib60dPath" >/dev/null 2>&1
    MoldnameDefaultLibsSaved=1
    echo "$ScriptFileName: info: libraries \"libmoldname60[d].a\" not found, created from \"libmoldname[d].a\"." >&2
  fi
fi

if [[ "$LinkMsvcrtVer" != "60" ]]; then
  LinkMsvcrtDllName="msvcr${LinkMsvcrtVer}.dll"
  LinkMsvcrtDlldName="msvcr${LinkMsvcrtVer}d.dll"

  if [[ ! -f "$LinkMsvcrtLibPath" || ! -f "$LinkMsvcrtLibdPath" ]]; then
    echo "$ScriptFileName: error: can't find \"libmsvcrt[d].a\" libraries." >&2
    exit 3
  fi
else
  LinkMsvcrtDllName="msvcrt.dll"
  LinkMsvcrtDlldName="msvcrtd.dll"
fi

# Before check if we can find target *.a and *.dll files.
LastError=0
if [[ ! -f "$LinkMsvcrtLibPath" ]]; then
  echo "$ScriptFileName: error: \"$LinkMsvcrtLibPath\" not found." >&2
  LastError=1
fi
if [[ ! -f "$LinkMsvcrtLibdPath" ]]; then
  echo "$ScriptFileName: error: \"$LinkMsvcrtLibdPath\" not found." >&2
  LastError=1
fi
if [[ $LastError -ne 0 ]]; then
  exit 4
fi

if [[ "$OSTYPE" == "msys" ]]; then
  WhichUtility='/bin/which'
else
  WhichUtility='/bin/which.exe'
fi

LastError=0
LinkMsvcrtDllPath="`"$WhichUtility" \"$LinkMsvcrtDllName\" 2>/dev/null`"
LinkMsvcrtDlldPath="`"$WhichUtility" \"$LinkMsvcrtDlldName\" 2>/dev/null`"

if [[ -z "$LinkMsvcrtDllPath" ]]; then
  echo "$ScriptFileName: $IgnoreStatusMsg: \"$LinkMsvcrtDllName\" not found." >&2
  LastError=1
else
  echo "$ScriptFileName: info: \"$LinkMsvcrtDllPath\"." >&2
fi
if [[ -z "$LinkMsvcrtDlldPath" ]]; then
  echo "$ScriptFileName: warning: \"$LinkMsvcrtDlldName\" not found." >&2
else
  echo "$ScriptFileName: info: \"$LinkMsvcrtDlldPath\"." >&2
fi

if [[ $LastError -ne 0 ]]; then
  echo "$ScriptFileName: info: You should install Microsoft Visual C++ Redistributables (vcredist_*.exe) before run application linked dynamically with this library." >&2
  if [[ $IgnoreDllCheck -eq 0 ]]; then
    exit 5
  fi
fi

if [[ -f "$LinkMoldnameLib60Path" && -f "$LinkMoldnameLib60dPath" &&\
      -f "$LinkMoldnameLibPath" && -f "$LinkMoldnameLibdPath" ]]; then
  (echo "$LinkMoldnameLib60Path" | grep -i "$LinkMoldnameLibPath") >/dev/null 2>&1
  LastError=$?
  if [[ $MoldnameDefaultLibsSaved -eq 0 || $LastError -ne 0 || ${#LinkMoldnameLib60Path} -ne ${#LinkMoldnameLibPath} ]]; then
    cp -f "$LinkMoldnameLibPath" "$LinkMoldnameLibDefaultPath" >/dev/null 2>&1
    cp -f "$LinkMoldnameLibdPath" "$LinkMoldnameLibDefaultdPath" >/dev/null 2>&1
  fi
else
  echo "$ScriptFileName: warning: can't copy \"libmoldname${LinkMsvcrtVer}[d].a\" libraries." >&2
fi
if [[ -f "$LinkMsvcrtLib60Path" && -f "$LinkMsvcrtLib60dPath" &&\
      -f "$LinkMsvcrtLibPath" && -f "$LinkMsvcrtLibdPath" ]]; then
  (echo "$LinkMsvcrtLib60Path" | grep -i "$LinkMsvcrtLibPath") >/dev/null 2>&1
  LastError=$?
  if [[ $MsvcrtDefaultLibsSaved -eq 0 || $LastError -ne 0 || ${#LinkMsvcrtLib60Path} -ne ${#LinkMsvcrtLibPath} ]]; then
    cp -f "$LinkMsvcrtLibPath" "$LinkMsvcrtLibDefaultPath" >/dev/null 2>&1
    cp -f "$LinkMsvcrtLibdPath" "$LinkMsvcrtLibDefaultdPath" >/dev/null 2>&1
  fi
else
  echo "$ScriptFileName: error: can't copy \"libmsvcr${LinkMsvcrtVer}[d].a\" libraries." >&2
  exit 6
fi

exit 0

fi
