''' Generates 8dot3 name(s) for a directory or a file.
''' By default sorts a directory file names in the alphabetical order before
''' generate short names.

''' CAUTION:
'''   The 8dot3 names must be available to generate for a file system in a
'''   volume. Use `fsutil 8dot3name ...` command to enable the functionality.

''' Based on:
'''   RtlGenerate8dot3Name:   https://github.com/reactos/reactos/blob/d6b5c19233510533f5d40fe9ade33094fa37f0ad/sdk/lib/rtl/dos8dot3.c#L81
'''   RtlIsNameLegalDOS8Dot3: https://github.com/reactos/reactos/blob/d6b5c19233510533f5d40fe9ade33094fa37f0ad/sdk/lib/rtl/dos8dot3.c#L249

''' USAGE:
'''   make_8dot3_names.vbs [-r] [-R] [-b | -B] [-p[rint-gen]] [--] <FileOrDirectory>

''' Tests:
'''   https://github.com/reactos/reactos/blob/d6b5c19233510533f5d40fe9ade33094fa37f0ad/modules/rostests/winetests/ntdll/path.c#L170
'''
'''   struct test
'''   {
'''       const char *path;
'''       BOOLEAN result;
'''       BOOLEAN spaces;
'''   };
'''
'''   static const struct test tests[] =
'''   {
'''       { "12345678",     TRUE,  FALSE },
'''       { "123 5678",     TRUE,  TRUE  },
'''       { "12345678.",    FALSE, 2 /*not set*/ },
'''       { "1234 678.",    FALSE, 2 /*not set*/ },
'''       { "12345678.a",   TRUE,  FALSE },
'''       { "12345678.a ",  FALSE, 2 /*not set*/ },
'''       { "12345678.a c", TRUE,  TRUE  },
'''       { " 2345678.a ",  FALSE, 2 /*not set*/ },
'''       { "1 345678.abc", TRUE,  TRUE },
'''       { "1      8.a c", TRUE,  TRUE },
'''       { "1 3 5 7 .abc", FALSE, 2 /*not set*/ },
'''       { "12345678.  c", TRUE,  TRUE },
'''       { "123456789.a",  FALSE, 2 /*not set*/ },
'''       { "12345.abcd",   FALSE, 2 /*not set*/ },
'''       { "12345.ab d",   FALSE, 2 /*not set*/ },
'''       { ".abc",         FALSE, 2 /*not set*/ },
'''       { "12.abc.d",     FALSE, 2 /*not set*/ },
'''       { ".",            TRUE,  FALSE },
'''       { "..",           TRUE,  FALSE },
'''       { "...",          FALSE, 2 /*not set*/ },
'''       { "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", FALSE, 2 /*not set*/ },
'''       { NULL, 0 }
'''   };

''' DESCRIPTION:
'''   --
'''     Separator between flags and positional arguments to explicitly stop the
'''     flags parser.
'''
'''   -r
'''     Generate or regenerate short names in all subdirectories recursively.
'''     The <FileOrDirectory> must be a directory path.
'''
'''   -R
'''     Regenerate short names if already exists including subdirectories.
'''
'''   -b
'''     Generate short names for all components from a parent directory if not
'''     exists.
'''
'''   -B
'''     Regenerate short names for all components from a parent directory even
'''     if exists.
'''
'''   -p[rint-gen]
'''     Print generation.
'''
'''   <FileOrDirectory>
'''     File or directory path to start from.

Sub PrintOrEchoLine(str)
  On Error Resume Next
  WScript.stdout.WriteLine str
  If err = &h80070006& Then
    WScript.Echo str
  End If
  On Error Goto 0
End Sub

Sub PrintOrEchoErrorLine(str)
  On Error Resume Next
  WScript.stderr.WriteLine str
  If err = &h80070006& Then
    WScript.Echo str
  End If
  On Error Goto 0
End Sub

ReDim cmd_args(WScript.Arguments.Count - 1)

Dim ExpectFlags : ExpectFlags = True

Dim Recursed : Recursed = False
Dim RegenExistedNames : RegenExistedNames = False
Dim GenParentPath : GenParentPath = False
Dim RegenParentPath : RegenParentPath = False
Dim PrintGen : PrintGen = False

Dim objShell : Set objShell = WScript.CreateObject("WScript.Shell")

Dim arg
Dim j : j = 0

For i = 0 To WScript.Arguments.Count-1 : Do ' empty `Do-Loop` to emulate `Continue`
  arg = WScript.Arguments(i)

  If ExpectFlags Then
    If arg <> "--" And Left(arg, 1) = "-" Then
      If arg = "-print-gen" Or arg = "-p" Then ' Print generation
        PrintGen = True
      ElseIf arg = "-r" Then ' Recursed
        Recursed = True
      ElseIf arg = "-R" Then ' Regenerate 
        RegenExistedNames = True
      ElseIf arg = "-b" Then ' Generate for parent components
        GenParentPath = True
      ElseIf arg = "-B" Then ' Regenerate for parent components
        RegenParentPath = True
      Else
        PrintOrEchoErrorLine WScript.ScriptName & ": error: unknown flag: `" & arg & "`"
        WScript.Quit 255
      End If
    Else
      ExpectFlags = False

      If arg = "--" Then Exit Do
    End If
  End If

  If Not ExpectFlags Then
    cmd_args(j) = arg

    j = j + 1
  End If
Loop While False : Next

ReDim Preserve cmd_args(j - 1)

' MsgBox Join(cmd_args, " ")

Dim cmd_args_ubound : cmd_args_ubound = UBound(cmd_args)

If cmd_args_ubound < 0 Then
  PrintOrEchoErrorLine WScript.ScriptName & ": error: <FileOrDirectory> argument is not defined."
  WScript.Quit 255
End If

' functions

Function GetFileShortPath(FilePathAbs)
  ' WORKAROUND:
  '   We use `\\?\` to bypass `GetFile` error: `File not found`.
  Dim File : Set File = objFS.GetFile("\\?\" & FilePathAbs)
  GetFileShortPath = File.ShortPath
  If Left(GetFileShortPath, 4) = "\\?\" Then
    GetFileShortPath = Mid(GetFileShortPath, 5)
  End If
End Function

Function GetFolderShortPath(FolderPathAbs)
  ' WORKAROUND:
  '   We use `\\?\` to bypass `GetFile` error: `File not found`.
  Dim Folder : Set Folder = objFS.GetFolder("\\?\" & FolderPathAbs & "\")
  GetFolderShortPath = Folder.ShortPath
  If Left(GetFolderShortPath, 4) = "\\?\" Then
    GetFolderShortPath = Mid(GetFolderShortPath, 5)
  End If
End Function

Function GetShortPath(PathAbs)
  If objFS.FileExists("\\?\" & PathAbs) Then
    GetShortPath = GetFileShortPath(PathAbs)
  ElseIf objFS.FolderExists("\\?\" & PathAbs) Then
    GetShortPath = GetFolderShortPath(PathAbs)
  End If
End Function

Dim objFS : Set objFS = CreateObject("Scripting.FileSystemObject")

Dim FileOrDirPath : FileOrDirPath = cmd_args(0)

Dim FileOrDirPathAbs : FileOrDirPathAbs = objFS.GetAbsolutePathName(FileOrDirPath) ' CAUTION: can alter a path character case if path exists

' remove `\\?\` prefix
If Left(FileOrDirPathAbs, 4) = "\\?\" Then
  FileOrDirPathAbs = Mid(FileOrDirPathAbs, 5)
End If

' test on path existence including long path
Dim IsFilePathExist : IsFilePathExist = objFS.FileExists("\\?\" & FileOrDirPathAbs)
Dim IsDirPathExist : IsDirPathExist = objFS.FolderExists("\\?\" & FileOrDirPathAbs)
If Not (IsFilePathExist Or IsDirPathExist) Then
  PrintOrEchoErrorLine _
    WScript.ScriptName & ": error: file or directory path must exist:" & vbCrLf & _
    WScript.ScriptName & ": info: ShortcutFilePath=`" & FileOrDirPathAbs & "`"
  WScript.Quit 10
End If

Dim ParentDir : ParentDir = objFS.GetParentFolderName(FileOrDirPathAbs)
Dim IsParentDirExist : IsParentDirExist = objFS.FolderExists("\\?\" & ParentDir & "\")
If Not IsParentDirExist Then
  PrintOrEchoErrorLine _
    WScript.ScriptName & ": error: parent directory must exist:" & vbCrLf & _
    WScript.ScriptName & ": info: ParentDir=`" & ParentDir & "`"
  WScript.Quit 20
End If

Dim dictNames : Set dictNames = CreateObject("Scripting.Dictionary")

''' ...
