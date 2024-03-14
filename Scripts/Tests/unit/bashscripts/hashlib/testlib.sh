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
  # don't write generated strings on drive and load after, store them in memory
  export STORE_IN_MEMORY=0
  # 0 - by usage of native array
  # 1 - by usage of a hash map (much more faster).
  export CHECK_HASH_COLLISIONS_TYPE=1
  export STR_NUM=5000
  export STR_LENGTH_MAX=256
  export STR_LENGTH_MIN=1
  export CH_CODE_MIN=32
  export CH_CODE_MAX=127

  TEST_SOURCES=("$CONTOOLS_ROOT/bash/hashlib.sh")
  TEST_FUNCTIONS=(GenerateStrings GenerateHashes GenerateHashMap ReadHashMap CheckHashCollisions)
}

function TestUserInit()
{
  NumCollisions=0

  if (( ! STORE_IN_MEMORY )); then
    # store in file system
    StringsFilePath="/tmp/$TestScriptParentDirName/${TestScriptBaseFileName}_${TestSessionId}.txt"
    StringHashesFilePath="/tmp/$TestScriptParentDirName/${TestScriptBaseFileName}_${TestSessionId}_out.txt"
  else
    # store in bash arrays in memory
    STRINGS=()
    HASHES=()
  fi
  StringHashCollisionsFilePath="/tmp/$TestScriptParentDirName/${TestScriptBaseFileName}_${TestSessionId}_collisions.txt"
}

function TestUserModuleExit() { :; }

function TestUserExit()
{
  if (( ! STORE_IN_MEMORY )); then
    # close all pipes
    exec 7>&-
    exec 8>&-
  fi
  exec 9>&-

  # remove output files only if test is passed!
  if (( ! NumCollisions )); then
    if (( ! STORE_IN_MEMORY )); then
      rm -f "$StringsFilePath"
      rm -f "$StringHashesFilePath"
    fi
    rm -f "$StringHashCollisionsFilePath"
  else
    if (( ! STORE_IN_MEMORY )); then
      mv -v "$StringsFilePath" "$TestScriptOutputsDirPath"
      mv -v "$StringHashesFilePath" "$TestScriptOutputsDirPath"
    fi
    mv -v "$StringHashCollisionsFilePath" "$TestScriptOutputsDirPath"
    echo
  fi
}

function GenerateStrings()
{
  function GenerateStrings_PipeErrorHandler()
  {
    return 255
  }

  trap "GenerateStrings_PipeErrorHandler" SIGPIPE # return on read/write error

  if (( ! STORE_IN_MEMORY )); then
    function GenerateStrings_LocalReturnHandler()
    {
      exec 7>&-
    }

    trap "GenerateStrings_LocalReturnHandler; $(trap -p RETURN)" RETURN

    exec 7> "$StringsFilePath"
    (( $? )) && return 1
  fi

  local String
  local CharsArr
  local StringLen
  local charCode
  local maxLen
  local strSuffix
  local i
  local j

  local IFS=''

  for (( i=0; i<STR_NUM; i++ )); do
    ## Msys bash 3.1.x has weak ctrl-c handling, this improves it a bit
    #if (( !(i%10) && (BASH_VERSINFO[0] < 3 || BASH_VERSINFO[0] == 3 && BASH_VERSINFO[1] <= 1) )); then
    #  Wait 1
    #fi

    CharsArr=()
    # generate random strings set with reduced character codes
    let StringLen="STR_LENGTH_MIN + (STR_LENGTH_MAX - STR_LENGTH_MIN) * $RANDOM / 32767"
    for (( j=0; j<StringLen; j++ )); do
      # range: CH_CODE_MIN - CH_CODE_MAX
      let charCode="CH_CODE_MIN + (CH_CODE_MAX - CH_CODE_MIN) * $RANDOM / 32767"
      tkl_byte_to_char $charCode
      CharsArr[j]="$RETURN_VALUE"
    done
    String="${CharsArr[*]:0:StringLen}" # faster than just append to the end of string
    if (( STORE_IN_MEMORY )); then
      STRINGS[$i]="$String"
      #SetHashMapItem RandomStrings $i "$String"
    else
      echo "$String" 1>&7
    fi
    if (( 16 >= StringLen )); then
      maxLen=$StringLen
      strSuffix=''
    else
      maxLen=16
      strSuffix='...'
    fi
    (( !(i%1000) )) && echo "$i: ${String:0:maxLen}$strSuffix"
  done

  return 0 # test has no internal errors
}

# testing HashStringGnuCrc32/HashStringBsdCrc32 speed on random string from 1 to 32 characters length
function GenerateHashes()
{
  local HashPredFunc="${1:-HashStringGnuCrc32}"

  function GenerateHashes_PipeErrorHandler()
  {
    return 255
  }

  trap "GenerateHashes_PipeErrorHandler" SIGPIPE # return on read/write error

  function GenerateHashes_LocalReturnHandler()
  {
    if (( ! STORE_IN_MEMORY )); then
      exec 7>&-
      exec 8>&-
    fi
  }

  trap "GenerateHashes_LocalReturnHandler; $(trap -p RETURN)" RETURN

  local index=0
  if (( ! STORE_IN_MEMORY )); then
    exec 7< "$StringsFilePath"
    (( $? )) && return 1
    exec 8> "$StringHashesFilePath"
    (( $? )) && return 2

    local line
    local hash
    while read -u 7 -r line; do
      ## Msys bash 3.1.x has weak ctrl-c handling, this improves it a bit
      #if (( !(i%10) && (BASH_VERSINFO[0] < 3 || BASH_VERSINFO[0] == 3 && BASH_VERSINFO[1] <= 1) )); then
      #  Wait 1
      #fi

      eval $HashPredFunc '"$line"'
      tkl_dec_to_hex "$RETURN_VALUE"
      tkl_zero_padding 8 "$RETURN_VALUE"
      echo "$RETURN_VALUE" 1>&8
      (( !(index%1000) )) && echo "$index: $RETURN_VALUE"
      (( index++ ))
    done
  else
    for (( i=0; i<STR_NUM; i++ )); do
      eval $HashPredFunc '"$STRINGS[$i]"'
      tkl_dec_to_hex "$RETURN_VALUE"
      tkl_zero_padding 8 "$RETURN_VALUE"
      HASHES[$i]="$RETURN_VALUE"
      (( !(index%1000) )) && echo "$index: $RETURN_VALUE"
      (( index++ ))
    done
  fi

  return 0 # test has no internal errors
}

# testing SetHashMapItem speed on sequenced key collection
function GenerateHashMap()
{
  local i
  for (( i=0; i<10000; i++ )); do
    SetHashMapItem "$1" $(( i*2 + 10 )) $i
    (( !(i%1000) )) && echo "$(( i*2 + 10 )): $i"
  done

  return 0 # test has no internal errors
}

# testing GetHashMapItem speed on sequenced key collection
function ReadHashMap()
{
  local i
  for (( i=0; i<10000; i++ )); do
    GetHashMapItem "$1" $(( i*2 + 10 ))
    (( !(i%1000) )) && echo "$(( i*2 + 10 )): $RETURN_VALUE"
  done

  tkl_set_last_error 0

  return 0 # test has no internal errors
}

# testing on hash collisions of previously generated string set
function CheckHashCollisions()
{
  function CheckHashCollisions_PipeErrorHandler()
  {
    return 255
  }

  trap "CheckHashCollisions_PipeErrorHandler" SIGPIPE # return on read/write error

  local oldShopt
  function CheckHashCollisions_LocalReturnHandler()
  {
    if (( ${#oldShopt} )); then
      eval $oldShopt
    fi

    if (( ! STORE_IN_MEMORY )); then
      exec 7>&-
      exec 8>&-
    fi
    exec 9>&-
  }

  trap "CheckHashCollisions_LocalReturnHandler; $(trap -p RETURN)" RETURN

  # enable nocase match for a file paths
  oldShopt="$(shopt -p nocasematch)"
  if [[ "$oldShopt" != "shopt -s nocasematch" ]]; then
    shopt -s nocasematch
  else
    oldShopt=''
  fi

  echo "Reading strings..."

  local IFS
  local i
  local j
  local maxLen
  local strLen
  local strSuffix
  local value
  local valueList
  local hashes
  local strings

  hashes=()
  strings=()

  if (( ! STORE_IN_MEMORY )); then
    exec 7< "$StringsFilePath"
    (( $? )) && return 1
    exec 8< "$StringHashesFilePath"
    (( $? )) && return 2
  fi
  exec 9> "$StringHashCollisionsFilePath"
  (( $? )) && return 3

  if (( ! STORE_IN_MEMORY )); then
    # read strings in the array
    i=0
    while read -u 7 -r value; do
      strings[i]="$value"
      strLen=${#value}
      if (( 16 >= strLen )); then
        maxLen=$strLen
        strSuffix=''
      else
        maxLen=16
        strSuffix='...'
      fi
      (( !(i%1000) )) && echo "$i: ${value:0:maxLen}$strSuffix"
      (( i++ ))
    done

    exec 7>&-
  else
    strings=("${STRINGS[@]}")
  fi
  echo

  echo "Reading hashes..."
  # read hashes in the array
  if (( ! STORE_IN_MEMORY )); then
    i=0
    while read -u 8 -r value; do
      if (( CHECK_HASH_COLLISIONS_TYPE==0 )); then
        hashes[i]="$value" # all hashes
      elif (( CHECK_HASH_COLLISIONS_TYPE==1 )); then
        GetHashMapItem HashesMap 0x$value
        if (( $? )); then
          hashes[i]="$value" # unique hashes
          valueList="$i"
          SetHashMapItem HashesMap 0x$value "$i"
        else
          hashes[i]='' # empty if not unique already
          valueList="$RETURN_VALUE $i" # as a string
          SetHashMapItem HashesMap 0x$value "$valueList"
        fi
      fi
      (( !(i%1000) )) && echo "$i: $value"
      (( i++ ))
      (( i > STR_NUM )) && break
    done

    exec 8>&-
  else
    if (( CHECK_HASH_COLLISIONS_TYPE==0 )); then
      hashes=("${HASHES[@]}")
    elif (( CHECK_HASH_COLLISIONS_TYPE==1 )); then
      for (( i=0; i<STR_NUM; i++ )); do
        value=${HASHES[i]}
        GetHashMapItem HashesMap 0x$value
        if (( $? )); then
          hashes[i]="$value" # unique hashes
          valueList="$i"
          SetHashMapItem HashesMap 0x$value "$i"
        else
          hashes[i]='' # empty if not unique already
          valueList="$RETURN_VALUE $i" # as a string
          SetHashMapItem HashesMap 0x$value "$valueList"
        fi
      done
    fi
  fi
  echo

  local string
  local stringIndex
  local hash
  local hashHex
  local hashHex2
  local lenHex
  local collisionStrings
  local collisionStringIndexes
  local colIndex

  IFS=$' \t' # to split by white spaces

  local k=0

  echo "Checking on hash collisions..."

  local hashesLen=${#hashes[@]}
  for (( i=0; i<hashesLen; i++ )); do
    collisionStrings=()
    collisionStringIndexes=()
    colIndex=0
    hash=${hashes[i]}
    if (( ${#hash} )); then
      hashHex="0x$hash"
      if (( CHECK_HASH_COLLISIONS_TYPE == 0 )); then
        (( !(i%1000) )) && echo "$i: $hash"
        for (( j=i+1; j<hashesLen; j++ )); do
          if (( ${#hashes[j]} )); then
            hashHex2="0x${hashes[j]}"
            #echo "$i: $j: $hashHex2"
            if (( hashHex == hashHex2 )) && [[ "${strings[i]}" != "${strings[j]}" ]]; then
              if (( ! colIndex )); then
                collisionStrings[colIndex]="${strings[i]}"
                collisionStringIndexes[colIndex]=$((i+1))
                (( colIndex++ ))
              fi
              collisionStrings[colIndex]="${strings[j]}"
              collisionStringIndexes[colIndex]=$((j+1))
              (( colIndex++ ))
              hashes[j]="" # drop hash as checked
            fi
          fi
        done
      elif (( CHECK_HASH_COLLISIONS_TYPE == 1 )); then
        GetHashMapItem HashesMap $hashHex
        valueList="$RETURN_VALUE"
        (( !(i%1000) )) && echo "$i: $hash"
        for j in $valueList; do
          if (( i != j )) && [[ "${strings[i]}" != "${strings[j]}" ]]; then
            if (( ! colIndex )); then
              collisionStrings[colIndex]="${strings[i]}"
              collisionStringIndexes[colIndex]=$((i+1))
              (( colIndex++ ))
            fi
            collisionStrings[colIndex]="${strings[j]}"
            collisionStringIndexes[colIndex]=$((j+1))
            (( colIndex++ ))
          fi
        done
      fi
    fi
    # check string hash collisions
    if (( colIndex )); then
      (( NumCollisions++ ))
      for (( j=0; j<colIndex; j++ )); do
        string="${collisionStrings[j]}"
        tkl_dec_to_hex "${#string}"
        lenHex="$RETURN_VALUE"
        stringIndex=${collisionStringIndexes[j]}
        tkl_zero_padding_from_args '' 3 "$NumCollisions" 8 "$hash" 6 "$stringIndex" 4 "$lenHex"
        value="${RETURN_VALUES[0]}: ${RETURN_VALUES[1]} ${RETURN_VALUES[2]}: ${RETURN_VALUES[3]} $string"
        echo "$value" 1>&9
        strLen=${#string}
        if (( 16 >= strLen )); then
          maxLen=$strLen
          strSuffix=''
        else
          maxLen=16
          strSuffix='...'
        fi
        value="      ${RETURN_VALUES[0]}: ${RETURN_VALUES[1]} ${RETURN_VALUES[2]}: ${RETURN_VALUES[3]} ${string:0:maxLen}$strSuffix"
        echo "$value" # duplicate output to the stdout
      done
    fi
  done
  if (( ! NumCollisions )); then
    tkl_set_last_error 0
  else
    tkl_set_last_error 1
  fi
  echo
  echo "Overall collisions: $NumCollisions"

  return 0 # test has no internal errors
}
