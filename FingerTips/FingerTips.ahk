Global Webs := {"Baidu": "https://www.baidu.com/s?ie=UTF-8&wd=", "Bing": "https://cn.bing.com/search?q=", "Google": "https://www.google.com/search?q="}

~LButton::
    if Moving()
        return
    KeyWait LButton, T0.3
    if ErrorLevel
        URLSearch()
return

$RButton::
    KeyWait, LButton, DT0.1
    if !ErrorLevel
        WebSearch()
    else
        Send {RButton}
return

Moving(CheckInterval := 200) {
    MouseGetPos, X1, Y1
    Sleep %CheckInterval%
    MouseGetPos, X2, Y2
    if !(X1 = X2 and Y1 = Y2)
        return 1
    return 0
}

GetClipboard() {
    clipboard := ""
    Send {Ctrl Down}c{Ctrl Up}
    ClipWait 1
    if !ErrorLevel
        return
}

URLSearch() {
    GetClipboard()
    if Trim(clipboard) ~= "^((https?|ftp|rtsp|mms)?://)?(([0-9a-zA-Z_!~*'().&=+$%-]+: )?[0-9a-zA-Z_!~*'().&=+$%-]+@)?(([0-9]{1,3}\.){3}[0-9]{1,3}|([0-9a-zA-Z_!~*'()-]+\.)*([0-9a-zA-Z][0-9a-zA-Z-]{0,61})?[0-9a-zA-Z]\.[a-zA-Z]{2,6})(:[0-9]{1,4})?((/?)|(/[0-9a-zA-Z_!~*'().;?:@&=+$,%#-]+)+/?)$"
        Run % "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe " Trim(clipboard)
    return
}

WebSearch(Web := "Baidu") {
    GetClipboard()
    Run % "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe " Webs[Web] Trim(clipboard)
}