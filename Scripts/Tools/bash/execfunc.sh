#!/bin/bash

# Author:   Andrey Dibrov (andry at inbox dot ru)

# Bash script which executes function by name of bash script and name of
# function in that script. Cygwin/Mingw/Msys system required.

# Examples:
# 1. execfunc.sh "$CONTOOLS_ROOT/execbat.sh" "ExecWindowsBatch" "echo 10"
# 2. source "$CONTOOLS_ROOT/execfunc.sh"
#    ExecBashFunction "$CONTOOLS_ROOT/execbat.sh" "ExecWindowsBatch" "echo 10"
 
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
tkl_include_or_abort "$CONTOOLS_BASH_ROOT/stringlib.sh"
tkl_include_or_abort "$CONTOOLS_BASH_ROOT/filelib.sh"

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
