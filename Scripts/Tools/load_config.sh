#!/bin/bash

# Script ONLY for execution.
if [[ -n "$BASH" && (-z "$BASH_LINENO" || ${BASH_LINENO[0]} -eq 0) ]]; then 

source "/bin/bash_entry" || exit $?
tkl_include "__init__.sh" || exit $?

# function needs to make all support variables local including the IFS varaible
function load_config()
{
  local __CONFIG_DIR="$1"
  local __CONFIG_FILE="$2"

  if [[ -z "$__CONFIG_DIR" ]]; then
    echo "$0: error: config directory is not defined." >&2
    return 1
  fi

  # CAUTION:
  #   Space before the negative value is required!
  #
  [[ "${__CONFIG_DIR: -1}" == '\' ]] && __CONFIG_DIR="${__CONFIG_DIR::-1}"

  if [[ ! -e "$__CONFIG_DIR" ]]; then
    echo "$0: error: config directory does not exist: \`$__CONFIG_DIR\`" >&2
    return 2
  fi


  if [[ ! -e "$__CONFIG_DIR/$__CONFIG_FILE" && -e "$__CONFIG_DIR/$__CONFIG_FILE.in" ]]; then
    echo "\`$__CONFIG_DIR/$__CONFIG_FILE.in\` -> \`$__CONFIG_DIR/$__CONFIG_FILE\`"
    cat "$__CONFIG_DIR/$__CONFIG_FILE.in" > "$__CONFIG_DIR/$__CONFIG_FILE"
  fi

  # load configuration files
  if [[ ! -e "$__CONFIG_DIR/$__CONFIG_FILE" ]]; then
    echo "$0: error: config file is not found: \`$__CONFIG_DIR/$__CONFIG_FILE%\`." >&2
    return 3
  fi

  local IFS='=' # split by character
  local __VAR
  local __VALUE
  while read -r __VAR __VALUE; do
    [[ -z "$__VAR" ]] && continue
    [[ "$__VAR" =~ ^[[:space:]]*# ]] && continue # ignore prefix (not postfix) comments
    [[ -z "$__VALUE" ]] && { tkl_declare_global "$__VAR" ""; continue; }
    if [[ '"' == "${__VALUE:0:1}" ]]; then
      tkl_declare_global "$__VAR" "${__VALUE:1:-1}"
    else
      tkl_declare_global "$__VAR" "$__VALUE"
    fi
  done < "$__CONFIG_DIR/$__CONFIG_FILE"

  return $?
}

load_config "$@"

fi
