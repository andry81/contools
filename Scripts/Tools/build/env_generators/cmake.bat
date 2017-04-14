@echo off

rem cmake generator select
set "CMAKE_GENERATOR_TOOLSET="
if "%DEV_COMPILER%" == "vc10" set "CMAKE_GENERATOR_TOOLSET=Visual Studio 10 2010"
if "%DEV_COMPILER%" == "vc12" set "CMAKE_GENERATOR_TOOLSET=Visual Studio 12 2013"
if "%DEV_COMPILER%" == "vc14" set "CMAKE_GENERATOR_TOOLSET=Visual Studio 14 2015"

if not "%CMAKE_GENERATOR_TOOLSET%" == "" ^
if "%DEV_ADDRESS_MODEL%" == "64" set "CMAKE_GENERATOR_TOOLSET=%CMAKE_GENERATOR_TOOLSET% Win64"
