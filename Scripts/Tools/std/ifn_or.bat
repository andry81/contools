@echo off
rem call "%%~dp0call.bat" echo;%%*
(call)
goto :IF%~1
exit /b -1

:IF1
if %~2 ( exit /b 0 ) else shift /2
if not "%~2" == "" goto IF1
exit /b 255

:IF3
if %2 %~3 %4 ( exit /b 0 ) else shift /2 & shift /2 & shift /2
if not "%~3" == "" goto IF3
exit /b 255

:IF4
if %~2 %3 %~4 %5 ( exit /b 0 ) else shift /2 & shift /2 & shift /2 & shift /2
if not "%~4" == "" goto IF4
exit /b 255

:IF5
if %~2 %~3 %4 %~5 %6 ( exit /b 0 ) else shift /2 & shift /2 & shift /2 & shift /2 & shift /2
if not "%~5" == "" goto IF5
exit /b 255
