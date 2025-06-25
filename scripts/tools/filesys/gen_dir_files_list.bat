@echo off

setlocal DISABLEDELAYEDEXPANSION

call "%%~dp0__init__.bat" || exit /b

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"

rem get code page value from first parameter
set "LAST_CODE_PAGE="
set CODE_PAGE=%~1

shift

rem get and set code page
call "%%CONTOOLS_ROOT%%/std/chcp.bat" %%CODE_PAGE%%

:PROCESS_DIR_LOOP
set "FILE_PATH_PTTN=%~1"

rem ignore specific patterns to avoid problems
if not defined FILE_PATH_PTTN (
  echo;%?~%: error: file or directory is not set.
  exit /b 1
) >&2
if "%FILE_PATH_PTTN:~0,1%" == "\" (
  echo;%?~%: error: path is not acceptable: "%FILE_PATH_PTTN%".
  exit /b 2
) >&2

rem double evaluate to % ~f1 to handle case with the *: "*" -> "X:\YYY\."
call :PROCESS_DIR_PATH "%%~f1" || exit /b

:PROCESS_DIR_LOOP_CONTINUE
shift

if exist "%~1" goto PROCESS_DIR_LOOP

rem restore code page
call "%%CONTOOLS_ROOT%%/std/restorecp.bat"

exit /b 0

:PROCESS_DIR_PATH
set "FILES_PATH=%~f1"

if not exist "%FILES_PATH%" (
  echo;%?~%: error: file or directory is not found: "%FILES_PATH%".
  exit /b -1
) >&2

rem check on file path
if exist "%FILES_PATH%\*" (
  call :FILES_PATH_AS_DIR
) else call :FILES_PATH_AS_FILE "%%FILES_PATH%%"

exit /b

:FILES_PATH_AS_DIR
call "%%CONTOOLS_ROOT%%/std/strlen.bat" /v FILES_PATH

set /A FILES_PATH_LEN=%ERRORLEVEL%+1

rem CAUTION:
rem   1. If a variable is empty, then it would not be expanded in the `cmd.exe`
rem      command line or in the inner expression of the
rem      `for /F "usebackq ..." %%i in (`<inner-expression>`) do ...`
rem      statement.
rem   2. The `cmd.exe` command line or the inner expression of the
rem      `for /F "usebackq ..." %%i in (`<inner-expression>`) do ...`
rem      statement does expand twice.
rem
rem   We must expand the command line into a variable to avoid these above.
rem
set ?.=@dir "%FILES_PATH%\" /B /O:N /S 2^>nul

for /F "usebackq tokens=* delims="eol^= %%i in (`%%?.%%`) do (
  set "FILE_PATH=%%i"
  setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!FILE_PATH:~%FILES_PATH_LEN%!") do endlocal & echo;%%i
)
exit /b

:FILES_PATH_AS_FILE
echo;%~nx1
