@echo off & goto DOC_END

rem USAGE:
rem   unix2dos.bat [-i] [-fix-tail-lr] <file>

rem Description:
rem   Converts mixed line endings text file into Windows text format.
rem   Msys2 tries to be used at first if `CONTOOLS_MSYS2_USR_ROOT` is defined,
rem   otherwise falls back to GnuWin32 if `CONTOOLS_GNUWIN32_ROOT` is defined.

rem -i
rem   Use in place conversion instead of read <file> and print result into
rem   stdout.
rem
rem -fix-tail-lr
rem   Fix the last line return.
rem   Uses multiple calls to `sed` to query the file and slow downs the
rem   execution.
:DOC_END

setlocal

call "%%~dp0__init__.bat" || exit /b

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"

rem script flags
set FLAG_INPLACE=0
set FLAG_FIX_TAIL_LR=0
set "SED_BARE_FLAGS="

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG if "%FLAG%" == "-i" (
  set FLAG_INPLACE=1
  shift
  set SED_BARE_FLAGS=%SED_BARE_FLAGS% -i
)

set "FLAG=%~1"

if defined FLAG if "%FLAG%" == "-fix-tail-lr" (
  set FLAG_FIX_TAIL_LR=1
  shift
)

set "INPUT_FILE=%~1"

if not exist "%INPUT_FILE%" (
  echo;%?~%: error: INPUT_FILE does not exist: INPUT_FILE="%INPUT_FILE%".
  exit /b 1
) >&2

rem Based on: https://unix.stackexchange.com/questions/182153/sed-read-whole-file-into-pattern-space-without-failing-on-single-line-input/182154#182154
rem
rem NOTE:
rem   Reads portably whole file into pattern space.
rem

rem WORKAROUND:
rem   To workaround the last line feed (LF) character manipulation by the `sed`:
rem     1. Check the last line on not empty with ending by the line feed (LF) character only.
rem     2. If not, then check the last line on ending by the carriage return (CR) character.
rem     3. If (1), then replace the ending LF by CR+LF.
rem     4. If (2), then append LF only.

set "SED_EXEC="
if defined CONTOOLS_MSYS2_USR_ROOT (
  set "SED_EXEC=%CONTOOLS_MSYS2_USR_ROOT%/bin/sed.exe"
) else if defined CONTOOLS_GNUWIN32_ROOT set "SED_EXEC=%CONTOOLS_GNUWIN32_ROOT%/bin/sed.exe"

if defined SED_EXEC if exist "%SED_EXEC%" goto EXEC

(
  echo;%?~%: error: `sed` executable is not defined or not exist: "%SED_EXEC%".
  exit /b 255
) >&2

:EXEC
set "SED_APPEND_LF_EXPR="

if %FLAG_FIX_TAIL_LR% EQU 0 goto SKIP_FIX_TAIL_LR

for /F "tokens=* delims="eol^= %%i in ("%INPUT_FILE%") do set "INPUT_FILE_SIZE=%%~zi"

set LAST_LINE_NOT_EMPTY_WITH_LF=0
set LAST_CR=0
if %INPUT_FILE_SIZE% NEQ 0 (
  "%SED_EXEC%" -b -e "H;1h;$!d;x" -e "/$/s/$/\n/g" "%INPUT_FILE%" | "%SED_EXEC%" -n -b -e "H;1h;$!d;x" -e "/[^\r\n]\n$/q0; q1" && set LAST_LINE_NOT_EMPTY_WITH_LF=1
)
if %INPUT_FILE_SIZE% NEQ 0 if %LAST_LINE_NOT_EMPTY_WITH_LF% EQU 0 (
  "%SED_EXEC%" -b -e "H;1h;$!d;x" -e "/$/s/$/\n/g" "%INPUT_FILE%" | "%SED_EXEC%" -n -b -e "H;1h;$!d;x" -e "/\r$/q0; q1" && set LAST_CR=1
)

if %LAST_LINE_NOT_EMPTY_WITH_LF% NEQ 0 set SED_APPEND_LF_EXPR= -e "/$/s/$/\r/g"
if %LAST_CR% NEQ 0 set SED_APPEND_LF_EXPR= -e "/$/s/$/\n/g"

:SKIP_FIX_TAIL_LR
"%SED_EXEC%" -n -b%SED_BARE_FLAGS% ^
  -e "H;1h;$!d;x" ^
  -e "s/\r\([^\n]\)/\r\n\1/mg" -e "s/\r\([^\n]\)/\r\n\1/mg" -e "s/\([^\r]\)\n/\1\r\n/mg" -e "s/\([^\r]\)\n/\1\r\n/mg" ^
  -e "s/^$/\r/mg"%SED_APPEND_LF_EXPR% -e "p" "%INPUT_FILE%"

if defined CONTOOLS_GNUWIN32_ROOT if %FLAG_INPLACE% NEQ 0 (
  rem delete sed in place backups (required for `GnuWin32`)
  del /F /Q /A:-D "sed??????" 2>nul
)
