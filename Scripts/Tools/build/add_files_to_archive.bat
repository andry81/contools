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

set "DIR=%~dpf1"
set "REL_PATH=%~2"
set "ARCHIVE_PATH=%~dpf3"
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
type nul>nul

call "%%?~dp0%%__init__.bat" || goto :EOF

pushd "%DIR%" || (
  echo.%?~nx0%: error: could not switch current directory: "%DIR%".
  exit /b 1
)

echo.  "%DIR%" -^> "%REL_PATH%"

rem CAUTION:
rem   Explicitly use temporary directory for 7zip. This is required in some cases where 7zip can't create temporary
rem   archive file around being updated archive file.
rem   For example: pushd c:\ && ( 7za.exe a -r <PathToArchive> "<SomeRelativePath>" & popd )

call "%%CONTOOLS_ROOT%%/uuidgen.bat"
set "TEMP_DIR_PATH=%TEMP%\%?~n0%.%RETURN_VALUE%"

mkdir "%TEMP_DIR_PATH%" || (
  popd
  echo.%?~nx0%: error: could not create temporary directory: "%TEMP_DIR_PATH%".
  exit /b 2
) >&2

if not exist "%ARCHIVE_DIR%" mkdir "%ARCHIVE_DIR%"

call :ARC
set LASTERROR=%ERRORLEVEL%

popd

rmdir /S /Q "%TEMP_DIR_PATH%"

exit /b %LASTERROR%

:ARC
rem remove arguments trailing back slashes to avoid exe command line parse old bug
if "%ARCHIVE_PATH:~-1%" == "\" set "ARCHIVE_PATH=%ARCHIVE_PATH:~0,-1%"
if "%REL_PATH:~-1%" == "\" set "REL_PATH=%REL_PATH:~0,-1%"

call :CMD "%%CONTOOLS_ROOT%%/7zip/7za.exe" a -r%%_7ZIP_SWITCHES%% "%%ARCHIVE_PATH%%" "%%REL_PATH%%" "-w%%TEMP_DIR_PATH%%"
exit /b

:CMD
echo.^>%*
(%*)
exit /b
