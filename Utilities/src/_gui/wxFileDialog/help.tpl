[+ AutoGen5 template txt=%s.txt +]
wxFileDialog.exe, version [+ AppMajorVer +].[+ AppMinorVer +].[+ AppRevision +], build [+ AppBuildNum +].
  Opens the Open/Save File dialog window to request file path(s) to be returned
  back into standard output.

Usage: wxFileDialog.exe [/?] <FileTypes> <StartFolder> <Title> [<Options>]
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
      (default: "Open" or "Save As")

    -<Options>: -[o | s]pnemw:
      o - (Default) Open file dialog.
      s - Save file dialog.
      p - Save file only: prompt for a confirmation if a file will be
          overwritten.
      n - Directs the dialog to return the path and file name of the selected
          shortcut file, not its target as it does by default. Currently this
          flag is only implemented in wxMSW and the non-dereferenced link path
          is always returned, even without this flag, under Unix and so using
          it there doesn't do anything.
      e - Select file only: the user may only select files that actually exist.
          Notice that under OS X the file dialog with open flag always behaves
          as if this style was specified, because it is impossible to choose a
          file that doesn't exist from a standard OS X file dialog.
          Select directory only: the dialog will allow the user to choose only
          an existing folder. When this style is not given, a
          "Create new directory" button is added to the dialog (on Windows) or
          some other way is provided to the user to type the name of a new
          folder.
      m - Open file only: allows selecting multiple files.
      w - Show the preview of the selected files (currently only supported by
          wxGTK).
      d - Open or create a directory dialog instead of a file dialog.

  Return codes (Positive values - errors, negative - warnings):
   -1   - selection canceled
    0   - succeded
    1   - help output
    2   - invalid command line
    255 - unspecified error

  Examples:
    1. wxFileDialog.exe "" . "Open Me"
    2. wxFileDialog.exe "" "" "Save Me" -sp
    3. wxFileDialog.exe "Text files (*.txt)|*.txt|C++ Source Files (*.cpp)|*.cpp" . "Save Me" -s
