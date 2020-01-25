* README_EN.txt
* 2020.01.25
* contools

1. DESCRIPTION
3. REPOSITORIES
4. PREREQUISITES
5. CONFIGURE
6. KNOWN ISSUES
6.1. The setup does not go to update the layout
7. AUTHOR EMAIL

-------------------------------------------------------------------------------
1. DESCRIPTION
-------------------------------------------------------------------------------
These scripts is a part of the contools project and is used to create and
update a Visual Studio 2017 layout installation.

-------------------------------------------------------------------------------
3. REPOSITORIES
-------------------------------------------------------------------------------
Primary:
  * https://sf.net/p/contools/contools/HEAD/tree/trunk
  * https://svn.code.sf.net/p/contools/contools/trunk
First mirror:
  * https://github.com/andry81/contools/tree/trunk
  * https://github.com/andry81/contools.git
Second mirror:
  * https://bitbucket.org/andry81/contools/src/trunk
  * https://bitbucket.org/andry81/contools.git

-------------------------------------------------------------------------------
4. PREREQUISITES
-------------------------------------------------------------------------------
Microsoft Visual Studio 2017 setup executable:

* `vs_professional.exe`

or

* `vs_community.exe`

-------------------------------------------------------------------------------
5. CONFIGURE
-------------------------------------------------------------------------------
Run the `configure.bat` to generate `config.vars` file and edit all values to
the correct one.

-------------------------------------------------------------------------------
6. KNOWN ISSUES
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
6.1. The setup does not go to update the layout
-------------------------------------------------------------------------------

You have to explicitly pass the '--update' key parameter to initiate an update.

-------------------------------------------------------------------------------
7. AUTHOR EMAIL
-------------------------------------------------------------------------------
Andrey Dibrov (andry at inbox dot ru)
