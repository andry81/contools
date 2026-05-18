@echo off & setlocal DISABLEDELAYEDEXPANSION & if not defined __STRING__ set "__STRING__=%~1"
if not defined __STRING__ exit /b 0
set "ASCII_CODE=-1" & for /F "usebackq tokens=* delims="eol^= %%i in ("%~dp0.impl\ascii_utf_7_bom.txt") do set /A "ASCII_CODE-=-1" & ^
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%j in ("!__STRING__:~0,1!-") do ^
endlocal & if "%%i" == "%%j" (
  setlocal ENABLEDELAYEDEXPANSION & (
    if !ASCII_CODE! NEQ 0 if !ASCII_CODE! NEQ 10 if !ASCII_CODE! NEQ 13 exit /b !ASCII_CODE!
  ) & endlocal
) else if "%%i-" == "%%j" setlocal ENABLEDELAYEDEXPANSION & (
  if !ASCII_CODE! NEQ 0 if !ASCII_CODE! NEQ 10 if !ASCII_CODE! NEQ 13 exit /b !ASCII_CODE!
) & endlocal
exit /b 0

rem USAGE:
rem   asc_utf.bat [<char>]

rem Description:
rem   Returns ASCII code for a first character from either the command line
rem   parameter or from `__STRING__`variable. Basically independent to a code
rem   page including 65000 (UTF-7).
rem
rem   NOTE:
rem     The ASCII file table has NUL LF CR characters replaced by FF character,
rem     where:
rem       * The `NUL` affects all contexts and ignored including the BOM
rem         sequence ignore too.
rem       * The `LF` affects `!` character expansion in
rem         `setlocal DISABLEDELAYEDEXPANSION` context.
rem       * The `CR` affects `set /P ...` context.
rem       * The `+` is affected by `65000` (UTF-7) code page because is the
rem         Unicode shift character (See RFC 2152).

rem CAUTION:
rem   The `__STRING__` is used at first if defined, even if <char> is defined.
rem   This is due to invalid `if "%~1" == ""` expression evaluation, when
rem   `%~1` is defined but equals to an empty string.
rem   Ex: 173 ASCII code character (`­`).

rem Examples:
rem
rem  1. Quote character
rem     >
rem     set __STRING__=^"
rem     asc_utf.bat
rem
rem  2. Caret character
rem     >
rem     set "__STRING__=^"
rem     asc_utf.bat
rem
rem  3. Unicode encoded plus in 65000 (UTF-7) code page
rem     >
rem     asc_utf.bat "+-"
