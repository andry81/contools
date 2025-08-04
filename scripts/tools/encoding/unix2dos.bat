@echo off & goto DOC_END

rem USAGE:
rem   unix2dos.bat [-i] <file>

rem Description:
rem   Converts mixed line endings text file into Windows text format.
rem   Msys2 tries to be used at first if `CONTOOLS_MSYS2_USR_ROOT` is defined,
rem   otherwise falls back to GnuWin32 if `CONTOOLS_GNUWIN32_ROOT` is defined.

rem -i
rem   Use in place conversion instead of read <file> and print result into
rem   stdout.
:DOC_END

setlocal

call "%%~dp0__init__.bat" || exit /b

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"

rem script flags
set FLAG_INPLACE=0
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

if defined CONTOOLS_MSYS2_USR_ROOT (
  "%CONTOOLS_MSYS2_USR_ROOT%/bin/sed.exe" -b%SED_BARE_FLAGS% ^
    -n -b -e "H;1h;$!d;x" ^
    -e "s/\r\([^\n]\)/\r\n\1/mg" -e "s/\r\([^\n]\)/\r\n\1/mg" -e "s/\([^\r]\)\n/\1\r\n/mg" -e "s/\([^\r]\)\n/\1\r\n/mg" ^
    -e "s/^$/\r/mg" -e "p" "%INPUT_FILE%"
) else if defined CONTOOLS_GNUWIN32_ROOT (
  "%CONTOOLS_GNUWIN32_ROOT%/bin/sed.exe" -b%SED_BARE_FLAGS% ^
    -n -b -e "H;1h;$!d;x" ^
    -e "s/\r\([^\n]\)/\r\n\1/mg" -e "s/\r\([^\n]\)/\r\n\1/mg" -e "s/\([^\r]\)\n/\1\r\n/mg" -e "s/\([^\r]\)\n/\1\r\n/mg" ^
    -e "s/^$/\r/mg" -e "p" "%INPUT_FILE%"

  if %FLAG_INPLACE% NEQ 0 (
    rem delete sed in place backups (required for `GnuWin32`)
    del /F /Q /A:-D "sed??????" 2>nul
  )
) else (
  echo;%?~%: error: `sed` executable external path is not defined.
  exit /b 255
) >&2
