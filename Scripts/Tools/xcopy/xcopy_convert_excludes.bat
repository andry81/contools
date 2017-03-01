@echo off

rem Script converts xcopy file/directory excludes into xcopy/robocopy
rem preformatted command line.

rem Drop return value
set "RETURN_VALUE="

setlocal

set HAS_RETURN_VALUE=0

set "XCOPY_EXCLUDE_FILES_LIST=%~1"

if "%XCOPY_EXCLUDE_FILES_LIST%" == "" exit /b 1

set ROBOCOPY_EXIST=0
if exist "%WINDIR%\system32\robocopy.exe" set ROBOCOPY_EXIST=1

set FILE_INDEX=1

:EXCLUDE_FILES_LOOP
set "FILE="
for /F "eol= tokens=%FILE_INDEX% delims=|" %%i in ("%XCOPY_EXCLUDE_FILES_LIST%") do set "FILE=%%i"
if "%FILE%" == "" goto EXIT

set VALUE_FOUND_DO_EXIT=0

if %ROBOCOPY_EXIST% EQU 0 (
  set "VALUE=%FILE%"
  goto VALUE_FOUND
)

set VALUE_FOUND_DO_EXIT=1
for /F "usebackq eol= tokens=* delims=" %%i in ("%FILE%") do (
  set "VALUE=%%i"
  call :VALUE_FOUND
)

goto VALUE_FOUND_END

:VALUE_FOUND
if %HAS_RETURN_VALUE% NEQ 0 (
  if %ROBOCOPY_EXIST% EQU 0 (
    set "RETURN_VALUE=%RETURN_VALUE%+%VALUE%"
  ) else (
    set RETURN_VALUE=%RETURN_VALUE% "%VALUE%"
  )
) else (
  if %ROBOCOPY_EXIST% EQU 0 (
    set "RETURN_VALUE=%VALUE%"
  ) else (
    set RETURN_VALUE="%VALUE%"
  )
  set HAS_RETURN_VALUE=1
)

if %VALUE_FOUND_DO_EXIT% NEQ 0 exit /b 0

:VALUE_FOUND_END
set /A FILE_INDEX+=1
goto EXCLUDE_FILES_LOOP

:EXIT
if %ROBOCOPY_EXIST% EQU 0 (
  endlocal
  set "RETURN_VALUE=%RETURN_VALUE%"
) else (
  endlocal
  set RETURN_VALUE=%RETURN_VALUE%
)

exit /b 0
