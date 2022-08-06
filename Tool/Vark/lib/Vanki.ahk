#Include <Vark>

class Vanki extends Vark {
    __New(settings) {
         this.TempDir         := settings.tempdir
         this.HistoryDir      := settings.historydir
         this.VimDir          := settings.vimdir
         this.Vimrc           := settings.vimrc
         this.TempFileName    := settings.tempfilename
         this.MixFileName     := settings.mixfilename
         this.CombineFileName := settings.combinefilename
         this.SaveToClip      := settings.savetoclip
         this.PopSizes        := settings.popsizes
         this.Delimiter       := settings.delimiter
         this.MixPath         := this.TempDir this.MixFileName
         this.CombinePath     := this.TempDir this.CombineFileName
         this.order           := 1
         this.suffix          := 0

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
     *    |   1   |   Y   |   Y   |   Y   |   Y   |
     *    |-------+-------+-------+-------+-------|
     *    |   2   |   Y   |   N   |   Y   |   N   |
     *    |-------+-------+-------+-------+-------|
     */
    Close(option) {
        if this.Save(option)
            return

        if (option = 0 or option = 1) {
            FileRead file, % this.TempPath
            if (!WinExist("ahk_id " this.win_id) and this.SavetoClip)
                Clipboard := file
            else {
                WinActivate % "ahk_id " this.win_id
                WinWaitActive % "ahk_id " this.win_id
                this.Content(file)
            }

            if (option = 0) {
                this.Mix(file)
                this.ExtraSuf(file)
                this.order ++
            }
            else if (option = 1) {
                this.suffix ++
                this.Suf(this.TempPath, file, this.suffix)
                this.Mix(file, this.suffix)
            }
        }
        else
            this.ExtraSuf(file)
    }

    Empty() {
        SendInput jkgg{Shift Down}v{Shift Up}Gd
        this.Close(this.suffix ? 0 : 2)
    }

    Suf(path, file, suffix) {
        if file
            FileAppend %file%, % path "_" suffix
    }

    ExtraSuf(file) {
        if this.suffix {
            if file {
                FileAppend %file%, % this.TempDir this.TempFileName this.order "_" (this.suffix + 1)
                FileCopy % this.MixPath, % this.HistoryDir this.TempFileName this.order "_" (this.suffix + 1) ".md"
            }
            FileDelete % this.TempPath
            FileDelete % this.HistoryDir this.TempFileName this.order ".md"
        }
        this.suffix := 0
    }

    Mix(file, suffix = 0) {
        if file
            FileAppend % file this.Delimiter, % this.MixPath
        FileCopy   % this.MixPath, % this.HistoryDir this.TempFileName this.order (suffix ? "_" suffix : "") ".md"
    }

    Combine() {
        file := ""
        Loop Files, % this.TempDir this.TempFileName "*"
        {
            FileRead content, %A_LoopFilePath%
            if content
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
        this.order  := 1
        this.suffix := 0
    }
}
