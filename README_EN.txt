* README_EN.txt
* 2026.07.14
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
Library for Windows Batch interpreter (cmd.exe) and Visual Basic Script (.vbs).

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
 |  | # Directory with input configuration files.
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
 +- /`_out`
 |    #
 |    # Output directory for all files.
 |
 +- /`scripts`
      #
      # The root for all scripts and tools excluding external or standalone.

-------------------------------------------------------------------------------
5. PREREQUISITES
-------------------------------------------------------------------------------
Currently used these set of prerequisites to run with or from:

1. OS platforms
2. Interpreters

1. OS platforms:

* Windows XP x86 SP3/x64 SP2
* Windows 7+

2. Interpreters:

* Windows Script Host 5.8+
  - standard implementation to run vbs scripts

-------------------------------------------------------------------------------
6. DEPENDENCIES
-------------------------------------------------------------------------------
N/A

-------------------------------------------------------------------------------
7. EXTERNALS
-------------------------------------------------------------------------------
See details in `README_EN.txt` in `externals` project:

https://github.com/andry81/externals

-------------------------------------------------------------------------------
8. DEPLOY
-------------------------------------------------------------------------------
To run specific Windows Batch scripts (.bat) you should run the installation
script:

* _install.bat`

-------------------------------------------------------------------------------
9. TESTS
-------------------------------------------------------------------------------
* bat scripts tests:

  ** scripts/tests/manual/bat
  ** scripts/tests/unit/bat
  ** scripts/tests/probe/bat
  ** scripts/tests/bench/bat

-------------------------------------------------------------------------------
10. AUTHOR
-------------------------------------------------------------------------------
Andrey Dibrov (andry at inbox dot ru)
