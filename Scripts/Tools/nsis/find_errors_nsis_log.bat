@echo off

set "NSIS_LOG_FILE=%~1"

set FIND_ERRORS=0
set FIND_WARNINGS=0

echo.Log file: "%CD:\=/%/%NSIS_LOG_FILE%"

rem TODO:
rem   * Fix not full Usage output, where prints only first text line:
rem   >Usage: WriteRegBin rootkey subkey entry_name hex_string_like_12848412AB
rem   >   root_key=(HKCR|HKLM|HKCU|HKU|HKCC|HKDD|HKPD|SHCTX)
rem   Solution: Print all next lines after, until EOF or until first printable character in a line

rem print debug NSIS messages at first
"%SystemRoot%\System32\findstr.exe" /R /I /N /A:05 ^
/C:" (macro:!debug_echo:" ^
"%NSIS_LOG_FILE%"

rem print critical NSIS warnings as errors at second
"%SystemRoot%\System32\findstr.exe" /R /I /N /A:04 ^
/C:"^error:" ^
/C:"^error -" ^
/C:"^!error:" ^
/C:"open at EOF" ^
/C:"error in script" ^
/C:"error in macro" ^
/C:"not defined!" ^
/C:"already defined!" ^
/C:"requires [0-9][0-9]* parameter(s), passed [0-9][0-9]*" ^
/C:"expects [0-9][0-9]*-[0-9][0-9]* parameters, got [0-9][0-9]*" ^
/C:"expects [0-9][0-9]* parameters, got [0-9][0-9]*" ^
/C:"expects [0-9][0-9]*\+ parameters, got [0-9][0-9]*" ^
/C:"no macro currently open" ^
/C:"could not find:" ^
/C:"Invalid command:" ^
/C:"unknown variable" ^
/C:"unknown constant" ^
/C:"^Call must " ^
/C:"is not set in language" ^
/C:"^Plugin not found" ^
/C:"^Plugin function not found" ^
/C:"no files found" ^
/C:"can't " ^
/C:"cannot interpret " ^
/C:"macro named .* not found!" ^
/C:"^warning: Invalid number:" ^
/C:"^!endif: no " ^
/C:"^Invalid label: " ^
/C:": unterminated " ^
/C:" not found, aborted search!" ^
/C:"^!macro:" ^
/C:"^!verbose:" ^
"%NSIS_LOG_FILE%"
if %ERRORLEVEL% EQU 0 set FIND_ERRORS=1

rem print not critical warnings
"%SystemRoot%\System32\findstr.exe" /R /I /N /A:06 ^
/C:"^warning:" ^
/C:"not referenced" ^
/C:"^Usage:" ^
/C:"^Note:" ^
/C:"^Var: currently" ^
"%NSIS_LOG_FILE%"
if %ERRORLEVEL% EQU 0 set FIND_WARNINGS=2

if %FIND_ERRORS% NEQ 0 exit /b 1

exit /b 0
