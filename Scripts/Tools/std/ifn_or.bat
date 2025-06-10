@echo off
rem echo;%*
:IF
(call) & goto :IF%~1
exit /b -1

:IF1
if %~2 <nul ( exit /b 0 ) else shift & shift
( if not "%~1" == "" goto IF ) & exit /b 255

:IF3
if %2 %~3 %4 <nul ( exit /b 0 ) else shift & shift & shift & shift
( if not "%~1" == "" goto IF ) & exit /b 255

:IF4
if %~2 %3 %~4 %5 <nul ( exit /b 0 ) else shift & shift & shift & shift & shift
( if not "%~1" == "" goto IF ) & exit /b 255

:IF5
if %~2 %~3 %4 %~5 %6 <nul ( exit /b 0 ) else shift & shift & shift & shift & shift & shift
( if not "%~1" == "" goto IF ) & exit /b 255
