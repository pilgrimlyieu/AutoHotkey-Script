class Vark {
    __New(settings) {
         this.TempDir      := settings.tempdir
         this.VimDir       := settings.vimdir
         this.Vimrc        := settings.vimrc
         this.TempFileName := settings.tempfilename
         this.PopSizes     := settings.popsizes
         this.TempPath     := this.TempDir this.TempFileName

         FileCreateDir % this.TempDir
    }

    Open() {
        temp_path := this.TempPath
        this.Temp(temp_path)
        this.Popout(temp_path)
    }

    Save(option) {
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
    }

    /**
     *    |-----------------------|
     *    |        option?        |
     *    |-------+-------+-------|
     *    | value | send? | keep? |
     *    |-------+-------+-------|
     *    |  -1   |   N   |   N   |
     *    |-------+-------+-------|
     *    |   0   |   Y   |   N   |
     *    |-------+-------+-------|
     *    |   1   |   Y   |   Y   |
     *    |-------+-------+-------|
     *    |   2   |   N   |   Y   |
     *    |-------+-------+-------|
     */
    Close(option) {
        this.Save(option)

        if (!option or option = 1)
            this.Content(this.TempPath)
        if (!option or (option = -1 and !this.remaining))
            FileDelete % this.TempPath

        this.remaining := option > 0
    }

    Temp(path) {
        if !FileExist(path)
            FileAppend % "", % path
    }

    Popout(path) {
        xcursor := A_CaretX
        ycursor := A_CaretY
        if !(xcursor and ycursor)
            MouseGetPos xcursor, ycursor

        Run % "gvim.exe " path " -u " this.Vimrc, % this.VimDir, , process_id
        this.process_id := process_id

        Process Priority, %process_id%, Realtime
        WinWait ahk_pid %process_id%, , 3
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

    Clear() {
        FileDelete % this.TempPath
        this.remaining := 0
    }
}
