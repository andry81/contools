@echo off & goto DOC_END

rem Description:
rem   Script converts uniform file/directory excludes list in format of
rem     `exclude1|..|excludeN` ,where
rem       `exclude` can be an exclude wildcard file name or @-prefixed path to
rem       text file with list of file name wildcards.
rem   into robocopy preformatted command line of excludes.

rem Examples:
rem   1. >
rem      call convert_excludes_to_robocopy.bat "@excludes_file_list.lst|*.pdb|*.ilk|*.map" "@excludes_dir_list.lst|dir1|dir2"
rem
rem   2. # NEW FORMAT: to exclude wildcards beginning by `@` or use exclude list file name beginning by `@`
rem      >
rem      call convert_excludes_to_robocopy.bat "/@excludes_file_list.lst|:@file|:@file*" "/@excludes_dir_list.lst|:@dir|:@dir*"
:DOC_END

rem Drop return value
set "RETURN_VALUE="

setlocal

set "?~n0=%~n0"

set "ROBOCOPY_EXCLUDE_FILES_LIST=%~1"
set "ROBOCOPY_EXCLUDE_DIRS_LIST=%~2"

if not defined ROBOCOPY_EXCLUDE_FILES_LIST if not defined ROBOCOPY_EXCLUDE_DIRS_LIST exit /b 1

if defined ROBOCOPY_EXCLUDE_FILES_LIST call :PROCESS_EXCLUDES_LIST "%%ROBOCOPY_EXCLUDE_FILES_LIST%%" /XF || exit /b
if defined ROBOCOPY_EXCLUDE_DIRS_LIST call :PROCESS_EXCLUDES_LIST "%%ROBOCOPY_EXCLUDE_DIRS_LIST%%" /XD || exit /b

endlocal & set RETURN_VALUE=%RETURN_VALUE%

exit /b 0

:PROCESS_EXCLUDES_LIST
set "ROBOCOPY_EXCLUDES_LIST=%~1"
set "ROBOCOPY_EXCLUDES_FLAG_PREFIX=%~2"

set INDEX=1

:ROBOCOPY_EXCLUDES_LIST_LOOP
set "FILE="
for /F "tokens=%INDEX% delims=|"eol^= %%i in ("%ROBOCOPY_EXCLUDES_LIST%") do set "FILE=%%i"
if not defined FILE exit /b 0

if "%FILE:~0,1%" == "@" set "FILE=%FILE:~1%" & goto EXCLUDE_LIST_FILE
if "%FILE:~0,1%" == "/" set "FILE=%FILE:~1%" & goto EXCLUDE_LIST_FILE
if "%FILE:~0,1%" == ":" set "FILE=%FILE:~1%" & goto EXCLUDE_WILDCARD
goto EXCLUDE_WILDCARD

:EXCLUDE_LIST_FILE
call :PROCESS_EXCLUDES_LIST_FILE
goto EXCLUDE_END

:EXCLUDE_WILDCARD
call :PROCESS_WILDCARD

:EXCLUDE_END

set /A INDEX+=1

goto ROBOCOPY_EXCLUDES_LIST_LOOP

:PROCESS_EXCLUDES_LIST_FILE
for /F "usebackq tokens=* delims="eol^= %%i in ("%FILE%") do (
  set "FILE=%%i"
  call :PROCESS_WILDCARD || exit /b
)
exit /b 0

:PROCESS_WILDCARD
for /F "tokens=* delims="eol^= %%i in ("%FILE%") do ^
set RETURN_VALUE=%RETURN_VALUE% %ROBOCOPY_EXCLUDES_FLAG_PREFIX% "%%i"

exit /b 0
