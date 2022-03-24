#IfWinActive ahk_exe G:\Movable Computer\Movable Software\Program Files\Anki\anki.exe
Cloze(keep := 0) {
    Global turn
    Send {Ctrl Down}x{Ctrl Up}
    Clipboard := Trim(Clipboard)
    if (Clipboard = "") {
        if (keep and turn != 1)
            turn --
        Clipboard := "{{c" turn "::" back "}} "
        Send {Ctrl Down}v{Ctrl Up}{Left 3}
        turn ++
    }
    else if (InStr(Clipboard, "{{c", 1) = 1 and SubStr(Clipboard, -1, 2) = "}}" and InStr(Clipboard, "::") > 4) {
        Clipboard := SubStr(Clipboard, InStr(Clipboard, "::") + 2, StrLen(clipboard) - 8)
        Send {Ctrl Down}v{Ctrl Up}
    }
    else {
        if (keep and turn != 1)
            turn --
        back := ""
        if (SubStr(clipboard, 0) = "}")
            back := " "
        clipboard := "{{c" turn "::" clipboard back "}} "
        Send {Ctrl Down}v{Ctrl Up}
        turn ++
    }
    Clipboard := ""
}
turn := 1

!c::
Cloze()
return

^+c::
Cloze(1)
return

+c::
turn := 1
return
#IfWinActive