Sub includeFile(fSpec)
    executeGlobal CreateObject("Scripting.FileSystemObject").openTextFile(fSpec).readAll()
End Sub

includeFile("ProductKey.vbs")

Wscript.Echo(DecodeFromBytes(ReadBinaryFile(WScript.Arguments(0))))
