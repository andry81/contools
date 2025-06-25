@echo off & for %%i in (%*) do set /A %%i+=0
exit /b

rem CAUTION:
rem   The `for %%i in (%*)` statement still can expand the globbing characters
rem   for the files in a current directory. You must avoid them.
