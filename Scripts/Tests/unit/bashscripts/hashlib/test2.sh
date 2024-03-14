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
tkl_include_or_abort "$CONTOOLS_ROOT/bash/funclib.sh"

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
