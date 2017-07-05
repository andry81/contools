@echo off

rem Drop last error level
cd .

rem Create local variable's stack
setlocal

if 0%__CTRL_SETLOCAL% EQU 1 (
  echo.%~nx0: error: cmd.exe is broken, please restart it!>&2
  exit /b 65535
)
set __CTRL_SETLOCAL=1

call "%%~dp0__init__.bat"

call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" "aaa" "a1" x
set SCRIPT_TEMP
pause
call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" "aaa" "a2"
set SCRIPT_TEMP
pause
call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" "aaa" "a3"
set SCRIPT_TEMP
pause
call "%%CONTOOLS_ROOT%%/std/free_temp_dir.bat"
set SCRIPT_TEMP
pause
call "%%CONTOOLS_ROOT%%/std/free_temp_dir.bat"
set SCRIPT_TEMP
pause
call "%%CONTOOLS_ROOT%%/std/free_temp_dir.bat"
set SCRIPT_TEMP

pause
