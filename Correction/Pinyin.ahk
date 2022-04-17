IsChineseMode() {
    DetectHiddenWindows On
    WinGet winid, ID, A
    wintitle := "ahk_id " DllCall("imm32\ImmGetDefaultIMEWnd", "Uint", winid, "Uint")
    SendMessage 0x283, 0x001, 0, , %wintitle%
    DetectHiddenWindows Off
    return ErrorLevel = 1025
}

#If IsChineseMode()
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