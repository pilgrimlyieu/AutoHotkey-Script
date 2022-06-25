#IfWinActive ahk_exe SumatraPDF.exe

$^c::
SendInput {Ctrl Down}c{Ctrl Up}
ClipWait 0
Clipboard := RegExReplace(Clipboard, "\s*\v+\s*", "")
return

^+c::SendInput {Ctrl Down}c{Ctrl Up}
