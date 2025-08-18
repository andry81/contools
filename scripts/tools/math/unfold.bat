@echo off & setlocal ENABLEDELAYEDEXPANSION & set "R=" & ^
for /F "tokens=1,2,3,4,5,6,* delims=,.:;" %%a in ("!%~2!") do ^
set "L1=%%a" & set "L2=%%b" & set "L3=%%c" & set "L4=%%d" & set "L5=%%e" & set "L6=%%f" & set "F=%%g" ^
  & ( if defined L1 if "!L1:~0,1!" == "0" set "L1=!L1:~1!" ) & ( if defined L1 if "!L1:~0,1!" == "0" set "L1=!L1:~1!" ) ^
  & ( if defined L2 if "!L2:~0,1!" == "0" set "L2=!L2:~1!" ) & ( if defined L1 if "!L2:~0,1!" == "0" set "L2=!L2:~1!" ) ^
  & ( if defined L3 if "!L3:~0,1!" == "0" set "L3=!L3:~1!" ) & ( if defined L1 if "!L3:~0,1!" == "0" set "L3=!L3:~1!" ) ^
  & ( if defined L4 if "!L4:~0,1!" == "0" set "L4=!L4:~1!" ) & ( if defined L1 if "!L4:~0,1!" == "0" set "L4=!L4:~1!" ) ^
  & ( if defined L5 if "!L5:~0,1!" == "0" set "L5=!L5:~1!" ) & ( if defined L1 if "!L5:~0,1!" == "0" set "L5=!L5:~1!" ) ^
  & ( if defined L6 if "!L6:~0,1!" == "0" set "L6=!L6:~1!" ) & ( if defined L1 if "!L6:~0,1!" == "0" set "L6=!L6:~1!" ) ^
  & ( if defined F if not "!F:,=!" == "!F!" call "%%~0" F F || call set /A "L6+=%%ERRORLEVEL%%" ) & ^
set /A "L5+=L6/1000" & set /A "L4+=L5/1000" & set /A "L3+=L4/1000" & set /A "L2+=L3/1000" & set /A "L1+=L2/1000" & set /A "F=L1/1000" & ^
set /A "L6%%=1000" & set /A "L5%%=1000" & set /A "L4%%=1000" & set /A "L3%%=1000" & set /A "L2%%=1000" & set /A "L1%%=1000" ^
  & ( if "%%b" == "" set "L2=!L1!" & set /A "L1=F %% 1000" & set /A "F/=1000" ) ^
  & ( if "%%c" == "" set "L3=!L2!" & set "L2=!L1!" & set /A "L1=F %% 1000" & set /A "F/=1000" ) ^
  & ( if "%%d" == "" set "L4=!L3!" & set "L3=!L2!" & set "L2=!L1!" & set /A "L1=F %% 1000" & set /A "F/=1000" ) ^
  & ( if "%%e" == "" set "L5=!L4!" & set "L4=!L3!" & set "L3=!L2!" & set "L2=!L1!" & set /A "L1=F %% 1000" & set /A "F/=1000" ) ^
  & ( if "%%f" == "" set "L6=!L5!" & set "L5=!L4!" & set "L4=!L3!" & set "L3=!L2!" & set "L2=!L1!" & set /A "L1=F %% 1000" & set /A "F/=1000" ) ^
  & ( if !L1! NEQ 0 set "R=!L1!" ) ^
  & ( if not "!R!" == "" ( ( if "!L2:~2,1!" == "" set "L2=0!L2!" ) & ( if "!L2:~2,1!" == "" set "L2=0!L2!" ) ) ) ^
  & ( if !L2! NEQ 0 ( set "R=!R!!L2!" ) else if not "!R!" == "" set "R=!R!000" ) ^
  & ( if not "!R!" == "" ( ( if "!L3:~2,1!" == "" set "L3=0!L3!" ) & ( if "!L3:~2,1!" == "" set "L3=0!L3!" ) ) ) ^
  & ( if !L3! NEQ 0 ( set "R=!R!!L3!" ) else if not "!R!" == "" set "R=!R!000" ) ^
  & ( if not "!R!" == "" ( ( if "!L4:~2,1!" == "" set "L4=0!L4!" ) & ( if "!L4:~2,1!" == "" set "L4=0!L4!" ) ) ) ^
  & ( if !L4! NEQ 0 ( set "R=!R!!L4!" ) else if not "!R!" == "" set "R=!R!000" ) ^
  & ( if not "!R!" == "" ( ( if "!L5:~2,1!" == "" set "L5=0!L5!" ) & ( if "!L5:~2,1!" == "" set "L5=0!L5!" ) ) ) ^
  & ( if !L5! NEQ 0 ( set "R=!R!!L5!" ) else if not "!R!" == "" set "R=!R!000" ) ^
  & ( if not "!R!" == "" ( ( if "!L6:~2,1!" == "" set "L6=0!L6!" ) & ( if "!L6:~2,1!" == "" set "L6=0!L6!" ) ) ) ^
  & ( if !L6! NEQ 0 ( set "R=!R!!L6!" ) else if not "!R!" == "" set "R=!R!000" )
for /F "tokens=* delims=" %%a in ("!R!") do endlocal & set "%~1=%%a" & exit /b %F%
endlocal & set "%~1=0" & if not "%~2" == "" if defined %~2 exit /b %F%
exit /b -1

rem USAGE:
rem   unfold.bat <out-var> <var>

rem Description:
rem   Unsigned integer series unfold script.
rem   Positive exit code indicates an overflow.
rem   Negative exit code indicates invalid input.

rem <var>:
rem   Integer series of numbers in the format:
rem     NNN[,NNN[,NNN[,NNN[,NNN[,NNN]]]]]
rem     , where NNN must not begin by 0 except `0`

rem <out-var>:
rem   String value of unfolded <var>.

rem Examples:
rem   1. >
rem      set a=0,1,2,3
rem      unfold.bat b a
rem      rem b=1002003
rem   2. >
rem      set a=1,2,3,4,5,6,4567,1,2,3,4,5
rem      unfold.bat b a
rem      rem b=1002003004005010