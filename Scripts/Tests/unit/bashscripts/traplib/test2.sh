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

# tests the PushTrap/PopTrap functional (EXIT only traps)
echo "Tests: traplib/$TestScriptFileName"
echo "Desc: tests the PushTrap/PopTrap functional (EXIT only traps)"
echo

function RunAllTests()
{
  RunTest Test_1_1 1
  RunTest Test_1_2 2:1
  RunTest Test_1_3 1
  RunTest Test_1_4
  RunTest Test_1_5
  RunTest Test_1_6
  RunTest Test_1_7
  RunTest Test_2_1 1
  RunTest Test_2_2 2:1
  RunTest Test_2_3 1
  RunTest Test_2_4
  RunTest Test_2_5
  RunTest Test_2_6
  RunTest Test_2_7
  RunTest Test_3_1 1:1
  RunTest Test_3_2 2:1
  RunTest Test_3_3 1
  RunTest Test_3_4
  RunTest Test_3_5
  RunTest Test_3_6
  RunTest Test_3_7
  RunTest Test_4_1 3:2:1
  RunTest Test_4_2 3:2:1
  RunTest Test_4_3 2:1
  RunTest Test_4_4 2:1
  RunTest Test_4_5 1
  RunTest Test_4_6 3:2:1
  RunTest Test_4_7 3:2:1
  RunTest Test_5_1 1:1
  RunTest Test_5_2 2:2:1
  RunTest Test_5_3
  RunTest Test_5_4 1
  RunTest Test_5_5
  RunTest Test_5_6
  RunTest Test_5_7
}

function RunAllTests1()
{
  RunTest Test_1_1 1
}

function Test_1_1()
{
  PushTrap test "TestEcho 1; TestAssertHasNoExtraVariables" EXIT
  TestAssertHasExtraVariables EXIT
}

function Test_1_2()
{
  PushTrap test "TestEcho 1; TestAssertHasNoExtraVariables" EXIT
  PushTrap test "TestEcho 2; TestAssertHasExtraVariables EXIT" EXIT
  TestAssertHasExtraVariables EXIT
}

function Test_1_3()
{
  PushTrap test "TestEcho 1; TestAssertHasNoExtraVariables" EXIT
  PushTrap test "TestEcho 2" EXIT
  PopTrap test EXIT
  TestAssertHasExtraVariables EXIT
}

function Test_1_4()
{
  PushTrap test "TestEcho 1" EXIT
  PushTrap test "TestEcho 2; TestAssertHasExtraVariables" EXIT
  PopTrap test EXIT
  PopTrap test EXIT
  TestAssertHasNoExtraVariables
}

function Test_1_5()
{
  PushTrap test "TestEcho 1" EXIT
  PushTrap test "TestEcho 2" EXIT
  PopTrap test EXIT
  PopTrap test EXIT
  PopTrap test EXIT
  TestAssertHasNoExtraVariables
}

function Test_1_6()
{
  PopTrap test EXIT
  TestAssertHasNoExtraVariables
}

function Test_1_7()
{
  PopTrap test EXIT
  PopTrap test EXIT
  TestAssertHasNoExtraVariables
}

function Test_2_1()
{
  (
    PushTrap test "TestEcho 1; TestAssertHasNoExtraVariables" EXIT
    TestAssertHasExtraVariables EXIT
  )
  TestAssertHasNoExtraVariables
}

function Test_2_2()
{
  (
    PushTrap test "TestEcho 1; TestAssertHasNoExtraVariables" EXIT
    PushTrap test "TestEcho 2; TestAssertHasExtraVariables EXIT" EXIT
    TestAssertHasExtraVariables EXIT
  )
  TestAssertHasNoExtraVariables
}

function Test_2_3()
{
  (
    PushTrap test "TestEcho 1; TestAssertHasNoExtraVariables" EXIT
    PushTrap test "TestEcho 2" EXIT
    PopTrap test EXIT
    TestAssertHasExtraVariables EXIT
  )
  TestAssertHasNoExtraVariables
}

function Test_2_4()
{
  (
    PushTrap test "TestEcho 1" EXIT
    PushTrap test "TestEcho 2" EXIT
    PopTrap test EXIT
    PopTrap test EXIT
    TestAssertHasNoExtraVariables
  )
}

function Test_2_5()
{
  (
    PushTrap test "TestEcho 1" EXIT
    PushTrap test "TestEcho 2" EXIT
    PopTrap test EXIT
    PopTrap test EXIT
    PopTrap test EXIT
    TestAssertHasNoExtraVariables
  )
}

function Test_2_6()
{
  (
    PopTrap test EXIT
    TestAssertHasNoExtraVariables
  )
}

function Test_2_7()
{
  (
    PopTrap test EXIT
    PopTrap test EXIT
    TestAssertHasNoExtraVariables
  )
}

function Test_3_1()
{
  PushTrap test "TestEcho 1" EXIT EXIT
  TestAssertHasExtraVariables EXIT
}

function Test_3_2()
{
  PushTrap test "TestEcho 1; TestAssertHasNoExtraVariables" EXIT
  (
    PushTrap test "TestEcho 2; TestAssertHasExtraVariables EXIT" EXIT
    TestAssertHasExtraVariables EXIT
  )
  TestAssertHasExtraVariables EXIT
}

function Test_3_3()
{
  PushTrap test "TestEcho 1; TestAssertHasNoExtraVariables" EXIT
  (
    PushTrap test "TestEcho 2" EXIT
    PopTrap test EXIT
    TestAssertHasExtraVariables EXIT
  )
  TestAssertHasExtraVariables EXIT
}

function Test_3_4()
{
  PushTrap test "TestEcho 1" EXIT
  (
    PushTrap test "TestEcho 2; TestAssertHasExtraVariables EXIT" EXIT
    PopTrap test EXIT
    TestAssertHasExtraVariables EXIT
  )
  PopTrap test EXIT
  TestAssertHasNoExtraVariables
}

function Test_3_5()
{
  PushTrap test "TestEcho 1" EXIT
  (
    PushTrap test "TestEcho 2" EXIT
    PopTrap test EXIT
    TestAssertHasExtraVariables EXIT
  )
  PopTrap test EXIT
  PopTrap test EXIT
  TestAssertHasNoExtraVariables
}

function Test_3_6()
{
  PopTrap test EXIT
  TestAssertHasNoExtraVariables
}

function Test_3_7()
{
  PopTrap test EXIT
  (
    PopTrap test EXIT
    TestAssertHasNoExtraVariables
  )
}

function Test_4_1()
{
  PushTrap test "TestEcho 1; TestAssertHasNoExtraVariables" EXIT
  PushTrap test "TestEcho 2; TestAssertHasExtraVariables EXIT" EXIT
  PushTrap test "TestEcho 3; TestAssertHasExtraVariables EXIT" EXIT
  TestAssertHasExtraVariables EXIT
}

function Test_4_2()
{
  PushTrap test "TestEcho 1; TestAssertHasNoExtraVariables" EXIT
  PushTrap test "TestEcho 2; TestAssertHasExtraVariables EXIT" EXIT
  PushTrap test "TestEcho 3; TestAssertHasExtraVariables EXIT" EXIT
  (
    PopTrap test EXIT
    TestAssertHasExtraVariables EXIT
  )
  TestAssertHasExtraVariables EXIT
}

function Test_4_3()
{
  PushTrap test "TestEcho 1; TestAssertHasNoExtraVariables" EXIT
  PushTrap test "TestEcho 2; TestAssertHasExtraVariables EXIT" EXIT
  PushTrap test "TestEcho 3" EXIT
  (
    PopTrap test EXIT
    TestAssertHasExtraVariables EXIT
  )
  PopTrap test EXIT
  TestAssertHasExtraVariables EXIT
}

function Test_4_4()
{
  PushTrap test "TestEcho 1; TestAssertHasNoExtraVariables" EXIT
  PushTrap test "TestEcho 2; TestAssertHasExtraVariables EXIT" EXIT
  (
    PushTrap test "TestEcho 3" EXIT
    TestAssertHasExtraVariables EXIT
    (
      PopTrap test EXIT
      TestAssertHasExtraVariables EXIT
    )
    PopTrap test EXIT
    TestAssertHasExtraVariables EXIT
  )
  TestAssertHasExtraVariables EXIT
}

function Test_4_5()
{
  PushTrap test "TestEcho 1; TestAssertHasNoExtraVariables" EXIT
  (
    PushTrap test "TestEcho 2" EXIT
    (
      PushTrap test "TestEcho 3" EXIT
      (
        PopTrap test EXIT
        TestAssertHasExtraVariables EXIT
      )
      PopTrap test EXIT
      TestAssertHasExtraVariables EXIT
    )
    PopTrap test EXIT
    TestAssertHasExtraVariables EXIT
  )
  TestAssertHasExtraVariables EXIT
}

function Test_4_6()
{
  PushTrap test "TestEcho 1; TestAssertHasNoExtraVariables" EXIT
  (
    PopTrap test EXIT
    PushTrap test "TestEcho 2; TestAssertHasExtraVariables EXIT" EXIT
    (
      PopTrap test EXIT
      PushTrap test "TestEcho 3; TestAssertHasExtraVariables EXIT" EXIT
    )
  )
  TestAssertHasExtraVariables EXIT
}

function Test_4_7()
{
  PushTrap test "TestEcho 1; TestAssertHasNoExtraVariables" EXIT
  (
    PushTrap test "TestEcho 2; TestAssertHasExtraVariables EXIT" EXIT
    (
      PushTrap test "TestEcho 3; TestAssertHasExtraVariables EXIT" EXIT
    )
  )
}

function Test_5_1()
{
  PushTrap test "TestEcho 1" EXIT EXIT
  TestAssertHasExtraVariables EXIT
}

function Test_5_2()
{
  PushTrap test "TestEcho 1; TestAssertHasNoExtraVariables" EXIT
  PushTrap test "TestEcho 2; TestAssertHasExtraVariables EXIT" EXIT EXIT
  TestAssertHasExtraVariables EXIT
}

function Test_5_3()
{
  PushTrap test "TestEcho 1" EXIT
  PushTrap test "TestEcho 2" EXIT
  PopTrap test EXIT EXIT
  TestAssertHasNoExtraVariables
}

function Test_5_4()
{
  PushTrap test "TestEcho 1; TestAssertHasNoExtraVariables" EXIT EXIT
  PushTrap test "TestEcho 2" EXIT
  PopTrap test EXIT EXIT
  TestAssertHasExtraVariables EXIT
}

function Test_5_5()
{
  PushTrap test "TestEcho 1" EXIT
  PushTrap test "TestEcho 2" EXIT EXIT
  PopTrap test EXIT
  PopTrap test EXIT EXIT
  PopTrap test EXIT
  TestAssertHasNoExtraVariables
}

function Test_5_6()
{
  PopTrap test EXIT EXIT
  TestAssertHasNoExtraVariables
}

function Test_5_7()
{
  PopTrap test EXIT
  PopTrap test EXIT EXIT
  TestAssertHasNoExtraVariables
}

RunAllTests

fi
