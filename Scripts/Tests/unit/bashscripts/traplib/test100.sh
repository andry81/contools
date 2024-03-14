#!/bin/bash

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

tkl_include_or_abort '__init__/__init__.sh'
tkl_include_or_abort 'testlib.sh'

if [[ -n "$BASH_LINENO" ]] && (( ${BASH_LINENO[0]} > 0 )); then
  TestScriptFilePath="${BASH_SOURCE[0]//\\//}"
else
  TestScriptFilePath="${0//\\//}"
fi
if [[ "${TestScriptFilePath:1:1}" == ":" ]]; then
  TestScriptFilePath="`/bin/readlink.exe -f "/${TestScriptFilePath/:/}"`"
else
  TestScriptFilePath="`/bin/readlink.exe -f "$TestScriptFilePath"`"
fi

TestScriptDirPath="${TestScriptFilePath%[/]*}"
TestScriptParentDirName="${TestScriptDirPath##*[/]}"
TestScriptFileName="${TestScriptFilePath##*[/]}"
TestScriptBaseFileName="${TestScriptFileName%.*}"

TestModuleInit

# test speed of PushTrap/PopTrap
echo "Tests: traplib/$TestScriptFileName"
echo "Desc: test speed of PushTrap/PopTrap"
echo

function RunAllTests()
{
  RunTest Test_1 '' 200
}

function Test_1()
{
  function BenchTrapPushPop()
  {
    local num=$1
    local i
    echo "Desc: $num iterations of PushTrap function"
    time {
      for (( i=0; i<num; i++ )); do
        PushTrap test '' RETURN
        (( !(i%10) )) && echo "$i"
      done
    }
    echo
    echo "Desc: $num iterations of PopTrap function"
    time {
      for (( i=0; i<num; i++ )); do
        PopTrap test RETURN
        (( !(i%10) )) && echo "$i"
      done
    }
    tkl_unset num
    tkl_unset i
  }
  BenchTrapPushPop "${TEST_SCRIPT_ARGS[@]}"
  TestAssertHasNoExtraVariables
}

RunAllTests

fi
