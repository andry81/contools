#!/bin/bash

# Script library to support function object.

# Script can be ONLY included by "source" command.
[[ -n "$BASH" && (-z "$BASH_LINENO" || BASH_LINENO[0] -gt 0) && (-z "$SOURCE_CONTOOLS_FUNCLIB_SH" || SOURCE_CONTOOLS_FUNCLIB_SH -eq 0) ]] || return 0 || exit 0 # exit to avoid continue if the return can not be called

SOURCE_CONTOOLS_FUNCLIB_SH=1 # including guard

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
tkl_include_or_abort "$TACKLELIB_BASH_ROOT/tacklelib/baselib.sh"
tkl_include_or_abort "$CONTOOLS_BASH_ROOT/hashlib.sh"

function GetFunctionDeclaration()
{
  local FuncName="$1" # has to be declared

  # drop return value
  RETURN_VALUE=""

  (( ${#FuncName} )) || return 1

  local LastError
  local FuncDecl
  local FuncDeclSize

  FuncDecl="$(declare -f "$FuncName")"
  LastError=$?
  FuncDeclSize=${#FuncDecl}

  (( ! LastError && FuncDeclSize )) || return 2

  RETURN_VALUE="$FuncDecl"

  return 0
}

function GetFunctionDeclarations()
{
  local FuncName
  local NumFuncs=0

  # drop return values
  RETURN_VALUES=()

  local i=0
  for FuncName in "$@"; do
    GetFunctionDeclaration "$FuncName"
    (( ! $? && NumFuncs++ ))
    RETURN_VALUES[i]="$RETURN_VALUE"
    (( i++ ))
  done

  (( NumFuncs )) && return 0

  return 1
}

function MakeFunctionCopy()
{
  local Flags="$1"
  if [[ "${Flags:0:1}" == '-' ]]; then
    shift
  else
    Flags=""
  fi
  local FuncName="$1"       # has to be declared
  local NewFuncName="$2"    # sould not be declared
  local SuffixCmd="$3"      # command added to the end of new function

  GetFunctionDeclaration "$FuncName"
  (( $? )) && return 1

  # drop return value
  (( ${#NewFuncName} )) || return 2

  MakeFunctionCopyImpl "$Flags" "$FuncName" "$RETURN_VALUE" "$NewFuncName" "$SuffixCmd"
}

function MakeFunctionCopyImpl()
{
  local Flags="$1"
  local FuncName="$2"       # has to be declared
  local FuncDecl="$3"
  local NewFuncName="$4"    # sould not be declared
  local SuffixCmd="$5"      # command added to the end of new function

  if [[ "${Flags//f/}" == "$Flags" ]]; then
    # new function should not exist
    NewFuncDecl="$(declare -f "$NewFuncName")"
    LastError=$?
    local NewFuncDeclSize=${#NewFuncDecl}

    (( LastError && ! NewFuncDeclSize )) || return 4
  fi

  # replace function name
  local FuncEscapedDecl="${FuncDecl#*()}"

  # escape function declaration string
  FuncEscapedDecl="${FuncEscapedDecl//\\/\\\\}"
  #FuncEscapedDecl="${FuncEscapedDecl//\$/\\\$}"

  if (( ${#SuffixCmd} )); then
    FuncEscapedDecl="${FuncEscapedDecl%\}*}$SuffixCmd"$'\n'"}"
  fi

  # make new function
  eval function "$NewFuncName"'()' "$FuncEscapedDecl"

  RETURN_VALUE="$NewFuncName"

  return 0
}

function DeleteFunction()
{
  local FuncName="$1" # has to be declared

  #echo "DeleteThisFunction: $FuncName: ${FUNCNAME[@]}"

  (( ${#FuncName} )) || return 2

  declare -f "$FuncName" >/dev/null
  if (( ! $? )); then
    unset -f "$FuncName"
    return 0
  fi

  return 1
}

# unsets current function call
function DeleteThisFunction()
{
  local FuncName="${FUNCNAME[1]}"

  #echo "DeleteThisFunction: $FuncName: ${FUNCNAME[@]}"

  if (( ${#FuncName} )); then
    unset $FuncName
    return 0
  fi

  return 1
}

# The same as MakeFunctionCopy but adds to the function name a unique
# indentifier constructed from the value returned by the function
# HashFunctionBodyAsToken and external identifier prefix/suffix if passed to the
# function.
function MakeFunctionUniqueCopy()
{
  local Flags="$1"
  if [[ "${Flags:0:1}" == '-' ]]; then
    shift
  else
    Flags=""
  fi
  local FuncName="$1"
  local NewFuncName="${2:-"$FuncName"}"
  local CallCtxLevel="${3:-0}" # 0 - context of a call to this function
  local IdPrefix="$4"
  local IdSuffix="$5"
  local SuffixCmd="$6"

  GetFunctionDeclaration "$FuncName"
  (( $? )) && return 1
  local FuncDecl="$RETURN_VALUE"

  if (( ${#CallCtxLevel} )); then
    GetFunctionCallCtx $(( CallCtxLevel + 1 ))
    (( $? )) && return 2

    tkl_get_shell_pid
    local ShellPID="${RETURN_VALUE:-65535}" # default value if fail

    MakeFunctionCopyImpl "$Flags" "$FuncName" "$FuncDecl" "${NewFuncName}${IdPrefix:+_}${IdPrefix}_${ShellPID}_${RETURN_VALUES[0]}_${RETURN_VALUES[3]}_${RETURN_VALUES[2]}${IdSuffix:+_}${IdSuffix}" "$SuffixCmd"
    (( $? )) && return 3
  else
    MakeFunctionCopyImpl "$Flags" "$FuncName" "$FuncDecl" "${NewFuncName}${IdPrefix:+_}${IdPrefix}${IdSuffix:+_}${IdSuffix}" "$SuffixCmd"
    (( $? )) && return 4
  fi

  return 0
}

function GetFunctionName()
{
  local CallNestIndex="${1:-0}" # 0 - context of call to this function

  # drop return values
  RETURN_VALUES=("" -1)

  local LineNumber=${BASH_LINENO[CallNestIndex+1]}
  if (( ${#LineNumber} )); then
    local FuncName="${FUNCNAME[CallNestIndex+1]}"
    if (( ${#FuncName} )); then
      RETURN_VALUES=("$FuncName" "$LineNumber")
      return 0
    fi
  fi

  return 1
}

function GetFunctionBody()
{
  local FuncName="$1" # has to be declared

  # drop return value
  RETURN_VALUE=""

  GetFunctionDeclaration "$FuncName"
  (( $? )) && return 1

  local FuncBody="${RETURN_VALUE#*\{}"
  FuncBody="${FuncBody#*[$'\r\n']}"
  FuncBody="${FuncBody%\}*}"
  RETURN_VALUE="${FuncBody%[$'\r\n']*}"

  return 0
}

# from top of stack to the begin
function FindFunctionLastCall()
{
  local FuncNames
  FuncNames=("$@")

  # drop return values
  RETURN_VALUES=(-1 $((NumFuncs-1)) )

  local FuncName
  local StackFuncName
  local NumFuncs=${#FUNCNAME[@]}
  local i
  for (( i=1; i < NumFuncs; i++ )); do
    StackFuncName="${FUNCNAME[i]}"
    for FuncName in "${FuncNames[@]}"; do
      if [[ "${StackFuncName#$FuncName}" != "$StackFuncName" ]]; then
        RETURN_VALUES=( $((NumFuncs-i-1)) $((NumFuncs-1)) ) # from stack begin
        return 0
      fi
    done
  done

  return 1
}

# from bagin of stack to the top
function FindFunctionFirstCall()
{
  local FuncNames
  FuncNames=("$@")

  local NumFuncs=${#FUNCNAME[@]}

  # drop return values
  RETURN_VALUES=(-1 $((NumFuncs-1)) )

  local FuncName
  local StackFuncName
  local NumFuncs=${#FUNCNAME[@]}
  local i
  for (( i=NumFuncs; --i >= 1; )); do
    StackFuncName="${FUNCNAME[i]}"
    for FuncName in ${FuncNames[@]}; do
      if [[ "${StackFuncName#$FuncName}" != "$StackFuncName" ]]; then
        RETURN_VALUES=( $((NumFuncs-i-1)) $((NumFuncs-1)) ) # from stack begin
        return 0
      fi
    done
  done

  return 1
}

function GetFunctionCallCtx()
{
  local CtxLevel="$1" # 0 - context of a call to this function

  # the join character should be not a character from function name token!
  HashArrayAsToken "FUNCNAME" '|' $(( CtxLevel + 2 ))
  if (( $? )); then
    # drop return values
    RETURN_VALUES=('' '' 0 '' 0)
    return 1
  fi
  local FuncsStackCallNamesHashToken="${RETURN_VALUES[0]}"
  local FuncsStackCallNames="${RETURN_VALUES[1]}"
  local FuncsStackCallNumNames="${RETURN_VALUES[2]}"
  HashArrayAsToken "BASH_LINENO" '|' $(( CtxLevel + 2 ))
  if (( $? )); then
    # drop return values
    RETURN_VALUES=('' '' 0 '' 0)
    return 2
  fi
  local FuncsStackCallLinesHashToken="${RETURN_VALUES[0]}"
  local FuncsStackCallLines="${RETURN_VALUES[1]}"

  RETURN_VALUES=(
    "$FuncsStackCallNamesHashToken" "$FuncsStackCallNames" "$FuncsStackCallNumNames"
    "$FuncsStackCallLinesHashToken" "$FuncsStackCallLines"
  )

  return 0
}
