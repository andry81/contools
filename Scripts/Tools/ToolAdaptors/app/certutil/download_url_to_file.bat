@echo off

setlocal

call "%%~dp0__init__\__init__.bat" || exit /b

if %IMPL_MODE%0 NEQ 0 goto IMPL

call "%%CONTOOLS_PROJECT_ROOT%%/__init__/declare_builtins.bat" %%0 %%*

for %%i in (CONTOOLS_ROOT CONTOOLS_UTILITIES_BIN_ROOT) do (
  if not defined %%i (
    echo.%~nx0: error: `%%i` variable is not defined.
    exit /b 255
  ) >&2
)

call "%%CONTOOLS_ROOT%%/build/init_project_log.bat" "%%?~n0%%" || exit /b

set "INIT_VARS_FILE=%PROJECT_LOG_DIR%\init.vars"

rem register all environment variables
set 2>nul > "%INIT_VARS_FILE%"

"%CONTOOLS_UTILITIES_BIN_ROOT%/contools/callf.exe" ^
  /ret-child-exit /pause-on-exit /tee-stdout "%PROJECT_LOG_FILE%" /tee-stderr-dup 1 ^
  /v IMPL_MODE 1 /v INIT_VARS_FILE "%INIT_VARS_FILE%" ^
  /ra "%%" "%%?01%%" /v "?01" "%%" ^
  "${COMSPEC}" "/c \"@\"${?~f0}\" {*}\"" %* || exit /b

exit /b 0

:IMPL

rem load initialization environment variables
for /F "usebackq eol=# tokens=1,* delims==" %%i in ("%INIT_VARS_FILE%") do set "%%i=%%j"

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
set "FLAG_ZERO_PAD="

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-zeropad" (
    set "FLAG_ZERO_PAD=%~2"
    shift
  ) else if "%FLAG%" == "-overwrite" (
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

rem Use {PAGENUM} as placeholder
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

rem convert string to integer
set /A "FROM_PAGE*=1"
set /A "TO_PAGE*=1"

if %FROM_PAGE% LSS 0 (
  echo.%?~nx0%: error: FROM_PAGE must be not negative number: "%FROM_PAGE%".
  exit /b 30
) >&2

if %TO_PAGE% LSS 0 (
  echo.%?~nx0%: error: TO_PAGE must be not negative number: "%TO_PAGE%".
  exit /b 31
) >&2

for /L %%i in (%FROM_PAGE%, 1, %TO_PAGE%) do (
  set PAGE_NUM=%%i
  call :PROCESS_PAGE
)

exit /b 0

:PROCESS_PAGE
if not defined FLAG_ZERO_PAD goto FLAG_ZERO_PAD_END
if 0 GEQ %FLAG_ZERO_PAD% goto FLAG_ZERO_PAD_END

rem safely count digits
set PAGE_NUM_DIGITS=1
set PAGE_NUM_NEXT_DECS=10

:PAGE_NUM_DIGITS_LOOP
if %PAGE_NUM% LSS %PAGE_NUM_NEXT_DECS% goto PAGE_NUM_DIGITS_LOOP_END

set "PAGE_NUM_PREV_DECS=%PAGE_NUM_NEXT_DECS%"
set /A "PAGE_NUM_NEXT_DECS*=10"
set /A "PAGE_NUM_DECS_FACTOR=%PAGE_NUM_NEXT_DECS% / %PAGE_NUM_PREV_DECS%"

if not "%PAGE_NUM_DECS_FACTOR%" == "10" goto PAGE_NUM_DIGITS_LOOP_END

set /A "PAGE_NUM_DIGITS+=1"

goto PAGE_NUM_DIGITS_LOOP

:PAGE_NUM_DIGITS_LOOP_END

if not defined FLAG_ZERO_PAD goto FLAG_ZERO_PAD_END

if %FLAG_ZERO_PAD% LSS %PAGE_NUM_DIGITS% goto FLAG_ZERO_PAD_END

set "PAGE_NUM=0000000000000000%PAGE_NUM%"
call set "PAGE_NUM=%%PAGE_NUM:~-%FLAG_ZERO_PAD%%%"

:FLAG_ZERO_PAD_END

call set "URL=%%URL_TMPL:{PAGENUM}=%PAGE_NUM%%%"
call set "OUT_FILE_PATH=%%OUT_FILE_PATH_TMPL:{PAGENUM}=%PAGE_NUM%%%"

if exist "%OUT_FILE_PATH%" (
  if %FLAG_OVERWRITE_OUTPUT_FILE%0 EQU 0 (
    echo.%?~nx0%: warning: "%OUT_FILE_PATH%" file is already exist, overwrite is not allowed, ignored.
    exit /b 0
  )
)

pushd "%OUT_FILE_DIR%" && (
  call :CMD certutil -urlcache -split -f "%%URL%%" "%%OUT_FILE_PATH%%"
  popd
  exit /b
)

:CMD
echo.^>%*
(
  %*
)
