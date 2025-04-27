@echo off

setlocal

:REPLACE_LOOP

call set "PROP_NEXT_VALUE=%%PROP_PREV_VALUE:%REPLACE_FROM%=%REPLACE_TO%%%"

rem skip on empty assign
if %FLAG_NO_SKIP_ON_EMPTY_ASSIGN% EQU 0 if not defined PROP_NEXT_VALUE (
  echo;%?~%: warning: property empty value assignment: "%PROP_NAME%"
  echo;%?~nx0%: info: REPLACE_FROM: "%REPLACE_FROM%"
  if %FLAG_DELETE% EQU 0 echo;%?~nx0%: info: REPLACE_TO: "%REPLACE_TO%"
  goto REPLACE_LOOP_NEXT
) >&2

rem skip on empty change
if "%PROP_NAME%" == "TargetPath" (
  if %FLAG_USE_CASE_COMPARE% NEQ 0 (
    if "%PROP_PREV_VALUE%" == "%PROP_NEXT_VALUE%" if %FLAG_ALLOW_TARGET_PATH_REASSIGN% EQU 0 (
      echo;%?~%: warning: property `TargetPath` is not changed (case^).
      echo;%?~nx0%: info: REPLACE_FROM: "%REPLACE_FROM%"
      if %FLAG_DELETE% EQU 0 echo;%?~nx0%: info: REPLACE_TO: "%REPLACE_TO%"
      goto REPLACE_LOOP_NEXT
    ) >&2
  ) else if /i "%PROP_PREV_VALUE%" == "%PROP_NEXT_VALUE%" if %FLAG_ALLOW_TARGET_PATH_REASSIGN% EQU 0 (
    echo;%?~%: warning: property `TargetPath` is not changed (nocase^).
    echo;%?~nx0%: info: REPLACE_FROM: "%REPLACE_FROM%"
    if %FLAG_DELETE% EQU 0 echo;%?~nx0%: info: REPLACE_TO: "%REPLACE_TO%"
    goto REPLACE_LOOP_NEXT
  ) >&2
) else if "%PROP_NAME%" == "WorkingDirectory" (
  if %FLAG_USE_CASE_COMPARE% NEQ 0 (
    if "%PROP_PREV_VALUE%" == "%PROP_NEXT_VALUE%" if %FLAG_ALLOW_WORKING_DIR_REASSIGN% EQU 0 (
      echo;%?~%: warning: property `WorkingDirectory` is not changed (case^).
      echo;%?~nx0%: info: REPLACE_FROM: "%REPLACE_FROM%"
      if %FLAG_DELETE% EQU 0 echo;%?~nx0%: info: REPLACE_TO: "%REPLACE_TO%"
      goto REPLACE_LOOP_NEXT
    ) >&2
  ) else if /i "%PROP_PREV_VALUE%" == "%PROP_NEXT_VALUE%" if %FLAG_ALLOW_WORKING_DIR_REASSIGN% EQU 0 (
    echo;%?~%: warning: property `WorkingDirectory` is not changed (nocase^).
    echo;%?~nx0%: info: REPLACE_FROM: "%REPLACE_FROM%"
    if %FLAG_DELETE% EQU 0 echo;%?~nx0%: info: REPLACE_TO: "%REPLACE_TO%"
    goto REPLACE_LOOP_NEXT
  ) >&2
)

set UPDATE_SHORTCUT=1

:REPLACE_LOOP_NEXT

rem skip on empty value
if not defined PROP_NEXT_VALUE goto EXIT

rem read next replace arg(s)

if %FLAG_DELETE% EQU 0 (
  set "REPLACE_FROM=%~1"
  set "REPLACE_TO=%~2"
  shift & shift
) else (
  set "REPLACE_FROM=%~1"
  shift
)

if %FLAG_DELETE% EQU 0 if defined REPLACE_FROM if not defined REPLACE_TO (
  echo;%?~%: warning: REPLACE_TO is not defined.
  echo;%?~nx0%: info: REPLACE_FROM: "%REPLACE_FROM%"
  goto EXIT
) >&2

if not defined REPLACE_FROM goto EXIT

if %FLAG_DELETE% EQU 0 if "%REPLACE_FROM%" == "%REPLACE_TO%" (
  echo;%?~%: warning: REPLACE_FROM must be not equal to REPLACE_TO: REPLACE_FROM="%REPLACE_FROM%".
  goto REPLACE_LOOP_NEXT
) >&2

set "PROP_PREV_VALUE=%PROP_NEXT_VALUE%"

goto REPLACE_LOOP

:EXIT

(
  endlocal
  set "UPDATE_SHORTCUT=%UPDATE_SHORTCUT%"
  set "PROP_NEXT_VALUE=%PROP_NEXT_VALUE%"
)
