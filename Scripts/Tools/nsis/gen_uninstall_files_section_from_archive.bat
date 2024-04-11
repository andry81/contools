@echo off

rem FILE OUTPUT EXAMPLE:
rem  Delete "$INSTDIR\uninst.exe"
rem  Delete "$INSTDIR\universal_tract\XORBitstreams.dll"
rem  Delete "$INSTDIR\universal_tract\VSatSync.dll"
rem  RMDir "$INSTDIR\universal_tract"

setlocal

call "%%~dp0__init__.bat" || exit /b

call "%%CONTOOLS_ROOT%%/std/declare_builtins.bat" %%0 %%* || exit /b

rem get code page value from first parameter
set "LAST_CODE_PAGE="
set "CODE_PAGE=%~1"

shift

rem get and set code page
call "%%CONTOOLS_ROOT%%/std/chcp.bat" %%CODE_PAGE%%

set "FILES_PATH_PREFIX=%~1"
set "INSTDIR_SUBDIR=%~2"
set "FILE_FILTER=%~3"

shift
shift
shift

set "INSTDIR_SUBDIR_SUFFIX="
if defined INSTDIR_SUBDIR set "INSTDIR_SUBDIR_SUFFIX=\%INSTDIR_SUBDIR%"
set "FILE_FILTER_SUFFIX="
if defined FILE_FILTER set "FILE_FILTER_SUFFIX=\%FILE_FILTER%"

:PROCESS_DIR_LOOP
call :PROCESS_DIR_PATH "%%~1" || exit /b

shift 

if exist "%~1" goto PROCESS_DIR_LOOP

rem restore code page
call "%%CONTOOLS_ROOT%%/std/restorecp.bat"

exit /b 0

:PROCESS_DIR_PATH
set "BASE_DIR_PATH=%~f1"

rem CAUTION:
rem   If a variable is empty, then it would not be expanded in the `cmd.exe` command line or in case of `for /F ...`!
rem   We must expand the command line into a variable.
rem
set ?.=@dir "%BASE_DIR_PATH%%FILE_FILTER_SUFFIX%" /A:-D /B /O:N /S

for /F "usebackq eol= tokens=* delims=" %%i in (`%%?.%%`) do (
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

for /F "usebackq eol= tokens=* delims=" %%i in (`@"%CONTOOLS_ROOT%/arc/7zip/7z.bat" l "%ARCHIVE_FILE_PATH%"`) do (
  set "ARCHIVE_LIST_LINE=%%i"
  call :PROCESS_ARCHIVE_LIST_LINE || exit /b
  call :IS_ARCHIVE_LIST_EOF && goto PROCESS_ARCHIVE_FILE_IMPL_EXIT
)

:PROCESS_ARCHIVE_FILE_IMPL_EXIT
if %ERRORLEVEL% EQU 0 (
  call "%%?~dp0%%gen_uninstall_files_section.bat" "%%CODE_PAGE%%" "%%FILES_PATH_PREFIX%%" "%%INSTDIR_SUBDIR%%" "" "%%ARCHIVE_LIST_TEMP_FILE_TREE_DIR%%" || exit /b
)

exit /b

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
for /F "eol= tokens=3" %%i in ("%ARCHIVE_LIST_LINE%") do (
  set "ARCHIVE_LIST_LINE_ATTR=%%i"
)

set "ARCHIVE_LIST_FILE_PATH_ATTR0="
if defined ARCHIVE_LIST_LINE_ATTR (
  set "ARCHIVE_LIST_FILE_PATH_ATTR0=%ARCHIVE_LIST_LINE_ATTR:~0,1%"
)

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

rem echo."%FILES_PATH_PREFIX%%INSTDIR_SUBDIR_SUFFIX%/%ARCHIVE_LIST_FILE_PATH:\=/%" >&2
if not exist "%TEMP_FILE_DIR%" ( mkdir "%TEMP_FILE_DIR%" || exit /b 1 )

rem create empty file
if defined TEMP_FILE_PATH (
  type nul > "%TEMP_FILE_PATH%"
)

exit /b
