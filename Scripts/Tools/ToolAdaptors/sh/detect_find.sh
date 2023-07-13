#!/bin/bash

SHELL_FIND=find

# detect `find.exe` in Windows behind `%SYSTEMROOT%\System32\find.exe`
if which where >/dev/null 2>&1; then
  for path in `where find 2>/dev/null`; do
    case "$path" in
      "$SYSTEMROOT"\\*) ;;
      "$WINDIR"\\*) ;;
      *)
        SHELL_FIND="$path"
        break
        ;;
    esac
  done
fi
