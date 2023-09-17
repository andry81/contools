@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script extracts files/directories from 7zip archive or any archive supported by 7zip
rem   preserving relative paths to each archive file.
rem   Script automatically does self logging.

rem Usage:
rem  <Flags> <Command arguments>

rem Flags:
rem   -i  - Do not create a subdirectory from an archive file name to unpuck into.
rem         By default does create a subdirectory from an archive file name for each archive.
rem

rem Command arguments:
rem %1 - Path to directory with archive files including subdirectories.
rem %2 - Path to directory with going to be extracted files.
rem %3 - Additional arguments for 7zip utility.
rem %4-%N - Optional archive file pattern list for the `dir` command, ex: `"*.7z" "*.zip" "*.rar"`

setlocal

if %IMPL_MODE%0 NEQ 0 goto IMPL

if not defined PROJECT_LOG_ROOT set PROJECT_LOG_ROOT=.log

call "%%~dp0__init__.bat" || exit /b

call "%%CONTOOLS_ROOT%%/std/declare_builtins.bat" %%0 %%*

call "%%CONTOOLS_ROOT%%/build/init_project_log.bat" "%%?~n0%%" || exit /b

call "%%CONTOOLS_ROOT%%/exec/exec_callf_prefix.bat" -- %%*
set LASTERROR=%ERRORLEVEL%

rem ...

exit /b %LASTERROR%

:IMPL
call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" . "%%?~n0%%" || (
  echo.%?~nx0%: error: could not allocate temporary directory: "%SCRIPT_TEMP_CURRENT_DIR%"
  exit /b 255
) >&2

call :MAIN %%*
set LASTERROR=%ERRORLEVEL%

rem cleanup temporary files
call "%%CONTOOLS_ROOT%%/std/free_temp_dir.bat"

exit /b %LASTERROR%

:MAIN
call "%%?~dp0%%.extract_files_from_archives_by_pttn/extract_files_from_archives_by_pttn.read_flags.bat" %%* || exit /b

set "SEARCH_FROM_DIR=%~1"
set "UNPACK_TO_DIR=%~2"
set "_7ZIP_SWITCHES=%~3"

rem read archive file pattern list
call "%%CONTOOLS_ROOT%%/std/read_args_to_var.bat" 3 ARC_FILE_PTTN_LIST %%*

if not defined SEARCH_FROM_DIR (
  echo.%~nx0: error: SEARCH_FROM_DIR is not defined.
  exit /b 255
) >&2

if not exist "%SEARCH_FROM_DIR%" (
  echo.%~nx0: error: SEARCH_FROM_DIR does not exist: "%SEARCH_FROM_DIR%".
  exit /b 255
) >&2

if not defined UNPACK_TO_DIR (
  echo.%~nx0: error: UNPACK_TO_DIR is not defined.
  exit /b 255
) >&2

if not exist "%UNPACK_TO_DIR%" (
  echo.%~nx0: error: UNPACK_TO_DIR does not exist: "%UNPACK_TO_DIR%".
  exit /b 255
) >&2

rem default values

if not defined ARC_FILE_PTTN_LIST set ARC_FILE_PTTN_LIST="*.7z" "*.7zip" "*.zip" "*.rar"

if not defined _7ZIP_SWITCHES set _7ZIP_SWITCHES=-bd

rem CAUTION:
rem   Explicitly use temporary directory for 7zip. This is required in some cases where 7zip can't create temporary
rem   archive file around being updated archive file.
rem   For example: pushd c:\ && ( 7z.exe a -r <PathToArchive> "<SomeRelativePath>" & popd )
rem
set "TEMP_DIR_PATH=%SCRIPT_TEMP_CURRENT_DIR%"

rem Drop last error level
call;

call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" SEARCH_FROM_DIR "%SEARCH_FROM_DIR%"
call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" UNPACK_TO_DIR   "%UNPACK_TO_DIR%"

call "%%CONTOOLS_ROOT%%/std/strlen.bat" /v SEARCH_FROM_DIR
set /A SEARCH_FROM_DIR_OFFSET=%ERRORLEVEL%+1

pushd "%SEARCH_FROM_DIR%" && (
  for /F "usebackq eol= tokens=* delims=" %%i in (`@dir %ARC_FILE_PTTN_LIST% /A:-D /B /S /O:N`) do ( set "ARC_FILE_PATH=%%i" & call :PROCESS )
  popd
)
exit /b 0

:PROCESS
if not defined ARC_FILE_PATH exit /b 0

call set "ARC_FILE_REL_PATH=%%ARC_FILE_PATH:~%SEARCH_FROM_DIR_OFFSET%%%"

for /F "eol= tokens=* delims=" %%i in ("%UNPACK_TO_DIR%\%ARC_FILE_REL_PATH%\..") do set "UNPACK_TO_FILE_DIR=%%~fi"
for /F "eol= tokens=* delims=" %%i in ("%ARC_FILE_REL_PATH%") do set "UNPACK_FILE_NAME=%%~ni"

if %CREATE_DIR_FROM_ARCHIVE_FILE_NAME% NEQ 0 set "UNPACK_TO_FILE_DIR=%UNPACK_TO_FILE_DIR%\%UNPACK_FILE_NAME%"

echo."%ARC_FILE_REL_PATH%"

if not exist "%UNPACK_TO_FILE_DIR%\" mkdir "%UNPACK_TO_FILE_DIR%"

call "%%CONTOOLS_ROOT%%/arc/7zip/7z.bat" x %%_7ZIP_SWITCHES%% "%%ARC_FILE_PATH%%" * "-w%%TEMP_DIR_PATH%%" "-o%%UNPACK_TO_FILE_DIR%%"
