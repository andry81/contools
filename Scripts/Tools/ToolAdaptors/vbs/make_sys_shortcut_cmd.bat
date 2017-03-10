@echo off

rem Script to create the Windows shortcut file to the "COMSPEC <cmdline>" in
rem the "%SYSTEMROOT%\system32" directory (specific run under
rem Windows XP only).
rem Creating a shortcut in the "%SYSTEMROOT%" directory under Windows XP avoids
rem parasite path prefixes in the output shortcut file.

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

call :SET "%%SYSTEMROOT%%\system32\"
goto :EOF

:SET
%~d1
pushd "%~dp1" && (
  call echo.Current directory: "%%CD%%"
  call :CMD "%%~dp0make_shortcut.vbs" "%%SC_NAME%%" "%%WD%%" "%%%%COMSPEC%%%%" "%%CMD_LINE%%"
)

goto :EOF

:CMD
echo.^>%*
(%*)
