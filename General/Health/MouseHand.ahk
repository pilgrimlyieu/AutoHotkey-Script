#NoTrayIcon
SetMouseDelay -1

global LBKeyNum := 600, LimitMins := 30, BreakSeconds := 60, ForceSeconds := 30

~LButton::
KeyLeftButton(ThisHotkey) {
    static LButton_key_num := 0, start_time := A_Now
    if LButton_key_num == 0
        return (start_time := A_Now, LButton_key_num++)
    else if 0 < LButton_key_num && LButton_key_num < LBKeyNum
        return LButton_key_num++
    else {
        if (tired_mins := DateDiff(A_Now, start_time, "Minutes")) <= LimitMins {
            BlockInput("MouseMove")
            MsgBox("已经高强度使用鼠标 " tired_mins " 分钟了，活动一下手吧！可在休息至少 " ForceSeconds "s 后按 Esc 键退出锁定模式。", "休息锁定模式", "Icon! 0x1000 T5")
            SetTimer(() => Hotkey("~Esc", (*) => BlockInput("MouseMoveOff"), "On"), -1000 * ForceSeconds)
            SetTimer(() => Hotkey("~Esc", (*) => BlockInput("MouseMoveOff"), "Off"), -1000 * BreakSeconds)
            SetTimer(() => BlockInput("MouseMoveOff"), -1000 * BreakSeconds)
        }
        LButton_key_num := 0, start_time := A_Now
    }
}