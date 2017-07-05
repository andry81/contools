@echo off

setlocal

rem get and set code page
call "%%CONTOOLS_ROOT%%/std/chcp.bat" 866

if 0%SVNCMD_TOOLS_DEBUG_VERBOCITY_LVL% GEQ 1 (echo.^>^>%0 %*) >&3

"%~dp0sqlite3.exe" %*
set LASTERROR=%ERRORLEVEL%

rem restore code page
call "%%CONTOOLS_ROOT%%/std/restorecp.bat"

(
  endlocal
  rem restore chcp variables
  set "CURRENT_CP=%CURRENT_CP%"
  set "LAST_CP=%LAST_CP%"
  exit /b %LASTERROR%
)
