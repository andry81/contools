@echo off

setlocal

set "?~dp0=%~dp0"
set "?~n0=%~n0"
set "?~nx0=%~nx0"

call "%%?~dp0%%__init__.bat" || exit /b

rem script flags
set FLAG_PAUSE_ON_EXIT=0
set RESTORE_LOCALE=0

call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" . "%%?~n0%%"

call :MAIN %%*
set LASTERROR=%ERRORLEVEL%

:EXIT_MAIN
rem restore locale
if %RESTORE_LOCALE% NEQ 0 call "%%CONTOOLS_ROOT%%/std/restorecp.bat"

rem cleanup temporary files
call "%%CONTOOLS_ROOT%%/std/free_temp_dir.bat"

if %FLAG_PAUSE_ON_EXIT% NEQ 0 pause

exit /b %LASTERROR%

:MAIN
rem script flags
set FLAG_WAIT_EXIT=0
set FLAG_CONVERT_FROM_UTF16=0

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-pause_on_exit" (
    set FLAG_PAUSE_ON_EXIT=1
  ) else if "%FLAG%" == "-wait" (
    set FLAG_WAIT_EXIT=1
  ) else if "%FLAG%" == "-from_utf16" (
    set FLAG_CONVERT_FROM_UTF16=1
  ) else (
    echo.%?~nx0%: error: invalid flag: %FLAG%
    exit /b -255
  ) >&2

  shift

  rem read until no flags
  goto FLAGS_LOOP
)

set "PWD=%~1"
shift

if not defined PWD goto NOPWD
cd /d "%PWD%" || exit /b 1

:NOPWD

set "FILES_LIST="
set NUM_FILES=0

set RANDOM_VALUE1=%RANDOM%_%RANDOM%
set RANDOM_VALUE2=%RANDOM%_%RANDOM%

set "COMPARE_FROM_LIST_FILE_TMP=%SCRIPT_TEMP_CURRENT_DIR%\input_file_list_utf_8.lst"

if %FLAG_CONVERT_FROM_UTF16% NEQ 0 (
  rem to convert from unicode
  call "%%CONTOOLS_ROOT%%/std/chcp.bat" 65001
  set RESTORE_LOCALE=1

  rem Recreate files and recode files w/o BOM applience (do use UTF-16 instead of UCS-2LE/BE for that!)
  rem See for details: https://stackoverflow.com/questions/11571665/using-iconv-to-convert-from-utf-16be-to-utf-8-without-bom/11571759#11571759
  rem
  call "%%CONTOOLS_ROOT%%/encoding/ansi2any.bat" UTF-16 UTF-8 "%%~1" > "%COMPARE_FROM_LIST_FILE_TMP%"
) else (
  set "COMPARE_FROM_LIST_FILE_TMP=%~1"
)

rem drop last error
type nul>nul

rem read selected file paths from file
for /F "usebackq eol=	 tokens=* delims=" %%i in ("%COMPARE_FROM_LIST_FILE_TMP%") do (
  set FILE_PATH=%%i
  call :PROCESS_FILE_PATH "%%FILE_PATH%%" || goto BREAK_LOOP
)

:BREAK_LOOP
set LASTERROR=%ERRORLEVEL%

if %LASTERROR% NEQ 0 exit /b %LASTERROR%
if %NUM_FILES% NEQ 2 exit /b 2

goto PROCESS_COMPARE

:PROCESS_FILE_PATH
if not defined FILE_PATH exit /b 3
rem must be files, not sub directories
if exist "%~1\" exit /b 4

if %NUM_FILES% EQU 0 (
  set "FILE_IN_1=%~1"
  set "FILE_OUT_1=%SCRIPT_TEMP_CURRENT_DIR%\%~n1.~%RANDOM_VALUE1%%~x1"
  set FILES_LIST="%SCRIPT_TEMP_CURRENT_DIR%\%~n1.~%RANDOM_VALUE1%%~x1"
) else if %NUM_FILES% EQU 1 (
  set "FILE_IN_2=%~1"
  set "FILE_OUT_2=%SCRIPT_TEMP_CURRENT_DIR%\%~n1.~%RANDOM_VALUE2%%~x1"
  set FILES_LIST=%FILES_LIST% "%SCRIPT_TEMP_CURRENT_DIR%\%~n1.~%RANDOM_VALUE2%%~x1"
)

set /A NUM_FILES+=1

rem only 2 first files from the list ais accepted
if %NUM_FILES% GTR 2 exit /b 2

exit /b 0

:PROCESS_COMPARE

rem The input from the `type` is required to detect UTF-16 WITH BOM (`sort` can detect ONLY UTF-8 input)
rem But in both cases not `sort` nor `type` COULD NOT detect UTF-16 WITHOUT BOM!
if exist "%FILE_IN_1%" ( type "%FILE_IN_1%" | sort /O "%FILE_OUT_1%" )
if exist "%FILE_IN_2%" ( type "%FILE_IN_2%" | sort /O "%FILE_OUT_2%" )

if %FLAG_WAIT_EXIT% NEQ 0 (
  call :CMD start /B /WAIT "" "%%CONSOLE_COMPARE_TOOL%%" /wait %%FILES_LIST%%
) else (
  call :CMD start /B "" "%%CONSOLE_COMPARE_TOOL%%" /nowait %%FILES_LIST%%
)

exit /b

:CMD
echo.^>%*
(%*)
