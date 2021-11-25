#!/bin/bash

# Author:   Andrey Dibrov (andry at inbox dot ru)

# Description:
#   Bash script to prints merged logs generated by pipetimes.exe utility.

# Usage:
#   "print_merged_logs.sh <stdout.log> <stderr.log> <stdout_index.log>
#          <stderr_index.log>", where:
#   <stdout.log> and <stderr.log> - standard output/error log files.
#   <stdout_index.log> and <stderr_index.log> - standard output/error log
#     files indexes.

if [[ -n "$BASH" ]]; then

if [[ -z "$SOURCE_TACKLELIB_BASH_TACKLELIB_SH" || SOURCE_TACKLELIB_BASH_TACKLELIB_SH -eq 0 ]]; then
  # builtin search
  for BASH_SOURCE_DIR in "/usr/local/bin" "/usr/bin" "/bin"; do
    [[ -f "$BASH_SOURCE_DIR/bash_tacklelib" ]] && {
      source "$BASH_SOURCE_DIR/bash_tacklelib" || exit $?
      break
    }
  done
fi

tkl_include '__init__.sh' || tkl_abort_include
tkl_include "$CONTOOLS_BASH_ROOT/stringlib.sh" || tkl_abort_include
tkl_include "$CONTOOLS_BASH_ROOT/filelib.sh" || tkl_abort_include

function PrintMergedLogs()
{
  local TargetOutLogFilePath="$1"
  local TargetErrLogFilePath="$2"
  local TargetOutIndexLogFilePath="$3"
  local TargetErrIndexLogFilePath="$4"

  [[ -n "$TargetOutLogFilePath" && -f "$TargetOutLogFilePath" ]] || return 1
  [[ -n "$TargetErrLogFilePath" && -f "$TargetErrLogFilePath" ]] || return 2
  [[ -n "$TargetOutIndexLogFilePath" && -f "$TargetOutIndexLogFilePath" ]] || return 3
  [[ -n "$TargetErrIndexLogFilePath" && -f "$TargetErrIndexLogFilePath" ]] || return 4

  local TargetOutIndexLogFileId=11
  local TargetErrIndexLogFileId=12

  # Open files for reading.
  eval exec "$TargetOutIndexLogFileId<'$TargetOutIndexLogFilePath'"
  eval exec "$TargetErrIndexLogFileId<'$TargetErrIndexLogFilePath'"

  # Read index files at first.
  local OutTimeStamp=0
  local OutTimeStamp1=0
  local OutTimeStamp2=0
  local OutTextOffset=0
  local OutTextLen=0
  local OutTimeStamp3=0
  local ErrTimeStamp=0
  local ErrTimeStamp1=0
  local ErrTimeStamp2=0
  local ErrTextOffset=0
  local ErrTextLen=0
  local ErrTimeStamp3=0

  local isOutIndexDataValid=0
  local isErrIndexDataValid=0

  local doReadOutIndexFile=1
  local doReadErrIndexFile=1

  local isOutTextIndexEOF=0
  local isErrTextIndexEOF=0

  local OutTextBuffer=""
  local ErrTextBuffer=""

  # Enables read string line into multiple variables. 
  local IFS=$' \t'

  # Find first line of valid index data for STDOUT stream
  while [[ $doReadOutIndexFile -ne 0 && $isOutIndexDataValid -eq 0 ]]; do
    read -r -u $TargetOutIndexLogFileId OutTimeStamp1 OutTimeStamp2 OutTextOffset OutTextLen OutTimeStamp3
    isOutTextIndexEOF=$?

    if [[ ${#OutTimeStamp1} -gt 0 && ${#OutTimeStamp2} -gt 0 && ${#OutTextOffset} -gt 0 &&
      ${#OutTextLen} -gt 0 ]]; then
      isOutIndexDataValid=1
    else
      isOutIndexDataValid=0
    fi

    if [[ $isOutTextIndexEOF -eq 0 ]]; then
      doReadOutIndexFile=1
    else
      doReadOutIndexFile=0
    fi
  done

  # Find first line of valid index data for STDERR stream
  while [[ $doReadErrIndexFile -ne 0 && $isErrIndexDataValid -eq 0 ]]; do
    read -r -u $TargetErrIndexLogFileId ErrTimeStamp1 ErrTimeStamp2 ErrTextOffset ErrTextLen ErrTimeStamp3
    isErrTextIndexEOF=$?

    if [[ ${#ErrTimeStamp1} -gt 0 && ${#ErrTimeStamp2} -gt 0 && ${#ErrTextOffset} -gt 0 &&
      ${#ErrTextLen} -gt 0 ]]; then
      isErrIndexDataValid=1
    else
      isErrIndexDataValid=0
    fi

    if [[ $isErrTextIndexEOF -eq 0 ]]; then
      doReadErrIndexFile=1
    else
      doReadErrIndexFile=0
    fi
  done

  if [[ $isOutIndexDataValid -eq 0 && $isErrIndexDataValid -eq 0 ]]; then
    # No any valid index data.
    return 5
  fi

  # Read text files into variables with disabled non printable characters
  # truncation at beginning/ending.

  # Enables read whole string line into a single variable. 
  IFS=""

  local stdinLine=""
  local doRead
  local minReadBlockSize=65536

  local OutTextBuffer=""
  {
    doRead=1
    while [[ $doRead -ne 0 ]]; do
      read -r -n $minReadBlockSize stdinLine
      local LastError=$?

      if [[ $LastError -eq 0 ]]; then
        OutTextBuffer="${OutTextBuffer}$stdinLine"$'\n'
      else
        OutTextBuffer="${OutTextBuffer}$stdinLine"
        doRead=0
      fi
    done
  } < "$TargetOutLogFilePath"

  local ErrTextBuffer=""
  {
    doRead=1
    while [[ $doRead -ne 0 ]]; do
      read -r -n $minReadBlockSize stdinLine
      local LastError=$?

      if [[ $LastError -eq 0 ]]; then
        ErrTextBuffer="${ErrTextBuffer}$stdinLine"$'\n'
      else
        ErrTextBuffer="${ErrTextBuffer}$stdinLine"
        doRead=0
      fi
    done
  } < "$TargetErrLogFilePath"

  if [[ ${#OutTextBuffer} -eq 0 && ${#ErrTextBuffer} -eq 0 ]]; then
    # Both files are empty.
    return 6
  fi

  local OutTimeStampValue=0
  local OutTextOffsetValue=0
  local OutTextLenValue=0
  local ErrTimeStampValue=0
  local ErrTextOffsetValue=0
  local ErrTextLenValue=0

  # Uses if index file compound from multiple index files.
  local OutTextBlockOffsetValue=0
  local ErrTextBlockOffsetValue=0
  local lastOutTextBlockOffsetValue=0
  local lastErrTextBlockOffsetValue=0

  # Update values.
  if [[ $isOutIndexDataValid -ne 0 ]]; then
    # Convert from hexadecimal to decimal.
    let OutTimeStampValue1=0x$OutTimeStamp1
    let OutTimeStampValue2=0x$OutTimeStamp2
    let OutTimeStampValueDiff="$OutTimeStampValue2-$OutTimeStampValue1"
    let OutTimeStampValueOffset="($OutTimeStampValueDiff/4)*3"
    let OutTimeStampValue="$OutTimeStampValue1+$OutTimeStampValueOffset"
    let OutTextOffsetValue=0x$OutTextOffset
    let OutTextLenValue=0x$OutTextLen

    if [[ $OutTextOffsetValue -eq 0 ]]; then
      # Update block offset accumulator.
      (( OutTextBlockOffsetValue+=lastOutTextBlockOffsetValue ))
    fi

    # Update last block offset accumulator.
    (( lastOutTextBlockOffsetValue=OutTextOffsetValue+OutTextLenValue ))

    # Update offset.
    (( OutTextOffsetValue+=OutTextBlockOffsetValue ))
  fi

  if [[ $isErrIndexDataValid -ne 0 ]]; then
    # Convert from hexadecimal to decimal.
    let ErrTimeStampValue1=0x$ErrTimeStamp1
    let ErrTimeStampValue2=0x$ErrTimeStamp2
    let ErrTimeStampValueDiff="$ErrTimeStampValue2-$ErrTimeStampValue1"
    let ErrTimeStampValueOffset="($ErrTimeStampValueDiff/4)*3"
    let ErrTimeStampValue="$ErrTimeStampValue1+$ErrTimeStampValueOffset"
    let ErrTextOffsetValue=0x$ErrTextOffset
    let ErrTextLenValue=0x$ErrTextLen

    if [[ $ErrTextOffsetValue -eq 0 ]]; then
      # Update block offset accumulator.
      (( ErrTextBlockOffsetValue+=lastErrTextBlockOffsetValue ))
    fi

    # Update last block offset accumulator.
    (( lastErrTextBlockOffsetValue=ErrTextOffsetValue+ErrTextLenValue ))

    # Update offset.
    (( ErrTextOffsetValue+=ErrTextBlockOffsetValue ))
  fi

  # Enables read string line into multiple variables. 
  IFS=$' \t'

  local streamType

  while [[ 1 ]]; do
    if [[ $isOutIndexDataValid -eq 0 && $isErrIndexDataValid -eq 0 ]]; then
      # No more valid index data.
      break
    fi

    if [[ $isErrIndexDataValid -eq 0 ||
      $isOutIndexDataValid -ne 0 && $OutTimeStampValue -le $ErrTimeStampValue ]]; then
      streamType=0
    else
      streamType=1
    fi
    
    if [[ $streamType -eq 0 ]]; then
      echo -n "${OutTextBuffer:$OutTextOffsetValue:$OutTextLenValue}"
      #echo -n "${OutTextBuffer:$OutTextOffsetValue:$OutTextLenValue}" >&2
      isOutIndexDataValid=0
    else
      echo -n "${ErrTextBuffer:$ErrTextOffsetValue:$ErrTextLenValue}"
      #echo -n "${ErrTextBuffer:$ErrTextOffsetValue:$ErrTextLenValue}" >&2
      isErrIndexDataValid=0
    fi

    # Read next line of valid index data.
    if [[ $streamType -eq 0 ]]; then
      while [[ $doReadOutIndexFile -ne 0 && $isOutIndexDataValid -eq 0 ]]; do
        read -r -u $TargetOutIndexLogFileId OutTimeStamp1 OutTimeStamp2 OutTextOffset OutTextLen OutTimeStamp3
        isOutTextIndexEOF=$?

        if [[ ${#OutTimeStamp1} -gt 0 && ${#OutTimeStamp2} -gt 0 && ${#OutTextOffset} -gt 0 &&
          ${#OutTextLen} -gt 0 ]]; then
          isOutIndexDataValid=1
        else
          isOutIndexDataValid=0
        fi

        if [[ $isOutTextIndexEOF -eq 0 ]]; then
          doReadOutIndexFile=1
        else
          doReadOutIndexFile=0
        fi
      done

      # Update values.
      if [[ $isOutIndexDataValid -ne 0 ]]; then
        # Convert from hexadecimal to decimal.
        let OutTimeStampValue1=0x$OutTimeStamp1
        let OutTimeStampValue2=0x$OutTimeStamp2
        let OutTimeStampValueDiff="$OutTimeStampValue2-$OutTimeStampValue1"
        let OutTimeStampValueOffset="($OutTimeStampValueDiff/4)*3"
        let OutTimeStampValue="$OutTimeStampValue1+$OutTimeStampValueOffset"
        let OutTextOffsetValue=0x$OutTextOffset
        let OutTextLenValue=0x$OutTextLen

        if [[ $OutTextOffsetValue -eq 0 ]]; then
          # Update block offset accumulator.
          (( OutTextBlockOffsetValue+=lastOutTextBlockOffsetValue ))
        fi

        # Update last block offset accumulator.
        (( lastOutTextBlockOffsetValue=OutTextOffsetValue+OutTextLenValue ))

        # Update offset.
        (( OutTextOffsetValue+=OutTextBlockOffsetValue ))
      fi
    fi

    if [[ $streamType -eq 1 ]]; then
      while [[ $doReadErrIndexFile -ne 0 && $isErrIndexDataValid -eq 0 ]]; do
        read -r -u $TargetErrIndexLogFileId ErrTimeStamp1 ErrTimeStamp2 ErrTextOffset ErrTextLen ErrTimeStamp3
        isErrTextIndexEOF=$?

        if [[ ${#ErrTimeStamp1} -gt 0 && ${#ErrTimeStamp2} -gt 0 && ${#ErrTextOffset} -gt 0 &&
          ${#ErrTextLen} -gt 0 ]]; then
          isErrIndexDataValid=1
        else
          isErrIndexDataValid=0
        fi

        if [[ $isErrTextIndexEOF -eq 0 ]]; then
          doReadErrIndexFile=1
        else
          doReadErrIndexFile=0
        fi
      done

      # Update values.
      if [[ $isErrIndexDataValid -ne 0 ]]; then
        # Convert from hexadecimal to decimal.
        let ErrTimeStampValue1=0x$ErrTimeStamp1
        let ErrTimeStampValue2=0x$ErrTimeStamp2
        let ErrTimeStampValueDiff="$ErrTimeStampValue2-$ErrTimeStampValue1"
        let ErrTimeStampValueOffset="($ErrTimeStampValueDiff/4)*3"
        let ErrTimeStampValue="$ErrTimeStampValue1+$ErrTimeStampValueOffset"
        let ErrTextOffsetValue=0x$ErrTextOffset
        let ErrTextLenValue=0x$ErrTextLen

        if [[ $ErrTextOffsetValue -eq 0 ]]; then
          # Update block offset accumulator.
          (( ErrTextBlockOffsetValue+=lastErrTextBlockOffsetValue ))
        fi

        # Update last block offset accumulator.
        (( lastErrTextBlockOffsetValue=ErrTextOffsetValue+ErrTextLenValue ))

        # Update offset.
        (( ErrTextOffsetValue+=ErrTextBlockOffsetValue ))
      fi
    fi
  done

  eval exec "$TargetOutIndexLogFileId>&-"
  eval exec "$TargetErrIndexLogFileId>&-"

  return 0
}

if [[ -z "$BASH_LINENO" || ${BASH_LINENO[0]} -eq 0 ]]; then
  # Script was not included, then execute it.
  PrintMergedLogs "$@"
  exit $?
fi

fi
