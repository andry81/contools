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
call "%%CONTOOLS_ROOT%%\std\get_wmic_local_datetime.bat"
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
"%COMSPEC%" /C call %0 %* 2>&1 | "%CONTOOLS_ROOT%\unxutils\tee.exe" "%CONFIGURE_DIR%\.log\%LOG_FILE_NAME_SUFFIX%.%~nx0.log"
exit /b

:IMPL
set "?~dp0=%~dp0"
set "?~n0=%~n0"
set "?~nx0=%~nx0"

set /A NEST_LVL+=1

call :MAIN %%*
set "LASTERRORLEVEL=%ERRORLEVEL%"

set /A NEST_LVL-=1

if %NEST_LVL% LEQ 0 pause

exit /b %LASTERRORLEVEL%

:MAIN
rem script flags
set FLAG_OVERWRITE_OUTPUT_FILE=0
set "BARE_FLAGS="

chcp 65001

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  set BARE_FLAGS=%BARE_FLAGS% %1

  shift

  rem read until no flags
  goto FLAGS_LOOP
)


set "FROM_PAGE=%~1"
set "TO_PAGE=%~2"

call "%%CONTOOLS_ROOT%%\ToolAdapters\download\download_url_to_html.bat"%%BARE_FLAGS%% "domain/url-{PAGENUM}" "%%FROM_PAGE%%" "%%TO_PAGE%%" "file #{PAGENUM}.html"
