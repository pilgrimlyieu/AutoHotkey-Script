AHK_Dir := "C:/Program Files/AutoHotkey/"

Scripts := [
    {path: "Basic/Abbreviation/Email",     ahk1: 0, admin: 0},
    ; {path: "Basic/Correction/AutoCorrect", ahk1: 1, admin: 0},
    {path: "Basic/Correction/Pinyin",      ahk1: 0, admin: 0},
    ; {path: "Basic/Remap/Fn",               ahk1: 0, admin: 0},
    {path: "Basic/Remap/NumLock",          ahk1: 0, admin: 0},
    {path: "Basic/Remap/Others",           ahk1: 0, admin: 0},
    {path: "Basic/Remap/Punctuation",      ahk1: 0, admin: 0},
    {path: "Basic/Window/WinDrag/main",    ahk1: 1, admin: 0},

    {path: "General/Common/Run",               ahk1: 0, admin: 1},
    {path: "General/Health/MouseHand",         ahk1: 0, admin: 0},
    {path: "General/Health/GoodSleep",         ahk1: 0, admin: 0},
    {path: "General/Specific/Vim/Vim",         ahk1: 0, admin: 0},
    {path: "General/Specific/Vim/WSLVim",      ahk1: 0, admin: 0},
    {path: "General/Specific/Vim/gVIME",       ahk1: 0, admin: 0},
    {path: "General/Specific/VSCode",          ahk1: 0, admin: 0},
    {path: "General/Specific/WindowsTerminal", ahk1: 0, admin: 0},

    ; {path: "Project/Vark/main", ahk1: 0, admin: 0},
]

for index, script in Scripts
    if script.admin
        Run("*RunAs `"" A_WorkingDir "/" script.path ".ahk`"") ; Should add #SingleInstance force in script file
    else {
        if script.ahk1
            Run("`"" AHK_Dir "v1.1.37.02/AutoHotkeyU64.exe`" /restart `"" A_WorkingDir "/" script.path ".ahk1`"")
        else
            Run("`"" AHK_Dir "v2/AutoHotkey.exe`" /restart `"" A_WorkingDir "/" script.path ".ahk`"")
    }
