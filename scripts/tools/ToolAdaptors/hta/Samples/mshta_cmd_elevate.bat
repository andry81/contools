@echo off

rem Description:
rem   Uniform variant of a command line as a single argument for the
rem   `mshta.exe` executable and other cases.
rem   You must take care about escaping of nested quotes and Windows Batch
rem   control characters.

rem   NOTE:
rem     `ExecuteGlobal` is used as a workaround, because the `mshta.exe` first
rem     argument must not be used with the surrounded quotes.

setlocal DISABLEDELAYEDEXPANSION

call "%%~dp0..\..\__init__\__init__.bat" || exit /b

rem The `__QARG0__` forms a Windows Batch compatible command line with escapes,
rem where:
rem   `\""` is a single nested `"`, `\""""` is a double nested `"` ,
rem   `\""""""` is a triple nested `"` and so on.
rem
rem NOTE:
rem   The `\""` sequence always have has an even number of double quotes to
rem   always quote a string in between because the `set` command argument
rem   is started by a quote.

set "__QARG0__=vbscript:ExecuteGlobal(\""Close(CreateObject(\""""Shell.Application\"""").ShellExecute(\""""%COMSPEC%\"""", \""""/k @cd \""""""%CD%\"""""" & %CD:~0,2% & \""""""%CONTOOLS_UTILS_BIN_ROOT%/contools/printargs.exe\"""""" \""""""123 456\""""""\"""", \""""\"""", \""""runas\"""", 1))\"")"

rem the input to translate
set __QARG0__

echo;---

rem Command line variant for the executable with C runtime command line parser

echo Translated into C runtime command line format:
echo;

rem translate Windows Batch compatible escapes into escape placeholders
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!__QARG0__:$=$0!") do endlocal & set "?.=%%i"
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!?.:\""""""=$3!") do endlocal & set "?.=%%i"
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!?.:\""""=$2!") do endlocal & set "?.=%%i"
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!?.:\""=$1!") do endlocal & set "?.=%%i"

rem translate escape placeholders into C runtime command line escapes
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!?.:$3=\\\\\\\"!"") do endlocal & set "?.=%%i"
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!?.:~0,-1!") do endlocal & set "?.=%%i"
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!?.:$2=\\\"!"") do endlocal & set "?.=%%i"
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!?.:~0,-1!") do endlocal & set "?.=%%i"
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!?.:$1=\"!"") do endlocal & set "?.=%%i"
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!?.:~0,-1!") do endlocal & set "?.=%%i"
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!?.:$0=$!") do endlocal & set "?.=%%i"

set ?.

echo;---

echo Executed as `printargs.exe "<?.>"` (with quotes):
echo;

setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!?.!") do endlocal & ^
"%CONTOOLS_UTILS_BIN_ROOT%/contools/printargs.exe" "%%i"

echo;---

echo Translated into `mshta.exe` command line format:
echo;

rem Command line variant for `mshta.exe` executable

rem translate Windows Batch compatible escapes into escape placeholders
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!__QARG0__:$=$0!") do endlocal & set "?.=%%i"
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!?.:\""""""=$3!") do endlocal & set "?.=%%i"
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!?.:\""""=$2!") do endlocal & set "?.=%%i"
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!?.:\""=$1!") do endlocal & set "?.=%%i"

rem translate escape placeholders into `mshta.exe` (vbs) escapes (`""` is a single nested `"`, `""""` is a double nested `"` and so on)
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!?.:$3=""""!") do endlocal & set "?.=%%i"
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!?.:$2=""!") do endlocal & set "?.=%%i"
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!?.:$1="!"") do endlocal & set "?.=%%i"
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!?.:~0,-1!") do endlocal & set "?.=%%i"
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!?.:$0=$!") do endlocal & set "?.=%%i"

set ?.

echo;---

echo Executed as `start /B /WAIT "" mshta.exe ^<?.^>` (without quotes):
echo;

setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!?.!") do endlocal & ^
start /B /WAIT "" "%SystemRoot%\System32\mshta.exe" %%i
