@echo off

rem Drop return value
set RETURN_VALUE=0

rem script names call stack
if defined ?~ ( set "__?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "__?~=%?~nx0%-^>%~nx0" ) else set "__?~=%~nx0"

set "__VAR_NAME_PREFIX__=%~1"
set "__DELIMS__=%~2"
set "__STRING__=%~3"

if not defined __VAR_NAME_PREFIX__ (
  echo;%?~%: error: Variable name prefix is not set.
  exit /b 1
) >&2

set "__SUBPATH__="
set __DIR_INDEX__=1

:LOOP
set "__SUBDIR__="
for /F "tokens=%__DIR_INDEX__% delims=%__DELIMS__%"eol^= %%i in ("%__STRING__%") do set "__SUBDIR__=%%i"
if not defined __SUBDIR__ goto LOOP_END

if defined __SUBPATH__ (
  set "__SUBPATH__=%__SUBPATH__%/%__SUBDIR__%"
) else set "__SUBPATH__=%__SUBDIR__%"

set "%__VAR_NAME_PREFIX__%%__DIR_INDEX__%=%__SUBPATH__%"

set /A __DIR_INDEX__+=1

goto LOOP

:LOOP_END
(
  rem drop local variables
  set "__?~="
  set "__VAR_NAME_PREFIX__="
  set "__DELIMS__="
  set "__STRING__="
  set "__SUBPATH__="
  set "__SUBDIR__="
  set "__DIR_INDEX__="
  set "__SUBDIR__="

  set /A "RETURN_VALUE=%__DIR_INDEX__%-1"
)
exit /b 0
