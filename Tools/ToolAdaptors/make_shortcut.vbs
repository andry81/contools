''' Creates the Windows shortcut file with assigned command line and working
''' directory.

set objWSHShell = CreateObject("WScript.Shell")
''' set objFso = CreateObject("Scripting.FileSystemObject")

sShortcut = WScript.Arguments.Item(0)
sWorkingDirectory = WScript.Arguments.Item(1)
sTargetPath = WScript.Arguments.Item(2)
If WScript.Arguments.length > 3 Then
  sArguments = WScript.Arguments.Item(3)
Else
  sArguments = ""
End If

set objSC = objWSHShell.CreateShortcut(sShortcut) 

If sWorkingDirectory <> "" Then
  sWorkingDirectory = """" & sWorkingDirectory & """"
End If
If sTargetPath <> "" Then
 sTargetPath = """" & sTargetPath & """"
End If

objSC.TargetPath = sTargetPath
objSC.WorkingDirectory = sWorkingDirectory
objSC.Arguments = sArguments

objSC.Save
