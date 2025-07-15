@echo off & setlocal DISABLEDELAYEDEXPANSION
if not defined __STRING__ set "__STRING__=%~1"
if not defined __STRING__ exit /b 0
set "ASCII_CODE=-1" & for /F "usebackq tokens=* delims="eol^= %%i in ("%~dp0.asc\ascii-utf-7-bom.txt") do set /A "ASCII_CODE-=-1" & ^
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%j in ("!__STRING__!-") do ^
endlocal & if "%%i" == "%%j" (
  setlocal ENABLEDELAYEDEXPANSION & (
    if !ASCII_CODE! NEQ 0 if !ASCII_CODE! NEQ 10 if !ASCII_CODE! NEQ 13 exit /b !ASCII_CODE!
  ) & endlocal
) else if "%%i-" == "%%j" ^
setlocal ENABLEDELAYEDEXPANSION & (
  if !ASCII_CODE! NEQ 0 if !ASCII_CODE! NEQ 10 if !ASCII_CODE! NEQ 13 exit /b !ASCII_CODE!
) & endlocal
exit /b 0

rem USAGE:
rem   asc-utf-8.bat [<char>]

rem Description:
rem   Returns ASCII code for a character from either `__STRING__` variable or
rem   from the command line parameter. Basically independent to a code page
rem   including 65000 (UTF-7).
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
rem
rem   Examples:
rem
rem     Quote character
rem     >
rem     set __STRING__=^"
rem     asc-utf-8.bat
rem
rem     Caret character
rem     >
rem     set "__STRING__=^"
rem     asc-utf-8.bat
rem
rem     Shift encoded plus in 65000 (UTF-7) code page
rem     >
rem     asc-utf-8.bat "+-"
