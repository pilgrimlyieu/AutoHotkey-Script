#Include "CleanPaste.ahk"

Cloze(keep := 0, space := 1) {
    global turn
    ClipSaved := ClipboardAll(), A_Clipboard := ""
    SendInput("{Ctrl Down}x{Ctrl Up}")
    ClipWait(0.5, 0)
    Text := space ? A_Clipboard : Trim(A_Clipboard, " `t`r`n")
    if !(keep && turn)
        turn++
    if Text == ""
        Result := "{{c" turn "::}}"
    else if (SubStr(Text, 1, 3) == "{{c") && (SubStr(Text, -2) == "}}") && (InStr(Text, "::") > 4) {
        if !(keep && turn)
            turn--
        Result := SubStr(Text, InStr(Text, "::") + 2, StrLen(Text) - 8)
    }
    else
        Result := "{{c" turn "::" StrReplace(StrReplace(Text, "}}", "} }"), "}}", "} }") ((SubStr(Text, -1) = "}") ? " }}" : "}}")
    A_Clipboard := Result
    ClipWait(0.5, 0)
    SendInput("{Ctrl Down}v{Ctrl Up}")
    if Text == ""
        SendInput("{Left 2}")
    Sleep(500)
    A_Clipboard := ClipSaved
}

global turn := 0

#HotIf WinActive("ahk_exe anki.exe")

+f1::global turn := 0
f1::Cloze(1)
f2::Cloze()
`::SendInput("{Text}<br>`n")

#InputLevel 1

+`::SendInput("{Ctrl Down}{Enter}{Ctrl Up}{Shift Down}{F1}{Shift Up}")
