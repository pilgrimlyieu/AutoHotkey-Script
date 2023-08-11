#Requires AutoHotkey v1.1+
#NoTrayIcon

SetTitleMatchMode RegEx
SetWinDelay -1

SysGet WorkAreaInfo, MonitorWorkArea

; 请将 Vim 目录放 PATH

IsNotEnglish() {
    DetectHiddenWindows On
    WinGet winid, ID, A
    wintitle := "ahk_id " DllCall("imm32\ImmGetDefaultIMEWnd", "Uint", winid, "Uint")
    SendMessage 0x283, 0x001, 0, , %wintitle%
    DetectHiddenWindows Off
    return ErrorLevel
}

ListJoin(list, string) {
    for index, content in list
        str .= string . content
    return SubStr(str, StrLen(string) + 1)
}

#IfWinNotActive ahk_class Vim

!q::
Clip := ClipboardAll
Clipboard := ""
SendInput {Ctrl Down}c{Ctrl Up}
ClipWait 0
if InStr(Clipboard, "`r`n")
    Run % "gvim -d """ ListJoin(StrSplit(Clipboard, "`r`n"), """ """) """", , , process_id
else if !ErrorLevel
    Run gvim "%Clipboard%", , , process_id
else
    Run gvim, , , process_id
Process Priority, %process_id%, High
WinWait ahk_pid %process_id%, , 10
WinSet Style, -0xC40000, ahk_pid %process_id%
WinMove ahk_pid %process_id%, , 0, 0, %WorkAreaInfoRight%, %WorkAreaInfoBottom%
WinActivate ahk_pid %process_id%
Clipboard := Clip
return

#If WinActive("^(i|s|v|V)")

CapsLock::SendInput {Alt Down}t{Alt Up}

#If WinActive("^i") and IsNotEnglish()

#Hotstring * C0 ? X

::jkk::SendInput {Esc}
::kjj::SendInput {Esc}
