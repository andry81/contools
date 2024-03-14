#!/bin/bash

# Script can be ONLY included by "source" command.
[[ -n "$BASH" && (-z "$BASH_LINENO" || BASH_LINENO[0] -gt 0) ]] || return 0 || exit 0 # exit to avoid continue if the return can not be called

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
tkl_include_or_abort "$CONTOOLS_ROOT/bash/testlib.sh"

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

  TEST_SOURCES=("$CONTOOLS_ROOT/bash/traplib.sh")
}

function TestUserInit() { :; }
function TestUserModuleExit() { :; }
function TestUserExit() { :; }
