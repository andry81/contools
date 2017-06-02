#!/bin/bash_entry

# Script can be ONLY included by "source" command.
if [[ -n "$BASH" && (-z "$BASH_LINENO" || ${BASH_LINENO[0]} -gt 0) ]]; then

source "${CONTOOLS_ROOT:-.}/testlib.sh"

function TestUserModuleInit()
{
  TEST_ENABLE_EXTRA_VARIABLES_CHECK=1

  IgnoreBaseExtraVariables=(RETURN_VALUE RETURN_VALUES BASH_SIGNALS BASH_SUBSHELL BASH_SUBSHELL_PIDS BASHPID FUNCNAME RANDOM)
  IgnoreBaseExtraVariablesSize=${#IgnoreBaseExtraVariables[@]}

  IgnoreTrapStackExtraVars_RETURN=(
    'GlobalTrapsPindingCallCtxs_*_RETURN*' 'GlobalTrapsPindingCallCtxsSize_*_RETURN*'
    'GlobalTrapsRegisterParams_*_RETURN_*'
    'GlobalTrapsStack_*_RETURN_*' 'GlobalTrapsStackSize_*_RETURN_*'
  )
  IgnoreTrapStackExtraVarsSize_RETURN=${#IgnoreTrapStackExtraVars_RETURN[@]}
  IgnoreTrapStackExtraVars_OTHERS=(
    'GlobalTrapsRegisterParams_*_%TRAPTYPE%_*'
    'GlobalTrapsStack_*_%TRAPTYPE%_*' 'GlobalTrapsStackSize_*_%TRAPTYPE%_*'
  )
  IgnoreTrapStackExtraVarsSize_OTHERS=${#IgnoreTrapStackExtraVars_OTHERS[@]}
  IgnoreTrapStackExtraVars_ALL=(
    'GlobalTrapsPindingCallCtxs_*_RETURN*' 'GlobalTrapsPindingCallCtxsSize_*_RETURN*'
    'GlobalTrapsRegisterParams_*_%TRAPTYPE%_*'
    'GlobalTrapsStack_*_%TRAPTYPE%_*' 'GlobalTrapsStackSize_*_%TRAPTYPE%_*'
  )
  IgnoreTrapStackExtraVarsSize_ALL=${#IgnoreTrapStackExtraVars_ALL[@]}

  TEST_SOURCES=("${CONTOOLS_ROOT:-.}/traplib.sh")
}

function TestUserInit() { :; }
function TestUserModuleExit() { :; }
function TestUserExit() { :; }

fi
