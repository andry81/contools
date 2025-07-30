@echo off

setlocal

call "%%~dp0__init__/__init__.bat"

echo Running %~nx0...

rem safe title call
setlocal DISABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("%~nx0 %*") do endlocal & title %%i

set /A __NEST_LVL+=1

setlocal EnableDelayedExpansion

set __COUNTER1=1
set __STRING_CHARS__=0

for /L %%i in (1,1,1000) do call :SET %%i

set __COUNTER1=1

for /L %%i in (1,1,1000) do call :GET %%i

echo;

set /A __NEST_LVL-=1
if %__NEST_LVL%0 EQU 0 call "%%CONTOOLS_ROOT%%/std/pause.bat"

exit /b 0

:GET
echo;%__COUNTER1% !STRING_%__COUNTER1%:~0,4!..!STRING_%__COUNTER1%:~-4!
set /A __COUNTER1+=1
exit /b 0

:SET
set INDEX=%~1
set /A INDEX_BLOCK=%INDEX% %% 10

set __STRING__=!__STRING_CHARS__:~-1!
set __STRING_LEN__=1
for /L %%i in (1,1,10) do (
  set __STRING__=!__STRING__!!__STRING__!
  set /A __STRING_LEN__*=2
)

set STRING_%__COUNTER1%=!__STRING__!

if %INDEX_BLOCK% EQU 1 echo;%INDEX% len=%__STRING_LEN__%

set /A __STRING_CHARS__+=1
set /A __COUNTER1+=1
