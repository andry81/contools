@echo off & goto DOC_END

rem Description:
rem   Script to extract an archive or all archives from a directory recursively using 7zip.
rem   Script automatically does self logging.

rem Usage:
rem  <Flags> <Command arguments>

rem Flags:
rem   -i  - Do not create a subdirectory from an archive file name to unpack.
rem         By default does create a subdirectory from an archive file name for each archive.
rem   -p  - Create extraction directory if does not exist.
rem   -k  - Skip archives which prefix path already existed in the output directory.

rem Command arguments:
rem %1 - Path to an archive file or a directory to search from.
rem %2 - Relative path with pattern inside archive.
rem %3 - Path to output directory for extracted files.
rem %4 - Additional arguments for 7zip utility.
rem %5-%N - Optional archive file pattern list for the `dir` command, ex: `"*.7z" "*.zip" "*.rar"`
rem         Has no effect if %1 is a file path.

rem Examples:
rem 1. call extract_files_from_archives.bat c:\path_with_archives * c:\path_with_content_from_all_archives
rem 2. call extract_files_from_archives.bat c:\path_with_archives * c:\path_with_content_from_all_archives "" "*.7z"
rem 3. call extract_files_from_archives.bat c:\path_with_archives\app_release_x86.7z release\x86\app.exe c:\path_for_unpack\app
rem 4. call extract_files_from_archives.bat c:\path_with_archives\app_release_x86.7z * c:\path_for_unpack\app
:DOC_END

setlocal

rem log into current directory
if not defined PROJECT_LOG_ROOT set PROJECT_LOG_ROOT=.log

call "%%~dp0../__init__/script_init.bat" %%0 %%* || exit /b
if %IMPL_MODE%0 EQU 0 exit /b

call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" . "%%?~n0%%" || exit /b

call :MAIN %%*
set LAST_ERROR=%ERRORLEVEL%

rem cleanup temporary files
call "%%CONTOOLS_ROOT%%/std/free_temp_dir.bat"

exit /b %LAST_ERROR%

:MAIN
call "%%?~dp0%%.extract_files_from_archives/extract_files_from_archives.read_flags.bat" %%* || exit /b

if FLAG_SHIFT GTR 0 for /L %%i in (1,1,%FLAG_SHIFT%) do shift

set "SEARCH_FROM=%~1"
set "EXTRACT_PTTN=%~2"
set "EXTRACT_TO_DIR=%~3"
set "_7ZIP_SWITCHES=%~4"

set /A FLAG_SHIFT+=4

rem read archive file pattern list
call "%%CONTOOLS_ROOT%%/std/setshift.bat" %%FLAG_SHIFT%% ARC_FILE_PTTN_LIST %%*

if not defined SEARCH_FROM (
  echo;%?~%: error: SEARCH_FROM is not defined.
  exit /b 255
) >&2

set "SEARCH_FROM_IN=%SEARCH_FROM%"

for /F "tokens=* delims="eol^= %%i in ("%SEARCH_FROM%\.") do set "SEARCH_FROM=%%~fi"

if not exist "\\?\%SEARCH_FROM%" (
  echo;%?~%: error: SEARCH_FROM does not exist: "%SEARCH_FROM%".
  exit /b 255
) >&2

if not defined EXTRACT_TO_DIR (
  echo;%?~%: error: EXTRACT_TO_DIR is not defined.
  exit /b 255
) >&2

set "EXTRACT_TO_DIR_IN=%EXTRACT_TO_DIR%"

for /F "tokens=* delims="eol^= %%i in ("%EXTRACT_TO_DIR%\.") do set "EXTRACT_TO_DIR=%%~fi"

if %CREATE_EXTRACT_TO_DIR% EQU 0 if not exist "\\?\%EXTRACT_TO_DIR%\*" (
  echo;%?~%: error: EXTRACT_TO_DIR directory does not exist: "%EXTRACT_TO_DIR%".
  exit /b 255
) >&2

rem default values

if not defined ARC_FILE_PTTN_LIST set ARC_FILE_PTTN_LIST="*.7z" "*.7zip" "*.zip" "*.rar" "*.xz" "*.tar" "*.bz2" "*.gz" "*.lz" "*.lzma"

if not defined _7ZIP_SWITCHES set _7ZIP_SWITCHES=-bd

if defined _7ZIP_SWITCHES set _7ZIP_SWITCHES= %_7ZIP_SWITCHES%

rem CAUTION:
rem   Explicitly use temporary directory for 7zip. This is required in some cases where 7zip can't create temporary
rem   archive file around being updated archive file.
rem   For example: pushd c:\ && ( 7z.exe a -r <PathToArchive> "<SomeRelativePath>" & popd )
rem
set "TEMP_DIR_PATH=%SCRIPT_TEMP_CURRENT_DIR%"

echo;  "%EXTRACT_PTTN%" -^> "%EXTRACT_TO_DIR_IN%"

if %CREATE_EXTRACT_TO_DIR% NEQ 0 call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/mkdir_if_notexist.bat" "%%EXTRACT_TO_DIR%%" >nul || exit /b

pushd "%EXTRACT_TO_DIR%" && (
  if exist "\\?\%SEARCH_FROM%\*" (
    call :EXTRACT_FROM_DIR %%ARC_FILE_PTTN_LIST%%
  ) else call :EXTRACT_FROM_FILE
  popd
)

exit /b

:EXTRACT_FROM_DIR
call "%%CONTOOLS_ROOT%%/std/strlen.bat" /v SEARCH_FROM
set /A ARC_FILE_PATH_OFFSET=%ERRORLEVEL%+1

set "SEARCH_FROM_FILES="

:ARC_FILE_PTTN_LOOP
set "ARC_FILE_PTTN=%~1"

if not defined ARC_FILE_PTTN goto ARC_FILE_PTTN_LOOP_END

set SEARCH_FROM_FILES=%SEARCH_FROM_FILES% "%SEARCH_FROM%\%ARC_FILE_PTTN%"

shift

goto ARC_FILE_PTTN_LOOP

:ARC_FILE_PTTN_LOOP_END

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
set ?.=@dir%SEARCH_FROM_FILES% /A:-D /B /O:N /S 2^>nul

if defined SEARCH_FROM_FILES for /F "usebackq tokens=* delims="eol^= %%i in (`%%?.%%`) do set "ARC_FILE_PATH=%%i" & call :PROCESS_DIR
exit /b

:EXTRACT_FROM_FILE
set ARC_FILE_PATH_OFFSET=0
set "ARC_FILE_PATH=%SEARCH_FROM%"
call :PROCESS_FILE
exit /b

:PROCESS_DIR
if not defined ARC_FILE_PATH exit /b 0

call set "ARC_FILE_REL_PATH=%%ARC_FILE_PATH:~%ARC_FILE_PATH_OFFSET%%%"

for /F "tokens=* delims="eol^= %%i in ("%EXTRACT_TO_DIR%\%ARC_FILE_REL_PATH%\..") do set "EXTRACT_TO_FILE_DIR=%%~fi"
for /F "tokens=* delims="eol^= %%i in ("%ARC_FILE_REL_PATH%") do set "EXTRACT_FILE_NAME=%%~ni"

set "EXTRACT_TO_FILE_DIR_W_NAME=%EXTRACT_TO_FILE_DIR%\%EXTRACT_FILE_NAME%"

if %CREATE_DIR_FROM_ARCHIVE_FILE_NAME% NEQ 0 set "EXTRACT_TO_FILE_DIR=%EXTRACT_TO_FILE_DIR_W_NAME%"

echo;"%ARC_FILE_REL_PATH%"

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/mkdir_if_notexist.bat" "%%EXTRACT_TO_FILE_DIR%%" >nul || exit /b

if %SKIP_ARCHIVES_WITH_EXISTED_EXTRACTED_PREFIX_PATH% NEQ 0 if exist "\\?\%EXTRACT_TO_FILE_DIR_W_NAME%\*" exit /b 0

call "%%CONTOOLS_ROOT%%/arc/7zip/7z.bat" x%%_7ZIP_SWITCHES%% "-w%%TEMP_DIR_PATH%%" "-o%%EXTRACT_TO_FILE_DIR%%" "%%ARC_FILE_PATH%%" "%%EXTRACT_PTTN%%"
exit /b

:PROCESS_FILE
call "%%CONTOOLS_ROOT%%/arc/7zip/7z.bat" x%%_7ZIP_SWITCHES%% "-w%%TEMP_DIR_PATH%%" "%%ARC_FILE_PATH%%" "%%EXTRACT_PTTN%%"
exit /b

:EXTRACT_PTTN_ERROR
(
  echo;%?~%: error: EXTRACT_PTTN must not contain wildcards: "%EXTRACT_PTTN%".
  exit /b 255
) >&2
exit /b 255
