#!/bin/bash_entry

# Author:   Andrey Dibrov (andry at inbox dot ru)

# Build scripts resource library, implements resource functions and variables
# for the build scripts.

# Script can be ONLY included by "source" command.
[[ -n "$BASH" && (-z "$BASH_LINENO" || BASH_LINENO[0] -gt 0) && (-z "$SOURCE_CONTOOLS_BUILDRES_SH" || SOURCE_CONTOOLS_BUILDRES_SH -eq 0) ]] || return 0 || exit 0 # exit to avoid continue if the return can not be called

SOURCE_CONTOOLS_BUILDRES_SH=1 # including guard

# Build common resources.

CommonVersionPattern1='m "\\d+.\\d+(?:\\.\\d+[a-zA-Z]*)?(?:-\\d+[a-zA-Z]*)?"'
DejaGnuVersionPattern1='m "Framework version[^\\r\\n]+?(\\d+.\\d+(?:\\.\\d+[a-zA-Z]*)?(?:-\\d+[a-zA-Z]*))?" '\''print "$1"'\'' x'
CommonVersionParsePattern1='m "[0]*(\\d+)\\.[0]*(\\d+[a-zA-Z]*)(?:\\.[0]*(\\d+[a-zA-Z]*))?(?:-[0]*(\\d+[a-zA-Z]*))?" '\''print "$1 $2"; if(defined($3) && length($3) > 0) { print " $3"; }; if(defined($4) && length($4) > 0) { print " $4"; }'\'' x'
TargetInvalidPathCharPttnForGrep="[ "$'\t'"\"'\`?*&|<>()]+"

function ProjectCompileIntHandler()
{
  return 0
}

function ProjectCompileExitHandler()
{
  local LastError="${1:-0}"

  SetCompileEndTime

  PrintCompileStatus
  PrintCompileStats

  return 0
}

function ProjectTargetIntHandler()
{
  return 0
}

function ProjectTargetExitHandler()
{
  local LastError="${1:-0}"

  SetTargetEndTime

  PrintTargetStatus
  PrintTargetStats

  if (( ! UserInterrupted )) && { (( ! LastError )) || IsTargetExitCodeIgnored "$LastError" && (( DoRunTarget != 2 )); }; then
    if (( DoRunTarget >= 0 && ( ! IsProjectCacheLoaded || TargetBuildIndex >= ProjectScenarioTargetFromIndex ) )); then
      SaveProjectCacheFile
    fi
  fi

  return 0
}

function ProjectTargetStageIntHandler()
{
  return 0
}

function ProjectTargetStageExitHandler()
{
  local LastError="${1:-0}"

  SetTargetStageEndTime

  PrintTargetStageStatus
  PrintTargetStageStats

  return 0
}
