;@Ahk2Exe-SetMainIcon Shutdown.ico
#NoTrayIcon

Warn(WarnMinute, ExtendLevel, ExtendMinute) {
    Warning := "还有 " WarnMinute " 分钟就要关机！请注意保存重要内容！"
    If ExtendLevel
        Warning .= "是否要延长 " ExtendMinute " 分钟关机？"
    Return Warning
}

Hint(WarnMinute) {
    Global SDTime, ExtendLevel, ExtendMinute
    DeltaTime := SDTime
    DeltaTime -= %A_Now%, Seconds
    Sleep % 1000 * (DeltaTime - WarnMinute * 60)
    If WarnMinute {
        Warning := Warn(WarnMinute, ExtendLevel, ExtendMinute)
        MsgBox % 4416 - ExtendLevel * 28, 即将关机, %Warning%, 10
        IfMsgBox Yes
        {
            SDTime += ExtendMinute, Minutes
            ExtendLevel --
        }
    }
    Else {
        Shutdown 1
    }
}

SDTime := A_Year A_MM A_DD "230000"
WarnMinutes := [5, 3, 1, 0]
ExtendLevel := 1
ExtendMinute := 5
For Index, Min in WarnMinutes
    Hint(Min)