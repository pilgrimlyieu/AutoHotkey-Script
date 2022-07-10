#NoTrayIcon

Process Priority, , Realtime
SetWinDelay -1

VIMPATH := "D:\Program Files\Vim\vim90"

#IfWinNotActive ahk_class Vim

!q::
Clip := Clipboard
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
WinMove ahk_pid %process_id%, , 0, 0, 1920, 1040
WinActivate ahk_pid %process_id%
Clipboard := Clip
return
