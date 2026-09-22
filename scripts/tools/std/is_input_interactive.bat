@echo off & if not defined CMDCMDLINE exit /b 255

setlocal DISABLEDELAYEDEXPANSION & setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!CMDCMDLINE!") do endlocal & set "__STRING__=%%i"

rem encode asterisk character (copy of `encode/encode_asterisk_char.bat` script)
setlocal ENABLEDELAYEDEXPANSION & if "!__STRING__!" == "!__STRING__:**=!" ( goto SKIP_ASTERISK_ENCODE ) else endlocal

:ASTERISK_ENCODE_LOOP
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=1 delims=*"eol^= %%i in (".!__STRING__!") do for /F "tokens=* delims="eol^= %%j in ("!__STRING__:**=!.") do endlocal & set "__STRING__=%%i$2A%%j" & ^
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!__STRING__:~1,-1!") do ^
if not "!__STRING__!" == "!__STRING__:**=!" ( endlocal & set "__STRING__=%%i" & goto ASTERISK_ENCODE_LOOP ) else endlocal & set "__STRING__=%%i"

:SKIP_ASTERISK_ENCODE

rem encode the rest globbing characters (copy of `encode/encode_glob_char.bat` script)
setlocal ENABLEDELAYEDEXPANSION & set "__STRING__=!__STRING__:<=$3C!" & set "__STRING__=!__STRING__:>=$3E!" & ^
for /F "tokens=* delims="eol^= %%i in ("!__STRING__:?=$3F!") do endlocal & set "__STRING__=%%i"

setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!__STRING__!") do endlocal & for %%j in (%%i) do ^
set "ARG=%%j" & setlocal ENABLEDELAYEDEXPANSION & ( if not "!ARG!" == "!ARG:/k=!" endlocal & goto CHECK_STDIN_REOPEN ) & ( if not "!ARG!" == "!ARG:/c=!" exit /b 255 ) & endlocal

:CHECK_STDIN_REOPEN & rem copy of `is_stdin_reopen.bat` script
"%SystemRoot%\System32\timeout.exe" /T 0 >nul 2>&1 && exit /b 0 & exit /b 255

rem Description:
rem   Script tests the `cmd.exe` process input on the interactive session which
rem   is enabled if:
rem     1. The `CMDLINELINE` variable value has `/k` flag or has no `/c` flag.
rem       AND
rem     2. The standard input is not reopened.
rem
rem   NOTE:
rem     The standard output can be reopened and session can be interactive,
rem     but other features like input completion or history traverse WILL BE
rem     disabled. You must additionally test the standard output on the
rem     redirection to detect these (see `is_stdout_reopen.bat` script).

rem Examples:
rem   1. >cmd.exe /k call is_input_interactive.bat /c ^&^& echo YES ^|^| echo NO ^& exit
rem      YES
rem
rem   2. >cmd.exe /c call is_input_interactive.bat /k ^&^& echo YES ^|^| echo NO ^& exit
rem      NO
rem
rem   3. >cmd.exe /k call is_input_interactive.bat /c ^&^& echo YES ^|^| echo NO ^& exit <nul
rem      NO
rem
rem   4. >cmd.exe /k call is_input_interactive.bat /c ^&^& echo YES ^|^| echo NO ^& exit >&2
rem      YES
rem
rem   5. >cmd.exe /c call is_input_interactive.bat /k ^&^& echo YES ^|^| echo NO ^& exit >&2
rem      NO
rem
rem   6. >cmd.exe /k call is_input_interactive.bat /c ^&^& echo YES ^|^| echo NO ^& exit <nul >&2
rem      NO
