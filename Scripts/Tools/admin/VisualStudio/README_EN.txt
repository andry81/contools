* README_EN.txt
* 2023.02.21
* contools/admin/VisualStudio

1. DESCRIPTION
2. CATALOG CONTENT DESCRIPTION
3. PREREQUISITES
4. CONFIGURE
5. USAGE
6. KNOWN ISSUES
6.1. The setup does not go to update the layout

-------------------------------------------------------------------------------
1. DESCRIPTION
-------------------------------------------------------------------------------
Scripts to download an offline version of `Visual Studio 2017/2019/2022`
installation package.

-------------------------------------------------------------------------------
2. CATALOG CONTENT DESCRIPTION
-------------------------------------------------------------------------------

+- /`vssetup`
|  | #
|  | # This project root directory.
|  |
|  +- /`__init__`
|     #
|     # Basic initialization scripts directory.
|
+- /`vscache`
   | #
   | # Visual Studio bootstrap directories root.
   |
   +- /`bootstrappers`
   |  #
   |  # Directory with standalone downloaded setup bootstrappers from the
   |  # Microsoft site (`VS_BOOTSTRAPPERS_CACHE_DIR`).
   |
   +- /`layout`
   |  #
   |  # Visual Studio layout root directory (`VS_LAYOUT_CACHE_ROOT`).
   |
   +- /`packages`
         #
         # Visual Studio packages root directory
         # (`VS_PACKAGES_CACHE_ROOT`).

-------------------------------------------------------------------------------
3. PREREQUISITES
-------------------------------------------------------------------------------
Microsoft Visual Studio setup requires to download the setup bootstrapper to
use offline setup or update an installation using the online:

* https://learn.microsoft.com/en-us/previous-versions/visualstudio/visual-studio-2017/install/create-an-offline-installation-of-visual-studio?view=vs-2017
  https://aka.ms/vs/15/release/vs_professional.exe
  https://aka.ms/vs/15/release/vs_enterprise.exe
  https://aka.ms/vs/15/release/vs_buildtools.exe

* https://learn.microsoft.com/en-us/visualstudio/install/create-an-offline-installation-of-visual-studio?view=vs-2019
  https://aka.ms/vs/16/release/vs_professional.exe
  https://aka.ms/vs/16/release/vs_enterprise.exe
  https://aka.ms/vs/16/release/vs_buildtools.exe

* https://learn.microsoft.com/en-us/visualstudio/install/create-an-offline-installation-of-visual-studio?view=vs-2022
  https://aka.ms/vs/17/release/vs_community.exe
  https://aka.ms/vs/17/release/vs_professional.exe
  https://aka.ms/vs/17/release/vs_enterprise.exe
  https://aka.ms/vs/17/release/vs_buildtools.exe

Setup bootstrapper version variants:

* https://learn.microsoft.com/en-us/previous-versions/visualstudio/visual-studio-2017/install/visual-studio-build-numbers-and-release-dates?view=vs-2017

* https://learn.microsoft.com/en-us/visualstudio/releases/2019/history

  NOTE:

    If you previously downloaded a specific bootstrapper file and want to
    verify what version it will install, here's how. In Windows, open
    File Explorer, right-click the bootstrapper file, choose Properties, choose
    the Details tab, and then view the Product version number. To match that
    number to a release of Visual Studio, refer to the table at the bottom of
    the Visual Studio 2019 Releases page.

* https://learn.microsoft.com/en-us/visualstudio/productinfo/release-rhythm

  NOTE:

    If you previously downloaded a bootstrapper file and want to verify what
    version it will install, here's how. In Windows, open File Explorer,
    right-click the bootstrapper file, choose Properties and then choose the
    Details tab. The Product version field will describe the channel and
    version that the bootstrapper will install. The version number should
    always be read as "latest servicing version of what is specified", and the
    channel is assumed to be Current unless explicitly specified. So, a
    bootstrapper with a Product version of LTSC 17.0 will install the latest
    17.0.x servicing release that is available on the 17.0 LTSC channel.
    A bootstrapper with a Product version that simply says Visual Studio 2022
    will install the latest servicing version of Visual Studio 2022 on the
    Current channel.

-------------------------------------------------------------------------------
4. CONFIGURE
-------------------------------------------------------------------------------

1. Copy the `vssetup` directory described in the `CATALOG CONTENT DESCRIPTION`
   section closer to selected drive root directory:

   d:\vssetup

2. Create set of directories near the `vssetup` directory as discribed
   in the `CATALOG CONTENT DESCRIPTION` section:

   * `vscache/bootstrappers`
   * `vscache/layout`
   * `vscache/packages`

3. Download latest Visual Studio setup bootstrap executable described in the
   `PREREQUISITES` section.

   Put the setup bootstrap executable into the `vscache/bootstrappers`
   directory optionally rename the file:

   `<vs-bootstrapper>.exe` -> `<vs-bootstrapper>_<product-version>.exe`

   NOTE:

     How to get the value for the `<product-version>` is described in the
     `PREREQUISITES` section.

4. Edit variables in the `__init__\__init__.bat` file for custom valid values:

   * `VS_BOOTSTRAPPER_EXE`
   * `VS_LAYOUT_CACHE_ROOT`
   * `VS_PACKAGES_CACHE_ROOT`
   * `VS_COMMON_CMDLINE`

   CAUTION:

      DO NOT CHANGE `VS_PACKAGES_CACHE_ROOT` directory in the future because
      the setup bootstrapper rely on it to distinguish different Visual Studio
      installations of the same type.

-------------------------------------------------------------------------------
5. USAGE
-------------------------------------------------------------------------------

Run in these order:

1. `vs_create_layout.bat`

   This will download a new layout related to the used setup bootstrap
   executable.

2. `vs_run_layout.bat`

   This will download the packages from the layout and install/update them.

-------------------------------------------------------------------------------
6. KNOWN ISSUES
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
6.1. The setup does not go to update
-------------------------------------------------------------------------------

You need to explicitly run `vs_run_layout.bat` with the '--update' key
parameter to initiate an update.
