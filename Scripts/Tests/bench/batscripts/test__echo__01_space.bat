@echo off

setlocal

call "%%~dp0__init__/__init__.bat" || exit /b

echo.^>%~nx0

set "TEMP_FILE=%TEMP%\@type-%RANDOM%-%RANDOM%.txt"

setlocal DISABLEDELAYEDEXPANSION

set "BEGIN_TIME=%TIME%"

(
  for /L %%i in (1,1,10000) do (
    echo Hello world!
  )
) >nul

call "%%CONTOOLS_ROOT%%/timediff.bat" "%%BEGIN_TIME%%" "%%TIME%%"

(
  endlocal
  set "TIMEDIFF=%TIMEDIFF%"
)

set /A TIMEDIFF/=10

set /A TIME_SECS=%TIMEDIFF% / 1000
set /A TIME_MSECS=%TIMEDIFF% %% 1000

if "%TIME_MSECS:~2,1%" == "" set "TIME_MSECS=0%TIME_MSECS%"
if "%TIME_MSECS:~2,1%" == "" set "TIME_MSECS=0%TIME_MSECS%"

echo Time spent: %TIME_SECS%.%TIME_MSECS% msecs
echo.

del /F /Q /A:-D "%TEMP_FILE%" >nul 2>nul

exit /b 0
