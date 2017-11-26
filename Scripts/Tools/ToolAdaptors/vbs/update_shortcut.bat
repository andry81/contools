@echo off

rem Script to update the Windows shortcut file to the "<cmdline>"
rem in the current directory.

rem Drom last error level
type nul>nul

rem Save all variables to stack
setlocal

set "SC_NAME=%~1"
set "WD=%~2"
set "CMD=%~3"
set "ARGS=%~4"

if not defined SC_NAME (
  echo %~nx0: error: Shortcut name is not defined
  exit /b 1
) >&2
if not exist "%SC_NAME%" (
  echo %~nx0: error: Shortcut file is not exist
  exit /b 2
) >&2

call :SET
goto :EOF

:SET
echo.Current directory: "%CD:\=/%"
call :CMD "%%~dp0update_shortcut.vbs" "%%SC_NAME%%" "%%WD%%" "%%CMD%%" "%%ARGS%%"

goto :EOF

:CMD
echo.^>%*
(%*)
