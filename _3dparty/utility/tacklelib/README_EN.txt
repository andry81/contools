* README_EN.txt
* 2018.12.17
* tacklelib

1. DESCRIPTION
2. LICENSE
3. REPOSITORIES
4. PREREQUISITES
5. DEPENDECIES
5.1. Required library dependencies
5.2. Optional library dependencies
6. CONFIGURE
7. AUTHOR EMAIL

-------------------------------------------------------------------------------
1. DESCRIPTION
-------------------------------------------------------------------------------
The C++11 generic library which may respresents the same ideas as introduced in
Boost/STL/Loki C++ libraries and at first focused for extension of already
existed C++ code. Sources has been written under MSVC2015 Update 3 and
recompiled in GCC v5.4. As a backbone build system the cmake v3 is used.

The latest version is here: https://sf.net/p/tacklelib

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
  * https://svn.code.sf.net/p/tacklelib/tacklelib/trunk
First mirror:
  * https://github.com/andry81/tacklelib.git
Second mirror:
  * https://bitbucket.org/andry81/tacklelib.git

-------------------------------------------------------------------------------
4. PREREQUISITES
-------------------------------------------------------------------------------
1. C++11 compiler: MSVC 2015 update 3 or GCC v5.4
2. cmake list modules: https://svn.code.sf.net/p/tacklelib/cmake/trunk

-------------------------------------------------------------------------------
5. DEPENDECIES
-------------------------------------------------------------------------------

For more details, the `tacklelib--scripts` repository
(https://sf.net/p/tacklelib/scripts) contains the `envorinment_local.cmake.in`
template file which describes all variables required to set for user before
the build.

You must use scripts inside the `_scripts` directory and prepared
configuration files in the root to build the `tacklelib` project.
Otherwise you have to set at least all dependent variables on yourself before
call to the cmake.

-------------------------------------------------------------------------------
5.1. Required library dependencies
-------------------------------------------------------------------------------

# multipurpose

* boost
  original: https://www.boost.org

# utility

* fmt       (C++ string safe formatter)
  forked:   https://sf.net/p/tacklelib/3dparty--fmt
  original: https://github.com/fmtlib/fmt

-------------------------------------------------------------------------------
5.2. Optional library dependencies
-------------------------------------------------------------------------------

# utility

* pystring  (python C++ string functions)
  forked:   https://sf.net/p/tacklelib/3dparty--pystring
  original: https://github.com/imageworks/pystring

# logger

* p7 logger client
  forked:   https://sf.net/p/tacklelib/3dparty--p7client
  original: http://baical.net/p7.html

# test

* google test
  patched, not published
  original: https://github.com/abseil/googletest

# packer

* libarchive
  original: https://www.libarchive.org

* xz utils
  original: https://tukaani.org/xz/

-------------------------------------------------------------------------------
6. CONFIGURE
-------------------------------------------------------------------------------

To generate sources which are not included in version control call the
`_scripts/configure_src.bat` under Windows or
`_scripts/configure_src.sh` under Linux script.

-------------------------------------------------------------------------------
7. AUTHOR EMAIL
-------------------------------------------------------------------------------
Andrey Dibrov (andry at inbox dot ru)
