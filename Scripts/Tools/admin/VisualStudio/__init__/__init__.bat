@echo off

call "%%~dp0canonical_path.bat" VS_SETUP_ROOT                                   "%%~dp0.."

call "%%~dp0canonical_path.bat" VS_CACHE_DIR                                    "%%VS_SETUP_ROOT%%\..\vscache"

call "%%~dp0canonical_path.bat" VS_BOOTSTRAPPERS_CACHE_DIR                      "%%VS_CACHE_DIR%%\bootstrappers"

rem can be on a network drive
call "%%~dp0canonical_path.bat" VS_LAYOUT_CACHE_ROOT                            "%%VS_CACHE_DIR%%\layout"

rem deprecated
rem call "%%~dp0canonical_path.bat" VS_DOWNLOAD_SHARED_ROOT                         "%%VS_CACHE_DIR%%\download"

rem must be on a local drive only
call "%%~dp0canonical_path.bat" VS_PACKAGES_CACHE_ROOT                          "%%VS_CACHE_DIR%%\packages"

set "VS_BOOTSTRAPPER_EXE=vs_Professional_15_9_28307_2094.exe"

set "VS_COMMON_CMDLINE=--add Microsoft.VisualStudio.Workload.NativeDesktop --includeRecommended"
