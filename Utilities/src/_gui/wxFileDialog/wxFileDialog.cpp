#include <cstdlib>
#include <iostream>

#include <wx/init.h>
#include <wx/app.h> 
#include <wx/filedlg.h>
#include <wx/dirdlg.h>
#include <wx/string.h>
#include <wx/arrstr.h>

#include "common.hpp"

#include "wxFileDialog.hpp"

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
        bool hadFlag_o = true; // Open file by default
        bool hadFlag_s = false;
        bool hadFlag_p = false;
        bool hadFlag_n = false;
        bool hadFlag_e = false;
        bool hadFlag_m = false;
        bool hadFlag_w = false;
        bool hadFlag_d = false;

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
                wchar_t * flagChar = &argv[4][0];
                while (*flagChar) {
                    if (*flagChar == L'o') {
                        // the last position has priority
                        hadFlag_s = false;
                        hadFlag_o = true;
                    }
                    else if (*flagChar == L's') {
                        // the last position has priority
                        hadFlag_o = false;
                        hadFlag_s = true;
                    }
                    else if (*flagChar == L'p') {
                        hadFlag_p = true;
                    }
                    else if (*flagChar == L'n') {
                        hadFlag_n = true;
                    }
                    else if (*flagChar == L'e') {
                        hadFlag_e = true;
                    }
                    else if (*flagChar == L'm') {
                        hadFlag_m = true;
                    }
                    else if (*flagChar == L'w') {
                        hadFlag_w = true;
                    }
                    else if (*flagChar == L'd') {
                        hadFlag_d = true;
                    }

                    ++flagChar;
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

        if (!hadFlag_d) {
            wxFileDialog * file_dialog = new wxFileDialog(NULL, title, start_folder, wxEmptyString, file_types,
                (hadFlag_o ? wxFD_OPEN : wxFD_SAVE) |
                (hadFlag_p ? wxFD_OVERWRITE_PROMPT : 0) |
                (hadFlag_n ? wxFD_NO_FOLLOW : 0) |
                (hadFlag_e ? wxFD_FILE_MUST_EXIST : 0) |
                (hadFlag_m ? wxFD_MULTIPLE : 0) |
                (hadFlag_w ? wxFD_PREVIEW : 0));
            if (file_dialog->ShowModal() == wxID_OK) {
                wxArrayString selected_paths;
                file_dialog->GetPaths(selected_paths);
                for (size_t i = 0; i < selected_paths.size(); i++) {
                    puts(selected_paths[i].c_str());
                }
                ret = 0;
            }
            else {
                ret = -1;
            }
        }
        else {
            wxDirDialog * dir_dialog = new wxDirDialog(NULL, title, start_folder,
                wxDD_DEFAULT_STYLE |
                (hadFlag_e ? wxDD_DIR_MUST_EXIST : 0));
            if (dir_dialog->ShowModal() == wxID_OK) {
                const wxString selected_path = dir_dialog->GetPath();
                puts(selected_path.c_str());
                ret = 0;
            }
            else {
                ret = -1;
            }
        }
    }

    wxEntryCleanup();

    return ret;
}
