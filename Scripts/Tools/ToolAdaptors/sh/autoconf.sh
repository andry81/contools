#!/bin/bash

if [[ -f "$1" ]]; then
  if [[ -n "$AUTOCONF" ]]; then
    eval '"$AUTOCONF"' $3 '"--output=$2"' '"$1"'
  else
    eval autoconf $3 '"--output=$2"' '"$1"'
  fi
  exit $?
fi

exit 254
