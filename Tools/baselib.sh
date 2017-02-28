#!/bin/bash_entry

# Script library to support basic shell operations.

# Short keyword's descriptions:
#  Item - value which passed as string in a function argument.
#  Array - array of not unique values which passed as array name in a function argument.
#  List - list of not unique values which passed as string in a function argument.
#  Args - list of not unique values which passed in function arguments ($@).
#  UArray - array of unique values which passed as array name in a function argument.
#  UList - list of unique values which passed as string in a function argument.
#  PItem - wildcard pattern value which passed as string in a function argument.
#  PArray - array of not unique wildcard pattern values which passed as array name in a function argument.
#  PList - list of not unique wildcard pattern values which passed as string in a function argument.
#  PArgs - list of not unique wildcard pattern items which passed in function arguments ($@).

# Script can be ONLY included by "source" command.
if [[ -n "$BASH" && (-z "$BASH_LINENO" || ${BASH_LINENO[0]} -gt 0) ]] && (( ! ${#SOURCE_CONTOOLS_BASELIB_SH} )); then

SOURCE_CONTOOLS_BASELIB_SH=1 # including guard

function declare_global()
{
  # The global declaration feature is enabled in Bash 4.2 but works stable only
  # on Bash 4.3 and higher.
  if (( ${BASH_VERSINFO[0]:-0} > 4 || ${BASH_VERSINFO[0]:-0} == 4 && ${BASH_VERSINFO[1]:-0} >= 3 )); then 
    declare -g $1="$2"
  else
    # Tricky implementation to set global variable from a function w/o:
    # 1. special characters handle
    # 2. issues with value injection
    read -r -d"\0" $1 <<< "$2" # WARNING: in old bash (3.2.x) will assign to a local variable if a local overlaps global
  fi
}

function declare_global_array()
{
  # The global declaration feature is enabled in Bash 4.2 but works stable only
  # on Bash 4.3 and higher.
  if (( ${BASH_VERSINFO[0]:-0} > 4 || ${BASH_VERSINFO[0]:-0} == 4 && ${BASH_VERSINFO[1]:-0} >= 3 )); then 
    local IFS=$' \t\r\n' # just in case, workaround for the bug in the "[@]:i" expression under the bash version lower than 4.1
    eval declare -g "$1=(\"\${@:2}\")"
  else
    local IFS=$' \t\r\n' # workaround for the bug in the "[@]:i" expression under the bash version lower than 4.1
    eval "$1=(\"\${@:2}\")" # WARNING: in old bash (3.2.x) will assign to a local variable if a local overlaps global
  fi
}

function declare_local_array()
{
  local IFS=$' \t\r\n' # just in case, workaround for the bug in the "[@]:i" expression under the bash version lower than 4.1
  eval declare "$1=(\"\${@:2}\")"
}

function declare_array()
{
  local IFS=$' \t\r\n' # just in case, workaround for the bug in the "[@]:i" expression under the bash version lower than 4.1
  eval "$1=(\"\${@:2}\")"
}

function EnableNoCaseMatch()
{
  RETURN_VALUE="$(shopt -p nocasematch)" # Read state before change

  if (( ! $? )); then
    if [[ "$RETURN_VALUE" != "shopt -s nocasematch" ]]; then
      shopt -s nocasematch
      return 0
    fi
  fi

  RETURN_VALUE=""

  return 1
}

function DisableNoCaseMatch()
{
  RETURN_VALUE="$(shopt -p nocasematch)" # Read state before change
  if (( ! $? )); then
    if [[ "$RETURN_VALUE" != "shopt -u nocasematch" ]]; then
      shopt -u nocasematch
      return 0
    fi
  fi

  RETURN_VALUE=""

  return 1
}

# function-wrapper over the shift command to pass into the shift the correct
# number of parameters to offset
function GetShiftOffset()
{
  local maxOffset="${1:-0}"
  if (( maxOffset )); then
    shift
  else
    return 0
  fi

  local numArgs="${#@}"
  if (( numArgs >= maxOffset )); then
    return $maxOffset
  fi

  return $numArgs
}

function IsEqualArrays()
{
  eval declare "ArraySize1=\"\${#$1[@]}\""
  eval declare "ArraySize2=\"\${#$2[@]}\""

  (( ArraySize1 == ArraySize2 )) || {
    if (( ArraySize1 < ArraySize2 )); then
      return 1
    else
      return -1
    fi
  }

  local i
  for (( i=0; i<ArraySize1; i++ )); do
    if eval "[[ \"\${$1[i]}\" < \"\${$2[i]}\" ]]"; then
      return 1
    elif eval "[[ \"\${$2[i]}\" < \"\${$1[i]}\" ]]"; then
      return -1
    fi
  done

  return 0
}

function ReverseArray()
{
  local InArrName="$1"
  local OutArrName="$2"
  local InArrSize
  local i
  local j

  eval InArrSize='${#'"$InArrName"'[@]}'

  eval $OutArrName='()'
  for (( i=InArrSize, j=0; --i >= 0; j++ )); do
    eval $OutArrName[j]='${'"$InArrName"'[i]}'
  done
}

function RemoveArrayFromUArray()
{
  local IFS=$' \t\r\n' # workaround for the bug in the "[@]:i" expression under the bash version lower than 4.1

  local i
  local j
  local isFound
  local item1
  local item2
  eval declare "ArrayFromSize=\"\${#$1[@]}\""
  eval declare "UArrayToSize=\"\${#$2[@]}\""
  (( UArrayToSize )) || return
  for (( i=0; i<ArrayFromSize; i++ )); do
    eval "item1=\"\${$1[i]}\""
    isFound=0
    for (( j=0; j<UArrayToSize; j++ )); do
      eval "item2=\"\${$2[j]}\""
      if [[ "$item1" == "$item2" ]]; then
        isFound=1
        break
      fi
    done
    if (( isFound )); then
      # remove it from the array
      eval "$2=(\"\${$2[@]:0:j}\" \"\${$2[@]:j+1}\")"
      (( UArrayToSize-- ))
    fi

    (( UArrayToSize )) || break
  done
}

function RemoveItemFromUArray()
{
  local IFS=$' \t\r\n' # workaround for the bug in the "[@]:i" expression under the bash version lower than 4.1

  local i
  local item
  eval declare "UArraySize=\"\${#$1[@]}\""
  for (( i=0; i<UArraySize; i++ )); do
    eval "item=\"\${$1[i]}\""
    if [[ "$item" == "$2" ]]; then
      # remove it from the array
      eval "$1=(\"\${$1[@]:0:\$i}\" \"\${$1[@]:\$i+1}\")"
      return 0
    fi
  done

  return 1
}

function RemovePListFromArray()
{
  local ArrayName="$1"
  shift

  local IFS=$' \t\r\n' # workaround for the bug in the "[@]:i" expression under the bash version lower than 4.1
  local PListArr
  PListArr=("$@")

  local i
  local j
  local item
  eval declare "ArraySize=\"\${#$ArrayName[@]}\""
  local PListSize="${#PListArr}"
  for (( i=0; i<PListSize; i++ )); do
    for (( j=0; j<ArraySize; )); do
      eval "item=\"\${$ArrayName[j]}\""
      isFound=0
      case "$item" in
        ${PListArr[i]})
          # remove it from the array
          eval "$ArrayName=(\"\${$ArrayName[@]:0:\$j}\" \"\${$ArrayName[@]:\$j+1}\")"
          ;;
        *) (( i++ )) ;;
      esac
    done
  done

  return 1
}

function CleanPArgsFromArray()
{
  # drop return value
  RETURN_VALUE=0

  local ArrayName="$1"
  shift
  local PListArr
  PListArr=("$@")

  local IFS=$' \t'

  local i
  local j
  local item
  eval declare "ArraySize=\"\${#$ArrayName[@]}\""
  local PListSize="${#PListArr[@]}"
  for (( i=0; i<PListSize; i++ )); do
    for (( j=0; j<ArraySize; j++ )); do
      eval "item=\"\${$ArrayName[j]}\""
      if [[ -n "$item" ]]; then
        isFound=0
        case "$item" in
          ${PListArr[i]})
            # remove it from the array
            eval "$ArrayName[j]=''"
            (( RETURN_VALUE++ ))
            ;;
        esac
      fi
    done
  done

  return 1
}

function AppendItemToUArray()
{
  # drop return value
  RETURN_VALUE=-1

  local IFS=$' \t'

  local i
  local item
  eval declare "UArraySize=\"\${#$1[@]}\""

  for (( i=0; i<UArraySize; i++ )); do
    eval "item=\"\${$1[i]}\""
    if [[ "$item" == "$2" ]]; then
      RETURN_VALUE=$i
      return 1
    fi
  done

  eval "$1[UArraySize]=\"\$2\""

  RETURN_VALUE=$UArraySize

  return 0
}

function AssignItemToUArray()
{
  # drop return value
  RETURN_VALUE=-1

  local AssignPredicateFunc="$3"

  [[ -n "$AssignPredicateFunc" ]] || return 2

  local IFS=$' \t'

  local i
  local item
  eval declare "UArraySize=\"\${#$1[@]}\""

  for (( i=0; i<UArraySize; i++ )); do
    eval "item=\"\${$1[i]}\""
    if "$AssignPredicateFunc" $i "$item" "$2"; then
      RETURN_VALUE=$i
      return 1
    fi
  done

  eval "$1[UArraySize]=\"\$2\""

  RETURN_VALUE=$UArraySize

  return 0
}

function AppendListToArray()
{
  local IFS=$' \t'
  local ArrayFrom=($1)
  eval "$2=(\"\${$2[@]}\" \"\${ArrayFrom[@]}\")"
}

function AppendListToUArray()
{
  local IFS="${3:-$' \t'}"

  local i
  local j
  local isFound
  local item1
  local item2
  local ArrayFrom=($1)
  local ArrayFromSize="${#ArrayFrom[@]}"
  eval declare "UArrayToSize=\"\${#$2[@]}\""
  for (( i=0; i<ArrayFromSize; i++ )); do
    item1="${ArrayFrom[i]}"
    isFound=0
    for (( j=0; j<UArrayToSize; j++ )); do
      eval "item2=\"\${$2[j]}\""
      if [[ "$item1" == "$item2" ]]; then
        isFound=1
        break
      fi
    done
    if (( ! isFound )); then
      eval "$2[UArrayToSize]=\"\$item1\""
      (( UArrayToSize++ ))
    fi
  done
}

function AppendUListToUArray()
{
  local IFS="${3:-$' \t'}"

  local i
  local j
  local isFound
  local item1
  local item2
  local ArrayFrom=($1)
  local ArrayFromSize="${#ArrayFrom[@]}"
  eval declare "UArrayToSize=\"\${#$2[@]}\""
  (( UArrayToSize )) || { eval "$2=(\"\${ArrayFrom[@]}\")"; return; }
  for (( i=0; i<ArrayFromSize; i++ )); do
    item1="${ArrayFrom[i]}"
    isFound=0
    for (( j=0; j<UArrayToSize; j++ )); do
      eval "item2=\"\${$2[j]}\""
      if [[ "$item1" == "$item2" ]]; then
        isFound=1
        break
      fi
    done
    if (( ! isFound )); then
      eval "$2[UArrayToSize]=\"\$item1\""
      (( UArrayToSize++ ))
    fi
  done
}

function AppendArrayToUArray()
{
  local IFS="${3:-$' \t'}"

  local i
  local j
  local isFound
  local item1
  local item2
  eval declare "ArrayFromSize=\"\${#$1[@]}\""
  eval declare "UArrayToSize=\"\${#$2[@]}\""
  for (( i=0; i<ArrayFromSize; i++ )); do
    eval "item1=\"\${$1[i]}\""
    isFound=0
    for (( j=0; j<UArrayToSize; j++ )); do
      eval "item2=\"\${$2[j]}\""
      if [[ "$item1" == "$item2" ]]; then
        isFound=1
        break
      fi
    done
    if (( ! isFound )); then
      eval "$2[UArrayToSize]=\"\$item1\""
      (( UArrayToSize++ ))
    fi
  done
}

function AppendUArrayToUArray()
{
  local IFS=$' \t'

  local i
  local j
  local isFound
  local item1
  local item2
  eval declare "UArrayToSize=\"\${#$1[@]}\""
  eval declare "UArrayFromSize=\"\${#$2[@]}\""
  (( UArrayToSize )) || { eval "$1=(\"\${$2[@]}\")"; return; }

  for (( j=0; j<UArrayFromSize; j++ )); do
    eval "item2=\"\${$2[j]}\""
    isFound=0
    for (( i=0; i<UArrayToSize; i++ )); do
      eval "item1=\"\${$1[i]}\""
      if [[ "$item1" == "$item2" ]]; then
        isFound=1
        break
      fi
    done
    if (( ! isFound )); then
      eval "$1[UArrayToSize]=\"\$item2\""
      (( UArrayToSize++ ))
    fi
  done
}

function AssignUArrayToUArray()
{
  local FirstPredicateFunc="$3"
  local SecondPredicateFunc="$4"
  local AssignPredicateFunc="$5"

  [[ -n "$FirstPredicateFunc" ]] || return 1
  [[ -n "$SecondPredicateFunc" ]] || return 2
  [[ -n "$AssignPredicateFunc" ]] || return 3

  local IFS=$' \t'

  local i
  local j
  local isFound
  local item1
  local item2
  eval declare "UArrayToSize=\"\${#$1[@]}\""
  eval declare "UArrayFromSize=\"\${#$2[@]}\""

  for (( j=0; j<UArrayFromSize; j++ )); do
    eval "item2=\"\${$2[j]}\""
    if "$FirstPredicateFunc" "$1" "$2" $j "$item2"; then
      isFound=0
      for (( i=0; i<UArrayToSize; i++ )); do
        eval "item1=\"\${$1[i]}\""
        if "$SecondPredicateFunc" "$1" "$2" $i $j "$item1" "$item2"; then
          isFound=1
          break
        fi
      done
      if (( ! isFound )); then
        "$AssignPredicateFunc" "$1" "$2" $i $j "$item2"
        (( UArrayToSize += $? ))
      fi
    fi
  done

  return 0
}

function AppendArrayToArray()
{
  local IFS="${3:-$' \t'}"

  local i
  eval declare "ArrayFromSize=\"\${#$1[@]}\""
  eval declare "ArrayToSize=\"\${#$2[@]}\""
  (( ArrayToSize )) || { eval "$2=(\"\${$1[@]}\")"; return; }
  for (( i=0; i<ArrayFromSize; i++ )); do
    eval "$2[ArrayToSize]=\"\${$1[i]}\""
    (( ArrayToSize++ ))
  done
}

function GetTimeAsString()
{
  # drop return value
  RETURN_VALUE=""

  if (( $# < 1 || ! ${1:-0} )); then
    RETURN_VALUE="0${2:-"s"}"
    return
  fi

  local TimeSecsOverall="$1"

  local TimeSecs="$TimeSecsOverall"

  local TimeMins=0
  (( TimeMins = TimeSecs/60 ))
  (( TimeSecs %= 60 ))

  local TimeHours=0
  (( TimeHours = TimeMins/60 ))
  (( TimeMins %= 60 ))

  local TimeDays=0
  (( TimeDays = TimeHours/24 ))
  (( TimeHours %= 24 ))

  local TimeString=""

  if (( TimeDays )); then
    TimeString="$TimeString${TimeDays}${TimeDays:+" Days, "}"
  fi
  if (( TimeHours )); then
    TimeString="$TimeString${TimeHours}${TimeHours:+"h:"}"
  fi

  local TimeMinsStr="$TimeMins"
  local TimeSecsStr="$TimeSecs"
  if (( TimeMins > 0 )); then
    if [[ $TimeMins -le 9 ]]; then
      TimeMinsStr="0$TimeMins"
    fi
    if (( ${#TimeSecs} == 1 )); then
      TimeSecsStr="0$TimeSecs"
    fi
  fi

  if (( TimeMins )); then
    TimeString="$TimeString${TimeMinsStr}${TimeMins:+"m:"}"
  fi
  local TimeWord="second"
  if [[ $TimeSecsOverall > 1 ]]; then
    TimeWord="${TimeWord}s"
  fi

  TimeString="$TimeString${TimeSecsStr}${TimeSecs:+"s"} ($TimeSecsOverall $TimeWord)"

  RETURN_VALUE="$TimeString"
}

function AssocGet()
{
  # drop return value
  RETURN_VALUE=""

  local DefaultValue="$1"
  local ArrayName="$2"

  if [[ -z "${ArrayName}" ]]; then
    if [[ -n "${DefaultValue}" ]]; then
      RETURN_VALUE="${DefaultValue}"
    fi
    return 1
  fi

  eval declare "ArraySize=\${#$ArrayName[@]}"

  local Array
  Array=()
  local i=0
  while (( i < ArraySize )); do
    eval Array[i]=\${$ArrayName[i]}
    (( i++ ))
  done

  if [[ -z "${Array[@]}" || "${#Array[@]}" -eq 0 ]]; then
    if [[ -n "${DefaultValue}" ]]; then
      RETURN_VALUE="${DefaultValue}"
    fi
    return 2
  fi

  local Key="$3"

  if [[ -z "$Key" ]]; then
    if [[ -n "${DefaultValue}" ]]; then
      RETURN_VALUE="${DefaultValue}"
    fi
    return 3
  fi

  i=0
  while (( i < ${#Array[@]} )); do
    if [[ "${Array[i]}" == "$Key" ]]; then
      if [[ -n "${Array[i+1]}" ]]; then
        RETURN_VALUE="${Array[i+1]}"
      fi
      return 0
    fi
    (( i += 2 ))
  done

  if [[ -n "${DefaultValue}" ]]; then
    RETURN_VALUE="${DefaultValue}"
  fi

  return 4
}

function FindArrayItem()
{
  local ArrayName="$1"
  local Item="$2"

  # drop return value
  RETURN_VALUE="-1"

  local ArraySize
  eval ArraySize='${#'"$ArrayName"'[@]}'

  local Item2
  local i
  for (( i=0; i < ArraySize; i++ )); do
    eval Item2='${'"$ArrayName"'[i]}'
    if [[ "$Item" == "$Item2" ]]; then
      RETURN_VALUE="$i"
      return 0
    fi
  done

  return 1
}

function byteToChar()
{
  local octal
  printf -v octal %03o $1
  printf -v RETURN_VALUE \\$octal
}

function charToSByte()
{
  printf -v RETURN_VALUE %d "'$1"
  # workaround for "printf" positive values
  (( RETURN_VALUE >= 128 )) && (( RETURN_VALUE -= 256 ))
}

function charToUByte()
{
  printf -v RETURN_VALUE %d "'$1"
  # workaround for "printf" negative values
  (( RETURN_VALUE < 0 )) && (( RETURN_VALUE += 256 ))
}

function decToHex()
{
  local value=$1
  local width=${2:-0}

  local hexChars=(0 1 2 3 4 5 6 7 8 9 a b c d e f)
  local hex
  local type=0

  # workaround for "printf %x" negative values under the bash 3.1.0
  if (( value < 0 )); then
    if (( value < 0x80000000 )); then
      type=2 # handle of negative numbers wider than 32-bit long
    else
      type=1 # handle of negative 32-bit numbers
    fi
  elif (( value > 0xffffffff )); then # handle of positive 64-bit numbers
    if (( value > 0x7fffffffffffffff )); then
      type=2
    fi
  elif (( value > 0x7fffffff )); then # handle of positive 32-bit numbers
    type=1
  fi

  if (( type == 0 )); then
    printf -v hex %x $value
  elif (( type == 1 )); then
    (( hex=value-0x7FFFFFFF-1 ))
    printf -v hex %08x $hex
    hex="${hexChars[${hex:0:1}+8]}${hex:1}"
  else
    (( hex=value-0x7FFFFFFFFFFFFFFF-1 ))
    printf -v hex %08x $hex
    hex="${hexChars[${hex:0:1}+8]}${hex:1}"
  fi

  RETURN_VALUE="${hex:-0}"

  (( width )) && ZeroPadding $width $RETURN_VALUE

  return 0
}

function ZeroPadding()
{
  local width="${1:-0}"
  local value="$2"
  local zeros="${3:-0000000000000000}"

  # workaround for the bash 3.1.0 bug for the expression "${arg:X:Y}",
  # where "Y == 0" or "Y + X >= ${#arg}"
  if (( width > ${#value} )); then
    RETURN_VALUE="${zeros:0:width-${#value}}$value"
    return 0
  fi

  RETURN_VALUE="$value"
  return 0
}

function ZeroPaddingArray()
{
  # drop return values
  RETURN_VALUES=()

  local zeros="${1:-0000000000000000}"
  shift

  while (( ${#@} )); do
    ZeroPadding "$1" "$2" "$zeros"
    RETURN_VALUES[${#RETURN_VALUES[@]}]="$RETURN_VALUE"
    shift 2
  done
}

# WARNING:
#   For the bash version 3.x this function only emulates the bash subshell
#   process id via the global BASH_SUBSHELL_PIDS array generated with an usage
#   of builtin variables BASH_SUBSHELL and RANDOM.
function GetShellPID()
{
  local ParentNestIndex="${1:-0}" # 0 - self pid

  # always use the global array
  (( ! ${#BASH_SUBSHELL_PIDS[@]} )) && BASH_SUBSHELL_PIDS=()

  if (( ${BASH_VERSINFO[0]:-0} >= 4 )); then
    BASH_SUBSHELL_PIDS[BASH_SUBSHELL]=$BASHPID
  else
    # this logic is not guarantee the real process id value, it's guarantee it's
    # uniqueness
    if (( ! ${#BASH_SUBSHELL_PIDS[BASH_SUBSHELL]} )); then
      # allocate shell PID as random value which are not in the list
      local ShellPID
      local pid
      local IsUnique=0

      while (( ! IsUnique )); do
        let ShellPID=$RANDOM+$RANDOM
        IsUnique=1
        for pid in "${BASH_SUBSHELL_PIDS[@]}"; do
          if (( pid == ShellPID )); then
            IsUnique=0
            break
          fi
        done
      done

      BASH_SUBSHELL_PIDS[BASH_SUBSHELL]=$ShellPID
    fi
  fi

  # use BASH_SUBSHELL instead of array size because the array can has holes
  if (( ParentNestIndex >= 0 && BASH_SUBSHELL >= ParentNestIndex )); then
    RETURN_VALUE=${BASH_SUBSHELL_PIDS[BASH_SUBSHELL-ParentNestIndex]}
    return 0
  fi

  # drop return value
  RETURN_VALUE=""

  return 1
}

function SafeFuncCall()
{
  local IFS=$' \t\r\n' # workaround for the bug in the "[@]:i" expression under the bash version lower than 4.1
  # evaluation w/o extra local variables!
  declare -f "$1" >/dev/null
  if (( ! $? )); then
    eval "$1" \"\${@:2}\"
    return $?
  fi
  return 0
}

function SafeFuncCallWithPrefix()
{
  local IFS=$' \t\r\n' # workaround for the bug in the "[@]:i" expression under the bash version lower than 4.1
  # evaluation w/o extra local variables!
  declare -f "${@:2:1}" >/dev/null
  if (( ! $? )); then
    eval "$1" # prefix
    eval "${@:2:1}" \"\${@:3}\"
    return $?
  fi
  return 0
}

function SafeStringEval()
{
  # evaluation w/o extra local variables!
  # first argument - extra eval string
  if (( ${#@} )); then
    if (( ${#@} == 1 )); then
      if (( ${#1} )); then
        eval "$1"
        return $?
      else
        return 0
      fi
    elif (( ${#@} > 1 )); then
      shift
      # next arguments - only functions
      while (( 1 )); do
        if (( ${#@} == 1 )); then
          eval SafeFuncCall "$1"
          return $? # always return error code from last call
        elif (( ${#1} > 1 )); then
          eval SafeFuncCall "$1"
        fi
        shift
      done
    fi
  fi
  return 0
}

function SafeStringsEval()
{
  #echo "SafeStringsEval: ${FUNCNAME[@]}"
  # evaluation w/o extra local variables!
  if (( ${#@} )); then
    while (( 1 )); do
      if (( ${#@} == 1 )); then
        if (( ${#1} )); then
          eval "$1"
          return $? # always return error code from last call
        else
          return 0
        fi
      elif (( ${#1} > 1 )); then
        eval "$1"
      fi
      shift
    done
  fi
  return 0
}

function Unset()
{
  unset -v -- "$@"
}

function Wait()
{
  local i
  for (( i=0; i<$1; i++ )); do
    (echo "" >/dev/null)
  done
}

function SetLastError()
{
  return ${1:-$LastError}
}

unset SOURCE_CONTOOLS_BASELIB_SH # including guard unset

fi
