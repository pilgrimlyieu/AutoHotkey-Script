#NoTrayIcon
Global LBNum := 300, Ticks := 1800, BreakTime := 60, ForceTime := 30
~LButton::
LButtonKeyNum := 0
Timer := 0
While (LButtonKeyNum < LBNum and Timer < Ticks) {
    KeyWait LButton, DT5
    If !ErrorLevel
        LButtonKeyNum ++
    Timer ++
    Sleep 1000
}
If (LButtonKeyNum = LBNum) {
    MsgBox 4144, 休息一下, 已经高强度持续使用鼠标很久了，活动一下手吧！可在休息至少 %ForceTime%s 后按 Esc 键退出锁定模式。, 10
    CoordMode Mouse
    MouseGetPos XPos, YPos
    Loop % ForceTime {
        Sleep 1000
        MouseMove XPos, YPos
    }
    Loop % BreakTime - ForceTime {
        KeyWait Esc, DT1
        MouseMove XPos, YPos
    } Until !ErrorLevel
}
Return