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
        if this.Save(option)
            return

        if (!option or option = 1)
            this.Content(this.TempPath)
        if !option {
            this.Mix(this.TempPath)
            this.order ++
        }
    }

    Mix(path) {
        FileRead   temp, % path
        FileAppend % temp this.Delimiter, % this.MixPath
        FileCopy   % this.MixPath, % this.HistoryDir "Temp_" this.order ".md"
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
