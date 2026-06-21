@set "TESTLIB__PREV_PROMPT=%PROMPT%" & (PROMPT=$H) & echo on & %*
@exit /b

rem Description:
rem   Calls `echo on` with empty prompt and a command call at the end.
rem   Previous prompt is saved in `TESTLIB__PREV_PROMPT` variable.
rem   To reset the prompt use either `setlocal` before the call and `endlocal`
rem   after, or `echo_off.bat` script.
rem
rem   Enables to echo a test commands out to the console as is until the
rem   `echo_off.bat` script (with the `@` prefix before the `call` if required)
rem   is called.
