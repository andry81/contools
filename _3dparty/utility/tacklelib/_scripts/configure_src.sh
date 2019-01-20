#!/bin/bash

# Not version constrol source files generator.

# Script ONLY for execution.
if [[ -n "$BASH" && (-z "$BASH_LINENO" || ${BASH_LINENO[0]} -eq 0) ]]; then 

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

source "${ScriptDirPath:-.}/__init__.sh" || exit $?

let NEST_LVL+=1

CONFIGURE_ROOT="$PROJECT_ROOT"
[[ -z "$PROJECT_ROOT" ]] && Exit 1

echo "\"$CONFIGURE_ROOT/include/tacklelib/setup.hpp.in\" -> \"$CONFIGURE_ROOT/include/tacklelib/setup.hpp\""
{
  cat "$CONFIGURE_ROOT/include/tacklelib/setup.hpp.in"
} > "$CONFIGURE_ROOT/include/tacklelib/setup.hpp"

echo "\"$CONFIGURE_ROOT/include/tacklelib/debug.hpp.in\" -> \"$CONFIGURE_ROOT/include/tacklelib/debug.hpp\""
{
  cat "$CONFIGURE_ROOT/include/tacklelib/debug.hpp.in"
} > "$CONFIGURE_ROOT/include/tacklelib/debug.hpp"

echo "\"$CONFIGURE_ROOT/include/tacklelib/optimization.hpp.in\" -> \"$CONFIGURE_ROOT/include/tacklelib/optimization.hpp\""
{
  cat "$CONFIGURE_ROOT/include/tacklelib/optimization.hpp.in"
} > "$CONFIGURE_ROOT/include/tacklelib/optimization.hpp"

echo "\"$CONFIGURE_ROOT/src/setup.hpp.in\" -> \"$CONFIGURE_ROOT/src/setup.hpp\""
{
  cat "$CONFIGURE_ROOT/src/setup.hpp.in"
} > "$CONFIGURE_ROOT/src/setup.hpp"

echo "\"$CONFIGURE_ROOT/src/debug.hpp.in\" -> \"$CONFIGURE_ROOT/src/debug.hpp\""
{
  cat "$CONFIGURE_ROOT/src/debug.hpp.in"
} > "$CONFIGURE_ROOT/src/debug.hpp"

echo "\"$CONFIGURE_ROOT/src/optimization.hpp.in\" -> \"$CONFIGURE_ROOT/src/optimization.hpp\""
{
  cat "$CONFIGURE_ROOT/src/optimization.hpp.in"
} > "$CONFIGURE_ROOT/src/optimization.hpp"

Exit

fi
