#!/bin/bash

if [[ -d "$2" ]]; then
  if [[ -n "$MKDIR" ]]; then
    eval '"$MKDIR"' $3 '"$2"'
  else
    eval mkdir $3 '"$2"'
  fi
  exit $?
fi

exit 0
