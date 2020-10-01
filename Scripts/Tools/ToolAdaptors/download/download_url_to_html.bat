@echo off

setlocal

call "%%~dp0__init__.bat" || exit /b

if %IMPL_MODE%0 NEQ 0 goto IMPL

rem no local logging if nested call
set WITH_LOGGING=0
if %NEST_LVL%0 EQU 0 set WITH_LOGGING=1

if %WITH_LOGGING% EQU 0 goto IMPL

if not exist "%CONFIGURE_DIR%\.log" mkdir "%CONFIGURE_DIR%\.log"

rem use stdout/stderr redirection with logging
call "%%CONTOOLS_ROOT%%\get_wmic_local_datetime.bat"
set "LOG_FILE_NAME_SUFFIX=%RETURN_VALUE:~0,4%'%RETURN_VALUE:~4,2%'%RETURN_VALUE:~6,2%_%RETURN_VALUE:~8,2%'%RETURN_VALUE:~10,2%'%RETURN_VALUE:~12,2%''%RETURN_VALUE:~15,3%"

set IMPL_MODE=1
rem CAUTION:
rem   We should avoid use handles 3 and 4 while the redirection has take a place because handles does reuse
rem   internally from left to right when being redirected externally.
rem   Example: if `1` is redirected, then `3` is internally reused, then if `2` redirected, then `4` is internally reused and so on.
rem   The discussion of the logic:
rem   https://stackoverflow.com/questions/9878007/why-doesnt-my-stderr-redirection-end-after-command-finishes-and-how-do-i-fix-i/9880156#9880156
rem   A partial analisis:
rem   https://www.dostips.com/forum/viewtopic.php?p=14612#p14612
rem
"%COMSPEC%" /C call %0 %* 2>&1 | "%CONTOOLS_UTILITIES_BIN_ROOT%\unxutils\tee.exe" "%CONFIGURE_DIR%\.log\%LOG_FILE_NAME_SUFFIX%.%~nx0.log"
exit /b

:IMPL
set "?~dp0=%~dp0"
set "?~n0=%~n0"
set "?~nx0=%~nx0"

call :MAIN %%*
set "LASTERRORLEVEL=%ERRORLEVEL%"

exit /b %LASTERRORLEVEL%

:MAIN
rem script flags
set FLAG_OVERWRITE_OUTPUT_FILE=0

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-overwrite" (
    set FLAG_OVERWRITE_OUTPUT_FILE=1
  )

  shift

  rem read until no flags
  goto FLAGS_LOOP
)

rem Uee {PAGENUM} as placeholder
set "URL_TMPL=%~1"

set "FROM_PAGE=%~2"
set "TO_PAGE=%~3"

rem Uee {PAGENUM} as placeholder
set "OUT_FILE_PATH_TMPL=%~4"

if not defined FROM_PAGE (
  echo.%?~nx0%: error: FROM_PAGE is not defined.
  exit /b 10
) >&2

if not defined TO_PAGE (
  echo.%?~nx0%: error: TO_PAGE is not defined.
  exit /b 11
) >&2

if not defined OUT_FILE_PATH_TMPL (
  echo.%?~nx0%: error: OUT_FILE_PATH_TMPL is not defined.
  exit /b 12
) >&2

rem update to absolute variant
set "OUT_FILE_PATH_TMPL=%~f4"
set "OUT_FILE_DIR=%~dp4"

if not exist "%OUT_FILE_DIR%" (
  echo.%?~nx0%: error: OUT_FILE_DIR directory does not exist: "%OUT_FILE_DIR%".
  exit /b 20
) >&2

for /L %%i in (%FROM_PAGE%, 1, %TO_PAGE%) do (
  set PAGE_NUM=%%i
  call :PROCESS_PAGE
)

exit /b 0

:PROCESS_PAGE
call set "URL=%%URL_TMPL:{PAGENUM}=%PAGE_NUM%%%"
call set "OUT_FILE_PATH=%%OUT_FILE_PATH_TMPL:{PAGENUM}=%PAGE_NUM%%%"

if exist "%OUT_FILE_PATH%" (
  if %FLAG_OVERWRITE_OUTPUT_FILE%0 EQU 0 (
    echo.%?~nx0%: warning: "%OUT_FILE_PATH%" file is already exist, overwrite is not allowed, ignored.
    exit /b 0
  )
)

call :CMD certutil -urlcache -split -f "%%URL%%" "%%OUT_FILE_PATH%%"
exit /b

:CMD
echo.^>%*
(%*)
