@echo off & goto DOC_END

rem USAGE:
rem   copy.bat [<flags>] [--] <from-path> <to-path> [<copy-flags>...]

rem Description:
rem   The builtin `copy` command wrapper script with echo and some conditions
rem   check before call.
rem
rem   Does support long paths, but can not copy.
rem
rem   NOTE:
rem     All input paths must be without `\\?\` prefix because:
rem       1. Can be directly used in commands which does not support long paths
rem          like builtin `dir` command.
rem       2. Can be checked on absence of globbing characters which includes
rem          `?` character.
rem       3. The `%%~f` builtin variables extension and other extensions does
rem          remove the prefix and then a path can be prefixed internally by
rem          the script.

rem <flags>:
rem   -chcp <CodePage>
rem     Set explicit code page.

rem --:
rem   Separator to stop parse flags.

rem <from-path>:
rem   From path.

rem <to-path>:
rem   To path.

rem <copy-flags>:
rem   Command line flags to pass into builtin `copy` command.
:DOC_END

echo;^>%~nx0 %*

setlocal

set "?~dp0=%~dp0"
set "?~n0=%~n0"

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"

set "?~nx0=%~nx0"

rem script flags
set "FLAG_CHCP="

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-chcp" (
    set "FLAG_CHCP=%~2"
    shift
  ) else if not "%FLAG%" == "--" (
    echo;%?~%: error: invalid flag: %FLAG%
    exit /b -255
  ) >&2

  shift

  rem read until no flags
  if not "%FLAG%" == "--" goto FLAGS_LOOP
)

set "FROM_PATH=%~1"
set "TO_PATH=%~2"

if not defined FROM_PATH (
  echo;%?~%: error: input path argument must be defined.
  exit /b -255
) >&2

if not defined TO_PATH (
  echo;%?~%: error: output path argument must be defined.
  exit /b -254
) >&2

set "FROM_PATH=%FROM_PATH:/=\%"
set "TO_PATH=%TO_PATH:/=\%"

rem check on missed components...

rem ...forwarding `\` character
if "\" == "%FROM_PATH:~0,1%" goto FROM_PATH_ERROR

rem ...double `\\` character
if not "%FROM_PATH%" == "%FROM_PATH:\\=\%" goto FROM_PATH_ERROR

rem ...trailing `\` character
if "\" == "%FROM_PATH:~-1%" goto FROM_PATH_ERROR

rem check on invalid characters in path
if not "%FROM_PATH%" == "%FROM_PATH:**=%" goto FROM_PATH_ERROR
if not "%FROM_PATH%" == "%FROM_PATH:?=%" goto FROM_PATH_ERROR
if not "%FROM_PATH%" == "%FROM_PATH:<=%" goto FROM_PATH_ERROR
if not "%FROM_PATH%" == "%FROM_PATH:>=%" goto FROM_PATH_ERROR

goto FROM_PATH_OK

:FROM_PATH_ERROR
(
  echo;%?~%: error: input path is invalid: FROM_PATH="%FROM_PATH%" TO_PATH="%TO_PATH%".
  exit /b -253
) >&2

:FROM_PATH_OK

rem check on missed components...

rem ...forwarding `\` character
if "\" == "%TO_PATH:~0,1%" goto TO_PATH_ERROR

rem ...double `\\` character
if not "%TO_PATH%" == "%TO_PATH:\\=\%" goto TO_PATH_ERROR

rem ...trailing `\` character
if "\" == "%TO_PATH:~-1%" goto TO_PATH_ERROR

rem check on invalid characters in path
if not "%TO_PATH%" == "%TO_PATH:**=%" goto TO_PATH_ERROR
if not "%TO_PATH%" == "%TO_PATH:?=%" goto TO_PATH_ERROR
if not "%TO_PATH%" == "%TO_PATH:<=%" goto TO_PATH_ERROR
if not "%TO_PATH%" == "%TO_PATH:>=%" goto TO_PATH_ERROR

if "\" == "%TO_PATH:~0,1%" goto TO_PATH_ERROR

goto TO_PATH_OK

:TO_PATH_ERROR
(
  echo;%?~%: error: output path is invalid: FROM_PATH="%FROM_PATH%" TO_PATH="%TO_PATH%".
  exit /b -252
) >&2

:TO_PATH_OK

for /F "tokens=* delims="eol^= %%i in ("%FROM_PATH%\.") do set "FROM_PATH_ABS=%%~fi"
for /F "tokens=* delims="eol^= %%i in ("%TO_PATH%\.") do set "TO_PATH_ABS=%%~fi"

if not exist "\\?\%FROM_PATH_ABS%" (
  echo;%?~%: error: input path does not exist: "%FROM_PATH_ABS%"
  exit /b -251
) >&2

if defined FLAG_CHCP call "%%CONTOOLS_ROOT%%/std/chcp.bat" %%FLAG_CHCP%%

call "%%?~dp0%%setshift.bat" 2 COPY_FLAGS_ %%*

if defined COPY_FLAGS_ (
  echo;^>^>copy %COPY_FLAGS_% "%FROM_PATH_ABS%" "%TO_PATH_ABS%"
  copy %COPY_FLAGS_% "%FROM_PATH_ABS%" "%TO_PATH_ABS%"
) else (
  echo;^>^>copy "%FROM_PATH_ABS%" "%TO_PATH_ABS%"
  copy "%FROM_PATH_ABS%" "%TO_PATH_ABS%"
)

if defined FLAG_CHCP call "%%?~dp0%%restorecp.bat"
