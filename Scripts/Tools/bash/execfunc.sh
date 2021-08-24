#!/bin/bash

# Author:   Andrey Dibrov (andry at inbox dot ru)

# Bash script which executes function by name of bash script and name of
# function in that script. Cygwin/Mingw/Msys system required.

# Examples:
# 1. execfunc.sh "$CONTOOLS_ROOT/execbat.sh" "ExecWindowsBatch" "echo 10"
# 2. source "$CONTOOLS_ROOT/execfunc.sh"
#    ExecBashFunction "$CONTOOLS_ROOT/execbat.sh" "ExecWindowsBatch" "echo 10"
 
if [[ -n "$BASH" ]]; then

source '/bin/bash_tacklelib' || exit $?
tkl_include '__init__.sh' || tkl_abort_include
tkl_include "$CONTOOLS_ROOT/bash/stringlib.sh"
tkl_include "$CONTOOLS_ROOT/bash/filelib.sh"

function ExecBashFunction()
{
  local ScriptFile="$1"
  local FunctionName="$2"

  GetFilePath "$ScriptFile"
  local ScriptFilePath="$RETURN_VALUE"
  if [[ -z "$ScriptFilePath" || ! -f "$ScriptFilePath" ]]; then
    return 254
  fi

  local FunctionArgs=""
  shift 2
  for arg in "$@"; do
    EscapeString "$arg" "" 1
    FunctionArgs="$FunctionArgs${FunctionArgs:+ }'$RETURN_VALUE'"
  done

  source "$ScriptFile"
  eval '"$FunctionName"' $FunctionArgs
  return $?
}

if [[ -z "$BASH_LINENO" || ${BASH_LINENO[0]} -eq 0 ]]; then
  # Script was not included, then execute it.
  ExecBashFunction "$@"
  exit $?
fi

fi
