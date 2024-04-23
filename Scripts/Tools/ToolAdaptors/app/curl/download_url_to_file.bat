@echo off

setlocal

call "%%~dp0../__init__/script_init.bat" %%0 %%* || exit /b
if %IMPL_MODE%0 EQU 0 exit /b

call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" . "%%?~n0%%" || exit /b

call :MAIN %%*
set LAST_ERROR=%ERRORLEVEL%

:FREE_TEMP_DIR
rem cleanup temporary files
call "%%CONTOOLS_ROOT%%/std/free_temp_dir.bat"

exit /b %LAST_ERROR%

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

rem Use {PAGENUM} as placeholder
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

set "CURL_ADAPTOR_DOWNLOAD_TEMP_DIR=%SCRIPT_TEMP_CURRENT_DIR%\download"
set "CURL_ADAPTOR_DOWNLOAD_DIR=%CURL_ADAPTOR_DOWNLOAD_DIR%"

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/mkdir.bat" "%%CURL_ADAPTOR_DOWNLOAD_TEMP_DIR%%" >nul || exit /b 255

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/mkdir_if_notexist.bat" "%%CURL_ADAPTOR_DOWNLOAD_DIR%%" || exit /b

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

call "%%CONTOOLS_ROOT%%/std/setshift.bat" 4 CURL_FLAGS %%*

for /L %%i in (%FROM_PAGE%,1,%TO_PAGE%) do (
  set PAGE_NUM=%%i
  call :PROCESS_URL %%CURL_FLAGS%% || goto MAIN_EXIT
)

goto ARCHIVE_DOWNLOAD_DIR

:NO_PAGES

set "PAGE_NUM="

call :PROCESS_URL %%CURL_FLAGS%% || goto MAIN_EXIT

:ARCHIVE_DOWNLOAD_DIR

echo.Archiving backup directory...
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/add_files_to_archive.bat" "%%CURL_ADAPTOR_DOWNLOAD_TEMP_DIR%%" "*" "%%CURL_ADAPTOR_DOWNLOAD_DIR%%/%%PROJECT_LOG_FILE_NAME_DATE_TIME%%--%%OUT_FILE_NAME_TMPL%%.7z" -sdel || exit /b 20
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

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/call.bat" "%%CURL_EXECUTABLE%%" -v %%* "%%URL%%" -o "%%CURL_ADAPTOR_DOWNLOAD_TEMP_DIR%%/%%OUT_FILE_NAME%%" || exit /b

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/xcopy_dir.bat"  "%%PROJECT_LOG_DIR%%"    "%%CURL_ADAPTOR_DOWNLOAD_TEMP_DIR%%/%%PROJECT_LOG_FILE_NAME_DATE_TIME%%" /Y /D /H || exit /b 10

exit /b 0
