@echo off

if /i "%DOWNLOAD_ADAPTOR_PROJECT_ROOT_INIT0_DIR%" == "%~dp0" exit /b 0

call "%%~dp0..\..\__init__\__init__.bat" || exit /b

set "DOWNLOAD_ADAPTOR_PROJECT_ROOT_INIT0_DIR=%~dp0"

if not defined NEST_LVL set NEST_LVL=0

if not defined DOWNLOAD_ADAPTOR_PROJECT_ROOT                call :CANONICAL_PATH DOWNLOAD_ADAPTOR_PROJECT_ROOT                "%%~dp0.."

if not defined DOWNLOAD_ADAPTOR_PROJECT_INPUT_CONFIG_ROOT   call :CANONICAL_PATH DOWNLOAD_ADAPTOR_PROJECT_INPUT_CONFIG_ROOT   "%%DOWNLOAD_ADAPTOR_PROJECT_ROOT%%/_config"
if not defined DOWNLOAD_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT  call :CANONICAL_PATH DOWNLOAD_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT  "%%PROJECT_OUTPUT_ROOT%%/config/download_adaptor"

if not exist "%DOWNLOAD_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%\" ( mkdir "%DOWNLOAD_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%" || exit /b 10 )

call "%%CONTOOLS_ROOT%%/build/load_config_dir.bat" -gen_user_config "%%DOWNLOAD_ADAPTOR_PROJECT_INPUT_CONFIG_ROOT%%" "%%DOWNLOAD_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%%" || exit /b

call :IF_DEFINED_AND_FILE_EXIST WKHTMLTOPDF_EXE || (
  echo.%~nx0: error: WKHTMLTOPDF_EXE file is not found: "%WKHTMLTOPDF_EXE%".
  exit /b 1
) >&2

call :CANONICAL_PATH DOWNLOAD_ADAPTOR_HTML_DIR    "%%DOWNLOAD_ADAPTOR_HTML_DIR%%"
call :CANONICAL_PATH DOWNLOAD_ADAPTOR_PDF_DIR     "%%DOWNLOAD_ADAPTOR_PDF_DIR%%"

if not exist "%DOWNLOAD_ADAPTOR_HTML_DIR%\" ( mkdir "%DOWNLOAD_ADAPTOR_HTML_DIR%" || exit /b 11 )
if not exist "%DOWNLOAD_ADAPTOR_PDF_DIR%\" ( mkdir "%DOWNLOAD_ADAPTOR_PDF_DIR%" || exit /b 12 )

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
