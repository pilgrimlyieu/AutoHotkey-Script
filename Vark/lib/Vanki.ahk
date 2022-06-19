Process     Priority, , Realtime
CoordMode   Caret
SetWinDelay -1

class Vanki {
    __New(settings) {
         this.TempDir         := settings.tempdir
         this.HistoryDir      := settings.historydir
         this.VimDir          := settings.vimdir
         this.Vimrc           := settings.vimrc
         this.TempFileName    := settings.tempfilename
         this.MixFileName     := settings.mixfilename
         this.CombineFileName := settings.combinefilename
         this.PopSizes        := settings.popsizes
         this.Delimiter       := settings.delimiter
         this.MixPath         := this.TempDir this.MixFileName
         this.CombinePath     := this.TempDir this.CombineFileName
         this.order           := 1

         FileCreateDir % this.TempDir
         FileCreateDir % this.HistoryDir
    }

    Open() {
        this.TempPath := this.TempDir this.TempFileName this.order
        this.Temp(this.TempPath)
        this.Popout(this.TempPath)
    }

    /**
     *    |---------------------------------------|
     *    |                option?                |
     *    |-------+-------+-------+-------+-------|
     *    | value | save? | send? | keep? | file? |
     *    |-------+-------+-------+-------+-------|
     *    |  -1   |   N   |   N   |   N   |   N   |
     *    |-------+-------+-------+-------+-------|
     *    |   0   |   Y   |   Y   |   N   |   Y   |
     *    |-------+-------+-------+-------+-------|
     *    |   1   |   Y   |   Y   |   Y   |   N   |
     *    |-------+-------+-------+-------+-------|
     *    |   2   |   Y   |   N   |   Y   |   N   |
     *    |-------+-------+-------+-------+-------|
     */
    Close(option) {
        if !WinExist("ahk_pid " this.process_id)
            return

        WinActivate   % "ahk_pid " this.process_id
        WinWaitActive % "ahk_pid " this.process_id

        if (option = -1)
            SendInput {Ctrl Down}{Shift Down}q{Shift Up}{Ctrl Up}
        else
            SendInput {Ctrl Down}q{Ctrl Up}

        WinWaitNotActive % "ahk_pid " this.process_id
        this.process_id := ""

        if (option = -1 or option = 2)
            return
        if !option {
            this.Mix(this.TempPath)
            this.order ++
        }
        this.Content(this.TempPath)
    }

    Mix(path) {
        FileRead   temp, % path
        FileAppend % temp this.Delimiter, % this.MixPath
        FileCopy   % this.MixPath, % this.HistoryDir "Temp_" this.order ".md"
    }

    Temp(path) {
        if !FileExist(path)
            FileAppend % "", % path
    }

    Popout(path) {
        xcursor := A_CaretX
        ycursor := A_CaretY
        if !(xcursor and ycursor)
            return

        Run % "gvim.exe " path " -u " this.Vimrc, % this.VimDir, , process_id
        this.process_id := process_id

        Process Priority, %process_id%, Realtime
        WinWait ahk_pid %process_id%, , 1
        WinSet  Style, -0xC40000, ahk_pid %process_id%

        win_xpos := xcursor
        win_ypos := ycursor - this.PopSizes[2] - 20
        if (win_xpos > A_ScreenWidth - this.PopSizes[1])
            win_xpos := A_ScreenWidth -this.PopSizes[1]
        if (win_ypos < 0)
            win_ypos := 0
        WinMove     ahk_pid %process_id%, , %win_xpos%, %win_ypos%, % this.PopSizes[1], % this.PopSizes[2]
        WinActivate ahk_pid %process_id%

        WinWaitNotActive ahk_pid %process_id%
        if WinExist("ahk_pid " process_id)
            this.Close(2)
    }

    Content(path) {
        FileRead  content, % path
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
        FileAppend %file%, % this.CombinePath
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
