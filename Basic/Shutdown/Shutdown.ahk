;@Ahk2Exe-SetMainIcon Shutdown.ico
#NoTrayIcon

Warn(WarnMinute) {
    Warning := "还有 " WarnMinute " 分钟就要关机！请注意保存重要内容！"
    If ExtendLevel
        Warning .= "是否要延长 " ExtendMinute " 分钟关机？"
    Return Warning
}

Hint(WarnMinute) {
    DeltaTime := SDTime
    DeltaTime -= %A_Now%, Seconds
    Sleep % 1000 * (DeltaTime - WarnMinute * 60)
    If WarnMinute {
        MsgBox % 4416 - ExtendLevel * 28, 即将关机, % Warn(WarnMinute), 10
        IfMsgBox Yes
        {
            SDTime += ExtendMinute, Minutes
            ExtendLevel --
        }
    }
    Else
        Shutdown 1
}

Global SDTime := A_Year A_MM A_DD 235959
Global WarnMinutes := [5, 3, 1, 0]
Global ExtendLevel := 1
Global ExtendMinute := 5
For Index, Min in WarnMinutes
    Hint(Min)
