@echo off

setlocal DISABLEDELAYEDEXPANSION

if %IMPL_MODE%0 NEQ 0 goto IMPL

call "%%~dp0__init__/__init__.bat" || exit /b

call "%%CONTOOLS_ROOT%%/std/declare_builtins.bat" %%0 %%* || exit /b

"%CONTOOLS_UTILITIES_BIN_ROOT%/contools/callf.exe" ^
  /v IMPL_MODE 1 /no-expand-env /no-subst-pos-vars /no-esc ^
  /print-win-error-string /ret-child-exit /pause-on-exit ^
  /disable-ctrl-signals /disable-ctrl-c-signal-no-inherit ^
  "%COMSPEC%" "/c \"@\"%?~f0%\" {*} ^& \"%CONTOOLS_ROOT%/std/errlvl.bat\"\""

set LAST_ERROR=%ERRORLEVEL%

echo.LAST_ERROR=%LAST_ERROR%

exit /b %LAST_ERROR%

:IMPL

:REPEAT_LOOP

call "%%CONTOOLS_ROOT%%/std/choice.bat" -c q CHOICE_VALUE Press [q] to quit or CTRL+C/CTRL-BREAK to test...
rem "%SystemRoot%\System32\choice.exe" /C q /m "Press [q] to quit or CTRL+C/CTRL-BREAK to test..."

set LAST_ERROR=%ERRORLEVEL%

rem if %ERRORLEVEL% EQU 1 exit /b
if /i "%CHOICE_VALUE%" == "q" exit /b

goto REPEAT_LOOP
