#!/bin/bash

if [[ -n "$BASH" ]]; then

source '/bin/bash_entry' || exit $?
tkl_include '__init__.sh' || tkl_abort_include
tkl_include 'testlib.sh' || tkl_abort_include

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

# create and read hash map
echo "Tests: hashlib/$TestScriptFileName"
echo "Desc: create and read hash map"
echo

function RunAllTests()
{
  RunTest Test_1
}

function Test_1()
{
  echo "Test #1"
  echo "Desc: 10000 iterations of SetHashMapItem function on sequenced key collection"
  time GenerateHashMap Test || exit 1
  echo

  echo "Test #2"
  echo "Desc: 10000 iterations of GetHashMapItem function on sequenced key collection"
  time ReadHashMap Test || exit 2
  echo
}

RunAllTests

fi
