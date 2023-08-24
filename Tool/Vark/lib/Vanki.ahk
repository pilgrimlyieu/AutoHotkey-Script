#Include <Vark>
#Include <md2html>

class Vanki extends Vark {
    __New(settings) {
        this.TempDir         := settings.tempdir
        this.HistoryDir      := settings.historydir
        this.Vimrc           := settings.vimrc
        this.SaveToClip      := settings.savetoclip
        this.SendbyClip      := settings.sendbyclip
        this.HTML            := settings.html
        this.PopSizes        := settings.popsizes
        this.Delimiter       := settings.delimiter
        this.MixPath         := this.TempDir this.MixFileName
        this.CombinePath     := this.TempDir this.CombineFileName
        this.TempFileName    := "Temp_"
        this.MixFileName     := "Mix.md"
        this.CombineFileName := "Combine.md"
        this.order           := 1
        this.suffix          := 0
        this.process_id   := ""

        DirCreate(this.TempDir)
        DirCreate(this.HistoryDir)

    }

    Open() {
        this.TempPath := this.TempDir this.TempFileName this.order
        this.Temp(this.TempPath)
        this.PopOut(this.TempPath)
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
        if !WinExist("ahk_pid " this.process_id)
            return
        this.Save(option)

        if option == 0 || option == 1 {
            file := FileRead(this.TempPath)
            if !WinExist("ahk_id " this.win_id) && this.SavetoClip
                A_Clipboard := file
            else {
                WinActivate("ahk_id " this.win_id)
                WinWaitActive("ahk_id " this.win_id)
                this.Content(file)
            }

            if option == 0 {
                this.Mix(file)
                this.ExtraSuf(file)
                this.order += 1
            }
            else {
                this.suffix += 1
                this.Suf(this.TempPath, file, this.suffix)
                this.Mix(file, this.suffix)
            }
        }
        else
            this.ExtraSuf(file)
    }

    Content(content) {
        content := ImageandUrl(RegExReplace(content, "(\n|\r)+$", ""), this.HTML)
        if this.SendbyClip {
            A_Clipboard := content
            ClipWait(0.5, 0)
            SendInput("{Ctrl Down}v{Ctrl Up}")
        }
        else
            SendInput("{Text}" content)
    }

    Empty() {
        SendInput("jkggdG")
        this.Close(this.suffix ? 0 : 2)
    }

    Suf(path, file, suffix) {
        if file
            FileAppend(file, path "_" suffix)
    }

    ExtraSuf(file) {
        if this.suffix {
            if file {
                FileAppend(file, this.TempDir this.TempFileName this.order "_" (this.suffix + 1))
                FileCopy(this.MixPath, this.HistoryDir this.TempFileName this.order "_" (this.suffix + 1) ".md")
            }
            FileDelete(this.TempPath)
            FileDelete(this.HistoryDir this.TempFileName this.order ".md")
        }
        this.suffix := 0
    }

    Mix(file, suffix := 0) {
        if file
            FileAppend(simpleHTMLtoMD(file) this.Delimiter, this.MixPath)
        FileCopy(this.MixPath, this.HistoryDir this.TempFileName this.order (suffix ? "_" suffix : "") ".md")
    }

    Combine() {
        file := ""
        loop files this.TempDir this.TempFileName "*" {
            content := FileRead(A_LoopFilePath)
            if content
                file .= content this.Delimiter
        }
        FileAppend(file, this.CombinePath)
    }

    Clear() {
        MsgBoxResult := MsgBox("是否要清除临时文件夹？（此操作不可逆！）", "清除临时文件夹", "Y/N/C Icon? Default2 0x1000 T5")
        if MsgBoxResult == "No"
            return

        DirDelete(this.TempDir, 1)
        DirCreate(this.TempDir)
        DirCreate(this.HistoryDir)
        this.order  := 1
        this.suffix := 0
    }
}