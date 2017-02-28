@echo off

rem FILE OUTPUT EXAMPLE:
rem  Delete "$INSTDIR\uninst.exe"
rem  Delete "$INSTDIR\universal_tract\XORBitstreams.dll"
rem  Delete "$INSTDIR\universal_tract\VSatSync.dll"
rem  RMDir "$INSTDIR\universal_tract"

setlocal

if "%TOOLS_PATH%" == "" set "TOOLS_PATH=%~dp0.."
set "TOOLS_PATH=%TOOLS_PATH:\=/%"
if "%TOOLS_PATH:~-1%" == "/" set "TOOLS_PATH=%TOOLS_PATH:~0,-1%"

set "?~dp0=%~dp0"
set "?~nx0=%~nx0"

rem drop last error level
cd .

rem get code page value from first parameter
set "LAST_CODE_PAGE="
set "CODE_PAGE=%~1"

shift

if "%CODE_PAGE%" == "" goto NOCODEPAGE

for /F "usebackq eol= tokens=1,* delims=:" %%i in (`chcp 2^>nul`) do set LAST_CODE_PAGE=%%j
set LAST_CODE_PAGE=%LAST_CODE_PAGE: =%

if not "%LAST_CODE_PAGE%" == "%CODE_PAGE%" chcp %CODE_PAGE% >nul

:NOCODEPAGE
set "FILES_PATH_PREFIX=%~1"
set "INSTDIR_SUBDIR=%~2"
set "FILE_FILTER=%~3"

shift
shift
shift

set "INSTDIR_SUBDIR_SUFFIX="
if not "%INSTDIR_SUBDIR%" == "" set "INSTDIR_SUBDIR_SUFFIX=\%INSTDIR_SUBDIR%"
set "FILE_FILTER_SUFFIX="
if not "%FILE_FILTER%" == "" set "FILE_FILTER_SUFFIX=\%FILE_FILTER%"

:PROCESS_DIR_LOOP
call :PROCESS_DIR_PATH "%%~1" || goto :EOF

shift 

if exist "%~1" goto PROCESS_DIR_LOOP

if not "%LAST_CODE_PAGE%" == "%CODE_PAGE%" chcp %LAST_CODE_PAGE% >nul

exit /b 0

:PROCESS_DIR_PATH
set "BASE_DIR_PATH=%~dpf1"

for /F "usebackq eol= tokens=* delims=" %%i in (`dir "%BASE_DIR_PATH%%FILE_FILTER_SUFFIX%" /S /B /A:-D 2^>nul`) do (
  set "ARCHIVE_FILE_PATH=%%i"
  call :PROCESS_ARCHIVE_FILE || goto :EOF
)

goto :EOF

:PROCESS_ARCHIVE_FILE

call "%%TOOLS_PATH%%/uuidgen.bat"

set "ARCHIVE_LIST_TEMP_FILE_TREE_DIR=%TEMP%\gen_uninstall_files_section_from_archive_%RETURN_VALUE%"

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

for /F "usebackq eol= tokens=* delims=" %%i in (`@"%TOOLS_PATH%/7zip/7za.exe" l "%ARCHIVE_FILE_PATH%"`) do (
  set "ARCHIVE_LIST_LINE=%%i"
  call :PROCESS_ARCHIVE_LIST_LINE || goto :EOF
  call :IS_ARCHIVE_LIST_EOF && goto PROCESS_ARCHIVE_FILE_IMPL_EXIT
)

:PROCESS_ARCHIVE_FILE_IMPL_EXIT
if %ERRORLEVEL% EQU 0 (
  call "%%?~dp0%%gen_uninstall_files_section.bat" "%%CODE_PAGE%%" "%%FILES_PATH_PREFIX%%" "%%INSTDIR_SUBDIR%%" "" "%%ARCHIVE_LIST_TEMP_FILE_TREE_DIR%%" || goto :EOF
)

goto :EOF

:IS_ARCHIVE_LIST_EOF
if %ARCHIVE_LIST_EOF% NEQ 0 exit /b 0
exit /b 1

:PROCESS_ARCHIVE_LIST_LINE
if "%ARCHIVE_LIST_LINE%" == "" exit /b 0

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

if "%ARCHIVE_LIST_FILE_PATH%" == "" exit /b 0

rem use attributes to determine directory path from file path
set "ARCHIVE_LIST_LINE_ATTR="
for /F "eol= tokens=3" %%i in ("%ARCHIVE_LIST_LINE%") do (
  set "ARCHIVE_LIST_LINE_ATTR=%%i"
)

set "ARCHIVE_LIST_FILE_PATH_ATTR0="
if not "%ARCHIVE_LIST_LINE_ATTR%" == "" (
  set "ARCHIVE_LIST_FILE_PATH_ATTR0=%ARCHIVE_LIST_LINE_ATTR:~0,1%"
)

rem create empty files tree in temporary directory to retrieve later a sorted file paths list by `dir` command
call :CREATE_TEMP_TREE_OF_EMPTY_FILES "%%ARCHIVE_LIST_FILE_PATH_ATTR0%%" "%%ARCHIVE_LIST_TEMP_FILE_TREE_DIR%%\%%ARCHIVE_LIST_FILE_PATH%%" || goto :EOF

exit /b 0

:CREATE_TEMP_TREE_OF_EMPTY_FILES
rem drop last error level
cd .

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
if not "%TEMP_FILE_PATH%" == "" (
  type nul > "%TEMP_FILE_PATH%"
)

goto :EOF
