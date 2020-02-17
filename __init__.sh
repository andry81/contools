#!/bin/bash

# Script can be ONLY included by "source" command.
if [[ -n "$BASH" && (-z "$BASH_LINENO" || ${BASH_LINENO[0]} -gt 0) ]] && (( ! ${#__BASE_INIT__} )); then 

__BASE_INIT__=1 # including guard

source "/bin/bash_entry" || exit $?

[[ -z "$NEST_LVL" ]] && NEST_LVL=0

CONFIGURE_ROOT="$BASH_SOURCE_DIR"

LOCAL_CONFIG_DIR_NAME=_config

CONTOOLS_ROOT="$CONFIGURE_ROOT/_tools"
UTILITY_ROOT="$CONTOOLS_ROOT"

fi
