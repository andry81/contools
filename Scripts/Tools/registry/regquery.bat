@echo off & goto DOC_END

rem Description:
rem   Script reads and parses standard output of "reg.exe query" to variable
rem   REGQUERY_VALUE. Script setvarfromstd.bat ignores empty strings until not
rem   empty string appear. Utility findstr.exe searches target string by
rem   regular expression without case sensitivity.
rem   If key not empty and doesn't exist, then error level sets to 1.
rem   If value not empty and doesn't exist, then error level sets to 2.
rem   If value empty, then script reads default value. If it is not defined,
rem   then script returns 2, otherwise 0.
rem   If key and value not empty and found, then error level sets to 0.

rem Command arguments:
rem %1 - Registry key path.
rem %2 - Key variable name (case insensitive). If doesn't exist or empty, script
rem      reads default value of key.
rem %3 - Flags:
rem    -v - (Default) Reads key value and sets REGQUERY_VALUE variable.
rem    -t - Just tests key or value on existence.

rem Examples:
rem 1. call regquery.bat "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Command Processor" EnableExtensions
rem    echo REGQUERY_VALUE=%REGQUERY_VALUE%
:DOC_END

rem Drop REGQUERY_VALUE variable
set "REGQUERY_VALUE="

rem Drop last error level
call;

rem Create local variable's stack
setlocal

set "__REG_PATH=%~1"
set "__REG_VAR=%~2"

if not defined __REG_PATH exit /b 65

rem remove last slash, otherwise reg.exe will exit with error code
if "%__REG_PATH:~-1%" == "\" set "__REG_PATH=%__REG_PATH:~0,-1%"

rem duplicate last slash, otherwise reg.exe will exit with error code
if not defined __REG_VAR goto IGNORE_REG_VAR
if "%__REG_VAR:~-1%" == "\" set "__REG_VAR=%__REG_VAR%\"

:IGNORE_REG_VAR
rem test if key is exist
"%SystemRoot%\System32\reg.exe" query "%__REG_PATH%" /v "%__REG_VAR%" >nul 2>nul || exit /b 1

if "%~2" == "" if "%~3" == "-t" exit /b 0

rem call "%%~dp0__init__.bat" || exit /b

if defined __REG_VAR call :QUERY_KEY_ESCAPE
goto QUERY_KEY_ESCAPE_END

:QUERY_KEY_ESCAPE
rem remove lash slash duplication
set "__KEYVAR=%__REG_VAR%"
if "%__KEYVAR:~-1%" == "\" set "__KEYVAR=%__REG_VAR:~0,-1%"

rem call "%%CONTOOLS_ROOT%%/cstresc.bat" "%%__KEYVAR%%" "__KEYVAR" "*"
set "__KEYVAR=%__KEYVAR:\=\\%"
set "__KEYVAR=%__KEYVAR:.=\.%"
set "__KEYVAR=%__KEYVAR:^=\^%"
set "__KEYVAR=%__KEYVAR:$=\$%"
set "__KEYVAR=%__KEYVAR:[=\[%"
set "__KEYVAR=%__KEYVAR:]=\]%"

if /i "%__KEYVAR:~0,5%" == "HKLM\" set "__KEYVAR=HKEY_LOCAL_MACHINE\%__KEYVAR:~5%"
if /i "%__KEYVAR:~0,5%" == "HKCU\" set "__KEYVAR=HKEY_CURRENT_USER\%__KEYVAR:~5%"
if /i "%__KEYVAR:~0,5%" == "HKCR\" set "__KEYVAR=HKEY_CLASSES_ROOT\%__KEYVAR:~5%"
if /i "%__KEYVAR:~0,5%" == "HKU\" set "__KEYVAR=HKEY_USERS\%__KEYVAR:~5%"
if /i "%__KEYVAR:~0,5%" == "HKCC\" set "__KEYVAR=HKEY_CURRENT_CONFIG\%__KEYVAR:~5%"

exit /b 0

:QUERY_KEY_ESCAPE_END

rem count words in key name
set __KEYVAR_WORDS=1
for %%i in (%__REG_VAR%) do set /A __KEYVAR_WORDS+=1

rem Read reg.exe output.
rem BUG: Too long values would be empty!
for /F "usebackq tokens=* delims=" %%i in (`@"%%SystemRoot%%\System32\reg.exe" query "%%__REG_PATH%%" /v "%%__REG_VAR%%" ^| "%%SystemRoot%%\System32\findstr.exe" /I /R /C:"%%__KEYVAR%%[^a-zA-Z0-9\\/][^a-zA-Z0-9\\/]*REG_[A-Z][A-Z]*" 2^>nul`) do set "STDOUT_VALUE=%%i"

rem count words in name of empty value (language independent parse)
if not defined __REG_VAR call :EMPTY_KEYNAME_PARSE
goto EMPTY_KEYNAME_PARSE_END

:EMPTY_KEYNAME_PARSE
set __KEYVAR_WORDS=1
set "__KEYNAME_WORD="

:EMPTY_KEYNAME_PARSE_LOOP
for /F "tokens=%__KEYVAR_WORDS%" %%i in ("%STDOUT_VALUE%") do set "__KEYNAME_WORD=%%i"
if not defined __KEYNAME_WORD exit /b 0
if not "%__KEYNAME_WORD:REG_=%" == "%__KEYNAME_WORD%" exit /b 0

set /A __KEYVAR_WORDS+=1

goto EMPTY_KEYNAME_PARSE_LOOP

:EMPTY_KEYNAME_PARSE_END

for /F "tokens=%__KEYVAR_WORDS%,*" %%i in ("%STDOUT_VALUE%") do (
  set "REGQUERY_VALUE=%%j"
)

rem reg.exe in Windows 7 for default key value returns 0 if Default value was not set
if not defined __REG_VAR if defined REGQUERY_VALUE if "%REGQUERY_VALUE:~0,1%" == "(" if "%REGQUERY_VALUE:~-1%" == ")" exit /b 1

goto EXIT

:EXIT
rem Drop internal variables but use some changed value(s) for the return
endlocal & set "REGQUERY_VALUE=%REGQUERY_VALUE%"

exit /b 0
