; #NoTrayIcon

global WARN_STAGES := [ ; minutes
    30,
    15,
    5,
    0, ; NECESSARY
]
global EXTEND_MINS := [
    5,
    5,
    5,
]
global EXTEND_MAX := EXTEND_MINS.Length
global SHUTDOWN_TIME := "233000" ; HHMMSS format
global TIME_TO_SHUTDOWN := A_YYYY . A_MM . A_DD . SHUTDOWN_TIME
global EXTEND_LEVEL := EXTEND_MAX

msToWarn(warn_min) {
    return DateDiff(DateAdd(TIME_TO_SHUTDOWN, -warn_min, "Minutes"), A_Now, "Seconds") * 1000
}

warnAndShutdown(warn_min) {
    global EXTEND_LEVEL, TIME_TO_SHUTDOWN
    delta_time := msToWarn(warn_min)
    if delta_time > 0 {
        SetTimer(, -delta_time)
    } else {
        if warn_min {
            if EXTEND_LEVEL > 0 {
                if_extend := MsgBox(Format("还有 {1} 分钟关机！请注意保存重要内容！是否要延长 {2} 分钟关机？", warn_min, EXTEND_MINS[EXTEND_LEVEL]), "关机提示", "YesNo Icon? 0x1000 T10")
                if if_extend == "Yes" {
                    try {
                        TIME_TO_SHUTDOWN := DateAdd(TIME_TO_SHUTDOWN, EXTEND_MINS[EXTEND_LEVEL--], "Minutes")
                        SetTimer(, -msToWarn(warn_min))
                    } catch {
                        ToolTip("已经不能再延长关机时间了！")
                        SetTimer(() => ToolTip(), -3000)
                    }
                }
            } else {
                MsgBox(Format("还有 {1} 分钟关机！请注意保存重要内容！", warn_min), "关机提示", "OK Iconi 0x1000 T10")
            }
        } else {
            MsgBox("现在关机或 10 秒后自动关机。", "关机提示", "OK Iconx 0x1000 T10")
            Shutdown(1)
        }
    }
}

for , warn_time in WARN_STAGES {
    if msToWarn(warn_time) > 0 {
        SetTimer(warnAndShutdown.Bind(warn_time), -msToWarn(warn_time))
    }
}
