class Vark {
    __New(settings) {
        this.TempDir      := settings["tempdir"]
        this.Vimrc        := settings["vimrc"]
        this.SaveToClip   := settings["savetoclip"]
        this.SendbyClip   := settings["sendbyclip"]
        this.PopSizes     := settings["popsizes"]
        this.TempFileName := "Temp"
        this.TempPath     := this.TempDir this.TempFileName
        this.process_id   := ""

        DirCreate(this.TempDir)
    }

    Open() {
        this.Temp(this.TempPath)
        this.Popout(this.TempPath)
    }

    Save(option) {
        WinActivate("ahk_pid " this.process_id)
        WinWaitActive("ahk_pid " this.process_id)
        if option == -1
            SendInput("{Ctrl Down}{Shift Down}q{Shift Up}{Ctrl Up}")
        else
            SendInput("{Ctrl Down}q{Ctrl Up}")
        WinWaitNotActive("ahk_pid " this.process_id)
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
        if !WinExist("ahk_pid " this.process_id)
            return
        this.Save(option)

        if option == 0 || option == 1 {
            content := FileRead(this.TempPath)
            if !WinExist("ahk_id " this.win_id) && this.SavetoClip
                A_Clipboard := content
            else {
                WinActivate("ahk_id " this.win_id)
                WinWaitActive("ahk_id " this.win_id)
                this.Content(content)
            }
        }
        if option == 0 || (option == -1 && !this.remaining)
            FileDelete(this.TempPath)

        this.remaining := option > 0
    }

    Temp(path) {
        if !FileExist(path)
            FileAppend("", path)
    }

    Popout(path) {
        this.win_id := WinExist("A")

        CaretGetPos(&xcursor, &ycursor)
        if !(xcursor && ycursor)
            MouseGetPos(&xcursor, &ycursor)
        win_xpos := (xcursor > A_ScreenWidth - this.PopSizes[1]) ? A_ScreenWidth - this.PopSizes[1] : xcursor
        win_ypos := (ycursor > this.PopSizes[2] + 20) ? ycursor - this.PopSizes[2] - 20 : 0

        Run("gvim " path " -u " this.Vimrc, , , &process_id)
        this.process_id := process_id

        ProcessSetPriority("Realtime", process_id)
        WinWait("ahk_pid " process_id, , 5)
        WinSetStyle(-12845056, "ahk_pid " process_id)
        WinSetAlwaysOnTop(1, "ahk_pid " process_id)
        WinMove(win_xpos, win_ypos, this.PopSizes[1], this.PopSizes[2], "ahk_pid " process_id)
        WinActivate("ahk_pid " process_id)
    }

    Content(content) {
        content := RegExReplace(content, "(\n|\r)+$", "")
        if this.SendbyClip {
            A_Clipboard := content
            SendInput("{Ctrl Down}v{Ctrl Up}")
        }
        else
            SendInput("{Text}" content)
    }

    Clear() {
        FileDelete(this.TempPath)
        this.remaining := 0
    }
}