@echo off

rem FILE OUTPUT EXAMPLE:
rem  !define PRODUCT_<TokenValue>0_NAME "app1.xxx"
rem  !define PRODUCT_<TokenValue>1_NAME "app2.yyy"
rem  !define PRODUCT_<TokenValue>S_NUM 2
rem  !define PRODUCT_<TokenValue>S_PP_COMMAND0 "!insertmacro PRODUCT_<TokenValue>S_PP_COMMAND0"
rem  !macro PRODUCT_<TokenValue>S_PP_COMMAND0
rem  ${SETUP_PP_COMMAND_PROLOG}
rem  ${SETUP_PP_COMMAND_PRED} 0
rem  ${SETUP_PP_COMMAND_PRED} 1
rem  ${SETUP_PP_COMMAND_EPILOG}
rem  !macroend

setlocal

if "%TOOLS_PATH%" == "" set "TOOLS_PATH=%~dp0.."
set "TOOLS_PATH=%TOOLS_PATH:\=/%"
if "%TOOLS_PATH:~-1%" == "/" set "TOOLS_PATH=%TOOLS_PATH:~0,-1%"

set "?~nx0=%~nx0"

rem drop last error level
cd .

rem get code page value from first parameter
set "LAST_CODE_PAGE="
set CODE_PAGE=%~1

shift

if "%CODE_PAGE%" == "" goto NOCODEPAGE

for /F "usebackq eol= tokens=1,* delims=:" %%i in (`chcp 2^>nul`) do set LAST_CODE_PAGE=%%j
set LAST_CODE_PAGE=%LAST_CODE_PAGE: =%

if not "%LAST_CODE_PAGE%" == "%CODE_PAGE%" chcp %CODE_PAGE% >nul

:NOCODEPAGE
set "TOKEN_VALUE=%~1"
set "FILE_EXT_LIST=%~2"
set "FILE_PATH_LIST_FILE=%~3"

if "%TOKEN_VALUE%" == "" (
  echo.%?~nx0%: error: token value is not set: "%TOKEN_VALUE%"
  exit /b 1
) >&2
if "%FILE_EXT_LIST%" == "" (
  echo.%?~nx0%: error: file extensions list is not set: "%FILE_EXT_LIST%"
  exit /b 2
) >&2

rem build findstr commandline from FILE_MASKS
set "FINDSTR_CMD_LINE=/I /E "

call :PROCESS_FILE_EXT_LIST
goto PROCESS_FILE_EXT_LIST_END

:PROCESS_FILE_EXT_LIST
set FILE_EXT_INDEX=1

:PROCESS_FILE_EXT_LIST_LOOP
set "FILE_EXT="
for /F "eol= tokens=%FILE_EXT_INDEX% delims=|" %%i in ("%FILE_EXT_LIST%") do set "FILE_EXT=%%i"
if "%FILE_EXT%" == "" goto :EOF

set FINDSTR_CMD_LINE=%FINDSTR_CMD_LINE% /C:"%FILE_EXT%"

set /A FILE_EXT_INDEX+=1

goto PROCESS_FILE_EXT_LIST_LOOP

:PROCESS_FILE_EXT_LIST_END

set FILE_INDEX=0
set "LAST_FILE_PATH="

for /F "usebackq eol= tokens=* delims=" %%i in (`@"%TOOLS_PATH%/gnuwin32/bin/sed.exe" "s/\(.*\)/\1\\/" "%FILE_PATH_LIST_FILE%" ^| sort ^| "%TOOLS_PATH%/gnuwin32/bin/sed.exe" "s/\(.*\).$/\1/" ^| findstr %FINDSTR_CMD_LINE%`) do (
  set "FILE_PATH=%%i"
  call :PROCESS_FILE_PATH || goto :EOF
)

set NUM_FILES=%FILE_INDEX%
echo.!define PRODUCT_%TOKEN_VALUE%S_NUM %NUM_FILES%

rem Generate compile time command as definition
set FILE_INDEX=0
echo.!define PRODUCT_%TOKEN_VALUE%S_PP_COMMAND0 "!insertmacro PRODUCT_%TOKEN_VALUE%S_PP_COMMAND0"
echo.!macro PRODUCT_%TOKEN_VALUE%S_PP_COMMAND0

if %NUM_FILES% GTR 0 echo.${SETUP_PP_COMMAND_PROLOG}
if %NUM_FILES% LEQ 0 goto REPEAT_PP_COMMAND_LOOP_END

:REPEAT_PP_COMMAND_LOOP
echo.${SETUP_PP_COMMAND_PRED} %FILE_INDEX%
set /A FILE_INDEX+=1
if %FILE_INDEX% LSS %NUM_FILES% goto REPEAT_PP_COMMAND_LOOP

:REPEAT_PP_COMMAND_LOOP_END

if %NUM_FILES% GTR 0 echo.${SETUP_PP_COMMAND_EPILOG}
echo.!macroend

if not "%LAST_CODE_PAGE%" == "%CODE_PAGE%" chcp %LAST_CODE_PAGE% >nul

goto :EOF

:PROCESS_FILE_PATH
rem ignore duplications
if "%LAST_FILE_PATH%" == "%FILE_PATH%" goto :EOF

echo.!define PRODUCT_%TOKEN_VALUE%%FILE_INDEX%_NAME "%FILE_PATH%"

set /A FILE_INDEX+=1

set "LAST_FILE_PATH=%FILE_PATH%"

exit /b 0
