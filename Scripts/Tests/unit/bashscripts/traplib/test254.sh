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

# tests the PushTrap/PopTrap functional (INT traps, requires manual ctrl-z press)
echo "Tests: traplib/$TestScriptFileName"
echo "Desc: tests the PushTrap/PopTrap functional (INT traps, requires manual ctrl-z press)"
echo

function RunAllTests()
{
  CONTINUE_ON_SIGINT=1
  RunTest Test_1_1 1
  RunTest Test_1_2 1
}

function RunAllTests1()
{
  :
}

function Test_1_1()
{
  PushTrap test "TestEcho 1; TestAssertHasNoExtraVariables INT; exit 254" INT
  # infinite loop  
  while (( 1 )); do
    sleep 1
  done
}

function Test_1_2()
{
  function Test()
  {
    # disables INT handling in the INT handler
    PushTrap test '' INT
    # infinite loop
    echo "Waiting in INT handler 3 seconds (the ctrl-z is disabled)..."
    sleep 3
  }

  PushTrap test "TestEcho 1; Test; TestAssertHasNoExtraVariables INT; exit 254" INT
  # infinite loop
  while (( 1 )); do
    sleep 1
  done
}

RunAllTests

fi
