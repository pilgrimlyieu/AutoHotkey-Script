GetSelectedText(wait := 0.5) {
    ClipSaved := ClipboardAll(), A_Clipboard := ""
    if WinActive("ahk_exe Code.exe")
        SendInput("{Alt Down}{Shift Down}c{shift Up}{Alt Up}")
    else
        SendInput("{Ctrl Down}c{Ctrl Up}")
    ClipWait(0.5, 0)
    return [ClipSaved, Trim(A_Clipboard)]
}