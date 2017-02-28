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
source "${TOOLS_PATH:-.}/funclib.sh"

TestModuleInit

TestNumTimes=10

# generate strings and HashStringGnuCrc32 hashes for test on collisions $TestNumTimes times
echo "Tests: hashlib/$TestScriptFileName"
echo "Desc: generate $STR_NUM strings and HashStringGnuCrc32 hashes for test on collisions $TestNumTimes times"
echo "String lengths range: $STR_LENGTH_MIN - $STR_LENGTH_MAX"
echo "String characters range: $CH_CODE_MIN - $CH_CODE_MAX"
echo

function Test()
{
  echo "Generating strings..."
  GenerateStrings || exit 1
  echo
  echo "Generating hashes..."
  GenerateHashes HashStringGnuCrc32 || exit 2
  echo
  echo "Checking on hash collisions..."
  CheckHashCollisions || exit 3
  echo
}

function RunAllTests()
{
  local i
  for (( i=1; i <= TestNumTimes; i++ )); do
    MakeFunctionCopy -f Test Test_$i
    RunTest Test_$i
  done
}

RunAllTests

fi
