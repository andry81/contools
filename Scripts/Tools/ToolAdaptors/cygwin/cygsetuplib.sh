#!/bin/bash

# Author:   Andrey Dibrov (andry at inbox dot ru)

# Script library to support operations with the cygwin setup.ini file.

# Script can be ONLY included by "source" command.
if [[ -n "$BASH" && (-z "$BASH_LINENO" || ${BASH_LINENO[0]} -gt 0) ]]; then

if [[ -z "$SOURCE_TACKLELIB_BASH_TACKLELIB_SH" || SOURCE_TACKLELIB_BASH_TACKLELIB_SH -eq 0 ]]; then
  # builtin search
  for BASH_SOURCE_DIR in "/usr/local/bin" "/usr/bin" "/bin"; do
    [[ -f "$BASH_SOURCE_DIR/bash_tacklelib" ]] && {
      source "$BASH_SOURCE_DIR/bash_tacklelib" || exit $?
      break
    }
  done
fi

tkl_include_or_abort 'baselib.sh'
tkl_include_or_abort 'traplib.sh'

function CygSetupIniPackageSectionIterator()
{
  local FoundPackagePredicate="$1"
  local SetupIniFilePath="$2"
  local PackagesToSearchArrayName="$3"
  local PackagesToNextSearchArrayName="$4"
  local FoundPackagesArrayName="$5"
  local NotFoundPackagesArrayName="$6"
  local IterationIndex="${7:-0}"

  eval local "PackagesToSearchArraySize=\"\${#$PackagesToSearchArrayName[@]}\""
  (( PackagesToSearchArraySize )) || return

  local IFS
  local DoRead=1
  local ReadError
  local stdinLine=""
  local WasReadAtLeastOneSection=0
  local mayIgnoreUntilNextPackage=0
  local packageSection=""
  local allPackages=0
  eval "[[ \"\${$PackagesToSearchArrayName[0]}\" == '*' ]]" && allPackages=1

  {
    while (( DoRead )); do
      # Enables read whole string line into a single variable.
      IFS=""
      read -r stdinLine
      local ReadError=$?

      # check line of package line
      case "$stdinLine" in
        @\ [._a-zA-Z0-9-]*)
          packageSection='[]'
          WasReadAtLeastOneSection=1
          if (( ! PackagesToSearchArraySize )); then
            # read of the last package section is complete, no need to continue reading
            DoRead=0
            break
          fi

          # find package in the search list and remove it
          if (( ! allPackages )) && ! eval RemoveItemFromUArray "'$PackagesToSearchArrayName'" "'${stdinLine:2}'"; then
            # the list hadn't the package
            mayIgnoreUntilNextPackage=1
          else
            [[ -z "$FoundPackagePredicate" ]] || "$FoundPackagePredicate" '' '@' "${stdinLine:2}"
            if (( ! allPackages )); then
              (( PackagesToSearchArraySize-- ))
              if [[ -n "$FoundPackagesArrayName" ]]; then
                eval AppendItemToUArray "'$FoundPackagesArrayName'" "\"\${stdinLine:2}\""
              fi
              mayIgnoreUntilNextPackage=0
            fi
          fi
          ;;

        *)
          if (( WasReadAtLeastOneSection && ! mayIgnoreUntilNextPackage )); then
            case "$stdinLine" in
              #'sdesc: "'*)
              #  [[ -z "$FoundPackagePredicate" ]] || "$FoundPackagePredicate" "$packageSection" 'sdesc:' "${stdinLine:7}"
              #  ;;
              #'ldesc: "'*)
              #  [[ -z "$FoundPackagePredicate" ]] || "$FoundPackagePredicate" "$packageSection" 'ldesc:' "${stdinLine:7}"
              #  ;;
              'category: '[^\"]*)
                [[ -z "$FoundPackagePredicate" ]] || "$FoundPackagePredicate" "$packageSection" 'category:' "${stdinLine:10}"
                ;;
              'requires: '[^\"]*)
                [[ -z "$FoundPackagePredicate" ]] || "$FoundPackagePredicate" "$packageSection" 'requires:' "${stdinLine:10}";
                if (( ! allPackages )) && [[ -n "$PackagesToNextSearchArrayName" ]]; then
                  eval AppendListToUArray '"${stdinLine:10}"' "'$PackagesToNextSearchArrayName'"
                fi
                ;;
              'version: '[^\"]*)
                [[ -z "$FoundPackagePredicate" ]] || "$FoundPackagePredicate" "$packageSection" 'version:' "${stdinLine:9}"
                ;;
              '['*']')
                packageSection="${stdinLine:-'[]'}"
                [[ -z "$FoundPackagePredicate" ]] || "$FoundPackagePredicate" "$packageSection" '' ''
                ;;
              'install: '[^\"]*)
                [[ -z "$FoundPackagePredicate" ]] || "$FoundPackagePredicate" "$packageSection" 'install:' "${stdinLine:9}"
                ;;
              'source: '[^\"]*)
                [[ -z "$FoundPackagePredicate" ]] || "$FoundPackagePredicate" "$packageSection" 'source:' "${stdinLine:8}"
                ;;
            esac
          fi
          ;;
      esac

      (( DoRead )) || break

      if (( ! ReadError )); then
        if (( ! mayIgnoreUntilNextPackage && (! IterationIndex || WasReadAtLeastOneSection) )); then
          echo -n "$stdinLine"$'\n'
        fi
      else
        if (( ! mayIgnoreUntilNextPackage && (! IterationIndex || WasReadAtLeastOneSection) )); then
          echo -n "$stdinLine"
        fi
        DoRead=0
      fi
    done
  } < "$SetupIniFilePath"

  if (( ! allPackages )); then
    if [[ -n "$FoundPackagesArrayName" && -n "$PackagesToNextSearchArrayName" ]]; then
      eval RemoveArrayFromUArray "'$FoundPackagesArrayName'" "'$PackagesToNextSearchArrayName'"
    fi
    if [[ -n "$NotFoundPackagesArrayName" ]]; then
      eval AppendArrayToUArray "'$PackagesToSearchArrayName'" "'$NotFoundPackagesArrayName'"
    fi
  fi
  eval "$PackagesToSearchArrayName=()"
}

function ExtractPackagesFromCygSetupIni()
{
  # drop return value
  RETURN_VALUE=()

  local FoundPackagePredicate="$1"
  local IterationEndPredicate="$2"
  local SetupIniFilePath="$3"
  [[ -f "$SetupIniFilePath" ]] || return 1

  shift 3

  local IFS=" \t"

  local PackagesToNextSearchArray
  PackagesToNextSearchArray=("$@")
  local PackagesToNextSearchArraySize="${#PackagesToNextSearchArray[@]}"
  (( PackagesToNextSearchArraySize )) || return 2 # nothing to extract

  local IterationIndex=0
  local PackagesToSearchArray
  local FoundPackagesArray
  local NotFoundPackagesArray
  PackagesToSearchArray=()
  FoundPackagesArray=()
  NotFoundPackagesArray=()

  while (( PackagesToNextSearchArraySize )); do
    AppendArrayToUArray 'PackagesToNextSearchArray' 'PackagesToSearchArray'
    PackagesToNextSearchArray=()

    CygSetupIniPackageSectionIterator "$FoundPackagePredicate" "$SetupIniFilePath" \
      'PackagesToSearchArray' 'PackagesToNextSearchArray' \
      'FoundPackagesArray' 'NotFoundPackagesArray' "$IterationIndex"
    [[ -z "$IterationEndPredicate" ]] || "$IterationEndPredicate" \
      "$IterationIndex" 'PackagesToSearchArray' 'PackagesToNextSearchArray' \
      'FoundPackagesArray' 'NotFoundPackagesArray'
    (( IterationIndex++ ))

    PackagesToNextSearchArraySize="${#PackagesToNextSearchArray[@]}"
  done

  IFS=" \t"

  RETURN_VALUE=("${NotFoundPackagesArray[@]}")

  return 0
}

function PrintPackageFieldFromCygSetupIni()
{
  local SetupIniFilePath="$1"
  [[ -f "$SetupIniFilePath" ]] || return 1
  local PackageSection="$2"
  local PackageField="$3"
  [[ -n "$PackageField" ]] || return 2

  shift 3

  local IFS=$' \t'

  local PackagesToSearchArrayForPrint
  PackagesToSearchArrayForPrint=("$@")
  (( ${#PackagesToSearchArrayForPrint[@]} )) || return 3 # nothing to extract

  # enable nocase match
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

  oldShopt="$(shopt -p nocasematch)" # Read state before change
  if [[ "$oldShopt" != "shopt -s nocasematch" ]]; then
    shopt -s nocasematch
  else
    oldShopt=''
  fi

  local PackagesToSearchArrayForPrint
  PackagesToSearchArrayForPrint=()

  function FoundPackageFunc1()
  {
    local localArray
    localArray=()
    case "$1" in
      "[$PackageSection]")
        case "$2" in
          "$PackageField:")
            IFS=$' \t'
            localArray=($3)
            AppendListToArray "${#localArray[@]} $3" 'PackagesToSearchArrayForPrint'
            ;;
        esac
        ;;
    esac
  }

  if [[ -e /dev/fd/3 ]]; then
    ExtractPackagesFromCygSetupIni 'FoundPackageFunc1' '' "$SetupIniFilePath" "$@" >&3
  else
    ExtractPackagesFromCygSetupIni 'FoundPackageFunc1' '' "$SetupIniFilePath" "$@" >/dev/null
  fi

  IFS=$' \t\r\n' # workaround for the bug in the "[@]:i" expression under the bash version lower than 4.1
  local i
  local numItems=0
  for ((i=0; i<${#PackagesToSearchArrayForPrint[@]}; i+=numItems+1)); do
    numItems="${PackagesToSearchArrayForPrint[$i]}"
    echo "${PackagesToSearchArrayForPrint[@]:$i+1:$numItems}"
  done

  return 0
}

function CalculateCygSetupIniPackagesDiff()
{
  local FromSetupIniFilePath="$1"
  local ToSetupIniFilePath="$2"
  local DiffSetupIniFilePath="$3"

  [[ -f "$FromSetupIniFilePath" ]] || return 1
  [[ -f "$ToSetupIniFilePath" ]] || return 2
  (( ${#@} >= 4 )) || return 3

  shift 3

  # enable nocase match
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

  oldShopt="$(shopt -p nocasematch)" # Read state before change
  if [[ "$oldShopt" != "shopt -s nocasematch" ]]; then
    shopt -s nocasematch
  else
    oldShopt=''
  fi

  local FoundPackagesArray1
  local FoundPackagesArray2
  local FromSetupIniFileIterations1=0
  local ToSetupIniFileIterations2=0
  FoundPackagesArray1=()
  FoundPackagesArray2=()

  function FoundPackageFunc1()
  {
    case "$1" in
      '')
        case "$2" in
          '@') FoundPackagesArray1[${#FoundPackagesArray1[@]}]="$3" ;;
        esac
        ;;
    esac
  }

  function FoundPackageFunc2()
  {
    case "$1" in
      '')
        case "$2" in
          '@') FoundPackagesArray2[${#FoundPackagesArray2[@]}]="$3" ;;
        esac
        ;;
    esac
  }

  function IterationEndFunc1()
  {
    (( FromSetupIniFileIterations1++ ))
  }

  function IterationEndFunc2()
  {
    (( FromSetupIniFileIterations2++ ))
  }

  local IFS=$' \t'
  local StageBeginTime
  local StageEndTime
  local StageSpentTime

  # calculate first package tree
  echo "Processing \"$FromSetupIniFilePath\"..."
  StageBeginTime="$(date "+%s")"
  if [[ -e /dev/fd/3 ]]; then
    ExtractPackagesFromCygSetupIni 'FoundPackageFunc1' 'IterationEndFunc1' "$FromSetupIniFilePath" "$@" >&3
  else
    ExtractPackagesFromCygSetupIni 'FoundPackageFunc1' 'IterationEndFunc1' "$FromSetupIniFilePath" "$@" >/dev/null
  fi
  StageEndTime="$(date "+%s")"
  (( StageSpentTime=StageEndTime-StageBeginTime ))
  echo "$FromSetupIniFilePath:
        Found : ${FoundPackagesArray1[@]:-*epmty*}
    Not Found : ${RETURN_VALUE[@]:-*epmty*}
  File Passes : ${FromSetupIniFileIterations1}
   Time Spent : ${StageSpentTime} sec"

  # calculate second package tree
  echo "Processing \"$ToSetupIniFilePath\"..."
  StageBeginTime="$(date "+%s")"
  IFS=$' \t'
  if [[ -e /dev/fd/4 ]]; then
    ExtractPackagesFromCygSetupIni 'FoundPackageFunc2' 'IterationEndFunc2' "$ToSetupIniFilePath" "${FoundPackagesArray1[@]}" >&4
  else
    ExtractPackagesFromCygSetupIni 'FoundPackageFunc2' 'IterationEndFunc2' "$ToSetupIniFilePath" "${FoundPackagesArray1[@]}" >/dev/null
  fi
  StageEndTime="$(date "+%s")"
  (( StageSpentTime=StageEndTime-StageBeginTime ))
  echo "$ToSetupIniFilePath:
        Found : ${FoundPackagesArray2[@]:-*epmty*}
    Not Found : ${RETURN_VALUE[@]:-*epmty*}
  File Passes : ${FromSetupIniFileIterations2}
   Time Spent : ${StageSpentTime} sec"
  if [[ -n "$DiffSetupIniFilePath" ]]; then
    if (( ${#RETURN_VALUE[@]} )); then
      echo "Writing \"$DiffSetupIniFilePath\"..."
      IFS=$' \t'
      PrintPackagesFromCygSetupIni "$FromSetupIniFilePath" "${RETURN_VALUE[@]}" > "$DiffSetupIniFilePath"
    else
      echo "" > "$DiffSetupIniFilePath"
    fi
  fi

  return 0
}

fi
