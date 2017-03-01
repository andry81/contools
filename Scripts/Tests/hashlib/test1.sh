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

# generate once strings for test on hashing speed and hash collisions
echo "Tests: hashlib/$TestScriptFileName"
echo "Desc: generate once $STR_NUM strings for test on hashing speed and hash collisions"
echo "String lengths range: $STR_LENGTH_MIN - $STR_LENGTH_MAX"
echo "String characters range: $CH_CODE_MIN - $CH_CODE_MAX"
echo

function RunAllTests()
{
  RunTest Test_1
}

function Test_1()
{
  echo "Generating strings..."
  GenerateStrings || exit 1
  echo

  echo "Test #1"
  echo "Desc: $STR_NUM iterations of HashStringGnuCrc32 function with random strings"
  time GenerateHashes || exit 2
  echo

  echo "Test #2"
  echo "Desc: testing on hash collisions of previously generated string set"
  CheckHashCollisions || exit 3
  echo
}

RunAllTests

fi
