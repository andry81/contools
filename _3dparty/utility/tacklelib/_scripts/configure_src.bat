@echo off

rem Not version control source files generator.

setlocal

call "%%~dp0__init__.bat" || goto :EOF

set /A NEST_LVL+=1
set LASTERROR=0

set "CONFIGURE_ROOT=%PROJECT_ROOT%"
if not defined CONFIGURE_ROOT (
  set LASTERROR=1
  goto EXIT
)

echo."%CONFIGURE_ROOT%/include/tacklelib/setup.hpp.in" -^> "%CONFIGURE_ROOT%/include/tacklelib/setup.hpp"
(
  type "%CONFIGURE_ROOT:/=\%\include\tacklelib\setup.hpp.in"
) > "%CONFIGURE_ROOT%/include/tacklelib/setup.hpp"

echo."%CONFIGURE_ROOT%/include/tacklelib/debug.hpp.in" -^> "%CONFIGURE_ROOT%/include/tacklelib/debug.hpp"
(
  type "%CONFIGURE_ROOT:/=\%\include\tacklelib\debug.hpp.in"
) > "%CONFIGURE_ROOT%/include/tacklelib/debug.hpp"

echo."%CONFIGURE_ROOT%/include/tacklelib/optimization.hpp.in" -^> "%CONFIGURE_ROOT%/include/tacklelib/optimization.hpp"
(
  type "%CONFIGURE_ROOT:/=\%\include\tacklelib\optimization.hpp.in"
) > "%CONFIGURE_ROOT%/include/tacklelib/optimization.hpp"

echo."%CONFIGURE_ROOT%/src/setup.hpp.in" -^> "%CONFIGURE_ROOT%/src/setup.hpp"
(
  type "%CONFIGURE_ROOT:/=\%\src\setup.hpp.in"
) > "%CONFIGURE_ROOT%/src/setup.hpp"

echo."%CONFIGURE_ROOT%/src/debug.hpp.in" -^> "%CONFIGURE_ROOT%/src/debug.hpp"
(
  type "%CONFIGURE_ROOT:/=\%\src\debug.hpp.in"
) > "%CONFIGURE_ROOT%/src/debug.hpp"

echo."%CONFIGURE_ROOT%/src/optimization.hpp.in" -^> "%CONFIGURE_ROOT%/src/optimization.hpp"
(
  type "%CONFIGURE_ROOT:/=\%\src\optimization.hpp.in"
) > "%CONFIGURE_ROOT%/src/optimization.hpp"

:EXIT
set /A NEST_LVL-=1

if %NEST_LVL% EQU 0 pause

exit /b %LASTERROR%
