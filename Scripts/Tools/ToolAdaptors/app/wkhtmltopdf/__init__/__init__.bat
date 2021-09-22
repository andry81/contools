@echo off

if /i "%WKHTMLTOPDF_ADAPTOR_PROJECT_ROOT_INIT0_DIR%" == "%~dp0" exit /b 0

call "%%~dp0..\..\__init__\__init__.bat" || exit /b

set "WKHTMLTOPDF_ADAPTOR_PROJECT_ROOT_INIT0_DIR=%~dp0"

if not defined NEST_LVL set NEST_LVL=0

if not defined WKHTMLTOPDF_ADAPTOR_PROJECT_ROOT                call :CANONICAL_PATH WKHTMLTOPDF_ADAPTOR_PROJECT_ROOT                "%%~dp0.."

if not defined WKHTMLTOPDF_ADAPTOR_PROJECT_INPUT_CONFIG_ROOT   call :CANONICAL_PATH WKHTMLTOPDF_ADAPTOR_PROJECT_INPUT_CONFIG_ROOT   "%%WKHTMLTOPDF_ADAPTOR_PROJECT_ROOT%%/_config"
if not defined WKHTMLTOPDF_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT  call :CANONICAL_PATH WKHTMLTOPDF_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT  "%%PROJECT_OUTPUT_ROOT%%/config/contools/tool_adaptors/wkhtmltopdf"

if not exist "%WKHTMLTOPDF_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%\" ( mkdir "%WKHTMLTOPDF_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%" || exit /b 10 )

call "%%CONTOOLS_ROOT%%/build/load_config_dir.bat" -gen_user_config "%%WKHTMLTOPDF_ADAPTOR_PROJECT_INPUT_CONFIG_ROOT%%" "%%WKHTMLTOPDF_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%%" || exit /b

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
