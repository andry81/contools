@echo off

rem Script to create the Windows shortcut file to the "COMSPEC /C <cmdline>" in
rem the "%SYSTEMROOT%" directory (specific run under Windows XP only).
rem Creating a shortcut in the "%SYSTEMROOT%" directory under Windows XP avoids
rem parasite path prefixes in the output shortcut file.

set "SC_NAME=%~1"
set "WD=%~2"
set "CMD_LINE=%~3"

if "%SC_NAME%" == "" (
  echo %~nx0: error: Shurtcut name is not defined>&2
  exit /b 1
)
if not "%CMD_LINE%" == "" (
  echo %~nx0: error: Command line for the shortcut is not defined>&2
  exit /b 2
)

rem Drom last error level
cd .

rem Save all variables to stack
setlocal

call :SET "%SYSTEMROOT%"
goto :EOF

:SET
%~d0
pushd "%~d0\" && (
  if "%CMD_LINE%" == "" (
    echo "%~dp0make_shortcut.vbs" "%SC_NAME%" "%WD%" "%%COMSPEC%%" "/C"
    "%~dp0make_shortcut.vbs" "%SC_NAME%" "%WD%" "%%COMSPEC%%" "/C"
  ) else (
    echo "%~dp0make_shortcut.vbs" "%SC_NAME%" "%WD%" "%%COMSPEC%%" "/C %CMD_LINE%"
    "%~dp0make_shortcut.vbs" "%SC_NAME%" "%WD%" "%%COMSPEC%%" "/C %CMD_LINE%"
  )
)
goto :EOF
