; #NoTrayIcon

global SHUTDOWNTIME := "233000" ; HHMMSS format
global WARNSTAGES := [ ; minutes
    30,
    15,
    10,
    5,
    3,
    1,
    0, ; NECCESARY
]
global ENTENDMINS := [
    5,
    10,
    15,
]
global EXTENDMAX := ENTENDMINS.Length
global TIMETOSHUTDOWN := A_YYYY . A_MM . A_DD . SHUTDOWNTIME
global EXTENDLEVEL := EXTENDMAX

secondsToWarn(warn_min) {
    global TIMETOSHUTDOWN
    return DateDiff(DateAdd(TIMETOSHUTDOWN, -warn_min, "Minutes"), A_Now, "Seconds")
}

warnAndShutdown(warn_min) {
    global EXTENDLEVEL, TIMETOSHUTDOWN
    delta_time := secondsToWarn(warn_min)
    if delta_time > 0 {
        SetTimer(, -delta_time)
    } else if delta_time <= 0 {
        if warn_min {
            if EXTENDLEVEL > 0 {
                if_extend := MsgBox(Format("还有 {1} 分钟关机！请注意保存重要内容！是否要延长 {2} 分钟关机？", warn_min, ENTENDMINS[EXTENDLEVEL]), "关机提示", "YesNo Icon? 0x1000 T10")
                if (if_extend == "Yes" || if_extend == "Timeout") {
                    try {
                        TIMETOSHUTDOWN := DateAdd(TIMETOSHUTDOWN, ENTENDMINS[EXTENDLEVEL--], "Minutes")
                        SetTimer(, -secondsToWarn(warn_min))
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

for , warn_time in WARNSTAGES {
    SetTimer(warnAndShutdown.Bind(warn_time), -secondsToWarn(warn_time))
}