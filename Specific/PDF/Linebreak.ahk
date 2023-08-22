#HotIf WinActive("ahk_exe SumatraPDF.exe")

$^c::{
    SendInput("{Ctrl Down}c{Ctrl Up}")
    ClipWait(0.5, 0)
    A_Clipboard := RegExReplace(A_Clipboard, "\s*\v+\s*", "")
}

^+c::SendInput("{Ctrl Down}c{Ctrl Up}")