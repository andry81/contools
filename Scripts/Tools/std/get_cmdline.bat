@echo off

setlocal

call "%%~dp0__init__.bat" || exit /b

set "RETURN_VALUE="

set ?__FLAG_ALLOCATE_TEMP_DIR=0

if not defined SCRIPT_TEMP_CURRENT_DIR set ?__FLAG_ALLOCATE_TEMP_DIR=1

if %?__FLAG_ALLOCATE_TEMP_DIR% NEQ 0 (
  call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" . "%%?~n0%%" || (
    echo.%?~nx0%: error: could not allocate temporary directory: "%SCRIPT_TEMP_CURRENT_DIR%"
    exit /b 255
  ) >&2
)

rem redirect command line into temporary file to print it correcly
for %%i in (1) do (
    set "PROMPT=$_"
    echo on
    for %%b in (1) do rem * #%*#
    @echo off
) > "%SCRIPT_TEMP_CURRENT_DIR%\cmdline.txt"

for /F "usebackq eol= tokens=* delims=" %%i in ("%SCRIPT_TEMP_CURRENT_DIR%\cmdline.txt") do set "RETURN_VALUE=%%i"
setlocal ENABLEDELAYEDEXPANSION
set "RETURN_VALUE=!RETURN_VALUE:*#=!"
set "RETURN_VALUE=!RETURN_VALUE:~0,-2!"
set RETURN_VALUE=%0 !RETURN_VALUE!
for /F "eol= tokens=* delims=" %%j in ("!RETURN_VALUE!") do (
  endlocal
  set "RETURN_VALUE=%%j"
)

rem cleanup temporary files
if %?__FLAG_ALLOCATE_TEMP_DIR% NEQ 0 (
  call "%%CONTOOLS_ROOT%%/std/free_temp_dir.bat"
)

setlocal ENABLEDELAYEDEXPANSION
for /F "eol= tokens=* delims=" %%i in ("!RETURN_VALUE!") do (
  endlocal
  endlocal
  set "RETURN_VALUE=%%i"
)

exit /b 0
