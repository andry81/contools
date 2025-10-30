@"%SystemRoot%\System32\timeout.exe" /T 0 >nul 2>&1 && exit /b 255 & exit /b 0

rem Description:
rem   Script tests the standard input stream reopen.

rem Examples:
rem   1. >call is_stdin_reopen.bat && echo YES || echo NO
rem      NO
rem
rem   2. call is_stdin_reopen.bat <nul && echo YES || echo NO
rem      YES
rem
rem   3. echo; | is_stdin_reopen.bat && echo YES || echo NO
rem      YES
rem
rem   4. ( is_stdin_reopen.bat && echo YES || echo NO ) <nul
rem      YES
rem
rem   5. echo; | ( is_stdin_reopen.bat && echo YES || echo NO )
rem      YES
rem
rem   6. cmd.exe /c call is_stdin_reopen.bat ^&^& echo YES ^|^| echo NO
rem      NO
rem
rem   7. cmd.exe /c call is_stdin_reopen.bat ^&^& echo YES ^|^| echo NO <nul
rem      YES
