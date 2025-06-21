@echo off & goto DOC_END

rem USAGE:
rem   xcopy_file_rename.bat [<flags>] [--] <from-path> <to-path> <from-file> <to-file>

rem Description:
rem   Script to copy file(s) from one directory to another with rename option
rem   through the copy-and-delete. If output name is different than the input
rem   one then the script will copy the file into output directory w/o renaming
rem   it and only after that will try to rename the file. If the file would be
rem   somehow locked on a moment of rename then the original file will be left
rem   unrenamed in the output directory to manual rename later.
rem
rem   Does support long paths, but can not rename and delete.
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
rem
rem   Can use command bare flags from `XCOPY_FILE_CMD_BARE_FLAGS` and
rem   `COPY_CMD_BARE_FLAGS` variables.
rem
rem   Can use utility flags from `XCOPY_FILE_FLAGS` and `COPY_FLAGS` variables.

rem <flags>:
rem   -chcp <CodePage>
rem     Set explicit code page.
rem
rem   -if_not_exist
rem     Copy if `<to-path>/<to-file>` does not exist.
rem
rem   -use_xcopy
rem     Use `xcopy` executable utility.
rem
rem   -use_cmd_bare_flags
rem     Use command bare flags from `XCOPY_FILE_CMD_BARE_FLAGS` and
rem     `COPY_CMD_BARE_FLAGS` variables.
rem
rem   -use_utility_flags
rem     Use utility flags from `XCOPY_FLAGS` and `COPY_FLAGS` variables.

rem --:
rem   Separator to stop parse flags.

rem <from-path>:
rem   From directory path.

rem <to-path>:
rem   To directory path.

rem <from-file>:
rem   From file name.

rem <to-file>:
rem   To file name.
:DOC_END

setlocal

set "?~dp0=%~dp0"
set "?~n0=%~n0"

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"

set "?~nx0=%~nx0"

rem script flags
set "FLAG_CHCP="
set FLAG_IF_NOT_EXIST=0
set FLAG_USE_XCOPY=0
set FLAG_USE_CMD_BARE_FLAGS=0
set FLAG_USE_UTILITY_FLAGS=0

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-chcp" (
    set "FLAG_CHCP=%~2"
    shift
  ) else if "%FLAG%" == "-if_not_exist" (
    set FLAG_IF_NOT_EXIST=1
  ) else if "%FLAG%" == "-use_xcopy" (
    set FLAG_USE_XCOPY=1
  ) else if "%FLAG%" == "-use_cmd_bare_flags" (
    set FLAG_USE_CMD_BARE_FLAGS=1
  ) else if "%FLAG%" == "-use_utility_flags" (
    set FLAG_USE_UTILITY_FLAGS=1
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
set "FROM_FILE=%~3"
set "TO_FILE=%~4"

if not defined FROM_PATH (
  echo;%?~%: error: input directory path argument must be defined.
  exit /b -255
) >&2

if not defined TO_PATH (
  echo;%?~%: error: output directory path argument must be defined.
  exit /b -254
) >&2

if not defined FROM_FILE (
  echo;%?~%: error: input from file argument must be defined.
  exit /b -253
) >&2

if not defined TO_FILE (
  echo;%?~%: error: input to file argument must be defined.
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
if not "%FROM_PATH%" == "%FROM_PATH:<=%" goto FROM_PATH_ERROR
if not "%FROM_PATH%" == "%FROM_PATH:>=%" goto FROM_PATH_ERROR

goto FROM_PATH_OK

:FROM_PATH_ERROR
(
  echo;%?~%: error: input directory path is invalid: FROM_PATH="%FROM_PATH%" FROM_FILE="%FROM_FILE%" TO_PATH="%TO_PATH%" TO_FILE="%TO_FILE%".
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
if not "%TO_PATH%" == "%TO_PATH:<=%" goto TO_PATH_ERROR
if not "%TO_PATH%" == "%TO_PATH:>=%" goto TO_PATH_ERROR

goto TO_PATH_OK

:TO_PATH_ERROR
(
  echo;%?~%: error: output directory path is invalid: FROM_PATH="%FROM_PATH%" FROM_FILE="%FROM_FILE%" TO_PATH="%TO_PATH%" TO_FILE="%TO_FILE%".
  exit /b -249
) >&2

:TO_PATH_OK

rem check on missed components...

rem check on invalid characters in file pattern
if not "%FROM_FILE%" == "%FROM_FILE:\=%" goto FROM_FILE_ERROR

goto FROM_FILE_OK

:FROM_FILE_ERROR
(
  echo;%?~%: error: input from file is invalid: FROM_PATH="%FROM_PATH%" FROM_FILE="%FROM_FILE%" TO_PATH="%TO_PATH%" TO_FILE="%TO_FILE%".
  exit /b -248
) >&2

:FROM_FILE_OK

rem check on missed components...

rem check on invalid characters in file pattern
if not "%TO_FILE%" == "%TO_FILE:\=%" goto TO_FILE_ERROR

goto TO_FILE_OK

:TO_FILE_ERROR
(
  echo;%?~%: error: input to file is invalid: FROM_PATH="%FROM_PATH%" FROM_FILE="%FROM_FILE%" TO_PATH="%TO_PATH%" TO_FILE="%TO_FILE%".
  exit /b -247
) >&2

:TO_FILE_OK

for /F "tokens=* delims="eol^= %%i in ("%FROM_PATH%\.") do set "FROM_DIR=%%~fi"
for /F "tokens=* delims="eol^= %%i in ("%TO_PATH%\.") do set "TO_DIR=%%~fi"

if not exist "\\?\%FROM_DIR%\*" (
  echo;%?~%: error: input directory does not exist: "%FROM_DIR%\"
  exit /b -246
) >&2

if not exist "\\?\%TO_DIR%\*" (
  echo;%?~%: error: output directory does not exist: "%TO_DIR%\"
  exit /b -245
) >&2

if %FLAG_IF_NOT_EXIST% NEQ 0 if exist "\\?\%TO_DIR%\%TO_FILE%" exit /b 0

echo;^>%?~nx0% %*

call "%%?~dp0%%__init__.bat" || exit /b

if %FLAG_USE_CMD_BARE_FLAGS% EQU 0 set "XCOPY_FILE_CMD_BARE_FLAGS="
if %FLAG_USE_CMD_BARE_FLAGS% EQU 0 set "COPY_CMD_BARE_FLAGS="
if defined FLAG_CHCP set XCOPY_FILE_CMD_BARE_FLAGS=%XCOPY_FILE_CMD_BARE_FLAGS% -chcp "%FLAG_CHCP%"
if defined FLAG_CHCP set COPY_CMD_BARE_FLAGS=%COPY_CMD_BARE_FLAGS% -chcp "%FLAG_CHCP%"

if %FLAG_USE_UTILITY_FLAGS% EQU 0 set "XCOPY_FILE_FLAGS="
if %FLAG_USE_UTILITY_FLAGS% EQU 0 set "COPY_FLAGS="
if not defined XCOPY_FILE_FLAGS set "XCOPY_FILE_FLAGS=/Y /D /H"
if not defined COPY_FLAGS set "COPY_FLAGS=/B /Y"

rem reset direct non command flags
set "XCOPY_FILE_BARE_FLAGS="
set "ROBOCOPY_FILE_BARE_FLAGS="

if /i not "%FROM_DIR%" == "%TO_DIR%" (
  ( call "%%CONTOOLS_ROOT%%/std/xcopy_file.bat"%%XCOPY_FILE_CMD_BARE_FLAGS%% "%%FROM_DIR%%" "%%FROM_FILE%%" "%%TO_DIR%%" %%XCOPY_FILE_FLAGS%% || exit /b ) && if /i not ^
      "%FROM_FILE%" == "%TO_FILE%" (
    (
      call "%%CONTOOLS_ROOT%%/std/copy.bat"%%COPY_CMD_BARE_FLAGS%% "%%TO_DIR%%/%%FROM_FILE%%" "%%TO_DIR%%/%%TO_FILE%%" %%COPY_FLAGS%% || exit /b
    ) && (
      call "%%CONTOOLS_ROOT%%/std/del_file.bat" "%%TO_DIR%%/%%FROM_FILE%%" /F /Q || exit /b
    )
  )
) else if /i not "%FROM_FILE%" == "%TO_FILE%" (
  (
    call "%%CONTOOLS_ROOT%%/std/copy.bat"%%COPY_CMD_BARE_FLAGS%% "%%TO_DIR%%/%%FROM_FILE%%" "%%TO_DIR%%/%%TO_FILE%%" %%COPY_FLAGS%% || exit /b
  ) && (
    call "%%CONTOOLS_ROOT%%/std/del_file.bat" "%%TO_DIR%%/%%FROM_FILE%%" /F /Q || exit /b
  )
)

exit /b 0
