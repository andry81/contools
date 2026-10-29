@echo off & goto DOC_END

rem USAGE:
rem   test_for_chcp.bat [<flags>]

rem Description:
rem   Probes for a code page from `cp.lst` file.

rem <flags>:
rem   -pv
rem     Prints only a valid code page number with success code from `chcp.com`.
rem
rem   -norestore
rem     Does not restore code page after the probe.
rem
rem   -noexclude
rem     Does not exclude code pages marked with the `!` prefix character as by
rem     default.
:DOC_END

setlocal DISABLEDELAYEDEXPANSION

call "%%~dp0__init__/script_init.bat" %%0 %%* || exit /b
if %IMPL_MODE%0 EQU 0 exit /b

call "%%CONTOOLS_ROOT%%/std/assert_if_def.bat" __CTRL_SETLOCAL "error: cmd.exe is broken, please restart it!" && set "__CTRL_SETLOCAL=1"
call "%%CONTOOLS_TESTLIB_ROOT%%/init.bat" "%%~f0" || exit /b

set ?~nx0=%~nx0

rem script flags
set FLAG_PRINT_VALID=0
set FLAG_NO_RESTORE=0
set FLAG_NO_EXCLUDE=0

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-pv" (
    set FLAG_PRINT_VALID=1
  ) else if "%FLAG%" == "-norestore" (
    set FLAG_NO_RESTORE=1
  ) else if "%FLAG%" == "-noexclude" (
    set FLAG_NO_EXCLUDE=1
  ) else (
    echo;%?~nx0%: error: invalid flag: %FLAG%
    exit /b -255
  ) >&2

  shift

  rem read until no flags
  if not "%FLAG%" == "--" goto FLAGS_LOOP
)

set "CHCP_EXEC="
if exist "%SystemRoot%\System32\chcp.com" set "CHCP_EXEC=%SystemRoot%\System32\chcp.com"
if not defined CHCP_EXEC if exist "%SystemRoot%\System64\chcp.com" set "CHCP_EXEC=%SystemRoot%\System64\chcp.com"

if not defined CHCP_EXEC (
  echo;%?~nx0% error: `chcp.com` is not found.
  exit /b 255
) >&2

rem read current code page
for /F "usebackq tokens=1,* delims=:"eol^= %%i in (`@"%CHCP_EXEC%" 2^>nul`) do set "LAST_CP=%%j"

if defined LAST_CP set "LAST_CP=%LAST_CP: =%"
if not defined LAST_CP set FLAG_NO_RESTORE=1

set LAST_ERROR=0
set PREV_CODE_PAGE=0

set "LINE="
set "DESCRIPTION="

for /F "usebackq tokens=* delims="eol^= %%i in ("%TEST_DATA_IN_ROOT%/%TEST_SCRIPT_FILE_NAME%/cp.lst") do ^
for /F "tokens=1,* delims=|" %%j in ("%%i") do set "LINE=%%i" & set "LINE0=%%j" & set "DESCRIPTION=%%k" & call :PROCESS_LINE

if %FLAG_PRINT_VALID% EQU 0 ^
if %PREV_CODE_PAGE% NEQ 0 if %LAST_CP% NEQ %PREV_CODE_PAGE% call :CHCP %%PREV_CODE_PAGE%%

exit /b 0

:PROCESS_LINE
if defined LINE0 set "LINE0=%LINE0: =%"

set "CODE_PAGE=%LINE0%"
set "CODE_PAGE_ATTR= "

set EXCLUDE_CODE_PAGE=0
if defined CODE_PAGE if "%CODE_PAGE:~0,1%" == "!" (
  set EXCLUDE_CODE_PAGE=1
  set "CODE_PAGE_ATTR=!"
  set "CODE_PAGE=%CODE_PAGE:~1%"
)

set "CODE_PAGE_STR=%CODE_PAGE%"

rem cast to integer
set /A CODE_PAGE_INT=CODE_PAGE

if %CODE_PAGE_INT% EQU 0 goto SKIP_CHCP
if %FLAG_PRINT_VALID% EQU 0 goto PRINT_VALID_END

if %EXCLUDE_CODE_PAGE% NEQ 0 if %FLAG_NO_EXCLUDE% EQU 0 exit /b 0

if "%CODE_PAGE_STR:~4,1%" == "" set CODE_PAGE_STR= %CODE_PAGE_STR%
if "%CODE_PAGE_STR:~4,1%" == "" set CODE_PAGE_STR= %CODE_PAGE_STR%
if "%CODE_PAGE_STR:~4,1%" == "" set CODE_PAGE_STR= %CODE_PAGE_STR%
if "%CODE_PAGE_STR:~4,1%" == "" set CODE_PAGE_STR= %CODE_PAGE_STR%

set "CODE_PAGE_INT_STR=%CODE_PAGE_INT%"

if "%CODE_PAGE_INT_STR:~4,1%" == "" set CODE_PAGE_INT_STR= %CODE_PAGE_INT_STR%
if "%CODE_PAGE_INT_STR:~4,1%" == "" set CODE_PAGE_INT_STR= %CODE_PAGE_INT_STR%
if "%CODE_PAGE_INT_STR:~4,1%" == "" set CODE_PAGE_INT_STR= %CODE_PAGE_INT_STR%
if "%CODE_PAGE_INT_STR:~4,1%" == "" set CODE_PAGE_INT_STR= %CODE_PAGE_INT_STR%

set LAST_ERROR=0
if %LAST_CP% NEQ %CODE_PAGE_INT% call :CHCP %%CODE_PAGE_INT%% || set LAST_ERROR=1

if %LAST_ERROR% EQU 0 setlocal ENABLEDELAYEDEXPANSION & ^
for /F "tokens=* delims="eol^= %%i in ("<!CODE_PAGE_ATTR!!CODE_PAGE_STR!>[!CODE_PAGE_INT_STR!] | !DESCRIPTION!") do endlocal & echo;%%i

exit /b 0

:PRINT_VALID_END

if %PREV_CODE_PAGE% NEQ 0 if %LAST_CP% NEQ %PREV_CODE_PAGE% call :CHCP %%PREV_CODE_PAGE%%

if %EXCLUDE_CODE_PAGE% EQU 0 (
  set PREV_CODE_PAGE=%CODE_PAGE_INT%
) else if %FLAG_NO_EXCLUDE% NEQ 0 (
  set PREV_CODE_PAGE=%CODE_PAGE_INT%
) else set PREV_CODE_PAGE=0

:SKIP_CHCP
setlocal ENABLEDELAYEDEXPANSION & for /F "usebackq tokens=* delims="eol^= %%i in ('"!LINE!"') do endlocal & echo;%%~i

exit /b 0

:CHCP
rem echo;^>%*
(
  if %FLAG_PRINT_VALID% EQU 0 (
    "%CHCP_EXEC%" %*
  ) else "%CHCP_EXEC%" %* 2>nul
  call set LAST_ERROR=%%ERRORLEVEL%%
  if %FLAG_NO_RESTORE% EQU 0 "%CHCP_EXEC%" %LAST_CP% 2>nul & rem restore immediately to avoid script execution breakage
) <nul >nul
exit /b %LAST_ERROR%
