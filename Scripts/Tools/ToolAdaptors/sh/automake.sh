#!/bin/bash

if [[ -f "$1" ]]; then
  FileBasePath="${1%.*}"
  if [[ -n "$AUTOMAKE" ]]; then
    eval '"$AUTOMAKE"' $3 '"$FileBasePath"'
  else
    eval automake $3 '"$FileBasePath"'
  fi
  exit $?
fi

exit 254
