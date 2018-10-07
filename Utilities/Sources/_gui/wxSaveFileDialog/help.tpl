[+ AutoGen5 template txt=%s.txt +]
wxSaveFileDialog.exe, version [+ AppMajorVer +].[+ AppMinorVer +].[+ AppRevision +], build [+ AppBuildNum +].
  Opens the Save File dialog window to request a file path to be returned back into standard output

Usage: wxSaveFileDialog.exe [/?] <FileTypes> <StartFolder> <Title> [<Options>]
  Description:
    /?:
      This help.
    <FileTypes>:
      File type(s) in format "description (*.ext)|*.ext" or just "*.ext"
      (default: "All files (*.*)|*.*")
    <StartFolder>:
      The Initial folder the dialog will show on opening
      (default: current directory)
    <Title>:
      The caption in the dialog's title bar
      (default: "Save As")
    -<Options>: -<p | n>:
      p - Prompt for a confirmation if a file will be overwritten.
      n - Directs the dialog to return the path and file name of the selected
          shortcut file, not its target as it does by default. Currently this
          flag is only implemented in wxMSW and the non-dereferenced link path
          is always returned, even without this flag, under Unix and so using
          it there doesn't do anything.

  Return codes (Positive values - errors, negative - warnings):
   -1   - selection canceled
    0   - succeded
    1   - help output
    2   - invalid command line
    255 - unspecified error

  Examples:
    wxSaveFileDialog.exe "" "" "Save Me" -p
    wxSaveFileDialog.exe "Text files (*.txt)|*.txt|C++ Source Files (*.cpp)|*.cpp" . "Save Me"
