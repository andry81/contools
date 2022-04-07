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

call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" . "%%?~n0%%" || (
  echo.%?~nx0%: error: could not allocate temporary directory: "%SCRIPT_TEMP_CURRENT_DIR%"
  set LASTERROR=255
  goto FREE_TEMP_DIR
) >&2

call :MAIN %%*
set LASTERROR=%ERRORLEVEL%

:FREE_TEMP_DIR
rem cleanup temporary files
call "%%CONTOOLS_ROOT%%/std/free_temp_dir.bat"

exit /b %LASTERROR%

:MAIN
rem script flags
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
  ) else (
    rem process only known flags
    goto FLAGS_LOOP_END
  )

  shift

  rem read until no flags
  goto FLAGS_LOOP
)

:FLAGS_LOOP_END

rem Uee {PAGENUM} as placeholder
set "URL_TMPL=%~1"

rem can be `.` to ignore
set "FROM_PAGE=%~2"
set "TO_PAGE=%~3"

rem Use {PAGENUM} as placeholder
set "OUT_FILE_NAME_TMPL=%~4"

if not defined FROM_PAGE (
  echo.%?~nx0%: error: FROM_PAGE is not defined.
  exit /b 10
) >&2

if not defined TO_PAGE (
  echo.%?~nx0%: error: TO_PAGE is not defined.
  exit /b 11
) >&2

if not defined OUT_FILE_NAME_TMPL (
  echo.%?~nx0%: error: OUT_FILE_NAME_TMPL is not defined.
  exit /b 12
) >&2

if "%FROM_PAGE%" == "." set "FROM_PAGE="
if "%TO_PAGE%" == "." set "TO_PAGE="

set "EMPTY_DIR_TMP=%SCRIPT_TEMP_CURRENT_DIR%\emptydir"

mkdir "%EMPTY_DIR_TMP%" || (
  echo.%?~n0%: error: could not create a directory: "%EMPTY_DIR_TMP%".
  exit /b 255
) >&2

set "CURL_ADAPTOR_DOWNLOAD_TEMP_DIR=%SCRIPT_TEMP_CURRENT_DIR%\download"
set "CURL_ADAPTOR_DOWNLOAD_DIR=%CURL_ADAPTOR_DOWNLOAD_DIR%"

mkdir "%CURL_ADAPTOR_DOWNLOAD_TEMP_DIR%" || (
  echo.%?~n0%: error: could not create a directory: "%CURL_ADAPTOR_DOWNLOAD_TEMP_DIR%".
  exit /b 255
) >&2

if not exist "%CURL_ADAPTOR_DOWNLOAD_DIR%\" mkdir "%CURL_ADAPTOR_DOWNLOAD_DIR%"

rem convert string to integer
if defined FROM_PAGE set /A "FROM_PAGE*=1"
if defined TO_PAGE set /A "TO_PAGE*=1"

if not defined FROM_PAGE goto NO_PAGES
if not defined TO_PAGE goto NO_PAGES

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
  call :PROCESS_URL %%5 %%6 %%7 %%8 %%9 || goto MAIN_EXIT
)

goto ARCHIVE_DOWNLOAD_DIR

:NO_PAGES

set "PAGE_NUM="
call :PROCESS_URL %%5 %%6 %%7 %%8 %%9 || goto MAIN_EXIT

:ARCHIVE_DOWNLOAD_DIR

echo.Archiving backup directory...
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/add_files_to_archive.bat" "%%CURL_ADAPTOR_DOWNLOAD_TEMP_DIR%%" "*" "%%CURL_ADAPTOR_DOWNLOAD_DIR%%/%%PROJECT_LOG_FILE_NAME_SUFFIX%%--%%OUT_FILE_NAME_TMPL%%.7z" -sdel || exit /b 20
echo.

:SKIP_ARCHIVE

:MAIN_EXIT
echo.

exit /b 0

:PROCESS_URL
if not defined PAGE_NUM goto URL_NO_PAGE

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
:URL_NO_PAGE

call set "URL=%%URL_TMPL:{PAGENUM}=%PAGE_NUM%%%"
call set "OUT_FILE_NAME=%%OUT_FILE_NAME_TMPL:{PAGENUM}=%PAGE_NUM%%%"

call :CMD "%%CURL_EXECUTABLE%%" -v %%* "%%URL%%" -o "%%CURL_ADAPTOR_DOWNLOAD_TEMP_DIR%%/%%OUT_FILE_NAME%%" || exit /b

call :XCOPY_DIR  "%%PROJECT_LOG_DIR%%"    "%%CURL_ADAPTOR_DOWNLOAD_TEMP_DIR%%/%%PROJECT_LOG_FILE_NAME_SUFFIX%%" /Y /D /H || exit /b 10

exit /b 0

:CMD
echo.^>%*
(
  %*
)
exit /b

:XCOPY_FILE
if not exist "\\?\%~f3" (
  echo.^>mkdir "%~3"
  call :MAKE_DIR "%%~3" || (
    echo.%?~nx0%: error: could not create a target file directory: "%~3".
    exit /b 255
  ) >&2
  echo.
)
call "%%CONTOOLS_ROOT%%/std/xcopy_file.bat" %%*
exit /b

:XCOPY_DIR
if not exist "\\?\%~f2" (
  echo.^>mkdir "%~2"
  call :MAKE_DIR "%%~2" || (
    echo.%?~nx0%: error: could not create a target directory: "%~2".
    exit /b 255
  ) >&2
  echo.
)
call "%%CONTOOLS_ROOT%%/std/xcopy_dir.bat" %%*
exit /b

:MAKE_DIR
for /F "eol= tokens=* delims=" %%i in ("%~1\.") do set "FILE_PATH=%%~fi"

mkdir "%FILE_PATH%" 2>nul || if exist "%SystemRoot%\System32\robocopy.exe" ( "%SystemRoot%\System32\robocopy.exe" /CREATE "%EMPTY_DIR_TMP%" "%FILE_PATH%" >nul ) else type 2>nul || (
  echo.%?~nx0%: error: could not create a target file directory: "%FILE_PATH%".
  exit /b 1
) >&2
exit /b
