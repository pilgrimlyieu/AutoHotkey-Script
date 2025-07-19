; #NoTrayIcon
#SingleInstance Force

#Include ..\..\..\Library\IME.ahk

SetTitleMatchMode "RegEx"

global IME_language := 1 ; 1: 中文, 0: 英文

SetTimer(SmartWSLVimIMELang, 50)

Switch2Language(lang) {
    if (lang == 1)
        Switch2Chinese()
    else if (lang == 0)
        Switch2English()
}

SmartWSLVimIMELang() {
    static last_vim_mode := 0 ; 1: 插入 0: 命令
    if WinActive("ahk_exe WindowsTerminal.exe") && WinActive(".*✏️[iR]$") {
        if (last_vim_mode == 0)
            Switch2Language(IME_language)
        last_vim_mode := 1
    } else if WinActive("ahk_exe WindowsTerminal.exe") && WinActive(".*✏️[^iR]$") {
        if (last_vim_mode == 1)
            Switch2English()
        last_vim_mode := 0
    }
}

#HotIf WinActive(".*✏️[iR]$") && WinActive("ahk_exe WindowsTerminal.exe")

; https://www.autohotkey.com/boards/viewtopic.php?p=36881#p36881
global LShift_down_timestamp := 0
global LShift_are_not_pressed := 1

$~*LShift:: {
    global LShift_down_timestamp, LShift_are_not_pressed
    if !LShift_down_timestamp
        LShift_down_timestamp := A_TickCount
    if LShift_are_not_pressed
        LShift_are_not_pressed := !(GetKeyState("Control", "P") || GetKeyState("Alt", "P") || GetKeyState("LWin", "P") ||
        GetKeyState("RWin", "P"))
}

$~LShift Up:: {
    global IME_language, LShift_down_timestamp, LShift_are_not_pressed
    if (A_PriorKey ~= "[LR]Shift") && LShift_are_not_pressed && (A_TickCount - LShift_down_timestamp < 300) {
        IME_language := !IME_language
    }
    LShift_down_timestamp := 0
    LShift_are_not_pressed := 1
}

