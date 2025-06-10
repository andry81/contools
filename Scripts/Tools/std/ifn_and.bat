@echo off
rem echo;%*
:IF
(call) & goto :IF%~1
exit /b -1

:IF1
if %~2 <nul ( shift & shift ) else exit /b 255
( if not "%~1" == "" goto IF ) & exit /b 0

:IF3
if %2 %~3 %4 <nul ( shift & shift & shift & shift ) else exit /b 255
( if not "%~1" == "" goto IF ) & exit /b 0

:IF4
if %~2 %3 %~4 %5 <nul ( shift & shift & shift & shift & shift ) else exit /b 255
( if not "%~1" == "" goto IF ) & exit /b 0

:IF5
if %~2 %~3 %4 %~5 %6 <nul ( shift & shift & shift & shift & shift & shift ) else exit /b 255
( if not "%~1" == "" goto IF ) & exit /b 0
