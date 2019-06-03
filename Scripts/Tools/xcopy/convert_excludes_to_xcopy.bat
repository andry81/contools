@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script converts unform file/directory excludes list in format of
rem     `exclude1|..|excludeN` ,where
rem       `exclude` can be an exclude wildcard file name or @-prefixed path to
rem       text file with list of file name wildcards.
rem   into xcopy preformatted command line of excludes stored as a list of
rem   strings in a file.

rem Examples:
rem   1. call convert_excludes_to_xcopy.bat "@excludes_file_list.lst|*.pdb|*.ilk|*.map" "@excludes_dir_list.lst|dir1|dir2" "xcopy_excludes.lst"

rem CAUTION:
rem   1. The excludes directory list does NOT differ to the excludes file list because
rem      the xcopy utility has the common flags for both the files and the directories.
rem   2. Exclude parameters should not contain not printable or control characters.

setlocal

set "XCOPY_EXCLUDE_FILES_LIST=%~1"
set "XCOPY_EXCLUDE_DIRS_LIST=%~2"
set "XCOPY_EXCLUDES_LIST_FILE=%~3"

if not defined XCOPY_EXCLUDE_FILES_LIST if not defined XCOPY_EXCLUDE_DIRS_LIST exit /b 1

if not defined XCOPY_EXCLUDES_LIST_FILE exit /b 2

rem create empty file
type nul> "%XCOPY_EXCLUDES_LIST_FILE%" || exit /b 2

if defined XCOPY_EXCLUDE_FILES_LIST ( call :PROCESS_EXCLUDES_LIST "%%XCOPY_EXCLUDE_FILES_LIST%%" || exit /b )
if defined XCOPY_EXCLUDE_DIRS_LIST ( call :PROCESS_EXCLUDES_LIST "%%XCOPY_EXCLUDE_DIRS_LIST%%" || exit /b )

exit /b 0

:PROCESS_EXCLUDES_LIST
set "XCOPY_EXCLUDES_LIST=%~1"

set INDEX=1

:XCOPY_EXCLUDES_LIST_LOOP
set "FILE="
for /F "eol=	 tokens=%INDEX% delims=|" %%i in ("%XCOPY_EXCLUDES_LIST%") do set "FILE=%%i"
if not defined FILE exit /b 0

if "%FILE:~0,1%" == "@" (
  set "FILE=%FILE:~1%"
  call :PROCESS_EXCLUDES_LIST_FILE
) else (
  call :PROCESS_WILDCARD
)

set /A INDEX+=1

goto XCOPY_EXCLUDES_LIST_LOOP

:PROCESS_EXCLUDES_LIST_FILE
for /F "usebackq eol=	 tokens=* delims=" %%i in ("%FILE%") do (
  set "FILE=%%i"
  call :PROCESS_WILDCARD || exit /b
)
exit /b 0

:PROCESS_WILDCARD
rem convert `*suffix.ext` into `suffix.ext`
if "%FILE:~0,1%" == "*" set "FILE=%FILE:~1%"
for /F "eol=	 tokens=* delims=" %%i in ("%FILE%") do (echo.%%i) >> "%XCOPY_EXCLUDES_LIST_FILE%"
exit /b 0
