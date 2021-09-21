@echo off

setlocal

set "?~0=%~0"
set "?~f0=%~f0"
set "?~dp0=%~dp0"
set "?~n0=%~n0"
set "?~nx0=%~nx0"
set "?~x0=%~x0"

call "%%~dp0__init__\__init__.bat" || exit /b

for %%i in (CONTOOLS_PROJECT_ROOT PROJECT_LOG_ROOT CONTOOLS_ROOT CONTOOLS_UTILITIES_BIN_ROOT) do (
  if not defined %%i (
    echo.%~nx0: error: `%%i` variable is not defined.
    exit /b 255
  ) >&2
)

if %IMPL_MODE%0 NEQ 0 goto IMPL

rem use stdout/stderr redirection with logging
call "%%CONTOOLS_ROOT%%\wmi\get_wmic_local_datetime.bat"
set "PROJECT_LOG_FILE_NAME_SUFFIX=%RETURN_VALUE:~0,4%'%RETURN_VALUE:~4,2%'%RETURN_VALUE:~6,2%_%RETURN_VALUE:~8,2%'%RETURN_VALUE:~10,2%'%RETURN_VALUE:~12,2%''%RETURN_VALUE:~15,3%"

set "PROJECT_LOG_DIR=%PROJECT_LOG_ROOT%\%PROJECT_LOG_FILE_NAME_SUFFIX%.%?~n0%"
set "PROJECT_LOG_FILE=%PROJECT_LOG_DIR%\%PROJECT_LOG_FILE_NAME_SUFFIX%.%?~n0%.log"

if not exist "%PROJECT_LOG_DIR%" ( mkdir "%PROJECT_LOG_DIR%" || exit /b )

set ?__CMDLINE__=%*
"%CONTOOLS_UTILITIES_BIN_ROOT%/contools/callf.exe" ^
  /ret-child-exit /pause-on-exit /tee-stdout "%PROJECT_LOG_FILE%" /tee-stderr-dup 1 ^
  /v IMPL_MODE 1 /ra "%%" "%%?01%%" /v "?01" "%%" ^
  /E0 /S1 /E2 /E3 ^
  "${COMSPEC}" "/c \"@\"{0}\" {1}\"" "${?~f0}" "${?__CMDLINE__}"
exit /b

:IMPL
rem call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" . "%%?~n0%%" || (
rem   echo.%?~nx0%: error: could not allocate temporary directory: "%SCRIPT_TEMP_CURRENT_DIR%"
rem   set LASTERROR=255
rem   goto FREE_TEMP_DIR
rem ) >&2

call :MAIN %%*
set LASTERROR=%ERRORLEVEL%

rem :FREE_TEMP_DIR
rem rem cleanup temporary files
rem call "%%CONTOOLS_ROOT%%/std/free_temp_dir.bat"

exit /b %LASTERROR%

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

pushd "%OUT_FILE_DIR%" && (
  call :CMD "%%WKHTMLTOPDF_EXE%%" "%%URL%%" "%%OUT_FILE_PATH%%"
  popd
  exit /b
)

:CMD
echo.^>%*
(
  %*
)
