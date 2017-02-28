#!/bin/bash_entry

# Author:   Andrey Dibrov (andry at inbox dot ru)

# Bash string library, supports common string functions.

# Script can be ONLY included by "source" command.
if [[ -n "$BASH" && (-z "$BASH_LINENO" || ${BASH_LINENO[0]} -gt 0) ]] && (( ! ${#SOURCE_CONTOOLS_STRINGLIB_SH} )); then

SOURCE_CONTOOLS_STRINGLIB_SH=1 # including guard

source "${TOOLS_PATH:-.}/baselib.sh"
source "${TOOLS_PATH:-.}/traplib.sh"

function FindChar()
{
  # drop return value
  RETURN_VALUE=""

  # (Required) String which would be searched.
  local String="$1"
  # (Required) Chars for search.
  local Chars="$2"

  if [[ -z "$String" ]]; then
    RETURN_VALUE="-1"
    return 1
  fi
  if [[ -z "$Chars" ]]; then
    RETURN_VALUE="-1"
    return 2
  fi

  local StringLen="${#String}"
  local CharsLen="${#Chars}"
  local i
  local j
  for (( i=0; i < StringLen; i++ )); do
    for (( j=0; j < CharsLen; j++ )); do
      if [[ "${String:$i:1}" == "${Chars:$j:1}" ]]; then
        RETURN_VALUE="$i"
        return 0
        break
      fi
    done
  done

  RETURN_VALUE="-1"

  return 3
}

function FindAnyChar()
{
  # drop return value
  RETURN_VALUE=""

  # (Required) String which would be searched.
  local String="$1"
  # (Required) Char for ignore.
  local Chars="$2"

  if [[ -z "$String" ]]; then
    RETURN_VALUE="-1"
    return 1
  fi
  if [[ -z "$Char" ]]; then
    RETURN_VALUE="-1"
    return 2
  fi

  # workaround for the bash 3.1.0 bug for the expression "${arg:X:Y}",
  # where "Y == 0" or "Y + X >= ${#arg}"
  local Char=""
  if (( ${#Chars} > 0 )); then
    Char="${Char:0:1}"
  fi

  local StringLen="${#String}"
  local i=0
  while (( i < StringLen )); do
    if [[ "${String:$i:1}" != "$Char" ]]; then
      RETURN_VALUE="$i"
      return 0
      break
    fi
    (( i++ ))
  done

  RETURN_VALUE="-1"

  return 3
}

function FindString()
{
  # drop return value
  RETURN_VALUE="-1"

  # (Required) String which would be searched.
  local String="$1"
  # (Required) Sub string which would be searched for.
  local Substring="$2"
  # (Optional) Options.
  local nocaseSearch=0
  if [[ "${3//i/}" != "$3" ]]; then
    nocaseSearch=1
  fi
  local usePerl=0
  if [[ "${3//p/}" != "$3" ]]; then
    usePerl=1
  fi

  [[ -n "$String" ]] || return 1
  if [[ -z "$Substring" ]]; then
    RETURN_VALUE="${#String}"
    return 2
  fi

  if (( ! usePerl )); then
    local StringLen="${#String}"
    local SubstringLen="${#Substring}"
    local StringIterLen=$StringLen-$SubstringLen+1
    local i=0
    while (( i < StringIterLen )); do
      if [[ "${String:$i:SubstringLen}" == "${Substring}" ]]; then
        RETURN_VALUE="$i"
        return 0
        break
      fi
      (( i++ ))
    done

    RETURN_VALUE="-1"
  else
    if (( ! nocaseSearch )); then
      RETURN_VALUE="`/bin/perl.exe -e 'print index($ARGV[0],$ARGV[1]);' "$String" "$Substring"`"
    else
      RETURN_VALUE="`/bin/perl.exe -e 'my $a=$ARGV[0]; my $b=$ARGV[1]; $a =~ /$b/i; print $-[0];' "$String" "$Substring"`"
    fi

    (( RETURN_VALUE >= 0 )) && return 0
  fi

  return 3
}

# WARNING: this implementation may be slow!
function CompareStrings()
{
  local Flags="$3"
  if [[ -n "$Flags" && "${Flags:0:1}" != '-' ]]; then
    Flags=''
  fi

  local oldShopt=""
  function LocalReturn()
  {
    if [[ -n "$oldShopt" ]]; then
      # Restore state
      eval $oldShopt
    fi
  }

  # override RETURN with other traps restore
  PushTrapFunctionMove "$DefaultTrapsStackName" LocalReturn RETURN || return 253

  oldShopt="$(shopt -p nocasematch)" # Read state before change it

  if [[ "${Flags//i/}" == "$Flags" ]]; then # case matching
    if [[ "$oldShopt" != "shopt -u nocasematch" ]]; then
      shopt -u nocasematch
    else
      oldShopt=""
    fi
  else # nocase matching
    if [[ "$oldShopt" != "shopt -s nocasematch" ]]; then
      shopt -s nocasematch
    else
      oldShopt=""
    fi
  fi

  [[ "$1" == "$2" ]] && return 0
  [[ "$1" < "$2" ]] && return 1
  return 255
}

# WARNING: this implementation is slow!
function ToLowerCase()
{
  # drop return value
  RETURN_VALUE=""

  local String="$1"
  local StringLen="${#String}"
  local ch

  local oldShopt=""
  function LocalReturn()
  {
    if [[ -n "$oldShopt" ]]; then
      # Restore state
      eval $oldShopt
    fi
  }

  # override RETURN with other traps restore
  PushTrapFunctionMove "$DefaultTrapsStackName" LocalReturn RETURN || return 253

  oldShopt="$(shopt -p nocasematch)" # Read state before change it

  if [[ "$oldShopt" != "shopt -u nocasematch" ]]; then # case matching
    shopt -u nocasematch
  else
    oldShopt=""
  fi

  local i
  local j
  for (( i=0; i<StringLen; i++ )); do
    ch="${String:$i:1}"
    case "$ch" in
      [A-Z])
        printf -v j %d "'$ch"
        j="$((j+32))"
        RETURN_VALUE="$RETURN_VALUE$(printf "\\$(printf %o $j)")"
        ;;

      *)
        RETURN_VALUE="$RETURN_VALUE$ch"
        ;;
    esac
  done
}

function EscapeString()
{
  # drop return value
  RETURN_VALUE=""

  # (Required) String which would be escaped.
  local String="$1"
  # (Optional) Set of characters in string which are gonna be escaped.
  local EscapeChars="$2"
  # (Optional) Type of escaping:
  #   0 - String will be quoted by the " character, so escape any character from
  #       "EscapeChars" by the \ character.
  #   1 - String will be quoted by the ' character, so the ' character should be
  #       escaped by the \' sequance. The "EscapeChars" variable doesn't used in this case.
  #   2 - String will be used in the cmd.exe shell, so quote any character from
  #       the "EscapeChars" variable by the ^ character.
  local EscapeType="${3:-0}"

  if [[ -z "$String" ]]; then
    RETURN_VALUE="$String"
    return 1
  fi

  if [[ -z "$EscapeChars" ]]; then
    case $EscapeType in
      0) EscapeChars='$!&|\`"' ;;
      2) EscapeChars='^?*&|<>()"' ;;
    esac
  fi

  local EscapedString=""
  local StringCharEscapeOffset=-1
  local i
  for (( i=0; i<${#String}; i++ )); do
    local StringChar="${String:$i:1}"
    case $EscapeType in
      0)
        FindChar "$EscapeChars" "$StringChar"
        StringCharEscapeOffset="$RETURN_VALUE"
        if (( StringCharEscapeOffset < 0 )); then
          EscapedString="$EscapedString$StringChar"
        else
          EscapedString="$EscapedString\\$StringChar"
        fi
      ;;
      1)
        if [[ "$StringChar" != "'" ]]; then
          EscapedString="$EscapedString$StringChar"
        else
          EscapedString="$EscapedString'\\''"
        fi
      ;;
      *)
        FindChar "$EscapeChars" "$StringChar"
        StringCharEscapeOffset="$RETURN_VALUE"
        if (( StringCharEscapeOffset >= 0 )); then
          EscapedString="$EscapedString^"
        fi
        EscapedString="$EscapedString$StringChar"
      ;;
    esac
  done

  [[ -n "$EscapedString" ]] || return 2

  RETURN_VALUE="$EscapedString"

  return 0
}

function MakeCommandLine()
{
  local IFS=$' \t\r\n' # workaround for the bug in the "[@]:i" expression under the bash version lower than 4.1
  MakeCommandLineEx "$1" "$2" '' '' "${@:3}"
}

function MakeCommandLineEx()
{
  # drop return value
  RETURN_VALUE=""

  # (Required) Set of characters in string which are gonna be escaped.
  local EscapeChars="$1"
  # (Required) Type of escaping:
  #   0 - Argument will be quoted by " character, so escape any character from
  #       "EscapeChars" by the \ character.
  #   1 - Arguments will be quoted by the ' character, so the ' character shall
  #       be escaped by \' sequance. The "EscapeChars" variable doesn't used in this case.
  #   2 - Argument will be quoted by the " character and used in the cmd.exe shell,
  #       so escape any character from the "EscapeChars" variable by the ^ character and escape
  #       result by the \ character to put it in a ""-quoted string.
  local EscapeType="$2"
  # (Optional) Predicate functions:
  #   Calls before/after each argument being processed.
  local PredicatePrefixFunc="$3"
  local PredicateSuffixFunc="$4"
  local EscapeFlags="${EscapeType#*:}"

  if (( ${#EscapeType} == ${#EscapeFlags} )); then
    EscapeFlags=""
  else
    EscapeType="${EscapeType%%:*}"
  fi

  [[ -z "$EscapeType" ]] && EscapeType=0

  shift 4

  local IFS=$' \t\n'

  local Args
  Args=("$@")

  local CommandLine=""
  local AlwaysQuoting=1

  [[ "${EscapeFlags//a/}" != "$EscapeFlags" ]] && AlwaysQuoting=0

  local arg
  local i=0

  case "$EscapeType" in
    0)
      for arg in "${Args[@]}"; do
        [[ -n "$PredicatePrefixFunc" ]] && "$PredicatePrefixFunc" CommandLine $i "$arg"
        EscapeString "$arg" "$EscapeChars" 0
        if (( AlwaysQuoting )) || [[ "${RETURN_VALUE//[ $'\t\r\n']/}" != "$RETURN_VALUE" ]]; then
          # we must quote white space characters in an argument to avoid argument splitting
          CommandLine="$CommandLine${CommandLine:+" "}\"$RETURN_VALUE\""
        else
          CommandLine="$CommandLine${CommandLine:+" "}$RETURN_VALUE"
        fi
        [[ -n "$PredicateSuffixFunc" ]] && "$PredicateSuffixFunc" CommandLine $i "$arg"
        (( i++ ))
      done
      ;;

    1)
      for arg in "${Args[@]}"; do
        [[ -n "$PredicatePrefixFunc" ]] && "$PredicatePrefixFunc" CommandLine $i "$arg"
        EscapeString "$arg" "$EscapeChars" 1
        if (( AlwaysQuoting )) || [[ "${RETURN_VALUE//[ $'\t\r\n']/}" != "$RETURN_VALUE" ]]; then
          # we must quote white space characters in an argument to avoid argument splitting
          CommandLine="$CommandLine${CommandLine:+" "}'$RETURN_VALUE'"
        else
          CommandLine="$CommandLine${CommandLine:+" "}$RETURN_VALUE"
        fi
        [[ -n "$PredicateSuffixFunc" ]] && "$PredicateSuffixFunc" CommandLine $i "$arg"
        (( i++ ))
      done
      ;;

    2)
      for arg in "${Args[@]}"; do
        [[ -n "$PredicatePrefixFunc" ]] && "$PredicatePrefixFunc" CommandLine $i "$arg"
        EscapeString "$arg" "$EscapeChars" 2
        EscapeString "$RETURN_VALUE" '' 0
        if (( AlwaysQuoting )) || [[ "${RETURN_VALUE//[ $'\t\r\n']/}" != "$RETURN_VALUE" ]]; then
          CommandLine="$CommandLine${CommandLine:+" "}\"$RETURN_VALUE\""
        else
          CommandLine="$CommandLine${CommandLine:+" "}$RETURN_VALUE"
        fi
        [[ -n "$PredicateSuffixFunc" ]] && "$PredicateSuffixFunc" CommandLine $i "$arg"
        (( i++ ))
      done
      ;;
  esac

  RETURN_VALUE="$CommandLine"

  return 0
}

function PrintSpreadSheet()
{
  local ColumnFlagsArrName="$1"
  local HeaderNamesArrName
  local BodyValuesArrName

  if [[ -n "$ColumnFlagsArrName" && "${ColumnFlagsArrName:0:1}" != '-' ]]; then
    ColumnFlagsArrName=''
    HeaderNamesArrName="$1"
    BodyValuesArrName="$2"
  else
    ColumnFlagsArrName="${ColumnFlagsArrName#-}"
    HeaderNamesArrName="$2"
    BodyValuesArrName="$3"
  fi

  eval local "HeaderNamesArrSize=\${#$HeaderNamesArrName[@]}"
  eval local "BodyValuesArrSize=\${#$BodyValuesArrName[@]}"

  local i
  local j

  local Padding40='                                        '
  local PrintListHeaderParams_Local

  local value
  local itemSize
  local localOffset

  local PrintListHAlignLeft_Local

  local PrintListColumnFlags_Local
  local PrintListHeaderName_Local
  local PrintListBodyValue_Local
  PrintListHeaderParams_Local=()

  # fill header parameters
  for (( i=0; i<HeaderNamesArrSize; i++ )); do
    PrintListHeaderParams_Local[i*2+0]="" # header aligner
    eval "PrintListHeaderName_Local=\"\${$HeaderNamesArrName[i]}\""
    if (( i > 0 )); then
      (( PrintListHeaderParams_Local[i*2+1]=${#PrintListHeaderName_Local}+2 )) # value max len
    else
      (( PrintListHeaderParams_Local[i*2+1]=${#PrintListHeaderName_Local}+3 )) # value max len
    fi
  done

  eval itemSize=\${$BodyValuesArrName[0]}
  for (( i=1; i<BodyValuesArrSize; i+=itemSize )); do
    for (( j=0; j<itemSize; j++ )); do
      (( localOffset=j*2+1 ))
      eval "value=\"\${$BodyValuesArrName[i+j]}\""
      (( ${#value} > PrintListHeaderParams_Local[localOffset] )) && PrintListHeaderParams_Local[localOffset]=${#value}
    done
  done

  # recalculate header aligners
  for (( i=0; i<HeaderNamesArrSize; i++ )); do
    (( localOffset=i*2 ))
    eval "PrintListHeaderName_Local=\"\${$HeaderNamesArrName[i]}\""
    if (( i > 0 )); then
      (( PrintListHeaderParams_Local[localOffset+1] > ${#PrintListHeaderName_Local}+2 )) && PrintListHeaderParams_Local[localOffset+0]="${Padding40:0:PrintListHeaderParams_Local[localOffset+1]-${#PrintListHeaderName_Local}-2}"
    else
      (( PrintListHeaderParams_Local[localOffset+1] > ${#PrintListHeaderName_Local}+3 )) && PrintListHeaderParams_Local[localOffset+0]="${Padding40:0:PrintListHeaderParams_Local[localOffset+1]-${#PrintListHeaderName_Local}-3}"
    fi
  done

  local ListHeaderStr
  local ListBodyStr
  local ListBodyAligner

  # construct header
  PrintListColumnFlags_Local=''
  (( ${#ColumnFlagsArrName} )) && eval "PrintListColumnFlags_Local=\"\${$ColumnFlagsArrName[0]}\""
  PrintListHAlignLeft_Local=0
  echo ColumnFlagsArrName=$ColumnFlagsArrName
  [[ "${PrintListColumnFlags_Local//HAlign=L/}" != "$PrintListColumnFlags_Local" ]] && PrintListHAlignLeft_Local=1
  eval "PrintListHeaderName_Local=\"\${$HeaderNamesArrName[0]}\""
  if (( PrintListHAlignLeft_Local )); then
    ListHeaderStr="# $PrintListHeaderName_Local${PrintListHeaderParams_Local[0*2+0]}"
  else
    ListHeaderStr="# ${PrintListHeaderParams_Local[0*2+0]}$PrintListHeaderName_Local"
  fi
  for (( i=1; i<HeaderNamesArrSize; i++ )); do
    PrintListColumnFlags_Local=''
    (( ${#ColumnFlagsArrName} )) && eval "PrintListColumnFlags_Local=\"\${$ColumnFlagsArrName[i]}\""
    PrintListHAlignLeft_Local=0
    [[ "${PrintListColumnFlags_Local//HAlign=L/}" != "$PrintListColumnFlags_Local" ]] && PrintListHAlignLeft_Local=1
    eval "PrintListHeaderName_Local=\"\${$HeaderNamesArrName[i]}\""
    if (( PrintListHAlignLeft_Local )); then
      ListHeaderStr="$ListHeaderStr | $PrintListHeaderName_Local${PrintListHeaderParams_Local[i*2+0]}"
    else
      ListHeaderStr="$ListHeaderStr | ${PrintListHeaderParams_Local[i*2+0]}$PrintListHeaderName_Local"
    fi
  done

  echo "$ListHeaderStr"

  for (( i=1; i<BodyValuesArrSize; i+=itemSize )); do
    # construct body
    PrintListColumnFlags_Local=''
    (( ${#ColumnFlagsArrName} )) && eval "PrintListColumnFlags_Local=\"\${$ColumnFlagsArrName[0]}\""
    PrintListHAlignLeft_Local=0
    [[ "${PrintListColumnFlags_Local//HAlign=L/}" != "$PrintListColumnFlags_Local" ]] && PrintListHAlignLeft_Local=1
    eval "PrintListBodyValue_Local=\"\${$BodyValuesArrName[i+0]}\""
    ListBodyAligner=''
    (( ${#PrintListBodyValue_Local} < PrintListHeaderParams_Local[0*2+1] )) && ListBodyAligner="${Padding40:0:PrintListHeaderParams_Local[0*2+1]-${#PrintListBodyValue_Local}}"
    if (( PrintListHAlignLeft_Local )); then
      ListBodyStr="$PrintListBodyValue_Local$ListBodyAligner"
    else
      ListBodyStr="$ListBodyAligner$PrintListBodyValue_Local"
    fi
    for (( j=1; j<itemSize; j++ )); do
      PrintListColumnFlags_Local=''
      (( ${#ColumnFlagsArrName} )) && eval "PrintListColumnFlags_Local=\"\${$ColumnFlagsArrName[j]}\""
      PrintListHAlignLeft_Local=0
      [[ "${PrintListColumnFlags_Local//HAlign=L/}" != "$PrintListColumnFlags_Local" ]] && PrintListHAlignLeft_Local=1
      eval "PrintListBodyValue_Local=\"\${$BodyValuesArrName[i+j]}\""
      ListBodyAligner=''
      (( ${#PrintListBodyValue_Local} < PrintListHeaderParams_Local[j*2+1] )) && ListBodyAligner="${Padding40:0:PrintListHeaderParams_Local[j*2+1]-${#PrintListBodyValue_Local}}"
      if (( PrintListHAlignLeft_Local )); then
        ListBodyStr="$ListBodyStr $PrintListBodyValue_Local$ListBodyAligner"
      else
        ListBodyStr="$ListBodyStr $ListBodyAligner$PrintListBodyValue_Local"
      fi
    done
    echo "$ListBodyStr"
  done
  (( BodyValuesArrSize <= 1 )) && echo "None"
}

unset SOURCE_CONTOOLS_STRINGLIB_SH # including guard unset

fi
