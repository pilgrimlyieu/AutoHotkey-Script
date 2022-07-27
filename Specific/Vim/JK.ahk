#NoTrayIcon

IsNotEnglish() {
    DetectHiddenWindows On
    WinGet winid, ID, A
    wintitle := "ahk_id " DllCall("imm32\ImmGetDefaultIMEWnd", "Uint", winid, "Uint")
    SendMessage 0x283, 0x001, 0, , %wintitle%
    DetectHiddenWindows Off
    return ErrorLevel
}

#If WinActive("GVim Mode: i") and IsNotEnglish()

#Hotstring * C0 ? X

::jj::SendInput {Text}jj
::jk::SendInput {Text}jk
::kj::SendInput {Text}kj
::kk::SendInput {Text}kk
