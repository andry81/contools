#!/bin/bash

# Another variant of a configuration file variables read and set script.
# The script must stay as simple as possible, so for this task it uses these parameters:
# 1. path where to lock a lock file
# 2. path where to read a file with variable names (each per line)
# 3. path where to read a file with variable values (each per line, must be the same quantity of lines with the variable names file)

# Script can be ONLY included by "source" command.
[[ -n "$BASH" && (-z "$BASH_LINENO" || BASH_LINENO[0] -gt 0) ]] || return 0 || exit 0 # exit to avoid continue if the return can not be called

function set_vars_from_locked_file_pair()
{
  # the lock file directory must already exist
  if [[ ! -d "${1%[/\\]*}" ]]; then
    echo "$0: error: lock file directory does not exist: \`${1%[/\\]*}\`" >&2
    return 1
  fi

  if [[ ! -f "${2//\\//}" ]]; then
    echo "$0: error: variable names file does not exist: \`$2\`" >&2
    return 2
  fi

  if [[ ! -f "${3//\\//}" ]]; then
    echo "$0: error: variable values file does not exist: \`$3\`" >&2
    return 3
  fi

  function LocalMain()
  {
    # open file for direct reading by the `read` in the same shell process
    exec 7< "$2"
    exec 8< "$3"

    # cleanup on return
    #
    # CAUTION:
    #   `trap - RETURN` is required here, otherwise the return trap would be called again in a parent scope function,
    #   in case if there was no trap command!
    #
    trap "rm -f \"$1\" 2> /dev/null; exec 8>&-; exec 7>&-; trap - RETURN" RETURN

    local __VarName
    local __VarValue

    # shared acquire of the lock file
    while :; do
      # lock via redirection to file
      {
        flock -s 9

        # simultaneous iteration over 2 lists in the same time
        while read -r -u 7 __VarName; do
          read -r -u 8 __VarValue
          # drop line returns
          __VarName="${__VarName//[$'\r\n']}"
          __VarValue="${__VarValue//[$'\r\n']}"
          # instead of `declare -gx` because `-g` is introduced only in `bash-4.2-alpha`
          export $__VarName="$__VarValue"
          (( ${4:-0} )) && echo "$__VarName=\`$__VarValue\`"
        done

        break

        # return with previous code
      } 9> "$1" 2> /dev/null # has exclusive lock been acquired?

      # busy wait
      sleep 0.02
    done
  }

  LocalMain "${1//\\//}" "${2//\\//}" "${3//\\//}" "${4:-0}"
}
