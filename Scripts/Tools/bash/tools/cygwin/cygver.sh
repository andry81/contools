#!/bin/bash

# Author:   Andrey Dibrov (andry at inbox dot ru)

# Bash script which reads version of cygwin package and prints it.
# Parse version number in to 4 or 5 numbers:
#   <MajorVersion>.<MinorVersion>.<PatchNumber>.<Revision1>[.<Revision2>]
# Version conversion examples:
#   - 1.7.5-1         ->  1.7.5.1
#   - 2.1-1           ->  2.1.0.1
#   - 1.4p6-10        ->  1.4.6.10
#   - 00885-1         ->  885.0.0.1
#   - 1.3.30c-10      ->  1.3.30c.10
#   - 20050522-1      ->  20050522.0.0.1
#   - 5.7_20091114-14 ->  5.7.20091114.14
#   - 4.5.20.2-2      ->  4.5.20.2.2
#   - 2009k-1         ->  2009k.0.0.1

# Command arguments:
# $1 - Package name.
# $2 - Path to cygwin installation main directory.

# Examples:
# 1. cygver.sh cygwin
# 2. source "cygver.sh"
#    CygwinVer cygwin

if [[ -n "$BASH" ]]; then

function CygwinVer()
{
  # Drop return value
  RETURN_VALUE=""

  [[ -n "$1" ]] || return 65
  [[ -x "/bin/cygcheck.exe" ]] || return 67

  local VerStr="`/bin/cygcheck.exe -c "$1" | /bin/grep.exe -i -P -e "^$1  *[0-9][0-9]*."`"

  [[ -n "$VerStr" ]] || return 1

  local MajorVer=""
  local MinorVer=""
  local PatchVer=""
  local RevVer=""
  local RevVer2=""

  local IFS=$' \t'
  local j=0
  for i in $VerStr; do
    if [[ j -eq 1 ]]; then
      if [[ -n "$i" ]]; then
        VerStr="$i"
      fi
      break
    fi
    (( j++ ))
  done

  IFS='-'
  j=0
  for i in $VerStr; do
    if [[ j -ne 0 ]]; then
      if [[ -n "$i" ]]; then
        RevVer2="$RevVer2${RevVer2:+.}$i"
      fi
    else
      if [[ -n "$i" ]]; then
        MajorVer="$i"
      fi
    fi
    (( j++ ))
  done

  IFS='.'
  j=0
  for i in $MajorVer; do
    if [[ j -ne 0 ]]; then
      if [[ -n "$i" ]]; then
        MinorVer="$MinorVer${MinorVer:+.}$i"
      fi
    else
      if [[ -n "$i" ]]; then
        MajorVer="$i"
      fi
    fi
    (( j++ ))
  done

  j=0
  for i in $MinorVer; do
    if [[ j -ne 0 ]]; then
      if [[ -n "$i" ]]; then
        PatchVer="$PatchVer${PatchVer:+.}$i"
      fi
    else
      if [[ -n "$i" ]]; then
        MinorVer="$i"
      fi
    fi
    (( j++ ))
  done

  IFS='p'
  j=0
  for i in $MinorVer; do
    if [[ j -ne 0 ]]; then
      if [[ -n "$i" ]]; then
        PatchVer="$PatchVer${PatchVer:+.}$i"
      fi
    else
      if [[ -n "$i" ]]; then
        MinorVer="$i"
      fi
    fi
    (( j++ ))
  done

  IFS='_'
  j=0
  for i in $MinorVer; do
    if [[ j -ne 0 ]]; then
      if [[ -n "$i" ]]; then
        PatchVer="$PatchVer${PatchVer:+.}$i"
      fi
    else
      if [[ -n "$i" ]]; then
        MinorVer="$i"
      fi
    fi
    (( j++ ))
  done

  IFS='.'
  j=0
  for i in $PatchVer; do
    if [[ j -ne 0 ]]; then
      if [[ -n "$i" ]]; then
        RevVer="$RevVer${RevVer:+.}$i"
      fi
    else
      if [[ -n "$i" ]]; then
        PatchVer="$i"
      fi
    fi
    (( j++ ))
  done

  if [[ -z "$RevVer" ]]; then
    if [[ -n "$RevVer2" ]]; then
      RevVer="$RevVer2"
      RevVer2=""
    fi
  fi

  RETURN_VALUE="${MajorVer:-0}.${MinorVer:-0}.${PatchVer:-0}.${RevVer:-0}${RevVer2:+.}$RevVer2"

  return 0
}

if [[ -z "$BASH_LINENO" || ${BASH_LINENO[0]} -eq 0 ]]; then
  # Script was not included, then execute it.
  CygwinVer "$@"
  LastError=$?
  [[ -z "$RETURN_VALUE" ]] || echo -n "$RETURN_VALUE"
  exit $LastError
fi

fi
