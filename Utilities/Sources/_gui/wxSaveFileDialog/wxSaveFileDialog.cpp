#include <cstdlib>
#include <iostream>

#include <wx/init.h>
#include <wx/app.h> 
#include <wx/filedlg.h>
#include <wx/string.h>

#include "common.hpp"

#include "wxSaveFileDialog.hpp"

#ifndef _UNICODE
#error Non unicode is not supported.
#endif


class MainApp : public wxApp
{
public:
    virtual bool OnInit()
    {
        return TRUE;
    }
};

IMPLEMENT_APP_NO_MAIN(MainApp);
IMPLEMENT_WX_THEME_SUPPORT;

int wmain(int argc, wchar_t * argv[])
{
    int ret = 255;

    //wxInitializer ini;
    //if (!ini.IsOk()) {
    //    return 255;
    //}

    wxEntryStart(argc, argv);
    wxTheApp->CallOnInit();

    if_break (true) {
        if (!argc || !argv[0]) {
            break;
        }

        bool do_show_help = false;

        InArgs in_args = InArgs();

        //<Flags>
        int flags = 0;
        bool hasFlags = false;
        bool hadFlag_p = false;
        bool hadFlag_n = false;

        if(argc >= 2 && argv[1]) {
            if(!wcscmp(argv[1], L"/?")) {
                if (argc >= 3) {
                    ret = 2;
                    break;
                }
                do_show_help = true; // /?
            }
            else {
                in_args.file_types = argv[1];
            }
        }

        if (argc >= 3 && argv[2]) {
            in_args.start_folder = argv[2];
        }

        if (argc >= 4 && argv[3]) {
            in_args.title = argv[3];
        }

        if (argc >= 5 && argv[4]) {
            if (argv[4][0] == '-') {
                hasFlags = true;
                if (wcschr(argv[4], L'p')) {
                    hadFlag_p = true;
                }
                else if (wcschr(argv[4], L'n')) {
                    hadFlag_n = true;
                }
            }
        }

        if(do_show_help) {
            ::puts(
#include "help_inl.hpp"
            );

            ret = 1;
            break;
        }

        const wxString file_types    = in_args.file_types ? in_args.file_types : wxEmptyString;
        const wxString start_folder  = in_args.start_folder ? in_args.start_folder : L".";
        const wxString title         = in_args.title ? in_args.title : wxEmptyString;

        wxString selected_path;

        wxFileDialog * open_dialog = new wxFileDialog(NULL, title, start_folder, wxEmptyString, file_types, wxFD_SAVE);
        if (open_dialog->ShowModal() == wxID_OK) {
            selected_path = open_dialog->GetPath();
            puts(selected_path.c_str());
            ret = 0;
        }
        else {
            ret = -1;
        }
    }

    wxEntryCleanup();

    return ret;
}
