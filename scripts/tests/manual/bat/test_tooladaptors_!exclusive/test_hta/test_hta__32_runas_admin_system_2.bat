@echo off

setlocal DISABLEDELAYEDEXPANSION

call "%%~dp0__init__/__init__.bat" || exit /b

echo;^>%~nx0

set "CMDLINE=\""%USERBIN_SCRIPTS_BAT_ROOT%/print-args-as-splitted-exe-cmdline.bat\"" \""123 & 456\"" \""654 | 321\"""

call "%%CONTOOLS_ROOT%%/std/is_system_elevated.bat" && (
  set CMDLINE="%SystemRoot%\System32\cmd.exe" /S /c "%CMDLINE%"
  call;
) || (
  set "PSEXEC=%CONTOOLS_SYSINTERNALS_ROOT%/psexec.exe"
  set CMDLINE="%SystemRoot%\System32\cmd.exe" /S /k "%CMDLINE%"
)

"%CONTOOLS_TOOL_ADAPTORS_ROOT%/hta/runas_admin_system.bat" %CMDLINE%
