@echo off

rem Drop last error level
type nul>nul

rem Create local variable's stack
setlocal

if 0%__CTRL_SETLOCAL% EQU 1 (
  echo.%~nx0: error: cmd.exe is broken, please restart it!>&2
  exit /b 65535
)
set __CTRL_SETLOCAL=1

call "%%~dp0__init__.bat" || exit /b
call "%%TESTLIB_ROOT%%/init.bat" "%%~dpf0" || exit /b

set __STRING__=a\b\.c
set __CHARS__=\.
set "STRING_REFERENCE=a\\b\\\.c"
call :TEST 6

set __STRING__=a\b\.c
set __CHARS__=.
set "STRING_REFERENCE=a\b\\.c
call :TEST 6

set __STRING__=a\b\.c
set "__CHARS__="
set "STRING_REFERENCE=a\\b\\.c"
call :TEST 6

set __STRING__= ^	-'`^?^*^&^|^<^>^(^)
set __CHARS__= '^?
set "STRING_REFERENCE=\ 	-\'`\?*&|<>()"
call :TEST 13

set __STRING__= ^	-'`^?^*
set __CHARS__=	^*
set "STRING_REFERENCE= \	-'`?\*"
call :TEST 7

set __STRING__='`^?^*^&^|^<^>^(^)
set __CHARS__=^|^?
set "STRING_REFERENCE='`\?*&\|<>()"
call :TEST 10

set __STRING__= ^	-'`^?^*^&^|^<^>^(^)'`%%
set __CHARS__=%% 
set "STRING_REFERENCE=\ 	-'`?*&|<>()'`\%%"
call :TEST 16

set __STRING__=	
set __CHARS__= 
set "STRING_REFERENCE=	"
call :TEST 1

set __STRING__= ^	
set __CHARS__= 
set "STRING_REFERENCE=\ 	"
call :TEST 2

set __STRING__=^^
set __CHARS__=^^
set "STRING_REFERENCE=\^"
call :TEST 1

set "__STRING__="
set __CHARS__=\
set "STRING_REFERENCE="
call :TEST 0

echo.

rem WARNING: must be called without the call prefix!
"%TESTLIB_ROOT%/exit.bat"

rem no code can be executed here, just in case
exit /b

:TEST
call "%%TESTLIB_ROOT%%/test.bat" %%*
exit /b
