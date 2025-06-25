@echo off & goto DOC_END

rem Description:
rem   Script to extract an archive or all archives from a directory recursively using 7zip.
rem   Script automatically does self logging.

rem CAUTION:
rem   Script is left for the backward compatibility. Use `extract_files_from_archives.bat` script instead.

rem Command arguments:
rem %1 - Path to output directory for extracted files.
rem %2 - Relative path with pattern inside archive.
rem %3 - Path to an archive file or a directory to search from.
rem %4 - Additional arguments for 7zip utility.
rem %5-%N - Optional archive file pattern list for the `dir` command, ex: `"*.7z" "*.zip" "*.rar"`

rem Examples:
rem 1. call extract_files_from_archive.bat c:\path_for_unpack\app release\x86\app.exe c:\path_with_archives\app_release_x86.7z
:DOC_END

setlocal

rem log into current directory
if not defined PROJECT_LOG_ROOT set PROJECT_LOG_ROOT=.log

call "%%~dp0../__init__/script_init.bat" %%0 %%* || exit /b
if %IMPL_MODE%0 EQU 0 exit /b

call "%%CONTOOLS_ROOT%%/std/callshift.bat" -3 "%%~dp0extract_files_from_archives.bat" %%3 %%2 %%1 %%*
