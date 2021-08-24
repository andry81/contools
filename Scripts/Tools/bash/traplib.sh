#!/bin/bash

# Script library to support trap shell operations.

# Script can be ONLY included by "source" command.
[[ -z "$BASH" || (-n "$BASH_LINENO" && BASH_LINENO[0] -le 0) || (-n "$SOURCE_CONTOOLS_TRAPLIB_SH" && SOURCE_CONTOOLS_TRAPLIB_SH -ne 0) ]] && return

SOURCE_CONTOOLS_TRAPLIB_SH=1 # including guard

source '/bin/bash_tacklelib' || exit $?
tkl_include '__init__.sh' || tkl_abort_include
tkl_include "$CONTOOLS_PROJECT_EXTERNALS_ROOT/tacklelib/bash/tacklelib/baselib.sh" || tkl_abort_include
tkl_include "$CONTOOLS_ROOT/bash/funclib.sh" || tkl_abort_include
tkl_include "$CONTOOLS_ROOT/bash/stringlib.sh" || tkl_abort_include

# TODO OPTIMIZE:
# - Speedup the CleanupPendingTrapCallCtxsImpl by splitting the GlobalTrapsPindingCallCtxs_*
#   array to subarrays with the function context level in subarray's name.
#

function GlobalTrapsStackFuncs_UserTrapHandlerInvoker()
{
  local CallFlags="${1:-0}"
  local TrapNameToken="$2"
  local TrapType="$3"
  local ExternalLastError="${4:-0}"
  local ShellPID="$5"
  local StackCtxId="$6"
  local FuncsStackCallNumNames="$7"
  local FuncsStackCallNames="$8"
  local FuncsStackCallLines="$9"

  (( "${#TrapNameToken}" )) || return 120
  (( "${#TrapType}" )) || return 121
  (( "${#StackCtxId}" )) || return 122

  # make user trap handler uninterruptable while searching for a user trap stack
  trap '' INT

  #echo "FUNCNAME=${FUNCNAME[@]}"
  #echo StackCtxId=$StackCtxId
  #echo "FuncsStackCallNames=$FuncsStackCallNames"

  # pop the stack
  local NumSkipCallCtxs
  local TrapHandlerFunc
  local TrapHandlerRegisterName

  # skip calls
  TrapHandlerRegisterName="GlobalTrapsRegisterParams_${TrapNameToken}_${TrapType}_${StackCtxId}"
  declare -p "$TrapHandlerRegisterName" >/dev/null 2>&1 || return 125

  eval NumSkipCallCtxs='"${'"$TrapHandlerRegisterName"'[2]}"'
  (( ! ${#NumSkipCallCtxs} )) && NumSkipCallCtxs=0
  if (( NumSkipCallCtxs >= 0 )); then
    (( NumSkipCallCtxs-- ))
    eval $TrapHandlerRegisterName[2]='"$NumSkipCallCtxs"'
    (( NumSkipCallCtxs >= 0 )) && return 255
  fi

  eval TrapHandlerFunc='"${'"$TrapHandlerRegisterName"'[1]}"'

  #echo "GlobalTrapsStackFuncs_UserTrapHandlerInvoker $@"

  tkl_safe_string_eval "tkl_unset \
CallFlags TrapNameToken TrapType ExternalLastError ShellPID StackCtxId \
FuncsStackCallNumNames FuncsStackCallNames FuncsStackCallLines \
NumSkipCallCtxs TrapHandlerFunc TrapHandlerRegisterName" \
    "tkl_safe_func_call_with_prefix \"tkl_set_last_error $ExternalLastError\" $TrapHandlerFunc \"$TrapNameToken\" \"$TrapType\" \"$ExternalLastError\" \"$ShellPID\" \
      \"$StackCtxId\" \"$FuncsStackCallNumNames\" \"$FuncsStackCallNames\" \"$FuncsStackCallLines\""
  local LastError=$?

  # Because the CallDefaultTrapHandler may be missed to call from a user trap
  # handler or been called in a subshell, then we must to redeclare variables
  # and cleanup the stack (again) from here.
  local CallFlags="${1:-0}"
  local TrapNameToken="$2"
  local TrapType="$3"
  local ExternalLastError="${4:-0}"
  local ShellPID="$5"
  local StackCtxId="$6"
  local FuncsStackCallNumNames="$7"
  local FuncsStackCallNames="$8"
  local FuncsStackCallLines="$9"

  local TrapStackName="GlobalTrapsStack_${TrapNameToken}_${TrapType}_${StackCtxId}"
  local TrapStackSizeName="GlobalTrapsStackSize_${TrapNameToken}_${TrapType}_${StackCtxId}"
  local TrapHandlerRegisterName="GlobalTrapsRegisterParams_${TrapNameToken}_${TrapType}_${StackCtxId}"

  if [[ "$TrapType" == 'RETURN' ]]; then
    CleanupPendingTrapCallCtxsImpl $CallFlags -1 "$TrapNameToken" "RETURN" "$ExternalLastError" "$FuncsStackCallNumNames" "$FuncsStackCallNames" "$FuncsStackCallLines"
  else
    # always remove stack at the end of the trap handler
    unset $TrapStackName
    unset $TrapStackSizeName
    unset $TrapHandlerRegisterName
  fi

  return $LastError
}

# call default trap handler (GlobalTrapsStackFuncs_DefaultTrapHandler) from
# a user trap handler from any function call context
function CallDefaultTrapHandler()
{
  GlobalTrapsStackFuncs_DefaultTrapHandler 0x01 "$@"
}

function GlobalTrapsStackFuncs_DefaultTrapHandler()
{
  local CallFlags="${1:-0}"
  local TrapNameToken="$2"
  local TrapType="$3"
  local ExternalLastError="${4:-0}"
  local ShellPID="$5"
  local StackCtxId="$6"
  local FuncsStackCallNumNames="$7"
  local FuncsStackCallNames="$8"
  local FuncsStackCallLines="$9"

  (( "${#TrapNameToken}" )) || return 120
  (( "${#TrapType}" )) || return 121
  (( "${#StackCtxId}" )) || return 122

  # make default trap handler uninterruptable while searching for a user trap stack
  trap '' INT

  # protect special common return global variables from changing in
  # user trap handlers of RETURN type from accedental change
  local RETURN_VALUE
  local RETURN_VALUES

  # pop the stack
  local i
  local NumSkipCallCtxs
  local TrapStackName
  local TrapStackSize
  local TrapStackSizeName
  local TrapHandlerRegisterName

  # skip calls
  TrapHandlerRegisterName="GlobalTrapsRegisterParams_${TrapNameToken}_${TrapType}_${StackCtxId}"
  declare -p "$TrapHandlerRegisterName" >/dev/null 2>&1 || return 125

  eval NumSkipCallCtxs='"${'"$TrapHandlerRegisterName"'[2]}"'
  (( ! ${#NumSkipCallCtxs} )) && NumSkipCallCtxs=0
  #echo NumSkipCallCtxs=$NumSkipCallCtxs
  #echo "FUNCNAME=${FUNCNAME[@]}"
  #declare -p $TrapHandlerRegisterName
  if (( NumSkipCallCtxs >= 0 )); then
    (( NumSkipCallCtxs-- ))
    eval $TrapHandlerRegisterName[2]='"$NumSkipCallCtxs"'
    (( NumSkipCallCtxs >= 0 )) && return 255
  fi

  TrapStackSizeName="GlobalTrapsStackSize_${TrapNameToken}_${TrapType}_${StackCtxId}"

  eval TrapStackSize=\$$TrapStackSizeName
  #echo TrapStackSize=$TrapStackSize
  (( ! ${#TrapStackSize} )) && TrapStackSize=0

  #echo TrapStackSize=$TrapStackSize
  (( TrapStackSize )) || return 126

  #echo "GlobalTrapsStackFuncs_DefaultTrapHandler $@"
  #echo -----

  TrapStackName="GlobalTrapsStack_${TrapNameToken}_${TrapType}_${StackCtxId}"

  # reverse the user trap handlers array
  local RevList
  eval tkl_reverse_array "$TrapStackName" RevList

  # reset last error before each not empty user trap handler eval string
  for (( i=0; i < TrapStackSize-1; i++ )); do
    if (( ${#RevList[i]} )); then
      RevList[i]="tkl_set_last_error $ExternalLastError; ${RevList[i]} ;" # space in case the string already trailed by the ;
    fi
  done

  if [[ "$TrapType" == 'RETURN' ]]; then
    CleanupPendingTrapCallCtxsImpl $CallFlags -1 "$TrapNameToken" "RETURN" "$ExternalLastError" "$FuncsStackCallNumNames" "$FuncsStackCallNames" "$FuncsStackCallLines"
  else
    # always remove stack at the end of the trap handler
    unset $TrapStackName
    unset $TrapStackSizeName
    unset $TrapHandlerRegisterName
  fi

  # 1. Unset all internal variables up to the function context where the
  #    PushTrap* function has been called but before the call to user trap
  #    handlers and a user trap handlers destructor.
  # 2. Restore default INT handling before a user trap handler call
  # 3. Call to user trap handlers.
  tkl_safe_string_eval "tkl_unset \
RETURN_VALUE RETURN_VALUES \
RevList CallFlags TrapNameToken TrapType ExternalLastError ShellPID StackCtxId \
FuncsStackCallNumNames FuncsStackCallNames FuncsStackCallLines \
i NumSkipCallCtxs \
TrapStackName TrapStackSize TrapStackSizeName \
TrapHandlerRegisterName" \
  "trap '' INT" \
  "${RevList[@]}"

  return $?
}

function GlobalTrapsStackFuncs_DefaultTrapHandlerDestructor()
{
  # call a user trap handler destructor (for example, to delete a user function,
  # because the stack in the function context has to be fully unwinded now)
  (( "${#1}" )) && eval "$1"

  #echo "UserCallCode=$2-" >&2

  # return with requested error value
  return $2
}

# WARNING:
# 1. All token parameters shall be consist of shell token characters.
# 2. If the TrapCmd variable has a call to a function and function is not unique
#    or may be overriden after the declaration then you must to make it unique
#    by manual copy it via the function MakeFunctionUniqueCopy with a new
#    function name (or call to PushTrapFunctionCopy/PushTrapFunctionMove
#    function to automatically Copy/Move function to unique one). Otherwise the
#    PushTrap* will register a function name for a call as a part of a command
#    but the trap will call an overriden version of a function because between
#    the call to PushTrap* and the actual call of the trap a function can be
#    redeclared.
# 3. DO NOT mix the native trap command and the PushTrap* functions in the same
#    function call context, otherwise the passed to the function user evaluation
#    string will become overriden and won't be called.
#    
# Traps Stack Format:
# <StackCtxId(0) for Trap(0)> =
#   ( [0]=<UserEvalString(0) for Trap(0)> ...
#     [N]=<UserEvalString(N) for Trap(0)> )
# ...
# <StackCtxId(K) for Trap(K)> =
#   ( [0]=<UserEvalString(0) for Trap(K)> ...
#     [M]=<UserEvalString(M) for Trap(K)> )
# ...
# , where:
#   StackCtxId=...+<ShellPID>_<CallCtxToken> (RETURN trap)
#   StackCtxId=...+<ShellPID> (other traps)
function PushTrap()
{
  local TrapNameToken="${1:-Default}"
  local TrapCmd="$2"
  shift 2
  local TrapTypes
  TrapTypes=("$@")

  local LastError
  local LateCallTrapEvalStrings
  PushTrapHandlerImpl "$TrapNameToken" 'GlobalTrapsStackFuncs_DefaultTrapHandler' "$TrapCmd" '' "${TrapTypes[@]}"
  LastError=$?
  
  # user trap handlers late call
  tkl_safe_string_eval "tkl_unset \
LastError LateCallTrapEvalStrings \
TrapNameToken TrapCmd TrapTypes" \
    "${LateCallTrapEvalStrings[@]}" \
    "return $LastError"

  return $?
}

function PushTrapHandler()
{
  local LastError
  local LateCallTrapEvalStrings
  PushTrapHandlerImpl "$@"
  LastError=$?

  # user trap handlers late call
  tkl_safe_string_eval "tkl_unset \
LastError LateCallTrapEvalStrings" \
    "${LateCallTrapEvalStrings[@]}" \
    "return $LastError"

  return $?
}

function PushTrapHandlerImpl()
{
  local TrapNameToken="${1:-Default}"
  local TrapHandlerFunc="$2"
  local TrapCmd="$3"
  local TrapHandlerDtor="$4"
  shift 4
  local TrapTypes
  TrapTypes=("$@")

  (( "${#TrapNameToken}" )) || return 8
  (( "${#TrapHandlerFunc}" )) || return 7
  (( "${#TrapTypes[@]}" )) || return 6

  # push trap of each type in the respective traps stack
  local LastError
  local TrapType

  # the main stack parameters (used for all traps)
  local TrapStackName
  local TrapStackSize
  local TrapStackSizeName

  # the handler register parameters array
  local TrapHandlerRegisterName

  local StackCtxId
  local CallCtxId
  local ShellPID

  # read all known traps as array of pairs
  local KnownTrapType
  local KnownTrapTypes
  local KnownTrapTypesSize
  if (( ! ${#BASH_SIGNALS} )); then
    KnownTrapTypes=$(trap -l)
    KnownTrapTypes="${KnownTrapTypes//)/}"
    eval BASH_SIGNALS="(0 RETURN 0 EXIT $KnownTrapTypes)"
  fi
  KnownTrapTypesSize=${#BASH_SIGNALS[@]}

  local FoundTraps
  FoundTraps=()
  local FoundTrapsSize=0

  local i
  local ignoreReturnTrap=0
  local NumReturnTrap=0
  local HasOtherTraps=0
  for TrapType in "${TrapTypes[@]}"; do
    for (( i=1; i < KnownTrapTypesSize; i+=2 )); do
      KnownTrapType="${BASH_SIGNALS[i]}"
      if [[ "${KnownTrapType%$TrapType}" != "$KnownTrapType" ]]; then
        FoundTraps[FoundTrapsSize]="${KnownTrapType#SIG}"
        (( FoundTrapsSize++ ))
        if [[ "$KnownTrapType" == 'RETURN' ]]; then
          (( NumReturnTrap++ ))
        else
          HasOtherTraps=1
        fi
        #echo KnownTrapType=$KnownTrapType
        break
      fi
    done
  done

  (( NumReturnTrap || HasOtherTraps )) || return 5

  # calculate current context level
  local CallCtxLevel=1
  FindFunctionFirstCall 'PushTrap*'
  if (( ! $? )); then
    (( CallCtxLevel+=RETURN_VALUES[1]-RETURN_VALUES[0]-1 )) # from top of the stack
  else
    return 5
  fi

  (( ! RETURN_VALUES[0] )) && ignoreReturnTrap=1 # ignore RETURN trap push if has no function context

  if (( ignoreReturnTrap && ! HasOtherTraps )); then
    # cleanup other contexts and exit
    CleanupPendingTrapCallCtxsImpl 0 0 "$TrapNameToken" "RETURN" 0
    return 4
  fi

  tkl_get_shell_pid
  ShellPID="${RETURN_VALUE:-65535}" # default value if fail

  local FuncsStackCallNamesHashToken
  local FuncsStackCallNames
  local FuncsStackCallNumNames=0
  local FuncsStackCallLinesHashToken
  local FuncsStackCallLines

  # get function calling context
  GetFunctionCallCtx $CallCtxLevel
  if (( ! $? )); then
    FuncsStackCallNamesHashToken="${RETURN_VALUES[0]}"
    FuncsStackCallNames="${RETURN_VALUES[1]}"
    FuncsStackCallNumNames="${RETURN_VALUES[2]}"
    FuncsStackCallLinesHashToken="${RETURN_VALUES[3]}"
    FuncsStackCallLines="${RETURN_VALUES[4]}"
    CallCtxId="${ShellPID}_${FuncsStackCallNamesHashToken}_${FuncsStackCallLinesHashToken}_${FuncsStackCallNumNames}"
  else
    CallCtxId="$ShellPID"
  fi
  CleanupPendingTrapCallCtxsImpl 0 0 "$TrapNameToken" "RETURN" 0 "$FuncsStackCallNumNames" "$FuncsStackCallNames" "$FuncsStackCallLines"

  local IsDefaultReturnTrapHandler=0
  local PendingTrapStackCallCtxsName
  local PendingTrapStackCallCtxsSizeName
  local PendingTrapStackCallCtxsSize

  if (( NumReturnTrap )); then
    # shall not push a trap if the call made out of valid function call context
    if (( ! ignoreReturnTrap )); then
      # prepare to check wheither we should to ignore the call
      StackCtxId="$CallCtxId"

      # the trap stack global variables
      TrapStackSizeName="GlobalTrapsStackSize_${TrapNameToken}_RETURN_${StackCtxId}"
      TrapStackName="GlobalTrapsStack_${TrapNameToken}_RETURN_${StackCtxId}"
      TrapHandlerRegisterName="GlobalTrapsRegisterParams_${TrapNameToken}_RETURN_${StackCtxId}"

      eval TrapStackSize=\$$TrapStackSizeName
      (( ! ${#TrapStackSize} )) && TrapStackSize=0

      if (( TrapStackSize )); then
        # read parameters of the stack saved in the first call to the PushTrap
        eval TrapHandlerDtor='"${'"$TrapHandlerRegisterName"'[0]}"'
        eval TrapHandlerFunc='"${'"$TrapHandlerRegisterName"'[1]}"'
      fi

      # ignore any calls of PushTrap in any trap handler
      FindFunctionLastCall 'GlobalTrapsStackFuncs_DefaultTrapHandler' 'GlobalTrapsStackFuncs_UserTrapHandlerInvoker'
      (( ! $? )) && ignoreReturnTrap=1 # ignore the call

      # continue if the call is still valid
      if (( ! ignoreReturnTrap )); then
        if [[ 'GlobalTrapsStackFuncs_DefaultTrapHandler' == "$TrapHandlerFunc" ]]; then
          IsDefaultReturnTrapHandler=1
        fi

        # create function call contexts list and the trap stack
        PendingTrapStackCallCtxsName="GlobalTrapsPindingCallCtxs_${TrapNameToken}_RETURN"
        PendingTrapStackCallCtxsSizeName="GlobalTrapsPindingCallCtxsSize_${TrapNameToken}_RETURN"

        eval PendingTrapStackCallCtxsSize=\$$PendingTrapStackCallCtxsSizeName
        (( ! ${#PendingTrapStackCallCtxsSize} )) && PendingTrapStackCallCtxsSize=0

        if (( ! PendingTrapStackCallCtxsSize )); then
          # create pending call contexts array
          eval $PendingTrapStackCallCtxsName='()'
        fi

        if (( ! TrapStackSize )); then
          # create the trap stack if not done yet
          eval $TrapStackName='()'
          eval $TrapHandlerRegisterName='()'
          # save trap handler destructor function
          eval $TrapHandlerRegisterName[0]='"$TrapHandlerDtor"'
          # save trap handler function
          eval $TrapHandlerRegisterName[1]='"$TrapHandlerFunc"'
        fi

        # num skip calls
        eval $TrapHandlerRegisterName[2]='"$CallCtxLevel"'
      fi
    fi
  fi

  local IsDefaultTrapHandler
  LastError=0
  for TrapType in "${FoundTraps[@]}"; do
    LastError=2
    IsDefaultTrapHandler=0
    if [[ "$TrapType" == 'RETURN' ]]; then
      (( ignoreReturnTrap )) && continue
      StackCtxId="$CallCtxId"

      # the trap stack global variables
      TrapStackSizeName="GlobalTrapsStackSize_${TrapNameToken}_${TrapType}_${StackCtxId}"
      TrapStackName="GlobalTrapsStack_${TrapNameToken}_${TrapType}_${StackCtxId}"
      TrapHandlerRegisterName="GlobalTrapsRegisterParams_${TrapNameToken}_${TrapType}_${StackCtxId}"

      eval TrapStackSize=\$$TrapStackSizeName
      (( ! ${#TrapStackSize} )) && TrapStackSize=0

      IsDefaultTrapHandler=$IsDefaultReturnTrapHandler

      # add new pending call context record
      eval $PendingTrapStackCallCtxsName[PendingTrapStackCallCtxsSize]='"$ShellPID $FuncsStackCallNumNames \"$FuncsStackCallNames\" \"$FuncsStackCallLines\""'
      (( PendingTrapStackCallCtxsSize++ ))

      # update pending call contexts size
      eval $PendingTrapStackCallCtxsSizeName='$PendingTrapStackCallCtxsSize'
    else
      StackCtxId="$ShellPID"

      # the trap stack global variables
      TrapStackSizeName="GlobalTrapsStackSize_${TrapNameToken}_${TrapType}_${StackCtxId}"
      TrapStackName="GlobalTrapsStack_${TrapNameToken}_${TrapType}_${StackCtxId}"
      TrapHandlerRegisterName="GlobalTrapsRegisterParams_${TrapNameToken}_${TrapType}_${StackCtxId}"

      eval TrapStackSize=\$$TrapStackSizeName
      (( ! ${#TrapStackSize} )) && TrapStackSize=0

      if (( TrapStackSize )); then
        # read parameters of the stack saved in the first call to the PushTrap
        eval TrapHandlerDtor='"${'"$TrapHandlerRegisterName"'[0]}"'
        eval TrapHandlerFunc='"${'"$TrapHandlerRegisterName"'[1]}"'
      fi

      # ignore any calls of PushTrap in any trap handler
      FindFunctionLastCall 'GlobalTrapsStackFuncs_DefaultTrapHandler' 'GlobalTrapsStackFuncs_UserTrapHandlerInvoker'
      (( ! $? )) && continue # ignore the call

      if [[ 'GlobalTrapsStackFuncs_DefaultTrapHandler' == "$TrapHandlerFunc" ]]; then
        IsDefaultTrapHandler=1
      fi

      if (( ! TrapStackSize )); then
        # create the trap stack if not done yet
        eval $TrapStackName='()'
        eval $TrapHandlerRegisterName='()'
        # save trap handler destructor function
        eval $TrapHandlerRegisterName[0]='"$TrapHandlerDtor"'
        # save trap handler function
        eval $TrapHandlerRegisterName[1]='"$TrapHandlerFunc"'
      fi
    fi

    (( ! IsDefaultTrapHandler )) && TrapHandlerFunc="GlobalTrapsStackFuncs_UserTrapHandlerInvoker"

    if (( ! TrapStackSize )); then
      EscapeString "$TrapHandlerDtor" '' 1
      eval $TrapStackName[TrapStackSize]='"GlobalTrapsStackFuncs_DefaultTrapHandlerDestructor '\''$RETURN_VALUE'\'' \$?"'
      (( TrapStackSize++ ))
    fi

    # push new record to the stack
    eval $TrapStackName[TrapStackSize]='"$TrapCmd"'
    (( TrapStackSize++ ))

    # update trap stack size
    eval $TrapStackSizeName='$TrapStackSize'

    # always reset trap handler
    if [[ "$TrapType" == 'RETURN' ]]; then
      # and drop trap if a trap handler has not been skipped
      trap "tkl_safe_func_call $TrapHandlerFunc 0 \"$TrapNameToken\" \"$TrapType\" \$? \"$ShellPID\" \
\"$StackCtxId\" \"$FuncsStackCallNumNames\" \"$FuncsStackCallNames\" \"$FuncsStackCallLines\"; \
local LastError=\$?; \
local NumSkipCallCtxs; \
eval NumSkipCallCtxs=\${GlobalTrapsRegisterParams_${TrapNameToken}_${TrapType}_${StackCtxId}[2]}; \
(( \${#NumSkipCallCtxs} && NumSkipCallCtxs >= 0 )) || trap '' '$TrapType'; \
tkl_set_last_error" \
        "$TrapType"
    else
      trap "tkl_safe_func_call $TrapHandlerFunc 0 \"$TrapNameToken\" \"$TrapType\" \$? \"$ShellPID\" \
\"$StackCtxId\" \"$FuncsStackCallNumNames\" \"$FuncsStackCallNames\" \"$FuncsStackCallLines\"" \
        "$TrapType"
    fi

    #echo ++++
    LastError=0
  done

  return $LastError
}

function CleanupPendingTrapCallCtxsImpl()
{
  local CallFlags="${1:-0}" # 0x01 - ignore process pid check
  local CallFrom="$2"       # -1 - trap handler, 0 - PushTrap, N - number of pops
  local TrapNameToken="$3"
  local TrapType="$4"
  local ExternalLastError="${5:-0}"
  local FuncsStackCallNumNames="${6:-0}"
  local FuncsStackCallNames="$7"
  local FuncsStackCallLines="$8"

  #echo "CleanupPendingTrapCallCtxsImpl"

  local IFS

  local TrapStackName
  local TrapStackSize
  local TrapStackSizeName
  local TrapHandlerRegisterName

  #local LateCallTrapEvalStrings # should be declared in the callers of this function
  local LateCallTrapEvalStringsSize=0
  local LateCallTrapHandlers
  local LateCallTrapHandlersSize=0
  local LateCallTrapRegisters
  local LateCallTrapRegistersSize=0
  local EvalList
  local RevList
  LateCallTrapHandlers=()
  LateCallTrapRegisters=()
  EvalList=()
  RevList=()

  local i
  local j
  local ArrSize
  local LastError
  local PendingCallCtxId
  local PendingTrapStackSize
  local PendingTrapStackSizeName
  local PendingTrapStackName
  local PendingTrapHandlerRegisterName

  # This is the context list where a trap handler must be called soon.
  # We use it in the cleanup procedure to remove records what become dormant or
  # abandoned because associated trap handler was not called on them for some
  # reason.
  # Format per record: { <FuncNamesStackSize>, <FuncNamesStack>, <FuncLinesStack> }
  local PendingTrapStackCallCtxsName="GlobalTrapsPindingCallCtxs_${TrapNameToken}_${TrapType}"
  local PendingTrapStackCallCtxsSizeName="GlobalTrapsPindingCallCtxsSize_${TrapNameToken}_${TrapType}"

  # Cleanup all pending call contexts which are already out of scope from the
  # context of this function call.
  local FuncsStackPendingCallNamesHashToken
  local FuncsStackPendingCallLinesHashToken

  local DoUpdateCallCtxs=0
  local NumCurrentCallCtxsPopped=0

  local PendingFuncsStackCtxEvalStr
  local PendingFuncsStackCtxArr
  local PendingTrapStackCallCtxsSize
  eval PendingTrapStackCallCtxsSize=\$$PendingTrapStackCallCtxsSizeName
  (( ! ${#PendingTrapStackCallCtxsSize} )) && PendingTrapStackCallCtxsSize=0

  tkl_get_shell_pid
  local ShellPID="${RETURN_VALUE:-65535}" # default value if fail

  # the cleanup procedure
  if (( PendingTrapStackCallCtxsSize )); then
    local CanCleanup
    local IsSubstackMatched
    #local PendingFuncsStackSubshellPID
    #local PendingFuncsStackCallNumNames
    #local PendingFuncsStackCallNames
    #local PendingFuncsStackCallLines
    local FuncsStackCallNamesToMatch="${FuncsStackCallNames:+|}$FuncsStackCallNames"
    local FuncsStackCallLinesToMatch="${FuncsStackCallLines:+|}$FuncsStackCallLines"
    ArrSize=$PendingTrapStackCallCtxsSize
    for (( i=0; i < ArrSize; i++ )); do
      eval PendingFuncsStackCtxEvalStr='"${'"$PendingTrapStackCallCtxsName"'[i]}"'
      eval PendingFuncsStackCtxArr="($PendingFuncsStackCtxEvalStr)"
      #PendingFuncsStackSubshellPID="${PendingFuncsStackCtxArr[0]}"
      #PendingFuncsStackCallNumNames="${PendingFuncsStackCtxArr[1]}"
      #PendingFuncsStackCallNames="${PendingFuncsStackCtxArr[2]}"
      #PendingFuncsStackCallLines="${PendingFuncsStackCtxArr[3]}"

      CanCleanup=0
      IsSubstackMatched=0
      if (( CallFlags & 0x01 )) || [[ "$ShellPID" == "${PendingFuncsStackCtxArr[0]}" ]]; then
        if (( PendingFuncsStackCtxArr[1] > FuncsStackCallNumNames )); then
          CanCleanup=1
        elif [[ "${FuncsStackCallNamesToMatch%|${PendingFuncsStackCtxArr[2]}}" == "$FuncsStackCallNamesToMatch" ||
                "${FuncsStackCallLinesToMatch%|${PendingFuncsStackCtxArr[3]}}" == "$FuncsStackCallLinesToMatch" ]]; then
          CanCleanup=1
        elif (( CallFrom != 0 && PendingFuncsStackCtxArr[1] == FuncsStackCallNumNames )); then
          IsSubstackMatched=1
          if (( CallFrom < 0 || NumCurrentCallCtxsPopped < CallFrom )); then # can pop either all or N record at a time
            CanCleanup=1
          fi
          (( NumCurrentCallCtxsPopped++ ))
        fi
      fi

      if (( CanCleanup )); then
        # out of scope, drop the record and associated stack
        HashStringAsToken "${PendingFuncsStackCtxArr[2]}"
        LastError=$?
        FuncsStackPendingCallNamesHashToken="$RETURN_VALUE"

        HashStringAsToken "${PendingFuncsStackCtxArr[3]}"
        let "LastError|=$?"
        FuncsStackPendingCallLinesHashToken="$RETURN_VALUE"

        if (( ! LastError )); then
          DoUpdateCallCtxs=1
          PendingCallCtxId="${PendingFuncsStackCtxArr[0]}_${FuncsStackPendingCallNamesHashToken}_${FuncsStackPendingCallLinesHashToken}_${PendingFuncsStackCtxArr[1]}"
          PendingTrapStackSizeName="GlobalTrapsStackSize_${TrapNameToken}_${TrapType}_${PendingCallCtxId}"
          PendingTrapStackName="GlobalTrapsStack_${TrapNameToken}_${TrapType}_${PendingCallCtxId}"
          PendingTrapHandlerRegisterName="GlobalTrapsRegisterParams_${TrapNameToken}_${TrapType}_${PendingCallCtxId}"

          if (( ! IsSubstackMatched && CallFrom != -1 )); then
            eval PendingTrapStackSize=\$$PendingTrapStackSizeName
            (( ! ${#PendingTrapStackSize} )) && PendingTrapStackSize=0

            if (( PendingTrapStackSize )); then
              # reverse the user trap handlers array
              eval tkl_reverse_array \"$PendingTrapStackName\" RevList

              # reset last error before each not empty user trap handler eval string
              for (( j=0; j < PendingTrapStackSize-1; j++ )); do
                if (( ${#RevList[j]} )); then
                  RevList[j]="tkl_set_last_error $ExternalLastError; ${RevList[j]} ;" # space in case the string already trailed by the ;
                fi
              done

              # to iterate from back
              LateCallTrapHandlers=("${LateCallTrapHandlers[@]}" "${RevList[@]}")
              (( LateCallTrapHandlersSize+=PendingTrapStackSize ))
              LateCallTrapHandlers[LateCallTrapHandlersSize]=$PendingTrapStackSize
              (( LateCallTrapHandlersSize++ ))

              eval LateCallTrapRegisters[LateCallTrapRegistersSize+0]='"${'"$PendingTrapHandlerRegisterName"'[0]}"'
              eval LateCallTrapRegisters[LateCallTrapRegistersSize+1]='"${'"$PendingTrapHandlerRegisterName"'[1]}"'
              (( LateCallTrapRegistersSize+=2 ))
            fi
          fi

          if (( ! IsSubstackMatched || CallFrom == -1 )); then
            # remove the stack if call is made:
            # 1. out of function call context scope
            # 2. below function call context scope
            # 3. in the trap handler
            unset $PendingTrapStackSizeName
            unset $PendingTrapStackName
            unset $PendingTrapHandlerRegisterName
          fi

          #echo "Removed: $TrapStackSizeName"
          #echo "Removed: $TrapStackName"

          # remove one record from pending call contexts list if a call is made:
          # 1. out of function call context scope
          # 2. below function call context scope
          # 3. in the trap handler
          # 4. by the PopTrap
          unset $PendingTrapStackCallCtxsName[i]
          (( PendingTrapStackCallCtxsSize-- ))

          #echo "PendingTrapStackCallCtxsSize=$PendingTrapStackCallCtxsSize"
        fi
      fi
    done
  fi

  # updating or removing pending call contexts list
  if (( DoUpdateCallCtxs )); then # do not repack if already empty on pop
    if (( PendingTrapStackCallCtxsSize )); then
      # repack the pending call contexts array
      eval $PendingTrapStackCallCtxsName='("${'"$PendingTrapStackCallCtxsName"'[@]}")'
      # update pending call contexts size
      eval $PendingTrapStackCallCtxsSizeName='$PendingTrapStackCallCtxsSize'
    else
      # no more function call context has remembered
      unset $PendingTrapStackCallCtxsName
      unset $PendingTrapStackCallCtxsSizeName
    fi
  fi

  IFS=$' \t\r\n' # workaround for the bug in the "[@]:i" expression under the bash version lower than 4.1

  # generate user trap handlers eval strings
  if (( LateCallTrapRegistersSize )); then
    local NextOffset
    (( NextOffset=LateCallTrapHandlersSize-1 ))
    for (( i=LateCallTrapRegistersSize-2; i >= 0; i-=2 )); do
      ArrSize=${LateCallTrapHandlers[NextOffset]}
      (( NextOffset-=ArrSize ))
      EscapeString "${LateCallTrapRegisters[i+0]}" '' 1
      LateCallTrapEvalStrings[LateCallTrapEvalStringsSize]="\
${LateCallTrapHandlers[@]:NextOffset:ArrSize}
GlobalTrapsStackFuncs_DefaultTrapHandlerDestructor '$RETURN_VALUE' \$?"
      (( LateCallTrapEvalStringsSize++ ))
      (( NextOffset-- ))
    done
  fi

  return 0
}

# Tips:
# 1. The TrapHandlerFunc will be auto copied to a new function with unique
#    signature. No need to pass a function with the unique name for that
#    reason.
# 2. To auto delete a copied function do add the DeleteThisFunction to
#    the end of the original function body. It will auto delete the new function
#    after it has executed and so the original one if it has executed too. Or
#    use the MakeFunctionUniqueCopy function with the special parameter to add
#    at the end of the function a shell code (DeleteThisFunction) only for a
#    function copy and PushTrap after to use a copied function.
# 3. If a function is not auto deletes itself then you have to delete a
#    function you have passed to the PushTrap function manually after it has
#    executed once.
function PushTrapFunctionCopy()
{
  local TrapNameToken="${1:-Default}"
  local TrapHandlerFunc="$2"
  shift 2
  local TrapTypes
  TrapTypes=("$@")

  # make new function copy from a user function, delete new function in the stack destructor
  local LastError
  local LateCallTrapEvalStrings
  MakeTrapHandlerCopy "$TrapHandlerFunc" 1
  LastError=$?
  (( LastError )) && return 1
  local NewFunc="$RETURN_VALUE"
  PushTrapHandlerImpl "$TrapNameToken" 'GlobalTrapsStackFuncs_DefaultTrapHandler' "$NewFunc" "DeleteFunction '$NewFunc'" "${TrapTypes[@]}"
  LastError=$?

  # user trap handlers late call
  tkl_safe_string_eval "tkl_unset \
LastError LateCallTrapEvalStrings NewFunc \
TrapNameToken TrapHandlerFunc TrapTypes" \
    "${LateCallTrapEvalStrings[@]}" \
    "return $LastError"

  return $?
}

# The same as PushTrapFunctionCopy but deletes the original function after the
# new one has copied.
function PushTrapFunctionMove()
{
  local TrapNameToken="${1:-Default}"
  local TrapHandlerFunc="$2"
  shift 2
  local TrapTypes
  TrapTypes=("$@")

  # make new function copy from a user function, delete new function in the stack destructor
  local LastError
  local LateCallTrapEvalStrings
  MakeTrapHandlerMove "$TrapHandlerFunc" 1
  LastError=$?
  (( LastError )) && return 1
  local NewFunc="$RETURN_VALUE"
  PushTrapHandlerImpl "$TrapNameToken" 'GlobalTrapsStackFuncs_DefaultTrapHandler' "$NewFunc" "DeleteFunction '$NewFunc'" "${TrapTypes[@]}"
  LastError=$?

  # user trap handlers late call
  tkl_safe_string_eval "tkl_unset \
LastError LateCallTrapEvalStrings NewFunc \
TrapNameToken TrapHandlerFunc TrapTypes" \
    "${LateCallTrapEvalStrings[@]}" \
    "return $LastError"

  return $?
}

function MakeTrapHandlerCopy()
{
  local FuncName="$1"
  local CallCtxLevel="$2" # 0 - context of a call to this function
  local SuffixCmd="$3"

  MakeFunctionUniqueCopy -f "$FuncName" '' $(( CallCtxLevel + 1 )) '' '' "$SuffixCmd"
  local LastError=$?
  if (( LastError )); then
    RETURN_VALUE="$FuncName" # set to original one
  fi

  return $LastError
}

function MakeTrapHandlerMove()
{
  local FuncName="$1"
  local CallCtxLevel="$2" # 0 - context of a call to this function
  local SuffixCmd="$3"

  MakeFunctionUniqueCopy -f "$FuncName" '' $(( CallCtxLevel + 1 )) '' '' "$SuffixCmd"
  local LastError=$?
  if (( ! LastError )); then
    DeleteFunction "$FuncName" # delete original one
  else
    RETURN_VALUE="$FuncName" # set to original one
  fi

  return $LastError
}

function PopTrap()
{
  local TrapNameToken="${1:-Default}"
  shift
  local TrapTypes
  TrapTypes=("$@")

  local LastError
  local LateCallTrapEvalStrings
  PopTrapImpl "$TrapNameToken" "${TrapTypes[@]}"
  LastError=$?

  # user trap handlers late call
  tkl_safe_string_eval "tkl_unset \
LastError LateCallTrapEvalStrings \
TrapNameToken TrapTypes" \
    "${LateCallTrapEvalStrings[@]}" \
    "return $LastError"

  return $?
}

function PopTrapImpl()
{
  #echo PopTrapImpl
  local TrapNameToken="${1:-Default}"
  shift
  local TrapTypes
  TrapTypes=("$@")

  (( "${#TrapNameToken}" )) || return 8
  (( "${#TrapTypes[@]}" )) || return 6

  # push trap of each type in the respective traps stack
  local LastError
  local TrapType

  # the main stack parameters (used for all traps)
  local TrapStackName
  local TrapStackSize
  local TrapStackSizeName

  # the handler register parameters array
  local TrapHandlerRegisterName

  local StackCtxId
  local CallCtxId
  local ShellPID

  # read all known traps as array of pairs
  local KnownTrapType
  local KnownTrapTypes
  local KnownTrapTypesSize
  if (( ! ${#BASH_SIGNALS} )); then
    KnownTrapTypes=$(trap -l)
    KnownTrapTypes="${KnownTrapTypes//)/}"
    eval BASH_SIGNALS="(0 RETURN 0 EXIT $KnownTrapTypes)"
  fi
  KnownTrapTypesSize=${#BASH_SIGNALS[@]}

  local FoundTraps
  FoundTraps=()
  local FoundTrapsSize=0

  local i
  local ignoreReturnTrap=0
  local NumReturnTrap=0
  local HasOtherTraps=0
  for TrapType in "${TrapTypes[@]}"; do
    for (( i=1; i < KnownTrapTypesSize; i+=2 )); do
      KnownTrapType="${BASH_SIGNALS[i]}"
      if [[ "${KnownTrapType%$TrapType}" != "$KnownTrapType" ]]; then
        FoundTraps[FoundTrapsSize]="${KnownTrapType#SIG}"
        (( FoundTrapsSize++ ))
        if [[ "$KnownTrapType" == 'RETURN' ]]; then
          (( NumReturnTrap++ ))
        else
          HasOtherTraps=1
        fi
        #echo KnownTrapType=$KnownTrapType
        break
      fi
    done
  done

  (( NumReturnTrap || HasOtherTraps )) || return 5

  # calculate current context level
  local CallCtxLevel=1
  FindFunctionFirstCall 'PopTrap*'
  if (( ! $? )); then
    (( CallCtxLevel+=RETURN_VALUES[1]-RETURN_VALUES[0]-1 )) # from top of the stack
  else
    return 5
  fi

  (( ! RETURN_VALUES[0] )) && ignoreReturnTrap=1 # ignore RETURN trap pop if has no function context

  if (( ignoreReturnTrap && ! HasOtherTraps )); then
    # cleanup other contexts and exit
    CleanupPendingTrapCallCtxsImpl 0 $NumReturnTrap "$TrapNameToken" "RETURN" 0
    return 4
  fi

  tkl_get_shell_pid
  ShellPID="${RETURN_VALUE:-65535}" # default value if fail

  local FuncsStackCallNamesHashToken
  local FuncsStackCallNames
  local FuncsStackCallNumNames=0
  local FuncsStackCallLinesHashToken
  local FuncsStackCallLines

  # get function calling context
  GetFunctionCallCtx $CallCtxLevel
  if (( ! $? )); then
    FuncsStackCallNamesHashToken="${RETURN_VALUES[0]}"
    FuncsStackCallNames="${RETURN_VALUES[1]}"
    FuncsStackCallNumNames="${RETURN_VALUES[2]}"
    FuncsStackCallLinesHashToken="${RETURN_VALUES[3]}"
    FuncsStackCallLines="${RETURN_VALUES[4]}"
    CallCtxId="${ShellPID}_${FuncsStackCallNamesHashToken}_${FuncsStackCallLinesHashToken}_${FuncsStackCallNumNames}"
  else
    CallCtxId="$ShellPID"
  fi
  CleanupPendingTrapCallCtxsImpl 0 $NumReturnTrap "$TrapNameToken" "RETURN" 0 "$FuncsStackCallNumNames" "$FuncsStackCallNames" "$FuncsStackCallLines"

  LastError=0
  for TrapType in "${FoundTraps[@]}"; do
    LastError=2
    if [[ "$TrapType" == 'RETURN' ]]; then
      (( ignoreReturnTrap )) && continue
      StackCtxId="$CallCtxId"
    else
      StackCtxId="$ShellPID"
    fi

    # the trap stack global variables
    TrapStackSizeName="GlobalTrapsStackSize_${TrapNameToken}_${TrapType}_${StackCtxId}"
    TrapStackName="GlobalTrapsStack_${TrapNameToken}_${TrapType}_${StackCtxId}"
    TrapHandlerRegisterName="GlobalTrapsRegisterParams_${TrapNameToken}_${TrapType}_${StackCtxId}"

    eval TrapStackSize=\$$TrapStackSizeName
    #echo TrapStackSize=$TrapStackSize
    (( ! ${#TrapStackSize} )) && TrapStackSize=0

    if (( TrapStackSize > 2 )); then # destructor call in the first item
      # pop trap from the stack
      (( TrapStackSize-- ))
      unset $TrapStackName[TrapStackSize]

      # update trap stack size
      eval $TrapStackSizeName='$TrapStackSize'
    else
      # drop the trap
      trap '' "$TrapType"

      unset $TrapStackSizeName
      unset $TrapStackName
      unset $TrapHandlerRegisterName
    fi
    LastError=0
  done

  return $LastError
}

function GetTrapNum()
{
  local TrapNameToken="${1:-Default}"
  shift
  local TrapTypes
  TrapTypes=("$@")

  # drop return values
  RETURN_VALUES=()

  (( "${#TrapNameToken}" )) || return 8
  (( "${#TrapTypes[@]}" )) || return 6

  # push trap of each type in the respective traps stack
  local LastError
  local TrapType
  local TrapTypesSize=${#TrapTypes[@]}

  # the main stack parameters (used for all traps)
  local TrapStackName
  local TrapStackSize
  local TrapStackSizeName

  # the handler register parameters array
  local TrapHandlerRegisterName

  local StackCtxId
  local CallCtxId
  local ShellPID

  local ignoreReturnTrap=0

  # calculate current context level
  local CallCtxLevel=2
  FindFunctionFirstCall 'GlobalTrapsStackFuncs_DefaultTrapHandler' 'GlobalTrapsStackFuncs_UserTrapHandlerInvoker'
  if (( ! $? )); then
    (( CallCtxLevel+=RETURN_VALUES[1]-RETURN_VALUES[0]-1 )) # from top of the stack
  else
    CallCtxLevel=1
    FindFunctionFirstCall 'GetTrap*' 'PushTrap*'
    if (( ! $? )); then
      (( CallCtxLevel+=RETURN_VALUES[1]-RETURN_VALUES[0]-1 )) # from top of the stack
    else
      # drop return values
      RETURN_VALUES=()
      return 5
    fi
  fi

  (( ! RETURN_VALUES[0] )) && ignoreReturnTrap=1 # ignore the call

  tkl_get_shell_pid
  ShellPID="${RETURN_VALUE:-65535}" # default value if fail

  local FuncsStackCallNamesHashToken
  local FuncsStackCallNames
  local FuncsStackCallNumNames=0
  local FuncsStackCallLinesHashToken
  local FuncsStackCallLines

  # get function calling context
  GetFunctionCallCtx $CallCtxLevel
  if (( ! $? )); then
    FuncsStackCallNamesHashToken="${RETURN_VALUES[0]}"
    FuncsStackCallNames="${RETURN_VALUES[1]}"
    FuncsStackCallNumNames="${RETURN_VALUES[2]}"
    FuncsStackCallLinesHashToken="${RETURN_VALUES[3]}"
    FuncsStackCallLines="${RETURN_VALUES[4]}"
    CallCtxId="${ShellPID}_${FuncsStackCallNamesHashToken}_${FuncsStackCallLinesHashToken}_${FuncsStackCallNumNames}"
  else
    CallCtxId="$ShellPID"
  fi

  # drop return values
  RETURN_VALUES=()

  local HasUserTraps=0
  local TrapIndex=0
  for TrapType in "${TrapTypes[@]}"; do
    if [[ "$TrapType" == 'RETURN' ]]; then
      if (( ignoreReturnTrap )); then
        (( ! ${#RETURN_VALUES[TrapIndex]} )) && RETURN_VALUES[TrapIndex]=0
        continue
      fi
      StackCtxId="$CallCtxId"
    else
      StackCtxId="$ShellPID"
    fi

    # the trap stack global variables
    TrapStackSizeName="GlobalTrapsStackSize_${TrapNameToken}_${TrapType}_${StackCtxId}"
    TrapStackName="GlobalTrapsStack_${TrapNameToken}_${TrapType}_${StackCtxId}"
    TrapHandlerRegisterName="GlobalTrapsRegisterParams_${TrapNameToken}_${TrapType}_${StackCtxId}"

    eval TrapStackSize=\$$TrapStackSizeName
    #echo TrapStackSize=$TrapStackSize
    (( ! ${#TrapStackSize} )) && TrapStackSize=0

    if (( TrapStackSize )); then
      RETURN_VALUES[TrapIndex]=$(( TrapStackSize-1 )) # minus destructor call string
    else
      RETURN_VALUES[TrapIndex]=0
    fi

    (( TrapStackSize )) && HasUserTraps=1

    (( TrapIndex++ ))
  done

  (( HasUserTraps )) && return 0

  return 1
}
