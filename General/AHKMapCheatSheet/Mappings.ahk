#Requires AutoHotkey v1.1.36.02+
#NoTrayIcon

WorkingDir     := "G:\Assets\Tool\AutoHotkey\"
Mappings_Helps := {"Fn": "Basic\Remap\Fn"
                 , "WinDrag": "Basic\Window\WinDrag\WinDrag"
                 , "Tips": "General\Tips\Run"
                 , "Anki_ChineseKeyWord": "Specific\Anki\ChineseKeyWord"
                 , "Anki_Derive": "Specific\Anki\Derive"
                 , "Anki_Cloze": "Specific\Anki\Cloze"
                 , "Vark": "Tool\Vark\Vark"
                 , "Vanki": "Tool\Vark\Vanki"}

Alias := []
text  := "Helps:"
for index in Mappings_Helps
    Alias.Push(index)
for index, value in Alias
    text .= "`r" index ": " value

#F1::
InputBox number, Helps, %text%, , , % 100 + 20 * index , , , , 5
if !ErrorLevel
    Run % "D:/Program Files/Snipaste/Snipaste.exe paste --files " WorkingDir Mappings_Helps[Alias[number]] ".png"
return
