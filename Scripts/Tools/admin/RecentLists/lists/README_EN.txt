* README_EN.txt
* 2023.02.19
* RecentList formats

1. DESCRIPTION
2. FORMATS

-------------------------------------------------------------------------------
1. DESCRIPTION
-------------------------------------------------------------------------------
RecentList cleanup config file format.

-------------------------------------------------------------------------------
2. FORMATS
-------------------------------------------------------------------------------

<Storage>|...

1. reg|<CleanupMode>|...
2. file|<Format>|...

1.1. reg|*|<RegKeyPath>

  Cleanup entire key path

1.2. reg|.|<RegKeyPath>|<RegKeyType>|<RegKeyName>

  Cleanup a single key name with exact name match.

1.3. reg|n|<RegKeyPath>[\*]|<RegKeyType>|<RegKeyName>[*]

  CAUTION:
    `n` pattern won't work if a value of the `<RegKeyName>` is too long.

  CAUTION:
    `<RegKeyName>` must be without whitespaces.

1.3.1 ...|<RegKeyPath>\*|<RegKeyType>|<RegKeyName>

  Cleanup multiple key name with exact name match from key path recursively.

1.3.2 ...|<RegKeyPath>|<RegKeyType>|<RegKeyName>*

  Cleanup multiple key name with inexact name match by single key path.

1.3.3 ...|<RegKeyPath>\*|<RegKeyType>|<RegKeyName>*

  Cleanup multiple key name with inexact name match from key path recursively.

2.1. file|ini|<CleanupMode>|...

2.1.1. file|ini|*|<FileExpandPath>|<IniSectionList>

  Cleanup multiple ini file sections in the expanded file path.

  CAUTION:
    To apply all variables expansion in `<FileExpandPath>` a cleanup script
    must run from respective session or process which has that environment
    variable.
    For example, `%COMMANDER_INI%` variable exists only under the
    `Total Commander` session.
