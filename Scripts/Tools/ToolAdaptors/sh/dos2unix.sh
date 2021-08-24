#!/bin/bash

if [[ -f "$2" ]]; then
  if [[ -n "$DOS2UNIX" ]]; then
    eval '"$DOS2UNIX"' $3 '"$2"' '2>/dev/null'
  else
    eval dos2unix $3 '"$2"' '2>/dev/null'
  fi
  exit $?
fi

exit 254
