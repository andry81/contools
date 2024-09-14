' Description:
'   Shell based script to be able to touch file by paths longer than 260+ characters.
'
' USAGE:
'   "%SystemRoot%\System32\cscript.exe" //NOLOGO touch_file.vbs "\\?\<absolute-canonical-file-path-to-file>"
'
'   , where (!) <absolute-canonical-file-path-to-file>: is an absolute file path separated with the backslash character ONLY - `\`
'

Dim objFS : Set objFS = CreateObject("Scripting.FileSystemObject")
Dim objFile : Set objFile = objFS.OpenTextFile(WScript.Arguments(0), 2)
objFile.Close
