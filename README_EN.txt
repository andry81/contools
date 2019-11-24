* README_EN.txt
* 2019.11.24
* ConsoleTools

CAUTION:
  A new version of console utilities is always UNDER DEVELOPMENT,
  see the DESCRIPTION section.

1. DESCRIPTION
2. LICENSE
3. REPOSITORIES
4. PREREQUISITES
5. DEPENDENCIES
6. INSTALLATION
7. AUTHOR

-------------------------------------------------------------------------------
1. DESCRIPTION
-------------------------------------------------------------------------------
A wide range of scripts for Windows NT interpreter (cmd.exe) and other
interpreters such as bash shell (.sh), visual basic (.vbs), jscript (.js),
python (.py), perl (.pl) and so on. Plus some set of standalone console
utilities aside other utilities from cygwin, msys and mingw.

The latest version is here:
  https://sf.net/p/contools/contools/HEAD/tree/trunk

WARNING:
  Use the SVN access to find out new functionality and bug fixes.
  See the REPOSITORIES section.

-------------------------------------------------------------------------------
2. LICENSE
-------------------------------------------------------------------------------
The MIT license (see included text file "license.txt" or
https://en.wikipedia.org/wiki/MIT_License)

-------------------------------------------------------------------------------
3. REPOSITORIES
-------------------------------------------------------------------------------
Primary:
  * https://sf.net/p/contools/contools/HEAD/tree/trunk/
    https://svn.code.sf.net/p/contools/contools/trunk
First mirror:
  * https://github.com/andry81/contools/tree/trunk
    https://github.com/andry81/contools.git
Second mirror:
  * https://bitbucket.org/andry81/contools/src/trunk
    https://bitbucket.org/andry81/contools.git

-------------------------------------------------------------------------------
4. PREREQUISITES
-------------------------------------------------------------------------------

Currently tested these set of OS platforms, compilers, IDE's and interpreters
to run from:

1. OS platforms.

* Windows 7 (`.bat` only, minimal version for the cmake 3.14)
* Cygwin 1.7.x (`.sh` only)

2. C++11 compilers.

* (primary) Microsoft Visual C++ 2015 Update 3
* (secondary) GCC 5.4+
* (experimental) Clang 3.8+

3. IDE's.

* Microsoft Visual Studio 2015 Update 3
* Microsoft Visual Studio 2017
* QtCreator 4.6+

4. Interpreters:

* bash shell 3.2.48+ (to run unix shell scripts)
* cmake 3.14+ :
  https://cmake.org/download/

Noticeable cmake changes from the version 3.14:

https://cmake.org/cmake/help/v3.14/release/3.14.html#deprecated-and-removed-features

* The FindQt module is no longer used by the find_package() command as a find
  module. This allows the Qt Project upstream to optionally provide its own
  QtConfig.cmake package configuration file and have applications use it via
  find_package(Qt) rather than find_package(Qt CONFIG). See policy CMP0084.

* Support for running CMake on Windows XP and Windows Vista has been dropped.
  The precompiled Windows binaries provided on cmake.org now require Windows 7
  or higher.

-------------------------------------------------------------------------------
5. DEPENDENCIES
-------------------------------------------------------------------------------

Read the `README_EN.deps.txt` file for the common dependencies for the Windows
and the Linux platforms.

-------------------------------------------------------------------------------
6. INSTALLATION
-------------------------------------------------------------------------------
run configure.bat

Windows executable utilities can be built if necessary under Microsoft Visual
Studio C++ 2015 Community Edition. The utilities does not require an installed
Microsoft Visual C++ 2015 Redistributables at runtime.

To build GUI utilities is required the wxWidgets library at least of version
3.1.x.

You have to download and copy the library sources manually into:

* wxWidgets:  `/_3dparty/gui/wxWidgets`

-------------------------------------------------------------------------------
7. AUTHOR
-------------------------------------------------------------------------------
Andrey Dibrov (andry at inbox dot ru)
