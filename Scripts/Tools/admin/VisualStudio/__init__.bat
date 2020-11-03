@echo off

if defined CONTOOLS_PROJECT_ROOT_INIT0_DIR goto INIT

set LASTERRORLEVEL=0

rem init script search logic
for %%i in ("%~dp0.." "%~dp0..\..") do (
  for %%j in ("__init__.bat" "__init__\__init__.bat") do (
    call :INCLUDE %%i %%j && (
      setlocal ENABLEDELAYEDEXPANSION & for %%i in (!LASTERRORLEVEL!) do (
        endlocal
        set "LASTERRORLEVEL="
        call :INIT
        exit /b %%i
      )
    )
  )
)

set "LASTERRORLEVEL="

call :INIT

exit /b

:INCLUDE
call :HAS_RECURSION "%%~1\%%~2" && exit /b 1
if not exist "%~1\%~2" exit /b 1
call "%%~1\%%~2"
set LASTERRORLEVEL=%ERRORLEVEL%
exit /b 0

:HAS_RECURSION
if /i "%~f1" == "%~f0" exit /b 0
exit /b 1

:INIT
if /i "%MSVC_LAYOUT_SCRIPTS_INIT0_DIR%" == "%~dp0" exit /b

set "MSVC_LAYOUT_SCRIPTS_INIT0_DIR=%~dp0"

if defined CONFIGURE_DIR goto IGNORE_CONFIGURE_DIR

set "CONFIGURE_DIR=%~dp0"
set "CONFIGURE_DIR=%CONFIGURE_DIR:~0,-1%"

:IGNORE_CONFIGURE_DIR
if not defined CONTOOLS_ROOT set "CONTOOLS_ROOT=%CONFIGURE_DIR%\tools"

if not defined NEST_LVL set NEST_LVL=0

call "%%CONTOOLS_ROOT%%\std\load_config.bat" "%%CONFIGURE_DIR%%" "config.vars" || (
  echo.%~nx0: error: config.vars is not loaded.
  exit /b 255
) >&2

exit /b 0
