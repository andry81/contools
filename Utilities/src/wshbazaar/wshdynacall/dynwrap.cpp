//-----------------------------------------------------------------
// Dynamic Procedure Call COM object.  Jeff Stong 1998
//-----------------------------------------------------------------
#define  WIN32_LEAN_AND_MEAN
#define INC_OLE2

#include <windows.h>
#include <malloc.h>
#include <tchar.h>
#include <Shlwapi.h>

// Using non-DLL version of DynaCall, so don't need to have the
// methods imported.
#undef DECLSPEC_IMPORT
#define DECLSPEC_IMPORT
extern "C" {
#include "dynacall.h"
}

#if 0
// Global optimizations cause crash in release builds made with
// Microsoft 32-bit C/C++ Compiler Version 11.00.7022
#ifdef _MSC_VER
#pragma optimize("g",off)
#endif
#endif

LPCSTR CLSIDVAL = "{202774D1-D479-11d1-ACD1-00A024BBB05E}";
LPCSTR CLASSKEY0 = "CLSID\\{202774D1-D479-11d1-ACD1-00A024BBB05E}";
LPCSTR CLASSKEY1 = "CLSID\\{202774D1-D479-11d1-ACD1-00A024BBB05E}\\InProcServer32";
LPCSTR PRODIDKEY0 = "DynamicWrapper";
LPCSTR PRODIDKEY1 = "DynamicWrapper\\CLSID";

// Allocate on-the-stack LPSTR from LPCWSTR
LPSTR W2AHelp(LPSTR a, LPCWSTR w, int n)
{
  a[0] = '\0';
  WideCharToMultiByte(CP_ACP, 0, w, -1, a, n, NULL, NULL);
  return a;
}
#define W2A(w) (((LPCWSTR)w == NULL) ? NULL : (_clen = \
    (lstrlenW(w)+1)*2,W2AHelp((LPSTR) _alloca(_clen), w, _clen)))
int _clen;

// Locate index for which c is equal to id in array of n elements
template <class T> UINT Find(WCHAR c, const T* arr, UINT n)
{
  for (UINT i = 0; i < n; i++)
    if (arr[i].id == c) 
      return i;
  return -1;
}

// Allowable tags procedure calling convention
class CDynCall;
typedef struct tagTAGINFO
{
  WCHAR id;     // Character
  HRESULT (*pfn)(CDynCall*, LPWSTR, int);  
    // Parsing callback procedure
} TAGINFO;

HRESULT iParse(CDynCall* p, LPWSTR w, int c);
HRESULT rParse(CDynCall* p, LPWSTR w, int c);
HRESULT fParse(CDynCall* p, LPWSTR w, int c);

const TAGINFO TagInfo[] =
{
  {_T('i'),iParse}, // Input arguments (see ARGTYPEINFO entries)
  {_T('r'),rParse}, // Return type (see ARGTYPEINFO entries)
  {_T('f'),fParse}, // Calling convention (see FLAGINFO entries)
};
#define FindIndexOfTag(wc) \
  Find<TAGINFO>(wc,TagInfo,sizeof(TagInfo)/sizeof(TAGINFO))

// Parameter and return values 
typedef struct tagARGTYPEINFO
{
  WCHAR id;      // Character
  UINT size;     // Size of type
  VARTYPE vt;    // Compatible VARTYPE
} ARGTYPEINFO;

const ARGTYPEINFO ArgInfo[] = 
{
{_T('a'), sizeof(IDispatch*),    VT_DISPATCH}, // a   IDispatch*
{_T('c'), sizeof(unsigned char), VT_I4},       // c   signed char  
{_T('d'), sizeof(double),        VT_R8},       // d   8 byte real 
{_T('f'), sizeof(float),         VT_R4},       // f   4 byte real 
{_T('k'), sizeof(IUnknown*),     VT_UNKNOWN},  // k   IUnknown* 
{_T('h'), sizeof(long),          VT_I4},       // h   HANDLE 
{_T('l'), sizeof(long),          VT_I4},       // l   long 
{_T('p'), sizeof(void*),         VT_PTR},      // p   pointer 
{_T('s'), sizeof(BSTR),          VT_LPSTR},    // s   string 
{_T('t'), sizeof(short),         VT_I2},       // t   short 
{_T('u'), sizeof(UINT),          VT_UINT},     // u   unsigned int 
{_T('w'), sizeof(BSTR),          VT_LPWSTR},   // w   wide string 
};
#define FindIndexOfArg(c) \
  Find<ARGTYPEINFO> \
    (c,ArgInfo,sizeof(ArgInfo)/sizeof(ARGTYPEINFO))

// Calling conventions flags
typedef struct tagFLAGINFO
{
  WCHAR id;     // Character
  WORD  wFlag;  // Flag for id
  WORD  wMask;  // Mask for flag value replacement
} FLAGINFO;

const FLAGINFO FlagInfo[] =
{
  {_T('m'), DC_MICROSOFT,    WORD(~(DC_MICROSOFT|DC_BORLAND))},
  {_T('b'), DC_BORLAND,      WORD(~(DC_MICROSOFT|DC_BORLAND))},
  {_T('s'), DC_CALL_STD,     WORD(~(DC_CALL_STD|DC_CALL_CDECL))},
  {_T('c'), DC_CALL_CDECL,   WORD(~(DC_CALL_STD|DC_CALL_CDECL))},
  {_T('4'), DC_RETVAL_MATH4, WORD(~(DC_RETVAL_MATH4|DC_RETVAL_MATH8))},
  {_T('8'), DC_RETVAL_MATH8, WORD(~(DC_RETVAL_MATH4|DC_RETVAL_MATH8))},
};

#define FindIndexOfFlag(c) \
  Find<FLAGINFO>(c,FlagInfo,sizeof(FlagInfo)/sizeof(FLAGINFO))

// DISPID for "Register" method and all those after
#define REGISTERDISPID 1
DISPID dispidLastUsed = REGISTERDISPID;

// CServer class holds global object count
class CServer
{
public:
  CServer() : m_hInstance(NULL), m_dwRef(0)
  {}
  HINSTANCE m_hInstance;
  DWORD m_dwRef;
};
CServer m_Server;

// CDynCall class manages dynamic procedure calls
class CDynCall
{
public:
  // ctor/dtor
  CDynCall() : dwAddress(0),
               cArgs(0), 
               iArg(NULL), 
               iRet(-1), 
               wFlags(DC_MICROSOFT|DC_CALL_STD),
               hDLL(NULL),
               pNext(NULL),
               bstrMethod(NULL)
    {}
  ~CDynCall() 
  { 
    SysFreeString(bstrMethod);
    FreeLibrary(hDLL);
    delete [] iArg; 
  }

  // Equivalance operators used by CDynCallChain class
  bool operator==(DISPID l) const
  { return l == dispid; }
  bool operator==(LPCWSTR l) const
  { return !lstrcmpiW(l,bstrMethod); }

  // Register the procedure
  HRESULT Register(DISPPARAMS* pDispParams, VARIANT* pVarResult)
  {
     // Require at least DLL and procedure name
    if (pDispParams->cArgs < 2)
      return DISP_E_BADPARAMCOUNT;

    VARIANTARG* rgvarg = pDispParams->rgvarg;
    int cArgs = pDispParams->cArgs;
    HRESULT hr = E_INVALIDARG;

    // Can the library be loaded?
    if ((hDLL = LoadLibraryW(rgvarg[cArgs-1].bstrVal)) != NULL)
    {
      // Find the address of the procedure
      bstrMethod = SysAllocString(rgvarg[cArgs-2].bstrVal);
      if ((dwAddress = SearchProcAddress(hDLL,W2A(bstrMethod))))
      {
        // Load the tags describing the procedure
        hr = S_OK;
        for (int i = cArgs-3; i >= 0 && SUCCEEDED(hr); i--)
          hr = GetTags(rgvarg[i].bstrVal);
      }
    }
    if (SUCCEEDED(hr))
      dispid = ++dispidLastUsed; // Assign a dispid
    if (pVarResult) // Return result if requested by caller
    {
      V_VT(pVarResult) = VT_BOOL;
      V_BOOL(pVarResult) = SUCCEEDED(hr);
    }
    return hr;
  }

  // Parse the tags
  HRESULT GetTags(LPWSTR wstrParms)
  {
    while (*wstrParms && iswspace(*wstrParms))
      wstrParms++;
    *wstrParms = towlower(*wstrParms);

    // Find the tag, check format and invoke callback
    int len = lstrlenW(wstrParms);
    UINT i = FindIndexOfTag(*wstrParms);
    if ((i == -1) || (len < 3) || (wstrParms[1] != L'='))
      return E_INVALIDARG;
    wstrParms += 2;
    return TagInfo[i].pfn(this,wstrParms,len-2);
  }

  // Invokes the procedure
  HRESULT Invoke(DISPPARAMS* pDispParams, VARIANT* pVarResult)
  {
    // Check argument count
    if (cArgs != pDispParams->cArgs)
      return DISP_E_BADPARAMCOUNT;

    HRESULT hr = S_OK;

    // Allocate DYNPARM structure on stack
    DYNAPARM* Parms = (DYNAPARM*)_alloca(sizeof(DYNAPARM)*cArgs);
    ZeroMemory(Parms,sizeof(DYNAPARM) * cArgs);
    DYNAPARM* Parm = Parms + (cArgs - 1); // Work last to first
    VARIANTARG* rgvarg = pDispParams->rgvarg;

    VARIANT va;
    VariantInit(&va);

    // Fill in each DYNPARM entry
    for (UINT i = 0; (i < cArgs) && !FAILED(hr); i++, Parm--)
    {
      // Parameter width from table
      Parm->nWidth = ArgInfo[iArg[i]].size; 
      if (Parm->nWidth > 4)
        Parm->dwFlags = DC_FLAG_ARGPTR;

      // Parameter value
      VariantClear(&va);
      hr = VariantChangeType(&va,&rgvarg[i],0,ArgInfo[iArg[i]].vt);
      if (SUCCEEDED(hr))
      {
        if (Parm->dwFlags & DC_FLAG_ARGPTR)
        {
          Parm->pArg = _alloca(Parm->nWidth);
          CopyMemory(Parm->pArg,&va.byref,Parm->nWidth);
        }
        else
          Parm->pArg = va.byref;
      }
      else
      {
        // Cases for which VariantChangeType doesn't work
        hr = S_OK;
        switch (ArgInfo[iArg[i]].vt)
        {
        case (VT_I4): // Handle
          if (rgvarg[i].vt <= VT_NULL)
            Parm->pArg = 0;
          else
            hr = E_INVALIDARG;
          break;

        case (VT_LPSTR):
          Parm->pArg = W2A(rgvarg[i].bstrVal);
          break;

        case (VT_LPWSTR):
          Parm->pArg = rgvarg[i].bstrVal;
          break;

        default:
          hr = E_INVALIDARG;
          break;
        }
      }
    }

    // Make the dynamic call
    RESULT rc;
    if (SUCCEEDED(hr))
      rc = DynaCall(wFlags,dwAddress,cArgs,Parms,NULL,0);

    // Get the return value if requested
    if (pVarResult)
    {
      CopyMemory(&pVarResult->lVal,&rc.Long,ArgInfo[iRet].size);
      pVarResult->vt = ArgInfo[iRet].vt;
    }

    // Cleanup
    VariantClear(&va);

    // Done
    return hr;
  }

  BSTR bstrMethod;   // Name of procedure
  DISPID dispid;     // Assigned DISPID
  HINSTANCE hDLL;    // Handle to DLL containing procedure
  DWORD dwAddress;   // Address of procedure
  WORD wFlags;       // Flags describing calling convention
  UINT cArgs;        // Number of arguments
  LPUINT iArg;       // Indexes to input arguments
  UINT iRet;         // Index of return type
  CDynCall* pNext;   // Pointer to next object in chain
};

// Parses the input arguments (i=)
HRESULT iParse(CDynCall* pThis, LPWSTR w, int c)
{
  pThis->iArg = new UINT[c];
  pThis->cArgs = c;
  UINT* p = pThis->iArg + (c - 1);
  for (; *w; w++)
  {
    UINT j = FindIndexOfArg(towlower(*w));
    if (j == -1)
      return E_INVALIDARG;
    if (p)
      *p = j;
    p--;
  }
  return S_OK;
}

// Parses the return argument (r=)
HRESULT rParse(CDynCall* pThis, LPWSTR w, int c)
{
  pThis->iRet = FindIndexOfArg(towlower(*w));
  return (pThis->iRet != -1) ? S_OK : E_INVALIDARG;
}

// Parses the calling convention flags (f=)
HRESULT fParse(CDynCall* pThis, LPWSTR w, int c)
{
  for (; *w; w++)
  {
    UINT i = FindIndexOfFlag(towlower(*w));
    if (i == -1)
      return E_INVALIDARG;
    pThis->wFlags = 
      (pThis->wFlags & FlagInfo[i].wMask) | FlagInfo[i].wFlag;
  }
  return S_OK;
}

// CDynCallChain class manages a simple CDynCall linked-list
class CDynCallChain
{
public:
  // ctor/dtor
  CDynCallChain() : m_pFirst(NULL)
  { }
  ~CDynCallChain()
  { 
    while (m_pFirst)
    {
      CDynCall* p = m_pFirst;
      m_pFirst = m_pFirst->pNext;
      delete p;
    }
  }

  // Find the DISPID for the given name s
  DISPID FindDISPID(LPWSTR s)
  {
    CDynCall* p = Find(s);
    if (p)
      return p->dispid;
    else if (!lstrcmpiW(s,L"Register"))
      return REGISTERDISPID;
    return DISPID_UNKNOWN;
  }

  // Register the procedure (creates a new CDynCall object and
  // adds it to the chain)
  HRESULT Register(DISPPARAMS* pDispParams, VARIANT* pVarResult)
  {
    CDynCall* p = new CDynCall;
    if (!p)
      return E_OUTOFMEMORY;
    HRESULT hr = p->Register(pDispParams,pVarResult);
    if (SUCCEEDED(hr))
    {
      p->pNext = m_pFirst;
      m_pFirst = p;
    }
    else
      delete p;
    return hr;
  }

  // Invoke the procedure identifies by dispid
  HRESULT Invoke(DISPID dispid, DISPPARAMS* pParams, 
                 VARIANT* pResult)
  {
    CDynCall* p = Find(dispid);
    if (p)
      return p->Invoke(pParams,pResult);
    else if (dispid == REGISTERDISPID)
      return Register(pParams,pResult);
    return DISPID_UNKNOWN;
  }

protected:
  // Find CDynCall object in chain with value l of type T
  template <class T> CDynCall* Find(T l)
  {
    CDynCall* p = nullptr;
    for (p = m_pFirst; p; p = p->pNext)
    {
      if (*p == l)
        break;
    }
    return p;
  }

protected:
  CDynCall* m_pFirst; // First object in chain
};

// Template class that provides basic IUnknown implementation
template <class T, const IID* piid>
class CInterface : public T
{
public:
  CInterface() : m_dwRef(0)
  { m_Server.m_dwRef++; }
  virtual ~CInterface()
  { m_Server.m_dwRef--; }

  STDMETHOD(QueryInterface)(REFIID riid, void** ppvObject)
  {
    if ((riid == IID_IUnknown) || (riid == *piid))
    {
      *ppvObject = (T*)static_cast<T*>(this);
      m_dwRef++;
      return S_OK;
    }
    return E_NOINTERFACE;
  }
  STDMETHOD_(ULONG,AddRef)()
  { return ++m_dwRef; }
  STDMETHOD_(ULONG,Release)()
  {
    if (!(--m_dwRef))
    {
      delete this;
      return 0;
    }
    return m_dwRef;
  }
  DWORD m_dwRef;
};


// COM class that provides for registering and invoking
// dynamic procedure calls
class CDynamicWrapper : public CInterface<IDispatch,&IID_IDispatch>
{
// IDispatch interface implementation
public:
    // These methods not implemented
    STDMETHOD(GetTypeInfoCount)(UINT* pctinfo)
    { return E_NOTIMPL;  }
    STDMETHOD(GetTypeInfo)(UINT, LCID, ITypeInfo**)
    { return E_NOTIMPL;  }

    // Defer to CDynCallChain for everything else
    STDMETHOD(GetIDsOfNames)(REFIID, LPOLESTR* rgszNames, 
               UINT cNames, LCID, DISPID* rgDispId)
    {
      for (UINT i = 0; i < cNames; i++)
      {
        rgDispId[i] = m_Chain.FindDISPID(rgszNames[i]);
        if (rgDispId[i] == DISPID_UNKNOWN)
          return DISP_E_MEMBERNOTFOUND;
      }
      return S_OK;
    }
    STDMETHOD(Invoke)(DISPID dispIdMember, REFIID, LCID, WORD, 
            DISPPARAMS* pDispParams, VARIANT* pVarResult,
            EXCEPINFO* pExcepInfo, UINT *puArgErr)
    {
      return m_Chain.Invoke(dispIdMember,pDispParams,pVarResult);
    }

protected:
  CDynCallChain m_Chain;
};

// Class factory to create CDynamicWrapper COM objects
class CClassFactory : 
  public CInterface<IClassFactory,&IID_IClassFactory>
{
public:
// IClassFactory interface implementation
  STDMETHOD(CreateInstance)(IUnknown* pUnkOuter, REFIID riid, 
                void** ppvObject)
  {
    if (pUnkOuter)
      return CLASS_E_NOAGGREGATION;
    CDynamicWrapper* pObject = new CDynamicWrapper;
    HRESULT hr = pObject->QueryInterface(riid,ppvObject);
    if (FAILED(hr))
      delete pObject;
    return hr;
  }
  STDMETHOD(LockServer)(BOOL fLock)
  { return CoLockObjectExternal(this,fLock,TRUE); }
};

// DllMain
extern "C"
BOOL WINAPI DllMain(HINSTANCE hInstance, DWORD dwReason, LPVOID)
{
  if (dwReason == DLL_PROCESS_ATTACH)
  {
    m_Server.m_hInstance = hInstance;
    DisableThreadLibraryCalls(hInstance);
  }
  return TRUE;
}

// Required COM in-proc server exports follow
STDAPI DllRegisterServer(void)
{
    HRESULT hr = E_FAIL;
    HKEY key = NULL;
    if (!RegCreateKey(HKEY_CLASSES_ROOT,CLASSKEY1,&key))
    {
        char szModulePath[_MAX_PATH];
        GetModuleFileName(m_Server.m_hInstance,szModulePath, _MAX_PATH);
        if(!RegSetValue(key,NULL,REG_SZ,szModulePath,0))
        {
            RegCloseKey(key);
            if (!RegCreateKey(HKEY_CLASSES_ROOT,PRODIDKEY1,&key))
            {
                if (!RegSetValue(key, NULL, REG_SZ, CLSIDVAL, 0)) {
                    hr = S_OK;
                }
            }
        }
    }
    RegCloseKey(key);
    return hr;
}

STDAPI DllUnregisterServer(void)
{
    // Based on:
    //   https://stackoverflow.com/questions/33207470/what-is-the-difference-between-shdeletekey-and-regdeletetree

    // Windows Vista+
    //RegDeleteTree(HKEY_CLASSES_ROOT, CLASSKEY0);
    //RegDeleteTree(HKEY_CLASSES_ROOT, PRODIDKEY0);

    // Windows XP+
    SHDeleteKey(HKEY_CLASSES_ROOT, CLASSKEY0);
    SHDeleteKey(HKEY_CLASSES_ROOT, PRODIDKEY0);

    return S_OK;
}

STDAPI DllGetClassObject(REFCLSID rclsid, REFIID riid, LPVOID* ppv)
{
  const GUID CLSID_DynWrap = { 0x202774d1, 0xd479, 0x11d1, 
      { 0xac, 0xd1, 0x0, 0xa0, 0x24, 0xbb, 0xb0, 0x5e } };
  HRESULT hr = CLASS_E_CLASSNOTAVAILABLE;
  if (rclsid == CLSID_DynWrap)
  {
    CClassFactory* pFactory = new CClassFactory;
    if (FAILED(hr = pFactory->QueryInterface(riid,ppv)))
      delete pFactory;
    hr = S_OK;
  }
  return hr;
}

STDAPI DllCanUnloadNow()
{
  return (m_Server.m_dwRef) ? S_FALSE : S_OK;
}
