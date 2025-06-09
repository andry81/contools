@echo off
rem call "%%~dp0call.bat" echo;%%*
:IFN
(call)
goto :IF%~1
exit /b -1

:IF1
if %~2 ( shift & shift ) else exit /b 255
if not "%~1" == "" goto IFN
exit /b 0

:IF3
if %2 %~3 %4 ( shift & shift & shift & shift ) else exit /b 255
if not "%~1" == "" goto IFN
exit /b 0

:IF4
if %~2 %3 %~4 %5 ( shift & shift & shift & shift & shift ) else exit /b 255
if not "%~1" == "" goto IFN
exit /b 0

:IF5
if %~2 %~3 %4 %~5 %6 ( shift & shift & shift & shift & shift & shift ) else exit /b 255
if not "%~1" == "" goto IFN
exit /b 0
