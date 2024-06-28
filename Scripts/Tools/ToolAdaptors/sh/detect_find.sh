#!/bin/bash

SHELL_FIND=find

# NOTE:
#   The `${path,,}` or `${path^^}` form has issues:
#     1. Does not handle a unicode string case conversion correctly (unicode characters translation in words).
#     2. Supported in Bash 4+.

# detect `find.exe` in Windows behind `$SYSTEMROOT\System32\find.exe`
if which where >/dev/null 2>&1; then
  local old_shopt="$(shopt -p nocasematch)" # read state before change
  if [[ "$old_shopt" != 'shopt -s nocasematch' ]]; then
    shopt -s nocasematch
  else
    old_shopt=''
  fi

  IFS=$'\r\n'; for path in `where find 2>/dev/null`; do # IFS - with trim trailing line feeds
    case "$path" in # with case insensitive comparison
      "$SYSTEMROOT"\\*) ;;
      "$WINDIR"\\*) ;;
      *)
        SHELL_FIND="$path"
        break
        ;;
    esac
  done

  if [[ -n "$old_shopt" ]]; then
    eval $old_shopt
  fi
fi
