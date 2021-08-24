#!/bin/bash

if [[ -f "$1" ]]; then
  if [[ -z "$3" || "${3#-*a}" == "$3" ]]; then
    if [[ -n "$CAT" ]]; then
      "$CAT" "$1" > "$2"
    else
      cat "$1" > "$2"
    fi
  else
    if [[ -n "$CAT" ]]; then
      "$CAT" "$1" >> "$2"
    else
      cat "$1" >> "$2"
    fi
  fi
  exit $?
fi

exit 254
