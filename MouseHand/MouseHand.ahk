#NoTrayIcon
~LButton::
LButtonKeyNum := 0
Timer := 0
While (LButtonKeyNum < 300 and Timer < 1800) {
    KeyWait LButton, DT5
    If !ErrorLevel
        LButtonKeyNum ++
    Timer ++
    Sleep 1000
}
If (LButtonKeyNum = 300) {
    MsgBox 4144, 休息一下, 已经高强度持续使用鼠标很久了，活动一下手吧！按 Esc 键退出锁定模式。, 10
    CoordMode Mouse
    MouseGetPos XPos, YPos
    Loop 60 {
        KeyWait Esc, DT1
        MouseMove XPos, YPos
        If !ErrorLevel
            Return
    }
}
Return