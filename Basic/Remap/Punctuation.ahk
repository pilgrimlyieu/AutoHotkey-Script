#NoTrayIcon

#HotIf !WinActive("ahk_exe Mathematica.exe")
![::SendInput("「")
!]::SendInput("」")
!+[::SendInput("『")
!+]::SendInput("』")
