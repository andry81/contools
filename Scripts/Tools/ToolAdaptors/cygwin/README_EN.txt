* README_EN.txt
* 2021.08.14
* contools--tool_adaptors--cygwin

1. DESCRIPTION
2. SCRIPTS
2.1. cygsetupdiff.sh
2.2. cygsetuplib.sh
2.3. cygsetupprint.sh
3. AUTHOR

-------------------------------------------------------------------------------
1. DESCRIPTION
-------------------------------------------------------------------------------
Set of scripts to maintain cygwin installation.

-------------------------------------------------------------------------------
2. SCRIPTS
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
2.1. cygsetupdiff.sh
-------------------------------------------------------------------------------

Script reads the first cygwin setup.ini file and extracts all requested
packages including it's dependencies. Then reads the second cygwin setup.ini
file and findout which found depencies is not found in that file. Then after
that it prints all packages not found in the second file but found in the
first.

-------------------------------------------------------------------------------
2.2. cygsetuplib.sh
-------------------------------------------------------------------------------

Script library to support operations with the cygwin setup.ini file.

-------------------------------------------------------------------------------
2.3. cygsetupprint.sh
-------------------------------------------------------------------------------

Script prints fields of found packages in the cygwin setup.ini file.

-------------------------------------------------------------------------------
3. AUTHOR
-------------------------------------------------------------------------------
Andrey Dibrov (andry at inbox dot ru)
