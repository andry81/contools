@echo off & goto :DOC_END

rem USAGE:
rem   ansi2any.bat [-chcp <code-page>] [-bom] <input-char-set> <output-char-set> <input-file>

rem Description:
rem   Converts <input-char-set> into <output-char-set> for the <input-file>.
rem   If <input-char-set> is empty, then does use current ASCII code page.
rem   The <output-char-set> must be not empty.
rem   If `-bom` flag is used, then the output char set must be a unicode char
rem   set.
:DOC_END

setlocal

call "%%~dp0__init__\__init__.bat" || exit /b

set "?~dp0=%~dp0"

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"

rem script flags
set "FLAG_CHCP="

call :MAIN %%*
set LAST_ERROR=%ERRORLEVEL%

rem restore locale
if defined FLAG_CHCP call "%%CONTOOLS_ROOT%%/std/restorecp.bat"

exit /b %LAST_ERROR%

:MAIN
rem script flags
set FLAG_USE_BOM=0

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-chcp" (
    set "FLAG_CHCP=%~2"
    shift
  ) else if "%FLAG%" == "-bom" (
    set FLAG_USE_BOM=1
  ) else (
    echo;%?~%: error: invalid flag: %FLAG%
    exit /b -255
  ) >&2

  shift

  rem read until no flags
  goto FLAGS_LOOP
)

set "INPUT_CHARSET=%~1"
set "OUTPUT_CHARSET=%~2"
set "INPUT_FILE=%~3"

if not defined OUTPUT_CHARSET (
  echo;%?~%: error: OUTPUT_CHARSET is not set.
  exit /b 255
) >&2

if not exist "%INPUT_FILE%" (
  echo;%?~%: error: INPUT_FILE does not exist: INPUT_FILE="%INPUT_FILE%".
  exit /b 255
) >&2

if defined FLAG_CHCP (
  call "%%CONTOOLS_ROOT%%/std/chcp.bat" "%%FLAG_CHCP%%"
  if not defined INPUT_CHARSET set "INPUT_CHARSET=CP%FLAG_CHCP%"
) else if not defined INPUT_CHARSET call :GET_CURRENT_CODE_PAGE

if %FLAG_USE_BOM% NEQ 0 call :OUTPUT_BOM || exit /b

rem workaround for `conversion from CP65001 unsupported`
if "%INPUT_CHARSET%" == "CP65001" (
  "%CONTOOLS_MSYS2_USR_ROOT%/bin/iconv.exe" -c -f UTF-8 -t "%OUTPUT_CHARSET%" "%INPUT_FILE%"
) else (
  "%CONTOOLS_MSYS2_USR_ROOT%/bin/iconv.exe" -c -f "%INPUT_CHARSET%" -t "%OUTPUT_CHARSET%" "%INPUT_FILE%"
)
exit /b

:GET_CURRENT_CODE_PAGE
set "CHCP_FILE="
if exist "%SystemRoot%\System32\chcp.com" set "CHCP_FILE=%SystemRoot%\System32\chcp.com"
if not defined CHCP_FILE if exist "%SystemRoot%\System64\chcp.com" set "CHCP_FILE=%SystemRoot%\System64\chcp.com"

for /F "usebackq tokens=2 delims=:"eol^= %%i in (`@"%CHCP_FILE%" 2^>nul`) do set CURRENT_CODE_PAGE=%%i

rem convert chcp code page into iconv name space
set INPUT_CHARSET=CP%CURRENT_CODE_PAGE: =%

exit /b 0

:OUTPUT_BOM
if /i "%OUTPUT_CHARSET%" == "CP65001" set "BOM_FILE_NAME=efbbbf.bin" & goto COPY_BOM
if /i "%OUTPUT_CHARSET%" == "UTF-8" set "BOM_FILE_NAME=efbbbf.bin" & goto COPY_BOM
if not "%OUTPUT_CHARSET:-2LE=%" == "%OUTPUT_CHARSET%" set "BOM_FILE_NAME=fffe.bin" & goto COPY_BOM
if not "%OUTPUT_CHARSET:-2BE=%" == "%OUTPUT_CHARSET%" set "BOM_FILE_NAME=feff.bin" & goto COPY_BOM
if not "%OUTPUT_CHARSET:-4LE=%" == "%OUTPUT_CHARSET%" set "BOM_FILE_NAME=fffe.bin" & goto COPY_BOM
if not "%OUTPUT_CHARSET:-4BE=%" == "%OUTPUT_CHARSET%" set "BOM_FILE_NAME=feff.bin" & goto COPY_BOM
if not "%OUTPUT_CHARSET:-16LE=%" == "%OUTPUT_CHARSET%" set "BOM_FILE_NAME=fffe.bin" & goto COPY_BOM
if not "%OUTPUT_CHARSET:-16BE=%" == "%OUTPUT_CHARSET%" set "BOM_FILE_NAME=feff.bin" & goto COPY_BOM
if not "%OUTPUT_CHARSET:-32LE=%" == "%OUTPUT_CHARSET%" set "BOM_FILE_NAME=fffe.bin" & goto COPY_BOM
if not "%OUTPUT_CHARSET:-32BE=%" == "%OUTPUT_CHARSET%" set "BOM_FILE_NAME=feff.bin" & goto COPY_BOM

(
  echo;%?~%: error: output char set is not unicode: OUTPUT_CHARSET="%OUTPUT_CHARSET%".
  exit /b 255
) >&2

:COPY_BOM
type "%?~dp0%boms\%BOM_FILE_NAME%"
