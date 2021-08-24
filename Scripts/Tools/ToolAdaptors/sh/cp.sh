#!/bin/bash

if [[ -f "$1" ]]; then
  if [[ -n "$CP" ]]; then
    eval '"$CP"' $3 '"$1"' '"$2"'
  else
    eval cp $3 '"$1"' '"$2"'
  fi
  exit $?
fi

exit 254
