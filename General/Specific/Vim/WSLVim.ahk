#NoTrayIcon

#Include ..\..\..\Library\IME.ahk

SetTitleMatchMode "RegEx"

SetTimer(SmartWSLVimIMELang, 100)

global IME_language := 1 ; 1: 中文, 0: 英文
global LShift_down_timestamp  := 0
global LShift_are_not_pressed := 1

SmartWSLVimIMELang() {
    static Mode := 1 ; 1: 插入 0: 命令
    if WinActive("ahk_exe WindowsTerminal.exe") && WinActive(".*✏️[iR]$") && (GetIMELang() != IME_language) {
        IME_language ? Switch2Chinese() : Switch2English()
        Mode := 1
    }
    else if WinActive("ahk_exe WindowsTerminal.exe") && WinActive(".*✏️[^iR]$") && Mode {
        Switch2English()
        Mode := 0
    }
}

#HotIf WinActive(".*✏️[iR]$") && WinActive("ahk_exe WindowsTerminal.exe")

; https://www.autohotkey.com/boards/viewtopic.php?p=36881#p36881
$~*LShift::{
    global LShift_down_timestamp, LShift_are_not_pressed
    if !LShift_down_timestamp
        LShift_down_timestamp := A_TickCount
    if LShift_are_not_pressed
        LShift_are_not_pressed := !(GetKeyState("Control", "P") ||  GetKeyState("Alt", "P") || GetKeyState("LWin", "P") || GetKeyState("RWin", "P"))
}

$~LShift Up::{
    global IME_language, LShift_down_timestamp, LShift_are_not_pressed
    if (A_PriorKey ~= "[LR]Shift") && !LShift_are_not_pressed && (A_TickCount - LShift_down_timestamp < 200) {
        IME_language := !IME_language
        SendInput("{LShift}")
    }
    LShift_down_timestamp  := 0
    LShift_are_not_pressed := 1
}