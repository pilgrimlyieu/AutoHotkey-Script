#NoTrayIcon
#SingleInstance Force

global savePath := "D:/Data/Vault/00-收集"

#^s:: {
    previewText := SubStr(A_Clipboard, 1, 100)
    if (StrLen(A_Clipboard) > 100) {
        previewText .= "…"
    }

    inputObj := InputBox("预览：`n" . previewText, "保存剪贴板内容")

    if (inputObj.Result != "OK" or inputObj.Value == "") {
        return
    }

    userInput := inputObj.Value
    sanitizedInput := RegExReplace(userInput, "[\\/:\*\?" "<>| ]", "-")

    if (A_Clipboard == "") {
        MsgBoxResult := MsgBox("剪贴板为空，确定要创建一个空的笔记文件吗？", "警告", "YesNo, IconQ")
        if (MsgBoxResult == "No") {
            return
        }
    }

    currentDate := FormatTime(, "yyyy-MM-dd")

    fileName := currentDate . " " . sanitizedInput . ".md"
    fullPath := savePath . "\" . fileName

    if !DirExist(savePath) {
        try {
            DirCreate(savePath)
        } catch Error as e {
            MsgBox("创建目录失败！ `n`n路径：" . savePath . "`n错误信息：" . e.Message, "错误", "IconX")
            return
        }
    }

    try {
        FileAppend(A_Clipboard, fullPath, "UTF-8")
    } catch Error as e {
        MsgBox("文件写入失败！ `n`n路径：" . fullPath . "`n错误信息：" . e.Message, "错误", "IconX")
        return
    }
}
