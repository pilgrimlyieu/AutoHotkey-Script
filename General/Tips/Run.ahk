#NoTrayIcon

#f::
    Clip := Clipboard
    Clipboard := ""
    SendInput {Ctrl Down}c{Ctrl Up}
    ClipWait 0
    selected := Trim(Clipboard)
    if (!(selected ~= "[*?""<>|]") and selected ~= "^[C-G]:(?:[\\\/].+)*[\\\/][^.]+$")
    	Run D:/Program Files/Everything/Everything.exe -parent "%selected%"
    else if (selected != "")
    	Run D:/Program Files/Everything/Everything.exe -search "%selected%"
    else
    	Run D:/Program Files/Everything/Everything.exe -home
    Clipboard := Clip
return

#s::WinMinimize A
#+s::WinMaximize A

#a::WinSet AlwaysOnTop, , A
