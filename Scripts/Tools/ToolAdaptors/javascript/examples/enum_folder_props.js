function PrintOrEchoLine(str)
{
  try {
    WScript.stdout.WriteLine(str);
  }
  catch(e) {
    if (e.err = 0x80070006) {
      WScript.Echo(str)
    }
    else throw e;
  }
}

function PrintOrEchoErrorLine(str)
{
  try {
    WScript.stderr.WriteLine(str);
  }
  catch(e) {
    if (e.err = 0x80070006) {
      WScript.Echo(str)
    }
    else throw e;
  }
}

var shellapp = WScript.CreateObject("Shell.Application");
var folder = shellapp.NameSpace("C:\\");
for (var j = 0; j < 0xFFFF; j++) {
    detail = folder.GetDetailsOf(null, j);
    if (!detail) {
        break;
    }
    PrintOrEchoLine("[" + j + "]`" + detail + "` = `" + folder.GetDetailsOf(folder.ParseName("common"), j) + "`");
}
