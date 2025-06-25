@echo off

setlocal DISABLEDELAYEDEXPANSION

call "%%~dp0__init__.bat" || exit /b

call "%%CONTOOLS_ROOT%%/std/declare_builtins.bat" %%0 %%* || exit /b

rem get code page value from first parameter
set "LAST_CODE_PAGE="
set CODE_PAGE=%~1

shift

rem get and set code page
call "%%CONTOOLS_ROOT%%/std/chcp.bat" %%CODE_PAGE%%

set "FILE_FILTER=%~1"

rem ignore specific patterns to avoid problems
if not defined FILE_FILTER (
  echo;%?~%: error: file or directory is not set.
  exit /b 1
) >&2
if "%FILE_FILTER:~0,1%" == "\" (
  echo;%?~%: error: path is not acceptable: "%FILE_FILTER%".
  exit /b 2
) >&2

rem double evaluate to % ~f1 to handle case with the *
set "FILE_PATH=%~f1"

shift

if "%~1" == "" (
  echo;%?~%: error: archive file filter is not set.
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

rem double evaluate to % ~f1 to handle case with the *: "*" -> "X:\YYY\."
call :PROCESS_FILE_PATH "%%FILE_PATH%%" || exit /b

rem restore code page
call "%%CONTOOLS_ROOT%%/std/restorecp.bat"

exit /b 0

:PROCESS_FILE_PATH
set "FILE_PATH=%~f1"

rem CAUTION:
rem   1. If a variable is empty, then it would not be expanded in the `cmd.exe`
rem      command line or in the inner expression of the
rem      `for /F "usebackq ..." %%i in (`<inner-expression>`) do ...`
rem      statement.
rem   2. The `cmd.exe` command line or the inner expression of the
rem      `for /F "usebackq ..." %%i in (`<inner-expression>`) do ...`
rem      statement does expand twice.
rem
rem   We must expand the command line into a variable to avoid these above.
rem
set ?.=@dir "%FILE_PATH%" /A:-D /B /O:N /S 2^>nul

for /F "usebackq tokens=* delims="eol^= %%i in (`%%?.%%`) do (
  set "ARCHIVE_FILE_PATH=%%i"
  call :PROCESS_ARCHIVE_FILE || exit /b
)

exit /b

:PROCESS_ARCHIVE_FILE

if defined SCRIPT_TEMP_CURRENT_DIR (
  set "ARCHIVE_LIST_TEMP_FILE_TREE_DIR=%SCRIPT_TEMP_CURRENT_DIR%\%?~n0%.%RANDOM%-%RANDOM%"
) else set "ARCHIVE_LIST_TEMP_FILE_TREE_DIR=%TEMP%\%?~n0%.%RANDOM%-%RANDOM%"

mkdir "%ARCHIVE_LIST_TEMP_FILE_TREE_DIR%"
rem safe all directory files remove except the directory
pushd "%ARCHIVE_LIST_TEMP_FILE_TREE_DIR%" && (
  rmdir /S /Q . 2>nul
  popd
)

call :PROCESS_ARCHIVE_FILE_IMPL
set LAST_ERROR=%ERRORLEVEL%

rem cleanup temporary files
rmdir /S /Q "%ARCHIVE_LIST_TEMP_FILE_TREE_DIR%"

exit /b %LAST_ERROR%

:PROCESS_ARCHIVE_FILE_IMPL
set ARCHIVE_LIST_FILTER=0
set ARCHIVE_LIST_EOF=0

for /F "usebackq tokens=* delims="eol^= %%i in (`@"%CONTOOLS_ROOT%/arc/7zip/7z.bat" l "%ARCHIVE_FILE_PATH%"`) do (
  set "ARCHIVE_LIST_LINE=%%i"
  call :PROCESS_ARCHIVE_LIST_LINE || exit /b
  call :IS_ARCHIVE_LIST_EOF && goto PROCESS_ARCHIVE_FILE_IMPL_EXIT
)

:PROCESS_ARCHIVE_FILE_IMPL_EXIT
if %ERRORLEVEL% NEQ 0 exit /b

set "ARCHIVE_FILE_FILTER_PATH_ARGS="
call :PROCESS_ARCHIVE_FILE_FILTER %ARCHIVE_FILE_FILTERS_ARGS%

call "%%?~dp0%%gen_dir_files_list.bat" "%%CODE_PAGE%%" %%ARCHIVE_FILE_FILTER_PATH_ARGS%% || exit /b

exit /b

:PROCESS_ARCHIVE_FILE_FILTER
:PROCESS_ARCHIVE_FILE_FILTER_LOOP
if "%~1" == "" exit /b
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
for /F "tokens=3"eol^= %%i in ("%ARCHIVE_LIST_LINE%") do set "ARCHIVE_LIST_LINE_ATTR=%%i"

set "ARCHIVE_LIST_FILE_PATH_ATTR0="
if defined ARCHIVE_LIST_LINE_ATTR set "ARCHIVE_LIST_FILE_PATH_ATTR0=%ARCHIVE_LIST_LINE_ATTR:~0,1%"

rem create empty files tree in temporary directory to retrieve later a sorted file paths list by `dir` command
call :CREATE_TEMP_TREE_OF_EMPTY_FILES "%%ARCHIVE_LIST_FILE_PATH_ATTR0%%" "%%ARCHIVE_LIST_TEMP_FILE_TREE_DIR%%\%%ARCHIVE_LIST_FILE_PATH%%" || exit /b

exit /b 0

:CREATE_TEMP_TREE_OF_EMPTY_FILES
rem drop last error level
call;

set TEMP_FILE_PATH_IS_DIR_PATH=0
if "%~1" == "D" set TEMP_FILE_PATH_IS_DIR_PATH=1

if %TEMP_FILE_PATH_IS_DIR_PATH% EQU 0 (
  set "TEMP_FILE_DIR=%~dp2"
  set "TEMP_FILE_PATH=%~f2"
) else (
  set "TEMP_FILE_DIR=%~f2\"
  set "TEMP_FILE_PATH="
)

rem echo;"%FILES_PATH_PREFIX%%INSTDIR_SUBDIR_SUFFIX%/%ARCHIVE_LIST_FILE_PATH:\=/%" >&2
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/mkdir_if_notexist.bat" "%%TEMP_FILE_DIR%%" >nul || exit /b 1

rem create empty file
if defined TEMP_FILE_PATH type nul > "%TEMP_FILE_PATH%"

exit /b
