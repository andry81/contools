@if "%~1" == "" exit /b %ERRORLEVEL%
@exit /b %~1

rem USAGE: errlvl.bat [<exit-code>]

rem Description:
rem   Script returns error level passed as first argument. If first argument is
rem   empty, then returns previous error level.

rem Examples:
rem   1. >call errlvl.bat 10
rem      >echo ERRORLEVEL=%ERRORLEVEL%
rem      ERRORLEVEL=10

rem CAUTION:
rem   The `exit /b %ERRORLEVEL%` is required as is to workaround the issue with
rem   not zero error code return:
rem
rem   ```1.bat
rem   @echo off
rem   
rem   setlocal
rem   
rem   call :TEST || exit /b
rem   exit /b 0
rem   
rem   :TEST
rem   exit /b 123
rem   ```
rem
rem   where:
rem
rem     >
rem     cmd.exe /c 1.bat
rem
rem     will always return 0
rem
rem   To workaround this:
rem
rem     >
rem     cmd.exe /c call 1.bat
rem
rem     Or
rem
rem     >
rem     cmd.exe /c "1.bat & call exit /b %%ERRORLEVEL%%"
rem
rem     Or
rem
rem     >
rem     cmd.exe /c "1.bat & "%%CONTOOLS_ROOT%%/std/errlvl.bat""
rem
rem     Or
rem
rem     NOTE: The `1.bat` is not quoted here, because `cmd.exe` will remove first and last quotes after the `/c`.
rem     >
rem     "%CONTOOLS_UTILS_BIN_ROOT%/contools/callf.exe" /ret-child-exit "" "cmd.exe /c 1.bat & \"${CONTOOLS_ROOT}/std/errlvl.bat\""
rem
rem     Or
rem
rem     >
rem     "%CONTOOLS_UTILS_BIN_ROOT%/contools/callf.exe" /ret-child-exit "" "cmd.exe /c \"1.bat ^& \"${CONTOOLS_ROOT}/std/errlvl.bat\"\""
rem
rem     Or
rem
rem     >
rem     "%CONTOOLS_UTILS_BIN_ROOT%/contools/callf.exe" /ret-child-exit "" "cmd.exe \"/c \"1.bat ^& \"${CONTOOLS_ROOT}/std/errlvl.bat\"\"\""
rem
rem     Or
rem
rem     NOTE: The best variant, with multiple issues workaround.
rem
rem     Pros:
rem       1. The `call` prefix is not used, so there is no the double expansion issue (see below).
rem       2. The `@` prefix prevents the `cmd.exe` to strip the quotes from the begin and the end of a command line.
rem       3. Special control character `&` does not need to be quoted or escaped.
rem
rem     Cons:
rem       1. The part of a command line after the `cmd.exe` still does expand by the `cmd.exe` itself.
rem          To bypass that you can use additional `callf` options: `/ra "%%" "%%?25%%" /v "?25" "%%"`
rem       2. To disable the rest `callf` features: `/no-subst-pos-vars /no-esc`
rem
rem     >
rem     "%CONTOOLS_UTILS_BIN_ROOT%/contools/callf.exe" /ret-child-exit /no-subst-pos-vars /no-esc "" "cmd.exe /c @\"1.bat\" & \"${CONTOOLS_ROOT}/std/errlvl.bat\"\""

rem CAUTION:
rem   The `call` operator will expand environment variables twice:
rem
rem   >
rem   callf /v B x /v A %B% /ret-child-exit "" "cmd.exe /c call echo %A%"
rem 
rem   Prints `x` instead of `%B%`.
rem
rem   So to bypass this you must use variants without the `call` prefix before
rem   the `1.bat`.
