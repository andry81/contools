@echo off

rem Description:
rem   Script cleanups (deletes) recent lists from known places everythere in
rem   the Windows registry.
rem

setlocal

rem scripts must run in administrator mode
net session >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
  echo.%~nx0: error: run script in administrator mode!
  exit /b -255
) >&2

rem Under WOW64 (32-bit process in 64-bit Windows) restart script in 64-bit mode
if "%PROCESSOR_ARCHITECTURE%" == "AMD64" goto X64
if not defined PROCESSOR_ARCHITEW6432 goto X32

rem restart in x64
if exist "%SystemRoot%\Sysnative\" (
  call :CMD "%%SystemRoot%%\Sysnative\cmd.exe" /C @%%0 %%*
  exit /b
)

(
  echo.%~nx0: error: run script in 64-bit console ONLY (in administrative mode)!
  exit /b -254
) >&2

:X64
:X32

set "RECENT_LISTS_PTTN_FILE=%~1"

if not exist "%RECENT_LISTS_PTTN_FILE%" (
  echo.%~nx0: error: recent lists pattern file is not found: "%RECENT_LISTS_PTTN_FILE%"
  exit /b 255
) >&2

set "CMD_INDENT_STR=  "

for /F "usebackq eol=# tokens=1,* delims=|" %%i in ("%RECENT_LISTS_PTTN_FILE%") do (
  set "RECENT_LIST_REG_KEY_RECORD=%%i|%%j"

  if "%%i" == "*" (
    set "RECENT_LIST_REG_KEY_PATH=%%j"
    call :CLEANUP_RECENT_LIST_REG_KEY_ALL
  ) else if "%%i" == "." (
    for /F "eol= tokens=1,2,* delims=|" %%k in ("%%j") do (
      set "RECENT_LIST_REG_KEY_PATH=%%k"
      set "RECENT_LIST_REG_KEY_TYPE=%%l"
      set "RECENT_LIST_REG_KEY_NAME=%%m"
      call :CLEANUP_RECENT_LIST_REG_KEY_NAME
    )
  ) else if "%%i" == "n" (
    for /F "eol= tokens=1,2,* delims=|" %%k in ("%%j") do (
      set "RECENT_LIST_REG_KEY_PATH_RE=%%k"
      set "RECENT_LIST_REG_KEY_TYPE=%%l"
      set "RECENT_LIST_REG_KEY_NAME_RE=%%m"
      call :CLEANUP_RECENT_LIST_REG_KEY_NAME_RE
    )
  ) else call :CLEANUP_RECENT_LIST_REG_KEY_UNKNOWN
  echo.---
)

exit /b 0

rem delete existed key path
:CLEANUP_RECENT_LIST_REG_KEY_ALL
if not defined RECENT_LIST_REG_KEY_PATH goto CLEANUP_RECENT_LIST_REG_KEY_UNKNOWN

echo."%RECENT_LIST_REG_KEY_PATH%"
call :CMD_W_INDENT "%%SystemRoot%%\System32\reg.exe" query "%%RECENT_LIST_REG_KEY_PATH%%" && (
  call :CMD_W_INDENT "%%SystemRoot%%\System32\reg.exe" delete "%%RECENT_LIST_REG_KEY_PATH%%" /f && (
    call :CMD_W_INDENT "%%SystemRoot%%\System32\reg.exe" add "%%RECENT_LIST_REG_KEY_PATH%%"
  )
)
exit /b

rem delete existed key name
:CLEANUP_RECENT_LIST_REG_KEY_NAME
if not defined RECENT_LIST_REG_KEY_NAME goto CLEANUP_RECENT_LIST_REG_KEY_UNKNOWN

echo."%RECENT_LIST_REG_KEY_PATH% | %RECENT_LIST_REG_KEY_TYPE% | %RECENT_LIST_REG_KEY_NAME%"
call :CMD_W_INDENT "%%SystemRoot%%\System32\reg.exe" query "%%RECENT_LIST_REG_KEY_PATH%%" /v "%%RECENT_LIST_REG_KEY_NAME%%" && (
  call :CMD_W_INDENT "%%SystemRoot%%\System32\reg.exe" add "%%RECENT_LIST_REG_KEY_PATH%%" /v "%%RECENT_LIST_REG_KEY_NAME%%" /t "%%RECENT_LIST_REG_KEY_TYPE%%" /f
)
exit /b

rem delete existed key name by regexp
:CLEANUP_RECENT_LIST_REG_KEY_NAME_RE
if not defined RECENT_LIST_REG_KEY_NAME_RE goto CLEANUP_RECENT_LIST_REG_KEY_UNKNOWN

set "REG_CMD_QUERY_BARE_FLAGS="

rem exact match
set "REG_CMD_FIND_BARE_FLAG=/v"
set "RECENT_LIST_REG_KEY_PATH=%RECENT_LIST_REG_KEY_PATH_RE%"
set "RECENT_LIST_REG_KEY_NAME=%RECENT_LIST_REG_KEY_NAME_RE%"

rem pattern in the key path
if "%RECENT_LIST_REG_KEY_PATH_RE:~-2%" == "\*" (
  set REG_CMD_QUERY_BARE_FLAGS= /s
  set "RECENT_LIST_REG_KEY_PATH=%RECENT_LIST_REG_KEY_PATH_RE:~0,-2%"
)

rem pattern in the key name
if "%RECENT_LIST_REG_KEY_NAME_RE:~-1%" == "*" (
  rem pattern match
  set "REG_CMD_FIND_BARE_FLAG=/f"
  set "RECENT_LIST_REG_KEY_NAME=%RECENT_LIST_REG_KEY_NAME_RE:~0,-1%"
)

set "RECENT_LIST_REG_KEY_SUBPATH=%RECENT_LIST_REG_KEY_PATH%"

echo."%RECENT_LIST_REG_KEY_PATH% | %RECENT_LIST_REG_KEY_TYPE% | %RECENT_LIST_REG_KEY_NAME_RE%"
call :CMD_ECHO_W_INDENT "%%SystemRoot%%\System32\reg.exe" query "%%RECENT_LIST_REG_KEY_PATH%%" %%REG_CMD_FIND_BARE_FLAG%% "%%RECENT_LIST_REG_KEY_NAME%%"%%REG_CMD_QUERY_BARE_FLAGS%%
for /f "usebackq tokens=* delims=" %%i in (`@"%SystemRoot%\System32\reg.exe" query "%RECENT_LIST_REG_KEY_PATH%" %REG_CMD_FIND_BARE_FLAG% "%RECENT_LIST_REG_KEY_NAME%"%REG_CMD_QUERY_BARE_FLAGS%`) do (
  if not "%%i" == "" (
    set "REGQUERY_LINE=%%i"
    call :CLEANUP_RECENT_LIST_REG_KEY_NAME_RE_IMPL
  )
)
exit /b

:CLEANUP_RECENT_LIST_REG_KEY_NAME_RE_IMPL
if "%REGQUERY_LINE:~0,5%" == "HKEY_" set "RECENT_LIST_REG_KEY_SUBPATH=%REGQUERY_LINE%"

if not "%REGQUERY_LINE:~0,4%" == "    " exit /b 0

rem CAUTION: name must be without whitespaces!
set "REGQUERY_KEY_NAME="
for /f "eol= tokens=1,* delims= " %%i in ("%REGQUERY_LINE:~4%") do set "REGQUERY_KEY_NAME=%%i"

call :CMD_W_INDENT "%%SystemRoot%%\System32\reg.exe" query "%%RECENT_LIST_REG_KEY_SUBPATH%%" /v "%%REGQUERY_KEY_NAME%%" && (
  call :CMD_W_INDENT "%%SystemRoot%%\System32\reg.exe" add "%%RECENT_LIST_REG_KEY_SUBPATH%%" /v "%%REGQUERY_KEY_NAME%%" /t "%%RECENT_LIST_REG_KEY_TYPE%%" /f
)

exit /b

:CLEANUP_RECENT_LIST_REG_KEY_UNKNOWN
echo.%~nx0: error: unknown registry record: "%RECENT_LIST_REG_KEY_RECORD%"
exit /b 0

:CMD
call :CMD_ECHO %%*
echo.^>%*
(
  %*
)
exit /b

:CMD_W_INDENT
call :CMD_ECHO_W_INDENT %%*
(
  %*
)
exit /b

:CMD_ECHO
echo.^>%*
exit /b

:CMD_ECHO_W_INDENT
echo.%CMD_INDENT_STR%^>%*
exit /b
