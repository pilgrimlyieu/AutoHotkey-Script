#NoTrayIcon

SetWinDelay -1
Process Priority, , Realtime

#IfWinNotActive ahk_class Vim

!q::
Clip := Clipboard
Clipboard := ""
SendInput {Ctrl Down}c{Ctrl Up}
ClipWait 0
if !(ErrorLevel or InStr(Clipboard, "`r"))
    Run gvim.exe "%Clipboard%", C:\Program Files\Vim\vim82, , process_id
else if (Clipboard = "")
    Run gvim.exe, C:\Program Files\Vim\vim82, , process_id
Process Priority, %process_id%, High
WinWait ahk_pid %process_id%, , 1
WinSet Style, -0x840000, ahk_pid %process_id%
WinMaximize ahk_pid %process_id%
Clipboard := Clip
return
