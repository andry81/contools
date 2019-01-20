* README_EN.txt
* 2019.01.20
* ConsoleTools

CAUTION:
  A new version of console utilities is always UNDER DEVELOPMENT,
  see the DESCRIPTION section.

1. DESCRIPTION
2. LICENSE
3. REPOSITORIES
4. PREREQUISITES
5. INSTALLATION
6. AUTHOR

-------------------------------------------------------------------------------
1. DESCRIPTION
-------------------------------------------------------------------------------
Scripts for WindowsNT interpreter cmd.exe and other interpreters to support
various operations and procedures with environment variables, text files and
piping.

The latest version is here: https://sf.net/p/contools

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
  * https://svn.code.sf.net/p/contools/contools/trunk
First mirror:
  * https://github.com/andry81/contools.git
Second mirror:
  * https://bitbucket.org/andry81/contools.git

-------------------------------------------------------------------------------
4. PREREQUISITES
-------------------------------------------------------------------------------
1. C++11 compiler: MSVC 2015 update 3 or GCC v5.4

-------------------------------------------------------------------------------
5. INSTALLATION
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
6. AUTHOR
-------------------------------------------------------------------------------
Andrey Dibrov (andry at inbox dot ru)
