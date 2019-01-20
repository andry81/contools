#ifndef __COMMON_GUI_WX_FILE_DIALOG_HPP__
#define __COMMON_GUI_WX_FILE_DIALOG_HPP__

#include <version.hpp>
#include <common.hpp>

namespace {

    struct InArgs
    {
        const wchar_t * file_types;
        const wchar_t * start_folder;
        const wchar_t * title;
    };

}

#endif
