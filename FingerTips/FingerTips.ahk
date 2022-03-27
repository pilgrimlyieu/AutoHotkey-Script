~LButton::
    MouseGetPos, X1, Y1
    Sleep 100
    MouseGetPos, X2, Y2
    if !(X1 = X2 and Y1 = Y2)
        return
    KeyWait LButton, T0.4
    if errorLevel = 1
        ClipboardAnalyze()
return

ClipboardAnalyze() {
    clipboard := ""
    Send {Ctrl Down}c{Ctrl Up}
    ClipWait 1
    if Trim(clipboard) ~= "^((https?|ftp|rtsp|mms)?://)?(([0-9a-zA-Z_!~*'().&=+$%-]+: )?[0-9a-zA-Z_!~*'().&=+$%-]+@)?(([0-9]{1,3}\.){3}[0-9]{1,3}|([0-9a-zA-Z_!~*'()-]+\.)*([0-9a-zA-Z][0-9a-zA-Z-]{0,61})?[0-9a-zA-Z]\.[a-zA-Z]{2,6})(:[0-9]{1,4})?((/?)|(/[0-9a-zA-Z_!~*'().;?:@&=+$,%#-]+)+/?)$"
        Run % "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe " Trim(clipboard)
}