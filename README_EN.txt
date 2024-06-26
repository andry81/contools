* README_EN.txt
* 2024.06.08
* contools

1. DESCRIPTION
2. LICENSE
3. REPOSITORIES
4. CATALOG CONTENT DESCRIPTION
5. PREREQUISITES
6. DEPENDENCIES
7. EXTERNALS
8. DEPLOY
9. TESTS
10. AUTHOR

-------------------------------------------------------------------------------
1. DESCRIPTION
-------------------------------------------------------------------------------
A wide range of scripts for Windows interpreter (cmd.exe) and other
interpreters such as bash shell (.sh), visual basic (.vbs), jscript (.js),
python (.py), perl (.pl) and so on. Plus some set of standalone console
utilities and tools aside other utilities and tools from cygwin, msys and
mingw.

The rest is extracted into standalone repositories beginning by `contools--`.

To search on the GitHub:

  https://github.com/andry81?tab=repositories&q=contools

-------------------------------------------------------------------------------
2. LICENSE
-------------------------------------------------------------------------------
The MIT license (see included text file "license.txt" or
https://en.wikipedia.org/wiki/MIT_License)

-------------------------------------------------------------------------------
3. REPOSITORIES
-------------------------------------------------------------------------------
Primary:
  * https://github.com/andry81/contools/branches
    https://github.com/andry81/contools.git
First mirror:
  * https://sf.net/p/contools/contools/ci/master/tree
    https://git.code.sf.net/p/contools/contools
Second mirror:
  * https://gitlab.com/andry81/contools/-/branches
    https://gitlab.com/andry81/contools.git

-------------------------------------------------------------------------------
4. CATALOG CONTENT DESCRIPTION
-------------------------------------------------------------------------------

<root>
 |
 +- /`.log`
 |    #
 |    # Log files directory, where does store all log files from all scripts
 |    # including all nested projects.
 |
 +- /`_externals`
 |    #
 |    # Immediate external projects catalog which could not be moved into the
 |    # 3dparty dependencies catalog.
 |
 +- /`_config`
 |  | #
 |  | # Directory with build input configuration files.
 |  |
 |  +- `config.system.vars.in`
 |  |   #
 |  |   # Template file with system set of environment variables
 |  |   # designed to be stored in a version control system.
 |  |
 |  +- `config.0.vars.in`
 |      #
 |      # Template file with user set of environment variables
 |      # designed to be stored in a version control system.
 |
 +- /`Projects`
 |    #
 |    # Project files to build contools utilities.
 |
 +- /`Output`
 |    #
 |    # Temporary directory with build output.
 |
 +- /`Scripts`
 |    #
 |    # The root for all scripts and tools excluding external or standalone.
 |
 +- /`Utilities`
    | #
    | # Internal and external utilities and tools.
    |
    +- /`bin/contools`
         #
         # Internal utilities and tools built by the project.

-------------------------------------------------------------------------------
5. PREREQUISITES
-------------------------------------------------------------------------------
Currently used these set of OS platforms, compilers, interpreters, modules,
IDE's, applications and patches to run with or from:

1. OS platforms:

* Windows XP x86 SP3/x64 SP2
* Windows 7+

* Cygwin 1.5+ or 3.0+ (`.sh` only):
  https://cygwin.com
  - to run scripts under cygwin

* Msys2 20190524+ (`.sh` only):
  https://www.msys2.org
  - to run scripts under msys2

* Linux Mint 18.3 x64 (`.sh` only)

2. C++11 compilers:

* (primary) Microsoft Visual C++ 2015 Update 3 or Microsoft Visual C++ 2017
* (secondary) GCC 5.4+

3. Interpreters:

* bash shell 3.2.48+
  - to run unix shell scripts

* cmake 3.14+ :
  https://cmake.org/download/
  - to run cmake scripts and modules

* python 3.7.3 or 3.7.5 (3.4+ or 3.5+)
  https://python.org
  - standard implementation to run python scripts
  - 3.7.4 has a bug in the `pytest` module execution (see `KNOWN ISSUES`
    section).
  - 3.6.2+ is required due to multiple bugs in the python implementation prior
    this version (see `KNOWN ISSUES` section).
  - 3.5+ is required for the direct import by a file path (with any extension)
    as noted in the documentation:
    https://docs.python.org/3/library/importlib.html#importing-a-source-file-directly

* cmake 3.15.1 (3.14+):
  https://cmake.org/download/
  - to run cmake scripts and modules
  - 3.14+ does allow use generator expressions at install phase:
    https://cmake.org/cmake/help/v3.14/policy/CMP0087.html

* Windows Script Host 5.8+
  - standard implementation to run vbs scripts

4. Applications:

* subversion 1.8+
  https://tortoisesvn.net
  - to run svn client

* git 2.24+
  https://git-scm.com
  - to run git client

* cygwin cygpath 1.42+
  - to run `bash_entry` script under cygwin

* msys cygpath 3.0+
  - to run `bash_entry` script under msys2

* cygwin readlink 6.10+
  - to run specific bash script functions with `readlink` calls

5. IDE's.

* Microsoft Visual Studio 2015 Update 3
* Microsoft Visual Studio 2017
* QtCreator 4.6+

Noticeable cmake changes from the version 3.14:

https://cmake.org/cmake/help/v3.14/release/3.14.html#deprecated-and-removed-features

* The FindQt module is no longer used by the find_package() command as a find
  module. This allows the Qt Project upstream to optionally provide its own
  QtConfig.cmake package configuration file and have applications use it via
  find_package(Qt) rather than find_package(Qt CONFIG). See policy CMP0084.

* Support for running CMake on Windows XP and Windows Vista has been dropped.
  The precompiled Windows binaries provided on cmake.org now require Windows 7
  or higher.

https://cmake.org/cmake/help/v3.14/release/3.14.html#id13

* The install(CODE) and install(SCRIPT) commands learned to support generator
  expressions. See policy CMP0087
  (https://cmake.org/cmake/help/v3.14/policy/CMP0087.html):

  In CMake 3.13 and earlier, install(CODE) and install(SCRIPT) did not evaluate
  generator expressions. CMake 3.14 and later will evaluate generator
  expressions for install(CODE) and install(SCRIPT).

6. Patches:

  Target repository with a 3dparty component sources must already contain all
  patches and description with it.

-------------------------------------------------------------------------------
6. DEPENDENCIES
-------------------------------------------------------------------------------
Any project which is dependent on this project have has to contain the
`README_EN.deps.txt` description file for the common dependencies in the
Windows and in the Linux like platforms.

-------------------------------------------------------------------------------
7. EXTERNALS
-------------------------------------------------------------------------------
See details in `README_EN.txt` in `externals` project:

https://github.com/andry81/externals

-------------------------------------------------------------------------------
8. DEPLOY
-------------------------------------------------------------------------------
To run bash shell scripts (`.sh` file extension) you should copy these scripts:

* /_externals/tacklelib/bash/tacklelib/bash_entry
* /_externals/tacklelib/bash/tacklelib/bash_tacklelib

into the `/bin` directory of your platform.

In pure Linux you have additional step to make scripts executable or readable:

>
sudo chmod ug+x /bin/bash_entry
sudo chmod o+r  /bin/bash_entry
sudo chmod a+r  /bin/bash_tacklelib

-------------------------------------------------------------------------------
9. TESTS
-------------------------------------------------------------------------------
* bat scripts tests:

  ** Scripts/Tests/manual/batscripts
  ** Scripts/Tests/unit/batscripts
  ** Scripts/Tests/bench/batscripts

* bash modules tests:

  ** Scripts/Tests/unit/hashlib
  ** Scripts/Tests/unit/traplib

-------------------------------------------------------------------------------
10. AUTHOR
-------------------------------------------------------------------------------
Andrey Dibrov (andry at inbox dot ru)
