// Author:   Andrey Dibrov (andry at inbox dot ru)

//SaRF => Search and Replace in Files.

//Script searches in text file by regular expressions and replaces found signatures
//by predefined text with regular expression variables (\1, \2, etc).
// Command arguments:
// [1] - Path to ANSI text file in which text would be searched and replaced.
// [2] - Path to ANSI text file, each line of which stores a regexp for string
//       which would be searched and replaced in text file [1].
// [3] - Path to ANSI text file, each line of which stores strings for
//       replacement in text file [1].

//Examples:
//1. sarf.js test.txt search.txt replace.txt

//For DEBUG purposes ONLY
var DEBUG = 0;

//Read arguments
var args = WScript.Arguments;
if(args.length < 3 ||
  args(0).length == 0 ||
  args(1).length == 0 ||
  args(2).length == 0) {
  WScript.Echo("sarf.js: Error 1");
  WScript.Quit(1);
}

var TargetFile = new ActiveXObject("Scripting.FileSystemObject");
var RegexpStringsFile = new ActiveXObject("Scripting.FileSystemObject");
var ReplaceStringsFile = new ActiveXObject("Scripting.FileSystemObject");
if(!TargetFile || !RegexpStringsFile || !ReplaceStringsFile) {
  if(DEBUG) {
    WScript.Echo("sarf.js: Error 2");
  }
  WScript.Quit(2);
}

var TargetFileStream = TargetFile.OpenTextFile(args(0),1);
var RegexpStringsFile = RegexpStringsFile.OpenTextFile(args(1),1);
var ReplaceStringsFile = ReplaceStringsFile.OpenTextFile(args(2),1);

function Clear() {
  if(TargetFileStream) TargetFileStream.Close();
  if(RegexpStringsFile) RegexpStringsFile.Close();
  if(ReplaceStringsFile) ReplaceStringsFile.Close();
}

if(!TargetFileStream || !RegexpStringsFile || !ReplaceStringsFile) {
  Clear();
  if(DEBUG) {
    WScript.Echo("sarf.js: Error 3");
  }
  WScript.Quit(3);
}

if(TargetFileStream.AtEndOfStream ||
  RegexpStringsFile.AtEndOfStream ||
  ReplaceStringsFile.AtEndOfStream) {
  Clear();
  if(DEBUG) {
    WScript.Echo("sarf.js: Error 4");
  }
  WScript.Quit(4);
}

var TargetFileAllText = TargetFileStream.ReadAll();
if(TargetFileAllText.length == 0) {
  Clear();
  if(DEBUG) {
    WScript.Echo("sarf.js: Error 5");
  }
  WScript.Quit(5);
}

var Rex = new RegExp();
var RexRepPreprocString = "(\\\\n)|(\\\\r)|(\\\\t)|(\\\\b)|(\\\\f)|(\\\\v)";
var RexRepProcString = "(\\\\1)|(\\\\2)|(\\\\3)|(\\\\4)|(\\\\5)|(\\\\6)|(\\\\7)|(\\\\8)|(\\\\9)";
var RexRepPreprocess = RegExp(RexRepPreprocString);
var RexRepProcess = RegExp(RexRepProcString);
var replacesOverall = 0;
do {
  var RexString = RegexpStringsFile.ReadLine();
  var ReplaceString = ReplaceStringsFile.ReadLine();
  if(RexString.length == 0) {
    break;
  }
  
  //Preprocess ReplaceString
  {
    var RexRepMatchArr = ReplaceString.match(RexRepPreprocess);
    var RexRepLastIndex = 0;
    var NewReplaceString = "";
    while(RexRepMatchArr != null && RegExp.lastIndex != -1) {
      NewReplaceString += ReplaceString.substring(RexRepLastIndex,RexRepLastIndex+RegExp.index)+eval("\""+RexRepMatchArr[0]+"\"");
      RexRepLastIndex += RegExp.lastIndex;
      RexRepMatchArr = ReplaceString.substr(RexRepLastIndex).match(RexRepPreprocess);
    }
    NewReplaceString += ReplaceString.substr(RexRepLastIndex);
    ReplaceString = NewReplaceString;
  }

  var ReplacedText = "";
  var RexLastIndex = 0;
  var replaces = 0;
  Rex.compile(RexString);
  var RexMatchArr = TargetFileAllText.match(Rex);
  if(RexMatchArr != null && RegExp.lastIndex != -1) {
    do {
      var RexMatchBegin = RegExp.index;
      var RexMatchEnd = RegExp.lastIndex;
      if(RexMatchArr.length > 1) {
        //Process ReplaceString
        var RexRepLastIndex = 0;
        var NewReplaceString = "";
        var RexRepMatchArr = ReplaceString.match(RexRepProcess);
        while(RexRepMatchArr != null && RegExp.lastIndex != -1) {
          NewReplaceString += ReplaceString.substring(RexRepLastIndex,RexRepLastIndex+RegExp.index)+RexMatchArr[RexRepMatchArr[0].substr(1)];
          RexRepLastIndex += RegExp.lastIndex;
          RexRepMatchArr = ReplaceString.substr(RexRepLastIndex).match(RexRepProcess);
        }
        NewReplaceString += ReplaceString.substr(RexRepLastIndex);
        ReplaceString = NewReplaceString;
      }
      ReplacedText += TargetFileAllText.substring(RexLastIndex,RexLastIndex+RexMatchBegin)+ReplaceString;
      RexLastIndex += RexMatchEnd;
      RexMatchArr = TargetFileAllText.substr(RexLastIndex).match(Rex);
      replaces++;
      replacesOverall++;
    } while(RexMatchArr != null && RegExp.lastIndex != -1);
    ReplacedText += TargetFileAllText.substr(RexLastIndex);
    TargetFileAllText = ReplacedText;
  }
  if(DEBUG) {
    WScript.Echo("["+replaces+"] => "+RexString+" => "+ReplaceString);
  }
} while(!RegexpStringsFile.AtEndOfStream && !ReplaceStringsFile.AtEndOfStream);

//Update file if was replacement
if(replacesOverall > 0) {
  TargetFileStream.Close();
  TargetFileStream = TargetFile.CreateTextFile(args(0),true);
  TargetFileStream.Write(TargetFileAllText);
}

if(DEBUG) {
  WScript.Echo("Replaces done: "+replacesOverall);
}
Clear();

WScript.Quit(0);
