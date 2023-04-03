@echo off

rem USAGE:
rem   echo_path_var.bat <VAR> [<PREFIX> [<SUFFIX>]]

rem <VAR>: VALUE1;VALUE2;...;VALUEN

setlocal DISABLEDELAYEDEXPANSION

set "__?VAR__=%~1"
if not defined __?PREFIX__ set "__?PREFIX__=%~2"
if not defined __?SUFFIX__ set "__?SUFFIX__=%~3"

if not defined __?VAR__ exit /b 255

rem Escape specific separator characters by sequence of `$NN` characters:
rem  1. `?` and `*` - globbing characters in the `for %%i in (...)` expression
rem  2. `,`, ` `    - separator characters in the `for %%i in (...)` expression
setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims=" %%i in ("!%__?VAR__%:$=$00!") do ( endlocal & set "%__?VAR__%=%%i" )
setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims=" %%i in ("!%__?VAR__%:^*=$01!") do ( endlocal & set "%__?VAR__%=%%i" )
setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims=" %%i in ("!%__?VAR__%:?=$02!") do ( endlocal & set "%__?VAR__%=%%i" )
setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims=" %%i in ("!%__?VAR__%: =$03!") do ( endlocal & set "%__?VAR__%=%%i" )
rem escape tabulation character
setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims=" %%i in ("!%__?VAR__%:	=$04!") do ( endlocal & set "%__?VAR__%=%%i" )
setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims=" %%i in ("!%__?VAR__%:,=$05!") do ( endlocal & set "%__?VAR__%=%%i" )

setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims=" %%i in ("!%__?VAR__%!") do (
  endlocal
  for %%j in (%%i) do (
    set "__?LINE__=%%j"
    rem unescape
    setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims=" %%i in ("!__?LINE__:$01=*!") do ( endlocal & set "__?LINE__=%%i" )
    setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims=" %%i in ("!__?LINE__:$02=?!") do ( endlocal & set "__?LINE__=%%i" )
    setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims=" %%i in ("!__?LINE__:$03= !") do ( endlocal & set "__?LINE__=%%i" )
    setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims=" %%i in ("!__?LINE__:$04=	!") do ( endlocal & set "__?LINE__=%%i" )
    setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims=" %%i in ("!__?LINE__:$05=,!") do ( endlocal & set "__?LINE__=%%i" )
    setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims=" %%i in ("!__?LINE__:$00=$!") do ( endlocal & set "__?LINE__=%%i" )
    rem trim leading white spaces
    rem setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims= " %%i in ("!__?LINE__!") do ( endlocal & set "__?LINE__=%%i" )
    setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims=" %%i in ("!__?PREFIX__!!__?LINE__!!__?SUFFIX__!") do ( endlocal & echo.%%i)
  )
)

exit /b 0
