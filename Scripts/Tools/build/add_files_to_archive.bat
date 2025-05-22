@echo off & goto DOC_END

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
:DOC_END

setlocal

set "?~dp0=%~dp0"
set "?~n0=%~n0"

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"

set "?~nx0=%~nx0"

set "DIR=%~f1"
set "REL_PATH=%~2"
set "ARCHIVE_PATH=%~f3"

shift
shift
shift

set _7ZIP_BARE_FLAGS_HAS_TEMP_DIR=0
set "_7ZIP_BARE_FLAGS="

:SWITCHES_LOOP
set _7ZIP_FLAG=%1

if not defined _7ZIP_FLAG goto SWITCHES_LOOP_END

if "%_7ZIP_FLAG:~0,2%" == "-w" set _7ZIP_BARE_FLAGS_HAS_TEMP_DIR=1

set _7ZIP_BARE_FLAGS=%_7ZIP_BARE_FLAGS% %_7ZIP_FLAG%

shift

goto SWITCHES_LOOP

:SWITCHES_LOOP_END

call "%%?~dp0%%__init__.bat" || exit /b

pushd "%DIR%" || (
  echo;%?~%: error: could not switch current directory: "%DIR%".
  set LAST_ERROR=1
  goto EXIT
)

echo;  "%DIR%" -^> "%REL_PATH%"

rem CAUTION:
rem   Explicitly use temporary directory for 7zip. This is required in some cases where 7zip can't create temporary
rem   archive file around being updated archive file.
rem   For example: pushd c:\ && ( 7z.exe a -r <PathToArchive> "<SomeRelativePath>" & popd )

call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" . "%%?~n0%%" || ( set "LAST_ERROR=255" & goto FREE_TEMP_DIR )

if %_7ZIP_BARE_FLAGS_HAS_TEMP_DIR% EQU 0 set _7ZIP_BARE_FLAGS=%_7ZIP_BARE_FLAGS% "-w%SCRIPT_TEMP_CURRENT_DIR%"

call :MAIN %%*
set LAST_ERROR=%ERRORLEVEL%

:FREE_TEMP_DIR
rem cleanup temporary files
call "%%CONTOOLS_ROOT%%/std/free_temp_dir.bat"

popd

:EXIT
exit /b %LAST_ERROR%

:MAIN
rem remove arguments trailing back slashes to avoid exe command line parse old bug
if "%ARCHIVE_PATH:~-1%" == "\" set "ARCHIVE_PATH=%ARCHIVE_PATH:~0,-1%"
if "%REL_PATH:~-1%" == "\" set "REL_PATH=%REL_PATH:~0,-1%"

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/call.bat" "%%CONTOOLS_ROOT%%/arc/7zip/7z.bat" a -r%%_7ZIP_BARE_FLAGS%% "%%ARCHIVE_PATH%%" "%%REL_PATH%%"

exit /b
