#NoTrayIcon

#Include ..\..\..\Library\IME.ahk

SetTimer(gVimIMEwithCompatibility, 50)

gVIME_status  := [1, 0] ; [gvim, others]

gVimIMEwithCompatibility() {
    static ime_compatibility
    ime_compatibility := GetIMECompatibility()
    vimactive := WinActive("ahk_exe gvim.exe")
    if vimactive && (ime_compatibility != gVIME_status[1])
        ChangeIMECompatibility(gVIME_status[1])
    else if !vimactive && (ime_compatibility != gVIME_status[2])
        ChangeIMECompatibility(gVIME_status[2])
}

#F1::ChangeIMECompatibility(gVIME_status[!WinActive("ahk_exe gvim.exe") + 1] := !GetIMECompatibility())
