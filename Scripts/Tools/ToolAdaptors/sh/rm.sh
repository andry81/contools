#!/bin/bash

if [[ -f "$2" ]]; then
  if [[ -n "$RM" ]]; then
    eval '"$RM"' $3 '"$2"'
  else
    eval rm $3 '"$2"'
  fi
  exit $?
fi

exit 0
