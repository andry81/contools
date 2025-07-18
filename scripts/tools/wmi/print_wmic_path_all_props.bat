@echo off

setlocal DISABLEDELAYEDEXPANSION

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"

set "FILE=%~1"

if not exist "%FILE%" (
  echo;%?~%: error: FILE does not exist: "%FILE%".
  exit /b 1
) >&2

for /F "tokens=* delims="eol^= %%i in ("%FILE%\.") do set "FILE=%%~fi"

set WMIC_COMMAND=DataFile
if exist "%FILE%\*" set WMIC_COMMAND=FsDir

rem NOTE:
rem   `findstr.exe` does return not zero exit code on empty output

"%SystemRoot%\System32\wbem\wmic.exe" %WMIC_COMMAND% where "Name='%FILE:\=\\%'" list /format:list | "%SystemRoot%\System32\findstr.exe" /R /C:"."
exit /b

rem USAGE:
rem   print_wmic_path_all_props.bat <path>

rem Description:
rem   Prints all WMI property values from a path.
rem
rem   Based on:
rem     https://superuser.com/questions/898017/windows-command-to-get-all-information-properties-of-a-file

rem CAUTION:
rem   In Windowx XP an elevated call under data protection flag will block the wmic tool!

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

rem CAUTION:
rem   The `wmic` executable does consume a first key press into the console
rem   window. So if you run a script with the pause at the script end, then it
rem   may remain paused after a single press into the console window if a key
rem   was pressed before the call to `wmic.exe`.
