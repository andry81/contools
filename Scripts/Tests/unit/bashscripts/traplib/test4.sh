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

# tests the PushTrap/PopTrap functional (RETURN+EXIT traps, nested function calls)
echo "Tests: traplib/$TestScriptFileName"
echo "Desc: tests the PushTrap/PopTrap functional (RETURN+EXIT traps, nested function calls)"
echo

function RunAllTests()
{
  RunTest Test_1_1 2:1
  RunTest Test_1_2 1
  RunTest Test_1_3
  RunTest Test_1_4 3:2:1
  RunTest Test_1_5 2:1
  RunTest Test_1_6 1
  RunTest Test_1_7
  RunTest Test_1_8 2:1
  RunTest Test_1_9 1
  RunTest Test_1_10 3:2:1
  RunTest Test_1_11 3:2:1
  RunTest Test_2_1 2:1:3
  RunTest Test_2_2 1:3
  RunTest Test_2_3
  RunTest Test_2_4 4:2:1:5:3
  RunTest Test_2_5 3:2:1
  RunTest Test_2_6 2:1
  RunTest Test_2_7 2:1:3
  RunTest Test_2_8 3:1:4
  RunTest Test_2_9 4:1
  RunTest Test_2_10 3
  RunTest Test_3_1 1:2
  RunTest Test_3_2 1:2
  RunTest Test_3_3 1:2
  RunTest Test_4_1 1:2
  RunTest Test_4_2 1:2:3
  RunTest Test_4_3 1:2
  RunTest Test_4_4 1:2:3
}

function RunAllTests1()
{
  RunTest Test_1_10 3:2:1
  RunTest Test_1_11 3:2:1
}

function Test_1_1()
{
  function Test1()
  {
    PushTrap test "TestEcho 1; TestAssertHasNoExtraVariables RETURN" RETURN
    function Test2()
    {
      PushTrap test "TestEcho 2" RETURN
    }
    Test2
    TestAssertHasExtraVariables RETURN
  }
  Test1
  TestAssertHasNoExtraVariables
}

function Test_1_2()
{
  function Test1()
  {
    PushTrap test "TestEcho 1; TestAssertHasNoExtraVariables RETURN" RETURN
    function Test2()
    {
      PushTrap test "TestEcho 2" RETURN
      PopTrap test RETURN
    }
    Test2
    TestAssertHasExtraVariables RETURN
  }
  Test1
  TestAssertHasNoExtraVariables
}

function Test_1_3()
{
  function Test1()
  {
    PushTrap test "TestEcho 1; TestAssertHasNoExtraVariables RETURN" RETURN
    function Test2()
    {
      PushTrap test "TestEcho 2" RETURN
      PopTrap test RETURN
    }
    Test2
    PopTrap test RETURN
    TestAssertHasNoExtraVariables
  }
  Test1
}

function Test_1_4()
{
  function Test1()
  {
    PushTrap test "TestEcho 1; TestAssertHasNoExtraVariables RETURN" RETURN
    function Test2()
    {
      PushTrap test "TestEcho 2" RETURN
      function Test3()
      {
        PushTrap test "TestEcho 3" RETURN
      }
      Test3
      TestAssertHasExtraVariables RETURN
    }
    Test2
    TestAssertHasExtraVariables RETURN
  }
  Test1
  TestAssertHasNoExtraVariables
}

function Test_1_5()
{
  function Test1()
  {
    PushTrap test "TestEcho 1; TestAssertHasNoExtraVariables RETURN" RETURN
    function Test2()
    {
      PushTrap test "TestEcho 2" RETURN
      function Test3()
      {
        PushTrap test "TestEcho 3" RETURN
        PopTrap test RETURN
      }
      Test3
      TestAssertHasExtraVariables RETURN
    }
    Test2
    TestAssertHasExtraVariables RETURN
  }
  Test1
  TestAssertHasNoExtraVariables
}

function Test_1_6()
{
  function Test1()
  {
    PushTrap test "TestEcho 1; TestAssertHasNoExtraVariables RETURN" RETURN
    function Test2()
    {
      PushTrap test "TestEcho 2" RETURN
      function Test3()
      {
        PushTrap test "TestEcho 3" RETURN
        PopTrap test RETURN
      }
      Test3
      PopTrap test RETURN
      TestAssertHasExtraVariables RETURN
    }
    Test2
    TestAssertHasExtraVariables RETURN
  }
  Test1
  TestAssertHasNoExtraVariables
}

function Test_1_7()
{
  function Test1()
  {
    PushTrap test "TestEcho 1; TestAssertHasNoExtraVariables RETURN" RETURN
    function Test2()
    {
      PushTrap test "TestEcho 2" RETURN
      function Test3()
      {
        PushTrap test "TestEcho 3" RETURN
        PopTrap test RETURN
      }
      Test3
      PopTrap test RETURN
      TestAssertHasExtraVariables RETURN
    }
    Test2
    PopTrap test RETURN
    TestAssertHasNoExtraVariables
  }
  Test1
}

function Test_1_8()
{
  function Test1()
  {
    PushTrap test "TestEcho 1; TestAssertHasNoExtraVariables RETURN" RETURN
    function Test2()
    {
      PushTrap test "TestEcho 2" RETURN
      function Test3()
      {
        PushTrap test "TestEcho 3" RETURN
        trap '' RETURN # override
      }
      Test3
      TestAssertHasExtraVariables RETURN
    }
    Test2
    TestAssertHasExtraVariables RETURN
  }
  Test1
  TestAssertHasNoExtraVariables
}

function Test_1_9()
{
  function Test1()
  {
    PushTrap test "TestEcho 1; TestAssertHasNoExtraVariables RETURN" RETURN
    function Test2()
    {
      PushTrap test "TestEcho 2" RETURN
      function Test3()
      {
        PushTrap test "TestEcho 3" RETURN
        trap '' RETURN # override
      }
      Test3
      trap '' RETURN # override
      TestAssertHasExtraVariables RETURN
    }
    Test2
    TestAssertHasExtraVariables RETURN
  }
  Test1
  TestAssertHasNoExtraVariables
}

function Test_1_10()
{
  function Test1()
  {
    PushTrap test "TestEcho 1; TestAssertHasNoExtraVariables RETURN" RETURN
    function Test2()
    {
      PushTrap test "TestEcho 2" RETURN
      function Test3()
      {
        PushTrap test "TestEcho 3" RETURN
        trap '' RETURN # override
      }
      Test3
      trap '' RETURN # override
      TestAssertHasExtraVariables RETURN
    }
    Test2
    trap '' RETURN # override
    TestAssertHasExtraVariables RETURN
  }
  Test1
  PopTrap test RETURN # initiates cleanup and late user handlers call
  TestAssertHasNoExtraVariables
}

function Test_1_11()
{
  function Test1()
  {
    PushTrap test "TestEcho 1; TestAssertHasNoExtraVariables RETURN" RETURN
    function Test2()
    {
      PushTrap test "TestEcho 2" RETURN
      function Test3()
      {
        PushTrap test "TestEcho 3" RETURN
        trap '' RETURN # override
      }
      Test3
      trap '' RETURN # override
      TestAssertHasExtraVariables RETURN
    }
    Test2
    trap '' RETURN # override
    TestAssertHasExtraVariables RETURN
  }
  Test1
  PushTrap test "" RETURN # initiates cleanup and late user handlers call
  TestAssertHasNoExtraVariables
}

function Test_2_1()
{
  function Test1()
  {
    PushTrap test "TestEcho 1; TestAssertHasNoExtraVariables RETURN" RETURN
    function Test2()
    {
      PushTrap test "TestEcho 2" RETURN
      PushTrap test "TestEcho 3; TestAssertHasNoExtraVariables EXIT" EXIT
    }
    Test2
    TestAssertHasExtraVariables RETURN EXIT
  }
  Test1
  TestAssertHasExtraVariables EXIT
}

function Test_2_2()
{
  function Test1()
  {
    PushTrap test "TestEcho 1; TestAssertHasNoExtraVariables RETURN" RETURN
    function Test2()
    {
      PushTrap test "TestEcho 2" RETURN
      PopTrap test RETURN
      PushTrap test "TestEcho 3; TestAssertHasNoExtraVariables EXIT" EXIT
    }
    Test2
    TestAssertHasExtraVariables RETURN EXIT
  }
  Test1
  TestAssertHasExtraVariables EXIT
}

function Test_2_3()
{
  function Test1()
  {
    PushTrap test "TestEcho 1" RETURN
    function Test2()
    {
      PushTrap test "TestEcho 2" RETURN
      PopTrap test RETURN
      PushTrap test "TestEcho 3" EXIT
      PopTrap test EXIT
    }
    Test2
    PopTrap test RETURN
    TestAssertHasNoExtraVariables
  }
  Test1
}

function Test_2_4()
{
  function Test1()
  {
    PushTrap test "TestEcho 1; TestAssertHasNoExtraVariables RETURN" RETURN
    function Test2()
    {
      PushTrap test "TestEcho 2" RETURN
      PushTrap test "TestEcho 3; TestAssertHasNoExtraVariables EXIT" EXIT
      function Test3()
      {
        PushTrap test "TestEcho 4" RETURN
        PushTrap test "TestEcho 5" EXIT
      }
      Test3
      TestAssertHasExtraVariables RETURN EXIT
    }
    Test2
    TestAssertHasExtraVariables RETURN EXIT
  }
  Test1
  TestAssertHasExtraVariables EXIT
}

function Test_2_5()
{
  function Test1()
  {
    PushTrap test "TestEcho 1; TestAssertHasNoExtraVariables RETURN" RETURN
    function Test2()
    {
      PushTrap test "TestEcho 2" RETURN
      function Test3()
      {
        PushTrap test "TestEcho 3" RETURN
        PushTrap test "TestEcho 4" EXIT
        PopTrap test EXIT
      }
      Test3
      TestAssertHasExtraVariables RETURN
    }
    Test2
    TestAssertHasExtraVariables RETURN
  }
  Test1
  TestAssertHasNoExtraVariables
}

function Test_2_6()
{
  function Test1()
  {
    PushTrap test "TestEcho 1" RETURN
    function Test2()
    {
      PushTrap test "TestEcho 2" RETURN
      function Test3()
      {
        PushTrap test "TestEcho 3" RETURN
        PopTrap test RETURN RETURN RETURN
      }
      Test3
      TestAssertHasExtraVariables RETURN
    }
    Test2
    TestAssertHasExtraVariables RETURN
  }
  Test1
  TestAssertHasNoExtraVariables
}

function Test_2_7()
{
  function Test1()
  {
    PushTrap test "TestEcho 1" RETURN
    function Test2()
    {
      PushTrap test "TestEcho 2" RETURN
      function Test3()
      {
        PushTrap test "TestEcho 3; TestAssertHasNoExtraVariables EXIT" EXIT
        PopTrap test RETURN RETURN
      }
      Test3
      TestAssertHasExtraVariables RETURN EXIT
    }
    Test2
    TestAssertHasExtraVariables RETURN EXIT
  }
  Test1
  TestAssertHasExtraVariables EXIT
}

function Test_2_8()
{
  function Test1()
  {
    PushTrap test "TestEcho 1; TestAssertHasNoExtraVariables RETURN" RETURN
    function Test2()
    {
      PushTrap test "TestEcho 2" RETURN
      function Test3()
      {
        PushTrap test "TestEcho 3" RETURN
        PushTrap test "TestEcho 4; TestAssertHasNoExtraVariables EXIT" EXIT
      }
      Test3
      trap '' RETURN # override
      TestAssertHasExtraVariables RETURN EXIT
    }
    Test2
    TestAssertHasExtraVariables RETURN EXIT
  }
  Test1
  TestAssertHasExtraVariables EXIT
}

function Test_2_9()
{
  function Test1()
  {
    PushTrap test "TestEcho 1; TestAssertHasNoExtraVariables RETURN" RETURN
    function Test2()
    {
      PushTrap test "TestEcho 2" RETURN
      function Test3()
      {
        PushTrap test "TestEcho 3" EXIT
        PushTrap test "TestEcho 4" RETURN
      }
      Test3
      trap '' EXIT RETURN # override
      TestAssertHasExtraVariables RETURN EXIT
    }
    Test2
    TestAssertHasExtraVariables RETURN EXIT
  }
  Test1
  TestAssertHasExtraVariables EXIT # global variables leak
}

function Test_2_10()
{
  function Test1()
  {
    PushTrap test "TestEcho 1" EXIT
    function Test2()
    {
      PushTrap test "TestEcho 2" RETURN
      function Test3()
      {
        PushTrap test "TestEcho 3" RETURN
      }
      Test3
      trap '' RETURN EXIT # override
      TestAssertHasExtraVariables RETURN EXIT
    }
    Test2
    trap '' RETURN # override
    TestAssertHasExtraVariables RETURN EXIT
  }
  Test1
  TestAssertHasExtraVariables RETURN EXIT # global variables leak
}

function Test_3_1()
{
  function Test2()
  {
    PushTrap test "TestEcho 255; TestAssertHasNoExtraVariables RETURN" RETURN
    TestEcho $?
  }
  function Test1()
  {
    PushTrap test "TestEcho 1; Test2; TestAssertHasNoExtraVariables RETURN" RETURN
  }
  Test1
  TestAssertHasNoExtraVariables
}

function Test_3_2()
{
  function Test2()
  {
    PushTrap test "TestEcho 255; TestAssertHasNoExtraVariables" EXIT
    TestEcho $?
  }
  function Test1()
  {
    PushTrap test "TestEcho 1; Test2; TestAssertHasNoExtraVariables RETURN" RETURN
  }
  Test1
  TestAssertHasNoExtraVariables
}

function Test_3_3()
{
  function Test2()
  {
    PushTrap test "TestEcho 255; TestAssertHasNoExtraVariables RETURN" RETURN
    TestEcho $?
  }
  function Test1()
  {
    PushTrap test "TestEcho 1; Test2; TestAssertHasNoExtraVariables" EXIT
  }
  Test1
  TestAssertHasExtraVariables EXIT
}

function Test_4_1()
{
  function Test1()
  {
    PushTrap test "TestEcho 1; TestAssertHasNoExtraVariables" RETURN
  }
  function Test2()
  {
    PushTrap test "TestEcho 2; TestAssertHasNoExtraVariables" RETURN
  }
  Test1
  Test2
}

function Test_4_2()
{
  function Test1()
  {
    PushTrap test "TestEcho 1; TestAssertHasNoExtraVariables" RETURN
  }
  function Test2()
  {
    PushTrap test "TestEcho 2; TestAssertHasNoExtraVariables" RETURN
  }
  function Test3()
  {
    PushTrap test "TestEcho 3; TestAssertHasNoExtraVariables" RETURN
  }
  Test1
  Test2
  Test3
}

function Test_4_3()
{
  function Test2()
  {
    PushTrap test "TestEcho 1; TestAssertHasNoExtraVariables" RETURN
  }
  function Test1()
  {
    Test2
    PushTrap test "TestEcho 2; TestAssertHasNoExtraVariables" RETURN
  }
  function Test()
  {
    Test1
  }
  Test
}

function Test_4_4()
{
  function Test3()
  {
    PushTrap test "TestEcho 1; TestAssertHasNoExtraVariables" RETURN
  }
  function Test2()
  {
    Test3
    PushTrap test "TestEcho 2; TestAssertHasNoExtraVariables" RETURN
  }
  function Test1()
  {
    Test2
    PushTrap test "TestEcho 3; TestAssertHasNoExtraVariables" RETURN
  }
  function Test()
  {
    Test1
  }
  Test
}

RunAllTests

fi
