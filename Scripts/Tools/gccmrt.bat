@echo off

rem ***************************************************************
rem Batch file to change GCC runtime library
rem Coded by Giovanni Bajo <rasky@develer.com>
rem Modified by Andrey Dibrov <andry@inbox.ru>
rem Public domain
rem ***************************************************************

rem Description:
rem   Scripts renames runtime library "libmsvcrt*.lib" files in the POSIX /lib
rem   directory to the variant w/o suffix to make them default for the GCC
rem   compiler linker.

setlocal
set "__GCC_LIB_DIR=%~dp0..\lib"
set "__GCC_MSVCRT_VER=%~1"

if not exist "%__GCC_LIB_DIR%\libmsvcrt.a" goto errorpath
if "%__GCC_MSVCRT_VER%" == "60" goto doit
if "%__GCC_MSVCRT_VER%" == "70" goto doit
if "%__GCC_MSVCRT_VER%" == "71" goto doit
if "%__GCC_MSVCRT_VER%" == "80" goto doit
goto usage

:doit
copy "%__GCC_LIB_DIR%\libmsvcr%__GCC_MSVCRT_VER%.a" "%__GCC_LIB_DIR%\libmsvcrt.a" >nul 2>nul
copy "%__GCC_LIB_DIR%\libmsvcr%__GCC_MSVCRT_VER%d.a" "%__GCC_LIB_DIR%\libmsvcrtd.a" >nul 2>nul
echo %~n0: set GCC to link executables by default with libmsvc%__GCC_MSVCRT_VER%*.a dynamic libraries.
exit /b

:usage
echo %~n0: configure the Microsoft runtime library to use for compilation
echo.
echo Usage: %~n0 ^<60^|70^|71^|80^>
echo.
echo   60 - Link with MSVCRT.DLL (like Visual Studio '98 aka VC6)
echo   70 - Link with MSVCR70.DLL (like Visual Studio .NET aka VC70)
echo   71 - Link with MSVCR71.DLL (like Visual Studio .NET 2003 aka VC71)
echo   80 - Link with MSVCR80.DLL (like Visual Studio .NET 2005 aka VC80)
exit /b

:errorpath
echo %~n0: Internal error while trying to find Mingw libraries directory.
exit /b
