#NoTrayIcon

#IfWinActive ahk_class Vim
CapsLock::SendInput {Alt Down}t{Alt Up}
