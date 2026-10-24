@echo off & goto DOC_END

rem USAGE:
rem   print_hash_list.bat <list-file> <for-tokens-per-line>...

rem Description:
rem   Prints a reformatted hash list.
rem   Can rearrange hash list colons or move them on another line.

rem <list-file>
rem   Path to list file to print.
rem   If empty or `.`, then read the stdin.

rem <for-tokens-per-line>
rem   The `:` delimited list of numbers for the `tokens` parameter in a `for`
rem   statement. Each next parameter forms an output on a new line.
rem
rem   CAUTION:
rem     All numbers must be less then 27.
rem     Quantity of <for-tokens-per-line> parameters must be not greater than
rem     10.

rem Examples:
rem   1.  Prints file path on a first line and the rest on the second.
rem       >
rem       gen_dir_hash_lst.bat -c "md5,sha256" -l -r . | print_hash_lst.bat . 4 1:2:3
:DOC_END

setlocal DISABLEDELAYEDEXPANSION

set "LIST_FILE=%~1"

if "%LIST_FILE%" == "." set "LIST_FILE="

rem generate `for ...` statements line using <for-tokens-per-line>

set "FOR_TOKENS=%~2

if not defined FOR_TOKENS (
  echo;%~nx0: error: for-tokens parameter must be defined.
  exit /b 255
) >&2

set "FOR_VARS_ALPHA=_abcdefghijklmnopqrstuvwxyz"

set "FOR_VARS_LIST="

rem for-variables list
for %%i in (%FOR_TOKENS::=,%) do call set "FOR_VARS_LIST=%%FOR_VARS_LIST%%%%FOR_VARS_ALPHA:~%%i,1%%,"

if not defined FOR_VARS_LIST (
  echo;%~nx0: error: for-tokens parameter is out-of-range.
  exit /b 255
) >&2

rem for-variables encoded list, ex: `4:2:6` or `d,b,f` -> `$d$b$f`
set "FOR_VARS_REMAPPED_LIST=$%FOR_VARS_LIST:,=$%"

rem remap for-variables list using a shifted alphabet starting `a`, ex: `4:2:6` or `d,b,f` -> `b,a,c`
set REMAPPED_ALPHA_INDEX=1

for /L %%i in (1,1,26) do call set "FOR_VAR=%%FOR_VARS_ALPHA:~%%i,1%%" & call call :IF "%%%%FOR_VARS_REMAPPED_LIST:$%%FOR_VAR%%=%%%%" NEQ "%%%%FOR_VARS_REMAPPED_LIST%%%%" && (
  call call set "FOR_REMAPPED_VAR=%%%%FOR_VARS_ALPHA:~%%REMAPPED_ALPHA_INDEX%%,1%%%%"
  call call set "FOR_VARS_REMAPPED_LIST=%%%%FOR_VARS_REMAPPED_LIST:$%%FOR_VAR%%=,%%FOR_REMAPPED_VAR%%%%%%"
  set /A REMAPPED_ALPHA_INDEX+=1
)

goto IF_END

:IF
if %* exit /b 0
exit /b 1

:IF_END

set "FOR_VARS_REMAPPED_LIST=%FOR_VARS_REMAPPED_LIST:~0,-1%"

setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!FOR_VARS_REMAPPED_LIST:,=,%%!") do endlocal & set "FOR_VARS_REMAPPED_LIST=%%i"

set "FOR_VARS_REMAPPED_LIST=%FOR_VARS_REMAPPED_LIST:~1%"

set FOR_LINE0=for /F "tokens=%FOR_TOKENS::=,% delims=,"eol^^= %%a in ("%%@") do echo;%FOR_VARS_REMAPPED_LIST:,=^^^|%

rem set FOR_LINE0

rem entire input line `for` statement
if defined LIST_FILE (
  set __FOR__=for /F "usebackq tokens=* delims="eol^^= %%@ in ("%LIST_FILE%"^)
) else set __FOR__=for /F "usebackq tokens=* delims="eol^^= %%@ in (`@"%%SystemRoot%%\System32\findstr.exe" /R /C:"^" 2^^^>nul`^)

rem first output line `for` statement with filter
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!__FOR__!") do endlocal & set __FOR__=%%i do ^
for /F "tokens=* delims="eol^^=%% %%@ in ("%%@"^) do for /F "tokens=* delims="eol^^=# %%@ in ("%%@"^)

set "NUM_NEXT_FORS=0"

shift
shift

rem read next <for-tokens-per-line>...
:FOR_NEXT_TOKENS_LOOP
set "FOR_TOKENS=%~1"

if not defined FOR_TOKENS goto PRINT

set /A NUM_NEXT_FORS+=1

set "FOR_VARS_LIST="

rem for-variables list
for %%i in (%FOR_TOKENS::=,%) do call set "FOR_VARS_LIST=%%FOR_VARS_LIST%%%%FOR_VARS_ALPHA:~%%i,1%%,"

if not defined FOR_VARS_LIST (
  echo;%~nx0: error: for-tokens parameter is out-of-range.
  exit /b 255
) >&2

rem for-variables encoded list, ex: `4:2:6` or `d,b,f` -> `$d$b$f`
set "FOR_VARS_REMAPPED_LIST=$%FOR_VARS_LIST:,=$%"

rem remap for-variables list using a shifted alphabet starting `a`, ex: `4:2:6` or `d,b,f` -> `b,a,c`
set REMAPPED_ALPHA_INDEX=1

for /L %%i in (1,1,26) do call set "FOR_VAR=%%FOR_VARS_ALPHA:~%%i,1%%" & call call :IF "%%%%FOR_VARS_REMAPPED_LIST:$%%FOR_VAR%%=%%%%" NEQ "%%%%FOR_VARS_REMAPPED_LIST%%%%" && (
  call call set "FOR_REMAPPED_VAR=%%%%FOR_VARS_ALPHA:~%%REMAPPED_ALPHA_INDEX%%,1%%%%"
  call call set "FOR_VARS_REMAPPED_LIST=%%%%FOR_VARS_REMAPPED_LIST:$%%FOR_VAR%%=,%%FOR_REMAPPED_VAR%%%%%%"
  set /A REMAPPED_ALPHA_INDEX+=1
)

goto IF_END

:IF
if %* exit /b 0
exit /b 1

:IF_END

set "FOR_VARS_REMAPPED_LIST=%FOR_VARS_REMAPPED_LIST:~0,-1%"

setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!FOR_VARS_REMAPPED_LIST:,=,%%!") do endlocal & set "FOR_VARS_REMAPPED_LIST=%%i"

set "FOR_VARS_REMAPPED_LIST=%FOR_VARS_REMAPPED_LIST:~1%"

set FOR_LINE%NUM_NEXT_FORS%=for /F "tokens=%FOR_TOKENS::=,% delims=,"eol^^= %%a in ("%%@") do echo;%FOR_VARS_REMAPPED_LIST:,=^^^|%

rem set FOR_LINE%NUM_NEXT_FORS%

shift

goto FOR_NEXT_TOKENS_LOOP

:SKIP_NEXT
:PRINT
%__FOR__% do call :__FOR__
exit /b

:__FOR__
for %%# in (:) do %FOR_LINE0%
if %NUM_NEXT_FORS% LSS 1 exit /b 0
for %%# in (:) do %FOR_LINE1%
if %NUM_NEXT_FORS% LSS 2 exit /b 0
for %%# in (:) do %FOR_LINE2%
if %NUM_NEXT_FORS% LSS 3 exit /b 0
for %%# in (:) do %FOR_LINE3%
if %NUM_NEXT_FORS% LSS 4 exit /b 0
for %%# in (:) do %FOR_LINE4%
if %NUM_NEXT_FORS% LSS 5 exit /b 0
for %%# in (:) do %FOR_LINE5%
if %NUM_NEXT_FORS% LSS 6 exit /b 0
for %%# in (:) do %FOR_LINE6%
if %NUM_NEXT_FORS% LSS 7 exit /b 0
for %%# in (:) do %FOR_LINE7%
if %NUM_NEXT_FORS% LSS 8 exit /b 0
for %%# in (:) do %FOR_LINE8%
if %NUM_NEXT_FORS% LSS 9 exit /b 0
for %%# in (:) do %FOR_LINE9%
exit /b 0
