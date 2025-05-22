@echo off & goto DOC_END

rem USAGE:
rem   callshift.bat [-exe] [-notrim] [-skip <skip-num>] [-lockfile <lock-file> [-trylock] [-lock-sleep-cmdline <lock-sleep-cmdline>]] [<shift> [<command> [<cmdline>...]]]

rem Description:
rem   Script calls `<command>` with skipped and shifted `<cmdline>`.
rem   The `call` prefix is not required to call batch scripts.

rem -exe
rem   Use exe command line encoder instead of the batch as by default.
rem   An executable command line does not use `,;=` characters as command line
rem   arguments separator.

rem -notrim
rem   Avoids spaces trim in the shifted command line.

rem -skip <skip-num>
rem   Number of `<cmdline>` arguments to skip before shift.
rem   If not defined, then 0.

rem -lockfile <lock-file>
rem   Calls a command line under the lock (a file redirection trick).
rem   If the lock was holden before the call, then the call waits the unlock
rem   if `-trylock` flag is not defined. Otherwise just ignores and the script
rem   returns a negative error code (-1024).
rem   The lock file directory must exist before the call.
rem   The lock file will be removed on script exit.

rem -lockfile <lock-file>
rem   Lock file path to lock the call.

rem -trylock
rem   Try to lock and if not, then exit immediately (-1024) instead of waiting
rem   the lock.
rem   Has no effect if `-lockfile` is not defined.

rem -lock-sleep-cmdline <lock-sleep-cmdline>
rem   The command line for the `sleep.bat` script to call on before attempt to
rem   acquire another lock.
rem   Has no effect if `-lockfile` is not defined.
rem   If not defined, then `50` (ms) is used by default.

rem <shift>:
rem   Number of `<cmdline>` arguments to skip and shift.
rem   If >=0, then shifts by `<shift>` beginning from `<skip-num>` argument.
rem   If < 0, then shifts by `|<shift>|` beginning from `<skip-num>+|<shift>|`
rem   argument.

rem <command>:
rem   Command to call with arguments.

rem CAUTION:
rem   The delayed expansion feature must be disabled before this script call:
rem   `setlocal DISABLEDELAYEDEXPANSION`, otherwise the `!` character will be
rem   expanded.
rem

rem Examples (in console):
rem   1. >callshift.bat 0 echo "1 2" ! ? * ^& ^| , ; = ^= "=" 3
rem      "1 2" ! ? * & | "=" 3
rem   2. >callshift.bat -exe 0 echo "1 2" ! ? * ^& ^| , ; = ^= "=" 3
rem      "1 2" ! ? * & | , ; = = "=" 3
rem   3. >callshift.bat 2 echo:"1 2" 3 4 5
rem      "1 2" 5
rem   4. >callshift.bat . set | sort
rem   5. >errlvl.bat 123
rem      >callshift.bat
rem      >callshift.bat 0 echo:
rem      >callshift.bat 0 echo 1 2 3
rem      >echo ERRORLEVEL=%ERRORLEVEL%
rem      ERRORLEVEL=123
rem   6. >callshift.bat -3 echo 1 2 3 4 5 6 7
rem      1 2 3 7
rem      rem in a script
rem      >call callshift.bat -3 command %%3 %%2 %%1 %%*
rem   7. >callshift.bat -skip 2 -3 echo a b 1 2 3 4 5 6 7
rem      a b 1 2 3 7
rem      rem in a script
rem      >call callshift.bat -skip 2 -3 command param0 param1 %%3 %%2 %%1 %%*
rem   8. >callshift.bat 0 exit /b 321
rem      >echo ERRORLEVEL=%ERRORLEVEL%
rem      ERRORLEVEL=321
rem   9. >errlvl.bat 123
rem      >callshift.bat 0 errlvl.bat 321
rem      >echo ERRORLEVEL=%ERRORLEVEL%
rem      ERRORLEVEL=321
rem  10. >callshift.bat -notrim 1 echo  a  b  c  d
rem       b  c  d
rem  11. >callshift.bat 0 echo;^>cmd param0 param1
rem      >cmd param0 param1
rem  12. >callshift.bat -lockfile "%TEMP%\lock0.myscript" 0 echo;Exclusive print

rem Examples (in script):
rem   1. set "$5E$3E=^>"
rem      call callshift.bat 0 echo;%%$5E$3E%%cmd param0 param1
rem   2. set "TAB=	"
rem      call callshift.bat -notrim 0 echo;cmd %%TAB%% %%TAB%% param0  %%TAB%%%%TAB%%  %%TAB%%%%TAB%%  param1 %%TAB%% %%TAB%%param2 %%TAB%%param3

rem Pros:
rem
rem   * Can handle almost all control characters.
rem   * Can call builtin commands.
rem   * Does restore previous ERRORLEVEL variable before call a command.
rem   * Can skip first N used arguments from the `%*` variable including
rem     additional command line arguments.
rem   * Can avoid spaces and tabulation characters trim in the shifted command
rem     line.
rem   * Can lock the call using a redirection into a file while at the command
rem     line call.
rem
rem Cons:
rem
rem   * The control characters like `&` and `|` still must be escaped before
rem     call in a user script (side issue).
rem   * Does write to a temporary file to save the command line as is and
rem     `cmd.exe /Q ...` can suppress `echo on` at all.
rem   * The delayed expansion feature must be disabled before this script call:
rem     `setlocal DISABLEDELAYEDEXPANSION`, otherwise the `!` character will be
rem     expanded.
rem   * A batch script command line and an executable command line has
rem     different encoders.
rem   * In case of a tabulation character immediately after a command line
rem     argument, you must entail each argument at least with one space
rem     character, because all tabulation characters does encode which may end
rem     up with arguments concatenation and so wrong skip and/or shift.
:DOC_END

rem with save of previous error level
setlocal DISABLEDELAYEDEXPANSION & set LAST_ERROR=%ERRORLEVEL%

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"

rem drop last error level
call;

if defined SCRIPT_TEMP_CURRENT_DIR (
  set "CMDLINE_TEMP_FILE=%SCRIPT_TEMP_CURRENT_DIR%\%~n0.%RANDOM%-%RANDOM%.txt"
) else set "CMDLINE_TEMP_FILE=%TEMP%\%~n0.%RANDOM%-%RANDOM%.txt"

rem redirect command line into temporary file to print it correctly
(
  setlocal DISABLEEXTENSIONS
  (set PROMPT=$_)
  echo on
  for %%z in (%%z) do rem * %*#
  @echo off
  endlocal
) > "%CMDLINE_TEMP_FILE%"

set "__STRING__=" & for /F "usebackq tokens=* delims="eol^= %%i in ("%CMDLINE_TEMP_FILE%") do set "__STRING__=%%i"

del /F /Q /A:-D "%CMDLINE_TEMP_FILE%" >nul 2>nul

rem WORKAROUND:
rem   In case if `echo` is turned off externally.
rem
if not defined __STRING__ exit /b %LAST_ERROR%

setlocal ENABLEDELAYEDEXPANSION & if not "!__STRING__:~6!" == "# " (
  for /F "tokens=* delims="eol^= %%i in ("!__STRING__:~6,-2!") do endlocal & set "__STRING__=%%i"
) else endlocal & set "__STRING__="

if not defined __STRING__ exit /b %LAST_ERROR%

set "?~dp0=%~dp0"

rem script flags
set FLAG_SHIFT=0
set FLAG_EXE=0
set FLAG_NO_TRIM=0
set FLAG_SKIP=0
set "FLAG_LOCK_FILE="
set "FLAG_LOCK_SLEEP_CMDLINE= 50"
set FLAG_TRYLOCK=0

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG if "%FLAG%" == "-exe" (
  set FLAG_EXE=1
  shift
  call set "FLAG=%%~1"
  set /A FLAG_SHIFT+=1
)

if defined FLAG if "%FLAG%" == "-notrim" (
  set FLAG_NO_TRIM=1
  shift
  call set "FLAG=%%~1"
  set /A FLAG_SHIFT+=1
)

if defined FLAG if "%FLAG%" == "-skip" (
  set "FLAG_SKIP=%~2"
  shift
  shift
  call set "FLAG=%%~1"
  set /A FLAG_SHIFT+=2
)

if defined FLAG if "%FLAG%" == "-lockfile" (
  set "FLAG_LOCK_FILE=%~2"
  shift
  shift
  call set "FLAG=%%~1"
  set /A FLAG_SHIFT+=2
)

if defined FLAG if "%FLAG%" == "-lock-sleep-cmdline" (
  set "FLAG_LOCK_SLEEP_CMDLINE= %~2"
  shift
  shift
  call set "FLAG=%%~1"
  set /A FLAG_SHIFT+=2
)

if defined FLAG if "%FLAG%" == "-trylock" (
  set FLAG_TRYLOCK=1
  shift
  call set "FLAG=%%~1"
  set /A FLAG_SHIFT+=1
)

set "SHIFT=%~1"
set "COMMAND="
set "CMDLINE="

rem test on invalid flag
if not defined SHIFT exit /b %LAST_ERROR%

set "SHIFT_=%SHIFT%"

rem cast to integer
set /A SHIFT+=0

if not "%SHIFT%" == "%SHIFT_%" exit /b %LAST_ERROR%

if not defined FLAG_LOCK_FILE goto SKIP_CALL_LOCK

for /F "tokens=* delims="eol^= %%i in ("%FLAG_LOCK_FILE%\.") do set "FLAG_LOCK_FILE_DIR=%%~dpi"

if not exist "%FLAG_LOCK_FILE_DIR%*" (
  echo;%?~%: error: lock file directory does not exist: "%FLAG_LOCK_FILE_DIR%"
  exit /b -1024
) >&2

rem lock loop
:CALL_LOCK_LOOP

rem lock via redirection to file
set LOCK_ACQUIRE=0
( ( set "LOCK_ACQUIRE=1" & call :LOCKED_CALL ) 9> "%FLAG_LOCK_FILE%" ) 2>nul

set LAST_ERROR=%ERRORLEVEL%

if %LOCK_ACQUIRE% EQU 0 (
  if %FLAG_TRYLOCK% NEQ 0 (
    del /F /Q /A:-D "%FLAG_LOCK_FILE%" >nul 2>nul
    exit /b -1024
  )

  call "%%?~dp0%%sleep.bat"%%FLAG_LOCK_SLEEP_CMDLINE%%

  goto CALL_LOCK_LOOP
)

del /F /Q /A:-D "%FLAG_LOCK_FILE%" >nul 2>nul

exit /b %LAST_ERROR%

:SKIP_CALL_LOCK
:LOCKED_CALL

rem cast to integer
set /A FLAG_SKIP+=0

set /A COMMAND_INDEX=FLAG_SHIFT+1
set /A ARG0_INDEX=FLAG_SHIFT+2

set /A SKIP=FLAG_SHIFT+2+FLAG_SKIP

if %SHIFT% GEQ 0 (
  set /A SHIFT+=SKIP
) else (
  set /A SKIP+=-SHIFT
  set /A SHIFT=FLAG_SHIFT+2+FLAG_SKIP-SHIFT*2
)

rem encode specific command line characters
if %FLAG_EXE% EQU 0 (
  call "%%?~dp0%%encode\encode_sys_chars_bat_cmdline.bat"
) else call "%%?~dp0%%encode\encode_sys_chars_exe_cmdline.bat"

rem CAUTION:
rem   Encodes ALL tabulation characters.
rem
if %FLAG_NO_TRIM% NEQ 0 setlocal ENABLEDELAYEDEXPANSION & ^
set "__STRING__=!__STRING__:  = $20!" & set "__STRING__=!__STRING__:$20 =$20$20!" & ^
set "__STRING__=!__STRING__:		=	$09!" & set "__STRING__=!__STRING__:$09	=$09$09!" & ^
set "__STRING__=!__STRING__:	 =$09$20!" & set "__STRING__=!__STRING__:$09 =$09$20!" & ^
for /F "tokens=* delims="eol^= %%i in ("!__STRING__:	=$09!") do endlocal & set "__STRING__=%%i"

set INDEX=0

setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!__STRING__!") do endlocal & for %%j in (%%i) do (
  setlocal ENABLEDELAYEDEXPANSION & if !INDEX! GEQ !ARG0_INDEX! (
    if !INDEX! LSS !SKIP! (
      if defined CMDLINE (
        for /F "tokens=* delims="eol^= %%v in ("!CMDLINE!") do endlocal & set "CMDLINE=%%v %%j"
      ) else endlocal & set "CMDLINE=%%j"
    ) else if !INDEX! GEQ !SHIFT! (
      if defined CMDLINE (
        for /F "tokens=* delims="eol^= %%v in ("!CMDLINE!") do endlocal & set "CMDLINE=%%v %%j"
      ) else endlocal & set "CMDLINE=%%j"
    ) else endlocal
  ) else if !INDEX! EQU !COMMAND_INDEX! (
    endlocal & set "COMMAND=%%j"
  ) else endlocal
  set /A INDEX+=1
)

if not defined COMMAND endlocal & exit /b %LAST_ERROR%
setlocal ENABLEDELAYEDEXPANSION & if defined CMDLINE (
  set "__STRING__=!COMMAND! !CMDLINE!"
) else set "__STRING__=!COMMAND!"
if %FLAG_NO_TRIM% NEQ 0 set "__STRING__=!__STRING__:$20= !" & set "__STRING__=!__STRING__:$09=	!"

setlocal DISABLEDELAYEDEXPANSION & if %FLAG_EXE% EQU 0 (
  call "%%?~dp0%%encode\decode_sys_chars_bat_cmdline.bat"
) else call "%%?~dp0%%encode\decode_sys_chars_exe_cmdline.bat"
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%v in ("!__STRING__!") do endlocal & endlocal & endlocal & endlocal & call :SETERRORLEVEL %LAST_ERROR% & (
  %%v
)
exit /b

:SETERRORLEVEL
exit /b %*
