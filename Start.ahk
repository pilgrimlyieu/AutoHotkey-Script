Dir := A_WorkingDir "\"

Scripts := ["Tips\Run"

          , "Correction\Pinyin"

          , "Shutdown\Shutdown"

          , "Window\WinDrag\main"

          , "Vim\Vim"
          , "Vim\KeyMap"

          , "Vark\main"]

For index, script in Scripts
    Run % "AutoHotkey.exe /restart " Dir script ".ahk"
