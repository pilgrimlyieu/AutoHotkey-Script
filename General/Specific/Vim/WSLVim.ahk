#NoTrayIcon

#Include ..\..\..\Library\IME.ahk

SetTitleMatchMode "RegEx"

SetTimer(SmartWSLVimIMELang, 100)

global IME_Lang := 1 ; 1: 中文, 0: 英文

SmartWSLVimIMELang() {
    static Mode := 1 ; 1: 插入 0: 命令
    if WinActive("ahk_exe WindowsTerminal.exe") && WinActive(".*✏️[iR]$") && GetIMELang() != IME_Lang {
        IME_Lang ? Switch2Chinese() : Switch2English()
        Mode := 1
    }
    else if WinActive("ahk_exe WindowsTerminal.exe") && WinActive(".*✏️[^iR]$") && Mode {
        Switch2English()
        Mode := 0
    }
}

#HotIf WinActive(".*✏️[iR]$") && WinActive("ahk_exe WindowsTerminal.exe")
; ~Shift::global IME_Lang := !IME_Lang

global LShift_down_timestamp := 0
global LShift_modifiers_are_pressed := false

; Solution from https://www.autohotkey.com/boards/viewtopic.php?p=36881#p36881
$~*LShift::{
    global LShift_down_timestamp, LShift_modifiers_are_pressed
    if !LShift_down_timestamp
        LShift_down_timestamp := A_TickCount
    if !LShift_modifiers_are_pressed
        LShift_modifiers_are_pressed := GetKeyState("Control", "P") ||  GetKeyState("Alt", "P") || GetKeyState("LWin", "P") || GetKeyState("RWin", "P")
}

$~LShift Up::{
    global LShift_down_timestamp, LShift_modifiers_are_pressed
    if (A_PriorKey ~= "LShift|RShift") && (!LShift_modifiers_are_pressed) && (A_TickCount - LShift_down_timestamp < 200) {
        global IME_Lang := !IME_Lang
        SendInput("{LShift}")
    }
    LShift_down_timestamp := 0
    LShift_modifiers_are_pressed := false
}
