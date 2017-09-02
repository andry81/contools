* README_EN.txt
* 2017.09.02
* Steam scripts

1. DESCRIPTION
2. USAGE
3. AUTHOR

-------------------------------------------------------------------------------
1. DESCRIPTION
-------------------------------------------------------------------------------
Set of scritps to maintain Steam execution on the Windows.

* `Steam.vbs`
  Avoids the need to make online login before go to offline.
  Can start Steam in offline mode w/o login.

-------------------------------------------------------------------------------
2. USAGE
-------------------------------------------------------------------------------
Steam.vbs [mode]
, where `mode` can be:
  `online`
  `offline`
  `AppID`

WARNING:
  * The Working Directory must point the Steam installation root.

CAUTION:
  * The script does not solve the `No steam logon` issue. If you want to play
    offline and game kicks you after ~1 min of a game play with that message,
    then YOU HAVE TO LOGIN and do `Go Offline` from the Steam main window!

-------------------------------------------------------------------------------
3. AUTHOR
-------------------------------------------------------------------------------
Andrey Dibrov (andry at inbox dot ru)
