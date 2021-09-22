@echo off

if /i "%CERTUTIL_ADAPTOR_PROJECT_ROOT_INIT0_DIR%" == "%~dp0" exit /b 0

call "%%~dp0..\..\__init__\__init__.bat" || exit /b

set "CERTUTIL_ADAPTOR_PROJECT_ROOT_INIT0_DIR=%~dp0"

if not defined NEST_LVL set NEST_LVL=0

if not defined CERTUTIL_ADAPTOR_PROJECT_ROOT                call :CANONICAL_PATH CERTUTIL_ADAPTOR_PROJECT_ROOT                "%%~dp0.."

if not defined CERTUTIL_ADAPTOR_PROJECT_INPUT_CONFIG_ROOT   call :CANONICAL_PATH CERTUTIL_ADAPTOR_PROJECT_INPUT_CONFIG_ROOT   "%%CERTUTIL_ADAPTOR_PROJECT_ROOT%%/_config"
if not defined CERTUTIL_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT  call :CANONICAL_PATH CERTUTIL_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT  "%%PROJECT_OUTPUT_ROOT%%/config/tool_adaptors/certutil"

if not exist "%CERTUTIL_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%\" ( mkdir "%CERTUTIL_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%" || exit /b 10 )

call "%%CONTOOLS_ROOT%%/build/load_config_dir.bat" -gen_user_config "%%CERTUTIL_ADAPTOR_PROJECT_INPUT_CONFIG_ROOT%%" "%%CERTUTIL_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%%" || exit /b

if defined CHCP chcp %CHCP%

exit /b 0

:IF_DEFINED_AND_FILE_EXIST
setlocal
if "%~1" == "" exit /b 1
if not defined %~1 exit /b 1
call set "DIR_PATH=%%%~1%%"
if not defined DIR_PATH exit /b 1
if not exist "%DIR_PATH%" exit /b 1
exit /b 0

:IF_DEFINED_AND_DIR_EXIST
setlocal
if "%~1" == "" exit /b 1
if not defined %~1 exit /b 1
call set "DIR_PATH=%%%~1%%"
if not defined DIR_PATH exit /b 1
if not exist "%DIR_PATH%\" exit /b 1
exit /b 0

:CANONICAL_PATH
setlocal DISABLEDELAYEDEXPANSION
for /F "eol= tokens=* delims=" %%i in ("%~2\.") do set "RETURN_VALUE=%%~fi"
rem set "RETURN_VALUE=%RETURN_VALUE:\=/%"
(
  endlocal
  set "%~1=%RETURN_VALUE%"
)
exit /b 0
