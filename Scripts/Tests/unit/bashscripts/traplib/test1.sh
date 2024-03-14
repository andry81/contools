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

# tests the PushTrap/PopTrap functional (RETURN only traps)
echo "Tests: traplib/$TestScriptFileName"
echo "Desc: tests the PushTrap/PopTrap functional (RETURN only traps)"
echo

function RunAllTests()
{
  RunTest Test_1_1
  RunTest Test_1_2
  RunTest Test_1_3
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
  RunTest Test_4_1
  RunTest Test_4_2
  RunTest Test_4_3
  RunTest Test_4_4
  RunTest Test_4_5
  RunTest Test_4_6
  RunTest Test_4_7
  RunTest Test_5_1 1:1
  RunTest Test_5_2 2:2:1
  RunTest Test_5_3
  RunTest Test_5_4 1
  RunTest Test_5_5
  RunTest Test_5_6
  RunTest Test_5_7
  RunTest Test_6_1 3
  RunTest Test_6_2 2
  RunTest Test_6_3 4
  RunTest Test_6_4 3
}

function RunAllTests1()
{
  RunTest Test_2_1 1
}

function Test_1_1()
{
  PushTrap test "TestEcho 1" RETURN
  TestAssertHasNoExtraVariables
}

function Test_1_2()
{
  PushTrap test "TestEcho 1; TestAssertHasNoExtraVariables" RETURN
  PushTrap test "TestEcho 2; TestAssertHasExtraVariables RETURN" RETURN
  TestAssertHasNoExtraVariables
}

function Test_1_3()
{
  PushTrap test "TestEcho 1" RETURN
  PushTrap test "TestEcho 2" RETURN
  PopTrap test RETURN
  TestAssertHasNoExtraVariables
}

function Test_1_4()
{
  PushTrap test "TestEcho 1" RETURN
  PushTrap test "TestEcho 2" RETURN
  PopTrap test RETURN
  PopTrap test RETURN
  TestAssertHasNoExtraVariables
}

function Test_1_5()
{
  PushTrap test "TestEcho 1" RETURN
  PushTrap test "TestEcho 2" RETURN
  PopTrap test RETURN
  PopTrap test RETURN
  PopTrap test RETURN
  TestAssertHasNoExtraVariables
}

function Test_1_6()
{
  PopTrap test RETURN
  TestAssertHasNoExtraVariables
}

function Test_1_7()
{
  PopTrap test RETURN
  PopTrap test RETURN
  TestAssertHasNoExtraVariables
}

function Test_2_1()
{
  function Test()
  {
    PushTrap test "TestEcho 1; TestAssertHasNoExtraVariables" RETURN
    TestAssertHasExtraVariables RETURN
  }
  Test
  TestAssertHasNoExtraVariables
}

function Test_2_2()
{
  function Test()
  {
    PushTrap test "TestEcho 1; TestAssertHasNoExtraVariables" RETURN
    PushTrap test "TestEcho 2; TestAssertHasExtraVariables RETURN" RETURN
    TestAssertHasExtraVariables RETURN
  }
  Test
  TestAssertHasNoExtraVariables
}

function Test_2_3()
{
  function Test()
  {
    PushTrap test "TestEcho 1; TestAssertHasNoExtraVariables" RETURN
    PushTrap test "TestEcho 2" RETURN
    PopTrap test RETURN
    TestAssertHasExtraVariables RETURN
  }
  Test
  TestAssertHasNoExtraVariables
}

function Test_2_4()
{
  function Test()
  {
    PushTrap test "TestEcho 1" RETURN
    PushTrap test "TestEcho 2" RETURN
    PopTrap test RETURN
    PopTrap test RETURN
    TestAssertHasNoExtraVariables
  }
  Test
}

function Test_2_5()
{
  function Test()
  {
    PushTrap test "TestEcho 1" RETURN
    PushTrap test "TestEcho 2" RETURN
    PopTrap test RETURN
    PopTrap test RETURN
    PopTrap test RETURN
    TestAssertHasNoExtraVariables
  }
  Test
}

function Test_2_6()
{
  function Test()
  {
    PopTrap test RETURN
    TestAssertHasNoExtraVariables
  }
  Test
}

function Test_2_7()
{
  function Test()
  {
    PopTrap test RETURN
    PopTrap test RETURN
    TestAssertHasNoExtraVariables
  }
  Test
}

function Test_3_1()
{
  function Test()
  {
    PushTrap test "TestEcho 1; TestAssertHasNoExtraVariables" RETURN RETURN
    TestAssertHasExtraVariables RETURN
  }
  ( Test; TestAssertHasNoExtraVariables )
}

function Test_3_2()
{
  function Test()
  {
    PushTrap test "TestEcho 1; TestAssertHasNoExtraVariables" RETURN
    PushTrap test "TestEcho 2; TestAssertHasExtraVariables RETURN" RETURN
    TestAssertHasExtraVariables RETURN
  }
  ( Test; TestAssertHasNoExtraVariables )
}

function Test_3_3()
{
  function Test()
  {
    PushTrap test "TestEcho 1; TestAssertHasNoExtraVariables" RETURN
    PushTrap test "TestEcho 2" RETURN
    PopTrap test RETURN
    TestAssertHasExtraVariables RETURN
  }
  ( Test; TestAssertHasNoExtraVariables )
}

function Test_3_4()
{
  function Test()
  {
    PushTrap test "TestEcho 1" RETURN
    PushTrap test "TestEcho 2" RETURN
    PopTrap test RETURN
    PopTrap test RETURN
    TestAssertHasNoExtraVariables
  }
  ( Test )
}

function Test_3_5()
{
  function Test()
  {
    PushTrap test "TestEcho 1" RETURN
    PushTrap test "TestEcho 2" RETURN
    PopTrap test RETURN
    PopTrap test RETURN
    PopTrap test RETURN
    TestAssertHasNoExtraVariables
  }
  ( Test )
}

function Test_3_6()
{
  function Test()
  {
    PopTrap test RETURN
    TestAssertHasNoExtraVariables
  }
  ( Test )
}

function Test_3_7()
{
  function Test()
  {
    PopTrap test RETURN
    PopTrap test RETURN
    TestAssertHasNoExtraVariables
  }
  ( Test )
}

function Test_4_1()
{
  function Test()
  {
    (
      PushTrap test "TestEcho 1" RETURN
      TestAssertHasExtraVariables RETURN
    )
    TestAssertHasNoExtraVariables
  }
  Test
}

function Test_4_2()
{
  function Test()
  {
    (
      PushTrap test "TestEcho 1" RETURN
      PushTrap test "TestEcho 2" RETURN
      TestAssertHasExtraVariables RETURN
    )
    TestAssertHasNoExtraVariables
  }
  Test
}

function Test_4_3()
{
  function Test()
  {
    (
      PushTrap test "TestEcho 1" RETURN
      PushTrap test "TestEcho 2" RETURN
      PopTrap test RETURN
      TestAssertHasExtraVariables RETURN
    )
    TestAssertHasNoExtraVariables
  }
  Test
}

function Test_4_4()
{
  function Test()
  {
    (
      PushTrap test "TestEcho 1" RETURN
      PushTrap test "TestEcho 2" RETURN
      PopTrap test RETURN
      PopTrap test RETURN
      TestAssertHasNoExtraVariables
    )
  }
  Test
}

function Test_4_5()
{
  function Test()
  {
    (
      PushTrap test "TestEcho 1" RETURN
      PushTrap test "TestEcho 2" RETURN
      PopTrap test RETURN
      PopTrap test RETURN
      PopTrap test RETURN
      TestAssertHasNoExtraVariables
    )
  }
  Test
}

function Test_4_6()
{
  function Test()
  {
    (
      PopTrap test RETURN
      TestAssertHasNoExtraVariables
    )
  }
  Test
}

function Test_4_7()
{
  function Test()
  {
    (
      PopTrap test RETURN
      PopTrap test RETURN
      TestAssertHasNoExtraVariables
    )
  }
  Test
}

function Test_5_1()
{
  function Test()
  {
    PushTrap test "TestEcho 1" RETURN RETURN
    TestAssertHasExtraVariables RETURN
  }
  Test
  TestAssertHasNoExtraVariables
}

function Test_5_2()
{
  function Test()
  {
    PushTrap test "TestEcho 1; TestAssertHasNoExtraVariables" RETURN
    PushTrap test "TestEcho 2" RETURN RETURN
    TestAssertHasExtraVariables RETURN
  }
  Test
  TestAssertHasNoExtraVariables
}

function Test_5_3()
{
  function Test()
  {
    PushTrap test "TestEcho 1" RETURN
    PushTrap test "TestEcho 2" RETURN
    PopTrap test RETURN RETURN
    TestAssertHasNoExtraVariables
  }
  Test
}

function Test_5_4()
{
  function Test()
  {
    PushTrap test "TestEcho 1; TestAssertHasNoExtraVariables" RETURN RETURN
    PushTrap test "TestEcho 2" RETURN
    PopTrap test RETURN RETURN
    TestAssertHasExtraVariables RETURN
  }
  Test
  TestAssertHasNoExtraVariables
}

function Test_5_5()
{
  function Test()
  {
    PushTrap test "TestEcho 1" RETURN
    PushTrap test "TestEcho 2" RETURN RETURN
    PopTrap test RETURN
    PopTrap test RETURN
    PopTrap test RETURN RETURN
    TestAssertHasNoExtraVariables
  }
  Test
}

function Test_5_6()
{
  function Test()
  {
    PopTrap test RETURN RETURN
    TestAssertHasNoExtraVariables
  }
  Test
}

function Test_5_7()
{
  function Test()
  {
    PopTrap test RETURN
    PopTrap test RETURN RETURN
    TestAssertHasNoExtraVariables
  }
  Test
}

function Test_6_1()
{
  function Test()
  {
    PushTrap test "TestEcho 1; TestAssertHasNoExtraVariables" RETURN
    PushTrap test "TestEcho 2" RETURN
    PopTrap test RETURN
    PopTrap test RETURN
    PushTrap test "TestEcho 3; TestAssertHasNoExtraVariables" RETURN
  }
  Test
}

function Test_6_2()
{
  function Test()
  {
    PushTrap test "TestEcho 1" RETURN RETURN
    PopTrap test RETURN RETURN
    PushTrap test "TestEcho 2; TestAssertHasNoExtraVariables" RETURN
  }
  Test
}

function Test_6_3()
{
  function Test()
  {
    PushTrap test "TestEcho 1; TestAssertHasNoExtraVariables" RETURN
    PushTrap test "TestEcho 2" RETURN
    PopTrap test RETURN
    PopTrap test RETURN
    PushTrap test "TestEcho 3; TestAssertHasNoExtraVariables" RETURN
    PopTrap test RETURN
    PushTrap test "TestEcho 4; TestAssertHasNoExtraVariables" RETURN
  }
  Test
}

function Test_6_4()
{
  function Test()
  {
    PushTrap test "TestEcho 1" RETURN RETURN
    PopTrap test RETURN RETURN
    PushTrap test "TestEcho 2; TestAssertHasNoExtraVariables" RETURN
    PopTrap test RETURN
    PushTrap test "TestEcho 3; TestAssertHasNoExtraVariables" RETURN
  }
  Test
}

RunAllTests

fi
