#!/bin/bash

if [[ -f "$1" ]]; then
  if [[ -n "$AUTOGEN" ]]; then
    eval '"$AUTOGEN"' $3 '"$1"'
  else
    eval autogen $3 '"$1"'
  fi
  exit $?
fi

exit 254
