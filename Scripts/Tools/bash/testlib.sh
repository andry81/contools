#!/bin/bash

# Script library to support testing.

# Script can be ONLY included by "source" command.
[[ -n "$BASH" && (-z "$BASH_LINENO" || BASH_LINENO[0] -gt 0) && (-z "$SOURCE_CONTOOLS_TESTLIB_SH" || SOURCE_CONTOOLS_TESTLIB_SH -eq 0) ]] || return 0 || exit 0 # exit to avoid continue if the return can not be called

SOURCE_CONTOOLS_TESTLIB_SH=1 # including guard

if [[ -z "$SOURCE_TACKLELIB_BASH_TACKLELIB_SH" || SOURCE_TACKLELIB_BASH_TACKLELIB_SH -eq 0 ]]; then
  # builtin search
  for BASH_SOURCE_DIR in "/usr/local/bin" "/usr/bin" "/bin"; do
    [[ -f "$BASH_SOURCE_DIR/bash_tacklelib" ]] && {
      source "$BASH_SOURCE_DIR/bash_tacklelib" || exit $?
      break
    }
  done
fi

tkl_include_or_abort '__init__.sh'
tkl_include_or_abort "$CONTOOLS_PROJECT_EXTERNALS_ROOT/tacklelib/bash/tacklelib/baselib.sh"
tkl_include_or_abort "$CONTOOLS_ROOT/bash/filelib.sh"
tkl_include_or_abort "$CONTOOLS_ROOT/bash/funclib.sh"
tkl_include_or_abort "$CONTOOLS_ROOT/bash/stringlib.sh"

function TestReturn()
{
  return ${1:-0}
}

function TestEcho()
{
  local code=$?
  echo "$@"
  return $code
}

function TestModuleInit()
{
  trap '' INT # handles only via TestInit

  ConvertBackendPathToNative "$BASH"
  echo "Environment:"
  echo "  BASH_VERSION=\"$BASH_VERSION\""
  echo "  BASH=\"$BASH\" -> \"$RETURN_VALUE\""
  echo "  PATH=\"$PATH\""
  echo

  TestScriptOutputsDirPath="$TestScriptDirPath/_out"

  IFS=$'\r\n' # by default

  # Cleanup and reset locale to avoid potential problems with sort, grep and string comparison.
  unset LANG
  export LC_COLLATE=C
  export LC_ALL=C

  LAST_WAIT_PID=0
  CONTINUE_ON_TEST_FAIL=1
  CONTINUE_ON_SIGINT=0
  NUM_TESTS_OVERALL=0
  NUM_TESTS_PASSED=0
  NUM_TESTS_FAILED=0
  TEST_SOURCES=()
  TEST_FUNCTIONS=()

  # Exports visible in the test procedure runs as explicit bash process.

  # snable extra variables check and test asserts
  export TEST_ENABLE_EXTRA_VARIABLES_CHECK=0

  trap TestModuleExit EXIT

  tkl_safe_func_call TestUserModuleInit

  local i
  local Str
  local len=${#TEST_SOURCES[@]}
  for (( i=0; i < len; i++ )); do
    Str="${TEST_SOURCES[i]}"
    TEST_SOURCES[i]="'${Str//\\//}'"
  done

  return 0
}

function TestInit()
{
  trap '' INT # wait for initialization

  IsTestOk=0
  TestLastError=127
  (( ! ${#TestSuccessCode} )) && TestSuccessCode=0
  TestScriptLastError=127
  (( ! ${#TestScriptSuccessCode} )) && TestScriptSuccessCode=0
  TestFlags=0

  tkl_get_shell_pid
  printf -v ProcId %x ${RETURN_VALUE:-65535} # default value if fail
  tkl_zero_padding 4 "$ProcId"
  ProcId="$RETURN_VALUE"

  printf -v RandomId %x%x $RANDOM $RANDOM
  tkl_zero_padding 8 "$RandomId"
  RandomId="$RETURN_VALUE"

  TestSessionId="${ProcId}_${RandomId}"

  TestStdoutFilePath="/tmp/$TestScriptParentDirName/${TestScriptBaseFileName}_${TestScriptFunc}_${TestSessionId}_stdout.txt"
  TestStdoutDefFilePath="/tmp/$TestScriptParentDirName/${TestScriptBaseFileName}_${TestScriptFunc}_${TestSessionId}_stdout_def.txt"
  TestStdoutsDiffFilePath="/tmp/$TestScriptParentDirName/${TestScriptBaseFileName}_${TestScriptFunc}_${TestSessionId}_stdouts_diff.txt"
  TestInitialEnvFilePath="/tmp/$TestScriptParentDirName/${TestScriptBaseFileName}_${TestScriptFunc}_${TestSessionId}_env_0.txt"
  TestExitEnvFilePath="/tmp/$TestScriptParentDirName/${TestScriptBaseFileName}_${TestScriptFunc}_${TestSessionId}_env_1.txt"
  if (( TEST_ENABLE_EXTRA_VARIABLES_CHECK )); then
    TestHasVarsEnvFilePath="/tmp/$TestScriptParentDirName/${TestScriptBaseFileName}_${TestScriptFunc}_${TestSessionId}_1_has_vars.txt"
    TestHasNoVarsEnvFilePath="/tmp/$TestScriptParentDirName/${TestScriptBaseFileName}_${TestScriptFunc}_${TestSessionId}_2_has_no_vars.txt"
    TestHasVarEnvDiffFilePath="/tmp/$TestScriptParentDirName/${TestScriptBaseFileName}_${TestScriptFunc}_${TestSessionId}_1_has_vars_diff.txt"
    TestHasNoVarEnvDiffFilePath="/tmp/$TestScriptParentDirName/${TestScriptBaseFileName}_${TestScriptFunc}_${TestSessionId}_2_has_no_vars_diff.txt"
  fi

  trap TestExit EXIT
  trap "TestIntHandler 254" INT

  mkdir -p "$TestScriptOutputsDirPath"
  mkdir -p "/tmp/$TestScriptParentDirName" || return 1

  exec 3> "$TestStdoutFilePath"
  if (( TEST_ENABLE_EXTRA_VARIABLES_CHECK )); then
    exec 5> "$TestHasVarsEnvFilePath"
    exec 6> "$TestHasNoVarsEnvFilePath"
  fi

  return 0
}

function TestModuleExit()
{
  trap '' INT # no interruption while handling trap

  tkl_safe_func_call TestUserModuleExit

  echo "-------------------------------------------------------------------------------"
  echo "  Tests passed:  $NUM_TESTS_PASSED"
  echo "  Tests failed:  $NUM_TESTS_FAILED"
  echo "  Tests overall: $NUM_TESTS_OVERALL"
  echo "-------------------------------------------------------------------------------"

  printf '\7' # beep
}

function TestExit()
{
  trap '' INT # no interruption while handling trap

  if (( ! IsTestOk )); then
    echo "FAILURE: $TestLastError ($TestScriptLastError)"
    echo
  else
    echo "PASSED: $TestLastError ($TestScriptLastError)"
    echo
  fi 

  # close all pipes
  exec 3>&-
  if (( TEST_ENABLE_EXTRA_VARIABLES_CHECK )); then
    exec 5>&-
    exec 6>&-
  fi

  # remove output files only if test is passed!
  local IsCleanupEcho=0
  if (( ! IsTestOk && TestFlags & 0x01 )); then
    mv -v "$TestStdoutsDiffFilePath" "$TestScriptOutputsDirPath"
    IsCleanupEcho=1
  else
    rm -f "$TestStdoutsDiffFilePath"
  fi
  rm -f "$TestStdoutFilePath"
  rm -f "$TestStdoutDefFilePath"
  rm -f "$TestInitialEnvFilePath"
  rm -f "$TestExitEnvFilePath"

  if (( TEST_ENABLE_EXTRA_VARIABLES_CHECK )); then
    if (( ! IsTestOk && TestFlags & 0x02 )); then
      mv -v "$TestHasVarEnvDiffFilePath" "$TestScriptOutputsDirPath"
      IsCleanupEcho=1
    else
      rm -f "$TestHasVarEnvDiffFilePath"
    fi
    if (( ! IsTestOk && TestFlags & 0x04 )); then
      mv -v "$TestHasNoVarEnvDiffFilePath" "$TestScriptOutputsDirPath"
      IsCleanupEcho=1
    else
      rm -f "$TestHasNoVarEnvDiffFilePath"
    fi
    rm -f "$TestHasVarsEnvFilePath"
    rm -f "$TestHasNoVarsEnvFilePath"
  fi

  rmdir "/tmp/$TestScriptParentDirName" || IsCleanupEcho=1

  (( IsCleanupEcho )) && echo
}

function TestExitWithCode()
{
  TestLastError=$1
  if (( TestLastError == 254 && CONTINUE_ON_SIGINT || TestLastError == TestSuccessCode )); then
    IsTestOk=1
  else
    IsTestOk=0
  fi
  let "TestFlags|=${2:-0}"
  exit $TestLastError
}

function TestIntHandler()
{
  local TestLastError=$1
  local IsTestOk
  if (( TestLastError == 254 && CONTINUE_ON_SIGINT )); then
    IsTestOk=1
  else
    IsTestOk=0
  fi
  if (( ! IsTestOk )); then
    exit $TestLastError
  fi
}

function TestExitSuccess()
{
  TestSetLastError $TestSuccessCode
  exit $TestLastError
}

function TestSetLastError()
{
  if (( TestLastError == 127 )); then
    TestLastError=$1
  fi
  if (( TestLastError == TestSuccessCode )); then
    IsTestOk=1
  else
    IsTestOk=0
  fi
  let "TestFlags|=${2:-0}"
}

function TestExitIfError()
{
  local LastError=$?
  if (( LastError )); then
    if (( LastError == 254 && CONTINUE_ON_SIGINT )); then
      (( NUM_TESTS_PASSED++ ))
    elif (( LastError != 254 )); then
      (( NUM_TESTS_FAILED++ ))
    fi
  else
    (( NUM_TESTS_PASSED++ ))
  fi
  (( NUM_TESTS_OVERALL++ ))
  if (( LastError == 254 && ! CONTINUE_ON_SIGINT || LastError && LastError != 254 && ! CONTINUE_ON_TEST_FAIL )); then
    (( LastError )) && exit $LastError
  fi
  return 0
}

function RunTestAndWait()
{
  local FuncBeforeWait="$1"
  shift

  RunTest "$@" &
  LAST_WAIT_PID=$!
  tkl_safe_func_call "$FuncBeforeWait"
  wait $LAST_WAIT_PID
}

function RunTest()
{
  local TestScriptFunc="$1"
  local TestStdoutDeclare="$2"
  shift 2
  local TestFuncArgs=("$@")

  local IFS=$'\n'

  # replace special character to line returns
  TestStdoutDeclare="${TestStdoutDeclare//:/$'\n'}"

  # in explicit subshell process with environment inheritance
  (
    TestInit || TestExitWithCode 1

    echo "$TestScriptFunc: TestSessionId=$TestSessionId"

    GetFunctionBody "$TestScriptFunc"
    (( $? )) && TestExitWithCode 2
    local TestFuncBody="$RETURN_VALUE"

    GetFunctionDeclarations TestUserInit TestUserExit "${TEST_FUNCTIONS[@]}"
    local TestFuncDecls="${RETURN_VALUES[*]}"
    
    MakeCommandLine '' 0 "${TestFuncArgs[@]}"
    local TestFuncArgsCmdLine="$RETURN_VALUE"

    local IFS=$' \t\r\n' # workaround for array expansion for TEST_SOURCES
    local TestSourcesCmdLine="${TEST_SOURCES[@]}"

    # Test script to run single test w/o environment inheritance from parent shell process.
    # First line in environment output is internal parameters list from
    # functions TestAssertHasExtraVariables and TestAssertHasNoExtraVariables.
    local TestScript="
trap 'exit 254' INT
trap '' PIPE

source \"\$CONTOOLS_PROJECT_EXTERNALS_ROOT/tacklelib/bash/tacklelib/baselib.sh\"
for src in $TestSourcesCmdLine; do
  source \"\$src\"
done
tkl_unset src

TEST_SCRIPT_ARGS=($TestFuncArgsCmdLine)
TestSessionId='$TestSessionId'
TestScriptFunc='$TestScriptFunc'
TestScriptFilePath='$TestScriptFilePath'
TestScriptDirPath='$TestScriptDirPath'
TestScriptParentDirName='$TestScriptParentDirName'
TestScriptBaseFileName='$TestScriptBaseFileName'
TestScriptOutputsDirPath='$TestScriptOutputsDirPath'

function TestEcho()
{
  local code=\$?
  echo \"\$@\" >&3
  return \$code
}

if (( TEST_ENABLE_EXTRA_VARIABLES_CHECK )); then
  function TestAssertHasExtraVariables()
  {
    echo \"=AssertHasExtraVars \$@\" >&5
    set -o posix;
    set >&5
    return 0
  }
  function TestAssertHasNoExtraVariables()
  {
    echo \"=AssertHasNoExtraVars \$@\" >&6
    set -o posix;
    set >&6
    return 0
  }
fi

$TestFuncDecls

tkl_safe_func_call TestUserInit

function TestScriptExit()
{
  set -o posix
  set > \"$TestExitEnvFilePath\"

  tkl_safe_func_call TestUserExit
}

trap 'TestScriptExit' EXIT

set -o posix
set > \"$TestInitialEnvFilePath\"

$TestFuncBody
"

    /bin/bash -c "$TestScript"
    TestScriptLastError=$?
    (( TestScriptLastError == 254 )) && TestExitWithCode 254
    (( TestScriptLastError == $TestScriptSuccessCode )) || TestExitWithCode 3
    local Output="${TestStdoutDeclare%$'\n'}" # remove last line return as optional
    echo -n -e "$Output${Output:+$'\n'}" >"$TestStdoutDefFilePath"
    local StdoutsDiff="$( \
      diff -c "$TestStdoutFilePath" "$TestStdoutDefFilePath" | \
      sed -e 's|--- /tmp/traplib/|--- |' -e 's|\*\*\* /tmp/traplib/|\*\*\* |')"
    if (( ${#StdoutsDiff} )); then
      echo -n "$StdoutsDiff" >"$TestStdoutsDiffFilePath"
      TestSetLastError 4 0x01
    fi

    exec 3>&-
    if (( TEST_ENABLE_EXTRA_VARIABLES_CHECK )); then
      exec 5>&-
      exec 6>&-

      # checking output from the test, slow but necessary
      local CleanEnvironment
      local TestEnvironment
      InitialEnv="$(cat "$TestInitialEnvFilePath")"
      if (( ${#InitialEnv} )); then
        HasVarsEnv="$(cat "$TestHasVarsEnvFilePath")"
        if (( ${#HasVarsEnv} )); then
          CompareEnvs "$HasVarsEnv" "$InitialEnv" "%%=*" "%%=*"
          if (( ! $? && ${#RETURN_VALUE} )); then
              echo "$RETURN_VALUE" >"$TestHasVarEnvDiffFilePath"
              TestSetLastError 5 0x02
          fi
        fi
        HasNoVarsEnv="$(cat "$TestHasNoVarsEnvFilePath")"
        if (( ${#HasNoVarsEnv} )); then
          CompareEnvs "$HasNoVarsEnv" "$InitialEnv" "%%=*" "%%=*"
          if (( ! $? && ${#RETURN_VALUE} )); then
              echo "$RETURN_VALUE" >"$TestHasNoVarEnvDiffFilePath"
              TestSetLastError 6 0x04
          fi
        fi
      else
        TestSetLastError 32
      fi
    fi

    TestExitSuccess
  )
  TestExitIfError
}

function CompareEnvs()
{
  local List1="$1"
  local List2="$2"
  local ListLineFilter1="$3"
  local ListLineFilter2="$4"
  local IgnoreReturnTrapVars="${5:-0}"
  local IgnoreExitTrapVars="${6:-1}"

  # drop return value
  RETURN_VALUES=""

  function CompareEnvs_LocalReturnHandler()
  {
    if (( ${#oldShopt} )); then
      eval $oldShopt
    fi
  }

  local oldShopt
  trap "CompareEnvs_LocalReturnHandler; $(trap -p RETURN)" RETURN

  # enable case match for a variable names
  oldShopt="$(shopt -p nocasematch)"
  if [[ "$oldShopt" == "shopt -s nocasematch" ]]; then
    shopt -u nocasematch
  else
    oldShopt=''
  fi

  # reload strings into arrays
  local IFS=$'\n' # to join by line return
  local ListArr1=(${List1[*]})
  local ListArr2=(${List2[*]})
  local ListArrSize1=${#ListArr1[@]};
  local ListArrSize2=${#ListArr2[@]};

  local LinesDiff
  LinesDiff=()

  local AssertTypeStr
  local TrapType
  local TrapTypesArr
  TrapTypesArr=('*') # has (has no) any (all) of trap types declared by pattern
  local TrapTypesArrSize=${#TrapTypesArr[@]}
  local TrapStackHasVarsArrName
  local TrapStackHasVarsArrSize
  local TrapStackHasVarName
  local TrapStackHasNoVarsArrName
  local TrapStackHasNoVarsArrSize
  local TrapStackHasNoVarName
  local CompCmdLine
  local CompCmdArr
  local NumCompBlocks=0
  local NumDiffLine=0
  local HasCurBlockDiffs=0
  local HasLastBlockDiffs=0
  local IsDiffLineFound

  # uses by AssertHasExtraVars
  local FoundTrapTypeNums

  local i
  local j
  local k
  local NumDiffsFound=0
  local Line1
  local FilteredLine1
  local Line2
  local FilteredLine2
  local LastFoundIndex=-1
  local DoIgnoreLine
  for (( i=0; i<ListArrSize1; i++ )); do
    IsDiffLineFound=0
    DoIgnore=0
    ReadMultilineValue ListArr1 $i
    Line1="${RETURN_VALUES[0]}"
    i=${RETURN_VALUES[1]}
    if (( ! ${#Line1} )); then
      continue
    # ignore empty variables but read special technical lines to (re)initialize comparison
    elif [[ -z "${Line1%%=*}" ]]; then
      # previous technical line process
      if (( NumCompBlocks )); then
        if [[ "$AssertTypeStr" == "AssertHasExtraVars" ]]; then
          # report by special lines what trap type variables were not found at all
          for (( k=0; k < TrapTypesArrSize; k++ )); do
            if (( ! FoundTrapNums[k] )); then
              LinesDiff[NumDiffLine]="> Not found: ${TrapTypesArr[k]}"
              (( NumDiffLine++ ))
              (( NumDiffsFound++ ))
            fi
          done
        fi
      fi
      # technical line: reinitialize comparison
      eval CompCmdLine="(${Line1#=})"
      if (( ${#CompCmdLine} > 1 )); then
        IFS=$' \t\r\n' # workaround for the bug in the "[@]:i" expression under the bash version lower than 4.1
        eval TrapTypesArr="(${CompCmdLine[@]:1})"
        IFS=$'\n' # to join by line return
      else
        TrapTypesArr=() # has (has no) any (all) of trap types declared by pattern
      fi
      TrapTypesArrSize=${#TrapTypesArr[@]}
      AssertTypeStr="${CompCmdLine[0]}"
      (( ! TrapTypesArrSize )) && TrapTypesArr[0]='*'
      TrapTypesArrSize=${#TrapTypesArr[@]}
      # do zeros found trap type numbers
      FoundTrapTypeNums=()
      for (( j=0; j < TrapTypesArrSize; j++ )); do
        FoundTrapTypeNums[j]=0
      done
      # find from begin
      LastFoundIndex=-1
      HasLastBlockDiffs=$HasCurBlockDiffs
      HasCurBlockDiffs=0
      if (( HasLastBlockDiffs )); then
        LinesDiff[NumDiffLine]=''
        (( NumDiffLine++ ))
      fi
      LinesDiff[NumDiffLine]=">> $AssertTypeStr: ${TrapTypesArr[@]}"
      (( NumDiffLine++ ))
      (( NumCompBlocks++ ))
      continue
    fi
    #echo "$i: $Line1"
    # Msys bash 3.1.x has weak ctrl-c handling, this improves it a bit
    if (( !(i%10) && (BASH_VERSINFO[0] < 3 || BASH_VERSINFO[0] == 3 && BASH_VERSINFO[1] <= 1) )); then
      Wait 1
    fi
    eval FilteredLine1='"${Line1'"$ListLineFilter1"'}"'
    # always ignore base extra variables created by other libraries than traplib
    for (( j=0; j < IgnoreBaseExtraVariablesSize; j++ )); do
      if [[ "${IgnoreBaseExtraVariables[j]}" == "$FilteredLine1" ]]; then
        DoIgnore=1
        break
      fi
    done
    (( DoIgnore )) && continue
    # but always checks presence of special extra variables created by the traplib functions
    if [[ "$AssertTypeStr" == "AssertHasExtraVars" ]]; then
      # test on specific extra variable absence except declared
      for (( j=0; j < TrapTypesArrSize; j++ )); do
        TrapType="${TrapTypesArr[j]}"
        if [[ "$TrapType" == '*' ]]; then
          TrapStackHasVarsArrName=IgnoreTrapStackExtraVars_ALL
          TrapStackHasVarsArrSize=$IgnoreTrapStackExtraVarsSize_ALL
        elif [[ "$TrapType" == 'RETURN' ]]; then
          TrapStackHasVarsArrName=IgnoreTrapStackExtraVars_RETURN
          TrapStackHasVarsArrSize=$IgnoreTrapStackExtraVarsSize_RETURN
        else
          TrapStackHasVarsArrName=IgnoreTrapStackExtraVars_OTHERS
          TrapStackHasVarsArrSize=$IgnoreTrapStackExtraVarsSize_OTHERS
        fi
        for (( k=0; k < TrapStackHasVarsArrSize; k++ )); do
          eval TrapStackHasVarName='"${'"$TrapStackHasVarsArrName"'[k]}"'
          TrapStackHasVarName="${TrapStackHasVarName//\%TRAPTYPE\%/$TrapType}"
          case "$FilteredLine1" in
            $TrapStackHasVarName)
              (( FoundTrapNums[j]++ ))
              DoIgnore=1
              break
            ;;
          esac
        done
        (( DoIgnore )) && break
      done
    elif [[ "$AssertTypeStr" == "AssertHasNoExtraVars" ]]; then
      # test on specific extra variable absence of declared
      for (( j=0; j < TrapTypesArrSize; j++ )); do
        TrapType="${TrapTypesArr[j]}"
        if [[ "$TrapType" == '*' ]]; then
          TrapStackHasNoVarsArrName=IgnoreTrapStackExtraVars_ALL
          TrapStackHasNoVarsArrSize=$IgnoreTrapStackExtraVarsSize_ALL
        elif [[ "$TrapType" == 'RETURN' ]]; then
          TrapStackHasNoVarsArrName=IgnoreTrapStackExtraVars_RETURN
          TrapStackHasNoVarsArrSize=$IgnoreTrapStackExtraVarsSize_RETURN
          TrapStackHasVarsArrName=IgnoreTrapStackExtraVars_OTHERS
          TrapStackHasVarsArrSize=$IgnoreTrapStackExtraVarsSize_OTHERS
        else
          TrapStackHasNoVarsArrName=IgnoreTrapStackExtraVars_OTHERS
          TrapStackHasNoVarsArrSize=$IgnoreTrapStackExtraVarsSize_OTHERS
          TrapStackHasVarsArrName=IgnoreTrapStackExtraVars_ALL
          TrapStackHasVarsArrSize=$IgnoreTrapStackExtraVarsSize_ALL
        fi
        for (( k=0; k < TrapStackHasNoVarsArrSize; k++ )); do
          eval TrapStackHasNoVarName='"${'"$TrapStackHasNoVarsArrName"'[k]}"'
          TrapStackHasNoVarName="${TrapStackHasNoVarName//\%TRAPTYPE\%/$TrapType}"
          case "$FilteredLine1" in
            $TrapStackHasNoVarName)
              IsDiffLineFound=1
              break
            ;;
          esac
        done
        (( IsDiffLineFound )) && break
        if [[ "$TrapType" != '*' ]]; then
          for (( k=0; k < TrapStackHasVarsArrSize; k++ )); do
            eval TrapStackHasVarName='"${'"$TrapStackHasVarsArrName"'[k]}"'
            TrapStackHasVarName="${TrapStackHasVarName//\%TRAPTYPE\%/*}"
            case "$FilteredLine1" in
              $TrapStackHasVarName)
                DoIgnore=1
                break
              ;;
            esac
          done
          (( DoIgnore )) && break
        fi
      done
    fi
    if (( IsDiffLineFound )); then
      LinesDiff[NumDiffLine]="$Line1"
      (( NumDiffLine++ ))
      (( NumDiffsFound++ ))
      HasCurBlockDiffs=1
    fi
    (( IsDiffLineFound || DoIgnore )) && continue
    # lists should be already sorted, start compare after last found
    for (( j=LastFoundIndex+1; j < ListArrSize2; j++ )); do
      ReadMultilineValue ListArr2 $j
      Line2="${RETURN_VALUES[0]}"
      j=${RETURN_VALUES[1]}
      # technical line: ignore it
      if [[ ! ${#Line2} || -z "${Line2%%=*}" ]]; then
        LastFoundIndex=$j
        continue
      fi
      eval FilteredLine2='"${Line2'"$ListLineFilter2"'}"'
      if [[ "$FilteredLine1" == "$FilteredLine2" ]]; then
        LastFoundIndex=$j;
        break
      fi
    done
    if (( j >= ListArrSize2 )); then
      LinesDiff[NumDiffLine]="$Line1"
      (( NumDiffLine++ ))
      (( NumDiffsFound++ ))
      HasCurBlockDiffs=1
      IsDiffLineFound=1
    fi
  done

  if (( NumCompBlocks )); then
    if [[ "$AssertTypeStr" == "AssertHasExtraVars" ]]; then
      # report by special lines what trap type variables were not found at all
      for (( k=0; k < TrapTypesArrSize; k++ )); do
        if (( ! FoundTrapNums[k] )); then
          LinesDiff[NumDiffLine]="> Not found: ${TrapTypesArr[k]}"
          (( NumDiffLine++ ))
          (( NumDiffsFound++ ))
        fi
      done
    fi
  fi

  if (( NumDiffsFound )); then
    RETURN_VALUE="${LinesDiff[*]}"
  else
    RETURN_VALUE=""
  fi

  return 0 # test has no internal errors
}

# searches for the ' character as multiline string quote
function ReadMultilineValue()
{
  local ArrName="$1"
  local Index="$2"

  # drop return values
  RETURN_VALUES=('' -1)

  local IFS=$'\n' # to join by line return
  local NewArr
  NewArr=()
  local NewLineIndex
  local EndMultilineIndex
  local IsMultilineEnd=0
  local IsMultilineQuote=0
  local Line
  local Value
  local ValueSize
  local i
  local IsEscape
  local Char

  EndMultilineIndex=$Index
  NewLineIndex=0
  while (( ! IsMultilineEnd )); do
    eval Line='"${'"$ArrName"'[EndMultilineIndex]}"'
    (( ${#Line} )) || break
    Value="${Line#*=}"
    ValueSize=${#Value}
    IsEscape=0
    for (( i=0; i < ValueSize; i++ )); do
      Char="${Value:i:1}"
      # state machine on flags
      if [[ "$Char" == "'" ]]; then
        if (( ! IsMultilineQuote )); then
          if (( ! IsEscape )); then
            IsMultilineQuote=1
          else
            IsEscape=0
          fi
        else
          IsMultilineQuote=0
        fi
      elif [[ "$Char" == '\' ]]; then #'
        if (( ! IsMultilineQuote )); then
          IsEscape=1
        fi
      fi
    done
    # stop state machine if no begin of '-quoting
    if (( ! IsMultilineQuote )); then
      IsMultilineEnd=1
    fi
    NewArr[NewLineIndex]="$Line"
    (( NewLineIndex++ ))
    (( ! IsMultilineEnd && EndMultilineIndex++ ))
  done

  RETURN_VALUES=("${NewArr[*]}" $EndMultilineIndex)
}
