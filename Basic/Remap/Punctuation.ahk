#NoTrayIcon

#Include ..\..\Library\IME.ahk

#HotIf !WinActive("ahk_exe WolframNB.exe") && (!WinActive("ahk_exe WindowsTerminal.exe") || (WinActive("ahk_exe WindowsTerminal.exe") && IsChinese()))
; #HotIf !WinActive("ahk_exe WolframNB.exe")
![::SendInput("「")
!]::SendInput("」")
!+[::SendInput("『")
!+]::SendInput("』")
