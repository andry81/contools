@echo off

setlocal

call "%%~dp0__init__.bat" || exit /b

call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" . "%%~n0"

call "%%CONTOOLS_ROOT%%/std/get_cmdline.bat" %%*

echo.Current directory: "%CD:\=/%"

setlocal ENABLEDELAYEDEXPANSION
if defined RETURN_VALUE for /F "eol= tokens=* delims=" %%i in ("!RETURN_VALUE!") do (
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
