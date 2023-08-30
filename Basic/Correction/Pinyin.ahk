#NoTrayIcon

IsChineseMode() {
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
    return result == 1025
}

#HotIf IsChineseMode()
#Hotstring c r * ?
; ui <-> iu
::mui::miu
::nui::niu
::lui::liu
::jui::jiu
::qui::qiu
::xui::xiu

::tiu::tui
::giu::gui
::kiu::kui
::hiu::hui
::riu::rui
::ziu::zui
::ciu::cui
::siu::sui

::enng::neng
::emng::meng
::enmg::meng