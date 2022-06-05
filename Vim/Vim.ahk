#NoTrayIcon
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
WinWaitActive ahk_pid %process_id%, , 5
WinActivate ahk_pid %process_id%
Clipboard := Clip
return

!v::
Run gvim.exe, C:\Program Files\Vim\vim82, , process_id
Process Priority, %process_id%, High
WinWaitActive ahk_pid %process_id%, , 5
WinActivate ahk_pid %process_id%
return

#IfWinActive ahk_class Vim
!v::Process Priority, gvim.exe, High
