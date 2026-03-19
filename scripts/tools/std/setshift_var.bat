@echo off & goto DOC_END

rem USAGE:
rem   setshift_var.bat <shift> <out-var> <cmdline-var> [-exe] [-notrim] [-skip <skip-num>] [-num <num-args>]

rem Description:
rem   Script sets `<out-var>` variable to partially shifted command line from
rem  `<cmdline-var>` variable.
rem
rem   See `setshift.bat` script for details.

rem <out-var>:
rem   Variable to set.

rem <cmdline-var>:
rem   Variable with a command line.

rem CAUTION:
rem   The delayed expansion feature must be disabled before this script call:
rem   `setlocal DISABLEDELAYEDEXPANSION`, otherwise the `!` character will be
rem   expanded.

rem Examples (in console):
rem   1. >set CMDLINE="1 2" ! ? * ^& ^| , ; = ^= "=" 3
rem      >setshift_var.bat 0 x CMDLINE
rem      >set x
rem      x="1 2" ! ? * & | "=" 3
rem   2. >set CMDLINE="1 2" ! ? * ^& ^| , ; = ^= "=" 3
rem      >setshift_var.bat 0 x CMDLINE -exe
rem      >set x
rem      x="1 2" ! ? * & | , ; = = "=" 3
rem   3. >set CMDLINE="1 2" 3 4 5
rem      >setshift_var.bat 2 x CMDLINE
rem      >set x
rem      x=4 5
rem   4. >errlvl.bat 123
rem      >setshift_var.bat
rem      >setshift_var.bat 0 x
rem      >set CMDLINE=1 2 3
rem      >setshift_var.bat 0 x CMDLINE
rem      >echo ERRORLEVEL=%ERRORLEVEL%
rem      ERRORLEVEL=123
rem      >set x
rem      x=1 2 3
rem   5. >set CMDLINE=1 2 3 4 5 6 7
rem      >setshift_var.bat 1 x CMDLINE -num 3
rem      >set x
rem      x=2 3 4
rem      rem in a script
rem      >call setshift.bat -num 3 1 x %%*
rem   6. >set CMDLINE=1 2 3 4 5 6 7
rem      >setshift_var.bat -3 x CMDLINE
rem      >set x
rem      x=1 2 3 7
rem      rem in a script
rem      >call setshift.bat -3 x %%3 %%2 %%1 %%*
rem   7. >set CMDLINE=a b 1 2 3 4 5 6 7
rem      >setshift_var.bat -3 x CMDLINE -skip 2
rem      >set x
rem      x=a b 1 2 3 7
rem      rem in a script
rem      >call setshift.bat -skip 2 -3 x param0 param1 %%3 %%2 %%1 %%*
rem   8. >set CMDLINE= a  b  c  d
rem      >setshift_var.bat 1 x CMDLINE -notrim
rem      >set x
rem      x= b  c  d
rem   9. >set CMDLINE=^>cmd param0 param1
rem      >setshift_var.bat 0 x CMDLINE
rem      >set x
rem      x=>cmd param0 param1
rem  10. >set CMDLINE=; echo echo 123
rem      >setshift_var.bat 1 x CMDLINE
rem      >set x
rem      x=echo 123

rem Examples (in script):
rem   1. >set CMDLINE=^>cmd param0 param1
rem      call setshift_var.bat 0 x CMDLINE
rem      set x
rem   2. set "TAB=	"
rem      >set CMDLINE=cmd %TAB% %TAB% param0  %TAB%%TAB%  %TAB%%TAB%  param1 %TAB% %TAB%param2 %TAB%param3
rem      call setshift_var.bat 0 x CMDLINE -notrim
rem      set x
:DOC_END

rem with save of previous error level
setlocal DISABLEDELAYEDEXPANSION & set LAST_ERROR=%ERRORLEVEL%

rem drop last error level
call;

setlocal ENABLEDELAYEDEXPANSION & for /F "usebackq tokens=* delims="eol^= %%i in ('"!%~3!"') do endlocal & set "__STRING__=%%~i"

if not defined __STRING__ exit /b %LAST_ERROR%

set "SHIFT=%~1"

rem test on invalid flag
if not defined SHIFT exit /b %LAST_ERROR%

set "SHIFT_=%SHIFT%"

rem cast to integer
set /A SHIFT+=0

if not "%SHIFT%" == "%SHIFT_%" exit /b %LAST_ERROR%

set "OUTVAR=%~2"

if not defined OUTVAR endlocal & exit /b %LAST_ERROR%

set "?~dp0=%~dp0"

shift & shift & shift

rem script flags
set /A "FLAG_EXE=0", "FLAG_NO_TRIM=0", "FLAG_SKIP=0", "FLAG_NUM_ARGS=65536"

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG if "%FLAG%" == "-exe"     set "FLAG_EXE=1"            & shift         & call set "FLAG=%%~1"
if defined FLAG if "%FLAG%" == "-notrim"  set "FLAG_NO_TRIM=1"        & shift         & call set "FLAG=%%~1"
if defined FLAG if "%FLAG%" == "-skip"    set /A "FLAG_SKIP=%~2"      & shift & shift & call set "FLAG=%%~1"
if defined FLAG if "%FLAG%" == "-num"     set /A "FLAG_NUM_ARGS=%~2"  & shift & shift & call set "FLAG=%%~1"

if %FLAG_SKIP% LSS 0 set /A "FLAG_SKIP=0"
if %FLAG_NUM_ARGS% LSS 0 set /A "FLAG_NUM_ARGS=0"

set "CMDLINE="
set /A "SKIP=FLAG_SKIP"

if %SHIFT% GEQ 0 (
  set /A "SHIFT+=SKIP", "ARGS_END=FLAG_NUM_ARGS+SHIFT"
) else set /A "ARGS_END=SKIP+FLAG_NUM_ARGS-SHIFT", "SKIP+=-SHIFT", "SHIFT=FLAG_SKIP-SHIFT*2"

rem encode specific command line characters
if %FLAG_EXE% EQU 0 (
  call "%%?~dp0%%encode\encode_sys_chars_bat_cmdline.bat"
) else call "%%?~dp0%%encode\encode_sys_chars_exe_cmdline.bat"

rem CAUTION:
rem   Encodes ALL tabulation characters.

if %FLAG_NO_TRIM% NEQ 0 setlocal ENABLEDELAYEDEXPANSION & ^
set "__STRING__=!__STRING__:  = $20!" & set "__STRING__=!__STRING__:$20 =$20$20!" & ^
set "__STRING__=!__STRING__:		=	$09!" & set "__STRING__=!__STRING__:$09	=$09$09!" & ^
set "__STRING__=!__STRING__:	 =$09$20!" & set "__STRING__=!__STRING__:$09 =$09$20!" & ^
for /F "tokens=* delims="eol^= %%i in ("!__STRING__:	=$09!") do endlocal & set "__STRING__=%%i"

set INDEX=0

setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!__STRING__!") do endlocal & for %%j in (%%i) do (
  setlocal ENABLEDELAYEDEXPANSION & if !INDEX! LSS !SKIP! (
    if defined CMDLINE (
      for /F "tokens=* delims="eol^= %%v in ("!CMDLINE!") do endlocal & set "CMDLINE=%%v %%j"
    ) else endlocal & set "CMDLINE=%%j"
  ) else if !INDEX! GEQ !SHIFT! (
    if !INDEX! LSS !ARGS_END! (
      if defined CMDLINE (
        for /F "tokens=* delims="eol^= %%v in ("!CMDLINE!") do endlocal & set "CMDLINE=%%v %%j"
      ) else endlocal & set "CMDLINE=%%j"
    ) else endlocal
  ) else endlocal
  set /A INDEX+=1
)

setlocal ENABLEDELAYEDEXPANSION & set "__STRING__=!CMDLINE!" & if %FLAG_NO_TRIM% NEQ 0 set "__STRING__=!__STRING__:$20= !" & set "__STRING__=!__STRING__:$09=	!"
if not defined __STRING__ for /F "tokens=* delims="eol^= %%i in ("!OUTVAR!") do endlocal & endlocal & set "%%i=" & exit /b %LAST_ERROR%

for /F "tokens=* delims="eol^= %%i in ("!OUTVAR!") do (
  setlocal DISABLEDELAYEDEXPANSION & if %FLAG_EXE% EQU 0 (
    call "%%?~dp0%%encode\decode_sys_chars_bat_cmdline.bat"
  ) else call "%%?~dp0%%encode\decode_sys_chars_exe_cmdline.bat"
  setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%v in ("!__STRING__!") do endlocal & endlocal & endlocal & endlocal & set "%%i=%%v" & exit /b %LAST_ERROR%
)
