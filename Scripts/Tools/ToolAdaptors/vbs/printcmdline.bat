@echo off

setlocal

call "%%~dp0__init__.bat" || exit /b

call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" . "%%~n0"

call "%%CONTOOLS_ROOT%%/std/get_cmdline.bat" %%*

setlocal ENABLEDELAYEDEXPANSION
if defined RETURN_VALUE for /F "eol= tokens=* delims=" %%i in ("!RETURN_VALUE!") do (
  endlocal
  echo.%%i
) else (
  endlocal
  echo.
)

rem cleanup temporary files
call "%%CONTOOLS_ROOT%%/std/free_temp_dir.bat"

exit /b 0
