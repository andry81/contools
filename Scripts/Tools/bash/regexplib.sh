#!/bin/bash

# Author:   Andrey Dibrov (andry at inbox dot ru)

# Regular expression library, implements main functions to automate regular expressions.

# Script can be ONLY included by "source" command.
[[ -n "$BASH" && (-z "$BASH_LINENO" || BASH_LINENO[0] -gt 0) && (-z "$SOURCE_CONTOOLS_REGEXPLIB_SH" || SOURCE_CONTOOLS_REGEXPLIB_SH -eq 0) ]] || return 0 || exit 0 # exit to avoid continue if the return can not be called

SOURCE_CONTOOLS_REGEXPLIB_SH=1 # including guard

function MatchString()
{
  local Flags="$1"
  local SearchString="$2"
  local SearchPattern="$3"

  # for the slow emulation case we have a chance to boost up overall performance by removing usage of the "$&" builtin perl variable
  local DoUseFullMatchVariable=0 # by default we don't use it
  [[ "${Flags//f/}" != "$Flags" ]] && DoUseFullMatchVariable=1

  local LastError=0

  if (( BASH_VERSINFO[0] > 3 || BASH_VERSINFO[0] == 3 && BASH_VERSINFO[1] >= 2 )); then
    eval [[ \"\$SearchString\" =~ "$SearchPattern" ]]
    LastError=$?
  else
    # slow emulation, have no choice
    BASH_REMATCH=()
    local ArrayStr
    if (( ! DoUseFullMatchVariable )); then
      ArrayStr="$(echo -n "$SearchString" | /bin/perl.exe "$CONTOOLS_ROOT/sar.pl" m "$SearchPattern" 'print("'\'''\''"); for(my $i=1; $i<@sys::numVars; $i++) { my $str2=""; eval("\$str2=\$$i;"); $str2 =~ '"s/'/'\\\\''/g"'; print(" '\''$str2'\''"); } 0;' mx)"
    else
      ArrayStr="$(echo -n "$SearchString" | /bin/perl.exe "$CONTOOLS_ROOT/sar.pl" m "$SearchPattern" 'my @str=$&; print("'\'''\''"); for(my $i=1; $i<@sys::numVars; $i++) { my $str2=""; eval("\$str2=\$$i;"); $str2 =~ '"s/'/'\\\\''/g"'; print(" '\''$str2'\''"); } $str=$&; $str =~ '"s/'/'\\\\''/g"'; print(" '\''$str'\''"); 0;' mx)"
    fi
    LastError=$?
    eval "BASH_REMATCH=($ArrayStr)"
    if (( DoUseFullMatchVariable && ${#BASH_REMATCH[@]} > 1 )); then
      BASH_REMATCH[0]="${BASH_REMATCH[${#BASH_REMATCH[@]}-1]}"
      unset BASH_REMATCH[${#BASH_REMATCH[@]}-1]
    fi
  fi

  return $LastError
}
