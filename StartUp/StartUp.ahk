;@Ahk2Exe-SetMainIcon StartUp.ico
#NoTrayIcon

; Sleep % 10000

OnOff := {"WeMeet": True, "WeChat": True, "TIM": True}

DetectHiddenWindows On

; 腾讯会议
If (!(WinExist("SBTecent") or WinExist("腾讯会议")) and 1 < A_WDay < 7) {
    If OnOff["WeMeet"] {
        Run D:\Program Files\Tencent\WeMeet\wemeetapp.exe
        WinWait 腾讯会议, , 10
        If (!ErrorLevel) {
            Sleep 5000
            ; 主窗口与会议窗口除 ID 外都相同，害得我只能通过修改标题来解决
            WinSetTitle 腾讯会议, , SBTecent
            CoordMode Mouse
            Click 960 580 ; 避免出现「异常退出」的错误
            Click 1060 500 ; 进入会议
            WinMinimize SBTecent
        }
    }
    Sleep % 5000
}

; 微信
If !WinExist("微信") {
    If OnOff["WeChat"] {
        Run D:\Program Files\WeChat\WeChat.exe
        WinWait 微信, , 10
        If (!ErrorLevel) {
            Sleep 5000
            CoordMode Mouse
            Click 960 610 ; 登录
            WinMinimize 微信
        }
    }
    Sleep % 5000
}

; TIM
If !WinExist("TIM") {
    If OnOff["TIM"] {
        Run D:\Program Files\TIM\Bin\QQScLauncher.exe, , Min
        WinMinimize TIM
    }
}