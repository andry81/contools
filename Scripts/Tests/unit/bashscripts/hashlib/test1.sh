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
