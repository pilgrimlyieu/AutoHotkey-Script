Dir := A_WorkingDir "\"

Scripts := ["Tips\Run"
          , "Shutdown\Shutdown"
          , "Window\WinDrag\main"
          , "Remap\Fn"

          , "Correction\Pinyin"
          , "Abbreviation\Common"

          , "Vim\Vim"
          , "Vim\KeyMap"
          , "Vark\main"]

For index, script in Scripts
    Run % "AutoHotkey.exe /restart /CP65001 " Dir script ".ahk"
