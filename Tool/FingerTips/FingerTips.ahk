Global Webs := Map(
    "Baidu",  "https://www.baidu.com/s?ie=UTF-8&wd=",
    "Bing",   "https://cn.bing.com/search?q=",
    "Google", "https://www.google.com/search?q=",
)

~LButton::{
    if !(IsMoved() || KeyWait("LButton", "T0.3"))
        URLSearch()
}

$RButton::{
    if KeyWait("LButton", "D T0.05")
        WebSearch()
    else
        SendInput "{RButton}"
}

IsMoved(CheckInterval := 200) {
    MouseGetPos &X1, &Y1
    Sleep CheckInterval
    MouseGetPos &X2, &Y2
    if (X1 != X2 || Y1 != Y2)
        return 1
    return 0
}

GetSelected() {
    ClipSaved := ClipboardAll()
    A_Clipboard := ""
    Send "{Ctrl Down}c{Ctrl Up}"
    if ClipWait(0.5, 0)
        content := A_Clipboard
    else
        content := ""
    A_Clipboard := ClipSaved
    ClipSaved := ""
    return content
}

URLSearch() {
    ClipContent := GetSelected()
    if Trim(ClipContent) ~= "^((https?|ftp|rtsp|mms)?:\/\/)?(([0-9a-zA-Z_!~*'().&=+$%-]+: )?[0-9a-zA-Z_!~*'().&=+$%-]+@)?(([0-9]{1,3}\.){3}[0-9]{1,3}|([0-9a-zA-Z_!~*'()-]+\.)*([0-9a-zA-Z][0-9a-zA-Z-]{0,61})?[0-9a-zA-Z]\.[a-zA-Z]{2,6})(:[0-9]{1,4})?((\/?)|(\/[0-9a-zA-Z_!~*'().;?:@&=+$,%#-]+)+\/?)$"
        Run "C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe " Trim(ClipContent)
    return
}

WebSearch(Web := "Baidu") {
    ClipContent := GetSelected()
    Run "C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe " Webs[Web] Trim(ClipContent)
}