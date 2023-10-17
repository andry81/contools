@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script to copy file(s) from one directory to another with rename option
rem   through the copy-and-delete. If output name is different than the input
rem   one then the script will copy the file into output directory w/o renaming
rem   it and only after that will try to rename the file. If the file would be
rem   somehow locked on a moment of rename then the original file will be left
rem   unrenamed in the output directory to manual rename later.

rem Examples:
rem 1. call xcopy_file_rename.bat "%%FROM_PATH%%" "%%TO_PATH%%" "%%FROM_FILE%%" "%%TO_FILE%%" || exit /b

echo.^>%~nx0 %*

setlocal

set "?~dp0=%~dp0"
set "?~n0=%~n0"
set "?~nx0=%~nx0"

rem script flags
set "FLAG_CHCP="
set FLAG_USE_XCOPY=0

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-chcp" (
    set "FLAG_CHCP=%~2"
    shift
  ) else if "%FLAG%" == "-use_xcopy" (
    set FLAG_USE_XCOPY=1
  ) else (
    echo.%?~nx0%: error: invalid flag: %FLAG%
    exit /b -255
  ) >&2

  shift

  rem read until no flags
  goto FLAGS_LOOP
)

set "FROM_PATH=%~1"
set "TO_PATH=%~2"
set "FROM_FILE=%~3"
set "TO_FILE=%~4"

if not defined FROM_PATH (
  echo.%?~nx0%: error: input directory path argument must be defined.
  exit /b -255
) >&2

if not defined TO_PATH (
  echo.%?~nx0%: error: output directory path argument must be defined.
  exit /b -254
) >&2

if not defined FROM_FILE (
  echo.%?~nx0%: error: input from file argument must be defined.
  exit /b -253
) >&2

if not defined TO_FILE (
  echo.%?~nx0%: error: input to file argument must be defined.
  exit /b -252
) >&2

set "FROM_PATH=%FROM_PATH:/=\%"
set "TO_PATH=%TO_PATH:/=\%"
set "FROM_FILE=%FROM_FILE:/=\%"
set "TO_FILE=%TO_FILE:/=\%"

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

goto FROM_PATH_OK

:FROM_PATH_ERROR
(
  echo.%?~nx0%: error: input directory path is invalid: FROM_PATH="%FROM_PATH%" FROM_FILE="%FROM_FILE%" TO_PATH="%TO_PATH%" TO_FILE="%TO_FILE%".
  exit /b -250
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

if "\" == "%TO_PATH:~0,1%" goto TO_PATH_ERROR

goto TO_PATH_OK

:TO_PATH_ERROR
(
  echo.%?~nx0%: error: output directory path is invalid: FROM_PATH="%FROM_PATH%" FROM_FILE="%FROM_FILE%" TO_PATH="%TO_PATH%" TO_FILE="%TO_FILE%".
  exit /b -249
) >&2

:TO_PATH_OK

rem check on missed components...

rem check on invalid characters in file pattern
if not "%FROM_FILE%" == "%FROM_FILE:\=%" goto FROM_FILE_ERROR

goto FROM_FILE_OK

:FROM_FILE_ERROR
(
  echo.%?~nx0%: error: input from file is invalid: FROM_PATH="%FROM_PATH%" FROM_FILE="%FROM_FILE%" TO_PATH="%TO_PATH%" TO_FILE="%TO_FILE%".
  exit /b -248
) >&2

:FROM_FILE_OK

rem check on missed components...

rem check on invalid characters in file pattern
if not "%TO_FILE%" == "%TO_FILE:\=%" goto TO_FILE_ERROR

goto TO_FILE_OK

:TO_FILE_ERROR
(
  echo.%?~nx0%: error: input to file is invalid: FROM_PATH="%FROM_PATH%" FROM_FILE="%FROM_FILE%" TO_PATH="%TO_PATH%" TO_FILE="%TO_FILE%".
  exit /b -247
) >&2

:TO_FILE_OK

set "FROM_ROOT=%~f1"
set "TO_ROOT=%~f2"

if not exist "\\?\%FROM_ROOT%\*" (
  echo.%?~nx0%: error: input directory does not exist: "%FROM_PATH%\"
  exit /b -246
) >&2

if not exist "\\?\%TO_ROOT%\*" (
  echo.%?~nx0%: error: output directory does not exist: "%TO_PATH%\"
  exit /b -245
) >&2

call "%%?~dp0%%__init__.bat" || exit /b

set "XCOPY_BARE_FLAGS="
set "COPY_BARE_FLAGS="
if defined FLAG_CHCP set XCOPY_BARE_FLAGS= -chcp "%FLAG_CHCP%"
if defined FLAG_CHCP set COPY_BARE_FLAGS= -chcp "%FLAG_CHCP%"

if /i not "%FROM_ROOT%" == "%TO_ROOT%" (
  ( call "%%CONTOOLS_ROOT%%/std/xcopy_file.bat"%%XCOPY_BARE_FLAGS%% "%%FROM_ROOT%%" "%%FROM_FILE%%" "%%TO_ROOT%%" /Y /D || exit /b ) && if /i not ^
      "%FROM_FILE%" == "%TO_FILE%" (
    (
      call "%%CONTOOLS_ROOT%%/std/copy.bat"%%COPY_BARE_FLAGS%% "%%TO_ROOT%%/%%FROM_FILE%%" "%%TO_ROOT%%/%%TO_FILE%%" /B /Y || exit /b
    ) && (
      call "%%CONTOOLS_ROOT%%/std/del_file.bat" "%%TO_ROOT%%/%%FROM_FILE%%" /F /Q || exit /b
    )
  )
) else if /i not "%FROM_FILE%" == "%TO_FILE%" (
  (
    call "%%CONTOOLS_ROOT%%/std/copy.bat"%%COPY_BARE_FLAGS%% "%%TO_ROOT%%/%%FROM_FILE%%" "%%TO_ROOT%%/%%TO_FILE%%" /B /Y || exit /b
  ) && (
    call "%%CONTOOLS_ROOT%%/std/del_file.bat" "%%TO_ROOT%%/%%FROM_FILE%%" /F /Q || exit /b
  )
)

exit /b 0
