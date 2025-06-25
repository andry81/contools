@echo off & goto DOC_END

rem USAGE:
rem   choice.bat [<flags>] [--] <variable> [<message>...]

rem Description:
rem   The choice utility wrapper, falls back to `set /P ...` if the utility
rem   does not exist (Windows XP 32-bit SP3).

rem <Flags>:
rem   -c <chars>
rem     List of choice key characters.
rem
rem   -exit_on_undefined_key
rem     Exit the input loop on undefined key selection.
rem     By default the input repeats.
rem     Has effect if `set /P ...` is used.
rem
rem   -use_set_command
rem     Use `set /P ...` instead of the choice utility if exists.
rem
rem   -X <param>
rem     Parameter to pass into the choice utility.

rem --:
rem   Separator to stop parse flags.

rem <variable>:
rem   Variable to return the selected key.

rem <message>:
rem   Message before the input echo;
rem   Leave empty if you want to echo input on the next line.
:DOC_END

setlocal

rem drop last error level
call;

set "?~dp0=%~dp0"
set "?~n0=%~n0"

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"

rem script flags
set FLAG_SHIFT=0
set FLAG_INPUT_CHARS=0
set FLAG_EXIT_ON_UNDEFINED_KEY=0
set FLAG_USE_SET_COMMAND=0
set "BARE_FLAGS="

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-c" (
    set "FLAG_INPUT_CHARS=%~2"
    shift
    set /A FLAG_SHIFT+=1
  ) else if "%FLAG%" == "-exit_on_undefined_key" (
    set FLAG_EXIT_ON_UNDEFINED_KEY=1
  ) else if "%FLAG%" == "-use_set_command" (
    set FLAG_USE_SET_COMMAND=1
  ) else if "%FLAG%" == "-X" (
    set BARE_FLAGS=%BARE_FLAGS% %2
    shift
    set /A FLAG_SHIFT+=1
  ) else if not "%FLAG%" == "--" (
    echo;%?~%: error: invalid flag: %FLAG%
    exit /b -255
  ) >&2

  shift
  set /A FLAG_SHIFT+=1

  rem read until no flags
  if not "%FLAG%" == "--" goto FLAGS_LOOP
)

set "VARIABLE=%~1"

set /A FLAG_SHIFT+=1

rem reset output variable if defined
if defined VARIABLE if defined %VARIABLE% set "%VARIABLE%="

call "%%?~dp0%%setshift.bat" -notrim %%FLAG_SHIFT%% MESSAGE %%*

if not defined VARIABLE (
  echo;%?~%: error: output variable name is not defined.
  exit /b -1
) >&2

if not defined FLAG_INPUT_CHARS (
  echo;%?~%: error: input selection key characters are not defined.
  exit /b -1
) >&2

if not defined MESSAGE goto SKIP_RECODE_MESSAGE

rem recode quote and exclamation characters
set "__?ESC__=^"
set __?QUOT__=^"
set "__?EXCL__=!"

rem replace a value quote characters by the \x01 character
set "MESSAGE=%MESSAGE:"=%"

rem recode quote and exclamation characters
set "MESSAGE=%MESSAGE:!=!__?EXCL__!%"
set "MESSAGE=%MESSAGE:^=!__?ESC__!%"
set "MESSAGE=%MESSAGE:=!__?QUOT__!%"

:SKIP_RECODE_MESSAGE

if %FLAG_USE_SET_COMMAND% NEQ 0 goto USE_SET_COMMAND_LOOP
if not exist "%SystemRoot%\System32\choice.exe" goto USE_SET_COMMAND_LOOP

rem default flags
if not defined BARE_FLAGS set "BARE_FLAGS= /N"

:USE_CHOICE_COMMAND_LOOP

if defined MESSAGE (
  rem special escape sequence for the choice utility
  set "MESSAGE=%MESSAGE:!__?QUOT__!=\!__?QUOT__!%"
  setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!MESSAGE!") do for /F "tokens=* delims="eol^= %%j in ("%%i") do endlocal & "%SystemRoot%\System32\choice.exe" /C "%FLAG_INPUT_CHARS%"%BARE_FLAGS% /M "%%j"
) else "%SystemRoot%\System32\choice.exe" /C "%FLAG_INPUT_CHARS%"%BARE_FLAGS%

set LAST_ERROR=%ERRORLEVEL%

rem not defined choice
if not %LAST_ERROR% GTR 0 (
  if %FLAG_EXIT_ON_UNDEFINED_KEY% EQU 0 goto USE_CHOICE_COMMAND_LOOP
  exit /b 0
)

set /A COUNT=LAST_ERROR-1

call set "INPUT_CHAR=%%FLAG_INPUT_CHARS:~%COUNT%,1%%"

(
  endlocal
  set "%VARIABLE%=%INPUT_CHAR%"
  exit /b %LAST_ERROR%
)

:USE_SET_COMMAND_LOOP
if defined MESSAGE (
  setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!MESSAGE!") do for /F "tokens=* delims="eol^= %%j in ("%%i") do endlocal & set /P "%VARIABLE%=%%j"
) else set /P "%VARIABLE%="

rem not defined choice
if not defined %VARIABLE% (
  if %FLAG_EXIT_ON_UNDEFINED_KEY% EQU 0 goto USE_SET_COMMAND_LOOP
  exit /b 0
)

set COUNT=0
call set "INPUT_CHAR=%%%VARIABLE%%%"

:SET_VARIABLE_CHARS_LOOP

call set "INPUT_CHAR_VARIANT=%%FLAG_INPUT_CHARS:~%COUNT%,1%%"
set /A LAST_ERROR=COUNT+1

if not defined INPUT_CHAR_VARIANT (
  if %FLAG_EXIT_ON_UNDEFINED_KEY% EQU 0 goto USE_SET_COMMAND_LOOP
  endlocal
  set "%VARIABLE%=%INPUT_CHAR%"
  exit /b 0
) else if /i "%INPUT_CHAR_VARIANT%" == "%INPUT_CHAR%" (
  endlocal
  set "%VARIABLE%=%INPUT_CHAR%"
  exit /b %LAST_ERROR%
)

set /A COUNT+=1

goto SET_VARIABLE_CHARS_LOOP
