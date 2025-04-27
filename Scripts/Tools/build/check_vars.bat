@echo off

setlocal

rem CAUTION:
rem   The `for %%i in (%*)` statement still can expand the globbing characters
rem   for the files in a current directory. You must avoid them.

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"

for %%i in (%*) do (
  if not defined %%~i (
    echo;%?~%: error: `%%~i` variable is not defined.
    exit /b 255
  ) >&2
)

exit /b 0
