
(
  endlocal
  for /F "usebackq eol=# tokens=1,* delims==" %%i in ("%__?CONFIG_OUT_DIR%/%__?CONFIG_FILE%") do ( set "__?VALUE=%%j" & call :PARSE "%%~1" "%%~2" "%%~3" %%i )
  set "__?VAR=" & set "__?VALUE=" & set "__?ATTR=" & set "__?VAR_EXPR=" & set "__?PARAM0=" & set "__?PARAM1=" & set "__?QUOT__=" & set "__?EXCL__=" & set "__?ESC__="
)
exit /b 0

:PARSE
set "__?ATTR=|"
set "__?VAR_EXPR=%~4"
if not "%~5" == "" ( set "__?ATTR=%__?ATTR%%~4|" & set "__?VAR_EXPR=%~5" )
set "__?VAR_EXPR=%__?VAR_EXPR:::=:.:%"

for /F "eol= tokens=1,2,* delims=:" %%i in ("%__?VAR_EXPR%") do ( call :PARSE_EXPR "%%~4" "%%~i" "%%~j" "%%~k" "%%~1" "%%~2" "%%~3" )
exit /b

:PARSE_EXPR
if not defined __?VALUE goto PARSE_VAR

set "__?VALUE=%__?VALUE:"=%"

if %~5 EQU 0 call set "__?VALUE=%__?VALUE%"

if ^/ == ^%__?VALUE:~0,1%/ if ^/ == ^%__?VALUE:~-1%/ call set "__?VALUE=%__?VALUE:~1,-1%"

:PARSE_VAR
if not "%~3" =="." ( set "__?PARAM0=%~3" ) else set "__?PARAM0="
if not "%~4" =="." ( set "__?PARAM1=%~4" ) else set "__?PARAM1="
if "%~6" == "" ( if "%~7" == "" ( if /i not "%__?PARAM0%" == "" ( set "%~1=" ) else if /i not "%__?PARAM1%" == "" ( set "%~1=" ) else ( goto PARSE_VALUE )
) else if /i not "%__?PARAM0%" == "" ( set "%~1=" ) else if /i "%__?PARAM1%" == "%~7" ( set "%~1=" & goto PARSE_VALUE ) else if /i not "%__?PARAM1%" == "" set "%~1="
) else if "%~7" == "" ( if /i not "%__?PARAM1%" == "" ( set "%~1=" ) else if /i "%__?PARAM0%" == "%~6" ( set "%~1=" & goto PARSE_VALUE ) else if /i not "%__?PARAM0%" == "" set "%~1="
) else if /i "%__?PARAM0%" == "%~6" if /i "%__?PARAM1%" == "%~7" ( set "%~1=" & goto PARSE_VALUE
) else if /i not "%__?PARAM0%" == "" ( set "%~1=" ) else if /i not "%__?PARAM1%" == "" set "%~1="
exit /b

:PARSE_VALUE
set "__?VAR=%~2"
if not "%__?ATTR:|once|=%" == "%__?ATTR%" if defined %__?VAR% exit /b 0

set __?QUOT__=^"
set "__?EXCL__=!" & set "__?ESC__=^"
set "__?VALUE=%__?VALUE:!=!__?EXCL__!%"
set "__?VALUE=%__?VALUE:=!__?QUOT__!%"
set "__?VALUE=%__?VALUE:^=!__?ESC__!%"
setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims=" %%i in ("%__?VALUE%") do ( endlocal & set "%__?VAR%=%%i" )
