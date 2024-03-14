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

# tests the PushTrap*/PopTrap*/GetTrap* functional (user trap handler destructor calls + PushTrap*/PopTrap*/GetTrap*)
echo "Tests: traplib/$TestScriptFileName"
echo "Desc: tests the PushTrap*/PopTrap*/GetTrap* functional (user trap handler destructor calls + PushTrap*/PopTrap*/GetTrap*)"
echo

function RunAllTests()
{
  RunTest Test_1_1 2:1
  RunTest Test_1_2 2:1
  RunTest Test_2_1 1
  RunTest Test_2_2 1:2
  RunTest Test_3_1 0:3:3:0
  RunTest Test_3_2 0:1:1:0
  RunTest Test_3_3 1:0:0:0
  RunTest Test_4_1 1:2
  RunTest Test_4_2 1:2
  RunTest Test_4_3 1
  RunTest Test_4_4
  RunTest Test_5_1 123:123:123
}

function RunAllTests1()
{
  RunTest Test_1_1 2:1
}

function Test_1_1()
{
  function Test()
  {
    PushTrap test "TestEcho 1; TestAssertHasNoExtraVariables" RETURN
    PushTrap test "TestEcho 2" RETURN
    trap '' RETURN # global variables leak
  }
  Test
  PopTrap test RETURN # initiates cleanup and late user handlers call
  TestAssertHasNoExtraVariables
}

function Test_1_2()
{
  function Test()
  {
    PushTrap test "TestEcho 1; TestAssertHasNoExtraVariables" RETURN
    PushTrap test "TestEcho 2" RETURN
    trap '' RETURN # global variables leak
  }
  Test
  PushTrap test '' RETURN # initiates cleanup and late user handlers call
  TestAssertHasNoExtraVariables
}

function Test_2_1()
{
  function Test()
  {
    function LocalHandler1()
    {
      TestEcho 1
      TestAssertHasNoExtraVariables
    }
    PushTrapFunctionMove test LocalHandler1 RETURN
    TestAssertHasExtraVariables RETURN
  }
  Test
  TestAssertHasNoExtraVariables
}

function Test_2_2()
{
  HANDLER_NAME=''
  function Test()
  {
    function LocalHandler1()
    {
      HANDLER_NAME="${FUNCNAME[0]}"
      TestEcho 1
    }
    PushTrapFunctionMove test LocalHandler1 RETURN
  }
  Test
  declare -f "$HANDLER_NAME" >/dev/null 2>&1 || TestEcho 2 # should be autodeleted already
  tkl_unset HANDLER_NAME
  TestAssertHasNoExtraVariables
}

function Test_3_1()
{
  function Test()
  {
    PushTrap test "" RETURN RETURN
    PushTrap test "" RETURN
    GetTrapNum test RETURN RETURN EXIT
    TestEcho $?
    TestEcho ${RETURN_VALUES[0]}
    TestEcho ${RETURN_VALUES[1]}
    TestEcho ${RETURN_VALUES[2]}
  }
  Test
  TestAssertHasNoExtraVariables
}

function Test_3_2()
{
  function Test()
  {
    PushTrap test "" RETURN EXIT
    PushTrap test "" RETURN
    PopTrap test EXIT RETURN
    GetTrapNum test RETURN RETURN EXIT
    TestEcho $?
    TestEcho ${RETURN_VALUES[0]}
    TestEcho ${RETURN_VALUES[1]}
    TestEcho ${RETURN_VALUES[2]}
  }
  Test
  TestAssertHasNoExtraVariables
}

function Test_3_3()
{
  function Test()
  {
    PushTrap test "" RETURN EXIT
    PushTrap test "" EXIT RETURN
    PopTrap test EXIT RETURN
    PopTrap test RETURN EXIT
    GetTrapNum test EXIT RETURN EXIT
    TestEcho $?
    TestEcho ${RETURN_VALUES[0]}
    TestEcho ${RETURN_VALUES[1]}
    TestEcho ${RETURN_VALUES[2]}
  }
  Test
  TestAssertHasNoExtraVariables
}

function Test_4_1()
{
  function UserTrapHandler()
  {
    TestAssertHasExtraVariables RETURN
    echo ">UserTrapHandler $@"
    TestEcho 1
    GetTrapNum "$1" "$2"
    if (( ! $? && RETURN_VALUES[0] )); then   
      CallDefaultTrapHandler "$@" # call default trap handler
    fi
    TestAssertHasNoExtraVariables
  }
  function Test()
  {
    PushTrapHandler test 'UserTrapHandler' 'TestEcho 2; TestAssertHasNoExtraVariables' '' RETURN
  }
  Test
}

function Test_4_2()
{
  function UserTrapHandler()
  {
    TestAssertHasExtraVariables RETURN
    echo ">UserTrapHandler $@"
    TestEcho 1
    GetTrapNum "$1" "$2"
    if (( ! $? && RETURN_VALUES[0] )); then
      ( CallDefaultTrapHandler "$@" ) # call default trap handler
    fi
    TestAssertHasExtraVariables RETURN
  }
  function Test()
  {
    PushTrapHandler test 'UserTrapHandler' 'TestEcho 2; TestAssertHasNoExtraVariables' '' RETURN
  }
  Test
}

function Test_4_3()
{
  function UserTrapHandler()
  {
    TestAssertHasExtraVariables RETURN
    echo ">UserTrapHandler $@"
    TestEcho 1
    #CallDefaultTrapHandler "$@" # forget to call default trap handler
    TestAssertHasExtraVariables RETURN
  }
  function Test()
  {
    PushTrapHandler test 'UserTrapHandler' 'TestEcho 2; TestAssertHasNoExtraVariables' '' RETURN
  }
  Test
  TestAssertHasNoExtraVariables
}

function Test_4_4()
{
  function UserTrapHandler()
  {
    TestAssertHasExtraVariables RETURN
    echo ">UserTrapHandler $@"
    TestEcho 1
    #CallDefaultTrapHandler "$@" # forget to call default trap handler
    TestAssertHasExtraVariables RETURN
  }
  function Test()
  {
    PushTrapHandler test 'UserTrapHandler' 'TestEcho 2; TestAssertHasNoExtraVariables' '' RETURN
    PopTrap test RETURN
    TestAssertHasNoExtraVariables
  }
  Test
}

function Test_5_1()
{
  function UserTrapHandler()
  {
    TestEcho $?
    TestAssertHasExtraVariables EXIT
    echo ">UserTrapHandler $@"
    CallDefaultTrapHandler "$@" # forget to call default trap handler
    TestAssertHasExtraVariables EXIT
  }
  function Test()
  {
    (
      PushTrapHandler test 'UserTrapHandler' 'TestEcho $?; TestAssertHasNoExtraVariables; tkl_set_last_error 222' '' EXIT
      TestAssertHasExtraVariables EXIT
      tkl_set_last_error 123
    )
    TestEcho $?
  }
  Test
  TestAssertHasNoExtraVariables
}

RunAllTests

fi
