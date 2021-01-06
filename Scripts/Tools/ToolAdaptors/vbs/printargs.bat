@echo off

rem Script to create the Windows shortcut file.

setlocal

call "%%~dp0__init__.bat" || exit /b

call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" . "%%~n0"

for %%i in (1) do (
    set "PROMPT=$_"
    echo on
    for %%b in (1) do rem * #%*#
    @echo off
) > "%SCRIPT_TEMP_CURRENT_DIR%\cmdline.txt"

for /F "usebackq eol= tokens=* delims=" %%i in ("%SCRIPT_TEMP_CURRENT_DIR%\cmdline.txt") do set "CMDLINE_STR=%%i"

setlocal ENABLEDELAYEDEXPANSION
set "CMDLINE_STR=!CMDLINE_STR:*#=!"
set "CMDLINE_STR=!CMDLINE_STR:~0,-2!"
if defined CMDLINE_STR for /F "eol= tokens=* delims=" %%i in ("!CMDLINE_STR!") do (
  endlocal
  echo.^>"%~dp0%~n0.vbs" %%i
  "%~dp0%~n0.vbs" %%i
) else (
  endlocal
  echo.^>"%~dp0%~n0.vbs"
  "%~dp0%~n0.vbs"
)

set LASTERROR=%ERRORLEVEL%

rem cleanup temporary files
call "%%CONTOOLS_ROOT%%/std/free_temp_dir.bat"

exit /b %LASTERROR%
