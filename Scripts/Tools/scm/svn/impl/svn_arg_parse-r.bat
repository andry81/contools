@echo off

set "ARG_SVN_REVISION_RANGE=%~1"

if "%ARG_SVN_REVISION_RANGE%" == "-" goto EMPTY_REVISION_RANGE

set ARG_SVN_REVISION_RANGE_IS_INVERSED=0
if "%ARG_SVN_REVISION_RANGE:~0,1%" == "!" (
  set ARG_SVN_REVISION_RANGE_IS_INVERSED=1
  set "ARG_SVN_REVISION_RANGE=%ARG_SVN_REVISION_RANGE:~1%"
)

set ARG_SVN_REVISION_RANGE_INCLUDING_EMPTY=0
if "%ARG_SVN_REVISION_RANGE:~-1%" == "-" (
  set ARG_SVN_REVISION_RANGE_INCLUDING_EMPTY=1
  set "ARG_SVN_REVISION_RANGE=%ARG_SVN_REVISION_RANGE:~0,-1%"
)

set "ARG_SVN_REVISION_RANGE_FROM="
set "ARG_SVN_REVISION_RANGE_TO="
for /F "eol= tokens=1,* delims=:" %%i in ("%ARG_SVN_REVISION_RANGE%") do (
  set "ARG_SVN_REVISION_RANGE_FROM=%%i"
  set "ARG_SVN_REVISION_RANGE_TO=%%j"
)

rem compensate if : character is in beggining
if not "%ARG_SVN_REVISION_RANGE%" == "%ARG_SVN_REVISION_RANGE::=%" ^
if not "%ARG_SVN_REVISION_RANGE_TO%" == "%ARG_SVN_REVISION_RANGE:*:=%" (
  set "ARG_SVN_REVISION_RANGE_TO=%ARG_SVN_REVISION_RANGE_FROM%"
  set ARG_SVN_REVISION_RANGE_FROM=0
)

if "%ARG_SVN_REVISION_RANGE_TO%" == "" (
  if "%ARG_SVN_REVISION_RANGE%" == "%ARG_SVN_REVISION_RANGE::=%" (
    if %ARG_SVN_REVISION_RANGE_IS_INVERSED% EQU 0 (
      if %ARG_SVN_REVISION_RANGE_INCLUDING_EMPTY% EQU 0 (
        set "SQLITE_EXP_REVISION_RANGE=revision = '%ARG_SVN_REVISION_RANGE_FROM%'"
      ) else (
        set "SQLITE_EXP_REVISION_RANGE=revision = '%ARG_SVN_REVISION_RANGE_FROM%' or revision = '' or revision is null"
      )
    ) else (
      if %ARG_SVN_REVISION_RANGE_INCLUDING_EMPTY% EQU 0 (
        set "SQLITE_EXP_REVISION_RANGE=revision != '%ARG_SVN_REVISION_RANGE_FROM%'"
      ) else (
        set "SQLITE_EXP_REVISION_RANGE=revision != '%ARG_SVN_REVISION_RANGE_FROM%' or revision = '' or revision is null"
      )
    )
  ) else (
    if %ARG_SVN_REVISION_RANGE_INCLUDING_EMPTY% EQU 0 (
      set "SQLITE_EXP_REVISION_RANGE=revision > '%ARG_SVN_REVISION_RANGE_FROM%'"
    ) else (
      set "SQLITE_EXP_REVISION_RANGE=revision > '%ARG_SVN_REVISION_RANGE_FROM%' or revision = '' or revision is null"
    )
  )
) else if %ARG_SVN_REVISION_RANGE_IS_INVERSED% EQU 0 (
  if %ARG_SVN_REVISION_RANGE_INCLUDING_EMPTY% EQU 0 (
    set "SQLITE_EXP_REVISION_RANGE=revision > '%ARG_SVN_REVISION_RANGE_FROM%' and revision <= '%ARG_SVN_REVISION_RANGE_TO%'"
  ) else (
    set "SQLITE_EXP_REVISION_RANGE=revision > '%ARG_SVN_REVISION_RANGE_FROM%' and revision <= '%ARG_SVN_REVISION_RANGE_TO%' or revision = '' or revision is null"
  )
) else (
  if %ARG_SVN_REVISION_RANGE_INCLUDING_EMPTY% EQU 0 (
    set "SQLITE_EXP_REVISION_RANGE=revision > '%ARG_SVN_REVISION_RANGE_TO%' or revision <= '%ARG_SVN_REVISION_RANGE_FROM%'"
  ) else (
    set "SQLITE_EXP_REVISION_RANGE=revision > '%ARG_SVN_REVISION_RANGE_TO%' or revision <= '%ARG_SVN_REVISION_RANGE_FROM%' or revision = '' or revision is null"
  )
)

goto EMPTY_REVISION_RANGE_END

:EMPTY_REVISION_RANGE
set "SQLITE_EXP_REVISION_RANGE=revision = '' or revision is null"

:EMPTY_REVISION_RANGE_END
