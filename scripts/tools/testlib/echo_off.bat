@echo off & (PROMPT=%TESTLIB__PREV_PROMPT%) & set "TESTLIB__PREV_PROMPT=" & %*
@exit /b

rem Description:
rem   Calls `echo off` with previous prompt restore and a command call at the
rem   end.
