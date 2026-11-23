@echo off

setlocal DISABLEDELAYEDEXPANSION

set "CLEANUP_FILE=%~1"

rem CAUTION:
rem   The `sed` does reformat the line returns.
rem

rem * replace all custom tokens:
rem    - ppk_XXXXXXXXXXXXXXXX (password private key)
rem * replace all GitHub tokens:
rem    - ghs_XXX...~520...XXX (https://github.blog/changelog/2026-05-15-github-app-installation-tokens-per-request-override-header/)
rem    - ghp_XXXXXXXXXXXXXXXX
rem * replace all GitHub tokens:
rem    - github_pat_XXXXXXXXXXXXXXXXXXXXXX_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
rem * replace environment variable values:
rem    - `PROJECTS_ROOT` -> `%PROJECTS_ROOT%`

setlocal ENABLEDELAYEDEXPANSION

rem encode
set "PROJECTS_ROOT_ESCAPED=!PROJECTS_ROOT:$=$24!"

for %%i in ({:7B }:7D [:5B ]:5D (:28 ^):29 ^^:5E .:2E +:2B ^&:26) do ^
for /F "tokens=1,* delims=:"eol^= %%j in ("%%i") do set "PROJECTS_ROOT_ESCAPED=!PROJECTS_ROOT_ESCAPED:%%j=$5C$%%k!"

set "PROJECTS_ROOT_ESCAPED=!PROJECTS_ROOT_ESCAPED:/=[\/\\]!"
set "PROJECTS_ROOT_ESCAPED=!PROJECTS_ROOT_ESCAPED:\=[\/\\]!"

rem decode
for %%i in ({:7B }:7D [:5B ]:5D (:28 ^):29 ^^:5E .:2E +:2B ^&:26 $:24) do ^
for /F "tokens=1,* delims=:"eol^= %%j in ("%%i") do set "PROJECTS_ROOT_ESCAPED=!PROJECTS_ROOT_ESCAPED:$%%k=\%%j!"

"!CONTOOLS_MSYS2_USR_ROOT!/bin/sed.exe" -E -i -b ^
  "s/ppk_[0-9a-zA-Z]{16,}/ppk_*/g; s/ghs_[A-Za-z0-9\._]{36,}/ghs_*/g; s/ghp_[A-Za-z0-9]{16,}/ghp_*/g; s/github_pat_[A-Za-z0-9]{22,}_[A-Za-z0-9]{71,}/github_pat_*/g; s/!PROJECTS_ROOT_ESCAPED!/%%PROJECTS_ROOT%%/g" ^
  "!CLEANUP_FILE!"
