Run D:\Program Files\Tencent\WeMeet\wemeetapp.exe
WinWait ahk_exe wemeetapp.exe, , 10
If !ErrorLevel {
    Sleep 3000
    ; 主窗口与会议窗口除 ID 外都相同，害得我只能通过修改标题来解决
    WinSetTitle ahk_exe wemeetapp.exe, , SBTencent
    CoordMode Mouse
    Click 960 580 ; 避免出现「异常退出」的错误
    Click 1060 500 ; 进入会议
    WinHide SBTencent
    WinMaximize 腾讯会议
    WinMinimize 腾讯会议
}