@echo off

setlocal

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"

rem drop last error level
call;

if "%~1" == "" (
  echo;%?~%: error: command argument is not defined.
  exit /b 255
) >&2

endlocal & if exist "%~1" call %%*
exit /b

rem CAUTION:
rem   The script may not call in case of a call from another script.
rem   You must use a correct form of the command line in case of a multi line
rem   call:
rem
rem     >
rem     call call_if_exist.bat ^
rem       THE-NEXT-QUOTED-LINE-MUST-BE-INDENTED
rem
rem   If the next line begins by the double quote is not indented, then the
rem   script won't be called at all!
rem
rem   See for details:
rem     `Line end escaping with ^ expression can break next line parsing` :
rem     https://github.com/andry81/contools/discussions/13
