@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script adds files/directories into 7zip archive. Archive would have relative path prefix
rem   from %2 variable.

rem Command arguments:
rem %1 - Path to directory with files/directories to archive.
rem %2 - Relative path with pattern inside first argument directory.
rem %3 - Path where create/reuse archive file.
rem %4-%N - Additional arguments for 7zip utility.

rem Examples:
rem 1. call add_files_to_archive.bat c:\path_to_archive\app release\x86 c:\path_of_archives\app_release_x86.7z -xr!"*.lib" -xr!"*.exp" -xr@"7zip_excludes_list.lst"

setlocal

set "?~n0=%~n0"
set "?~nx0=%~nx0"
set "?~dp0=%~dp0"

set "DIR=%~f1"
set "REL_PATH=%~2"
set "ARCHIVE_PATH=%~f3"
set "ARCHIVE_DIR=%~dp3"

shift
shift
shift

set "_7ZIP_SWITCHES="

:SWITCHES_LOOP
set _7ZIP_SWITCH=%1

if not defined _7ZIP_SWITCH goto SWITCHES_LOOP_END

set _7ZIP_SWITCHES=%_7ZIP_SWITCHES% %_7ZIP_SWITCH%

shift

goto SWITCHES_LOOP

:SWITCHES_LOOP_END

rem Drop last error level
call;

call "%%?~dp0%%__init__.bat" || exit /b

pushd "%DIR%" || (
  echo.%?~nx0%: error: could not switch current directory: "%DIR%".
  set LASTERROR=1
  goto EXIT
)

echo.  "%DIR%" -^> "%REL_PATH%"

rem CAUTION:
rem   Explicitly use temporary directory for 7zip. This is required in some cases where 7zip can't create temporary
rem   archive file around being updated archive file.
rem   For example: pushd c:\ && ( 7z.exe a -r <PathToArchive> "<SomeRelativePath>" & popd )

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

popd

:EXIT
exit /b %LASTERROR%

:MAIN
set "EMPTY_DIR_TMP=%SCRIPT_TEMP_CURRENT_DIR%\emptydir"

mkdir "%EMPTY_DIR_TMP%" || (
  echo.%?~n0%: error: could not create a directory: "%EMPTY_DIR_TMP%".
  exit /b 255
) >&2

if not exist "%ARCHIVE_DIR%\" ( call :MAKE_DIR "%%ARCHIVE_DIR%%" || exit /b 2 )

rem remove arguments trailing back slashes to avoid exe command line parse old bug
if "%ARCHIVE_PATH:~-1%" == "\" set "ARCHIVE_PATH=%ARCHIVE_PATH:~0,-1%"
if "%REL_PATH:~-1%" == "\" set "REL_PATH=%REL_PATH:~0,-1%"

call :CMD "%%CONTOOLS_ROOT%%/arc/7zip/7z.bat" a -r%%_7ZIP_SWITCHES%% "%%ARCHIVE_PATH%%" "%%REL_PATH%%" "-w%%SCRIPT_TEMP_CURRENT_DIR%%"
exit /b

:CMD
echo.^>%*
(
  %*
)
exit /b

:MAKE_DIR
for /F "eol= tokens=* delims=" %%i in ("%~1\.") do set "FILE_PATH=%%~fi"

mkdir "%FILE_PATH%" 2>nul || if exist "%SystemRoot%\System32\robocopy.exe" ( "%SystemRoot%\System32\robocopy.exe" /CREATE "%EMPTY_DIR_TMP%" "%FILE_PATH%" >nul ) else type 2>nul || (
  echo.%?~nx0%: error: could not create a target file directory: "%FILE_PATH%".
  exit /b 1
) >&2
exit /b
