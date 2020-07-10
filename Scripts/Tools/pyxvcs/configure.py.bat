@echo off

rem rem implementation through the `python` 3.x + `plumbum` module
rem 
rem setlocal
rem 
rem call "%%~dp0__init__.bat" || exit /b
rem 
rem "%PYTHON_EXE_PATH%" "%~dp0configure.xsh" %*
rem exit /b

setlocal

call "%%~dp0__init__.bat" || exit /b

for %%i in (PROJECT_ROOT CONTOOLS_ROOT PYTHON_EXE_PATH PYXVCS_PYTHON_SCRIPTS_ROOT) do (
  if not defined %%i (
    echo.%~nx0: error: `%%i` variable is not defined.
    exit /b 255
  ) >&2
)

if %IMPL_MODE%0 NEQ 0 goto IMPL

rem no local logging if nested call
set WITH_LOGGING=0
if %NEST_LVL%0 EQU 0 set WITH_LOGGING=1

if %WITH_LOGGING% EQU 0 goto IMPL

if not exist "%PROJECT_ROOT%\.log" mkdir "%PROJECT_ROOT%\.log"

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
"%COMSPEC%" /C call %0 %* 2>&1 | "%CONTOOLS_ROOT%\unxutils\tee.exe" "%PROJECT_ROOT%\.log\%LOG_FILE_NAME_SUFFIX%.%~nx0.log"
exit /b

:IMPL
set /A NEST_LVL+=1

call :MAIN %%*

set /A NEST_LVL-=1

if %NEST_LVL% LEQ 0 pause

:MAIN
rem no local logging if nested call
call :CMD "%%PYTHON_EXE_PATH%%" "%%PYXVCS_PYTHON_SCRIPTS_ROOT%%/configure.xsh" %%*
exit /b

:CMD
echo.^>%*
echo.
(
  %*
)
exit /b
