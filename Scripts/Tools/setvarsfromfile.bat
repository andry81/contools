@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script reads text file with variables in format "VARIABLE=VALUE" and
rem   applies it. You can use all expression types what uses by "set" command
rem   in the command preprocessor cmd.exe (read help about command "set").

rem Example of variables text file (by default a name and a value has single
rem expansion pass):
rem   # Comment string
rem   _MYVALUE0=0
rem   _MYVALUE1=1
rem   "_MYVALUE2=1&2"
rem   /A _MYVALUE3=1+2
rem   /P _MYVALUE4=<"MyDirectory\Config&Init\MyVariableValue.var"
rem   /E /P _MYVALUE4=<"MyDirectory\Config&Init\MyVariableValue2.var"
rem   _MYVALUE10=%_MYVALUE1%0
rem   _MYVALUE0=
rem   /E _MYVALUE1=10
rem   _MYVALUE12=1%?0%2
rem   "_MYVALUE13=1^2"
rem   _MYVALUE14="1^2" "3&4" "5 6"
rem   "_MYVALUE100=123"
rem   /R "_MYVALUE101=%%_MYVALUE100%%"
rem   /R "%_MYVALUE101%_MYVALUE102=%_MYVALUE101%+200"
rem   /X /R "%_MYVALUE101%_MYVALUE103=%_MYVALUE101%+200"

rem To avoid problems with special characters you should use quotes around
rem VARIABLE=VALUE expression. In any other case use %?*% placement variables.

rem Variable flags:
rem   /E - set only if empty
rem   /H - set only if value exist as directory or file
rem   /R - reference variable, blocks variable's value expansion (ignores
rem        flag -e)
rem   /X - do not expand variable's name
rem   /P - set from file
rem   /V - double expand variable's value if /R is not set (ignores flag -e)
rem Plus all flags from the "set" command (see the help: set /?):
rem   /A - math expression set
rem   /P - read first line from a file

rem Command arguments:
rem %1 - Path to file with variables.
rem %2 - Flags 1:
rem    -e - Additionally expands variable's value
rem         (by default value has single expansion).
rem %3 - All setting variables prefix.
rem You should use special variables in the file to avoid problems with
rem respective characters:
rem   %?0% - expands to ^ (Useful when "evaluate" flag defined)
rem   %?1% - expands to " (Should always be used instead)
rem   !?2! - expands to ! (Should always be used in case of
rem          "setlocal ENABLEDELAYEDEXPANSION" before variables loading) 

rem Examples:
rem 1. call setvarsfromfile.bat blabla.vars

if "%~1" == "" exit /b 65

rem Drop last error level.
call;

echo.loading "%~1"...

set "__FLAGS=%~2"
set "__VAR_PREFIX=%~3"

set "?0=^"
set ?1="
set !?2!=!

set __DO_EXPAND_ALL_VALUES=0
if defined __FLAGS (
  if not "%__FLAGS%" == "%__FLAGS:e=%" set __DO_EXPAND_ALL_VALUES=1
)

for /F "usebackq eol=# tokens=1,* delims=<" %%i in ("%~1") do (
  set __EXP=%%i
  set __STDIN_FILE=%%j
  call :SET_ROUTINE || exit /b
)

rem Drop internal variables.
set "?0="
set "?1="
set "!?2!="
set "__FLAGS="
set "__DO_EXPAND_ALL_VALUES="
set "__DO_EXPAND_VALUE="
set "__VAR_PREFIX="
set "__VAR_NAME="
set "__EXP="
set "__EXP_R="
set "__SET1="
set "__SET2="
set "__SET_FLAGS="
set "__SET_FLAG_IF_EMPTY="
set "__SET_FLAG_IF_EXIST="
set "__SET_FLAG_FROM_FILE="
set "__SET_FLAG_IS_QUOTED="
set "__SET_FLAG_REF="
set "__SET_FLAG_DONT_EXPAND_NAME="
set "__SET_FLAG_DBL_EXPAND_VALUE="
set "__STDIN_FILE="
set "__ARGS__="

rem Exit with current error level.
exit /b

:SET_ROUTINE
rem echo.%__EXP%^<%__STDIN_FILE%
set __SET_FLAGS=
set __SET_FLAG_IF_EMPTY=0
set __SET_FLAG_IF_EXIST=0
set __SET_FLAG_FROM_FILE=0
set __SET_FLAG_IS_QUOTED=0
set __SET_FLAG_REF=0
set __SET_FLAG_DONT_EXPAND_NAME=0
set __SET_FLAG_DBL_EXPAND_VALUE=0

:SET_ROUTINE_IMPL
set __SET1=^%__EXP:~0,1%/

if ^%__SET1%/ == / exit /b 0
if ^%__SET1% == ^"/ goto SET_QUOTED
if "%__SET1%" == "~0,1/" exit /b 0

if %__SET1% == // goto SET_WITH_FLAG

if "%__SET1%" == "/" exit /b 1

rem echo."__SET_FLAG_IF_EMPTY=%__SET_FLAG_IF_EMPTY%"
rem echo."__SET_FLAG_FROM_FILE=%__SET_FLAG_FROM_FILE%"
if %__SET_FLAG_IF_EMPTY%0 NEQ 0 goto SET_IF_EMPTY
if %__SET_FLAG_FROM_FILE%0 NEQ 0 goto SET_FROM_FILE

goto SET_EXP

:SET_QUOTED
call :SET_QUOTED_IMPL %%__EXP%%
exit /b

:SET_QUOTED_IMPL
rem echo 3. __EXP=%__EXP% ^| %*
set __SET_FLAG_IS_QUOTED=1
for /F "eol= tokens=1,* delims==" %%i in ("%~1") do (
  set __EXP=%%i
  call :SET_EXP_IMPL "%%j" || exit /b
)
exit /b 0

:SET_WITH_FLAG
set __SET1=^%__EXP:~0,2%/

if ^%__SET1%/ == / exit /b 0
if "%__SET1%" == "~0,2/" exit /b 0

if "%__SET1%" == "//" exit /b 1

if %__SET1% == /E/ ( set "__SET_FLAG_IF_EMPTY=1" )
if %__SET1% == /H/ ( set "__SET_FLAG_IF_EXIST=1" )
if %__SET1% == /R/ ( set "__SET_FLAG_REF=1" )
if %__SET1% == /X/ ( set "__SET_FLAG_DONT_EXPAND_NAME=1" )
if %__SET1% == /P/ ( set "__SET_FLAG_FROM_FILE=1" )
if %__SET1% == /V/ ( set "__SET_FLAG_DBL_EXPAND_VALUE=1" )

rem echo.=^> %__EXP%^|%*^|%__STDIN_FILE%
if %__SET_FLAG_IS_QUOTED%0 NEQ 0 (
  call :SET_WITH_FLAG_IMPL "%%__EXP%%" %*
) else (
  call :SET_WITH_FLAG_IMPL %%__EXP%% %*
)
exit /b

:SET_WITH_FLAG_IMPL
if not %__SET1% == /E/ if not %__SET1% == /H/ if not %__SET1% == /R/ if not %__SET1% == /X/ if not %__SET1% == /V/ set __SET_FLAGS=%__SET_FLAGS%%1 

set __SET2=%2
set __SET2=^%__SET2:~0,1%/

if ^%__SET2%/ == / exit /b 1
if ^%__SET2% == ^"/ goto SET_WITH_FLAG_IMPL_QUOTED
if "%__SET2%" == "~0,1/" exit /b 1
if "%__SET2%" == "/" exit /b 1
goto SET_WITH_FLAG_IMPL_UNQUOTED

:SET_WITH_FLAG_IMPL_QUOTED
set __SET_FLAG_IS_QUOTED=1

:SET_WITH_FLAG_IMPL_UNQUOTED

set "__EXP=%~2"
rem echo.-^> %__EXP%^|%3 %4 %5 %6 %7 %8 %9
call :SET_ROUTINE_IMPL %%3 %%4 %%5 %%6 %%7 %%8 %%9
exit /b

:SET_IF_EMPTY
rem echo 1. __EXP=%__EXP% ^| %*
for /F "usebackq eol= tokens=1,* delims== " %%i in ('%__EXP%') do (
  set __EXP=%%i
  call :SET_IF_EMPTY_IMPL %%j %* || exit /b
)
exit /b

:SET_IF_EMPTY_IMPL
if %__SET_FLAG_DONT_EXPAND_NAME%0 EQU 0 (
  call set "__SET1=%__VAR_PREFIX%%__EXP%"
) else (
  set "__SET1=%__VAR_PREFIX%%__EXP%"
)
if defined __SET1 call set "__SET1=%%%__SET1%%%"
if defined __SET1 exit /b 0

if %__SET_FLAG_FROM_FILE%0 NEQ 0 goto SET_FROM_FILE

goto SET_EXP_IMPL

:SET_EXP
if %__SET_FLAG_IS_QUOTED%0 NEQ 0 goto SET_EXP_QUOTED
goto SET_EXP_UNQUOTED

:SET_EXP_QUOTED
for /F "eol= tokens=1,* delims==" %%i in ("%__EXP%") do (
  set __EXP=%%i
  call :SET_EXP_IMPL %%j %* || exit /b
)
exit /b

:SET_EXP_UNQUOTED
rem echo 2. __EXP=%__EXP% ^| %*
for /F "usebackq eol= tokens=1,* delims== " %%i in ('%__EXP% ') do (
  set __EXP=%%i
  call :SET_EXP_IMPL %%j %* || exit /b
)
exit /b

:SET_EXP_IMPL
if %__SET_FLAG_IS_QUOTED%0 NEQ 0 goto SET_EXP_IMPL_QUOTED
goto SET_EXP_IMPL_UNQUOTED

:SET_EXP_IMPL_QUOTED
set "__ARGS__=%~1"
set __DO_EXPAND_VALUE=0
if %__DO_EXPAND_ALL_VALUES%0 NEQ 0 set __DO_EXPAND_VALUE=1
if %__SET_FLAG_DBL_EXPAND_VALUE%0 NEQ 0 set __DO_EXPAND_VALUE=1

if %__DO_EXPAND_VALUE%0 NEQ 0 if %__SET_FLAG_REF%0 EQU 0 if defined __ARGS__ call set "__ARGS__=%__ARGS__%"
if defined __ARGS__ set "__ARGS__=%__ARGS__:^^^^=^%"
if defined __ARGS__ set "__ARGS__=%__ARGS__:^^=^%"
if %__DO_EXPAND_VALUE%0 NEQ 0 if %__SET_FLAG_REF%0 EQU 0 if defined __ARGS__ set "__ARGS__=%__ARGS__:^=^^%"

if %__SET_FLAG_DONT_EXPAND_NAME%0 EQU 0 (
  call set "__VAR_NAME=%__VAR_PREFIX%%__EXP%"
) else (
  set "__VAR_NAME=%__VAR_PREFIX%%__EXP%"
)

rem ignore set if variable's value is not exist as path or begins/ends by slash or having double slash inside (empty expanded variables in a value)
if %__SET_FLAG_IF_EXIST%0 NEQ 0 (
  if not defined __ARGS__ exit /b 0
  set "__ARGS__=%__ARGS__:\=/%"
)
if %__SET_FLAG_IF_EXIST%0 NEQ 0 (
  if "%__ARGS__:~0,1%" == "/" exit /b 0
  if "%__ARGS__:~-1%" == "/" exit /b 0
  if not "%__ARGS__%" == "%__ARGS__://=%" exit /b 0
  if not exist "%__ARGS__%" exit /b 0
)

rem echo.%__SET_FLAGS%"%__VAR_NAME%=%__ARGS__%" %__SET_FLAG_IF_EMPTY:1=/E% %__SET_FLAG_IF_EXIST:1=/H% %__SET_FLAG_REF:1=/R% %__SET_FLAG_DONT_EXPAND_NAME:1=/X% %__SET_FLAG_DBL_EXPAND_VALUE:1=/V%
rem echo.
rem exit /b 0
set %__SET_FLAGS%"%__VAR_NAME%=%__ARGS__%"
exit /b

:SET_EXP_IMPL_UNQUOTED
set __ARGS__=%*
set __DO_EXPAND_VALUE=0
if %__DO_EXPAND_ALL_VALUES%0 NEQ 0 set __DO_EXPAND_VALUE=1
if %__SET_FLAG_DBL_EXPAND_VALUE%0 NEQ 0 set __DO_EXPAND_VALUE=1

if %__DO_EXPAND_VALUE%0 NEQ 0 if %__SET_FLAG_REF%0 EQU 0 if not "%~1" == "" call set __ARGS__=%__ARGS__%
if not "%~1" == "" set __ARGS__=%__ARGS__:^^^^=^%
if not "%~1" == "" set __ARGS__=%__ARGS__:^^=^%
if %__DO_EXPAND_VALUE%0 NEQ 0 if %__SET_FLAG_REF%0 EQU 0 if not "%~1" == "" set __ARGS__=%__ARGS__:^=^^%

if %__SET_FLAG_DONT_EXPAND_NAME%0 EQU 0 (
  call set "__VAR_NAME=%__VAR_PREFIX%%__EXP%"
) else (
  set "__VAR_NAME=%__VAR_PREFIX%%__EXP%"
)

rem ignore set if variable's value does not exist as path or begins/ends by slash or having double slash inside (empty expanded variables in a value)
if %__SET_FLAG_IF_EXIST%0 NEQ 0 (
  if not defined __ARGS__ exit /b 0
  set "__ARGS__=%__ARGS__:\=/%"
)
if %__SET_FLAG_IF_EXIST%0 NEQ 0 (
  if "%__ARGS__:~0,1%" == "/" exit /b 0
  if "%__ARGS__:~-1%" == "/" exit /b 0
  if not "%__ARGS__%" == "%__ARGS__://=%" exit /b 0
  if not exist "%__ARGS__%" exit /b 0
)

rem echo.%__SET_FLAGS%%__VAR_NAME%=%__ARGS__% __DO_EXPAND_VALUE=%__DO_EXPAND_VALUE% %__SET_FLAG_IF_EMPTY:1=/E% %__SET_FLAG_IF_EXIST:1=/H% %__SET_FLAG_REF:1=/R% %__SET_FLAG_DONT_EXPAND_NAME:1=/X% %__SET_FLAG_DBL_EXPAND_VALUE:1=/V%
rem echo.
rem exit /b 0
set %__SET_FLAGS%%__VAR_NAME%=%__ARGS__%
exit /b

:SET_FROM_FILE
rem echo.--^> %__EXP%^|%*^|%__STDIN_FILE%
for /F "eol= tokens=1,* delims==" %%i in ("%__EXP%") do (
  set __EXP=%%i
  call :SET_FROM_FILE_IMPL %%__STDIN_FILE%% || exit /b
)
exit /b

:SET_FROM_FILE_IMPL
set "__STDIN_FILE=%~1"
set __DO_EXPAND_VALUE=0
if %__DO_EXPAND_ALL_VALUES%0 NEQ 0 set __DO_EXPAND_VALUE=1
if %__SET_FLAG_DBL_EXPAND_VALUE%0 NEQ 0 set __DO_EXPAND_VALUE=1

if %__DO_EXPAND_VALUE%0 NEQ 0 if %__SET_FLAG_REF%0 EQU 0 if defined __STDIN_FILE call set "__STDIN_FILE=%__STDIN_FILE%"

if %__SET_FLAG_DONT_EXPAND_NAME%0 EQU 0 (
  call set "__VAR_NAME=%__VAR_PREFIX%%__EXP%"
) else (
  set "__VAR_NAME=%__VAR_PREFIX%%__EXP%"
)

rem ignore set if variable's value does not exist as path or begins/ends by slash or having double slash inside (empty expanded variables in a value)
if %__SET_FLAG_IF_EXIST%0 NEQ 0 (
  if not defined __STDIN_FILE exit /b 0
  set "__STDIN_FILE=%__STDIN_FILE:\=/%"
)
if %__SET_FLAG_IF_EXIST%0 NEQ 0 (
  if "%__STDIN_FILE:~0,1%" == "/" exit /b 0
  if "%__STDIN_FILE:~-1%" == "/" exit /b 0
  if not "%__STDIN_FILE%" == "%__STDIN_FILE://=%" exit /b 0
  if not exist "%__STDIN_FILE%" exit /b 0
)

rem echo.%__SET_FLAGS%%__VAR_NAME%=^<"%__STDIN_FILE%" %__SET_FLAG_IF_EMPTY:1=/E% %__SET_FLAG_IF_EXIST:1=/H% %__SET_FLAG_REF:1=/R% %__SET_FLAG_DONT_EXPAND_NAME:1=/X% %__SET_FLAG_DBL_EXPAND_VALUE:1=/V%
rem echo.
rem exit /b 0
set %__SET_FLAGS%%__VAR_NAME%=<"%__STDIN_FILE%"
exit /b
