#!/bin/bash_entry

# Author:   Andrey Dibrov (andry at inbox dot ru)

# Set of bash functions to work with perl. Cygwin/Msys/Mingw system required.

# Script can be ONLY included by "source" command.
if [[ -n "$BASH" && (-z "$BASH_LINENO" || BASH_LINENO[0] -gt 0) ]]; then 

source '/bin/bash_entry' || exit $?
tkl_include '__init__.sh' || tkl_abort_include
tkl_include "$CONTOOLS_ROOT/bash/stringlib.sh" || tkl_abort_include

# Function gets perl module list file path.
function GetPerlModuleListFilePath()
{
  # Drop return value
  RETURN_VALUE=""

  local PerlModuleListFilePathPrefix="/lib/perl${PerlCurVerArr[0]}/${PerlCurVerArr[0]}.${PerlCurVerArr[1]}"
  local PerlModuleListFileName="perllocal.pod"
  local PerlModuleListFilePath="`find "$PerlModuleListFilePathPrefix" -iname "$PerlModuleListFileName" | tail --lines=1`"

  [[ -n "$PerlModuleListFilePath" ]] || return 1

  RETURN_VALUE="$PerlModuleListFilePath"

  return 0
}

# Function cleans perl module installation info
# (this is not uninstall procedure).
function CleanInstallPerlModule()
{
  local PerlModuleListFilePath="$1"
  local PerlModuleName="$2"

  [[ -n "$PerlModuleListFilePath" && -f "$PerlModuleListFilePath" ]] || return 1
  [[ -n "$PerlModuleName" ]] || return 2

  # Escape for regular expression.
  EscapeString "$PerlModuleName" "\\\$^?*+|."
  local PerlModuleEscapedName="$RETURN_VALUE"

  local MatchPattern=\
'=head2[ \t]+[^:]+:[^:]+:[^:]+:[ \t]*C<Module>[ \t]+'\
'L<'"$PerlModuleEscapedName"'\|'"$PerlModuleEscapedName"'>'\
'[ \t]*(\r?\n).*?'\
'=back\1?\1?'

  local SearchPattern1=\
'(.*?)=head2[ \t]+[^:]+:[^:]+:[^:]+:[ \t]*C<Module>[ \t]+'\
'L<'"$PerlModuleEscapedName"'\|'"$PerlModuleEscapedName"'>'\
'[ \t]*(\r?\n).*?'\
'=back\2?\2?(.*)'

  local ReplacePattern1=\
'"$1$3"'

  # Read file in variable.
  local PerlModuleListFileText="`<"$PerlModuleListFilePath"`"
  if [[ -z "$PerlModuleListFileText" ]]; then
    # Nothing to be done.
    return 0
  fi

  echo "$PerlModuleListFileText" |\
    /bin/perl.exe "$CONTOOLS_ROOT/sar.pl" m "$MatchPattern" '' ms >/dev/null
  if [[ $? -ne 0 ]]; then
    return 128
  fi

  echo "$PerlModuleListFileText" |\
    /bin/perl.exe "$CONTOOLS_ROOT/sar.pl" s "$SearchPattern1" "$ReplacePattern1" mse > "$PerlModuleListFilePath"
  if [[ $? -ne 0 ]]; then
    return 3
  fi

  # Update variable.
  PerlModuleListFileText="`<"$PerlModuleListFilePath"`"

  # Remove repeated section if file not empty.
  while [[ -n "$PerlModuleListFileText" ]]; do
    echo "$PerlModuleListFileText" |\
      /bin/perl.exe "$CONTOOLS_ROOT/sar.pl" m "$MatchPattern" '' ms >/dev/null
    if [[ $? -ne 0 ]]; then
      # No more repeated section.
      break
    fi

    echo "$PerlModuleListFileText" |\
      /bin/perl.exe "$CONTOOLS_ROOT/sar.pl" s "$SearchPattern1" "$ReplacePattern1" mse > "$PerlModuleListFilePath"
    if [[ $? -ne 0 ]]; then
      return 4
    fi

    # Update variable.
    PerlModuleListFileText="`<"$PerlModuleListFilePath"`"
  done

  return 0
}

fi
