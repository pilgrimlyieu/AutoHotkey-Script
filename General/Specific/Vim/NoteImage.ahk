#SingleInstance Force

#Include ..\..\..\Library\Start.ahk

preventStartLaunch(A_Args)

global SNIPASTE_PATH := "D:/Software/Scoop/apps/snipaste/current/Snipaste.exe"
global COMPRESSION_CMD := "pythonw `"D:/Project/Scripts/AutoHotkey/General/Common/scripts/ImageCompression.pyw`""
global MAX_SIZE_KB := 500

transformToWindows(wslPath) {
    return "\\wsl.localhost\Ubuntu" . StrReplace(wslPath, "/", "\")
}

#HotIf WinActive("ahk_exe WindowsTerminal.exe")

^!v:: {
    local imageBaseName := A_Clipboard
    if (imageBaseName == "") {
        res := InputBox("剪贴板为空，请输入图片文件名", "输入文件名")
        if res.Result == "Cancel" || res.Value == "" {
            return
        }
        imageBaseName := res.Value
    }
    imageBaseName := RegExReplace(imageBaseName, "[\\/:\*\?" "<>| ]", "-")
    imageBaseName := RegExReplace(imageBaseName, "\.(png|jpg|jpeg|gif|bmp)$", "")

    local tempFilePath := "\\wsl.localhost\Ubuntu/tmp/vim_file_path"
    if !FileExist(tempFilePath) {
        return
    }
    local mdFullPath := Trim(FileRead(tempFilePath))
    if (mdFullPath = "") {
        return
    }
    mdFullPath := transformToWindows(mdFullPath)

    try {
        SplitPath(mdFullPath, &mdFileName, &mdDir, &mdExt, &mdNameNoExt)
        local imageSaveDir := mdDir . "\" . mdNameNoExt
        local imageSavePath := imageSaveDir . "\" . imageBaseName . ".png"
    } catch {
        return
    }

    if !DirExist(imageSaveDir) {
        DirCreate(imageSaveDir)
    }

    RunWait('"' SNIPASTE_PATH '" snip -o "' imageSavePath '"', , "Hide")

    WinWaitActive("ahk_exe Snipaste.exe", , 3)
    WinWaitNotActive("ahk_exe Snipaste.exe", , 10)
    ClipWait(0.5, 1)

    if (COMPRESSION_CMD) {
        RunWait(COMPRESSION_CMD . " `"" imageSavePath "`"", , "Hide")
    }

    try {
        local fileSizeKB := Round(FileGetSize(imageSavePath) / 1024)
        local successMsg := "图片已成功保存并压缩！`n路径：" imageSavePath "`n大小：" fileSizeKB " KB"

        if (fileSizeKB > MAX_SIZE_KB) {
            TrayTip(successMsg . "`n`n文件大小（" . fileSizeKB . " KB）超出阈值（" . MAX_SIZE_KB . " KB）！", "操作成功", "Icon!")
        } else {
            TrayTip(successMsg, "操作成功", "Iconi")
        }
    } catch {
        TrayTip("图片大小获取失败！", "操作失败", "Iconx")
    }
    SetTimer(TrayTip, -3000)
}
