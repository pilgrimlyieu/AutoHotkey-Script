class Vanki {
    __New(settings) {
         this.TempDir := settings.tempdir
         this.AssetDir := settings.assetdir
         this.HistoryDir := settings.historydir
         this.VimDir := settings.vimdir
         this.Vimrc := settings.vimrc
         this.TempFileName := settings.tempfilename
         this.MixFileName := settings.mixfilename
         this.CombineFileName := settings.combinefilename
         this.PopSizes := settings.popsizes
         this.Delimiter := settings.delimiter
         this.order := 1
         FileCreateDir % this.TempDir
         FileCreateDir % this.HistoryDir
    }

    Open() {
        this.Temp(this.order)
        this.Popout(this.order)
    }

    Close(remain) {
        if !WinExist("ahk_pid " this.process_id)
            return
        this.remaining := (remain > 0) ? 1 : 0
        this.remain_last_window := remain
        WinActivate % "ahk_pid " this.process_id
        WinWaitActive % "ahk_pid " this.process_id
        if (remain = -1)
            SendInput {Ctrl Down}{Shift Down}q{Shift Up}{Ctrl Up}
        else
            SendInput {Ctrl Down}q{Ctrl Up}
        WinWaitNotActive % "ahk_pid " this.process_id
        this.process_id := ""
        if (remain = -1 or remain = 2)
            return
        if (this.remaining = 0)
            this.Mix(this.order)
        this.Content(this.order)
    }

    Mix(order) {
        FileRead temp, % this.TempDir this.TempFileName order
        FileAppend % temp this.Delimiter, % this.TempDir this.MixFileName
        FileCopy % this.TempDir this.MixFileName, % this.HistoryDir "Temp_" order ".md"
    }

    Temp(order) {
        if !FileExist(this.TempDir this.TempFileName order)
            FileAppend % "", % this.TempDir this.TempFileName order
    }

    Popout(order) {
        xcursor := A_CaretX
        ycursor := A_CaretY
        if !(xcursor and ycursor)
            return
        Run % "gvim.exe " this.TempDir this.TempFileName order " -u " this.Vimrc, % this.VimDir, , process_id
        this.process_id := process_id
        Process Priority, %process_id%, Realtime
        WinWait ahk_pid %process_id%, , 1
        WinSet Style, -0xC40000, ahk_pid %process_id%
        win_xpos := xcursor
        win_ypos := ycursor - this.PopSizes[2] - 20
        WinMove ahk_pid %process_id%, , % (win_xpos > 0) ? ((win_xpos > A_ScreenWidth  - this.PopSizes[1]) ? A_ScreenWidth  - this.PopSizes[1] : win_xpos) : 0, % (win_ypos > 0) ? ((win_ypos > A_ScreenHeight - this.PopSizes[2]) ? A_ScreenHeight - this.PopSizes[2] : win_ypos) : 0, % this.PopSizes[1], % this.PopSizes[2]
        WinActivate ahk_pid %process_id%
        WinWaitNotActive ahk_pid %process_id%
        if WinExist("ahk_pid " process_id)
            this.Close(2)
        if (this.remain_last_window = 0)
            this.order ++
    }

    Content(order) {
        FileRead content, % this.TempDir this.TempFileName order
        SendInput % "{Text}" content
        SendInput {BackSpace}
    }

    Combine() {
        file := ""
        Loop Files, % this.TempDir this.TempFileName "*"
        {
            FileRead content, %A_LoopFilePath%
            file .= content this.Delimiter
        }
        FileAppend %file%, % this.TempDir this.CombineFileName
    }

    Clear() {
        MsgBox 4388, 清除临时文件夹, 是否要清除临时文件夹？（此操作不可逆！）, 5
        IfMsgBox No
            return
        FileRemoveDir % this.TempDir, 1
        FileCreateDir % this.TempDir
        FileCreateDir % this.HistoryDir
        this.order := 1
    }
}

Process Priority, , Realtime
CoordMode Caret
SetWinDelay -1

Global Settings := {"tempdir": "G:\Temp\.vanki\"
                  , "assetdir": "G:\Temp\.vanki\images\"
                  , "historydir": "G:\Temp\.vanki\.history\"
                  , "vimdir": "C:\Program Files\Vim\vim82"
                  , "vimrc": "G:\Assets\Tool\AutoHotkey\Vark\vanki.vimrc"
                  , "tempfilename": "Temp_"
                  , "mixfilename": "Mix.md"
                  , "combinefilename": "Combine.md"
                  , "popsizes": [960, 240]
                  , "delimiter": "`r`n<hr class='section'>`r`n`r`n"}

VimAnki := new Vanki(Settings)

^w::VimAnki.Close(0)
^e::VimAnki.Close(1)
^r::VimAnki.Close(-1)

#IfWinNotActive ahk_class Vim

^q::VimAnki.Open()
^t::VimAnki.Combine()
^y::VimAnki.Clear()
