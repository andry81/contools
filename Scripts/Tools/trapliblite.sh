#!/bin/bash

# lightweight trap stack implementation

# Script can be ONLY included by "source" command.
if [[ -n "$BASH" && (-z "$BASH_LINENO" || ${BASH_LINENO[0]} -gt 0) ]] && (( ! ${#SOURCE_TRAPLIB_SH} )); then 

SOURCE_TRAPLIB_SH=1 # including guard

function GetTrapCmdLine()
{
  local IFS=$' \t\r\n'
  GetTrapCmdLineImpl RETURN_VALUES "$@"
}

function GetTrapCmdLineImpl()
{
  local out_var="$1"
  shift

  # drop return values
  eval "$out_var=()"

  local IFS
  local trap_sig
  local stack_var
  local stack_arr
  local trap_cmdline
  local trap_prev_cmdline
  local i

  i=0
  IFS=$' \t\r\n'; for trap_sig in "$@"; do
    stack_var="_traplib_stack_${trap_sig}_cmdline"
    declare -a "stack_arr=(\"\${$stack_var[@]}\")"
    if (( ${#stack_arr[@]} )); then
      for trap_cmdline in "${stack_arr[@]}"; do
        declare -a "trap_prev_cmdline=(\"\${$out_var[i]}\")"
        if [[ -n "$trap_prev_cmdline" ]]; then
          eval "$out_var[i]=\"\$trap_cmdline; \$trap_prev_cmdline\"" # the last stored is the first executed
        else
          eval "$out_var[i]=\"\$trap_cmdline\""
        fi
      done
    else
      # use the signal current trap command line
      declare -a "trap_cmdline=(`trap -p "$trap_sig"`)"
      eval "$out_var[i]=\"\${trap_cmdline[2]}\""
    fi
    (( i++ ))
  done
}

function PushTrap()
{
  # drop return values
  EXIT_CODES=()
  RETURN_VALUES=()

  local cmdline="$1"
  [[ -z "$cmdline" ]] && return 0 # nothing to push
  shift

  local IFS

  local trap_sig
  local stack_var
  local stack_arr
  local trap_cmdline_size
  local prev_cmdline

  IFS=$' \t\r\n'; for trap_sig in "$@"; do
    stack_var="_traplib_stack_${trap_sig}_cmdline"
    declare -a "stack_arr=(\"\${$stack_var[@]}\")"
    trap_cmdline_size=${#stack_arr[@]}
    if (( trap_cmdline_size )); then
      # append to the end is equal to push trap onto stack
      eval "$stack_var[trap_cmdline_size]=\"\$cmdline\""
    else
      # first stack element is always the trap current command line if not empty
      declare -a "prev_cmdline=(`trap -p $trap_sig`)"
      if (( ${#prev_cmdline[2]} )); then
        eval "$stack_var=(\"\${prev_cmdline[2]}\" \"\$cmdline\")"
      else
        eval "$stack_var=(\"\$cmdline\")"
      fi
    fi
    # update the signal trap command line
    GetTrapCmdLine "$trap_sig"
    trap "${RETURN_VALUES[0]}" "$trap_sig"
    EXIT_CODES[i++]=$?
  done
}

function PopTrap()
{
  # drop return values
  EXIT_CODES=()
  RETURN_VALUES=()

  local IFS

  local trap_sig
  local stack_var
  local stack_arr
  local trap_cmdline_size
  local trap_cmdline
  local i

  i=0
  IFS=$' \t\r\n'; for trap_sig in "$@"; do
    stack_var="_traplib_stack_${trap_sig}_cmdline"
    declare -a "stack_arr=(\"\${$stack_var[@]}\")"
    trap_cmdline_size=${#stack_arr[@]}
    if (( trap_cmdline_size )); then
      (( trap_cmdline_size-- ))
      RETURN_VALUES[i]="${stack_arr[trap_cmdline_size]}"
      # unset the end
      unset $stack_var[trap_cmdline_size]
      (( !trap_cmdline_size )) && unset $stack_var

      # update the signal trap command line
      if (( trap_cmdline_size )); then
        GetTrapCmdLineImpl trap_cmdline "$trap_sig"
        trap "${trap_cmdline[0]}" "$trap_sig"
      else
        trap "" "$trap_sig" # just clear the trap
      fi
      EXIT_CODES[i]=$?
    else
      # nothing to pop
      RETURN_VALUES[i]=""
    fi
    (( i++ ))
  done
}

function PopExecTrap()
{
  # drop exit codes
  EXIT_CODES=()

  local IFS=$' \t\r\n'

  PopTrap "$@"

  local cmdline
  local i

  i=0
  IFS=$' \t\r\n'; for cmdline in "${RETURN_VALUES[@]}"; do
    # execute as function and store exit code
    eval "function _traplib_immediate_handler() { $cmdline; }"
    _traplib_immediate_handler
    EXIT_CODES[i++]=$?
    unset _traplib_immediate_handler
  done
}

fi
