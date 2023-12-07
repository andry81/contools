@echo off

rem Description:
rem   A file last modified time request.

rem CAUTION:
rem   In Windowx XP an elevated call under data protection flag will block the wmic tool!
rem

rem CAUTION:
rem   The `wmic` executable has an issue with different output codepage:
rem
rem     https://stackoverflow.com/questions/55310573/wmic-command-in-batch-outputting-non-utf-8-text-files/55312341#55312341
rem
rem   The encoding of wmic's output depends on where the output is being sent
rem     * If you send the output to a disk file by using a redirection operator
rem       or the /output switch, wmic will use UCS-2 LE BOM
rem     * If you send the output to the console or to a pipe, wmic will use OEM
rem       codepage
rem

rem Drop last error level
call;

set "FILE=%~1"

if not exist "%FILE%" (
  echo.%~nx0: error: FILE does not exist: "%FILE%".
  exit /b 1
) >&2

rem drop return value
set "RETURN_VALUE="

for /F "eol= tokens=* delims=" %%i in ("%FILE%\.") do set "FILE=%%~fi"

for /F "usebackq eol= tokens=1,* delims==" %%i in (`@"%%SystemRoot%%\System32\wbem\wmic.exe" DataFile where "Name='%%FILE:\=\\%%'" get LastModified /VALUE`) do if "%%i" == "LastModified" set "RETURN_VALUE=%%j"

if defined RETURN_VALUE exit /b 0

exit /b 1
