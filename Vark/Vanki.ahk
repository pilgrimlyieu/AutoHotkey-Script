class Vanki {
    __New(settings) {
         this.TempDir := settings.tempdir
         this.AssetDir := settings.assetdir
         this.MixDir := settings.mixdir
         this.TempFileName := settings.tempfilename
         this.MixFileName := settings.mixfilename
         this.PopSizes := settings.popsizes
         this.Delimiter := settings.delimiter

         this.order := 1

         FileCreateDir % this.TempDir
         FileCreateDir % this.MixDir
    }

    Open() {
        this.Temp()
        this.Popout()
    }

    Close(remain) {
        if !WinActive("ahk_pid " this.process_id)
            return
        this.remain_last_window := remain
        SendInput {,}q
        WinWaitNotActive % "ahk_pid" this.process_id
        this.process_id := ""
        this.Content()
    }

    Temp() {
        FileAppend % "", % this.TempDir this.TempFileName this.order
    }

    Popout() {
        MouseGetPos mouse_xpos, mouse_ypos
        Run % "gvim.exe " this.TempDir this.TempFileName this.order " -u G:\Settings\anki.vimrc", C:\Program Files\Vim\vim82, , process_id
        this.process_id := process_id
        Process Priority, %process_id%, Realtime
        WinWaitActive ahk_pid %process_id%, , 1
        WinSet Style, -0xC00000, ahk_pid %process_id%
        WinSet Style, -0x40000, ahk_pid %process_id%
        win_xpos := mouse_xpos - this.PopSizes[1] / 2
        win_ypos := mouse_ypos - this.PopSizes[2]
        WinMove ahk_pid %process_id%, , % (win_xpos > 0) ? win_xpos : 0, % (win_ypos > 0) ? win_ypos : 0, % this.PopSizes[1], % this.PopSizes[2]
        WinActivate ahk_pid %process_id%

        WinWaitNotActive ahk_pid %process_id%
        if !this.remain_last_window
            this.order ++
    }

    Content() {
        FileRead content, % this.TempDir this.TempFileName this.order
        SendInput % "{Text}" content
    }

    Remove() {
        FileDelete % this.TempDir this.TempFileName this.order
    }

    Clear() {
        FileRemoveDir % this.TempDir, 1
        FileCreateDir % this.TempDir
        this.order := 1
    }
}

CoordMode Mouse

Global Settings := {"tempdir": "G:\Temp\.vanki\"
                  , "assetdir": "G:\Temp\.vanki\images\"
                  , "mixdir": "G:\Temp\.vanki\.mix\"
                  , "tempfilename": "Temp_"
                  , "mixfilename": "Mix.md"
                  , "popsizes": [1080, 320]
                  , "delimiter": "`r`n`r`n<hr class='section'>`r`n`r`n"}

Test := new Vanki(Settings)

^q::Test.Open()
^w::Test.Close(0)
^e::Test.Close(1)
