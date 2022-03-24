#NoTrayIcon
Global LBNum := 300, CheckMins := 30, BreakTime := 60, ForceTime := 30
~LButton::
If (LButtonKeyNum > 0) {
    LButtonKeyNum ++
    Return
}
LButtonKeyNum := 1
SetTimer MouseHand, % - 60000 * CheckMins
Return

MouseHand:
If (LButtonKeyNum >= LBNum) {
    MsgBox 4144, 休息锁定模式, 已经高强度使用鼠标 %CheckMins% 分钟了 ，活动一下手吧！可在休息至少 %ForceTime%s 后按 Esc 键退出锁定模式。, 10
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
LButtonKeyNum := 0
Return