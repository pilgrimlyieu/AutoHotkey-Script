#NoTrayIcon

#Include ..\..\..\Library\IME.ahk

SetTitleMatchMode "RegEx"

SetTimer(SmartWSLVimIMELang, 100)

global IME_Lang := 1 ; 1: 中文, 0: 英文

SmartWSLVimIMELang() {
    static Mode := 1 ; 1: 插入 0: 命令
    if WinActive("ahk_exe WindowsTerminal.exe") && WinActive("^[iR]🏷️.*✏️$") && GetIMELang() != IME_Lang {
        IME_Lang ? Switch2Chinese() : Switch2English()
        Mode := 1
    }
    else if WinActive("ahk_exe WindowsTerminal.exe") && WinActive("^[^iR]🏷️.*✏️$") && Mode {
        Switch2English()
        Mode := 0
    }
}

#HotIf WinActive("^[iR]🏷️.*✏️$") && WinActive("ahk_exe WindowsTerminal.exe")
~Shift::global IME_Lang := !IME_Lang
