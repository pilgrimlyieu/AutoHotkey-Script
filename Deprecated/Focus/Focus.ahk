;@Ahk2Exe-SetMainIcon Icon\Focus.ico

Global ConfigFile := A_ScriptDir "\Focus.ini", DataFile := A_ScriptDir "\Focus.db"
Global Online := 0, AdvancedSettingOnOff := 0, RLNOF := 0, RENOF := 0, ROF := 0, EOF := 0, LeaveLevel := 0, Note := 0, NoteOnOff := 0, Note := 0, NoteUsed := 0
Global ReadOF := 1
Global Begins := [0700, 0750, 0845, 0940, 1035, 1130, 1400, 1455, 1550, 1845, 2015]
Global Ends := [0740, 0830, 0925, 1020, 1115, 1210, 1440, 1535, 1630, 2000, 2130]
Global ExtraStatus := ["未启用", "启用中"]
Global WhiteList := ["SumatraPDF.exe", "WINWORD.EXE", "POWERPNT.EXE", "Snipaste.exe", "GoldenDict.exe", "db.exe", "javaw.exe", "Mathematica.exe", "anki.exe"]
Global CourseNum := Begins.Length()
Global ChooseTab := 1
Global EveningTime := 2000
Global DefaultPassword := 000000

If !FileExist(ConfigFile)
    Gosub Create_Config
_Ke := StrSplit(ReadIni(ConfigFile, "", "设置"), "`n")
Loop % _Ke.Length() {
    _Va := StrSplit(_Ke[A_Index], "=")
    tVar := _Va[1]
    %tVar% := _Va[2]
}
If FileExist(DataFile) {
    Loop Read, %DataFile%
    {
        _Va := StrSplit(A_LoopReadLine, "=")
        tVar := _Va[1]
        %tVar% := _Va[2]
    }
    FileDelete %DataFile%
}
Else {
    UsedNum := LeaveNum
    ExtraTime := ExtraMinute
    ExtraLevel := 0
    DeltaTime := 0
}
RegexWhiteList := "i)\A("
For Index, Value in WhiteList {
    RegexWhiteList .= Value "|"
}
RegexWhiteList := SubStr(RegexWhiteList, 1, -1) ")\z"
Global EStatus := ExtraStatus[ExtraLevel + 1]
Global SetPassword := Decrypt(SubStr(PasswordCode, 1, 8), SubStr(PasswordCode, 9))

Menu Tray, NoStandard
Menu Tray, Add, 设置, Setting
Menu Tray, Default, 设置
Menu Tray, Add, 腾讯会议主窗口, Main
Menu Tray, Add, 长时离屏, Extra
Menu Tray, Add, 笔记时间, Note
Menu Tray, Add, 重启, Reload
Menu Tray, Add, 退出, Exit

; Sleep 60000

If MainOnOff
    WinHide SBTencent

If (1 < A_WDay and A_WDay < 7) {
    While 1 {
        If (ExtraLevel and ExtraTime and ExtraOnOff) {
            MsgBox 4160, 长时离屏, 已开启「长时离屏」！, 5
            Tick := 0
            While (ExtraLevel and DeltaTime < ExtraTime) {
                WinActive("腾讯会议") ? : Tick ++
                Sleep 1000
                (Tick = 60) ? (Tick := 0) (DeltaTime ++)
            }
            Gosub Delta
        }
        If !WinActive("腾讯会议") {
            Loop % CheckInterval {
                WinWaitActive 腾讯会议, , 1
                EL := ErrorLevel
                If (ExtraLevel or !EL)
                    Continue 2
            }
            WinGet ProcName, ProcessName, A
            If ProcName ~= RegexWhiteList {
                Continue
            }
            FormatTime, Now, , HHmm
            If (Now > Ends[Ends.Length()]) {
                DetectHiddenWindows On
                CoordMode Mouse
                WinActivate 腾讯会议
                WinKill 腾讯会议
                Click 1000 580
                Sleep 500
                WinKill SBTencent
                ExitApp
            }
            Loop %CourseNum% {
                If (Begins[A_Index] <= Now and Now <= Ends[A_Index] and EL) {
                    If (A_WDay = 6 and Now >= EveningTime and !FridayOnOff)
                        ExitApp
                    Else If (UsedNum and LeaveOnOff) {
                        MsgBox 4388, 短时离屏, 离屏时间过长，是否开启为时 %LeaveMinute% 分钟的「短时离屏」？`n剩余短时离屏次数：%UsedNum%, 5
                        IfMsgBox Yes
                        {
                            UsedNum --
                            LeaveLevel := 1
                            Sleep % LeaveMinute * 60000
                            LeaveLevel := 0
                            Continue 2
                        }
                        If (Now >= EveningTime and !WinActive("ahk_exe anki.exe") and AnkiOnOff) {
                            If !WinExist("ahk_exe anki.exe") {
                                Run C:\Users\Administrator\Desktop\Anki.lnk
                                CoordMode Mouse
                                WinWait ahk_exe anki.exe, , 10
                                WinActivate ahk_exe anki.exe
                                Click 1140 330
                            }
                            WinActivate ahk_exe anki.exe
                        }
                        Else
                            WinActivate 腾讯会议
                        Continue 2
                    }
                }
            }
        }
    }
}
ExitApp

Setting:
    Gui Setting:New, , 设置
    Gui Setting:Default
    Gui Setting:Margin, 10, 10
    Gui Setting:Color, EBEDF4
    Gui Setting:Font, s12, SimHei
    Gui Setting:+AlwaysOnTop
    If AdvancedSettingOnOff
        Gui Add, Tab3, Choose%ChooseTab%, 基础|短时离屏|长时离屏|高级
    Else
        Gui Add, Tab3, Choose%ChooseTab%, 基础|短时离屏|长时离屏
    Gui Tab, 基础
    Gui Add, CheckBox, x20 y+15 vMainOnOff gGETV Checked%MainOnOff%, 自动隐藏「腾讯会议」主窗口
    Gui Add, CheckBox, x20 y+15 vFridayOnOff gGETV Checked%FridayOnOff%, 周五晚自习
    Gui Add, CheckBox, x20 y+15 vAnkiOnOff gGETV Checked%AnkiOnOff%, Anki 模式
    Gui Add, CheckBox, x20 y+15 vNoteOnOff gGETV Checked%NoteOnOff%, 笔记模式
    Gui Add, Text, x20 y+15, 笔记模式次数：
    Gui Add, Edit, x+10 w50 vNoteNum gGETV
    Gui Add, UpDown, Range0-5, %NoteNum%
    Gui Add, Text, x20 x+10 y+-20, 次
    Gui Add, Text, x20 y+15, 笔记模式时间：
    Gui Add, Edit, x+10 w50 vNoteTime gGETV
    Gui Add, UpDown, Range15-45, %NoteTime%
    Gui Add, Text, x20 x+10 y+-20, 分钟
    Gui Add, Text, x20 y+15, 检查离屏间隔时间：
    Gui Add, Edit, x+10 w50 vCheckInterval gGETV
    Gui Add, UpDown, Range1-300, %CheckInterval%
    Gui Add, Text, x20 x+10 y+-20, 秒
    Gui Add, CheckBox, x20 y+15 vAdvancedSettingOnOff gSAS Checked%AdvancedSettingOnOff%, 显示高级设置
    Gui Tab, 短时离屏
    Gui Add, CheckBox, x20 y+15 vLeaveOnOff gGETV Checked%LeaveOnOff%, 短时离屏
    Gui Add, Text, x20 y+15, 剩余短时离屏次数：%UsedNum% 次
    Gui Add, Button, Default w50 x230 y+-25 gRLN, 重置
    Gui Add, Text, x20 y+15, 允许短时离屏次数：
    Gui Add, Edit, x+10 w50 vLeaveNum gGETV
    Gui Add, UpDown, Range0-10, %LeaveNum%
    Gui Add, Text, x20 x+10 y+-20, 次
    Gui Add, Text, x20 y+15, 单次短时离屏时间：
    Gui Add, Edit, x+10 w50 vLeaveMinute gGETV
    Gui Add, UpDown, Range1-10, %LeaveMinute%
    Gui Add, Text, x20 x+10 y+-20, 分钟
    Gui Tab, 长时离屏
    Gui Add, CheckBox, x20 y+15 vExtraOnOff gGETV Checked%ExtraOnOff%, 长时离屏
    Gui Add, Text, x20 y+15, 长时离屏状态：%EStatus%
    Gui Add, Text, x20 y+15, 长时离屏持续时间：%DeltaTime% 分钟
    Gui Add, Text, x20 y+15, 剩余长时离屏时间：%ExtraTime% 分钟
    Gui Add, Button, Default w50 x230 y+-25 gREN, 重置
    Gui Add, Text, x20 y+15, 允许长时离屏时间：
    Gui Add, Edit, x+10 w50 vExtraMinute gGETV
    Gui Add, UpDown, Range%LeaveMinute%-120, %ExtraMinute%
    Gui Add, Text, x20 x+10 y+-20, 分钟
    If AdvancedSettingOnOff {
        Gui Tab, 高级
        If AdvancedGUIOnOff {
            Gui Add, Text, x20 y+15, 新高级设置密码：
            Gui Add, Edit, x+0 y+-20 w105 Limit6 Number Password -WantCtrlA vInputSetPassword gUpdate
            Gui Add, Button, Default w50 x20 y+15 gSP, 设置
            Gui Add, CheckBox, x20 y+15 vReadOF gUpdate Checked%ReadOF%, 只读模式
            Gui Add, CheckBox, x20 y+15 vRLNOF gUpdate Checked%RLNOF%, 短时离屏次数重置
            Gui Add, CheckBox, x20 y+15 vRENOF gUpdate Checked%RENOF%, 长时离屏时间重置
            Gui Add, CheckBox, x20 y+15 vROF gUpdate Checked%RENOF%, 重启
            Gui Add, CheckBox, x20 y+15 vEOF gUpdate Checked%RENOF%, 退出
            Gui Add, Button, Default w50 x20 y+15 gOUT, 登出
        }
        Else {
            Gui Add, Text, x20 y+15, 请输入高级设置密码：
            Gui Add, Edit, x+0 y+-20 w105 Limit6 Number Password -WantCtrlA vInputPassword gUpdate
            Gui Add, Button, Default w50 x20 y+15 gCP, 登入
        }
    }
    Gui Setting:Show, NA, 设置
    ChooseTab := 1
    AdvancedGUIOnOff := 0
Return

Extra:
    If !(ExtraOnOff and ExtraTime) {
        MsgBox 4160, 长时离屏, 「长时离屏」未开启或次数已尽！, 5
        Return
    }
    Else If LeaveLevel {
        MsgBox 4160, 长时离屏, 当前已开始短时离屏，无法开启长时离屏！, 5
        Return
    }
    ExtraLevel := !ExtraLevel
    EStatus := ExtraStatus[ExtraLevel + 1]
Return

Note:
    If (NoteOnOff or NoteUsed >= NoteNum) {
        MsgBox 4160, 笔记模式, 「笔记模式」未开启或次数已尽！, 5
        Return
    }
    Else If Note {
        NoteUsed ++
        Note := 0
        Used := NoteNum - NoteUsed
        MsgBox 4160, 笔记模式, 持续 %Pass% 分钟的笔记模式已关闭！`n剩余可用笔记模式次数：%Used% , 5
        Return
    }
    Note := 1
    MsgBox 4160, 笔记模式, 笔记模式已开启！, 5
    Studu := ""
    Pass := 0
    Loop % NoteTime {
        WinGetTitle WT, A
        If !(WT ~= "Week-\d{2}_\d{2}(?:-\d{2}){2}(?:_\w+)?\.md - ENote - Visual Studio Code \[管理员\]") {
            MsgBox 4132, 笔记模式, 是否要继续进行笔记模式？！`n笔记模式持续时间：%Pass% 分钟, 5
            IfMsgBox No
                Break
            WinActivate %Study%
        }
        Else
            Study := WT
        Sleep 60000
        Pass ++
    }
    Note := 0
    NoteUsed ++
    Used := NoteNum - NoteUsed
    MsgBox 4160, 笔记模式, 持续 %Pass% 分钟的笔记模式已关闭！`n剩余可用笔记模式次数：%Used%, 5
Return

Delta:
    ExtraTime -= DeltaTime
    MsgBox 4160, 长时离屏, 已关闭持续 %DeltaTime% 分钟的「长时离屏」！, 5
    DeltaTime := 0
    ExtraLevel := 0
    EStatus := ExtraStatus[ExtraLevel + 1]
Return

Main:
    If WinExist("SBTencent") {
        WinMinimize SBTencent
        WinSet Bottom, , SBTencent
        WinHide SBTencent
        Return
    }
    WinShow SBTencent
Return

Reload:
    If ROF {
        FileAppend UsedNum=%UsedNum%`n, %DataFile%
        FileAppend ExtraTime=%ExtraTime%`n, %DataFile%
        FileAppend ExtraLevel=%ExtraLevel%`n, %DataFile%
        FileAppend DeltaTime=%DeltaTime%`n, %DataFile%
        Reload
    }
    Else 
        MsgBox 4144, 高级设置未启用, 高级设置未启用此功能！, 5
Return

Exit:
    If EOF
        ExitApp
    MsgBox 4144, 高级设置未启用, 高级设置未启用此功能！, 5
Return

Create_Config:
    IniWrite 1, %ConfigFile%, 设置, MainOnOff
    IniWrite 0, %ConfigFile%, 设置, FridayOnOff
    IniWrite 1, %ConfigFile%, 设置, AnkiOnOff
    IniWrite 1, %ConfigFile%, 设置, NoteOnOff
    IniWrite 5, %ConfigFile%, 设置, NoteNum
    IniWrite 30, %ConfigFile%, 设置, NoteTime
    IniWrite 60, %ConfigFile%, 设置, CheckInterval
    IniWrite 1, %ConfigFile%, 设置, LeaveOnOff
    IniWrite 5, %ConfigFile%, 设置, LeaveNum
    IniWrite 5, %ConfigFile%, 设置, LeaveMinute
    IniWrite 1, %ConfigFile%, 设置, ExtraOnOff
    IniWrite 30, %ConfigFile%, 设置, ExtraMinute
    IniWrite % Encrypt(DefaultPassword), %ConfigFile%, 设置, PasswordCode
Return

Update:
    GuiControlGet tVa, , %A_GuiControl%
    %A_GuiControl% := tVa
Return

CP:
    If (InputPassword = SetPassword and StrLen(InputPassword) = 6) {
        AdvancedGUIOnOff := 1
        ChooseTab := 4
        InputPassword := ""
        Gosub Setting
    }
    Else If (StrLen(InputPassword) != 6)
        MsgBox 4144, 密码错误, 密码长度不足 6 位！, 5
    Else
        MsgBox 4144, 密码错误, 密码错误！, 5
Return

OUT:
    AdvancedGUIOnOff := 0
    ChooseTab := 4
    Gosub Setting
Return

SP:
    If (StrLen(InputSetPassword) != 6)
        MsgBox 4144, 密码不合法, 密码长度不足 6 位！, 5
    Else If (InputSetPassword = SetPassword)
        MsgBox 4144, 密码不合法, 密码与原密码重复！, 5
    Else {
        SetPassword := InputSetPassword
        WriteIni(ConfigFile, Encrypt(SetPassword), "PasswordCode", "设置")
        ChooseTab := 4
        InputSetPassword := ""
        Gosub Setting
    }
Return

SAS:
    AdvancedSettingOnOff := !AdvancedSettingOnOff
    Gosub Setting
Return

GETV:
    If ReadOF
        Return
    GuiControlGet tVa, , %A_GuiControl%
    %A_GuiControl% := tVa
    WriteIni(ConfigFile, tVa, A_GuiControl, "设置")
Return

RLN:
    If ReadOF {
        MsgBox 4144, 只读模式, 当前为只读模式，无法进行该操作！, 5
        Return
    }
    If RLNOF {
        UsedNum := LeaveNum
        ChooseTab := 2
        Gosub Setting
    }
    Else
        MsgBox 4144, 高级设置未启用, 高级设置未启用此功能！, 5
Return

REN:
    If ReadOF {
        MsgBox 4144, 只读模式, 当前为只读模式，无法进行该操作！, 5
        Return
    }
    If RENOF {
        ExtraTime := ExtraMinute
        ChooseTab := 3
        Gosub Setting
    }
    Else
        MsgBox 4144, 高级设置未启用, 高级设置未启用此功能！, 5
Return

ReadIni(_ConfigFile, _key := "", _Section := "设置") {
    If FileExist(_ConfigFile) {
        Iniread initmp, %_ConfigFile%, %_Section%, %_key%
        Return initmp
    }
}

WriteIni(_ConfigFile, _value, _key, _Section := "设置") {
    If _value !=
        IniWrite %_value%, %_ConfigFile%, %_Section%, %_key%
}

Encrypt(PlainText) {
    FormatTime Key1, , yyyyMMdd
    TempKey += 1, Days
    FormatTime Key2, %TempKey%, yyyyMMdd
    TempKey += -2, Days
    FormatTime Key3, %TempKey%, yyyyMMdd
    Return A_YYYY A_MM A_DD Key2 * Key3 - A_WDay * Key1 * PlainText
}

Decrypt(Now, CypherText) {
    FormatTime Key1, % Now 000000, yyyyMMdd
    FormatTime Key2, % Now 000000, WDay
    TempKey := SubStr(Now, 1, 8)
    TempKey += 1, Days
    FormatTime Key3, %TempKey%, yyyyMMdd
    TempKey += -2, Days
    FormatTime Key4, %TempKey%, yyyyMMdd
    PlainText := (Key3 * Key4 - CypherText) // (Key2 * Key1)
    Loop % 6 - StrLen(PlainText)
        Plus .= 0
    Return Plus PlainText
}
