#!/bin/bash

# Script can be ONLY included by "source" command.
if [[ -n "$BASH" && (-z "$BASH_LINENO" || ${BASH_LINENO[0]} -gt 0) ]] && (( ! ${#TACKLELIB_SOURCE_ROOT_INIT_SH} )); then 

TACKLELIB_SOURCE_ROOT_INIT_SH=1 # including guard

if [[ "$(type -t ScriptBaseInit)" != "function" ]]; then
  function ScriptBaseInit
  {
    if [[ -n "$BASH_LINENO" ]] && (( ${BASH_LINENO[0]} > 0 )); then
      ScriptFilePath="${BASH_SOURCE[0]//\\//}"
    else
      ScriptFilePath="${0//\\//}"
    fi
    if [[ "${ScriptFilePath:1:1}" == ":" ]]; then
      ScriptFilePath="`/bin/readlink -f "/${ScriptFilePath/:/}"`"
    else
      ScriptFilePath="`/bin/readlink -f "$ScriptFilePath"`"
    fi

    ScriptDirPath="${ScriptFilePath%[/]*}"
    ScriptFileName="${ScriptFilePath##*[/]}"
  }

  ScriptBaseInit "$@"
fi

# Special exit code value variable has used by the specific set of functions
# like `Call` and `Exit` to hold the exit code over the builtin functions like
# `pushd` and `popd` which are changes the real exit code.
LastError=0

function Exit()
{
  let NEST_LVL-=1

  #[[ $NEST_LVL -eq 0 ]] && Pause

  if [[ $# -eq 0 ]]; then
    exit $LastError
  else
    exit $@
  fi
}

export PROJECT_ROOT="`/bin/readlink -f "$ScriptDirPath/.."`"

fi
