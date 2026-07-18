@echo off & goto DOC_END

rem CAUTION:
rem   The `set_fileshortname.vbs` script must be a 32-bit process to create
rem   `jcb.tools` object.

rem NOTE:
rem   The elevation shell code is based on:
rem     `Uniform variant of a command line as a single argument for the mshta.exe executable and other cases` :
rem     https://github.com/andry81/contools/discussions/11

rem NOTE:
rem   A command line or a variable (ex: `__SCRIPT__`) can contain an even
rem   number of double quotes prefixed by the `\` character.
rem
rem   It can be replaced by N/2 number of quotes without the prefix or
rem   a quote with N/2-nested escape sequence:
rem
rem     \""     -> "    or \"
rem     \""""   -> ""   or \\\"
rem     \"""""" -> """  or \\\\\\\"
rem     etc
rem
rem   The meaning is to always use an even number of quotes to insert an
rem   arbitrary number of quotes with or without an escape sequence.
rem
rem   For example, in the `set` command, because
rem   the `set` command argument is started by a double quote:
rem
rem     >
rem     set "A=X \"" | & < > \"""
rem     set "B=Y \"" | & < > \"" | & < > \"""" | & < > \"""""

rem CAUTION:
rem   The environment variables does use by the shell code to workaround the
rem   `mshta.exe` command line length limitation (see the link).

rem CAUTION:
rem   The `mshta.exe` does expand all the %-escape placeholders (`%NN`).
rem   The script does not use `%` character in the shell code. In case of a
rem   change in the future you must prevent the expansion by replacing all the
rem   `%` by `%25` to avoid the command line breakage.
rem   All the `"` does process for the same reason.

rem NOTE:
rem   The `ExecuteGlobal` is used as a workaround, because the `mshta.exe`
rem   first argument must not be used with the surrounded quotes.

rem CAUTION:
rem   The `ShellExecute` does not wait a child process close.

rem CAUTION:
rem   The `cmd.exe` does expand the %-variables in the context of an elevated
rem   process. You must properly escape these to avoid the expansion before the
rem   elevation!

rem CAUTION:
rem   `\""`, `\""""`, etc expressions only has meaning inside a `.bat` script.
rem   Any attempt to use it outside of a script (including a terminal command
rem   line) will lead into incorrect expansion because a terminal command
rem   line or an `.exe` command line has their own different expansion rules
rem   including command line of the `cmd.exe` executable.

rem CAUTION:
rem   Avoid a back slash before the double quote in an executable (`.exe`)
rem   command line, otherwise a command line parse will be broken:
rem     >
rem     some.exe "... ... \"
rem                        ^ - escaped
rem     >
rem     some.exe "... ... \""
rem                        ^ - escaped
rem   To workaround:
rem     >
rem     some.exe "... ... \\"
rem                        ^ - escaped
rem     >
rem     some.exe "... ... \\""
rem                        ^ - escaped
rem
rem   A trailing double quote will be escaped in some command line parse code
rem   runtimes. But not everywhere, for example, `cmd.exe` has different rules:
rem
rem     >
rem     cmd.exe /c @echo "... ... \"
rem                               ^ - prints as is

rem NOTE:
rem   The `::"::"::` is an unexisted statement in the VBS
rem   (error: `VBScript compilation error: Expected statement`) in case of
rem   strip from a string with a valid VBS shell code. So it can be used as a
rem   VBS shell code lines delimiter in another shell code or Windows Batch
rem   script.

rem CAUTION:
rem   If you pass a parameter or set of parameters starting the first argument,
rem   then these may be skipped, due to the internal `cmd.exe` command line
rem   parse logic. The command line does not ignored if started using the slash
rem   character with the known option - `/k`, `/c` and etc.
:DOC_END

rem second `setlocal` to drop locals before a command line execution
setlocal DISABLEDELAYEDEXPANSION & setlocal

rem script names call stack, disabled due to self call and partial inheritance (process elevation does not inherit a parent process variables by default)
rem if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"
set "?~=%~nx0"

set /A ELEVATED+=0

if %IMPL_MODE%0 NEQ 0 goto IMPL
call :IS_ADMIN_ELEVATED && goto ELEVATED

goto ELEVATE

rem CAUTION:
rem   Windows 7 has an issue around the `find.exe` utility and code page 65001.
rem   We use `findstr.exe` instead of `find.exe` to workaround it.
rem
rem   Based on: https://superuser.com/questions/557387/pipe-not-working-in-cmd-exe-on-windows-7/1869422#1869422

rem CAUTION:
rem   In Windows XP an elevated call under data protection flag will block the wmic tool, so we have to use `ver` command instead!

:IS_ADMIN_ELEVATED
set "WINDOWS_VER_STR=" & set "WINDOWS_MAJOR_VER=0" & for /F "usebackq tokens=1,2,* delims=[]" %%i in (`@ver 2^>nul`) do set "WINDOWS_VER_STR=%%j"
if not defined WINDOWS_VER_STR goto SKIP_VER
setlocal ENABLEDELAYEDEXPANSION & for /F "usebackq tokens=* delims="eol^= %%i in ('"!WINDOWS_VER_STR:* =!"') do endlocal & set "WINDOWS_VER_STR=%%~i"
for /F "tokens=1,2,* delims=."eol^= %%i in ("%WINDOWS_VER_STR%") do set "WINDOWS_MAJOR_VER=%%i"
:SKIP_VER
if %WINDOWS_MAJOR_VER% GEQ 6 (
  if exist "%SystemRoot%\System32\where.exe" "%SystemRoot%\System32\whoami.exe" /groups | "%SystemRoot%\System32\findstr.exe" /L "S-1-16-12288" >nul 2>nul & exit /b
) else if exist "%SystemRoot%\System32\fltmc.exe" "%SystemRoot%\System32\fltmc.exe" >nul 2>nul & exit /b
exit /b 255

:ELEVATE
for /F "tokens=* delims="eol^= %%i in ("%CD%\.") do set "CWD=%%~fi"

if "%CWD:~-1%" == "\" set "CWD=%CWD%."

rem CAUTION:
rem   The `cd "%CD%" ^& %CD:~0,2%` must be before the command, otherwise the system root will be the current directory!
rem

rem Windows Batch compatible command line with escapes
set "?@=/c @set \""IMPL_MODE=1\"" & cd \""%CWD%\"" & %CWD:~0,2% & \""%~f0\"" %* & pause"

rem shell code
set "__SCRIPT__=ExecuteGlobal(\""Set objProc = CreateObject(\""""WScript.Shell\"""").Environment(\""""Process\"""") : ::"^
::"::CreateObject(\""""Shell.Application\"""").ShellExecute objProc(\""""?0\""""), objProc(\""""?@\""""), \""""\"""", \""""runas\"""", 1 : Close()\"")"

set "__SCRIPT__=%__SCRIPT__:::"::"::=%"

rem command
set "?0="

(
  setlocal ENABLEDELAYEDEXPANSION

  if not "!PROCESSOR_ARCHITECTURE!" == "x86" (
    if not exist "!SystemRoot!\SysWOW64\*" (
      echo;!?~!: error: not x86 system or without SysWOW64 system directory.
      exit /b 255
    ) >&2

    if defined SystemRoot set "?0=!SystemRoot!\SysWOW64\cmd.exe"
  ) else if defined COMSPEC set "?0=!COMSPEC!"

  rem translate Windows Batch compatible escapes into escape placeholders
  set "__SCRIPT__=!__SCRIPT__:$=$0!"
  set "__SCRIPT__=!__SCRIPT__:\""""""=$3!"
  set "__SCRIPT__=!__SCRIPT__:\""""=$2!"
  set "__SCRIPT__=!__SCRIPT__:\""=$1!"
  set "__SCRIPT__=!__SCRIPT__:"^=$1!"

  set "?@=!?@:$=$0!"
  set "?@=!?@:\""""""=$3!"
  set "?@=!?@:\""""=$2!"
  set "?@=!?@:\""=$1!"
  set "?@=!?@:"^=$1!"

  rem translate escape placeholders into `mshta.exe` (vbs) escapes
  set "__SCRIPT__=!__SCRIPT__:$3=""""!"
  set "__SCRIPT__=!__SCRIPT__:$2=""!"
  set "__SCRIPT__=!__SCRIPT__:$1="!"
  set "__SCRIPT__=!__SCRIPT__:$0=$!"

  set "?@=!?@:$3=""""!"
  set "?@=!?@:$2=""!"
  set "?@=!?@:$1="!"
  set "?@=!?@:$0=$!"

  rem with locals drop
  for /F "tokens=* delims="eol^= %%i in ("!__SCRIPT__!") do break ^
  & for /F "usebackq tokens=* delims="eol^= %%j in ('"!?0!"') do break ^
  & for /F "usebackq tokens=* delims="eol^= %%k in ('"!?@!"') do endlocal & endlocal ^
  & set "?0=%%~j" & set "?@=%%~k" ^
  & start "" /B /WAIT "%SystemRoot%\System32\mshta.exe" vbscript:%%i
  exit /b
)

:ELEVATED
set ELEVATED=1

:IMPL
if %ELEVATED% EQU 0 call :IS_ADMIN_ELEVATED || (
  echo;%?~%: error: process must be elevated before continue.
  exit /b 255
) >&2

rem NOTE: recheck, just in case
if "%PROCESSOR_ARCHITECTURE%" == "x86" goto X86

if not exist "%SystemRoot%\SysWOW64\*" (
  echo;%?~%: error: not x86 system without SysWOW64 system directory.
  exit /b 255
) >&2

rem CAUTION: ShellExecute does not wait a child process close!
"%SystemRoot%\SysWOW64\cmd.exe" /c @"%~f0" %*
exit /b

:X86
echo;^>"%SystemRoot%\System32\cscript.exe" //nologo "%~dpn0.vbs" %*
"%SystemRoot%\System32\cscript.exe" //nologo "%~dpn0.vbs" %*
