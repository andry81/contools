@echo off & goto DOC_END

rem Description:
rem   Get file hash in a CVS format into the variable.

rem Example:
rem 1. call get_file_hash_cvs.bat -c md5 -b -s <file>
rem    rem RETURN_VALUE=<size>,<md5>,<file>
:DOC_END

rem drop return value
set "RETURN_VALUE="

setlocal

call "%%~dp0__init__\__init__.bat" || exit /b

set "?~nx0=%~nx0"

rem script flags
set "HASHDEEP_CMD_FLAG_ARGS="

rem hashdeep flags
set "HASHDEEP_CMD_ARGS="

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-c" (
    rem consume next argument into flags
    set HASHDEEP_CMD_FLAG_ARGS=%HASHDEEP_CMD_FLAG_ARGS%%FLAG% %2 
    shift
    shift
  ) else if "%FLAG%" == "-p" (
    rem consume next argument into flags
    set HASHDEEP_CMD_FLAG_ARGS=%HASHDEEP_CMD_FLAG_ARGS%%FLAG% %2 
    shift
    shift
  ) else if "%FLAG%" == "-k" (
    rem consume next argument into flags
    set HASHDEEP_CMD_FLAG_ARGS=%HASHDEEP_CMD_FLAG_ARGS%%FLAG% %2 
    shift
    shift
  ) else if "%FLAG%" == "-j" (
    rem consume next argument into flags
    set HASHDEEP_CMD_FLAG_ARGS=%HASHDEEP_CMD_FLAG_ARGS%%FLAG% %2 
    shift
    shift
  ) else if "%FLAG%" == "-o" (
    rem consume next argument into flags
    set HASHDEEP_CMD_FLAG_ARGS=%HASHDEEP_CMD_FLAG_ARGS%%FLAG% %2 
    shift
    shift
  ) else if "%FLAG%" == "-i" (
    rem consume next argument into flags
    set HASHDEEP_CMD_FLAG_ARGS=%HASHDEEP_CMD_FLAG_ARGS%%FLAG% %2 
    shift
    shift
  ) else if "%FLAG%" == "-f" (
    rem consume next argument into flags
    set HASHDEEP_CMD_FLAG_ARGS=%HASHDEEP_CMD_FLAG_ARGS%%FLAG% %2 
    shift
    shift
  ) else (
    set HASHDEEP_CMD_ARGS=%HASHDEEP_CMD_ARGS%%1 
    shift
  )

  rem read until no flags
  goto FLAGS_LOOP
)

:ARGSN_LOOP
if not "%~1" == "" (
  set HASHDEEP_CMD_ARGS=%HASHDEEP_CMD_ARGS%%1 
  shift
  goto ARGSN_LOOP
)

for /F "usebackq tokens=* delims="eol^= %%i in (`@"%%CONTOOLS_ROOT%%/hash/hashdeep.bat" %%HASHDEEP_CMD_FLAG_ARGS%% %%HASHDEEP_CMD_ARGS%%`) do (
  set "HASHDEEP_LINE=%%i"
  call :PROCESS_LINE || goto EXIT
)

:EXIT
endlocal & set "RETURN_VALUE=%RETURN_VALUE%"

exit /b 0

:PROCESS_LINE
if not defined HASHDEEP_LINE exit /b 0

if "%HASHDEEP_LINE:~0,1%" == "%%" exit /b 0
if "%HASHDEEP_LINE:~0,1%" == "#" exit /b 0

set "RETURN_VALUE=%HASHDEEP_LINE%"

exit /b 0
