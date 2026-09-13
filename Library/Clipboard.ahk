GetSelectedPath(wait := 0.5) {
    ClipSaved := ClipboardAll(), A_Clipboard := ""
    if WinActive("ahk_exe Code.exe")
        SendInput("{Alt Down}{Shift Down}c{shift Up}{Alt Up}")
    else if WinActive("ahk_exe clion64.exe") || WinActive("ahk_exe pycharm64.exe")
        SendInput("{Ctrl Down}{Alt Down}{Shift Down}q{Shift Up}{Alt Up}{Ctrl Up}") ; User defined shortcut in CLion/PyCharm; Ctrl+Shift+C has been taken by other function
    else
        SendInput("{Ctrl Down}c{Ctrl Up}")
    ClipWait(wait, 0)
    return {
        saved: ClipSaved,
        path:  Trim(A_Clipboard),
    }
}
