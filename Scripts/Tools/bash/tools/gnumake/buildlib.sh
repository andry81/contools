#!/bin/bash_entry

# Author:   Andrey Dibrov (andry at inbox dot ru)

# Core build library, implements main functions for build scripts.

# Script can be ONLY included by "source" command.
[[ -n "$BASH" && (-z "$BASH_LINENO" || BASH_LINENO[0] -gt 0) && (-z "$SOURCE_CONTOOLS_BUILDLIB_SH" || SOURCE_CONTOOLS_BUILDLIB_SH -eq 0) ]] || return 0 || exit 0 # exit to avoid continue if the return can not be called

SOURCE_CONTOOLS_BUILDLIB_SH=1 # including guard

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
tkl_include_or_abort "$CONTOOLS_BASH_ROOT/funclib.sh"
tkl_include_or_abort "$CONTOOLS_BASH_ROOT/traplib.sh"
tkl_include_or_abort "$CONTOOLS_BASH_ROOT/synclib.sh"
tkl_include_or_abort "$CONTOOLS_BASH_ROOT/hashlib.sh"
tkl_include_or_abort "$CONTOOLS_BASH_ROOT/patchlib.sh"
tkl_include_or_abort "$CONTOOLS_BASH_ROOT/stringlib.sh"
tkl_include_or_abort "$CONTOOLS_BASH_ROOT/filelib.sh"
tkl_include_or_abort "$CONTOOLS_BASH_ROOT/mountdir.sh"
tkl_include_or_abort "$CONTOOLS_BASH_ROOT/unmountdir.sh"
tkl_include_or_abort "$CONTOOLS_BASH_ROOT/tools/gnumake/buildlibcomponents.sh"
if [[ "$OSTYPE" == "cygwin" ]]; then
  tkl_include_or_abort "$CONTOOLS_BASH_ROOT/tools/cygwin/cygver.sh"
fi

function InitializeBuildSystem()
{
  BuildSystemLongName="Gnu build system for Windows"
  BuildSystemShortName="GnuBuilds"
  BuildSystemHomePageUrl="sourceforge.net/projects/gnubuilds"
  BuildSystemMajorVersion=1
  BuildSystemMinorVersion=8
  BuildSystemRevisionVersion=0
  BuildSystemVerStr="$BuildSystemMajorVersion.$BuildSystemMinorVersion.$BuildSystemRevisionVersion"

  DefaultTrapsStackName="Default"

  LastError=0
  LastAssertLevelStr="info"
  UserInterrupted=0
  GccUsageVersion=0

  case "$OSTYPE" in
    "msys") WhichUtility='/bin/which' ;;
    *) WhichUtility='/bin/which.exe' ;;
  esac

  # cleanup shell options
  CleanupShopt

  # cleanup environment variables
  CleanupEnvVars

  # create OSTYPEPATH variable
  ExcludeOldPathFromPath OSTYPEPATH

  return 0
}

function InitializeTargetScript()
{
  SetSystemAttributes
}

function IsDebugging()
{
  if [[ -n "$_DEBUG" && $_DEBUG -ne 0 ]]; then
    return 1
  fi

  return 0
}

function BeginCompileSubShell
{
  CompileScriptProcId="$$"
  # register default handlers
  PushCompileExitHandler ""
  PushCompileInterruptHandler ""
}

function BeginTargetSubShell
{
  TargetScriptProcId="$$"
  # register default handlers
  PushTargetExitHandler ""
  PushTargetInterruptHandler ""
}

function BeginTargetStageSubShell
{
  # register default handlers
  PushTargetStageExitHandler ""
  PushTargetStageInterruptHandler ""
}

function OnTargetStageIntHandler()
{
  trap '' INT # disable any interruption while processing it

  UpdateLastErrorInRetCodeFile 254

  # Restore pipes
  exec 1>&-
  exec 2>&-
  exec 1>&3
  exec 2>&4

  # INT handler always calls before EXIT handler
  UserInterrupted=1
  GetTrapNum "$1" "$2"
  if (( ! $? && RETURN_VALUES[0] )); then
    EvalTargetStageIntBlock CallDefaultTrapHandler "$@"
  fi
  DefaultTargetStageIntHandler

  exit 254
}

function OnTargetStageExitHandler()
{
  local LastError="$?"

  trap '' INT # disable any interruption while processing it

  UpdateLastErrorInRetCodeFile "$LastError"

  GetTrapNum "$1" "$2"
  if (( ! $? && RETURN_VALUES[0] )); then
    if (( ! UserInterrupted )); then
      CallDefaultTrapHandler "$@"
    else
      EvalTargetStageIntBlock CallDefaultTrapHandler "$@"
    fi
  fi
  DefaultTargetStageExitHandler "$LastError"

  return 0
}

function OnTargetIntHandler()
{
  trap '' INT # disable any interruption while processing it

  UpdateLastErrorInRetCodeFile 254

  # Restore pipes
  exec 1>&-
  exec 2>&-
  exec 1>&3
  exec 2>&4

  # INT handler always calls before EXIT handler
  UserInterrupted=1
  GetTrapNum "$1" "$2"
  if (( ! $? && RETURN_VALUES[0] )); then
    EvalTargetIntBlock CallDefaultTrapHandler "$@"
  fi
  DefaultTargetIntHandler

  exit 254
}

function OnTargetExitHandler()
{
  local LastError="$?"

  trap '' INT # disable any interruption while processing it

  UpdateLastErrorInRetCodeFile "$LastError"

  # Restore pipes
  GetTrapNum "$1" "$2"
  if (( ! $? && RETURN_VALUES[0] )); then
    if (( ! UserInterrupted )); then
      EvalTargetExitBlock CallDefaultTrapHandler "$@"
    else
      EvalTargetIntBlock CallDefaultTrapHandler "$@"
    fi
  fi
  DefaultTargetExitHandler "$LastError"

  return 0
}

function OnCompileIntHandler()
{
  trap '' INT # disable any interruption while processing it

  UpdateLastErrorInRetCodeFile 254

  # Restore pipes
  exec 1>&-
  exec 2>&-
  exec 1>&3
  exec 2>&4

  # INT handler always calls before EXIT handler
  UserInterrupted=1
  GetTrapNum "$1" "$2"
  if (( ! $? && RETURN_VALUES[0] )); then
    EvalCompileIntBlock CallDefaultTrapHandler "$@"
  fi
  DefaultCompileIntHandler

  exit 254
}

function OnCompileExitHandler()
{
  local LastError="$?"

  trap '' INT # disable any interruption while processing it

  UpdateLastErrorInRetCodeFile "$LastError"

  GetTrapNum "$1" "$2"
  if (( ! $? && RETURN_VALUES[0] )); then
    if (( ! UserInterrupted )); then
      CallDefaultTrapHandler "$@"
    else
      EvalCompileIntBlock CallDefaultTrapHandler "$@"
    fi
  fi
  DefaultCompileExitHandler "$LastError"

  return 0
}

function DefaultCompileExitHandler()
{
  EndCompile
  return 0
}

function DefaultTargetExitHandler()
{
  EndTarget
  return 0
}

function DefaultTargetStageExitHandler()
{
  EndTargetStage
  return 0
}

function DefaultCompileIntHandler()
{
  return 0
}

function DefaultTargetIntHandler()
{
  return 0
}

function DefaultTargetStageIntHandler()
{
  return 0
}

function PushCompileExitHandler()
{
  PushTrapHandler "$DefaultTrapsStackName" 'OnCompileExitHandler' "$@" '' EXIT
}

function PushTargetExitHandler()
{
  PushTrapHandler "$DefaultTrapsStackName" 'OnTargetExitHandler' "$@" '' EXIT
}

function PushTargetStageExitHandler()
{
  PushTrapHandler "$DefaultTrapsStackName" 'OnTargetStageExitHandler' "$@" '' EXIT
}

function PushCompileInterruptHandler()
{
  PushTrapHandler "$DefaultTrapsStackName" 'OnCompileIntHandler' "$@" '' INT
}

function PushTargetInterruptHandler()
{
  PushTrapHandler "$DefaultTrapsStackName" 'OnTargetIntHandler' "$@" '' INT
}

function PushTargetStageInterruptHandler()
{
  PushTrapHandler "$DefaultTrapsStackName" 'OnTargetStageIntHandler' "$@" '' INT
}

function SyncStdoutStderr()
{
  tkl_wait 10
}

function EvalTargetStageIntBlock()
{
  # Always run in subshell to trap EXIT
  (
  (
  (
  SyncStdoutStderr # give a moment to initialize executables on stdout pipe before executables on stderr pipe
  (
    eval "$@"
  ) 2>&1 >&5 | tee -a "$TargetStageLogErrFilePath" | "$CONTOOLS_ROOT/bash/tee2.sh" -6 >&8
  ) 5>&1 | "$CONTOOLS_ROOT/bash/tee2.sh" -7 >&9
  ) 6>&1 7>&1 | tee -a "$TargetStageFullLogFilePath" | tee -a "$CompileFullLogFileName" >/dev/null
  ) 8>&1 9>&2
}

function EvalTargetStageBlock()
{
  SetTargetStage "$1"

  local LastError

  # Always run in subshell to trap EXIT
  (
  (
  (
  SyncStdoutStderr # give a moment to initialize executables on stdout pipe before executables on stderr pipe
  (
    BeginTargetStage
    shift
    eval "$@"
    LastError="$?"
    echo ""
    exit "$LastError"
  ) 2>&1 >&5 | tee -a "$TargetStageLogErrFilePath" | "$CONTOOLS_ROOT/bash/tee2.sh" -6 >&8 # temporary redirect stdout to the steam descriptor 8
  ) 5>&1 | "$CONTOOLS_ROOT/bash/tee2.sh" -7 >&9 # temporary redirect stdout (which is redirected stderr here) to the steam descriptor 9
  ) 6>&1 7>&1 | tee -a "$TargetStageFullLogFilePath" >/dev/null # redirect cloned stdout/stderr output to files
  ) 8>&1 9>&2 # redirect the stream descriptors 8 and 9 back to stdout and stderr

  TargetStageBlockExit

  return $?
}

function EvalTargetIntBlock()
{
  # Always run in subshell to trap EXIT
  (
  (
  (
  SyncStdoutStderr # give a moment to initialize executables on stdout pipe before executables on stderr pipe
  (
    eval "$@"
  ) 2>&5 | "$CONTOOLS_ROOT/bash/tee2.sh" -6 >&8 # temporary redirect stdout to the steam descriptor 8
  ) 5>&1 | "$CONTOOLS_ROOT/bash/tee2.sh" -7 >&9 # temporary redirect stdout (which is redirected stderr here) to the steam descriptor 9
  ) 6>&1 7>&1 | tee -a "$CompileFullLogFileName" | tee -a "$CompileLogStatsFileName" >/dev/null # redirect cloned stdout/stderr output to files
  ) 8>&1 9>&2 # redirect the stream descriptors 8 and 9 back to stdout and stderr
}

function EvalTargetExitBlock()
{
  # Always run in subshell to trap EXIT
  (
  (
  (
  SyncStdoutStderr # give a moment to initialize executables on stdout pipe before executables on stderr pipe
  (
    eval "$@" || exit $?
  ) 2>&5 | "$CONTOOLS_ROOT/bash/tee2.sh" -6 >&8 # temporary redirect stdout to the steam descriptor 8
  ) 5>&1 | "$CONTOOLS_ROOT/bash/tee2.sh" -7 >&9 # temporary redirect stdout (which is redirected stderr here) to the steam descriptor 9
  ) 6>&1 7>&1 | tee -a "$CompileLogStatsFileName" >/dev/null # redirect cloned stdout/stderr output to files
  ) 8>&1 9>&2 # redirect the stream descriptors 8 and 9 back to stdout and stderr
}

function EvalCompileIntBlock()
{
  # Always run in subshell to trap EXIT
  (
  (
  (
  SyncStdoutStderr # give a moment to initialize executables on stdout pipe before executables on stderr pipe
  (
    eval "$@"
  # Copy streams stdout and stderr to stream descriptors 4 and 5 to later redirect
  # them back to stdout and stderr. This is useful if you want copy all output
  # from stdout and stderr streams in one file without redirecting stderr to
  # stdout.
  ) 2>&5 | "$CONTOOLS_ROOT/bash/tee2.sh" -6 >&8 # temporary redirect stdout to the steam descriptor 8
  ) 5>&1 | "$CONTOOLS_ROOT/bash/tee2.sh" -7 >&9 # temporary redirect stdout (which is redirected stderr here) to the steam descriptor 9
  ) 6>&1 7>&1 | tee -a "$CompileFullLogFileName" >/dev/null # redirect cloned stdout/stderr output to files
  ) 8>&1 9>&2 # redirect the stream descriptors 8 and 9 back to stdout and stderr
}

function EvalCompileBlock()
{
  # Always run in subshell to trap EXIT
  (
  (
  (
  SyncStdoutStderr # give a moment to initialize executables on stdout pipe before executables on stderr pipe
  (
    BeginCompile
    eval "$@" || exit $?
  # Copy streams stdout and stderr to stream descriptors 4 and 5 to later redirect
  # them back to stdout and stderr. This is useful if you want copy all output
  # from stdout and stderr streams in one file without redirecting stderr to
  # stdout.
  ) 2>&5 | "$CONTOOLS_ROOT/bash/tee2.sh" -6 >&8 # temporary redirect stdout to the steam descriptor 8
  ) 5>&1 | "$CONTOOLS_ROOT/bash/tee2.sh" -7 >&9 # temporary redirect stdout (which is redirected stderr here) to the steam descriptor 9
  ) 6>&1 7>&1 | tee -a "$CompileFullLogFileName" >/dev/null # redirect cloned stdout/stderr output to files
  ) 8>&1 9>&2 # redirect the stream descriptors 8 and 9 back to stdout and stderr

  CompileBlockExit
}

function MakeBaseRedirections()
{
  #IsDebugging
  #if (( $? )); then
  #  exec 3<> "$CompileLogDbgFileName"
  #fi
  exec 3>&1 # duplicate stdout descriptor in case of redirection to a broken pipe
  exec 4>&2 # duplicate stderr descriptor in case of redirection to a broken pipe
}

function SetTargetStage()
{
  TargetStageName="$1"
  SetTargetStageBeginTime

  local TargetStageBuildIndexStr="$TargetStageBuildIndex"
  (( TargetStageBuildIndexStr++ ))
  if (( TargetStageBuildIndexStr < 10 )); then
    TargetStageBuildIndexStr="0$TargetStageBuildIndexStr"
  fi
  TargetStageDirName="${TargetStageBuildIndexStr}_$TargetStageName"
  TargetStageLogOutDirPath="$TargetLogOutDirPath/$TargetStageDirName"

  # Convert system paths which used by native console utilities in to native paths.
  if [[ -n "$TargetStageLogOutDirPath" ]]; then
    ConvertNativePathToBackend "$TargetStageLogOutDirPath"
    TargetStageLogOutDirPath="$RETURN_VALUE"
  fi

  TargetStageLogOutFilePath="$TargetStageLogOutDirPath/$ProjectName${ProjectName:+"-"}$ProjectPlatformType${ProjectPlatformType:+"-"}$TargetName${TargetName:+"-"}$TargetStageName.1.log"
  TargetStageLogErrFilePath="$TargetStageLogOutDirPath/$ProjectName${ProjectName:+"-"}$ProjectPlatformType${ProjectPlatformType:+"-"}$TargetName${TargetName:+"-"}$TargetStageName.2.log"
  TargetStageLogOutIndexFilePath="$TargetStageLogOutDirPath/$ProjectName${ProjectName:+"-"}$ProjectPlatformType${ProjectPlatformType:+"-"}$TargetName${TargetName:+"-"}$TargetStageName.index.1.log"
  TargetStageLogErrIndexFilePath="$TargetStageLogOutDirPath/$ProjectName${ProjectName:+"-"}$ProjectPlatformType${ProjectPlatformType:+"-"}$TargetName${TargetName:+"-"}$TargetStageName.index.2.log"
  TargetStageDbgFilePath="$TargetStageLogOutDirPath/$ProjectName${ProjectName:+"-"}$ProjectPlatformType${ProjectPlatformType:+"-"}$TargetName${TargetName:+"-"}$TargetStageName.3.log"
  TargetStageFullLogFilePath="$TargetStageLogOutDirPath/$ProjectName${ProjectName:+"-"}$ProjectPlatformType${ProjectPlatformType:+"-"}$TargetName${TargetName:+"-"}$TargetStageName.full.log"

  # For utilities which consumes only native paths
  if [[ -n "$TargetStageLogOutIndexFilePath" ]]; then
    ConvertBackendPathToNative "$TargetStageLogOutIndexFilePath"
    TargetStageLogOutIndexNativeFilePath="$RETURN_VALUE"
  fi
  if [[ -n "$TargetStageLogErrIndexFilePath" ]]; then
    ConvertBackendPathToNative "$TargetStageLogErrIndexFilePath"
    TargetStageLogErrIndexNativeFilePath="$RETURN_VALUE"
  fi

  CreateTargetStageLogDirs
  BackupTargetStageLogFiles

  (( TargetStageBuildIndex++ ))
}

function SetCompileBeginTime()
{
  CompileBeginTime="$(date "+%s")"
}

function SetCompileEndTime()
{
  CompileEndTime="$(date "+%s")"
  (( CompileSpentTime=CompileEndTime-CompileBeginTime ))
}

function SetTargetBeginTime()
{
  TargetBeginTime="$(date "+%s")"
}

function SetTargetEndTime()
{
  TargetEndTime="$(date "+%s")"
  (( TargetSpentTime=TargetEndTime-TargetBeginTime ))
}

function SetTargetStageBeginTime()
{
  TargetStageBeginTime="$(date "+%s")"
}

function SetTargetStageEndTime()
{
  TargetStageEndTime="$(date "+%s")"
  (( TargetStageSpentTime=TargetStageEndTime-TargetStageBeginTime ))
}

function UpdateLastErrorInRetCodeFile()
{
  local LastError="${1:-0}"

  echo -n "$LastError" > "$ProjectScriptReturnCodeFile"
}

function UpdateProjectScriptReturnParamsFile()
{
  tkl_make_command_line '' 1 "$@"
  echo "$RETURN_VALUE" > "$ProjectScriptReturnParamsFile"
}

function RemoveProjectScriptReturnCodeFile()
{
  rm -f "$ProjectScriptReturnCodeFile"
}

function RemoveProjectScriptReturnParamsFile()
{
  rm -f "$ProjectScriptReturnParamsFile"
}

function ExitWithError()
{
  local ErrorCode="$1"
  # if flag is set and string is not empty then show error message
  if [[ -n "$2" ]]; then
    sleep 1 # give a moment to complete printing to the stdout (suppress stdout/stderr reordering in the tty)
    echo "$2"$'\n' >&2
  fi

  # store last error in the file
  UpdateLastErrorInRetCodeFile "${ErrorCode:-"0"}"

  exit ${ErrorCode:-"0"}
}

function ExitIfError()
{
  # Exit immediately if user interruption
  (( ! UserInterrupted )) || exit 255

  LastError=0

  local IFS=$' \t' # enables read string line into multiple variables
  read -r LastError < "$ProjectScriptReturnCodeFile"

  LastError=${LastError:-0}
  (( ! LastError )) || exit $LastError
}

function IsTargetStageExitCodeIgnored()
{
  local LastError="${1:-0}"

  if (( LastError )); then
    case "$TargetStageName" in
      test* | bench* | stresstest*)
        if (( DoRunTarget != 2 )); then
          return 0
        fi
        ;;
    esac
  else
    return 1
  fi

  return 2
}

function IsTargetExitCodeIgnored()
{
  local LastError="${1:-0}"

  if (( LastError )); then
    case "$TargetName" in
      test* | bench* | stresstest*)
        if (( DoRunTarget != 2 )); then
          return 0
        fi
        ;;
    esac
  else
    return 1
  fi

  return 2
}

function TargetStageBlockExit()
{
  # Exit immediately if user interruption
  (( ! UserInterrupted )) || exit 255

  local LastError
  local IFS=$' \t' # enables read string line into multiple variables

  read -r LastError < "$ProjectScriptReturnCodeFile"
  LastError=${LastError:-0}

  if (( LastError )); then
    # supress if required the exit codes only for predefined set of target stages
    IsTargetStageExitCodeIgnored "$LastError" || exit $LastError
  fi

  return 0
}

function TargetBlockExit()
{
  local LastError
  local IFS=$' \t' # enables read string line into multiple variables

  read -r LastError < "$ProjectScriptReturnCodeFile"
  LastError=${LastError:-0}

  if (( LastError )); then
    # supress if required the exit codes only for predefined set of target stages
    IsTargetExitCodeIgnored "$LastError" || return $LastError
  fi

  return 0
}

function CompileBlockExit()
{
  ExitIfError
}

function CleanupShopt()
{
  local shoptState

  tkl_disable_nocase_match # by default - nocase match

  # disable compatability with v3.1
  if (( BASH_VERSINFO[0] > 3 || BASH_VERSINFO[0] == 3 && BASH_VERSINFO[1] >= 2 )); then
    shoptState="$(shopt -p nocasematch)"
    if (( ! $? )); then
      if [[ "$shoptState" != "shopt -s compat31" ]]; then
        shopt -s compat31
        return 0
      fi
    fi
  fi

  return 0
}

function CleanupEnvVars()
{
  PATH="`echo "$PATH" | /bin/tr '[:upper:]' '[:lower:]'`"
  OLDPATH="`echo "$OLDPATH" | /bin/tr '[:upper:]' '[:lower:]'`"
  TEMP="`echo "$TEMP" | /bin/tr '[:upper:]' '[:lower:]'`"
  TMP="`echo "$TMP" | /bin/tr '[:upper:]' '[:lower:]'`"
  CONTOOLS_ROOT="`echo "$CONTOOLS_ROOT" | /bin/tr '[:upper:]' '[:lower:]'`"

  ConvertNativePathListToBackend "$PATH"
  PATH="$RETURN_VALUE"
  ConvertNativePathListToBackend "$OLDPATH"
  OLDPATH="$RETURN_VALUE"
  ConvertNativePathListToBackend "$CONTOOLS_ROOT"
  CONTOOLS_ROOT="$RETURN_VALUE"

  RemoveRelativePathsFromPathListVariable PATH
  RemoveRelativePathsFromPathListVariable OLDPATH

  # Cleanup and reset locale to avoid potential problems with sort, grep and string comparison.
  # Set these variable explicitly from the build system environment to alter behaviour.
  unset LANG
  export LC_COLLATE=C
  export LC_ALL=C
}

function GetVerStrFromArr()
{
  # drop return value
  RETURN_VALUE=""

  for arg in "$@"; do
    RETURN_VALUE="$RETURN_VALUE${RETURN_VALUE:+"."}${arg:-"0"}"
  done

  return 0
}

function GetProjectRuntimeId()
{
  # drop return value
  RETURN_VALUE=""

  local VersionString=""
  local NewVersionArr
  NewVersionArr=()
  local IFS=$' \t'

  case "$OSTYPE" in
    "msys")
      VersionString="$(/bin/uname.exe -r)"
    ;;
    "cygwin")
      VersionString="$(/bin/cygcheck.exe -c cygwin | grep -E -e "^cygwin.*")"
      NewVersionArr=(${VersionString[*]})
      VersionString="${NewVersionArr[1]}"
    ;;
    *)
      return 1
    ;;
  esac

  VersionString="${VersionString%% *}"
  VersionString="${VersionString%%(*}"

  NewVersionArr=()

  IFS='.'
  local SubVersionArr
  local NewVersionArrSize=0
  local VersionArr=(${VersionString[*]})
  local VersionArrSize=${#VersionArr[@]}
  local i
  for (( i=0; i < VersionArrSize; i++ )); do
    IFS='-'
    SubVersionArr=(${VersionArr[i]})
    NewVersionArr=("${NewVersionArr[@]}" "${SubVersionArr[@]}")
  done

  IFS='_'
  RETURN_VALUE="${OSTYPE}_${NewVersionArr[*]}"

  return 0
}

function SetSystemAttributes()
{
  case "$OSTYPE" in
    "msys") SystemBinPath="/mingw/bin" ;;
    *) SystemBinPath="/bin" ;;
  esac
}

function MergeTargetStageLogs()
{
  if [[ -n "$TargetStageName" ]]; then
    echo "Merging stage \"$TargetStageName\" logs..."
    "$CONTOOLS_ROOT/bash/print_merged_logs.sh" \
      "$TargetStageLogOutFilePath" \
      "$TargetStageLogErrFilePath" \
      "$TargetStageLogOutIndexFilePath" \
      "$TargetStageLogErrIndexFilePath" > \
        "$TargetStageFullLogFilePath"
  fi
}

function CollectLogStats()
{
  # drop return value
  RETURN_VALUE=""

  [[ -n "$1" ]] || return 1

  local TargetFilePath="`/bin/readlink.exe -f "$1"`"
  local TargetDirPath="${TargetFilePath%[/]*}"
  local TargetFileName="${TargetFilePath##*[/]}"

  local StatsType="$2"

  case "$StatsType" in
    "w")
      local MatchPattern1=\
'warning:|WARNING:[ \t][^=]|([^\r\n]+)WARNING:[ \t]===[ \t][^\r\n]+([\r\n]\1WARNING:[ \t]===[ \t][^\r\n]+)*|'\
'xgcc: unrecognized option'

      local Warnings="`cat "$TargetFilePath" |\
        /bin/perl.exe "$CONTOOLS_ROOT/sar.pl" m "$MatchPattern1" '$main::i++' gmsx '$main::i=0' 'print "$main::i"'`"

      RETURN_VALUE="${Warnings:-0}"
    ;;

    "e")
      local MatchPattern1=\
'error:|ERROR:|make: \*\*\*[[:space:]]+[^[:space:]]+[[:space:]]+Error[[:space:]]+'

      local Errors="`cat "$TargetFilePath" |\
        /bin/perl.exe "$CONTOOLS_ROOT/sar.pl" m "$MatchPattern1" '$main::i++' gmsx '$main::i=0' 'print "$main::i"'`"

      RETURN_VALUE="${Errors:-0}"
    ;;

    "p")
      local MatchPattern1=\
'(\d+) of \d+ patches applied.'

      local Patches="`cat "$TargetFilePath" |\
        /bin/perl.exe "$CONTOOLS_ROOT/sar.pl" m "$MatchPattern1" '$main::i++' gmsx '$main::i=0' 'print "$main::i"'`"

      RETURN_VALUE="${Patches:-0}"
    ;;
  esac

  return 0
}

function PrintCompileStatus()
{
  if (( UserInterrupted )); then
    echo $'\n'"*** Compilation of \"$ProjectPath/$ProjectPlatformType\" is interrupted by user."
  else
    if (( ! LastError )); then
      echo "*** Compilation of \"$ProjectPath/$ProjectPlatformType\" is succeed."
    else
      echo "*** Compilation of \"$ProjectPath/$ProjectPlatformType\" is failed ($LastError)."
    fi
  fi
}

function PrintCompileStats()
{
  GetTimeAsString $CompileSpentTime
  local CompileSpentTimeStr="$RETURN_VALUE"

  echo "---------------------------------------
    Spent time: $CompileSpentTimeStr
---------------------------------------
"
}

function PrintTargetStatus()
{
  if (( UserInterrupted )); then
    echo $'\n'"*** Target \"$ProjectPath/$ProjectPlatformType/$TargetName\" is interrupted by user."
  else
    if (( ! LastError )); then
      if (( DoRunTarget > 0 )); then
        echo "*** Target \"$ProjectPath/$ProjectPlatformType/$TargetName\" is succeed."
      elif (( ! DoRunTarget )); then
        echo "*** Target \"$ProjectPath/$ProjectPlatformType/$TargetName\" already has been run, ignored."
      else
        echo "*** Target \"$ProjectPath/$ProjectPlatformType/$TargetName\" is excluded from the run."
      fi
    elif ! IsTargetExitCodeIgnored "$LastError"; then
      echo "*** Target \"$ProjectPath/$ProjectPlatformType/$TargetName\" is failed ($LastError)."
    else
      echo "*** Target \"$ProjectPath/$ProjectPlatformType/$TargetName\" is failed ($LastError) but ignored."
    fi
  fi
}

function PrintTargetStats()
{
  GetTimeAsString $TargetSpentTime
  local TargetSpentTimeStr="$RETURN_VALUE"

  echo "---------------------------------------
    Spent time: $TargetSpentTimeStr
---------------------------------------
"
}

function PrintTargetStageStatus()
{
  if (( UserInterrupted )); then
    echo $'\n'"*** Target stage \"$ProjectPath/$ProjectPlatformType/$TargetName/$TargetStageName\" is interrupted by user."
  else
    if (( ! LastError )); then
      echo "*** Target stage \"$ProjectPath/$ProjectPlatformType/$TargetName/$TargetStageName\" is succeed."
    elif ! IsTargetStageExitCodeIgnored "$LastError"; then
      echo "*** Target stage \"$ProjectPath/$ProjectPlatformType/$TargetName/$TargetStageName\" is failed ($LastError)."
    else
      echo "*** Target stage \"$ProjectPath/$ProjectPlatformType/$TargetName/$TargetStageName\" is failed ($LastError) but ignored."
    fi
  fi
}

function PrintTargetStageStats()
{
  local PrintErrorStats=0
  local NumErrorsStr="*"
  local NumWarningsStr="*"

  if [[ -f "$TargetStageLogErrFilePath" ]]; then
    case "$TargetStageName" in
      "patch") ;;
      *)
        CollectLogStats "$TargetStageLogErrFilePath" e
        NumErrorsStr="$RETURN_VALUE"
        CollectLogStats "$TargetStageLogErrFilePath" w
        NumWarningsStr="$RETURN_VALUE"
        PrintErrorStats=1
      ;;
    esac
  fi

  GetTimeAsString $TargetStageSpentTime
  local TargetStageSpentTimeStr="$RETURN_VALUE"

  echo "---------------------------------------"
  case "$TargetStageName" in
    "patch")
      echo \
"    Applied patches : ${AppliedPatches:-0}
    Overall patches : ${OverallExistingPatches:-0}
"
    ;;

    *)
      if (( PrintErrorStats )); then
        echo \
"    Errors          : $NumErrorsStr
    Warnings        : $NumWarningsStr
"
      fi
    ;;
  esac
  echo "    Spent time      : $TargetStageSpentTimeStr
---------------------------------------
"
}

function BeginCompile()
{
  SetCompileBeginTime
  BeginCompileSubShell
  UpdateLastErrorInRetCodeFile 255
  PushCompileExitHandler "ProjectCompileExitHandler"
  PushCompileInterruptHandler "ProjectCompileIntHandler"
  PushTrap "$DefaultTrapsStackName" '' PIPE # ignore any miswrites to closed pipes
}

function EndCompile()
{
  return 0
}

function BeginProjectCompile()
{
  eval ProjectCompileTime=\"$ProjectCompileEvalTime\"
}

function BeginTarget()
{
  SetTargetBeginTime
  BeginTargetSubShell
  TargetStageName=""
  TargetStageBuildIndex=0
  DoRunTarget=0
  UpdateLastErrorInRetCodeFile 255
  PushTargetExitHandler "ProjectTargetExitHandler"
  PushTargetInterruptHandler "ProjectTargetIntHandler"
  PushTrap "$DefaultTrapsStackName" '' PIPE # ignore any miswrites to closed pipes
}

function EndTarget()
{
  return 0
}

function BeginTargetStage()
{
  BeginTargetStageSubShell
  UpdateLastErrorInRetCodeFile 255
  PushTargetStageExitHandler "ProjectTargetStageExitHandler"
  PushTargetStageInterruptHandler "ProjectTargetStageIntHandler"
  PushTrap "$DefaultTrapsStackName" '' PIPE # ignore any miswrites to closed pipes

  echo "*** Beginning the \"$ProjectPath/$ProjectPlatformType/$TargetName/$TargetStageName\" target stage..."

  CreateTargetCurrentDir
  ChangeCurDirToTargetCurrentDir
}

function EndTargetStage()
{
  TargetStageName=""
}

function MakeLogsPackage()
{
  local PackingAbsDirPath="$1"
  local ArchiveAbsDirPath="$2"
  local ArchiveNameSuffix="$3"
  local DoCleanupAfterPack="${4:-0}"

  [[ "${PackingAbsDirPath:0:1}" == '/' ]] || return 1
  [[ "${ArchiveAbsDirPath:0:1}" == '/' ]] || return 2

  if [[ -f "$PackingAbsDirPath/$ProjectName-$ProjectPlatformType.full.log" ]]; then
    echo "* Making logs package..."
    (
      MakeDir -p "$ArchiveAbsDirPath" && \
      pushd "$RETURN_VALUE" >/dev/null && \
      {
        local TarFiles
        TarFiles=()
        [[ ! -d "$PackingAbsDirPath/$ProjectPlatformType" ]] || \
          TarFiles[${#TarFiles[@]}]="$ProjectPlatformType"
        TarFiles[${#TarFiles[@]}]="$ProjectName-$ProjectPlatformType.full.log"
        [[ ! -f "$PackingAbsDirPath/$ProjectName-$ProjectPlatformType.stats.log" ]] || \
          TarFiles[${#TarFiles[@]}]="$ProjectName-$ProjectPlatformType.stats.log"
        [[ ! -f "$PackingAbsDirPath/$ProjectName-$ProjectPlatformType.full.log.bak" ]] || \
          TarFiles[${#TarFiles[@]}]="$ProjectName-$ProjectPlatformType.full.log.bak"
        [[ ! -f "$PackingAbsDirPath/$ProjectName-$ProjectPlatformType.stats.log.bak" ]] || \
          TarFiles[${#TarFiles[@]}]="$ProjectName-$ProjectPlatformType.stats.log.bak"
        tar --no-same-permissions --hard-dereference -h -jcf "$ProjectName-$ProjectPlatformType${ArchiveNameSuffix:+-}$ArchiveNameSuffix.logs.$PackageArchiveExt" \
          -C "$PackingAbsDirPath" "${TarFiles[@]}" && (( DoCleanupAfterPack )) && \
          {
            local arg
            local FilePath
            for arg in "${TarFiles[@]}"; do
              FilePath="$PackingAbsDirPath/$arg"
              if [[ -f "$FilePath" ]]; then
                rm -f "$FilePath"
              elif [[ -d "$FilePath" ]]; then
                CleanupDir "$FilePath" && rmdir --ignore-fail-on-non-empty "$FilePath"
              fi
            done
          }
      }
    )
    echo ""
  fi

  return 0
}

function Assert()
{
  local AssertLevel="${1:-0}"
  local Message="$2"

  if (( ! AssertLevel )); then
    local AssertLevelStr="warning"
  else
    local AssertLevelStr="error"
  fi

  Message="`echo "$Message" | /bin/sed.exe -e "s/%ASSERT_LEVEL_STR%/$AssertLevelStr/g"`"

  if (( ! AssertLevel )); then
    echo "$Message" >&2
    sleep 1 # sync to print stderr before next stdout
  else
    ExitWithError 50 "$Message"
  fi
}

function GetAppPath()
{
  GetFilePath "$1"
}

function ExcludeOldPathFromPath()
{
  local VarName="$1"

  local LastError
  local NewPath=""
  local IsFound
  local ch

  local IFS=':'
  for arg1 in $PATH; do
    IsFound=0
    for arg2 in $OLDPATH; do
      FindString "${arg1:0:${#arg2}}" "$arg2" -i
      LastError=$?
      cn="${arg1:${#arg2}:1}"
      if (( ! LastError )); then
        if (( ! RETURN_VALUE )) && [[ -z "$cn" || "$cn" == '/' ]]; then
          IsFound=1
          break
        fi
      fi
    done
    if (( ! IsFound )); then
      NewPath="$NewPath${NewPath:+${arg1:+:}}$arg1"
    fi
  done

  eval "$VarName=\"\$NewPath\""

  return 0
}

# All search paths in PATH and OLDPATH should be absolute!
function SearchAppDependencies()
{
  # Relation between search path variables:
  #
  # Before the project setups it's own search path variables:
  #   OSTYPEPATH=PATH-OLDPATH
  # After the project setups it's own search path variables:
  #   DEPSPATH=PATH-OLDPATH
  #

  local AppDirPath="$1"
  local FromDirPath="${2:-"$AppDirPath"}"
  local Extensions="${3:-exe dll so}"
  eval declare "ReturnArrs=($4)"

  [[ -d "$AppDirPath" ]] || return 1

  shift 4

  local IFS

  local AppLogPaths
  local AppLogPathsToUse
  AppLogPaths=("$@")
  AppLogPathsToUse=()

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

  GetAbsolutePathFromDirPath "$AppDirPath"
  local AppAbsDirPath="$RETURN_VALUE"

  # just in case of empty
  local AppRelativeDirPath=""
  if [[ -n "$BuildRootDirPath" ]]; then
    GetRelativePathFromAbsolutePaths "$AppAbsDirPath" "$BuildRootDirPath"
    AppRelativeDirPath="$RETURN_VALUE"
  fi

  local AppPath="${AppRelativeDirPath:-"$AppAbsDirPath"}"

  local FilePath
  local FileName
  local FileDirPath
  local FromCurDir
  local FileSize
  local CksumArr
  local Crc32Value=""
  local Md5Value=""
  local Sha1Value=""
  local FileNameMaxLen
  local FileNameHeader
  local FileNameHeaderAligner
  local arg
  local i0
  local i1
  local j0
  local j1

  local Padding10="          "
  local Padding40="                                        "

  # all file path directories should exist
  for arg in "${AppLogPaths[@]}"; do
    if [[ -f "$arg" ]]; then
      echo -n "" > "$arg"
      AppLogPathsToUse[${#AppLogPathsToUse[@]}]="$arg"
    else
      FilePath="`/bin/readlink.exe -f "$arg"`"
      FileDirPath="${FilePath%[/]*}"
      if [[ -d "$FileDirPath" ]]; then
        echo -n "" > "$FilePath"
        AppLogPathsToUse[${#AppLogPathsToUse[@]}]="$FilePath"
      else
        AppLogPathsToUse[${#AppLogPathsToUse[@]}]=""
      fi
    fi
  done

  local AppPathVarsListFilePath="${AppLogPathsToUse[0]}"
  local AppFilesListFilePath="${AppLogPathsToUse[1]}"
  local AppFileFirstDepsTreeFilePath="${AppLogPathsToUse[2]}"
  local AppMatchedFileDepsListFilePath_APPPATH="${AppLogPathsToUse[3]}"
  local AppMatchedFileDepsListFilePath_DEPSPATH="${AppLogPathsToUse[4]}"
  local AppMatchedFileDepsListFilePath_OLDPATH="${AppLogPathsToUse[5]}"
  local AppUnmatchedFileDepsListFilePath_APP="${AppLogPathsToUse[6]}"
  local AppUnmatchedFileDepsListFilePath_OS="${AppLogPathsToUse[7]}"

  # create DEPSPATH variable
  ExcludeOldPathFromPath DEPSPATH

  echo "Application package base search paths:"
  echo "APPPATH    : $AppPath"
  echo "PATH       : $PATH"
  echo "OLDPATH    : $OLDPATH"
  echo "OSTYPEPATH : $OSTYPEPATH"
  echo "DEPSPATH   : $DEPSPATH"
  echo ""

  {
    echo "APPPATH=$AppPath"
    echo "PATH=$PATH"
    echo "OLDPATH=$OLDPATH"
    echo "OSTYPEPATH=$OSTYPEPATH"
    echo "DEPSPATH=$DEPSPATH"
    echo ""
  } | \
  {
    if [[ -f "$AppPathVarsListFilePath" ]]; then
      tee -a "$AppPathVarsListFilePath"
    else
      tee
    fi
  } 2>&1 >/dev/null # supress duplicating output

  echo "Application package files search extensions: $Extensions"
  echo ""

  echo "Searching application package files which may has dependencies:"

  {
    echo "APPPATH=$AppPath"
    echo ""
  } | \
  {
    if [[ -f "$AppFilesListFilePath" ]]; then
      tee -a "$AppFilesListFilePath"
    else
      tee
    fi
  } 2>&1 >/dev/null # supress duplicating output

  local AppFilesListArr=(7) # N items per structure
  local HasFiles=0

  GetFileDependantsByDirPath "$AppDirPath" "$Extensions"
  if (( ${#RETURN_VALUE[@]} )); then
    HasFiles=1
  fi

  FileNameHeader="File Name"
  FileNameHeaderAligner=""
  (( FileNameMaxLen=${#FileNameHeader}+3 ))

  IFS=$'\r\n'
  for arg in "${RETURN_VALUE[@]}"; do
    FileName="${arg##*/}"
    FileDirPath="${arg%/*}"
    IFS=$' \t'
    CksumArr=(`cksum "$arg" 2>/dev/null`)
    FileSize="${CksumArr[1]}"
    Crc32Value="${CksumArr[0]}"
    Md5Value="`md5sum "$arg" 2>/dev/null`"
    Sha1Value="`sha1sum "$arg" 2>/dev/null`"
    # avoid "printf %x" negative values (bash 3.1.0 "printf" bug workaround)
    if (( Crc32Value < 2147483648 )); then
      printf -v Crc32Value '%08X' "$Crc32Value"
    else
      printf -v Crc32Value '%08X' "$((Crc32Value-2147483648))"
      Crc32Value="F${Crc32Value:1}"
    fi

    GetRelativePathFromAbsolutePaths "$FileDirPath" "$FromDirPath"
    FromCurDir="$RETURN_VALUE"

    AppFilesListArr[${#AppFilesListArr[@]}]="$arg"              # full path
    AppFilesListArr[${#AppFilesListArr[@]}]="$FileName"         # file name only
    AppFilesListArr[${#AppFilesListArr[@]}]="$FromCurDir"       # local path from APPPATH
    AppFilesListArr[${#AppFilesListArr[@]}]="$FileSize"         # file size
    AppFilesListArr[${#AppFilesListArr[@]}]="$Crc32Value"       # file crc2 value
    AppFilesListArr[${#AppFilesListArr[@]}]="${Md5Value:0:32}"  # file md5 hash
    AppFilesListArr[${#AppFilesListArr[@]}]="${Sha1Value:0:40}" # file sha1 hash

    (( ${#FileName} > FileNameMaxLen )) && FileNameMaxLen="${#FileName}"
  done

  (( FileNameMaxLen > ${#FileNameHeader}+3 )) && FileNameHeaderAligner="${Padding40:0:FileNameMaxLen-${#FileNameHeader}-3}"

  echo "# $FileNameHeaderAligner$FileNameHeader | Size (b) | CRC32  | Dir Path"
  if [[ -f "$AppFilesListFilePath" ]]; then
    echo "# $FileNameHeaderAligner$FileNameHeader | Size (b) | CRC32  | MD5                            | SHA1                                   | Dir Path" \
      >> "$AppFilesListFilePath"
  fi

  {
    for (( i0=1; i0<${#AppFilesListArr[@]}; i0+=${AppFilesListArr[0]} )); do
      FileName="${AppFilesListArr[i0+1]}"
      FileDirPath="${AppFilesListArr[i0+2]}"
      FileSize="${AppFilesListArr[i0+3]}"
      Crc32Value="${AppFilesListArr[i0+4]}"
      Md5Value="${AppFilesListArr[i0+5]}"
      Sha1Value="${AppFilesListArr[i0+6]}"

      FileNameHeaderAligner=""
      (( FileNameMaxLen > ${#FileName} )) && FileNameHeaderAligner="${Padding40:0:FileNameMaxLen-${#FileName}}"

      if [[ -f "$AppFilesListFilePath" ]]; then
        echo "$FileNameHeaderAligner$FileName ${Padding10:${#FileSize}}$FileSize $Crc32Value ${Md5Value:0:32} ${Sha1Value:0:40} $FileDirPath/" \
          >> "$AppFilesListFilePath"
      fi
      echo "$FileNameHeaderAligner$FileName ${Padding10:${#FileSize}}$FileSize $Crc32Value $FileDirPath/"
    done
  } | sort -

  {
    (( HasFiles )) || echo "None"
    echo ""
  } | \
  {
    if [[ -f "$AppFilesListFilePath" ]]; then
      tee -a "$AppFilesListFilePath"
    else
      tee
    fi
  }

  echo "Application package one level resolved dependencies:"

  {
    echo "APPPATH=$AppPath"
    echo ""
  } | \
  {
    if [[ -f "$AppFileFirstDepsTreeFilePath" ]]; then
      tee -a "$AppFileFirstDepsTreeFilePath"
    else
      tee
    fi
  } 2>&1 >/dev/null # supress duplicating output

  local AppFileFirstDepsTreeArr
  local AppFileFirstDepsUListArr
  local AppFileFirstDepsUListPerFileArr
  AppFileFirstDepsTreeArr=(4) # first known N items per structure
  AppFileFirstDepsUListArr=() # all level 1 unique dependencies
  AppFileFirstDepsUListPerFileArr=() # level 1 unique dependencies per level 0 item (files in APPPATH paths) in dependencies tree

  HasFiles=0

  for (( i0=1; i0<${#AppFilesListArr[@]}; i0+=${AppFilesListArr[0]} )); do
    FilePath="${AppFilesListArr[i0+0]}"
    FileName="${AppFilesListArr[i0+1]}"
    FileDirPath="${AppFilesListArr[i0+2]}"

    ReadFileDependents "$FilePath"

    AppFileFirstDepsUListPerFileArr=()
    AppendArrayToUArray RETURN_VALUE AppFileFirstDepsUListPerFileArr

    j0="${#AppFileFirstDepsUListPerFileArr[@]}"

    AppFileFirstDepsTreeArr[${#AppFileFirstDepsTreeArr[@]}]="$FilePath"
    AppFileFirstDepsTreeArr[${#AppFileFirstDepsTreeArr[@]}]="$FileName"
    AppFileFirstDepsTreeArr[${#AppFileFirstDepsTreeArr[@]}]="$FileDirPath"
    AppFileFirstDepsTreeArr[${#AppFileFirstDepsTreeArr[@]}]="$j0"
    AppendArrayToArray AppFileFirstDepsUListPerFileArr AppFileFirstDepsTreeArr
    AppendUArrayToUArray AppFileFirstDepsUListArr AppFileFirstDepsUListPerFileArr

    (( j0 )) && HasFiles=1
  done

  IFS=$' \t\r\n' # workaround for the bug in the "[@]:i" expression under the bash version lower than 4.1
  {
    j0=0
    for (( i0=1; i0<${#AppFileFirstDepsTreeArr[@]}; i0+=${AppFileFirstDepsTreeArr[0]}+j0 )); do
      FilePath="${AppFileFirstDepsTreeArr[i0+0]}"
      FileName="${AppFileFirstDepsTreeArr[i0+1]}"
      FileDirPath="${AppFileFirstDepsTreeArr[i0+2]}"
      j0="${AppFileFirstDepsTreeArr[i0+3]}"
      AppDepsListPerFileArr=("${AppFileFirstDepsTreeArr[@]:i0+4:j0}")

      echo "$FileDirPath/$FileName:"
      for arg in "${AppDepsListPerFileArr[@]}"; do
        echo "  $arg"
      done
      echo ""
    done

    (( HasFiles )) || echo "None"$'\n'
  } | \
  {
    if [[ -f "$AppFileFirstDepsTreeFilePath" ]]; then
      tee -a "$AppFileFirstDepsTreeFilePath"
    else
      tee
    fi
  }

  echo "Calculating overall matched application package dependencies..."

  # resolved dependencies with full parameters set in all iterations for respective search paths variable
  local AppMatchedFileDepsListArr_APPPATH
  local AppMatchedFileDepsListArr_DEPSPATH
  local AppMatchedFileDepsListArr_OLDPATH
  AppMatchedFileDepsListArr_APPPATH=(8) # N items per structure
  AppMatchedFileDepsListArr_DEPSPATH=(8) # N items per structure
  AppMatchedFileDepsListArr_OLDPATH=(8) # N items per structure

  # unresolved dependencies from APPPATH and DEPSPATH search paths excluding resolved dependencies from all search paths
  local AppUnmatchedFileDepsListArr_APP
  AppUnmatchedFileDepsListArr_APP=(3)
  # unresolved dependencies from OLDPATH search paths excluding resolved dependencies from all search paths
  local AppUnmatchedFileDepsListArr_OS
  AppUnmatchedFileDepsListArr_OS=(2)

  # previous iteration solving dependencies for respective search paths variable
  local AppPrevSolvingFileDepsListArr_APPPATH
  local AppPrevSolvingFileDepsListArr_DEPSPATH
  AppPrevSolvingFileDepsListArr_APPPATH=(2) # N items per structure
  AppPrevSolvingFileDepsListArr_DEPSPATH=(2) # N items per structure
  #local AppPrevSolvingFileDepsListArr_OLDPATH=(2) # N items per structure
  # dependencies to resolve in current iteration for respective search paths variable
  local AppToResolveFileDepsListArr_APPPATH
  local AppToResolveFileDepsListArr_DEPSPATH
  local AppToResolveFileDepsListArr_OLDPATH
  AppToResolveFileDepsListArr_APPPATH=(2) # N items per structure
  AppToResolveFileDepsListArr_DEPSPATH=(2) # N items per structure
  AppToResolveFileDepsListArr_OLDPATH=(2) # N items per structure
  # resolved dependencies with reduced parameters set in all iterations for respective search paths variable
  local AppResolvedFileDepsListArr_APPPATH
  local AppResolvedFileDepsListArr_DEPSPATH
  local AppResolvedFileDepsListArr_OLDPATH
  AppResolvedFileDepsListArr_APPPATH=()
  AppResolvedFileDepsListArr_DEPSPATH=()
  AppResolvedFileDepsListArr_OLDPATH=()
  # unresolved dependencies in all iterations for respective search paths variable
  local AppUnresolvedFileDepsListArr_APPPATH
  local AppUnresolvedFileDepsListArr_DEPSPATH
  local AppUnresolvedFileDepsListArr_OLDPATH
  AppUnresolvedFileDepsListArr_APPPATH=(2) # N items per structure
  AppUnresolvedFileDepsListArr_DEPSPATH=(2) # N items per structure
  AppUnresolvedFileDepsListArr_OLDPATH=(2) # N items per structure
  local FileName2
  local IsFound

  # prepare depencencies lists to resolve
  for (( i0=0; i0<${#AppFileFirstDepsUListArr[@]}; i0++ )); do
    # from there file name is dependent
    AppToResolveFileDepsListArr_APPPATH[${#AppToResolveFileDepsListArr_APPPATH[@]}]="${AppFileFirstDepsUListArr[i0]}"
    # initial level of dependency indirection
    AppToResolveFileDepsListArr_APPPATH[${#AppToResolveFileDepsListArr_APPPATH[@]}]=1
  done

  local FileNameMaxLen_APPPATH
  local FileNameMaxLen_DEPSPATH
  local FileNameMaxLen_OLDPATH

  (( FileNameMaxLen_APPPATH=${#FileNameHeader}+3 ))
  (( FileNameMaxLen_DEPSPATH=${#FileNameHeader}+3 ))
  (( FileNameMaxLen_OLDPATH=${#FileNameHeader}+3 ))

  function IsDependencyWasSolving_APPPATH()
  {
    local FileName="$1"
    local FileName2
    local IsFound=0
    local i

    for (( i=0; i<${#AppResolvedFileDepsListArr_APPPATH[@]}; i++ )); do
      FileName2="${AppResolvedFileDepsListArr_APPPATH[i]}"
      if [[ "$FileName" == "$FileName2" ]]; then
        return 0
      fi
    done
    for (( i=1; i<${#AppUnresolvedFileDepsListArr_APPPATH[@]}; i+=${AppUnresolvedFileDepsListArr_APPPATH[0]} )); do
      FileName2="${AppUnresolvedFileDepsListArr_APPPATH[i+0]}"
      if [[ "$FileName" == "$FileName2" ]]; then
        return 0
      fi
    done

    return 1
  }

  function IsDependencyWasSolving_DEPSPATH()
  {
    local FileName="$1"
    local FileName2
    local IsFound=0
    local i

    for (( i=0; i<${#AppResolvedFileDepsListArr_DEPSPATH[@]}; i++ )); do
      FileName2="${AppResolvedFileDepsListArr_DEPSPATH[i]}"
      if [[ "$FileName" == "$FileName2" ]]; then
        return 0
      fi
    done
    for (( i=1; i<${#AppUnresolvedFileDepsListArr_DEPSPATH[@]}; i+=${AppUnresolvedFileDepsListArr_DEPSPATH[0]} )); do
      FileName2="${AppUnresolvedFileDepsListArr_DEPSPATH[i+0]}"
      if [[ "$FileName" == "$FileName2" ]]; then
        return 0
      fi
    done

    return 1
  }

  function IsDependencyWasSolving_OLDPATH()
  {
    local FileName="$1"
    local FileName2
    local IsFound=0
    local i

    for (( i=0; i<${#AppResolvedFileDepsListArr_OLDPATH[@]}; i++ )); do
      FileName2="${AppResolvedFileDepsListArr_OLDPATH[i]}"
      if [[ "$FileName" == "$FileName2" ]]; then
        return 0
      fi
    done
    for (( i=1; i<${#AppUnresolvedFileDepsListArr_OLDPATH[@]}; i+=${AppUnresolvedFileDepsListArr_OLDPATH[0]} )); do
      FileName2="${AppUnresolvedFileDepsListArr_OLDPATH[i+0]}"
      if [[ "$FileName" == "$FileName2" ]]; then
        return 0
      fi
    done

    return 1
  }

  while (( 1 )); do
    # search dependencies in APPPATH
    while (( ${#AppToResolveFileDepsListArr_APPPATH[@]} > 1 )); do
      #echo "*${AppToResolveFileDepsListArr_APPPATH[@]}*"
      for (( i0=1; i0<${#AppToResolveFileDepsListArr_APPPATH[@]}; i0+=${AppToResolveFileDepsListArr_APPPATH[0]} )); do
        IsFound=0
        FileName="${AppToResolveFileDepsListArr_APPPATH[i0+0]}"
        IFS=':'
        for arg in $AppAbsDirPath; do
          IFS=$'\r\n' # enables string split only by line return characters and non printable characters may become part of name
          for FilePath in `find "$arg" -mount -type f -iname "$FileName" -print 2>/dev/null`; do
            if [[ -n "${FilePath//[[:space:]]/}" ]]; then
              IsFound=1
              FileDirPath="${FilePath%/*}"
              IFS=$' \t'
              CksumArr=(`cksum "$FilePath" 2>/dev/null`)
              FileSize="${CksumArr[1]}"
              Crc32Value="${CksumArr[0]}"
              Md5Value="`md5sum "$FilePath" 2>/dev/null`"
              Sha1Value="`sha1sum "$FilePath" 2>/dev/null`"
              # avoid "printf %x" negative values (bash 3.1.0 "printf" bug workaround)
              if (( Crc32Value < 2147483648 )); then
                printf -v Crc32Value '%08X' "$Crc32Value"
              else
                printf -v Crc32Value '%08X' "$((Crc32Value-2147483648))"
                Crc32Value="F${Crc32Value:1}"
              fi

              GetRelativePathFromAbsolutePaths "$FileDirPath" "$FromDirPath"
              FromCurDir="$RETURN_VALUE"

              AppMatchedFileDepsListArr_APPPATH[${#AppMatchedFileDepsListArr_APPPATH[@]}]="$FilePath"         # full path
              AppMatchedFileDepsListArr_APPPATH[${#AppMatchedFileDepsListArr_APPPATH[@]}]="$FileName"         # file name only
              AppMatchedFileDepsListArr_APPPATH[${#AppMatchedFileDepsListArr_APPPATH[@]}]="$FromCurDir"       # local path from APPPATH
              AppMatchedFileDepsListArr_APPPATH[${#AppMatchedFileDepsListArr_APPPATH[@]}]="$FileSize"         # file size
              AppMatchedFileDepsListArr_APPPATH[${#AppMatchedFileDepsListArr_APPPATH[@]}]="$Crc32Value"       # file crc2 value
              AppMatchedFileDepsListArr_APPPATH[${#AppMatchedFileDepsListArr_APPPATH[@]}]="${Md5Value:0:32}"  # file md5 hash
              AppMatchedFileDepsListArr_APPPATH[${#AppMatchedFileDepsListArr_APPPATH[@]}]="${Sha1Value:0:40}" # file sha1 hash
              AppMatchedFileDepsListArr_APPPATH[${#AppMatchedFileDepsListArr_APPPATH[@]}]="${AppToResolveFileDepsListArr_APPPATH[i0+1]}" # minimal level of dependency indirection
            fi
          done
        done

        if (( IsFound )); then
          AppResolvedFileDepsListArr_APPPATH[${#AppResolvedFileDepsListArr_APPPATH[@]}]="$FileName"
          (( ${#FileName} > FileNameMaxLen_APPPATH )) && FileNameMaxLen_APPPATH="${#FileName}"
        else
          AppUnresolvedFileDepsListArr_APPPATH[${#AppUnresolvedFileDepsListArr_APPPATH[@]}]="$FileName"
          AppUnresolvedFileDepsListArr_APPPATH[${#AppUnresolvedFileDepsListArr_APPPATH[@]}]="${AppToResolveFileDepsListArr_APPPATH[i0+1]}"
        fi

        AppPrevSolvingFileDepsListArr_APPPATH[${#AppPrevSolvingFileDepsListArr_APPPATH[@]}]="$FileName"
        AppPrevSolvingFileDepsListArr_APPPATH[${#AppPrevSolvingFileDepsListArr_APPPATH[@]}]="${AppToResolveFileDepsListArr_APPPATH[i0+1]}"
      done

      #echo "-${AppResolvedFileDepsListArr_APPPATH[@]}-"
      #echo "=${AppUnresolvedFileDepsListArr_APPPATH[@]}="

      # read dependencies in dependencies which are found for APPPATH
      AppFileFirstDepsUListPerFileArr=(2)
      for (( i0=1; i0<${#AppMatchedFileDepsListArr_APPPATH[@]}; i0+=${AppMatchedFileDepsListArr_APPPATH[0]} )); do
        FilePath="${AppMatchedFileDepsListArr_APPPATH[i0+0]}"

        ReadFileDependents "$FilePath"

        for FileName in "${RETURN_VALUE[@]}"; do
          IsFound=0
          for (( i1=${#AppFileFirstDepsUListPerFileArr[@]}-${AppFileFirstDepsUListPerFileArr[0]};
                 i1>=0;
                 i1-=${AppFileFirstDepsUListPerFileArr[0]} )); do
            if [[ "$FileName" == "${AppFileFirstDepsUListPerFileArr[i1+0]}" ]]; then
              IsFound=1
              break
            fi
          done
          if (( ! IsFound )); then
            AppFileFirstDepsUListPerFileArr[${#AppFileFirstDepsUListPerFileArr[@]}]="$FileName"
            AppFileFirstDepsUListPerFileArr[${#AppFileFirstDepsUListPerFileArr[@]}]="$((${AppMatchedFileDepsListArr_APPPATH[i0+7]}+1))"
          fi
        done
      done

      AppToResolveFileDepsListArr_APPPATH=(2)
      for (( i0=1; i0<${#AppFileFirstDepsUListPerFileArr[@]}; i0+=${AppFileFirstDepsUListPerFileArr[0]} )); do
        FileName="${AppFileFirstDepsUListPerFileArr[i0+0]}"
        if ! IsDependencyWasSolving_APPPATH "$FileName"; then
          AppToResolveFileDepsListArr_APPPATH[${#AppToResolveFileDepsListArr_APPPATH[@]}]="$FileName"
          AppToResolveFileDepsListArr_APPPATH[${#AppToResolveFileDepsListArr_APPPATH[@]}]="${AppFileFirstDepsUListPerFileArr[i0+1]}"
        fi
      done
      #echo ""
    done

    #echo "---------2"

    # searching dependencies in DEPSPATH
    while (( ${#AppToResolveFileDepsListArr_DEPSPATH[@]} > 1 )); do
      #echo "*${AppToResolveFileDepsListArr_DEPSPATH[@]}*"
      for (( i0=1; i0<${#AppToResolveFileDepsListArr_DEPSPATH[@]}; i0+=${AppToResolveFileDepsListArr_DEPSPATH[0]} )); do
        IsFound=0
        FileName="${AppToResolveFileDepsListArr_DEPSPATH[i0+0]}"
        IFS=':'
        for arg in $DEPSPATH; do
          IFS=$'\r\n' # enables string split only by line return characters and non printable characters may become part of name
          for FilePath in `find "$arg" -mount -maxdepth 1 -type f -iname "$FileName" -print 2>/dev/null`; do
            if [[ -n "${FilePath//[[:space:]]/}" ]]; then
              IsFound=1
              FileDirPath="${FilePath%/*}"
              IFS=$' \t'
              CksumArr=(`cksum "$FilePath" 2>/dev/null`)
              FileSize="${CksumArr[1]}"
              Crc32Value="${CksumArr[0]}"
              Md5Value="`md5sum "$FilePath" 2>/dev/null`"
              Sha1Value="`sha1sum "$FilePath" 2>/dev/null`"
              # avoid "printf %x" negative values (bash 3.1.0 "printf" bug workaround)
              if (( Crc32Value < 2147483648 )); then
                printf -v Crc32Value '%08X' "$Crc32Value"
              else
                printf -v Crc32Value '%08X' "$((Crc32Value-2147483648))"
                Crc32Value="F${Crc32Value:1}"
              fi
              AppMatchedFileDepsListArr_DEPSPATH[${#AppMatchedFileDepsListArr_DEPSPATH[@]}]="$FilePath"         # full path
              AppMatchedFileDepsListArr_DEPSPATH[${#AppMatchedFileDepsListArr_DEPSPATH[@]}]="$FileName"         # file name only
              AppMatchedFileDepsListArr_DEPSPATH[${#AppMatchedFileDepsListArr_DEPSPATH[@]}]="$FileDirPath"      # path from DEPSPATH
              AppMatchedFileDepsListArr_DEPSPATH[${#AppMatchedFileDepsListArr_DEPSPATH[@]}]="$FileSize"         # file size
              AppMatchedFileDepsListArr_DEPSPATH[${#AppMatchedFileDepsListArr_DEPSPATH[@]}]="$Crc32Value"       # file crc2 value
              AppMatchedFileDepsListArr_DEPSPATH[${#AppMatchedFileDepsListArr_DEPSPATH[@]}]="${Md5Value:0:32}"  # file md5 hash
              AppMatchedFileDepsListArr_DEPSPATH[${#AppMatchedFileDepsListArr_DEPSPATH[@]}]="${Sha1Value:0:40}" # file sha1 hash
              AppMatchedFileDepsListArr_DEPSPATH[${#AppMatchedFileDepsListArr_DEPSPATH[@]}]="${AppToResolveFileDepsListArr_DEPSPATH[i0+1]}" # minimal level of dependency indirection
            fi
          done
        done

        if (( IsFound )); then
          AppResolvedFileDepsListArr_DEPSPATH[${#AppResolvedFileDepsListArr_DEPSPATH[@]}]="$FileName"
          (( ${#FileName} > FileNameMaxLen_DEPSPATH )) && FileNameMaxLen_DEPSPATH="${#FileName}"
        else
          AppUnresolvedFileDepsListArr_DEPSPATH[${#AppUnresolvedFileDepsListArr_DEPSPATH[@]}]="$FileName"
          AppUnresolvedFileDepsListArr_DEPSPATH[${#AppUnresolvedFileDepsListArr_DEPSPATH[@]}]="${AppToResolveFileDepsListArr_DEPSPATH[i0+1]}"
        fi

        AppPrevSolvingFileDepsListArr_DEPSPATH[${#AppPrevSolvingFileDepsListArr_DEPSPATH[@]}]="$FileName"
        AppPrevSolvingFileDepsListArr_DEPSPATH[${#AppPrevSolvingFileDepsListArr_DEPSPATH[@]}]="${AppToResolveFileDepsListArr_DEPSPATH[i0+1]}"
      done

      #echo "-${AppResolvedFileDepsListArr_DEPSPATH[@]}-"
      #echo "=${AppUnresolvedFileDepsListArr_DEPSPATH[@]}="

      # read dependencies in dependencies which are found for DEPSPATH
      AppFileFirstDepsUListPerFileArr=(2)
      for (( i0=1; i0<${#AppMatchedFileDepsListArr_DEPSPATH[@]}; i0+=${AppMatchedFileDepsListArr_DEPSPATH[0]} )); do
        FilePath="${AppMatchedFileDepsListArr_DEPSPATH[i0+0]}"

        ReadFileDependents "$FilePath"

        for FileName in "${RETURN_VALUE[@]}"; do
          IsFound=0
          for (( i1=${#AppFileFirstDepsUListPerFileArr[@]}-${AppFileFirstDepsUListPerFileArr[0]};
                 i1>=0;
                 i1-=${AppFileFirstDepsUListPerFileArr[0]} )); do
            if [[ "$FileName" == "${AppFileFirstDepsUListPerFileArr[i1+0]}" ]]; then
              IsFound=1
              break
            fi
          done
          if (( ! IsFound )); then
            AppFileFirstDepsUListPerFileArr[${#AppFileFirstDepsUListPerFileArr[@]}]="$FileName"
            AppFileFirstDepsUListPerFileArr[${#AppFileFirstDepsUListPerFileArr[@]}]="$((${AppMatchedFileDepsListArr_DEPSPATH[i0+7]}+1))"
          fi
        done
      done

      AppToResolveFileDepsListArr_DEPSPATH=(2)
      for (( i0=1; i0<${#AppFileFirstDepsUListPerFileArr[@]}; i0+=${AppFileFirstDepsUListPerFileArr[0]} )); do
        FileName="${AppFileFirstDepsUListPerFileArr[i0+0]}"
        if ! IsDependencyWasSolving_DEPSPATH "$FileName"; then
          AppToResolveFileDepsListArr_DEPSPATH[${#AppToResolveFileDepsListArr_DEPSPATH[@]}]="$FileName"
          AppToResolveFileDepsListArr_DEPSPATH[${#AppToResolveFileDepsListArr_DEPSPATH[@]}]="${AppFileFirstDepsUListPerFileArr[i0+1]}"
        fi
      done
      #echo ""
    done

    #echo "------------3"

    # searching dependencies in OLDPATH
    while (( ${#AppToResolveFileDepsListArr_OLDPATH[@]} > 1 )); do
      #echo "*${AppToResolveFileDepsListArr_OLDPATH[@]}*"
      for (( i0=1; i0<${#AppToResolveFileDepsListArr_OLDPATH[@]}; i0+=${AppToResolveFileDepsListArr_OLDPATH[0]} )); do
        IsFound=0
        FileName="${AppToResolveFileDepsListArr_OLDPATH[i0+0]}"
        IFS=':'
        for arg in $OLDPATH; do
          IFS=$'\r\n' # enables string split only by line return characters and non printable characters may become part of name
          for FilePath in `find "$arg" -mount -maxdepth 1 -type f -iname "$FileName" -print 2>/dev/null`; do
            if [[ -n "${FilePath//[[:space:]]/}" ]]; then
              IsFound=1
              FileDirPath="${FilePath%/*}"
              IFS=$' \t'
              CksumArr=(`cksum "$FilePath" 2>/dev/null`)
              FileSize="${CksumArr[1]}"
              Crc32Value="${CksumArr[0]}"
              Md5Value="`md5sum "$FilePath" 2>/dev/null`"
              Sha1Value="`sha1sum "$FilePath" 2>/dev/null`"
              # avoid "printf %x" negative values (bash 3.1.0 "printf" bug workaround)
              if (( Crc32Value < 2147483648 )); then
                printf -v Crc32Value '%08X' "$Crc32Value"
              else
                printf -v Crc32Value '%08X' "$((Crc32Value-2147483648))"
                Crc32Value="F${Crc32Value:1}"
              fi
              AppMatchedFileDepsListArr_OLDPATH[${#AppMatchedFileDepsListArr_OLDPATH[@]}]="$FilePath"         # full path
              AppMatchedFileDepsListArr_OLDPATH[${#AppMatchedFileDepsListArr_OLDPATH[@]}]="$FileName"         # file name only
              AppMatchedFileDepsListArr_OLDPATH[${#AppMatchedFileDepsListArr_OLDPATH[@]}]="$FileDirPath"      # path from OLDPATH
              AppMatchedFileDepsListArr_OLDPATH[${#AppMatchedFileDepsListArr_OLDPATH[@]}]="$FileSize"         # file size
              AppMatchedFileDepsListArr_OLDPATH[${#AppMatchedFileDepsListArr_OLDPATH[@]}]="$Crc32Value"       # file crc2 value
              AppMatchedFileDepsListArr_OLDPATH[${#AppMatchedFileDepsListArr_OLDPATH[@]}]="${Md5Value:0:32}"  # file md5 hash
              AppMatchedFileDepsListArr_OLDPATH[${#AppMatchedFileDepsListArr_OLDPATH[@]}]="${Sha1Value:0:40}" # file sha1 hash
              AppMatchedFileDepsListArr_OLDPATH[${#AppMatchedFileDepsListArr_OLDPATH[@]}]="${AppToResolveFileDepsListArr_OLDPATH[i0+1]}" # minimal level of dependency indirection
            fi
          done
        done

        if (( IsFound )); then
          AppResolvedFileDepsListArr_OLDPATH[${#AppResolvedFileDepsListArr_OLDPATH[@]}]="$FileName"
          (( ${#FileName} > FileNameMaxLen_OLDPATH )) && FileNameMaxLen_OLDPATH="${#FileName}"
        else
          AppUnresolvedFileDepsListArr_OLDPATH[${#AppUnresolvedFileDepsListArr_OLDPATH[@]}]="$FileName"
          AppUnresolvedFileDepsListArr_OLDPATH[${#AppUnresolvedFileDepsListArr_OLDPATH[@]}]="${AppToResolveFileDepsListArr_OLDPATH[i0+1]}"
        fi

        #AppPrevSolvingFileDepsListArr_OLDPATH[${#AppPrevSolvingFileDepsListArr_OLDPATH[@]}]="$FileName"
        #AppPrevSolvingFileDepsListArr_OLDPATH[${#AppPrevSolvingFileDepsListArr_OLDPATH[@]}]="${AppToResolveFileDepsListArr_OLDPATH[i0+1]}"
      done

      #echo "-${AppResolvedFileDepsListArr_OLDPATH[@]}-"
      #echo "-${AppUnresolvedFileDepsListArr_OLDPATH[@]}-"

      # read dependencies in dependencies which are found for OLDPATH
      AppFileFirstDepsUListPerFileArr=(2)
      for (( i0=1; i0<${#AppMatchedFileDepsListArr_OLDPATH[@]}; i0+=${AppMatchedFileDepsListArr_OLDPATH[0]} )); do
        FilePath="${AppMatchedFileDepsListArr_OLDPATH[i0+0]}"

        ReadFileDependents "$FilePath"

        for FileName in "${RETURN_VALUE[@]}"; do
          IsFound=0
          for (( i1=${#AppFileFirstDepsUListPerFileArr[@]}-${AppFileFirstDepsUListPerFileArr[0]};
                 i1>=0;
                 i1-=${AppFileFirstDepsUListPerFileArr[0]} )); do
            if [[ "$FileName" == "${AppFileFirstDepsUListPerFileArr[i1+0]}" ]]; then
              IsFound=1
              break
            fi
          done
          if (( ! IsFound )); then
            AppFileFirstDepsUListPerFileArr[${#AppFileFirstDepsUListPerFileArr[@]}]="$FileName"
            AppFileFirstDepsUListPerFileArr[${#AppFileFirstDepsUListPerFileArr[@]}]="$((${AppMatchedFileDepsListArr_OLDPATH[i0+7]}+1))"
          fi
        done
      done

      AppToResolveFileDepsListArr_OLDPATH=(2)
      for (( i0=1; i0<${#AppFileFirstDepsUListPerFileArr[@]}; i0+=${AppFileFirstDepsUListPerFileArr[0]} )); do
        FileName="${AppFileFirstDepsUListPerFileArr[i0+0]}"
        if ! IsDependencyWasSolving_OLDPATH "$FileName"; then
          AppToResolveFileDepsListArr_OLDPATH[${#AppToResolveFileDepsListArr_OLDPATH[@]}]="$FileName"
          AppToResolveFileDepsListArr_OLDPATH[${#AppToResolveFileDepsListArr_OLDPATH[@]}]="${AppFileFirstDepsUListPerFileArr[i0+1]}"
        fi
      done
      #echo ""
    done

    #echo "------X"

    # We need to find dependencies in all search paths even if they duplicate each other, so
    # move "PrevSolving" dependencies to "ToResolve" of other search paths group in this order:
    # 1. APPPATH dependent on DEPSPATH
    # 2. DEPSPATH dependent on APPPATH
    # 3. APPPATH and DEPSPATH dependent on OLDPATH
    # 4. OLDPATH can't depend on others, all solved/unresolved dependencies here leaves as is
    #
    # Iteration continues until "PrevSolving" dependencies for APPPATH and DEPSPATH got empty, because
    # after that all dependencies will be (un)matched completely (dependencies tree will be fully parsed).
    #

    if (( ${#AppPrevSolvingFileDepsListArr_APPPATH[@]} > 1 || ${#AppPrevSolvingFileDepsListArr_DEPSPATH[@]} > 1 )); then
      # APPPATH -> DEPSPATH
      for (( i0=1; i0<${#AppPrevSolvingFileDepsListArr_APPPATH[@]}; i0+=${AppPrevSolvingFileDepsListArr_APPPATH[0]} )); do
        FileName="${AppPrevSolvingFileDepsListArr_APPPATH[i0+0]}"
        if ! IsDependencyWasSolving_DEPSPATH "$FileName"; then
          AppToResolveFileDepsListArr_DEPSPATH[${#AppToResolveFileDepsListArr_DEPSPATH[@]}]="$FileName"
          AppToResolveFileDepsListArr_DEPSPATH[${#AppToResolveFileDepsListArr_DEPSPATH[@]}]="${AppPrevSolvingFileDepsListArr_APPPATH[i0+1]}"
        fi
      done

      # DEPSPATH -> APPPATH
      for (( i0=1; i0<${#AppPrevSolvingFileDepsListArr_DEPSPATH[@]}; i0+=${AppPrevSolvingFileDepsListArr_DEPSPATH[0]} )); do
        FileName="${AppPrevSolvingFileDepsListArr_DEPSPATH[i0+0]}"
        if ! IsDependencyWasSolving_APPPATH "$FileName"; then
          AppToResolveFileDepsListArr_APPPATH[${#AppToResolveFileDepsListArr_APPPATH[@]}]="$FileName"
          AppToResolveFileDepsListArr_APPPATH[${#AppToResolveFileDepsListArr_APPPATH[@]}]="${AppPrevSolvingFileDepsListArr_DEPSPATH[i0+1]}"
        fi
      done

      # APPPATH+DEPSPATH -> OLDPATH
      for (( i0=1; i0<${#AppPrevSolvingFileDepsListArr_APPPATH[@]}; i0+=${AppPrevSolvingFileDepsListArr_APPPATH[0]} )); do
        FileName="${AppPrevSolvingFileDepsListArr_APPPATH[i0+0]}"
        if ! IsDependencyWasSolving_OLDPATH "$FileName"; then
          AppToResolveFileDepsListArr_OLDPATH[${#AppToResolveFileDepsListArr_OLDPATH[@]}]="$FileName"
          AppToResolveFileDepsListArr_OLDPATH[${#AppToResolveFileDepsListArr_OLDPATH[@]}]="${AppPrevSolvingFileDepsListArr_APPPATH[i0+1]}"
        fi
      done
      for (( i0=1; i0<${#AppPrevSolvingFileDepsListArr_DEPSPATH[@]}; i0+=${AppPrevSolvingFileDepsListArr_DEPSPATH[0]} )); do
        FileName="${AppPrevSolvingFileDepsListArr_DEPSPATH[i0+0]}"
        if ! IsDependencyWasSolving_OLDPATH "$FileName"; then
          AppToResolveFileDepsListArr_OLDPATH[${#AppToResolveFileDepsListArr_OLDPATH[@]}]="$FileName"
          AppToResolveFileDepsListArr_OLDPATH[${#AppToResolveFileDepsListArr_OLDPATH[@]}]="${AppPrevSolvingFileDepsListArr_DEPSPATH[i0+1]}"
        fi
      done

      AppPrevSolvingFileDepsListArr_APPPATH=(2)
      AppPrevSolvingFileDepsListArr_DEPSPATH=(2)
      #AppPrevSolvingFileDepsListArr_OLDPATH=(2)
    else
      break
    fi
  done

  echo ""

  echo "Application package locally matched dependencies (APPPATH):"

  {
    echo "APPPATH=$AppPath"
    echo "PATH=$PATH"
    echo "OLDPATH=$OLDPATH"
    echo "OSTYPEPATH=$OSTYPEPATH"
    echo "DEPSPATH=$DEPSPATH"
    echo ""
  } | \
  {
    if [[ -f "$AppMatchedFileDepsListFilePath_APPPATH" ]]; then
      tee -a "$AppMatchedFileDepsListFilePath_APPPATH"
    else
      tee
    fi
  } 2>&1 >/dev/null # supress duplicating output

  {
    echo "# Legend:"
    echo "#   * - minimal level of dependency indirection"
  } | \
  {
    if [[ -f "$AppMatchedFileDepsListFilePath_APPPATH" ]]; then
      tee -a "$AppMatchedFileDepsListFilePath_APPPATH"
    else
      tee
    fi
  }

  if (( ${#AppMatchedFileDepsListArr_APPPATH[@]} > 1 )); then
    HasFiles=1
  else
    HasFiles=0
  fi

  FileNameHeaderAligner=""
  (( FileNameMaxLen_APPPATH > ${#FileNameHeader}+3 )) && FileNameHeaderAligner="${Padding40:0:FileNameMaxLen_APPPATH-${#FileNameHeader}-3}"

  echo "# $FileNameHeaderAligner$FileNameHeader | * | Size (b) | CRC32  | Dir Path"
  if [[ -f "$AppMatchedFileDepsListFilePath_APPPATH" ]]; then
    echo "# $FileNameHeaderAligner$FileNameHeader | * | Size (b) | CRC32  | MD5                            | SHA1                                   | Dir Path" \
      >> "$AppMatchedFileDepsListFilePath_APPPATH"
  fi

  local MinIndirLvl
  local MinIndirLvlAligner

  {
    for (( i0=1; i0<${#AppMatchedFileDepsListArr_APPPATH[@]}; i0+=${AppMatchedFileDepsListArr_APPPATH[0]} )); do
      FileName="${AppMatchedFileDepsListArr_APPPATH[i0+1]}"
      FileDirPath="${AppMatchedFileDepsListArr_APPPATH[i0+2]}"
      FileSize="${AppMatchedFileDepsListArr_APPPATH[i0+3]}"
      Crc32Value="${AppMatchedFileDepsListArr_APPPATH[i0+4]}"
      Md5Value="${AppMatchedFileDepsListArr_APPPATH[i0+5]}"
      Sha1Value="${AppMatchedFileDepsListArr_APPPATH[i0+6]}"
      MinIndirLvl="${AppMatchedFileDepsListArr_APPPATH[i0+7]}"

      FileNameHeaderAligner=""
      (( FileNameMaxLen_APPPATH > ${#FileName} )) && FileNameHeaderAligner="${Padding40:0:FileNameMaxLen_APPPATH-${#FileName}}"
      MinIndirLvlAligner=""
      (( 2 > ${#MinIndirLvl} )) && MinIndirLvlAligner="${Padding40:0:3-${#MinIndirLvl}}"

      if [[ -f "$AppMatchedFileDepsListFilePath_APPPATH" ]]; then
        echo "$FileNameHeaderAligner$FileName $MinIndirLvlAligner$MinIndirLvl ${Padding10:${#FileSize}}$FileSize $Crc32Value ${Md5Value:0:32} ${Sha1Value:0:40} $FileDirPath/" \
          >> "$AppMatchedFileDepsListFilePath_APPPATH"
      fi
      echo "$FileNameHeaderAligner$FileName $MinIndirLvlAligner$MinIndirLvl ${Padding10:${#FileSize}}$FileSize $Crc32Value $FileDirPath/"
    done
  } | sort -

  {
    (( HasFiles )) || echo "None"
    echo ""
  } | \
  {
    if [[ -f "$AppMatchedFileDepsListFilePath_APPPATH" ]]; then
      tee -a "$AppMatchedFileDepsListFilePath_APPPATH"
    else
      tee
    fi
  }

  echo "Application package \"$OSTYPE\" matched dependencies (DEPSPATH):"

  {
    echo "APPPATH=$AppPath"
    echo "PATH=$PATH"
    echo "OLDPATH=$OLDPATH"
    echo "OSTYPEPATH=$OSTYPEPATH"
    echo "DEPSPATH=$DEPSPATH"
    echo ""
  } | \
  {
    if [[ -f "$AppMatchedFileDepsListFilePath_DEPSPATH" ]]; then
      tee -a "$AppMatchedFileDepsListFilePath_DEPSPATH"
    else
      tee
    fi
  } 2>&1 >/dev/null # supress duplicating output

  {
    echo "# Legend:"
    echo "#   * - minimal level of dependency indirection"
  } | \
  {
    if [[ -f "$AppMatchedFileDepsListFilePath_DEPSPATH" ]]; then
      tee -a "$AppMatchedFileDepsListFilePath_DEPSPATH"
    else
      tee
    fi
  }

  if (( ${#AppMatchedFileDepsListArr_DEPSPATH[@]} > 1 )); then
    HasFiles=1
  else
    HasFiles=0
  fi

  FileNameHeaderAligner=""
  (( FileNameMaxLen_DEPSPATH > ${#FileNameHeader}+3 )) && FileNameHeaderAligner="${Padding40:0:FileNameMaxLen_DEPSPATH-${#FileNameHeader}-3}"

  echo "# $FileNameHeaderAligner$FileNameHeader | * | Size (b) | CRC32  | Dir Path"
  if [[ -f "$AppMatchedFileDepsListFilePath_DEPSPATH" ]]; then
    echo "# $FileNameHeaderAligner$FileNameHeader | * | Size (b) | CRC32  | MD5                            | SHA1                                   | Dir Path" \
      >> "$AppMatchedFileDepsListFilePath_DEPSPATH"
  fi

  local MinIndirLvl
  local MinIndirLvlAligner

  {
    for (( i0=1; i0<${#AppMatchedFileDepsListArr_DEPSPATH[@]}; i0+=${AppMatchedFileDepsListArr_DEPSPATH[0]} )); do
      FileName="${AppMatchedFileDepsListArr_DEPSPATH[i0+1]}"
      FileDirPath="${AppMatchedFileDepsListArr_DEPSPATH[i0+2]}"
      FileSize="${AppMatchedFileDepsListArr_DEPSPATH[i0+3]}"
      Crc32Value="${AppMatchedFileDepsListArr_DEPSPATH[i0+4]}"
      Md5Value="${AppMatchedFileDepsListArr_DEPSPATH[i0+5]}"
      Sha1Value="${AppMatchedFileDepsListArr_DEPSPATH[i0+6]}"
      MinIndirLvl="${AppMatchedFileDepsListArr_DEPSPATH[i0+7]}"

      FileNameHeaderAligner=""
      (( FileNameMaxLen_DEPSPATH > ${#FileName} )) && FileNameHeaderAligner="${Padding40:0:FileNameMaxLen_DEPSPATH-${#FileName}}"
      MinIndirLvlAligner=""
      (( 2 > ${#MinIndirLvl} )) && MinIndirLvlAligner="${Padding40:0:3-${#MinIndirLvl}}"

      if [[ -f "$AppMatchedFileDepsListFilePath_DEPSPATH" ]]; then
        echo "$FileNameHeaderAligner$FileName $MinIndirLvlAligner$MinIndirLvl ${Padding10:${#FileSize}}$FileSize $Crc32Value ${Md5Value:0:32} ${Sha1Value:0:40} $FileDirPath/" \
          >> "$AppMatchedFileDepsListFilePath_DEPSPATH"
      fi
      echo "$FileNameHeaderAligner$FileName $MinIndirLvlAligner$MinIndirLvl ${Padding10:${#FileSize}}$FileSize $Crc32Value $FileDirPath/"
    done
  } | sort -

  {
    (( HasFiles )) || echo "None"
    echo ""
  } | \
  {
    if [[ -f "$AppMatchedFileDepsListFilePath_DEPSPATH" ]]; then
      tee -a "$AppMatchedFileDepsListFilePath_DEPSPATH"
    else
      tee
    fi
  }

  echo "Application package \"$OS\" matched dependencies (OLDPATH):"

  {
    echo "APPPATH=$AppPath"
    echo "PATH=$PATH"
    echo "OLDPATH=$OLDPATH"
    echo "OSTYPEPATH=$OSTYPEPATH"
    echo "DEPSPATH=$DEPSPATH"
    echo ""
  } | \
  {
    if [[ -f "$AppMatchedFileDepsListFilePath_OLDPATH" ]]; then
      tee -a "$AppMatchedFileDepsListFilePath_OLDPATH"
    else
      tee
    fi
  } 2>&1 >/dev/null # supress duplicating output

  {
    echo "# Legend:"
    echo "#   * - minimal level of dependency indirection"
  } | \
  {
    if [[ -f "$AppMatchedFileDepsListFilePath_OLDPATH" ]]; then
      tee -a "$AppMatchedFileDepsListFilePath_OLDPATH"
    else
      tee
    fi
  }

  if (( ${#AppMatchedFileDepsListArr_OLDPATH[@]} > 1 )); then
    HasFiles=1
  else
    HasFiles=0
  fi

  FileNameHeaderAligner=""
  (( FileNameMaxLen_OLDPATH > ${#FileNameHeader}+3 )) && FileNameHeaderAligner="${Padding40:0:FileNameMaxLen_OLDPATH-${#FileNameHeader}-3}"

  echo "# $FileNameHeaderAligner$FileNameHeader | * | Size (b) | CRC32  | Dir Path"
  if [[ -f "$AppMatchedFileDepsListFilePath_OLDPATH" ]]; then
    echo "# $FileNameHeaderAligner$FileNameHeader | * | Size (b) | CRC32  | MD5                            | SHA1                                   | Dir Path" \
      >> "$AppMatchedFileDepsListFilePath_OLDPATH"
  fi

  local MinIndirLvl
  local MinIndirLvlAligner

  {
    for (( i0=1; i0<${#AppMatchedFileDepsListArr_OLDPATH[@]}; i0+=${AppMatchedFileDepsListArr_OLDPATH[0]} )); do
      FileName="${AppMatchedFileDepsListArr_OLDPATH[i0+1]}"
      FileDirPath="${AppMatchedFileDepsListArr_OLDPATH[i0+2]}"
      FileSize="${AppMatchedFileDepsListArr_OLDPATH[i0+3]}"
      Crc32Value="${AppMatchedFileDepsListArr_OLDPATH[i0+4]}"
      Md5Value="${AppMatchedFileDepsListArr_OLDPATH[i0+5]}"
      Sha1Value="${AppMatchedFileDepsListArr_OLDPATH[i0+6]}"
      MinIndirLvl="${AppMatchedFileDepsListArr_OLDPATH[i0+7]}"

      FileNameHeaderAligner=""
      (( FileNameMaxLen_OLDPATH > ${#FileName} )) && FileNameHeaderAligner="${Padding40:0:FileNameMaxLen_OLDPATH-${#FileName}}"
      MinIndirLvlAligner=""
      (( 2 > ${#MinIndirLvl} )) && MinIndirLvlAligner="${Padding40:0:3-${#MinIndirLvl}}"

      if [[ -f "$AppMatchedFileDepsListFilePath_OLDPATH" ]]; then
        echo "$FileNameHeaderAligner$FileName $MinIndirLvlAligner$MinIndirLvl ${Padding10:${#FileSize}}$FileSize $Crc32Value ${Md5Value:0:32} ${Sha1Value:0:40} $FileDirPath/" \
          >> "$AppMatchedFileDepsListFilePath_OLDPATH"
      fi
      echo "$FileNameHeaderAligner$FileName $MinIndirLvlAligner$MinIndirLvl ${Padding10:${#FileSize}}$FileSize $Crc32Value $FileDirPath/"
    done
  } | sort -

  {
    (( HasFiles )) || echo "None"
    echo ""
  } | \
  {
    if [[ -f "$AppMatchedFileDepsListFilePath_OLDPATH" ]]; then
      tee -a "$AppMatchedFileDepsListFilePath_OLDPATH"
    else
      tee
    fi
  }

  echo "Application package locally unmatched dependencies (APPPATH+DEPSPATH):"

  {
    echo "APPPATH=$AppPath"
    echo "PATH=$PATH"
    echo "OLDPATH=$OLDPATH"
    echo "OSTYPEPATH=$OSTYPEPATH"
    echo "DEPSPATH=$DEPSPATH"
    echo ""
  } | \
  {
    if [[ -f "$AppUnmatchedFileDepsListFilePath_APP" ]]; then
      tee -a "$AppUnmatchedFileDepsListFilePath_APP"
    else
      tee
    fi
  } 2>&1 >/dev/null # supress duplicating output

  FileNameHeaderAligner=""
  (( FileNameMaxLen=${#FileNameHeader}+3 ))

  #echo "AppUnresolvedFileDepsListArr_APPPATH=${AppUnresolvedFileDepsListArr_APPPATH[@]}"
  #echo "AppResolvedFileDepsListArr_DEPSPATH=${AppResolvedFileDepsListArr_DEPSPATH[@]}"
  #echo "AppResolvedFileDepsListArr_OLDPATH=${AppResolvedFileDepsListArr_OLDPATH[@]}"

  # APPPATH
  for (( i0=1; i0<${#AppUnresolvedFileDepsListArr_APPPATH[@]}; i0+=${AppUnresolvedFileDepsListArr_APPPATH[0]} )); do
    FileName="${AppUnresolvedFileDepsListArr_APPPATH[i0+0]}"
    IsFound=0
    for (( i1=0; i1<${#AppResolvedFileDepsListArr_DEPSPATH[@]}; i1++ )); do
      FileName2="${AppResolvedFileDepsListArr_DEPSPATH[i1]}"
      if [[ "$FileName" == "$FileName2" ]]; then
        IsFound=1
        break
      fi
    done
    if (( ! IsFound )); then
      for (( i1=0; i1<${#AppResolvedFileDepsListArr_OLDPATH[@]}; i1++ )); do
        FileName2="${AppResolvedFileDepsListArr_OLDPATH[i1]}"
        if [[ "$FileName" == "$FileName2" ]]; then
          IsFound=1
          break
        fi
      done
    fi

    if (( ! IsFound )); then
      AppUnmatchedFileDepsListArr_APP[${#AppUnmatchedFileDepsListArr_APP[@]}]="$FileName"
      AppUnmatchedFileDepsListArr_APP[${#AppUnmatchedFileDepsListArr_APP[@]}]="${AppUnresolvedFileDepsListArr_APPPATH[i0+1]}"
      AppUnmatchedFileDepsListArr_APP[${#AppUnmatchedFileDepsListArr_APP[@]}]="APPPATH"
      (( ${#FileName} > FileNameMaxLen )) && FileNameMaxLen="${#FileName}"
    fi
  done

  # DEPSPATH
  for (( i0=1; i0<${#AppUnresolvedFileDepsListArr_DEPSPATH[@]}; i0+=${AppUnresolvedFileDepsListArr_DEPSPATH[0]} )); do
    FileName="${AppUnresolvedFileDepsListArr_DEPSPATH[i0+0]}"
    IsFound=0
    for (( i1=0; i1<${#AppResolvedFileDepsListArr_APPPATH[@]}; i1++ )); do
      FileName2="${AppResolvedFileDepsListArr_APPPATH[i1]}"
      if [[ "$FileName" == "$FileName2" ]]; then
        IsFound=1
        break
      fi
    done
    if (( ! IsFound )); then
      for (( i1=0; i1<${#AppResolvedFileDepsListArr_OLDPATH[@]}; i1++ )); do
        FileName2="${AppResolvedFileDepsListArr_OLDPATH[i1]}"
        if [[ "$FileName" == "$FileName2" ]]; then
          IsFound=1
          break
        fi
      done
    fi

    if (( ! IsFound )); then
      AppUnmatchedFileDepsListArr_APP[${#AppUnmatchedFileDepsListArr_APP[@]}]="$FileName"
      AppUnmatchedFileDepsListArr_APP[${#AppUnmatchedFileDepsListArr_APP[@]}]="${AppUnresolvedFileDepsListArr_DEPSPATH[i0+1]}"
      AppUnmatchedFileDepsListArr_APP[${#AppUnmatchedFileDepsListArr_APP[@]}]="DEPSPATH"
      (( ${#FileName} > FileNameMaxLen )) && FileNameMaxLen="${#FileName}"
    fi
  done

  if (( ${#AppUnmatchedFileDepsListArr_APP[@]} > 1 )); then
    HasFiles=1
  else
    HasFiles=0
  fi

  (( FileNameMaxLen > ${#FileNameHeader}+3 )) && FileNameHeaderAligner="${Padding40:0:FileNameMaxLen-${#FileNameHeader}-3}"

  {
    echo "# Legend:"
    echo "#   * - minimal level of dependency indirection"
    echo "# $FileNameHeaderAligner$FileNameHeader | * | Group"
  } | \
  {
    if [[ -f "$AppUnmatchedFileDepsListFilePath_APP" ]]; then
      tee -a "$AppUnmatchedFileDepsListFilePath_APP"
    else
      tee
    fi
  }

  local Group

  {
    for (( i0=1; i0<${#AppUnmatchedFileDepsListArr_APP[@]}; i0+=${AppUnmatchedFileDepsListArr_APP[0]} )); do
      FileName="${AppUnmatchedFileDepsListArr_APP[i0+0]}"
      MinIndirLvl="${AppUnmatchedFileDepsListArr_APP[i0+1]}"
      Group="${AppUnmatchedFileDepsListArr_APP[i0+2]}"

      FileNameHeaderAligner=""
      (( FileNameMaxLen > ${#FileName} )) && FileNameHeaderAligner="${Padding40:0:FileNameMaxLen-${#FileName}}"
      MinIndirLvlAligner=""
      (( 2 > ${#MinIndirLvl} )) && MinIndirLvlAligner="${Padding40:0:3-${#MinIndirLvl}}"

      echo "$FileNameHeaderAligner$FileName $MinIndirLvlAligner$MinIndirLvl $Group"
    done
  } | sort - | \
  {
    if [[ -f "$AppUnmatchedFileDepsListFilePath_APP" ]]; then
      tee -a "$AppUnmatchedFileDepsListFilePath_APP"
    else
      tee
    fi
  }

  {
    (( HasFiles )) || echo "None"
    echo ""
  } | \
  {
    if [[ -f "$AppUnmatchedFileDepsListFilePath_APP" ]]; then
      tee -a "$AppUnmatchedFileDepsListFilePath_APP"
    else
      tee
    fi
  }

  echo "Application package \"$OS\" unmatched dependencies (OLDPATH)..."

  {
    echo "APPPATH=$AppPath"
    echo "PATH=$PATH"
    echo "OLDPATH=$OLDPATH"
    echo "OSTYPEPATH=$OSTYPEPATH"
    echo "DEPSPATH=$DEPSPATH"
    echo ""
  } | \
  {
    if [[ -f "$AppUnmatchedFileDepsListFilePath_OS" ]]; then
      tee -a "$AppUnmatchedFileDepsListFilePath_OS"
    else
      tee
    fi
  } 2>&1 >/dev/null # supress duplicating output

  FileNameHeaderAligner=""
  (( FileNameMaxLen=${#FileNameHeader}+3 ))

  for (( i0=1; i0<${#AppUnresolvedFileDepsListArr_OLDPATH[@]}; i0+=${AppUnresolvedFileDepsListArr_OLDPATH[0]} )); do
    FileName="${AppUnresolvedFileDepsListArr_OLDPATH[i0+0]}"
    IsFound=0
    for (( i1=0; i1<${#AppResolvedFileDepsListArr_APPPATH[@]}; i1++ )); do
      FileName2="${AppResolvedFileDepsListArr_APPPATH[i1]}"
      if [[ "$FileName" == "$FileName2" ]]; then
        IsFound=1
        break
      fi
    done
    if (( ! IsFound )); then
      for (( i1=0; i1<${#AppResolvedFileDepsListArr_DEPSPATH[@]}; i1++ )); do
        FileName2="${AppResolvedFileDepsListArr_DEPSPATH[i1]}"
        if [[ "$FileName" == "$FileName2" ]]; then
          IsFound=1
          break
        fi
      done
      if (( ! IsFound )); then
        for (( i1=1; i1<${#AppUnresolvedFileDepsListArr_APPPATH[@]}; i1+=${AppUnresolvedFileDepsListArr_APPPATH[0]} )); do
          FileName2="${AppUnresolvedFileDepsListArr_APPPATH[i1]}"
          if [[ "$FileName" == "$FileName2" ]]; then
            IsFound=1
            break
          fi
        done
        if (( ! IsFound )); then
          for (( i1=1; i1<${#AppUnresolvedFileDepsListArr_DEPSPATH[@]}; i1+=${AppUnresolvedFileDepsListArr_DEPSPATH[0]} )); do
            FileName2="${AppUnresolvedFileDepsListArr_DEPSPATH[i1]}"
            if [[ "$FileName" == "$FileName2" ]]; then
              IsFound=1
              break
            fi
          done
        fi
      fi
    fi

    if (( ! IsFound )); then
      AppUnmatchedFileDepsListArr_OS[${#AppUnmatchedFileDepsListArr_OS[@]}]="$FileName"
      AppUnmatchedFileDepsListArr_OS[${#AppUnmatchedFileDepsListArr_OS[@]}]="${AppUnresolvedFileDepsListArr_OLDPATH[i0+1]}"
      #AppUnmatchedFileDepsListArr_OS[${#AppUnmatchedFileDepsListArr_OS[@]}]="OLDPATH"
      (( ${#FileName} > FileNameMaxLen )) && FileNameMaxLen="${#FileName}"
    fi
  done

  if (( ${#AppUnmatchedFileDepsListArr_OS[@]} > 1 )); then
    HasFiles=1
  else
    HasFiles=0
  fi

  (( FileNameMaxLen > ${#FileNameHeader}+3 )) && FileNameHeaderAligner="${Padding40:0:FileNameMaxLen-${#FileNameHeader}-3}"

  {
    echo "# Legend:"
    echo "#   * - minimal level of dependency indirection"
    echo "# $FileNameHeaderAligner$FileNameHeader | *"
  } | \
  {
    if [[ -f "$AppUnmatchedFileDepsListFilePath_OS" ]]; then
      tee -a "$AppUnmatchedFileDepsListFilePath_OS"
    else
      tee
    fi
  }

  {
    for (( i0=1; i0<${#AppUnmatchedFileDepsListArr_OS[@]}; i0+=${AppUnmatchedFileDepsListArr_OS[0]} )); do
      FileName="${AppUnmatchedFileDepsListArr_OS[i0+0]}"
      MinIndirLvl="${AppUnmatchedFileDepsListArr_OS[i0+1]}"
      #Group="${AppUnmatchedFileDepsListArr_OS[i0+2]}"

      FileNameHeaderAligner=""
      (( FileNameMaxLen > ${#FileName} )) && FileNameHeaderAligner="${Padding40:0:FileNameMaxLen-${#FileName}}"
      MinIndirLvlAligner=""
      (( 2 > ${#MinIndirLvl} )) && MinIndirLvlAligner="${Padding40:0:3-${#MinIndirLvl}}"

      echo "$FileNameHeaderAligner$FileName $MinIndirLvlAligner$MinIndirLvl"
    done
  } | sort - | \
  {
    if [[ -f "$AppUnmatchedFileDepsListFilePath_OS" ]]; then
      tee -a "$AppUnmatchedFileDepsListFilePath_OS"
    else
      tee
    fi
  }

  {
    (( HasFiles )) || echo "None"
    echo ""
  } | \
  {
    if [[ -f "$AppUnmatchedFileDepsListFilePath_OS" ]]; then
      tee -a "$AppUnmatchedFileDepsListFilePath_OS"
    else
      tee
    fi
  }

  # save array to the external namespace
  if [[ -n "${ReturnArrs[0]}" ]]; then
    declare_array ${ReturnArrs[0]} "${AppMatchedFileDepsListArr_APPPATH[@]}"
  fi

  if [[ -n "${ReturnArrs[1]}" ]]; then
    declare_array ${ReturnArrs[1]} "${AppMatchedFileDepsListArr_DEPSPATH[@]}"
  fi

  if [[ -n "${ReturnArrs[2]}" ]]; then
    declare_array ${ReturnArrs[2]} "${AppMatchedFileDepsListArr_OLDPATH[@]}"
  fi

  if [[ -n "${ReturnArrs[3]}" ]]; then
    declare_array ${ReturnArrs[3]} "${AppUnmatchedFileDepsListArr_APP[@]}"
  fi

  if [[ -n "${ReturnArrs[4]}" ]]; then
    declare_array ${ReturnArrs[4]} "${AppUnmatchedFileDepsListArr_OS[@]}"
  fi

  return 0
}

function CollectPackageDeps()
{
  local TargetInputDirPath="$1"
  local TargetOutputDirPath="$2"
  local BaseName="$3"

  GetAbsolutePathFromDirPath "$TargetInputDirPath"
  local TargetInputAbsDirPath="$RETURN_VALUE"
  [[ -d "$TargetInputAbsDirPath" ]] || return 1

  GetAbsolutePathFromDirPath "$TargetOutputDirPath"
  local TargetOutputAbsDirPath="$RETURN_VALUE"
  [[ -d "$TargetOutputAbsDirPath" ]] || return 2

  [[ -n "$BaseName" ]] || return 3

  MakeDir -p "$TargetOutputAbsDirPath/bin/$OSTYPE" || return 4
  MakeDir -p "$TargetOutputAbsDirPath/logs" || return 5

  local MatchedDepsListArr_DEPSPATH

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

  SearchAppDependencies "$TargetInputAbsDirPath" '' 'exe dll so' '"" MatchedDepsListArr_DEPSPATH' \
    "$TargetOutputAbsDirPath/logs/$BaseName.1_search_paths.lst" \
    "$TargetOutputAbsDirPath/logs/$BaseName.2_appfiles.lst" \
    "$TargetOutputAbsDirPath/logs/$BaseName.3_appfiles_deps1lvltree.lst" \
    "$TargetOutputAbsDirPath/logs/$BaseName.4_matcheddeps_APPPATH.lst" \
    "$TargetOutputAbsDirPath/logs/$BaseName.5_matcheddeps_DEPSPATH.lst" \
    "$TargetOutputAbsDirPath/logs/$BaseName.6_matcheddeps_OLDPATH.lst" \
    "$TargetOutputAbsDirPath/logs/$BaseName.7_unmatcheddeps_APP.lst" \
    "$TargetOutputAbsDirPath/logs/$BaseName.8_unmatcheddeps_OS.lst" || return 32

  echo "Preparing dependency files for packing..."

  local FilePath
  local FilePath2
  local FileName
  local FileName2
  local FileSize
  local FileSize2
  local FileCrc32Value
  local FileCrc32Value2
  local FileHashMd5Value
  local FileHashMd5Value2
  local IsFound
  local i
  local j

  #local TarFiles=()
  local TarFilesParams
  TarFilesParams=(4)

  for (( i=1; i<${#MatchedDepsListArr_DEPSPATH[@]}; i+=${MatchedDepsListArr_DEPSPATH[0]} )); do
    FileName="${MatchedDepsListArr_DEPSPATH[i+1]}"
    FileSize="${MatchedDepsListArr_DEPSPATH[i+3]}"
    FileCrc32Value="${MatchedDepsListArr_DEPSPATH[i+4]}"
    FileHashMd5Value="${MatchedDepsListArr_DEPSPATH[i+5]}"
    FileHashSha1Value="${MatchedDepsListArr_DEPSPATH[i+6]}"
    IsFound=0
    for (( j=1; j<${#TarFilesParams[@]}; j+=${TarFilesParams[0]} )); do
      FileName2="${TarFilesParams[j+0]}"
      if [[ "$FileName" == "$FileName2" ]]; then
        FileSize2="${TarFilesParams[j+1]}"
        if [[ "$FileSize" == "$FileSize2" ]]; then
          FileCrc32Value2="${TarFilesParams[j+2]}"
          if [[ "$FileCrc32Value" == "$FileCrc32Value2" ]]; then
            FileHashMd5Value2="${TarFilesParams[j+3]}"
            if [[ "$FileHashMd5Value" == "$FileHashMd5Value2" ]]; then
              IsFound=1
              break
            fi
          fi
        fi
      fi
    done

    if (( ! IsFound )); then
      FilePath="${MatchedDepsListArr_DEPSPATH[i+0]}"
      # Ignore not absolute paths
      if [[ "${FilePath:0:1}" == "/" ]]; then
        FilePath2="bin/$OSTYPE$FilePath"
        #TarFiles[${#TarFiles[@]}]="$FilePath2"
        TarFilesParams[${#TarFilesParams[@]}]="$FileName"
        TarFilesParams[${#TarFilesParams[@]}]="$FileSize"
        TarFilesParams[${#TarFilesParams[@]}]="$FileCrc32Value"
        TarFilesParams[${#TarFilesParams[@]}]="$FileHashMd5Value"

        MakeDir -p "$TargetOutputAbsDirPath/${FilePath2%/*}" && \
          cp -fv "$FilePath" "$TargetOutputAbsDirPath/$FilePath2"
      fi
    fi
  done

  echo ""

  return 0
}

function AlterDirectoryPermissions()
{
  PrintDirectoryPermissions "$@"
}

function ReadAndCalculateProjectBuildDependencies()
{
  local ProjectPath="$1"
  local ProjectPlatformType="$2"
  local ProjectScenarioName="$3"

  # drop return values.
  # not cyclic project matched/unmatched dependency list
  ProjectMatchedDependencyListArr=(6+6) # N items per user structure + M items per technical structure
  ProjectUnmatchedDependencyListArr=(4+6)

  # cyclic project unmatched dependency list
  ProjectCyclicDependencyListArr=(5)

  (( ${#ProjectDependencies[@]} <= 1 )) && return 255

  local ProjectMatchedDependencyDataListArr
  ProjectMatchedDependencyDataListArr=()

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

  # dependencies to resolve in current iteration
  local AppToResolveFileDepsListArr
  AppToResolveFileDepsListArr=(5) # N items per structure

  # path in the dependencies tree to currently processing dependency w/o root node
  local PathOfCurrentDependency
  PathOfCurrentDependency=()

  local RootProjectPath="$ProjectPath"

  # add at first the root project
  ProjectMatchedDependencyListArr[j+0]=$ProjectPath         # Project Path
  ProjectMatchedDependencyListArr[j+1]=0                    # *
  ProjectMatchedDependencyListArr[j+2]=""                   # Build Status
  ProjectMatchedDependencyListArr[j+3]=$ProjectPlatformType # Platform Type
  ProjectMatchedDependencyListArr[j+4]=$ProjectScenarioName # Scenario Name
  ProjectMatchedDependencyListArr[j+5]='/'                  # Dependency Tree Path

  local i
  local j

  for (( i=1, j=1, k=1; i<${#ProjectDependencies[@]}; i+=ProjectDependencies[0], j+=ProjectMatchedDependencyListArr[0] )); do
    ProjectPath=${ProjectDependencies[i+0]}
    ProjectPlatformType=${ProjectDependencies[i+1]}
    ProjectScenarioName=${ProjectDependencies[i+2]}
    if IsProjectExists $ProjectPath $ProjectPlatformType -s; then
      ProjectMatchedDependencyListArr[j+0]=$ProjectPath         # Project Path
      ProjectMatchedDependencyListArr[j+1]=1                    # *
      ProjectMatchedDependencyListArr[j+2]=""                   # Build Status
      ProjectMatchedDependencyListArr[j+3]=$ProjectPlatformType # Platform Type
      ProjectMatchedDependencyListArr[j+4]=$ProjectScenarioName # Scenario Name
      ProjectMatchedDependencyListArr[j+5]='/'                  # Dependency Tree Path
      # copy of above
      AppToResolveFileDepsListArr[k+0]=$ProjectPath
      AppToResolveFileDepsListArr[k+1]=1
      AppToResolveFileDepsListArr[k+2]=$ProjectPlatformType
      AppToResolveFileDepsListArr[k+3]=$ProjectScenarioName
      AppToResolveFileDepsListArr[k+4]='/'
      (( k+=AppToResolveFileDepsListArr[0] ))
    else
      # is not found, leave it as an unmatched
      ProjectUnmatchedDependencyListArr[j+0]=$ProjectPath         # Project Path
      ProjectUnmatchedDependencyListArr[j+1]=1                    # *
      ProjectUnmatchedDependencyListArr[j+2]=$ProjectPlatformType # Platform Type
      ProjectUnmatchedDependencyListArr[j+3]=$ProjectScenarioName # Scenario Name
      ProjectUnmatchedDependencyListArr[j+4]='/'                  # Dependency Tree Path
    fi
    # technical fields, are not visible for the printer (PrintProjectBuildDependencies)
    ProjectMatchedDependencyListArr[j+5]=-1 # primary parent offset
    ProjectMatchedDependencyListArr[j+6]=-1 # first child offset
    ProjectMatchedDependencyListArr[j+7]=-1 # number of children
    ProjectMatchedDependencyListArr[j+8]=-1 # first secondary parent offset
    ProjectMatchedDependencyListArr[j+9]=-1 # number of secondary parents
  done

  # recursively expand dependencies, add children to the end of the list
  for (( i=1; i<${#AppToResolveFileDepsListArr[@]}; i+=AppToResolveFileDepsListArr[0] )); do
    GetProjectConfigFilePath $ProjectPath $ProjectPlatformType
    source "$RETURN_VALUE"
    $ProjectDirPath/$ProjectPlatformType/config.sh
  done
  "$BuildRootDirPath/Projects/$ProjectPath/$ProjectPlatformType/config.sh"
  MakeCommandArgumentsFromFile - && echo -n "$RETURN_VALUE";

  # load configuration file in the shell child process to drop all loaded variables at the return, and
  # return result as raw string for the array variable
}

function PrintProjectBuildDependencies()
{
  local PrintListHeaderNames
  local PrintListColumnFlags

  PrintListHeaderNames=('Project Path' '*' 'Build Status' 'Platform Type' 'Scenario Name' 'Dependency Tree Path')
  PrintListColumnFlags=(HAlign=L HAlign=R HAlign=L HAlign=L HAlign=L HALign=L)

  echo "Project matched dependencies:"
  echo "# Legend:"
  echo "#   * - minimal level of dependency indirection"
  PrintSpreadSheet -PrintListColumnFlags PrintListHeaderNames ProjectMatchedDependencyListArr
  echo ""

  PrintListHeaderNames=('Project Path' '*' 'Platform Type' 'Scenario Name' 'Dependency Tree Path')
  PrintListColumnFlags=(HAlign=L HAlign=R HAlign=L HAlign=L HALign=L)

  echo "Project unmatched dependencies:"
  echo "# Legend:"
  echo "#   * - minimal level of dependency indirection"
  PrintSpreadSheet -PrintListColumnFlags PrintListHeaderNames ProjectUnmatchedDependencyListArr
  echo ""

  PrintListHeaderNames=('Project Path' 'Dependent On' '*' 'Dependency Tree Path')
  PrintListColumnFlags=(HAlign=L HAlign=L HAlign=R HAlign=L)

  if (( ${#ProjectCyclicDependencyListArr[@]} > 1 )); then
    echo "Project cyclic dependencies:"
    echo "# Legend:"
    echo "#   * - minimal level of dependency indirection"
    PrintSpreadSheet -PrintListColumnFlags PrintListHeaderNames ProjectCyclicDependencyListArr
    echo ""
  fi

  return 0
}
