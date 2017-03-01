@echo off

setlocal

if "%TOOLS_PATH%" == "" set "TOOLS_PATH=%~dp0"
set "TOOLS_PATH=%TOOLS_PATH:\=/%"
if "%TOOLS_PATH:~-1%" == "/" set "TOOLS_PATH=%TOOLS_PATH:~0,-1%"

set "?~nx0=%~nx0"

rem drop last error level
cd .

rem get code page value from first parameter
set "LAST_CODE_PAGE="
set CODE_PAGE=%~1

shift

if "%CODE_PAGE%" == "" goto NOCODEPAGE

for /F "usebackq eol= tokens=1,* delims=:" %%i in (`chcp 2^>nul`) do set LAST_CODE_PAGE=%%j
set LAST_CODE_PAGE=%LAST_CODE_PAGE: =%

if not "%LAST_CODE_PAGE%" == "%CODE_PAGE%" chcp %CODE_PAGE% >nul

:NOCODEPAGE
:PROCESS_DIR_LOOP
set "FILE_PATH_PTTN=%~1"

rem ignore specific patterns to avoid problems
if "%FILE_PATH_PTTN%" == "" (
  echo.%?~nx0%: error: file or directory is not set.
  exit /b 1
) >&2
if "%FILE_PATH_PTTN:~0,1%" == "\" (
  echo.%?~nx0%: error: file or directory path is not acceptable: "%FILE_PATH_PTTN%".
  exit /b 2
) >&2

rem double evaluate to % ~dpf1 to handle case with the *: "*" -> "X:\YYY\."
call :PROCESS_DIR_PATH "%%~dpf1" || goto :EOF

:PROCESS_DIR_LOOP_CONTINUE
shift

if exist "%~1" goto PROCESS_DIR_LOOP

if not "%LAST_CODE_PAGE%" == "%CODE_PAGE%" chcp %LAST_CODE_PAGE% >nul

exit /b 0

:PROCESS_DIR_PATH
set "FILES_PATH=%~dpf1"

if not exist "%FILES_PATH%" exit /b -1

rem check on file path
if exist "%FILES_PATH%\" (
  call :FILES_PATH_AS_DIR
) else call :FILES_PATH_AS_FILE "%FILES_PATH%"

exit /b

:FILES_PATH_AS_DIR
call "%%TOOLS_PATH%%/strlen.bat" /v FILES_PATH
set /A FILES_PATH_LEN=%ERRORLEVEL%+1
dir /B /S "%FILES_PATH%\" | "%TOOLS_PATH%/gnuwin32/bin/sed.exe" "s/.\{%FILES_PATH_LEN%\}\(.*\)/\1\\/" | sort | "%TOOLS_PATH%/gnuwin32/bin/sed.exe" "s/\(.*\).$/\1/"
goto :EOF

:FILES_PATH_AS_FILE
echo.%~nx1
