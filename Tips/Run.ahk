#NoTrayIcon

#f::
    Clip := Clipboard
    Clipboard := ""
    Send {Ctrl Down}c{Ctrl Up}
    Clipboard := Trim(Clipboard)
    if (!(Clipboard ~= "[*?""<>|]") and Clipboard ~= "^[C-G]:(?:[\\/].+)*[\\/][^.]+$")
    	Run D:/Program Files/Everything/Everything.exe -path %Clipboard%
    else if (Clipboard != "")
    	Run D:/Program Files/Everything/Everything.exe -search "%Clipboard%"
    else
    	Run D:/Program Files/Everything/Everything.exe -home
    Clipboard := Clip
return

#s::WinMinimize A

#a::WinSet AlwaysOnTop, , A
