This is the dynacall.dll that I described as "bringing back the Declare
statement"  in VBScript. Basically it will allow you to call functions
in other dlls...like any of the win32 api functions. This will be my
only distribution.

Many thanks to Ton Plooy and Jeff Stong who wrote the code and published
it in WDJ. And more thanks to William Epp for getting it to work with my
sample script ccupd.vbs using the GETPROFILESTRING function. However I
have another function in the sample that still doesn't work
GETPROFILESECTION. This is a work in progress but I think it is a handy
little feature. Hopefully by this distributions it will get where it
needs to be. Clarence and Ian have offered to post it on their sites so
further updates can be had at either WSH site. (anyone else call this
thing woosh? Hopefully it will perform this way).

Basically you declare functions and other DLLS like this:

'   Create the wrapper object for dynamic DLL function calling
Dim UserWrap 
Set UserWrap = CreateObject("DynamicWrapper")
'   GetProcAddress for GetPrivateProfileStringA()
UserWrap.Register "kernel32.DLL", "GetPrivateProfileString", "i=ssssls",
"f=s", "r=l"


The input parameters are:

i=describes the number and data type of the functions parameters

f=type of call _stdcall or _cdecl. So it can work with both MS C++ and
Borland C++. Default to _stdcall. If that doesn't work use _cdecl. If
that doesn't work good luck!

r=return data type.


Data types are:

const ARGTYPEINFO ArgInfo[] = 
{
{'a', sizeof(IDispatch*),    VT_DISPATCH}, // a   IDispatch*
{'c', sizeof(unsigned char), VT_I4},       // c   signed char  
{'d', sizeof(double),        VT_R8},       // d   8 byte real 
{'f', sizeof(float),         VT_R4},       // f   4 byte real 
{'k', sizeof(IUnknown*),     VT_UNKNOWN},  // k   IUnknown* 
{'h', sizeof(long),          VT_I4},       // h   HANDLE 
{'l', sizeof(long),          VT_I4},       // l   long 
{'p', sizeof(void*),         VT_PTR},      // p   pointer 
{'s', sizeof(BSTR),          VT_LPSTR},    // s   string 
{'t', sizeof(short),         VT_I2},       // t   short 
{'u', sizeof(UINT),          VT_UINT},     // u   unsigned int 
{'w', sizeof(BSTR),          VT_LPWSTR},   // w   wide string 
}

William Epp added anr 'r' for VT_BYREF (pass by reference)but is for
strings only. This made the GETPROFILESTRING function to work. But it
didn't work for the GETPROFILESECTION. If anyone gets it to work please
let me know.


Attachments:

stong.zip - original download from WDJ
DynaWrap.zip - the modified code, the DLL with modifications.
feature.htm - the feature article for this code by Jeff Stong. Only
thing I could find on WDJ. I couldn't find Ton's article.