@(call; 5>&4) 2>nul && exit /b 0 & "%SystemRoot%\System32\timeout.exe" /T 0 >nul 2>&1 && exit /b 255 & exit /b 0

rem Description:
rem   Script tests the standard input/output/error stream reopen.

rem Examples:
rem   1. >call is_std_reopen.bat && echo YES || echo NO
rem      NO
rem
rem   2. >call is_std_reopen.bat <nul && echo YES || echo NO
rem      YES
rem
rem   3. >call is_std_reopen.bat >nul && echo YES || echo NO
rem      YES
rem
rem   4. >call is_std_reopen.bat 2>nul && echo YES || echo NO
rem      YES
rem
rem   5. >echo; | call is_std_reopen.bat && echo YES || echo NO
rem      YES
rem
rem   6. >( call is_std_reopen.bat && echo YES || echo NO ) <nul
rem      YES
rem
rem   7. >( call is_std_reopen.bat && echo YES >&2 || echo NO >&2 ) >nul
rem      YES
rem
rem   8. >( call is_std_reopen.bat && echo YES || echo NO ) 2>nul
rem      YES
rem
rem   9. >echo; | ( call is_std_reopen.bat && echo YES || echo NO )
rem      YES
rem
rem  10. >cmd.exe /c call is_std_reopen.bat ^&^& echo YES ^|^| echo NO
rem      NO
rem
rem  11. >cmd.exe /c call is_std_reopen.bat ^&^& echo YES ^|^| echo NO <nul
rem      YES
rem
rem  These does not work:
rem
rem   1. >cmd.exe /c call is_std_reopen.bat ^&^& echo YES ^>^&2 ^|^| echo NO ^>^&2 >nul
rem      NO
rem
rem   2. >cmd.exe /c call is_std_reopen.bat ^&^& echo YES ^|^| echo NO 2>nul
rem      NO
rem
rem  These does work:
rem
rem   1. >cmd.exe /c call is_std_reopen.bat ^>nul ^&^& echo YES ^|^| echo NO
rem      YES
rem
rem   2. >cmd.exe /c call is_std_reopen.bat 2^>nul^&^& echo YES ^|^| echo NO
rem      YES
