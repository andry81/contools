#!/bin/bash

# Author:   Andrey Dibrov (andry at inbox dot ru)

# Patch library, implements main functions to automate source patching.

# Script can be ONLY included by "source" command.
[[ -n "$BASH" && (-z "$BASH_LINENO" || BASH_LINENO[0] -gt 0) && (-z "$SOURCE_CONTOOLS_PATCHLIB_SH" || SOURCE_CONTOOLS_PATCHLIB_SH -eq 0) ]] || return 0 || exit 0 # exit to avoid continue if the return can not be called

SOURCE_CONTOOLS_PATCHLIB_SH=1 # including guard

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
tkl_include_or_abort "$CONTOOLS_BASH_ROOT/regexplib.sh"

function PatchFileIterator()
{
  local PatchFilePath="$1"
  local PatchCurDirPath="${2:-.}"
  local PredicateHeadFunc="$3"
  local PredicateBodyFunc="$4"
  local FromHunkFileIndex="${5:-0}"

  GetShiftOffset 5 "$@" || shift $?

  [[ -f "$PatchFilePath" ]] || return 1
  [[ -n "$PredicateHeadFunc" ]] || return 2

  local LastError=0
  local InFilePath=""
  local OutFilePath=""
  local PatchHunkFileIndex
  local PatchFileNextIndex=0
  local PatchHunkIndex

  local PatchLine=""
  local PatchHeaderType=0
  # 1 - context type
  # 2 - uniform type

  local IsBlockCommented=0

  # previous 
  {
    local IFS='' # enables read whole string line into a single variable.

    while read -r PatchLine; do
      case "$PatchLine" in
        # context patch type
        '***'[[:blank:]]*[^\*])
          if MatchString '' "$PatchLine" '^\*\*\*[[:blank:]]+([^'$'\t'']+)'; then
            InFilePath="${BASH_REMATCH[1]}"
            PatchHeaderIndex=1
            PatchHeaderType=1
          else
            return 1
            InFilePath=""
            PatchHeaderIndex=0
            PatchHeaderType=0
          fi
          IsBlockCommented=0
          ;;

        # may be context or uniform patch type
        ---[[:blank:]]*[^-])
          if (( PatchHeaderType != 1 || PatchHeaderIndex != 1 )); then
            if MatchString '' "$PatchLine" '^---[[:blank:]]+([^'$'\t'']+)'; then
              InFilePath="${BASH_REMATCH[1]}"
              PatchHeaderIndex=1
              PatchHeaderType=2
            else
              return 2
              InFilePath=""
              PatchHeaderIndex=0
              PatchHeaderType=0
            fi
            IsBlockCommented=0
          else
            if MatchString '' "$PatchLine" '^---[[:blank:]]+([^'$'\t'']+)'; then
              OutFilePath="${BASH_REMATCH[1]}"
              PatchHeaderIndex=2
              PatchHunkFileIndex=$PatchFileNextIndex
              (( PatchFileNextIndex++ ))
              PatchHunkIndex=0
            else
              return 3
              OutFilePath=""
              PatchHeaderIndex=0
              PatchHeaderType=0
            fi
          fi
        ;;

        # uniform patch type
        \+\+\+[[:blank:]]*[^\+])
          if (( PatchHeaderType == 2 && PatchHeaderIndex == 1 )); then
            if MatchString '' "$PatchLine" '^\+\+\+[[:blank:]]+([^'$'\t'']+)'; then
              OutFilePath="${BASH_REMATCH[1]}"
              PatchHeaderIndex=2
              PatchHunkFileIndex=$PatchFileNextIndex
              (( PatchFileNextIndex++ ))
              PatchHunkIndex=0
            else
              return 4
              OutFilePath=""
              PatchHeaderIndex=0
              PatchHeaderType=0
            fi
          fi
        ;;

        # context patch type
        '***************'*)
          if (( PatchHeaderType == 1 && PatchHeaderIndex >= 2 )); then
            PatchHeaderIndex=3
          fi
          ;;

        '***'[[:blank:]]*[[:blank:]]'****')
          if (( PatchHeaderType == 1 && PatchHeaderIndex == 3 )); then
            if (( PatchHunkFileIndex >= FromHunkFileIndex )); then
              "$PredicateHeadFunc" "$PatchCurDirPath" "$InFilePath" "$OutFilePath" "$PatchHunkFileIndex" "$PatchHunkIndex" 0 "$@"
              LastError=$?
              if (( LastError )); then # stop iterating
                return 3
              fi
            fi
            (( PatchHunkIndex++ ))
            IsBlockCommented=0
          fi
          ;;

        # uniform patch type
        \@\@[[:blank:]]*)
          if (( PatchHeaderType == 2 && PatchHeaderIndex == 2 )); then
            if (( PatchHunkFileIndex >= FromHunkFileIndex )); then
              "$PredicateHeadFunc" "$PatchCurDirPath" "$InFilePath" "$OutFilePath" "$PatchHunkFileIndex" "$PatchHunkIndex" 1 "$@"
              LastError=$?
              if (( LastError )); then # stop iterating
                return 4
              fi
            fi
            (( PatchHunkIndex++ ))
            IsBlockCommented=0
          fi
          ;;

        \#*)
          IsBlockCommented=1
          ;;

        *)
          if (( ! IsBlockCommented )); then
            if (( PatchHeaderType == 1 && PatchHeaderIndex == 3 )); then
              case "$PatchLine" in
                ---[[:blank:]]*[[:blank:]]----)
                  continue
                  ;;
              esac
            fi
            if (( PatchHeaderType && PatchHeaderIndex >= 2 )) && [[ -n "$PredicateBodyFunc" ]]; then
              "$PredicateBodyFunc" "$PatchLine" "$@"
              LastError=$?
              if (( LastError )); then # stop iterating
                return 5
              fi
            fi
          fi
          ;;
      esac
    done
  } < "$PatchFilePath"

  return 0
}

# for the debugging purposes
function PatchFileTester()
{
  local PatchFilePath="$1"
  local PatchCurDirPath="${2:-.}"
  local FromHunkFileIndex="${3:-0}"

  local IsPatchHunksBegan=0

  local PrevPatchInsertLinesInHunk=''
  local PrevOverallPatchLinesInHunk=''
  local PatchInsertLinesInHunk
  local OverallPatchLinesInHunk
  
  function IteratorPredicateFunc1()
  {
    if (( IsPatchHunksBegan )); then
      PrevPatchInsertLinesInHunk="$PatchInsertLinesInHunk"
      PrevOverallPatchLinesInHunk="$OverallPatchLinesInHunk"
    fi
    PatchInsertLinesInHunk=0
    OverallPatchLinesInHunk=0
    IsPatchHunksBegan=1

    local InFilePath="$2"
    local OutFilePath="$3"
    local PatchHunkFileIndex="$4"
    local PatchHunkIndex="$5"
    local PatchHunkType="$6"

    if (( PatchHunkFileIndex > FromHunkFileIndex )); then
      echo "PatchInsertLinesInHunk=$PrevPatchInsertLinesInHunk"
      echo "OverallPatchLinesInHunk=$PrevOverallPatchLinesInHunk"
      echo ''
    fi
    echo "InFilePath=$InFilePath"
    echo "OutFilePath=$OutFilePath"
    echo "PatchHunkFileIndex=$PatchHunkFileIndex"
    echo "PatchHunkIndex=$PatchHunkIndex"
    echo "PatchHunkType=$PatchHunkType"

    return 0
  }

  function IteratorPredicateFunc2()
  {
    (( IsPatchHunksBegan )) || return 0

    local PatchLine="$1"

    case "$PatchLine" in
      '+'*) (( PatchInsertLinesInHunk++ )) ;;
    esac

    (( OverallPatchLinesInHunk++ ))

    return 0
  }

  PatchFileIterator "$PatchFilePath" "$PatchCurDirPath" IteratorPredicateFunc1 IteratorPredicateFunc2 "$FromHunkFileIndex"
  if (( IsPatchHunksBegan )); then
    echo "PatchInsertLinesInHunk=$PatchInsertLinesInHunk"
    echo "OverallPatchLinesInHunk=$OverallPatchLinesInHunk"
    echo ''
  fi
}

function PatchIniFileIterator()
{
  local IniFilePath="$1"
  local PredicateFunc="$2"

  [[ -f "$IniFilePath" ]] || return 1
  [[ -n "$PredicateFunc" ]] || return 2

  local LastError=0
  local IniLine=""

  {
    local IFS='' # enables read whole string line into a single variable.

    while read -r IniLine; do
      case "$IniLine" in
        \#*) # ignore commented lines in file
          continue
          ;;

        exec:* | ?exec:*)
          if MatchString '' "$IniLine" '([^:]+):([^:]*):(.+)'; then
            "$PredicateFunc" "exec:*" "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" "${BASH_REMATCH[3]}"
            LastError=$?
            if (( LastError )); then # stop iterating
              return 1
            fi
          else
            return 2
          fi
          ;;

        *.patch:*)
          if MatchString '' "$IniLine" '([^:]+):?([^:]*):?(.*)'; then
            "$PredicateFunc" "*.patch:*" "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" "${BASH_REMATCH[3]}"
            LastError=$?
            if (( LastError )); then # stop iterating
              return 3
            fi
          else
            return 4
          fi
          ;;

        *:*)
          if MatchString '' "$IniLine" '([^:]+):([^:]*):([^:]*):([^:]+):?(.*)'; then
            "$PredicateFunc" "*:*" "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" "${BASH_REMATCH[3]}" "${BASH_REMATCH[4]}" "${BASH_REMATCH[5]}"
            LastError=$?
            if (( LastError )); then # stop iterating
              return 5
            fi
          else
            return 6
          fi
          ;;
      esac
    done
  } < "$IniFilePath"

  return 0
}

function InitPatchIniFileIteratorVarsByParams()
{
  local PatchCurDirPathArg

  case "$1" in
    "exec:*")
      PatchFilePath="$2"
      PatchCurDirPathArg="$3"
      PatchCurDirPath="${PatchCurDirPathArg:-"$PWD"}"
      GetShiftOffset 3 "$@" || shift $?
      eval "ExecArgsArr=($@)"
      [[ "${PatchFilePath:0:1}" == '$' ]] && eval "PatchFilePath=\"$PatchFilePath\""
      [[ "${PatchCurDirPath:0:1}" == '$' ]] && eval "PatchCurDirPath=\"$PatchCurDirPath\""
      PatchCurDirPath="${PatchCurDirPath//\\//}"
      [[ "${PatchCurDirPath:0:1}" == "/" ]] || PatchCurDirPath="$PWD${PatchCurDirPath:+/}$PatchCurDirPath"
      ;;

    "*.patch:*")
      PatchFilePath="$2"
      PatchCurDirPathArg="$3"
      PatchCurDirPath="${PatchCurDirPathArg:-"$PWD"}"
      PatchAttributes="$4"
      [[ "${PatchFilePath:0:1}" == '$' ]] && eval "PatchFilePath=\"$PatchFilePath\""
      [[ "${PatchCurDirPath:0:1}" == '$' ]] && eval "PatchCurDirPath=\"$PatchCurDirPath\""
      [[ "${PatchAttributes:0:1}" == '$' ]] && eval "PatchAttributes=\"$PatchAttributes\""
      PatchFilePath="${PatchFilePath//\\//}"
      PatchCurDirPath="${PatchCurDirPath//\\//}"
      [[ "${PatchCurDirPath:0:1}" == "/" ]] || PatchCurDirPath="$PWD${PatchCurDirPath:+/}$PatchCurDirPath"
      if [[ -n "$PatchFilePath" ]]; then
        [[ "${PatchFilePath:0:1}" == "/" ]] || PatchFilePath="$TargetInputDirPath/$PatchFilePath"
      fi
      ;;

    "*:*")
      PatchFilePath="$2"
      PatchCurDirPathArg="$3"
      PatchCurDirPath="${PatchCurDirPathArg:-"$PWD"}"
      PatchingFileInputPath="$4"
      PatchingFileOutputPath="$5"
      PatchingFileAttr="$6"
      DoIgnoredFileInputPathAbsence=0
      if [[ "${PatchingFileInputPath:0:1}" == '-' ]]; then
        PatchingFileInputPath="${PatchingFileInputPath:1}"
        DoIgnoredFileInputPathAbsence=1
      fi
      DoIgnoredFileOutputPathAbsence=0
      if [[ "${PatchingFileOutputPath:0:1}" == '-' ]]; then
        PatchingFileOutputPath="${PatchingFileOutputPath:1}"
        DoIgnoredFileOutputPathAbsence=1
      fi
      [[ "${PatchFilePath:0:1}" == '$' ]] && eval "PatchFilePath=\"$PatchFilePath\""
      [[ "${PatchCurDirPath:0:1}" == '$' ]] && eval "PatchCurDirPath=\"$PatchCurDirPath\""
      [[ "${PatchingFileInputPath:0:1}" == '$' ]] && eval "PatchingFileInputPath=\"$PatchingFileInputPath\""
      [[ "${PatchingFileOutputPath:0:1}" == '$' ]] && eval "PatchingFileOutputPath=\"$PatchingFileOutputPath\""
      [[ "${PatchingFileAttr:0:1}" == '$' ]] && eval "PatchingFileAttr=\"$PatchingFileAttr\""
      PatchFilePath="${PatchFilePath//\\//}"
      PatchCurDirPath="${PatchCurDirPath//\\//}"
      PatchingFileInputPath="${PatchingFileInputPath//\\//}"
      PatchingFileOutputPath="${PatchingFileOutputPath//\\//}"
      if [[ -n "$PatchFilePath" ]]; then
        [[ "${PatchFilePath:0:1}" == "/" ]] || PatchFilePath="$TargetInputDirPath${PatchFilePath:+/}$PatchFilePath"
      fi
      [[ "${PatchCurDirPath:0:1}" == "/" ]] || PatchCurDirPath="$PWD/$PatchCurDirPath"
      if [[ -n "$PatchingFileInputPath" && "${PatchingFileInputPath:0:1}" != "/" ]]; then
        if [[ -z "$PatchCurDirPathArg" ]]; then
          PatchingFileInputPath="$TargetInputDirPath${PatchingFileInputPath:+/}$PatchingFileInputPath"
        fi
      fi
      if [[ -n "$PatchingFileOutputPath" && "${PatchingFileOutputPath:0:1}" != "/" ]]; then
        if [[ -z "$PatchCurDirPathArg" ]]; then
          PatchingFileOutputPath="$TargetOutputDirPath${PatchingFileOutputPath:+/}$PatchingFileOutputPath"
        fi
      fi
      ;;
  esac

  if [[ "${PatchFilePath:0:1}" == '/' ]]; then
    PatchFileAbsPath="$PatchFilePath"
  elif [[ -n "$PatchFilePath" ]]; then
    PatchFileAbsPath="$PatchCurDirPath${PatchFilePath:+/}$PatchFilePath"
  fi
  if [[ "${PatchingFileInputPath:0:1}" == '/' ]]; then
    PatchingFileInputAbsPath="$PatchingFileInputPath"
  elif [[ -n "$PatchingFileInputPath" ]]; then
    PatchingFileInputAbsPath="$PatchCurDirPath${PatchingFileInputPath:+/}$PatchingFileInputPath"
  fi
  if [[ "${PatchingFileOutputPath:0:1}" == '/' ]]; then
    PatchingFileOutputAbsPath="$PatchingFileOutputPath"
  elif [[ -n "$PatchingFileOutputPath" ]]; then
    PatchingFileOutputAbsPath="$PatchCurDirPath${PatchingFileOutputPath:+/}$PatchingFileOutputPath"
  fi

  if [[ -n "$PatchFilePath" ]]; then
    GetRelativePathFromAbsolutePaths "$PatchFileAbsPath" "$BuildRootDirPath"
    PatchFilePathPrint="${RETURN_VALUE:-"$PatchFileAbsPath"}"
  else
    PatchFilePathPrint="${PatchFileAbsPath:-"$PatchCurDirPath"}"
  fi
  if [[ -n "$PatchingFileInputPath" ]]; then
    GetRelativePathFromAbsolutePaths "$PatchingFileInputAbsPath" "$BuildRootDirPath"
    PatchingFileInputPathPrint="${RETURN_VALUE:-"$PatchingFileInputAbsPath"}"
  else
    PatchingFileInputPathPrint="${PatchingFileInputAbsPath:-"$PatchCurDirPath"}"
  fi
  if [[ -n "$PatchingFileOutputPath" ]]; then
    GetRelativePathFromAbsolutePaths "$PatchingFileOutputAbsPath" "$BuildRootDirPath"
    PatchingFileOutputPathPrint="${RETURN_VALUE:-"$PatchingFileOutputPath"}"
  else
    GetRelativePathFromAbsolutePaths "$TargetOutputDirPath" "$BuildRootDirPath"
    PatchingFileOutputPathPrint="${RETURN_VALUE:-"$TargetOutputDirPath"}"
  fi
}

function CheckPatchIniFile()
{
  [[ -f "$TargetInputDirPath/patchlist.ini" ]] || return 2

  echo "Checking patches..."

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
  PushTrapFunctionMove "$DefaultTrapsStackName" LocalReturn RETURN || return 3

  oldShopt="$(shopt -p nocasematch)" # Read state before change
  if [[ "$oldShopt" != "shopt -s nocasematch" ]]; then
    shopt -s nocasematch
  else
    oldShopt=''
  fi

  OverallExistingPatches=0

  local ValidPatchHunks=0
  local OverallPatchHunks=0
  local ValidPatchFiles=0
  local OverallPatchFiles=0
  local ValidExecFileInFiles=0
  local OverallExecFileInFiles=0
  local IgnoredExecFileInFiles=0

  function IteratorPredicateFunc1()
  {
    case "$1" in
      "exec:*")
        (( OverallExistingPatches++ ))
        return 0
        ;;
    esac

    local LocalValidPatchHunks=0
    local LocalOverallPatchHunks=0
    local IsPatchHunksBegan=0

    local PatchInsertLinesInHunk
    local OverallPatchLinesInHunk

    local PrevValidExecFileInputFiles
    local PrevValidPatchHunks=0
    local PrevOverallPatchHunks=0
    local IsLastPatchHunkValid=0

    function IteratorPredicateFunc1_1()
    {
      local CurDirPath="$1"
      local InFilePath="$2"
      local OutFilePath="$3"
      local PatchHunkFileIndex="${4:-0}"
      local PatchHunkIndex="${5:-0}"
      local PatchHunkType="${6:-0}"

      GetShiftOffset 6 "$@" || shift $?

      local PatchType="$1"

      # validate previous hunk before continue with next one
      if (( IsPatchHunksBegan )); then
        IsLastPatchHunkValid="$(( OverallPatchHunks-PrevOverallPatchHunks == ValidPatchHunks-PrevValidPatchHunks ))"
        if (( ! IsLastPatchHunkValid && PatchInsertLinesInHunk == OverallPatchLinesInHunk )); then
          # previous hunk was purely file addition, not modification, so trait
          # a path to a patching file as valid even if a patching file does not exist 
          (( ValidPatchHunks++ ))
          (( LocalValidPatchHunks++ ))
        fi

        PrevValidPatchHunks="$ValidPatchHunks"
        PrevOverallPatchHunks="$OverallPatchHunks"
      fi

      PatchInsertLinesInHunk=0
      OverallPatchLinesInHunk=0
      IsPatchHunksBegan=1

      local IsFound=0
      local InFilePath="$InFilePath"

      if [[ -n "$InFilePath" ]]; then
        ConvertNativePathToBackend "$InFilePath"
        InFilePath="$RETURN_VALUE"
        if [[ "${InFilePath:0:1}" == '/' ]]; then
          [[ -f "$InFilePath" ]] && IsFound=1
        else
          InFilePath="$CurDirPath${CurDirPath:+/}$InFilePath"
          [[ -f "$InFilePath" ]] && IsFound=1
        fi
        if (( IsFound )); then
          [[ "${InFilePath//\\//}" == "$InFilePath" ]] || IsFound=0
        fi
      else
        case "$PatchType" in
          1) IsFound=1 ;; # nothing to check, empty file name treats as correct
        esac
      fi

      case "$PatchType" in
        0)
          if (( IsFound )); then
            (( ValidPatchHunks++ ))
            (( LocalValidPatchHunks++ ))
          fi
          (( OverallPatchHunks++ ))
          (( LocalOverallPatchHunks++ ))
          ;;

        1)
          (( IsFound )) && (( ValidExecFileInFiles++ ))
          ;;
      esac

      return 0
    }

    function IteratorPredicateFunc1_2()
    {
      # ignore until hunks begin
      (( IsPatchHunksBegan )) || return 0

      local PatchLine="$1"

      case "$PatchLine" in
        '+'*) (( PatchInsertLinesInHunk++ )) ;;
      esac

      (( OverallPatchLinesInHunk++ ))

      return 0
    }

    local PatchFilePath=""
    local PatchCurDirPath=""
    local PatchAttributes=""

    local PatchingFileInputPath=""
    local PatchingFileOutputPath=""
    local PatchingFileAttr=""

    local PatchFileAbsPath=""
    local PatchingFileInputAbsPath=""
    local PatchingFileOutputAbsPath=""

    local PatchFilePathPrint=""
    local PatchingFileInputPathPrint=""
    local PatchingFileOutputPathPrint=""

    local DoIgnoredFileInputPathAbsence
    local DoIgnoredFileOutputPathAbsence

    InitPatchIniFileIteratorVarsByParams "$@"

    local IsValid=0

    case "$1" in
      "*.patch:*")
        if [[ -n "$PatchFilePath" ]]; then
          if [[ -f "$PatchFileAbsPath" ]]; then
            PatchFileIterator "$PatchFilePath" "$PatchCurDirPath" IteratorPredicateFunc1_1 IteratorPredicateFunc1_2 0 0
            if (( IsPatchHunksBegan )); then
              IsLastPatchHunkValid="$(( OverallPatchHunks-PrevOverallPatchHunks == ValidPatchHunks-PrevValidPatchHunks ))"
              if (( ! IsLastPatchHunkValid && PatchInsertLinesInHunk == OverallPatchLinesInHunk )); then
                # previous hunk was purely file addition, not modification, so trait
                # a path to a patching file as valid even if a patching file does not exist 
                (( ValidPatchHunks++ ))
                (( LocalValidPatchHunks++ ))
              fi
              IsValid="$(( OverallPatchHunks-PrevOverallPatchHunks == ValidPatchHunks-PrevValidPatchHunks ))"
            else
              IsValid=1
            fi
            if (( IsValid )); then
              (( ValidPatchFiles++ ))
            fi
          fi

          echo "* $PatchFilePathPrint: "
          if (( IsValid )); then
            echo -n "  Ok         : "
          else
            echo -n "  Has errors : "
          fi
          echo "  $LocalValidPatchHunks of $LocalOverallPatchHunks hunk input/output paths in the patch is valid"
        fi
        (( OverallPatchFiles++ ))
        ;;

      "*:*")
        if [[ -n "$PatchFilePath" ]]; then
          if [[ -x "$PatchFileAbsPath" ]]; then
            if (( !DoIgnoredFileOutputPathAbsence )); then
              if [[ -n "$PatchingFileOutputPath" ]] && \
                { [[ -z "$PatchingFileInputPath" || -f "$PatchingFileInputAbsPath" ]] || (( DoIgnoredFileInputPathAbsence )); }; then
                PrevValidExecFileInputFiles="$ValidExecFileInFiles"
                IteratorPredicateFunc1_1 "$PatchCurDirPath" "$PatchingFileInputPath" "$PatchingFileOutputPath" 0 0 0 1
                IsValid="$(( ValidExecFileInFiles-PrevValidExecFileInputFiles ))"
              fi
            else
              (( IgnoredExecFileInFiles++ ))
            fi
          fi

          echo "* $PatchFilePathPrint: "
          if (( IsValid )); then
            if (( !DoIgnoredFileInputPathAbsence && !DoIgnoredFileOutputPathAbsence )); then
              echo -n "  Ok         : "
            else
              echo -n "  Ignored    : "
            fi
          else
            echo -n "  Has errors : "
          fi
          echo "  ${PatchingFileInputPath:+$PatchingFileInputPathPrint}${PatchingFileInputPath:+ }-> $PatchingFileOutputPathPrint"
        fi
        (( OverallExecFileInFiles++ ))
        ;;
    esac

    (( OverallExistingPatches++ ))

    return 0
  }

  PatchIniFileIterator "$TargetInputDirPath/patchlist.ini" IteratorPredicateFunc1
  echo ""

  echo "Overall $ValidPatchHunks of $OverallPatchHunks hunks including input/output path in $ValidPatchFiles of $OverallPatchFiles patch file(s) is valid"
  echo "Overall $ValidExecFileInFiles of $OverallExecFileInFiles executable file input path(s) is valid"
  echo "Overall $IgnoredExecFileInFiles of $OverallExecFileInFiles executable file input path(s) is ignored"
  echo ""

  if (( OverallPatchFiles == ValidPatchFiles && OverallExecFileInFiles == ValidExecFileInFiles+IgnoredExecFileInFiles )); then
    return 0
  fi
  
  return 1
}

function ApplyPatchIniFile()
{
  echo "Patching sources..."
  if [[ ! -f "$TargetInputDirPath/patchlist.ini" ]]; then
    ExitWithError 0 "$TargetScriptFileName: warning: \"$TargetInputDirPath/patchlist.ini\": patch list file is not found, nothing to patch."
  fi

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

  AppliedPatches=0
  OverallExistingPatches="${OverallExistingPatches:-0}"

  local DoUpdateOverallPatches=0
  (( OverallExistingPatches )) || DoUpdateOverallPatches=1

  function IteratorPredicateFunc()
  {
    local LastError=0
    local IFS

    local ExecArgsArr
    ExecArgsArr=()
    local PatchFilePath=""
    local PatchCurDirPath=""
    local PatchAttributes=""

    local PatchingFileInputPath=""
    local PatchingFileOutputPath=""
    local PatchingFileAttr=""

    local PatchFileAbsPath=""
    local PatchingFileInputAbsPath=""
    local PatchingFileOutputAbsPath=""

    local PatchFilePathPrint=""
    local PatchingFileInputPathPrint=""
    local PatchingFileOutputPathPrint=""

    local DoIgnoredFileInputPathAbsence
    local DoIgnoredFileOutputPathAbsence

    InitPatchIniFileIteratorVarsByParams "$@"

    case "$1" in
      "exec:*")
        MakeCommandLine '' 0:a "${ExecArgsArr[@]}"
        echo "* executing: $RETURN_VALUE"
        if [[ "$PatchCurDirPath" != "$PWD" ]]; then
          if pushd "$PatchCurDirPath" >/dev/null; then
            # set IFS to default before call any user functions
            IFS=$' \t\r\n'
            eval "${ExecArgsArr[@]}"
            LastError=$?
            popd >/dev/null
          else
            LastError=254
          fi
        else
          # set IFS to default before call any user functions
          IFS=$' \t\r\n'
          eval "${ExecArgsArr[@]}"
          LastError=$?
        fi
        if (( ! LastError )); then
          (( AppliedPatches++ ))
          echo "  executing: Done"
        else
          echo "  executing: Error: $LastError"
        fi
        ;;

      "*.patch:*")
        if [[ -n "$PatchFilePath" ]]; then
          echo "* $PatchFilePathPrint:
  $PatchingFileOutputPathPrint/*:"
          if [[ -f "$PatchFileAbsPath" ]]; then
            if [[ "$PatchCurDirPath" != "$PWD" ]]; then
              if pushd "$PatchCurDirPath" >/dev/null; then
                eval /bin/diffpat.exe -t -N $PatchAttributes -d '"$TargetOutputDirPath"' -i '"$PatchFilePath"'
                LastError=$?
                popd >/dev/null
              else
                LastError=254
              fi
            else
              eval /bin/diffpat.exe -t -N $PatchAttributes -d '"$TargetOutputDirPath"' -i '"$PatchFilePath"'
              LastError=$?
            fi
            if (( ! LastError )); then
              (( AppliedPatches++ ))
            fi
            (( DoUpdateOverallPatches && OverallExistingPatches++ ))
          else
            echo "  $PatchFilePathPrint: Not found"
          fi
        fi
        ;;

      "*:*")
        if [[ -n "$PatchFilePath" ]]; then
          echo "* $PatchFilePathPrint:
  $PatchingFileOutputPathPrint:"
          if [[ -x "$PatchFileAbsPath" ]]; then
            if [[ -n "$PatchingFileOutputPath" ]] && \
              [[ -z "$PatchingFileInputPath" || -f "$PatchingFileInputAbsPath" ]]; then
              if [[ "$PatchCurDirPath" != "$PWD" ]]; then
                if pushd "$PatchCurDirPath" >/dev/null; then
                  # set IFS to default before call any user scripts
                  IFS=$' \t\r\n'
                  "$PatchFilePath" "$PatchingFileInputPath" "$PatchingFileOutputPath" "$PatchingFileAttr"
                  LastError=$?
                  popd >/dev/null
                else
                  LastError=254
                fi
              else
                # set IFS to default before call any user scripts
                IFS=$' \t\r\n'
                "$PatchFilePath" "$PatchingFileInputPath" "$PatchingFileOutputPath" "$PatchingFileAttr"
                LastError=$?
              fi
              if (( ! LastError )); then
                (( AppliedPatches++ ))
                echo "  $PatchingFileOutputPathPrint: Done"
              else
                echo "  $PatchingFileOutputPathPrint: Error: $LastError"
              fi
            else
              if [[ -n "$PatchingFileInputPath" ]]; then
                echo "  $PatchingFileOutputPathPrint: Not found"
              else
                echo "  Input and output is not set."
              fi
            fi
            (( DoUpdateOverallPatches && OverallExistingPatches++ ))
          else
            echo "$PatchFilePathPrint: Not found or not an executable"
          fi
        fi
        ;;
    esac

    return $LastError
  }

  function IteratorPredicateOnErrorFunc()
  {
    ExitWithError 97 "$TargetScriptFileName: error: ($1) One or more patches failed to apply."
  }

  PatchIniFileIterator "$TargetInputDirPath/patchlist.ini" IteratorPredicateFunc IteratorPredicateOnErrorFunc

  if (( AppliedPatches != OverallExistingPatches )); then
    return 1
  fi

  return 0
}

function BackupRestoreSourcesBeforePatching()
{
  local DoRestoreOnly="${1:-0}"

  local LastError
  local TargetOutputParentDirPath="${TargetOutputDirPath%/*}"
  local TargetOutputDirName="${TargetOutputDirPath##*/}"

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

  GetRelativePathFromAbsolutePaths "$TargetOutputParentDirPath" "$BuildRootDirPath/Sources"
  local TargetOutputParentDirRelativePath="$RETURN_VALUE"

  local TargetBackupOutputParentDirPath="$TargetBackupDirPath/$TargetOutputParentDirRelativePath"
  if [[ ! -e "$TargetBackupDirPath/$TargetOutputParentDirRelativePath" ]]; then
    ExtractBackendPath "$TargetBackupDirPath/$TargetOutputParentDirRelativePath"
    local ExtractedTargetBackupOutputParentDirPath="$RETURN_VALUE"
    mkdir -p "$ExtractedTargetBackupOutputParentDirPath"
  fi

  local DoRestore=0
  if [[ -f "$TargetBackupDirPath/$TargetOutputParentDirRelativePath/$TargetOutputDirName.tar.bz2" ]]; then
    DoRestore=1
  fi
  if (( DoRestore )); then
    echo "Restoring file(s) which were patched before..."
    (
      pushd "$TargetBackupDirPath/$TargetOutputParentDirRelativePath" >/dev/null && \
      {
        if tar --no-same-permissions --overwrite -jxvf "$TargetOutputDirName.tar.bz2" -C "$TargetOutputParentDirPath"; then
          rm -vf "$TargetBackupDirPath/$TargetOutputParentDirRelativePath/$TargetOutputDirName.tar.bz2"
        else
          exit $?
        fi
      }
    )
    LastError=$?
    echo ""

    (( ! LastError )) || return $LastError
  fi

  (( DoRestoreOnly )) && return 0

  echo "Backuping files about to be patched..."

  if [[ ! -f "$TargetInputDirPath/patchlist.ini" ]]; then
    ExitWithError 0 "$TargetScriptFileName: warning: \"$TargetInputDirPath/patchlist.ini\": patch list file is not found, nothing to backup."
  fi

  local PatchingPaths
  PatchingPaths=()
  local ValidPatchHunks=0
  local OverallPatchHunks=0
  local ValidPatchFiles=0
  local OverallPatchFiles=0
  local ValidExecFileOutFiles=0
  local OverallExecFileOutFiles=0
  local DuplicatedExecFileOutFiles=0

  function IteratorPredicateFunc1()
  {
    local LastError=0
    function IteratorPredicateFunc1_1()
    {
      local CurDirPath="$1"
      local InFilePath="$2"
      local OutFilePath="$3"

      GetShiftOffset 6 "$@" || shift $?

      local PatchType="$1"

      local IsFound=0
      local RelativeOutFilePath="$OutFilePath"

      if [[ -n "$OutFilePath" ]]; then
        ConvertNativePathToBackend "$OutFilePath"
        OutFilePath="$RETURN_VALUE"
        if [[ "${OutFilePath:0:1}" == '/' ]]; then
          [[ -f "$OutFilePath" || -d "$OutFilePath" ]] && IsFound=1
        else
          OutFilePath="$CurDirPath${CurDirPath:+/}$OutFilePath"
          [[ -f "$OutFilePath" || -d "$OutFilePath" ]] && IsFound=1
        fi
      fi

      GetRelativePathFromAbsolutePaths "$OutFilePath" "$TargetOutputParentDirPath"
      local RelativeOutFilePath="${RETURN_VALUE:-"$OutFilePath"}"

      local i
      local EscapedPath
      local MayAppend=1

      if [[ -n "$RelativeOutFilePath" ]]; then
        # check if directory already includes other child directories and files, and if yes then
        # clean all found children because they will be doublicated by the tar packing behaviour
        EscapeString "$RelativeOutFilePath" '[](){}\|?*!@^&'
        EscapedPath="$RETURN_VALUE"
        CleanPArgsFromArray PatchingPaths "$EscapedPath/*"
        (( DuplicatedExecFileOutFiles += RETURN_VALUE ))
        for (( i=0; i<${#PatchingPaths[@]}; i++ )); do
          case "$RelativeOutFilePath" in
            "${PatchingPaths[i]}"/*)
              MayAppend=0
              break
              ;;
          esac
        done
        (( MayAppend )) && AppendItemToUArray PatchingPaths "$RelativeOutFilePath"
      else
        LastError=1
        return 1
      fi

      case "$PatchType" in
        0)
          (( IsFound )) && (( ValidPatchHunks++ ))
          (( OverallPatchHunks++ ))
          ;;

        1)
          if (( IsFound )); then
            if (( MayAppend )); then
              (( ValidExecFileOutFiles++ ))
            else
              (( DuplicatedExecFileOutFiles++ ))
            fi
          fi
          ;;
      esac

      if (( ! IsFound )); then
        echo "warning: file is not found: $RelativeOutFilePath"
      fi

      return 0
    }

    local PatchFilePath=""
    local PatchCurDirPath=""
    local PatchAttributes=""

    local PatchingFileInputPath=""
    local PatchingFileOutputPath=""
    local PatchingFileAttr=""

    local PatchFileAbsPath=""
    local PatchingFileInputAbsPath=""
    local PatchingFileOutputAbsPath=""

    local PatchFilePathPrint=""
    local PatchingFileInputPathPrint=""
    local PatchingFileOutputPathPrint=""

    InitPatchIniFileIteratorVarsByParams "$@"

    local PrevValidExecFileInputFiles
    local PrevValidPatchHunks
    local IsValid=0

    case "$1" in
      "*.patch:*")
        if [[ -n "$PatchFilePath" && -f "$PatchFileAbsPath" ]]; then
          PrevValidPatchHunks="$ValidPatchHunks"
          PatchFileIterator "$PatchFilePath" "$PatchCurDirPath" IteratorPredicateFunc1_1 '' '' 0
          IsValid="$(( ValidPatchHunks-PrevValidPatchHunks ))"
          if (( IsValid )); then
            (( ValidPatchFiles++ ))
          fi
        fi
        (( OverallPatchFiles++ ))
      ;;

      "*:*")
        if [[ -n "$PatchFilePath" && -x "$PatchFileAbsPath" ]]; then
          if [[ -n "$PatchingFileOutputPath" ]]; then
            IteratorPredicateFunc1_1 "$PatchCurDirPath" "$PatchingFileInputPath" "$PatchingFileOutputPath" '' '' 1
          fi
        fi
        (( OverallExecFileOutFiles++ ))
      ;;
    esac

    return $LastError
  }

  PatchIniFileIterator "$TargetInputDirPath/patchlist.ini" IteratorPredicateFunc1
  LastError=$?

  # cleanup paths
  GetExitingPaths "$TargetOutputParentDirPath" "${PatchingPaths[@]}"
  PatchingPaths=("${RETURN_VALUE[@]}")
  
  if (( "${#PatchingPaths[@]}" )); then
    (
      pushd "$TargetBackupDirPath/$TargetOutputParentDirRelativePath" >/dev/null && \
        tar --no-same-permissions -jcvf "$TargetOutputDirName.tar.bz2" -C "$TargetOutputParentDirPath" \
          "${PatchingPaths[@]}"
    )
  fi
  echo ""

  echo "Overall $ValidPatchHunks of $OverallPatchHunks hunk output path(s) in $ValidPatchFiles of $OverallPatchFiles patch file(s) is backuped"
  echo "Overall $ValidExecFileOutFiles of $OverallExecFileOutFiles executable file output path(s) is backuped"
  echo "Overall $DuplicatedExecFileOutFiles of $OverallExecFileOutFiles executable file output path(s) is duplicated and ignored"
  echo ""

  return $LastError
}
