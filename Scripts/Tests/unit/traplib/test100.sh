#!/bin/bash_entry

if [[ -n "$BASH" ]]; then

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

source "$TestScriptDirPath/testlib.sh"

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
    Unset num
    Unset i
  }
  BenchTrapPushPop "${TEST_SCRIPT_ARGS[@]}"
  TestAssertHasNoExtraVariables
}

RunAllTests

fi
