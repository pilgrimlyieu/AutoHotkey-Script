class Vark {
    __New(settings) {
         this.TempDir      := settings.tempdir
         this.VimDir       := settings.vimdir
         this.Vimrc        := settings.vimrc
         this.TempFileName := settings.tempfilename
         this.SaveToClip   := settings.savetoclip
         this.SendbyClip   := settings.sendbyclip
         this.PopSizes     := settings.popsizes
         this.TempPath     := this.TempDir this.TempFileName

         FileCreateDir % this.TempDir
    }

    Open() {
        this.Temp(this.TempPath)
        this.Popout(this.TempPath)
    }

    Save(option) {
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
        if !WinExist("ahk_pid " this.process_id)
            return
        this.Save(option)

        if (option = 0 or option = 1) {
            FileRead content, % this.TempPath
            if (!WinExist("ahk_id " this.win_id) and this.SavetoClip)
                Clipboard := content
            else {
                WinActivate % "ahk_id " this.win_id
                WinWaitActive % "ahk_id " this.win_id
                this.Content(content)
            }
        }
        if (option = 0 or (option = -1 and !this.remaining))
            FileDelete % this.TempPath

        this.remaining := option > 0
    }

    Temp(path) {
        if !FileExist(path)
            FileAppend % "", %path%
    }

    Popout(path) {
        this.win_id := WinExist("A")

        xcursor := A_CaretX
        ycursor := A_CaretY
        if !(xcursor and ycursor)
            MouseGetPos xcursor, ycursor
        win_xpos := xcursor
        win_ypos := ycursor - this.PopSizes[2] - 20
        if (win_xpos > A_ScreenWidth - this.PopSizes[1])
            win_xpos := A_ScreenWidth -this.PopSizes[1]
        if (win_ypos < 0)
            win_ypos := 0

        Run % "gvim.exe " path " -u " this.Vimrc, % this.VimDir, , process_id
        this.process_id := process_id

        Process     Priority, %process_id%, Realtime
        WinWait     ahk_pid %process_id%, , 5
        WinSet      Style, -0xC40000, ahk_pid %process_id%
        WinSet      AlwaysOnTop, On, ahk_pid %process_id%
        WinMove     ahk_pid %process_id%, , %win_xpos%, %win_ypos%, % this.PopSizes[1], % this.PopSizes[2]
        WinActivate ahk_pid %process_id%
    }

    Content(content) {
        content := RegExReplace(content, "(\n|\r)+$", "")
        if this.SendbyClip {
            Clipboard := content
            SendInput {Ctrl Down}v{Ctrl Up}
        }
        else
            SendInput % "{Text}" content
    }

    Clear() {
        FileDelete % this.TempPath
        this.remaining := 0
    }
}
