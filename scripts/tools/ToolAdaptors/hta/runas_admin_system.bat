@echo off & goto DOC_END

rem USAGE:
rem   runas_admin_system.bat <cmdline>...

rem Description:
rem   Script runs <cmdline> under UAC promotion using `mshta.exe` executable.
rem   The command line does split by the first argument to be passed into
rem   `ShellExecute` function.
rem   Requires `psexec.exe` in the `PATH` or in the `PSEXEC` variable.
rem
rem   The <cmdline> can contain an even number of double quotes prefixed by the
rem   `\` character. It will be replaced by N/2 number of quotes without the
rem   prefix:
rem     \"" -> "
rem     \"""" -> ""
rem     \"""""" -> """
rem     etc
rem   The meaning is to always use an even number of quotes to insert an
rem   arbitrary number of quotes.

rem CAUTION:
rem   `\""`, `\""""`, etc expressions only has meaning inside a `.bat` script.
rem   Any attempt to use it outside of a script (including a terminal command
rem   line) will lead into incorrect expansion because a terminal command
rem   line or an `.exe` command line has their own different expansion rules
rem   including command line of the `cmd.exe` executable.

rem NOTE:
rem   The command line load and parse code is a copy from
rem   `print-args-as-splitted-exe-cmdline.bat` script from `userbin` project.

rem CAUTION:
rem   Opposite to `runas_admin.bat` script the
rem   `runas_admin_system.bat "%SystemRoot%\System32\cmd.exe" ...` command will
rem   start a 64-bit variant of `cmd.exe` process even if run from 32-bit
rem   `cmd.exe` process.
rem   You have to use
rem   `runas_admin_system.bat "%SystemRoot%\SysWOW64\cmd.exe" ..` command
rem   instead to directly run 32-bit `cmd.exe` process.

rem Examples (in script):
rem   1. >
rem      set "PSEXEC=.../psexec.exe"
rem      runas_admin_system.bat "%SystemRoot%\System32\cmd.exe" /k echo 123
rem      runas_admin_system.bat "%SystemRoot%\SysWOW64\cmd.exe" /k echo 123
rem
rem   2. Without Windows Batch compatible double quotes escapes
rem      >
rem      set "PSEXEC=.../psexec.exe"
rem      set CMDLINE=print-args-as-splitted-exe-cmdline.bat "123 & 456" "654 | 321"
rem      
rem      call is-system-elevated.bat && (
rem        set CMDLINE="%SystemRoot%\System32\cmd.exe" /c %CMDLINE%
rem        call;
rem      ) || set CMDLINE="%SystemRoot%\System32\cmd.exe" /k %CMDLINE%
rem      
rem      runas_admin_system.bat %CMDLINE%
rem      
rem      <
rem      rem |"123 & 456"|
rem      rem |"654 | 321"|
rem
rem   3. >
rem      set "PSEXEC=.../psexec.exe"
rem      set "CMDLINE=print-args-as-splitted-exe-cmdline.bat \""123 & 456\"" \""654 | 321\"""
rem      
rem      call is-system-elevated.bat && (
rem        set CMDLINE="%SystemRoot%\System32\cmd.exe" /S /c "%CMDLINE%"
rem        call;
rem      ) || set CMDLINE="%SystemRoot%\System32\cmd.exe" /S /k "%CMDLINE%"
rem      
rem      runas_admin_system.bat %CMDLINE%
rem      
rem      <
rem      rem |"123 & 456"|
rem      rem |"654 | 321"|
:DOC_END

rem with save of previous error level, second `setlocal` to drop locals before a command line execution
setlocal DISABLEDELAYEDEXPANSION & setlocal & set LAST_ERROR=%ERRORLEVEL%

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"

if defined SCRIPT_TEMP_CURRENT_DIR (
  set "CMDLINE_TEMP_FILE=%SCRIPT_TEMP_CURRENT_DIR%\%~n0.%RANDOM%-%RANDOM%.txt"
) else set "CMDLINE_TEMP_FILE=%TEMP%\%~n0.%RANDOM%-%RANDOM%.txt"

(
  setlocal DISABLEEXTENSIONS
  (PROMPT=$_)
  echo on
  for %%z in (%%z) do rem |%*|
  @echo off
  endlocal
) > "%CMDLINE_TEMP_FILE%"

set "?.=" & for /F "usebackq tokens=* delims="eol^= %%i in ("%CMDLINE_TEMP_FILE%") do set "?.=%%i"

rem CAUTION: must check on empty variable to avoid accidental `del /Q ""` case
if defined CMDLINE_TEMP_FILE del /F /Q /A:-D "%CMDLINE_TEMP_FILE%" >nul 2>nul

rem WORKAROUND:
rem   In case if `echo` is turned off externally.
rem
if not defined ?. exit /b %LAST_ERROR%

setlocal ENABLEDELAYEDEXPANSION & for /F "usebackq tokens=* delims="eol^= %%i in ('"!?.:~5,-2!"') do endlocal & set "?.=%%~i"

if not defined ?. exit /b %LAST_ERROR%

rem CAUTION:
rem   We must always use the Administrator elevation in case of not SYSTEM
rem   account, because `psexec.exe` can be installed only in the elevated
rem   account.

call :IS_SYSTEM_ELEVATED || goto CALL_ADMIN_ELEVATE_AND_EXIT

rem translate Windows Batch compatible double quotes escapes into escape placeholders
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!?.:$=$0!") do endlocal & set "?.=%%i"
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!?.:\""""""=$3!") do endlocal & set "?.=%%i"
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!?.:\""""=$2!") do endlocal & set "?.=%%i"
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!?.:\""=$1!") do endlocal & set "?.=%%i"
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!?.:"^=$1!"") do endlocal & set "?.=%%i"
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!?.:~0,-1!") do endlocal & set "?.=%%i"

rem translate escape placeholders into an arbitrary number of double quotes
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!?.:$3="""!"") do endlocal & set "?.=%%i"
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!?.:~0,-1!") do endlocal & set "?.=%%i"
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!?.:$2=""!") do endlocal & set "?.=%%i"
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!?.:$1="!"") do endlocal & set "?.=%%i"
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!?.:~0,-1!") do endlocal & set "?.=%%i"
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!?.:$0=$!") do endlocal & set "?.=%%i"

rem with locals drop
setlocal ENABLEDELAYEDEXPANSION & ^
for /F "usebackq tokens=* delims="eol^= %%i in ('"!?.!"') do endlocal & endlocal & %%~i
exit /b

rem CAUTION:
rem   Windows 7 has an issue around the `find.exe` utility and code page 65001.
rem   We use `findstr.exe` instead of `find.exe` to workaround it.
rem
rem   Based on: https://superuser.com/questions/557387/pipe-not-working-in-cmd-exe-on-windows-7/1869422#1869422

rem CAUTION:
rem   In Windows XP an elevated call under data protection flag will block the wmic tool, so we have to use `ver` command instead!

:IS_SYSTEM_ELEVATED
set "WINDOWS_VER_STR=" & set "WINDOWS_MAJOR_VER=0" & for /F "usebackq tokens=1,2,* delims=[]" %%i in (`@ver 2^>nul`) do set "WINDOWS_VER_STR=%%j"
if not defined WINDOWS_VER_STR goto SKIP_VER
setlocal ENABLEDELAYEDEXPANSION & for /F "usebackq tokens=* delims="eol^= %%i in ('"!WINDOWS_VER_STR:* =!"') do endlocal & set "WINDOWS_VER_STR=%%~i"
for /F "tokens=1,2,* delims=."eol^= %%i in ("%WINDOWS_VER_STR%") do set "WINDOWS_MAJOR_VER=%%i"
:SKIP_VER
if %WINDOWS_MAJOR_VER% GEQ 6 (
  if exist "%SystemRoot%\System32\where.exe" "%SystemRoot%\System32\whoami.exe" /groups | "%SystemRoot%\System32\findstr.exe" /L "S-1-16-16384" >nul 2>nul & exit /b
) else if exist "%SystemRoot%\System32\fltmc.exe" "%SystemRoot%\System32\fltmc.exe" >nul 2>nul & exit /b
exit /b 255

:CALL_ADMIN_ELEVATE_AND_EXIT
if not defined PSEXEC set "PSEXEC=psexec.exe"

setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!PSEXEC!") do endlocal & set "PSEXEC=%%~fi"

if not exist "%PSEXEC%" (
  echo;%?~%: error: `psexec.exe` is not found: "%PSEXEC%".
  exit /b 255
) >&2

call :SPLIT_COMMAND_LINE

rem translate Windows Batch compatible double quotes escapes into escape placeholders
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!COMMAND:$=$0!") do endlocal & set "COMMAND=%%i"
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!COMMAND:\""""""=$3!") do endlocal & set "COMMAND=%%i"
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!COMMAND:\""""=$2!") do endlocal & set "COMMAND=%%i"
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!COMMAND:\""=$1!") do endlocal & set "COMMAND=%%i"
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!COMMAND:"^=$1!"") do endlocal & set "COMMAND=%%i"
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!COMMAND:~0,-1!") do endlocal & set "COMMAND=%%i"

rem translate escape placeholders into an arbitrary number of double quotes in `mshta.exe` (vbs) format
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!COMMAND:$3=""""""""""""!") do endlocal & set "COMMAND=%%i"
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!COMMAND:$2=""""""""!") do endlocal & set "COMMAND=%%i"
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!COMMAND:$1=""""!") do endlocal & set "COMMAND=%%i"
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!COMMAND:$0=$!") do endlocal & set "COMMAND=%%i"

if defined ARGS (
  rem translate Windows Batch compatible double quotes escapes into escape placeholders
  setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!ARGS:$=$0!") do endlocal & set "ARGS=%%i"
  setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!ARGS:\""""""=$3!") do endlocal & set "ARGS=%%i"
  setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!ARGS:\""""=$2!") do endlocal & set "ARGS=%%i"
  setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!ARGS:\""=$1!") do endlocal & set "ARGS=%%i"
  setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!ARGS:"^=$1!"") do endlocal & set "ARGS=%%i"
  setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!ARGS:~0,-1!") do endlocal & set "ARGS=%%i"

  rem translate escape placeholders into an arbitrary number of double quotes in `mshta.exe` (vbs) format
  setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!ARGS:$3=""""""""""""!") do endlocal & set "ARGS=%%i"
  setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!ARGS:$2=""""""""!") do endlocal & set "ARGS=%%i"
  setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!ARGS:$1=""""!") do endlocal & set "ARGS=%%i"
  setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!ARGS:$0=$!") do endlocal & set "ARGS=%%i"
)

rem CAUTION: ShellExecute does not wait a child process close!
rem NOTE: `ExecuteGlobal` is used as a workaround, because the `mshta.exe` first argument must not be used with the surrounded quotes

rem with locals drop
setlocal ENABLEDELAYEDEXPANSION & ^
for /F "usebackq tokens=* delims="eol^= %%i in ('"!PSEXEC!"') do ^
for /F "usebackq tokens=* delims="eol^= %%j in ('"!COMMAND!!ARGS!"') do endlocal & endlocal & ^
start /B /WAIT "" "%SystemRoot%\System32\mshta.exe" vbscript:ExecuteGlobal("Close(CreateObject(""Shell.Application"").ShellExecute(""%%~i"", ""-i -s -d %%~j"", """", ""runas"", 0))")
exit /b

:SPLIT_COMMAND_LINE
rem Encode these characters (see general implementation in `std/encode/encode_sys_chars_exe_cmdline.bat` script):
rem  $          - encode character
rem  |&()<>     - control flow characters
rem  '`^%!+     - escape or sequence expand characters (`+` is a unicode codepoint sequence character in 65000 code page)
rem  ?*<>       - globbing characters in the `for ... %%i in (...)` expression or in a command line (`?<` has different globbing versus `*`, `*.` versus `*.>`)
rem  ,;=        - separator characters in the `for ... %%i in (...)` expression or in a command line

setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!?.:$=$24!") do endlocal & set "?.=%%i"

setlocal ENABLEDELAYEDEXPANSION & set "?.=!?.:"=$22!"
for /F "tokens=* delims="eol^= %%i in ("!?.!") do endlocal & set "?.=%%i"

set "?.=%?.:!=$21%"

setlocal ENABLEDELAYEDEXPANSION & if "!?.!" == "!?.:**=!" ( endlocal & goto ASTERISK_CHAR_ENCODE_END ) else endlocal

:ASTERISK_CHAR_ENCODE_LOOP
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=1 delims=*"eol^= %%i in (".!?.!") do for /F "tokens=* delims="eol^= %%j in ("!?.:**=!.") do endlocal & set "?.=%%i$2A%%j" & ^
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!?.:~1,-1!") do ^
if not "!?.!" == "!?.:**=!" ( endlocal & set "?.=%%i" & goto ASTERISK_CHAR_ENCODE_LOOP ) else endlocal & set "?.=%%i"
:ASTERISK_CHAR_ENCODE_END

setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!?.!") do for /F "tokens=1 delims=="eol^= %%j in (".!?.!") do endlocal & set "__HEAD__=%%j" & set "__TAIL__=.%%i" & ^
setlocal ENABLEDELAYEDEXPANSION & if "!__HEAD__!" == "!__TAIL__!" ( endlocal & goto EQUAL_CHAR_ENCODE_END ) else endlocal

set "?.=" & setlocal ENABLEDELAYEDEXPANSION
:EQUAL_CHAR_ENCODE_LOOP
if "!__HEAD__!" == "!__TAIL__!" for /F "tokens=* delims="eol^= %%i in ("!?.!!__TAIL__:~1!") do endlocal & set "?.=%%i" & goto EQUAL_CHAR_ENCODE_END
set "__OFFSET__=2" & set "__TMP__=!__HEAD__!" & for %%i in (65536 32768 16384 8192 4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do if not "!__TMP__:~%%i,1!" == "" set /A "__OFFSET__+=%%i" & set "__TMP__=!__TMP__:~%%i!"
if defined __TAIL__ set "__TAIL__=!__TAIL__:~%__OFFSET__%!"
set "?.=!?.!!__HEAD__:~1!$3D" & ^
for /F "tokens=* delims="eol^= %%i in ("!?.!") do for /F "tokens=1 delims=="eol^= %%j in (".!__TAIL__!") do for /F "tokens=* delims="eol^= %%k in (".!__TAIL__!") do ^
endlocal & set "?.=%%i" & set "__HEAD__=%%j" & set "__TAIL__=%%k" & setlocal ENABLEDELAYEDEXPANSION
goto EQUAL_CHAR_ENCODE_LOOP
:EQUAL_CHAR_ENCODE_END

setlocal ENABLEDELAYEDEXPANSION & ^
set "?.=!?.:|=$7C!" & set "?.=!?.:&=$26!"  & set "?.=!?.:(=$28!" & set "?.=!?.:)=$29!" & ^
set "?.=!?.:<=$3C!" & set "?.=!?.:>=$3E!"  & set "?.=!?.:'=$27!" & set "?.=!?.:`=$60!" & ^
set "?.=!?.:^=$5E!" & set "?.=!?.:%%=$25!" & set "?.=!?.:+=$2B!" & ^
set "?.=!?.:?=$3F!" & set "?.=!?.:,=$2C!"  & set "?.=!?.:;=$3B!" & ^
for /F "tokens=* delims="eol^= %%i in ("!?.!") do endlocal & set "?.=%%i"

set "COMMAND="
set "ARGS="

setlocal ENABLEDELAYEDEXPANSION & set "?.=!?.:$22="!" & ^
for /F "tokens=* delims="eol^= %%i in ("!?.!") do endlocal & for %%j in (%%i) do (
  set "__ARG__=%%j" & setlocal ENABLEDELAYEDEXPANSION & set "__ARG__=!__ARG__:"=$22!"
  for /F "tokens=* delims="eol^= %%i in ("!__ARG__!") do endlocal & set "__ARG__=%%i"

  call set "__ARG__=%%__ARG__:$21=!%%"

  setlocal ENABLEDELAYEDEXPANSION & set "__ARG__=!__ARG__:$22="!"
    set "__ARG__=!__ARG__:$7C=|!" & set "__ARG__=!__ARG__:$26=&!"  & set "__ARG__=!__ARG__:$28=(!" & set "__ARG__=!__ARG__:$29=)!" ^
  & set "__ARG__=!__ARG__:$3C=<!" & set "__ARG__=!__ARG__:$3E=>!"  & set "__ARG__=!__ARG__:$27='!" & set "__ARG__=!__ARG__:$60=`!" ^
  & set "__ARG__=!__ARG__:$5E=^!" & set "__ARG__=!__ARG__:$25=%%!" & set "__ARG__=!__ARG__:$2B=+!" ^
  & set "__ARG__=!__ARG__:$3F=?!" & set "__ARG__=!__ARG__:$2A=*!" ^
  & set "__ARG__=!__ARG__:$2C=,!" & set "__ARG__=!__ARG__:$3B=;!"  & set "__ARG__=!__ARG__:$3D==!" & set "__ARG__=!__ARG__:$24=$!" ^
  & for /F "tokens=* delims="eol^= %%i in ("!__ARG__!") do break ^
  & if defined COMMAND (
    for /F "usebackq tokens=* delims="eol^= %%j in ('"!ARGS!"') do endlocal & set "ARGS=%%~j %%i"
  ) else endlocal & set "COMMAND=%%i"
)
