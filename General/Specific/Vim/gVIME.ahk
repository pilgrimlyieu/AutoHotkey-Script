#NoTrayIcon

#Include ..\..\..\Library\IME.ahk

SetTimer(gVimIMEwithCompatibility, 250)

gVimIMEwithCompatibility() {
    static ime_compatibility
    ime_compatibility := GetIMECompatibility()
    if WinActive("ahk_exe gvim.exe") && !ime_compatibility
        ChangeIMECompatibility(1)
    else if ime_compatibility && !WinActive("ahk_exe gvim.exe")
        ChangeIMECompatibility(0)
}
