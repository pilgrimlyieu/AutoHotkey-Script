GetIMEMode() {
    DetectHiddenWindows True
    hWnd := winGetID("A")
    result := SendMessage(0x283, 0x001, 0, , "ahk_id " DllCall("imm32\ImmGetDefaultIMEWnd", "Uint", hWnd, "Uint"))
    DetectHiddenWindows False
    return result
}

IsChineseMode() => GetIMEMode() == 1025
IsNotChineseMode() => GetIMEMode() != 1025
IsEnglishMode() => GetIMEMode() == 0
IsNotEnglishMode() => GetIMEMode() != 0