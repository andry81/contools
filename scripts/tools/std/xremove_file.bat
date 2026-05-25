<!-- : bat in wsf skip

@echo off & goto DOC_END

rem USAGE:
rem   xremove_file.bat [-vbs] [--] <path>

rem Description:
rem   A file path delete script with echo and some conditions check before
rem   call.
rem
rem   Does support long paths.
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

rem -vbs:
rem   Use VBS built-in script to remove the file.

rem --:
rem   Separator to stop parse flags.

rem <path>
rem   Single file path.
:DOC_END

if %CONTOOLS_VERBOSE%0 NEQ 0 echo;^>%~nx0 %*

setlocal

set "?~f0=%~f0"
set "?~n0=%~n0"

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"

rem script flags
set /A "FLAG_SHIFT=0", "FLAG_VBS=0"

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG if "%FLAG%" == "-vbs" set "FLAG_VBS=1" & shift & call set "FLAG=%%~1" & set /A FLAG_SHIFT+=1
if defined FLAG if "%FLAG%" == "--" shift & set /A FLAG_SHIFT+=1

set "FROM_PATH=%~1"

if not defined FROM_PATH (
  echo;%?~%: error: file path argument must be defined.
  exit /b -255
) >&2

set "FROM_PATH=%FROM_PATH:/=\%"

if "%FROM_PATH:~0,4%" == "\\?\" set "FROM_PATH=%FROM_PATH:~4%"

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
  echo;%?~%: error: file path is invalid: "%FROM_PATH%".
  exit /b -254
) >&2

:FROM_PATH_OK

for /F "tokens=* delims="eol^= %%i in ("%FROM_PATH%\.") do ^
for /F "tokens=* delims="eol^= %%j in ("%%~dpi.") do set "FILE_PATH=%%~fi" & set "FILE_DIR=%%~fj" & set "FILE_NAME=%%~nxi"

rem CAUTION:
rem   The `mklink` command can create symbolic directory link and in the disconnected state it does
rem   report existence of a directory without the trailing back slash:
rem     `x:\<path-to-dir-without-trailing-back-slash>`
rem   So we must test the path with the trailing back slash to check existence of the link AND it's connection state.

if not exist "\\?\%FILE_PATH%" (
  echo;%?~%: error: path does not exist: "%FILE_PATH%"
  exit /b 1
) >&2 else if exist "\\?\%FILE_PATH%\*" (
  echo;%?~%: error: path does exist and is a directory: "%FILE_PATH%"
  exit /b -254
) >&2 else if exist "\\?\%FILE_PATH%\" (
  echo;%?~%: error: path does exist and is an unlinked directory: "%FILE_PATH%"
  exit /b -253
) >&2

rem check on long file path
if exist "%FILE_PATH%" (
  rem CAUTION: must check on empty variable to avoid accidental `del /Q ""` case
  if %CONTOOLS_VERBOSE%0 NEQ 0 echo;^>^>del /F /Q /A:-D "%FILE_PATH%"
  if defined FILE_PATH del /F /Q /A:-D "%FILE_PATH%" >nul 2>nul
  exit /b
)

if %FLAG_VBS% NEQ 0 goto DELETE_FILE_VBS

rem check on `robocopy` existence
if not exist "%SystemRoot%\System32\robocopy.exe" goto DELETE_FILE_VBS

rem move the file to a temporary directory to delete it
if defined SCRIPT_TEMP_CURRENT_DIR (
  set "FILE_PATH_TEMP_DIR=%SCRIPT_TEMP_CURRENT_DIR%\%?~n0%.%RANDOM%-%RANDOM%"
) else set "FILE_PATH_TEMP_DIR=%TEMP%\%?~n0%.%RANDOM%-%RANDOM%"

if %CONTOOLS_VERBOSE%0 NEQ 0 echo;^>^>"%SystemRoot%\System32\robocopy.exe" "%FILE_DIR%" "%FILE_PATH_TEMP_DIR%" "%FILE_NAME%" /R:0 /W:0 /NP /NJH /NS /NC /XX /XO /XC /XN /MOV
"%SystemRoot%\System32\robocopy.exe" "%FILE_DIR%" "%FILE_PATH_TEMP_DIR%" "%FILE_NAME%" /R:0 /W:0 /NP /NJH /NS /NC /XX /XO /XC /XN /MOV >nul

rmdir /S /Q "%FILE_PATH_TEMP_DIR%" >nul 2>nul
exit /b

:DELETE_FILE_VBS
if %CONTOOLS_VERBOSE%0 NEQ 0 echo;^>^>"%SystemRoot%\System32\cscript.exe" //NOLOGO //JOB:DELETE_FILE "%?~f0%?.wsf" "\\?\%FILE_PATH%"
"%SystemRoot%\System32\cscript.exe" //NOLOGO //JOB:DELETE_FILE "%?~f0%?.wsf" "\\?\%FILE_PATH%"
exit /b

rem end of bat -->

<package>
  <job id="DELETE_FILE">
    <script language="VBScript">
      ' Description:
      '   Shell based script to be able to delete file by paths longer than 260+ characters.
      '
      ' USAGE:
      '   ... "\\?\<absolute-canonical-file-path-to-file>"
      '
      '   , where (!) <absolute-canonical-file-path-to-file>: is an absolute file path separated with the backslash character ONLY - `\`
      '

      Dim objFS : Set objFS = CreateObject("Scripting.FileSystemObject")
      objFS.DeleteFile WScript.Arguments(0)
    </script>
  </job>
</package>
