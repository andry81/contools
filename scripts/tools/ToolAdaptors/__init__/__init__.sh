#!/bin/bash

# Script can be ONLY included by "source" command.
[[ -n "$BASH" && (-z "$BASH_LINENO" || BASH_LINENO[0] -gt 0) && (-z "$CONTOOLS_PROJECT_ROOT_INIT0_DIR" || "$CONTOOLS_PROJECT_ROOT_INIT0_DIR" != "$CONTOOLS_PROJECT_ROOT") ]] || return 0 || exit 0 # exit to avoid continue if the return can not be called

tkl_include_or_abort "../../__init__/__init__.sh"
