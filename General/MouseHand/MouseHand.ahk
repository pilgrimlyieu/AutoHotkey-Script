#NoTrayIcon

global LBKeyNum := 600, CheckMins := 30, BreakSeconds := 60, ForceSeconds := 30

~LButton::
KeyLeftButton(ThisHotkey) {
    static LButton_key_num := 0
    if (LButton_key_num > 0) {
        LButton_key_num += 1
        return
    }
    LButton_key_num := 1
    SetTimer LockMouse, -60000 * CheckMins

    LockMouse() {
        if (LButton_key_num >= LBKeyNum) {
            BlockInput "MouseMove"
            MsgBox "已经高强度使用鼠标 " CheckMins " 分钟了，活动一下手吧！可在休息至少 " ForceSeconds "s 后按 Esc 键退出锁定模式。", "休息锁定模式", "Icon! 0x1000 T5"
            UnlockMouse(ThisHotkey) => BlockInput("MouseMoveOff")
            SetTimer () => Hotkey("~Esc", UnlockMouse, "On"), -1000 * ForceSeconds
            SetTimer () => Hotkey("~Esc", UnlockMouse, "Off"), -1000 * BreakSeconds
            SetTimer () => UnlockMouse, -1000 * BreakSeconds
        }
        LButton_key_num := 0
    }
}