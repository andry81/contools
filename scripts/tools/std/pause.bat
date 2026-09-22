@echo off & goto DOC_END

rem USAGE:
rem   pause.bat [-c] [-chcp <code-page>]

rem Description:
rem   Sets the code page to the last known (`%LAST_CP%`) after a code page
rem   restore routine (basically after a call to the `restorecp.bat` script).
rem   That is required in cases where the code page before a call to the
rem   `chcp.bat` was different when the after and so the `pause` command does
rem   print unreadable text in the log. This is it, all output into a log file
rem   must be made under the same code page!
rem
rem NOTE:
rem   Script does not change the error level because restores it internally
rem
rem CAUTION:
rem   The `chcp.com` does reset the standard input.
rem   See for the details:
rem     "`chcp.com` and `fc.exe` does reset the standard input" :
rem     https://github.com/andry81/contools/discussions/35

rem CAUTION:
rem   The double redirection has an issue versus `callf` utility.
rem   See for details:
rem     "`set /p` skips the input after `callf` call with the elevation" :
rem     https://github.com/andry81/contools/discussions/37

rem -c
rem   Pause only when `cmd.exe` is not in the interactive mode (see
rem   `is_input_interactive.bat` script).

rem -chcp <code-page>
rem   Change the code page to <code-page> before the pause.
:DOC_END

setlocal & set "LAST_ERROR=%ERRORLEVEL%"

set "?~dp0=%~dp0"

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"

rem script flags
set FLAG_NOT_INTERACTIVE_ONLY_PAUSE=0
set "FLAG_CHCP="

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG if "%FLAG%" == "-c"    set "FLAG_NOT_INTERACTIVE_ONLY_PAUSE=1"         & shift & call set "FLAG=%%~1"
if defined FLAG if "%FLAG%" == "-chcp" set "FLAG_CHCP=%~2"                     & shift & shift & call set "FLAG=%%~1"

if defined FLAG (
  echo;%?~%: error: invalid flag: %FLAG%
) >&2

if %FLAG_NOT_INTERACTIVE_ONLY_PAUSE% NEQ 0 call :IS_INPUT_INTERACTIVE && exit /b %LAST_ERROR%

if defined FLAG_CHCP (
  call "%%?~dp0%%chcp.bat" %%FLAG_CHCP%%
  if exist "%SystemRoot%\System32\timeout.exe" ( "%SystemRoot%\System32\timeout.exe" /T -1 ) else pause
  call "%%?~dp0%%restorecp.bat"
  exit /b %LAST_ERROR%
)

set "__?CHCP_FILE="
if exist "%SystemRoot%\System32\chcp.com" set "__?CHCP_FILE=%SystemRoot%\System32\chcp.com"
if not defined __?CHCP_FILE if exist "%SystemRoot%\System64\chcp.com" set "__?CHCP_FILE=%SystemRoot%\System64\chcp.com"
if not defined __?CHCP_FILE if exist "%SystemRoot%\SysWOW64\chcp.com" set "__?CHCP_FILE=%SystemRoot%\SysWOW64\chcp.com"

if not defined __?CHCP_FILE (
  if exist "%SystemRoot%\System32\timeout.exe" ( "%SystemRoot%\System32\timeout.exe" /T -1 ) else pause
  exit /b %LAST_ERROR%
)

for /F "usebackq tokens=1,* delims=:"eol^= %%i in (`@"%%__?CHCP_FILE%%" ^<nul 2^>nul`) do set "CURRENT_CP=%%j"
if defined CURRENT_CP set "CURRENT_CP=%CURRENT_CP: =%"

if exist "%SystemRoot%\System32\timeout.exe" (
  if defined LAST_CP if not "%CURRENT_CP%" == "%LAST_CP%" "%__?CHCP_FILE%" %LAST_CP% <nul >nul & "%SystemRoot%\System32\timeout.exe" /T -1 & "%__?CHCP_FILE%" %CURRENT_CP% <nul >nul & exit /b %LAST_ERROR%
  "%SystemRoot%\System32\timeout.exe" /T -1
) else (
  if defined LAST_CP if not "%CURRENT_CP%" == "%LAST_CP%" "%__?CHCP_FILE%" %LAST_CP% <nul >nul & pause & "%__?CHCP_FILE%" %CURRENT_CP% <nul >nul & exit /b %LAST_ERROR%
  pause
)

exit /b %LAST_ERROR%

:IS_INPUT_INTERACTIVE
rem copy of `is_input_interactive.bat` script
if not defined CMDCMDLINE exit /b 255

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
