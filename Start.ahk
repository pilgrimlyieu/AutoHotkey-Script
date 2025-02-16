#include Library\Start.ahk

AHK_Dir := "C:/Program Files/AutoHotkey/"

Scripts := [
    {path: "Basic/Abbreviation",                admin: 0, dir: 1, recursive: 0},
    ; {path: "Basic/Correction/AutoCorrect.ahk1", admin: 0, dir: 0, recursive: 0},
    {path: "Basic/Correction/Pinyin.ahk",       admin: 0, dir: 0, recursive: 0},
    {path: "Basic/Remap",                       admin: 0, dir: 1, recursive: 0},
    {path: "Basic/Window/WinDrag/main.ahk1",    admin: 0, dir: 0, recursive: 0},

    {path: "General/Common",                       admin: 1, dir: 1, recursive: 0},
    {path: "General/Health",                       admin: 0, dir: 1, recursive: 0},
    {path: "General/Specific/Vim",                 admin: 0, dir: 1, recursive: 0},
    {path: "General/Specific/VSCode.ahk",          admin: 0, dir: 0, recursive: 0},
    {path: "General/Specific/WindowsTerminal.ahk", admin: 0, dir: 0, recursive: 0},

    ; {path: "Project/Vark/main.ahk", admin: 0, dir: 0, recursive: 0},
]

normalizePath(path) {
    return A_WorkingDir "/" path
}

executeScript(path, admin := false) {
    ahkType := path ~= "\.ahk1$" ? -1 : path ~= "\.ahk$" ? 1 : 0
    if (ahkType == 0) {
        return
    }
    if admin
        Run(Format("*RunAs `"{1}`"", path)) ; Should add #SingleInstance force in script file
    else {
        if ahkType == -1
            ; ShellRunAsUser(Format("`"{1}v1.1.37.02/AutoHotkeyU64.exe`" /restart `"{2}`" LAUNCH_FROM_START", AHK_Dir, path))
            ShellRunAsUser(Format("{1}v1.1.37.02/AutoHotkeyU64.exe", AHK_Dir), Format("/restart `"{1}`" LAUNCH_FROM_START", path))
        else if ahkType == 1
            ; ShellRunAsUser(Format("`"{1}v2/AutoHotkey.exe`" /restart `"{2}`" LAUNCH_FROM_START", AHK_Dir, path))
            ShellRunAsUser(Format("{1}v2/AutoHotkey.exe", AHK_Dir), Format("/restart `"{1}`" LAUNCH_FROM_START", path))
    }
}

processItem(item, recursive := false) {
    path := normalizePath(item.path)
    property := FileExist(path)
    if (InStr(property, "D")) {
        loop files path . "/*", recursive ? "R" : "" {
            executeScript(A_LoopFileFullPath, item.admin)
        }
    } else if (property) {
        executeScript(path, item.admin)
    }
}

for index, item in Scripts
    processItem(item, item.recursive)
