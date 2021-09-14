#!/bin/bash

# Script can be ONLY included by "source" command.
[[ -z "$BASH" || (-n "$BASH_LINENO" && BASH_LINENO[0] -le 0) || (-n "$CONTOOLS_PROJECT_ROOT_INIT0_DIR" && -d "$CONTOOLS_PROJECT_ROOT_INIT0_DIR") ]] && return

tkl_include "../__init__/__init__.sh" "$@" || tkl_abort_include
