@echo off & setlocal DISABLEDELAYEDEXPANSION & set "?.=%~2~" & setlocal ENABLEDELAYEDEXPANSION & ( if "!?.:~%~1!" == "" exit /b 0 ) & exit /b 255

rem USAGE:
rem   is_str_shorter_than.bat <len> <str>

rem Description:
rem   Checks <str> on length shorter than <len>.

rem NOTE:
rem   `copy /B "<from>" "..."` fails to copy exactly 259 characters long
rem   of <from> absolute path and does not print an error message, but does
rem   print an error for paths longer than 259.
rem   Note that the error code is not zero for paths longer than 258
rem   characters.
rem   To workaround use `is_str_shorter_than.bat 259 <abs-path>`.
