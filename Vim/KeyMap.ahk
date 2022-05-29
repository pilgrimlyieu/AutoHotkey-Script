#NoTrayIcon

#IfWinActive ahk_class Vim
CapsLock::SendInput {Alt Down}v{Alt Up}
