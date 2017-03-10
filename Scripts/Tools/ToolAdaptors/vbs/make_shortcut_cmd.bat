@echo off

rem Script to create the Windows shortcut file to the "COMSPEC <cmdline>"
rem in the current directory.

rem Drom last error level
cd .

rem Save all variables to stack
setlocal

set "SC_NAME=%~1"
set "WD=%~2"
set "CMD_LINE=%~3"

if "%SC_NAME%" == "" (
  echo %~nx0: error: Shortcut name is not defined
  exit /b 1
) >&2

call :SET
goto :EOF

:SET
echo.Current directory: "%CD%"
call :CMD "%%~dp0make_shortcut.vbs" "%%SC_NAME%%" "%%WD%%" "%%%%COMSPEC%%%%" "%%CMD_LINE%%"

goto :EOF

:CMD
echo.^>%*
(%*)
