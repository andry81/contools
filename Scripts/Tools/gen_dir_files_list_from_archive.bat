@echo off

setlocal

call "%%~dp0__init__.bat" || goto :EOF

set "?~n0=%~n0"
set "?~nx0=%~nx0"
set "?~dp0=%~dp0"

rem drop last error level
type nul>nul

rem get code page value from first parameter
set "LAST_CODE_PAGE="
set CODE_PAGE=%~1

shift

rem get and set code page
call "%%CONTOOLS_ROOT%%/std/chcp.bat" %%CODE_PAGE%%

set "FILE_FILTER=%~1"

rem ignore specific patterns to avoid problems
if not defined FILE_FILTER (
  echo.%?~nx0%: error: file or directory is not set.
  exit /b 1
) >&2
if "%FILE_FILTER:~0,1%" == "\" (
  echo.%?~nx0%: error: file or directory path is not acceptable: "%FILE_FILTER%".
  exit /b 2
) >&2

rem double evaluate to % ~dpf1 to handle case with the *
set "FILE_PATH=%~dpf1"

shift

if "%~1" == "" (
  echo.%?~nx0%: error: archive file filter is not set.
  exit /b 3
)

rem collect archive file filters
set "ARCHIVE_FILE_FILTERS_ARGS="
set ARCHIVE_FILE_FILTERS_INDEX=0

:ARCHIVE_FILE_FILTERS_LOOP
if %ARCHIVE_FILE_FILTERS_INDEX% NEQ 0 set ARCHIVE_FILE_FILTERS_ARGS=%ARCHIVE_FILE_FILTERS_ARGS% %1
if %ARCHIVE_FILE_FILTERS_INDEX% EQU 0 set ARCHIVE_FILE_FILTERS_ARGS=%1
shift

set /A ARCHIVE_FILE_FILTERS_INDEX+=1

if "%~1" == "" goto ARCHIVE_FILE_FILTERS_END

goto ARCHIVE_FILE_FILTERS_LOOP

:ARCHIVE_FILE_FILTERS_END

rem double evaluate to % ~dpf1 to handle case with the *: "*" -> "X:\YYY\."
call :PROCESS_FILE_PATH "%%FILE_PATH%%" || goto :EOF

rem restore code page
call "%%CONTOOLS_ROOT%%/std/restorecp.bat"

exit /b 0

:PROCESS_FILE_PATH
set "FILE_PATH=%~dpf1"

for /F "usebackq eol=	 tokens=* delims=" %%i in (`dir "%FILE_PATH%" /S /B /A:-D 2^>nul`) do (
  set "ARCHIVE_FILE_PATH=%%i"
  call :PROCESS_ARCHIVE_FILE || goto :EOF
)

goto :EOF

:PROCESS_ARCHIVE_FILE

call "%%CONTOOLS_ROOT%%/uuidgen.bat"
set "ARCHIVE_LIST_TEMP_FILE_TREE_DIR=%TEMP%\%?~n0%.%RETURN_VALUE%"

mkdir "%ARCHIVE_LIST_TEMP_FILE_TREE_DIR%"
rem safe all directory files remove except the directory
pushd "%ARCHIVE_LIST_TEMP_FILE_TREE_DIR%" && (
  rmdir /S /Q . 2>nul
  popd
)

call :PROCESS_ARCHIVE_FILE_IMPL
set LASTERROR=%ERRORLEVEL%

rem cleanup temporary files
rmdir /S /Q "%ARCHIVE_LIST_TEMP_FILE_TREE_DIR%"

exit /b %LASTERROR%

:PROCESS_ARCHIVE_FILE_IMPL
set ARCHIVE_LIST_FILTER=0
set ARCHIVE_LIST_EOF=0

for /F "usebackq eol=	 tokens=* delims=" %%i in (`@"%CONTOOLS_ROOT%/7zip/7za.exe" l "%ARCHIVE_FILE_PATH%"`) do (
  set "ARCHIVE_LIST_LINE=%%i"
  call :PROCESS_ARCHIVE_LIST_LINE || goto :EOF
  call :IS_ARCHIVE_LIST_EOF && goto PROCESS_ARCHIVE_FILE_IMPL_EXIT
)

:PROCESS_ARCHIVE_FILE_IMPL_EXIT
if %ERRORLEVEL% NEQ 0 goto :EOF

set "ARCHIVE_FILE_FILTER_PATH_ARGS="
call :PROCESS_ARCHIVE_FILE_FILTER %ARCHIVE_FILE_FILTERS_ARGS%

call "%%?~dp0%%gen_dir_files_list.bat" "%%CODE_PAGE%%" %%ARCHIVE_FILE_FILTER_PATH_ARGS%% || goto :EOF

goto :EOF

:PROCESS_ARCHIVE_FILE_FILTER
:PROCESS_ARCHIVE_FILE_FILTER_LOOP
if "%~1" == "" goto :EOF
set ARCHIVE_FILE_FILTER_PATH_ARGS=%ARCHIVE_FILE_FILTER_PATH_ARGS% "%ARCHIVE_LIST_TEMP_FILE_TREE_DIR%\%~1"

shift

goto PROCESS_ARCHIVE_FILE_FILTER_LOOP

:IS_ARCHIVE_LIST_EOF
if %ARCHIVE_LIST_EOF% NEQ 0 exit /b 0
exit /b 1

:PROCESS_ARCHIVE_LIST_LINE
if not defined ARCHIVE_LIST_LINE exit /b 0

if %ARCHIVE_LIST_FILTER% NEQ 0 (
  if "%ARCHIVE_LIST_LINE:~0,25%" == "------------------- -----" (
    set ARCHIVE_LIST_EOF=1
    exit /b 0
  )
) else (
  if "%ARCHIVE_LIST_LINE:~0,25%" == "------------------- -----" set ARCHIVE_LIST_FILTER=1
  exit /b 0
)

set "ARCHIVE_LIST_FILE_PATH=%ARCHIVE_LIST_LINE:~53%"

if not defined ARCHIVE_LIST_FILE_PATH exit /b 0

rem use attributes to determine directory path from file path
set "ARCHIVE_LIST_LINE_ATTR="
for /F "eol=	 tokens=3" %%i in ("%ARCHIVE_LIST_LINE%") do (
  set "ARCHIVE_LIST_LINE_ATTR=%%i"
)

set "ARCHIVE_LIST_FILE_PATH_ATTR0="
if defined ARCHIVE_LIST_LINE_ATTR (
  set "ARCHIVE_LIST_FILE_PATH_ATTR0=%ARCHIVE_LIST_LINE_ATTR:~0,1%"
)

rem create empty files tree in temporary directory to retrieve later a sorted file paths list by `dir` command
call :CREATE_TEMP_TREE_OF_EMPTY_FILES "%%ARCHIVE_LIST_FILE_PATH_ATTR0%%" "%%ARCHIVE_LIST_TEMP_FILE_TREE_DIR%%\%%ARCHIVE_LIST_FILE_PATH%%" || goto :EOF

exit /b 0

:CREATE_TEMP_TREE_OF_EMPTY_FILES
rem drop last error level
type nul>nul

set TEMP_FILE_PATH_IS_DIR_PATH=0
if "%~1" == "D" set TEMP_FILE_PATH_IS_DIR_PATH=1

if %TEMP_FILE_PATH_IS_DIR_PATH% EQU 0 (
  set "TEMP_FILE_DIR=%~dp2"
  set "TEMP_FILE_PATH=%~dpf2"
) else (
  set "TEMP_FILE_DIR=%~dpf2\"
  set "TEMP_FILE_PATH="
)

rem echo."%FILES_PATH_PREFIX%%INSTDIR_SUBDIR_SUFFIX%/%ARCHIVE_LIST_FILE_PATH:\=/%" >&2
if not exist "%TEMP_FILE_DIR%" ( mkdir "%TEMP_FILE_DIR%" || exit /b 1 )

rem create empty file
if defined TEMP_FILE_PATH (
  type nul > "%TEMP_FILE_PATH%"
)

goto :EOF
