@echo off

rem CAUTION:
rem  DO NOT kill cmd.exe processes by this script because it can kill
rem  self cmd.exe host before kill other cmd.exe processes.

setlocal

set "?~nx0=%~nx0"

call "%%~dp0__init__.bat" || exit /b

rem script flags
set FLAG_CLOSE_ALL=0

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-all" (
    set FLAG_CLOSE_ALL=1
    shift
  ) else (
    echo.%?~nx0%: error: invalid flag: %FLAG%
    exit /b -255
  ) >&2

  rem read until no flags
  goto FLAGS_LOOP
)

set "PROC_NAME=%~1"
set "OBJECT_NAME=%~2"

if not defined PROC_NAME (
  echo.%?~nx0%: error: PROC_NAME is not set.
  exit /b 1
) >&2

if not defined OBJECT_NAME (
  echo.%?~nx0%: error: OBJECT_NAME is not set.
  exit /b 2
) >&2

if %FLAG_CLOSE_ALL% NEQ 0 (
  echo.Killing "%PROC_NAME%" processes holding "%OBJECT_NAME%" handle...
) else (
  echo.Killing first "%PROC_NAME%" process holding "%OBJECT_NAME%" handle...
)

rem Add \ character to the end of argument string if \ character already at the end,
rem otherwise handle.exe command line parser will fail because of trailing \" sequence.
if "%PROC_NAME:~-1%" == "\" set "PROC_NAME=%PROC_NAME%\"
if "%OBJECT_NAME:~-1%" == "\" set "OBJECT_NAME=%OBJECT_NAME%\"

for /F "usebackq eol= tokens=* delims=" %%i in (`@"%CONTOOLS_SYSINTERNALS_ROOT%/handle.exe" -p "%PROC_NAME%" "%OBJECT_NAME%" ^| "%%SystemRoot%%\System32\findstr.exe" /R /C:"pid: .*type: "`) do (
  set "HANDLE_LINE=%%i"
  call :PROCESS_HANDLE_LINE
  if %FLAG_CLOSE_ALL% EQU 0 exit /b 0
)
echo.
exit /b

:PROCESS_HANDLE_LINE
set WORD_INDEX=1
set WORD_FOUND=0

:PROCESS_HANDLE_LINE_LOOP
set "WORD="
for /F "eol= tokens=%WORD_INDEX% delims= " %%i in ("%HANDLE_LINE%") do set "WORD=%%i"
if not defined WORD exit /b 0

if %WORD_INDEX% EQU 1 set "PROC_NAME=%WORD%"
if %WORD_FOUND% NEQ 0 set "PROC_PID=%WORD%" & goto HANDLE_LINE_PROCESSED
if "%WORD%" == "pid:" set WORD_FOUND=1

set /A WORD_INDEX+=1

goto PROCESS_HANDLE_LINE_LOOP

:HANDLE_LINE_PROCESSED
if not defined PROC_NAME exit /b 1
if not defined PROC_PID exit /b 2
echo.  Killing %PROC_NAME% with pid %PROC_PID%...
taskkill /PID %PROC_PID%
