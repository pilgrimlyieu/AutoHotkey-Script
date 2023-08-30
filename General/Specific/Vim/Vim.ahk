#NoTrayIcon

SetTitleMatchMode "RegEx"
SetWinDelay 0
MonitorGetWorkArea( , , , &WorkAreaInfoRight, &WorkAreaInfoBottom)

; 请将 Vim 目录放 PATH

IsNotEnglishMode() {
    DetectHiddenWindows True
    hWnd := winGetID("A")
    result := SendMessage(
        0x283, ; Message: WM_IME_CONTROL
        0x001, ; wParam : IMC_GETCONVERSIONMODE
        0    , ; lParam : (NoArgs)
             , ; Control : (Window)
        ; Retrieves the default window handle to the IME class.
        "ahk_id " DllCall("imm32\ImmGetDefaultIMEWnd", "Uint", hWnd, "Uint")
    )
    DetectHiddenWindows False
    return result
}

ListJoin(list, string) {
    for index, content in list
        str .= string . content
    return SubStr(str, StrLen(string) + 1)
}

#HotIf !WinActive("ahk_class Vim")

!q::{
    ClipSaved := ClipboardAll()
    A_Clipboard := ""
    SendInput("{Ctrl Down}c{Ctrl Up}")
    clip_result := ClipWait(0.5, 0)
    if InStr(A_Clipboard, "`r`n")
        Run("gvim -d `"" ListJoin(StrSplit(A_Clipboard, "`r`n"), "`" `"") "`"", , , &process_id)
    else if clip_result
        Run("gvim `"" A_Clipboard "`"", , , &process_id)
    else
        Run("gvim", , , &process_id)
    ProcessSetPriority("High", process_id)
    WinWait("ahk_pid " process_id, , 10)
    WinSetStyle(-0xC40000, "ahk_pid " process_id)
    WinMove(0, 0, WorkAreaInfoRight, WorkAreaInfoBottom, "ahk_pid " process_id)
    WinActivate("ahk_pid " process_id)
    A_Clipboard := ClipSaved
    ClipSaved := ""
}

#HotIf WinActive("^(i|s|v|V)") && WinActive("ahk_class Vim")

CapsLock::SendInput("{Alt Down}{F12}{Alt Up}")
+CapsLock::SendInput("{Alt Down}{Shift Down}{F12}{Shift Up}{Alt Up}")
^CapsLock::SendInput("{Ctrl Down}{Alt Down}{F12}{Alt Up}{Ctrl Up}")
^+CapsLock::SendInput("{Ctrl Down}{Shift Down}{Alt Down}{F12}{Alt Up}{Shift Up}{Ctrl Up}")

#HotIf WinActive("^i") && WinActive("ahk_class Vim") && IsNotEnglishMode()

#Hotstring * C0 ? X

::jkk::SendInput("{Esc}")
::kjj::SendInput("{Esc}")