#NoTrayIcon

Process Priority, , Realtime
SetWinDelay -1

VIMPATH := "D:\Program Files\Vim\vim90"

IsNotEnglish() {
    DetectHiddenWindows On
    WinGet winid, ID, A
    wintitle := "ahk_id " DllCall("imm32\ImmGetDefaultIMEWnd", "Uint", winid, "Uint")
    SendMessage 0x283, 0x001, 0, , %wintitle%
    DetectHiddenWindows Off
    return ErrorLevel
}

#IfWinNotActive ahk_class Vim

!q::
Clip := ClipboardAll
Clipboard := ""
SendInput {Ctrl Down}c{Ctrl Up}
ClipWait 0
if !(ErrorLevel or InStr(Clipboard, "`r"))
    Run gvim.exe "%Clipboard%", %VIMPATH%, , process_id
else if (Clipboard = "")
    Run gvim.exe, %VIMPATH%, , process_id
Process Priority, %process_id%, High
WinWait ahk_pid %process_id%, , 10
WinSet Style, -0xC40000, ahk_pid %process_id%
WinMove ahk_pid %process_id%, , 0, 0, %A_ScreenWidth%, % A_ScreenHeight - 40
WinActivate ahk_pid %process_id%
Clipboard := Clip
return

#IfWinActive ahk_class Vim

CapsLock::SendInput {Alt Down}t{Alt Up}

#If WinActive("GVim Mode: i") and IsNotEnglish()

#Hotstring * C0 ? X

; ::jj::SendInput {Text}jj
; ::kk::SendInput {Text}kk
::jk::SendInput {Text}jk
::kj::SendInput {Text}kj
