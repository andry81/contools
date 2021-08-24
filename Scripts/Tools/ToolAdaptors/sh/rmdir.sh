#!/bin/bash

if [[ -d "$2" ]]; then
  # load all libraries
  source "$CONTOOLS_ROOT/filelib.sh"

  if [[ -n "$RMDIR" ]]; then
    CleanupDir '' "$2" && eval '"$RMDIR"' $3 '"$2"'
  else
    CleanupDir '' "$2" && eval rmdir $3 '"$2"'
  fi
  exit $?
fi

exit 0
