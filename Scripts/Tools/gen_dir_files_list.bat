@echo off

setlocal

call "%%~dp0__init__.bat" || exit /b

set "?~nx0=%~nx0"

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
  echo.%?~nx0%: error: file or directory is not set.
  exit /b 1
) >&2
if "%FILE_PATH_PTTN:~0,1%" == "\" (
  echo.%?~nx0%: error: file or directory path is not acceptable: "%FILE_PATH_PTTN%".
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
  echo.%?~nx0%: error: file or directory is not found: "%FILES_PATH%".
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
dir /B /S /O:N "%FILES_PATH%\" | "%CONTOOLS_GNUWIN32_ROOT%/bin/sed.exe" "s/.\{%FILES_PATH_LEN%\}\(.*\)/\1\\/" | "%CONTOOLS_GNUWIN32_ROOT%/bin/sed.exe" "s/\(.*\).$/\1/"
exit /b

:FILES_PATH_AS_FILE
echo.%~nx1
